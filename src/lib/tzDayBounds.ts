/**
 * Company-timezone calendar day bounds (Pacific/Auckland by default).
 * Keep in sync with INVT-admin/lib/tzDayBounds.js and owner window._tzDayStart/_tzDayEnd.
 */

function pad2(n: number): string {
  return (n < 10 ? '0' : '') + n;
}

/** Next calendar YYYY-MM-DD after ymd (UTC-date arithmetic on Y/M/D parts). */
export function nextYmd(ymd: string): string {
  const p = String(ymd || '')
    .split('-')
    .map(Number);
  if (p.length !== 3 || !p[0]) return '';
  const dt = new Date(Date.UTC(p[0], p[1] - 1, p[2] + 1));
  return dt.getUTCFullYear() + '-' + pad2(dt.getUTCMonth() + 1) + '-' + pad2(dt.getUTCDate());
}

/**
 * Unix-ms for 00:00:00 on ymd in IANA timezone.
 * Offset sampled at UTC noon probe (same algorithm as owner panel).
 */
export function tzDayStart(ymd: string, timeZone = 'Pacific/Auckland'): number {
  const z = timeZone || 'Pacific/Auckland';
  if (!ymd || !/^\d{4}-\d{2}-\d{2}$/.test(String(ymd))) return 0;
  const p = String(ymd)
    .split('-')
    .map(Number);
  const probe = new Date(Date.UTC(p[0], p[1] - 1, p[2], 12, 0, 0));
  const inTZ = new Date(probe.toLocaleString('en-CA', { timeZone: z, hour12: false }));
  const inUTC = new Date(probe.toLocaleString('en-CA', { timeZone: 'UTC', hour12: false }));
  const offsetMs = inTZ.getTime() - inUTC.getTime();
  return Date.UTC(p[0], p[1] - 1, p[2]) - offsetMs;
}

/** Inclusive end-of-day ms for ymd (= next midnight − 1ms). */
export function tzDayEnd(ymd: string, timeZone = 'Pacific/Auckland'): number {
  const start = tzDayStart(ymd, timeZone);
  if (!start) return 0;
  const next = nextYmd(ymd);
  const nextStart = tzDayStart(next, timeZone);
  return nextStart ? nextStart - 1 : start + 24 * 60 * 60 * 1000 - 1;
}

/** en-NZ calendar date in Pacific/Auckland (for claim batch Submitted/Approved/Paid). */
export function formatNzDate(ts: number | string | null | undefined): string {
  if (ts == null || ts === '') return '—';
  const n = typeof ts === 'number' ? ts : Date.parse(String(ts));
  if (!Number.isFinite(n) || n <= 0) return '—';
  return new Date(n).toLocaleDateString('en-NZ', { timeZone: 'Pacific/Auckland' });
}

/** en-NZ date+time in Pacific/Auckland (trip History log, etc.). */
export function formatNzDateTime(ts: number | string | null | undefined): string {
  if (ts == null || ts === '') return '—';
  const n = typeof ts === 'number' ? ts : Date.parse(String(ts));
  if (!Number.isFinite(n) || n <= 0) return '—';
  return new Date(n).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland' });
}
