/**
 * Full TM trip detail fields for council Reports (summary + modal + CSV).
 * Passenger display name = cardholder name from TM card entry (tmCardName / tmPassengers.cardholderName).
 */

function num(v: unknown, fallback = 0): number {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

function str(v: unknown, fallback = ''): string {
  if (v == null) return fallback;
  return String(v).trim() || fallback;
}

/** Format ISO string or epoch ms/seconds to NZ-readable local datetime. */
export function formatTmDateTime(raw: unknown): string {
  if (raw == null || raw === '') return '';
  if (typeof raw === 'number' || (typeof raw === 'string' && /^\d{10,13}$/.test(raw.trim()))) {
    let ms = Number(raw);
    if (!Number.isFinite(ms) || ms <= 0) return '';
    if (ms < 1e12) ms *= 1000;
    try {
      return new Intl.DateTimeFormat('en-NZ', {
        timeZone: 'Pacific/Auckland',
        year: 'numeric',
        month: 'short',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
      }).format(new Date(ms));
    } catch {
      return new Date(ms).toISOString().slice(0, 16).replace('T', ' ');
    }
  }
  const s = String(raw).trim();
  const parsed = Date.parse(s);
  if (Number.isFinite(parsed)) {
    try {
      return new Intl.DateTimeFormat('en-NZ', {
        timeZone: 'Pacific/Auckland',
        year: 'numeric',
        month: 'short',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
      }).format(new Date(parsed));
    } catch {
      return s.slice(0, 16).replace('T', ' ');
    }
  }
  return s.slice(0, 16).replace('T', ' ');
}

export function formatTmDuration(job: Record<string, any>): string {
  const label = str(job.durationLabel || job.DurationLabel);
  if (label) return label;
  const min = job.durationMin ?? job.DurationMin ?? job.minutes;
  if (min != null && min !== '' && Number.isFinite(Number(min))) {
    return `${Number(min)} min`;
  }
  const dur = job.duration ?? job.Duration;
  if (dur != null && dur !== '') {
    const n = Number(dur);
    if (Number.isFinite(n)) {
      // Heuristic: large values are ms; medium are seconds; small are minutes
      if (n > 1e6) return `${Math.round(n / 60000)} min`;
      if (n > 300) return `${Math.round(n / 60)} min`;
      return `${n} min`;
    }
    return String(dur);
  }
  const startMs = toMs(job.startedAt_ISO || job.startedAt);
  const endMs = toMs(job.completedAt_ISO || job.completedAt);
  if (startMs && endMs && endMs > startMs) {
    return `${Math.round((endMs - startMs) / 60000)} min`;
  }
  return '';
}

function toMs(raw: unknown): number {
  if (raw == null || raw === '') return 0;
  if (typeof raw === 'number' || (typeof raw === 'string' && /^\d{10,13}$/.test(String(raw).trim()))) {
    let ms = Number(raw);
    if (ms < 1e12) ms *= 1000;
    return Number.isFinite(ms) ? ms : 0;
  }
  const p = Date.parse(String(raw));
  return Number.isFinite(p) ? p : 0;
}

function addr(job: Record<string, any>, ...keys: string[]): string {
  for (const k of keys) {
    const v = job[k];
    if (typeof v === 'string' && v.trim()) return v.trim();
  }
  const pickupLoc = job.pickupLocation || job.startLocation || {};
  const dropLoc = job.dropLocation || job.endLocation || job.dropoffLocation || {};
  if (keys[0] && keys[0].toLowerCase().includes('pick') && pickupLoc.address) return String(pickupLoc.address);
  if (
    keys[0] &&
    (keys[0].toLowerCase().includes('drop') || keys[0].toLowerCase().includes('dest')) &&
    dropLoc.address
  ) {
    return String(dropLoc.address);
  }
  return '';
}

function extractCoords(job: Record<string, any>): {
  pickupLat: number;
  pickupLng: number;
  dropLat: number;
  dropLng: number;
} {
  const pickupLoc = job.pickupLocation || job.startLocation || {};
  const dropLoc = job.dropLocation || job.endLocation || job.dropoffLocation || {};
  return {
    pickupLat: num(
      job.pickupLat ?? job.startLat ?? pickupLoc.latitude ?? pickupLoc.lat,
    ),
    pickupLng: num(
      job.pickupLng ?? job.pickupLon ?? job.startLng ?? job.startLon ?? pickupLoc.longitude ?? pickupLoc.lng,
    ),
    dropLat: num(job.dropLat ?? job.endLat ?? job.dropoffLat ?? dropLoc.latitude ?? dropLoc.lat),
    dropLng: num(
      job.dropLng ?? job.dropLon ?? job.endLng ?? job.endLon ?? job.dropoffLng ?? dropLoc.longitude ?? dropLoc.lng,
    ),
  };
}

/** Cardholder name from TM card entry — preferred passenger display. */
export function resolveCardholderName(job: Record<string, any>): string {
  const passengers = Array.isArray(job.tmPassengers) ? job.tmPassengers : [];
  const fromList = passengers
    .map((p: any) => str(p.cardholderName || p.cardHolderName || p.name))
    .filter(Boolean);
  if (fromList.length) return fromList.join(' + ');
  return (
    str(job.tmCardName) ||
    str(job.cardholderName) ||
    str(job.tmPassengerName) ||
    str(job.passengerName) ||
    str(job.customerName) ||
    ''
  );
}

/**
 * Map job source / hail / dispatch / website / passenger app into a display
 * Trip Category. Drivers write `source` (e.g. hail), not `tmTripCategory`, so
 * the council modal was always blank when only tmTripCategory was read.
 */
export function resolveTripCategoryLabel(t: Record<string, any> | null | undefined): string {
  if (!t || typeof t !== 'object') return '—';
  const explicit = str(t.tmTripCategory || t.tripCategory);
  if (explicit && explicit !== '—') return explicit;
  if (t.manuallyAddedByCompany === true || t.manuallyAddedByCompany === 'true') {
    return 'Manually added by company';
  }
  const raw = String(
    t.source || t.bookingSource || t.BookingSource || t.Source || t.via || t.Via || '',
  )
    .toLowerCase()
    .trim();
  if (!raw) return '—';
  if (raw === 'manual_owner' || raw.includes('manual_owner') || raw.includes('manual owner')) {
    return 'Manually added by company';
  }
  if (
    raw.includes('hail') ||
    raw.includes('driverapp') ||
    raw.includes('driver_app') ||
    raw.includes('driver-app') ||
    raw.includes('driver created') ||
    raw.includes('street') ||
    raw === 'queue' ||
    raw.includes('driverqueue')
  ) {
    return 'Hail';
  }
  if (raw.includes('dispatch') || raw.includes('console')) return 'Dispatch';
  if (raw.includes('web') || raw.includes('website')) return 'Website';
  if (raw.includes('passenger') || raw.includes('rider') || raw.includes('pax') || raw.includes('app')) {
    return 'Passenger app';
  }
  if (raw.includes('food')) return 'Food';
  if (raw.includes('freight') || raw.includes('parcel')) return 'Freight';
  if (raw === 'driver_complete') return '—';
  return raw.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

export function isManuallyAddedByCompany(t: Record<string, any> | null | undefined): boolean {
  if (!t || typeof t !== 'object') return false;
  if (t.manuallyAddedByCompany === true || t.manuallyAddedByCompany === 'true') return true;
  const raw = String(t.source || t.bookingSource || '').toLowerCase();
  return raw === 'manual_owner' || raw.includes('manual_owner');
}

export type TmTripDetail = {
  id: string;
  cid: string;
  rawKey: string;
  companyName: string;
  status: string;
  passengerName: string;
  voucherNo: string;
  allCards: string;
  tripCategory: string;
  /** Owner-panel manual entry — surface “Manually added by company” in UI. */
  manuallyAddedByCompany: boolean;
  dateTime: string;
  endTime: string;
  /** Raw values for edit forms (ISO or epoch) — avoid round-tripping display strings. */
  startedAtRaw: string;
  completedAtRaw: string;
  pickup: string;
  dropoff: string;
  distanceKm: string;
  duration: string;
  driverName: string;
  vehicleId: string;
  paymentMethod: string;
  meterFare: number;
  waitingCharge: number;
  meterSubsidy: number;
  hoistCouncil: number;
  hoistLines: string;
  totalCouncil: number;
  passengerShare: number;
  passengerPays: number;
  passengerCount: number;
  splitNote: string;
  pickupLat: number;
  pickupLng: number;
  dropLat: number;
  dropLng: number;
  revisionNote: string;
  expectedMeter: number | null;
  fareMismatch: boolean;
};

export type RefTariff = {
  base?: number;
  perKm?: number;
  perMin?: number;
  stopFee?: number;
};

/** Expected meter from reference price list (car rates by default). */
export function expectedMeterFromTariff(
  tariff: RefTariff | null | undefined,
  distanceKm: number,
  durationMin: number,
  waitingMin = 0,
): number | null {
  if (!tariff || typeof tariff !== 'object') return null;
  const base = num(tariff.base);
  const perKm = num(tariff.perKm);
  const perMin = num(tariff.perMin);
  const stop = num(tariff.stopFee);
  if (!base && !perKm && !perMin && !stop) return null;
  return +(base + distanceKm * perKm + durationMin * perMin + waitingMin * stop).toFixed(2);
}

export function buildTmTripDetail(
  t: Record<string, any>,
  opts?: { refTariff?: RefTariff | null },
): TmTripDetail {
  const passengers = Array.isArray(t.tmPassengers) ? t.tmPassengers : [];
  const vouchers = Array.isArray(t.tmVoucherNumbers) ? t.tmVoucherNumbers : [];
  const cardNums = passengers.length
    ? passengers.map((p: any) => p.cardNumber || '').filter(Boolean)
    : vouchers.length
      ? vouchers.map(String)
      : [str(t.tmVoucherNo || t.tmCardNumber || t.cardNumber)].filter(Boolean);

  const waiting = num(t.waitingCost ?? t.WaitingCost ?? t.waitingCharge ?? t.waitingFee);
  const meterFare = num(t.fare ?? t.tmMeterFare ?? t.meterFare);
  const hoist = num(t.tmSubsidyHoist ?? t.hoistTotal);
  // Meter %/cap claim only — never fold hoist into the claim figure.
  let meterSubsidy = 0;
  if (t.tmSubsidyFare != null && t.tmSubsidyFare !== '') {
    meterSubsidy = num(t.tmSubsidyFare);
  } else {
    const combined = num(t.tmSubsidy ?? t.tmCouncilPays);
    meterSubsidy = Math.max(0, +(combined - hoist).toFixed(2));
  }
  // Display-only grand total (meter claim + hoist); not used as the claim column.
  const totalCouncil = +(meterSubsidy + hoist).toFixed(2);
  const passengerShare = Math.max(0, meterFare - meterSubsidy);
  const passengerPays = num(t.tmPassengerPays ?? passengerShare + waiting);
  const paxCount = cardNums.length || num(t.tmPassengerCount, 1) || 1;

  const hoistArr = Array.isArray(t.tmHoists) ? t.tmHoists : [];
  const hoistLines = hoistArr.length
    ? hoistArr
        .map((h: any, i: number) => `Hoist ${i + 1} card ${h.cardNumber || '—'} $${num(h.amount).toFixed(2)}`)
        .join('; ')
    : hoist > 0
      ? `Hoist total $${hoist.toFixed(2)}`
      : '';

  const distRaw = t.distanceKm || t.distance || t.distanceTravelled || t.tripDistanceKm || '';
  const distanceKmNum =
    distRaw !== '' && distRaw != null && Number.isFinite(Number(distRaw)) ? Number(distRaw) : 0;
  const distanceKm = distanceKmNum ? distanceKmNum.toFixed(2) : '';
  const durationStr = formatTmDuration(t) || '';
  const durationMinMatch = durationStr.match(/([\d.]+)\s*min/i);
  const durationMin = durationMinMatch ? Number(durationMinMatch[1]) : num(t.durationMin);

  const coords = extractCoords(t);
  let expected: number | null = null;
  if (opts?.refTariff) {
    const stopFee = num(opts.refTariff.stopFee);
    const waitMin = stopFee > 0 && waiting > 0 ? waiting / stopFee : 0;
    expected = expectedMeterFromTariff(opts.refTariff, distanceKmNum, durationMin, waitMin);
  }
  const fareMismatch =
    expected != null && meterFare > 0 && Math.abs(meterFare - expected) > Math.max(1, expected * 0.15);

  const driverName =
    str(t.driverFullName || t.driverDisplayName || t.driverName || t.driver_name || t.driverEmail) || '—';

  return {
    id: str(t.bookingId || t._rawKey || '—'),
    cid: str(t._cid),
    rawKey: str(t._rawKey),
    companyName: str(t._companyName || '—'),
    status: str(t.status || 'pending'),
    passengerName: resolveCardholderName(t) || '—',
    voucherNo: str(t.tmVoucherNo || t.tmCardNumber || cardNums[0] || '—'),
    allCards: cardNums.join(', ') || str(t.tmVoucherNo || t.tmCardNumber) || '—',
    tripCategory: resolveTripCategoryLabel(t),
    manuallyAddedByCompany: isManuallyAddedByCompany(t),
    dateTime: formatTmDateTime(t.startedAt_ISO || t.startedAt || t.completedAt_ISO || t.completedAt) || '—',
    endTime: formatTmDateTime(t.completedAt_ISO || t.completedAt) || '—',
    startedAtRaw: str(t.startedAt_ISO || t.startedAt || ''),
    completedAtRaw: str(t.completedAt_ISO || t.completedAt || ''),
    pickup: addr(t, 'pickupAddress', 'pickup', 'source', 'pickupLocation_address') || '—',
    dropoff: addr(t, 'dropAddress', 'dropoff', 'destination', 'dropLocation_address') || '—',
    distanceKm,
    duration: durationStr || '—',
    driverName,
    vehicleId: str(t.vehicleId || t.vehicle || t.taxiNumber || '—'),
    paymentMethod: str(
      t.paymentType || t.paymentMethod || t.PaymentMethod || t.payMethod || t.tmPaymentType || '—',
    ),
    meterFare,
    waitingCharge: waiting,
    meterSubsidy,
    hoistCouncil: hoist,
    hoistLines,
    totalCouncil,
    passengerShare,
    passengerPays,
    passengerCount: paxCount,
    splitNote:
      paxCount > 1
        ? `${paxCount} TM passengers — meter split $${(meterFare / paxCount).toFixed(2)}/card`
        : '',
    pickupLat: coords.pickupLat,
    pickupLng: coords.pickupLng,
    dropLat: coords.dropLat,
    dropLng: coords.dropLng,
    revisionNote: str(t.revisionNote || t.revisionNotes || ''),
    expectedMeter: expected,
    fareMismatch,
  };
}

export const TM_TRIP_CSV_HEADERS = [
  'Date',
  'End',
  'Operator',
  'Driver',
  'Vehicle',
  'Passenger (cardholder)',
  'Voucher / Cards',
  'Trip Category',
  'Pickup',
  'Dropoff',
  'Distance km',
  'Duration',
  'Meter Fare',
  'Expected Meter',
  'Waiting',
  'Meter Subsidy',
  'Hoist (council)',
  'Hoist detail',
  'Total Council',
  'Passenger Share',
  'Passenger Pays',
  'Payment Method',
  'Split',
  'Status',
  'Booking / Job ID',
] as const;

export function tmTripDetailToCsvRow(d: TmTripDetail): string[] {
  return [
    d.dateTime,
    d.endTime,
    d.companyName,
    d.driverName,
    d.vehicleId,
    d.passengerName,
    d.allCards,
    d.tripCategory,
    d.pickup,
    d.dropoff,
    d.distanceKm,
    d.duration,
    d.meterFare.toFixed(2),
    d.expectedMeter != null ? d.expectedMeter.toFixed(2) : '',
    d.waitingCharge.toFixed(2),
    d.meterSubsidy.toFixed(2),
    d.hoistCouncil.toFixed(2),
    d.hoistLines,
    d.totalCouncil.toFixed(2),
    d.passengerShare.toFixed(2),
    d.passengerPays.toFixed(2),
    d.paymentMethod,
    d.splitNote,
    d.status,
    d.id,
  ];
}
