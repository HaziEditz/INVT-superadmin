/**
 * Council emergency edit vs Return-to-company clarity.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { formatEventLabel, buildTripEvent } from '../src/lib/tmTripEvents.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');

test('council-trip-edit requires correctionNote server-side', () => {
  const start = councilSrc.indexOf("router.post('/api/council-trip-edit'");
  assert.ok(start >= 0);
  const end = councilSrc.indexOf("router.post('/api/council-tariff-save'", start);
  const chunk = councilSrc.slice(start, end > start ? end : start + 4500);
  assert.match(chunk, /correctionNote/);
  assert.match(chunk, /Council correction reason is required/);
  assert.match(chunk, /note: correctionNote/);
});

test('Edit panel is framed as emergency override, not equal to Return', () => {
  assert.match(councilSrc, /Emergency correction — council edits fields directly \(exception\)/);
  assert.match(councilSrc, /Prefer Return to company/);
  assert.match(councilSrc, /Council correction reason/);
  assert.match(councilSrc, /Save emergency correction/);
  assert.match(councilSrc, /Normal path — return for company to fix/);
  // Collapsed by default — no auto-open on revision_needed
  assert.doesNotMatch(councilSrc, /revision_needed\?'open'/);
  // Old equally-weighted primary label gone from edit summary
  assert.doesNotMatch(councilSrc, /<summary[^>]*>Edit all fields<\/summary>/);
});

test('Flagged and Revision both get edit panel (non-archived); archived excluded', () => {
  assert.match(councilSrc, /if\(d\.status==='archived'\) return '';/);
  // Panel is status-agnostic except archived — same for flagged + revision_needed
  assert.match(councilSrc, /function buildEditPanel\(d\)/);
  assert.match(councilSrc, /cpTripDetailBehaviorScript\(true\)/);
});

test('council_edited history labels include Council note', () => {
  const ev = buildTripEvent('council_edited', {
    by: 'ICC',
    byRole: 'council',
    note: 'Fixed hoist count for claim',
  });
  assert.match(formatEventLabel(ev), /Council: Fixed hoist count for claim/);
});
