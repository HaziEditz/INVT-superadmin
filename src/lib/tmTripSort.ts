/**
 * Council trip list/sort helpers — prefer real numeric activity time over empty ISO strings.
 */

function coerceTimeMs(raw: unknown): number {
  if (raw == null || raw === '') return 0;
  if (typeof raw === 'number') {
    if (!Number.isFinite(raw) || raw <= 0) return 0;
    return raw < 1e12 ? Math.round(raw * 1000) : Math.round(raw);
  }
  const s = String(raw).trim();
  if (!s) return 0;
  if (/^\d{10,13}$/.test(s)) {
    let n = Number(s);
    if (!Number.isFinite(n) || n <= 0) return 0;
    if (n < 1e12) n *= 1000;
    return Math.round(n);
  }
  const parsed = Date.parse(s);
  return Number.isFinite(parsed) ? parsed : 0;
}

/**
 * Best available trip activity timestamp (ms).
 * Prefer start, then complete — matches what Reports Date column falls back to.
 */
export function tripActivityMs(t: Record<string, unknown> | null | undefined): number {
  if (!t || typeof t !== 'object') return 0;
  return (
    coerceTimeMs(t.startedAt_ISO) ||
    coerceTimeMs(t.startedAt) ||
    coerceTimeMs(t.completedAt_ISO) ||
    coerceTimeMs(t.completedAt) ||
    coerceTimeMs(t.JobCompleteTime) ||
    coerceTimeMs(t.submittedAt) ||
    coerceTimeMs(t.approvedAt) ||
    coerceTimeMs(t.createdAt) ||
    coerceTimeMs(t.CreatedAt) ||
    0
  );
}

/** Newest-first comparator for council trip lists. */
export function compareTripsNewestFirst(a: Record<string, unknown>, b: Record<string, unknown>): number {
  return tripActivityMs(b) - tripActivityMs(a);
}

/** YYYY-MM from trip activity time (UTC), or null if unknown. */
export function tripMonthKey(t: Record<string, unknown> | null | undefined): string | null {
  const ms = tripActivityMs(t);
  if (!ms) return null;
  return new Date(ms).toISOString().slice(0, 7);
}
