/**
 * Synced / Manual / Legacy labeling for TM economics & unused tariff data.
 */

export type TmProvenanceKind = 'synced' | 'manual' | 'legacy' | 'unknown';

export type TmProvenance = {
  kind: TmProvenanceKind;
  label: string;
  detail: string;
};

export function classifyTmConfig(tmConfig: Record<string, unknown> | null | undefined): TmProvenance {
  if (!tmConfig || typeof tmConfig !== 'object') {
    return { kind: 'unknown', label: 'Not set', detail: 'No company TM config yet' };
  }
  const source = String(tmConfig.sourceCouncilId || '').trim();
  const syncedAt = tmConfig.syncedFromCouncilAt;
  const manualAt = tmConfig.manualOverrideAt;
  if (source && syncedAt != null && syncedAt !== '') {
    const when =
      typeof syncedAt === 'number'
        ? new Date(syncedAt).toLocaleString('en-NZ')
        : String(syncedAt);
    return {
      kind: 'synced',
      label: 'Synced',
      detail: `From council ${source}` + (when ? ` · ${when}` : ''),
    };
  }
  if (manualAt != null && manualAt !== '') {
    const when =
      typeof manualAt === 'number' ? new Date(manualAt as number).toLocaleString('en-NZ') : String(manualAt);
    return {
      kind: 'manual',
      label: 'Manual',
      detail: 'Company override' + (when ? ` · ${when}` : ''),
    };
  }
  // Values present but no provenance markers
  const hasVals =
    tmConfig.councilSubsidyPercent != null ||
    tmConfig.councilPercent != null ||
    tmConfig.capAmount != null ||
    tmConfig.councilCapAmount != null;
  if (hasVals) {
    return {
      kind: 'manual',
      label: 'Manual',
      detail: 'Company TM config (no council sync marker)',
    };
  }
  return { kind: 'unknown', label: 'Not set', detail: 'No subsidy/cap stored' };
}

export function legacyTariffProvenance(): TmProvenance {
  return {
    kind: 'legacy',
    label: 'Legacy',
    detail: 'tmTariffs — unused for live metering / claims',
  };
}

/** HTML badge for council portal / SA pages (inline styles — no shared CSS file). */
export function provenanceBadgeHtml(p: TmProvenance): string {
  const colors: Record<TmProvenanceKind, { bg: string; fg: string; border: string }> = {
    synced: { bg: '#E8F5E9', fg: '#1B5E20', border: '#A5D6A7' },
    manual: { bg: '#FFF8E1', fg: '#E65100', border: '#FFE082' },
    legacy: { bg: '#ECEFF1', fg: '#546E7A', border: '#CFD8DC' },
    unknown: { bg: '#F5F5F5', fg: '#757575', border: '#E0E0E0' },
  };
  const c = colors[p.kind];
  const title = String(p.detail || '').replace(/"/g, '&quot;');
  return `<span title="${title}" style="display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:${c.bg};color:${c.fg};border:1px solid ${c.border};white-space:nowrap">${p.label}</span>`;
}
