/**
 * Auth gate for shared payment APIs.
 * Accepts Firebase ID token (driver/passenger clients) or BW_ADMIN_KEY (ops/tests).
 */
import type { Request } from 'express';
import { verifyFirebaseToken } from '../firebase';

export type PaymentAuth =
  | { ok: true; uid: string; via: 'firebase' | 'admin_key' }
  | { ok: false; status: number; error: string };

export async function requirePaymentAuth(req: Request): Promise<PaymentAuth> {
  const adminKey = process.env.BW_ADMIN_KEY || '';
  const headerKey = String(req.headers['x-admin-key'] || '').trim();
  if (adminKey && headerKey && headerKey === adminKey) {
    return { ok: true, uid: 'admin-key', via: 'admin_key' };
  }

  const auth = String(req.headers.authorization || '');
  const m = /^Bearer\s+(.+)$/i.exec(auth);
  if (!m) {
    return { ok: false, status: 401, error: 'Missing Authorization: Bearer <Firebase ID token>' };
  }
  try {
    const uid = await verifyFirebaseToken(m[1].trim());
    if (!uid) return { ok: false, status: 401, error: 'Invalid or expired Firebase ID token' };
    return { ok: true, uid, via: 'firebase' };
  } catch (e: any) {
    return { ok: false, status: 401, error: 'Token verification failed: ' + (e?.message || 'unknown') };
  }
}
