import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const libSrc = readFileSync(join(root, 'src/lib/tmCleanScan.ts'), 'utf8');
const routeSrc = readFileSync(join(root, 'src/routes/tmCleanScan.ts'), 'utf8');
const appSrc = readFileSync(join(root, 'src/app.ts'), 'utf8');

/** Inline copy of shouldAutoApproveCleanTrip gate (matches tmAnomaly). */
function tripWasEverFlagged(trip) {
  const flaggedAt = trip?.flaggedAt;
  if (flaggedAt != null && flaggedAt !== '' && Number(flaggedAt) !== 0) return true;
  const events = trip?.events;
  if (events && typeof events === 'object') {
    for (const ev of Object.values(events)) {
      if (!ev || typeof ev !== 'object') continue;
      const type = String(ev.type || '').trim().toLowerCase();
      const to = String(ev.toStatus || '').trim().toLowerCase();
      if (type === 'flagged' || to === 'flagged') return true;
    }
  }
  return false;
}
function tripWasEverEdited(trip) {
  const editedAt = trip?.editedAt;
  if (editedAt != null && editedAt !== '' && Number(editedAt) !== 0) return true;
  const events = trip?.events;
  if (events && typeof events === 'object') {
    for (const ev of Object.values(events)) {
      if (!ev || typeof ev !== 'object') continue;
      const type = String(ev.type || '').trim().toLowerCase();
      if (type === 'owner_edited' || type === 'council_edited' || type === 'sa_edited') return true;
    }
  }
  return false;
}
function shouldAutoApproveCleanTrip(trip) {
  if (!trip || typeof trip !== 'object') return false;
  if (String(trip.status || '').trim().toLowerCase() !== 'submitted') return false;
  if (tripWasEverFlagged(trip)) return false;
  if (tripWasEverEdited(trip)) return false;
  const reasons = Array.isArray(trip.flagReasons)
    ? trip.flagReasons.map((r) => String(r || '').trim()).filter(Boolean)
    : [];
  if (reasons.length) return false;
  if (String(trip.anomalyDetail || '').trim()) return false;
  return true;
}
function planCleanAutoApprovals(trips) {
  const list = Array.isArray(trips) ? trips : [];
  const candidates = [];
  let skipped = 0;
  for (const t of list) {
    if (!shouldAutoApproveCleanTrip(t)) {
      skipped++;
      continue;
    }
    const cid = String(t._cid || '').trim();
    const rawKey = String(t._rawKey || '').trim();
    const councilId = String(t.councilId || '').trim();
    if (!cid || !rawKey || !councilId) {
      skipped++;
      continue;
    }
    candidates.push({ cid, rawKey, councilId });
  }
  return { candidates, skipped, scanned: list.length };
}

test('planCleanAutoApprovals picks only submitted clean never-flagged', () => {
  const plan = planCleanAutoApprovals([
    {
      _cid: '860869',
      _rawKey: 'a',
      councilId: 'cncl_a',
      status: 'submitted',
      flagReasons: [],
    },
    {
      _cid: '860869',
      _rawKey: 'b',
      councilId: 'cncl_a',
      status: 'submitted',
      flagReasons: [],
      flaggedAt: 99,
    },
    {
      _cid: '860869',
      _rawKey: 'c',
      councilId: 'cncl_a',
      status: 'pending',
      flagReasons: [],
    },
    {
      _cid: '860869',
      _rawKey: 'd',
      councilId: 'cncl_a',
      status: 'submitted',
      flagReasons: [],
      events: { e1: { type: 'owner_edited' } },
    },
  ]);
  assert.equal(plan.candidates.length, 1);
  assert.equal(plan.candidates[0].rawKey, 'a');
  assert.equal(plan.scanned, 4);
});

test('SA clean-scan lib + route wiring', () => {
  assert.match(libSrc, /export function planCleanAutoApprovals/);
  assert.match(libSrc, /shouldAutoApproveCleanTrip/);
  assert.match(routeSrc, /planCleanAutoApprovals/);
  assert.match(routeSrc, /planApprovedTripBatchUpsert/);
  assert.match(routeSrc, /\/api\/sa\/tm-clean-scan/);
  assert.match(routeSrc, /applyAnomalyScan/);
  assert.match(appSrc, /tmCleanScan/);
});
