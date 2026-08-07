/**
 * Trip detail enrichment + approval/price-list wiring for Phase 1.5.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const require = createRequire(import.meta.url);

// Inline pure copies matching tmTripDetail.ts (node:test without ts-node)
function formatTmDateTime(raw) {
  if (raw == null || raw === '') return '';
  if (typeof raw === 'number' || (typeof raw === 'string' && /^\d{10,13}$/.test(String(raw).trim()))) {
    let ms = Number(raw);
    if (ms < 1e12) ms *= 1000;
    return new Date(ms).toISOString().slice(0, 16).replace('T', ' ');
  }
  const p = Date.parse(String(raw));
  if (Number.isFinite(p)) return new Date(p).toISOString().slice(0, 16).replace('T', ' ');
  return String(raw).slice(0, 16).replace('T', ' ');
}

function resolveCardholderName(job) {
  const passengers = Array.isArray(job.tmPassengers) ? job.tmPassengers : [];
  const fromList = passengers.map((p) => String(p.cardholderName || '').trim()).filter(Boolean);
  if (fromList.length) return fromList.join(' + ');
  return String(job.tmCardName || job.cardholderName || job.tmPassengerName || '').trim();
}

function expectedMeterFromTariff(tariff, distanceKm, durationMin, waitingMin = 0) {
  if (!tariff) return null;
  const base = Number(tariff.base) || 0;
  const perKm = Number(tariff.perKm) || 0;
  const perMin = Number(tariff.perMin) || 0;
  const stop = Number(tariff.stopFee) || 0;
  if (!base && !perKm && !perMin && !stop) return null;
  return +(base + distanceKm * perKm + durationMin * perMin + waitingMin * stop).toFixed(2);
}

const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const detailSrc = readFileSync(join(root, 'src/lib/tmTripDetail.ts'), 'utf8');
const settingsPage = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Settings.aspx'),
  'utf8',
);

test('formatTmDateTime formats epoch ms (not raw digits only)', () => {
  const out = formatTmDateTime(1700000000000);
  assert.ok(out.length > 8);
  assert.doesNotMatch(out, /^1700000000000$/);
});

test('resolveCardholderName prefers tmCardName from card entry', () => {
  assert.equal(resolveCardholderName({ tmCardName: 'Jane Doe', tmPassengerName: '—' }), 'Jane Doe');
  assert.equal(
    resolveCardholderName({ tmPassengers: [{ cardholderName: 'A' }, { cardholderName: 'B' }] }),
    'A + B',
  );
});

test('expectedMeterFromTariff computes reference fare', () => {
  const n = expectedMeterFromTariff({ base: 3.5, perKm: 2, perMin: 0.5, stopFee: 0 }, 10, 20, 0);
  assert.equal(n, 3.5 + 20 + 10);
});

test('tmTripDetail source uses tmCardName and format helpers', () => {
  assert.match(detailSrc, /resolveCardholderName/);
  assert.match(detailSrc, /tmCardName/);
  assert.match(detailSrc, /formatTmDateTime/);
  assert.match(detailSrc, /formatTmDuration/);
  assert.match(detailSrc, /pickupLat/);
  assert.match(detailSrc, /startedAtRaw/);
  assert.match(detailSrc, /expectedMeterFromTariff/);
});

test('council Reports has three-action approve + edit + map', () => {
  assert.match(councilSrc, /action === 'return'/);
  assert.match(councilSrc, /revision_needed/);
  assert.match(councilSrc, /\/api\/council-trip-edit/);
  assert.match(councilSrc, /Reject \/ Red-flag/);
  assert.match(councilSrc, /Return to company/);
  assert.match(councilSrc, /cp-trip-map/);
  assert.match(councilSrc, /leaflet/i);
  assert.match(councilSrc, /buildEditPanel/);
  assert.match(councilSrc, /startedAtRaw/);
});

test('Reports detail script does not nest single-quoted alert inside single-quoted h+=', () => {
  // Phase 1.5 regression: alert('...') inside h += '...' broke the whole <script>
  // with Uncaught SyntaxError: Unexpected identifier 'Reject' → Details click noop.
  assert.doesNotMatch(
    councilSrc,
    /h \+= '[^']*alert\('/,
  );
  assert.match(councilSrc, /alert\(&#39;Reject note required&#39;\)/);
  assert.match(councilSrc, /alert\(&#39;Revision note required&#39;\)/);
});

test('council tariff save + Operators reference price list', () => {
  assert.match(councilSrc, /\/api\/council-tariff-save/);
  assert.match(councilSrc, /Reference price list/);
});

test('TM-Settings re-enables reference price list editing', () => {
  assert.match(settingsPage, /Reference price list/);
  assert.match(settingsPage, /adminRead\('tmTariffs'\)/);
  assert.match(settingsPage, /openTariffModal/);
  assert.match(settingsPage, /not live metering/i);
});
