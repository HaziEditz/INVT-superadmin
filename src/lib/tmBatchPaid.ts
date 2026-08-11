/**
 * Claim-batch Paid helpers: proof metadata + trip cascade list.
 */

export const PROOF_MISSING_LABEL = 'No proof uploaded';

export type BatchPaymentDocMeta = {
  paymentDocUrl: string | null;
  paymentDocName: string | null;
  paymentDocPath: string | null;
  paymentDocUploadedAt: number | null;
  paymentDocUploadedBy: string | null;
  paymentDocMissing: boolean;
};

export function hasPaymentProof(batch: Record<string, any> | null | undefined): boolean {
  if (!batch || typeof batch !== 'object') return false;
  return !!(batch.paymentDocUrl || batch.paymentDocPath || batch.paymentDocName);
};

export function proofMissingFlag(batch: Record<string, any> | null | undefined): boolean {
  const st = String(batch?.status || '').toLowerCase();
  if (st !== 'paid') return false;
  return !hasPaymentProof(batch);
}

export function buildPaidBatchPatch(opts: {
  who: string;
  payRef?: string | null;
  paidAmount?: number | null;
  paidDate?: string | null;
  notes?: string | null;
  doc?: Partial<BatchPaymentDocMeta> | null;
  now?: number;
}): Record<string, any> {
  const now = opts.now != null ? Number(opts.now) : Date.now();
  const patch: Record<string, any> = {
    status: 'paid',
    paidAt: now,
    paidBy: opts.who,
  };
  const ref = opts.payRef != null ? String(opts.payRef).trim() : '';
  if (ref) {
    patch.payRef = ref;
    patch.paidRef = ref;
  }
  if (opts.paidAmount != null && Number.isFinite(Number(opts.paidAmount))) {
    patch.paidAmount = Number(opts.paidAmount);
  }
  if (opts.paidDate) patch.paidDate = String(opts.paidDate);
  if (opts.notes) patch.notes = String(opts.notes);

  const doc = opts.doc;
  if (doc && (doc.paymentDocUrl || doc.paymentDocPath || doc.paymentDocName)) {
    if (doc.paymentDocUrl != null) patch.paymentDocUrl = doc.paymentDocUrl;
    if (doc.paymentDocName != null) patch.paymentDocName = doc.paymentDocName;
    if (doc.paymentDocPath != null) patch.paymentDocPath = doc.paymentDocPath;
    patch.paymentDocUploadedAt = doc.paymentDocUploadedAt != null ? doc.paymentDocUploadedAt : now;
    patch.paymentDocUploadedBy = doc.paymentDocUploadedBy != null ? doc.paymentDocUploadedBy : opts.who;
    patch.paymentDocMissing = false;
  } else {
    patch.paymentDocMissing = true;
  }
  return patch;
}

/** Resolve trip raw keys from a batch record for status cascade. */
export function resolveBatchTripKeys(
  batch: Record<string, any> | null | undefined,
  defaultCid: string,
): Array<{ cid: string; rawKey: string }> {
  if (!batch || typeof batch !== 'object') return [];
  const rawList = Array.isArray(batch.trips)
    ? batch.trips
    : Array.isArray(batch.tripIds)
      ? batch.tripIds
      : [];
  const out: Array<{ cid: string; rawKey: string }> = [];
  const seen = new Set<string>();
  rawList.forEach((item: any) => {
    let cid = String(defaultCid || '').trim();
    let rawKey = '';
    if (item && typeof item === 'object') {
      rawKey = String(item.rawKey || item._rawKey || item.id || item.bookingId || '').trim();
      cid = String(item.cid || item._cid || cid).trim();
    } else {
      const s = String(item || '').trim();
      if (!s) return;
      if (s.indexOf('/') > 0) {
        const parts = s.split('/');
        cid = parts[0];
        rawKey = parts.slice(1).join('/');
      } else {
        rawKey = s;
      }
    }
    if (!cid || !rawKey) return;
    const k = cid + '/' + rawKey;
    if (seen.has(k)) return;
    seen.add(k);
    out.push({ cid, rawKey });
  });
  return out;
}

export function buildTripPaidPatch(who: string, now = Date.now()): Record<string, any> {
  return {
    status: 'paid',
    paidAt: now,
    paidBy: who,
  };
}

/** Claim Batches status tabs / dropdown values. */
export type ClaimBatchStatusFilter =
  | 'all'
  | 'submitted'
  | 'approved'
  | 'paid'
  | 'flagged';

export function normalizeClaimBatchStatusFilter(
  raw: string | null | undefined,
): ClaimBatchStatusFilter {
  const s = String(raw || '').trim().toLowerCase();
  if (s === 'approved' || s === 'paid' || s === 'all' || s === 'flagged' || s === 'submitted') {
    return s;
  }
  return 'submitted';
}

/**
 * Batches that need attention: rejected / revision_needed, or paid without proof.
 */
export function isFlaggedClaimBatch(batch: Record<string, any> | null | undefined): boolean {
  if (!batch || typeof batch !== 'object') return false;
  const st = String(batch.status || '').trim().toLowerCase();
  if (st === 'rejected' || st === 'revision_needed') return true;
  return proofMissingFlag(batch);
}

/** YYYY-MM from a YYYY-MM-DD (or YYYY-MM) date string; null if invalid. */
export function ymFromDateInput(raw: string | null | undefined): string | null {
  const s = String(raw || '').trim();
  if (!s) return null;
  const m = s.match(/^(\d{4}-\d{2})(?:-\d{2})?$/);
  return m ? m[1] : null;
}

/** Include batch month when it falls within optional From/To (inclusive by YYYY-MM). */
export function batchYmInDateRange(
  ym: string | null | undefined,
  from?: string | null,
  to?: string | null,
): boolean {
  const raw = String(ym || '').trim();
  // Accept primary YYYY-MM and addendum keys like 2026-08-b2.
  const monthMatch = raw.match(/^(\d{4}-\d{2})(?:-b(?:[2-9]|[1-9]\d+))?$/);
  const month = monthMatch ? monthMatch[1] : '';
  if (!month) {
    // Unknown month: only include when no date filter is active
    return !ymFromDateInput(from) && !ymFromDateInput(to);
  }
  const fromYm = ymFromDateInput(from);
  const toYm = ymFromDateInput(to);
  if (fromYm && month < fromYm) return false;
  if (toYm && month > toYm) return false;
  return true;
}

export function batchMatchesStatusFilter(
  batch: Record<string, any> | null | undefined,
  status: ClaimBatchStatusFilter,
): boolean {
  if (!batch || typeof batch !== 'object') return false;
  if (status === 'all') return true;
  if (status === 'flagged') return isFlaggedClaimBatch(batch);
  return String(batch.status || '').trim().toLowerCase() === status;
}

/** Filter claim batches by status dropdown/tab + optional From/To month range. */
export function filterClaimBatches<T extends { status?: string; _ym?: string }>(
  batches: T[],
  opts: {
    status?: string | null;
    from?: string | null;
    to?: string | null;
  } = {},
): T[] {
  const status = normalizeClaimBatchStatusFilter(opts.status);
  return (batches || []).filter((b) => {
    if (!batchMatchesStatusFilter(b, status)) return false;
    return batchYmInDateRange(b._ym, opts.from, opts.to);
  });
}

