/**
 * Phase A: /api/fb must require Bearer + isSuperAdmin (same model as sa-wallet).
 * Client helpers must send Authorization; no raw unauthenticated /api/fb fetches.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const saAdmin = readFileSync(join(root, 'src/routes/sa-admin.ts'), 'utf8');
const saAuth = readFileSync(join(root, 'src/lib/saAuth.ts'), 'utf8');
const helpers = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/assets/js/tm-helpers.js'),
  'utf8',
);
const fdMulti = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/assets/js/fd-multi-company.js'),
  'utf8',
);

test('saAuth exports requireSa + requireFirebaseUser with Bearer verify + isSuperAdmin', () => {
  assert.match(saAuth, /export async function requireSa/);
  assert.match(saAuth, /export async function requireFirebaseUser/);
  assert.match(saAuth, /verifyFirebaseToken/);
  assert.match(saAuth, /isSuperAdmin/);
  assert.match(saAuth, /Missing Authorization: Bearer/);
  assert.match(saAuth, /Not a super-admin/);
});

test('GET and POST /api/fb call requireSa before fbRead/fbWrite', () => {
  const getIdx = saAdmin.indexOf("router.get('/api/fb'");
  const postIdx = saAdmin.indexOf("router.post('/api/fb'");
  assert.ok(getIdx >= 0, 'GET /api/fb route exists');
  assert.ok(postIdx >= 0, 'POST /api/fb route exists');

  const getBlock = saAdmin.slice(getIdx, postIdx > getIdx ? postIdx : getIdx + 2500);
  const postBlock = saAdmin.slice(postIdx, postIdx + 2500);
  assert.match(getBlock, /await requireSa\(req\)/);
  assert.match(postBlock, /await requireSa\(req\)/);
  assert.match(getBlock, /if \(!auth\.ok\)/);
  assert.match(postBlock, /if \(!auth\.ok\)/);

  const getAuth = getBlock.indexOf('await requireSa');
  const getRead = getBlock.indexOf('fbRead(');
  const postAuth = postBlock.indexOf('await requireSa');
  const postWrite = postBlock.indexOf('fbWrite(');
  assert.ok(getAuth >= 0 && getRead > getAuth, 'GET requireSa before fbRead');
  assert.ok(postAuth >= 0 && postWrite > postAuth, 'POST requireSa before fbWrite');
});

test('GET /api/sa/me exists for SA bootstrap without reading blocklisted superAdmins via /api/fb', () => {
  assert.match(saAdmin, /router\.get\('\/api\/sa\/me'/);
  assert.match(saAdmin, /requireFirebaseUser\(req\)/);
  assert.match(saAdmin, /isSA/);
});

test('tm-helpers _fbGet/_fbPost send Authorization Bearer via getIdToken', () => {
  assert.match(helpers, /function _fbAuthHeaders/);
  assert.match(helpers, /getIdToken/);
  assert.match(helpers, /Authorization['"]?\s*:\s*['"]Bearer /);
  assert.match(helpers, /function _fbGet/);
  assert.match(helpers, /function _fbPost/);
  // Must not document unauthenticated proxy anymore
  assert.doesNotMatch(helpers, /No client-side Firebase auth needed/);
  // Bootstrap uses /api/sa/me, not blocklisted superAdmins via _fbGet
  assert.match(helpers, /\/api\/sa\/me/);
  assert.doesNotMatch(helpers, /_fbGet\('superAdmins\//);
});

test('fd-multi-company uses _fbGet (Bearer) not raw fetch(/api/fb)', () => {
  assert.match(fdMulti, /_fbGet\('superClients'\)/);
  assert.doesNotMatch(fdMulti, /fetch\(['"]\/api\/fb/);
});

test('no aspx/js under SA portal uses raw unauthenticated fetch(/api/fb)', () => {
  const base = join(root, 'taxitime.co.nz/superadmin360taxi');
  const offenders = [];
  function walk(dir) {
    for (const name of readdirSync(dir, { withFileTypes: true })) {
      const p = join(dir, name.name);
      if (name.isDirectory()) {
        if (name.name === 'bower_components' || name.name === 'node_modules') continue;
        walk(p);
        continue;
      }
      if (!/\.(aspx|js|html)$/i.test(name.name)) continue;
      if (name.name === 'tm-helpers.js') continue; // allowed to call /api/fb with Bearer
      const src = readFileSync(p, 'utf8');
      if (/fetch\s*\(\s*['"`]\/api\/fb/.test(src)) offenders.push(p);
    }
  }
  walk(base);
  assert.deepEqual(offenders, [], 'raw /api/fb fetches: ' + offenders.join(', '));
});

test('pages that load fd-multi-company also load tm-helpers first', () => {
  const pages = [
    'FD-Orders.aspx',
    'FD-Payouts.aspx',
    'FD-Reports.aspx',
    'FD-Restaurants.aspx',
    'FD-Commission.aspx',
    'FR-Orders.aspx',
    'FR-Payouts.aspx',
    'FR-Reports.aspx',
    'FR-Commission.aspx',
  ];
  for (const page of pages) {
    const src = readFileSync(join(root, 'taxitime.co.nz/superadmin360taxi', page), 'utf8');
    const helpersIdx = src.indexOf('assets/js/tm-helpers.js');
    const multiIdx = src.indexOf('assets/js/fd-multi-company.js');
    assert.ok(helpersIdx >= 0, page + ' loads tm-helpers');
    assert.ok(multiIdx >= 0, page + ' loads fd-multi-company');
    assert.ok(helpersIdx < multiIdx, page + ' loads tm-helpers before fd-multi-company');
  }
});
