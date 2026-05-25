const https = require('https');

export const DB_HOSTNAME = 'bookawaka2026-564e1-default-rtdb.firebaseio.com';
export const DB_SECRET   = process.env.FIREBASE_DB_SECRET || '';

export const FIREBASE_WEB_API_KEY = 'AIzaSyDIVSI_GRYG0hCPvc9h80QXZMxwZoejctQ';
export const DB_BASE_STRIPE = 'https://bookawaka2026-564e1-default-rtdb.firebaseio.com';

// ── Core Firebase REST helpers ────────────────────────────────────────────────
export function firebaseRequest(method, nodePath, data, cb) {
  const qIdx = nodePath.indexOf('?');
  const basePath = qIdx >= 0 ? nodePath.slice(0, qIdx) : nodePath;
  const existingQS = qIdx >= 0 ? nodePath.slice(qIdx + 1) : '';
  const authParam = DB_SECRET ? 'auth=' + encodeURIComponent(DB_SECRET) : '';
  const allParams = [existingQS, authParam].filter(Boolean).join('&');
  const qs = allParams ? '?' + allParams : '';
  const body = (data !== null && data !== undefined) ? JSON.stringify(data) : null;
  const options: any = {
    hostname: DB_HOSTNAME,
    path: '/' + basePath + '.json' + qs,
    method: method,
    headers: { 'Content-Type': 'application/json' }
  };
  if (body) options.headers['Content-Length'] = Buffer.byteLength(body);
  const req = https.request(options, (res) => {
    let raw = '';
    res.on('data', c => raw += c);
    res.on('end', () => {
      try {
        const parsed = JSON.parse(raw);
        if (parsed && typeof parsed === 'object' && parsed.error) {
          console.error('[Firebase] Error on', method, '/' + basePath + ':', JSON.stringify(parsed.error));
        }
        cb(null, parsed);
      } catch (e) { cb(null, raw); }
    });
  });
  req.on('error', (err) => {
    console.error('[Firebase] Network error on', method, '/' + basePath + ':', err.message);
    cb(err);
  });
  if (body) req.write(body);
  req.end();
}

export function fbRead(p, cb) { firebaseRequest('GET', p, null, cb); }
export function fbWrite(m, p, d, cb) { firebaseRequest(m, p, d, cb); }
export function fbReadP(p): Promise<any> {
  return new Promise((res, rej) => fbRead(p, (e, d) => e ? rej(e) : res(d)));
}
export function fbWriteP(m, p, d): Promise<any> {
  return new Promise((res, rej) => fbWrite(m, p, d, (e, r) => e ? rej(e) : res(r)));
}

// ── Stripe-specific firebase helpers (use DB_BASE_STRIPE) ─────────────────────
export async function fbGet(path) {
  const r = await fetch(`${DB_BASE_STRIPE}/${path}.json?auth=${process.env.FIREBASE_DB_SECRET}`);
  return r.json();
}
export async function fbSet(path, data) {
  await fetch(`${DB_BASE_STRIPE}/${path}.json?auth=${process.env.FIREBASE_DB_SECRET}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
}

// ── Super Admin role check ────────────────────────────────────────────────────
export function isSuperAdmin(uid, cb) {
  fbRead('superAdmins/' + uid, (err, val) => {
    cb(null, !err && val === true);
  });
}

// ── Firebase Auth REST API helpers ────────────────────────────────────────────
export function fbAuthCreate(email, password, cb) {
  const key = process.env.FIREBASE_WEB_API_KEY;
  if (!key) return cb(new Error('FIREBASE_WEB_API_KEY not set'));
  const body = JSON.stringify({ email, password, returnSecureToken: true });
  const opts = { hostname: 'identitytoolkit.googleapis.com', path: '/v1/accounts:signUp?key=' + key, method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) } };
  const req = https.request(opts, (res) => { let r = ''; res.on('data', c => r += c); res.on('end', () => { try { const d = JSON.parse(r); if (d.error) return cb(new Error(d.error.message || 'Auth create failed')); cb(null, { uid: d.localId, email: d.email, idToken: d.idToken }); } catch(e){ cb(e); } }); });
  req.on('error', cb); req.write(body); req.end();
}

export function fbAuthSignIn(email, password, cb) {
  const key = process.env.FIREBASE_WEB_API_KEY;
  if (!key) return cb(new Error('FIREBASE_WEB_API_KEY not set'));
  const body = JSON.stringify({ email, password, returnSecureToken: true });
  const opts = { hostname: 'identitytoolkit.googleapis.com', path: '/v1/accounts:signInWithPassword?key=' + key, method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) } };
  const req = https.request(opts, (res) => { let r = ''; res.on('data', c => r += c); res.on('end', () => { try { const d = JSON.parse(r); if (d.error) return cb(new Error(d.error.message || 'Sign in failed')); cb(null, { uid: d.localId, email: d.email, idToken: d.idToken }); } catch(e){ cb(e); } }); });
  req.on('error', cb); req.write(body); req.end();
}

export function fbAuthSendReset(email, cb) {
  const key = process.env.FIREBASE_WEB_API_KEY;
  if (!key) return cb(new Error('FIREBASE_WEB_API_KEY not set'));
  const body = JSON.stringify({ requestType: 'PASSWORD_RESET', email });
  const opts = { hostname: 'identitytoolkit.googleapis.com', path: '/v1/accounts:sendOobCode?key=' + key, method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) } };
  const req = https.request(opts, (res) => { let r = ''; res.on('data', c => r += c); res.on('end', () => { try { const d = JSON.parse(r); if (d.error) return cb(new Error(d.error.message || 'Reset failed')); cb(null, { ok: true }); } catch(e){ cb(e); } }); });
  req.on('error', cb); req.write(body); req.end();
}

// ── Firebase Auth REST (Promise-based, for newer routes) ──────────────────────
export function authRestPost(endpoint, body) {
  return new Promise((resolve, reject) => {
    const bodyStr = JSON.stringify(body);
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      port: 443,
      path: '/v1/accounts:' + endpoint + '?key=' + FIREBASE_WEB_API_KEY,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(bodyStr) }
    };
    const req = https.request(opts, (resp) => {
      let raw = '';
      resp.on('data', c => raw += c);
      resp.on('end', () => {
        try { resolve(JSON.parse(raw)); } catch(e) { resolve({ error: { message: 'Parse error' } }); }
      });
    });
    req.on('error', reject);
    req.write(bodyStr);
    req.end();
  });
}

export function generateTempPassword() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
  let s = '';
  for (let i = 0; i < 10; i++) s += chars[Math.floor(Math.random() * chars.length)];
  return 'BW-' + s.slice(0, 5) + '-' + s.slice(5);
}

export async function createFirebaseAuthUser(email, password) {
  const data: any = await authRestPost('signUp', { email, password, returnSecureToken: false });
  if (data.localId) return { uid: data.localId };
  throw new Error((data.error && data.error.message) || 'Firebase Auth creation failed');
}

export function getUidByEmail(email): Promise<string | null> {
  return new Promise((resolve) => {
    const body = JSON.stringify({ email: [email] });
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      port: 443,
      path: '/v1/accounts:lookup?key=' + FIREBASE_WEB_API_KEY,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) }
    };
    const req = https.request(opts, (resp) => {
      let raw = '';
      resp.on('data', c => raw += c);
      resp.on('end', () => {
        try {
          const data = JSON.parse(raw);
          if (data.users && data.users[0] && data.users[0].localId) {
            resolve(data.users[0].localId);
          } else {
            resolve(null);
          }
        } catch(e) { resolve(null); }
      });
    });
    req.on('error', () => resolve(null));
    req.write(body);
    req.end();
  });
}

// ── Firebase sign-in (returns idToken, used by company-earnings portal) ────────
export async function firebaseSignIn(email, password): Promise<string | null> {
  const key = FIREBASE_WEB_API_KEY;
  const data: any = await authRestPost('signInWithPassword', { email, password, returnSecureToken: true });
  if (data.idToken) return data.idToken;
  return null;
}

// ── Verify Firebase ID token via REST ─────────────────────────────────────────
export async function verifyFirebaseToken(idToken): Promise<string | null> {
  const data: any = await authRestPost('lookup', { idToken });
  if (data.users && data.users[0]) return data.users[0].localId;
  return null;
}
