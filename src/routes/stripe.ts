import { Router } from 'express';
import { fbReadP, fbWriteP } from '../firebase';
import { getStripe } from '../utils';

const router = Router();

/* ── Stripe Webhook (must be raw body) ─────────────────────────────────────── */
router.post('/api/stripe/webhook', (req, res, next) => {
  if ((req as any)._rawBodyParsed) return next();
  let data = '';
  req.on('data', chunk => data += chunk);
  req.on('end', async () => {
    const sig = req.headers['stripe-signature'] as string;
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    let event: any;
    try {
      if (webhookSecret && sig) {
        const stripe = getStripe();
        event = stripe.webhooks.constructEvent(Buffer.from(data), sig, webhookSecret);
      } else {
        event = JSON.parse(data);
      }
    } catch (err: any) {
      console.error('[stripe-webhook] signature error:', err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    try {
      if (event.type === 'checkout.session.completed') {
        const session = event.data.object;
        const { cid: cidMeta, companyId: companyIdMeta, invoiceId, type } = session.metadata || {};
        const cid = cidMeta || companyIdMeta;   // booking site sends companyId; SA portal sends cid
        if (type === 'subscription_invoice' && cid && invoiceId) {
          const paidAt = Date.now();
          await fbWriteP('PATCH', `superBilling/${cid}/invoices/${invoiceId}`, {
            status: 'paid', paidAt, paidVia: 'stripe',
            stripeSessionId: session.id,
            stripePaymentIntent: session.payment_intent || null
          });
          // Keep superClients status in sync so dispatch app trial banner clears
          await fbWriteP('PATCH', `superClients/${cid}`, {
            subscriptionStatus: 'paid', status: 'active', lastStripeChargeId: session.payment_intent || null, lastBilledAt: paidAt
          });
          console.log(`[stripe-webhook] Invoice ${invoiceId} for company ${cid} marked paid — superClients status set to active`);
        }
        if (type === 'booking_payment' && cid) {
          // OWNERSHIP SPLIT (agreed 2026-05-07 with web booking team):
          // The web booking site's webhook owns: Status transition, pendingjobs push,
          // paidAt, stripeSessionId. That webhook is the dispatch trigger.
          //
          // The SA portal webhook owns ONLY: stripeConfirmedFare + paymentStatus/paymentMethod.
          // - stripeConfirmedFare is write-once and never touched by any other system.
          //   Our sync endpoints read it to restore the correct fare after the driver app
          //   overwrites allbookings.fare with the meter reading at completion.
          // - paymentStatus:'paid' + paymentMethod:'card' are written here as a safety net
          //   so our sync guard (which checks paymentStatus==='paid') always activates
          //   even if the web booking webhook fails.
          // These are all PATCH writes — no conflict with the web booking webhook.
          // We intentionally do NOT write to pendingjobs (web booking webhook owns that).
          const bookingId = session.metadata.bookingId;
          const booking = await fbReadP(`allbookings/${cid}/${bookingId}`);
          const fareAmt = parseFloat(booking?.Fare || booking?.fare || (session.amount_total ?? 0) / 100 || 0) || 0;
          await fbWriteP('PATCH', `allbookings/${cid}/${bookingId}`, {
            stripeConfirmedFare: fareAmt,
            paymentStatus: 'paid',
            paymentMethod: 'card',
          });
          console.log(`[stripe-webhook] booking_payment ${bookingId} cid=${cid} — stamped stripeConfirmedFare=${fareAmt} (pendingjobs owned by web booking webhook)`);
        }
      }
      if (event.type === 'payment_intent.payment_failed') {
        const pi = event.data.object;
        const { cid, invoiceId, vid } = pi.metadata || {};
        if (cid && invoiceId) {
          await fbWriteP('PATCH', `superBilling/${cid}/invoices/${invoiceId}`, {
            stripeLastError: pi.last_payment_error?.message || 'Payment failed'
          });
        }
        if (cid && vid && !invoiceId) {
          const idx = await fbReadP('rentalPaymentIntentIndex/' + pi.id);
          if (idx) {
            await fbWriteP('PATCH', `rentalReservations/${idx.cid}/${idx.reservationId}`, {
              status: 'payment_failed', paymentFailedAt: Date.now(),
              paymentFailNote: pi.last_payment_error?.message || 'Payment failed', updatedAt: Date.now()
            });
            console.log('[stripe-webhook] rental PI failed:', pi.id);
          }
        }
      }
      if (event.type === 'charge.refunded') {
        const charge = event.data.object;
        const piId = typeof charge.payment_intent === 'string' ? charge.payment_intent : null;
        if (piId) {
          const idx = await fbReadP('rentalPaymentIntentIndex/' + piId);
          if (idx) {
            await fbWriteP('PATCH', `rentalReservations/${idx.cid}/${idx.reservationId}`, {
              'refund.status': 'refunded', 'refund.refundedAt': Date.now(),
              'refund.amount': (charge.amount_refunded || 0) / 100, updatedAt: Date.now()
            });
            console.log('[stripe-webhook] rental charge refunded:', charge.id);
          }
        }
      }
    } catch (err: any) {
      console.error('[stripe-webhook] handler error:', err.message);
    }
    res.json({ received: true });
  });
});

/* ── Create Stripe Checkout Session for a company invoice ──────────────────── */
router.post('/api/stripe/create-invoice-checkout', async (req, res) => {
  try {
    const { cid, invoiceId, companyName, email, period, amount } = req.body;
    if (!cid || !invoiceId || !amount) return res.status(400).json({ error: 'cid, invoiceId and amount required' });
    const stripe = getStripe();
    const amountCents = Math.round(Number(amount) * 100);
    if (amountCents < 50) return res.status(400).json({ error: 'Amount too small (min $0.50)' });
    const baseUrl = `https://${(process.env.REPLIT_DOMAINS || '').split(',')[0]}`;
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'payment',
      customer_email: email || undefined,
      line_items: [{
        price_data: {
          currency: 'nzd', unit_amount: amountCents,
          product_data: { name: `BookaWaka Subscription — ${period || 'Invoice'}`, description: `Company: ${companyName || cid} | Invoice ID: ${invoiceId}` }
        }, quantity: 1
      }],
      metadata: { cid, invoiceId, type: 'subscription_invoice', companyName: companyName || cid },
      success_url: `${baseUrl}/SA-Billing.aspx?stripe=success&cid=${cid}&inv=${invoiceId}`,
      cancel_url: `${baseUrl}/SA-Billing.aspx?stripe=cancel&cid=${cid}`
    });
    await fbWriteP('PATCH', `superBilling/${cid}/invoices/${invoiceId}`, {
      stripeSessionId: session.id, stripeStatus: 'pending', stripeCreatedAt: Date.now()
    });
    res.json({ ok: true, url: session.url, sessionId: session.id });
  } catch (err: any) {
    console.error('[stripe] create-invoice-checkout error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ── Check Stripe session status ───────────────────────────────────────────── */
router.get('/api/stripe/session-status', async (req, res) => {
  try {
    const { sessionId } = req.query;
    if (!sessionId) return res.status(400).json({ error: 'sessionId required' });
    const stripe = getStripe();
    const session = await stripe.checkout.sessions.retrieve(sessionId as string);
    res.json({ status: session.payment_status, sessionId: session.id, metadata: session.metadata });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

/* ── Create Stripe Checkout for a passenger booking payment ────────────────── */
router.post('/api/stripe/create-booking-payment', async (req, res) => {
  try {
    const { cid, bookingId, description, amount, email, currency } = req.body;
    if (!cid || !bookingId || !amount) return res.status(400).json({ error: 'cid, bookingId and amount required' });
    const stripe = getStripe();
    const amountCents = Math.round(Number(amount) * 100);
    const cur = (currency || 'nzd').toLowerCase();
    const baseUrl = `https://${(process.env.REPLIT_DOMAINS || '').split(',')[0]}`;
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'], mode: 'payment',
      customer_email: email || undefined,
      line_items: [{
        price_data: { currency: cur, unit_amount: amountCents, product_data: { name: description || 'BookaWaka Booking Payment', description: `Booking ID: ${bookingId}` } },
        quantity: 1
      }],
      metadata: { cid, bookingId, type: 'booking_payment' },
      success_url: `${baseUrl}/payment-success?booking=${bookingId}&cid=${cid}`,
      cancel_url: `${baseUrl}/payment-cancel?booking=${bookingId}&cid=${cid}`
    });
    res.json({ ok: true, url: session.url, sessionId: session.id });
  } catch (err: any) {
    console.error('[stripe] create-booking-payment error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ── Booking payment success page ──────────────────────────────────────────── */
router.get('/payment-success', (req, res) => {
  const { booking, cid } = req.query;
  res.setHeader('Content-Type', 'text/html');
  res.end(`<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Payment Confirmed — BookaWaka</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f0f4f8; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
  .card { background: #fff; border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,.08); padding: 48px 40px; max-width: 480px; width: 100%; text-align: center; }
  .icon { width: 72px; height: 72px; background: #e8f5e9; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; font-size: 36px; }
  h1 { font-size: 24px; font-weight: 700; color: #1b5e20; margin-bottom: 12px; }
  p { color: #555; font-size: 15px; line-height: 1.6; margin-bottom: 8px; }
  .ref { background: #f5f5f5; border-radius: 8px; padding: 12px 16px; margin: 20px 0; font-family: monospace; font-size: 14px; color: #333; word-break: break-all; }
  .note { font-size: 13px; color: #888; margin-top: 16px; }
  .btn { display: inline-block; margin-top: 28px; padding: 12px 32px; background: #1565C0; color: #fff; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 15px; }
</style>
</head>
<body>
<div class="card">
  <div class="icon">✅</div>
  <h1>Payment Confirmed</h1>
  <p>Your booking payment has been received successfully.</p>
  ${booking ? `<div class="ref">Booking reference: <strong>${String(booking).replace(/[<>&"]/g, '')}</strong></div>` : ''}
  <p>Your driver has been notified and will be with you shortly.</p>
  <p class="note">A receipt has been sent to your email address.</p>
</div>
</body>
</html>`);
});

/* ── Booking payment cancel page ───────────────────────────────────────────── */
router.get('/payment-cancel', (req, res) => {
  const { booking } = req.query;
  res.setHeader('Content-Type', 'text/html');
  res.end(`<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Payment Cancelled — BookaWaka</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f0f4f8; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
  .card { background: #fff; border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,.08); padding: 48px 40px; max-width: 480px; width: 100%; text-align: center; }
  .icon { width: 72px; height: 72px; background: #fff3e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; font-size: 36px; }
  h1 { font-size: 24px; font-weight: 700; color: #e65100; margin-bottom: 12px; }
  p { color: #555; font-size: 15px; line-height: 1.6; margin-bottom: 8px; }
  .ref { background: #f5f5f5; border-radius: 8px; padding: 12px 16px; margin: 20px 0; font-family: monospace; font-size: 14px; color: #333; word-break: break-all; }
  .note { font-size: 13px; color: #888; margin-top: 16px; }
  .btn { display: inline-block; margin-top: 28px; padding: 12px 32px; background: #1565C0; color: #fff; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 15px; }
</style>
</head>
<body>
<div class="card">
  <div class="icon">⚠️</div>
  <h1>Payment Cancelled</h1>
  <p>Your payment was not completed. Your booking has still been received by dispatch.</p>
  ${booking ? `<div class="ref">Booking reference: <strong>${String(booking).replace(/[<>&"]/g, '')}</strong></div>` : ''}
  <p>You can pay the driver directly on arrival, or try again using the link in your confirmation.</p>
  <p class="note">If you need help, please contact your taxi company directly.</p>
</div>
</body>
</html>`);
});

/* ── Get Stripe public key ─────────────────────────────────────────────────── */
router.get('/api/stripe/config', (_req, res) => {
  const pk = process.env.STRIPE_PUBLISHABLE_KEY;
  if (!pk) return res.status(500).json({ error: 'Stripe not configured' });
  res.json({ publishableKey: pk, mode: pk.includes('_test_') ? 'test' : 'live' });
});

/* ── List recent Stripe payments ───────────────────────────────────────────── */
router.get('/api/stripe/recent-payments', async (_req, res) => {
  try {
    const stripe = getStripe();
    const sessions = await stripe.checkout.sessions.list({ limit: 20 });
    const payments = sessions.data.map((s: any) => ({
      id: s.id, status: s.payment_status,
      amount: s.amount_total ? (s.amount_total / 100).toFixed(2) : '—',
      currency: s.currency, customerEmail: s.customer_email,
      created: s.created, metadata: s.metadata
    }));
    res.json({ ok: true, payments });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
