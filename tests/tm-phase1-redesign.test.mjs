/**
 * Phase 1 TM redesign — vehicle registry join, provenance badges, reports wiring.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, '..');
const require = createRequire(import.meta.url);

const {
  resolveDriverVehicle,
  companyVehicleMap,
  readVehicleNode,
} = require(join(root, 'taxitime.co.nz/superadmin360taxi/assets/js/vehicle-registry.js'));

const {
  classifyTmConfig,
  legacyTariffProvenance,
  provenanceBadgeHtml,
  setupHubBannerHtml,
} = require(join(root, 'taxitime.co.nz/superadmin360taxi/assets/js/tm-provenance.js'));

const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const setupPage = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Setup.aspx'),
  'utf8',
);
const settingsPage = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Settings.aspx'),
  'utf8',
);
const configPage = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Council-Config.aspx'),
  'utf8',
);
const homePage = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/Home.aspx'),
  'utf8',
);

test('resolveDriverVehicle reads registration + cab from company vehicles via assignedVehicles', () => {
  const vehicles = {
    '860869': {
      '12': {
        taxiNumber: '12',
        registration: 'ABC123',
        make: 'Toyota',
        model: 'Prius',
        vehicleType: 'Standard',
      },
    },
  };
  const driver = {
    firstName: 'Ann',
    assignedVehicles: ['12'],
  };
  const v = resolveDriverVehicle(vehicles, '860869', driver);
  assert.equal(v.registration, 'ABC123');
  assert.equal(v.taxiNumber, '12');
  assert.match(v.label, /Toyota/);
});

test('resolveDriverVehicle does not invent plate from empty driver profile', () => {
  const v = resolveDriverVehicle({}, '860869', { firstName: 'Bob' });
  assert.equal(v.registration, '');
  assert.equal(v.taxiNumber, '');
});

test('companyVehicleMap indexes by taxi number', () => {
  const map = companyVehicleMap(
    { '1': { '7': { taxiNumber: '7', registration: 'XYZ9' } } },
    '1',
  );
  assert.equal(map['7'].registration, 'XYZ9');
});

test('readVehicleNode accepts plate alias', () => {
  const info = readVehicleNode({ plate: 'aa11', vehicleNo: '3' }, '3');
  assert.equal(info.registration, 'AA11');
  assert.equal(info.taxiNumber, '3');
});

test('classifyTmConfig distinguishes synced vs manual', () => {
  const synced = classifyTmConfig({
    sourceCouncilId: 'icc',
    syncedFromCouncilAt: Date.now(),
    councilSubsidyPercent: 75,
  });
  assert.equal(synced.kind, 'synced');
  const manual = classifyTmConfig({
    manualOverrideAt: Date.now(),
    councilSubsidyPercent: 50,
  });
  assert.equal(manual.kind, 'manual');
  assert.equal(legacyTariffProvenance().kind, 'manual');
  assert.match(provenanceBadgeHtml(legacyTariffProvenance()), /reference|Reference|Manual/i);
  assert.match(provenanceBadgeHtml(synced), /Synced/);
  assert.match(setupHubBannerHtml('Council Config'), /TM Setup Hub/);
});

test('TM Setup Hub page exists with guided steps and snapshot', () => {
  assert.match(setupPage, /TM Setup Hub/);
  assert.match(setupPage, /loadHub/);
  assert.match(setupPage, /tm-provenance\.js/);
  assert.match(setupPage, /Step 1|Quick add|Approve/i);
});

test('soft-redirect banners on advanced TM pages', () => {
  assert.match(settingsPage, /Prefer TM Setup Hub/);
  assert.match(configPage, /Prefer TM Setup Hub/);
  assert.match(homePage, /TM Setup Hub/);
  assert.match(homePage, /Council Config \(Advanced\)/);
});

test('council Operators joins vehicles registry for plate and cab', () => {
  assert.match(councilSrc, /resolveDriverVehicle/);
  assert.match(councilSrc, /fbRead\('vehicles'/);
  assert.match(councilSrc, /Registration/);
  assert.match(councilSrc, /Cab No/);
  assert.match(councilSrc, /provenanceBadgeHtml/);
  assert.match(councilSrc, /classifyTmConfig/);
});

test('council Reports has company selector, date range, detail modal, full CSV', () => {
  assert.match(councilSrc, /name="company"/);
  assert.match(councilSrc, /All Companies/);
  assert.match(councilSrc, /name="from"/);
  assert.match(councilSrc, /name="to"/);
  assert.match(councilSrc, /openCpDetail/);
  assert.match(councilSrc, /tripDetailModalHtml/);
  assert.match(councilSrc, /TM_TRIP_CSV_HEADERS/);
  assert.match(councilSrc, /buildTmTripDetail/);
  assert.match(councilSrc, /Payment Method/);
  assert.match(councilSrc, /Fare Breakdown/);
});

test('council Dashboard snapshot includes approved companies', () => {
  assert.match(councilSrc, /Approved Companies/);
  assert.match(councilSrc, /Recent TM activity/);
  assert.match(councilSrc, /Dashboard snapshot/);
});
