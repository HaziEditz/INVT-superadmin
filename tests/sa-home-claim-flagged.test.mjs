/**
 * SA Home KPIs: council claim = subsidyOf + hoist once; flagged requires councilId.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const home = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/Home.aspx'),
  'utf8',
);
const helpers = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/assets/js/tm-helpers.js'),
  'utf8',
);
const anomalySrc = readFileSync(join(root, 'src/lib/tmAnomaly.ts'), 'utf8');

function loadSubsidyHelpers() {
  const sandbox = { window: {}, console };
  vm.createContext(sandbox);
  const start = helpers.indexOf('function hoistPaysOf');
  assert.ok(start >= 0);
  const end = helpers.indexOf('window.hoistUsesOf = hoistUsesOf;', start);
  assert.ok(end > start);
  vm.runInContext(helpers.slice(start, end) + '\n;window.hoistUsesOf = hoistUsesOf;', sandbox);
  return sandbox.window;
}

test('tm-helpers subsidyOf strips combined tmSubsidy before hoist add', () => {
  const { subsidyOf, hoistPaysOf } = loadSubsidyHelpers();
  const j = {
    tmSubsidyFare: 9.79,
    tmSubsidy: 20.79,
    tmCouncilPays: 20.79,
    tmSubsidyHoist: 11,
    hoistTotal: 11,
  };
  assert.equal(subsidyOf(j), 9.79);
  assert.equal(hoistPaysOf(j), 11);
  assert.equal(+(subsidyOf(j) + hoistPaysOf(j)).toFixed(2), 20.79);
});

test('Home.aspx claim uses subsidyOf/hoistPaysOf and meter+hoist label', () => {
  assert.match(home, /Council Claim \(meter \+ hoist\) This Month/);
  assert.match(home, /typeof subsidyOf === 'function'/);
  assert.match(home, /hoistPaysOf\(j\)/);
  assert.match(home, /tmClaim \+= meterSub \+ hoistFee/);
  assert.doesNotMatch(home, /tmCouncilAmount\|\|j\.tmSubsidy\|\|j\.tmSubsidyFare/);
});

test('Home.aspx flagged KPI requires councilId', () => {
  assert.match(home, /status=flagged · with councilId/);
  assert.match(home, /st\.councilId\|\|st\.tmCouncilId/);
  assert.match(home, /if\(!String\(st\.councilId/);
});

test('applyAnomalyScan refuses to flag without councilId and stamps it when present', () => {
  assert.match(anomalySrc, /export function resolveTripCouncilId/);
  assert.match(anomalySrc, /Never create\/refresh flagged rows without councilId/);
  assert.match(anomalySrc, /if \(!councilId\) continue;/);
  assert.match(anomalySrc, /councilId,\s*\n\s*\}/);
  const flagBlockStart = anomalySrc.indexOf('status: \'flagged\'');
  assert.ok(flagBlockStart > 0);
  const nearby = anomalySrc.slice(flagBlockStart - 200, flagBlockStart + 120);
  assert.match(nearby, /councilId/);
  assert.match(nearby, /if \(!councilId\) continue/);
});
