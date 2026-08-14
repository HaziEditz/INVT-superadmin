/**
 * Shared SA portal auth — Firebase ID token + superAdmins membership.
 * Same model as /api/sa-wallet, TM Settlement, TM Clean Scan.
 */
import type { Request } from 'express';
import { isSuperAdmin, verifyFirebaseToken } from '../firebase';

export type SaAuthOk = { ok: true; uid: string; isSA: boolean };
export type SaAuthFail = { ok: false; status: number; error: string };
export type SaAuthResult = SaAuthOk | SaAuthFail;

/**
 * Verify Bearer Firebase ID token.
 * When requireSuperAdmin is true (default for requireSa), non-SA callers get 403.
 */
export async function resolveSaAuth(
  req: Request,
  opts: { requireSuperAdmin?: boolean } = {},
): Promise<SaAuthResult> {
  const auth = (req.headers['authorization'] as string) || '';
  const m = /^Bearer\s+(.+)$/i.exec(auth);
  if (!m) {
    return { ok: false, status: 401, error: 'Missing Authorization: Bearer <Firebase ID token>' };
  }
  let uid: string | null = null;
  try {
    uid = await verifyFirebaseToken(m[1].trim());
  } catch (e: any) {
    return { ok: false, status: 401, error: 'Token verification failed: ' + (e?.message || 'unknown') };
  }
  if (!uid) {
    return { ok: false, status: 401, error: 'Invalid or expired Firebase ID token' };
  }
  const isSA: boolean = await new Promise((resolve) =>
    isSuperAdmin(uid as string, (_e: any, ok: boolean) => resolve(!!ok)),
  );
  if (opts.requireSuperAdmin && !isSA) {
    return { ok: false, status: 403, error: 'Not a super-admin' };
  }
  return { ok: true, uid, isSA };
}

/** Require verified Firebase ID token + superAdmins/{uid} === true. */
export async function requireSa(req: Request): Promise<SaAuthResult> {
  return resolveSaAuth(req, { requireSuperAdmin: true });
}

/** Verify token only; report whether uid is a super-admin (no 403 for non-SA). */
export async function requireFirebaseUser(req: Request): Promise<SaAuthResult> {
  return resolveSaAuth(req, { requireSuperAdmin: false });
}
