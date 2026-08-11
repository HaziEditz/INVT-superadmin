/**
 * SA TM settlement API — council invoices, council-paid tracking, company payout plans.
 * chargeEnabled false blocks live charge/payout execution.
 */
import { Router, Request, Response } from 'express';
import { fbRead, fbWrite, isSuperAdmin, verifyFirebaseToken } from '../firebase';
import {
  assertSettlementChargeAllowed,
  buildCouncilSettlementInvoice,
  markCouncilPaidBookaWaka,
  planCompanyPayouts,
  linesFromStampedTrips,
  settlementInvoicePath,
  settlementPayoutPath,
  SETTLEMENT_UI_LABEL,
} from '../lib/tmSettlement';
import {
  aggregateWouldBeFees,
  normalizePlatformTmFeeDefaults,
  PLATFORM_FEE_UI_LABEL,
} from '../lib/tmPlatformFees';

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

function loadStampedTripsForCouncil(
  councilId: string,
  cb: (trips: any[]) => void,
): void {
  fbRead('tmTripStatus', (_e: any, allStatus: any) => {
    if (!allStatus || typeof allStatus !== 'object') return cb([]);
    const cids = Object.keys(allStatus);
    if (!cids.length) return cb([]);
    let pending = cids.length * 2;
    const jobsMap: Record<string, any> = {};
    const namesMap: Record<string, string> = {};
    const done = () => {
      if (--pending > 0) return;
      const out: any[] = [];
      cids.forEach((cid) => {
        const statusMap = allStatus[cid] || {};
        const jobs = jobsMap[cid] || {};
        Object.entries(statusMap).forEach(([rawKey, st]: [string, any]) => {
          if (!st || st.councilId !== councilId) return;
          if (st.platformFeeStampAt == null || st.platformFeeStampAt === '') return;
          const job = jobs[rawKey] || {};
          out.push({
            _cid: cid,
            _rawKey: rawKey,
            _companyName: namesMap[cid] || 'Operator ' + cid,
            councilId: st.councilId,
            ...job,
            tmSubsidyFare: st.tmSubsidyFare ?? job.tmSubsidyFare ?? job.tmSubsidy,
            tmSubsidy: st.tmSubsidy ?? job.tmSubsidy,
            tmSubsidyHoist: st.tmSubsidyHoist ?? job.tmSubsidyHoist ?? job.hoistTotal,
            batchId: st.batchId,
            batchYm: st.batchYm,
            platformFeeCouncil: st.platformFeeCouncil,
            platformFeeCompany: st.platformFeeCompany,
            platformFeeStampAt: st.platformFeeStampAt,
            status: st.status,
          });
        });
      });
      cb(out);
    };
    if (!cids.length) return cb([]);
    cids.forEach((cid) => {
      fbRead('completedJobs/' + cid, (_e2: any, jobs: any) => {
        jobsMap[cid] = jobs || {};
        done();
      });
      fbRead('superClients/' + cid, (_e3: any, sc: any) => {
        namesMap[cid] = sc && sc.name ? sc.name : 'Operator ' + cid;
        done();
      });
    });
  });
}

/** GET /api/sa/tm-platform-fees — defaults + would-be fees report */
router.get('/api/sa/tm-platform-fees', async (req, res) => {
  const auth = await requireSa(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  const month = String(req.query.month || '').trim();
  const councilId = String(req.query.councilId || '').trim();
  const companyId = String(req.query.companyId || '').trim();
  fbRead('platformTmFees/defaults', (_e: any, defaultsRaw: any) => {
    const defaults = normalizePlatformTmFeeDefaults(defaultsRaw);
    fbRead('tmTripStatus', (_e2: any, allStatus: any) => {
      const trips: any[] = [];
      if (allStatus && typeof allStatus === 'object') {
        Object.keys(allStatus).forEach((cid) => {
          const map = allStatus[cid] || {};
          Object.keys(map).forEach((rawKey) => {
            const st = map[rawKey];
            if (!st || typeof st !== 'object') return;
            trips.push({
              _cid: cid,
              _rawKey: rawKey,
              councilId: st.councilId,
              platformFeeCouncil: st.platformFeeCouncil,
              platformFeeCompany: st.platformFeeCompany,
              platformFeeStampAt: st.platformFeeStampAt,
              status: st.status,
            });
          });
        });
      }
      const wouldBe = aggregateWouldBeFees(trips, {
        month: month || undefined,
        councilId: councilId || undefined,
        companyId: companyId || undefined,
      });
      res.json({
        ok: true,
        label: PLATFORM_FEE_UI_LABEL,
        defaults,
        wouldBe,
      });
    });
  });
});

/** PUT /api/sa/tm-platform-fees/defaults — SA updates rates; chargeEnabled forced false unless explicit true */
router.put('/api/sa/tm-platform-fees/defaults', async (req, res) => {
  const auth = await requireSa(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  const body = req.body && typeof req.body === 'object' ? req.body : {};
  const next = normalizePlatformTmFeeDefaults({
    councilFeePerTrip: body.councilFeePerTrip,
    companyFeePerTrip: body.companyFeePerTrip,
    // Never accidentally turn on from UI typos — only explicit boolean true
    chargeEnabled: body.chargeEnabled === true,
  });
  fbWrite('PUT', 'platformTmFees/defaults', { ...next, updatedAt: Date.now(), updatedBy: auth.uid }, (err: any) => {
    if (err) return res.status(500).json({ error: String(err.message || err) });
    res.json({ ok: true, defaults: next, label: PLATFORM_FEE_UI_LABEL });
  });
});

/**
 * POST /api/sa/tm-settlement/invoice
 * Body: { councilId, ym, notes? } — builds draft invoice itemized by company from stamped trips
 */
router.post('/api/sa/tm-settlement/invoice', async (req, res) => {
  const auth = await requireSa(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  const councilId = String(req.body?.councilId || '').trim();
  const ym = String(req.body?.ym || '').trim();
  if (!councilId || !/^\d{4}-\d{2}$/.test(ym)) {
    return res.status(400).json({ error: 'councilId and ym (YYYY-MM) required' });
  }
  fbRead('platformTmFees/defaults', (_ed: any, defaultsRaw: any) => {
    const defaults = normalizePlatformTmFeeDefaults(defaultsRaw);
    loadStampedTripsForCouncil(councilId, (trips) => {
      const lines = linesFromStampedTrips(trips, ym);
      const invoice = buildCouncilSettlementInvoice({
        councilId,
        ym,
        lines,
        defaults,
        notes: req.body?.notes != null ? String(req.body.notes) : null,
      });
      const path = settlementInvoicePath(councilId, ym);
      fbWrite('PUT', path, invoice, (err: any) => {
        if (err) return res.status(500).json({ error: String(err.message || err) });
        res.json({ ok: true, path, invoice, label: SETTLEMENT_UI_LABEL });
      });
    });
  });
});

/** POST /api/sa/tm-settlement/council-paid — track council paid BookaWaka (no auto charge) */
router.post('/api/sa/tm-settlement/council-paid', async (req, res) => {
  const auth = await requireSa(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  const councilId = String(req.body?.councilId || '').trim();
  const ym = String(req.body?.ym || '').trim();
  if (!councilId || !ym) return res.status(400).json({ error: 'councilId and ym required' });
  const path = settlementInvoicePath(councilId, ym);
  fbRead(path, (_e: any, existing: any) => {
    if (!existing || typeof existing !== 'object') {
      return res.status(404).json({ error: 'Invoice not found — create draft first' });
    }
    const paid = markCouncilPaidBookaWaka(existing, {
      who: auth.uid,
      payRef: req.body?.payRef,
      amount: req.body?.amount != null ? Number(req.body.amount) : null,
    });
    fbWrite('PUT', path, paid, (err: any) => {
      if (err) return res.status(500).json({ error: String(err.message || err) });
      res.json({ ok: true, invoice: paid, label: SETTLEMENT_UI_LABEL });
    });
  });
});

/**
 * POST /api/sa/tm-settlement/plan-payouts
 * Writes payout plans; live execution blocked while chargeEnabled false.
 */
router.post('/api/sa/tm-settlement/plan-payouts', async (req, res) => {
  const auth = await requireSa(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  const councilId = String(req.body?.councilId || '').trim();
  const ym = String(req.body?.ym || '').trim();
  if (!councilId || !ym) return res.status(400).json({ error: 'councilId and ym required' });
  fbRead('platformTmFees/defaults', (_ed: any, defaultsRaw: any) => {
    const defaults = normalizePlatformTmFeeDefaults(defaultsRaw);
    const gate = assertSettlementChargeAllowed(defaults);
    const path = settlementInvoicePath(councilId, ym);
    fbRead(path, (_e: any, invoice: any) => {
      if (!invoice || typeof invoice !== 'object') {
        return res.status(404).json({ error: 'Invoice not found' });
      }
      const plans = planCompanyPayouts(invoice, defaults);
      let left = Math.max(plans.length, 1);
      const finish = () => {
        res.json({
          ok: true,
          chargeAllowed: gate.allowed,
          reason: gate.reason,
          plans,
          label: SETTLEMENT_UI_LABEL,
        });
      };
      if (!plans.length) return finish();
      plans.forEach((p) => {
        fbWrite('PUT', settlementPayoutPath(p.cid, p.ym), { ...p, updatedAt: Date.now(), updatedBy: auth.uid }, () => {
          if (--left === 0) finish();
        });
      });
    });
  });
});

/**
 * POST /api/sa/tm-settlement/execute-payouts
 * Hard-blocked while chargeEnabled false — mechanism present, no real money movement.
 */
router.post('/api/sa/tm-settlement/execute-payouts', async (req, res) => {
  const auth = await requireSa(req);
  if (!auth.ok) return res.status(auth.status).json({ error: auth.error });
  fbRead('platformTmFees/defaults', (_ed: any, defaultsRaw: any) => {
    const defaults = normalizePlatformTmFeeDefaults(defaultsRaw);
    const gate = assertSettlementChargeAllowed(defaults);
    if (!gate.allowed) {
      return res.status(403).json({
        ok: false,
        blocked: true,
        reason: gate.reason,
        label: SETTLEMENT_UI_LABEL,
      });
    }
    // Real Stripe/bank execution intentionally not implemented yet — even when enabled,
    // this endpoint acknowledges the gate only until banking ops is wired.
    res.status(501).json({
      ok: false,
      reason: 'Live payout execution not wired — chargeEnabled is on but banking connector is TODO.',
      label: SETTLEMENT_UI_LABEL,
    });
  });
});

router.get('/api/sa/tm-settlement/_health', (_req, res) => {
  res.json({ ok: true, service: 'tm-settlement', label: SETTLEMENT_UI_LABEL });
});

export default router;
