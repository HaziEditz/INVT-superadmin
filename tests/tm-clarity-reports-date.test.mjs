/**
 * Part A clarity labels + SA TM-Reports company filter + blank-date fallback.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const helpersSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/assets/js/tm-helpers.js'),
  'utf8',
);
const reportsSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Reports.aspx'),
  'utf8',
);
const tripsSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'),
  'utf8',
);
const dosSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/SA-DriverOpsSummary.aspx'),
  'utf8',
);
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');

function loadTripDisplayTimeRaw() {
  const sandbox = { window: {}, console };
  vm.createContext(sandbox);
  // Extract just the helper functions we need (file depends on other globals lightly).
  const start = helpersSrc.indexOf('function tripDisplayTimeRaw');
  assert.ok(start >= 0, 'tripDisplayTimeRaw missing');
  const end = helpersSrc.indexOf('window.tripDisplayTimeRaw = tripDisplayTimeRaw;', start);
  assert.ok(end > start);
  const chunk =
    helpersSrc.slice(start, end) +
    '\n;window.tripDisplayTimeRaw = tripDisplayTimeRaw;';
  vm.runInContext(chunk, sandbox);
  return sandbox.window.tripDisplayTimeRaw;
}

test('tripDisplayTimeRaw falls back to completedAt when start missing', () => {
  const tripDisplayTimeRaw = loadTripDisplayTimeRaw();
  assert.equal(
    tripDisplayTimeRaw({ completedAt: '2026-08-12T13:32:33.000Z' }),
    '2026-08-12T13:32:33.000Z',
  );
  assert.equal(
    tripDisplayTimeRaw({ startedAt_ISO: '2026-08-01T01:00:00.000Z', completedAt: '2026-08-12T13:32:33.000Z' }),
    '2026-08-01T01:00:00.000Z',
  );
  assert.equal(tripDisplayTimeRaw({}), '');
});

test('TM-Trips Date cell uses tripDisplayTimeRaw', () => {
  assert.match(tripsSrc, /tripDisplayTimeRaw\(t\)/);
  assert.match(tripsSrc, /completedAt: j\.completedAt/);
});

test('TM-Reports has company filter + clarity columns + date fallback', () => {
  assert.match(reportsSrc, /id="rp-f-company"/);
  assert.match(reportsSrc, /populateRPCompanies/);
  assert.match(reportsSrc, /Gross fare \(meter \+ hoist\)/);
  assert.match(reportsSrc, /Meter base \(%\/cap\)/);
  assert.match(reportsSrc, /tripDisplayTimeRaw\(t\)/);
  assert.match(reportsSrc, /%\/cap subsidy applies to Meter base/);
});

test('SA DOS clarity labels Gross fare + Meter base', () => {
  assert.match(dosSrc, /Gross fare \(meter \+ hoist\)/);
  assert.match(dosSrc, /Meter base \(%\/cap applies here\)/);
  assert.match(dosSrc, /Gross .+ Meter base /);
});

test('council portal Trips + Batches/Dashboard clarity labels', () => {
  assert.match(councilSrc, /Gross fare \(meter \+ hoist\)/);
  assert.match(councilSrc, /Meter base \(%\/cap applies here\)/);
  assert.match(councilSrc, /%\/cap is not on this number/);
  assert.match(councilSrc, /applied to Meter base/);
  assert.match(councilSrc, /meter %\/cap · hoist separate/);
});
