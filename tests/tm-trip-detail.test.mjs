/**
 * Trip detail builder tests — mirrors src/lib/tmTripDetail.ts for node:test.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = readFileSync(join(root, 'src/lib/tmTripDetail.ts'), 'utf8');

test('tmTripDetail exports full CSV header set', () => {
  for (const col of [
    'Passenger',
    'Pickup',
    'Dropoff',
    'Meter Fare',
    'Hoist (council)',
    'Payment Method',
    'Split',
    'Voucher / Cards',
  ]) {
    assert.match(src, new RegExp(col.replace(/[()]/g, '\\$&')));
  }
});

test('tmTripDetail builds hoist lines and multi-card split', () => {
  assert.match(src, /tmHoists/);
  assert.match(src, /tmPassengers/);
  assert.match(src, /splitNote/);
  assert.match(src, /passengerCount/);
  assert.match(src, /waitingCharge/);
});
