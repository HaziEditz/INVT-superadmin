/**
 * SA clean-trip scan planning — pure helpers (no Firebase I/O).
 * Gate: shouldAutoApproveCleanTrip (submitted + clean + never flagged).
 */

import { shouldAutoApproveCleanTrip, type AnomalyTripLike } from './tmAnomaly';

export type CleanScanCandidate = {
  cid: string;
  rawKey: string;
  councilId: string;
};

export type CleanScanPlan = {
  candidates: CleanScanCandidate[];
  skipped: number;
  scanned: number;
};

/** From a flat trip list (post anomaly merge), pick auto-approve targets. */
export function planCleanAutoApprovals(trips: AnomalyTripLike[]): CleanScanPlan {
  const list = Array.isArray(trips) ? trips : [];
  const candidates: CleanScanCandidate[] = [];
  let skipped = 0;
  for (const t of list) {
    if (!shouldAutoApproveCleanTrip(t)) {
      skipped++;
      continue;
    }
    const cid = String(t._cid || '').trim();
    const rawKey = String(t._rawKey || '').trim();
    const councilId = String((t as any).councilId || '').trim();
    if (!cid || !rawKey || !councilId) {
      skipped++;
      continue;
    }
    candidates.push({ cid, rawKey, councilId });
  }
  return { candidates, skipped, scanned: list.length };
}

export function summarizeCleanScanResult(opts: {
  scanned: number;
  approved: number;
  flagged: number;
  skipped: number;
  errors?: number;
}): Record<string, number | string> {
  return {
    scanned: opts.scanned,
    approved: opts.approved,
    flagged: opts.flagged,
    skipped: opts.skipped,
    errors: opts.errors || 0,
    note: 'Council Trips UI unchanged — this only promotes clean never-flagged submitted trips into approved + claim batch.',
  };
}
