/**
 * Shared taxi/TM platform payment API (driver app today; passenger clients later).
 * Direct charges on BookaWaka platform Stripe account — no Connect destination.
 */
import { Router } from 'express';
import { fbWriteP } from '../firebase';
import { getStripe } from '../utils';
import { requirePaymentAuth } from '../lib/paymentAuth';
import {
  planChargeRefund,
  splitPlatformFee,
  type PaymentClientChannel,
  type PlatformChargeLedger,
  type RefundDestination,
} from '../lib/platformPayments';

const router = Router();

function feePercentFromEnv(): number {
  const n = Number(process.env.BOOKAWAKA_TAP_FEE_PERCENT);
  return Number.isFinite(n) && n >= 0 ? n : 0;
}

/** POST /api/payments/terminal/connection-token — Stripe Terminal SDK bootstrap */
router.post('/api/payments/terminal/connection-token', async (req, res) => {
  const auth = await requirePaymentAuth(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  try {
    if (!process.env.STRIPE_SECRET_KEY) {
      return res.status(503).json({ error: 'STRIPE_SECRET_KEY not configured' });
    }
    const stripe = getStripe();
    const token = await stripe.terminal.connectionTokens.create();
    res.json({ ok: true, secret: token.secret });
  } catch (e: any) {
    console.error('[payments] connection-token', e?.message || e);
    res.status(500).json({ error: e?.message || 'connection token failed' });
  }
});

/**
 * POST /api/payments/tap/create-intent
 * Body: { amountCents, companyId, bookingId?, driverId?, clientChannel?, currency? }
 */
router.post('/api/payments/tap/create-intent', async (req, res) => {
  const auth = await requirePaymentAuth(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  try {
    if (!process.env.STRIPE_SECRET_KEY) {
      return res.status(503).json({ error: 'STRIPE_SECRET_KEY not configured' });
    }
    const amountCents = Math.round(Number(req.body?.amountCents) || 0);
    const companyId = String(req.body?.companyId || '').trim();
    if (!companyId || amountCents < 1) {
      return res.status(400).json({ error: 'companyId and amountCents required' });
    }
    const bookingId = req.body?.bookingId ? String(req.body.bookingId) : null;
    const driverId = req.body?.driverId ? String(req.body.driverId) : null;
    const clientChannel = String(req.body?.clientChannel || 'driver_app') as PaymentClientChannel;
    const currency = String(req.body?.currency || 'nzd').toLowerCase();
    const split = splitPlatformFee({
      amountCents,
      platformFeePercent: feePercentFromEnv(),
    });

    const stripe = getStripe();
    const pi = await stripe.paymentIntents.create({
      amount: split.amountCents,
      currency,
      payment_method_types: ['card_present'],
      capture_method: 'automatic',
      metadata: {
        companyId,
        bookingId: bookingId || '',
        driverId: driverId || '',
        clientChannel,
        actorUid: auth.uid,
        platformFeeCents: String(split.platformFeeCents),
        companyNetCents: String(split.companyNetCents),
        vertical: 'taxi',
        method: 'tap_to_pay',
      },
    });

    res.json({
      ok: true,
      paymentIntentId: pi.id,
      clientSecret: pi.client_secret,
      ...split,
      currency,
    });
  } catch (e: any) {
    console.error('[payments] create-intent', e?.message || e);
    res.status(500).json({ error: e?.message || 'create intent failed' });
  }
});

/** POST /api/payments/tap/record-ledger */
router.post('/api/payments/tap/record-ledger', async (req, res) => {
  const auth = await requirePaymentAuth(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  try {
    const paymentIntentId = String(req.body?.paymentIntentId || '').trim();
    const companyId = String(req.body?.companyId || '').trim();
    const amountCents = Math.round(Number(req.body?.amountCents) || 0);
    if (!paymentIntentId || !companyId || amountCents < 1) {
      return res.status(400).json({ error: 'paymentIntentId, companyId, amountCents required' });
    }
    const split = splitPlatformFee({
      amountCents,
      platformFeePercent:
        req.body?.platformFeePercent != null
          ? Number(req.body.platformFeePercent)
          : feePercentFromEnv(),
    });
    const ledger: PlatformChargeLedger = {
      chargeId: String(req.body?.chargeId || paymentIntentId),
      paymentIntentId,
      companyId,
      bookingId: req.body?.bookingId ? String(req.body.bookingId) : null,
      driverId: req.body?.driverId ? String(req.body.driverId) : null,
      amountCents: split.amountCents,
      platformFeeCents: split.platformFeeCents,
      companyNetCents: split.companyNetCents,
      currency: 'nzd',
      method: 'tap_to_pay',
      clientChannel: String(req.body?.clientChannel || 'driver_app') as PaymentClientChannel,
      createdAt: Date.now(),
      passengerUid: req.body?.passengerUid ? String(req.body.passengerUid) : null,
    };
    await fbWriteP('PUT', `platformPaymentLedger/${companyId}/${paymentIntentId}`, {
      ...ledger,
      recordedByUid: auth.uid,
    });
    res.json({ ok: true, ledger });
  } catch (e: any) {
    console.error('[payments] record-ledger', e?.message || e);
    res.status(500).json({ error: e?.message || 'record ledger failed' });
  }
});

/**
 * POST /api/payments/tap/refund
 * destination: original_card | passenger_wallet (wallet credit not implemented yet)
 */
router.post('/api/payments/tap/refund', async (req, res) => {
  const auth = await requirePaymentAuth(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  try {
    const paymentIntentId = String(req.body?.paymentIntentId || '').trim();
    const companyId = String(req.body?.companyId || '').trim();
    const destination = String(req.body?.destination || 'original_card') as RefundDestination;
    if (!paymentIntentId || !companyId) {
      return res.status(400).json({ error: 'paymentIntentId and companyId required' });
    }

    const ledger: PlatformChargeLedger = {
      chargeId: String(req.body?.chargeId || paymentIntentId),
      paymentIntentId,
      companyId,
      amountCents: Math.round(Number(req.body?.amountCents) || 0),
      platformFeeCents: Math.round(Number(req.body?.platformFeeCents) || 0),
      companyNetCents: Math.round(Number(req.body?.companyNetCents) || 0),
      currency: 'nzd',
      method: 'tap_to_pay',
      clientChannel: 'driver_app',
      createdAt: Date.now(),
      passengerUid: req.body?.passengerUid ? String(req.body.passengerUid) : null,
    };
    if (ledger.amountCents < 1) {
      return res.status(400).json({ error: 'amountCents required' });
    }

    const plan = planChargeRefund({
      ledger,
      destination,
      amountCents:
        req.body?.refundAmountCents != null ? Number(req.body.refundAmountCents) : undefined,
    });

    if (plan.destination === 'passenger_wallet') {
      return res.status(501).json({
        ok: false,
        error: 'passenger_wallet refund not implemented yet',
        plan,
      });
    }

    if (!process.env.STRIPE_SECRET_KEY) {
      return res.status(503).json({ error: 'STRIPE_SECRET_KEY not configured' });
    }
    const stripe = getStripe();
    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      amount: plan.amountCents,
    });
    await fbWriteP('PUT', `platformPaymentRefunds/${companyId}/${refund.id}`, {
      ...plan,
      refundId: refund.id,
      status: refund.status,
      createdAt: Date.now(),
      refundedByUid: auth.uid,
    });
    res.json({ ok: true, refundId: refund.id, status: refund.status, plan });
  } catch (e: any) {
    console.error('[payments] refund', e?.message || e);
    res.status(500).json({ error: e?.message || 'refund failed' });
  }
});

export default router;
