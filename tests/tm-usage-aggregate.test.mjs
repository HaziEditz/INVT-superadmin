/**
 * Cardholder usage Insights — client aggregate + council wiring.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const require = createRequire(import.meta.url);
const U = require(join(root, 'src/lib/tmUsageAggregate.client.js'));

const sample = [
  {
    tmCardNumber: '111',
    tmPassengerName: 'Alice',
    tmMeterFare: 40,
    tmSubsidyFare: 26,
    tmPassengerPays: 14,
    tmSubsidyHoist: 11,
    tmHoistCount: 1,
    paymentType: 'Cash',
    driverName: 'D1',
    vehicleId: '201',
    completedAt_ISO: '2026-08-01T02:00:00.000Z',
  },
  {
    tmCardNumber: '111',
    tmPassengerName: 'Alice',
    tmMeterFare: 20,
    tmSubsidyFare: 13,
    tmPassengerPays: 7,
    paymentType: 'Card',
    driverName: 'D1',
    vehicleId: '201',
    completedAt_ISO: '2026-08-15T02:00:00.000Z',
  },
  {
    tmCardNumber: '222',
    tmPassengerName: 'Bob',
    fare: 10,
    tmSubsidyFare: 6.5,
    tmPassengerPays: 3.5,
    paymentType: 'Account',
    driverName: 'D2',
    vehicleId: '202',
    completedAt_ISO: '2026-07-20T02:00:00.000Z',
  },
];

test('client aggregate includes fare, pax, pay-type by card', () => {
  const usage = U.aggregateTripUsage(sample);
  assert.equal(usage.byCard.length, 2);
  const alice = usage.byCard.find((r) => r.key === '111');
  assert.ok(alice);
  assert.equal(alice.trips, 2);
  assert.equal(alice.meterFare, 60);
  assert.equal(alice.councilPays, 39);
  assert.equal(alice.passengerPays, 21);
  assert.equal(alice.hoistPays, 11);
  assert.equal(alice.payByType.Cash.trips, 1);
  assert.equal(alice.payByType.Card.trips, 1);
  assert.match(U.formatPayByType(alice.payByType), /Cash:1/);
  assert.match(U.formatPayByType(alice.payByType), /Card:1/);
});

test('day/month period buckets + date filter', () => {
  const byMonth = U.aggregateUsageByMonth(sample);
  assert.ok(byMonth.some((r) => r.key === '2026-08'));
  assert.ok(byMonth.some((r) => r.key === '2026-07'));
  const aug = byMonth.find((r) => r.key === '2026-08');
  assert.equal(aug.trips, 2);
  assert.ok(aug.meterFare > 0 && aug.passengerPays > 0);
  const filtered = U.filterByDateRange(sample, '2026-08-01', '2026-08-31');
  assert.equal(filtered.length, 2);
  const byDay = U.aggregateUsageByDay(filtered);
  assert.ok(byDay.length >= 1);
  assert.ok(byDay.every((r) => r.payByType && typeof r.payByType === 'object'));
});

test('tmUnifiedTrips.ts exports richer UsageBucket fields', () => {
  const src = readFileSync(join(root, 'src/lib/tmUnifiedTrips.ts'), 'utf8');
  assert.match(src, /export function formatPayByType/);
  assert.match(src, /export function meterFareOf/);
  assert.match(src, /export function passengerPaysOf/);
  assert.match(src, /payByType/);
  assert.match(src, /normalizeTripPayMethod/);
});

test('council Insights wires fare/pax/pay-type + day/month toggle', () => {
  const src = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
  assert.match(src, /formatPayByType/);
  assert.match(src, /Fare \$/);
  assert.match(src, /Pax \$/);
  assert.match(src, /Pay type/);
  assert.match(src, /periodView/);
  assert.match(src, /periodToggleQs\('day'\)/);
  assert.match(src, /periodToggleQs\('month'\)/);
  assert.match(src, /All Companies/);
});

test('SA TM-Reports includes cardholder usage Insights block', () => {
  const src = readFileSync(
    join(root, 'taxitime.co.nz/superadmin360taxi/TM-Reports.aspx'),
    'utf8',
  );
  assert.match(src, /tmUsageAggregate\.client\.js/);
  assert.match(src, /Cardholder usage \(Insights\)/);
  assert.match(src, /renderCardholderUsage/);
  assert.match(src, /rp-usage-from/);
  assert.match(src, /rpSetUsagePeriod/);
});

test('owner assets ship the shared client aggregate helper', () => {
  assert.ok(
    existsSync(
      join(
        root,
        '../INVT-admin/taxitime.co.nz/owner/assets/js/tmUsageAggregate.client.js',
      ),
    ),
  );
});
