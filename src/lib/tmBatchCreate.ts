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

/** Approve upsert decision (includes addendum spill when month is locked). */
export type ApproveBatchDecision = 'create' | 'refresh' | 'addendum';

const BATCH_KEY_RE = /^(\d{4}-\d{2})(?:-b([2-9]|[1-9]\d+))?$/;

/** Base YYYY-MM from keys like 2026-08 or 2026-08-b2. */
export function baseYmFromBatchKey(key: string | null | undefined): string | null {
  const m = String(key || '')
    .trim()
    .match(BATCH_KEY_RE);
  return m ? m[1] : null;
}

/** Parse batch month key → base month + sequence (base=1, -b2=2, …). */
export function parseBatchMonthKey(
  key: string | null | undefined,
): { baseYm: string; seq: number; batchKey: string } | null {
  const batchKey = String(key || '').trim();
  const m = batchKey.match(BATCH_KEY_RE);
  if (!m) return null;
  const baseYm = m[1];
  const seq = m[2] ? parseInt(m[2], 10) : 1;
  if (!Number.isFinite(seq) || seq < 1) return null;
  return { baseYm, seq, batchKey };
}

/** Next unpaid sibling key after locked primary (2026-08 → 2026-08-b2 → b3…). */
export function nextAddendumMonthKey(
  baseYm: string,
  existingKeys: Iterable<string> | null | undefined,
): string {
  const base = String(baseYm || '').trim();
  if (!/^\d{4}-\d{2}$/.test(base)) return base || '0000-00-b2';
  let maxSeq = 1;
  for (const k of existingKeys || []) {
    const parsed = parseBatchMonthKey(k);
    if (!parsed || parsed.baseYm !== base) continue;
    if (parsed.seq > maxSeq) maxSeq = parsed.seq;
  }
  return `${base}-b${maxSeq + 1}`;
}

export function isOpenClaimBatchStatus(status: unknown): boolean {
  const st = String(status || '')
    .trim()
    .toLowerCase();
  return !st || st === 'draft' || st === 'submitted';
}

export function isLockedClaimBatchStatus(status: unknown): boolean {
  const st = String(status || '')
    .trim()
    .toLowerCase();
  return st === 'approved' || st === 'paid';
}

/** Whether an existing RTDB batch row may be created/refreshed by the test trigger. */
export function shouldWriteBatchCreate(existing: { status?: string } | null | undefined): ExistingBatchDecision {
  if (!existing || typeof existing !== 'object') return 'create';
  const st = String(existing.status || '').trim().toLowerCase();
  if (!st || st === 'draft') return 'create';
  if (st === 'submitted') return 'refresh';
  return 'skip';
}

/**
 * Choose which company batch key to write for an approved trip.
 * Open draft/submitted (base or addendum) → refresh; locked base → new/open addendum.
 */
export function resolveApproveBatchKey(
  companyBatches: Record<string, unknown> | null | undefined,
  baseYm: string,
): {
  batchKey: string;
  existing: Record<string, unknown> | null;
  decision: ApproveBatchDecision;
} {
  const base = String(baseYm || '').trim();
  const map =
    companyBatches && typeof companyBatches === 'object'
      ? (companyBatches as Record<string, unknown>)
      : {};
  const keys = Object.keys(map);

  // Prefer any open sibling for this month (highest seq = latest addendum).
  const openSiblings = keys
    .map((k) => parseBatchMonthKey(k))
    .filter((p): p is NonNullable<typeof p> => !!p && p.baseYm === base)
    .filter((p) => {
      const row = map[p.batchKey];
      return row && typeof row === 'object' && isOpenClaimBatchStatus((row as { status?: unknown }).status);
    })
    .sort((a, b) => b.seq - a.seq);

  if (openSiblings.length) {
    const pick = openSiblings[0];
    const existing = map[pick.batchKey] as Record<string, unknown>;
    return {
      batchKey: pick.batchKey,
      existing,
      decision: pick.seq === 1 && shouldWriteBatchCreate(existing) === 'create' ? 'create' : 'refresh',
    };
  }

  const baseRow = map[base];
  if (!baseRow || typeof baseRow !== 'object') {
    return { batchKey: base, existing: null, decision: 'create' };
  }
  if (isOpenClaimBatchStatus((baseRow as { status?: unknown }).status)) {
    const decision = shouldWriteBatchCreate(baseRow as { status?: string });
    return {
      batchKey: base,
      existing: baseRow as Record<string, unknown>,
      decision: decision === 'create' ? 'create' : 'refresh',
    };
  }

  // Primary month locked (approved/paid) — spill to unpaid addendum.
  const addendumKey = nextAddendumMonthKey(base, keys);
  const existingAdd = map[addendumKey];
  if (existingAdd && typeof existingAdd === 'object' && isOpenClaimBatchStatus((existingAdd as { status?: unknown }).status)) {
    return {
      batchKey: addendumKey,
      existing: existingAdd as Record<string, unknown>,
      decision: 'addendum',
    };
  }
  return { batchKey: addendumKey, existing: null, decision: 'addendum' };
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
 * Prefer planApprovedTripBatchUpsert when company sibling batches are available (addendum spill).
 */
export function mergeApprovedTripIntoBatch(
  existing: Record<string, unknown> | null | undefined,
  trip: CouncilTripLike,
  opts: {
    who: string;
    now?: number;
    submittedRef?: string;
    notes?: string;
    /** Override path month key (e.g. 2026-08-b2). Defaults to trip month. */
    batchKey?: string;
    /** Force decision label when writing a new addendum. */
    decision?: ApproveBatchDecision | ExistingBatchDecision;
  },
): {
  decision: ApproveBatchDecision | ExistingBatchDecision;
  cid: string;
  ym: string;
  batchKey: string;
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
  const batchKey = String(opts.batchKey || ym).trim() || ym;
  const forced = opts.decision;
  let decision: ApproveBatchDecision | ExistingBatchDecision =
    forced || shouldWriteBatchCreate(existing as { status?: string } | null);
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
  const isAddendum = decision === 'addendum' || /-b\d+$/.test(batchKey);
  const payload: Record<string, unknown> = {
    status: 'submitted',
    submittedAt: (ex as { submittedAt?: unknown }).submittedAt || now,
    submittedBy: (ex as { submittedBy?: unknown }).submittedBy || who,
    submittedRef:
      (ex as { submittedRef?: unknown }).submittedRef ||
      opts.submittedRef ||
      (isAddendum ? 'council-trip-approve-addendum' : 'council-trip-approve'),
    notes:
      (ex as { notes?: unknown }).notes ||
      opts.notes ||
      (isAddendum
        ? 'Addendum batch — late approvals after month claim was locked'
        : 'Auto-added when council approved trip'),
    tripCount: trips.length,
    totalTrips: trips.length,
    claimAmount: totalSubsidy,
    totalSubsidy,
    trips,
  };
  if (isAddendum) {
    const parent = baseYmFromBatchKey(batchKey) || ym;
    payload.isAddendum = true;
    payload.parentBatchKey = parent;
  }
  return {
    decision: isAddendum && decision !== 'refresh' ? 'addendum' : decision,
    cid,
    ym,
    batchKey,
    pathSuffix: cid + '/' + batchKey,
    added: !already,
    payload,
  };
}

/**
 * Approve → batch upsert with addendum spill when the primary month batch is locked.
 * Reads all company month keys under tmBatches/{council}/{cid}.
 */
export function planApprovedTripBatchUpsert(
  companyBatches: Record<string, unknown> | null | undefined,
  trip: CouncilTripLike,
  opts: {
    who: string;
    now?: number;
    submittedRef?: string;
    notes?: string;
  },
): {
  decision: ApproveBatchDecision;
  cid: string;
  ym: string;
  batchKey: string;
  pathSuffix: string;
  added: boolean;
  payload: Record<string, unknown>;
} | null {
  const cid = String(trip._cid || '').trim();
  const rawKey = String(trip._rawKey || '').trim();
  if (!cid || !rawKey) return null;
  const now = opts.now != null ? Number(opts.now) : Date.now();
  let baseYm = tripMonthKey(trip);
  if (!baseYm) baseYm = new Date(now).toISOString().slice(0, 7);

  const map =
    companyBatches && typeof companyBatches === 'object'
      ? (companyBatches as Record<string, unknown>)
      : {};

  // Idempotent: if trip already listed on any sibling, refresh that open batch
  // or no-op when it already sits on a locked claim.
  for (const key of Object.keys(map)) {
    const row = map[key];
    if (!row || typeof row !== 'object') continue;
    const parsed = parseBatchMonthKey(key);
    if (!parsed || parsed.baseYm !== baseYm) continue;
    const refs = normalizeBatchTripRefs((row as { trips?: unknown }).trips, cid);
    if (!refs.some((r) => r.cid === cid && r.rawKey === rawKey)) continue;
    if (isLockedClaimBatchStatus((row as { status?: unknown }).status)) {
      return null; // already claimed in locked batch — do not duplicate
    }
    const merged = mergeApprovedTripIntoBatch(row as Record<string, unknown>, trip, {
      ...opts,
      now,
      batchKey: key,
      decision: parsed.seq > 1 ? 'addendum' : 'refresh',
    });
    if (!merged) return null;
    return {
      decision: parsed.seq > 1 ? 'addendum' : 'refresh',
      cid: merged.cid,
      ym: merged.ym,
      batchKey: merged.batchKey,
      pathSuffix: merged.pathSuffix,
      added: merged.added,
      payload: merged.payload,
    };
  }

  const slot = resolveApproveBatchKey(map, baseYm);
  const merged = mergeApprovedTripIntoBatch(slot.existing, trip, {
    ...opts,
    now,
    batchKey: slot.batchKey,
    decision: slot.decision,
    submittedRef:
      opts.submittedRef ||
      (slot.decision === 'addendum' ? 'council-trip-approve-addendum' : 'council-trip-approve'),
    notes:
      opts.notes ||
      (slot.decision === 'addendum'
        ? 'Addendum batch — late approvals after month claim was locked'
        : undefined),
  });
  if (!merged) return null;
  return {
    decision: slot.decision,
    cid: merged.cid,
    ym: merged.ym,
    batchKey: merged.batchKey,
    pathSuffix: merged.pathSuffix,
    added: merged.added,
    payload: merged.payload,
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
