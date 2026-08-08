/**
 * Soft-archive helpers + council/SA wiring guards.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const archiveSrc = readFileSync(join(root, 'src/lib/tmArchive.ts'), 'utf8');
const anomalySrc = readFileSync(join(root, 'src/lib/tmAnomaly.ts'), 'utf8');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const tmTripsSrc = readFileSync(
  join(root, 'taxitime.co.nz/superadmin360taxi/TM-Trips.aspx'),
  'utf8',
);

function isArchivedStatus(status) {
  return String(status || '').trim().toLowerCase() === 'archived';
}

function archivePatch(fromStatus, by, note) {
  const prior = String(fromStatus || 'submitted').trim().toLowerCase() || 'submitted';
  const safeFrom = prior === 'archived' ? 'submitted' : prior;
  const patch = {
    status: 'archived',
    archivedAt: Date.now(),
    archivedBy: by || 'unknown',
    archivedFromStatus: safeFrom,
  };
  const n = note != null ? String(note).trim() : '';
  patch.archiveNote = n || null;
  return patch;
}

function restorePatch(st) {
  const from = String(st?.archivedFromStatus || 'submitted').trim().toLowerCase() || 'submitted';
  const restoreTo = from === 'archived' ? 'submitted' : from;
  return {
    status: restoreTo,
    archivedAt: null,
    archivedBy: null,
    archivedFromStatus: null,
    archiveNote: null,
    restoredAt: Date.now(),
  };
}

test('archivePatch stores prior status and soft-deletes', () => {
  const p = archivePatch('flagged', 'Council Tester', 'dup card');
  assert.equal(p.status, 'archived');
  assert.equal(p.archivedFromStatus, 'flagged');
  assert.equal(p.archivedBy, 'Council Tester');
  assert.equal(p.archiveNote, 'dup card');
  assert.ok(p.archivedAt);
});

test('restorePatch returns to archivedFromStatus', () => {
  const p = restorePatch({ archivedFromStatus: 'submitted' });
  assert.equal(p.status, 'submitted');
  assert.equal(p.archivedAt, null);
  assert.equal(p.archivedFromStatus, null);
  assert.ok(p.restoredAt);
});

test('isArchivedStatus helper', () => {
  assert.equal(isArchivedStatus('archived'), true);
  assert.equal(isArchivedStatus('submitted'), false);
});

test('tmArchive source exports helpers', () => {
  assert.match(archiveSrc, /export function isArchivedStatus/);
  assert.match(archiveSrc, /export function archivePatch/);
  assert.match(archiveSrc, /export function restorePatch/);
  assert.match(archiveSrc, /STATUS_ARCHIVED/);
});

test('anomaly scan skips archived', () => {
  assert.match(anomalySrc, /status === 'archived'/);
});

test('council portal archived tab + bulk archive/restore APIs', () => {
  assert.match(councilSrc, /\/council-portal\/archived/);
  assert.match(councilSrc, /redirectLegacyTripPage\(req, res, 'archived'\)/);
  assert.match(councilSrc, /status=archived|status === 'archived'/);
  assert.match(councilSrc, /\/api\/council-archive/);
  assert.match(councilSrc, /\/api\/council-bulk-archive/);
  assert.match(councilSrc, /\/api\/council-restore/);
  assert.match(councilSrc, /\/api\/council-bulk-restore/);
  assert.match(councilSrc, /includeArchived/);
  assert.match(councilSrc, /Archive selected/);
  assert.match(councilSrc, /Restore selected/);
  assert.match(councilSrc, /archivePatch/);
  assert.match(councilSrc, /restorePatch/);
  assert.match(councilSrc, /isArchivedStatus/);
});

test('SA TM-Trips has archive/restore individual and bulk', () => {
  assert.match(tmTripsSrc, /archived/);
  assert.match(tmTripsSrc, /archiveTT|Archive selected/);
  assert.match(tmTripsSrc, /restoreTT|Restore selected/);
  assert.match(tmTripsSrc, /archiveAllMatchingTT/);
  assert.match(tmTripsSrc, /ttArchivePatch/);
});
