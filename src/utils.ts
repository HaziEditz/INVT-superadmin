import crypto from 'crypto';
import { fbReadP, fbWriteP, fbGet, fbSet } from './firebase';

// ── Password hashing ──────────────────────────────────────────────────────────
// Plain SHA-256 hex — used for driver records (matches Owner Panel).
export function sha256Hex(input: string): string {
  return crypto.createHash('sha256').update(input).digest('hex');
}

// Salted SHA-256 — used for towing portal login (existing pattern).
export function twHash(pwd: string): string {
  return crypto.createHash('sha256').update('tw360nz:' + pwd).digest('hex');
}

/** Strip plaintext password fields from driver writes; hash to passwordHash instead. */
export function sanitizeDriverPayload(data: unknown): unknown {
  if (data === null || typeof data !== 'object') return data;
  if (Array.isArray(data)) return data.map(sanitizeDriverPayload);
  const obj = data as Record<string, unknown>;
  const out: Record<string, unknown> = { ...obj };
  if (typeof out.password === 'string' && out.password) {
    out.passwordHash = sha256Hex(out.password);
  }
  delete out.password;
  return out;
}

export function isDriversFbPath(p: string): boolean {
  const head = String(p || '').replace(/^\/+/, '').split(/[\/?]/)[0].toLowerCase();
  return head === 'drivers';
}

// ── Re-export firebase helpers so route files can import from one place ────────
export { fbReadP, fbWriteP, fbGet, fbSet };

// ── CORS ──────────────────────────────────────────────────────────────────────
export const CORS_ORIGIN = process.env.PUBLIC_SITE_ORIGIN || '*';
export function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', CORS_ORIGIN);
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Api-Key');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
}

// ── HTML escape ───────────────────────────────────────────────────────────────
export function esc(s) {
  if (s === null || s === undefined) return '';
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

// ── Audit logging ─────────────────────────────────────────────────────────────
export function logAudit(action, details, uid?) {
  const ts = Date.now();
  const entry: any = { action, details, timestamp: ts };
  if (uid) entry.uid = uid;
  const key = 'auditLogs/' + ts + '_' + Math.random().toString(36).slice(2, 7);
  fbWriteP('PUT', key, entry).catch(() => {});
}

// ── Resend email client ───────────────────────────────────────────────────────
export async function getResendClient() {
  try {
    const { listConnections } = await import('../node_modules/@replit/extensions/dist/cjs/index.js' as any).catch(() => ({ listConnections: null })) as any;
    if (!listConnections) {
      const { Resend } = await import('resend');
      const key = process.env.RESEND_API_KEY;
      if (!key) return null;
      return new Resend(key);
    }
    const conns = await listConnections('resend');
    if (!conns || conns.length === 0) return null;
    const settings = conns[0].getClient ? conns[0].getClient() : conns[0].settings;
    const apiKey = settings.api_key || settings.apiKey;
    if (!apiKey) return null;
    const { Resend } = await import('resend');
    return new Resend(apiKey);
  } catch (e) {
    return null;
  }
}

// ── Stripe client ─────────────────────────────────────────────────────────────
export function getStripe() {
  const Stripe = require('stripe');
  return new Stripe(process.env.STRIPE_SECRET_KEY || '', { apiVersion: '2023-10-16' });
}

// ── Admin API proxy ───────────────────────────────────────────────────────────
export const ADMIN_API_HOST = '01067f31-afeb-4a32-a195-60c80223accf-00-dgff2mfkeoci.riker.replit.dev';
export const ADMIN_API_KEY  = process.env.ADMIN_API_KEY || 'bookawaka-admin-2026';

export function adminRequest(method, path, body?): Promise<any> {
  return new Promise((resolve, reject) => {
    const https = require('https');
    const bodyStr = body ? JSON.stringify(body) : '';
    const opts: any = {
      hostname: ADMIN_API_HOST,
      port: 443,
      path,
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': ADMIN_API_KEY
      }
    };
    if (bodyStr) opts.headers['Content-Length'] = Buffer.byteLength(bodyStr);
    const req = https.request(opts, (resp) => {
      let raw = '';
      resp.on('data', c => raw += c);
      resp.on('end', () => {
        try { resolve(JSON.parse(raw)); } catch(e) { resolve({ raw }); }
      });
    });
    req.on('error', reject);
    if (bodyStr) req.write(bodyStr);
    req.end();
  });
}

// ── Job ID generator ──────────────────────────────────────────────────────────
const _todayParts = () => {
  const d = new Date();
  const yr = d.getFullYear();
  const mo = String(d.getMonth() + 1).padStart(2, '0');
  const dy = String(d.getDate()).padStart(2, '0');
  return { yr, mo, dy, dateKey: `${yr}${mo}${dy}` };
};

const _jobCounters: Record<string, number> = {};

export async function generateJobId(prefix: string): Promise<string> {
  const { dateKey, yr, mo, dy } = _todayParts();
  const counterKey = `jobCounters/${prefix}/${dateKey}`;
  let count = _jobCounters[counterKey];
  if (!count) {
    try {
      const remote = await fbGet(counterKey);
      count = (remote && typeof remote.count === 'number') ? remote.count : 0;
    } catch { count = 0; }
  }
  count++;
  _jobCounters[counterKey] = count;
  await fbSet(counterKey, { count }).catch(() => {});
  const seq = String(count).padStart(4, '0');
  return `${prefix}-${yr}${mo}${dy}-${seq}`;
}

// ── Generic JSON response helpers ─────────────────────────────────────────────
export function sendJson(res, status, data) {
  res.status(status).json(data);
}

export function sendError(res, status, message) {
  res.status(status).json({ error: message });
}
