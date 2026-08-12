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
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const anomalySrc = readFileSync(join(root, 'src/lib/tmAnomaly.ts'), 'utf8');

function str(v, fallback = '') {
  if (v == null) return fallback;
  return String(v).trim() || fallback;
}

/** Inline mirror of resolveTripCategoryLabel */
function resolveTripCategoryLabel(t) {
  if (!t || typeof t !== 'object') return '—';
  const explicit = str(t.tmTripCategory || t.tripCategory);
  if (explicit && explicit !== '—') return explicit;
  if (t.manuallyAddedByCompany === true || t.manuallyAddedByCompany === 'true') {
    return 'Manually added by company';
  }
  const raw = String(
    t.source || t.bookingSource || t.BookingSource || t.Source || t.via || t.Via || '',
  )
    .toLowerCase()
    .trim();
  if (!raw) return '—';
  if (raw === 'manual_owner' || raw.includes('manual_owner') || raw.includes('manual owner')) {
    return 'Manually added by company';
  }
  if (
    raw.includes('hail') ||
    raw.includes('driverapp') ||
    raw.includes('driver_app') ||
    raw.includes('driver-app') ||
    raw.includes('driver created') ||
    raw.includes('street') ||
    raw === 'queue' ||
    raw.includes('driverqueue')
  ) {
    return 'Hail';
  }
  if (raw.includes('dispatch') || raw.includes('console')) return 'Dispatch';
  if (raw.includes('web') || raw.includes('website')) return 'Website';
  if (raw.includes('passenger') || raw.includes('rider') || raw.includes('pax') || raw.includes('app')) {
    return 'Passenger app';
  }
  if (raw.includes('food')) return 'Food';
  if (raw.includes('freight') || raw.includes('parcel')) return 'Freight';
  if (raw === 'driver_complete') return '—';
  return raw.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

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

test('resolveTripCategoryLabel wired into buildTmTripDetail', () => {
  assert.match(src, /export function resolveTripCategoryLabel/);
  assert.match(src, /export function isManuallyAddedByCompany/);
  assert.match(src, /tripCategory: resolveTripCategoryLabel\(t\)/);
  assert.match(src, /manuallyAddedByCompany: isManuallyAddedByCompany\(t\)/);
  assert.match(src, /Manually added by company/);
  assert.match(src, /return 'Hail'/);
  assert.match(src, /return 'Dispatch'/);
});

test('resolveTripCategoryLabel maps hail when tmTripCategory blank (live 8692608131 shape)', () => {
  assert.equal(resolveTripCategoryLabel({ source: 'hail', fare: 15.27 }), 'Hail');
  assert.equal(resolveTripCategoryLabel({ source: 'dispatch' }), 'Dispatch');
  assert.equal(resolveTripCategoryLabel({ source: 'website' }), 'Website');
  assert.equal(resolveTripCategoryLabel({ source: 'passenger_app' }), 'Passenger app');
  assert.equal(resolveTripCategoryLabel({ source: 'manual_owner' }), 'Manually added by company');
  assert.equal(resolveTripCategoryLabel({ tmTripCategory: 'Medical' }), 'Medical');
  assert.equal(resolveTripCategoryLabel({}), '—');
});

test('council modal surfaces Manual badge + category from builder', () => {
  assert.match(councilSrc, /Manually added by company/);
  assert.match(councilSrc, /d\.manuallyAddedByCompany/);
  assert.match(councilSrc, /Trip Category/);
});

test('anomaly skip GPS/route for manual_owner trips; fare/card still apply', () => {
  assert.match(anomalySrc, /manual_owner/);
  assert.match(anomalySrc, /manuallyAddedByCompany/);
  assert.match(anomalySrc, /isManualOwner/);
  assert.match(anomalySrc, /!isManualOwner && isImplausibleShortTrip/);
});
