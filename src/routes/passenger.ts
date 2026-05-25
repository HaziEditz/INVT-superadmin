import { Router } from 'express';
import { fbReadP, fbWriteP } from '../firebase';
import { getResendClient, getStripe } from '../utils';
import { generateJobId } from '../jobId';
import { rentDays, rentIsAvailable, rentCalcPricing } from '../rentalHelpers';
import crypto from 'crypto';

const router = Router();

// Controlled cancel-reason list (locked 2026-05-18).
// Stored in Firebase as a fixed code so reporting can group cleanly.
// `other` is the only one that accepts a free-text `cancelDetails` field.
const CANCEL_REASONS = [
  'changed_plans',
  'waited_too_long',
  'found_another_ride',
  'booked_by_mistake',
  'driver_too_far',
  'price_too_high',
  'vehicle_issue',
  'other'
] as const;
type CancelReason = typeof CANCEL_REASONS[number];

function normalizeCancelReason(input: any): { reason: CancelReason; details: string } {
  const raw = String(input || '').trim().toLowerCase();
  const reason: CancelReason = (CANCEL_REASONS as readonly string[]).includes(raw)
    ? (raw as CancelReason)
    : 'other';
  return { reason, details: '' };
}

// ─────────────────────────────────────────────────────────────────────────────
// TOWING
// ─────────────────────────────────────────────────────────────────────────────

router.get('/api/passenger/towing/config', async (_req, res) => {
  try {
    const cfg = await fbReadP('bwConfig/towing') || {};
    res.json({
      ok: true,
      baseCalloutFee: parseFloat(cfg.baseCalloutFee) || 95,
      currency: 'NZD',
      problems: [
        'Flat Tyre', 'Dead Battery', 'Lockout', 'Engine Breakdown',
        'Accident Recovery', 'Fuel Delivery', 'Overheating', 'Other'
      ],
      paymentTypes: ['cash', 'card_on_arrival', 'stripe', 'insurance'],
      scheduleOptions: ['now', 'scheduled']
    });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

router.post('/api/passenger/towing/payment-intent', async (_req, res) => {
  try {
    const stripe = getStripe();
    const cfg = await fbReadP('bwConfig/towing') || {};
    const baseFeeCents = Math.round((parseFloat(cfg.baseCalloutFee) || 95) * 100);
    const pi = await stripe.paymentIntents.create({
      amount: baseFeeCents,
      currency: 'nzd',
      description: 'BookaWaka Towing — Base Callout Fee',
      metadata: { source: 'passenger_app', createdAt: String(Date.now()) }
    });
    res.json({ ok: true, clientSecret: pi.client_secret, amountCents: baseFeeCents, publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || '' });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

router.post('/api/passenger/towing/request', async (req, res) => {
  try {
    const {
      customerName, customerPhone, customerEmail,
      pickup, dropoff, vehicleMake, vehicleModel, vehicleYear, vehicleColour, vehicleRego,
      problem, problemNotes, paymentType, schedule, scheduledAt,
      insuranceCompany, policyNo, thirdPartyInsurer, thirdPartyPolicy,
      thirdPartyPlate, policeReportNo, stripePaymentIntentId
    } = req.body;

    if (!customerName || !customerPhone || !pickup || !dropoff || !vehicleMake || !vehicleModel || !problem || !paymentType) {
      return res.status(400).json({ ok: false, error: 'Missing required fields: customerName, customerPhone, pickup, dropoff, vehicleMake, vehicleModel, problem, paymentType' });
    }

    const now = Date.now();
    const jobId = `TW${now}`;
    const record: any = {
      jobId, source: 'passenger_app',
      customerName, customerPhone, customerEmail: customerEmail || '',
      pickup, dropoff,
      vehicleMake, vehicleModel,
      vehicleYear: vehicleYear || '', vehicleColour: vehicleColour || '', vehicleRego: vehicleRego || '',
      problem, problemNotes: problemNotes || '',
      paymentType, schedule: schedule || 'now', scheduledAt: scheduledAt || null,
      insuranceCompany: insuranceCompany || '', policyNo: policyNo || '',
      thirdPartyInsurer: thirdPartyInsurer || '', thirdPartyPolicy: thirdPartyPolicy || '',
      thirdPartyPlate: thirdPartyPlate || '', policeReportNo: policeReportNo || '',
      status: 'pending', createdAt: now, updatedAt: now
    };

    await fbWriteP('PUT', `towingJobs/unassigned/${jobId}`, record);
    await fbWriteP('PUT', `towingJobIndex/${jobId}`, { companyId: 'unassigned', createdAt: now, status: 'pending', paymentType });

    setImmediate(async () => {
      try {
        if (paymentType === 'stripe' && stripePaymentIntentId) {
          const stripe = getStripe();
          const pi = await stripe.paymentIntents.retrieve(stripePaymentIntentId);
          const confirmed = pi.status === 'succeeded';
          await fbWriteP('PATCH', `towingJobs/unassigned/${jobId}`, { paymentConfirmed: confirmed, paymentStatus: pi.status, stripePaymentIntentId });
          await fbWriteP('PATCH', `towingJobIndex/${jobId}`, { paymentConfirmed: confirmed });
        }
      } catch (ve: any) { console.error('[passenger/tow-verify]', ve.message); }
      try {
        const { client: rc, fromEmail } = await getResendClient();
        const dtStr = new Date(now).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
        const baseUrl = 'https://' + (process.env.REPLIT_DOMAINS || '').split(',')[0];
        await rc.emails.send({
          from: fromEmail, to: fromEmail,
          subject: `🚛 New Tow Request (App) — ${record.customerName} — ${record.problem}`,
          html: `<div style="font-family:sans-serif;max-width:520px"><h2 style="color:#E65100">🚛 New Tow Request — Passenger App</h2><p style="color:#888;font-size:13px">${dtStr} NZT &bull; Job ID: <code>${jobId}</code></p><table style="width:100%;border-collapse:collapse;font-size:14px"><tr><td style="padding:6px 0;color:#555;width:130px">Customer</td><td style="font-weight:600">${record.customerName} — ${record.customerPhone}</td></tr><tr><td style="padding:6px 0;color:#555">Pickup</td><td>${record.pickup}</td></tr><tr><td style="padding:6px 0;color:#555">Drop-off</td><td>${record.dropoff}</td></tr><tr><td style="padding:6px 0;color:#555">Vehicle</td><td>${record.vehicleYear} ${record.vehicleMake} ${record.vehicleModel}${record.vehicleRego ? ' (' + record.vehicleRego + ')' : ''}</td></tr><tr><td style="padding:6px 0;color:#555">Problem</td><td style="font-weight:600;color:#C62828">${record.problem}${record.problemNotes ? ' — ' + record.problemNotes : ''}</td></tr><tr><td style="padding:6px 0;color:#555">Payment</td><td>${(record.paymentType||'').toUpperCase()}</td></tr></table><div style="margin-top:18px"><a href="${baseUrl}/SA-Towing.aspx#unassigned" style="background:#E65100;color:#fff;padding:10px 20px;border-radius:6px;text-decoration:none;font-weight:600">Assign Job Now →</a></div></div>`
        });
      } catch (emailErr: any) { console.error('[passenger/tow-notify]', emailErr.message); }
    });

    const trackUrl = `https://taxitime.co.nz/tow/track?id=${jobId}`;
    res.json({ ok: true, jobId, trackUrl, message: 'Tow request submitted. We will assign a truck shortly.' });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

router.get('/api/passenger/towing/track/:jobId', async (req, res) => {
  try {
    const jobId = (req.params.jobId || '').trim();
    if (!jobId) return res.status(400).json({ ok: false, error: 'jobId required' });

    const idx = await fbReadP(`towingJobIndex/${jobId}`);
    if (!idx) return res.status(404).json({ ok: false, error: 'Job not found' });

    const cid = idx.companyId || 'unassigned';
    const jobPath = cid === 'unassigned' ? `towingJobs/unassigned/${jobId}` : `towingJobs/${cid}/${jobId}`;
    const [job, access] = await Promise.all([
      fbReadP(jobPath).then((d: any) => d || {}),
      cid !== 'unassigned' ? fbReadP(`towingPortalAccess/${cid}`).then((d: any) => d || {}) : Promise.resolve({})
    ]);

    const status = job.status || idx.status || 'pending';
    const statusOrder = ['pending', 'assigned', 'enroute', 'arrived', 'loading', 'dropoff', 'completed', 'cancelled'];
    const statusIdx = statusOrder.indexOf(status);
    const steps = statusOrder.map(s => ({
      key: s,
      done: statusOrder.indexOf(s) < statusIdx,
      active: s === status
    }));

    const fmtDt = (ts: number) => ts ? new Date(ts).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' }) : null;

    // Towing cancellation policy + canCancel flag. Default: pending/assigned only.
    // Operator can override per-company under bwConfig/towing/cancellationPolicy.
    const towCfg = await fbReadP('bwConfig/towing').catch(() => null) || {};
    const cancellablePre = ['pending', 'assigned'];
    const canCancel = cancellablePre.includes(status);
    const cancellationPolicy = {
      text: (towCfg.cancellationPolicy && String(towCfg.cancellationPolicy)) ||
        'Free cancellation before a driver is dispatched to your location. Once the driver is en route or has arrived, cancellation may incur a callout fee.',
      cancellableStatuses: cancellablePre,
      currentlyCancellable: canCancel
    };

    res.json({
      ok: true,
      jobId,
      status,
      statusIndex: statusIdx,
      steps,
      company: cid !== 'unassigned' ? { id: cid, name: (access as any).name || cid, phone: (access as any).phone || null } : null,
      companyPhone: cid !== 'unassigned' ? ((access as any).phone || null) : null,
      driver: job.driverName ? { name: job.driverName, phone: job.driverPhone || null } : null,
      job: {
        pickup: job.pickup, dropoff: job.dropoff,
        problem: job.problem, problemNotes: job.problemNotes || '',
        vehicleMake: job.vehicleMake, vehicleModel: job.vehicleModel,
        vehicleYear: job.vehicleYear || '', vehicleRego: job.vehicleRego || '',
        schedule: job.schedule || 'now', scheduledAt: job.scheduledAt || null,
        paymentType: job.paymentType,
        createdAt: job.createdAt, updatedAt: job.updatedAt,
        createdAtFormatted: fmtDt(job.createdAt),
        updatedAtFormatted: fmtDt(job.updatedAt)
      },
      canCancel,
      cancellationPolicy,
      trackUrl: `https://taxitime.co.nz/tow/track?id=${jobId}`
    });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// POST /api/passenger/towing/cancel/:jobId
// Body: { customerPhone } — last-4-digit match against the phone on file (auth)
// Only allowed while job is still in 'pending' or 'assigned' state.
// Refunds Stripe pre-payment if present, releases unassigned slot, notifies company.
router.post('/api/passenger/towing/cancel/:jobId', async (req, res) => {
  try {
    const jobId = (req.params.jobId || '').trim();
    const { customerPhone, reason, cancelDetails } = req.body || {};
    if (!jobId) return res.status(400).json({ ok: false, error: 'jobId required' });
    if (!customerPhone) return res.status(400).json({ ok: false, error: 'customerPhone required for verification' });
    const { reason: cancelReasonCode } = normalizeCancelReason(reason);
    const cancelDetailsStr = cancelReasonCode === 'other'
      ? String(cancelDetails || '').slice(0, 500)
      : '';

    const idx = await fbReadP(`towingJobIndex/${jobId}`);
    if (!idx) return res.status(404).json({ ok: false, error: 'Job not found' });

    const cid = idx.companyId || 'unassigned';
    const jobPath = cid === 'unassigned' ? `towingJobs/unassigned/${jobId}` : `towingJobs/${cid}/${jobId}`;
    const job: any = await fbReadP(jobPath);
    if (!job) return res.status(404).json({ ok: false, error: 'Job not found' });

    // Phone auth — match last 4 digits to defeat formatting differences (+64, spaces, etc.)
    const onFile = String(job.customerPhone || '').replace(/\D/g, '');
    const supplied = String(customerPhone || '').replace(/\D/g, '');
    if (!onFile || !supplied || onFile.slice(-4) !== supplied.slice(-4)) {
      return res.status(403).json({ ok: false, error: 'Phone number does not match the booking on file' });
    }

    const status = job.status || idx.status || 'pending';
    const cancellable = ['pending', 'assigned'];
    if (!cancellable.includes(status)) {
      return res.status(409).json({ ok: false, error: `Cannot cancel — job status is "${status}". Please call the operator directly.` });
    }
    if (status === 'cancelled') {
      return res.status(409).json({ ok: false, error: 'Job is already cancelled' });
    }

    // Refund Stripe pre-payment if present
    let refundNote = '';
    if (job.paymentType === 'stripe' && job.stripePaymentIntentId && job.paymentConfirmed) {
      try {
        const stripe = getStripe();
        await stripe.refunds.create({ payment_intent: job.stripePaymentIntentId });
        refundNote = 'Callout fee refunded to your card. ';
      } catch (se: any) {
        console.error('[passenger/tow-cancel] refund', se.message);
        refundNote = 'Refund attempted but failed (' + se.message + ') — please contact us. ';
      }
    }

    const now = Date.now();
    const patch = {
      status: 'cancelled',
      cancelledAt: now,
      cancelledBy: 'passenger_app',
      cancelReason: cancelReasonCode,
      cancelDetails: cancelDetailsStr,
      updatedAt: now
    };
    await Promise.all([
      fbWriteP('PATCH', jobPath, patch),
      fbWriteP('PATCH', `towingJobIndex/${jobId}`, { status: 'cancelled' })
    ]);

    // Notify the assigned company (or platform admin if still unassigned)
    setImmediate(async () => {
      try {
        const { client: rc, fromEmail } = await getResendClient();
        let toAddr = fromEmail;
        let companyName = 'BookaWaka Admin';
        if (cid !== 'unassigned') {
          const access: any = await fbReadP(`towingPortalAccess/${cid}`).catch(() => ({})) || {};
          if (access.email) toAddr = access.email;
          companyName = access.name || cid;
        }
        await rc.emails.send({
          from: fromEmail, to: toAddr,
          subject: `❌ Tow Job Cancelled by Customer — ${jobId}`,
          html: `<div style="font-family:sans-serif;max-width:520px"><h2 style="color:#C62828">Tow Job Cancelled</h2><p>The customer cancelled their tow request via the passenger app.</p><table style="width:100%;border-collapse:collapse;font-size:14px"><tr><td style="padding:6px 0;color:#555;width:130px">Job ID</td><td style="font-weight:600;font-family:monospace">${jobId}</td></tr><tr><td style="padding:6px 0;color:#555">Customer</td><td>${job.customerName || ''} — ${job.customerPhone || ''}</td></tr><tr><td style="padding:6px 0;color:#555">Pickup</td><td>${job.pickup || ''}</td></tr><tr><td style="padding:6px 0;color:#555">Was status</td><td>${status}</td></tr><tr><td style="padding:6px 0;color:#555">Reason</td><td>${patch.cancelReason}${patch.cancelDetails ? ' — ' + patch.cancelDetails : ''}</td></tr>${refundNote ? `<tr><td style="padding:6px 0;color:#555">Refund</td><td>${refundNote}</td></tr>` : ''}</table></div>`
        });
      } catch (err: any) { console.error('[passenger/tow-cancel email]', err.message); }
    });

    console.log(`[passenger/tow-cancel] ${jobId} | was:${status} | cid:${cid} | ${refundNote}`);
    res.json({ ok: true, jobId, status: 'cancelled', message: refundNote ? refundNote.trim() : 'Tow request cancelled.' });
  } catch (e: any) {
    console.error('[passenger/tow-cancel]', e.message);
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// RENTAL
// ─────────────────────────────────────────────────────────────────────────────

router.get('/api/passenger/rental/search', async (req, res) => {
  try {
    const { pickup, category } = req.query as any;
    const retDate = req.query['return'] as string;
    if (!pickup || !retDate) return res.status(400).json({ ok: false, error: 'pickup and return dates required (YYYY-MM-DD)' });

    const days = rentDays(pickup, retDate);
    if (days < 1) return res.status(400).json({ ok: false, error: 'return date must be after pickup date' });

    const [config, portalAccess] = await Promise.all([
      fbReadP('bwConfig/rental'),
      fbReadP('rentalPortalAccess')
    ]);
    if (!config || config.enabled === false) {
      return res.json({ ok: true, vehicles: [], message: 'Rental booking is not available right now.' });
    }

    const companies = Object.entries(portalAccess || {}).filter(([, a]: any) => a && a.active !== false);
    const companyData = await Promise.all(companies.map(async ([cid, acc]: any) => {
      const [fleet, avail] = await Promise.all([
        fbReadP('rentalFleet/' + cid),
        fbReadP('rentalAvailability/' + cid)
      ]);
      return { cid, name: acc.name || cid, fleet: fleet || {}, avail: avail || {} };
    }));

    const catIcons: any = { Economy: '🚗', Compact: '🚙', Standard: '🚘', SUV: '🚙', '4WD': '🚐', Luxury: '💎', 'People Mover': '🚌', 'Ute/Truck': '🛻' };
    const vehicles: any[] = [];
    companyData.forEach(({ cid, name, fleet, avail }) => {
      Object.entries(fleet).forEach(([vid, v]: any) => {
        if (v.status !== 'available') return;
        if (category && v.category !== category) return;
        if (!rentIsAvailable(avail, vid, pickup, retDate)) return;
        const totalPrice = days * parseFloat(v.pricePerDay || 0);
        vehicles.push({
          vid, cid,
          companyName: name,
          make: v.make || '', model: v.model || '', year: v.year || '',
          category: v.category || '', rego: v.rego || '',
          seats: v.seats || 5, transmission: v.transmission || 'auto',
          pricePerDay: parseFloat(v.pricePerDay || 0),
          pricePerWeek: v.pricePerWeek ? parseFloat(v.pricePerWeek) : null,
          totalPrice: parseFloat(totalPrice.toFixed(2)),
          depositAmount: parseFloat(v.depositAmount || 0),
          minDriverAge: v.minDriverAge || 21,
          mileagePolicy: v.mileagePolicy || { type: 'limited' },
          imageUrl: v.imageUrl || null,
          icon: catIcons[v.category] || '🚗',
          features: [
            v.seats ? `${v.seats} seats` : null,
            v.transmission === 'manual' ? 'Manual' : 'Automatic',
            v.category || null,
            v.mileagePolicy && v.mileagePolicy.type === 'unlimited' ? 'Unlimited km' : null
          ].filter(Boolean)
        });
      });
    });
    vehicles.sort((a, b) => a.pricePerDay - b.pricePerDay);

    res.json({
      ok: true,
      pickup, returnDate: retDate, days,
      category: category || null,
      totalVehicles: vehicles.length,
      vehicles,
      categories: ['Economy', 'Compact', 'Standard', 'SUV', '4WD', 'Luxury', 'People Mover', 'Ute/Truck']
    });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

router.get('/api/passenger/rental/vehicle', async (req, res) => {
  try {
    const { cid, vid, pickup } = req.query as any;
    const retDate = req.query['return'] as string;
    if (!cid || !vid || !pickup || !retDate) return res.status(400).json({ ok: false, error: 'cid, vid, pickup and return required' });

    const days = rentDays(pickup, retDate);
    if (days < 1) return res.status(400).json({ ok: false, error: 'return date must be after pickup date' });

    const [vehicle, avail, addons, insurance, config, rentalCfg, portalAcc] = await Promise.all([
      fbReadP('rentalFleet/' + cid + '/' + vid),
      fbReadP('rentalAvailability/' + cid + '/' + vid),
      fbReadP('rentalAddons/' + cid),
      fbReadP('rentalInsurance/' + cid),
      fbReadP('bwConfig/rental'),
      fbReadP('rentalConfig/' + cid),
      fbReadP('rentalPortalAccess/' + cid)
    ]);

    if (!vehicle) return res.status(404).json({ ok: false, error: 'Vehicle not found' });
    if (!rentIsAvailable({ [vid]: avail || {} }, vid, pickup, retDate)) {
      return res.status(409).json({ ok: false, error: 'Vehicle not available for selected dates' });
    }

    const commissionRate = parseFloat((rentalCfg && rentalCfg.commissionRate) || (config && config.defaultCommission) || 12);

    const addonsList = Object.entries(addons || {}).filter(([, a]: any) => a && a.enabled !== false).map(([key, a]: any) => ({
      key, name: a.name || key,
      description: a.description || '',
      pricePerDay: a.pricePerDay ? parseFloat(a.pricePerDay) : null,
      priceFlat: a.priceFlat ? parseFloat(a.priceFlat) : null,
      required: a.required || false
    }));

    const insuranceTiers = Object.entries(insurance || {}).map(([tier, i]: any) => ({
      tier, name: i.name || tier,
      description: i.description || '',
      pricePerDay: parseFloat(i.pricePerDay || 0),
      excess: i.excess || null
    }));

    const pricingByTier: any = {};
    insuranceTiers.forEach(({ tier }) => {
      pricingByTier[tier] = rentCalcPricing(vehicle, addons, [], tier, insurance, days, commissionRate);
    });

    res.json({
      ok: true,
      cid, vid, pickup, returnDate: retDate, days,
      companyName: (portalAcc && portalAcc.name) || cid,
      vehicle: {
        make: vehicle.make || '', model: vehicle.model || '', year: vehicle.year || '',
        category: vehicle.category || '', rego: vehicle.rego || '',
        seats: vehicle.seats || 5, transmission: vehicle.transmission || 'auto',
        pricePerDay: parseFloat(vehicle.pricePerDay || 0),
        pricePerWeek: vehicle.pricePerWeek ? parseFloat(vehicle.pricePerWeek) : null,
        depositAmount: parseFloat(vehicle.depositAmount || 0),
        minDriverAge: vehicle.minDriverAge || 21,
        mileagePolicy: vehicle.mileagePolicy || { type: 'limited' },
        imageUrl: vehicle.imageUrl || null,
        description: vehicle.description || ''
      },
      addons: addonsList,
      insuranceTiers,
      pricingByTier,
      basePricing: rentCalcPricing(vehicle, addons, [], 'none', insurance, days, commissionRate)
    });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

router.post('/api/passenger/rental/book', async (req, res) => {
  try {
    const {
      cid, vid, pickupDate, returnDate,
      insuranceTier, selectedAddons,
      customer,
      rentalPaymentIntentId, depositPaymentIntentId
    } = req.body;

    if (!cid || !vid || !pickupDate || !returnDate) return res.status(400).json({ ok: false, error: 'cid, vid, pickupDate, returnDate required' });
    if (!customer || !customer.name || !customer.email || !customer.phone) return res.status(400).json({ ok: false, error: 'customer.name, customer.email, customer.phone required' });

    const days = rentDays(pickupDate, returnDate);
    if (days < 1) return res.status(400).json({ ok: false, error: 'returnDate must be after pickupDate' });

    const [vehicle, avail, addons, insurance, config, rentalCfg, portalAcc, r2rConfig] = await Promise.all([
      fbReadP('rentalFleet/' + cid + '/' + vid),
      fbReadP('rentalAvailability/' + cid + '/' + vid),
      fbReadP('rentalAddons/' + cid),
      fbReadP('rentalInsurance/' + cid),
      fbReadP('bwConfig/rental'),
      fbReadP('rentalConfig/' + cid),
      fbReadP('rentalPortalAccess/' + cid),
      fbReadP('bwConfig/rental/rideToRental')
    ]);

    if (!vehicle) return res.status(404).json({ ok: false, error: 'Vehicle not found' });
    if (!rentIsAvailable({ [vid]: avail || {} }, vid, pickupDate, returnDate)) {
      return res.status(409).json({ ok: false, error: 'Vehicle not available for selected dates — please search again' });
    }

    const commissionRate = parseFloat((rentalCfg && rentalCfg.commissionRate) || (config && config.defaultCommission) || 12);
    const addonKeys = Array.isArray(selectedAddons) ? selectedAddons : [];
    const tier = insuranceTier || 'none';
    const pricing: any = rentCalcPricing(vehicle, addons, addonKeys, tier, insurance, days, commissionRate);
    pricing.rentalPaymentIntentId = rentalPaymentIntentId || null;
    pricing.depositPaymentIntentId = depositPaymentIntentId || null;

    const companyName = (portalAcc && portalAcc.name) || cid;
    const jobId = await generateJobId(cid);
    const reservationId = 'RES' + Date.now();
    const now = Date.now();
    const cancelToken = crypto.randomBytes(16).toString('hex');

    let promoCode: string | null = null;
    if (r2rConfig && r2rConfig.enabled && r2rConfig.discountPercent > 0) {
      promoCode = 'R2R-' + jobId.slice(-6).toUpperCase();
    }

    const reservation: any = {
      jobId, reservationId,
      companyId: cid, vehicleId: vid,
      customerName: customer.name, customerEmail: customer.email,
      customerId: customer.email, customerPhone: customer.phone,
      customerDOB: customer.dob || '', customerLicence: customer.licence || '',
      pickupDate, returnDate, billingDays: days,
      insuranceTier: tier, selectedAddons: addonKeys,
      pricing: { ...pricing, rentalPaymentIntentId, depositPaymentIntentId },
      deposit: { amount: pricing.depositAmount, status: depositPaymentIntentId ? 'authorized' : 'none', depositPaymentIntentId: depositPaymentIntentId || null },
      rentalPaymentIntentId: rentalPaymentIntentId || null,
      cancelToken, promoCode,
      status: 'confirmed', source: 'passenger_app',
      createdAt: now, updatedAt: now
    };

    const avUpdates: any = {};
    let d = new Date(pickupDate), end = new Date(returnDate);
    while (d < end) {
      avUpdates['rentalAvailability/' + cid + '/' + vid + '/' + d.toISOString().slice(0, 10)] = 'blocked';
      d.setDate(d.getDate() + 1);
    }

    const writes = [
      fbWriteP('PUT', 'rentalReservations/' + cid + '/' + reservationId, reservation),
      fbWriteP('PUT', 'allbookings/' + cid + '/' + jobId, {
        jobId, companyId: cid, source: 'rental', status: 'confirmed',
        passenger: { name: customer.name, email: customer.email, phone: customer.phone },
        fare: { amount: pricing.subtotal, currency: 'NZD' },
        rentalRef: reservationId, createdAt: now
      }),
      fbWriteP('PATCH', '', avUpdates),
      fbWriteP('PUT', 'rentalCancelTokens/' + cancelToken, { cid, reservationId, createdAt: now }),
      fbWriteP('PUT', 'rentalBookingIndex/' + jobId, { cid, reservationId, customerEmail: (customer.email || '').toLowerCase() })
    ];
    if (rentalPaymentIntentId) writes.push(fbWriteP('PUT', 'rentalPaymentIntentIndex/' + rentalPaymentIntentId, { cid, reservationId }));
    if (promoCode) writes.push(fbWriteP('PUT', 'rentalPromos/' + promoCode, {
      code: promoCode, discountPercent: r2rConfig.discountPercent,
      used: false, customerEmail: customer.email, rentalJobId: jobId,
      createdAt: now, expiresAt: now + 7 * 24 * 60 * 60 * 1000
    }));
    await Promise.all(writes);

    console.log(`[passenger/rental/book] ${jobId} | cid:${cid} | vid:${vid} | $${pricing.subtotal.toFixed(2)}`);

    const baseUrl = 'https://' + (process.env.REPLIT_DOMAINS || '').split(',')[0];
    setImmediate(async () => {
      try {
        const { client: rc, fromEmail } = await getResendClient();
        await rc.emails.send({
          from: fromEmail, to: customer.email,
          subject: `Booking Confirmed: ${jobId} — ${vehicle.make || ''} ${vehicle.model || ''}`,
          html: `<div style="font-family:sans-serif;max-width:560px"><h2 style="color:#00695C">✅ Rental Booking Confirmed</h2><p>Hi <strong>${customer.name}</strong>, your rental is confirmed with <strong>${companyName}</strong>.</p><table style="width:100%;border-collapse:collapse;font-size:14px;margin:16px 0"><tr><td style="padding:6px 0;color:#555;width:120px">Booking Ref</td><td style="font-weight:600;font-family:monospace">${jobId}</td></tr><tr><td style="padding:6px 0;color:#555">Vehicle</td><td>${vehicle.make} ${vehicle.model} (${vehicle.year})</td></tr><tr><td style="padding:6px 0;color:#555">Pickup</td><td>${pickupDate}</td></tr><tr><td style="padding:6px 0;color:#555">Return</td><td>${returnDate} (${days} days)</td></tr><tr><td style="padding:6px 0;color:#555">Total</td><td style="font-weight:700;color:#00695C">$${pricing.subtotal.toFixed(2)} NZD</td></tr></table>${promoCode ? `<div style="background:#E0F2F1;border:1px solid #B2DFDB;border-radius:8px;padding:14px 18px;margin-top:16px"><strong>🎁 Ride-to-Rental Promo</strong><br>Use code <strong>${promoCode}</strong> for ${r2rConfig.discountPercent}% off your next ride booking!<br><small>Valid 7 days.</small></div>` : ''}</div>`
        });
        if (portalAcc && portalAcc.email) {
          await rc.emails.send({
            from: fromEmail, to: portalAcc.email,
            subject: `New Rental Booking (App): ${jobId}`,
            html: `<div style="font-family:sans-serif;max-width:520px"><h2 style="color:#00695C">New Rental Booking</h2><table style="width:100%;border-collapse:collapse;font-size:14px"><tr><td style="padding:6px 0;color:#555;width:120px">Booking Ref</td><td style="font-weight:600;font-family:monospace">${jobId}</td></tr><tr><td style="padding:6px 0;color:#555">Customer</td><td>${customer.name} — ${customer.phone}</td></tr><tr><td style="padding:6px 0;color:#555">Email</td><td>${customer.email}</td></tr><tr><td style="padding:6px 0;color:#555">Vehicle</td><td>${vehicle.make} ${vehicle.model} (${vehicle.rego})</td></tr><tr><td style="padding:6px 0;color:#555">Pickup</td><td>${pickupDate}</td></tr><tr><td style="padding:6px 0;color:#555">Return</td><td>${returnDate}</td></tr><tr><td style="padding:6px 0;color:#555">Revenue</td><td style="font-weight:700;color:#00695C">$${pricing.ownerNet.toFixed(2)} (after ${commissionRate}% commission)</td></tr></table></div>`
          });
        }
      } catch (emailErr: any) { console.error('[passenger/rental/email]', emailErr.message); }
    });

    res.json({
      ok: true, jobId, reservationId, companyName, promoCode,
      pricing: { subtotal: pricing.subtotal, depositAmount: pricing.depositAmount, days, currency: 'NZD' },
      cancelToken,
      message: 'Rental booking confirmed. Confirmation email sent to ' + customer.email
    });
  } catch (e: any) {
    console.error('[passenger/rental/book]', e.message);
    res.status(500).json({ ok: false, error: e.message });
  }
});

router.get('/api/passenger/rental/booking/:jobId', async (req, res) => {
  try {
    const jobId = (req.params.jobId || '').trim();
    if (!jobId) return res.status(400).json({ ok: false, error: 'jobId required' });

    const idx = await fbReadP('rentalBookingIndex/' + jobId);
    if (!idx) return res.status(404).json({ ok: false, error: 'Booking not found' });

    const { cid, reservationId } = idx;
    const reservation = await fbReadP('rentalReservations/' + cid + '/' + reservationId);
    if (!reservation) return res.status(404).json({ ok: false, error: 'Reservation not found' });

    const [vehicle, portalAcc] = await Promise.all([
      fbReadP('rentalFleet/' + cid + '/' + reservation.vehicleId),
      fbReadP('rentalPortalAccess/' + cid)
    ]);

    const fmtDt = (ts: number) => ts ? new Date(ts).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : null;

    // Cancellation policy. Default: free cancellation 48+ hrs before pickup.
    // Operator can override under bwConfig/rental/cancellationPolicy { freeHours, text }.
    const rentCfg: any = await fbReadP('bwConfig/rental').catch(() => null) || {};
    const policyCfg = rentCfg.cancellationPolicy || {};
    const freeHours = Number.isFinite(+policyCfg.freeHours) ? +policyCfg.freeHours : 48;
    const pickupTs = reservation.pickupDate ? new Date(reservation.pickupDate).getTime() : 0;
    const hoursUntilPickup = pickupTs ? Math.max(0, (pickupTs - Date.now()) / 3600000) : 0;
    const reservationStatus = reservation.status || 'confirmed';
    const cancellableStatuses = ['confirmed', 'pending'];
    const canCancel = cancellableStatuses.includes(reservationStatus);
    const freeCancellation = canCancel && hoursUntilPickup >= freeHours;
    const cancellationPolicy = {
      text: (policyCfg.text && String(policyCfg.text)) ||
        `Free cancellation up to ${freeHours} hours before pickup. Within ${freeHours} hours, your deposit may be retained.`,
      freeHours,
      hoursUntilPickup: Math.round(hoursUntilPickup * 10) / 10,
      currentlyCancellable: canCancel,
      freeCancellation
    };

    res.json({
      ok: true, jobId, reservationId,
      status: reservationStatus,
      companyName: (portalAcc && portalAcc.name) || cid,
      companyPhone: (portalAcc && portalAcc.phone) || null,
      pickupDate: reservation.pickupDate, returnDate: reservation.returnDate,
      billingDays: reservation.billingDays,
      vehicle: vehicle ? {
        make: vehicle.make, model: vehicle.model, year: vehicle.year,
        category: vehicle.category, rego: vehicle.rego, imageUrl: vehicle.imageUrl || null
      } : null,
      pricing: {
        subtotal: reservation.pricing && reservation.pricing.subtotal,
        depositAmount: reservation.pricing && reservation.pricing.depositAmount,
        currency: 'NZD'
      },
      promoCode: reservation.promoCode || null,
      canCancel,
      cancellationPolicy,
      createdAt: reservation.createdAt,
      createdAtFormatted: fmtDt(reservation.createdAt)
    });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// POST /api/passenger/rental/cancel/:jobId
// Body: { cancelToken? , customerEmail? } — either matches the reservation
// Refunds Stripe rental charge + releases the deposit auth + frees up availability.
// Free cancellation if pickup is >= freeHours away (default 48), otherwise the
// deposit MAY be retained per cancellationPolicy (we still try to release it; the
// rental owner can adjust manually).
router.post('/api/passenger/rental/cancel/:jobId', async (req, res) => {
  try {
    const jobId = (req.params.jobId || '').trim();
    const { cancelToken, customerEmail, reason, cancelDetails } = req.body || {};
    if (!jobId) return res.status(400).json({ ok: false, error: 'jobId required' });
    if (!cancelToken && !customerEmail) {
      return res.status(400).json({ ok: false, error: 'cancelToken or customerEmail required for verification' });
    }
    const { reason: cancelReasonCode } = normalizeCancelReason(reason);
    const cancelDetailsStr = cancelReasonCode === 'other'
      ? String(cancelDetails || '').slice(0, 500)
      : '';

    const idx = await fbReadP('rentalBookingIndex/' + jobId);
    if (!idx) return res.status(404).json({ ok: false, error: 'Booking not found' });
    const { cid, reservationId } = idx;
    const reservation: any = await fbReadP('rentalReservations/' + cid + '/' + reservationId);
    if (!reservation) return res.status(404).json({ ok: false, error: 'Reservation not found' });

    // Auth — accept either matching cancelToken OR matching customerEmail
    const tokenOk = cancelToken && reservation.cancelToken && String(cancelToken) === String(reservation.cancelToken);
    const emailOk = customerEmail && reservation.customerEmail &&
      String(customerEmail).trim().toLowerCase() === String(reservation.customerEmail).trim().toLowerCase();
    if (!tokenOk && !emailOk) {
      return res.status(403).json({ ok: false, error: 'Verification failed — cancelToken or customerEmail does not match' });
    }

    const status = reservation.status || 'confirmed';
    if (!['confirmed', 'pending'].includes(status)) {
      return res.status(409).json({ ok: false, error: `Cannot cancel — reservation status is "${status}".` });
    }

    // Cancellation policy
    const rentCfg: any = await fbReadP('bwConfig/rental').catch(() => null) || {};
    const policyCfg = rentCfg.cancellationPolicy || {};
    const freeHours = Number.isFinite(+policyCfg.freeHours) ? +policyCfg.freeHours : 48;
    const pickupTs = reservation.pickupDate ? new Date(reservation.pickupDate).getTime() : 0;
    const hoursUntilPickup = pickupTs ? (pickupTs - Date.now()) / 3600000 : 0;
    const isFree = hoursUntilPickup >= freeHours;

    const stripe = getStripe();
    let notes = '';
    // Always refund the rental charge (auto-captured at booking)
    if (reservation.rentalPaymentIntentId) {
      try {
        await stripe.refunds.create({ payment_intent: reservation.rentalPaymentIntentId });
        notes += 'Rental refunded. ';
      } catch (se: any) {
        notes += 'Rental refund error: ' + se.message + ' ';
        console.error('[passenger/rental-cancel] refund', se.message);
      }
    }
    // Deposit was authorized but not captured — release the auth
    if (reservation.deposit && reservation.deposit.depositPaymentIntentId) {
      try {
        await stripe.paymentIntents.cancel(reservation.deposit.depositPaymentIntentId);
        notes += 'Deposit released.';
      } catch (se: any) {
        console.error('[passenger/rental-cancel] deposit', se.message);
        notes += 'Deposit release error: ' + se.message;
      }
    }

    // Free up availability for the booked dates
    if (reservation.vehicleId && reservation.pickupDate && reservation.returnDate) {
      const avUpdates: Record<string, any> = {};
      let d = new Date(reservation.pickupDate);
      const end = new Date(reservation.returnDate);
      while (d < end) {
        avUpdates['rentalAvailability/' + cid + '/' + reservation.vehicleId + '/' + d.toISOString().slice(0, 10)] = null;
        d.setDate(d.getDate() + 1);
      }
      await fbWriteP('PATCH', '', avUpdates);
    }

    const now = Date.now();
    await fbWriteP('PATCH', 'rentalReservations/' + cid + '/' + reservationId, {
      status: 'cancelled',
      cancelledAt: now,
      cancelledBy: 'passenger_app',
      cancelNote: notes.trim(),
      cancelReason: cancelReasonCode,
      cancelDetails: cancelDetailsStr,
      updatedAt: now
    });
    // Mark allbookings row too so dispatch/SA see the cancel
    if (reservation.jobId) {
      await fbWriteP('PATCH', 'allbookings/' + cid + '/' + reservation.jobId, {
        status: 'cancelled', cancelledAt: now, cancelledBy: 'passenger_app'
      }).catch((e: any) => console.error('[passenger/rental-cancel] allbookings', e.message));
    }

    // Notify owner
    setImmediate(async () => {
      try {
        const { client: rc, fromEmail } = await getResendClient();
        const portalAcc: any = await fbReadP('rentalPortalAccess/' + cid).catch(() => ({})) || {};
        const toAddr = portalAcc.email || fromEmail;
        await rc.emails.send({
          from: fromEmail, to: toAddr,
          subject: `❌ Rental Booking Cancelled by Customer — ${jobId}`,
          html: `<div style="font-family:sans-serif;max-width:520px"><h2 style="color:#C62828">Rental Cancelled</h2><p>The customer cancelled their rental via the passenger app.</p><table style="width:100%;border-collapse:collapse;font-size:14px"><tr><td style="padding:6px 0;color:#555;width:140px">Booking Ref</td><td style="font-weight:600;font-family:monospace">${jobId}</td></tr><tr><td style="padding:6px 0;color:#555">Reservation ID</td><td style="font-family:monospace">${reservationId}</td></tr><tr><td style="padding:6px 0;color:#555">Customer</td><td>${reservation.customerName || ''} — ${reservation.customerEmail || ''}</td></tr><tr><td style="padding:6px 0;color:#555">Pickup → Return</td><td>${reservation.pickupDate} → ${reservation.returnDate}</td></tr><tr><td style="padding:6px 0;color:#555">Hours to pickup</td><td>${hoursUntilPickup.toFixed(1)} hrs (${isFree ? 'free cancellation window' : 'inside ' + freeHours + 'hr fee window'})</td></tr><tr><td style="padding:6px 0;color:#555">Stripe</td><td>${notes || '(no Stripe actions)'}</td></tr><tr><td style="padding:6px 0;color:#555">Reason</td><td>${cancelReasonCode}${cancelDetailsStr ? ' — ' + cancelDetailsStr : ''}</td></tr></table></div>`
        });
      } catch (err: any) { console.error('[passenger/rental-cancel email]', err.message); }
    });

    console.log(`[passenger/rental-cancel] ${jobId} | res:${reservationId} | cid:${cid} | free:${isFree} | ${notes}`);
    res.json({
      ok: true, jobId, reservationId, status: 'cancelled',
      freeCancellation: isFree,
      hoursUntilPickup: Math.round(hoursUntilPickup * 10) / 10,
      message: (isFree ? 'Cancelled within the free cancellation window. ' : `Cancelled inside the ${freeHours}-hour window — deposit handling subject to operator policy. `) + notes.trim()
    });
  } catch (e: any) {
    console.error('[passenger/rental-cancel]', e.message);
    res.status(500).json({ ok: false, error: e.message });
  }
});

export default router;
