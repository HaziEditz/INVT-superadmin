import { Router } from 'express';
import crypto from 'crypto';
import path from 'path';
import fs from 'fs';
import {
  fbRead, fbWrite, fbReadP, fbWriteP
} from '../firebase';
import {
  isSuperAdmin, authRestPost, createFirebaseAuthUser,
  getUidByEmail, generateTempPassword, firebaseSignIn, verifyFirebaseToken,
  fbAuthCreate
} from '../firebase';
import {
  esc, logAudit, getResendClient, ADMIN_API_KEY, setCorsHeaders,
  sanitizeDriverPayload, isDriversFbPath
} from '../utils';
import { saViewSessions, genToken, persistSessionDirect, unpersistSessionDirect } from '../sessions';

const router = Router();

const SA_VIEW_TTL = 4 * 60 * 60 * 1000;
const DB_BASE = 'https://taxilatest.firebaseio.com';

/** Grant owner panel + dispatcher access after company approval/onboarding. */
async function grantOwnerFirebaseAccess(cid: string, uid: string, companyName: string): Promise<void> {
  const name = String(companyName || '').trim() || ('Company ' + cid);
  await fbWriteP('PUT', `adminAccess/${cid}/${uid}`, true);
  await fbWriteP('PUT', `users/${uid}/companyId`, String(cid));
  await fbWriteP('PUT', `users/${uid}/companyName`, name);
  await fbWriteP('PUT', `users/${uid}/role`, 'owner');
}

// ── Firebase Proxy ────────────────────────────────────────────────────────────
// Sensitive paths that must NEVER be read via the unauthenticated /api/fb
// proxy. Any read/write whose path starts with one of these segments is
// rejected — these are admin-only paths that should be accessed through
// dedicated authenticated endpoints, not the generic browser-side proxy.
//
// Added 2026-05-18 after code review flagged a UID-enumeration auth bypass:
//   - superAdmins/* exposed the list of admin UIDs, which any caller could
//     then pass as ?saUid= to the wallet gate (now fixed via ID token auth).
//   - passengerWallet/* and walletAdminAudit/* contain financial data that
//     must only be reached via /api/sa-wallet/* (admin-authed proxy).
const FB_PROXY_BLOCKLIST = ['superadmins', 'passengerwallet', 'walletadminaudit', 'stripeconfig'];
function isBlockedFbPath(p: string): boolean {
  const head = String(p || '').replace(/^\/+/, '').split(/[\/?]/)[0].toLowerCase();
  return FB_PROXY_BLOCKLIST.includes(head);
}

router.get('/api/fb', (req, res) => {
  let p = ((req.query.path as string) || '').replace(/^\/+/, '');
  if (!p) return res.status(400).json({ error: 'missing path' });
  if (isBlockedFbPath(p)) return res.status(403).json({ error: 'Path not accessible via /api/fb — use the dedicated admin endpoint' });
  const limitToLast = req.query.limitToLast ? parseInt(req.query.limitToLast as string, 10) : null;
  const orderBy = (req.query.orderBy as string) || null;
  let fbPath = p;
  if (limitToLast || orderBy) {
    const params: string[] = [];
    if (orderBy) params.push('orderBy=' + encodeURIComponent('"' + orderBy + '"'));
    if (limitToLast) params.push('limitToLast=' + limitToLast);
    fbPath = p + (p.includes('?') ? '&' : '?') + params.join('&');
  }
  fbRead(fbPath, (err, data) => {
    if (err) return res.status(500).json({ error: String(err) });
    res.json(data);
  });
});

router.post('/api/fb', (req, res) => {
  const p = ((req.body.path as string) || '').replace(/^\/+/, '');
  const method = ((req.body.method as string) || 'PATCH').toUpperCase();
  let data = req.body.data;
  if (!p) return res.status(400).json({ error: 'missing path' });
  if (isBlockedFbPath(p)) return res.status(403).json({ error: 'Path not writable via /api/fb — use the dedicated admin endpoint' });
  if (isDriversFbPath(p) && data != null) data = sanitizeDriverPayload(data);
  fbWrite(method, p, data, (err, result) => {
    if (err) return res.status(500).json({ error: String(err) });
    res.json(result);
  });
});

// ── Delete Company ─────────────────────────────────────────────────────────────
router.post('/api/company/delete', (req, res) => {
  const cid = ((req.body.cid as string) || '').trim();
  if (!cid) return res.status(400).json({ error: 'Missing company ID' });

  const paths = [
    'superClients/' + cid,
    'superBilling/' + cid,
    'superPayouts/' + cid,
    'adminAccess/' + cid,
    'companyHours/' + cid,
    'companyPortalAccess/' + cid,
    'completedJobs/' + cid,
    'tmTripStatus/' + cid,
  ];

  let done = 0;
  let failed: string | null = null;

  paths.forEach((p) => {
    fbWrite('DELETE', p, null, (err) => {
      if (err && !String(err).includes('null')) failed = String(err);
      done++;
      if (done === paths.length) {
        if (failed) {
          console.error('[delete-company] error for cid', cid, failed);
          return res.json({ ok: true, warning: failed });
        }
        console.log('[delete-company] removed all data for cid', cid);
        res.json({ ok: true });
      }
    });
  });
});

// ── Wipe test data for a company (test-driver records + skeleton stubs) ──────
// POST { cid, testDriverIds?: string[], wipeStubs?: boolean }
// Deletes from allbookings/{cid}, completedJobs/{cid}, driverEarnings/*/{cid}/{driverId}
// Returns counts of what was removed.
router.post('/api/admin/wipe-test-data', async (req, res) => {
  try {
    const cid = String(req.body.cid || '').trim();
    if (!cid) return res.status(400).json({ error: 'Missing cid' });
    const testDriverIds: string[] = Array.isArray(req.body.testDriverIds) && req.body.testDriverIds.length
      ? req.body.testDriverIds.map((s: any) => String(s).trim()).filter(Boolean)
      : ['D001', 'D002'];
    const wipeStubs = req.body.wipeStubs !== false;
    const driverSet = new Set(testDriverIds);

    const isStub = (j: any) => {
      if (!j || typeof j !== 'object') return false;
      return !(j.bookingId || j.pickupAddress || j.PickupAddress || j.dropAddress || j.DropAddress
        || j.fare || j.FinalFare || j.driverId || j.DriverId || j.passengerName || j.PassengerName);
    };

    const [allb, compj] = await Promise.all([
      fbReadP('allbookings/' + cid).catch(() => ({})),
      fbReadP('completedJobs/' + cid).catch(() => ({}))
    ]);

    const allbDel: string[] = [];
    Object.entries(allb || {}).forEach(([k, j]: any) => {
      const drv = j && (j.driverId || j.DriverId);
      if ((drv && driverSet.has(drv)) || (wipeStubs && isStub(j))) allbDel.push(k);
    });
    const compjDel: string[] = [];
    Object.entries(compj || {}).forEach(([k, j]: any) => {
      const drv = j && (j.driverId || j.DriverId);
      if (drv && driverSet.has(drv)) compjDel.push(k);
    });

    // Multi-path PATCH in batches of 500
    async function batchDel(prefix: string, keys: string[]) {
      for (let i = 0; i < keys.length; i += 500) {
        const slice = keys.slice(i, i + 500);
        const body: Record<string, null> = {};
        slice.forEach(k => { body[prefix + '/' + k] = null; });
        await fbWriteP('PATCH', '', body);
      }
    }
    await batchDel('allbookings/' + cid, allbDel);
    await batchDel('completedJobs/' + cid, compjDel);

    // Clear driverEarnings for test drivers across all jobTypes for this company
    const earnings = await fbReadP('driverEarnings').catch(() => ({}));
    const earnDel: Record<string, null> = {};
    let earnCount = 0;
    if (earnings && typeof earnings === 'object') {
      for (const [jobType, byCid] of Object.entries<any>(earnings)) {
        if (!byCid || typeof byCid !== 'object') continue;
        const coNode = byCid[cid];
        if (!coNode || typeof coNode !== 'object') continue;
        for (const drv of Object.keys(coNode)) {
          if (driverSet.has(drv)) {
            earnDel['driverEarnings/' + jobType + '/' + cid + '/' + drv] = null;
            earnCount++;
          }
        }
      }
    }
    if (earnCount) await fbWriteP('PATCH', '', earnDel);

    console.log('[wipe-test-data] cid=' + cid, 'allbookings=' + allbDel.length, 'completedJobs=' + compjDel.length, 'earnings=' + earnCount);
    res.json({
      ok: true,
      cid,
      deleted: {
        allbookings: allbDel.length,
        completedJobs: compjDel.length,
        driverEarnings: earnCount
      },
      testDriverIds,
      wipeStubs
    });
  } catch (e: any) {
    console.error('[wipe-test-data] error', e);
    res.status(500).json({ error: e.message || String(e) });
  }
});

// ── Sync registrations → superClients (self-heals external auto-approvals) ──
// External Registration Replit may stamp onboardRequests/{id} with status='trial'
// or 'active' and a companyId, but skip writing the matching superClients/{cid}.
// This endpoint mirrors any such orphans so SA-Clients shows them. Idempotent.
router.post('/api/admin/sync-registrations', async (req, res) => {
  // ── Auth gate: require super-admin UID OR BW_ADMIN_KEY header ──────────────
  const saUid = (req.body && req.body.saUid) || (req.query.saUid as string) || '';
  const adminKeyHeader = (req.headers['x-admin-key'] as string) || '';
  const adminKey = process.env.BW_ADMIN_KEY || '';
  const headerOk = !!adminKey && adminKeyHeader === adminKey;
  const uidOk: boolean = saUid ? await new Promise<boolean>(resolve => isSuperAdmin(saUid, (_e: any, ok: boolean) => resolve(!!ok))) : false;
  if (!headerOk && !uidOk) {
    return res.status(403).json({ error: 'Not authorised — super-admin or X-Admin-Key required' });
  }
  try {
    const [reqs, clients] = await Promise.all([
      fbReadP('onboardRequests'),
      fbReadP('superClients')
    ]);
    const existing = clients || {};
    const onboard = reqs || {};
    const created: any[] = [];
    const skipped: any[] = [];
    const patch: any = {};
    const now = Date.now();
    const seenCids = new Set<string>();
    // Build name→cid index from existing superClients so we can refuse to
    // create a SECOND record for the same operator. Root cause of the
    // 620611 / 768576 duplicate (2026-05-15): External Registration handed
    // out a fresh cid when an existing operator re-signed up, and nothing
    // here detected the name collision.
    const normName = (s: string) => String(s || '').toLowerCase().replace(/\s+/g, ' ').trim();
    const existingByName: Record<string, string> = {};
    for (const [exCid, exRec] of Object.entries<any>(existing)) {
      const n = normName((exRec && exRec.name) || '');
      if (n) existingByName[n] = exCid;
    }
    const seenNames = new Map<string, string>(); // normName → first cid in this scan
    // Validate cid/uid format (Firebase-safe: no '/', '.', '#', '$', '[', ']')
    const isSafeKey = (k: string) => !!k && !/[\/.#$\[\]]/.test(k) && k.length <= 64;
    for (const [regId, r0] of Object.entries<any>(onboard)) {
      const r = r0 || {};
      const cid = r.companyId ? String(r.companyId) : '';
      if (!cid) { skipped.push({ regId, reason: 'no companyId' }); continue; }
      if (!isSafeKey(cid)) { skipped.push({ regId, cid, reason: 'unsafe cid format' }); continue; }
      if (!(r.status === 'trial' || r.status === 'active')) {
        skipped.push({ regId, reason: 'status=' + r.status }); continue;
      }
      if (existing[cid]) { skipped.push({ regId, cid, reason: 'already in superClients' }); continue; }
      if (seenCids.has(cid)) { skipped.push({ regId, cid, reason: 'duplicate companyId in same scan' }); continue; }
      const name = r.businessName || r.name || r.company || ('Company ' + cid);
      const nameKey = normName(name);
      // Name-uniqueness guard: if a superClients record already exists with
      // the same name (case/whitespace-insensitive), refuse to create a new
      // cid and log it loudly so SA can merge or rename manually.
      if (nameKey && existingByName[nameKey]) {
        skipped.push({ regId, cid, reason: 'name collision with existing cid=' + existingByName[nameKey] + ' (name="' + name + '") — refused to create duplicate' });
        console.warn('[sync-registrations] REFUSED duplicate name "' + name + '" — regId=' + regId + ' newCid=' + cid + ' existingCid=' + existingByName[nameKey]);
        continue;
      }
      if (nameKey && seenNames.has(nameKey)) {
        skipped.push({ regId, cid, reason: 'name collision within this scan with cid=' + seenNames.get(nameKey) });
        console.warn('[sync-registrations] REFUSED in-scan duplicate name "' + name + '" — regId=' + regId + ' newCid=' + cid);
        continue;
      }
      seenCids.add(cid);
      if (nameKey) seenNames.set(nameKey, cid);
      patch['superClients/' + cid] = {
        name,
        contactName: r.contactName || '',
        email: r.email || '',
        phone: r.phone || '',
        city: r.city || '',
        country: r.country || '',
        serviceType: r.serviceType || 'taxi',
        status: r.status,
        subscriptionStatus: r.status,
        packageId: r.plan ? ('pkg_' + r.plan) : 'pkg_free_trial',
        packageName: r.planLabel || 'Free Trial',
        packagePrice: typeof r.planPrice === 'number' ? r.planPrice : 0,
        trialStart: r.trialStart || 0,
        trialEnd: r.trialEnd || 0,
        trialDays: r.trialDays || 0,
        ownerUid: r.uid || '',
        externalRegId: regId,
        approvedAt: r.approvedAt || r.submittedAt || now,
        createdAt: r.approvedAt || r.submittedAt || now,
        syncedFromExternalAt: now,
        onboardedBy: 'external-auto-sync',
        modules: r.modules || { taxi: true }
      };
      // companySettings / adminAccess / users: only write if absent (don't clobber)
      const [existingSettings, existingAccess, existingUserCid] = await Promise.all([
        fbReadP('companySettings/' + cid),
        r.uid && isSafeKey(r.uid) ? fbReadP('adminAccess/' + cid + '/' + r.uid) : Promise.resolve(null),
        r.uid && isSafeKey(r.uid) ? fbReadP('users/' + r.uid + '/companyId') : Promise.resolve(null)
      ]);
      if (!existingSettings) {
        patch['companySettings/' + cid] = {
          autoDispatch: true,
          features: { accEnabled: false, autoDispatch: true, businessAccounts: false, tmEnabled: false, totalMobility: false },
          paymentMethods: { cashEnabled: true },
          timezone: 'Pacific/Auckland'
        };
      }
      if (r.uid && isSafeKey(r.uid)) {
        if (!existingAccess) patch['adminAccess/' + cid + '/' + r.uid] = true;
        if (!existingUserCid) patch['users/' + r.uid + '/companyId'] = cid;
      }
      created.push({
        regId, cid, name, email: r.email || '', status: r.status,
        wroteSettings: !existingSettings,
        wroteAccess: !!(r.uid && isSafeKey(r.uid) && !existingAccess),
        wroteUserCid: !!(r.uid && isSafeKey(r.uid) && !existingUserCid)
      });
    }
    if (Object.keys(patch).length) await fbWriteP('PATCH', '', patch);
    logAudit('sync_registrations', 'created=' + created.length + ' skipped=' + skipped.length, 'sa-admin');
    res.json({ ok: true, created, skipped, createdCount: created.length });
  } catch (err: any) {
    console.error('[sync-registrations] error', err);
    res.status(500).json({ error: String(err.message || err) });
  }
});

// ── Registrations — served directly from Firebase onboardRequests/ ────────────
// ── Passenger Watch-list (cross-company aggregate of flagged riders) ─────────
router.get('/api/admin/passenger-watchlist', async (req, res) => {
  try {
    const days = Math.max(1, Math.min(365, parseInt((req.query.days as string) || '90', 10)));
    const minLow = Math.max(1, parseInt((req.query.minLow as string) || '2', 10));
    const lowStarMax = Math.max(1, Math.min(5, parseInt((req.query.lowStarMax as string) || '2', 10)));
    const cutoff = Date.now() - days * 24 * 60 * 60 * 1000;

    const [allRatings, superClients] = await Promise.all([
      fbReadP('passengerRatings'),
      fbReadP('superClients')
    ]);

    const out: any[] = [];
    if (allRatings && typeof allRatings === 'object') {
      for (const [cid, byPhone] of Object.entries<any>(allRatings)) {
        if (!byPhone || typeof byPhone !== 'object') continue;
        const coName = (superClients && superClients[cid] && superClients[cid].name) || cid;
        for (const [phone, byBooking] of Object.entries<any>(byPhone)) {
          if (!byBooking || typeof byBooking !== 'object') continue;
          let total = 0, sum = 0, lowCount = 0, lastTs = 0, lastReason = '';
          for (const r of Object.values<any>(byBooking)) {
            const rating = Number(r && r.rating);
            const ts = Number(r && (r.ratedAt || r.timestamp || r.createdAt)) || 0;
            if (!rating || rating < 1 || rating > 5) continue;
            total++; sum += rating;
            if (rating <= lowStarMax && ts >= cutoff) {
              lowCount++;
              if (ts > lastTs) { lastTs = ts; lastReason = String((r && (r.reason || r.comment)) || ''); }
            }
          }
          if (lowCount >= minLow) {
            out.push({
              companyId: cid,
              companyName: coName,
              phone,
              totalRatings: total,
              avgRating: total ? Math.round((sum / total) * 10) / 10 : 0,
              lowRatingsInWindow: lowCount,
              lastLowAt: lastTs,
              lastLowReason: lastReason
            });
          }
        }
      }
    }
    out.sort((a, b) => b.lowRatingsInWindow - a.lowRatingsInWindow || b.lastLowAt - a.lastLowAt);
    res.json({ windowDays: days, minLow, lowStarMax, count: out.length, items: out });
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

router.get('/api/admin/registrations', async (req, res) => {
  try {
    const reqs = await fbReadP('onboardRequests');
    if (!reqs) return res.json([]);
    const statusFilter = (req.query.status as string) || '';
    const list = Object.entries(reqs)
      .map(([id, r]: [string, any]) => ({
        id,
        company:        r.businessName || r.name || '',
        name:           r.contactName || '',
        email:          r.email || '',
        phone:          r.phone || '',
        area:           r.city || '',
        country:        r.country || '',
        message:        r.message || '',
        tradingName:    r.tradingName || r.businessName || '',
        businessNumber: r.regNo || r.businessNumber || '',
        fleetSize:      r.fleetSize || '',
        website:        r.website || '',
        modules:        r.modules || {},
        towingFleetSize:r.towingFleetSize || '',
        truckTypes:     r.truckTypes || '',
        operatingHours: r.operatingHours || '',
        afterHours:     r.afterHours || false,
        status:         r.status || 'pending',
        submittedAt:    typeof r.submittedAt === 'number' ? r.submittedAt : (r.submittedAt ? new Date(r.submittedAt).getTime() : 0),
        approvedAt:     r.approvedAt || 0,
        companyId:      r.companyId || '',
        uid:            r.uid || '',
        serviceType:    r.serviceType || 'taxi',
        _source:        'firebase'
      }))
      .filter(r => !statusFilter || r.status === statusFilter)
      .sort((a, b) => (b.submittedAt || 0) - (a.submittedAt || 0));
    res.json(list);
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

router.get('/api/admin/registrations/:id', async (req, res) => {
  try {
    const r = await fbReadP('onboardRequests/' + req.params.id);
    if (!r) return res.status(404).json({ error: 'Registration not found' });
    res.json({
      id: req.params.id,
      company:     r.businessName || r.name || '',
      name:        r.contactName || '',
      email:       r.email || '',
      status:      r.status || 'pending',
      companyId:   r.companyId || '',
      uid:         r.uid || '',
      serviceType: r.serviceType || 'taxi',
      _source:     'firebase'
    });
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

// ── Approve registration ──────────────────────────────────────────────────────
async function sendWelcomeEmail({ companyName, email, cid, tempPassword }: any) {
  try {
    const resend = await getResendClient();
    if (!resend) return { ok: false, error: 'Email client unavailable' };
    const result = await resend.emails.send({
      from: 'BookaWaka <info@bookawaka.com>',
      to: [email],
      subject: `Welcome to BookaWaka — Your company is live! (ID: ${cid})`,
      html: buildWelcomeEmail({ companyName, email, cid, tempPassword })
    }) as any;
    if (result.error) {
      console.error('[welcome-email] Resend error for', email, ':', result.error);
      return { ok: false, error: result.error.message };
    }
    console.log('[welcome-email] Sent to', email, '| id:', result.data && result.data.id);
    return { ok: true, id: result.data && result.data.id };
  } catch (err: any) {
    console.error('[welcome-email] Failed for', email, ':', err.message || err);
    return { ok: false, error: String(err.message || err) };
  }
}

// Approve — all registrations now come from Firebase; frontend routes firebase-source
// registrations through /api/admin/direct-onboard. This endpoint handles any
// external or legacy callers that still POST here directly.
router.post('/api/admin/registrations/:id/approve', async (req, res) => {
  const { email: bodyEmail, uid: bodyUid, _saEmail } = req.body || {};
  try {
    const r = await fbReadP('onboardRequests/' + req.params.id);
    if (!r) return res.status(404).json({ error: 'Registration not found' });
    const email = bodyEmail || r.email || '';
    const companyName = r.businessName || r.name || email || req.params.id;
    // If already approved and has a CID, just ensure access grants are in place
    let cid: string = r.companyId ? String(r.companyId) : '';
    if (!cid) {
      // Generate a new company ID
      const existing = await fbReadP('superClients') || {};
      let attempts = 0;
      do { cid = String(Math.floor(100000 + Math.random() * 900000)); attempts++; }
      while (existing[cid] && attempts < 20);
      const now = Date.now();
      await fbWriteP('PUT', 'superClients/' + cid, {
        name: companyName, email, city: r.city || '', country: r.country || '',
        contactName: r.contactName || '', phone: r.phone || '',
        status: 'trial', createdAt: now, onboardedBy: 'sa-approve'
      });
      await fbWriteP('PATCH', 'onboardRequests/' + req.params.id, { status: 'trial', companyId: cid, approvedAt: now });
    }
    let uid: string | null = bodyUid || r.uid || null;
    let tempPassword: string | null = null;
    let autoCreated = false;
    if (!uid && email) {
      uid = await getUidByEmail(email);
      if (!uid) {
        tempPassword = generateTempPassword();
        try {
          const created = await createFirebaseAuthUser(email, tempPassword);
          uid = created.uid; autoCreated = true;
          console.log('[approve] Auto-created Firebase Auth for', email, 'uid:', uid);
        } catch (authErr: any) {
          console.error('[approve] Auth auto-create failed for', email, ':', authErr.message);
          return res.json({ ok: true, companyId: cid, uidWarning: true, authError: authErr.message });
        }
      }
    }
    if (uid) {
      await grantOwnerFirebaseAccess(cid, uid, companyName);
      if (autoCreated) fbWriteP('PATCH', 'onboardRequests/' + req.params.id, { uid }).catch(() => {});
      console.log('[approve] Access granted uid', uid, 'for company', cid);
    }
    logAudit('company_approved', `cid=${cid} | ${companyName} | uid=${uid || 'none'} | Approved${autoCreated ? '; account auto-created' : ''}`, _saEmail || email || 'sa-admin');
    if (email && autoCreated && tempPassword) {
      sendWelcomeEmail({ companyName, email, cid, tempPassword }).catch(() => {});
    }
    res.json({ ok: true, companyId: cid, registration: { companyId: cid, company: companyName, email, status: 'trial' }, uid, autoCreated, tempPassword, accessGranted: !!uid });
  } catch (err: any) {
    res.status(500).json({ error: String(err.message || err) });
  }
});

router.post('/api/admin/registrations/:id/reject', async (req, res) => {
  const { reason, _saEmail } = req.body || {};
  try {
    const r = await fbReadP('onboardRequests/' + req.params.id);
    const note = reason || '';
    await fbWriteP('PATCH', 'onboardRequests/' + req.params.id, { status: 'rejected', rejectedAt: Date.now(), rejectionNote: note });
    logAudit('company_rejected', `id=${req.params.id} | ${(r && (r.businessName || r.name)) || ''} | Rejected: ${note}`, _saEmail || 'sa-admin');
    res.json({ ok: true, registration: { id: req.params.id, status: 'rejected', company: (r && (r.businessName || r.name)) || '', companyId: (r && r.companyId) || '' } });
  } catch (err: any) { res.status(500).json({ error: String(err.message || err) }); }
});

router.post('/api/admin/registrations/:id/activate', async (req, res) => {
  const { email, companyId: bodyCompanyId, uid: bodyUid, _saEmail } = req.body || {};
  try {
    const r = await fbReadP('onboardRequests/' + req.params.id);
    await fbWriteP('PATCH', 'onboardRequests/' + req.params.id, { status: 'active', activatedAt: Date.now() });
    const cid = bodyCompanyId || (r && r.companyId) || '';
    let uid: string | null = bodyUid || (r && r.uid) || null;
    if (cid) {
      if (!uid && email) uid = await getUidByEmail(email);
      if (uid) {
        fbWrite('PUT', 'adminAccess/' + cid + '/' + uid, true, (e) => { if (e) console.error('[adminAccess] re-activate write error:', e); else console.log('[adminAccess] re-granted uid', uid, 'for company', cid); });
        fbWrite('PUT', 'users/' + uid + '/companyId', String(cid), (e) => { if (e) console.error('[users/companyId] re-activate write error:', e); });
      }
    }
    logAudit('company_activated', `id=${req.params.id} | cid=${cid} | ${(r && (r.businessName || r.name)) || ''} | Re-activated`, _saEmail || 'sa-admin');
    res.json({ ok: true });
  } catch (err: any) { res.status(500).json({ error: String(err.message || err) }); }
});

router.post('/api/admin/registrations/:id/deactivate', async (req, res) => {
  const { companyId, _saEmail } = req.body || {};
  try {
    await fbWriteP('PATCH', 'onboardRequests/' + req.params.id, { status: 'deactivated', deactivatedAt: Date.now() });
    if (companyId) {
      fbRead('adminAccess/' + companyId, (readErr, uidMap) => {
        if (!readErr && uidMap && typeof uidMap === 'object') {
          Object.keys(uidMap).forEach(uid => {
            fbWrite('DELETE', 'users/' + uid + '/companyId', null, (e) => { if (e) console.error('[users/companyId] deactivate delete error:', e); });
          });
        }
        fbWrite('DELETE', 'adminAccess/' + companyId, null, (e) => { if (e) console.error('[adminAccess] delete error:', e); else console.log('[adminAccess] revoked all access for company', companyId); });
      });
    }
    logAudit('company_deactivated', `id=${req.params.id} | cid=${companyId || ''} | Deactivated; all portal access revoked`, _saEmail || 'sa-admin');
    res.json({ ok: true });
  } catch (err: any) { res.status(500).json({ error: String(err.message || err) }); }
});

// ── UID lookup ────────────────────────────────────────────────────────────────
router.get('/api/admin/lookup-uid', async (req, res) => {
  const email = ((req.query.email as string) || '').trim();
  if (!email) return res.status(400).json({ error: 'email required' });
  try {
    const uid = await getUidByEmail(email);
    res.json({ uid: uid || null });
  } catch (e) {
    res.json({ uid: null });
  }
});

// ── Grant / Revoke access ─────────────────────────────────────────────────────
router.post('/api/admin/grant-access', (req, res) => {
  const { email, companyId } = req.body || {};
  if (!email || !companyId) return res.status(400).json({ error: 'email and companyId required' });
  getUidByEmail(email).then(uid => {
    if (!uid) return res.json({ success: false, uidWarning: true });
    fbWrite('PUT', 'adminAccess/' + companyId + '/' + uid, true, (err) => {
      if (err) return res.status(500).json({ error: String(err) });
      console.log('[adminAccess] manually granted uid', uid, 'for company', companyId);
      fbWrite('PUT', 'users/' + uid + '/companyId', String(companyId), () => {});
      logAudit('access_granted', `cid=${String(companyId)} | uid=${uid} | Panel access granted to ${email}`, email);
      res.json({ success: true, uid });
    });
  });
});

router.post('/api/admin/grant-access-uid', (req, res) => {
  const { uid, companyId } = req.body || {};
  if (!uid || !companyId) return res.status(400).json({ error: 'uid and companyId required' });
  fbWrite('PUT', 'adminAccess/' + companyId + '/' + uid, true, (err) => {
    if (err) return res.status(500).json({ error: String(err) });
    console.log('[adminAccess] direct-granted uid', uid, 'for company', companyId);
    fbWrite('PUT', 'users/' + uid + '/companyId', String(companyId), () => {});
    logAudit('access_granted', `cid=${String(companyId)} | uid=${uid} | Panel access granted by UID`, req.body._saEmail || 'sa-admin');
    res.json({ success: true });
  });
});

router.post('/api/admin/revoke-access-uid', (req, res) => {
  const { uid, companyId, _saEmail } = req.body || {};
  if (!uid || !companyId) return res.status(400).json({ error: 'uid and companyId required' });
  fbWrite('DELETE', 'adminAccess/' + companyId + '/' + uid, null, (err) => {
    if (err) return res.status(500).json({ error: String(err) });
    fbWrite('DELETE', 'users/' + uid + '/companyId', null, () => {});
    console.log('[adminAccess] revoked uid', uid, 'from company', companyId);
    logAudit('access_revoked', `cid=${String(companyId)} | uid=${uid} | Panel access revoked by UID`, _saEmail || 'sa-admin');
    res.json({ success: true });
  });
});

router.get('/api/admin/accounts', async (req, res) => {
  try {
    const clients = await fbReadP('superClients');
    if (!clients) return res.json([]);
    const list = Object.entries(clients).map(([cid, c]: [string, any]) => ({
      id: cid, companyId: cid,
      name:      c.name || cid,
      email:     c.email || c.contactEmail || '',
      status:    c.status || 'active',
      city:      c.city || '',
      country:   c.country || '',
      plan:      c.plan || '',
      createdAt: c.createdAt || 0
    }));
    res.json(list);
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

// ── Welcome email preview ─────────────────────────────────────────────────────
router.get('/api/admin/welcome-email-preview', (req, res) => {
  const { name, email, cid } = req.query as any;
  if (!name && !email) return res.status(400).send('<p>Missing name/email query params</p>');
  const html = buildWelcomeEmail({
    companyName: name || 'Your Company',
    email: email || 'owner@example.com',
    cid: cid || '——',
    tempPassword: 'Temp@1234'
  });
  res.setHeader('Content-Type', 'text/html');
  res.send(html);
});

// ── Company Onboarding Request (Public Join Form) ──────────────────────────────
const JOIN_CSS = `
*{box-sizing:border-box;margin:0;padding:0}
body{background:#F5F5F5;font-family:'Segoe UI',system-ui,sans-serif;color:#263238;min-height:100vh}
.jn-header{background:linear-gradient(135deg,#BF360C,#E65100);color:#fff;padding:28px 24px;text-align:center}
.jn-header h1{font-size:26px;font-weight:700;margin-bottom:6px}
.jn-header p{font-size:14px;opacity:.85}
.jn-wrap{max-width:760px;margin:0 auto;padding:32px 16px}
.jn-card{background:#fff;border-radius:10px;box-shadow:0 2px 8px rgba(0,0,0,.1);padding:28px;margin-bottom:24px}
.jn-card h2{font-size:15px;font-weight:700;color:#E65100;margin-bottom:18px;padding-bottom:10px;border-bottom:2px solid #FFF3E0}
.jn-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
@media(max-width:540px){.jn-grid{grid-template-columns:1fr}}
.jn-field{margin-bottom:0}
.jn-field label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
.jn-field label span{color:#E65100}
.jn-field input,.jn-field select,.jn-field textarea{width:100%;padding:10px 12px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;font-family:inherit;transition:.15s}
.jn-field input:focus,.jn-field select:focus,.jn-field textarea:focus{outline:none;border-color:#E65100;box-shadow:0 0 0 3px rgba(230,81,0,.1)}
.jn-field textarea{resize:vertical;min-height:90px}
.jn-modules{display:flex;gap:10px;flex-wrap:wrap;margin-top:4px}
.jn-mod{display:flex;align-items:center;gap:6px;padding:8px 14px;border:1.5px solid #ddd;border-radius:8px;cursor:pointer;font-size:13px;font-weight:500;user-select:none;transition:.15s}
.jn-mod:hover{border-color:#E65100}
.jn-mod input[type=checkbox]{width:16px;height:16px;accent-color:#E65100;cursor:pointer}
.jn-footer{text-align:center;padding-bottom:32px}
.jn-submit{background:#E65100;color:#fff;border:none;border-radius:8px;padding:14px 40px;font-size:16px;font-weight:700;cursor:pointer;box-shadow:0 3px 10px rgba(230,81,0,.3);transition:.15s}
.jn-submit:hover{background:#BF360C;transform:translateY(-1px)}
.jn-note{font-size:12px;color:#aaa;margin-top:12px}
.jn-req{color:#E65100}
.jn-success{max-width:560px;margin:60px auto;background:#fff;border-radius:12px;padding:48px 36px;text-align:center;box-shadow:0 4px 20px rgba(0,0,0,.1)}
.jn-success h2{font-size:24px;color:#2E7D32;margin:16px 0 10px}
.jn-success p{color:#555;font-size:14px;line-height:1.7}
.jn-err{background:#FFEBEE;border-left:4px solid #C62828;padding:12px 16px;border-radius:6px;color:#C62828;font-size:13px;margin-bottom:20px}
`;

router.get('/join', (req, res) => {
  const err = (req.query.err as string) || '';
  const errHtml = err ? `<div class="jn-err">&#9888; ${esc(err)}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Join BookaWaka Platform &mdash; Apply Now</title>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
var db=firebase.database();
</script>
<style>
${JOIN_CSS}
.jn-pkg-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:14px;margin-top:10px}
.jn-pkg{border:2.5px solid #ddd;border-radius:10px;padding:0;cursor:pointer;transition:.15s;overflow:hidden;position:relative;background:#fff}
.jn-pkg:hover{border-color:#E65100;box-shadow:0 2px 10px rgba(230,81,0,.15)}
.jn-pkg.selected{border-color:#E65100;box-shadow:0 0 0 3px rgba(230,81,0,.18)}
.jn-pkg-head{padding:14px 14px 10px;background:#1565C0;color:#fff}
.jn-pkg-head.flat-annual{background:#6A1B9A}
.jn-pkg-head.flat-monthly{background:#0277BD}
.jn-pkg-name{font-size:14px;font-weight:700;margin-bottom:4px}
.jn-pkg-price{font-size:22px;font-weight:800;line-height:1}
.jn-pkg-price span{font-size:12px;font-weight:400;opacity:.85}
.jn-pkg-body{padding:10px 14px}
.jn-pkg-desc{font-size:12.5px;color:#555;margin-bottom:8px;line-height:1.5}
.jn-pkg-mods{display:flex;gap:5px;flex-wrap:wrap;margin-bottom:6px}
.jn-mod-tag{font-size:10.5px;font-weight:600;padding:2px 8px;border-radius:10px}
.jn-mod-taxi{background:#E3F2FD;color:#1565C0}.jn-mod-food{background:#E8F5E9;color:#1B5E20}.jn-mod-freight{background:#F3E5F5;color:#6A1B9A}
.jn-pkg-tiers{font-size:11px;color:#666;margin-top:4px}
.jn-pkg-trial{display:inline-block;font-size:11px;font-weight:600;background:#FFF3E0;color:#E65100;padding:2px 8px;border-radius:10px;margin-top:4px}
.jn-pkg-check{display:none;position:absolute;top:8px;right:8px;background:#E65100;color:#fff;border-radius:50%;width:22px;height:22px;align-items:center;justify-content:center;font-size:13px;font-weight:700}
.jn-pkg.selected .jn-pkg-check{display:flex}
.jn-pkg-none{text-align:center;color:#aaa;padding:24px 0;font-size:13px}
.jn-pkg-err{background:#FFEBEE;border:1.5px solid #FFCDD2;color:#C62828;padding:8px 12px;border-radius:6px;font-size:13px;margin-top:8px;display:none}
</style>
</head>
<body>
<div class="jn-header">
  <h1>&#128665; Join the BookaWaka Platform</h1>
  <p>Submit your application to connect your taxi company to the BookaWaka network.<br>Our team will review your request within 1&ndash;2 business days.</p>
</div>
<div class="jn-wrap">
${errHtml}
<form method="POST" action="/api/submit-onboard-request" onsubmit="return validateJoin(event)">
<input type="hidden" name="packageId" id="jn-pkg-id" value=""/>
<input type="hidden" name="packageName" id="jn-pkg-name" value=""/>

<div class="jn-card">
  <h2>&#127970; Company Information</h2>
  <div class="jn-grid">
    <div class="jn-field"><label>Company Name <span>*</span></label><input type="text" name="name" required placeholder="e.g. City Cabs Ltd"/></div>
    <div class="jn-field"><label>Trading Name <em style="font-weight:400;color:#aaa">(if different)</em></label><input type="text" name="tradingName" placeholder="Optional"/></div>
    <div class="jn-field"><label>City <span>*</span></label><input type="text" name="city" required placeholder="e.g. Auckland"/></div>
    <div class="jn-field"><label>Country <span>*</span></label><input type="text" name="country" required placeholder="e.g. New Zealand"/></div>
    <div class="jn-field"><label>Company Registration No.</label><input type="text" name="regNo" placeholder="Optional &mdash; NZBN or local equivalent"/></div>
    <div class="jn-field"><label>Estimated Fleet Size</label>
      <select name="fleetSize">
        <option value="">Select range</option>
        <option value="1-5">1 &ndash; 5 vehicles</option>
        <option value="6-20">6 &ndash; 20 vehicles</option>
        <option value="21-50">21 &ndash; 50 vehicles</option>
        <option value="51-100">51 &ndash; 100 vehicles</option>
        <option value="100+">100+ vehicles</option>
      </select>
    </div>
  </div>
</div>

<div class="jn-card">
  <h2>&#128100; Primary Contact</h2>
  <div class="jn-grid">
    <div class="jn-field"><label>Contact Name <span>*</span></label><input type="text" name="contactName" required placeholder="Full name"/></div>
    <div class="jn-field"><label>Job Title</label><input type="text" name="contactTitle" placeholder="e.g. Operations Manager"/></div>
    <div class="jn-field"><label>Email Address <span>*</span></label><input type="email" name="email" required placeholder="contact@yourcompany.com"/></div>
    <div class="jn-field"><label>Phone Number <span>*</span></label><input type="tel" name="phone" required placeholder="+64 21 000 0000"/></div>
    <div class="jn-field jn-grid" style="grid-column:1/-1"><label>Website</label><input type="url" name="website" placeholder="https://yourcompany.com (optional)"/></div>
  </div>
</div>

<div class="jn-card">
  <h2>&#128230; Modules &amp; Services</h2>
  <p style="font-size:13px;color:#666;margin-bottom:14px">Which BookaWaka modules are you interested in? You can enable more later.</p>
  <div class="jn-modules">
    <label class="jn-mod"><input type="checkbox" name="moduleTaxi" value="1" checked> &#128665; Taxi Dispatch</label>
    <label class="jn-mod"><input type="checkbox" name="moduleFD" value="1"> &#127829; Food Delivery</label>
    <label class="jn-mod"><input type="checkbox" name="moduleFR" value="1"> &#128230; Freight Delivery</label>
  </div>
  <div style="margin-top:20px">
    <div class="jn-field"><label>Anything else you'd like us to know?</label><textarea name="message" placeholder="Service area, special requirements, current software you use, timeline to go live&hellip;"></textarea></div>
  </div>
</div>

<div class="jn-card">
  <h2>&#128176; Choose a Subscription Package</h2>
  <p style="font-size:13px;color:#666;margin-bottom:6px">Select the plan that suits your fleet. You can change this any time after you join.</p>
  <div id="jn-pkg-grid" class="jn-pkg-grid">
    <div class="jn-pkg-none">Loading available packages&hellip;</div>
  </div>
  <div id="jn-pkg-err" class="jn-pkg-err">Please select a package to continue.</div>
</div>

<div class="jn-footer">
  <button type="submit" class="jn-submit">&#128640; Submit Application</button>
  <p class="jn-note">By submitting, you agree that BookaWaka may contact you about this application.<br>All information is kept confidential.</p>
</div>
</form>
</div>

<script>
var selectedPkgId='';
function selectPkg(id,name){
  selectedPkgId=id;
  document.getElementById('jn-pkg-id').value=id;
  document.getElementById('jn-pkg-name').value=name;
  document.getElementById('jn-pkg-err').style.display='none';
  document.querySelectorAll('.jn-pkg').forEach(function(el){
    el.classList.toggle('selected', el.dataset.id===id);
  });
}
function validateJoin(e){
  if(!selectedPkgId){
    document.getElementById('jn-pkg-err').style.display='block';
    document.getElementById('jn-pkg-grid').scrollIntoView({behavior:'smooth',block:'center'});
    e.preventDefault(); return false;
  }
  return true;
}
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function buildPkgCard(id,p){
  var bt=p.billingType||'per_car_monthly';
  var headCls='jn-pkg-head'+(bt==='flat_annual'?' flat-annual':bt==='flat_monthly'?' flat-monthly':'');
  var priceMain='$'+(+(p.pricePerCar||p.monthlyPrice||0)).toFixed(2);
  var priceSub='/taxi/month';
  if(bt==='flat_annual'){ priceMain='$'+(+(p.flatPrice||0)).toFixed(2); priceSub='/year'; }
  else if(bt==='flat_monthly'){ priceMain='$'+(+(p.flatPrice||0)).toFixed(2); priceSub='/month'; }
  var mods='';
  if(p.modules){
    if(p.modules.taxi)    mods+='<span class="jn-mod-tag jn-mod-taxi">&#128663; Taxi</span>';
    if(p.modules.food)    mods+='<span class="jn-mod-tag jn-mod-food">&#127829; Food</span>';
    if(p.modules.freight) mods+='<span class="jn-mod-tag jn-mod-freight">&#128230; Freight</span>';
  }
  var tiersHtml='';
  var tiers=Array.isArray(p.volumeTiers)?p.volumeTiers:(p.volumeTiers?Object.values(p.volumeTiers):null);
  if(tiers&&tiers.length&&bt==='per_car_monthly'){
    tiersHtml='<div class="jn-pkg-tiers"><strong>Volume pricing:</strong><br>'
      +tiers.map(function(t){
        var range=t.max===0?t.min+'+ cars':t.min+'\u2013'+t.max+' cars';
        return range+' = $'+parseFloat(t.price).toFixed(2)+'/car';
      }).join(' &bull; ')+'</div>';
  }
  var trialHtml=p.trialDays?'<div class="jn-pkg-trial">&#9201; '+p.trialDays+'-day free trial</div>':'';
  return '<div class="jn-pkg" data-id="'+esc(id)+'" onclick="selectPkg(\''+esc(id)+'\',\''+esc(p.name||id)+'\')">'
    +'<span class="jn-pkg-check">&#10003;</span>'
    +'<div class="'+headCls+'">'
      +'<div class="jn-pkg-name">'+esc(p.name||id)+'</div>'
      +'<div class="jn-pkg-price">'+priceMain+'<span> '+priceSub+'</span></div>'
      +(p.minimumMonthly&&bt==='per_car_monthly'?'<div style="font-size:11px;opacity:.75;margin-top:2px">Min. $'+parseFloat(p.minimumMonthly).toFixed(0)+'/month</div>':'')
    +'</div>'
    +'<div class="jn-pkg-body">'
      +'<div class="jn-pkg-desc">'+esc(p.description||'')+'</div>'
      +'<div class="jn-pkg-mods">'+mods+'</div>'
      +tiersHtml
      +trialHtml
    +'</div>'
  +'</div>';
}

function loadPackages(){
  db.ref('superPackages').on('value', function(snap){
    var pkgs=snap.val()||{};
    var grid=document.getElementById('jn-pkg-grid');
    var visible=Object.keys(pkgs).filter(function(id){
      return pkgs[id].active!==false && pkgs[id].showOnJoin!==false;
    }).sort(function(a,b){ return (pkgs[a].sortOrder||99)-(pkgs[b].sortOrder||99); });
    if(!visible.length){
      grid.innerHTML='<div class="jn-pkg-none">No packages available at this time. Our team will discuss pricing with you.</div>';
      return;
    }
    grid.innerHTML=visible.map(function(id){ return buildPkgCard(id,pkgs[id]); }).join('');
    if(selectedPkgId) selectPkg(selectedPkgId, pkgs[selectedPkgId]&&pkgs[selectedPkgId].name||'');
  });
}
loadPackages();
</script>
</body></html>`);
});

router.get('/join/success', (req, res) => {
  const ref = (req.query.ref as string) || '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Application Submitted &mdash; BookaWaka</title>
<style>${JOIN_CSS}</style></head>
<body style="background:linear-gradient(135deg,#E8F5E9,#F1F8E9)">
<div style="padding:20px">
<div class="jn-success">
  <div style="font-size:56px">&#9989;</div>
  <h2>Application Submitted!</h2>
  <p>Thank you for your interest in joining the BookaWaka platform.<br><br>
  Your reference number is: <strong style="color:#E65100;font-family:monospace">${esc(ref)}</strong><br><br>
  Our team will review your application and get back to you within <strong>1&ndash;2 business days</strong>. Please check your email for a confirmation.</p>
  <div style="margin-top:28px">
    <a href="/join" style="display:inline-block;padding:10px 24px;background:#E65100;color:#fff;border-radius:6px;text-decoration:none;font-weight:600;font-size:14px">Submit Another Application</a>
  </div>
</div>
</div>
</body></html>`);
});

// ── Public registration API ───────────────────────────────────────────────────
const CORS_ORIGIN = process.env.PUBLIC_SITE_ORIGIN || '*';
function setPublicCors(res: any) {
  res.setHeader('Access-Control-Allow-Origin', CORS_ORIGIN);
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

router.options('/api/public/register', (req, res) => {
  setPublicCors(res);
  res.status(204).end();
});

router.post('/api/public/register', (req, res) => {
  setPublicCors(res);
  const b = req.body || {};
  const name = (b.companyName || b.name || '').trim();
  const email = (b.email || '').trim().toLowerCase();
  const phone = (b.phone || '').trim();
  const city = (b.city || '').trim();
  const country = (b.country || 'New Zealand').trim();
  const contactName = (b.contactName || b.name || '').trim();
  const businessType = (b.businessType || b.type || '').trim();
  if (!name || !email || !phone || !contactName) {
    return res.status(400).json({ ok: false, error: 'Required fields missing: companyName, email, phone, contactName' });
  }
  const reqId = 'REQ' + Date.now();
  const types = businessType.split(',').map((s: string) => s.trim());
  const data: any = {
    name, tradingName: b.tradingName || '',
    city: city || '', country: country || 'New Zealand',
    regNo: b.regNo || '', fleetSize: b.fleetSize || '',
    contactName, contactTitle: b.contactTitle || '',
    email, phone,
    website: b.website || '',
    businessType,
    modules: {
      taxi: types.includes('taxi') || b.moduleTaxi === true || b.moduleTaxi === '1',
      foodDelivery: types.includes('food') || b.moduleFD === true || b.moduleFD === '1',
      freight: types.includes('courier') || b.moduleFR === true || b.moduleFR === '1'
    },
    message: b.message || '',
    status: 'pending',
    source: 'website',
    submittedAt: Date.now()
  };
  let attempt = 0;
  const MAX_ATTEMPTS = 3;
  function tryWrite() {
    attempt++;
    fbWrite('PUT', 'onboardRequests/' + reqId, data, (err) => {
      if (!err) {
        res.json({ ok: true, ref: reqId });
      } else if (attempt < MAX_ATTEMPTS) {
        setTimeout(tryWrite, 1500 * attempt);
      } else {
        console.error('[public/register] Firebase write failed after', MAX_ATTEMPTS, 'attempts:', err);
        res.status(500).json({ ok: false, error: 'Could not save registration. Please try again.' });
      }
    });
  }
  tryWrite();
});

router.post('/api/submit-onboard-request', (req, res) => {
  const name = (req.body.name || '').trim();
  const email = (req.body.email || '').trim().toLowerCase();
  const phone = (req.body.phone || '').trim();
  const city = (req.body.city || '').trim();
  const country = (req.body.country || '').trim();
  const contactName = (req.body.contactName || '').trim();
  if (!name || !email || !phone || !city || !country || !contactName) {
    return res.redirect('/join?err=Please+fill+in+all+required+fields.');
  }
  const reqId = 'REQ' + Date.now();
  const data: any = {
    name, tradingName: req.body.tradingName || '',
    city, country,
    regNo: req.body.regNo || '', fleetSize: req.body.fleetSize || '',
    contactName, contactTitle: req.body.contactTitle || '',
    email, phone,
    website: req.body.website || '',
    modules: {
      taxi: req.body.moduleTaxi === '1',
      foodDelivery: req.body.moduleFD === '1',
      freight: req.body.moduleFR === '1'
    },
    packageId: req.body.packageId || null,
    packageName: req.body.packageName || null,
    message: req.body.message || '',
    status: 'pending',
    submittedAt: Date.now()
  };
  let attempt = 0;
  const MAX_ATTEMPTS = 3;
  function tryWrite() {
    attempt++;
    fbWrite('PUT', 'onboardRequests/' + reqId, data, (err) => {
      if (!err) {
        res.redirect('/join/success?ref=' + encodeURIComponent(reqId));
      } else if (attempt < MAX_ATTEMPTS) {
        setTimeout(tryWrite, 1500 * attempt);
      } else {
        console.error('[submit-onboard] Firebase write failed after', MAX_ATTEMPTS, 'attempts:', err);
        res.redirect('/join?err=Submission+could+not+be+saved.+Please+try+again+in+a+moment.');
      }
    });
  }
  tryWrite();
});

// ── Create Portal Access ──────────────────────────────────────────────────────
router.post('/api/create-portal-access', async (req, res) => {
  const { portalType, entityId, email, password, companyId, name } = req.body;
  if (!portalType || !entityId || !email || !password) return res.status(400).json({ error: 'Missing required fields' });
  if ((password as string).length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' });
  const emailClean = (email as string).toLowerCase().trim();
  try {
    const authUser = await createFirebaseAuthUser(emailClean, password);
    let fbPath: string;
    if (portalType === 'restaurant') fbPath = 'foodRestaurantAccess/' + entityId;
    else if (portalType === 'council') fbPath = 'tmCouncilAccess/' + entityId;
    else if (portalType === 'freight') fbPath = 'freightAccess/' + entityId;
    else return res.status(400).json({ error: 'Invalid portalType' });
    const data: any = { email: emailClean, uid: authUser.uid, active: true, createdAt: Date.now() };
    if (companyId) data.companyId = companyId;
    if (name) data.name = name;
    fbWrite('PUT', fbPath, data, (err) => {
      if (err) return res.json({ error: String(err) });
      res.json({ ok: true, uid: authUser.uid });
    });
  } catch (authErr: any) {
    if ((authErr.message || '').includes('EMAIL_EXISTS')) {
      return res.json({ error: 'Email already registered. Use Send Reset Email to set a new password.' });
    }
    return res.json({ error: authErr.message || 'Failed to create auth account' });
  }
});

// ── Transfer Approval / Rejection Emails ──────────────────────────────────────
function buildTransferApprovalEmail(d: any) {
  const { driverName, driverEmail, fromCompany, toCompany, vehicleInfo, plate, note, approvedAt } = d;
  const dateStr = approvedAt ? new Date(approvedAt).toLocaleDateString('en-NZ', { day:'numeric', month:'long', year:'numeric' }) : new Date().toLocaleDateString('en-NZ', { day:'numeric', month:'long', year:'numeric' });
  const noteRow = note ? `<tr><td style="padding:8px 14px;color:#666;font-size:13px;border-bottom:1px solid #f0f0f0">Note</td><td style="padding:8px 14px;font-size:13px;border-bottom:1px solid #f0f0f0;font-style:italic">${esc(note)}</td></tr>` : '';
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Transfer Approved &mdash; BookaWaka</title></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:32px 16px"><tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%">
<tr><td style="background:#1565C0;border-radius:10px 10px 0 0;padding:28px 32px;text-align:center"><div style="font-size:28px;margin-bottom:6px">&#128665;</div><div style="font-size:22px;font-weight:700;color:#fff">BookaWaka</div><div style="font-size:12px;color:rgba(255,255,255,.7);margin-top:4px;text-transform:uppercase;letter-spacing:.1em">Driver Platform</div></td></tr>
<tr><td style="background:#2E7D32;padding:16px 32px;text-align:center"><div style="font-size:18px;font-weight:700;color:#fff">&#10003;&nbsp; Transfer Request Approved</div></td></tr>
<tr><td style="background:#fff;padding:32px;border-radius:0 0 10px 10px;box-shadow:0 2px 8px rgba(0,0,0,.08)">
<p style="font-size:15px;color:#333;margin:0 0 10px">Hi <strong>${esc(driverName)}</strong>,</p>
<p style="font-size:14px;color:#555;line-height:1.6;margin:0 0 24px">Great news! Your request to transfer between companies on the BookaWaka platform has been reviewed and <strong style="color:#2E7D32">approved</strong>.</p>
<div style="background:#F8FBFF;border:1px solid #BBDEFB;border-radius:8px;overflow:hidden;margin-bottom:28px">
<div style="background:#E3F2FD;padding:10px 14px;font-size:12px;font-weight:700;color:#0D47A1;text-transform:uppercase">Transfer Summary</div>
<table width="100%" cellpadding="0" cellspacing="0">
<tr><td style="padding:8px 14px;color:#666;font-size:13px;border-bottom:1px solid #f0f0f0;width:40%">Previous Company</td><td style="padding:8px 14px;font-size:13px;border-bottom:1px solid #f0f0f0">${esc(fromCompany)}</td></tr>
<tr><td style="padding:8px 14px;color:#666;font-size:13px;border-bottom:1px solid #f0f0f0">New Company</td><td style="padding:8px 14px;font-size:13px;font-weight:700;color:#1565C0;border-bottom:1px solid #f0f0f0">${esc(toCompany)}</td></tr>
<tr><td style="padding:8px 14px;color:#666;font-size:13px;border-bottom:1px solid #f0f0f0">Vehicle</td><td style="padding:8px 14px;font-size:13px;border-bottom:1px solid #f0f0f0">${esc(vehicleInfo || '—')}${plate && plate !== '—' ? ` <span style="font-family:monospace;font-size:12px;color:#888">(${esc(plate)})</span>` : ''}</td></tr>
<tr><td style="padding:8px 14px;color:#666;font-size:13px;border-bottom:1px solid #f0f0f0">Effective Date</td><td style="padding:8px 14px;font-size:13px;border-bottom:1px solid #f0f0f0">${dateStr}</td></tr>
${noteRow}
</table></div>
<ul style="font-size:14px;color:#555;line-height:1.8;margin:0 0 24px;padding-left:20px">
<li>Your driver account is now linked to <strong>${esc(toCompany)}</strong></li>
<li>Log in to the BookaWaka Driver App — your new company settings will load automatically</li>
<li>Your trip history with your previous company remains on record</li>
</ul>
<hr style="border:none;border-top:1px solid #f0f0f0;margin:0 0 22px"/>
<p style="font-size:13px;color:#777;line-height:1.7;margin:0">BookaWaka is New Zealand's purpose-built taxi and mobility platform.</p>
</td></tr>
<tr><td style="padding:22px 0;text-align:center"><div style="font-size:12px;color:#aaa">&copy; ${new Date().getFullYear()} BookaWaka &mdash; New Zealand</div></td></tr>
</table></td></tr></table></body></html>`;
}

function buildTransferRejectionEmail(d: any) {
  const { driverName, fromCompany, toCompany, rejectionReason, rejectedAt } = d;
  const dateStr = rejectedAt ? new Date(rejectedAt).toLocaleDateString('en-NZ', { day:'numeric', month:'long', year:'numeric' }) : new Date().toLocaleDateString('en-NZ', { day:'numeric', month:'long', year:'numeric' });
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Transfer Request Declined &mdash; BookaWaka</title></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:32px 16px"><tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%">
<tr><td style="background:#1565C0;border-radius:10px 10px 0 0;padding:28px 32px;text-align:center"><div style="font-size:28px;margin-bottom:6px">&#128665;</div><div style="font-size:22px;font-weight:700;color:#fff">BookaWaka</div><div style="font-size:12px;color:rgba(255,255,255,.7);margin-top:4px;text-transform:uppercase;letter-spacing:.1em">Driver Platform</div></td></tr>
<tr><td style="background:#B71C1C;padding:16px 32px;text-align:center"><div style="font-size:18px;font-weight:700;color:#fff">&#10007;&nbsp; Transfer Request Declined</div></td></tr>
<tr><td style="background:#fff;padding:32px;border-radius:0 0 10px 10px;box-shadow:0 2px 8px rgba(0,0,0,.08)">
<p style="font-size:15px;color:#333;margin:0 0 10px">Hi <strong>${esc(driverName)}</strong>,</p>
<p style="font-size:14px;color:#555;line-height:1.6;margin:0 0 24px">We've reviewed your transfer request. Unfortunately, your request to transfer from <strong>${esc(fromCompany||'your current company')}</strong> to <strong>${esc(toCompany)}</strong> has been <strong style="color:#B71C1C">declined</strong>.</p>
<div style="background:#FFF3E0;border:1px solid #FFCC80;border-radius:8px;padding:18px 20px;margin-bottom:28px">
<div style="font-size:12px;font-weight:700;color:#E65100;text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px">Reason for Decline</div>
<p style="font-size:14px;color:#333;margin:0;line-height:1.6">${esc(rejectionReason||'No reason provided.')}</p>
</div>
<div style="background:#F8FBFF;border:1px solid #BBDEFB;border-radius:8px;overflow:hidden;margin-bottom:28px">
<div style="background:#E3F2FD;padding:10px 14px;font-size:12px;font-weight:700;color:#0D47A1;text-transform:uppercase">Transfer Details</div>
<table width="100%" cellpadding="0" cellspacing="0">
<tr><td style="padding:8px 14px;color:#666;font-size:13px;border-bottom:1px solid #f0f0f0;width:40%">From Company</td><td style="padding:8px 14px;font-size:13px;border-bottom:1px solid #f0f0f0">${esc(fromCompany||'—')}</td></tr>
<tr><td style="padding:8px 14px;color:#666;font-size:13px;border-bottom:1px solid #f0f0f0">Requested Transfer To</td><td style="padding:8px 14px;font-size:13px;border-bottom:1px solid #f0f0f0">${esc(toCompany||'—')}</td></tr>
<tr><td style="padding:8px 14px;color:#666;font-size:13px">Decision Date</td><td style="padding:8px 14px;font-size:13px">${dateStr}</td></tr>
</table></div>
<hr style="border:none;border-top:1px solid #f0f0f0;margin:0 0 22px"/>
<p style="font-size:13px;color:#777;line-height:1.7;margin:0">BookaWaka is New Zealand's purpose-built taxi and mobility platform.</p>
</td></tr>
<tr><td style="padding:22px 0;text-align:center"><div style="font-size:12px;color:#aaa">&copy; ${new Date().getFullYear()} BookaWaka &mdash; New Zealand</div></td></tr>
</table></td></tr></table></body></html>`;
}

router.post('/api/send-transfer-email', async (req, res) => {
  const { type, driverName, driverEmail, fromCompany, toCompany, vehicleInfo, plate, note, rejectionReason } = req.body;
  if (!driverEmail || !driverName || !toCompany) {
    return res.status(400).json({ error: 'Missing required fields: driverEmail, driverName, toCompany' });
  }
  const isRejection = type === 'rejected';
  try {
    const resend = await getResendClient();
    if (!resend) return res.status(500).json({ error: 'Email client unavailable' });
    const html = isRejection
      ? buildTransferRejectionEmail({ driverName, fromCompany: fromCompany || '—', toCompany, rejectionReason, rejectedAt: new Date().toISOString() })
      : buildTransferApprovalEmail({ driverName, driverEmail, fromCompany: fromCompany || '—', toCompany, vehicleInfo, plate, note, approvedAt: new Date().toISOString() });
    const subject = isRejection
      ? `Your Transfer Request Has Been Declined — BookaWaka`
      : `Your Transfer to ${toCompany} Has Been Approved — BookaWaka`;
    const result = await resend.emails.send({
      from: 'BookaWaka <info@bookawaka.com>',
      to: [driverEmail],
      subject,
      html
    }) as any;
    if (result.error) {
      console.error('Resend error:', result.error);
      return res.status(500).json({ error: result.error.message || 'Email send failed' });
    }
    console.log('Transfer', isRejection ? 'rejection' : 'approval', 'email sent to', driverEmail, '| id:', result.data && result.data.id);
    res.json({ ok: true, id: result.data && result.data.id });
  } catch (err: any) {
    console.error('Transfer email error:', err);
    res.status(500).json({ error: String(err.message || err) });
  }
});

// ── Company Email (General Compose) ──────────────────────────────────────────
function buildCompanyEmail(d: any) {
  const { companyName, toEmail, subject, body, refNo, amount, sentAt } = d;
  const dateStr = new Date(sentAt || Date.now()).toLocaleDateString('en-NZ', { day:'numeric', month:'long', year:'numeric' });
  const refRow = (refNo || amount) ? `
    <div style="background:#F8FBFF;border:1px solid #BBDEFB;border-radius:6px;padding:12px 16px;margin-bottom:22px;display:flex;gap:24px;flex-wrap:wrap">
      ${refNo ? `<div><span style="font-size:11px;color:#90A4AE;font-weight:700;text-transform:uppercase;letter-spacing:.05em">Reference</span><div style="font-size:14px;font-family:monospace;font-weight:700;color:#1565C0;margin-top:2px">${esc(refNo)}</div></div>` : ''}
      ${amount ? `<div><span style="font-size:11px;color:#90A4AE;font-weight:700;text-transform:uppercase;letter-spacing:.05em">Amount</span><div style="font-size:14px;font-weight:700;color:#1565C0;margin-top:2px">${esc(amount)}</div></div>` : ''}
    </div>` : '';
  const bodyHtml = String(body || '')
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
    .replace(/\n\n/g,'</p><p style="font-size:14px;color:#555;line-height:1.7;margin:0 0 12px">')
    .replace(/\n/g,'<br/>');
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${esc(subject)}</title></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:32px 16px"><tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%">
<tr><td style="background:#1565C0;border-radius:10px 10px 0 0;padding:24px 32px;text-align:center"><div style="font-size:26px;margin-bottom:5px">&#128665;</div><div style="font-size:20px;font-weight:700;color:#fff">BookaWaka</div><div style="font-size:11px;color:rgba(255,255,255,.65);margin-top:3px;text-transform:uppercase;letter-spacing:.1em">Admin Team</div></td></tr>
<tr><td style="background:#0D47A1;padding:12px 32px"><div style="font-size:15px;font-weight:600;color:#fff">${esc(subject)}</div><div style="font-size:11px;color:rgba(255,255,255,.6);margin-top:3px">To: ${esc(companyName)} &mdash; ${dateStr}</div></td></tr>
<tr><td style="background:#fff;padding:30px 32px;border-radius:0 0 10px 10px;box-shadow:0 2px 8px rgba(0,0,0,.08)">
${refRow}
<p style="font-size:14px;color:#555;line-height:1.7;margin:0 0 12px">${bodyHtml}</p>
<hr style="border:none;border-top:1px solid #f0f0f0;margin:28px 0 20px"/>
<p style="font-size:12px;color:#aaa;line-height:1.6;margin:0 0 6px"><strong style="color:#1565C0">BookaWaka</strong> — New Zealand's purpose-built taxi &amp; mobility platform.</p>
</td></tr>
<tr><td style="padding:20px 0;text-align:center"><div style="font-size:11px;color:#bbb">&copy; ${new Date().getFullYear()} BookaWaka Ltd &mdash; New Zealand<br/><span>This message was sent by a BookaWaka administrator to ${esc(companyName)}.</span></div></td></tr>
</table></td></tr></table></body></html>`;
}

router.post('/api/send-company-email', async (req, res) => {
  const { companyId, companyName, toEmail, cc, subject, body, refNo, amount } = req.body;
  if (!toEmail || !subject || !body) {
    return res.status(400).json({ error: 'Missing required fields: toEmail, subject, body' });
  }
  const sentAt = Date.now();
  const logEntry: any = {
    companyId: companyId || null, companyName: companyName || toEmail,
    toEmail, cc: cc && cc.length ? cc : null, subject,
    refNo: refNo || null, amount: amount || null, sentAt, sentBy: 'superadmin', status: 'pending'
  };
  try {
    const resend = await getResendClient();
    if (!resend) return res.status(500).json({ error: 'Email client unavailable' });
    const html = buildCompanyEmail({ companyName: companyName || toEmail, toEmail, subject, body, refNo, amount, sentAt });
    const payload: any = { from: 'BookaWaka Admin <info@bookawaka.com>', to: [toEmail], subject, html };
    if (cc && cc.length) payload.cc = cc;
    const result = await resend.emails.send(payload) as any;
    if (result.error) {
      logEntry.status = 'failed'; logEntry.error = result.error.message || 'Resend error';
      fbWrite('POST', 'emailLog', logEntry, () => {});
      console.error('Company email send error:', result.error);
      return res.status(500).json({ error: logEntry.error });
    }
    logEntry.status = 'sent'; logEntry.resendId = result.data && result.data.id;
    fbWrite('POST', 'emailLog', logEntry, () => {});
    console.log('Company email sent to', toEmail, '| id:', logEntry.resendId);
    res.json({ ok: true, id: logEntry.resendId });
  } catch (err: any) {
    logEntry.status = 'failed'; logEntry.error = String(err.message || err);
    fbWrite('POST', 'emailLog', logEntry, () => {});
    console.error('Company email error:', err);
    res.status(500).json({ error: logEntry.error });
  }
});

// ── Billing Overview ──────────────────────────────────────────────────────────
router.get('/api/admin/billing-overview', async (req, res) => {
  try {
    const [clients, billing] = await Promise.all([fbReadP('superClients'), fbReadP('superBilling')]);
    if (!clients) return res.json([]);
    const rows = Object.keys(clients).map(cid => {
      const c = clients[cid] || {};
      const b = (billing && billing[cid]) || {};
      const info = b.info || {};
      const invoices: any[] = Object.values(b.invoices || {});
      const sorted = invoices.slice().sort((a: any, b2: any) => (b2.period || '').localeCompare(a.period || ''));
      const latest = sorted[0] || null;
      const paid     = invoices.filter((i: any) => i.status === 'paid').length;
      const unpaid   = invoices.filter((i: any) => i.status === 'unpaid').length;
      const overdue  = invoices.filter((i: any) => i.status === 'overdue').length;
      const collected = invoices.filter((i: any) => i.status === 'paid').reduce((s: number, i: any) => s + (+(i.amount) || 0), 0);
      const outstanding = invoices.filter((i: any) => i.status !== 'paid').reduce((s: number, i: any) => s + (+(i.amount) || 0), 0);
      return { cid, name: c.name || cid, status: c.status || 'active', email: c.contactEmail || c.email || '', city: c.city || '', plan: info.packageName || c.plan || c.packageName || '', monthlyFee: info.monthlyFee || null, nextDueDate: info.nextDueDate || null, latestInvoice: latest, paid, unpaid, overdue, collected, outstanding, totalInvoices: invoices.length };
    });
    rows.sort((a, b2) => {
      const rank = (r: any) => r.overdue > 0 ? 0 : r.unpaid > 0 ? 1 : r.status === 'active' ? 2 : 3;
      return rank(a) - rank(b2);
    });
    res.json(rows);
  } catch (err: any) {
    res.status(500).json({ error: String(err.message || err) });
  }
});

// ── Billing Reminder Email ─────────────────────────────────────────────────────
async function sendBillingReminderEmail(toEmail: string, companyName: string, html: string, isOverdue: boolean, periodLabel: string) {
  try {
    const resend = await getResendClient();
    if (!resend) return { error: 'Email client unavailable' };
    const subject = isOverdue
      ? `Overdue Invoice — ${periodLabel} — BookaWaka`
      : `Invoice Reminder — ${periodLabel} — BookaWaka`;
    const result = await resend.emails.send({
      from: 'BookaWaka Billing <info@bookawaka.com>',
      to: [toEmail], subject, html
    }) as any;
    if (result.error) {
      console.error('[billing-reminder] Resend error:', result.error);
      return { error: result.error.message || String(result.error) };
    }
    console.log('[billing-reminder] Sent to', toEmail, '| id:', result.data && result.data.id);
    return { ok: true };
  } catch (e: any) {
    console.error('[billing-reminder] Exception:', e.message);
    return { error: String(e.message || e) };
  }
}

router.post('/api/admin/send-billing-reminder', async (req, res) => {
  const { cid, companyName, email, period, amount, status, invoiceId } = req.body || {};
  if (!email) return res.status(400).json({ error: 'No email address on file for this company' });
  if (!period || !amount) return res.status(400).json({ error: 'period and amount required' });
  const periodLabel = (() => {
    try { const [y, m] = period.split('-'); return new Date(+y, +m - 1, 1).toLocaleDateString('en-NZ', { month: 'long', year: 'numeric' }); }
    catch { return period; }
  })();
  const isOverdue = status === 'overdue';
  const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/></head><body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:30px 0"><tr><td align="center">
<table width="560" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
<tr><td style="background:${isOverdue ? '#B71C1C' : '#1565C0'};padding:28px 32px;text-align:center">
<div style="font-size:24px;font-weight:700;color:#fff">${isOverdue ? '&#9888; Overdue Invoice' : '&#128203; Invoice Reminder'}</div>
<div style="color:rgba(255,255,255,.8);font-size:14px;margin-top:6px">BookaWaka Platform</div>
</td></tr>
<tr><td style="padding:28px 32px">
<p style="font-size:15px;color:#333;margin-bottom:20px">Hi <strong>${esc(companyName || 'there')}</strong>,</p>
<p style="font-size:14px;color:#555;line-height:1.6;margin-bottom:20px">${isOverdue ? `This is a reminder that your subscription invoice for <strong>${periodLabel}</strong> is <strong style="color:#B71C1C">overdue</strong>. Please arrange payment as soon as possible to avoid service interruption.` : `This is a friendly reminder that your subscription invoice for <strong>${periodLabel}</strong> is due for payment.`}</p>
<table width="100%" cellpadding="0" cellspacing="0" style="background:#F8F9FA;border-radius:6px;padding:20px;margin-bottom:24px;border-left:4px solid ${isOverdue ? '#B71C1C' : '#1565C0'}">
<tr><td><strong style="font-size:13px;color:#757575;text-transform:uppercase;letter-spacing:.5px">Invoice Period</strong><br/><span style="font-size:16px;font-weight:700;color:#263238">${periodLabel}</span></td></tr>
<tr><td height="12"></td></tr>
<tr><td><strong style="font-size:13px;color:#757575;text-transform:uppercase;letter-spacing:.5px">Amount Due</strong><br/><span style="font-size:28px;font-weight:700;color:${isOverdue ? '#B71C1C' : '#1565C0'}">$${(+amount).toFixed(2)} NZD</span></td></tr>
</table>
<p style="font-size:14px;color:#555;line-height:1.6;margin-bottom:24px">To pay or discuss your account, please reply to this email or contact the BookaWaka team directly.</p>
<hr style="border:none;border-top:1px solid #eee;margin-bottom:20px"/>
<p style="font-size:12px;color:#aaa;text-align:center">BookaWaka &bull; <a href="https://bookawaka.co.nz" style="color:#1565C0">bookawaka.co.nz</a></p>
</td></tr>
</table>
</td></tr></table></body></html>`;
  try {
    const sent = await sendBillingReminderEmail(email, companyName, html, isOverdue, periodLabel);
    if (sent.error) return res.status(500).json({ error: sent.error });
    fbWrite('PUT', `superBilling/${cid}/reminders/${Date.now()}`, { sentAt: new Date().toISOString(), period, amount, email, status }, () => {});
    res.json({ ok: true });
  } catch (err: any) {
    res.status(500).json({ error: String(err.message || err) });
  }
});

// ── SA View-As ────────────────────────────────────────────────────────────────
router.post('/api/admin/view-as', (req, res) => {
  const { cid, cidName, saUid } = req.body || {};
  if (!cid || !saUid) return res.status(400).json({ error: 'cid and saUid required' });
  isSuperAdmin(saUid, (err: any, isSA: boolean) => {
    if (err || !isSA) return res.status(403).json({ error: 'Not authorised as SA admin' });
    const now = Date.now();
    for (const k of Object.keys(saViewSessions)) {
      if (saViewSessions[k].expires < now) { delete saViewSessions[k]; unpersistSessionDirect('saView', k); }
    }
    const token = genToken(56);
    const sess = { cid, cidName: cidName || cid, saUid, expires: now + SA_VIEW_TTL };
    saViewSessions[token] = sess;
    persistSessionDirect('saView', token, sess);
    console.log('[view-as] SA uid', saUid, 'opened view-as for company', cid);
    res.json({ token });
  });
});

router.get('/api/admin/sa-view-session', (req, res) => {
  const token = ((req.query.token as string) || '').trim();
  if (!token) return res.status(400).json({ error: 'No token' });
  const session = saViewSessions[token];
  if (!session || session.expires < Date.now()) {
    delete saViewSessions[token];
    unpersistSessionDirect('saView', token);
    return res.status(403).json({ error: 'Session expired or invalid — please start a new View-As session' });
  }
  res.json({ cid: session.cid, cidName: session.cidName });
});

// ── Panel users ────────────────────────────────────────────────────────────────
router.get('/api/admin/panel-users/:cid', (req, res) => {
  const cid = req.params.cid;
  fbRead('adminAccess/' + cid, async (err, data) => {
    if (err) return res.status(500).json({ error: String(err) });
    if (!data) return res.json([]);
    const uids = Object.keys(data).filter(uid => data[uid] === true);
    if (!uids.length) return res.json([]);
    try {
      const result = await authRestPost('lookup', { localId: uids }) as any;
      const users = (result.users || []).map((u: any) => ({ uid: u.localId, email: u.email || '' }));
      res.json(users);
    } catch (e) {
      res.json(uids.map(uid => ({ uid, email: '' })));
    }
  });
});

// ── Per-company Stripe keys (stripeConfig/{cid}) ─────────────────────────────
router.get('/api/admin/stripe-config/:cid', async (req, res) => {
  const cid = String(req.params.cid || '').trim();
  if (!cid) return res.status(400).json({ error: 'cid required' });
  try {
    const data = (await fbReadP('stripeConfig/' + cid)) || {};
    res.json({
      ok: true,
      stripePublishableKey: data.stripePublishableKey || data.publishableKey || data.publishable_key || '',
      stripeSecretKey: data.stripeSecretKey || data.secretKey || data.secret_key || '',
      stripeWebhookSecret: data.stripeWebhookSecret || data.webhookSecret || data.webhook_secret || '',
      updatedAt: data.updatedAt || null,
      updatedBy: data.updatedBy || null,
    });
  } catch (e: any) {
    res.status(500).json({ error: e.message || String(e) });
  }
});

router.post('/api/admin/stripe-config/:cid', async (req, res) => {
  const cid = String(req.params.cid || '').trim();
  if (!cid) return res.status(400).json({ error: 'cid required' });
  const pub = String(req.body?.stripePublishableKey || '').trim();
  const sec = String(req.body?.stripeSecretKey || '').trim();
  const wh  = String(req.body?.stripeWebhookSecret || '').trim();
  const actor = String(req.body?._saEmail || 'sa-admin').trim();
  if (!pub && !sec && !wh) return res.status(400).json({ error: 'At least one Stripe key is required' });
  if (pub && !pub.startsWith('pk_')) return res.status(400).json({ error: 'Publishable key must start with pk_' });
  if (sec && !sec.startsWith('sk_')) return res.status(400).json({ error: 'Secret key must start with sk_' });
  if (wh && !wh.startsWith('whsec_')) return res.status(400).json({ error: 'Webhook secret must start with whsec_' });
  try {
    const existing = (await fbReadP('stripeConfig/' + cid)) || {};
    const payload = {
      ...existing,
      stripePublishableKey: pub || existing.stripePublishableKey || existing.publishableKey || '',
      stripeSecretKey: sec || existing.stripeSecretKey || existing.secretKey || '',
      stripeWebhookSecret: wh || existing.stripeWebhookSecret || existing.webhookSecret || '',
      publishableKey: pub || existing.publishableKey || existing.stripePublishableKey || '',
      secretKey: sec || existing.secretKey || existing.stripeSecretKey || '',
      webhookSecret: wh || existing.webhookSecret || existing.stripeWebhookSecret || '',
      updatedAt: Date.now(),
      updatedBy: actor,
    };
    await fbWriteP('PATCH', 'stripeConfig/' + cid, payload);
    logAudit('stripe_config_updated', `cid=${cid} publishable=${!!pub} secret=${!!sec} webhook=${!!wh}`, actor);
    res.json({ ok: true });
  } catch (e: any) {
    res.status(500).json({ error: e.message || String(e) });
  }
});

// ── Reset owner password ───────────────────────────────────────────────────────
router.post('/api/admin/reset-owner-password', async (req, res) => {
  const { email } = req.body || {};
  if (!email) return res.status(400).json({ error: 'Email required' });
  try {
    const result = await authRestPost('sendOobCode', { requestType: 'PASSWORD_RESET', email }) as any;
    if (result.error) return res.status(400).json({ error: result.error.message || 'Failed to send reset email' });
    console.log('[reset-password] Password reset email sent to', email);
    res.json({ ok: true });
  } catch (err: any) {
    res.status(500).json({ error: String(err.message || err) });
  }
});

// ── Audit log ─────────────────────────────────────────────────────────────────
router.get('/api/admin/audit-log', (req, res) => {
  fbRead('superAuditLog', (err, data) => {
    if (err) return res.status(500).json({ error: String(err) });
    const entries: any[] = [];
    if (data && typeof data === 'object') {
      Object.keys(data).forEach(k => {
        const e = data[k];
        if (e && e.ts) entries.push(Object.assign({ _key: k }, e));
      });
    }
    entries.sort((a, b) => b.ts - a.ts);
    res.json({ entries });
  });
});

// ── Revoke access ─────────────────────────────────────────────────────────────
router.post('/api/admin/revoke-access', (req, res) => {
  const { cid, uid, _saEmail } = req.body || {};
  if (!cid || !uid) return res.status(400).json({ error: 'cid and uid required' });
  fbWrite('DELETE', 'adminAccess/' + cid + '/' + uid, null, (err) => {
    if (err) return res.status(500).json({ error: String(err) });
    fbWrite('DELETE', 'users/' + uid + '/companyId', null, () => {});
    console.log('[revoke-access] Revoked uid', uid, 'from company', cid);
    logAudit('access_revoked', `cid=${String(cid)} | uid=${uid} | Panel access revoked`, _saEmail || 'sa-admin');
    res.json({ ok: true });
  });
});

// ── Direct Onboarding ─────────────────────────────────────────────────────────
router.post('/api/admin/direct-onboard', async (req, res) => {
  const { name, email, city, country, contactName, phone, plan, notes } = req.body || {};
  if (!name || !email) return res.status(400).json({ error: 'Company name and admin email are required' });
  try {
    let uid: string | null = null;
    let tempPassword: string | null = null;
    let autoCreated = false;
    let needsManualAccess = false;
    try {
      tempPassword = generateTempPassword();
      const created = await createFirebaseAuthUser(email, tempPassword);
      uid = created.uid;
      autoCreated = true;
      console.log('[direct-onboard] Created Firebase Auth for', email, 'uid:', uid);
    } catch (authErr: any) {
      if ((authErr.message || '').includes('EMAIL_EXISTS')) {
        uid = null; tempPassword = null; needsManualAccess = true;
        console.log('[direct-onboard] EMAIL_EXISTS for', email, '— company will be created, access grant deferred');
      } else { throw authErr; }
    }
    const existing = await new Promise<any>(resolve => fbRead('superClients', (e, d) => resolve(d || {})));
    let cid: string;
    let attempts = 0;
    do {
      cid = String(Math.floor(100000 + Math.random() * 900000));
      attempts++;
    } while (existing[cid] && attempts < 20);
    const now = Date.now();
    await new Promise<void>((resolve, reject) => {
      fbWrite('PUT', 'superClients/' + cid, {
        name: name.trim(), email: email.trim(), city: (city || '').trim(), country: (country || '').trim(),
        contactName: (contactName || '').trim(), phone: (phone || '').trim(), plan: (plan || '').trim(),
        notes: (notes || '').trim(), status: 'trial', createdAt: now, onboardedBy: 'direct-sa'
      }, (e) => e ? reject(new Error(String(e))) : resolve());
    });
    if (uid) {
      await grantOwnerFirebaseAccess(cid, uid, name.trim());
    }
    console.log('[direct-onboard] Company', cid, '(' + name + ') onboarded successfully' + (needsManualAccess ? ' [access grant deferred]' : ''));
    logAudit('company_onboarded', `cid=${cid} | ${name} | email=${email} | plan=${plan || 'trial'}${autoCreated ? ' | account auto-created' : ''}${needsManualAccess ? ' | access grant deferred (existing account)' : ''}`, req.body._saEmail || 'sa-admin');
    sendWelcomeEmail({ companyName: name, email, cid, tempPassword })
      .then(r => { if (r.ok) console.log('[direct-onboard] Welcome email sent to', email); })
      .catch(() => {});
    res.json({ ok: true, cid, uid, email, name, autoCreated, tempPassword, needsManualAccess });
  } catch (err: any) {
    console.error('[direct-onboard] Error:', err.message || err);
    res.status(500).json({ error: String(err.message || err) });
  }
});

// ── Grant SA admin ────────────────────────────────────────────────────────────
router.get('/api/admin/grant-sa', (req, res) => {
  const { uid, key } = req.query as any;
  const dbSecret = process.env.FIREBASE_DB_SECRET || '';
  if (!uid) return res.status(400).send('<h2>Error: uid param required</h2>');
  if (!key || key !== dbSecret) return res.status(403).send('<h2>Error: Invalid key</h2>');
  fbWrite('PUT', 'superAdmins/' + uid, true, (err) => {
    if (err) return res.status(500).send('<h2>Error writing to Firebase: ' + String(err) + '</h2>');
    console.log('[grant-sa] Granted SA admin access to uid', uid, '(superAdmins node)');
    res.send(`<!DOCTYPE html><html><head><meta charset="utf-8">
<style>body{font-family:sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f0fdf4}
.box{background:#fff;border-radius:12px;padding:40px;text-align:center;box-shadow:0 4px 20px rgba(0,0,0,.1);max-width:440px}
h2{color:#16a34a;margin:0 0 12px}p{color:#555;margin:0 0 20px}a{display:inline-block;background:#1565C0;color:#fff;padding:10px 24px;border-radius:6px;text-decoration:none;font-weight:600}
</style></head><body><div class="box">
<h2>&#10003; SA Admin Access Granted</h2>
<p>UID <code>${uid}</code> has been added to <code>superAdmins/</code> in Firebase.<br><br>
You can now log in to the SA portal and use <strong>View as Company</strong>.</p>
<a href="/Home.aspx">Go to SA Portal &rarr;</a>
</div></body></html>`);
  });
});

// ── Trial Expiry Alerts ───────────────────────────────────────────────────────
router.post('/api/admin/trial-expiry-alerts', async (req, res) => {
  try {
    const dbSecret = process.env.FIREBASE_DB_SECRET || '';
    const clientsResp = await fetch(`${DB_BASE}/superClients.json?auth=${dbSecret}`);
    const clients: any = await clientsResp.json();
    if (!clients || typeof clients !== 'object') return res.json({ ok: true, sent: 0 });
    const alertsResp = await fetch(`${DB_BASE}/superAlerts/trialExpiry.json?auth=${dbSecret}`);
    const alerts: any = (await alertsResp.json()) || {};
    const now = Date.now();
    const threeDays = 3 * 24 * 60 * 60 * 1000;
    const debounce  = 23 * 60 * 60 * 1000;
    const expiring: [string, any][] = Object.entries(clients).filter(([cid, c]: [string, any]) => {
      if (c.status !== 'trial' || !c.trialEnd) return false;
      const trialEndMs = typeof c.trialEnd === 'number' ? c.trialEnd : new Date(c.trialEnd).getTime();
      if (isNaN(trialEndMs)) return false;
      const daysLeft = (trialEndMs - now) / (24 * 60 * 60 * 1000);
      if (daysLeft > 3 || daysLeft < 0) return false;
      const lastAlert = alerts[cid] && alerts[cid].sentAt ? alerts[cid].sentAt : 0;
      return (now - lastAlert) >= debounce;
    }) as [string, any][];
    if (!expiring.length) return res.json({ ok: true, sent: 0, message: 'No expiring trials needing alert' });
    const resend = await getResendClient();
    if (!resend) return res.status(500).json({ ok: false, error: 'Email client unavailable' });
    const SA_ALERT_EMAIL = process.env.SA_ALERT_EMAIL || 'info@bookawaka.com';
    let sent = 0;
    for (const [cid, c] of expiring) {
      const trialEndMs = typeof c.trialEnd === 'number' ? c.trialEnd : new Date(c.trialEnd).getTime();
      const daysLeft = Math.ceil((trialEndMs - now) / (24 * 60 * 60 * 1000));
      const trialEndDate = new Date(trialEndMs).toLocaleDateString('en-NZ', { day: 'numeric', month: 'long', year: 'numeric' });
      const name = c.name || cid;
      const htmlBody = `<div style="font-family:Arial,sans-serif;max-width:560px;margin:0 auto;padding:20px">
<div style="background:#E65100;color:#fff;padding:14px 20px;border-radius:8px 8px 0 0"><h2 style="margin:0;font-size:17px">&#9200; Trial Expiry Alert — ${daysLeft} day${daysLeft!==1?'s':''} remaining</h2></div>
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:0 0 8px 8px;padding:20px">
<p style="margin-top:0">The following company's trial is about to expire:</p>
<table style="width:100%;border-collapse:collapse;font-size:14px">
<tr><td style="padding:7px 10px;font-weight:600;color:#555;background:#f8f8f8;width:140px">Company</td><td style="padding:7px 10px;font-weight:700">${esc(name)}</td></tr>
<tr><td style="padding:7px 10px;font-weight:600;color:#555;background:#f8f8f8">Company ID</td><td style="padding:7px 10px;font-family:monospace">${esc(cid)}</td></tr>
<tr><td style="padding:7px 10px;font-weight:600;color:#555;background:#f8f8f8">Trial Ends</td><td style="padding:7px 10px;color:#C62828;font-weight:700">${trialEndDate} (${daysLeft} day${daysLeft!==1?'s':''} left)</td></tr>
${c.contactEmail ? `<tr><td style="padding:7px 10px;font-weight:600;color:#555;background:#f8f8f8">Contact</td><td style="padding:7px 10px"><a href="mailto:${esc(c.contactEmail)}">${esc(c.contactEmail)}</a></td></tr>` : ''}
</table>
<p style="margin-top:16px;font-size:12px;color:#aaa">This is an automated alert from BookaWaka Super Admin. Alerts send at most once every 23 hours per company.</p>
</div></div>`;
      const result = await resend.emails.send({
        from: 'BookaWaka Admin <info@bookawaka.com>',
        to: [SA_ALERT_EMAIL],
        subject: `&#9200; Trial Expiry: ${name} — ${daysLeft} day${daysLeft!==1?'s':''} left`,
        html: htmlBody
      }) as any;
      if (!result.error) {
        await fetch(`${DB_BASE}/superAlerts/trialExpiry/${encodeURIComponent(cid)}.json?auth=${dbSecret}`, {
          method: 'PUT', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ cid, name, sentAt: now, daysLeft })
        });
        sent++;
      } else {
        console.error('[trial-expiry-alert] Resend error for', cid, ':', result.error);
      }
    }
    console.log(`[trial-expiry-alert] Sent ${sent} alert(s) for ${expiring.length} expiring trial(s)`);
    res.json({ ok: true, sent, total: expiring.length });
  } catch (err: any) {
    console.error('[trial-expiry-alert] Error:', err);
    res.status(500).json({ ok: false, error: String(err.message || err) });
  }
});

// ── Deploy Firebase Rules ─────────────────────────────────────────────────────
router.post('/admin/deploy-firebase-rules', async (req, res) => {
  const key = (req.headers['x-admin-key'] as string) || '';
  if (key !== ADMIN_API_KEY) return res.status(403).json({ ok: false, error: 'Forbidden' });
  const dbSecret = process.env.FIREBASE_DB_SECRET || '';
  if (!dbSecret) return res.status(500).json({ ok: false, error: 'FIREBASE_DB_SECRET not set' });
  try {
    const rulesPath = path.join(process.cwd(), 'database.rules.json');
    let rulesJson: string;
    try { rulesJson = fs.readFileSync(rulesPath, 'utf8'); }
    catch { return res.status(404).json({ ok: false, error: 'database.rules.json not found' }); }
    JSON.parse(rulesJson);
    const r = await fetch(`https://taxilatest.firebaseio.com/.settings/rules.json?auth=${dbSecret}`, {
      method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: rulesJson
    });
    const data: any = await r.json();
    if (data.status === 'ok' || data.rules) {
      console.log('[deploy-firebase-rules] Rules deployed successfully');
      res.json({ ok: true, message: 'Firebase rules deployed successfully' });
    } else {
      res.status(500).json({ ok: false, error: JSON.stringify(data) });
    }
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ── Auto-mark overdue invoices ────────────────────────────────────────────────
router.post('/api/admin/mark-overdue-invoices', async (req, res) => {
  try {
    const dbSecret = process.env.FIREBASE_DB_SECRET || '';
    const now = Date.now();
    const billingResp = await fetch(`${DB_BASE}/superBilling.json?auth=${dbSecret}`);
    const billing: any = await billingResp.json();
    if (!billing || typeof billing !== 'object') return res.json({ ok: true, marked: 0 });
    const updates: any = {};
    let marked = 0;
    Object.entries(billing).forEach(([cid, compData]: [string, any]) => {
      const invoices = (compData && compData.invoices) || {};
      Object.entries(invoices).forEach(([invId, inv]: [string, any]) => {
        if (!inv || inv.status !== 'unpaid' || !inv.period) return;
        const [y, m] = inv.period.split('-').map(Number);
        if (!y || !m) return;
        const dueDate = new Date(y, m, 15).getTime();
        if (now > dueDate) {
          updates[`superBilling/${cid}/invoices/${invId}/status`] = 'overdue';
          updates[`superBilling/${cid}/invoices/${invId}/markedOverdueAt`] = new Date().toISOString();
          marked++;
        }
      });
    });
    if (marked === 0) return res.json({ ok: true, marked: 0, message: 'No invoices to mark overdue' });
    await fetch(`${DB_BASE}/.json?auth=${dbSecret}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(updates)
    });
    console.log(`[mark-overdue] Marked ${marked} invoice(s) as overdue`);
    res.json({ ok: true, marked });
  } catch (err: any) {
    console.error('[mark-overdue] Error:', err);
    res.status(500).json({ ok: false, error: String(err.message || err) });
  }
});

// ── Send invoice email ────────────────────────────────────────────────────────
router.post('/api/admin/send-invoice', async (req, res) => {
  const { cid, companyName, email, period, amount, status, invoiceId } = req.body || {};
  if (!email) return res.status(400).json({ error: 'No email for this company' });
  if (!period || !amount) return res.status(400).json({ error: 'period and amount required' });
  const periodLabel = (() => {
    try { const [y, m] = period.split('-'); return new Date(+y, +m - 1, 1).toLocaleDateString('en-NZ', { month: 'long', year: 'numeric' }); }
    catch { return period; }
  })();
  const isPaid = status === 'paid';
  const isOverdue = status === 'overdue';
  const now = new Date().toLocaleDateString('en-NZ', { day: 'numeric', month: 'long', year: 'numeric' });
  const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/></head><body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:30px 0"><tr><td align="center">
<table width="560" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
<tr><td style="background:#1565C0;padding:28px 32px;text-align:center"><div style="font-size:26px;font-weight:700;color:#fff">&#128179; TAX INVOICE</div><div style="color:rgba(255,255,255,.8);font-size:14px;margin-top:6px">BookaWaka Platform &mdash; ${periodLabel}</div></td></tr>
<tr><td style="padding:28px 32px">
<table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:24px">
<tr><td valign="top" width="50%"><div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#aaa;margin-bottom:4px">Billed To</div><div style="font-size:16px;font-weight:700;color:#263238">${esc(companyName || '')}</div><div style="font-size:12px;color:#888;margin-top:2px">Company ID: ${esc(cid || '')}</div></td>
<td valign="top" width="50%" align="right"><div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#aaa;margin-bottom:4px">Invoice Date</div><div style="font-size:13px;color:#263238">${now}</div><div style="margin-top:4px;display:inline-block;padding:3px 10px;background:${isPaid?'#E8F5E9':isOverdue?'#FFEBEE':'#FFF3E0'};color:${isPaid?'#2E7D32':isOverdue?'#C62828':'#E65100'};border-radius:6px;font-size:12px;font-weight:700">${isPaid?'PAID':isOverdue?'OVERDUE':'UNPAID'}</div></td></tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;font-size:14px;margin-bottom:20px">
<tr style="background:#E3F2FD"><th style="padding:10px 14px;text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:#0D47A1">Description</th><th style="padding:10px 14px;text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:#0D47A1">Period</th><th style="padding:10px 14px;text-align:right;font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:#0D47A1">Amount (NZD)</th></tr>
<tr style="border-bottom:1px solid #f0f0f0"><td style="padding:12px 14px;color:#333">BookaWaka SaaS Subscription</td><td style="padding:12px 14px;color:#555">${periodLabel}</td><td style="padding:12px 14px;text-align:right;font-weight:700;color:#1565C0">$${(+amount).toFixed(2)}</td></tr>
<tr style="background:#f8f9fa"><td colspan="2" style="padding:12px 14px;font-weight:700;color:#263238;text-align:right">Total Due</td><td style="padding:12px 14px;text-align:right;font-size:20px;font-weight:700;color:#1565C0">$${(+amount).toFixed(2)} NZD</td></tr>
</table>
<p style="font-size:13px;color:#555;line-height:1.6;margin-bottom:24px">Please reply to this email or contact the BookaWaka team to arrange payment.</p>
<hr style="border:none;border-top:1px solid #eee;margin-bottom:20px"/>
<p style="font-size:12px;color:#aaa;text-align:center">BookaWaka &bull; <a href="https://bookawaka.co.nz" style="color:#1565C0">bookawaka.co.nz</a></p>
</td></tr></table></td></tr></table></body></html>`;
  try {
    const resend = await getResendClient();
    if (!resend) return res.status(500).json({ error: 'Email client unavailable' });
    const result = await resend.emails.send({
      from: 'BookaWaka Billing <info@bookawaka.com>', to: [email],
      subject: `Invoice — ${periodLabel} — BookaWaka`, html
    }) as any;
    if (result.error) return res.status(500).json({ error: result.error.message || String(result.error) });
    fbWrite('PUT', `superBilling/${cid}/invoiceSentLog/${Date.now()}`, { sentAt: new Date().toISOString(), period, amount, email, invoiceId: invoiceId || null }, () => {});
    console.log('[send-invoice] Sent to', email, '| period:', period);
    res.json({ ok: true });
  } catch (err: any) {
    res.status(500).json({ error: String(err.message || err) });
  }
});

// ── Company Payout Summary ────────────────────────────────────────────────────
async function calcCompanyEarnings(cid: string, sinceTs: number) {
  const since = sinceTs || 0;
  const safeRead = (p: string) => fbReadP(p).catch(() => null);
  const [sc, jobs, foodOrds, freightOrds] = await Promise.all([
    safeRead('superClients/' + cid), safeRead('completedJobs/' + cid),
    safeRead('foodOrders/' + cid), safeRead('freightOrders/' + cid)
  ]);
  const commPct = parseFloat((sc && sc.commissionPct) || 15);
  let taxiGross = 0, taxiCom = 0, taxiNet = 0, taxiTrips = 0;
  Object.values(jobs || {}).forEach((t: any) => {
    if ((t.completedAt || t.createdAt || 0) > since) {
      const fare = parseFloat(t.fare || 0);
      const com  = fare * commPct / 100;
      taxiGross += fare; taxiCom += com; taxiNet += (fare - com); taxiTrips++;
    }
  });
  let foodGross = 0, foodCom = 0, foodNet = 0, foodOrders = 0;
  Object.values(foodOrds || {}).forEach((o: any) => {
    if (o.status === 'delivered' && (o.createdAt || 0) > since) {
      foodGross += parseFloat(o.subtotal || 0); foodCom += parseFloat(o.foodCommission || 0);
      foodNet += parseFloat(o.restaurantPayout || 0); foodOrders++;
    }
  });
  let freightGross = 0, freightCom = 0, freightNet = 0, freightJobs = 0;
  Object.values(freightOrds || {}).forEach((o: any) => {
    if (o.status === 'delivered' && (o.createdAt || 0) > since) {
      freightGross += parseFloat(o.amount || 0); freightCom += parseFloat(o.freightCommission || 0);
      freightNet += parseFloat(o.freightPayout || 0); freightJobs++;
    }
  });
  const totalNet = taxiNet + foodNet + freightNet;
  return {
    companyId: cid, companyName: (sc && sc.name) || ('Company ' + cid),
    stripeConnectId: (sc && sc.stripeConnectId) || null, payoutSchedule: (sc && sc.payoutSchedule) || 'weekly',
    lastPayoutAt: (sc && sc.lastPayoutAt) || 0, commissionPct: commPct, totalNet,
    totalGross: taxiGross + foodGross + freightGross, totalCommission: taxiCom + foodCom + freightCom,
    taxi:    { gross: taxiGross,    commission: taxiCom,    net: taxiNet,    trips: taxiTrips },
    food:    { gross: foodGross,    commission: foodCom,    net: foodNet,    orders: foodOrders },
    freight: { gross: freightGross, commission: freightCom, net: freightNet, jobs: freightJobs }
  };
}

// ── Company Earnings Portal ───────────────────────────────────────────────────
function requireCompanyEarningsAuth(req: any, res: any, next: any) {
  const uid = req.session && req.session.companyEarningsUid;
  const cid = req.session && req.session.companyEarningsCid;
  if (!uid || !cid) return res.redirect('/company-earnings-portal');
  req.cepUid = uid; req.cepCid = cid; req.cepName = (req.session.companyEarningsName || cid);
  next();
}

router.get('/company-earnings-portal', (req, res) => {
  const err = (req.query.err as string) || '';
  const errMsgs: any = { invalid: 'Invalid email or password.', missing: 'Please enter your email and password.', nodata: 'Account not found.', session: 'Session expired.' };
  const errHtml = err ? `<div style="background:#FFEBEE;color:#C62828;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px;border-left:4px solid #C62828">${esc(errMsgs[err] || err)}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Company Earnings Portal — BookaWaka</title>
<style>*{box-sizing:border-box;margin:0;padding:0}
body{background:linear-gradient(135deg,#0D47A1,#1565C0);min-height:100vh;display:flex;align-items:center;justify-content:center;font-family:'Segoe UI',system-ui,sans-serif}
.box{background:#fff;border-radius:10px;padding:40px;width:400px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25)}
h1{font-size:22px;color:#0D47A1;margin-bottom:4px}.sub{color:#888;font-size:13px;margin-bottom:28px}
label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
input{width:100%;padding:10px 12px;border:1px solid #ddd;border-radius:6px;font-size:14px;margin-bottom:18px}
input:focus{outline:none;border-color:#1565C0;box-shadow:0 0 0 3px rgba(21,101,192,.1)}
button{width:100%;padding:12px;background:#1565C0;color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:600;cursor:pointer}
button:hover{background:#0D47A1}.hint{text-align:center;font-size:12px;color:#aaa;margin-top:18px}</style>
</head><body><div class="box">
<h1>&#128188; Company Earnings</h1>
<p class="sub">BookaWaka &mdash; Operator Portal</p>
${errHtml}
<form method="POST" action="/api/company-earnings-login">
<label>Email Address</label>
<input type="email" name="email" required autocomplete="email" placeholder="operator@yourcompany.com"/>
<label>Password</label>
<input type="password" name="password" required autocomplete="current-password"/>
<button type="submit">Sign In</button>
</form>
<p class="hint">Contact your BookaWaka administrator for access.</p>
</div></body></html>`);
});

router.post('/api/company-earnings-login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.redirect('/company-earnings-portal?err=missing');
  try {
    const idToken = await firebaseSignIn(email, password);
    if (!idToken) return res.redirect('/company-earnings-portal?err=invalid');
    const uid = await verifyFirebaseToken(idToken);
    if (!uid) return res.redirect('/company-earnings-portal?err=nodata');
    const clients = await fbReadP('superClients');
    let matchCid: string | null = null, matchName: string | null = null;
    for (const [cid, sc] of Object.entries(clients || {}) as [string, any][]) {
      const access = await fbReadP('companyPortalAccess/' + cid);
      if (access && (access.uid === uid || access.email === email)) { matchCid = cid; matchName = sc.name || cid; break; }
    }
    if (!matchCid) return res.redirect('/company-earnings-portal?err=nodata');
    (req as any).session.companyEarningsUid = uid;
    (req as any).session.companyEarningsCid = matchCid;
    (req as any).session.companyEarningsName = matchName;
    res.redirect('/company-earnings-portal/dashboard');
  } catch (e) { res.redirect('/company-earnings-portal?err=invalid'); }
});

router.get('/company-earnings-portal/dashboard', requireCompanyEarningsAuth, async (req: any, res) => {
  const cid = req.cepCid, name = req.cepName;
  try {
    const sc = await fbReadP('superClients/' + cid);
    const earnings = await calcCompanyEarnings(cid, (sc && sc.lastPayoutAt) || 0);
    const payoutsRaw = await fbReadP('companyPayouts/' + cid);
    const payouts: any[] = Object.values(payoutsRaw || {}).sort((a: any, b: any) => (b.triggeredAt||0) - (a.triggeredAt||0)).slice(0, 10);
    const schedule = (sc && sc.payoutSchedule) || 'weekly';
    const lastPayout = (sc && sc.lastPayoutAt) ? new Date(sc.lastPayoutAt).toLocaleDateString('en-NZ', { day:'2-digit', month:'short', year:'numeric' }) : 'Never';
    const fmtAmt = (v: any) => '$' + parseFloat(v||0).toFixed(2);
    const payoutRows = payouts.map((p: any) => {
      const dt = p.triggeredAt ? new Date(p.triggeredAt).toLocaleDateString('en-NZ', { day:'2-digit', month:'short', year:'numeric' }) : '—';
      const bk = p.breakdown || {};
      return `<tr><td>${dt}</td><td style="color:#2E7D32;font-weight:700">${fmtAmt(p.amount)}</td><td><span style="background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7">PAID</span></td><td style="font-size:11.5px;color:#666">Taxi ${fmtAmt(bk.taxi&&bk.taxi.net)} &middot; Food ${fmtAmt(bk.food&&bk.food.net)} &middot; Freight ${fmtAmt(bk.freight&&bk.freight.net)}</td><td style="font-family:monospace;font-size:11px;color:#999">${esc(p.stripeTransferId||'—')}</td></tr>`;
    }).join('') || '<tr><td colspan="5" style="color:#aaa;text-align:center;padding:18px">No payouts yet</td></tr>';
    const subDeduct = parseFloat((sc && sc.subscriptionDeductPending) || 0);
    const netAfterSub = earnings.totalNet - subDeduct;
    res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(name)} Earnings — BookaWaka</title>
<style>*{box-sizing:border-box;margin:0;padding:0}
body{background:#F3F6FB;font-family:'Segoe UI',system-ui,sans-serif;color:#222}
.hd{background:#0D47A1;color:#fff;padding:16px 28px;display:flex;align-items:center;justify-content:space-between}
.hd h1{font-size:17px;font-weight:700}.hd a{color:#90CAF9;font-size:13px;text-decoration:none}
.wrap{max-width:960px;margin:28px auto;padding:0 20px}
.stats{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:14px;margin-bottom:24px}
.stat{background:#fff;border-radius:8px;padding:16px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1)}
.stat .lbl{font-size:11px;color:#888;font-weight:500;margin-bottom:4px;text-transform:uppercase;letter-spacing:.4px}
.stat .val{font-size:24px;font-weight:800;color:#0D47A1}
.stat.green .val{color:#2E7D32}.stat.orange .val{color:#E65100}.stat.red .val{color:#C62828}
.card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:20px;overflow:hidden}
.card-hd{background:#0D47A1;color:#fff;padding:12px 18px;font-size:14px;font-weight:700}
.card-bd{padding:16px 18px}
.breakdown{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:16px}
.bk-box{background:#F0F7FF;border-radius:6px;padding:12px 14px;text-align:center;border:1px solid #BBDEFB}
.bk-box h4{font-size:12px;color:#1565C0;font-weight:700;margin-bottom:8px}
.bk-row{display:flex;justify-content:space-between;font-size:12px;color:#555;padding:2px 0}
.bk-row .bk-net{font-weight:700;color:#2E7D32}
table.ep-tbl{width:100%;border-collapse:collapse;font-size:13px}
.ep-tbl th{background:#E3F2FD;padding:9px 12px;text-align:left;font-weight:700;color:#0D47A1;border-bottom:2px solid #BBDEFB}
.ep-tbl td{padding:8px 12px;border-bottom:1px solid #f5f5f5}
.ep-tbl tr:hover td{background:#FFFDE7}
.info-bar{background:#E3F2FD;border:1px solid #BBDEFB;border-radius:6px;padding:12px 16px;font-size:13px;color:#1565C0;margin-bottom:16px}
${subDeduct > 0 ? '.sub-notice{background:#FFF8E1;border:1px solid #FFE082;border-radius:6px;padding:12px 16px;font-size:13px;color:#E65100;margin-bottom:16px}' : ''}
</style></head>
<body>
<div class="hd"><h1>&#128188; ${esc(name)} — Earnings Dashboard</h1><a href="/api/company-earnings-logout">Sign Out</a></div>
<div class="wrap">
  <div class="info-bar">&#128197; Payout schedule: <strong>${schedule.charAt(0).toUpperCase()+schedule.slice(1)}</strong> &nbsp;|&nbsp; Last payout: <strong>${lastPayout}</strong> &nbsp;|&nbsp; ${sc&&sc.stripeConnectId ? '&#9989; Stripe Connected' : '&#9888;&#65039; Stripe not connected — contact BookaWaka'}</div>
  ${subDeduct > 0 ? `<div class="sub-notice">&#128274; Subscription fee deduction pending: <strong>$${subDeduct.toFixed(2)}</strong> will be withheld from your next payout.</div>` : ''}
  <div class="stats">
    <div class="stat"><div class="lbl">Total Pending</div><div class="val">${fmtAmt(earnings.totalNet)}</div></div>
    <div class="stat"><div class="lbl">Net After Subscription</div><div class="val green">${fmtAmt(netAfterSub < 0 ? 0 : netAfterSub)}</div></div>
    <div class="stat orange"><div class="lbl">BookaWaka Commission</div><div class="val">${fmtAmt(earnings.totalCommission)}</div></div>
    <div class="stat"><div class="lbl">Gross Revenue</div><div class="val">${fmtAmt(earnings.totalGross)}</div></div>
  </div>
  <div class="card">
    <div class="card-hd">Earnings Breakdown — Since Last Payout</div>
    <div class="card-bd">
      <div class="breakdown">
        <div class="bk-box"><h4>&#128661; Taxi</h4>
          <div class="bk-row"><span>Trips</span><span>${earnings.taxi.trips}</span></div>
          <div class="bk-row"><span>Gross</span><span>${fmtAmt(earnings.taxi.gross)}</span></div>
          <div class="bk-row"><span>Commission (${earnings.commissionPct}%)</span><span style="color:#E65100">-${fmtAmt(earnings.taxi.commission)}</span></div>
          <div class="bk-row"><span>Net</span><span class="bk-net">${fmtAmt(earnings.taxi.net)}</span></div>
        </div>
        <div class="bk-box"><h4>&#127829; Food Delivery</h4>
          <div class="bk-row"><span>Orders</span><span>${earnings.food.orders}</span></div>
          <div class="bk-row"><span>Gross</span><span>${fmtAmt(earnings.food.gross)}</span></div>
          <div class="bk-row"><span>Commission</span><span style="color:#E65100">-${fmtAmt(earnings.food.commission)}</span></div>
          <div class="bk-row"><span>Net</span><span class="bk-net">${fmtAmt(earnings.food.net)}</span></div>
        </div>
        <div class="bk-box"><h4>&#128666; Freight</h4>
          <div class="bk-row"><span>Deliveries</span><span>${earnings.freight.jobs}</span></div>
          <div class="bk-row"><span>Gross</span><span>${fmtAmt(earnings.freight.gross)}</span></div>
          <div class="bk-row"><span>Commission</span><span style="color:#E65100">-${fmtAmt(earnings.freight.commission)}</span></div>
          <div class="bk-row"><span>Net</span><span class="bk-net">${fmtAmt(earnings.freight.net)}</span></div>
        </div>
      </div>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">Payout History</div>
    <div class="card-bd" style="padding:0">
      <table class="ep-tbl">
        <thead><tr><th>Date</th><th>Amount</th><th>Status</th><th>Breakdown</th><th>Stripe ID</th></tr></thead>
        <tbody>${payoutRows}</tbody>
      </table>
    </div>
  </div>
</div></body></html>`);
  } catch (e: any) { res.send('<p>Error: ' + esc(e.message) + '</p>'); }
});

router.get('/api/company-earnings-logout', (req, res) => {
  if ((req as any).session) {
    delete (req as any).session.companyEarningsUid;
    delete (req as any).session.companyEarningsCid;
    delete (req as any).session.companyEarningsName;
  }
  res.redirect('/company-earnings-portal');
});

// ── Welcome email HTML builder ────────────────────────────────────────────────
function buildWelcomeEmail(d: any): string {
  const { companyName, email, cid, tempPassword, ownerPanelUrl } = d;
  const panelUrl = ownerPanelUrl || 'https://admin.bookawaka.co.nz';
  const year = new Date().getFullYear();
  const pwdBlock = tempPassword ? `
<tr><td style="background:#FFF8E1;border:1px solid #FFE082;border-radius:8px;padding:18px 24px;margin-bottom:22px">
<div style="font-size:11px;color:#E65100;text-transform:uppercase;font-weight:700;letter-spacing:.08em;margin-bottom:8px">&#9888; Temporary Password — change after first login</div>
<div style="font-size:22px;font-weight:700;color:#E65100;font-family:'Courier New',monospace;letter-spacing:2px">${esc(tempPassword)}</div>
<div style="font-size:12px;color:#888;margin-top:8px">For security, please update your password immediately after signing in.</div>
</td></tr><tr><td style="height:18px"></td></tr>` : '';
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Welcome to BookaWaka</title></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:32px 16px"><tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%">
<tr><td style="background:linear-gradient(135deg,#1B5E20 0%,#2E7D32 60%,#388E3C 100%);border-radius:12px 12px 0 0;padding:30px 32px;text-align:center">
<div style="font-size:36px;margin-bottom:8px">&#128665;</div>
<div style="font-size:24px;font-weight:700;color:#fff;letter-spacing:-.3px">Welcome to BookaWaka!</div>
<div style="font-size:13px;color:rgba(255,255,255,.75);margin-top:5px">Your company is now live on the platform</div>
</td></tr>
<tr><td style="background:#43A047;padding:10px 32px"><div style="font-size:13px;color:#fff;font-weight:500">&#127881; ${esc(companyName)} &mdash; Account Activated</div></td></tr>
<tr><td style="background:#fff;padding:32px 32px 28px;border-radius:0 0 12px 12px;box-shadow:0 2px 10px rgba(0,0,0,.08)">
<p style="font-size:15px;color:#333;line-height:1.7;margin:0 0 22px">Hi there,<br/><br/>Great news — <strong>${esc(companyName)}</strong> has been successfully onboarded onto the BookaWaka platform. Your owner panel is ready and your account is active.</p>
<table cellpadding="0" cellspacing="0" width="100%" style="margin-bottom:18px"><tr><td style="background:#E3F2FD;border:1px solid #BBDEFB;border-radius:8px;padding:18px 24px">
<div style="font-size:11px;color:#1565C0;text-transform:uppercase;font-weight:700;letter-spacing:.08em;margin-bottom:6px">Your Company ID</div>
<div style="font-size:28px;font-weight:700;color:#1565C0;font-family:'Courier New',monospace;letter-spacing:3px">${esc(String(cid))}</div>
<div style="font-size:12px;color:#888;margin-top:6px">Keep this ID handy — you'll need it to identify your company on the platform.</div>
</td></tr></table>
<table cellpadding="0" cellspacing="0" width="100%" style="margin-bottom:18px"><tr><td style="background:#F8F9FA;border:1px solid #E0E0E0;border-radius:8px;padding:18px 24px">
<div style="font-size:11px;color:#757575;text-transform:uppercase;font-weight:700;letter-spacing:.08em;margin-bottom:8px">Login Email</div>
<div style="font-size:16px;font-weight:600;color:#263238">${esc(email)}</div>
</td></tr></table>
${pwdBlock}
<table cellpadding="0" cellspacing="0" width="100%" style="margin-bottom:28px"><tr><td align="center">
<a href="${panelUrl}" style="display:inline-block;background:#2E7D32;color:#fff;font-size:15px;font-weight:700;padding:14px 36px;border-radius:6px;text-decoration:none">&#128187; Log In to Your Owner Panel &rarr;</a>
</td></tr></table>
<div style="background:#F1F8E9;border-left:4px solid #43A047;border-radius:0 6px 6px 0;padding:16px 20px;margin-bottom:24px">
<div style="font-size:13px;font-weight:700;color:#2E7D32;margin-bottom:10px">&#128640; What to do next:</div>
<ul style="margin:0;padding-left:18px;font-size:13px;color:#555;line-height:1.9">
<li>Log in using the credentials above</li>
${tempPassword ? '<li><strong>Change your password</strong> immediately after first login</li>' : ''}
<li>Set up your company profile and operating area</li>
<li>Add your vehicles and driver accounts</li>
<li>Configure your dispatch settings</li>
</ul>
</div>
<hr style="border:none;border-top:1px solid #f0f0f0;margin:24px 0 18px"/>
<p style="font-size:12px;color:#aaa;line-height:1.6;margin:0 0 10px"><strong style="color:#2E7D32">BookaWaka</strong> — New Zealand's purpose-built taxi &amp; mobility platform.</p>
</td></tr>
<tr><td style="padding:20px 0;text-align:center"><div style="font-size:11px;color:#bbb">&copy; ${year} BookaWaka Ltd &mdash; New Zealand<br/>This account was set up by a BookaWaka administrator on behalf of ${esc(companyName)}.</div></td></tr>
</table></td></tr></table></body></html>`;
}

export default router;
