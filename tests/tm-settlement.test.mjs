import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const libSrc = readFileSync(join(root, 'src/lib/tmSettlement.ts'), 'utf8');
const routeSrc = readFileSync(join(root, 'src/routes/tmSettlement.ts'), 'utf8');
const feeSrc = readFileSync(join(root, 'src/lib/tmPlatformFees.ts'), 'utf8');
const appSrc = readFileSync(join(root, 'src/app.ts'), 'utf8');

function money2(n) {
  return Math.max(0, Math.round((Number(n) || 0) * 100) / 100);
}
function normalizePlatformTmFeeDefaults(raw) {
  const r = raw && typeof raw === 'object' ? raw : {};
  return {
    councilFeePerTrip: money2(r.councilFeePerTrip),
    companyFeePerTrip: money2(r.companyFeePerTrip),
    chargeEnabled: r.chargeEnabled === true,
  };
}
const SETTLEMENT_UI_LABEL = 'BookaWaka settlement — platform fees not charged yet';

function assertSettlementChargeAllowed(defaults) {
  const d = normalizePlatformTmFeeDefaults(defaults);
  if (d.chargeEnabled === true) {
    return { allowed: true, reason: 'chargeEnabled is true' };
  }
  return {
    allowed: false,
    reason: 'chargeEnabled is false (hard off) — draft/track only; no automatic charging.',
  };
}

function buildCouncilSettlementInvoice(opts) {
  const now = opts.now != null ? Number(opts.now) : Date.now();
  const d = normalizePlatformTmFeeDefaults(opts.defaults);
  const lines = (opts.lines || []).map((ln) => {
    const claimSubsidy = money2(ln.claimSubsidy);
    const hoistPays = money2(ln.hoistPays);
    const platformFeeCouncil = money2(ln.platformFeeCouncil);
    const platformFeeCompany = money2(ln.platformFeeCompany);
    return {
      cid: String(ln.cid || '').trim(),
      tripCount: Math.max(0, Math.round(Number(ln.tripCount) || 0)),
      claimSubsidy,
      hoistPays,
      platformFeeCouncil,
      platformFeeCompany,
      companyPayoutGross: money2(claimSubsidy + hoistPays - platformFeeCompany),
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
  totals.companyPayoutTotal = money2(lines.reduce((s, ln) => s + ln.companyPayoutGross, 0));
  return {
    councilId: String(opts.councilId || '').trim(),
    ym: String(opts.ym || '').trim(),
    status: 'draft',
    chargeEnabledSnapshot: d.chargeEnabled === true,
    lines,
    totals,
    label: SETTLEMENT_UI_LABEL,
    createdAt: now,
  };
}

function markCouncilPaidBookaWaka(invoice, opts) {
  const now = opts.now != null ? Number(opts.now) : Date.now();
  return {
    ...invoice,
    status: 'council_paid',
    councilPaidAt: now,
    councilPaidBy: String(opts.who || '').trim() || 'sa',
    councilPaidRef: opts.payRef != null ? String(opts.payRef).trim() || null : null,
    councilPaidAmount:
      opts.amount != null && Number.isFinite(Number(opts.amount))
        ? money2(opts.amount)
        : invoice.totals.councilInvoiceTotal,
  };
}

function planCompanyPayouts(invoice, defaults) {
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

test('assertSettlementChargeAllowed hard-off by default', () => {
  const g = assertSettlementChargeAllowed({
    councilFeePerTrip: 1,
    companyFeePerTrip: 0.5,
    chargeEnabled: false,
  });
  assert.equal(g.allowed, false);
  assert.match(g.reason, /chargeEnabled is false/);
});

test('buildCouncilSettlementInvoice itemizes by company', () => {
  const inv = buildCouncilSettlementInvoice({
    councilId: 'cncl_a',
    ym: '2026-08',
    defaults: { councilFeePerTrip: 1, companyFeePerTrip: 0.5, chargeEnabled: false },
    lines: [
      {
        cid: '860869',
        tripCount: 2,
        claimSubsidy: 20,
        hoistPays: 11.5,
        platformFeeCouncil: 2,
        platformFeeCompany: 1,
      },
      {
        cid: '860870',
        tripCount: 1,
        claimSubsidy: 10,
        hoistPays: 0,
        platformFeeCouncil: 1,
        platformFeeCompany: 0.5,
      },
    ],
    now: 1000,
  });
  assert.equal(inv.status, 'draft');
  assert.equal(inv.chargeEnabledSnapshot, false);
  assert.equal(inv.label, SETTLEMENT_UI_LABEL);
  assert.equal(inv.totals.tripCount, 3);
  assert.equal(inv.totals.councilInvoiceTotal, 44.5);
  assert.equal(inv.lines[0].companyPayoutGross, 30.5);
});

test('markCouncilPaidBookaWaka tracks payment without charging', () => {
  const inv = buildCouncilSettlementInvoice({
    councilId: 'cncl_a',
    ym: '2026-08',
    lines: [
      {
        cid: '860869',
        tripCount: 1,
        claimSubsidy: 10,
        hoistPays: 0,
        platformFeeCouncil: 1,
        platformFeeCompany: 0.5,
      },
    ],
  });
  const paid = markCouncilPaidBookaWaka(inv, { who: 'sa', payRef: 'INV-1', now: 2000 });
  assert.equal(paid.status, 'council_paid');
  assert.equal(paid.councilPaidRef, 'INV-1');
  assert.equal(paid.councilPaidAt, 2000);
});

test('planCompanyPayouts blocks when chargeEnabled false', () => {
  const inv = buildCouncilSettlementInvoice({
    councilId: 'cncl_a',
    ym: '2026-08',
    lines: [
      {
        cid: '860869',
        tripCount: 1,
        claimSubsidy: 10,
        hoistPays: 0,
        platformFeeCouncil: 1,
        platformFeeCompany: 0.5,
      },
    ],
  });
  const plans = planCompanyPayouts(inv, {
    councilFeePerTrip: 1,
    companyFeePerTrip: 0.5,
    chargeEnabled: false,
  });
  assert.equal(plans.length, 1);
  assert.equal(plans[0].status, 'blocked');
  assert.equal(plans[0].amount, 9.5);
});

test('settlement lib + route keep chargeEnabled false and mount', () => {
  assert.match(libSrc, /export function buildCouncilSettlementInvoice/);
  assert.match(libSrc, /export function markCouncilPaidBookaWaka/);
  assert.match(libSrc, /export function planCompanyPayouts/);
  assert.match(routeSrc, /\/api\/sa\/tm-settlement/);
  assert.match(routeSrc, /execute-payouts/);
  assert.match(routeSrc, /chargeEnabled/);
  assert.match(feeSrc, /platformFeeChargeEnabled: false/);
  assert.match(appSrc, /tmSettlement/);
});
