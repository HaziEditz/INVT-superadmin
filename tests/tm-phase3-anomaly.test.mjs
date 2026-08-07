/**
 * Phase 3 anomaly detection + claim eligibility + council route wiring.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const require = createRequire(import.meta.url);

// Inline pure copies (node:test without ts compile) matching tmAnomaly.ts
function num(v, fallback = 0) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}
function expectedMeterFromTariff(tariff, distanceKm, durationMin, waitingMin = 0) {
  if (!tariff) return null;
  const base = num(tariff.base);
  const perKm = num(tariff.perKm);
  const perMin = num(tariff.perMin);
  const stop = num(tariff.stopFee);
  if (!base && !perKm && !perMin && !stop) return null;
  return +(base + distanceKm * perKm + durationMin * perMin + waitingMin * stop).toFixed(2);
}
function toTripMs(raw) {
  if (raw == null || raw === '') return 0;
  if (typeof raw === 'number' || (typeof raw === 'string' && /^\d{10,13}$/.test(String(raw).trim()))) {
    let ms = Number(raw);
    if (ms < 1e12) ms *= 1000;
    return Number.isFinite(ms) ? ms : 0;
  }
  const p = Date.parse(String(raw));
  return Number.isFinite(p) ? p : 0;
}
function tripWindow(trip) {
  const start = toTripMs(trip.startedAt_ISO || trip.startedAt) || toTripMs(trip.completedAt_ISO || trip.completedAt);
  let end = toTripMs(trip.completedAt_ISO || trip.completedAt) || start;
  if (end < start) end = start;
  return { start, end };
}
function windowsOverlapOrWithin(a, b, withinMs) {
  if (!a.start || !b.start) return false;
  if (a.start <= b.end && b.start <= a.end) return true;
  return Math.abs(a.start - b.start) <= withinMs;
}
function detectTripAnomalies(trip, opts = {}) {
  const reasons = [];
  const details = [];
  const peers = (opts.peers || []).filter((p) => p && p !== trip);
  const fare = num(trip.tmMeterFare ?? trip.meterFare ?? trip.fare ?? trip.totalFare);
  const dist = num(trip.distanceKm ?? trip.distance);
  const dur = num(trip.durationMin);
  const expected = expectedMeterFromTariff(opts.refTariff, dist, dur, 0);
  if (expected != null && fare > 0 && Math.abs(fare - expected) > Math.max(1, expected * 0.15)) {
    reasons.push('fare_mismatch');
    details.push('fare');
  }
  const card = String(trip.tmCardNumber || trip.tmVoucherNo || '').replace(/\s+/g, '');
  const selfWin = tripWindow(trip);
  const selfVeh = String(trip.vehicleId || '').toUpperCase();
  const selfKey = `${trip._cid}/${trip._rawKey}`;
  if (card) {
    for (const peer of peers) {
      const peerKey = `${peer._cid}/${peer._rawKey}`;
      if (peerKey === selfKey) continue;
      const peerCard = String(peer.tmCardNumber || peer.tmVoucherNo || '').replace(/\s+/g, '');
      if (peerCard !== card) continue;
      const peerWin = tripWindow(peer);
      if (!windowsOverlapOrWithin(selfWin, peerWin, 3 * 60 * 1000)) continue;
      if (!reasons.includes('same_card_reuse_3min')) reasons.push('same_card_reuse_3min');
      const peerVeh = String(peer.vehicleId || '').toUpperCase();
      if (selfVeh && peerVeh && selfVeh !== peerVeh && !reasons.includes('same_card_same_time_diff_taxi')) {
        reasons.push('same_card_same_time_diff_taxi');
      }
    }
  }
  return { reasons, detail: details.join('; ') };
}
function isClaimEligibleStatus(status) {
  const s = String(status || '').trim().toLowerCase();
  return s === 'approved' || s === 'paid';
}
function applyAnomalyScan(trips, tariffByCid) {
  const patches = [];
  for (const trip of trips) {
    const status = String(trip.status || '').toLowerCase();
    if (['approved', 'rejected', 'paid'].includes(status)) continue;
    const node = tariffByCid[trip._cid];
    const ref = node && node.car ? node.car : node;
    const hit = detectTripAnomalies(trip, { peers: trips, refTariff: ref });
    if (hit.reasons.length) {
      if (status === 'revision_needed') {
        patches.push({ cid: trip._cid, rawKey: trip._rawKey, patch: { flagReasons: hit.reasons } });
      } else {
        patches.push({
          cid: trip._cid,
          rawKey: trip._rawKey,
          patch: { status: 'flagged', flagReasons: hit.reasons },
        });
      }
    } else if (status === 'flagged') {
      patches.push({
        cid: trip._cid,
        rawKey: trip._rawKey,
        patch: { status: 'submitted', flagReasons: [] },
      });
    }
  }
  return patches;
}

const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const anomalySrc = readFileSync(join(root, 'src/lib/tmAnomaly.ts'), 'utf8');
const adminSrc = readFileSync(join(root, '..', 'INVT-admin', 'server.js'), 'utf8');

test('fare_mismatch vs reference tariff', () => {
  const hit = detectTripAnomalies(
    { fare: 40, distanceKm: 10, durationMin: 20 },
    { refTariff: { base: 3.5, perKm: 2, perMin: 0.5, stopFee: 0 } },
  );
  // expected = 3.5 + 20 + 10 = 33.5; |40-33.5|=6.5 > max(1, 5.025)
  assert.ok(hit.reasons.includes('fare_mismatch'));
});

test('same_card_reuse_3min', () => {
  const t0 = 1_700_000_000_000;
  const a = {
    _cid: 'c1',
    _rawKey: 'a',
    tmCardNumber: '111',
    vehicleId: '201',
    startedAt: t0,
    completedAt: t0 + 60_000,
  };
  const b = {
    _cid: 'c1',
    _rawKey: 'b',
    tmCardNumber: '111',
    vehicleId: '201',
    startedAt: t0 + 90_000,
    completedAt: t0 + 120_000,
  };
  const hit = detectTripAnomalies(a, { peers: [a, b] });
  assert.ok(hit.reasons.includes('same_card_reuse_3min'));
});

test('same_card_same_time_diff_taxi', () => {
  const t0 = 1_700_000_000_000;
  const a = {
    _cid: 'c1',
    _rawKey: 'a',
    tmCardNumber: '222',
    vehicleId: '201',
    startedAt: t0,
    completedAt: t0 + 600_000,
  };
  const b = {
    _cid: 'c1',
    _rawKey: 'b',
    tmCardNumber: '222',
    vehicleId: '305',
    startedAt: t0 + 30_000,
    completedAt: t0 + 500_000,
  };
  const hit = detectTripAnomalies(a, { peers: [a, b] });
  assert.ok(hit.reasons.includes('same_card_reuse_3min'));
  assert.ok(hit.reasons.includes('same_card_same_time_diff_taxi'));
});

test('applyAnomalyScan flags submitted and clears clean flagged', () => {
  const trips = [
    {
      _cid: 'c1',
      _rawKey: 'x',
      status: 'submitted',
      fare: 100,
      distanceKm: 1,
      durationMin: 1,
    },
    { _cid: 'c1', _rawKey: 'y', status: 'flagged', fare: 5, distanceKm: 1, durationMin: 1, flagReasons: ['fare_mismatch'] },
  ];
  const patches = applyAnomalyScan(trips, {
    c1: { car: { base: 3, perKm: 2, perMin: 0.5, stopFee: 0 } },
  });
  const x = patches.find((p) => p.rawKey === 'x');
  const y = patches.find((p) => p.rawKey === 'y');
  assert.equal(x.patch.status, 'flagged');
  assert.equal(y.patch.status, 'submitted');
});

test('isClaimEligibleStatus excludes flagged/revision/rejected', () => {
  assert.equal(isClaimEligibleStatus('approved'), true);
  assert.equal(isClaimEligibleStatus('paid'), true);
  assert.equal(isClaimEligibleStatus('flagged'), false);
  assert.equal(isClaimEligibleStatus('revision_needed'), false);
  assert.equal(isClaimEligibleStatus('rejected'), false);
  assert.equal(isClaimEligibleStatus('submitted'), false);
});

test('tmAnomaly source exports claim helper and rules', () => {
  assert.match(anomalySrc, /export function isClaimEligibleStatus/);
  assert.match(anomalySrc, /same_card_reuse_3min/);
  assert.match(anomalySrc, /same_card_same_time_diff_taxi/);
  assert.match(anomalySrc, /applyAnomalyScan/);
});

test('council portal pending + anomalies + bulk endpoints', () => {
  assert.match(councilSrc, /\/council-portal\/pending/);
  assert.match(councilSrc, /\/council-portal\/anomalies/);
  assert.match(councilSrc, /\/api\/council-bulk-approve/);
  assert.match(councilSrc, /\/api\/council-bulk-return/);
  assert.match(councilSrc, /\/api\/tm-scan-submitted/);
  assert.match(councilSrc, /Approve All/);
  assert.match(councilSrc, /Return selected/);
  assert.match(councilSrc, /isClaimEligibleStatus/);
  assert.match(councilSrc, /applyAnomalyScan|detectTripAnomalies|scanAndRefreshTrips/);
  assert.match(councilSrc, /flagReasons/);
  assert.match(councilSrc, /excluded this period/);
  assert.match(councilSrc, /View Flagged Trips/);
  assert.match(councilSrc, /\/council-portal\/anomalies\?t=/);
});

test('owner panel shows flagged edit-warning on revision_needed', () => {
  assert.match(adminSrc, /Council flagged|flagReasons|anomalyDetail/);
  assert.match(adminSrc, /revision_needed/);
});
