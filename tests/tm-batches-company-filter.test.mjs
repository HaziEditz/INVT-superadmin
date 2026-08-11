import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { filterClaimBatches } from '../src/lib/tmBatchPaid.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');

test('filterClaimBatches filters by company _cid', () => {
  const batches = [
    { _cid: '860869', _ym: '2026-08', status: 'submitted' },
    { _cid: '860870', _ym: '2026-08', status: 'submitted' },
    { _cid: '860869', _ym: '2026-07', status: 'paid' },
  ];
  const only869 = filterClaimBatches(batches, { status: 'all', company: '860869' });
  assert.equal(only869.length, 2);
  assert.ok(only869.every((b) => b._cid === '860869'));
  const submitted869 = filterClaimBatches(batches, {
    status: 'submitted',
    company: '860869',
    from: '2026-08-01',
    to: '2026-08-31',
  });
  assert.equal(submitted869.length, 1);
  assert.equal(submitted869[0]._ym, '2026-08');
});

test('council Claim Batches UI has Status/From/To/Company filter', () => {
  assert.match(councilSrc, /name="company"/);
  assert.match(councilSrc, /filterCompany/);
  assert.match(councilSrc, /Status\/From\/To|Company matches Trips tab/);
});
