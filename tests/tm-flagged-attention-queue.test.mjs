/**
 * Fix pack: TM-Flagged date fallback + attention-queue clarity + Home KPI flagged count.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const flaggedSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Flagged.aspx'),
  'utf8',
);
const homeSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/Home.aspx'),
  'utf8',
);

test('TM-Flagged Date + From/To use tripDisplayTimeRaw (not startTime alone)', () => {
  assert.match(flaggedSrc, /tripDisplayTimeRaw\(t\)/);
  assert.match(flaggedSrc, /var filterDt = \(typeof tripDisplayTimeRaw/);
  assert.match(flaggedSrc, /var dtRaw = \(typeof tripDisplayTimeRaw/);
  assert.match(flaggedSrc, /completedAt: j\.completedAt/);
  // Must not filter dates only on startTime
  assert.doesNotMatch(
    flaggedSrc.slice(flaggedSrc.indexOf('function renderFL'), flaggedSrc.indexOf('function openFLEdit') || flaggedSrc.length),
    /var day = .*t\.startTime(?![\s\S]*tripDisplayTimeRaw)/,
  );
});

test('TM-Flagged is labelled Attention queue with stage breakdown', () => {
  assert.match(flaggedSrc, /Attention queue/);
  assert.match(flaggedSrc, /Wider than owner\/council/);
  assert.match(flaggedSrc, /revision_needed/);
  assert.match(flaggedSrc, /option value="revision_needed"/);
  assert.match(flaggedSrc, /flaggedStatuses = \['flagged','company_approved','rejected','revision_needed'\]/);
  assert.match(flaggedSrc, /stageBits\.revision_needed/);
});

test('Home KPI counts status=flagged (not company_approved)', () => {
  assert.match(homeSrc, /kpi-tm-flagged/);
  assert.match(homeSrc, /Flagged Trips/);
  assert.match(homeSrc, /status=flagged/);
  assert.match(homeSrc, /String\(st\.status\|\|''\)\.toLowerCase\(\)==='flagged'/);
  // Count loop: increment only on flagged — must not check company_approved for the tally
  const loopStart = homeSrc.indexOf('var flaggedCount = 0;');
  assert.ok(loopStart >= 0);
  const loopEnd = homeSrc.indexOf("getElementById('kpi-tm-flagged')", loopStart);
  const loop = homeSrc.slice(loopStart, loopEnd);
  assert.match(loop, /==='flagged'/);
  assert.doesNotMatch(loop, /company_approved/);
});
