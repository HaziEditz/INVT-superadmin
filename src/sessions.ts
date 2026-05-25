import { fbReadP, fbWriteP } from './firebase';

export const councilSessions: Record<string, any>    = {};
export const restaurantSessions: Record<string, any> = {};
export const freightSessions: Record<string, any>    = {};
export const rentalSessions: Record<string, any>     = {};
export const towingSessions: Record<string, any>     = {};
export const saViewSessions: Record<string, any>     = {};

const STORES: Record<string, Record<string, any>> = {
  council:    councilSessions,
  restaurant: restaurantSessions,
  freight:    freightSessions,
  rental:     rentalSessions,
  towing:     towingSessions,
  saView:     saViewSessions,
};

const FB_PREFIX = 'portalSessions';

function _expOf(sess: any): number {
  return Number(sess?.expiresAt || sess?.exp || sess?.expires || 0);
}

function _persist(storeName: string, token: string, sess: any): void {
  fbWriteP('PUT', `${FB_PREFIX}/${storeName}/${encodeURIComponent(token)}`, sess)
    .catch(e => console.error(`[sessions] persist ${storeName}:`, e.message));
}

function _unpersist(storeName: string, token: string): void {
  fbWriteP('DELETE', `${FB_PREFIX}/${storeName}/${encodeURIComponent(token)}`, null)
    .catch(e => console.error(`[sessions] delete ${storeName}:`, e.message));
}

function _storeNameFor(store: Record<string, any>): string | null {
  for (const [name, s] of Object.entries(STORES)) if (s === store) return name;
  return null;
}

export function genToken(len = 40): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let t = '';
  for (let i = 0; i < len; i++) t += chars[Math.floor(Math.random() * chars.length)];
  return t;
}

export const SESSION_TTL = 8 * 60 * 60 * 1000;

export function createSession(store: Record<string, any>, uid: string, email: string): string {
  const token = genToken();
  const sess = { uid, email, expiresAt: Date.now() + SESSION_TTL };
  store[token] = sess;
  const name = _storeNameFor(store);
  if (name) _persist(name, token, sess);
  return token;
}

export function getSession(store: Record<string, any>, token: string): any | null {
  if (!token) return null;
  const sess = store[token];
  if (!sess) return null;
  const exp = _expOf(sess);
  if (exp && Date.now() > exp) {
    delete store[token];
    const name = _storeNameFor(store);
    if (name) _unpersist(name, token);
    return null;
  }
  // TTL refresh stays in-memory only (avoids a Firebase write on every API call)
  sess.expiresAt = Date.now() + SESSION_TTL;
  return sess;
}

export function deleteSession(store: Record<string, any>, token: string): void {
  if (!token) return;
  delete store[token];
  const name = _storeNameFor(store);
  if (name) _unpersist(name, token);
}

export function purgeExpired(store: Record<string, any>): void {
  const now = Date.now();
  const name = _storeNameFor(store);
  for (const tok of Object.keys(store)) {
    const exp = _expOf(store[tok]);
    if (exp && now > exp) {
      delete store[tok];
      if (name) _unpersist(name, tok);
    }
  }
}

setInterval(() => {
  Object.values(STORES).forEach(purgeExpired);
}, 30 * 60 * 1000);

// ── Council portal wrappers ───────────────────────────────────────────────────
export function cpSetSession(councilId: string, name: string, email: string): string {
  const token = genToken();
  const sess = { uid: councilId, councilId, name, email, expiresAt: Date.now() + SESSION_TTL };
  councilSessions[token] = sess;
  _persist('council', token, sess);
  return token;
}
export function cpGetSession(token: string): any | null { return getSession(councilSessions, token); }
export function cpDeleteSession(token: string): void { deleteSession(councilSessions, token); }

// ── Freight portal wrappers ───────────────────────────────────────────────────
export function fpSetSession(freightCompanyId: string, name: string, email: string, companyId: string): string {
  const token = genToken();
  const sess = { uid: freightCompanyId, freightCompanyId, name, email, companyId, expiresAt: Date.now() + SESSION_TTL };
  freightSessions[token] = sess;
  _persist('freight', token, sess);
  return token;
}
export function fpGetSession(token: string): any | null { return getSession(freightSessions, token); }
export function fpDeleteSession(token: string): void { deleteSession(freightSessions, token); }

// ── Restaurant portal wrappers ────────────────────────────────────────────────
export function rpSetSession(restaurantId: string, name: string, email: string, companyId: string): string {
  const token = genToken();
  const sess = { uid: restaurantId, restaurantId, name, email, companyId, expiresAt: Date.now() + SESSION_TTL };
  restaurantSessions[token] = sess;
  _persist('restaurant', token, sess);
  return token;
}
export function rpGetSession(token: string): any | null { return getSession(restaurantSessions, token); }
export function rpDeleteSession(token: string): void { deleteSession(restaurantSessions, token); }

// ── Direct persistence helpers (for stores using custom set/delete) ──────────
export function persistSessionDirect(storeName: string, token: string, sess: any): void {
  if (!STORES[storeName]) return;
  _persist(storeName, token, sess);
}
export function unpersistSessionDirect(storeName: string, token: string): void {
  if (!STORES[storeName]) return;
  _unpersist(storeName, token);
}

// ── Hydrate all stores from Firebase on startup ──────────────────────────────
export async function hydrateAllSessions(): Promise<void> {
  const now = Date.now();
  for (const [name, store] of Object.entries(STORES)) {
    try {
      const data = await fbReadP(`${FB_PREFIX}/${name}`);
      if (!data || typeof data !== 'object') continue;
      let kept = 0, expired = 0;
      for (const [tok, sess] of Object.entries(data as Record<string, any>)) {
        const exp = _expOf(sess);
        if (exp && now > exp) {
          _unpersist(name, tok);
          expired++;
        } else {
          store[tok] = sess;
          kept++;
        }
      }
      if (kept || expired) console.log(`[sessions] Hydrated ${name}: ${kept} active, ${expired} expired`);
    } catch (e: any) {
      console.error(`[sessions] hydrate ${name}:`, e.message);
    }
  }
}
