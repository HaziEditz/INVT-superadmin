/**
 * One-shot: place orphan approved trips into unpaid addendum batch 2026-08-b2.
 * Does NOT modify the locked paid primary batch 2026-08.
 *
 * Usage: node scripts/backfill-orphan-approved-addendum.mjs
 */
import https from 'node:https';

const ADMIN = 'https://invt-admin-production.up.railway.app';
const COUNCIL = 'cncl_invercargill_city_council_test';
const CID = '860869';
const ORPHANS = ['8692608092', '869260810113'];

function get(path) {
  return new Promise((resolve, reject) => {
    https
      .get(`${ADMIN}/api/admin-read?path=${encodeURIComponent(path)}`, (r) => {
        let d = '';
        r.on('data', (c) => (d += c));
        r.on('end', () => {
          try {
            const j = JSON.parse(d);
            resolve(j.data !== undefined ? j.data : j);
          } catch (e) {
            reject(e);
          }
        });
      })
      .on('error', reject);
  });
}

function postWrite(path, method, data) {
  const body = JSON.stringify({ path, method, data });
  return new Promise((resolve, reject) => {
    const req = https.request(
      `${ADMIN}/api/admin-write`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
      },
      (r) => {
        let d = '';
        r.on('data', (c) => (d += c));
        r.on('end', () => resolve({ status: r.statusCode, body: d }));
      },
    );
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

function subsidyOfTrip(t) {
  const hoist = parseFloat(String(t.tmSubsidyHoist ?? t.hoistTotal ?? t.hoistCost ?? 0)) || 0;
  if (t.tmSubsidyFare != null && t.tmSubsidyFare !== '') {
    return parseFloat(String(t.tmSubsidyFare)) || 0;
  }
  const combined =
    parseFloat(
      String(
        t.tmSubsidy != null
          ? t.tmSubsidy
          : t.tmCouncilPays != null
            ? t.tmCouncilPays
            : t.totalSubsidy != null
              ? t.totalSubsidy
              : 0,
      ),
    ) || 0;
  return Math.max(0, +(combined - hoist).toFixed(2));
}

const dry = process.argv.includes('--dry');

const primary = await get(`tmBatches/${COUNCIL}/${CID}/2026-08`);
console.log('primary 2026-08 before', {
  status: primary?.status,
  tripCount: primary?.tripCount,
  trips: primary?.trips,
  totalSubsidy: primary?.totalSubsidy,
});

const existingAdd = await get(`tmBatches/${COUNCIL}/${CID}/2026-08-b2`);
if (existingAdd && existingAdd.status && existingAdd.status !== 'null') {
  console.log('addendum already exists', existingAdd);
}

const tripRows = [];
for (const rawKey of ORPHANS) {
  const st = (await get(`tmTripStatus/${CID}/${rawKey}`)) || {};
  const job = (await get(`completedJobs/${CID}/${rawKey}`)) || {};
  const row = { ...job, ...st, _cid: CID, _rawKey: rawKey, status: 'approved' };
  console.log('orphan', rawKey, {
    status: st.status,
    batchId: st.batchId || null,
    batchYm: st.batchYm || null,
    subsidyFare: subsidyOfTrip(row),
  });
  if (String(st.status || '').toLowerCase() !== 'approved') {
    throw new Error(`${rawKey} is not approved — abort`);
  }
  if (st.batchId) {
    throw new Error(`${rawKey} already has batchId=${st.batchId} — abort`);
  }
  tripRows.push(row);
}

const trips = tripRows.map((t) => ({ cid: CID, rawKey: t._rawKey }));
const totalSubsidy = +tripRows.reduce((s, t) => s + subsidyOfTrip(t), 0).toFixed(2);
const now = Date.now();
const payload = {
  status: 'submitted',
  submittedAt: now,
  submittedBy: 'backfill-orphan-approved-addendum',
  submittedRef: 'council-trip-approve-addendum',
  notes: 'Addendum batch — late approvals after month claim was locked (one-shot backfill)',
  tripCount: trips.length,
  totalTrips: trips.length,
  claimAmount: totalSubsidy,
  totalSubsidy,
  trips,
  isAddendum: true,
  parentBatchKey: '2026-08',
};

console.log('will write', { path: `tmBatches/${COUNCIL}/${CID}/2026-08-b2`, payload });

if (dry) {
  console.log('dry run — no writes');
  process.exit(0);
}

const w1 = await postWrite(`tmBatches/${COUNCIL}/${CID}/2026-08-b2`, 'PUT', payload);
console.log('batch write', w1.status, w1.body.slice(0, 300));
if (w1.status >= 400) process.exit(1);

for (const rawKey of ORPHANS) {
  const w = await postWrite(`tmTripStatus/${CID}/${rawKey}`, 'PATCH', {
    batchId: `${CID}/2026-08-b2`,
    batchYm: '2026-08-b2',
  });
  console.log('status patch', rawKey, w.status, w.body.slice(0, 200));
  if (w.status >= 400) process.exit(1);
}

const afterPrimary = await get(`tmBatches/${COUNCIL}/${CID}/2026-08`);
const afterAdd = await get(`tmBatches/${COUNCIL}/${CID}/2026-08-b2`);
console.log('VERIFY primary unchanged', {
  status: afterPrimary?.status,
  tripCount: afterPrimary?.tripCount,
  trips: afterPrimary?.trips,
  totalSubsidy: afterPrimary?.totalSubsidy,
});
console.log('VERIFY addendum', {
  status: afterAdd?.status,
  tripCount: afterAdd?.tripCount,
  trips: afterAdd?.trips,
  totalSubsidy: afterAdd?.totalSubsidy,
  isAddendum: afterAdd?.isAddendum,
  parentBatchKey: afterAdd?.parentBatchKey,
});
for (const rawKey of ORPHANS) {
  const st = await get(`tmTripStatus/${CID}/${rawKey}`);
  console.log('VERIFY trip', rawKey, { status: st.status, batchId: st.batchId, batchYm: st.batchYm });
}

if (afterPrimary?.status !== 'paid' || Number(afterPrimary?.tripCount) !== 3) {
  console.error('FAIL: paid primary batch was altered');
  process.exit(1);
}
if (afterAdd?.status !== 'submitted' || Number(afterAdd?.tripCount) !== 2) {
  console.error('FAIL: addendum not as expected');
  process.exit(1);
}
console.log('OK backfill complete');
