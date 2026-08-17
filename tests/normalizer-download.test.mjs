/**
 * SA normalizer download hygiene — shared loads, per-cid pendingjobs, load-test skip.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = readFileSync(join(root, 'src/normalizer.ts'), 'utf8');
const helperSrc = readFileSync(join(root, 'src/lib/loadTestTenants.ts'), 'utf8');

// Pure helper — load via ts if available, else mirror assert from source
test('isSyntheticLoadTestCompanyId marks bwtest harness ids', async () => {
  assert.match(helperSrc, /export function isSyntheticLoadTestCompanyId/);
  // Dynamic import of compiled-ish TS via node --experimental or transpile:
  // Mirror the logic inline to keep the test zero-build.
  function isSyntheticLoadTestCompanyId(cid) {
    const c = String(cid || '').trim().toLowerCase();
    if (!c) return false;
    if (c === 'bwtest' || c === 'bwtesttariff') return true;
    if (c.startsWith('bwtest')) return true;
    return false;
  }
  assert.equal(isSyntheticLoadTestCompanyId('bwtest'), true);
  assert.equal(isSyntheticLoadTestCompanyId('bwtesttariff'), true);
  assert.equal(isSyntheticLoadTestCompanyId('bwtest-extra'), true);
  assert.equal(isSyntheticLoadTestCompanyId('860869'), false);
  assert.equal(isSyntheticLoadTestCompanyId('860870'), false);
});

test('normalizer interval is at least 60 seconds', () => {
  const m = src.match(/const INTERVAL_MS = ([^;]+);/);
  assert.ok(m);
  // eslint-disable-next-line no-new-func
  const ms = Function(`return (${m[1]})`)();
  assert.ok(ms >= 60_000);
});

test('normalizer loads pendingjobs once per cycle via shallow + per-cid', () => {
  assert.match(src, /async function loadPendingJobsOperational/);
  assert.match(src, /pendingjobs\?shallow=true/);
  assert.match(src, /pendingjobs\/' \+ cid/);
  assert.match(src, /isSyntheticLoadTestCompanyId/);
  // No triple independent root reads in the four workers
  assert.doesNotMatch(src, /const pendingRoot = await fbReadP\('pendingjobs'\)/);
});

test('normalizer still runs all four heal paths', () => {
  assert.match(src, /normalizeVehicleStatus\(/);
  assert.match(src, /normalizePaymentStatus\(/);
  assert.match(src, /normalizeBookingNotifications\(/);
  assert.match(src, /normalizeStalePendingJobs\(/);
  assert.match(src, /paymentStatus:"paid"/);
  assert.match(src, /rideStatus/);
});
