/**
 * Passenger name + Return-from-approved + empty-batch delete markers.
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
const tripsSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'),
  'utf8',
);
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const detailSrc = readFileSync(join(root, 'src/lib/tmTripDetail.ts'), 'utf8');

function loadResolveCardholderName() {
  const sandbox = { window: {}, console };
  vm.createContext(sandbox);
  const start = helpersSrc.indexOf('function resolveCardholderName');
  assert.ok(start >= 0);
  const end = helpersSrc.indexOf('window.resolveCardholderName = resolveCardholderName;', start);
  assert.ok(end > start);
  vm.runInContext(
    helpersSrc.slice(start, end) + '\n;window.resolveCardholderName = resolveCardholderName;',
    sandbox,
  );
  return sandbox.window.resolveCardholderName;
}

test('resolveCardholderName prefers tmCardName when tmPassengerName blank (live Patton shape)', () => {
  const resolveCardholderName = loadResolveCardholderName();
  assert.equal(
    resolveCardholderName({ tmCardName: 'Richard Patton', tmPassengerName: null }),
    'Richard Patton',
  );
  assert.equal(
    resolveCardholderName({
      tmPassengers: [{ cardholderName: 'A' }, { cardholderName: 'B' }],
      tmCardName: 'X',
    }),
    'A + B',
  );
});

test('SA TM-Trips list uses resolveCardholderName', () => {
  assert.match(tripsSrc, /resolveCardholderName\(j\)/);
});

test('council Dashboard recent activity uses resolveCardholderName', () => {
  assert.match(councilSrc, /resolveCardholderName\(t\)/);
  assert.match(detailSrc, /export function resolveCardholderName/);
});

test('Trip Detail modal: Return only (no Reject return-for-fix); Return works on approved', () => {
  assert.doesNotMatch(councilSrc, /Reject \(return for fix\)/);
  assert.match(councilSrc, /canReturn = canApprove \|\| d\.status==='approved'/);
  assert.match(councilSrc, /Return to company/);
  assert.match(councilSrc, /status === 'approved'/);
  assert.match(councilSrc, /action" value="return"/);
});

test('empty batch is deleted after last trip removed', () => {
  assert.match(councilSrc, /plan\.tripCount === 0/);
  assert.match(councilSrc, /fbWrite\('DELETE', batchPath/);
});
