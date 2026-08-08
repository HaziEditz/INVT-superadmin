/**

 * Reports sort + batch create/submit helpers + auto-batch on approve.

 */

import assert from 'node:assert/strict';

import test from 'node:test';

import { readFileSync } from 'node:fs';

import { join, dirname } from 'node:path';

import { fileURLToPath } from 'node:url';



const root = join(dirname(fileURLToPath(import.meta.url)), '..');



// Pure mirrors — keep in sync with src/lib/tmTripSort.ts + tmBatchCreate.ts

function coerceTimeMs(raw) {

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



function tripActivityMs(t) {

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



function compareTripsNewestFirst(a, b) {

  return tripActivityMs(b) - tripActivityMs(a);

}



function tripMonthKey(t) {

  const ms = tripActivityMs(t);

  if (!ms) return null;

  return new Date(ms).toISOString().slice(0, 7);

}



function isClaimEligibleStatus(status) {

  const s = String(status || '').trim().toLowerCase();

  return s === 'approved' || s === 'paid';

}



function shouldWriteBatchCreate(existing) {

  if (!existing || typeof existing !== 'object') return 'create';

  const st = String(existing.status || '').trim().toLowerCase();

  if (!st || st === 'draft') return 'create';

  if (st === 'submitted') return 'refresh';

  return 'skip';

}



function subsidyOfTrip(t) {
  const hoist =
    parseFloat(String(t.tmSubsidyHoist ?? t.hoistTotal ?? t.hoistCost ?? 0)) || 0;
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



function normalizeBatchTripRefs(rawList, defaultCid) {

  const out = [];

  const seen = new Set();

  for (const item of rawList || []) {

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



function computeDisplayBatchTotals(batch, tripRows) {

  const b = batch && typeof batch === 'object' ? batch : {};

  if (Array.isArray(tripRows) && tripRows.length) {

    let totalTrips = 0;

    let totalSubsidy = 0;

    for (const t of tripRows) {

      const st = String(t?.status || '').trim().toLowerCase();

      if (st && !isClaimEligibleStatus(st)) continue;

      totalTrips++;

      totalSubsidy += subsidyOfTrip(t);

    }

    if (totalTrips > 0) {

      return { totalTrips, totalSubsidy: +totalSubsidy.toFixed(2) };

    }

  }

  const storedTrips =

    Number(b.tripCount != null && b.tripCount !== '' ? b.tripCount : b.totalTrips || 0) || 0;

  const storedSub =

    parseFloat(

      String(b.totalSubsidy != null && b.totalSubsidy !== '' ? b.totalSubsidy : b.claimAmount || 0),

    ) || 0;

  return { totalTrips: storedTrips, totalSubsidy: storedSub };

}



function mergeApprovedTripIntoBatch(existing, trip, opts) {

  const cid = String(trip._cid || '').trim();

  const rawKey = String(trip._rawKey || '').trim();

  if (!cid || !rawKey) return null;

  const now = opts.now != null ? Number(opts.now) : Date.now();

  const who = String(opts.who || 'council').trim() || 'council';

  let ym = tripMonthKey(trip);

  if (!ym) ym = new Date(now).toISOString().slice(0, 7);

  const decision = shouldWriteBatchCreate(existing);

  if (decision === 'skip') return null;

  const ex = existing && typeof existing === 'object' ? existing : {};

  const trips = normalizeBatchTripRefs(ex.trips, cid);

  const already = trips.some((x) => x.cid === cid && x.rawKey === rawKey);

  let totalSubsidy =

    parseFloat(String(ex.totalSubsidy != null ? ex.totalSubsidy : ex.claimAmount || 0)) || 0;

  if (!already) {

    trips.push({ cid, rawKey });

    totalSubsidy += subsidyOfTrip(trip);

  } else if (!trips.length) {

    trips.push({ cid, rawKey });

    totalSubsidy = subsidyOfTrip(trip);

  }

  totalSubsidy = +totalSubsidy.toFixed(2);

  return {

    decision,

    cid,

    ym,

    pathSuffix: cid + '/' + ym,

    added: !already,

    payload: {

      status: 'submitted',

      submittedAt: ex.submittedAt || now,

      submittedBy: ex.submittedBy || who,

      submittedRef: ex.submittedRef || opts.submittedRef || 'council-trip-approve',

      tripCount: trips.length,

      totalTrips: trips.length,

      claimAmount: totalSubsidy,

      totalSubsidy,

      trips,

    },

  };

}



function planCouncilBatchCreates(trips, opts) {

  const companyFilter = String(opts.companyId || '').trim();

  const monthFilter = String(opts.month || '').trim();

  const who = String(opts.who || 'council').trim() || 'council';

  const now = opts.now != null ? Number(opts.now) : Date.now();

  const agg = new Map();

  for (const t of trips || []) {

    if (!isClaimEligibleStatus(t.status)) continue;

    const cid = String(t._cid || '').trim();

    const rawKey = String(t._rawKey || '').trim();

    if (!cid || !rawKey) continue;

    if (companyFilter && cid !== companyFilter) continue;

    const ym = tripMonthKey(t);

    if (!ym) continue;

    if (monthFilter && ym !== monthFilter) continue;

    if (!tripActivityMs(t)) continue;

    const key = cid + '/' + ym;

    let row = agg.get(key);

    if (!row) {

      row = { cid, ym, trips: [], totalSubsidy: 0 };

      agg.set(key, row);

    }

    if (row.trips.some((x) => x.rawKey === rawKey && x.cid === cid)) continue;

    row.trips.push({ cid, rawKey });

    row.totalSubsidy += subsidyOfTrip(t);

  }

  return Array.from(agg.values()).map((a) => ({

    cid: a.cid,

    ym: a.ym,

    tripCount: a.trips.length,

    totalSubsidy: +a.totalSubsidy.toFixed(2),

    payload: {

      status: 'submitted',

      submittedAt: now,

      submittedBy: who,

      submittedRef: 'council-create-now',

      tripCount: a.trips.length,

      trips: a.trips,

    },

  }));

}



const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');

const sortSrc = readFileSync(join(root, 'src/lib/tmTripSort.ts'), 'utf8');

const createSrc = readFileSync(join(root, 'src/lib/tmBatchCreate.ts'), 'utf8');



test('tripActivityMs uses numeric completedAt when ISO fields missing (live hail shape)', () => {

  const older = { completedAt: 1786084850880 };

  const newer = { completedAt: 1786161702348 };

  assert.ok(tripActivityMs(newer) > tripActivityMs(older));

  assert.equal(tripActivityMs({ startedAt_ISO: '' }), 0);

  assert.ok(tripActivityMs({ startedAt_ISO: '2026-08-08T04:10:22.492Z' }) > 0);

});



test('Reports newest-first works when startedAt_ISO is empty', () => {

  const rows = [

    { _rawKey: 'old', completedAt: 1000 },

    { _rawKey: 'new', completedAt: 3000 },

    { _rawKey: 'mid', completedAt: 2000 },

  ];

  rows.sort(compareTripsNewestFirst);

  assert.deepEqual(

    rows.map((r) => r._rawKey),

    ['new', 'mid', 'old'],

  );

});



test('tripMonthKey from epoch completedAt', () => {

  assert.equal(tripMonthKey({ completedAt: Date.parse('2026-08-08T04:10:22.492Z') }), '2026-08');

});



test('planCouncilBatchCreates groups approved trips by company/month', () => {

  const plans = planCouncilBatchCreates(

    [

      {

        _cid: '860869',

        _rawKey: '8692608084',

        status: 'approved',

        completedAt: Date.parse('2026-08-08T04:10:22Z'),

        tmSubsidy: 12.5,

      },

      {

        _cid: '860869',

        _rawKey: '8692608081',

        status: 'approved',

        completedAt: Date.parse('2026-08-07T14:00:00Z'),

        tmSubsidy: 10,

      },

      {

        _cid: '860869',

        _rawKey: 'pending1',

        status: 'pending',

        completedAt: Date.parse('2026-08-08T04:10:22Z'),

        tmSubsidy: 99,

      },

    ],

    { councilId: 'inv', who: 'Tester', now: 111, month: '2026-08' },

  );

  assert.equal(plans.length, 1);

  assert.equal(plans[0].tripCount, 2);

  assert.equal(plans[0].totalSubsidy, 22.5);

  assert.equal(plans[0].payload.status, 'submitted');

  assert.equal(plans[0].payload.submittedRef, 'council-create-now');

});



test('shouldWriteBatchCreate skips approved/paid', () => {

  assert.equal(shouldWriteBatchCreate(null), 'create');

  assert.equal(shouldWriteBatchCreate({ status: 'draft' }), 'create');

  assert.equal(shouldWriteBatchCreate({ status: 'submitted' }), 'refresh');

  assert.equal(shouldWriteBatchCreate({ status: 'approved' }), 'skip');

  assert.equal(shouldWriteBatchCreate({ status: 'paid' }), 'skip');

});



test('mergeApprovedTripIntoBatch creates month batch on first approve', () => {

  const merged = mergeApprovedTripIntoBatch(

    null,

    {

      _cid: '860869',

      _rawKey: 'trip1',

      status: 'approved',

      completedAt: Date.parse('2026-08-08T04:10:22Z'),

      tmSubsidy: 15.5,

    },

    { who: 'Council', now: 999, submittedRef: 'council-trip-approve' },

  );

  assert.ok(merged);

  assert.equal(merged.decision, 'create');

  assert.equal(merged.ym, '2026-08');

  assert.equal(merged.added, true);

  assert.equal(merged.payload.tripCount, 1);

  assert.equal(merged.payload.totalSubsidy, 15.5);

  assert.equal(merged.payload.submittedRef, 'council-trip-approve');

  assert.deepEqual(merged.payload.trips, [{ cid: '860869', rawKey: 'trip1' }]);

});



test('mergeApprovedTripIntoBatch appends to open submitted batch', () => {

  const merged = mergeApprovedTripIntoBatch(

    {

      status: 'submitted',

      tripCount: 1,

      totalSubsidy: 10,

      trips: [{ cid: '860869', rawKey: 'trip1' }],

    },

    {

      _cid: '860869',

      _rawKey: 'trip2',

      status: 'approved',

      completedAt: Date.parse('2026-08-09T04:10:22Z'),

      tmSubsidy: 7.25,

    },

    { who: 'Council', now: 1000 },

  );

  assert.ok(merged);

  assert.equal(merged.decision, 'refresh');

  assert.equal(merged.added, true);

  assert.equal(merged.payload.tripCount, 2);

  assert.equal(merged.payload.totalSubsidy, 17.25);

});



test('mergeApprovedTripIntoBatch skips paid batches', () => {

  const merged = mergeApprovedTripIntoBatch(

    { status: 'paid', trips: [] },

    { _cid: '860869', _rawKey: 'x', status: 'approved', tmSubsidy: 1 },

    { who: 'Council', now: Date.parse('2026-08-01T00:00:00Z') },

  );

  assert.equal(merged, null);

});



test('computeDisplayBatchTotals counts stubs without status', () => {

  const totals = computeDisplayBatchTotals(

    { tripCount: 2, totalSubsidy: 20 },

    [

      { _rawKey: 'a', status: '' },

      { _rawKey: 'b' },

    ],

  );

  assert.equal(totals.totalTrips, 2);

});



test('computeDisplayBatchTotals falls back to stored tripCount when recount is empty', () => {

  const totals = computeDisplayBatchTotals(

    { tripCount: 5, totalSubsidy: 42.5 },

    [{ status: 'rejected' }, { status: 'revision_needed' }],

  );

  assert.equal(totals.totalTrips, 5);

  assert.equal(totals.totalSubsidy, 42.5);

});



test('council wires sort helper + map gen + auto-batch on approve', () => {

  assert.match(sortSrc, /export function tripActivityMs/);

  assert.match(sortSrc, /export function compareTripsNewestFirst/);

  assert.match(createSrc, /export function planCouncilBatchCreates/);

  assert.match(createSrc, /export function mergeApprovedTripIntoBatch/);

  assert.match(createSrc, /export function computeDisplayBatchTotals/);

  assert.match(councilSrc, /compareTripsNewestFirst/);

  assert.match(councilSrc, /tripActivityMs/);

  assert.match(councilSrc, /_cpMapGen/);

  assert.match(councilSrc, /cpDestroyTripMap\(\)/);

  assert.match(councilSrc, /gen !== _cpMapGen/);

  assert.match(councilSrc, /\/api\/council-batch-create/);

  assert.match(councilSrc, /Rebuild \/ submit batch/);

  assert.match(councilSrc, /planCouncilBatchCreates/);

  assert.match(councilSrc, /afterCouncilApproveAddToBatch/);

  assert.match(councilSrc, /mergeApprovedTripIntoBatch/);

  assert.match(councilSrc, /computeDisplayBatchTotals/);

  assert.match(councilSrc, /needPuGeo/);

  assert.match(councilSrc, /needDuGeo/);

  assert.match(councilSrc, /weight:5/);

  assert.match(councilSrc, /rows\.sort\(compareTripsNewestFirst\)/);

});


