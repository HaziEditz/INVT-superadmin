import { Router } from 'express';
import { fbReadP, fbWriteP, fbRead, fbWrite } from '../firebase';
import { setCorsHeaders } from '../utils';
import { generateJobId } from '../jobId';

const router = Router();

// ── Driver Earnings Helper ─────────────────────────────────────────────────────
// Single authoritative writer for driverEarnings/taxi/{cid}/{driverId}.
// - Writes a per-trip record at trips/{jobId} (idempotent — deduplicates double calls)
// - Increments aggregate totals only if this jobId hasn't been counted yet
// - Uses PATCH not PUT so the trips/ sub-node is never wiped
// - Rounds totals to 2 decimal places to prevent float drift
// - Path: driverEarnings/taxi/{cid}/{driverId}  (taxi segment mandatory — see replit.md gotcha)
function updateDriverEarnings(
  companyId: string,
  driverId: string,
  jobId: string,
  fare: number,
  distance: number,
  completedAt: number,
  callback: (err?: any) => void
): void {
  const earningsPath = `driverEarnings/taxi/${companyId}/${driverId}`;

  fbRead(earningsPath, (_readErr: any, existing: any) => {
    const prev = existing || {};
    const trips: Record<string, any> = prev.trips || {};

    // Dedup guard: if this jobId already has a trip record, skip aggregate increment
    const alreadyCounted = !!trips[jobId];

    const tripRecord = {
      jobId,
      fare: Math.round(fare * 100) / 100,
      distance: Math.round(distance * 1000) / 1000,
      completedAt
    };

    const pending2 = alreadyCounted ? 1 : 2;
    let p2 = pending2;
    let p2err = false;

    function p2done(err?: any) {
      if (err && !p2err) {
        p2err = true;
        return callback(err);
      }
      p2--;
      if (p2 === 0 && !p2err) callback();
    }

    // Always write the per-trip record (idempotent)
    fbWrite('PUT', `${earningsPath}/trips/${jobId}`, tripRecord, p2done);

    if (!alreadyCounted) {
      // Increment aggregate totals
      const updated = {
        driverId,
        companyId,
        totalEarnings: Math.round((parseFloat(prev.totalEarnings || 0) + fare) * 100) / 100,
        totalTrips:    (parseInt(prev.totalTrips || 0)) + 1,
        totalDistance: Math.round((parseFloat(prev.totalDistance || 0) + distance) * 1000) / 1000,
        lastTripAt:   completedAt,
        lastJobId:    jobId
      };
      fbWrite('PATCH', earningsPath, updated, p2done);
    } else {
      console.log(`[driverEarnings] ${jobId} already counted — skipping aggregate increment`);
    }
  });
}

// ── Create Job ─────────────────────────────────────────────────────────────────
router.post('/api/job/create', async (req, res) => {
  setCorsHeaders(res);
  const { companyId, source, driverId, vehicleId, passenger, pickup, dropoff,
          fare, payment, tariffId, notes } = req.body || {};

  if (!companyId) return res.status(400).json({ ok: false, error: 'companyId required' });

  const validSources = ['dispatch', 'hail', 'passenger', 'web', 'food', 'freight'];
  if (!source || !validSources.includes(source)) {
    return res.status(400).json({ ok: false, error: 'source required: ' + validSources.join(' | ') });
  }

  try {
    const jobId = await generateJobId(companyId);
    const now = Date.now();

    const jobRecord = {
      jobId,
      companyId,
      source,
      status: 'pending',
      driverId: driverId || null,
      vehicleId: vehicleId || null,
      passenger: passenger || {},
      pickup: pickup || {},
      dropoff: dropoff || {},
      fare: {
        base:     parseFloat((fare && fare.base)     || 0),
        distance: parseFloat((fare && fare.distance) || 0),
        waiting:  parseFloat((fare && fare.waiting)  || 0),
        total:    parseFloat((fare && fare.total)    || 0)
      },
      payment: {
        method: (payment && payment.method) || 'cash',
        paid: false
      },
      tariffId: tariffId || '',
      notes: notes || '',
      createdAt: now,
      assignedAt: null,
      startedAt: null,
      completedAt: null,
      distance: 0,
      duration: 0
    };

    await fbWriteP('PUT', 'allbookings/' + companyId + '/' + jobId, jobRecord);

    console.log('[job/create] Job', jobId, '| company:', companyId, '| source:', source);
    res.json({ ok: true, jobId, createdAt: now });

  } catch (err: any) {
    console.error('[job/create] Error:', err);
    res.status(500).json({ ok: false, error: String(err.message || err) });
  }
});

// ── Offline Trip Sync ──────────────────────────────────────────────────────────
router.post('/api/syncOfflineTrip', async (req, res) => {
  setCorsHeaders(res);
  const body = req.body || {};
  const { jobId, companyId, driverId, vehicleId, events, tripSummary } = body;

  console.log(`[syncOfflineTrip] received jobId=${jobId} cid=${companyId} driver=${driverId} keys=${Object.keys(body).join(',')}`);

  if (!jobId || !companyId || !driverId) {
    return res.status(400).json({ ok: false, error: 'jobId, companyId and driverId are required' });
  }
  if (!/^\d{9,}$/.test(String(jobId))) {
    console.warn(`[syncOfflineTrip] Rejected invalid jobId "${jobId}" for driver ${driverId} — looks like a driverId, not a booking ID`);
    return res.status(400).json({ ok: false, error: `Invalid jobId "${jobId}" — must be a numeric booking ID from /api/job/create` });
  }

  const ts = tripSummary || {};
  const eventsArrEarly: any[] = Array.isArray(events) ? events : [];

  const completedEvent = eventsArrEarly.find((e: any) => e?.eventType === 'Completed' || e?.eventType === 'TripEnded');
  const eventFare = parseFloat(completedEvent?.meta?.fare ?? 0) || 0;

  const driverFare = parseFloat(ts.fare ?? body.TotalFare ?? body.totalFare ?? 0) || eventFare;
  const baseFare   = parseFloat(ts.baseFare  ?? body.FareBase  ?? body.fareBase  ?? 0) || 0;
  const distance   = parseFloat(ts.distance  ?? body.JobDistance ?? body.jobDistance ?? body.FareDistance ?? 0) || 0;
  const duration   = ts.duration || body.duration || 0;
  const isOffline  = ts.completedOffline === true || body.completedOffline === true;

  const TERMINAL_EVENTS   = new Set(['Completed','TripEnded','Delivered','DropOff','DropedOff','Finished','completed','tripEnded','delivered']);
  const INPROGRESS_EVENTS = new Set(['PickedUp','Started','EnRoute','OnWay','pickedUp','started']);
  const eventsArr: any[] = Array.isArray(events) ? events : [];
  const eventTypes  = eventsArr.map((e: any) => e?.eventType || '');
  const hasTerminal   = eventTypes.some((t: string) => TERMINAL_EVENTS.has(t));
  const hasInProgress = eventTypes.some((t: string) => INPROGRESS_EVENTS.has(t));

  const derivedStatus        = hasTerminal ? 'completed' : hasInProgress ? 'inProgress' : 'assigned';
  const derivedStatusDisplay = hasTerminal ? 'Completed' : hasInProgress ? 'InProgress' : 'Assigned';

  const hasMeaningfulData = hasTerminal || driverFare > 0;

  console.log(`[syncOfflineTrip] fare=${driverFare} distance=${distance} offline=${isOffline} eventTypes=${eventTypes.join('|')} → status=${derivedStatus}`);

  if (!hasMeaningfulData) {
    console.log(`[syncOfflineTrip] No meaningful data (fare=0, no terminal events) — skipping status/fare write for ${jobId}`);
  }

  const now = Date.now();

  // Pre-paid guard: if the booking was already paid by card (paymentStatus: 'paid'),
  // do NOT overwrite fare/Fare with the driver's meter reading — the Stripe-confirmed
  // amount is authoritative. Also never overwrite paymentMethod from the driver payload.
  let effectiveFare = driverFare;
  let isPrePaid = false;
  if (hasMeaningfulData) {
    try {
      const existing = await fbReadP(`allbookings/${companyId}/${jobId}`);
      if (existing && existing.paymentStatus === 'paid') {
        // Use stripeConfirmedFare — a write-once field set by the Stripe webhook.
        // Dispatch overwrites allbookings.fare at completion, so we cannot rely on
        // existing.fare; stripeConfirmedFare is never touched by dispatch or drivers.
        const confirmedFare = parseFloat(existing.stripeConfirmedFare || 0) || 0;
        if (confirmedFare > 0) {
          effectiveFare = confirmedFare;
          isPrePaid = true;
          console.log(`[syncOfflineTrip] Pre-paid booking ${jobId} — preserving stripeConfirmedFare ${effectiveFare} (driver sent ${driverFare})`);
        }
      }
    } catch (e: any) {
      console.warn(`[syncOfflineTrip] Could not read existing booking ${jobId}:`, e.message);
    }
  }

  // Build record — never include paymentMethod (set at booking creation, not completion)
  const bookingRecord: Record<string, any> = {
    jobId,
    companyId,
    driverId,
    vehicleId: vehicleId || body.VehicleId || '',
    tariffId: ts.tariffId || body.tariffId || '',
    startTime: ts.startTime || body.startTime || null,
    endTime: ts.endTime || body.endTime || null,
    completedOffline: isOffline,
    uploadedAt: now,
    events: eventsArr
  };

  if (hasMeaningfulData) {
    if (!isPrePaid) {
      bookingRecord.fare          = effectiveFare;
      bookingRecord.baseFare      = baseFare;
      bookingRecord.waitingCharge = parseFloat(ts.waitingCharge ?? body.FareExtras ?? 0) || 0;
      bookingRecord.distance      = distance;
      bookingRecord.duration      = duration;
    } else {
      // Pre-paid: re-assert correct fare and payment method.
      // The driver app writes fare+paymentMethod directly to allbookings at completion
      // using job.paymentType from the offer notification — if PaymentType:'card' was
      // not in the notification, it defaults to 'cash' and overwrites our Stripe data.
      // This sync endpoint runs server-side after the driver's direct write, so asserting
      // here is the last write and restores the correct values.
      bookingRecord.fare          = effectiveFare;
      bookingRecord.Fare          = effectiveFare;
      bookingRecord.paymentMethod = 'card';
      bookingRecord.PaymentMethod = 'card';
      bookingRecord.paymentStatus = 'paid';
      bookingRecord.PaymentStatus = 'paid';
    }
    bookingRecord.status  = derivedStatus;
    bookingRecord.Status  = derivedStatusDisplay;
  }

  let pending = 2;
  let hasError = false;

  function done(err?: any) {
    if (err && !hasError) {
      hasError = true;
      console.error('[syncOfflineTrip] Firebase write error:', err);
      return res.status(500).json({ ok: false, error: String(err) });
    }
    pending--;
    if (pending === 0 && !hasError) {
      console.log(`[syncOfflineTrip] Trip ${jobId} saved for company ${companyId} | fare: ${effectiveFare} | offline: ${isOffline}`);
      res.json({ ok: true, jobId, savedAt: now });
    }
  }

  fbWrite('PATCH', 'allbookings/' + companyId + '/' + jobId, bookingRecord, done);

  if (effectiveFare > 0 && hasTerminal) {
    updateDriverEarnings(companyId, driverId, jobId, effectiveFare, distance, now, done);
  } else {
    done();
  }
});

// ── Alias: /api/job/sync-offline-trip (driver app uses this path with uppercase fields) ───
// Maps BookingId→jobId, TotalFare→fare, FareBase→baseFare, JobDistance→distance, etc.
router.post('/api/job/sync-offline-trip', async (req, res) => {
  setCorsHeaders(res);
  const body = req.body || {};
  console.log(`[sync-offline-trip] alias hit — BookingId=${body.BookingId} TotalFare=${body.TotalFare}`);

  const jobId     = String(body.BookingId || body.jobId || '');
  const companyId = String(body.CompanyId || body.companyId || '');
  const driverId  = String(body.DriverId  || body.driverId  || '');
  const vehicleId = String(body.VehicleId || body.vehicleId || '');

  if (!jobId || !companyId || !driverId) {
    return res.status(400).json({ ok: false, error: 'BookingId/jobId, CompanyId/companyId and DriverId/driverId are required' });
  }
  if (!/^\d{9,}$/.test(jobId)) {
    return res.status(400).json({ ok: false, error: `Invalid jobId "${jobId}"` });
  }

  const driverFare = parseFloat(body.TotalFare || body.fare || 0) || 0;
  const baseFare   = parseFloat(body.FareBase  || body.baseFare || 0) || 0;
  const distance   = parseFloat(body.JobDistance || body.FareDistance || body.distance || 0) || 0;
  const extras     = parseFloat(body.FareExtras || 0) || 0;
  const now        = Date.now();

  console.log(`[sync-offline-trip] fare=${driverFare} distance=${distance} driver=${driverId}`);

  // Pre-paid guard: if paymentStatus='paid', the Stripe-confirmed fare is authoritative.
  // Use stripeConfirmedFare — written only by the Stripe webhook, never by dispatch.
  // Dispatch overwrites allbookings.fare on completion, so existing.fare is not reliable.
  let effectiveFare = driverFare;
  let isPrePaid = false;
  try {
    const existing = await fbReadP(`allbookings/${companyId}/${jobId}`);
    if (existing && existing.paymentStatus === 'paid') {
      const confirmedFare = parseFloat(existing.stripeConfirmedFare || 0) || 0;
      if (confirmedFare > 0) {
        effectiveFare = confirmedFare;
        isPrePaid = true;
        console.log(`[sync-offline-trip] Pre-paid booking ${jobId} — preserving stripeConfirmedFare ${effectiveFare} (driver sent ${driverFare})`);
      }
    }
  } catch (e: any) {
    console.warn(`[sync-offline-trip] Could not read existing booking ${jobId}:`, e.message);
  }

  const bookingRecord: Record<string, any> = {
    jobId, companyId, driverId, vehicleId,
    fare: effectiveFare, baseFare,
    waitingCharge: extras,
    fareTime:     parseFloat(body.FareTime     || 0) || 0,
    fareDistance: parseFloat(body.FareDistance || 0) || 0,
    currency:     body.FareCurrency || 'NZD',
    dropAddress:  body.DropAddress  || '',
    dropLatLng:   body.DropLatLng   || '',
    distance, duration: 0,
    completedOffline: body.completedOffline === true,
    uploadedAt: now,
    status: 'completed',
    Status: 'Completed',
  };

  if (isPrePaid) {
    // Re-assert correct fare and payment method. The driver app writes paymentMethod
    // to allbookings directly at completion based on job.paymentType from the offer
    // notification. If PaymentType:'card' was absent from the notification it defaults
    // to 'cash', overwriting the Stripe webhook's value. This sync endpoint runs
    // server-side and is the last writer — re-asserting here restores correct values.
    bookingRecord.Fare          = effectiveFare;
    bookingRecord.paymentMethod = 'card';
    bookingRecord.PaymentMethod = 'card';
    bookingRecord.paymentStatus = 'paid';
    bookingRecord.PaymentStatus = 'paid';
  }

  let pending = 2;
  let hasError = false;
  function done(err?: any) {
    if (err && !hasError) {
      hasError = true;
      console.error('[sync-offline-trip] Firebase write error:', err);
      return res.status(500).json({ ok: false, error: String(err) });
    }
    pending--;
    if (pending === 0 && !hasError) {
      console.log(`[sync-offline-trip] Trip ${jobId} saved | fare: ${effectiveFare}${effectiveFare !== driverFare ? ` (driver sent ${driverFare})` : ''}`);
      res.json({ ok: true, jobId, savedAt: now });
    }
  }

  fbWrite('PATCH', 'allbookings/' + companyId + '/' + jobId, bookingRecord, done);

  if (effectiveFare > 0) {
    updateDriverEarnings(companyId, driverId, jobId, effectiveFare, distance, now, done);
  } else {
    done();
  }

  // Clear currentJobId so driver app doesn't think it still has an active job.
  if (vehicleId) {
    fbWriteP('PATCH', `online/${companyId}/${vehicleId}/current`, { currentJobId: null })
      .then(() => console.log(`[sync-offline-trip] Cleared currentJobId for ${vehicleId}`))
      .catch((e: any) => console.warn(`[sync-offline-trip] Could not clear currentJobId for ${vehicleId}:`, e.message));
  }
});

// ── Tariffs (public — website & passenger app for fare estimation) ─────────────
// GET /api/tariffs?cid=COMPANY_ID
// Returns all tariffs for a company so the booking site can calculate fare estimates.
// Formula: estimatedFare = baseFare + (distanceKm * pricePerKm)
// tariffs/{cid} is publicly readable per database.rules.json
router.get('/api/tariffs', async (req, res) => {
  setCorsHeaders(res);
  const cid = ((req.query.cid as string) || '').trim();
  if (!cid) return res.status(400).json({ ok: false, error: 'cid required' });
  try {
    const tariffs = await fbReadP('tariffs/' + cid);
    if (!tariffs) return res.json({ ok: true, tariffs: [] });
    const list = Object.entries(tariffs as Record<string, any>).map(([id, t]) => ({
      id,
      name: t.name || t.TariffName || '',
      baseFare: parseFloat(t.baseFare || 0),
      pricePerKm: parseFloat(t.pricePerKm || 0),
      waitingRate: parseFloat(t.waitingRate || 0),
      minimumFare: parseFloat(t.minimumFare || 0),
      isTM: (t.name || t.TariffName || '').toLowerCase().includes('mobility')
    }));
    res.json({ ok: true, tariffs: list });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ── Fare Estimate (public — website & passenger app) ──────────────────────────
// GET /api/fare-estimate?cid=&fromLat=&fromLng=&toLat=&toLng=
// Uses Haversine straight-line distance + Standard tariff to return an instant estimate.
// Formula: max(baseFare + distanceKm * pricePerKm, minimumFare)
router.get('/api/fare-estimate', async (req, res) => {
  setCorsHeaders(res);
  const { cid, fromLat, fromLng, toLat, toLng } = req.query as Record<string, string>;
  if (!cid || !fromLat || !fromLng || !toLat || !toLng) {
    return res.status(400).json({ ok: false, error: 'cid, fromLat, fromLng, toLat, toLng required' });
  }
  const toRad = (d: number) => d * Math.PI / 180;
  const haversineKm = (lat1: number, lng1: number, lat2: number, lng2: number): number => {
    const R = 6371;
    const dLat = toRad(lat2 - lat1);
    const dLng = toRad(lng2 - lng1);
    const a = Math.sin(dLat / 2) ** 2 +
      Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  };
  try {
    const tariffs = await fbReadP('tariffs/' + cid);
    if (!tariffs) return res.status(404).json({ ok: false, error: 'No tariffs found for this company' });
    // Pick the standard (non-TM) tariff — lowest baseFare that is not Total Mobility
    const list = Object.entries(tariffs as Record<string, any>)
      .map(([id, t]) => ({ id, ...t, isTM: !!(t.isTM || (t.name || t.TariffName || '').toLowerCase().includes('mobility')) }))
      .filter(t => !t.isTM)
      .sort((a, b) => parseFloat(a.baseFare || 0) - parseFloat(b.baseFare || 0));
    if (!list.length) return res.status(404).json({ ok: false, error: 'No standard tariff found' });
    const tariff = list[0];
    const distanceKm = haversineKm(
      parseFloat(fromLat), parseFloat(fromLng),
      parseFloat(toLat),   parseFloat(toLng)
    );
    // Add 20% buffer for road distance vs straight-line
    const roadDistanceKm = Math.round(distanceKm * 1.2 * 10) / 10;
    const baseFare      = parseFloat(tariff.baseFare || 0);
    const pricePerKm    = parseFloat(tariff.pricePerKm || 0);
    const minimumFare   = parseFloat(tariff.minimumFare || 0);
    const rawFare       = baseFare + roadDistanceKm * pricePerKm;
    const estimatedFare = Math.max(rawFare, minimumFare);
    res.json({
      ok: true,
      tariffId: tariff.id,
      tariffName: tariff.name || tariff.TariffName,
      distanceKm: roadDistanceKm,
      baseFare,
      pricePerKm,
      minimumFare,
      estimatedFare: Math.round(estimatedFare * 100) / 100,
      note: 'Straight-line distance with 20% road buffer applied. Final fare set by driver meter.'
    });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ── Public Company List (public — website booking widget) ──────────────────────
// GET /api/public/companies
// Returns active/trial companies available for booking.
// Used by multi-company booking sites to populate a company selector.
router.get('/api/public/companies', async (req, res) => {
  setCorsHeaders(res);
  try {
    const clients = await fbReadP('superClients') as Record<string, any> | null;
    if (!clients) return res.json({ ok: true, companies: [] });
    const companies = Object.entries(clients)
      .filter(([, c]) => c && (c.status === 'active' || c.status === 'trial'))
      .map(([id, c]) => ({
        id,
        name:  c.name  || c.companyName || id,
        city:  c.city  || '',
        phone: c.phone || ''
      }));
    res.json({ ok: true, companies });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ── Payment Config (public — website & passenger app) ─────────────────────────
// GET /api/payment-config?cid=OPTIONAL_COMPANY_ID
// Returns platform-wide and per-company cash switch values.
// Both must be true for cash to be offered to the passenger.
router.get('/api/payment-config', async (req, res) => {
  setCorsHeaders(res);
  const cid = ((req.query.cid as string) || '').trim();
  try {
    const [platformPayments, companyPayments] = await Promise.all([
      fbReadP('bwConfig/paymentMethods'),
      cid ? fbReadP('companySettings/' + cid + '/paymentMethods') : Promise.resolve(null)
    ]);
    const cashEnabled = (platformPayments as any)?.cashEnabled !== false;
    const cardEnabled = (platformPayments as any)?.cardEnabled === true;
    const companyCashEnabled = cid
      ? ((companyPayments as any)?.cashEnabled !== false)
      : null;
    const effectiveCash = cashEnabled && (companyCashEnabled !== false);
    res.json({ ok: true, cashEnabled, cardEnabled, companyCashEnabled, effectiveCash });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ── Driver My Job (driver app polls this to get current assigned job) ──────────
// GET /api/driver/myjob?cid=&vehicleId=
// Returns the currently assigned pending job for a vehicle, if any.
// Driver app uses this to display the job details after dispatch assigns it.
router.get('/api/driver/myjob', async (req, res) => {
  setCorsHeaders(res);
  const cid = ((req.query.cid as string) || '').trim();
  const vehicleId = ((req.query.vehicleId as string) || '').trim();
  const driverId  = ((req.query.driverId  as string) || '').trim();
  if (!cid) return res.status(400).json({ ok: false, error: 'cid required' });
  if (!vehicleId && !driverId) return res.status(400).json({ ok: false, error: 'vehicleId or driverId required' });
  try {
    const pending = await fbReadP('pendingjobs/' + cid) as Record<string, any> | null;
    if (!pending) return res.json({ ok: true, job: null });
    // Find any job assigned to this vehicle or driver
    const match = Object.entries(pending).find(([, j]) => {
      if (!j) return false;
      const jVehicle = (j.vehicleId || j.VehicleId || j.assignedVehicle || '').toString();
      const jDriver  = (j.driverId  || j.DriverId  || j.assignedDriver  || '').toString();
      if (vehicleId && jVehicle === vehicleId) return true;
      if (driverId  && jDriver  === driverId)  return true;
      return false;
    });
    if (!match) return res.json({ ok: true, job: null });
    const [jobId, job] = match;
    res.json({ ok: true, job: { ...job, jobId } });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

export default router;
