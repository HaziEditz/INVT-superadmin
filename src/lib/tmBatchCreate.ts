/**
 * Build / refresh council claim batches from approved trips (testing + SA parity).
 * Council trip approve also upserts into the month batch via mergeApprovedTripIntoBatch.
 */
import { isClaimEligibleStatus } from './tmAnomaly';
import { tripActivityMs, tripMonthKey } from './tmTripSort';

export type CouncilTripLike = {
  _cid?: string;
  _rawKey?: string;
  status?: string;
  tmSubsidy?: number | string;
  totalSubsidy?: number | string;
  [key: string]: unknown;
};

export type BatchTripRef = { cid: string; rawKey: string };

export type BatchCreatePlan = {
  cid: string;
  ym: string;
  pathSuffix: string; // cid/ym under tmBatches/{councilId}/
  trips: BatchTripRef[];
  tripCount: number;
  totalSubsidy: number;
  payload: Record<string, unknown>;
};

export type ExistingBatchDecision = 'create' | 'refresh' | 'skip';

/** Whether an existing RTDB batch row may be created/refreshed by the test trigger. */
export function shouldWriteBatchCreate(existing: { status?: string } | null | undefined): ExistingBatchDecision {
  if (!existing || typeof existing !== 'object') return 'create';
  const st = String(existing.status || '').trim().toLowerCase();
  if (!st || st === 'draft') return 'create';
  if (st === 'submitted') return 'refresh';
  return 'skip';
}

/**
 * Meter %/cap council claim only — hoist stays out of batch claim totals.
 * Prefer tmSubsidyFare; legacy combined fields fall back to combined − hoist.
 */
export function subsidyOfTrip(t: CouncilTripLike): number {
  const hoist =
    parseFloat(String(t.tmSubsidyHoist ?? t.hoistTotal ?? t.hoistCost ?? 0)) || 0;
  if (t.tmSubsidyFare != null && t.tmSubsidyFare !== '') {
    return parseFloat(String(t.tmSubsidyFare)) || 0;
  }
  const combined =
    parseFloat(
      String(
        t.tmSubsidy != null
          ? t.tmSubsidy
          : t.tmCouncilPays != null
            ? t.tmCouncilPays
            : t.totalSubsidy != null
              ? t.totalSubsidy
              : 0,
      ),
    ) || 0;
  return Math.max(0, +(combined - hoist).toFixed(2));
}

/** Normalize batch trip list entries to { cid, rawKey }. */
export function normalizeBatchTripRefs(
  rawList: unknown,
  defaultCid: string,
): BatchTripRef[] {
  const out: BatchTripRef[] = [];
  const seen = new Set<string>();
  const list = Array.isArray(rawList) ? rawList : [];
  for (const item of list) {
    let cid = defaultCid;
    let rawKey = '';
    if (item && typeof item === 'object') {
      const o = item as Record<string, unknown>;
      rawKey = String(o.rawKey || o._rawKey || o.id || o.bookingId || '').trim();
      cid = String(o.cid || o._cid || defaultCid).trim() || defaultCid;
    } else {
      const s = String(item || '').trim();
      if (s.indexOf('/') > 0) {
        const slash = s.indexOf('/');
        cid = s.slice(0, slash);
        rawKey = s.slice(slash + 1);
      } else {
        rawKey = s;
      }
    }
    if (!cid || !rawKey) continue;
    const k = cid + '/' + rawKey;
    if (seen.has(k)) continue;
    seen.add(k);
    out.push({ cid, rawKey });
  }
  return out;
}

/**
 * Display totals for a claim batch row.
 * Prefer live recount of resolved trips; treat missing status on batch stubs as claimable
 * (lookup often returns refs without status). Fall back to stored tripCount/totalTrips.
 */
export function computeDisplayBatchTotals(
  batch: {
    tripCount?: number | string;
    totalTrips?: number | string;
    totalSubsidy?: number | string;
    claimAmount?: number | string;
  } | null | undefined,
  tripRows: CouncilTripLike[],
): { totalTrips: number; totalSubsidy: number } {
  const b = batch && typeof batch === 'object' ? batch : {};
  if (Array.isArray(tripRows) && tripRows.length) {
    let totalTrips = 0;
    let totalSubsidy = 0;
    for (const t of tripRows) {
      const st = String(t?.status || '').trim().toLowerCase();
      // Skip only when we know the trip is not claim-eligible
      if (st && !isClaimEligibleStatus(st)) continue;
      totalTrips++;
      totalSubsidy += subsidyOfTrip(t);
    }
    if (totalTrips > 0) {
      return { totalTrips, totalSubsidy: +totalSubsidy.toFixed(2) };
    }
  }
  const storedTrips =
    Number(b.tripCount != null && b.tripCount !== '' ? b.tripCount : b.totalTrips || 0) || 0;
  const storedSub =
    parseFloat(
      String(b.totalSubsidy != null && b.totalSubsidy !== '' ? b.totalSubsidy : b.claimAmount || 0),
    ) || 0;
  return { totalTrips: storedTrips, totalSubsidy: storedSub };
}

/**
 * Upsert one approved trip into an open month batch (create or refresh submitted/draft).
 * Skips approved/paid batches so council claim lock is preserved.
 */
export function mergeApprovedTripIntoBatch(
  existing: Record<string, unknown> | null | undefined,
  trip: CouncilTripLike,
  opts: {
    who: string;
    now?: number;
    submittedRef?: string;
    notes?: string;
  },
): {
  decision: ExistingBatchDecision;
  cid: string;
  ym: string;
  pathSuffix: string;
  added: boolean;
  payload: Record<string, unknown>;
} | null {
  const cid = String(trip._cid || '').trim();
  const rawKey = String(trip._rawKey || '').trim();
  if (!cid || !rawKey) return null;
  const now = opts.now != null ? Number(opts.now) : Date.now();
  const who = String(opts.who || 'council').trim() || 'council';
  let ym = tripMonthKey(trip);
  if (!ym) ym = new Date(now).toISOString().slice(0, 7);
  const decision = shouldWriteBatchCreate(existing as { status?: string } | null);
  if (decision === 'skip') return null;

  const ex = existing && typeof existing === 'object' ? existing : {};
  const trips = normalizeBatchTripRefs((ex as { trips?: unknown }).trips, cid);
  const already = trips.some((x) => x.cid === cid && x.rawKey === rawKey);
  let totalSubsidy =
    parseFloat(
      String(
        (ex as { totalSubsidy?: unknown }).totalSubsidy != null
          ? (ex as { totalSubsidy?: unknown }).totalSubsidy
          : (ex as { claimAmount?: unknown }).claimAmount || 0,
      ),
    ) || 0;

  if (!already) {
    trips.push({ cid, rawKey });
    totalSubsidy += subsidyOfTrip(trip);
  } else if (!trips.length) {
    trips.push({ cid, rawKey });
    totalSubsidy = subsidyOfTrip(trip);
  }

  totalSubsidy = +totalSubsidy.toFixed(2);
  const payload: Record<string, unknown> = {
    status: 'submitted',
    submittedAt: (ex as { submittedAt?: unknown }).submittedAt || now,
    submittedBy: (ex as { submittedBy?: unknown }).submittedBy || who,
    submittedRef:
      (ex as { submittedRef?: unknown }).submittedRef ||
      opts.submittedRef ||
      'council-trip-approve',
    notes:
      (ex as { notes?: unknown }).notes ||
      opts.notes ||
      'Auto-added when council approved trip',
    tripCount: trips.length,
    totalTrips: trips.length,
    claimAmount: totalSubsidy,
    totalSubsidy,
    trips,
  };
  return {
    decision,
    cid,
    ym,
    pathSuffix: cid + '/' + ym,
    added: !already,
    payload,
  };
}

/**
 * Aggregate claim-eligible trips into submitted batch payloads.
 * Optional companyId / month filters for targeted testing.
 */
export function planCouncilBatchCreates(
  trips: CouncilTripLike[],
  opts: {
    councilId: string;
    companyId?: string;
    month?: string;
    who: string;
    now?: number;
  },
): BatchCreatePlan[] {
  const councilId = String(opts.councilId || '').trim();
  const companyFilter = String(opts.companyId || '').trim();
  const monthFilter = String(opts.month || '').trim();
  const who = String(opts.who || 'council').trim() || 'council';
  const now = opts.now != null ? Number(opts.now) : Date.now();
  if (!councilId) return [];

  type Agg = {
    cid: string;
    ym: string;
    trips: Array<{ cid: string; rawKey: string }>;
    totalSubsidy: number;
  };
  const agg = new Map<string, Agg>();

  for (const t of trips || []) {
    if (!isClaimEligibleStatus(t.status)) continue;
    const cid = String(t._cid || '').trim();
    const rawKey = String(t._rawKey || '').trim();
    if (!cid || !rawKey) continue;
    if (companyFilter && cid !== companyFilter) continue;
    const ym = tripMonthKey(t);
    if (!ym) continue;
    if (monthFilter && ym !== monthFilter) continue;
    // Prefer activity month; ignore trips with no clock
    if (!tripActivityMs(t)) continue;

    const key = cid + '/' + ym;
    let row = agg.get(key);
    if (!row) {
      row = { cid, ym, trips: [], totalSubsidy: 0 };
      agg.set(key, row);
    }
    if (row.trips.some((x) => x.rawKey === rawKey && x.cid === cid)) continue;
    row.trips.push({ cid, rawKey });
    row.totalSubsidy += subsidyOfTrip(t);
  }

  return Array.from(agg.values())
    .map((a) => {
      const totalSubsidy = +a.totalSubsidy.toFixed(2);
      const payload: Record<string, unknown> = {
        status: 'submitted',
        submittedAt: now,
        submittedBy: who,
        submittedRef: 'council-create-now',
        notes: 'Created via council Create/submit batch now (testing)',
        tripCount: a.trips.length,
        totalTrips: a.trips.length,
        claimAmount: totalSubsidy,
        totalSubsidy,
        trips: a.trips,
      };
      return {
        cid: a.cid,
        ym: a.ym,
        pathSuffix: a.cid + '/' + a.ym,
        trips: a.trips,
        tripCount: a.trips.length,
        totalSubsidy,
        payload,
      };
    })
    .sort((a, b) => b.ym.localeCompare(a.ym) || a.cid.localeCompare(b.cid));
}
