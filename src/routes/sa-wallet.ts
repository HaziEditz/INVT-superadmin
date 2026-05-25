// SA-Wallet proxy — forwards admin wallet calls to Customer Web Replit.
// Browser → SA Portal proxy (this file) → Customer Web /api/admin/wallet/*
// The browser never sees BW_ADMIN_KEY; it lives only on the server.
//
// Auth model (hardened 2026-05-18 after code review):
//   - Browser sends `Authorization: Bearer <firebase ID token>` header
//   - This proxy verifies the token server-side via verifyFirebaseToken()
//     and then checks the resolved uid against superAdmins (isSuperAdmin)
//   - A caller-supplied saUid in query/body/header is NEVER an auth source —
//     it is ignored. This closes the UID-enumeration bypass flagged in review.
//
// Endpoints (mirror Customer Web's surface 1:1):
//   GET  /api/sa-wallet/lookup                    ?uid= | ?key= | ?email= | ?phone=
//   GET  /api/sa-wallet/balance/:identifier       ?type=uid|key|email|phone
//   GET  /api/sa-wallet/ledger/:identifier        ?type=…&from=ISO&to=ISO
//   GET  /api/sa-wallet/reconciliation            ?from=ISO&to=ISO
//   POST /api/sa-wallet/adjust                    { identifier, identifierType, amount, reason, adjustedBy, note? }

import { Router, Request, Response } from 'express';
import { isSuperAdmin, verifyFirebaseToken } from '../firebase';

const router = Router();

async function authedAdmin(req: Request): Promise<{ ok: true; uid: string } | { ok: false; status: number; error: string }> {
  const auth = (req.headers['authorization'] as string) || '';
  const m = /^Bearer\s+(.+)$/i.exec(auth);
  if (!m) {
    return { ok: false, status: 401, error: 'Missing Authorization: Bearer <Firebase ID token>' };
  }
  const idToken = m[1].trim();
  let uid: string | null = null;
  try {
    uid = await verifyFirebaseToken(idToken);
  } catch (e: any) {
    return { ok: false, status: 401, error: 'Token verification failed: ' + (e?.message || 'unknown') };
  }
  if (!uid) {
    return { ok: false, status: 401, error: 'Invalid or expired Firebase ID token' };
  }
  const isSA: boolean = await new Promise(resolve =>
    isSuperAdmin(uid as string, (_e: any, ok: boolean) => resolve(!!ok))
  );
  if (!isSA) {
    return { ok: false, status: 403, error: 'Not a super-admin' };
  }
  return { ok: true, uid };
}

async function proxyWallet(req: Request, res: Response, subPath: string): Promise<void> {
  const customerWebUrl = process.env.CUSTOMER_WEB_URL;
  const adminKey = process.env.BW_ADMIN_KEY;

  if (!customerWebUrl) {
    res.status(503).json({ error: 'CUSTOMER_WEB_URL not configured on SA Portal' });
    return;
  }
  if (!adminKey) {
    res.status(503).json({ error: 'BW_ADMIN_KEY not configured on SA Portal' });
    return;
  }

  const auth = await authedAdmin(req);
  if (!auth.ok) {
    res.status(auth.status).json({ error: auth.error });
    return;
  }

  // Build target URL preserving query string (strip any legacy saUid)
  const qs = new URLSearchParams();
  for (const [k, v] of Object.entries(req.query)) {
    if (k === 'saUid') continue;
    if (typeof v === 'string') qs.append(k, v);
    else if (Array.isArray(v)) v.forEach(x => qs.append(k, String(x)));
  }
  const queryStr = qs.toString();
  const base = customerWebUrl.replace(/\/+$/, '');
  const target = `${base}/api/admin/wallet/${subPath}${queryStr ? '?' + queryStr : ''}`;

  // For mutating methods, strip saUid from the body and stamp the verified uid
  // as adminUid so the upstream audit trail records the authenticated actor.
  let bodyJson: string | undefined = undefined;
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    const cleaned: any = { ...(req.body || {}) };
    delete cleaned.saUid;
    cleaned.adminUid = auth.uid;
    bodyJson = JSON.stringify(cleaned);
  }

  try {
    const upstream = await fetch(target, {
      method: req.method,
      headers: {
        'X-Admin-Key': adminKey,
        'X-Admin-Uid': auth.uid,
        'Content-Type': 'application/json',
        Accept: 'application/json'
      },
      body: bodyJson
    });
    const text = await upstream.text();
    res.status(upstream.status);
    const ct = upstream.headers.get('content-type') || 'application/json';
    res.setHeader('Content-Type', ct);
    res.send(text);
  } catch (e: any) {
    console.error('[sa-wallet proxy]', req.method, target, '—', e.message);
    res.status(502).json({ error: 'Upstream Customer Web call failed', detail: e.message });
  }
}

router.get('/api/sa-wallet/lookup', (req, res) => proxyWallet(req, res, 'lookup'));
router.get('/api/sa-wallet/balance/:identifier', (req, res) =>
  proxyWallet(req, res, 'balance/' + encodeURIComponent(req.params.identifier))
);
router.get('/api/sa-wallet/ledger/:identifier', (req, res) =>
  proxyWallet(req, res, 'ledger/' + encodeURIComponent(req.params.identifier))
);
router.get('/api/sa-wallet/reconciliation', (req, res) => proxyWallet(req, res, 'reconciliation'));
router.post('/api/sa-wallet/adjust', (req, res) => proxyWallet(req, res, 'adjust'));

// Health probe — does NOT require admin auth (handy for smoke tests).
// Reports whether both required server-side configs are present.
// Intentionally reveals booleans only, never the actual values.
router.get('/api/sa-wallet/_health', (_req, res) => {
  res.json({
    ok: true,
    customerWebUrl: !!process.env.CUSTOMER_WEB_URL,
    bwAdminKey: !!process.env.BW_ADMIN_KEY
  });
});

export default router;
