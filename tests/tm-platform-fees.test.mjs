import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  normalizePlatformTmFeeDefaults,
  resolvePlatformTmFees,
  buildTripPlatformFeeStamp,
  aggregateWouldBeFees,
  PLATFORM_FEE_UI_LABEL,
} from '../src/lib/tmPlatformFees.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const feeSrc = readFileSync(join(root, 'src/lib/tmPlatformFees.ts'), 'utf8');

test('normalizePlatformTmFeeDefaults keeps chargeEnabled hard-off unless explicit true', () => {
  assert.deepEqual(normalizePlatformTmFeeDefaults(null), {
    councilFeePerTrip: 0,
    companyFeePerTrip: 0,
    chargeEnabled: false,
  });
  assert.equal(normalizePlatformTmFeeDefaults({ chargeEnabled: true }).chargeEnabled, true);
  assert.equal(normalizePlatformTmFeeDefaults({ chargeEnabled: 1 }).chargeEnabled, false);
  assert.equal(normalizePlatformTmFeeDefaults({ chargeEnabled: 'true' }).chargeEnabled, false);
});

test('resolvePlatformTmFees: company override beats defaults', () => {
  const r = resolvePlatformTmFees(
    { councilFeePerTrip: 1, companyFeePerTrip: 0.5, chargeEnabled: false },
    { councilFeePerTrip: 1.25, companyFeePerTrip: '' },
  );
  assert.equal(r.councilFeePerTrip, 1.25);
  assert.equal(r.companyFeePerTrip, 0.5);
  assert.equal(r.source, 'company_override');
  assert.equal(r.chargeEnabled, false);
});

test('buildTripPlatformFeeStamp never enables live charge on stamp', () => {
  const stamp = buildTripPlatformFeeStamp(
    resolvePlatformTmFees({ councilFeePerTrip: 1, companyFeePerTrip: 0.5, chargeEnabled: true }, null),
    1000,
  );
  assert.equal(stamp.platformFeeCouncil, 1);
  assert.equal(stamp.platformFeeCompany, 0.5);
  assert.equal(stamp.platformFeeChargeEnabled, false);
  assert.equal(stamp.platformFeeStampAt, 1000);
  assert.equal(stamp.platformFeeLabel, PLATFORM_FEE_UI_LABEL);
});

test('aggregateWouldBeFees groups stamped trips', () => {
  const agg = aggregateWouldBeFees([
    {
      _cid: '860869',
      councilId: 'cncl_a',
      platformFeeStampAt: 1,
      platformFeeCouncil: 1,
      platformFeeCompany: 0.5,
    },
    {
      _cid: '860870',
      councilId: 'cncl_a',
      platformFeeStampAt: 2,
      platformFeeCouncil: 1,
      platformFeeCompany: 0.5,
    },
    { _cid: '860869', councilId: 'cncl_a', status: 'approved' },
  ]);
  assert.equal(agg.tripCount, 2);
  assert.equal(agg.councilFees, 2);
  assert.equal(agg.companyFees, 1);
  assert.equal(agg.byCompany.length, 2);
  assert.equal(agg.byCouncil[0].councilId, 'cncl_a');
});

test('companyFeeOverrideFromTmConfig reads override keys', async () => {
  const { companyFeeOverrideFromTmConfig } = await import('../src/lib/tmPlatformFees.ts');
  const o = companyFeeOverrideFromTmConfig({
    councilFeePerTrip: 1.1,
    companyFeePerTrip: 0.4,
  });
  assert.equal(o.councilFeePerTrip, 1.1);
  assert.equal(o.companyFeePerTrip, 0.4);
});

test('fee helpers exported and council stamps on claim-ready path', () => {
  assert.match(feeSrc, /export function resolvePlatformTmFees/);
  assert.match(feeSrc, /export function buildTripPlatformFeeStamp/);
  assert.match(feeSrc, /platformFeeChargeEnabled: false/);
  assert.match(councilSrc, /buildTripPlatformFeeStamp|stampPlatformFeesOnApprove/);
  assert.match(councilSrc, /platformTmFees\/defaults/);
});
