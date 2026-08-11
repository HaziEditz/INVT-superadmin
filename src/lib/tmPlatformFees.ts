/**
 * BookaWaka TM platform fees — config resolve + trip stamps.
 * chargeEnabled defaults false; no real charging in this module.
 */

export type PlatformTmFeeDefaults = {
  councilFeePerTrip: number;
  companyFeePerTrip: number;
  /** Hard off until settlement + legal sign-off enables charging. */
  chargeEnabled: boolean;
};

export type CompanyFeeOverride = {
  councilFeePerTrip?: number | string | null;
  companyFeePerTrip?: number | string | null;
};

export type ResolvedPlatformTmFees = {
  councilFeePerTrip: number;
  companyFeePerTrip: number;
  chargeEnabled: boolean;
  source: 'default' | 'company_override';
};

export type TripPlatformFeeStamp = {
  platformFeeCouncil: number;
  platformFeeCompany: number;
  platformFeeCouncilRate: number;
  platformFeeCompanyRate: number;
  platformFeeStampAt: number;
  platformFeeChargeEnabled: boolean;
  platformFeeSource: 'default' | 'company_override';
  /** UI / reports: never interpret as live charge while false. */
  platformFeeLabel: string;
};

const FEE_LABEL = 'BookaWaka platform fees — not charged yet';

export function money2(n: number): number {
  return Math.max(0, Math.round((Number(n) || 0) * 100) / 100);
}

export function normalizePlatformTmFeeDefaults(
  raw: Record<string, unknown> | null | undefined,
): PlatformTmFeeDefaults {
  const r = raw && typeof raw === 'object' ? raw : {};
  return {
    councilFeePerTrip: money2(r.councilFeePerTrip as number),
    companyFeePerTrip: money2(r.companyFeePerTrip as number),
    // Only true when explicitly boolean true — never coerce from "1"/truthy junk
    chargeEnabled: r.chargeEnabled === true,
  };
}

function overrideNum(v: unknown): number | null {
  if (v == null || v === '') return null;
  const n = Number(v);
  if (!Number.isFinite(n) || n < 0) return null;
  return money2(n);
}

/** Company override wins when set; else platform defaults. */
export function resolvePlatformTmFees(
  defaults: PlatformTmFeeDefaults | null | undefined,
  companyCfg: CompanyFeeOverride | null | undefined,
): ResolvedPlatformTmFees {
  const d = normalizePlatformTmFeeDefaults(defaults as any);
  const co = companyCfg && typeof companyCfg === 'object' ? companyCfg : {};
  const councilO = overrideNum(co.councilFeePerTrip);
  const companyO = overrideNum(co.companyFeePerTrip);
  const usedOverride = councilO != null || companyO != null;
  return {
    councilFeePerTrip: councilO != null ? councilO : d.councilFeePerTrip,
    companyFeePerTrip: companyO != null ? companyO : d.companyFeePerTrip,
    chargeEnabled: d.chargeEnabled === true,
    source: usedOverride ? 'company_override' : 'default',
  };
}

export function buildTripPlatformFeeStamp(
  resolved: ResolvedPlatformTmFees,
  now = Date.now(),
): TripPlatformFeeStamp {
  return {
    platformFeeCouncil: resolved.councilFeePerTrip,
    platformFeeCompany: resolved.companyFeePerTrip,
    platformFeeCouncilRate: resolved.councilFeePerTrip,
    platformFeeCompanyRate: resolved.companyFeePerTrip,
    platformFeeStampAt: now,
    // Stamps never enable live charge even if defaults flip later mid-trip
    platformFeeChargeEnabled: false,
    platformFeeSource: resolved.source,
    platformFeeLabel: FEE_LABEL,
  };
}

export type FeeTripLike = {
  _cid?: string;
  councilId?: string;
  platformFeeCouncil?: number | string;
  platformFeeCompany?: number | string;
  platformFeeStampAt?: number | string;
  status?: string;
};

function stampMonthKey(stampAt: unknown): string | null {
  const n = Number(stampAt);
  if (!Number.isFinite(n) || n <= 0) return null;
  const d = new Date(n < 1e12 ? n * 1000 : n);
  if (Number.isNaN(d.getTime())) return null;
  // NZ calendar month for "this month" reporting
  const parts = new Intl.DateTimeFormat('en-NZ', {
    timeZone: 'Pacific/Auckland',
    year: 'numeric',
    month: '2-digit',
  }).formatToParts(d);
  const y = parts.find((p) => p.type === 'year')?.value;
  const m = parts.find((p) => p.type === 'month')?.value;
  return y && m ? `${y}-${m}` : null;
}

/** Pull fee override fields from companySettings/{cid}/tmConfig (or aliases). */
export function companyFeeOverrideFromTmConfig(
  tmConfig: Record<string, unknown> | null | undefined,
): CompanyFeeOverride {
  const c = tmConfig && typeof tmConfig === 'object' ? tmConfig : {};
  return {
    councilFeePerTrip:
      c.councilFeePerTrip != null ? c.councilFeePerTrip : (c.platformFeeCouncil as any),
    companyFeePerTrip:
      c.companyFeePerTrip != null ? c.companyFeePerTrip : (c.platformFeeCompany as any),
  };
}

/** Aggregate stamped would-be fees for reporting (no charging). */
export function aggregateWouldBeFees(
  trips: FeeTripLike[],
  opts?: { companyId?: string; councilId?: string; month?: string },
): {
  tripCount: number;
  councilFees: number;
  companyFees: number;
  byCompany: Array<{ cid: string; tripCount: number; councilFees: number; companyFees: number }>;
  byCouncil: Array<{
    councilId: string;
    tripCount: number;
    councilFees: number;
    companyFees: number;
  }>;
} {
  const companyFilter = String(opts?.companyId || '').trim();
  const councilFilter = String(opts?.councilId || '').trim();
  const monthFilter = String(opts?.month || '').trim();
  const byCid = new Map<string, { tripCount: number; councilFees: number; companyFees: number }>();
  const byCouncil = new Map<
    string,
    { tripCount: number; councilFees: number; companyFees: number }
  >();
  let tripCount = 0;
  let councilFees = 0;
  let companyFees = 0;

  for (const t of trips || []) {
    if (t.platformFeeStampAt == null || t.platformFeeStampAt === '') continue;
    if (monthFilter) {
      const mk = stampMonthKey(t.platformFeeStampAt);
      if (mk !== monthFilter) continue;
    }
    const cid = String(t._cid || '').trim();
    const councilId = String(t.councilId || '').trim() || 'unknown';
    if (companyFilter && cid !== companyFilter) continue;
    if (councilFilter && councilId !== councilFilter) continue;
    const cFee = money2(t.platformFeeCouncil as number);
    const coFee = money2(t.platformFeeCompany as number);
    tripCount++;
    councilFees = money2(councilFees + cFee);
    companyFees = money2(companyFees + coFee);
    if (cid) {
      const row = byCid.get(cid) || { tripCount: 0, councilFees: 0, companyFees: 0 };
      row.tripCount++;
      row.councilFees = money2(row.councilFees + cFee);
      row.companyFees = money2(row.companyFees + coFee);
      byCid.set(cid, row);
    }
    const crow = byCouncil.get(councilId) || { tripCount: 0, councilFees: 0, companyFees: 0 };
    crow.tripCount++;
    crow.councilFees = money2(crow.councilFees + cFee);
    crow.companyFees = money2(crow.companyFees + coFee);
    byCouncil.set(councilId, crow);
  }

  return {
    tripCount,
    councilFees,
    companyFees,
    byCompany: Array.from(byCid.entries())
      .map(([cid, r]) => ({ cid, ...r }))
      .sort((a, b) => a.cid.localeCompare(b.cid)),
    byCouncil: Array.from(byCouncil.entries())
      .map(([councilId, r]) => ({ councilId, ...r }))
      .sort((a, b) => a.councilId.localeCompare(b.councilId)),
  };
}

export const PLATFORM_FEE_UI_LABEL = FEE_LABEL;
