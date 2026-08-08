/**
 * Unified council Trips helpers + council.ts wiring.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const unifiedSrc = readFileSync(join(root, 'src/lib/tmUnifiedTrips.ts'), 'utf8');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');

// Inline mirrors of tmUnifiedTrips.ts (node:test without ts compile)
function isArchivedStatus(status) {
  return String(status || '').trim().toLowerCase() === 'archived';
}
function tripActivityMs(t) {
  const raw = t?.startedAt_ISO || t?.startedAt || t?.completedAt_ISO || t?.completedAt || 0;
  if (typeof raw === 'number') return raw < 1e12 ? raw * 1000 : raw;
  const p = Date.parse(String(raw));
  return Number.isFinite(p) ? p : 0;
}
function tripMatchesSearch(t, q) {
  const needle = String(q || '').trim().toLowerCase();
  if (!needle) return true;
  const hay = [
    t.tmVoucherNo,
    t.tmCardNumber,
    t.tmPassengerName,
    t.passengerName,
    t.driverName,
    t.driverFullName,
    t._companyName,
    t.source,
    t.pickupAddress,
    t.dropAddress,
    t._rawKey,
  ]
    .map((v) => String(v || '').toLowerCase())
    .join(' ');
  return hay.includes(needle);
}
function normalizeUnifiedTripStatus(raw) {
  const s = String(raw || '').trim().toLowerCase();
  if (
    s === 'pending' ||
    s === 'flagged' ||
    s === 'archived' ||
    s === 'approved' ||
    s === 'paid' ||
    s === 'rejected' ||
    s === 'all'
  ) {
    return s;
  }
  if (s === 'submitted' || s === 'anomalies') return s === 'anomalies' ? 'flagged' : 'pending';
  if (s === 'reports' || s === 'search' || s === 'trips') return 'all';
  return 'all';
}
function tripMatchesUnifiedStatus(trip, status) {
  if (!trip) return false;
  const st = String(trip.status || '').trim().toLowerCase();
  if (status === 'all') return !isArchivedStatus(st);
  if (status === 'pending') return st === 'submitted';
  if (status === 'flagged') return st === 'flagged';
  if (status === 'archived') return isArchivedStatus(st);
  if (status === 'approved') return st === 'approved';
  if (status === 'paid') return st === 'paid';
  if (status === 'rejected') return st === 'rejected';
  return true;
}
function filterTripsUnified(trips, opts = {}) {
  const status = normalizeUnifiedTripStatus(opts.status);
  let rows = (trips || []).slice();
  rows = rows.filter((t) => tripMatchesUnifiedStatus(t, status));
  const companyId = String(opts.companyId || '').trim();
  if (companyId) rows = rows.filter((t) => String(t._cid || '') === companyId);
  const q = String(opts.q || '').trim();
  if (q) rows = rows.filter((t) => tripMatchesSearch(t, q));
  if (opts.from) {
    const fromMs = Date.parse(String(opts.from) + 'T00:00:00');
    if (Number.isFinite(fromMs)) rows = rows.filter((t) => tripActivityMs(t) >= fromMs);
  }
  if (opts.to) {
    const toMs = Date.parse(String(opts.to) + 'T23:59:59');
    if (Number.isFinite(toMs)) rows = rows.filter((t) => tripActivityMs(t) <= toMs);
  }
  rows.sort((a, b) => tripActivityMs(b) - tripActivityMs(a));
  return rows;
}
function subsidyOf(t) {
  return parseFloat(String(t.tmSubsidy != null ? t.tmSubsidy : t.tmCouncilPays || 0)) || 0;
}
function aggregateTripUsage(trips, limitOrOpts = Number.POSITIVE_INFINITY) {
  const limit =
    typeof limitOrOpts === 'number'
      ? limitOrOpts
      : limitOrOpts?.limit != null
        ? limitOrOpts.limit
        : Number.POSITIVE_INFINITY;
  const bump = (map, key, label, pay, hoist) => {
    const k = String(key || '').trim() || '—';
    let row = map.get(k);
    if (!row) {
      row = { key: k, label: label || k, trips: 0, councilPays: 0, hoistPays: 0 };
      map.set(k, row);
    }
    row.trips++;
    row.councilPays += pay;
    row.hoistPays += hoist || 0;
  };
  const cards = new Map();
  const drivers = new Map();
  const vehicles = new Map();
  const passengers = new Map();
  for (const t of trips || []) {
    const pay = subsidyOf(t);
    const hoist = parseFloat(String(t.tmSubsidyHoist || 0)) || 0;
    const card = String(t.tmCardNumber || t.tmVoucherNo || '—').trim() || '—';
    const cardLabel = String(t.tmCardName || t.tmPassengerName || card).trim() || card;
    bump(cards, card, cardLabel, pay, hoist);
    const driver = String(t.driverFullName || t.driverName || '—').trim() || '—';
    bump(drivers, driver, driver, pay, hoist);
    const vehicle = String(t.vehicleId || t.taxiNumber || '—').trim() || '—';
    bump(vehicles, vehicle, vehicle, pay, hoist);
    bump(passengers, cardLabel, cardLabel, pay, hoist);
  }
  const sortTop = (m) => {
    let rows = Array.from(m.values())
      .map((r) => ({
        ...r,
        councilPays: +r.councilPays.toFixed(2),
        hoistPays: +r.hoistPays.toFixed(2),
      }))
      .sort((a, b) => b.trips - a.trips || b.councilPays - a.councilPays);
    if (Number.isFinite(limit) && limit >= 0) rows = rows.slice(0, limit);
    return rows;
  };
  return {
    byCard: sortTop(cards),
    byDriver: sortTop(drivers),
    byVehicle: sortTop(vehicles),
    byPassenger: sortTop(passengers),
  };
}
function countTripsByUnifiedStatus(trips) {
  const out = {
    all: 0,
    pending: 0,
    flagged: 0,
    archived: 0,
    approved: 0,
    paid: 0,
    rejected: 0,
  };
  for (const t of trips || []) {
    const st = String(t?.status || '').trim().toLowerCase();
    if (isArchivedStatus(st)) out.archived++;
    else {
      out.all++;
      if (st === 'submitted') out.pending++;
      else if (st === 'flagged') out.flagged++;
      else if (st === 'approved') out.approved++;
      else if (st === 'paid') out.paid++;
      else if (st === 'rejected') out.rejected++;
    }
  }
  return out;
}

const sample = [
  {
    _cid: 'c1',
    status: 'submitted',
    tmPassengerName: 'Ada',
    tmVoucherNo: 'V1',
    driverName: 'Dan',
    vehicleId: '201',
    tmSubsidy: 10,
    startedAt_ISO: '2026-03-01T10:00:00',
  },
  {
    _cid: 'c1',
    status: 'flagged',
    tmPassengerName: 'Bob',
    tmVoucherNo: 'V2',
    driverName: 'Dan',
    vehicleId: '201',
    tmSubsidy: 20,
    startedAt_ISO: '2026-03-02T10:00:00',
  },
  {
    _cid: 'c2',
    status: 'archived',
    tmPassengerName: 'Cara',
    tmVoucherNo: 'V3',
    driverName: 'Eve',
    vehicleId: '305',
    tmSubsidy: 5,
    startedAt_ISO: '2026-03-03T10:00:00',
  },
  {
    _cid: 'c2',
    status: 'approved',
    tmPassengerName: 'Dee',
    tmVoucherNo: 'V4',
    driverName: 'Eve',
    vehicleId: '305',
    tmSubsidy: 15,
    startedAt_ISO: '2026-03-04T10:00:00',
  },
];

test('normalizeUnifiedTripStatus maps legacy aliases', () => {
  assert.equal(normalizeUnifiedTripStatus('pending'), 'pending');
  assert.equal(normalizeUnifiedTripStatus('submitted'), 'pending');
  assert.equal(normalizeUnifiedTripStatus('anomalies'), 'flagged');
  assert.equal(normalizeUnifiedTripStatus('reports'), 'all');
  assert.equal(normalizeUnifiedTripStatus('search'), 'all');
  assert.equal(normalizeUnifiedTripStatus('trips'), 'all');
  assert.equal(normalizeUnifiedTripStatus('paid'), 'paid');
  assert.equal(normalizeUnifiedTripStatus('nope'), 'all');
});

test('filterTripsUnified filters by status, company, q, dates', () => {
  const pending = filterTripsUnified(sample, { status: 'pending' });
  assert.equal(pending.length, 1);
  assert.equal(pending[0].tmVoucherNo, 'V1');

  const all = filterTripsUnified(sample, { status: 'all' });
  assert.equal(all.length, 3); // excludes archived
  assert.ok(all.every((t) => t.status !== 'archived'));

  const archived = filterTripsUnified(sample, { status: 'archived' });
  assert.equal(archived.length, 1);

  const byCo = filterTripsUnified(sample, { status: 'all', companyId: 'c2' });
  assert.equal(byCo.length, 1);
  assert.equal(byCo[0].tmVoucherNo, 'V4');

  const byQ = filterTripsUnified(sample, { status: 'all', q: 'Ada' });
  assert.equal(byQ.length, 1);

  const byDate = filterTripsUnified(sample, {
    status: 'all',
    from: '2026-03-02',
    to: '2026-03-03',
  });
  assert.equal(byDate.length, 1);
  assert.equal(byDate[0].tmVoucherNo, 'V2');
});

test('aggregateTripUsage and countTripsByUnifiedStatus', () => {
  const usage = aggregateTripUsage(sample.filter((t) => t.status !== 'archived'));
  assert.ok(usage.byDriver.length >= 1);
  assert.ok(usage.byVehicle.some((r) => r.key === '201' && r.trips === 2));
  const counts = countTripsByUnifiedStatus(sample);
  assert.equal(counts.pending, 1);
  assert.equal(counts.flagged, 1);
  assert.equal(counts.archived, 1);
  assert.equal(counts.approved, 1);
  assert.equal(counts.all, 3);
});

test('tmUnifiedTrips source exports helpers', () => {
  assert.match(unifiedSrc, /export function normalizeUnifiedTripStatus/);
  assert.match(unifiedSrc, /export function filterTripsUnified/);
  assert.match(unifiedSrc, /export function aggregateTripUsage/);
  assert.match(unifiedSrc, /export function countTripsByUnifiedStatus/);
  assert.match(unifiedSrc, /UNIFIED_TRIP_STATUS_OPTIONS/);
});

test('council.ts slim nav + unified trips wiring', () => {
  const navBlock = councilSrc.slice(
    councilSrc.indexOf('function renderNav'),
    councilSrc.indexOf('function portalPage'),
  );
  assert.match(navBlock, /\['trips'/);
  assert.match(navBlock, /\['batches'/);
  assert.match(navBlock, /\['operators'/);
  assert.doesNotMatch(navBlock, /Pending Approval/);
  assert.doesNotMatch(navBlock, /\['search'/);
  assert.doesNotMatch(navBlock, /\['pending'/);
  assert.doesNotMatch(navBlock, /\['anomalies'/);
  assert.doesNotMatch(navBlock, /\['archived'/);
  assert.doesNotMatch(navBlock, /\['reports'/);

  assert.match(councilSrc, /function redirectLegacyTripPage/);
  assert.match(councilSrc, /filterTripsUnified/);
  assert.match(councilSrc, /aggregateTripUsage/);
  assert.match(councilSrc, /countTripsByUnifiedStatus/);
  assert.match(councilSrc, /legacyReturnToStatus/);
  assert.match(councilSrc, /status=pending/);
  assert.match(councilSrc, /status=flagged/);
});

test('legacy trip pages redirect to unified trips', () => {
  assert.match(
    councilSrc,
    /router\.get\('\/council-portal\/pending'[\s\S]*?redirectLegacyTripPage\(req, res, 'pending'\)/,
  );
  assert.match(
    councilSrc,
    /router\.get\('\/council-portal\/anomalies'[\s\S]*?redirectLegacyTripPage\(req, res, 'flagged'\)/,
  );
  assert.match(
    councilSrc,
    /router\.get\('\/council-portal\/archived'[\s\S]*?redirectLegacyTripPage\(req, res, 'archived'\)/,
  );
  assert.match(
    councilSrc,
    /router\.get\('\/council-portal\/search'[\s\S]*?redirectLegacyTripPage\(req, res, 'all'\)/,
  );
  assert.match(
    councilSrc,
    /router\.get\('\/council-portal\/reports'[\s\S]*?redirectLegacyTripPage\(req, res, 'all'\)/,
  );
  assert.match(
    councilSrc,
    /router\.get\('\/council-portal\/flagged'[\s\S]*?redirectLegacyTripPage\(req, res, 'flagged'\)/,
  );
  assert.match(councilSrc, /\/council-portal\/trips\?.*status=/);
});

test('bulk approve/archive/restore respect active Trips filters', () => {
  assert.match(councilSrc, /function unifiedFiltersFromBody/);
  assert.match(councilSrc, /filterHiddens/);
  // Approve-all path uses filterTripsUnified (not bare all submitted)
  const approveBlock = councilSrc.slice(
    councilSrc.indexOf("router.post('/api/council-bulk-approve'"),
    councilSrc.indexOf("router.post('/api/council-bulk-return'"),
  );
  assert.match(approveBlock, /allClean/);
  assert.match(approveBlock, /filterTripsUnified\(scanned/);
  assert.match(approveBlock, /filters\.q/);
  assert.match(approveBlock, /filters\.company/);
  assert.match(approveBlock, /filters\.from/);
  assert.match(approveBlock, /filters\.to/);
  assert.doesNotMatch(
    approveBlock,
    /if \(allClean\) return true;/,
  );

  const archiveBlock = councilSrc.slice(
    councilSrc.indexOf("router.post('/api/council-bulk-archive'"),
    councilSrc.indexOf("router.post('/api/council-restore'"),
  );
  assert.match(archiveBlock, /allMatching/);
  assert.match(archiveBlock, /filterTripsUnified\(scanned/);
  assert.match(archiveBlock, /unifiedFiltersFromBody/);

  const restoreBlock = councilSrc.slice(
    councilSrc.indexOf("router.post('/api/council-bulk-restore'"),
    councilSrc.indexOf("router.post('/api/council-bulk-restore'") + 2500,
  );
  assert.match(restoreBlock, /filterTripsUnified\(myTrips/);
  assert.match(restoreBlock, /status: 'archived'/);

  // Toolbar posts filter fields with bulk forms
  assert.match(councilSrc, /name="q" value="\$\{esc\(q\)\}"/);
  assert.match(councilSrc, /name="company" value="\$\{esc\(filterCompany\)\}"/);
  assert.match(councilSrc, /matching the current filters/);
});
