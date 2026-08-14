/**
 * Unified council Trips view — status filter + usage aggregates + entity reports.
 */
import { isArchivedStatus } from './tmArchive';
import { tripActivityMs } from './tmTripSort';
import { tripMatchesSearch, type SearchableTrip } from './tmTripSearch';
import { tzDayEnd, tzDayStart } from './tzDayBounds';
import {
  compareTripsResubmitFirst,
  isAwaitingCouncilRecheck,
} from './tmLifecycleMarkers';

export type UnifiedTripStatusFilter =
  | 'all'
  | 'pending'
  | 'revision'
  | 'flagged'
  | 'archived'
  | 'approved'
  | 'paid'
  | 'rejected';

export const UNIFIED_TRIP_STATUS_OPTIONS: Array<{ value: UnifiedTripStatusFilter; label: string }> = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'revision', label: 'Revision' },
  { value: 'flagged', label: 'Flagged' },
  { value: 'archived', label: 'Archived' },
  { value: 'approved', label: 'Approved' },
  { value: 'paid', label: 'Paid' },
  { value: 'rejected', label: 'Rejected' },
];

/** Pending tab: council-queue submitted + pre-submit company pipeline statuses. */
const PENDING_TAB_STATUSES = new Set(['submitted', 'pending', 'company_approved']);

export type EntityType = 'company' | 'driver' | 'vehicle' | 'card' | 'passenger';

export const ENTITY_TYPES: EntityType[] = ['company', 'driver', 'vehicle', 'card', 'passenger'];

export function normalizeUnifiedTripStatus(
  raw: string | null | undefined,
): UnifiedTripStatusFilter {
  const s = String(raw || '').trim().toLowerCase();
  if (
    s === 'pending' ||
    s === 'revision' ||
    s === 'flagged' ||
    s === 'archived' ||
    s === 'approved' ||
    s === 'paid' ||
    s === 'rejected' ||
    s === 'all'
  ) {
    return s;
  }
  // Legacy aliases from old nav / returnTo
  if (s === 'revision_needed' || s === 'needs_revision') return 'revision';
  if (s === 'submitted' || s === 'company_approved') return 'pending';
  if (s === 'anomalies') return 'flagged';
  if (s === 'reports' || s === 'search' || s === 'trips') return 'all';
  return 'all';
}

/** Map legacy returnTo page names → unified status (for post-action redirects). */
export function legacyReturnToStatus(returnTo: string | null | undefined): UnifiedTripStatusFilter {
  const rt = String(returnTo || '').trim().toLowerCase();
  if (rt === 'anomalies' || rt === 'flagged') return 'flagged';
  if (rt === 'archived') return 'archived';
  if (rt === 'pending' || rt === 'submitted' || rt === 'company_approved') return 'pending';
  if (rt === 'revision' || rt === 'revision_needed') return 'revision';
  if (rt === 'approved') return 'approved';
  if (rt === 'paid') return 'paid';
  if (rt === 'rejected') return 'rejected';
  if (rt === 'reports' || rt === 'search' || rt === 'trips' || rt === 'all') return 'all';
  return normalizeUnifiedTripStatus(rt);
}

export function normalizeEntityType(raw: string | null | undefined): EntityType | null {
  const s = String(raw || '').trim().toLowerCase();
  if (
    s === 'company' ||
    s === 'driver' ||
    s === 'vehicle' ||
    s === 'card' ||
    s === 'passenger'
  ) {
    return s;
  }
  return null;
}

export function tripMatchesUnifiedStatus(
  trip: { status?: string; resubmittedAt?: unknown } | null | undefined,
  status: UnifiedTripStatusFilter,
): boolean {
  if (!trip) return false;
  const st = String(trip.status || '').trim().toLowerCase();
  if (status === 'all') return !isArchivedStatus(st);
  // Pending = first-look queue; exclude resubmits (those belong on Revision).
  if (status === 'pending') {
    return PENDING_TAB_STATUSES.has(st) && !isAwaitingCouncilRecheck(trip);
  }
  // Revision = company says fixed — awaiting council recheck (submitted + resubmittedAt).
  // revision_needed (awaiting company) is NOT here — stays visible under All only.
  if (status === 'revision') return isAwaitingCouncilRecheck(trip);
  if (status === 'flagged') return st === 'flagged';
  if (status === 'archived') return isArchivedStatus(st);
  if (status === 'approved') return st === 'approved';
  if (status === 'paid') return st === 'paid';
  if (status === 'rejected') return st === 'rejected';
  return true;
}

export function filterTripsUnified<
  T extends SearchableTrip & { status?: string; resubmittedAt?: unknown; _cid?: string },
>(
  trips: T[],
  opts: {
    status?: string | null;
    q?: string | null;
    companyId?: string | null;
    from?: string | null;
    to?: string | null;
  } = {},
): T[] {
  const status = normalizeUnifiedTripStatus(opts.status);
  let rows = (trips || []).slice();
  rows = rows.filter((t) => tripMatchesUnifiedStatus(t, status));
  const companyId = String(opts.companyId || '').trim();
  if (companyId) rows = rows.filter((t) => String(t._cid || '') === companyId);
  const q = String(opts.q || '').trim();
  if (q) rows = rows.filter((t) => tripMatchesSearch(t, q));
  if (opts.from) {
    const fromMs = tzDayStart(String(opts.from).trim(), 'Pacific/Auckland');
    if (fromMs) rows = rows.filter((t) => tripActivityMs(t as any) >= fromMs);
  }
  if (opts.to) {
    const toMs = tzDayEnd(String(opts.to).trim(), 'Pacific/Auckland');
    if (toMs) rows = rows.filter((t) => tripActivityMs(t as any) <= toMs);
  }
  // Revision / Pending: resubmit-aware sort (Revision rows are all resubmits).
  if (status === 'pending' || status === 'revision') {
    rows.sort((a, b) =>
      compareTripsResubmitFirst(a as any, b as any, (t) => tripActivityMs(t as any)),
    );
  } else {
    rows.sort((a, b) => tripActivityMs(b as any) - tripActivityMs(a as any));
  }
  return rows;
}

/** Remainder payment method counts within a usage bucket (Cash / Card / Account…). */
export type PayTypeBucket = {
  trips: number;
  passengerPays: number;
};

export type UsageBucket = {
  key: string;
  label: string;
  trips: number;
  meterFare: number;
  councilPays: number;
  passengerPays: number;
  hoistPays: number;
  /** Passenger remainder payment type → trips + passenger $ */
  payByType: Record<string, PayTypeBucket>;
};

export type HoistDayBucket = {
  day: string;
  uses: number;
  hoistPays: number;
  trips: number;
  tripsWithHoist: number;
};

export type PeriodUsageBucket = {
  key: string;
  trips: number;
  meterFare: number;
  councilPays: number;
  passengerPays: number;
  hoistPays: number;
  hoistUses: number;
  payByType: Record<string, PayTypeBucket>;
};

export type EntityTotals = {
  trips: number;
  meterFare: number;
  councilPays: number;
  passengerPays: number;
  hoistPays: number;
  hoistUses: number;
};

/**
 * Meter %/cap council claim only — never includes flat hoist.
 * Prefer tmSubsidyFare; legacy combined tmSubsidy/tmCouncilPays falls back to combined − hoist.
 */
export function subsidyOf(t: any): number {
  const hoist = hoistPaysOf(t);
  if (t?.tmSubsidyFare != null && t.tmSubsidyFare !== '') {
    return parseFloat(String(t.tmSubsidyFare)) || 0;
  }
  const combined =
    parseFloat(String(t?.tmSubsidy != null ? t.tmSubsidy : t?.tmCouncilPays || 0)) || 0;
  return Math.max(0, +(combined - hoist).toFixed(2));
}

export function hoistPaysOf(t: any): number {
  return (
    parseFloat(String(t.tmSubsidyHoist ?? t.hoistTotal ?? t.hoistCost ?? 0)) || 0
  );
}

/** Meter base used for %/cap split (excludes flat hoist). */
export function meterFareOf(t: any): number {
  return parseFloat(String(t?.tmMeterFare ?? t?.fare ?? t?.Fare ?? t?.meterFare ?? 0)) || 0;
}

/** Passenger remainder after council %/cap (falls back to meter − council). */
export function passengerPaysOf(t: any): number {
  const council = subsidyOf(t);
  const explicit = parseFloat(String(t?.tmPassengerPays ?? t?.passengerPays ?? t?.patientPays ?? ''));
  if (Number.isFinite(explicit) && explicit > 0) return explicit;
  return Math.max(0, +(meterFareOf(t) - council).toFixed(2));
}

/**
 * Normalize passenger remainder payment type for Insights breakdown.
 * Prefers explicit paymentType / paymentMethod fields on the trip record.
 */
export function normalizeTripPayMethod(t: any): string {
  const raw = String(
    t?.paymentType ||
      t?.PaymentType ||
      t?.paymentMethod ||
      t?.PaymentMethod ||
      t?.payMethod ||
      t?.tmPaymentType ||
      t?.tmPassengerPaymentType ||
      '',
  )
    .trim();
  if (!raw || raw === '—') return 'Unknown';
  const lower = raw.toLowerCase();
  if (lower === 'tm' || lower === 'total_mobility' || lower === 'total mobility') {
    return 'TM';
  }
  if (lower === 'eftpos' || lower === 'eFTPOS') return 'EFTPOS';
  if (lower === 'card' || lower === 'credit' || lower === 'debit') return 'Card';
  if (lower === 'cash') return 'Cash';
  if (lower === 'account' || lower === 'charge') return 'Account';
  if (lower === 'acc') return 'ACC';
  return raw.charAt(0).toUpperCase() + raw.slice(1);
}

/** Compact "Cash:2 $14 · Card:1 $6" label for Insights tables. */
export function formatPayByType(payByType: Record<string, PayTypeBucket> | undefined | null): string {
  const entries = Object.entries(payByType || {}).filter(([, v]) => v && v.trips > 0);
  if (!entries.length) return '—';
  entries.sort((a, b) => b[1].trips - a[1].trips || a[0].localeCompare(b[0]));
  return entries
    .map(([k, v]) => `${k}:${v.trips} $${(+v.passengerPays).toFixed(2)}`)
    .join(' · ');
}

function bumpPayType(
  payByType: Record<string, PayTypeBucket>,
  method: string,
  passengerPays: number,
): void {
  const m = String(method || 'Unknown').trim() || 'Unknown';
  let row = payByType[m];
  if (!row) {
    row = { trips: 0, passengerPays: 0 };
    payByType[m] = row;
  }
  row.trips++;
  row.passengerPays += passengerPays;
}

function roundPayByType(
  payByType: Record<string, PayTypeBucket>,
): Record<string, PayTypeBucket> {
  const out: Record<string, PayTypeBucket> = {};
  for (const [k, v] of Object.entries(payByType || {})) {
    out[k] = { trips: v.trips, passengerPays: +v.passengerPays.toFixed(2) };
  }
  return out;
}

/** Count hoist uses on a trip (prefer line items / explicit counts). */
export function hoistUsesOf(t: any): number {
  if (Array.isArray(t?.tmHoists) && t.tmHoists.length) return t.tmHoists.length;
  const counted = parseInt(
    String(t?.tmHoistCount ?? t?.hoistCount ?? t?.hoistUsed ?? ''),
    10,
  );
  if (Number.isFinite(counted) && counted > 0) return counted;
  return hoistPaysOf(t) > 0 ? 1 : 0;
}

/** Calendar day in Pacific/Auckland (YYYY-MM-DD), or empty if unknown. */
export function tripDayKey(t: any): string {
  const ms = tripActivityMs(t);
  if (!ms) return '';
  try {
    return new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Pacific/Auckland',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date(ms));
  } catch {
    return new Date(ms).toISOString().slice(0, 10);
  }
}

export function tripMonthKeyNz(t: any): string {
  const day = tripDayKey(t);
  return day ? day.slice(0, 7) : '';
}

function normKey(s: string): string {
  return String(s || '')
    .trim()
    .toLowerCase()
    .replace(/\s+/g, ' ');
}

export function tripCardKeys(t: any): string[] {
  const keys: string[] = [];
  for (const v of [t?.tmCardNumber, t?.tmVoucherNo, t?.cardNumber]) {
    const s = String(v || '').trim();
    if (s && s !== '—') keys.push(s);
  }
  if (Array.isArray(t?.allCardNums)) {
    for (const n of t.allCardNums) {
      const s = String(n || '').trim();
      if (s && s !== '—') keys.push(s);
    }
  }
  if (Array.isArray(t?.tmVoucherNumbers)) {
    for (const n of t.tmVoucherNumbers) {
      const s = String(n || '').trim();
      if (s && s !== '—') keys.push(s);
    }
  }
  if (t?.allCards) {
    for (const part of String(t.allCards).split(/[,;]/)) {
      const s = part.trim();
      if (s && s !== '—') keys.push(s);
    }
  }
  if (Array.isArray(t?.tmPassengers)) {
    for (const p of t.tmPassengers) {
      const s = String(p?.cardNumber || '').trim();
      if (s && s !== '—') keys.push(s);
    }
  }
  return keys;
}

export function tripDriverKey(t: any): string {
  return (
    String(t?.driverFullName || t?.driverDisplayName || t?.driverName || t?.driver || '')
      .trim() || '—'
  );
}

export function tripVehicleKey(t: any): string {
  return (
    String(
      t?.vehicleId ||
        t?.taxiNumber ||
        t?.registration ||
        t?.vehicle ||
        t?.VehicleNo ||
        '',
    ).trim() || '—'
  );
}

export function tripPassengerKey(t: any): string {
  return (
    String(t?.tmCardName || t?.tmPassengerName || t?.passengerName || t?.cardholderName || '')
      .trim() || '—'
  );
}

/** Prefer the more complete display name (more tokens, then longer). */
export function preferPassengerLabel(a: string, b: string): string {
  const aa = String(a || '').trim();
  const bb = String(b || '').trim();
  if (!aa || aa === '—') return bb || '—';
  if (!bb || bb === '—') return aa;
  const aParts = aa.split(/\s+/).filter(Boolean).length;
  const bParts = bb.split(/\s+/).filter(Boolean).length;
  if (bParts !== aParts) return bParts > aParts ? bb : aa;
  return bb.length > aa.length ? bb : aa;
}

/**
 * Stable passenger identity for Insights: prefer TM card number so incomplete
 * first-name-only captures don't split the same cardholder into two rows.
 */
export function tripPassengerIdentity(t: any): { key: string; label: string } {
  const label = tripPassengerKey(t);
  const card = tripCardKeys(t)[0];
  if (card) return { key: 'card:' + normKey(card), label };
  return { key: 'name:' + normKey(label), label };
}

export function tripMatchesEntity(
  trip: any,
  type: EntityType,
  key: string,
): boolean {
  const want = String(key || '').trim();
  if (!want || !trip) return false;
  const wantN = normKey(want);
  if (type === 'company') return String(trip._cid || '').trim() === want;
  if (type === 'driver') return normKey(tripDriverKey(trip)) === wantN;
  if (type === 'vehicle') return normKey(tripVehicleKey(trip)) === wantN;
  if (type === 'card') {
    return tripCardKeys(trip).some((k) => normKey(k) === wantN || k === want);
  }
  if (type === 'passenger') {
    const id = tripPassengerIdentity(trip);
    if (normKey(id.key) === wantN || id.key === want) return true;
    if (normKey(tripPassengerKey(trip)) === wantN) return true;
    const bare = wantN.replace(/^card:/, '').replace(/^name:/, '');
    if (tripCardKeys(trip).some((k) => normKey(k) === bare)) return true;
    return false;
  }
  return false;
}

export function filterTripsByEntity<T>(
  trips: T[],
  type: EntityType,
  key: string,
): T[] {
  return (trips || []).filter((t) => tripMatchesEntity(t, type, key));
}

function bumpUsage(
  map: Map<string, UsageBucket>,
  key: string,
  label: string,
  amounts: {
    councilPays: number;
    hoistPays: number;
    meterFare: number;
    passengerPays: number;
    payMethod: string;
  },
): void {
  const k = String(key || '').trim() || '—';
  let row = map.get(k);
  if (!row) {
    row = {
      key: k,
      label: label || k,
      trips: 0,
      meterFare: 0,
      councilPays: 0,
      passengerPays: 0,
      hoistPays: 0,
      payByType: {},
    };
    map.set(k, row);
  }
  row.trips++;
  row.meterFare += amounts.meterFare;
  row.councilPays += amounts.councilPays;
  row.passengerPays += amounts.passengerPays;
  row.hoistPays += amounts.hoistPays;
  bumpPayType(row.payByType, amounts.payMethod, amounts.passengerPays);
  if (label) row.label = preferPassengerLabel(row.label, label);
}

/** Usage buckets for Insights (scoped to already-filtered trips). Default: all rows. */
export function aggregateTripUsage(
  trips: any[],
  limitOrOpts: number | { limit?: number } = Number.POSITIVE_INFINITY,
): {
  byCard: UsageBucket[];
  byDriver: UsageBucket[];
  byVehicle: UsageBucket[];
  byPassenger: UsageBucket[];
} {
  const limit =
    typeof limitOrOpts === 'number'
      ? limitOrOpts
      : limitOrOpts?.limit != null
        ? limitOrOpts.limit
        : Number.POSITIVE_INFINITY;
  const cards = new Map<string, UsageBucket>();
  const drivers = new Map<string, UsageBucket>();
  const vehicles = new Map<string, UsageBucket>();
  const passengers = new Map<string, UsageBucket>();

  for (const t of trips || []) {
    const amounts = {
      councilPays: subsidyOf(t),
      hoistPays: hoistPaysOf(t),
      meterFare: meterFareOf(t),
      passengerPays: passengerPaysOf(t),
      payMethod: normalizeTripPayMethod(t),
    };
    const card = tripCardKeys(t)[0] || '—';
    const cardLabel = tripPassengerKey(t);
    bumpUsage(
      cards,
      card,
      cardLabel + (card !== '—' && cardLabel !== card && cardLabel !== '—' ? ` (${card})` : card === '—' ? cardLabel : ` (${card})`),
      amounts,
    );

    const driver = tripDriverKey(t);
    bumpUsage(drivers, driver, driver, amounts);

    const vehicle = tripVehicleKey(t);
    bumpUsage(vehicles, vehicle, vehicle, amounts);

    const passenger = tripPassengerIdentity(t);
    bumpUsage(passengers, passenger.key, passenger.label, amounts);
  }

  const sortTop = (m: Map<string, UsageBucket>) => {
    let rows = Array.from(m.values())
      .map((r) => ({
        ...r,
        meterFare: +r.meterFare.toFixed(2),
        councilPays: +r.councilPays.toFixed(2),
        passengerPays: +r.passengerPays.toFixed(2),
        hoistPays: +r.hoistPays.toFixed(2),
        payByType: roundPayByType(r.payByType),
      }))
      .sort((a, b) => b.trips - a.trips || b.councilPays - a.councilPays);
    if (Number.isFinite(limit) && limit >= 0) rows = rows.slice(0, limit);
    return rows;
  };

  return {
    byCard: sortTop(cards),
    byDriver: sortTop(drivers),
    byVehicle: sortTop(vehicles),
    byPassenger: sortTop(passengers),
  };
}

/** Day-wise hoist usage (Claim Batches / entity pages). */
export function aggregateHoistByDay(trips: any[]): HoistDayBucket[] {
  const map = new Map<string, HoistDayBucket>();
  for (const t of trips || []) {
    const day = tripDayKey(t) || 'unknown';
    let row = map.get(day);
    if (!row) {
      row = { day, uses: 0, hoistPays: 0, trips: 0, tripsWithHoist: 0 };
      map.set(day, row);
    }
    row.trips++;
    const uses = hoistUsesOf(t);
    const pays = hoistPaysOf(t);
    if (uses > 0 || pays > 0) {
      row.tripsWithHoist++;
      row.uses += uses;
      row.hoistPays += pays;
    }
  }
  return Array.from(map.values())
    .map((r) => ({ ...r, hoistPays: +r.hoistPays.toFixed(2) }))
    .sort((a, b) => a.day.localeCompare(b.day));
}

function aggregateByPeriod(
  trips: any[],
  keyFn: (t: any) => string,
): PeriodUsageBucket[] {
  const map = new Map<string, PeriodUsageBucket>();
  for (const t of trips || []) {
    const key = keyFn(t) || 'unknown';
    let row = map.get(key);
    if (!row) {
      row = {
        key,
        trips: 0,
        meterFare: 0,
        councilPays: 0,
        passengerPays: 0,
        hoistPays: 0,
        hoistUses: 0,
        payByType: {},
      };
      map.set(key, row);
    }
    const meter = meterFareOf(t);
    const council = subsidyOf(t);
    const pax = passengerPaysOf(t);
    const hoist = hoistPaysOf(t);
    row.trips++;
    row.meterFare += meter;
    row.councilPays += council;
    row.passengerPays += pax;
    row.hoistPays += hoist;
    row.hoistUses += hoistUsesOf(t);
    bumpPayType(row.payByType, normalizeTripPayMethod(t), pax);
  }
  return Array.from(map.values())
    .map((r) => ({
      ...r,
      meterFare: +r.meterFare.toFixed(2),
      councilPays: +r.councilPays.toFixed(2),
      passengerPays: +r.passengerPays.toFixed(2),
      hoistPays: +r.hoistPays.toFixed(2),
      payByType: roundPayByType(r.payByType),
    }))
    .sort((a, b) => a.key.localeCompare(b.key));
}

export function aggregateUsageByDay(trips: any[]): PeriodUsageBucket[] {
  return aggregateByPeriod(trips, tripDayKey);
}

export function aggregateUsageByMonth(trips: any[]): PeriodUsageBucket[] {
  return aggregateByPeriod(trips, tripMonthKeyNz);
}

export function sumEntityTotals(trips: any[]): EntityTotals {
  let meterFare = 0;
  let councilPays = 0;
  let passengerPays = 0;
  let hoistPays = 0;
  let hoistUses = 0;
  for (const t of trips || []) {
    meterFare += meterFareOf(t);
    const hoist = hoistPaysOf(t);
    hoistPays += hoist;
    hoistUses += hoistUsesOf(t);
    councilPays += subsidyOf(t);
    passengerPays += passengerPaysOf(t);
  }
  return {
    trips: (trips || []).length,
    meterFare: +meterFare.toFixed(2),
    councilPays: +councilPays.toFixed(2),
    passengerPays: +passengerPays.toFixed(2),
    hoistPays: +hoistPays.toFixed(2),
    hoistUses,
  };
}

/** Count trips per unified status (for tab badges). Uses full scanned list before status filter. */
export function countTripsByUnifiedStatus(trips: any[]): Record<UnifiedTripStatusFilter, number> {
  const out: Record<UnifiedTripStatusFilter, number> = {
    all: 0,
    pending: 0,
    revision: 0,
    flagged: 0,
    archived: 0,
    approved: 0,
    paid: 0,
    rejected: 0,
  };
  for (const t of trips || []) {
    const st = String(t?.status || '').trim().toLowerCase();
    if (isArchivedStatus(st)) out.archived++;
    else {
      out.all++;
      // Specialty tabs are action queues — revision_needed (awaiting company) is All-only.
      if (isAwaitingCouncilRecheck(t)) out.revision++;
      else if (PENDING_TAB_STATUSES.has(st)) out.pending++;
      else if (st === 'flagged') out.flagged++;
      else if (st === 'approved') out.approved++;
      else if (st === 'paid') out.paid++;
      else if (st === 'rejected') out.rejected++;
      else if (st === 'revision_needed') {
        /* All-only — awaiting company fix */
      } else out.pending++; // unknown non-archived → Pending so it stays findable
    }
  }
  return out;
}

/** Distance km for summary totals (0 when missing/invalid). */
export function tripDistanceKmOf(t: any): number {
  const raw = t?.distanceKm ?? t?.distance ?? t?.distanceTravelled ?? t?.tripDistanceKm;
  if (raw == null || raw === '') return 0;
  const n = Number(raw);
  return Number.isFinite(n) && n > 0 ? n : 0;
}

/** Duration minutes for summary totals. */
export function tripDurationMinOf(t: any): number {
  if (t?.durationMin != null && t.durationMin !== '' && Number.isFinite(Number(t.durationMin))) {
    const n = Number(t.durationMin);
    return n > 0 ? n : 0;
  }
  const label = String(t?.duration || t?.durationLabel || t?.DurationMin || '');
  const m = label.match(/([\d.]+)\s*min/i);
  if (m) {
    const n = Number(m[1]);
    return Number.isFinite(n) && n > 0 ? n : 0;
  }
  return 0;
}

export function formatDurationTotal(mins: number): string {
  const total = Math.max(0, Math.round(Number(mins) || 0));
  if (total <= 0) return '0 min';
  const h = Math.floor(total / 60);
  const m = total % 60;
  if (h <= 0) return `${m} min`;
  if (m === 0) return `${h}h`;
  return `${h}h ${m}m`;
}

/**
 * Pure multi-company operators partition — used by Operators page & tests.
 * Ensures each company gets its own driver list (never a mixed bag).
 */
export function partitionOperatorRosters(
  approvedCids: string[],
  driversRoot: Record<string, unknown> | null | undefined,
  listDrivers: (
    root: Record<string, unknown> | null | undefined,
    cid: string,
    opts?: { activeOnly?: boolean },
  ) => Array<{ _uid?: string; companyId?: string; company_id?: string; email?: string; name?: string; firstName?: string }>,
): Array<{ cid: string; drivers: ReturnType<typeof listDrivers> }> {
  return (approvedCids || []).map((cid) => ({
    cid: String(cid),
    drivers: listDrivers(driversRoot, cid, { activeOnly: true }),
  }));
}
