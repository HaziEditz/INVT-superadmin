/**
 * Merge nested drivers/{cid}/{uid} + flat drivers/{key} with companyId,
 * then dedupe by person identity (uid / email / dispatcherId / phone).
 * Nested records win over flat duplicates.
 */

export type DriverRecord = Record<string, unknown> & {
  uid?: string;
  _uid?: string;
  _source?: 'nested' | 'flat';
  companyId?: string;
  company_id?: string;
  email?: string;
  dispatcherId?: string;
  id?: string;
  firstName?: string;
  lastName?: string;
  name?: string;
  phone?: string;
  mobileNumber?: string;
  mobile?: string;
  active?: boolean;
  status?: string;
  isWheelchairAccessible?: boolean;
  accessible?: boolean;
  wav?: boolean;
  vehicleType?: string;
};

export function looksLikeDriver(d: unknown): d is DriverRecord {
  if (!d || typeof d !== 'object') return false;
  const o = d as DriverRecord;
  return !!(
    o.email ||
    o.uid ||
    o.dispatcherId ||
    o.firstName ||
    o.lastName ||
    o.name ||
    o.phone ||
    o.mobileNumber ||
    o.mobile
  );
}

export function isDriverActive(d: DriverRecord): boolean {
  return d.active !== false && d.status !== 'inactive' && d.status !== 'suspended';
}

export function isDriverWav(d: DriverRecord): boolean {
  const vt = String(d.vehicleType || '').toLowerCase();
  return !!(
    d.isWheelchairAccessible ||
    d.accessible ||
    d.wav ||
    vt.includes('wheelchair') ||
    vt.includes('wav')
  );
}

function looksLikeFirebasePushKey(k: string): boolean {
  return typeof k === 'string' && k.charAt(0) === '-';
}

export function driverIdentityKeys(rtdbKey: string, d: DriverRecord): string[] {
  const keys: string[] = [];
  const uid = String(d.uid || d.dispatcherId || d.id || '')
    .trim()
    .toLowerCase();
  if (uid) {
    keys.push('uid:' + uid);
  } else if (rtdbKey && !looksLikeFirebasePushKey(rtdbKey)) {
    keys.push('uid:' + String(rtdbKey).trim().toLowerCase());
  }
  const email = String(d.email || '')
    .trim()
    .toLowerCase();
  if (email) keys.push('email:' + email);
  const phone = String(d.phone || d.mobileNumber || d.mobile || '').replace(/\D/g, '');
  if (phone.length >= 7) keys.push('phone:' + phone);
  if (!keys.length && rtdbKey) keys.push('key:' + rtdbKey);
  return keys;
}

function isNestedCompanyBucket(_key: string, val: Record<string, unknown>): boolean {
  const kids = Object.values(val);
  if (!kids.length) return false;
  const sample = kids.find((c) => c && typeof c === 'object') as DriverRecord | undefined;
  if (!sample) return false;
  return looksLikeDriver(sample) && !looksLikeDriver(val);
}

export function listDriversForCompany(
  raw: Record<string, unknown> | null | undefined,
  companyId: string,
  opts: { activeOnly?: boolean } = {},
): DriverRecord[] {
  const cid = String(companyId || '').trim();
  if (!cid || !raw || typeof raw !== 'object') return [];

  const nested: DriverRecord[] = [];
  const flat: DriverRecord[] = [];

  const nestedBucket = raw[cid];
  if (nestedBucket && typeof nestedBucket === 'object' && !Array.isArray(nestedBucket)) {
    for (const [uid, d] of Object.entries(nestedBucket as Record<string, unknown>)) {
      if (!looksLikeDriver(d)) continue;
      nested.push({ ...(d as DriverRecord), _uid: uid, _source: 'nested' });
    }
  }

  for (const [key, val] of Object.entries(raw)) {
    if (key === cid) continue;
    if (!val || typeof val !== 'object' || Array.isArray(val)) continue;
    const rec = val as Record<string, unknown>;
    if (isNestedCompanyBucket(key, rec)) continue;
    if (!looksLikeDriver(rec)) continue;
    const rowCid = String(rec.companyId || rec.company_id || '').trim();
    if (rowCid !== cid) continue;
    flat.push({
      ...(rec as DriverRecord),
      _uid: key,
      _source: 'flat',
    });
  }

  const ordered = [...nested, ...flat];
  const seen = new Set<string>();
  const out: DriverRecord[] = [];

  for (const d of ordered) {
    const idKeys = driverIdentityKeys(String(d._uid || ''), d);
    if (idKeys.some((k) => seen.has(k))) continue;
    for (const k of idKeys) seen.add(k);
    if (opts.activeOnly && !isDriverActive(d)) continue;
    out.push(d);
  }

  return out;
}
