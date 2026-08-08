/**
 * Unified council Trips view — status filter + usage aggregates.
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

export type UsageBucket = { key: string; label: string; trips: number; councilPays: number };

function subsidyOf(t: any): number {
  return parseFloat(String(t.tmSubsidy != null ? t.tmSubsidy : t.tmCouncilPays || 0)) || 0;
}

function bump(
  map: Map<string, UsageBucket>,
  key: string,
  label: string,
  councilPays: number,
): void {
  const k = String(key || '').trim() || '—';
  let row = map.get(k);
  if (!row) {
    row = { key: k, label: label || k, trips: 0, councilPays: 0 };
    map.set(k, row);
  }
  row.trips++;
  row.councilPays += councilPays;
}

/** Top usage buckets for Insights panel (scoped to already-filtered trips). */
export function aggregateTripUsage(
  trips: any[],
  limit = 8,
): {
  byCard: UsageBucket[];
  byDriver: UsageBucket[];
  byVehicle: UsageBucket[];
} {
  const cards = new Map<string, UsageBucket>();
  const drivers = new Map<string, UsageBucket>();
  const vehicles = new Map<string, UsageBucket>();

  for (const t of trips || []) {
    const pay = subsidyOf(t);
    const card =
      String(t.tmCardNumber || t.tmVoucherNo || t.cardNumber || '').trim() ||
      (Array.isArray(t.allCardNums) && t.allCardNums[0] ? String(t.allCardNums[0]) : '') ||
      '—';
    const cardLabel =
      String(t.tmCardName || t.tmPassengerName || t.passengerName || card).trim() || card;
    bump(cards, card, cardLabel + (card !== '—' && cardLabel !== card ? ` (${card})` : ''), pay);

    const driver =
      String(t.driverFullName || t.driverDisplayName || t.driverName || t.driver || '—').trim() ||
      '—';
    bump(drivers, driver, driver, pay);

    const vehicle =
      String(t.vehicleId || t.taxiNumber || t.vehicle || t.VehicleNo || '—').trim() || '—';
    bump(vehicles, vehicle, vehicle, pay);
  }

  const sortTop = (m: Map<string, UsageBucket>) =>
    Array.from(m.values())
      .map((r) => ({ ...r, councilPays: +r.councilPays.toFixed(2) }))
      .sort((a, b) => b.trips - a.trips || b.councilPays - a.councilPays)
      .slice(0, limit);

  return {
    byCard: sortTop(cards),
    byDriver: sortTop(drivers),
    byVehicle: sortTop(vehicles),
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
