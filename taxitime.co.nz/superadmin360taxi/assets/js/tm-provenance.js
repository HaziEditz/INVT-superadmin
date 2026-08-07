/**
 * Synced / Manual / Legacy badges for TM config. Mirror of src/lib/tmProvenance.ts.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.BWTmProvenance = factory();
  }
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  function classifyTmConfig(tmConfig) {
    if (!tmConfig || typeof tmConfig !== 'object') {
      return { kind: 'unknown', label: 'Not set', detail: 'No company TM config yet' };
    }
    var source = String(tmConfig.sourceCouncilId || '').trim();
    var syncedAt = tmConfig.syncedFromCouncilAt;
    var manualAt = tmConfig.manualOverrideAt;
    if (source && syncedAt != null && syncedAt !== '') {
      var when =
        typeof syncedAt === 'number' ? new Date(syncedAt).toLocaleString('en-NZ') : String(syncedAt);
      return {
        kind: 'synced',
        label: 'Synced',
        detail: 'From council ' + source + (when ? ' · ' + when : ''),
      };
    }
    if (manualAt != null && manualAt !== '') {
      var whenM =
        typeof manualAt === 'number' ? new Date(manualAt).toLocaleString('en-NZ') : String(manualAt);
      return {
        kind: 'manual',
        label: 'Manual',
        detail: 'Company override' + (whenM ? ' · ' + whenM : ''),
      };
    }
    var hasVals =
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

  function legacyTariffProvenance() {
    return {
      kind: 'manual',
      label: 'Manual reference',
      detail: 'Reference price list — fare-mismatch checks only; not live meter SoT',
    };
  }

  function provenanceBadgeHtml(p) {
    var colors = {
      synced: { bg: '#E8F5E9', fg: '#1B5E20', border: '#A5D6A7' },
      manual: { bg: '#FFF8E1', fg: '#E65100', border: '#FFE082' },
      legacy: { bg: '#ECEFF1', fg: '#546E7A', border: '#CFD8DC' },
      unknown: { bg: '#F5F5F5', fg: '#757575', border: '#E0E0E0' },
    };
    var c = colors[p.kind] || colors.unknown;
    var title = String(p.detail || '').replace(/"/g, '&quot;');
    return (
      '<span title="' +
      title +
      '" class="tm-prov tm-prov-' +
      p.kind +
      '" style="display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:' +
      c.bg +
      ';color:' +
      c.fg +
      ';border:1px solid ' +
      c.border +
      ';white-space:nowrap">' +
      p.label +
      '</span>'
    );
  }

  function setupHubBannerHtml(advancedLabel) {
    var label = advancedLabel || 'this advanced page';
    return (
      '<div class="tm-setup-banner" style="margin:0 0 16px;padding:12px 16px;border-radius:8px;background:#E3F2FD;border-left:4px solid #1565C0;font-size:13px;color:#0D47A1;line-height:1.45">' +
      '<strong>Prefer TM Setup Hub</strong> for day-to-day council onboarding and company approval. ' +
      'You are on ' +
      label +
      ' (kept for advanced edits). ' +
      '<a href="TM-Setup.aspx" style="font-weight:700;color:#0D47A1;text-decoration:underline">Open Setup Hub →</a>' +
      '</div>'
    );
  }

  return {
    classifyTmConfig: classifyTmConfig,
    legacyTariffProvenance: legacyTariffProvenance,
    provenanceBadgeHtml: provenanceBadgeHtml,
    setupHubBannerHtml: setupHubBannerHtml,
  };
});
