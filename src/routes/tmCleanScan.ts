/**
 * SA clean-trip scan job — walks all companies/trips, anomaly scan + never-flagged gate,
 * approve + claim-batch upsert. Council Trips UI unchanged.
 */
import { Router, Request, Response } from 'express';
import { fbRead, fbWrite, isSuperAdmin, verifyFirebaseToken } from '../firebase';
import {
  applyAnomalyScan,
  shouldAutoApproveCleanTrip,
  type AnomalyStatusPatch,
} from '../lib/tmAnomaly';
import { planCleanAutoApprovals, summarizeCleanScanResult } from '../lib/tmCleanScan';
import { planApprovedTripBatchUpsert, type CouncilTripLike } from '../lib/tmBatchCreate';
import {
  buildTripPlatformFeeStamp,
  companyFeeOverrideFromTmConfig,
  normalizePlatformTmFeeDefaults,
  resolvePlatformTmFees,
} from '../lib/tmPlatformFees';
import { buildTripEvent, newEventKey } from '../lib/tmTripEvents';

const router = Router();

async function requireSa(req: Request): Promise<{ ok: true; uid: string } | { ok: false; status: number; error: string }> {
  const auth = (req.headers['authorization'] as string) || '';
  const m = /^Bearer\s+(.+)$/i.exec(auth);
  if (!m) return { ok: false, status: 401, error: 'Missing Authorization: Bearer <Firebase ID token>' };
  let uid: string | null = null;
  try {
    uid = await verifyFirebaseToken(m[1].trim());
  } catch (e: any) {
    return { ok: false, status: 401, error: 'Token verification failed: ' + (e?.message || 'unknown') };
  }
  if (!uid) return { ok: false, status: 401, error: 'Invalid or expired Firebase ID token' };
  const isSA: boolean = await new Promise((resolve) =>
    isSuperAdmin(uid as string, (_e: any, ok: boolean) => resolve(!!ok)),
  );
  if (!isSA) return { ok: false, status: 403, error: 'Not a super-admin' };
  return { ok: true, uid };
}

function normalizeTmTripEconomics(job: any): Record<string, number> {
  const hoist = Number(job?.tmSubsidyHoist ?? job?.hoistTotal ?? job?.hoistCost ?? 0) || 0;
  const meterFare = Number(job?.tmMeterFare ?? job?.meterFare ?? 0) || 0;
  const legacyFare = Number(job?.fare ?? job?.totalFare ?? job?.tmTotalFare ?? 0) || 0;
  const fare = meterFare || Math.max(0, legacyFare - (job?.hoistTotal || job?.tmSubsidyHoist ? hoist : 0));
  const combined = Number(job?.tmCouncilPays ?? job?.councilPays ?? job?.tmSubsidy ?? 0) || 0;
  const subsidyFare =
    job?.tmSubsidyFare != null && job?.tmSubsidyFare !== ''
      ? Number(job.tmSubsidyFare) || 0
      : Math.max(0, combined - hoist);
  const pax =
    Number(job?.tmPassengerPays ?? job?.passengerPays ?? Math.max(0, fare - subsidyFare)) || 0;
  return {
    fare: +fare.toFixed(2),
    tmSubsidyFare: +subsidyFare.toFixed(2),
    tmSubsidyHoist: +hoist.toFixed(2),
    tmSubsidy: +subsidyFare.toFixed(2),
    tmPassengerPays: +pax.toFixed(2),
  };
}

function loadFlatTrips(cb: (trips: any[]) => void): void {
  fbRead('tmTripStatus', (_e: any, allStatus: any) => {
    if (!allStatus || typeof allStatus !== 'object') return cb([]);
    const cids = Object.keys(allStatus);
    if (!cids.length) return cb([]);
    let pending = cids.length;
    const jobsMap: Record<string, any> = {};
    const finish = () => {
      if (--pending > 0) return;
      const out: any[] = [];
      cids.forEach((cid) => {
        const statusMap = allStatus[cid] || {};
        const jobs = jobsMap[cid] || {};
        Object.entries(statusMap).forEach(([rawKey, st]: [string, any]) => {
          if (!st || typeof st !== 'object') return;
          const job = jobs[rawKey] || {};
          const econ = normalizeTmTripEconomics(job);
          out.push({
            _cid: cid,
            _rawKey: rawKey,
            ...job,
            ...econ,
            status: st.status || 'pending',
            councilId: st.councilId,
            submittedAt: st.submittedAt,
            approvedAt: st.approvedAt,
            flagReasons: Array.isArray(st.flagReasons) ? st.flagReasons : [],
            anomalyDetail: st.anomalyDetail || null,
            anomalyScannedAt: st.anomalyScannedAt || null,
            flaggedAt: st.flaggedAt || null,
            events: st.events || null,
            batchId: st.batchId,
            platformFeeStampAt: st.platformFeeStampAt,
            editedAt: st.editedAt || null,
          });
        });
      });
      cb(out);
    };
    cids.forEach((cid) => {
      fbRead('completedJobs/' + cid, (_e2: any, jobs: any) => {
        jobsMap[cid] = jobs || {};
        finish();
      });
    });
  });
}

function loadTariffs(cids: string[], cb: (map: Record<string, any>) => void): void {
  const unique = Array.from(new Set(cids.filter(Boolean)));
  if (!unique.length) return cb({});
  const map: Record<string, any> = {};
  let left = unique.length;
  unique.forEach((cid) => {
    fbRead('tmTariffs/' + cid, (_e: any, tar: any) => {
      map[cid] = tar || {};
      if (--left === 0) cb(map);
    });
  });
}

function loadCards(cb: (map: Record<string, any>) => void): void {
  fbRead('tmCards', (_e: any, all: any) => {
    const map: Record<string, any> = {};
    if (all && typeof all === 'object') {
      Object.keys(all).forEach((k) => {
        const row = all[k];
        if (!row || typeof row !== 'object') return;
        const num = String(k || '').replace(/\s+/g, '');
        if (num) map[num] = row;
      });
    }
    cb(map);
  });
}

function persistPatches(patches: AnomalyStatusPatch[], done: () => void): void {
  if (!patches.length) return done();
  let left = patches.length;
  patches.forEach((p) => {
    fbWrite('PATCH', 'tmTripStatus/' + p.cid + '/' + p.rawKey, p.patch, () => {
      if (--left === 0) done();
    });
  });
}

function stampAndUpsertBatch(
  councilId: string,
  cid: string,
  rawKey: string,
  who: string,
  tripExtras: any,
  cb: (err: string | null) => void,
): void {
  fbRead('completedJobs/' + cid + '/' + rawKey, (_e: any, job: any) => {
    const st = tripExtras && typeof tripExtras === 'object' ? tripExtras : {};
    const tripLike: CouncilTripLike = {
      ...(job && typeof job === 'object' ? job : {}),
      ...st,
      _cid: cid,
      _rawKey: rawKey,
      status: 'approved',
      ...normalizeTmTripEconomics(job && typeof job === 'object' ? job : {}),
    };
    const afterStamp = () => {
      fbRead('tmBatches/' + councilId + '/' + cid, (_eb: any, companyBatches: any) => {
        const plan = planApprovedTripBatchUpsert(companyBatches, tripLike, {
          who,
          now: Date.now(),
          submittedRef: 'sa-tm-clean-scan',
        });
        if (!plan) return cb(null);
        fbWrite('PATCH', 'tmBatches/' + councilId + '/' + plan.pathSuffix, plan.payload, (errW: any) => {
          if (errW) return cb(String(errW.message || errW));
          fbWrite(
            'PATCH',
            'tmTripStatus/' + cid + '/' + rawKey,
            { batchId: plan.pathSuffix, batchYm: plan.batchKey },
            () => cb(null),
          );
        });
      });
    };
    if (st.platformFeeStampAt != null && st.platformFeeStampAt !== '') {
      return afterStamp();
    }
    fbRead('platformTmFees/defaults', (_ed: any, defaults: any) => {
      fbRead('companySettings/' + cid + '/tmConfig', (_ec: any, tmCfg: any) => {
        const resolved = resolvePlatformTmFees(
          normalizePlatformTmFeeDefaults(defaults),
          companyFeeOverrideFromTmConfig(tmCfg),
        );
        const stamp = buildTripPlatformFeeStamp(resolved);
        fbWrite('PATCH', 'tmTripStatus/' + cid + '/' + rawKey, stamp, () => {
          Object.assign(tripLike, stamp);
          afterStamp();
        });
      });
    });
  });
}

function approveOne(
  cand: { cid: string; rawKey: string; councilId: string },
  trip: any,
  who: string,
  cb: (err: string | null) => void,
): void {
  const now = Date.now();
  fbWrite(
    'PATCH',
    'tmTripStatus/' + cand.cid + '/' + cand.rawKey,
    {
      status: 'approved',
      approvedAt: now,
      approvedBy: who,
      autoApproved: true,
      autoApprovedBy: 'sa-tm-clean-scan',
    },
    (err: any) => {
      if (err) return cb(String(err.message || err));
      const ek = newEventKey();
      const ev = buildTripEvent('approved', {
        by: who,
        byRole: 'system',
        fromStatus: 'submitted',
        toStatus: 'approved',
        note: 'SA clean-scan auto-approved: clean never-flagged never-edited trip',
      });
      fbWrite('PUT', 'tmTripStatus/' + cand.cid + '/' + cand.rawKey + '/events/' + ek, ev, () => {
        stampAndUpsertBatch(cand.councilId, cand.cid, cand.rawKey, who, trip, cb);
      });
    },
  );
}

/**
 * POST /api/sa/tm-clean-scan
 * Body: { dryRun?: boolean, councilId?: string, companyId?: string }
 */
router.post('/api/sa/tm-clean-scan', async (req, res) => {
  const auth = await requireSa(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  const dryRun = !!(req.body && req.body.dryRun);
  const councilFilter = String(req.body?.councilId || req.query.councilId || '').trim();
  const companyFilter = String(req.body?.companyId || req.query.companyId || '').trim();
  const who = 'sa-tm-clean-scan:' + auth.uid;

  loadFlatTrips((allTrips) => {
    let trips = allTrips;
    if (councilFilter) trips = trips.filter((t) => String(t.councilId || '') === councilFilter);
    if (companyFilter) trips = trips.filter((t) => String(t._cid || '') === companyFilter);
    const cids = trips.map((t) => String(t._cid || '')).filter(Boolean);
    loadTariffs(cids, (tariffByCid) => {
      loadCards((cardsByNumber) => {
        const patches = applyAnomalyScan(trips, tariffByCid, cardsByNumber);
        const byKey: Record<string, Record<string, unknown>> = {};
        patches.forEach((p) => {
          byKey[p.cid + '/' + p.rawKey] = p.patch;
        });
        const updated = trips.map((t) => {
          const patch = byKey[String(t._cid) + '/' + String(t._rawKey)];
          if (!patch) return t;
          return {
            ...t,
            status: patch.status != null ? patch.status : t.status,
            flagReasons: patch.flagReasons !== undefined ? patch.flagReasons : t.flagReasons,
            anomalyDetail: patch.anomalyDetail !== undefined ? patch.anomalyDetail : t.anomalyDetail,
            anomalyScannedAt:
              patch.anomalyScannedAt != null ? patch.anomalyScannedAt : t.anomalyScannedAt,
            flaggedAt: patch.flaggedAt != null ? patch.flaggedAt : t.flaggedAt,
          };
        });
        const plan = planCleanAutoApprovals(updated);
        const flagged = patches.filter((p) => String(p.patch.status || '') === 'flagged').length;

        if (dryRun) {
          return res.json({
            ok: true,
            dryRun: true,
            ...summarizeCleanScanResult({
              scanned: plan.scanned,
              approved: plan.candidates.length,
              flagged,
              skipped: plan.skipped,
            }),
            candidates: plan.candidates,
          });
        }

        const applyPatchesThenApprove = () => {
          let left = plan.candidates.length;
          let approved = 0;
          let errors = 0;
          if (!left) {
            return res.json({
              ok: true,
              dryRun: false,
              ...summarizeCleanScanResult({
                scanned: plan.scanned,
                approved: 0,
                flagged,
                skipped: plan.skipped,
              }),
            });
          }
          plan.candidates.forEach((cand) => {
            const trip = updated.find(
              (t) => String(t._cid) === cand.cid && String(t._rawKey) === cand.rawKey,
            );
            // Re-check gate after scan merge
            if (!trip || !shouldAutoApproveCleanTrip(trip)) {
              if (--left === 0) {
                res.json({
                  ok: true,
                  dryRun: false,
                  ...summarizeCleanScanResult({
                    scanned: plan.scanned,
                    approved,
                    flagged,
                    skipped: plan.skipped,
                    errors,
                  }),
                });
              }
              return;
            }
            approveOne(cand, trip, who, (err) => {
              if (err) errors++;
              else approved++;
              if (--left === 0) {
                res.json({
                  ok: true,
                  dryRun: false,
                  ...summarizeCleanScanResult({
                    scanned: plan.scanned,
                    approved,
                    flagged,
                    skipped: plan.skipped,
                    errors,
                  }),
                });
              }
            });
          });
        };

        persistPatches(patches, applyPatchesThenApprove);
      });
    });
  });
});

router.get('/api/sa/tm-clean-scan/_health', (_req, res) => {
  res.json({ ok: true, service: 'tm-clean-scan' });
});

export default router;
