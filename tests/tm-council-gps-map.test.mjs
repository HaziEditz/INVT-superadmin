/**
 * Council map prefers driver gpsRoute; geocode+OSRM is fallback only.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  parseJobGpsRoute,
  jobCoordsMissing,
  buildTmTripDetail,
} from '../src/lib/tmTripDetail.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const detailSrc = readFileSync(join(root, 'src/lib/tmTripDetail.ts'), 'utf8');

test('parseJobGpsRoute prefers gpsRoute array', () => {
  const pts = parseJobGpsRoute({
    gpsRoute: [
      { lat: -46.41836, lng: 168.35287, at: 1 },
      { lat: -46.41858, lng: 168.35377, at: 2 },
      { lat: -46.42094, lng: 168.35516, at: 3 },
    ],
  });
  assert.equal(pts.length, 3);
  assert.ok(Math.abs(pts[0].lat - -46.41836) < 1e-5);
  assert.ok(Math.abs(pts[2].lng - 168.35516) < 1e-5);
});

test('parseJobGpsRoute decodes app delta polyline when array missing', () => {
  // First absolute E5, then deltas — same scheme as driver-app encodeRoutePolyline
  const poly = '-4641836,16835287;27,33;-22,0';
  const pts = parseJobGpsRoute({ routePolyline: poly });
  assert.ok(pts.length >= 2);
  assert.ok(Math.abs(pts[0].lat - -46.41836) < 1e-5);
  assert.ok(Math.abs(pts[0].lng - 168.35287) < 1e-5);
});

test('8692608133-shaped hail: trail present, stored latlng missing', () => {
  const job = {
    pickupAddress: '177H, Tweed Street, Appleby, Invercargill',
    dropAddress: '110, Bowmont Street, Appleby, Invercargill',
    gpsRoute: [
      { lat: -46.4183628, lng: 168.3528695 },
      { lat: -46.4185787, lng: 168.3537687 },
      { lat: -46.4209426, lng: 168.3551581 },
    ],
  };
  assert.equal(jobCoordsMissing(job), true);
  const trail = parseJobGpsRoute(job);
  assert.equal(trail.length, 3);
  const d = buildTmTripDetail({ ...job, _cid: '860869', _rawKey: '8692608133', status: 'approved' });
  assert.equal(d.gpsRoute.length, 3);
  assert.equal(d.pickupLat, 0);
  assert.equal(d.dropLat, 0);
});

test('council map prefers GPS trail before geocode/OSRM', () => {
  assert.match(councilSrc, /cpNormalizeGpsRoute/);
  assert.match(councilSrc, /cpDrawGpsTrail/);
  assert.match(councilSrc, /Prefer driver's logged GPS trail/);
  assert.match(councilSrc, /Driver GPS trail/);
  assert.match(councilSrc, /Estimated road route \(no GPS trail on job\)/);
  // initCpTripMap checks trail first
  const init = councilSrc.indexOf('function initCpTripMap');
  const trailIdx = councilSrc.indexOf('cpNormalizeGpsRoute(d)', init);
  const geoIdx = councilSrc.indexOf('cpGeocodeAddr', init);
  assert.ok(init >= 0 && trailIdx > init);
  assert.ok(trailIdx < geoIdx, 'GPS trail must run before geocode fallback');
});

test('buildTmTripDetail wires parseJobGpsRoute; display-only (no fare change)', () => {
  assert.match(detailSrc, /gpsRoute: parseJobGpsRoute\(t\)/);
  assert.match(detailSrc, /Does not affect fare/);
});
