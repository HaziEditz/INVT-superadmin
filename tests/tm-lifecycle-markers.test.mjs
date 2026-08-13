/**
 * Lifecycle list markers: Resubmitted / Restored clarity chips.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  hasResubmittedMarker,
  hasRestoredMarker,
  lifecycleMarkerLabels,
  compareTripsResubmitFirst,
  RESUBMITTED_BADGE_LABEL,
  RESTORED_BADGE_LABEL,
} from '../src/lib/tmLifecycleMarkers.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const unifiedSrc = readFileSync(join(root, 'src/lib/tmUnifiedTrips.ts'), 'utf8');
const tmTripsSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'),
  'utf8',
);

test('hasResubmittedMarker only while awaiting re-review', () => {
  assert.equal(hasResubmittedMarker({ status: 'submitted', resubmittedAt: 1 }), true);
  assert.equal(hasResubmittedMarker({ status: 'flagged', resubmittedAt: 1 }), true);
  assert.equal(hasResubmittedMarker({ status: 'pending', resubmittedAt: 1 }), true);
  assert.equal(hasResubmittedMarker({ status: 'approved', resubmittedAt: 1 }), false);
  assert.equal(hasResubmittedMarker({ status: 'paid', resubmittedAt: 1 }), false);
  assert.equal(hasResubmittedMarker({ status: 'submitted' }), false);
  assert.equal(hasResubmittedMarker({ status: 'revision_needed', resubmittedAt: 1 }), false);
});

test('hasRestoredMarker when restoredAt set and not archived', () => {
  assert.equal(hasRestoredMarker({ status: 'flagged', restoredAt: 9 }), true);
  assert.equal(hasRestoredMarker({ status: 'submitted', restoredAt: 9 }), true);
  assert.equal(hasRestoredMarker({ status: 'archived', restoredAt: 9 }), false);
  assert.equal(hasRestoredMarker({ status: 'submitted' }), false);
});

test('lifecycle labels match agreed copy', () => {
  assert.deepEqual(
    lifecycleMarkerLabels({ status: 'submitted', resubmittedAt: 1, restoredAt: 2 }),
    [RESUBMITTED_BADGE_LABEL, RESTORED_BADGE_LABEL],
  );
  assert.equal(RESUBMITTED_BADGE_LABEL, 'Resubmitted - previously returned');
  assert.equal(RESTORED_BADGE_LABEL, 'Restored from archive');
});

test('compareTripsResubmitFirst puts resubmits above brand-new', () => {
  const a = { status: 'submitted', resubmittedAt: null, _ms: 100 };
  const b = { status: 'submitted', resubmittedAt: 50, _ms: 10 };
  const cmp = compareTripsResubmitFirst(a, b, (t) => t._ms);
  assert.ok(cmp > 0, 'b (resubmit) should sort before a');
});

test('tmUnifiedTrips Pending sort uses compareTripsResubmitFirst', () => {
  assert.match(unifiedSrc, /compareTripsResubmitFirst/);
  assert.match(unifiedSrc, /status === 'pending'/);
});

test('council Trips wires lifecycleListChips into Status column', () => {
  assert.match(councilSrc, /lifecycleListChips/);
  assert.match(councilSrc, /RESUBMITTED_BADGE_LABEL/);
  assert.match(councilSrc, /RESTORED_BADGE_LABEL/);
  assert.match(councilSrc, /lifecycleListChips\(t\)/);
  assert.match(councilSrc, /statusBadge\(d\.status\)/);
});

test('SA TM-Trips wires same badge copy + restoredAt + resubmit sort', () => {
  assert.match(tmTripsSrc, /Resubmitted - previously returned/);
  assert.match(tmTripsSrc, /Restored from archive/);
  assert.match(tmTripsSrc, /ttLifecycleChips/);
  assert.match(tmTripsSrc, /t\.restoredAt = st\.restoredAt/);
  assert.match(tmTripsSrc, /hasResubmittedMarker\(ta\)/);
});
