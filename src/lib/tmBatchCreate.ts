/**
 * Build / refresh council claim batches from approved trips (testing + SA parity).
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

export type BatchCreatePlan = {
  cid: string;
  ym: string;
  pathSuffix: string; // cid/ym under tmBatches/{councilId}/
  trips: Array<{ cid: string; rawKey: string }>;
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

export function subsidyOfTrip(t: CouncilTripLike): number {
  return parseFloat(String(t.tmSubsidy != null ? t.tmSubsidy : t.totalSubsidy || 0)) || 0;
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
