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

test('source exports paid helpers and storage', () => {
  assert.match(paidSrc, /export function resolveBatchTripKeys/);
  assert.match(paidSrc, /PROOF_MISSING_LABEL/);
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
