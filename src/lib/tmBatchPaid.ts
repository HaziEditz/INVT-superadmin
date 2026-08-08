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
