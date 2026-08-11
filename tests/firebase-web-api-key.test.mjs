/**
 * Council portal auth helpers must work even when FIREBASE_WEB_API_KEY env is unset
 * (Replit often only has FIREBASE_DB_SECRET). Code falls back to the bookawaka2026 key.
 * SA portal Auth is bookawaka2026-564e1 (same project as owner/council/app).
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = readFileSync(join(root, 'src/firebase.ts'), 'utf8');
const cleanScan = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Clean-Scan.aspx'),
  'utf8',
);
const login = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/SA-Login.aspx'),
  'utf8',
);

test('firebase.ts defines bookawaka2026 web API key constant', () => {
  assert.match(src, /export const FIREBASE_WEB_API_KEY = 'AIzaSyDIVSI/);
  assert.match(src, /bookawaka2026/);
});

test('firebase.ts SA portal verify key aliases bookawaka2026', () => {
  assert.match(src, /export const SA_PORTAL_WEB_API_KEY = FIREBASE_WEB_API_KEY/);
  assert.match(src, /resolveIdTokenVerifyKeys/);
  assert.match(src, /authRestPostWithKey\('lookup'/);
});

test('fbAuthCreate/SignIn/SendReset use resolveWebApiKey fallback', () => {
  assert.match(src, /function resolveWebApiKey/);
  assert.match(src, /process\.env\.FIREBASE_WEB_API_KEY \|\| FIREBASE_WEB_API_KEY/);
  assert.match(src, /export function fbAuthCreate/);
  const createBody = src.slice(src.indexOf('export function fbAuthCreate'));
  const createFn = createBody.slice(0, createBody.indexOf('export function fbAuthSignIn'));
  assert.match(createFn, /resolveWebApiKey\(\)/);
  assert.doesNotMatch(
    createFn,
    /const key = process\.env\.FIREBASE_WEB_API_KEY;\s*\n\s*if \(!key\)/,
  );
});

test('SA-Login and Clean Scan use bookawaka2026 Auth', () => {
  assert.match(login, /projectId:"bookawaka2026-564e1"/);
  assert.match(login, /bookawaka2026-564e1\.firebaseapp\.com/);
  assert.doesNotMatch(login, /taxilatest/);
  assert.match(cleanScan, /projectId:"bookawaka2026-564e1"/);
  assert.match(cleanScan, /getIdToken\(true\)/);
  assert.match(cleanScan, /Authorization':'Bearer '/);
  assert.doesNotMatch(cleanScan, /taxilatest/);
});
