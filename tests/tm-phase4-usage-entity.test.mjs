/**
 * Phase 4 usage / hoist-by-day / entity filters + multi-company operators partition.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const unifiedSrc = readFileSync(join(root, 'src/lib/tmUnifiedTrips.ts'), 'utf8');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');

function tripActivityMs(t) {
  const raw = t?.startedAt_ISO || t?.startedAt || t?.completedAt_ISO || t?.completedAt || 0;
  if (typeof raw === 'number') return raw < 1e12 ? raw * 1000 : raw;
  const p = Date.parse(String(raw));
  return Number.isFinite(p) ? p : 0;
}

function subsidyOf(t) {
  return parseFloat(String(t.tmSubsidy != null ? t.tmSubsidy : t.tmCouncilPays || 0)) || 0;
}
function hoistPaysOf(t) {
  return parseFloat(String(t.tmSubsidyHoist ?? t.hoistTotal ?? t.hoistCost ?? 0)) || 0;
}
function hoistUsesOf(t) {
  if (Array.isArray(t?.tmHoists) && t.tmHoists.length) return t.tmHoists.length;
  const counted = parseInt(String(t?.tmHoistCount ?? t?.hoistCount ?? t?.hoistUsed ?? ''), 10);
  if (Number.isFinite(counted) && counted > 0) return counted;
  return hoistPaysOf(t) > 0 ? 1 : 0;
}
function tripDayKey(t) {
  const ms = tripActivityMs(t);
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
function tripCardKeys(t) {
  const keys = [];
  for (const v of [t?.tmCardNumber, t?.tmVoucherNo, t?.cardNumber]) {
    const s = String(v || '').trim();
    if (s) keys.push(s);
  }
  if (Array.isArray(t?.allCardNums)) {
    for (const n of t.allCardNums) {
      const s = String(n || '').trim();
      if (s) keys.push(s);
    }
  }
  return keys;
}
function tripDriverKey(t) {
  return String(t?.driverFullName || t?.driverDisplayName || t?.driverName || t?.driver || '').trim() || '—';
}
function tripVehicleKey(t) {
  return String(t?.vehicleId || t?.taxiNumber || t?.registration || t?.vehicle || t?.VehicleNo || '').trim() || '—';
}
function tripPassengerKey(t) {
  return String(t?.tmCardName || t?.tmPassengerName || t?.passengerName || t?.cardholderName || '').trim() || '—';
}
function normKey(s) {
  return String(s || '').trim().toLowerCase().replace(/\s+/g, ' ');
}
function tripMatchesEntity(trip, type, key) {
  const want = String(key || '').trim();
  if (!want || !trip) return false;
  const wantN = normKey(want);
  if (type === 'company') return String(trip._cid || '').trim() === want;
  if (type === 'driver') return normKey(tripDriverKey(trip)) === wantN;
  if (type === 'vehicle') return normKey(tripVehicleKey(trip)) === wantN;
  if (type === 'card') return tripCardKeys(trip).some((k) => normKey(k) === wantN || k === want);
  if (type === 'passenger') return normKey(tripPassengerKey(trip)) === wantN;
  return false;
}
function bumpUsage(map, key, label, councilPays, hoistPays) {
  const k = String(key || '').trim() || '—';
  let row = map.get(k);
  if (!row) {
    row = { key: k, label: label || k, trips: 0, councilPays: 0, hoistPays: 0 };
    map.set(k, row);
  }
  row.trips++;
  row.councilPays += councilPays;
  row.hoistPays += hoistPays;
}
function aggregateTripUsage(trips, limitOrOpts = Number.POSITIVE_INFINITY) {
  const limit =
    typeof limitOrOpts === 'number'
      ? limitOrOpts
      : limitOrOpts?.limit != null
        ? limitOrOpts.limit
        : Number.POSITIVE_INFINITY;
  const cards = new Map();
  const drivers = new Map();
  const vehicles = new Map();
  const passengers = new Map();
  for (const t of trips || []) {
    const pay = subsidyOf(t);
    const hoist = hoistPaysOf(t);
    const card = tripCardKeys(t)[0] || '—';
    const cardLabel = tripPassengerKey(t);
    bumpUsage(cards, card, cardLabel, pay, hoist);
    bumpUsage(drivers, tripDriverKey(t), tripDriverKey(t), pay, hoist);
    bumpUsage(vehicles, tripVehicleKey(t), tripVehicleKey(t), pay, hoist);
    bumpUsage(passengers, tripPassengerKey(t), tripPassengerKey(t), pay, hoist);
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
function aggregateHoistByDay(trips) {
  const map = new Map();
  for (const t of trips || []) {
    const day = tripDayKey(t) || 'unknown';
    let row = map.get(day);
    if (!row) {
      row = { day, uses: 0, hoistPays: 0, trips: 0, tripsWithHoist: 0 };
      map.set(day, row);
    }
    row.trips++;
    const uses = hoistUsesOf(t);
    const pays = hoistPaysOf(t);
    if (uses > 0 || pays > 0) {
      row.tripsWithHoist++;
      row.uses += uses;
      row.hoistPays += pays;
    }
  }
  return Array.from(map.values())
    .map((r) => ({ ...r, hoistPays: +r.hoistPays.toFixed(2) }))
    .sort((a, b) => a.day.localeCompare(b.day));
}
function aggregateByPeriod(trips, keyFn) {
  const map = new Map();
  for (const t of trips || []) {
    const key = keyFn(t) || 'unknown';
    let row = map.get(key);
    if (!row) row = { key, trips: 0, councilPays: 0, hoistPays: 0, hoistUses: 0 };
    row.trips++;
    row.councilPays += subsidyOf(t);
    row.hoistPays += hoistPaysOf(t);
    row.hoistUses += hoistUsesOf(t);
    map.set(key, row);
  }
  return Array.from(map.values())
    .map((r) => ({
      ...r,
      councilPays: +r.councilPays.toFixed(2),
      hoistPays: +r.hoistPays.toFixed(2),
    }))
    .sort((a, b) => a.key.localeCompare(b.key));
}
function looksLikeDriver(d) {
  if (!d || typeof d !== 'object') return false;
  return !!(d.email || d.uid || d.dispatcherId || d.firstName || d.lastName || d.name || d.phone);
}
function listDriversForCompanyInline(raw, companyId) {
  const cid = String(companyId || '').trim();
  if (!cid || !raw) return [];
  const out = [];
  const nested = raw[cid];
  if (nested && typeof nested === 'object') {
    for (const [uid, d] of Object.entries(nested)) {
      if (looksLikeDriver(d)) out.push({ ...d, _uid: uid, _cid: cid });
    }
  }
  for (const [key, val] of Object.entries(raw)) {
    if (key === cid) continue;
    if (!looksLikeDriver(val)) continue;
    if (String(val.companyId || val.company_id || '') === cid) {
      out.push({ ...val, _uid: key, _cid: cid });
    }
  }
  return out;
}
function partitionOperatorRosters(approvedCids, driversRoot, listDrivers) {
  return (approvedCids || []).map((cid) => ({
    cid: String(cid),
    drivers: listDrivers(driversRoot, cid, { activeOnly: true }),
  }));
}

const dayA = Date.parse('2026-03-01T10:00:00+13:00');
const dayB = Date.parse('2026-03-02T10:00:00+13:00');

const sampleTrips = [
  {
    _cid: '860869',
    tmCardNumber: 'CARD1',
    tmCardName: 'Alice',
    driverName: 'Driver A',
    taxiNumber: 'T1',
    tmSubsidy: 10,
    tmSubsidyHoist: 5,
    tmHoists: [{ amount: 5 }],
    completedAt: dayA,
  },
  {
    _cid: '860869',
    tmCardNumber: 'CARD1',
    tmCardName: 'Alice',
    driverName: 'Driver A',
    taxiNumber: 'T1',
    tmSubsidy: 12,
    tmSubsidyHoist: 5,
    hoistCount: 1,
    completedAt: dayB,
  },
  {
    _cid: '999001',
    tmCardNumber: 'CARD2',
    tmCardName: 'Bob',
    driverName: 'Driver B',
    taxiNumber: 'T2',
    tmSubsidy: 8,
    tmSubsidyHoist: 0,
    completedAt: dayA,
  },
];

test('aggregateHoistByDay buckets two trips on different days', () => {
  const rows = aggregateHoistByDay(sampleTrips);
  assert.equal(rows.length, 2);
  assert.equal(rows[0].uses, 1);
  assert.equal(rows[0].hoistPays, 5);
  assert.equal(rows[1].uses, 1);
  assert.equal(rows[1].hoistPays, 5);
  const totalUses = rows.reduce((s, r) => s + r.uses, 0);
  assert.equal(totalUses, 2);
});

test('hoistUsesOf counts tmHoistCount when tmHoists absent', () => {
  assert.equal(hoistUsesOf({ tmHoistCount: 2, tmSubsidyHoist: 20 }), 2);
  assert.equal(hoistUsesOf({ tmHoists: [{}, {}], tmHoistCount: 9 }), 2);
  assert.equal(hoistUsesOf({ fare: 10 }), 0);
});

test('aggregateTripUsage returns all cards (not capped at 8) with hoist', () => {
  const many = [];
  for (let i = 0; i < 12; i++) {
    many.push({
      tmCardNumber: 'C' + i,
      tmCardName: 'P' + i,
      driverName: 'D' + i,
      taxiNumber: 'V' + i,
      tmSubsidy: 1,
      tmSubsidyHoist: 2,
      completedAt: dayA,
    });
  }
  const all = aggregateTripUsage(many);
  assert.equal(all.byCard.length, 12);
  assert.equal(all.byCard[0].hoistPays, 2);
  const top3 = aggregateTripUsage(many, 3);
  assert.equal(top3.byCard.length, 3);
  const viaOpts = aggregateTripUsage(many, { limit: Infinity });
  assert.equal(viaOpts.byCard.length, 12);
});

test('aggregateUsageByDay and ByMonth roll council + hoist', () => {
  const byDay = aggregateByPeriod(sampleTrips, tripDayKey);
  assert.ok(byDay.length >= 2);
  const byMonth = aggregateByPeriod(sampleTrips, tripMonthKeyNz);
  assert.equal(byMonth.length, 1);
  assert.equal(byMonth[0].trips, 3);
  assert.equal(byMonth[0].hoistUses, 2);
});

test('entity filter matches company driver vehicle card passenger', () => {
  assert.equal(sampleTrips.filter((t) => tripMatchesEntity(t, 'company', '999001')).length, 1);
  assert.equal(sampleTrips.filter((t) => tripMatchesEntity(t, 'driver', 'Driver A')).length, 2);
  assert.equal(sampleTrips.filter((t) => tripMatchesEntity(t, 'vehicle', 'T2')).length, 1);
  assert.equal(sampleTrips.filter((t) => tripMatchesEntity(t, 'card', 'CARD1')).length, 2);
  assert.equal(sampleTrips.filter((t) => tripMatchesEntity(t, 'passenger', 'Bob')).length, 1);
});

test('partitionOperatorRosters keeps drivers per company separate', () => {
  const root = {
    '860869': {
      u1: { email: 'a@x.com', firstName: 'Ann', name: 'Ann' },
      u2: { email: 'b@x.com', firstName: 'Ben', name: 'Ben' },
    },
    '999001': {
      u3: { email: 'c@x.com', firstName: 'Cy', name: 'Cy' },
    },
    flatX: { email: 'd@x.com', firstName: 'Dee', companyId: '999001' },
  };
  const parts = partitionOperatorRosters(['860869', '999001'], root, (r, cid) =>
    listDriversForCompanyInline(r, cid),
  );
  assert.equal(parts.length, 2);
  assert.equal(parts[0].cid, '860869');
  assert.equal(parts[0].drivers.length, 2);
  assert.equal(parts[1].cid, '999001');
  assert.equal(parts[1].drivers.length, 2); // nested Cy + flat Dee
  const emails0 = parts[0].drivers.map((d) => d.email).sort();
  const emails1 = parts[1].drivers.map((d) => d.email).sort();
  assert.deepEqual(emails0, ['a@x.com', 'b@x.com']);
  assert.deepEqual(emails1, ['c@x.com', 'd@x.com']);
  // No cross-contamination
  assert.ok(!emails0.includes('c@x.com'));
  assert.ok(!emails1.includes('a@x.com'));
});

test('tmUnifiedTrips source exports phase4 helpers', () => {
  assert.match(unifiedSrc, /export function aggregateHoistByDay/);
  assert.match(unifiedSrc, /export function aggregateUsageByDay/);
  assert.match(unifiedSrc, /export function aggregateUsageByMonth/);
  assert.match(unifiedSrc, /export function tripMatchesEntity/);
  assert.match(unifiedSrc, /export function filterTripsByEntity/);
  assert.match(unifiedSrc, /export function partitionOperatorRosters/);
  assert.match(unifiedSrc, /byPassenger/);
  assert.match(unifiedSrc, /hoistPays/);
  assert.match(unifiedSrc, /Pacific\/Auckland/);
});

test('council Operators builds per-cid sections (multi-company safe)', () => {
  assert.match(councilSrc, /approvedCids\.map\(cid/);
  assert.match(councilSrc, /listDriversForCompany\(driversRoot, cid/);
  assert.match(councilSrc, /partitionOperatorRosters|listDriversForCompany\(driversRoot, cid/);
  assert.match(councilSrc, /tmTariffs/);
  assert.match(councilSrc, /Save reference prices/);
  // Each company card includes trip history link once entity page ships
  assert.match(councilSrc, /\/council-portal\/entity/);
});

test('council wires hoist-by-day, insights entity links, card-save, entity page', () => {
  assert.match(councilSrc, /aggregateHoistByDay/);
  assert.match(councilSrc, /Hoist by day/);
  assert.match(councilSrc, /aggregateUsageByDay/);
  assert.match(councilSrc, /\/council-portal\/entity/);
  assert.match(councilSrc, /\/api\/council-card-save/);
  assert.match(councilSrc, /expiryDate/);
  assert.match(councilSrc, /entityType|entityKey|normalizeEntityType/);
});
