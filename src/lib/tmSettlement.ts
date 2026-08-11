/**
 * BookaWaka TM settlement layer — invoices, council-paid tracking, company payouts.
 * chargeEnabled stays false by default: draft/track only; no automatic real charges.
 */

import { money2, normalizePlatformTmFeeDefaults, type PlatformTmFeeDefaults } from './tmPlatformFees';

export type SettlementCompanyLine = {
  cid: string;
  companyName?: string;
  tripCount: number;
  claimSubsidy: number;
  hoistPays: number;
  platformFeeCouncil: number;
  platformFeeCompany: number;
  /** Claim + hoist − company platform fee (informational while charge off). */
  companyPayoutGross: number;
};

export type CouncilSettlementInvoice = {
  councilId: string;
  ym: string;
  status: 'draft' | 'issued' | 'council_paid' | 'payouts_pending' | 'closed';
  chargeEnabledSnapshot: boolean;
  lines: SettlementCompanyLine[];
  totals: {
    tripCount: number;
    claimSubsidy: number;
    hoistPays: number;
    platformFeeCouncil: number;
    platformFeeCompany: number;
    /** What council owes BookaWaka (claim+hoist + council platform fees). */
    councilInvoiceTotal: number;
    companyPayoutTotal: number;
  };
  label: string;
  createdAt: number;
  issuedAt?: number | null;
  councilPaidAt?: number | null;
  councilPaidBy?: string | null;
  councilPaidRef?: string | null;
  councilPaidAmount?: number | null;
  notes?: string | null;
};

export type CompanyPayoutPlan = {
  cid: string;
  ym: string;
  councilId: string;
  amount: number;
  platformFeeCompany: number;
  status: 'pending' | 'paid' | 'blocked';
  blockedReason?: string | null;
};

export const SETTLEMENT_UI_LABEL = 'BookaWaka settlement — platform fees not charged yet';

export function assertSettlementChargeAllowed(
  defaults: PlatformTmFeeDefaults | null | undefined,
): { allowed: boolean; reason: string } {
  const d = normalizePlatformTmFeeDefaults(defaults as any);
  if (d.chargeEnabled === true) {
    return {
      allowed: true,
      reason: 'chargeEnabled is true — real charge path may proceed after legal/accounting sign-off checks.',
    };
  }
  return {
    allowed: false,
    reason: 'chargeEnabled is false (hard off) — draft/track only; no automatic charging.',
  };
}

export function buildCouncilSettlementInvoice(opts: {
  councilId: string;
  ym: string;
  lines: SettlementCompanyLine[];
  defaults?: PlatformTmFeeDefaults | null;
  now?: number;
  notes?: string | null;
}): CouncilSettlementInvoice {
  const now = opts.now != null ? Number(opts.now) : Date.now();
  const d = normalizePlatformTmFeeDefaults(opts.defaults as any);
  const lines = (opts.lines || []).map((ln) => {
    const claimSubsidy = money2(ln.claimSubsidy);
    const hoistPays = money2(ln.hoistPays);
    const platformFeeCouncil = money2(ln.platformFeeCouncil);
    const platformFeeCompany = money2(ln.platformFeeCompany);
    const companyPayoutGross = money2(claimSubsidy + hoistPays - platformFeeCompany);
    return {
      cid: String(ln.cid || '').trim(),
      companyName: ln.companyName || undefined,
      tripCount: Math.max(0, Math.round(Number(ln.tripCount) || 0)),
      claimSubsidy,
      hoistPays,
      platformFeeCouncil,
      platformFeeCompany,
      companyPayoutGross,
    };
  });
  const totals = lines.reduce(
    (acc, ln) => {
      acc.tripCount += ln.tripCount;
      acc.claimSubsidy = money2(acc.claimSubsidy + ln.claimSubsidy);
      acc.hoistPays = money2(acc.hoistPays + ln.hoistPays);
      acc.platformFeeCouncil = money2(acc.platformFeeCouncil + ln.platformFeeCouncil);
      acc.platformFeeCompany = money2(acc.platformFeeCompany + ln.platformFeeCompany);
      return acc;
    },
    {
      tripCount: 0,
      claimSubsidy: 0,
      hoistPays: 0,
      platformFeeCouncil: 0,
      platformFeeCompany: 0,
      councilInvoiceTotal: 0,
      companyPayoutTotal: 0,
    },
  );
  totals.councilInvoiceTotal = money2(
    totals.claimSubsidy + totals.hoistPays + totals.platformFeeCouncil,
  );
  totals.companyPayoutTotal = money2(
    lines.reduce((s, ln) => s + ln.companyPayoutGross, 0),
  );
  return {
    councilId: String(opts.councilId || '').trim(),
    ym: String(opts.ym || '').trim(),
    status: 'draft',
    chargeEnabledSnapshot: d.chargeEnabled === true,
    lines,
    totals,
    label: SETTLEMENT_UI_LABEL,
    createdAt: now,
    issuedAt: null,
    councilPaidAt: null,
    councilPaidBy: null,
    councilPaidRef: null,
    councilPaidAmount: null,
    notes: opts.notes != null ? String(opts.notes) : null,
  };
}

/** Mark council paid BookaWaka (tracking only — does not move money). */
export function markCouncilPaidBookaWaka(
  invoice: CouncilSettlementInvoice,
  opts: { who: string; payRef?: string | null; amount?: number | null; now?: number },
): CouncilSettlementInvoice {
  const now = opts.now != null ? Number(opts.now) : Date.now();
  const amount =
    opts.amount != null && Number.isFinite(Number(opts.amount))
      ? money2(opts.amount)
      : invoice.totals.councilInvoiceTotal;
  return {
    ...invoice,
    status: 'council_paid',
    councilPaidAt: now,
    councilPaidBy: String(opts.who || '').trim() || 'sa',
    councilPaidRef: opts.payRef != null ? String(opts.payRef).trim() || null : null,
    councilPaidAmount: amount,
  };
}

/** Plan company payouts from an invoice; blocks live payout when chargeEnabled false. */
export function planCompanyPayouts(
  invoice: CouncilSettlementInvoice,
  defaults?: PlatformTmFeeDefaults | null,
): CompanyPayoutPlan[] {
  const gate = assertSettlementChargeAllowed(defaults);
  return (invoice.lines || []).map((ln) => ({
    cid: ln.cid,
    ym: invoice.ym,
    councilId: invoice.councilId,
    amount: ln.companyPayoutGross,
    platformFeeCompany: ln.platformFeeCompany,
    status: gate.allowed ? 'pending' : 'blocked',
    blockedReason: gate.allowed ? null : gate.reason,
  }));
}

/** RTDB path helpers */
export function settlementInvoicePath(councilId: string, ym: string): string {
  return `tmSettlement/invoices/${councilId}/${ym}`;
}

export function settlementPayoutPath(cid: string, ym: string): string {
  return `tmSettlement/payouts/${cid}/${ym}`;
}

/** Build lines from stamped trips + batch economics for a council/month. */
export function linesFromStampedTrips(
  trips: Array<{
    _cid?: string;
    _companyName?: string;
    platformFeeCouncil?: number | string;
    platformFeeCompany?: number | string;
    platformFeeStampAt?: number | string;
    tmSubsidyFare?: number | string;
    tmSubsidy?: number | string;
    tmSubsidyHoist?: number | string;
    batchYm?: string;
    batchId?: string;
  }>,
  ym: string,
): SettlementCompanyLine[] {
  const byCid = new Map<string, SettlementCompanyLine>();
  const month = String(ym || '').trim();
  for (const t of trips || []) {
    if (t.platformFeeStampAt == null || t.platformFeeStampAt === '') continue;
    const batchYm = String(t.batchYm || t.batchId || '').slice(0, 7);
    // Prefer batch month; if missing, still include when caller already filtered
    if (month && batchYm && batchYm !== month && !String(t.batchId || '').startsWith(month)) {
      continue;
    }
    const cid = String(t._cid || '').trim();
    if (!cid) continue;
    const row =
      byCid.get(cid) ||
      ({
        cid,
        companyName: t._companyName ? String(t._companyName) : undefined,
        tripCount: 0,
        claimSubsidy: 0,
        hoistPays: 0,
        platformFeeCouncil: 0,
        platformFeeCompany: 0,
        companyPayoutGross: 0,
      } as SettlementCompanyLine);
    row.tripCount++;
    row.claimSubsidy = money2(
      row.claimSubsidy + Number(t.tmSubsidyFare ?? t.tmSubsidy ?? 0),
    );
    row.hoistPays = money2(row.hoistPays + Number(t.tmSubsidyHoist ?? 0));
    row.platformFeeCouncil = money2(row.platformFeeCouncil + Number(t.platformFeeCouncil ?? 0));
    row.platformFeeCompany = money2(row.platformFeeCompany + Number(t.platformFeeCompany ?? 0));
    row.companyPayoutGross = money2(
      row.claimSubsidy + row.hoistPays - row.platformFeeCompany,
    );
    byCid.set(cid, row);
  }
  return Array.from(byCid.values()).sort((a, b) => a.cid.localeCompare(b.cid));
}
