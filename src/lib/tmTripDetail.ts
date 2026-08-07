/**
 * Full TM trip detail fields for council Reports (summary + modal + CSV).
 * Aligns with SA TM-Trips viewTT / mapTMTrip completeness.
 */

function num(v: unknown, fallback = 0): number {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

function str(v: unknown, fallback = ''): string {
  if (v == null) return fallback;
  return String(v).trim() || fallback;
}

function addr(job: Record<string, any>, ...keys: string[]): string {
  for (const k of keys) {
    const v = job[k];
    if (typeof v === 'string' && v.trim()) return v.trim();
  }
  const pickupLoc = job.pickupLocation || job.startLocation || {};
  const dropLoc = job.dropLocation || job.endLocation || job.dropoffLocation || {};
  if (keys[0] && keys[0].toLowerCase().includes('pick') && pickupLoc.address) return String(pickupLoc.address);
  if (keys[0] && (keys[0].toLowerCase().includes('drop') || keys[0].toLowerCase().includes('dest')) && dropLoc.address) {
    return String(dropLoc.address);
  }
  return '';
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
  dateTime: string;
  endTime: string;
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
};

export function buildTmTripDetail(t: Record<string, any>): TmTripDetail {
  const passengers = Array.isArray(t.tmPassengers) ? t.tmPassengers : [];
  const vouchers = Array.isArray(t.tmVoucherNumbers) ? t.tmVoucherNumbers : [];
  const cardNums = passengers.length
    ? passengers.map((p: any) => p.cardNumber || '').filter(Boolean)
    : vouchers.length
      ? vouchers.map(String)
      : [str(t.tmVoucherNo || t.cardNumber)].filter(Boolean);

  const waiting = num(t.waitingCost ?? t.WaitingCost ?? t.waitingCharge ?? t.waitingFee);
  const meterFare = num(t.fare ?? t.tmMeterFare ?? t.meterFare);
  const meterSubsidy = num(t.tmSubsidyFare);
  const hoist = num(t.tmSubsidyHoist ?? t.hoistTotal);
  const totalCouncil = num(t.tmSubsidy ?? t.tmCouncilPays ?? meterSubsidy + hoist);
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

  const start = str(t.startedAt_ISO || t.startedAt || t.completedAt_ISO || '');
  const end = str(t.completedAt_ISO || t.completedAt || '');
  const distRaw = t.distanceKm || t.distance || t.distanceTravelled || t.tripDistanceKm || '';
  const distanceKm = distRaw !== '' && distRaw != null ? String(parseFloat(String(distRaw)).toFixed(2)) : '';

  const driverName =
    str(t.driverFullName || t.driverDisplayName || t.driverName || t.driver_name || t.driverEmail) || '—';

  return {
    id: str(t.bookingId || t._rawKey || '—'),
    cid: str(t._cid),
    rawKey: str(t._rawKey),
    companyName: str(t._companyName || '—'),
    status: str(t.status || 'pending'),
    passengerName: str(t.tmPassengerName || t.passengerName || '—'),
    voucherNo: str(t.tmVoucherNo || cardNums[0] || '—'),
    allCards: cardNums.join(', ') || str(t.tmVoucherNo) || '—',
    tripCategory: str(t.tmTripCategory || '—'),
    dateTime: start ? start.slice(0, 16).replace('T', ' ') : '—',
    endTime: end ? end.slice(0, 16).replace('T', ' ') : '—',
    pickup: addr(t, 'pickupAddress', 'pickup', 'source', 'pickupLocation_address') || '—',
    dropoff: addr(t, 'dropAddress', 'dropoff', 'destination', 'dropLocation_address') || '—',
    distanceKm,
    duration: str(t.durationLabel || t.duration || '—'),
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
  };
}

export const TM_TRIP_CSV_HEADERS = [
  'Date',
  'End',
  'Operator',
  'Driver',
  'Vehicle',
  'Passenger',
  'Voucher / Cards',
  'Trip Category',
  'Pickup',
  'Dropoff',
  'Distance km',
  'Duration',
  'Meter Fare',
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
