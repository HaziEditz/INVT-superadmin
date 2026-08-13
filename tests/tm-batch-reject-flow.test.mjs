/**
 * Claim-batch per-trip Reject: remove from batch + ever-flagged includes reject.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const createSrc = readFileSync(join(root, 'src/lib/tmBatchCreate.ts'), 'utf8');
const anomalySrc = readFileSync(join(root, 'src/lib/tmAnomaly.ts'), 'utf8');

/** Mirror of planRemoveTripFromBatch (keep in sync with tmBatchCreate.ts). */
function normalizeBatchTripRefs(rawList, defaultCid) {
  const out = [];
  const seen = new Set();
  const list = Array.isArray(rawList) ? rawList : [];
  for (const item of list) {
    let cid = defaultCid;
    let rawKey = '';
    if (item && typeof item === 'object') {
      rawKey = String(item.rawKey || item._rawKey || item.id || item.bookingId || '').trim();
      cid = String(item.cid || item._cid || defaultCid).trim() || defaultCid;
    } else {
      const s = String(item || '').trim();
      if (s.indexOf('/') > 0) {
        const slash = s.indexOf('/');
        cid = s.slice(0, slash);
        rawKey = s.slice(slash + 1);
      } else {
        rawKey = s;
      }
    }
    if (!cid || !rawKey) continue;
    const k = cid + '/' + rawKey;
    if (seen.has(k)) continue;
    seen.add(k);
    out.push({ cid, rawKey });
  }
  return out;
}

function planRemoveTripFromBatch(batch, cid, rawKey, opts) {
  const companyCid = String(cid || '').trim();
  const key = String(rawKey || '').trim();
  const ex = batch && typeof batch === 'object' ? batch : {};
  const trips = normalizeBatchTripRefs(ex.trips, companyCid);
  const next = trips.filter((t) => !(t.cid === companyCid && t.rawKey === key));
  const found = next.length < trips.length;
  let totalSubsidy =
    parseFloat(String(ex.totalSubsidy != null ? ex.totalSubsidy : ex.claimAmount || 0)) || 0;
  if (found && opts?.removedSubsidy != null && Number.isFinite(Number(opts.removedSubsidy))) {
    totalSubsidy = Math.max(0, +(totalSubsidy - Number(opts.removedSubsidy)).toFixed(2));
  } else if (found && next.length === 0) {
    totalSubsidy = 0;
  }
  totalSubsidy = +totalSubsidy.toFixed(2);
  return {
    found,
    trips: next,
    tripCount: next.length,
    totalSubsidy,
    payload: {
      trips: next,
      tripCount: next.length,
      totalTrips: next.length,
      totalSubsidy,
      claimAmount: totalSubsidy,
    },
  };
}

function tripWasEverFlagged(trip) {
  const flaggedAt = trip?.flaggedAt;
  if (flaggedAt != null && flaggedAt !== '' && Number(flaggedAt) !== 0) return true;
  const rejectedAt = trip?.rejectedAt;
  if (rejectedAt != null && rejectedAt !== '' && Number(rejectedAt) !== 0) return true;
  const events = trip?.events;
  if (events && typeof events === 'object') {
    for (const ev of Object.values(events)) {
      if (!ev || typeof ev !== 'object') continue;
      const type = String(ev.type || '').trim().toLowerCase();
      const to = String(ev.toStatus || '').trim().toLowerCase();
      if (
        type === 'flagged' ||
        to === 'flagged' ||
        type === 'rejected' ||
        to === 'rejected' ||
        type === 'returned' ||
        to === 'revision_needed'
      ) {
        return true;
      }
    }
  }
  return false;
}

function shouldAutoApproveCleanTrip(trip) {
  if (!trip || typeof trip !== 'object') return false;
  const st = String(trip.status || '').trim().toLowerCase();
  if (st !== 'submitted') return false;
  if (tripWasEverFlagged(trip)) return false;
  return true;
}

test('planRemoveTripFromBatch removes live 8692608131-shaped trip and zeros empty batch', () => {
  const batch = {
    status: 'submitted',
    tripCount: 1,
    totalSubsidy: 9.93,
    trips: [{ cid: '860869', rawKey: '8692608131' }],
  };
  const plan = planRemoveTripFromBatch(batch, '860869', '8692608131', {
    removedSubsidy: 9.93,
  });
  assert.equal(plan.found, true);
  assert.equal(plan.tripCount, 0);
  assert.equal(plan.totalSubsidy, 0);
  assert.deepEqual(plan.trips, []);
});

test('planRemoveTripFromBatch leaves unrelated trips and subtracts subsidy', () => {
  const batch = {
    status: 'submitted',
    totalSubsidy: 20,
    trips: [
      { cid: '860869', rawKey: 'A' },
      { cid: '860869', rawKey: 'B' },
    ],
  };
  const plan = planRemoveTripFromBatch(batch, '860869', 'A', { removedSubsidy: 7.5 });
  assert.equal(plan.found, true);
  assert.equal(plan.tripCount, 1);
  assert.equal(plan.trips[0].rawKey, 'B');
  assert.equal(plan.totalSubsidy, 12.5);
});

test('tripWasEverFlagged / shouldAutoApproveCleanTrip treat council reject as forever-flagged', () => {
  assert.equal(
    tripWasEverFlagged({
      events: { e1: { type: 'rejected', toStatus: 'revision_needed' } },
    }),
    true,
  );
  assert.equal(tripWasEverFlagged({ rejectedAt: 1786542135061 }), true);
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      events: { e1: { type: 'rejected', toStatus: 'revision_needed' } },
    }),
    false,
  );
});

test('source wires per-trip Return (batch remove) + ever-flagged reject history + no batch-level Reject UI', () => {
  assert.match(createSrc, /export function planRemoveTripFromBatch/);
  assert.match(anomalySrc, /rejectedAt/);
  assert.match(anomalySrc, /type === 'rejected'/);
  assert.match(councilSrc, /Trips in this batch/);
  assert.match(councilSrc, /Return to company/);
  assert.doesNotMatch(councilSrc, /Reject \(return for fix\)/);
  assert.match(councilSrc, /afterRejectRemoveFromBatch/);
  assert.match(councilSrc, /planRemoveTripFromBatch/);
  assert.match(councilSrc, /status: 'revision_needed'/);
  assert.match(councilSrc, /Batch-level Reject removed/);
  assert.match(councilSrc, /batch-reject-flow:per-trip-details-v1/);
  assert.match(councilSrc, /rejectFlow: 'per-trip-details-v1'/);
  assert.doesNotMatch(councilSrc, /confirm\('Reject this batch\?'\)/);
  assert.doesNotMatch(councilSrc, /Reject selected/);
  assert.match(councilSrc, /canReturn = canApprove \|\| d\.status==='approved'/);
});
