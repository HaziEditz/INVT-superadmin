import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  parseSaCompanyTmConfigFields,
  legacySaCompanyTmConfigFallback,
  resolveCouncilTmRates,
  calcTmMeterSubsidyFromCouncil,
  resolveHoistAmount,
} from '../lib/tmRateResolve.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const saCompany = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/SA-Company.aspx'),
  'utf8',
);
const trips = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'),
  'utf8',
);
const flagged = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Flagged.aspx'),
  'utf8',
);
const home = readFileSync(join(root, 'taxitime.co.nz/superadmin360taxi/Home.aspx'), 'utf8');
const helpers = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/assets/js/tm-helpers.js'),
  'utf8',
);

test('BEFORE: blank SA-Company fields silently became 65 / 37.40 / 11.50', () => {
  const legacy = legacySaCompanyTmConfigFallback('', '', '');
  assert.equal(legacy.pct, 65);
  assert.equal(legacy.cap, 37.4);
  assert.equal(legacy.hoist, 11.5);
});

test('AFTER: blank SA-Company fields refuse save (no guessed overwrite)', () => {
  const blank = parseSaCompanyTmConfigFields('', '', '');
  assert.equal(blank.ok, false);
  assert.match(String(blank.error), /required|Blank/i);

  const partial = parseSaCompanyTmConfigFields('65', '', '11');
  assert.equal(partial.ok, false);

  const ok = parseSaCompanyTmConfigFields('65', '37.4', '11');
  assert.equal(ok.ok, true);
  assert.equal(ok.pct, 65);
  assert.equal(ok.cap, 37.4);
  assert.equal(ok.hoist, 11);
});

test('SA-Company.aspx wires refuse-blank save (no || 65 / 37.40 / 11.50)', () => {
  assert.match(saCompany, /parseSaCompanyTmConfigFields/);
  assert.doesNotMatch(saCompany, /parseFloat\(pctEl && pctEl\.value\) \|\| 65/);
  assert.doesNotMatch(saCompany, /\|\| 37\.40/);
  assert.doesNotMatch(saCompany, /\|\| 11\.50/);
  assert.doesNotMatch(saCompany, /: 65\);/);
  assert.match(saCompany, /Blank fields are not saved|required/);
});

test('calcTmMeterSubsidyFromCouncil never invents 75%', () => {
  const missing = calcTmMeterSubsidyFromCouncil(100, {});
  assert.equal(missing.ok, false);
  assert.equal(missing.amount, null);
  assert.equal(missing.configMissing, true);

  const live = calcTmMeterSubsidyFromCouncil(100, { subsidyPercent: 65, capAmount: 40 });
  assert.equal(live.ok, true);
  assert.equal(live.amount, 40);
});

test('resolveHoistAmount never invents $5/use', () => {
  const noRate = resolveHoistAmount({ tmHoistCount: 2 }, {});
  assert.equal(noRate.amount, 0);
  assert.equal(noRate.configMissing, true);

  const withRate = resolveHoistAmount({ tmHoistCount: 2 }, { subsidyPercent: 65, hoistRatePerUse: 11 });
  assert.equal(withRate.amount, 22);
  assert.equal(withRate.configMissing, false);

  const stored = resolveHoistAmount({ tmSubsidyHoist: 22, tmHoistCount: 2 }, {});
  assert.equal(stored.amount, 22);
  assert.equal(stored.fromStored, true);
});

test('TM-Trips / Flagged / Home use live helpers — no 75 / $5 / 37.50 fallbacks', () => {
  assert.match(helpers, /window\.parseSaCompanyTmConfigFields/);
  assert.match(helpers, /window\.calcTmMeterSubsidyFromCouncil/);
  assert.match(helpers, /window\.resolveHoistAmount/);

  assert.match(trips, /calcTmMeterSubsidyFromCouncil/);
  assert.match(trips, /resolveHoistAmount/);
  assert.doesNotMatch(trips, /subsidyPercent \|\| 75/);
  assert.doesNotMatch(trips, /tmHoistCount \* 5/);
  assert.doesNotMatch(trips, /capAmount \|\| 99999/);

  assert.match(flagged, /resolveCouncilTmRates/);
  assert.match(flagged, /refuse guessed 75%/);
  assert.doesNotMatch(flagged, /subsidyPercent \|\| 75/);
  assert.doesNotMatch(flagged, /capAmount \|\| 37\.50/);

  assert.match(home, /calcTmMeterSubsidyFromCouncil/);
  assert.match(home, /resolveHoistAmount/);
  assert.doesNotMatch(home, /subsidyPercent \|\| 75/);
  assert.doesNotMatch(home, /tmHoistCount\) \* 5/);
});

test('resolveCouncilTmRates ready only when subsidy % > 0', () => {
  assert.equal(resolveCouncilTmRates({}).ready, false);
  assert.equal(resolveCouncilTmRates({ subsidyPercent: 0 }).ready, false);
  assert.equal(resolveCouncilTmRates({ subsidyPercent: 65, capAmount: 37.4 }).ready, true);
});
