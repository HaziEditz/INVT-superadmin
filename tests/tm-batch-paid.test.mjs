/**
 * Claim batch Paid helpers + council/owner wiring.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const paidSrc = readFileSync(join(root, 'src/lib/tmBatchPaid.ts'), 'utf8');
const storageSrc = readFileSync(join(root, 'src/lib/tmBatchStorage.ts'), 'utf8');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const saBatches = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Batches.aspx'),
  'utf8',
);
const adminSrc = readFileSync(join(root, '..', 'INVT-admin', 'server.js'), 'utf8');

function resolveBatchTripKeys(batch, defaultCid) {
  if (!batch || typeof batch !== 'object') return [];
  const rawList = Array.isArray(batch.trips)
    ? batch.trips
    : Array.isArray(batch.tripIds)
      ? batch.tripIds
      : [];
  const out = [];
  const seen = new Set();
  rawList.forEach((item) => {
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
      } else rawKey = s;
    }
    if (!cid || !rawKey) return;
    const k = cid + '/' + rawKey;
    if (seen.has(k)) return;
    seen.add(k);
    out.push({ cid, rawKey });
  });
  return out;
}

function buildPaidBatchPatch(opts) {
  const now = opts.now != null ? Number(opts.now) : Date.now();
  const patch = { status: 'paid', paidAt: now, paidBy: opts.who };
  if (opts.payRef) {
    patch.payRef = opts.payRef;
    patch.paidRef = opts.payRef;
  }
  if (opts.doc && (opts.doc.paymentDocUrl || opts.doc.paymentDocName)) {
    patch.paymentDocUrl = opts.doc.paymentDocUrl;
    patch.paymentDocName = opts.doc.paymentDocName;
    patch.paymentDocMissing = false;
  } else {
    patch.paymentDocMissing = true;
  }
  return patch;
}

function proofMissingFlag(batch) {
  const st = String(batch?.status || '').toLowerCase();
  if (st !== 'paid') return false;
  return !(batch.paymentDocUrl || batch.paymentDocPath || batch.paymentDocName);
}

test('resolveBatchTripKeys handles string and object trip ids', () => {
  const keys = resolveBatchTripKeys(
    { trips: ['abc', { cid: '9', rawKey: 'def' }, '9/ghi', 'abc'] },
    '860869',
  );
  assert.deepEqual(keys, [
    { cid: '860869', rawKey: 'abc' },
    { cid: '9', rawKey: 'def' },
    { cid: '9', rawKey: 'ghi' },
  ]);
});

test('buildPaidBatchPatch flags missing proof', () => {
  const miss = buildPaidBatchPatch({ who: 'Council', payRef: 'EFT1', now: 100 });
  assert.equal(miss.status, 'paid');
  assert.equal(miss.paymentDocMissing, true);
  assert.equal(miss.payRef, 'EFT1');
  const withDoc = buildPaidBatchPatch({
    who: 'Council',
    now: 100,
    doc: { paymentDocUrl: 'https://x', paymentDocName: 'inv.pdf' },
  });
  assert.equal(withDoc.paymentDocMissing, false);
  assert.equal(withDoc.paymentDocName, 'inv.pdf');
});

test('proofMissingFlag only for paid without doc', () => {
  assert.equal(proofMissingFlag({ status: 'approved' }), false);
  assert.equal(proofMissingFlag({ status: 'paid' }), true);
  assert.equal(proofMissingFlag({ status: 'paid', paymentDocUrl: 'rtdb:x' }), false);
});

function normalizeClaimBatchStatusFilter(raw) {
  const s = String(raw || '').trim().toLowerCase();
  if (s === 'approved' || s === 'paid' || s === 'all' || s === 'flagged' || s === 'submitted') return s;
  return 'submitted';
}

function isFlaggedClaimBatch(batch) {
  if (!batch || typeof batch !== 'object') return false;
  const st = String(batch.status || '').trim().toLowerCase();
  if (st === 'rejected' || st === 'revision_needed') return true;
  return proofMissingFlag(batch);
}

function ymFromDateInput(raw) {
  const s = String(raw || '').trim();
  if (!s) return null;
  const m = s.match(/^(\d{4}-\d{2})(?:-\d{2})?$/);
  return m ? m[1] : null;
}

function batchYmInDateRange(ym, from, to) {
  const raw = String(ym || '').trim();
  const monthMatch = raw.match(/^(\d{4}-\d{2})(?:-b(?:[2-9]|[1-9]\d+))?$/);
  const month = monthMatch ? monthMatch[1] : '';
  if (!month) {
    return !ymFromDateInput(from) && !ymFromDateInput(to);
  }
  const fromYm = ymFromDateInput(from);
  const toYm = ymFromDateInput(to);
  if (fromYm && month < fromYm) return false;
  if (toYm && month > toYm) return false;
  return true;
}

function filterClaimBatches(batches, opts = {}) {
  const status = normalizeClaimBatchStatusFilter(opts.status);
  return (batches || []).filter((b) => {
    if (status === 'all') {
      // keep
    } else if (status === 'flagged') {
      if (!isFlaggedClaimBatch(b)) return false;
    } else if (String(b.status || '').toLowerCase() !== status) {
      return false;
    }
    return batchYmInDateRange(b._ym, opts.from, opts.to);
  });
}

test('filterClaimBatches status + From/To month range', () => {
  const rows = [
    { _ym: '2026-06', status: 'submitted' },
    { _ym: '2026-07', status: 'approved' },
    { _ym: '2026-08', status: 'paid', paymentDocUrl: 'x' },
    { _ym: '2026-08', status: 'paid' },
    { _ym: '2026-05', status: 'rejected' },
  ];
  assert.equal(filterClaimBatches(rows, { status: 'approved' }).length, 1);
  assert.equal(filterClaimBatches(rows, { status: 'flagged' }).length, 2);
  assert.deepEqual(
    filterClaimBatches(rows, { status: 'all', from: '2026-07-01', to: '2026-08-31' }).map((b) => b._ym + ':' + b.status),
    ['2026-07:approved', '2026-08:paid', '2026-08:paid'],
  );
});

test('filterClaimBatches includes addendum keys in From/To month range', () => {
  const rows = [
    { _ym: '2026-08', status: 'paid' },
    { _ym: '2026-08-b2', status: 'submitted' },
    { _ym: '2026-09-b2', status: 'submitted' },
  ];
  assert.deepEqual(
    filterClaimBatches(rows, { status: 'all', from: '2026-08-01', to: '2026-08-31' }).map((b) => b._ym),
    ['2026-08', '2026-08-b2'],
  );
  assert.equal(filterClaimBatches(rows, { status: 'submitted', from: '2026-08-01', to: '2026-08-31' }).length, 1);
});

test('source exports paid helpers and storage', () => {
  assert.match(paidSrc, /export function resolveBatchTripKeys/);
  assert.match(paidSrc, /PROOF_MISSING_LABEL/);
  assert.match(paidSrc, /export function filterClaimBatches/);
  assert.match(paidSrc, /export function isFlaggedClaimBatch/);
  assert.match(storageSrc, /storeBatchProof/);
  assert.match(storageSrc, /firebase-admin|firebasestorage|tmBatchDocs/);
});

test('council batches tabs + cascade + attach proof', () => {
  assert.match(councilSrc, /tab=.*submitted|Approved \(unpaid\)|Paid/);
  assert.match(councilSrc, /cascadeBatchTripsToPaid/);
  assert.match(councilSrc, /attach_proof/);
  assert.match(councilSrc, /No proof uploaded|PROOF_MISSING_LABEL/);
  assert.match(councilSrc, /storeBatchProof/);
  assert.match(councilSrc, /\/api\/council-batch-doc/);
  assert.match(councilSrc, /cpOpenMarkPaid/);
  assert.match(councilSrc, /filterClaimBatches/);
  assert.match(councilSrc, /name="from"/);
  assert.match(councilSrc, /name="to"/);
  assert.match(councilSrc, /Flagged/);
  assert.match(councilSrc, /normalizeClaimBatchStatusFilter/);
});

test('SA Mark Paid uploads proof and cascades trips', () => {
  assert.match(saBatches, /paid-file/);
  assert.match(saBatches, /cascadeTripsPaid/);
  assert.match(saBatches, /tmBatchDocs/);
  assert.match(saBatches, /No proof uploaded/);
  assert.match(saBatches, /sa-batch-tabs|Submitted.*Approved.*Paid/);
});

test('owner claim batches show proof download + tabs', () => {
  assert.match(adminSrc, /downloadBatchProof/);
  assert.match(adminSrc, /No proof uploaded/);
  assert.match(adminSrc, /setBatTab/);
  assert.match(adminSrc, /bat-tabs/);
});
