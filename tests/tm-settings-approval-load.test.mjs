/**
 * Company TM Approval must not freeze on Loading after legacy tariff table removal.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const page = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Settings.aspx'),
  'utf8',
);

test('loadAll does not write removed tariff-tb (that froze Loading…)', () => {
  assert.match(page, /function loadAll/);
  assert.match(page, /do not write to it/);
  assert.doesNotMatch(
    page,
    /function loadAll\([\s\S]*?getElementById\('tariff-tb'\)\.innerHTML/,
  );
  assert.match(page, /adminRead\('superClients'\)/);
  assert.match(page, /adminRead\('tmConfig'\)/);
  assert.match(page, /adminRead\('tmCompanyAccess'\)/);
  assert.match(page, /function asObjectMap/);
  assert.match(page, /renderApproval\(\)/);
});

test('approval UI still present for Approve/Revoke', () => {
  assert.match(page, /Company TM Approval/);
  assert.match(page, /onclick="setAccess/);
  assert.match(page, /Filter by Council/);
});
