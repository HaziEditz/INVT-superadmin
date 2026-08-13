/**
 * Multi-cycle return→resubmit visibility: trip never vanishes from All;
 * correct specialty tab at every step.
 */
import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  isAwaitingCouncilRecheck,
  isAwaitingCompanyFix,
  AWAITING_COMPANY_FIX_LABEL,
} from '../src/lib/tmLifecycleMarkers.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const councilSrc = readFileSync(join(root, 'src/routes/council.ts'), 'utf8');
const unifiedSrc = readFileSync(join(root, 'src/lib/tmUnifiedTrips.ts'), 'utf8');

// Mirror tmUnifiedTrips tab membership (same rules as source — avoids ESM path resolution on .ts graph).
function isArchivedStatus(status) {
  return String(status || '').trim().toLowerCase() === 'archived';
}
const PENDING_TAB_STATUSES = new Set(['submitted', 'pending', 'company_approved']);
function tripMatchesUnifiedStatus(trip, status) {
  if (!trip) return false;
  const st = String(trip.status || '').trim().toLowerCase();
  if (status === 'all') return !isArchivedStatus(st);
  if (status === 'pending') {
    return PENDING_TAB_STATUSES.has(st) && !isAwaitingCouncilRecheck(trip);
  }
  if (status === 'revision') return isAwaitingCouncilRecheck(trip);
  if (status === 'flagged') return st === 'flagged';
  if (status === 'archived') return isArchivedStatus(st);
  if (status === 'approved') return st === 'approved';
  if (status === 'paid') return st === 'paid';
  if (status === 'rejected') return st === 'rejected';
  return true;
}
function filterTripsUnified(trips, opts = {}) {
  const status = String(opts.status || 'all');
  return (trips || []).filter((t) => tripMatchesUnifiedStatus(t, status));
}
function countTripsByUnifiedStatus(trips) {
  const out = {
    all: 0,
    pending: 0,
    revision: 0,
    flagged: 0,
    archived: 0,
    approved: 0,
    paid: 0,
    rejected: 0,
  };
  for (const t of trips || []) {
    const st = String(t?.status || '').trim().toLowerCase();
    if (isArchivedStatus(st)) out.archived++;
    else {
      out.all++;
      if (isAwaitingCouncilRecheck(t)) out.revision++;
      else if (PENDING_TAB_STATUSES.has(st)) out.pending++;
      else if (st === 'flagged') out.flagged++;
      else if (st === 'approved') out.approved++;
      else if (st === 'paid') out.paid++;
      else if (st === 'rejected') out.rejected++;
    }
  }
  return out;
}

function tabsFor(trip) {
  return {
    all: tripMatchesUnifiedStatus(trip, 'all'),
    pending: tripMatchesUnifiedStatus(trip, 'pending'),
    revision: tripMatchesUnifiedStatus(trip, 'revision'),
    flagged: tripMatchesUnifiedStatus(trip, 'flagged'),
    approved: tripMatchesUnifiedStatus(trip, 'approved'),
  };
}

function assertFindable(trip, step) {
  const t = tabsFor(trip);
  assert.equal(t.all, true, `${step}: must be visible under All`);
  return { t };
}

test('source wires isAwaitingCouncilRecheck into Pending/Revision filters', () => {
  assert.match(unifiedSrc, /isAwaitingCouncilRecheck/);
  assert.match(unifiedSrc, /status === 'revision'\) return isAwaitingCouncilRecheck/);
  assert.match(unifiedSrc, /!isAwaitingCouncilRecheck\(trip\)/);
  assert.match(unifiedSrc, /revision_needed \(awaiting company\) is NOT here/);
});

test('awaiting-company vs recheck helpers', () => {
  assert.equal(isAwaitingCompanyFix({ status: 'revision_needed' }), true);
  assert.equal(isAwaitingCompanyFix({ status: 'submitted' }), false);
  assert.equal(isAwaitingCouncilRecheck({ status: 'submitted', resubmittedAt: 1 }), true);
  assert.equal(isAwaitingCouncilRecheck({ status: 'submitted' }), false);
  assert.equal(isAwaitingCouncilRecheck({ status: 'revision_needed', resubmittedAt: 1 }), false);
  assert.equal(AWAITING_COMPANY_FIX_LABEL, 'Awaiting company fix');
});

test('multi-cycle return→resubmit: always findable; correct tab each step', () => {
  const id = 'CYCLE-TRIP-1';
  let trip = { status: 'flagged', resubmittedAt: null, _rawKey: id };

  {
    const { t } = assertFindable(trip, 'flagged');
    assert.equal(t.flagged, true);
    assert.equal(t.revision, false);
    assert.equal(t.pending, false);
  }

  const CYCLES = 5;
  for (let n = 1; n <= CYCLES; n++) {
    trip = { ...trip, status: 'revision_needed', resubmittedAt: null };
    {
      const { t } = assertFindable(trip, `cycle${n}-returned`);
      assert.equal(t.revision, false, `cycle${n}: returned must NOT be on Revision`);
      assert.equal(t.pending, false);
      assert.equal(t.flagged, false);
      assert.equal(isAwaitingCompanyFix(trip), true);
    }

    trip = { ...trip, status: 'submitted', resubmittedAt: 1_000_000 + n };
    {
      const { t } = assertFindable(trip, `cycle${n}-resubmitted`);
      assert.equal(t.revision, true, `cycle${n}: resubmit must be on Revision`);
      assert.equal(t.pending, false, `cycle${n}: resubmit must NOT be on Pending`);
      assert.equal(isAwaitingCouncilRecheck(trip), true);
    }
  }

  trip = { ...trip, status: 'approved' };
  {
    const { t } = assertFindable(trip, 'approved');
    assert.equal(t.approved, true);
    assert.equal(t.revision, false);
  }

  const pool = [
    { status: 'submitted', resubmittedAt: null, _rawKey: 'new' },
    { status: 'revision_needed', resubmittedAt: null, _rawKey: 'waiting' },
    { status: 'submitted', resubmittedAt: 99, _rawKey: id },
    { status: 'flagged', resubmittedAt: null, _rawKey: 'flag' },
    { status: 'archived', resubmittedAt: null, _rawKey: 'arch' },
  ];
  const inAll = filterTripsUnified(pool, { status: 'all' }).map((x) => x._rawKey);
  assert.ok(inAll.includes(id));
  assert.ok(inAll.includes('waiting'));
  assert.ok(!inAll.includes('arch'));
  assert.deepEqual(
    filterTripsUnified(pool, { status: 'revision' }).map((x) => x._rawKey),
    [id],
  );
  assert.deepEqual(
    filterTripsUnified(pool, { status: 'pending' }).map((x) => x._rawKey),
    ['new'],
  );

  const counts = countTripsByUnifiedStatus(pool);
  assert.equal(counts.revision, 1);
  assert.equal(counts.pending, 1);
  assert.equal(counts.flagged, 1);
  assert.equal(counts.archived, 1);
  assert.equal(counts.all, 4);
  assert.equal(counts.pending + counts.revision + counts.flagged + 1, counts.all);
});

test('council badge uses Awaiting company fix; return clears resubmittedAt', () => {
  assert.match(councilSrc, /AWAITING_COMPANY_FIX_LABEL/);
  assert.match(councilSrc, /revision_needed:\s*`<span class="cp-bdg-a">\$\{AWAITING_COMPANY_FIX_LABEL\}<\/span>`/);
  assert.match(councilSrc, /resubmittedAt: null/);
  assert.match(councilSrc, /resubmittedBy: null/);
  assert.equal(AWAITING_COMPANY_FIX_LABEL, 'Awaiting company fix');
});

test('Revision tab trips are submitted (actionable) — Approve/Return available', () => {
  assert.match(councilSrc, /_ACTIONABLE = \{submitted:1/);
  assert.equal(isAwaitingCouncilRecheck({ status: 'submitted', resubmittedAt: 1 }), true);
  assert.equal(isAwaitingCouncilRecheck({ status: 'revision_needed' }), false);
});
