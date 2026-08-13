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

export function hasResubmittedMarker(
  trip: { status?: string | null; resubmittedAt?: unknown } | null | undefined,
): boolean {
  if (!trip || trip.resubmittedAt == null || trip.resubmittedAt === '') return false;
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
