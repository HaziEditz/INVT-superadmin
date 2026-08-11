import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const home = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/Home.aspx'),
  'utf8',
);
const trips = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'),
  'utf8',
);

test('Home Total Mobility nav lists Platform Fees, Clean-trip Scan, Settlement', () => {
  assert.match(home, /TM-Platform-Fees\.aspx">Platform Fees</);
  assert.match(home, /TM-Clean-Scan\.aspx">Clean-trip Scan</);
  assert.match(home, /TM-Settlement\.aspx">Settlement</);
});

test('TM-Trips Total Mobility nav lists the three new pages', () => {
  assert.match(trips, /TM-Platform-Fees\.aspx/);
  assert.match(trips, /TM-Clean-Scan\.aspx/);
  assert.match(trips, /TM-Settlement\.aspx/);
});
