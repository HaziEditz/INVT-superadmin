/**
 * Lifecycle clarity markers for TM trip lists (council + SA).
 * Additive badges only — does not change status machine.
 */

/** Statuses where a prior return→resubmit still needs human attention. */
const RESUBMIT_VISIBLE_STATUSES = new Set([
  'submitted',
  'pending',
  'company_approved',
  'flagged',
]);

function hasResubmittedAt(trip: { resubmittedAt?: unknown } | null | undefined): boolean {
  if (!trip) return false;
  return trip.resubmittedAt != null && trip.resubmittedAt !== '';
}

/**
 * Council Revision tab: company says fixed — awaiting council recheck.
 * status=submitted + resubmittedAt (no new status value).
 */
export function isAwaitingCouncilRecheck(
  trip: { status?: string | null; resubmittedAt?: unknown } | null | undefined,
): boolean {
  if (!hasResubmittedAt(trip)) return false;
  const st = String(trip?.status || '')
    .trim()
    .toLowerCase();
  return st === 'submitted';
}

/** Council list: returned to company, waiting on owner Save & Resubmit. */
export function isAwaitingCompanyFix(
  trip: { status?: string | null } | null | undefined,
): boolean {
  if (!trip) return false;
  return (
    String(trip.status || '')
      .trim()
      .toLowerCase() === 'revision_needed'
  );
}

export function hasResubmittedMarker(
  trip: { status?: string | null; resubmittedAt?: unknown } | null | undefined,
): boolean {
  if (!hasResubmittedAt(trip)) return false;
  const st = String(trip.status || '')
    .trim()
    .toLowerCase();
  return RESUBMIT_VISIBLE_STATUSES.has(st);
}

export function hasRestoredMarker(
  trip: { status?: string | null; restoredAt?: unknown } | null | undefined,
): boolean {
  if (!trip || trip.restoredAt == null || trip.restoredAt === '') return false;
  const st = String(trip.status || '')
    .trim()
    .toLowerCase();
  return st !== 'archived';
}

export const RESUBMITTED_BADGE_LABEL = 'Resubmitted - previously returned';
export const RESTORED_BADGE_LABEL = 'Restored from archive';
/** Council badge while status is revision_needed (with company). */
export const AWAITING_COMPANY_FIX_LABEL = 'Awaiting company fix';

/** Plain labels for list chips (caller wraps in HTML). */
export function lifecycleMarkerLabels(
  trip: {
    status?: string | null;
    resubmittedAt?: unknown;
    restoredAt?: unknown;
  } | null | undefined,
): string[] {
  const out: string[] = [];
  if (hasResubmittedMarker(trip)) out.push(RESUBMITTED_BADGE_LABEL);
  if (hasRestoredMarker(trip)) out.push(RESTORED_BADGE_LABEL);
  return out;
}

/**
 * Sort key boost: resubmitted awaiting review before brand-new.
 * Use when ranking Pending (or equivalent) lists.
 */
export function resubmitSortRank(trip: {
  status?: string | null;
  resubmittedAt?: unknown;
}): number {
  return hasResubmittedMarker(trip) ? 1 : 0;
}

export function compareTripsResubmitFirst<T extends { status?: string | null; resubmittedAt?: unknown }>(
  a: T,
  b: T,
  activityMs: (t: T) => number,
): number {
  const ra = resubmitSortRank(a);
  const rb = resubmitSortRank(b);
  if (rb !== ra) return rb - ra;
  return activityMs(b) - activityMs(a);
}
