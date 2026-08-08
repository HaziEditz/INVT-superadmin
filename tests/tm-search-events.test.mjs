/**
 * TM search + trip events + owner archive guards.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const searchSrc = readFileSync(join(root, 'src/lib/tmTripSearch.ts'), 'utf8');
const eventsSrc = readFileSync(join(root, 'src/lib/tmTripEvents.ts'), 'utf8');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const tmTripsSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'),
  'utf8',
);
const adminSrc = readFileSync(
  join(root, '..', 'INVT-admin', 'server.js'),
  'utf8',
);

function tripMatchesSearch(trip, query) {
  const q = String(query || '').trim().toLowerCase();
  if (!q) return true;
  if (!trip) return false;
  const ids = [trip._rawKey, trip.bookingId, trip.id, trip.jobId]
    .map((v) => String(v || '').toLowerCase())
    .filter(Boolean);
  const passengers = [trip.passengerName, trip.tmCardName, trip.tmPassengerName, trip.customerName]
    .map((v) => String(v || '').toLowerCase())
    .filter(Boolean);
  const drivers = [trip.driverName, trip.driver].map((v) => String(v || '').toLowerCase()).filter(Boolean);
  const cards = [];
  const primary = String(trip.tmCardNumber || trip.tmVoucherNo || trip.cardNumber || '')
    .toLowerCase()
    .replace(/\s+/g, '');
  if (primary) cards.push(primary);
  if (Array.isArray(trip.allCardNums)) {
    trip.allCardNums.forEach((c) => {
      const n = String(c || '').toLowerCase().replace(/\s+/g, '');
      if (n) cards.push(n);
    });
  }
  const hay = ids.concat(passengers, drivers, cards).join(' ');
  const qCompact = q.replace(/\s+/g, '');
  return hay.includes(q) || (qCompact.length > 0 && hay.replace(/\s+/g, '').includes(qCompact));
}

function synthesizeEventsFromStatus(st) {
  const out = [];
  const push = (type, at) => {
    const n = Number(at);
    if (!Number.isFinite(n) || n <= 0) return;
    out.push({ at: n, type });
  };
  push('submitted', st.submittedAt);
  push('flagged', st.flaggedAt);
  push('returned', st.sentBackAt);
  push('resubmitted', st.resubmittedAt);
  push('approved', st.approvedAt);
  out.sort((a, b) => a.at - b.at);
  return out;
}

test('tripMatchesSearch matches job, passenger, driver, card', () => {
  const trip = {
    _rawKey: '8692608082',
    passengerName: 'Jane Doe',
    driverName: 'Sam Driver',
    tmCardNumber: 'TM-9988',
  };
  assert.equal(tripMatchesSearch(trip, '8692608082'), true);
  assert.equal(tripMatchesSearch(trip, 'jane'), true);
  assert.equal(tripMatchesSearch(trip, 'sam'), true);
  assert.equal(tripMatchesSearch(trip, '9988'), true);
  assert.equal(tripMatchesSearch(trip, 'nope'), false);
  assert.equal(tripMatchesSearch(trip, ''), true);
});

test('synthesizeEventsFromStatus builds chronological timeline', () => {
  const ev = synthesizeEventsFromStatus({
    submittedAt: 100,
    flaggedAt: 200,
    sentBackAt: 300,
    resubmittedAt: 400,
  });
  assert.deepEqual(
    ev.map((e) => e.type),
    ['submitted', 'flagged', 'returned', 'resubmitted'],
  );
});

test('search + events source exports', () => {
  assert.match(searchSrc, /export function tripMatchesSearch/);
  assert.match(eventsSrc, /export function buildTripEvent/);
  assert.match(eventsSrc, /export function normalizeTripEvents/);
  assert.match(eventsSrc, /synthesizeEventsFromStatus/);
});

test('council search page + timeline + in-tab q', () => {
  assert.match(councilSrc, /\/council-portal\/search/);
  assert.match(councilSrc, /redirectLegacyTripPage\(req, res, 'all'\)/);
  assert.match(councilSrc, /tripMatchesSearch|filterTripsUnified/);
  assert.match(councilSrc, /appendTripEvent/);
  assert.match(councilSrc, /tripHistoryHtml/);
  assert.match(councilSrc, /name="q"|filterQ|req\.query\.q/);
});

test('SA TM-Trips timeline helpers', () => {
  assert.match(tmTripsSrc, /ttTripHistoryHtml/);
  assert.match(tmTripsSrc, /ttAppendEvent/);
});

test('owner can archive revision_needed but not restore', () => {
  assert.match(adminSrc, /archiveOwnerTrip/);
  assert.match(adminSrc, /revision_needed/);
  assert.match(adminSrc, /ownerTripHistoryHtml|Trip history/);
  assert.match(adminSrc, /Only trips returned for revision can be archived/);
  assert.doesNotMatch(adminSrc, /function restoreOwnerTrip/);
  assert.match(adminSrc, /council or BookaWaka admin can restore/i);
});

test('owner fix comment required on resubmit and stored on events', () => {
  assert.match(adminSrc, /te-fixComment/);
  assert.match(adminSrc, /fix comment is required before resubmitting/);
  assert.match(adminSrc, /note: fixComment/);
  assert.match(adminSrc, /type: 'resubmitted'/);
  assert.match(adminSrc, /type: 'owner_edited'/);
});

test('council detail map geocodes and is on pending + flagged + reports', () => {
  assert.match(councilSrc, /initCpTripMap/);
  assert.match(councilSrc, /\/api\/council-geocode/);
  assert.match(councilSrc, /nominatim\.openstreetmap\.org/);
  assert.match(councilSrc, /BookaWaka-CouncilPortal/);
  assert.match(councilSrc, /cp-trip-map-wrap/);
  assert.match(councilSrc, /hmNHrzRCf9tD/);
  assert.match(councilSrc, /openCpDetail/);
  assert.match(councilSrc, /_cpReturnTo = \$\{JSON\.stringify\(returnTo\)\}|_cpReturnTo = '/);
  assert.match(councilSrc, /filterTripsUnified/);
  assert.match(councilSrc, /\/council-portal\/trips/);
  assert.doesNotMatch(councilSrc, /function initRptMap|openRptDetail/);
  assert.doesNotMatch(councilSrc, /cp-trip-map-debug|cpMapDbg|council-map-debug|mapdbg-20260808/);
});
