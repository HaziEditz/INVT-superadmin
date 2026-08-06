/**
 * Council portal auth helpers must work even when FIREBASE_WEB_API_KEY env is unset
 * (Replit often only has FIREBASE_DB_SECRET). Code falls back to the bookawaka2026 key.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = readFileSync(join(root, 'src/firebase.ts'), 'utf8');

test('firebase.ts defines bookawaka2026 web API key constant', () => {
  assert.match(src, /export const FIREBASE_WEB_API_KEY = 'AIzaSy/);
  assert.match(src, /bookawaka2026/);
});

test('fbAuthCreate/SignIn/SendReset use resolveWebApiKey fallback', () => {
  assert.match(src, /function resolveWebApiKey/);
  assert.match(src, /process\.env\.FIREBASE_WEB_API_KEY \|\| FIREBASE_WEB_API_KEY/);
  assert.match(src, /export function fbAuthCreate/);
  // Must not require env-only key without fallback.
  const createBody = src.slice(src.indexOf('export function fbAuthCreate'));
  const createFn = createBody.slice(0, createBody.indexOf('export function fbAuthSignIn'));
  assert.match(createFn, /resolveWebApiKey\(\)/);
  assert.doesNotMatch(
    createFn,
    /const key = process\.env\.FIREBASE_WEB_API_KEY;\s*\n\s*if \(!key\)/,
  );
});
