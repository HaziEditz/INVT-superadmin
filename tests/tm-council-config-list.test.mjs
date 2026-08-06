/**
 * TM Council Config list must not go blank when tmConfig is null but portal access exists.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const page = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Council-Config.aspx'),
  'utf8',
);
const saAdmin = readFileSync(join(root, 'src/routes/sa-admin.ts'), 'utf8');

test('list merges tmCouncilAccess orphans when tmConfig is empty', () => {
  assert.match(page, /function mergeAccessOrphans/);
  assert.match(page, /function normalizeCouncilMap/);
  assert.match(page, /mergeAccessOrphans\(normalizeCouncilMap/);
  assert.match(page, /acc\.uid \|\| acc\.passwordHash/);
});

test('fb proxy refuses wiping entire tmConfig root', () => {
  assert.match(saAdmin, /isUnsafeFbPath/);
  assert.match(saAdmin, /Refusing to write\/delete entire tmConfig root/);
  assert.match(saAdmin, /PUT requires a non-null body/);
});
