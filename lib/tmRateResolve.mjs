/**
 * Shared TM rate resolution — no guessed 65%/75%/$5/$37.50 defaults.
 * Mirrors driver-app DEFAULT_TM_CONFIG (0/0/0) + block-when-missing behaviour.
 */

/**
 * @param {Record<string, unknown>|null|undefined} council  tmConfig/{councilId} shape
 * @returns {{ pct: number, cap: number, hoistRate: number, ready: boolean, uncapped: boolean, reason: string|null }}
 */
export function resolveCouncilTmRates(council) {
  const c = council && typeof council === 'object' ? council : {};
  const pct = parseFloat(String(c.subsidyPercent ?? c.councilSubsidyPercent ?? c.councilPercent ?? ''));
  const capRaw = parseFloat(String(c.capAmount ?? c.councilCapAmount ?? c.subsidyCap ?? ''));
  const hoistRate = parseFloat(
    String(c.hoistRatePerUse ?? c.hoistCostPerUnit ?? c.hoistUnitCost ?? ''),
  );
  const pctOk = Number.isFinite(pct) && pct > 0;
  const hoistOk = Number.isFinite(hoistRate) && hoistRate >= 0;
  // Cap ≤0 / missing = uncapped % (same as driver calcTmSplit) — only when pct is ready.
  const uncapped = !Number.isFinite(capRaw) || capRaw <= 0;
  const cap = uncapped ? 0 : capRaw;
  if (!pctOk) {
    return {
      pct: 0,
      cap: 0,
      hoistRate: hoistOk ? hoistRate : 0,
      ready: false,
      uncapped: true,
      reason: 'Council TM subsidy % missing or ≤0 — refuse guessed rate',
    };
  }
  return {
    pct,
    cap,
    hoistRate: hoistOk ? hoistRate : 0,
    ready: true,
    uncapped,
    reason: null,
  };
}

/**
 * Meter-only subsidy. Returns null amount when config not ready (never invents 75%).
 * @returns {{ ok: boolean, amount: number|null, uncapped: boolean, configMissing: boolean, reason: string|null, pct: number, cap: number }}
 */
export function calcTmMeterSubsidyFromCouncil(meterFare, council) {
  const rates = resolveCouncilTmRates(council);
  const fare = Math.max(0, parseFloat(String(meterFare)) || 0);
  if (!rates.ready) {
    return {
      ok: false,
      amount: null,
      uncapped: true,
      configMissing: true,
      reason: rates.reason,
      pct: 0,
      cap: 0,
    };
  }
  const raw = (fare * rates.pct) / 100;
  const amount = rates.uncapped ? raw : Math.min(raw, rates.cap);
  return {
    ok: true,
    amount: +amount.toFixed(2),
    uncapped: rates.uncapped,
    configMissing: false,
    reason: null,
    pct: rates.pct,
    cap: rates.cap,
  };
}

/**
 * Prefer stored hoist dollars; else uses × rate when rate known. Never invents $5/use.
 * @returns {{ amount: number, fromStored: boolean, configMissing: boolean, reason: string|null }}
 */
export function resolveHoistAmount(job, council) {
  const j = job && typeof job === 'object' ? job : {};
  const stored = parseFloat(
    String(j.tmHoistFeeTotal ?? j.hoistTotal ?? j.hoistFee ?? j.tmSubsidyHoist ?? ''),
  );
  if (Number.isFinite(stored) && stored > 0) {
    return { amount: +stored.toFixed(2), fromStored: true, configMissing: false, reason: null };
  }
  const count = parseInt(String(j.tmHoistCount ?? j.hoistCount ?? 0), 10) || 0;
  if (count <= 0) {
    return { amount: 0, fromStored: false, configMissing: false, reason: null };
  }
  const rates = resolveCouncilTmRates(council);
  if (!(rates.hoistRate > 0)) {
    return {
      amount: 0,
      fromStored: false,
      configMissing: true,
      reason: 'Hoist uses present but hoist rate missing — refuse $5 guess',
    };
  }
  return {
    amount: +(count * rates.hoistRate).toFixed(2),
    fromStored: false,
    configMissing: false,
    reason: null,
  };
}

/**
 * SA-Company manual TM form: blank/invalid → refuse (do not write 65/37.40/11.50).
 * @returns {{ ok: true, pct: number, cap: number, hoist: number } | { ok: false, error: string }}
 */
export function parseSaCompanyTmConfigFields(pctRaw, capRaw, hoistRaw) {
  const pctStr = String(pctRaw ?? '').trim();
  const capStr = String(capRaw ?? '').trim();
  const hoistStr = String(hoistRaw ?? '').trim();
  if (!pctStr || !capStr || !hoistStr) {
    return {
      ok: false,
      error:
        'Subsidy %, cap, and hoist are all required. Blank fields are not saved as guessed defaults — enter real values or cancel.',
    };
  }
  const pct = parseFloat(pctStr);
  const cap = parseFloat(capStr);
  const hoist = parseFloat(hoistStr);
  if (!Number.isFinite(pct) || pct <= 0 || pct > 100) {
    return { ok: false, error: 'Council subsidy % must be a number between 1 and 100.' };
  }
  if (!Number.isFinite(cap) || cap < 0) {
    return { ok: false, error: 'Council cap must be a number ≥ 0 (0 = uncapped %).' };
  }
  if (!Number.isFinite(hoist) || hoist < 0) {
    return { ok: false, error: 'Hoist cost per unit must be a number ≥ 0.' };
  }
  return { ok: true, pct, cap, hoist };
}

/** Old buggy SA-Company save behaviour (for regression evidence only). */
export function legacySaCompanyTmConfigFallback(pctRaw, capRaw, hoistRaw) {
  return {
    pct: parseFloat(pctRaw) || 65,
    cap: parseFloat(capRaw) || 37.4,
    hoist: parseFloat(hoistRaw) || 11.5,
  };
}
