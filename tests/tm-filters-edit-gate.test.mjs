import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const trips = readFileSync(join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'), 'utf8');
const flagged = readFileSync(join(root, 'taxitime.co.nz/superadmin360taxi/TM-Flagged.aspx'), 'utf8');
const settlement = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Settlement.aspx'),
  'utf8',
);
const cleanScan = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Clean-Scan.aspx'),
  'utf8',
);
const anomaly = readFileSync(join(root, 'src/lib/tmAnomaly.ts'), 'utf8');
const admin = readFileSync(join(root, '..', 'INVT-admin', 'server.js'), 'utf8');

test('TM Trips has Company dropdown filter', () => {
  assert.match(trips, /id="tt-f-company"/);
  assert.match(trips, /All Companies/);
  assert.match(trips, /fCo && String\(t\._cid/);
});

test('TM Flagged has Company + From/To filters', () => {
  assert.match(flagged, /id="fl-f-company"/);
  assert.match(flagged, /id="fl-f-from"/);
  assert.match(flagged, /id="fl-f-to"/);
});

test('TM Settlement uses council/company dropdowns', () => {
  assert.match(settlement, /<select id="set-council"/);
  assert.match(settlement, /<select id="set-company"/);
  assert.doesNotMatch(settlement, /placeholder="cncl_/);
});

test('TM Clean Scan uses council/company dropdowns and no date range', () => {
  assert.match(cleanScan, /<select id="scan-council"/);
  assert.match(cleanScan, /<select id="scan-company"/);
  assert.doesNotMatch(cleanScan, /type="date"/);
  assert.doesNotMatch(cleanScan, /type="month"/);
});

test('never-edited gate wired in anomaly + owner edit stamps editedAt', () => {
  assert.match(anomaly, /export function tripWasEverEdited/);
  assert.match(anomaly, /if \(tripWasEverEdited\(trip\)\) return false/);
  assert.match(admin, /editedAt: editEv\.at/);
  assert.match(admin, /type: 'owner_edited'/);
});
