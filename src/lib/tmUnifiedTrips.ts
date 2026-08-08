/**
 * Unified council Trips view — status filter + usage aggregates + entity reports.
 */
import { isArchivedStatus } from './tmArchive';
import { tripActivityMs } from './tmTripSort';
import { tripMatchesSearch, type SearchableTrip } from './tmTripSearch';

export type UnifiedTripStatusFilter =
  | 'all'
  | 'pending'
  | 'flagged'
  | 'archived'
  | 'approved'
  | 'paid'
  | 'rejected';

export const UNIFIED_TRIP_STATUS_OPTIONS: Array<{ value: UnifiedTripStatusFilter; label: string }> = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'flagged', label: 'Flagged' },
  { value: 'archived', label: 'Archived' },
  { value: 'approved', label: 'Approved' },
  { value: 'paid', label: 'Paid' },
  { value: 'rejected', label: 'Rejected' },
];

export type EntityType = 'company' | 'driver' | 'vehicle' | 'card' | 'passenger';

export const ENTITY_TYPES: EntityType[] = ['company', 'driver', 'vehicle', 'card', 'passenger'];

export function normalizeUnifiedTripStatus(
  raw: string | null | undefined,
): UnifiedTripStatusFilter {
  const s = String(raw || '').trim().toLowerCase();
  if (
    s === 'pending' ||
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
  if (s === 'submitted' || s === 'anomalies') return s === 'anomalies' ? 'flagged' : 'pending';
  if (s === 'reports' || s === 'search' || s === 'trips') return 'all';
  return 'all';
}

/** Map legacy returnTo page names → unified status (for post-action redirects). */
export function legacyReturnToStatus(returnTo: string | null | undefined): UnifiedTripStatusFilter {
  const rt = String(returnTo || '').trim().toLowerCase();
  if (rt === 'anomalies' || rt === 'flagged') return 'flagged';
  if (rt === 'archived') return 'archived';
  if (rt === 'pending' || rt === 'submitted') return 'pending';
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
  trip: { status?: string } | null | undefined,
  status: UnifiedTripStatusFilter,
): boolean {
  if (!trip) return false;
  const st = String(trip.status || '').trim().toLowerCase();
  if (status === 'all') return !isArchivedStatus(st);
  if (status === 'pending') return st === 'submitted';
  if (status === 'flagged') return st === 'flagged';
  if (status === 'archived') return isArchivedStatus(st);
  if (status === 'approved') return st === 'approved';
  if (status === 'paid') return st === 'paid';
  if (status === 'rejected') return st === 'rejected';
  return true;
}

export function filterTripsUnified<T extends SearchableTrip & { status?: string; _cid?: string }>(
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
    const fromMs = Date.parse(String(opts.from) + 'T00:00:00');
    if (Number.isFinite(fromMs)) rows = rows.filter((t) => tripActivityMs(t as any) >= fromMs);
  }
  if (opts.to) {
    const toMs = Date.parse(String(opts.to) + 'T23:59:59');
    if (Number.isFinite(toMs)) rows = rows.filter((t) => tripActivityMs(t as any) <= toMs);
  }
  rows.sort((a, b) => tripActivityMs(b as any) - tripActivityMs(a as any));
  return rows;
}

export type UsageBucket = {
  key: string;
  label: string;
  trips: number;
  councilPays: number;
  hoistPays: number;
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
  councilPays: number;
  hoistPays: number;
  hoistUses: number;
};

export type EntityTotals = {
  trips: number;
  meterFare: number;
  councilPays: number;
  passengerPays: number;
  hoistPays: number;
  hoistUses: number;
};

export function subsidyOf(t: any): number {
  return parseFloat(String(t.tmSubsidy != null ? t.tmSubsidy : t.tmCouncilPays || 0)) || 0;
}

export function hoistPaysOf(t: any): number {
  return (
    parseFloat(String(t.tmSubsidyHoist ?? t.hoistTotal ?? t.hoistCost ?? 0)) || 0
  );
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
    if (s) keys.push(s);
  }
  if (Array.isArray(t?.allCardNums)) {
    for (const n of t.allCardNums) {
      const s = String(n || '').trim();
      if (s) keys.push(s);
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
  if (type === 'passenger') return normKey(tripPassengerKey(trip)) === wantN;
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
  councilPays: number,
  hoistPays: number,
): void {
  const k = String(key || '').trim() || '—';
  let row = map.get(k);
  if (!row) {
    row = { key: k, label: label || k, trips: 0, councilPays: 0, hoistPays: 0 };
    map.set(k, row);
  }
  row.trips++;
  row.councilPays += councilPays;
  row.hoistPays += hoistPays;
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
    const pay = subsidyOf(t);
    const hoist = hoistPaysOf(t);
    const card =
      tripCardKeys(t)[0] ||
      '—';
    const cardLabel = tripPassengerKey(t);
    bumpUsage(
      cards,
      card,
      cardLabel + (card !== '—' && cardLabel !== card && cardLabel !== '—' ? ` (${card})` : card === '—' ? cardLabel : ` (${card})`),
      pay,
      hoist,
    );

    const driver = tripDriverKey(t);
    bumpUsage(drivers, driver, driver, pay, hoist);

    const vehicle = tripVehicleKey(t);
    bumpUsage(vehicles, vehicle, vehicle, pay, hoist);

    const passenger = tripPassengerKey(t);
    bumpUsage(passengers, passenger, passenger, pay, hoist);
  }

  const sortTop = (m: Map<string, UsageBucket>) => {
    let rows = Array.from(m.values())
      .map((r) => ({
        ...r,
        councilPays: +r.councilPays.toFixed(2),
        hoistPays: +r.hoistPays.toFixed(2),
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
      row = { key, trips: 0, councilPays: 0, hoistPays: 0, hoistUses: 0 };
      map.set(key, row);
    }
    row.trips++;
    row.councilPays += subsidyOf(t);
    row.hoistPays += hoistPaysOf(t);
    row.hoistUses += hoistUsesOf(t);
  }
  return Array.from(map.values())
    .map((r) => ({
      ...r,
      councilPays: +r.councilPays.toFixed(2),
      hoistPays: +r.hoistPays.toFixed(2),
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
    meterFare += parseFloat(String(t.tmMeterFare ?? t.fare ?? t.Fare ?? 0)) || 0;
    const hoist = hoistPaysOf(t);
    hoistPays += hoist;
    hoistUses += hoistUsesOf(t);
    const council = subsidyOf(t);
    councilPays += council;
    const pax =
      parseFloat(String(t.tmPassengerPays ?? t.passengerPays ?? 0)) ||
      Math.max(0, (parseFloat(String(t.tmMeterFare ?? t.fare ?? 0)) || 0) - (council - hoist));
    passengerPays += pax;
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
      if (st === 'submitted') out.pending++;
      else if (st === 'flagged') out.flagged++;
      else if (st === 'approved') out.approved++;
      else if (st === 'paid') out.paid++;
      else if (st === 'rejected') out.rejected++;
    }
  }
  return out;
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
