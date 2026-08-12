/**
 * Phase 3 anomaly detection + claim eligibility + council route wiring.
 * Includes card limit / expiry post-hoc flags (replaces UI-only 2B enforcement).
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');

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
function tripDayKey(t) {
  const ms = tripWindow(t).start || toTripMs(t.completedAt_ISO || t.completedAt);
  if (!ms) return '';
  try {
    return new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Pacific/Auckland',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date(ms));
  } catch {
    return new Date(ms).toISOString().slice(0, 10);
  }
}
function tripMonthKeyNz(t) {
  const day = tripDayKey(t);
  return day ? day.slice(0, 7) : '';
}
function tripIdentity(trip) {
  return `${trip._cid}/${trip._rawKey || trip.bookingId || trip.id}`;
}
function tripCardNumbers(trip) {
  const primary = String(trip.tmCardNumber || trip.tmVoucherNo || trip.cardNumber || '').replace(/\s+/g, '');
  return primary ? [primary] : [];
}
function isUsageCountableStatus(status) {
  const s = String(status || '').trim().toLowerCase();
  return s !== 'archived' && s !== 'rejected';
}
function positiveIntLimit(raw) {
  if (raw == null || raw === '') return null;
  const n = parseInt(String(raw), 10);
  if (!Number.isFinite(n) || n <= 0) return null;
  return n;
}
function cardDailyTripLimit(card) {
  if (!card) return null;
  return positiveIntLimit(card.usageLimitDaily ?? card.maxFarePerTrip);
}
function cardMonthlyTripLimit(card) {
  if (!card) return null;
  return positiveIntLimit(card.usageLimitMonthly ?? card.monthlyLimit);
}
function mmYyToExpiryDate(raw) {
  const s = String(raw || '').trim();
  if (!s) return null;
  const m = s.match(/^(\d{1,2})\s*[\/\-]\s*(\d{2}|\d{4})$/);
  if (!m) return null;
  const month = parseInt(m[1], 10);
  let year = parseInt(m[2], 10);
  if (!Number.isFinite(month) || month < 1 || month > 12) return null;
  if (year < 100) year += year >= 70 ? 1900 : 2000;
  const lastDay = new Date(Date.UTC(year, month, 0)).getUTCDate();
  return `${year}-${String(month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;
}
function resolveCardExpiryDate(card, trip) {
  const fromCard = String(card?.expiryDate || '').trim().slice(0, 10);
  if (/^\d{4}-\d{2}-\d{2}$/.test(fromCard)) return fromCard;
  return mmYyToExpiryDate(trip?.tmCardExpiry);
}
function isCardExpiredAtTrip(trip, card) {
  const expiry = resolveCardExpiryDate(card, trip);
  if (!expiry) return false;
  const day = tripDayKey(trip);
  if (!day) return false;
  return day > expiry;
}
function cardUsageOrdinal(trip, peers, card, bucket) {
  const selfKey = tripIdentity(trip);
  const selfBucket = bucket === 'day' ? tripDayKey(trip) : tripMonthKeyNz(trip);
  if (!selfBucket || !card) return 0;
  const seen = new Set();
  const cohort = [];
  for (const p of [trip, ...(peers || [])]) {
    if (!p || !isUsageCountableStatus(p.status)) continue;
    if (!tripCardNumbers(p).includes(card)) continue;
    const b = bucket === 'day' ? tripDayKey(p) : tripMonthKeyNz(p);
    if (b !== selfBucket) continue;
    const key = tripIdentity(p);
    if (!key || key === '/' || seen.has(key)) continue;
    seen.add(key);
    const w = tripWindow(p);
    cohort.push({ key, ms: w.start || w.end || 0 });
  }
  cohort.sort((a, b) => a.ms - b.ms || a.key.localeCompare(b.key));
  const idx = cohort.findIndex((c) => c.key === selfKey);
  return idx < 0 ? 0 : idx + 1;
}
function lookupAnomalyCard(cardsByNumber, cardNumber) {
  if (!cardsByNumber || !cardNumber) return null;
  if (cardsByNumber[cardNumber]) return cardsByNumber[cardNumber];
  const compact = cardNumber.replace(/\s+/g, '');
  return cardsByNumber[compact] || null;
}
function detectTripAnomalies(trip, opts = {}) {
  const reasons = [];
  const details = [];
  const peers = (opts.peers || []).filter((p) => p && p !== trip);
  const fare = num(trip.tmMeterFare ?? trip.meterFare ?? trip.fare ?? trip.totalFare);
  const dist = trip.distanceKm != null && trip.distanceKm !== '' ? num(trip.distanceKm ?? trip.distance) : (trip.distance != null && trip.distance !== '' ? num(trip.distance) : null);
  const durRaw = trip.durationMin != null && trip.durationMin !== '' ? num(trip.durationMin) : null;
  const dur = durRaw != null ? durRaw : 0;
  const expected = expectedMeterFromTariff(opts.refTariff, dist || 0, dur, 0);
  if (expected != null && fare > 0 && Math.abs(fare - expected) > Math.max(1, expected * 0.15)) {
    reasons.push('fare_mismatch');
    details.push('fare');
  }
  // implausible_short_trip: <0.1km + <3min, or 0,0 sentinel + <3min
  const SHORT_KM = 0.1;
  const SHORT_MIN = 3;
  function isSentinel(lat, lng) {
    if (lat == null || lat === '' || lng == null || lng === '') return false;
    const la = Number(lat); const ln = Number(lng);
    return Number.isFinite(la) && Number.isFinite(ln) && Math.abs(la) < 1e-5 && Math.abs(ln) < 1e-5;
  }
  function parseLL(raw) {
    const s = String(raw || '').trim();
    const m = s.match(/^(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)$/);
    if (!m) return null;
    return { lat: Number(m[1]), lng: Number(m[2]) };
  }
  const dropS = parseLL(trip.dropLatLng || trip.DropLatLng);
  const pickS = parseLL(trip.pickupLatLng || trip.PickupLatLng);
  const invalidCoords =
    isSentinel(trip.dropLat, trip.dropLng) ||
    isSentinel(trip.pickupLat, trip.pickupLng) ||
    (dropS && isSentinel(dropS.lat, dropS.lng)) ||
    (pickS && isSentinel(pickS.lat, pickS.lng));
  if (durRaw != null && dur < SHORT_MIN) {
    const isManual =
      trip.manuallyAddedByCompany === true ||
      trip.manuallyAddedByCompany === 'true' ||
      String(trip.source || '')
        .toLowerCase()
        .includes('manual_owner');
    if (!isManual && (invalidCoords || (dist != null && dist < SHORT_KM))) {
      reasons.push('implausible_short_trip');
      details.push('short');
    }
  }
  const cards = tripCardNumbers(trip);
  const selfWin = tripWindow(trip);
  const selfVeh = String(trip.vehicleId || '').toUpperCase();
  const selfKey = tripIdentity(trip);
  for (const card of cards) {
    for (const peer of peers) {
      const peerKey = tripIdentity(peer);
      if (peerKey === selfKey) continue;
      const peerCard = tripCardNumbers(peer)[0] || '';
      if (peerCard !== card) continue;
      const peerWin = tripWindow(peer);
      if (!windowsOverlapOrWithin(selfWin, peerWin, 3 * 60 * 1000)) continue;
      if (!reasons.includes('same_card_reuse_3min')) reasons.push('same_card_reuse_3min');
      const peerVeh = String(peer.vehicleId || '').toUpperCase();
      if (selfVeh && peerVeh && selfVeh !== peerVeh && !reasons.includes('same_card_same_time_diff_taxi')) {
        reasons.push('same_card_same_time_diff_taxi');
      }
    }
    const registry = lookupAnomalyCard(opts.cardsByNumber, card);
    if (isCardExpiredAtTrip(trip, registry) && !reasons.includes('card_expired')) {
      reasons.push('card_expired');
    }
    const dailyLimit = cardDailyTripLimit(registry);
    if (dailyLimit != null) {
      const ordinal = cardUsageOrdinal(trip, peers, card, 'day');
      if (ordinal > dailyLimit && !reasons.includes('limit_exceeded_daily')) {
        reasons.push('limit_exceeded_daily');
      }
    }
    const monthlyLimit = cardMonthlyTripLimit(registry);
    if (monthlyLimit != null) {
      const ordinal = cardUsageOrdinal(trip, peers, card, 'month');
      if (ordinal > monthlyLimit && !reasons.includes('limit_exceeded_monthly')) {
        reasons.push('limit_exceeded_monthly');
      }
    }
  }
  return { reasons, detail: details.join('; ') };
}
function isClaimEligibleStatus(status) {
  const s = String(status || '').trim().toLowerCase();
  return s === 'approved' || s === 'paid';
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
function tripWasEverEdited(trip) {
  const editedAt = trip?.editedAt;
  if (editedAt != null && editedAt !== '' && Number(editedAt) !== 0) return true;
  const events = trip?.events;
  if (events && typeof events === 'object') {
    for (const ev of Object.values(events)) {
      if (!ev || typeof ev !== 'object') continue;
      const type = String(ev.type || '').trim().toLowerCase();
      if (type === 'owner_edited' || type === 'council_edited' || type === 'sa_edited') return true;
    }
  }
  return false;
}
function shouldAutoApproveCleanTrip(trip) {
  if (!trip || typeof trip !== 'object') return false;
  const st = String(trip.status || '').trim().toLowerCase();
  if (st !== 'submitted') return false;
  if (tripWasEverFlagged(trip)) return false;
  if (tripWasEverEdited(trip)) return false;
  const reasons = Array.isArray(trip.flagReasons)
    ? trip.flagReasons.map((r) => String(r || '').trim()).filter(Boolean)
    : [];
  if (reasons.length) return false;
  const detail = String(trip.anomalyDetail || '').trim();
  if (detail) return false;
  return true;
}
function applyAnomalyScan(trips, tariffByCid, cardsByNumber) {
  const patches = [];
  for (const trip of trips) {
    const status = String(trip.status || '').toLowerCase();
    if (['approved', 'rejected', 'paid'].includes(status)) continue;
    const node = tariffByCid[trip._cid];
    const ref = node && node.car ? node.car : node;
    const hit = detectTripAnomalies(trip, { peers: trips, refTariff: ref, cardsByNumber });
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
const flaggedAspx = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Flagged.aspx'),
  'utf8',
);
const adminSrc = readFileSync(join(root, '..', 'INVT-admin', 'server.js'), 'utf8');

test('fare_mismatch vs reference tariff', () => {
  const hit = detectTripAnomalies(
    { fare: 40, distanceKm: 10, durationMin: 20 },
    { refTariff: { base: 3.5, perKm: 2, perMin: 0.5, stopFee: 0 } },
  );
  // expected = 3.5 + 20 + 10 = 33.5; |40-33.5|=6.5 > max(1, 5.025)
  assert.ok(hit.reasons.includes('fare_mismatch'));
});

test('implausible_short_trip flags near-zero distance + short duration (8088 pattern)', () => {
  const hit = detectTripAnomalies({
    _cid: '860869',
    _rawKey: '8692608088',
    distanceKm: 0.00909626923623701,
    durationMin: 2,
    fare: 15.06,
  });
  assert.ok(hit.reasons.includes('implausible_short_trip'));
});

test('implausible_short_trip treats 0,0 sentinel as invalid, not real zero distance', () => {
  const hit = detectTripAnomalies({
    _cid: 'c1',
    _rawKey: 'z',
    durationMin: 1,
    dropLatLng: '0,0',
    pickupLat: -46.4,
    pickupLng: 168.3,
  });
  assert.ok(hit.reasons.includes('implausible_short_trip'));
  // Missing distance + no sentinel + short time → do not invent a zero-distance flag
  const clean = detectTripAnomalies({
    _cid: 'c1',
    _rawKey: 'ok',
    durationMin: 1,
    fare: 12,
  });
  assert.equal(clean.reasons.includes('implausible_short_trip'), false);
});

test('implausible_short_trip does not flag normal distance trips', () => {
  const hit = detectTripAnomalies({
    distanceKm: 3.2,
    durationMin: 8,
    fare: 18,
  });
  assert.equal(hit.reasons.includes('implausible_short_trip'), false);
});

test('implausible_short_trip skipped for manual_owner (no GPS); fare mismatch still flags', () => {
  const shortManual = detectTripAnomalies({
    source: 'manual_owner',
    manuallyAddedByCompany: true,
    distanceKm: 0.01,
    durationMin: 1,
    fare: 20,
    dropLat: 0,
    dropLng: 0,
  });
  assert.equal(shortManual.reasons.includes('implausible_short_trip'), false);

  const fareHit = detectTripAnomalies(
    {
      source: 'manual_owner',
      manuallyAddedByCompany: true,
      distanceKm: 10,
      durationMin: 20,
      fare: 100,
    },
    { refTariff: { base: 3, perKm: 2, perMin: 0.5, stopFee: 0 } },
  );
  assert.ok(fareHit.reasons.includes('fare_mismatch'));
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

test('limit_exceeded_daily flags only trips past the trip-count limit', () => {
  // Fixed NZ afternoon so day key is stable
  const day = Date.parse('2024-06-15T02:00:00.000Z'); // NZ winter afternoon
  const cards = { TM99: { usageLimitDaily: 2 } };
  const mk = (key, offsetMin, status = 'submitted') => ({
    _cid: 'c1',
    _rawKey: key,
    status,
    tmCardNumber: 'TM99',
    startedAt: day + offsetMin * 60_000,
    completedAt: day + offsetMin * 60_000 + 30_000,
  });
  const trips = [mk('t1', 0), mk('t2', 10), mk('t3', 20)];
  const h1 = detectTripAnomalies(trips[0], { peers: trips, cardsByNumber: cards });
  const h2 = detectTripAnomalies(trips[1], { peers: trips, cardsByNumber: cards });
  const h3 = detectTripAnomalies(trips[2], { peers: trips, cardsByNumber: cards });
  assert.equal(h1.reasons.includes('limit_exceeded_daily'), false);
  assert.equal(h2.reasons.includes('limit_exceeded_daily'), false);
  assert.ok(h3.reasons.includes('limit_exceeded_daily'));
});

test('limit_exceeded_monthly flags ordinal over monthly trip limit', () => {
  const cards = { TM88: { usageLimitMonthly: 1 } };
  const a = {
    _cid: 'c1',
    _rawKey: 'a',
    status: 'approved',
    tmCardNumber: 'TM88',
    startedAt: Date.parse('2024-06-01T02:00:00.000Z'),
  };
  const b = {
    _cid: 'c1',
    _rawKey: 'b',
    status: 'submitted',
    tmCardNumber: 'TM88',
    startedAt: Date.parse('2024-06-20T02:00:00.000Z'),
  };
  const hitA = detectTripAnomalies(a, { peers: [a, b], cardsByNumber: cards });
  const hitB = detectTripAnomalies(b, { peers: [a, b], cardsByNumber: cards });
  assert.equal(hitA.reasons.includes('limit_exceeded_monthly'), false);
  assert.ok(hitB.reasons.includes('limit_exceeded_monthly'));
});

test('rejected trips do not count toward card limits', () => {
  const cards = { TM77: { usageLimitDaily: 1 } };
  const day = Date.parse('2024-06-15T02:00:00.000Z');
  const rejected = {
    _cid: 'c1',
    _rawKey: 'r',
    status: 'rejected',
    tmCardNumber: 'TM77',
    startedAt: day,
  };
  const ok = {
    _cid: 'c1',
    _rawKey: 'ok',
    status: 'submitted',
    tmCardNumber: 'TM77',
    startedAt: day + 60_000,
  };
  const hit = detectTripAnomalies(ok, { peers: [rejected, ok], cardsByNumber: cards });
  assert.equal(hit.reasons.includes('limit_exceeded_daily'), false);
});

test('card_expired when trip day is after registry expiryDate', () => {
  const cards = { TM55: { expiryDate: '2024-01-10' } };
  const expiredTrip = {
    _cid: 'c1',
    _rawKey: 'e',
    status: 'submitted',
    tmCardNumber: 'TM55',
    startedAt: Date.parse('2024-01-12T02:00:00.000Z'),
  };
  const validTrip = {
    _cid: 'c1',
    _rawKey: 'v',
    status: 'submitted',
    tmCardNumber: 'TM55',
    startedAt: Date.parse('2024-01-10T02:00:00.000Z'),
  };
  assert.ok(detectTripAnomalies(expiredTrip, { cardsByNumber: cards }).reasons.includes('card_expired'));
  assert.equal(
    detectTripAnomalies(validTrip, { cardsByNumber: cards }).reasons.includes('card_expired'),
    false,
  );
});

test('card_expired falls back to trip tmCardExpiry MM/YY when registry blank', () => {
  const trip = {
    _cid: 'c1',
    _rawKey: 'x',
    status: 'submitted',
    tmCardNumber: 'TM44',
    tmCardExpiry: '01/24',
    startedAt: Date.parse('2024-02-05T02:00:00.000Z'),
  };
  const hit = detectTripAnomalies(trip, { cardsByNumber: { TM44: {} } });
  assert.ok(hit.reasons.includes('card_expired'));
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

test('applyAnomalyScan applies card_expired via cardsByNumber', () => {
  const trips = [
    {
      _cid: 'c1',
      _rawKey: 'z',
      status: 'submitted',
      tmCardNumber: 'EXP1',
      startedAt: Date.parse('2025-01-01T02:00:00.000Z'),
      fare: 5,
      distanceKm: 1,
      durationMin: 1,
    },
  ];
  const patches = applyAnomalyScan(
    trips,
    { c1: { car: { base: 3, perKm: 2, perMin: 0.5, stopFee: 0 } } },
    { EXP1: { expiryDate: '2024-01-01' } },
  );
  assert.equal(patches.length, 1);
  assert.ok(patches[0].patch.flagReasons.includes('card_expired'));
});

test('isClaimEligibleStatus excludes flagged/revision/rejected', () => {
  assert.equal(isClaimEligibleStatus('approved'), true);
  assert.equal(isClaimEligibleStatus('paid'), true);
  assert.equal(isClaimEligibleStatus('flagged'), false);
  assert.equal(isClaimEligibleStatus('revision_needed'), false);
  assert.equal(isClaimEligibleStatus('rejected'), false);
  assert.equal(isClaimEligibleStatus('submitted'), false);
});

test('shouldAutoApproveCleanTrip: never-flagged clean submitted auto-approves', () => {
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      anomalyDetail: null,
    }),
    true,
  );
});

test('shouldAutoApproveCleanTrip: previously flagged then cleared still requires manual approval', () => {
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      anomalyDetail: null,
      flaggedAt: 1786205003066,
    }),
    false,
  );
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      events: {
        e1: { type: 'flagged', toStatus: 'flagged', at: 1 },
      },
    }),
    false,
  );
  // Council reject/return also blocks forever auto-approve
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      events: { e1: { type: 'rejected', toStatus: 'revision_needed', at: 2 } },
    }),
    false,
  );
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      rejectedAt: 1786542135061,
    }),
    false,
  );
  // Still dirty → no auto-approve
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: ['card_expired'],
    }),
    false,
  );
  assert.equal(shouldAutoApproveCleanTrip({ status: 'flagged', flagReasons: [] }), false);
});

test('shouldAutoApproveCleanTrip: previously edited clean trip still requires manual approval', () => {
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      anomalyDetail: null,
      editedAt: 99,
    }),
    false,
  );
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      events: { e1: { type: 'owner_edited', at: 1 } },
    }),
    false,
  );
  assert.equal(
    shouldAutoApproveCleanTrip({
      status: 'submitted',
      flagReasons: [],
      events: { e1: { type: 'council_edited', at: 1 } },
    }),
    false,
  );
});

test('tmAnomaly source exports claim helper and rules', () => {
  assert.match(anomalySrc, /export function isClaimEligibleStatus/);
  assert.match(anomalySrc, /export function shouldAutoApproveCleanTrip/);
  assert.match(anomalySrc, /export function tripWasEverFlagged/);
  assert.match(anomalySrc, /export function tripWasEverEdited/);
  assert.match(anomalySrc, /same_card_reuse_3min/);
  assert.match(anomalySrc, /same_card_same_time_diff_taxi/);
  assert.match(anomalySrc, /applyAnomalyScan/);
  assert.match(anomalySrc, /limit_exceeded_daily/);
  assert.match(anomalySrc, /limit_exceeded_monthly/);
  assert.match(anomalySrc, /card_expired/);
  assert.match(anomalySrc, /implausible_short_trip/);
  assert.match(anomalySrc, /isImplausibleShortTrip/);
  assert.match(anomalySrc, /hasInvalidTripCoords/);
  assert.match(anomalySrc, /IMPLAUSIBLE_SHORT_MAX_KM/);
  assert.match(anomalySrc, /cardsByNumber/);
  assert.match(anomalySrc, /cardUsageOrdinal/);
  assert.match(anomalySrc, /manuallyAddedByCompany/);
  assert.match(anomalySrc, /!isManualOwner && isImplausibleShortTrip/);
});

test('council portal loads tmCards into anomaly scan', () => {
  assert.match(councilSrc, /loadTmCardsByNumber/);
  assert.match(councilSrc, /fbRead\('tmCards'/);
  assert.match(councilSrc, /applyAnomalyScan\(list, tariffByCid \|\| \{\}, cardsByNumber/);
  assert.match(councilSrc, /autoApproveCleanNeverFlaggedTrips/);
  assert.match(councilSrc, /shouldAutoApproveCleanTrip/);
  assert.match(councilSrc, /afterCouncilApproveAddToBatch/);
  assert.match(councilSrc, /system-auto-approve/);
  assert.match(councilSrc, /limit_exceeded_daily/);
  assert.match(councilSrc, /card_expired/);
  assert.match(councilSrc, /implausible_short_trip/);
  assert.match(councilSrc, /Implausible short trip/);
  assert.match(councilSrc, /Daily limit exceeded/);
});

test('council portal pending + anomalies + bulk endpoints', () => {
  assert.match(councilSrc, /\/council-portal\/pending/);
  assert.match(councilSrc, /\/council-portal\/anomalies/);
  assert.match(councilSrc, /redirectLegacyTripPage\(req, res, 'pending'\)/);
  assert.match(councilSrc, /redirectLegacyTripPage\(req, res, 'flagged'\)/);
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
  assert.match(councilSrc, /\/council-portal\/trips\?t=.*status=flagged/);
  assert.match(councilSrc, /Return unlocks company editing/);
  assert.match(councilSrc, /view-only for the company until you click Return/);
});

test('SA Flagged filter includes card_expired and implausible_short_trip', () => {
  assert.match(flaggedAspx, /limit_exceeded_daily/);
  assert.match(flaggedAspx, /card_expired/);
  assert.match(flaggedAspx, /implausible_short_trip/);
});

test('owner panel shows flagged edit-warning on revision_needed and flagged', () => {
  assert.match(adminSrc, /Council flagged|flagReasons|anomalyDetail/);
  assert.match(adminSrc, /revision_needed/);
  assert.match(adminSrc, /implausible_short_trip/);
  assert.match(adminSrc, /st === 'flagged'/);
  assert.match(adminSrc, /tmFlagReasonLabels/);
});
