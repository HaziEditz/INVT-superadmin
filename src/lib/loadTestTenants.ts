/**
 * Synthetic load-test / regression harness company IDs.
 * Keep their RTDB data for harness runs, but exclude from expensive background scanners.
 */
export function isSyntheticLoadTestCompanyId(cid: string | null | undefined): boolean {
  const c = String(cid || '').trim().toLowerCase();
  if (!c) return false;
  if (c === 'bwtest' || c === 'bwtesttariff') return true;
  if (c.startsWith('bwtest')) return true;
  return false;
}
