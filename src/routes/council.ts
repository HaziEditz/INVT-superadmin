import { Router, Request, Response, NextFunction } from 'express';
import https from 'https';
import { fbRead, fbWrite, fbAuthCreate, fbAuthSignIn, fbAuthSendReset } from '../firebase';
import { esc } from '../utils';
import { cpGetSession, cpSetSession, cpDeleteSession, councilSessions } from '../sessions';
import { isDriverWav, listDriversForCompany } from '../lib/driverList';
import { resolveDriverVehicle } from '../lib/vehicleRegistry';
import {
  classifyTmConfig,
  legacyTariffProvenance,
  provenanceBadgeHtml,
} from '../lib/tmProvenance';
import {
  buildTmTripDetail,
  tmTripDetailToCsvRow,
  TM_TRIP_CSV_HEADERS,
  type TmTripDetail,
} from '../lib/tmTripDetail';
import {
  applyAnomalyScan,
  partitionCleanAndFlagged,
  isClaimEligibleStatus,
  type AnomalyStatusPatch,
} from '../lib/tmAnomaly';
import {
  isArchivedStatus,
  archivePatch,
  restorePatch,
} from '../lib/tmArchive';
import { tripMatchesSearch } from '../lib/tmTripSearch';
import {
  normalizeUnifiedTripStatus,
  legacyReturnToStatus,
  filterTripsUnified,
  aggregateTripUsage,
  countTripsByUnifiedStatus,
  UNIFIED_TRIP_STATUS_OPTIONS,
  aggregateHoistByDay,
  aggregateUsageByDay,
  aggregateUsageByMonth,
  filterTripsByEntity,
  normalizeEntityType,
  sumEntityTotals,
  partitionOperatorRosters,
  ENTITY_TYPES,
  hoistPaysOf,
  hoistUsesOf,
} from '../lib/tmUnifiedTrips';
import {
  buildTripEvent,
  newEventKey,
  normalizeTripEvents,
  formatEventLabel,
} from '../lib/tmTripEvents';
import {
  PROOF_MISSING_LABEL,
  buildPaidBatchPatch,
  buildTripPaidPatch,
  hasPaymentProof,
  proofMissingFlag,
  resolveBatchTripKeys,
  normalizeClaimBatchStatusFilter,
  filterClaimBatches,
  isFlaggedClaimBatch,
} from '../lib/tmBatchPaid';
import { storeBatchProof, MAX_PROOF_BYTES } from '../lib/tmBatchStorage';
import { compareTripsNewestFirst, tripActivityMs, tripMonthKey } from '../lib/tmTripSort';
import {
  planCouncilBatchCreates,
  shouldWriteBatchCreate,
  mergeApprovedTripIntoBatch,
  computeDisplayBatchTotals,
  type CouncilTripLike,
} from '../lib/tmBatchCreate';

const router = Router();

/**
 * After council approves a trip, upsert it into that month's open claim batch
 * so trips cannot sit approved with no batch.
 */
function upsertApprovedTripIntoMonthBatch(
  councilId: string,
  tripLike: CouncilTripLike,
  who: string,
  cb: () => void,
): void {
  const cid = String(tripLike._cid || '').trim();
  const rawKey = String(tripLike._rawKey || '').trim();
  if (!councilId || !cid || !rawKey) return cb();
  const now = Date.now();
  const ymGuess = tripMonthKey(tripLike) || new Date(now).toISOString().slice(0, 7);
  const path = 'tmBatches/' + councilId + '/' + cid + '/' + ymGuess;
  fbRead(path, (_e: any, existing: any) => {
    const merged = mergeApprovedTripIntoBatch(existing, tripLike, {
      who,
      now,
      submittedRef: 'council-trip-approve',
    });
    if (!merged) return cb();
    const writePath = 'tmBatches/' + councilId + '/' + merged.pathSuffix;
    fbWrite('PATCH', writePath, merged.payload, () => {
      fbWrite(
        'PATCH',
        'tmTripStatus/' + cid + '/' + rawKey,
        { batchId: merged.pathSuffix, batchYm: merged.ym },
        () => cb(),
      );
    });
  });
}

/** Load job economics then upsert into month batch (approve path). */
function afterCouncilApproveAddToBatch(
  councilId: string,
  tripCid: string,
  tripRawKey: string,
  who: string,
  statusExtras: Record<string, unknown> | null | undefined,
  cb: () => void,
): void {
  fbRead('completedJobs/' + tripCid + '/' + tripRawKey, (_e: any, job: any) => {
    const st = statusExtras && typeof statusExtras === 'object' ? statusExtras : {};
    const tripLike: CouncilTripLike = {
      ...(job && typeof job === 'object' ? job : {}),
      ...st,
      _cid: tripCid,
      _rawKey: tripRawKey,
      status: 'approved',
      tmSubsidy:
        (job && (job.tmSubsidy ?? job.tmCouncilPays)) ??
        st.tmSubsidy ??
        st.tmCouncilPays ??
        0,
    };
    upsertApprovedTripIntoMonthBatch(councilId, tripLike, who, cb);
  });
}

// ── CSS & helpers ──────────────────────────────────────────────────────────────
const PORTAL_CSS = `
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#F4F7F4;color:#333;font-size:14px;min-height:100vh}
a{color:inherit;text-decoration:none}
.cp-nav{background:#1B5E20;color:#fff;height:52px;padding:0 24px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100;box-shadow:0 2px 8px rgba(0,0,0,.25)}
.cp-nav-brand{font-size:15px;font-weight:700;display:flex;align-items:center;gap:6px}
.cp-nav-links{display:flex}
.cp-nav-links a{color:rgba(255,255,255,.78);padding:17px 13px;font-size:12.5px;display:flex;align-items:center;gap:4px;border-bottom:3px solid transparent;transition:all .15s}
.cp-nav-links a:hover{background:rgba(255,255,255,.1);color:#fff}
.cp-nav-links a.on{color:#fff;border-bottom-color:#69F0AE;background:rgba(255,255,255,.08)}
.cp-nav-right{font-size:12px;opacity:.75;display:flex;align-items:center;gap:14px}
.cp-main{padding:22px 24px;max-width:1280px;margin:0 auto}
.cp-card{background:#fff;border-radius:6px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:18px;overflow:hidden}
.cp-card-hd{padding:13px 18px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between}
.cp-card-hd h3{font-size:14px;font-weight:700;color:#1B5E20;display:flex;align-items:center;gap:6px}
.cp-card-bd{padding:16px 18px}
.cp-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:14px;margin-bottom:18px}
.cp-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #2E7D32}
.cp-stat.warn{border-left-color:#E65100}.cp-stat.flag{border-left-color:#C62828}
.cp-stat-v{font-size:26px;font-weight:700;color:#1B5E20;line-height:1.1}
.cp-stat.warn .cp-stat-v{color:#E65100}.cp-stat.flag .cp-stat-v{color:#C62828}
.cp-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.cp-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.cp-tbl th{background:#F1F8E9;padding:9px 11px;text-align:left;font-size:11.5px;font-weight:700;color:#33691E;border-bottom:2px solid #C5E1A5;white-space:nowrap}
.cp-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.cp-tbl tr:last-child td{border-bottom:none}
.cp-tbl tr:hover td{background:#FAFFF7}
.cp-tbl tfoot td{background:#F1F8E9;font-weight:700;font-size:12px;color:#2E7D32;border-top:2px solid #C5E1A5}
.cp-empty{text-align:center;color:#aaa;padding:24px;font-style:italic}
.cp-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:12.5px;font-weight:600}
.cp-btn-g{background:#2E7D32;color:#fff}.cp-btn-r{background:#C62828;color:#fff}
.cp-bdg-b{display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600;background:#E3F2FD;color:#1565C0}
.cp-bdg-r{background:#FFEBEE;color:#C62828;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.cp-bdg-g{background:#E8F5E9;color:#2E7D32;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.cp-bdg-a{background:#FFF8E1;color:#E65100;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.cp-bdg-gr{background:#F5F5F5;color:#757575;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.cp-month-row{display:flex;gap:12px;align-items:center;flex-wrap:wrap;margin-bottom:16px}
.cp-month-row label{font-size:13px;color:#555;font-weight:500}
.cp-month-row select{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.cp-bar-wrap{background:#E0E0E0;border-radius:4px;height:8px;overflow:hidden;min-width:80px}
.cp-bar-fill{background:#2E7D32;height:100%;border-radius:4px}
.cp-bar-fill.over{background:#C62828}
.cp-notice{padding:12px 16px;border-radius:6px;margin-bottom:16px;font-size:13px}
.cp-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.cp-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.cp-tog-on{background:#E8F5E9;color:#2E7D32;border:1px solid #C8E6C9;padding:4px 10px;border-radius:12px;font-size:11.5px;font-weight:600;cursor:pointer}
.cp-tog-off{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;padding:4px 10px;border-radius:12px;font-size:11.5px;font-weight:600;cursor:pointer}
.cp-btn-sm{padding:5px 10px;background:#1B5E20;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:12px;font-weight:600}
.cp-tbl tr.cp-row-click{cursor:pointer}
.cp-tbl tr.cp-row-click:hover td{background:#E8F5E9}
.cp-ov{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:999;align-items:center;justify-content:center;padding:16px}
.cp-ov.open{display:flex}
.cp-modal{background:#fff;border-radius:8px;width:720px;max-width:96vw;max-height:92vh;overflow-y:auto;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.cp-modal-hd{background:#1B5E20;color:#fff;padding:14px 18px;display:flex;align-items:center;justify-content:space-between;border-radius:8px 8px 0 0}
.cp-modal-hd h3{margin:0;font-size:15px}
.cp-modal-bd{padding:18px}
.cp-modal-ft{padding:12px 18px;border-top:1px solid #eee;display:flex;justify-content:flex-end;gap:8px}
.cp-input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.cp-search-hero{background:#fff;border:2px solid #2E7D32;border-radius:8px;padding:14px 16px;margin-bottom:16px;box-shadow:0 2px 8px rgba(46,125,50,.12)}
.cp-search-hero label{display:block;font-size:13px;font-weight:700;color:#1B5E20;margin-bottom:8px}
.cp-search-hero-row{display:flex;gap:10px;align-items:stretch;flex-wrap:wrap}
.cp-search-hero input[type="search"]{flex:1;min-width:220px;padding:12px 14px;border:1px solid #A5D6A7;border-radius:6px;font-size:15px;background:#FAFFF7}
.cp-search-hero input[type="search"]:focus{outline:2px solid #69F0AE;border-color:#2E7D32}
.cp-search-hero .cp-btn{padding:12px 18px;font-size:14px}
#cp-trip-map-wrap{margin-top:12px;overflow:hidden;border-radius:6px;position:relative}
#cp-trip-map{height:220px;border-radius:6px;z-index:1;background:#E8F5E9;overflow:hidden}
#cp-trip-map-status{font-size:12px;color:#666;margin:0 0 6px;min-height:16px}
#cp-trip-map-debug{display:none;margin-top:8px;font-size:11px;font-family:ui-monospace,Consolas,monospace;background:#0f172a;color:#e2e8f0;padding:8px;border-radius:4px;max-height:220px;overflow:auto;white-space:pre-wrap}
.cp-bdg-mismatch{background:#FFEBEE;color:#C62828;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.cp-edit-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px 12px;margin-top:10px}
.cp-edit-grid label{display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:2px}
.cp-edit-grid input,.cp-edit-grid select,.cp-edit-grid textarea{width:100%;padding:6px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px}
.cp-ref-badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:#FFF8E1;color:#E65100;border:1px solid #FFE082}
.cp-chip{display:inline-block;padding:2px 8px;border-radius:10px;font-size:10.5px;font-weight:600;background:#FFEBEE;color:#C62828;margin:1px 2px 1px 0;border:1px solid #FFCDD2}
.cp-timeline{margin-top:14px}
.cp-timeline-hd{font-size:12px;font-weight:700;color:#555;margin-bottom:8px}
.cp-timeline-item{border-left:3px solid #A5D6A7;padding:4px 0 10px 12px;margin-left:4px}
.cp-timeline-item:last-child{padding-bottom:2px}
.cp-timeline-when{font-size:11px;color:#888}
.cp-tabs{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:14px}
.cp-tab{display:inline-block;padding:7px 14px;border-radius:16px;font-size:12.5px;font-weight:600;background:#eee;color:#555;border:1px solid #ddd}
.cp-tab.on{background:#1B5E20;color:#fff;border-color:#1B5E20}
.cp-tab .cp-tab-n{opacity:.85;font-weight:700;margin-left:4px}
.cp-proof-miss{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:#FFF8E1;color:#E65100;border:1px solid #FFE082}
.cp-proof-ok{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.cp-timeline-label{font-size:12.5px;color:#333;margin-top:1px}
`;

function renderNav(session: any, token: string, activePage: string): string {
  const te = encodeURIComponent(token);
  const pages: [string, string][] = [
    ['dashboard', '&#128202; Dashboard'],
    ['trips', '&#128661; Trips'],
    ['batches', '&#128196; Claim Batches'],
    ['cards', '&#127938; Cards'],
    ['limits', '&#128176; Trip Limits'],
    ['config', '&#9881; Config'],
    ['operators', '&#127970; Operators'],
  ];
  const links = pages.map(([pg, lbl]) =>
    `<a href="/council-portal/${pg}?t=${te}" class="${activePage === pg ? 'on' : ''}">${lbl}</a>`
  ).join('');
  return `<nav class="cp-nav">
  <div class="cp-nav-brand">&#127963; <span>${esc(session.name || 'Council Portal')}</span></div>
  <div class="cp-nav-links">${links}</div>
  <div class="cp-nav-right">
    <span>${esc(session.email || '')}</span>
    <a href="/api/council-logout?t=${te}" style="opacity:1;color:#A5D6A7">Sign Out</a>
  </div>
</nav>`;
}

function portalPage(title: string, nav: string, body: string): string {
  return `<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} — Council Portal</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHryRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
<style>${PORTAL_CSS}</style></head>
<body>${nav}<div class="cp-main">${body}</div></body></html>`;
}

function statusBadge(s: string): string {
  const map: Record<string, string> = {
    pending:          '<span class="cp-bdg-gr">Pending</span>',
    company_approved: '<span class="cp-bdg-b">Owner Approved</span>',
    submitted:        '<span class="cp-bdg-b">Submitted to Council</span>',
    approved:         '<span class="cp-bdg-g">Council Approved</span>',
    revision_needed:  '<span class="cp-bdg-a">Revision Needed</span>',
    rejected:         '<span class="cp-bdg-r">Rejected</span>',
    paid:             '<span class="cp-bdg-g">Paid</span>',
    flagged:          '<span class="cp-bdg-r">Flagged</span>',
    archived:         '<span class="cp-bdg-gr">Archived</span>',
  };
  return map[s] || `<span class="cp-bdg-gr">${esc(s || 'pending')}</span>`;
}

function isTmCompletedJob(job: any): boolean {
  if (!job || typeof job !== 'object') return false;
  if (job.isTotalMobility === true || job.tmUsed === true) return true;
  const pt = String(job.paymentType || job.PaymentType || job.paymentMethod || '')
    .toLowerCase()
    .replace(/[_\s-]/g, '');
  if (pt === 'totalmobility' || pt === 'tm') return true;
  if (job.tmPaymentType === 'total_mobility' || job.paymentCategory === 'total_mobility') return true;
  // Driver app stores remainder method as paymentType but writes TM economics separately.
  if (job.tmCouncilPays != null || job.councilPays != null || job.tmSubsidyFare != null) return true;
  if (job.tmSubsidy != null && Number(job.tmSubsidy) > 0) return true;
  if (job.tmCardNumber || job.tmVoucherNo) return true;
  if (Array.isArray(job.tmHoists) && job.tmHoists.length > 0) return true;
  return false;
}

/** Normalize meter vs hoist line items for portal display (Phase 2A.1). */
function normalizeTmTripEconomics(job: any): {
  fare: number;
  tmSubsidyFare: number;
  tmSubsidyHoist: number;
  tmSubsidy: number;
  tmPassengerPays: number;
} {
  const hoist = Number(job.tmSubsidyHoist ?? job.hoistTotal ?? job.hoistCost ?? 0) || 0;
  const meterFare = Number(job.tmMeterFare ?? job.meterFare ?? 0) || 0;
  const legacyFare = Number(job.fare ?? job.totalFare ?? job.tmTotalFare ?? 0) || 0;
  const fare = meterFare || Math.max(0, legacyFare - (job.hoistTotal || job.tmSubsidyHoist ? hoist : 0));
  const subsidyFare = Number(
    job.tmSubsidyFare ??
      (job.tmCouncilPays != null ? Math.max(0, Number(job.tmCouncilPays) - hoist) : job.tmSubsidy) ??
      0,
  ) || 0;
  const totalCouncil =
    Number(job.tmCouncilPays ?? job.councilPays ?? subsidyFare + hoist) || 0;
  const pax =
    Number(job.tmPassengerPays ?? job.passengerPays ?? Math.max(0, fare - subsidyFare)) || 0;
  return {
    fare: +fare.toFixed(2),
    tmSubsidyFare: +subsidyFare.toFixed(2),
    tmSubsidyHoist: +hoist.toFixed(2),
    tmSubsidy: +totalCouncil.toFixed(2),
    tmPassengerPays: +pax.toFixed(2),
  };
}

function loadCouncilTrips(councilId: string, cb: (err: any, trips: any[]) => void): void {
  fbRead('tmTripStatus', (err: any, allStatus: any) => {
    if (err || !allStatus) return cb(null, []);
    const cids = Object.keys(allStatus);
    if (cids.length === 0) return cb(null, []);
    let pending = cids.length * 2;
    const jobsMap: Record<string, any> = {};
    const namesMap: Record<string, string> = {};
    function done() { if (--pending === 0) merge(); }
    cids.forEach(cid => {
      fbRead('completedJobs/' + cid, (e2: any, jobs: any) => { jobsMap[cid] = jobs || {}; done(); });
      fbRead('superClients/' + cid, (e3: any, sc: any) => { namesMap[cid] = (sc && sc.name) ? sc.name : ('Operator ' + cid); done(); });
    });
    function merge() {
      const result: any[] = [];
      cids.forEach(cid => {
        const statusMap = allStatus[cid] || {};
        const jobs = jobsMap[cid] || {};
        Object.entries(statusMap).forEach(([rawKey, st]: [string, any]) => {
          if (!st || st.councilId !== councilId) return;
          const job = jobs[rawKey] || {};
          // tmTripStatus row for this council is authoritative for the claims list;
          // also accept completed jobs that carry TM economics even if paymentType is the remainder method.
          if (Object.keys(job).length && !isTmCompletedJob(job) && !st.submittedAt && !st.status) return;
          const econ = normalizeTmTripEconomics(job);
          result.push({
            _cid: cid, _rawKey: rawKey, _companyName: namesMap[cid] || ('Operator ' + cid),
            ...job,
            ...econ,
            status: st.status || 'pending', councilId: st.councilId,
            submittedAt: st.submittedAt, approvedAt: st.approvedAt, rejectedAt: st.rejectedAt,
            approvedBy: st.approvedBy, rejectedBy: st.rejectedBy,
            revisionNote: st.revisionNote || st.revisionNotes || null,
            revisionNotes: st.revisionNotes || st.revisionNote || null,
            batchId: st.batchId,
            flagReasons: Array.isArray(st.flagReasons) ? st.flagReasons : [],
            anomalyDetail: st.anomalyDetail || null,
            anomalyScannedAt: st.anomalyScannedAt || null,
            flaggedAt: st.flaggedAt || null,
            rejectNote: st.rejectNote || null,
            sentBackAt: st.sentBackAt || null,
            sentBackBy: st.sentBackBy || null,
            archivedAt: st.archivedAt || null,
            archivedBy: st.archivedBy || null,
            archivedFromStatus: st.archivedFromStatus || null,
            archiveNote: st.archiveNote || null,
            resubmittedAt: st.resubmittedAt || null,
            resubmittedBy: st.resubmittedBy || null,
            restoredAt: st.restoredAt || null,
            events: st.events || null,
          });
        });
      });
      cb(null, result);
    }
  });
}

function appendTripEvent(
  cid: string,
  rawKey: string,
  event: ReturnType<typeof buildTripEvent>,
  cb?: () => void,
): void {
  const key = newEventKey();
  fbWrite('PUT', 'tmTripStatus/' + cid + '/' + rawKey + '/events/' + key, event, () => {
    if (cb) cb();
  });
}

/** Newest-last chronological timeline (escapes all user-facing text). */
function tripHistoryHtml(stOrTrip: any): string {
  const events = normalizeTripEvents(stOrTrip);
  if (!events.length) {
    return `<div class="cp-timeline"><div class="cp-timeline-hd">History</div><div class="cp-empty" style="padding:12px">No events yet.</div></div>`;
  }
  const items = events
    .map((e) => {
      const when = e.at ? new Date(e.at).toLocaleString('en-NZ') : '—';
      const by = e.by ? ` · ${esc(String(e.by))}` : '';
      const label = formatEventLabel(e);
      return `<div class="cp-timeline-item">
  <div class="cp-timeline-when">${esc(when)}${by}</div>
  <div class="cp-timeline-label">${esc(label)}</div>
</div>`;
    })
    .join('');
  return `<div class="cp-timeline"><div class="cp-timeline-hd">History</div>${items}</div>`;
}

function companyFilterOptionsHtml(trips: any[], selected: string): string {
  const map: Record<string, string> = {};
  (trips || []).forEach((t) => {
    if (t && t._cid) map[String(t._cid)] = String(t._companyName || 'Operator ' + t._cid);
  });
  return Object.keys(map)
    .sort((a, b) => map[a].localeCompare(map[b]))
    .map(
      (cid) =>
        `<option value="${esc(cid)}"${cid === selected ? ' selected' : ''}>${esc(map[cid])}</option>`,
    )
    .join('');
}

function inlineTripSearchFormHtml(
  actionPath: string,
  token: string,
  q: string,
  company: string,
  companyOpts: string,
  extrasHtml = '',
): string {
  const te = encodeURIComponent(token);
  return `<form method="GET" action="${actionPath}" class="cp-month-row" style="margin-bottom:14px">
  <input type="hidden" name="t" value="${esc(token)}"/>
  <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">Search</label>
    <input type="search" name="q" class="cp-input" value="${esc(q)}" placeholder="Voucher, passenger, driver, job id…" style="min-width:220px"/></div>
  <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">Company</label>
    <select name="company" class="cp-input"><option value="">All</option>${companyOpts}</select></div>
  ${extrasHtml}
  <button type="submit" class="cp-btn cp-btn-g">&#128269; Search</button>
  ${q || company ? `<a href="${actionPath}?t=${te}" class="cp-btn" style="background:#eee;color:#333">Clear</a>` : ''}
</form>`;
}

function filterTripsBySearchAndCompany(trips: any[], q: string, company: string): any[] {
  let rows = trips || [];
  if (company) rows = rows.filter((t) => String(t._cid) === company);
  if (q) rows = rows.filter((t) => tripMatchesSearch(t, q));
  return rows;
}

function loadTariffsForCids(cids: string[], cb: (map: Record<string, any>) => void): void {
  const unique = Array.from(new Set((cids || []).map((c) => String(c || '').trim()).filter(Boolean)));
  if (unique.length === 0) return cb({});
  const map: Record<string, any> = {};
  let left = unique.length;
  unique.forEach((cid) => {
    fbRead('tmTariffs/' + cid, (_e: any, tar: any) => {
      map[cid] = tar || {};
      if (--left === 0) cb(map);
    });
  });
}

function persistAnomalyPatches(patches: AnomalyStatusPatch[], done: () => void): void {
  if (!patches || patches.length === 0) return done();
  let left = patches.length;
  patches.forEach((p) => {
    fbWrite('PATCH', 'tmTripStatus/' + p.cid + '/' + p.rawKey, p.patch, () => {
      const finishOne = () => {
        if (--left === 0) done();
      };
      if (String(p.patch.status || '') === 'flagged') {
        const reasons = Array.isArray(p.patch.flagReasons)
          ? (p.patch.flagReasons as string[]).map(String)
          : null;
        appendTripEvent(
          p.cid,
          p.rawKey,
          buildTripEvent('flagged', {
            byRole: 'system',
            toStatus: 'flagged',
            reasons,
            note: p.patch.anomalyDetail != null ? String(p.patch.anomalyDetail) : null,
          }),
          finishOne,
        );
      } else {
        finishOne();
      }
    });
  });
}

function scanAndRefreshTrips(trips: any[], cb: (updated: any[]) => void): void {
  const list = Array.isArray(trips) ? trips : [];
  const cids = list.map((t) => String(t._cid || '')).filter(Boolean);
  loadTariffsForCids(cids, (tariffByCid) => {
    const patches = applyAnomalyScan(list, tariffByCid);
    persistAnomalyPatches(patches, () => {
      const byKey: Record<string, Record<string, unknown>> = {};
      patches.forEach((p) => {
        byKey[p.cid + '/' + p.rawKey] = p.patch;
      });
      const updated = list.map((t) => {
        const patch = byKey[String(t._cid) + '/' + String(t._rawKey)];
        if (!patch) return t;
        return {
          ...t,
          status: patch.status != null ? patch.status : t.status,
          flagReasons: patch.flagReasons !== undefined ? patch.flagReasons : t.flagReasons,
          anomalyDetail: patch.anomalyDetail !== undefined ? patch.anomalyDetail : t.anomalyDetail,
          anomalyScannedAt: patch.anomalyScannedAt != null ? patch.anomalyScannedAt : t.anomalyScannedAt,
          flaggedAt: patch.flaggedAt != null ? patch.flaggedAt : t.flaggedAt,
        };
      });
      cb(updated);
    });
  });
}

function flagReasonChips(reasons: any, detail?: string | null): string {
  const arr = Array.isArray(reasons) ? reasons.map((r) => String(r || '').trim()).filter(Boolean) : [];
  if (!arr.length) {
    return detail ? `<span class="cp-chip" title="${esc(String(detail))}">flagged</span>` : '';
  }
  const title = detail ? esc(String(detail)) : '';
  return arr
    .map((r) => `<span class="cp-chip"${title ? ` title="${title}"` : ''}>${esc(r)}</span>`)
    .join(' ');
}

/** Validation ranges for shared SA / council financial fields. */
function validateTmFinancials(pct: number, cap: number, hoist: number): string | null {
  if (isNaN(pct) || pct < 1 || pct > 100) return 'Subsidy % must be between 1 and 100.';
  if (isNaN(cap) || cap <= 0 || cap > 500) return 'Subsidy cap must be between $0.01 and $500.';
  if (isNaN(hoist) || hoist < 0 || hoist > 200) return 'Hoist fee per use must be between $0 and $200.';
  return null;
}

function companyTmConfigFromCouncil(councilId: string, council: any) {
  const pct = parseFloat(council.subsidyPercent) || 0;
  const cap = parseFloat(council.capAmount) || 0;
  const hoist = parseFloat(council.hoistRatePerUse) || 0;
  return {
    councilSubsidyPercent: pct,
    councilCapAmount: cap,
    hoistCostPerUnit: hoist,
    councilPercent: pct,
    passengerPercent: Math.max(0, 100 - pct),
    capAmount: cap,
    hoistUnitCost: hoist,
    sourceCouncilId: String(councilId || ''),
    syncedFromCouncilAt: Date.now(),
    updatedAt: Date.now(),
  };
}

function syncCouncilTmConfigToApprovedCompanies(councilId: string, council: any, done: (n: number) => void) {
  const payload = companyTmConfigFromCouncil(councilId, council);
  fbRead('tmCompanyAccess', (err: any, access: any) => {
    if (err || !access) return done(0);
    const cids: string[] = [];
    Object.keys(access).forEach((cid) => {
      const row = access[cid] && access[cid][councilId];
      if (row && row.approved === true) cids.push(cid);
    });
    if (cids.length === 0) return done(0);
    let left = cids.length;
    cids.forEach((cid) => {
      fbWrite('PUT', 'companySettings/' + cid + '/tmConfig', payload, () => {
        if (--left === 0) done(cids.length);
      });
    });
  });
}

function requirePortalAuth(req: Request, res: Response, next: NextFunction): void {
  const token = (req.query.t as string) || '';
  const session = cpGetSession(token);
  if (!session) { res.redirect('/council-portal?err=session'); return; }
  (req as any).cpSession = session;
  (req as any).cpToken = token;
  next();
}

/** In-memory Nominatim cache (server-side; browser UAs are blocked by OSM policy). */
const _cpGeocodeServerCache = new Map<string, { lat: number; lon: number } | null>();
let _cpGeocodeLastAt = 0;

function nominatimGeocode(
  q: string,
  cb: (err: string | null, ll: { lat: number; lon: number } | null) => void,
): void {
  const key = String(q || '').trim().toLowerCase();
  if (!key) return cb(null, null);
  if (_cpGeocodeServerCache.has(key)) return cb(null, _cpGeocodeServerCache.get(key) || null);
  const wait = Math.max(0, 1100 - (Date.now() - _cpGeocodeLastAt));
  const run = () => {
    _cpGeocodeLastAt = Date.now();
    const path =
      '/search?format=json&limit=1&countrycodes=nz&q=' + encodeURIComponent(String(q).trim());
    const req = https.request(
      {
        hostname: 'nominatim.openstreetmap.org',
        path,
        method: 'GET',
        headers: {
          Accept: 'application/json',
          'Accept-Language': 'en',
          'User-Agent': 'BookaWaka-CouncilPortal/1.0 (tm-map; contact: support@bookawaka.nz)',
        },
      },
      (res) => {
        let raw = '';
        res.on('data', (c) => (raw += c));
        res.on('end', () => {
          if (res.statusCode && res.statusCode >= 400) {
            return cb('HTTP ' + res.statusCode, null);
          }
          try {
            const arr = JSON.parse(raw);
            if (arr && arr[0] && arr[0].lat != null && arr[0].lon != null) {
              const ll = { lat: Number(arr[0].lat), lon: Number(arr[0].lon) };
              if (Number.isFinite(ll.lat) && Number.isFinite(ll.lon)) {
                _cpGeocodeServerCache.set(key, ll);
                return cb(null, ll);
              }
            }
            _cpGeocodeServerCache.set(key, null);
            return cb(null, null);
          } catch (e: any) {
            return cb(String(e && e.message ? e.message : e), null);
          }
        });
      },
    );
    req.on('error', (e) => cb(String(e.message || e), null));
    req.end();
  };
  if (wait > 0) setTimeout(run, wait);
  else run();
}

// ── Login / logout ─────────────────────────────────────────────────────────────
router.get('/council-portal', (req, res) => {
  const err = (req.query.err as string) || '';
  const errMsgs: Record<string, string> = {
    invalid: 'Invalid email or password.',
    missing: 'Please enter your email and password.',
    nodata: 'Unable to verify credentials. Please try again.',
    session: 'Your session has expired. Please sign in again.'
  };
  const errHtml = err ? `<div class="err-msg">${esc(errMsgs[err] || 'Sign in error.')}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Council Portal — BookaWaka</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:linear-gradient(135deg,#1B5E20,#2E7D32);min-height:100vh;display:flex;align-items:center;justify-content:center;font-family:'Segoe UI',system-ui,sans-serif}
.login-box{background:#fff;border-radius:10px;padding:40px;width:400px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.login-box h1{font-size:22px;color:#1B5E20;margin-bottom:4px}
.login-box p{color:#888;font-size:13px;margin-bottom:28px}
label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
input{width:100%;padding:10px 12px;border:1px solid #ddd;border-radius:6px;font-size:14px;margin-bottom:18px;box-sizing:border-box}
input:focus{outline:none;border-color:#2E7D32;box-shadow:0 0 0 3px rgba(46,125,50,.1)}
button{width:100%;padding:12px;background:#2E7D32;color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:600;cursor:pointer}
button:hover{background:#1B5E20}
.err-msg{background:#FFEBEE;color:#C62828;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px;border-left:4px solid #C62828}
.hint{text-align:center;font-size:12px;color:#aaa;margin-top:18px}
</style></head>
<body>
<div class="login-box">
  <h1>&#127963; Council Portal</h1>
  <p>BookaWaka &mdash; Total Mobility System</p>
  ${errHtml}
  <form method="POST" action="/api/council-login">
    <label>Email Address</label>
    <input type="email" name="email" placeholder="you@council.govt.nz" required autocomplete="email"/>
    <label>Password</label>
    <input type="password" name="password" required autocomplete="current-password"/>
    <button type="submit">Sign In</button>
  </form>
  <p class="hint">Forgot your password?<br>Contact your BookaWaka administrator to reset access.</p>
</div>
</body></html>`);
});

router.post('/api/council-login', (req, res) => {
  const email = ((req.body.email as string) || '').trim().toLowerCase();
  const password = (req.body.password as string) || '';
  if (!email || !password) return res.redirect('/council-portal?err=missing');
  fbAuthSignIn(email, password, (authErr: any, authUser: any) => {
    if (authErr) return res.redirect('/council-portal?err=invalid');
    fbRead('tmCouncilAccess', (err: any, data: any) => {
      if (err || !data) return res.redirect('/council-portal?err=nodata');
      let matched: any = null;
      for (const [cid, acc] of Object.entries(data) as [string, any][]) {
        if (acc && acc.uid === authUser.uid && acc.active !== false) {
          matched = { councilId: cid, ...acc }; break;
        }
      }
      if (!matched) return res.redirect('/council-portal?err=invalid');
      fbRead('tmConfig/' + matched.councilId, (e2: any, cfg: any) => {
        const name = cfg && cfg.name ? cfg.name : matched.councilId;
        const token = cpSetSession(matched.councilId, name, email);
        fbWrite('PUT', 'tmCouncilAccess/' + matched.councilId + '/lastLogin', Date.now(), () => {});
        res.redirect('/council-portal/dashboard?t=' + encodeURIComponent(token));
      });
    });
  });
});

router.get('/api/council-logout', (req, res) => {
  const tok = (req.query.t as string) || '';
  if (tok) cpDeleteSession(tok as string);
  res.redirect('/council-portal');
});

/** TEMP map-debug ring (remove after live map investigation). */
const _cpGeocodeDebugLog: any[] = [];
function cpGeocodeDebugPush(entry: Record<string, unknown>): void {
  _cpGeocodeDebugLog.push({ at: Date.now(), ...entry });
  if (_cpGeocodeDebugLog.length > 40) _cpGeocodeDebugLog.shift();
}

/** Server-side Nominatim proxy — browsers get 403 with default UA. */
router.get('/api/council-geocode', (req, res) => {
  const token = String(req.query.t || '');
  const sess = cpGetSession(token);
  if (!sess) {
    cpGeocodeDebugPush({ kind: 'proxy', ok: false, status: 401, q: String(req.query.q || '').slice(0, 80) });
    return res.status(401).json({ error: 'session' });
  }
  const q = String(req.query.q || '').trim();
  if (!q || q === '—') {
    cpGeocodeDebugPush({ kind: 'proxy', ok: true, status: 200, q, lat: null, lon: null, reason: 'empty' });
    return res.json({ lat: null, lon: null });
  }
  if (q.length > 300) {
    cpGeocodeDebugPush({ kind: 'proxy', ok: false, status: 400, q: q.slice(0, 80) });
    return res.status(400).json({ error: 'query too long' });
  }
  nominatimGeocode(q, (err, ll) => {
    if (err && !ll) {
      cpGeocodeDebugPush({ kind: 'proxy', ok: false, status: 502, q: q.slice(0, 120), detail: err });
      return res.status(502).json({ error: 'geocode_failed', detail: err });
    }
    if (!ll) {
      cpGeocodeDebugPush({ kind: 'proxy', ok: true, status: 200, q: q.slice(0, 120), lat: null, lon: null });
      return res.json({ lat: null, lon: null });
    }
    cpGeocodeDebugPush({
      kind: 'proxy',
      ok: true,
      status: 200,
      q: q.slice(0, 120),
      lat: ll.lat,
      lon: ll.lon,
    });
    res.json({ lat: ll.lat, lon: ll.lon });
  });
});

/**
 * TEMP live map investigation endpoint (no session).
 * GET /api/council-map-debug?k=mapdbg-20260808&action=selftest|log
 * POST /api/council-map-debug?k=mapdbg-20260808&action=beacon  JSON body
 */
router.all('/api/council-map-debug', (req, res) => {
  if (String(req.query.k || '') !== 'mapdbg-20260808') {
    return res.status(404).json({ error: 'not_found' });
  }
  const action = String(req.query.action || req.body?.action || 'log');
  if (action === 'log') {
    return res.json({
      marker: 'map-debug-v1',
      commitHint: '00d6dc5-proxy',
      proxyPath: '/api/council-geocode',
      log: _cpGeocodeDebugLog.slice(-30),
    });
  }
  if (action === 'beacon') {
    const body = req.method === 'POST' ? req.body || {} : req.query;
    cpGeocodeDebugPush({ kind: 'beacon', ...(typeof body === 'object' ? body : { raw: String(body) }) });
    return res.json({ ok: true });
  }
  if (action === 'selftest') {
    const addrs = [
      '305, Kelvin Street, Gladstone, Invercargill',
      '311, Kelvin Street, Gladstone, Invercargill',
    ];
    const results: any[] = [];
    const runNext = (i: number) => {
      if (i >= addrs.length) {
        return res.json({
          marker: 'map-debug-v1',
          from: 'railway-nominatimGeocode',
          results,
          logTail: _cpGeocodeDebugLog.slice(-10),
        });
      }
      const q = addrs[i];
      const t0 = Date.now();
      nominatimGeocode(q, (err, ll) => {
        results.push({
          q,
          ms: Date.now() - t0,
          err: err || null,
          lat: ll ? ll.lat : null,
          lon: ll ? ll.lon : null,
        });
        cpGeocodeDebugPush({
          kind: 'selftest',
          q,
          err: err || null,
          lat: ll ? ll.lat : null,
          lon: ll ? ll.lon : null,
        });
        runNext(i + 1);
      });
    };
    return runNext(0);
  }
  return res.status(400).json({ error: 'bad_action' });
});

// ── Set council password (called from SA admin) ────────────────────────────────
router.post('/api/set-council-password', (req, res) => {
  const { councilId, email, password } = req.body;
  if (!councilId || !email || !password) return res.status(400).json({ error: 'Missing fields' });
  if (password.length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' });
  const emailClean = (email as string).toLowerCase().trim();
  fbAuthCreate(emailClean, password, (authErr: any, authUser: any) => {
    if (authErr) {
      if (authErr.message === 'EMAIL_EXISTS') {
        return res.json({ error: 'A login account already exists for this email. Use the Send Reset Email option to set a new password.' });
      }
      return res.json({ error: authErr.message || 'Failed to create login account' });
    }
    const data = { email: emailClean, uid: authUser.uid, active: true, createdAt: Date.now() };
    fbWrite('PUT', 'tmCouncilAccess/' + councilId, data, (err: any) => {
      if (err) return res.json({ error: String(err) });
      res.json({ ok: true, uid: authUser.uid });
    });
  });
});

const COUNCIL_RETURN_TO_ALLOWED = new Set([
  'pending',
  'anomalies',
  'flagged',
  'archived',
  'reports',
  'trips',
  'all',
  'approved',
  'paid',
  'rejected',
  'submitted',
  'search',
]);

function normalizeCouncilReturnTo(raw: string | undefined, fallback = 'pending'): string {
  const rt = String(raw || fallback).trim().toLowerCase();
  if (COUNCIL_RETURN_TO_ALLOWED.has(rt)) return rt;
  return fallback;
}

/** Post-action redirects always land on unified Trips with a status filter. */
function councilReturnPath(
  returnTo: string,
  te: string,
  filters?: { q?: string; company?: string; from?: string; to?: string } | null,
): string {
  const status = legacyReturnToStatus(returnTo);
  const parts = [`t=${te}`, `status=${encodeURIComponent(status)}`];
  if (filters) {
    for (const k of ['q', 'company', 'from', 'to'] as const) {
      const v = String(filters[k] || '').trim();
      if (v) parts.push(k + '=' + encodeURIComponent(v));
    }
  }
  return '/council-portal/trips?' + parts.join('&');
}

/** Active Trips list filters posted with bulk actions. */
function unifiedFiltersFromBody(body: any): {
  status: string;
  q: string;
  company: string;
  from: string;
  to: string;
} {
  return {
    status: String(body?.status || body?.returnTo || '').trim(),
    q: String(body?.q || '').trim(),
    company: String(body?.company || '').trim(),
    from: String(body?.from || '').trim(),
    to: String(body?.to || '').trim(),
  };
}

function redirectLegacyTripPage(req: Request, res: Response, defaultStatus: string): void {
  const token = (req as any).cpToken;
  const te = encodeURIComponent(token);
  const status = normalizeUnifiedTripStatus(String(req.query.status || defaultStatus));
  const parts = [`t=${te}`, `status=${encodeURIComponent(status)}`];
  for (const k of ['q', 'company', 'from', 'to', 'msg', 'mt'] as const) {
    const v = String(req.query[k] || '').trim();
    if (v) parts.push(k + '=' + encodeURIComponent(v));
  }
  res.redirect('/council-portal/trips?' + parts.join('&'));
}

// ── Approve / reject / return individual trip ─────────────────────────────────
router.post('/api/council-approve', (req, res) => {
  const token = (req.body._token as string) || '';
  const tripCid = (req.body.tripCid as string) || '';
  const tripRawKey = (req.body.tripRawKey as string) || '';
  const action = (req.body.action as string) || '';
  const returnTo = normalizeCouncilReturnTo(req.body.returnTo, 'pending');
  const flagReason = String(req.body.flagReason || '').trim();
  const note = String(req.body.note || req.body.revisionNote || '').trim();
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(returnTo, te);
  if (!sess || !tripCid || !tripRawKey || !['approve', 'reject', 'return'].includes(action)) {
    return res.redirect(base + '&msg=Invalid+request&mt=err');
  }
  // Verify trip belongs to this council
  fbRead('tmTripStatus/' + tripCid + '/' + tripRawKey, (e0: any, st: any) => {
    if (e0 || !st || st.councilId !== sess.councilId) {
      return res.redirect(base + '&msg=Trip+not+found+for+this+council&mt=err');
    }
    if (action === 'return' && !note) {
      return res.redirect(base + '&msg=Revision+note+is+required&mt=err');
    }
    if (action === 'reject' && !note) {
      return res.redirect(base + '&msg=Reject+note+is+required&mt=err');
    }
    const now = Date.now();
    const who = sess.name || sess.councilId;
    let patch: any;
    let msg: string;
    let eventType: 'approved' | 'rejected' | 'returned';
    if (action === 'approve') {
      patch = { status: 'approved', approvedAt: now, approvedBy: who };
      msg = 'Trip approved successfully.';
      eventType = 'approved';
    } else if (action === 'reject') {
      const reason = flagReason || 'other';
      patch = {
        status: 'rejected',
        rejectedAt: now,
        rejectedBy: who,
        flagReasons: [reason],
        rejectNote: note,
        revisionNote: note,
      };
      msg = 'Trip rejected / red-flagged.';
      eventType = 'rejected';
    } else {
      patch = {
        status: 'revision_needed',
        revisionNote: note,
        sentBackAt: now,
        sentBackBy: who,
        flagReasons: Array.isArray(st.flagReasons) ? st.flagReasons : [],
        anomalyDetail: st.anomalyDetail || null,
      };
      msg = 'Trip returned to company for revision.';
      eventType = 'returned';
    }
    fbWrite('PATCH', 'tmTripStatus/' + tripCid + '/' + tripRawKey, patch, (err: any) => {
      if (err) return res.redirect(base + '&msg=Update+failed&mt=err');
      const ev = buildTripEvent(eventType, {
        by: who,
        byRole: 'council',
        note: note || null,
        reasons: eventType === 'rejected' ? [flagReason || 'other'] : null,
        fromStatus: st.status || null,
        toStatus: patch.status,
      });
      appendTripEvent(tripCid, tripRawKey, ev, () => {
        const finish = () =>
          res.redirect(base + '&msg=' + encodeURIComponent(msg) + '&mt=ok');
        if (action !== 'approve') return finish();
        afterCouncilApproveAddToBatch(sess.councilId, tripCid, tripRawKey, who, st, finish);
      });
    });
  });
});

/** Whitelist for council trip field edits (completedJobs PATCH). */
const COUNCIL_TRIP_EDIT_FIELDS: string[] = [
  'tmCardName', 'cardholderName', 'tmPassengerName', 'passengerName', 'customerName',
  'tmVoucherNo', 'tmCardNumber', 'cardNumber',
  'pickupAddress', 'source', 'pickup',
  'dropAddress', 'dropoff', 'destination',
  'fare', 'tmMeterFare', 'meterFare',
  'waitingCost', 'waitingCharge', 'WaitingCost',
  'tmSubsidyFare', 'tmSubsidyHoist', 'tmSubsidy', 'tmPassengerPays', 'tmCouncilPays',
  'startedAt_ISO', 'completedAt_ISO', 'startedAt', 'completedAt',
  'paymentType', 'paymentMethod', 'PaymentMethod', 'payMethod', 'tmPaymentType',
  'distanceKm', 'distance', 'distanceTravelled', 'tripDistanceKm',
  'duration', 'durationMin', 'durationLabel', 'DurationMin',
  'tmTripCategory', 'driverName', 'driverFullName', 'vehicleId', 'taxiNumber',
];

// ── Council edit completed job fields ─────────────────────────────────────────
router.post('/api/council-trip-edit', (req, res) => {
  const token = (req.body._token as string) || '';
  const tripCid = (req.body.tripCid as string) || '';
  const tripRawKey = (req.body.tripRawKey as string) || '';
  const returnTo = normalizeCouncilReturnTo(req.body.returnTo, 'all');
  const resubmit = String(req.body.resubmit || '') === '1';
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(returnTo, te);
  if (!sess || !tripCid || !tripRawKey) {
    return res.redirect(base + '&msg=Invalid+request&mt=err');
  }
  fbRead('tmTripStatus/' + tripCid + '/' + tripRawKey, (e0: any, st: any) => {
    if (e0 || !st || st.councilId !== sess.councilId) {
      return res.redirect(base + '&msg=Trip+not+found+for+this+council&mt=err');
    }
    const patch: Record<string, any> = {};
    COUNCIL_TRIP_EDIT_FIELDS.forEach((k) => {
      if (req.body[k] === undefined) return;
      const raw = req.body[k];
      if (raw === '') {
        patch[k] = '';
        return;
      }
      // numeric fare / distance fields
      if (
        /^(fare|tmMeterFare|meterFare|waitingCost|waitingCharge|WaitingCost|tmSubsidyFare|tmSubsidyHoist|tmSubsidy|tmPassengerPays|tmCouncilPays|distanceKm|distance|distanceTravelled|tripDistanceKm|durationMin|DurationMin)$/.test(
          k,
        )
      ) {
        const n = parseFloat(String(raw));
        if (Number.isFinite(n)) patch[k] = n;
        return;
      }
      patch[k] = String(raw);
    });
    // Convenience aliases from the edit form
    if (req.body.passengerName != null && patch.tmCardName === undefined) {
      patch.tmCardName = String(req.body.passengerName);
    }
    if (req.body.voucherNo != null && patch.tmVoucherNo === undefined) {
      patch.tmVoucherNo = String(req.body.voucherNo);
    }
    // Keep meter aliases in sync when council edits the primary fare field
    if (patch.fare != null && patch.tmMeterFare === undefined) patch.tmMeterFare = patch.fare;
    if (patch.waitingCost != null && patch.waitingCharge === undefined) patch.waitingCharge = patch.waitingCost;
    if (patch.pickupAddress != null && patch.source === undefined) patch.source = patch.pickupAddress;
    if (patch.dropAddress != null && patch.destination === undefined) patch.destination = patch.dropAddress;
    if (patch.durationLabel != null && patch.duration === undefined) patch.duration = patch.durationLabel;
    if (patch.paymentMethod != null && patch.paymentType === undefined) patch.paymentType = patch.paymentMethod;
    const fieldsChanged = Object.keys(patch);
    const who = sess.name || sess.councilId;
    const emitEditedAndRedirect = (okMsg: string) => {
      appendTripEvent(
        tripCid,
        tripRawKey,
        buildTripEvent('council_edited', {
          by: who,
          byRole: 'council',
          fieldsChanged: fieldsChanged.length ? fieldsChanged : null,
        }),
        () => {
          res.redirect(base + '&msg=' + encodeURIComponent(okMsg) + '&mt=ok');
        },
      );
    };
    const finish = () => {
      if (!resubmit) {
        return emitEditedAndRedirect('Trip fields updated.');
      }
      fbWrite(
        'PATCH',
        'tmTripStatus/' + tripCid + '/' + tripRawKey,
        {
          status: 'submitted',
          resubmittedAt: Date.now(),
          resubmittedBy: who,
        },
        (e2: any) => {
          if (e2) return res.redirect(base + '&msg=Job+saved+but+status+update+failed&mt=err');
          emitEditedAndRedirect('Trip updated and marked submitted.');
        },
      );
    };
    if (Object.keys(patch).length === 0 && !resubmit) {
      return res.redirect(base + '&msg=No+fields+to+update&mt=err');
    }
    if (Object.keys(patch).length === 0) return finish();
    fbWrite('PATCH', 'completedJobs/' + tripCid + '/' + tripRawKey, patch, (err: any) => {
      if (err) return res.redirect(base + '&msg=Update+failed&mt=err');
      finish();
    });
  });
});

// ── Save reference price list (tmTariffs) for approved operators ──────────────
router.post('/api/council-tariff-save', (req, res) => {
  const token = (req.body._token as string) || '';
  const cid = String(req.body.cid || '').trim();
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !cid) {
    return res.redirect('/council-portal/operators?t=' + te + '&msg=Invalid+request&mt=err');
  }
  fbRead('tmCompanyAccess/' + cid + '/' + sess.councilId, (e0: any, acc: any) => {
    if (e0 || !acc || acc.approved !== true) {
      return res.redirect(
        '/council-portal/operators?t=' + te + '&msg=Company+not+approved+under+your+council&mt=err',
      );
    }
    const num = (k: string) => {
      const n = parseFloat(String(req.body[k] ?? ''));
      return Number.isFinite(n) ? n : 0;
    };
    const data = {
      car: {
        base: num('car_base'),
        perKm: num('car_perKm'),
        perMin: num('car_perMin'),
        stopFee: num('car_stopFee'),
      },
      van: {
        base: num('van_base'),
        perKm: num('van_perKm'),
        perMin: num('van_perMin'),
        stopFee: num('van_stopFee'),
      },
      updatedAt: Date.now(),
      updatedBy: sess.name || sess.councilId,
      updatedByCouncilId: sess.councilId,
    };
    fbWrite('PUT', 'tmTariffs/' + cid, data, (err: any) => {
      if (err) {
        return res.redirect('/council-portal/operators?t=' + te + '&msg=Save+failed&mt=err');
      }
      res.redirect(
        '/council-portal/operators?t=' +
          te +
          '&msg=' +
          encodeURIComponent('Reference price list saved.') +
          '&mt=ok',
      );
    });
  });
});

// ── Dashboard ──────────────────────────────────────────────────────────────────
router.get('/council-portal/dashboard', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const now = new Date();
  const curMonth = now.toISOString().slice(0, 7);
  loadCouncilTrips(sess.councilId, (err: any, myTrips: any[]) => {
    fbRead('tmConfig/' + sess.councilId, (e2: any, cfg: any) => {
      fbRead('tmCompanyAccess', (e3: any, allAccess: any) => {
      let approvedOps = 0;
      if (allAccess && typeof allAccess === 'object') {
        Object.values(allAccess).forEach((councils: any) => {
          if (councils && councils[sess.councilId] && councils[sess.councilId].approved) approvedOps++;
        });
      }
      const thisMonthTrips = myTrips.filter((t) => tripMonthKey(t) === curMonth);
      let totalCouncilPays = 0, pendingCount = 0, flaggedCount = 0;
      thisMonthTrips.forEach(t => {
        totalCouncilPays += parseFloat(t.tmSubsidy || 0);
        if (t.status === 'submitted') pendingCount++;
        if (t.status === 'flagged') flaggedCount++;
      });
      const avg = thisMonthTrips.length ? (totalCouncilPays / thisMonthTrips.length).toFixed(2) : '0.00';
      const recent = [...myTrips].sort(compareTripsNewestFirst).slice(0, 10);
      const configHtml = cfg ? `
<div class="cp-card"><div class="cp-card-hd"><h3>Council Configuration ${provenanceBadgeHtml({ kind: 'synced', label: 'Live', detail: 'Council source of truth for subsidy / cap / hoist' })}</h3></div><div class="cp-card-bd">
<table style="font-size:13px;width:100%">
<tr><td style="padding:4px 8px;color:#666">Region</td><td style="padding:4px 8px;font-weight:500">${esc(cfg.region || '—')}</td>
    <td style="padding:4px 8px;color:#666">Subsidy Cap</td><td style="padding:4px 8px;font-weight:500">$${parseFloat(cfg.capAmount || 0).toFixed(2)}</td></tr>
<tr><td style="padding:4px 8px;color:#666">Subsidy %</td><td style="padding:4px 8px;font-weight:500">${cfg.subsidyPercent || 0}%</td>
    <td style="padding:4px 8px;color:#666">Hoist Fee</td><td style="padding:4px 8px;font-weight:500">$${parseFloat(cfg.hoistRatePerUse || 0).toFixed(2)} / use <span style="color:#888;font-size:11px">(100% council)</span></td></tr>
<tr><td style="padding:4px 8px;color:#666">Monthly Limit</td><td style="padding:4px 8px;font-weight:500">${cfg.monthlyLimitPerPassenger || 'No limit'}</td>
    <td style="padding:4px 8px;color:#666">Daily Limit</td><td style="padding:4px 8px;font-weight:500">${cfg.dailyLimitPerPassenger || 'No limit'}</td></tr>
</table>
<p style="font-size:12px;margin-top:10px"><a href="/council-portal/config?t=${encodeURIComponent(token)}" style="color:#2E7D32;font-weight:600">Edit subsidy %, cap &amp; hoist rate &rarr;</a></p>
</div></div>` : '';
      const recentRows = recent.map(t => {
        const dt = t.startedAt_ISO ? t.startedAt_ISO.slice(0, 16).replace('T', ' ') : '—';
        return `<tr><td style="font-family:monospace;font-size:11px">${esc(t.tmVoucherNo || t._rawKey)}</td>
<td>${esc(t.tmPassengerName || '—')}</td>
<td style="font-size:12px;color:#555">${esc(t._companyName || '—')}</td>
<td>${dt}</td><td>$${parseFloat(t.fare || 0).toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:600">$${parseFloat(t.tmSubsidy || 0).toFixed(2)}</td>
<td>${statusBadge(t.status)}</td></tr>`;
      }).join('');
      const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:6px">Dashboard snapshot</h2>
<p style="font-size:13px;color:#666;margin-bottom:14px">At-a-glance: approved operators, this month&rsquo;s TM activity, and recent trips.</p>
<div class="cp-stats">
  <div class="cp-stat"><div class="cp-stat-v">${approvedOps}</div><div class="cp-stat-l">Approved Companies</div></div>
  <div class="cp-stat"><div class="cp-stat-v">${thisMonthTrips.length}</div><div class="cp-stat-l">Trips This Month (${esc(curMonth)})</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totalCouncilPays.toFixed(2)}</div><div class="cp-stat-l">Council Pays This Month</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${avg}</div><div class="cp-stat-l">Avg Per Trip</div></div>
  ${pendingCount > 0 ? `<div class="cp-stat flag"><div class="cp-stat-v">${pendingCount}</div><div class="cp-stat-l"><a href="/council-portal/trips?t=${encodeURIComponent(token)}&status=pending" style="color:inherit">Awaiting Your Approval</a></div></div>` : ''}
  ${flaggedCount > 0 ? `<div class="cp-stat flag"><div class="cp-stat-v">${flaggedCount}</div><div class="cp-stat-l"><a href="/council-portal/trips?t=${encodeURIComponent(token)}&status=flagged" style="color:inherit">Flagged anomalies</a></div></div>` : ''}
</div>
${configHtml}
<div class="cp-card">
  <div class="cp-card-hd"><h3>Recent TM activity (${recent.length})</h3>
    <a href="/council-portal/trips?t=${encodeURIComponent(token)}&status=all" style="font-size:12px;color:#2E7D32">View all &rarr;</a></div>
  ${recent.length ? `<table class="cp-tbl"><thead><tr><th>Voucher No.</th><th>Passenger</th><th>Operator</th><th>Date</th><th>Fare</th><th>Council Pays</th><th>Status</th></tr></thead>
<tbody>${recentRows}</tbody></table>` : '<div class="cp-empty">No trips submitted to this council yet.</div>'}
</div>`;
      res.send(portalPage('Dashboard', renderNav(sess, token, 'dashboard'), body));
      });
    });
  });
});

// ── Trips (unified) ───────────────────────────────────────────────────────────
router.get('/council-portal/trips', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const te = encodeURIComponent(token);
  const status = normalizeUnifiedTripStatus(String(req.query.status || 'all'));
  const q = String(req.query.q || '').trim();
  const filterCompany = String(req.query.company || '').trim();
  const filterFrom = String(req.query.from || '').trim();
  const filterTo = String(req.query.to || '').trim();
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(msg)}</div>` : '';

  const keepQs = (extraStatus?: string) => {
    const parts = [`t=${te}`, `status=${encodeURIComponent(extraStatus || status)}`];
    if (q) parts.push('q=' + encodeURIComponent(q));
    if (filterCompany) parts.push('company=' + encodeURIComponent(filterCompany));
    if (filterFrom) parts.push('from=' + encodeURIComponent(filterFrom));
    if (filterTo) parts.push('to=' + encodeURIComponent(filterTo));
    return parts.join('&');
  };

  loadCouncilTrips(sess.councilId, (_err: any, myTrips: any[]) => {
    scanAndRefreshTrips(myTrips, (scanned) => {
      const universe = filterTripsUnified(scanned, {
        status: 'all',
        q,
        companyId: filterCompany,
        from: filterFrom,
        to: filterTo,
      }).concat(
        filterTripsUnified(scanned, {
          status: 'archived',
          q,
          companyId: filterCompany,
          from: filterFrom,
          to: filterTo,
        }),
      );
      const counts = countTripsByUnifiedStatus(universe);
      const displayTrips = filterTripsUnified(scanned, {
        status,
        q,
        companyId: filterCompany,
        from: filterFrom,
        to: filterTo,
      });
      const companyOpts = companyFilterOptionsHtml(scanned, filterCompany);
      const tariffCids = Array.from(
        new Set(displayTrips.map((t) => String(t._cid || '')).filter(Boolean)),
      );
      loadTariffsForCids(tariffCids, (tariffByCid) => {
        const details = displayTrips.map((t) =>
          buildTmTripDetail(t, { refTariff: (tariffByCid[t._cid] || {}).car || null }),
        );
        let totFare = 0,
          totCouncil = 0,
          totPax = 0;
        details.forEach((d) => {
          totFare += d.meterFare;
          totCouncil += d.totalCouncil;
          totPax += d.passengerPays;
        });
        const usage = aggregateTripUsage(displayTrips);
        const usageByDay = aggregateUsageByDay(displayTrips);
        const usageByMonth = aggregateUsageByMonth(displayTrips);
        const returnTo = status;
        const showCheckbox = status === 'pending' || status === 'flagged' || status === 'archived';

        const statusOpts = UNIFIED_TRIP_STATUS_OPTIONS.map(
          (o) =>
            `<option value="${esc(o.value)}"${o.value === status ? ' selected' : ''}>${esc(o.label)}</option>`,
        ).join('');

        const tabsHtml =
          `<div class="cp-tabs">` +
          UNIFIED_TRIP_STATUS_OPTIONS.map((o) => {
            const n = counts[o.value] || 0;
            return `<a class="cp-tab${o.value === status ? ' on' : ''}" href="/council-portal/trips?${keepQs(o.value)}">${esc(o.label)}<span class="cp-tab-n">${n}</span></a>`;
          }).join('') +
          `</div>`;

        const entityFilterQs =
          (filterFrom ? `&from=${encodeURIComponent(filterFrom)}` : '') +
          (filterTo ? `&to=${encodeURIComponent(filterTo)}` : '') +
          (filterCompany ? `&company=${encodeURIComponent(filterCompany)}` : '');
        const entityHref = (type: string, key: string) =>
          `/council-portal/entity?t=${te}&type=${encodeURIComponent(type)}&key=${encodeURIComponent(key)}${entityFilterQs}`;

        const usageTable = (title: string, rows: typeof usage.byCard, entityType: string) =>
          `<div style="flex:1;min-width:200px"><h4 style="font-size:12.5px;color:#33691E;margin:0 0 8px">${esc(title)}</h4>` +
          (rows.length
            ? `<table class="cp-tbl"><thead><tr><th>Name</th><th>Trips</th><th>Council $</th><th>Hoist $</th></tr></thead><tbody>` +
              rows
                .map(
                  (r) =>
                    `<tr><td><a href="${entityHref(entityType, r.key)}" style="color:#2E7D32;font-weight:600">${esc(r.label)}</a></td><td>${r.trips}</td><td>$${r.councilPays.toFixed(2)}</td><td>$${(r.hoistPays || 0).toFixed(2)}</td></tr>`,
                )
                .join('') +
              `</tbody></table>`
            : '<div class="cp-empty" style="padding:12px">No data</div>') +
          '</div>';

        const periodTable = (title: string, rows: typeof usageByDay) =>
          `<details style="margin-top:12px"><summary style="cursor:pointer;font-weight:600;color:#33691E">${esc(title)}</summary>` +
          (rows.length
            ? `<table class="cp-tbl" style="margin-top:8px"><thead><tr><th>Period</th><th>Trips</th><th>Council $</th><th>Hoist $</th><th>Hoist uses</th></tr></thead><tbody>` +
              rows
                .map(
                  (r) =>
                    `<tr><td>${esc(r.key)}</td><td>${r.trips}</td><td>$${r.councilPays.toFixed(2)}</td><td>$${r.hoistPays.toFixed(2)}</td><td>${r.hoistUses}</td></tr>`,
                )
                .join('') +
              `</tbody></table>`
            : '<div class="cp-empty" style="padding:12px">No data</div>') +
          '</details>';

        const insightsOpen = filterFrom || filterTo ? ' open' : '';
        const insightsHtml = `<details class="cp-card" style="padding:14px 18px;margin-bottom:18px"${insightsOpen}>
  <summary style="cursor:pointer;font-weight:700;color:#1B5E20">Insights — usage by card, driver, vehicle &amp; passenger</summary>
  <div style="display:flex;gap:18px;flex-wrap:wrap;margin-top:12px">
    ${usageTable('By card', usage.byCard, 'card')}
    ${usageTable('By driver', usage.byDriver, 'driver')}
    ${usageTable('By vehicle', usage.byVehicle, 'vehicle')}
    ${usageTable('By passenger', usage.byPassenger, 'passenger')}
  </div>
  ${periodTable('Usage by day', usageByDay)}
  ${periodTable('Usage by month', usageByMonth)}
</details>`;

        const filterHiddens =
          `<input type="hidden" name="status" value="${esc(status)}"/>` +
          `<input type="hidden" name="q" value="${esc(q)}"/>` +
          `<input type="hidden" name="company" value="${esc(filterCompany)}"/>` +
          `<input type="hidden" name="from" value="${esc(filterFrom)}"/>` +
          `<input type="hidden" name="to" value="${esc(filterTo)}"/>`;

        let toolbar = '';
        if (status === 'pending' && displayTrips.length) {
          toolbar = `<div style="margin-bottom:14px;display:flex;flex-wrap:wrap;gap:8px;align-items:center">
<form method="POST" action="/api/council-bulk-approve" style="display:inline" onsubmit="return confirm('Approve ${displayTrips.length} trip(s) matching the current filters?')">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="pending"/>
  <input type="hidden" name="allClean" value="1"/>
  ${filterHiddens}
  <button type="submit" class="cp-btn cp-btn-g">&#10003; Approve All (${displayTrips.length})</button>
</form>
<form id="cp-bulk-archive" method="POST" action="/api/council-bulk-archive" style="display:inline-flex;flex-wrap:wrap;gap:8px;align-items:center" onsubmit="return cpBulkArchiveConfirm()">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="pending"/>
  ${filterHiddens}
  <label style="font-size:12.5px;font-weight:600;color:#555">Archive note (optional)</label>
  <input name="note" class="cp-input" style="min-width:200px" placeholder="Optional note"/>
  <button type="submit" class="cp-btn" style="background:#757575;color:#fff">&#128193; Archive selected</button>
</form>
<form method="POST" action="/api/council-bulk-archive" style="display:inline" onsubmit="return cpBulkArchiveAll(${displayTrips.length})">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="pending"/>
  <input type="hidden" name="allMatching" value="1"/>
  ${filterHiddens}
  <button type="submit" class="cp-btn" style="background:#616161;color:#fff">&#128193; Archive all matching (${displayTrips.length})</button>
</form>
</div>`;
        } else if (status === 'flagged' && displayTrips.length) {
          toolbar = `<p style="font-size:12.5px;color:#5d4037;margin-bottom:12px;padding:10px 12px;background:#FFF8E1;border-left:4px solid #E65100;border-radius:4px"><strong>Return unlocks company editing.</strong> The trip stays view-only for the company until you click Return — this ensures council reviews the original flagged data before anything can be edited.</p>
<form id="cp-bulk-return" method="POST" action="/api/council-bulk-return" style="margin-bottom:12px" onsubmit="return cpBulkReturn(this)">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="flagged"/>
  ${filterHiddens}
  <label style="font-size:12.5px;font-weight:600;color:#555;margin-right:8px">Revision note (required)</label>
  <input name="note" class="cp-input" style="min-width:240px;margin-right:8px" placeholder="Note for company" required/>
  <button type="submit" class="cp-btn" style="background:#E65100;color:#fff">&#8617; Return selected</button>
</form>
<form id="cp-bulk-archive" method="POST" action="/api/council-bulk-archive" style="display:inline-flex;flex-wrap:wrap;gap:8px;align-items:center;margin-bottom:12px" onsubmit="return cpBulkArchiveSelected(this)">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="flagged"/>
  ${filterHiddens}
  <label style="font-size:12.5px;font-weight:600;color:#555">Archive note (optional)</label>
  <input name="note" class="cp-input" style="min-width:200px" placeholder="Optional note"/>
  <button type="submit" class="cp-btn" style="background:#757575;color:#fff">&#128193; Archive selected</button>
</form>
<form method="POST" action="/api/council-bulk-archive" style="display:inline;margin-left:8px;margin-bottom:12px" onsubmit="return cpBulkArchiveAll(${displayTrips.length})">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="flagged"/>
  <input type="hidden" name="allMatching" value="1"/>
  ${filterHiddens}
  <button type="submit" class="cp-btn" style="background:#616161;color:#fff">&#128193; Archive all matching (${displayTrips.length})</button>
</form>`;
        } else if (status === 'archived' && displayTrips.length) {
          toolbar = `<div style="margin-bottom:14px">
<form id="cp-bulk-restore" method="POST" action="/api/council-bulk-restore" style="display:inline-flex;flex-wrap:wrap;gap:8px;align-items:center" onsubmit="return cpBulkRestoreSelected(this)">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="archived"/>
  ${filterHiddens}
  <button type="submit" class="cp-btn cp-btn-g">&#8634; Restore selected</button>
</form>
<form method="POST" action="/api/council-bulk-restore" style="display:inline;margin-left:8px" onsubmit="return cpBulkRestoreAll(${displayTrips.length})">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="returnTo" value="archived"/>
  <input type="hidden" name="allMatching" value="1"/>
  ${filterHiddens}
  <button type="submit" class="cp-btn" style="background:#2E7D32;color:#fff">&#8634; Restore all matching (${displayTrips.length})</button>
</form>
</div>`;
        }

        const checkboxForm =
          status === 'pending'
            ? 'cp-bulk-archive'
            : status === 'flagged'
              ? 'cp-bulk-return'
              : status === 'archived'
                ? 'cp-bulk-restore'
                : '';

        const rowActions = (t: any, idx: number, d: TmTripDetail): string => {
          const rt = esc(returnTo);
          let h = `<button type="button" class="cp-btn-sm" style="margin-right:4px" onclick="openCpDetail(${idx})">Details</button>`;
          if (status === 'pending') {
            h += `
  <form method="POST" action="/api/council-approve" style="display:inline">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="approve"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <button type="submit" class="cp-btn cp-btn-g" style="margin-right:4px">&#10003; Approve</button>
  </form>
  <form method="POST" action="/api/council-approve" style="display:inline" onsubmit="return cpRejectTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="reject"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <input type="hidden" name="flagReason" value=""/>
    <input type="hidden" name="note" value=""/>
    <button type="submit" class="cp-btn cp-btn-r" style="margin-right:4px">&#10007; Reject</button>
  </form>
  <form method="POST" action="/api/council-approve" style="display:inline" onsubmit="return cpReturnTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="return"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <input type="hidden" name="note" value=""/>
    <button type="submit" class="cp-btn" style="background:#E65100;color:#fff;margin-right:4px">&#8617; Return</button>
  </form>
  <form method="POST" action="/api/council-archive" style="display:inline" onsubmit="return cpArchiveTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <button type="submit" class="cp-btn" style="background:#757575;color:#fff">&#128193; Archive</button>
  </form>`;
          } else if (status === 'flagged') {
            h += `
  <form method="POST" action="/api/council-approve" style="display:inline" onsubmit="return cpReturnTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="return"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <input type="hidden" name="note" value=""/>
    <button type="submit" class="cp-btn" style="background:#E65100;color:#fff;margin-right:4px">&#8617; Return</button>
  </form>
  <form method="POST" action="/api/council-approve" style="display:inline" onsubmit="return cpRejectTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="reject"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <input type="hidden" name="flagReason" value=""/>
    <input type="hidden" name="note" value=""/>
    <button type="submit" class="cp-btn cp-btn-r" style="margin-right:4px">&#10007; Reject</button>
  </form>
  <form method="POST" action="/api/council-archive" style="display:inline" onsubmit="return cpArchiveTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <button type="submit" class="cp-btn" style="background:#757575;color:#fff">&#128193; Archive</button>
  </form>`;
          } else if (status === 'archived' || isArchivedStatus(d.status)) {
            h += `
  <form method="POST" action="/api/council-restore" style="display:inline" onsubmit="return cpRestoreTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <button type="submit" class="cp-btn cp-btn-g">&#8634; Restore</button>
  </form>`;
          } else {
            h += `
  <form method="POST" action="/api/council-archive" style="display:inline" onsubmit="return confirm('Archive this trip?')">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(d.cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(d.rawKey)}"/>
    <input type="hidden" name="returnTo" value="${rt}"/>
    <button type="submit" class="cp-btn-sm" style="background:#757575">Archive</button>
  </form>`;
          }
          return h;
        };

        const rows = displayTrips
          .map((t, idx) => {
            const d = details[idx];
            const chips = flagReasonChips(t.flagReasons, t.anomalyDetail);
            const tripKey = esc(String(t._cid) + '|' + String(t._rawKey));
            const cb = showCheckbox
              ? `<td onclick="event.stopPropagation()"><input type="checkbox" name="trip" value="${tripKey}" form="${checkboxForm}"/></td>`
              : '';
            return `<tr class="cp-row-click" data-idx="${idx}" onclick="openCpDetail(${idx})">
${cb}
<td>${esc(d.dateTime || '—')}</td>
<td style="font-size:12px;color:#555">${esc(d.companyName)}</td>
<td>${esc(d.passengerName)}</td>
<td>${esc(d.driverName || '—')}</td>
<td>${esc(d.pickup)}</td>
<td>${esc(d.dropoff)}</td>
<td>$${d.meterFare.toFixed(2)}</td>
<td style="font-weight:700;color:#1B5E20">$${d.totalCouncil.toFixed(2)}</td>
<td>$${d.passengerPays.toFixed(2)}</td>
<td>${statusBadge(d.status)}${chips ? `<div style="margin-top:3px">${chips}</div>` : ''}</td>
<td style="white-space:nowrap" onclick="event.stopPropagation()">${rowActions(t, idx, d)}</td>
</tr>`;
          })
          .join('');

        const bodyHtmlByIdx = details.map((d, idx) => {
          const src = displayTrips[idx] || {};
          const chips = flagReasonChips(src.flagReasons, src.anomalyDetail);
          const chipBlock = chips
            ? `<div style="margin:10px 0 0;padding:8px 10px;border-radius:6px;background:#FFEBEE;font-size:12px"><strong style="color:#C62828">Anomaly flags</strong><div style="margin-top:4px">${chips}</div>${src.anomalyDetail ? `<div style="margin-top:4px;color:#888">${esc(String(src.anomalyDetail))}</div>` : ''}</div>`
            : '';
          return tripDetailModalHtml(d) + chipBlock + tripHistoryHtml(src);
        });
        const tripsJson = JSON.stringify(details).replace(/</g, '\\u003c');
        const bodiesJson = JSON.stringify(bodyHtmlByIdx).replace(/</g, '\\u003c');

        const exportQs =
          `&company=${encodeURIComponent(filterCompany)}` +
          `&from=${encodeURIComponent(filterFrom)}` +
          `&to=${encodeURIComponent(filterTo)}` +
          `&q=${encodeURIComponent(q)}` +
          (status !== 'all' ? `&status=${encodeURIComponent(status)}` : '') +
          (status === 'archived' ? '&includeArchived=1' : '');

        const hasFilters = !!(q || filterCompany || filterFrom || filterTo || status !== 'all');
        const thead =
          (showCheckbox ? '<th></th>' : '') +
          '<th>Date</th><th>Operator</th><th>Passenger</th><th>Driver</th><th>Pickup</th><th>Dropoff</th><th>Meter</th><th>Council</th><th>Pax</th><th>Status</th><th>Actions</th>';

        const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:6px">Trips</h2>
${noticeHtml}
<p style="font-size:13px;color:#666;margin-bottom:14px">Review, approve, flag, archive, and explore trip usage in one place. Manage operator access on <a href="/council-portal/operators?t=${te}" style="color:#2E7D32;font-weight:600">Operators</a>.</p>
<form method="GET" action="/council-portal/trips" class="cp-search-hero">
  <input type="hidden" name="t" value="${esc(token)}"/>
  <input type="hidden" name="status" value="${esc(status)}"/>
  <input type="hidden" name="company" value="${esc(filterCompany)}"/>
  <input type="hidden" name="from" value="${esc(filterFrom)}"/>
  <input type="hidden" name="to" value="${esc(filterTo)}"/>
  <label for="cp-trips-search">&#128269; Search trips</label>
  <div class="cp-search-hero-row">
    <input id="cp-trips-search" type="search" name="q" value="${esc(q)}" placeholder="Job ID, voucher, passenger, driver, card number…" autocomplete="off" autofocus/>
    <button type="submit" class="cp-btn cp-btn-g">Search</button>
    ${q ? `<a href="/council-portal/trips?t=${te}&status=${encodeURIComponent(status)}${filterCompany ? '&company=' + encodeURIComponent(filterCompany) : ''}${filterFrom ? '&from=' + encodeURIComponent(filterFrom) : ''}${filterTo ? '&to=' + encodeURIComponent(filterTo) : ''}" class="cp-btn" style="background:#eee;color:#333">Clear search</a>` : ''}
  </div>
  <p style="font-size:12px;color:#666;margin:8px 0 0">Search runs across the current status tab and other filters below.</p>
</form>
${tabsHtml}
<div class="cp-month-row">
  <form method="GET" action="/council-portal/trips" style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap">
    <input type="hidden" name="t" value="${esc(token)}"/>
    <input type="hidden" name="q" value="${esc(q)}"/>
    <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">Status</label>
      <select name="status" class="cp-input">${statusOpts}</select></div>
    <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">Company</label>
      <select name="company" class="cp-input"><option value="">All Companies</option>${companyOpts}</select></div>
    <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">From</label>
      <input type="date" name="from" class="cp-input" value="${esc(filterFrom)}"/></div>
    <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">To</label>
      <input type="date" name="to" class="cp-input" value="${esc(filterTo)}"/></div>
    <button type="submit" class="cp-btn cp-btn-g">Apply filters</button>
    ${hasFilters ? `<a href="/council-portal/trips?t=${te}&status=all" class="cp-btn" style="background:#eee;color:#333">Clear all</a>` : ''}
  </form>
  <a href="/council-portal/export?t=${te}${exportQs}" class="cp-btn cp-btn-g" style="margin-left:auto">&#11015; Download CSV</a>
</div>
<div class="cp-stats">
  <div class="cp-stat"><div class="cp-stat-v">${details.length}</div><div class="cp-stat-l">Trips in selection</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totFare.toFixed(2)}</div><div class="cp-stat-l">Total Meter Fare</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totCouncil.toFixed(2)}</div><div class="cp-stat-l">Total Council Claim</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totPax.toFixed(2)}</div><div class="cp-stat-l">Total Passenger Pays</div></div>
</div>
${toolbar}
${insightsHtml}
<div class="cp-card" style="overflow-x:auto">
  <div class="cp-card-hd"><h3>Trip list</h3>
    <span style="font-size:12px;color:#888">${details.length} trip(s) — click for full detail</span></div>
  ${details.length ? `<table class="cp-tbl">
<thead><tr>${thead}</tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="cp-empty">No trips for this selection.</div>'}
</div>
${cpTripDetailOverlayHtml()}
${CP_TRIP_ACTION_SCRIPT}
${CP_TRIP_MAP_SCRIPT}
<script>
var _cpTrips = ${tripsJson};
var _cpBodies = ${bodiesJson};
var _cpToken = ${JSON.stringify(token)};
var _cpReturnTo = ${JSON.stringify(returnTo)};
function cpBulkReturn(form){
  var boxes = document.querySelectorAll('input[name="trip"]:checked');
  if(!boxes.length){ alert('Select at least one trip.'); return false; }
  var note = (form.note && form.note.value || '').trim();
  if(!note){ alert('A revision note is required.'); return false; }
  form.querySelectorAll('input[data-ret-inj]').forEach(function(el){ el.remove(); });
  boxes.forEach(function(b){
    var inp = document.createElement('input');
    inp.type = 'hidden';
    inp.name = 'trip';
    inp.value = b.value;
    inp.setAttribute('data-ret-inj','1');
    form.appendChild(inp);
  });
  return confirm('Return '+boxes.length+' flagged trip(s) to company?');
}
</script>
${cpTripDetailBehaviorScript(true)}`;

        res.send(portalPage('Trips', renderNav(sess, token, 'trips'), body));
      });
    });
  });
});

// ── Legacy trip pages → unified Trips ─────────────────────────────────────────
router.get('/council-portal/flagged', requirePortalAuth, (req, res) => {
  redirectLegacyTripPage(req, res, 'flagged');
});

const CP_TRIP_ACTION_SCRIPT = `
<script>
function cpRejectTrip(form){
  var reason = prompt('Flag reason:\\nfare_mismatch, waiting_charged, hoist_rate_mismatch, or other','other');
  if(reason===null) return false;
  reason = String(reason||'').trim() || 'other';
  var allowed = {fare_mismatch:1,waiting_charged:1,hoist_rate_mismatch:1,other:1};
  if(!allowed[reason]) reason = 'other';
  var note = prompt('Reject note (required):','');
  if(note===null) return false;
  note = String(note||'').trim();
  if(!note){ alert('A reject note is required.'); return false; }
  form.flagReason.value = reason;
  form.note.value = note;
  return true;
}
function cpReturnTrip(form){
  var note = prompt('Revision comment for the company (required):','');
  if(note===null) return false;
  note = String(note||'').trim();
  if(!note){ alert('A revision comment is required.'); return false; }
  form.note.value = note;
  return true;
}
function cpArchiveTrip(form){
  return confirm('Archive this trip? You can restore it later from Archived.');
}
function cpBulkArchiveConfirm(){
  var boxes = document.querySelectorAll('input[name="trip"]:checked');
  if(!boxes.length){ alert('Select at least one trip.'); return false; }
  return confirm('Archive '+boxes.length+' selected trip(s)?');
}
function cpBulkArchiveSelected(form){
  var boxes = document.querySelectorAll('input[name="trip"]:checked');
  if(!boxes.length){ alert('Select at least one trip.'); return false; }
  form.querySelectorAll('input[data-arch-inj]').forEach(function(el){ el.remove(); });
  boxes.forEach(function(b){
    var inp = document.createElement('input');
    inp.type = 'hidden';
    inp.name = 'trip';
    inp.value = b.value;
    inp.setAttribute('data-arch-inj','1');
    form.appendChild(inp);
  });
  return confirm('Archive '+boxes.length+' selected trip(s)?');
}
function cpBulkArchiveAll(n){
  return confirm('Archive all '+n+' trip(s) currently listed on this page?');
}
function cpRestoreTrip(form){
  return confirm('Restore this trip to its previous status?');
}
function cpBulkRestoreSelected(form){
  var boxes = document.querySelectorAll('input[name="trip"]:checked');
  if(!boxes.length){ alert('Select at least one trip.'); return false; }
  form.querySelectorAll('input[data-res-inj]').forEach(function(el){ el.remove(); });
  boxes.forEach(function(b){
    var inp = document.createElement('input');
    inp.type = 'hidden';
    inp.name = 'trip';
    inp.value = b.value;
    inp.setAttribute('data-res-inj','1');
    form.appendChild(inp);
  });
  return confirm('Restore '+boxes.length+' selected trip(s)?');
}
function cpBulkRestoreAll(n){
  return confirm('Restore all '+n+' archived trip(s) on this page?');
}
</script>`;

/** Shared Leaflet map + address fallback via server geocode proxy (Nominatim blocks browser UAs). */
const CP_TRIP_MAP_SCRIPT = `
<script>
var _cpMap = null;
var _cpMapGen = 0;
var _cpGeocache = {};
var _cpGeocodeQueue = [];
var _cpGeocoding = false;
function cpMapDbg(msg, obj){
  var el = document.getElementById('cp-trip-map-debug');
  if(!el) return;
  el.style.display = 'block';
  var line = msg + (obj !== undefined ? ' ' + JSON.stringify(obj) : '');
  el.textContent = (el.textContent ? el.textContent + '\\n' : '') + line;
  try{
    fetch('/api/council-map-debug?k=mapdbg-20260808&action=beacon', {
      method:'POST',
      headers:{'Content-Type':'application/json','Accept':'application/json'},
      body: JSON.stringify({msg:msg, obj:obj || null, href: location.pathname})
    }).catch(function(){});
  }catch(e){}
}
function cpMapStatus(msg){
  var el = document.getElementById('cp-trip-map-status');
  if(!el) return;
  el.textContent = msg || '';
  el.style.display = msg ? 'block' : 'none';
  if(msg) cpMapDbg('status', msg);
}
function cpDestroyTripMap(){
  if(_cpMap){ try{_cpMap.remove();}catch(e){} _cpMap=null; }
}
function cpGeocodeAddr(addr){
  addr = String(addr||'').trim();
  if(!addr || addr==='—') return Promise.resolve(null);
  if(_cpGeocache[addr]) return Promise.resolve(_cpGeocache[addr]);
  return new Promise(function(resolve){
    _cpGeocodeQueue.push({addr:addr, resolve:resolve});
    cpProcessGeocodeQueue();
  });
}
function cpProcessGeocodeQueue(){
  if(_cpGeocoding || !_cpGeocodeQueue.length) return;
  _cpGeocoding = true;
  var item = _cpGeocodeQueue.shift();
  if(_cpGeocache[item.addr]){
    item.resolve(_cpGeocache[item.addr]);
    _cpGeocoding = false;
    cpProcessGeocodeQueue();
    return;
  }
  var tok = typeof _cpToken === 'string' ? _cpToken : '';
  var url = '/api/council-geocode?t='+encodeURIComponent(tok)+'&q='+encodeURIComponent(item.addr);
  cpMapDbg('geocode fetch start', {addr:item.addr, tokLen: tok.length, url: url.replace(/t=[^&]+/,'t=…')});
  fetch(url,{headers:{'Accept':'application/json'}}).then(function(r){
    cpMapDbg('geocode HTTP', {addr:item.addr, status:r.status, ok:r.ok});
    if(!r.ok) throw new Error('geocode HTTP '+r.status);
    return r.json();
  }).then(function(j){
    cpMapDbg('geocode JSON', {addr:item.addr, body:j});
    var ll = null;
    if(j && j.lat != null && j.lon != null){
      ll = [Number(j.lat), Number(j.lon)];
      if(Number.isFinite(ll[0]) && Number.isFinite(ll[1])) _cpGeocache[item.addr] = ll;
      else ll = null;
    }
    item.resolve(ll);
  }).catch(function(err){
    cpMapDbg('geocode ERROR', {addr:item.addr, err: String(err && err.message ? err.message : err)});
    item.resolve(null);
  }).then(function(){
    _cpGeocoding = false;
    setTimeout(cpProcessGeocodeQueue, 1100);
  });
}
function cpReportMapLayout(tag){
  var el = document.getElementById('cp-trip-map');
  var wrap = document.getElementById('cp-trip-map-wrap');
  var ov = document.getElementById('cp-detail-ov');
  var modal = ov ? ov.querySelector('.cp-modal') : null;
  var size = _cpMap ? _cpMap.getSize() : null;
  var layers = 0;
  try{ if(_cpMap) _cpMap.eachLayer(function(){ layers++; }); }catch(e){}
  cpMapDbg('map layout '+tag, {
    elW: el ? el.clientWidth : null,
    elH: el ? el.clientHeight : null,
    wrapW: wrap ? wrap.clientWidth : null,
    wrapH: wrap ? wrap.clientHeight : null,
    modalScroll: modal ? modal.scrollTop : null,
    modalClientH: modal ? modal.clientHeight : null,
    modalScrollH: modal ? modal.scrollHeight : null,
    leafletSize: size ? {x:size.x,y:size.y} : null,
    layerCount: layers,
    paneCount: el ? el.querySelectorAll('.leaflet-tile-pane img').length : 0
  });
}
function cpDrawTripMap(puLL, duLL, gen){
  if(gen != null && gen !== _cpMapGen) return;
  var el = document.getElementById('cp-trip-map');
  if(!el || typeof L==='undefined') return;
  cpDestroyTripMap();
  if(gen != null && gen !== _cpMapGen) return;
  if(!puLL && !duLL){
    cpMapStatus('Map unavailable — no coordinates or geocodable addresses.');
    return;
  }
  cpMapDbg('cpDrawTripMap', {puLL:puLL, duLL:duLL, gen:gen});
  var center = puLL || duLL;
  _cpMap = L.map(el).setView(center, 13);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19, attribution: '&copy; OpenStreetMap'
  }).addTo(_cpMap);
  var bounds = [];
  if(puLL){
    L.marker(puLL).addTo(_cpMap).bindPopup('Pickup');
    bounds.push(puLL);
  }
  if(duLL){
    L.marker(duLL).addTo(_cpMap).bindPopup('Dropoff');
    bounds.push(duLL);
  }
  if(puLL && duLL){
    L.polyline([puLL, duLL], {color:'#1B5E20', weight:5, opacity:0.92}).addTo(_cpMap);
  }
  if(bounds.length > 1) _cpMap.fitBounds(bounds, {padding:[24,24]});
  else if(bounds.length === 1) _cpMap.setView(bounds[0], 15);
  cpReportMapLayout('after-draw');
  setTimeout(function(){
    if(_cpMap && (gen == null || gen === _cpMapGen)) _cpMap.invalidateSize();
    cpReportMapLayout('after-invalidate-120');
  }, 120);
  setTimeout(function(){
    if(_cpMap && (gen == null || gen === _cpMapGen)) _cpMap.invalidateSize();
    cpReportMapLayout('after-invalidate-600');
  }, 600);
}
function initCpTripMap(d, gen){
  if(gen == null) gen = _cpMapGen;
  cpDestroyTripMap();
  if(gen !== _cpMapGen) return;
  var dbg = document.getElementById('cp-trip-map-debug');
  if(dbg){ dbg.style.display='block'; dbg.textContent=''; }
  cpMapStatus('');
  var el = document.getElementById('cp-trip-map');
  if(!el || typeof L==='undefined') return;
  var plat = Number(d.pickupLat), plng = Number(d.pickupLng);
  var dlat = Number(d.dropLat), dlng = Number(d.dropLng);
  var hasPu = Number.isFinite(plat) && Number.isFinite(plng) && plat !== 0 && plng !== 0;
  var hasDu = Number.isFinite(dlat) && Number.isFinite(dlng) && dlat !== 0 && dlng !== 0;
  var pickup = String(d.pickup || '').trim();
  var dropoff = String(d.dropoff || '').trim();
  var needPuGeo = !hasPu && pickup && pickup !== '—';
  var needDuGeo = !hasDu && dropoff && dropoff !== '—';
  cpMapDbg('initCpTripMap', {gen:gen, mapGen:_cpMapGen, id:d.id||d.jobId||null, hasPu:hasPu, hasDu:hasDu, needPuGeo:needPuGeo, needDuGeo:needDuGeo, pickup:pickup, dropoff:dropoff, tokLen:(typeof _cpToken==='string'?_cpToken.length:0)});
  if(hasPu && hasDu){
    cpDrawTripMap([plat, plng], [dlat, dlng], gen);
    return;
  }
  if(!needPuGeo && !needDuGeo){
    if(hasPu || hasDu){
      cpDrawTripMap(hasPu ? [plat, plng] : null, hasDu ? [dlat, dlng] : null, gen);
      return;
    }
    cpMapStatus('Map unavailable — no pickup/dropoff addresses.');
    return;
  }
  cpMapStatus('Locating addresses on map…');
  Promise.all([
    needPuGeo ? cpGeocodeAddr(pickup) : Promise.resolve(hasPu ? [plat, plng] : null),
    needDuGeo ? cpGeocodeAddr(dropoff) : Promise.resolve(hasDu ? [dlat, dlng] : null)
  ]).then(function(r){
    if(gen !== _cpMapGen) return;
    cpMapDbg('geocode Promise.all done', {pu:r[0], du:r[1], gen:gen, mapGen:_cpMapGen});
    if(!r[0] && !r[1]){
      cpMapStatus('Address not found on map.');
      return;
    }
    cpMapStatus('');
    cpDrawTripMap(r[0], r[1], gen);
  });
}
</script>`;

function cpTripDetailOverlayHtml(): string {
  return `<div class="cp-ov" id="cp-detail-ov" onclick="if(event.target===this)closeCpDetail()">
  <div class="cp-modal" onclick="event.stopPropagation()">
    <div class="cp-modal-hd"><h3 id="cp-detail-title">Trip detail</h3>
      <button type="button" onclick="closeCpDetail()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
    <div class="cp-modal-bd" id="cp-detail-body"></div>
    <div class="cp-modal-ft" id="cp-detail-ft" style="flex-wrap:wrap;justify-content:space-between;align-items:flex-start">
      <div id="cp-detail-actions" style="flex:1;display:flex;flex-wrap:wrap;gap:8px;align-items:flex-start"></div>
      <button type="button" class="cp-btn" style="background:#eee;color:#333" onclick="closeCpDetail()">Close</button>
    </div>
  </div>
</div>`;
}

/** Client detail open/close + action/edit panels. Expects _cpTrips, _cpBodies, _cpToken, _cpReturnTo. */
function cpTripDetailBehaviorScript(includeEditPanel: boolean): string {
  const editFn = includeEditPanel
    ? `function buildEditPanel(d){
  if(d.status==='archived') return '';
  var html = '<details style="margin-top:14px;border:1px solid #FFE082;border-radius:6px;padding:10px 12px;background:#FFFDE7" '+(d.status==='revision_needed'?'open':'')+'>';
  html += '<summary style="cursor:pointer;font-weight:700;color:#E65100">Edit all fields</summary>';
  html += '<form method="POST" action="/api/council-trip-edit" style="margin-top:10px">';
  html += '<input type="hidden" name="_token" value="'+_escAttr(_cpToken)+'"/>';
  html += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
  html += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
  html += '<input type="hidden" name="returnTo" value="'+_escAttr(_cpReturnTo)+'"/>';
  html += '<div class="cp-edit-grid">';
  html += _fld('tmCardName','Passenger / cardholder',d.passengerName);
  html += _fld('tmVoucherNo','Voucher / card no',d.voucherNo);
  html += _fld('pickupAddress','Pickup',d.pickup,true);
  html += _fld('dropAddress','Dropoff',d.dropoff,true);
  html += _fld('fare','Meter fare',d.meterFare);
  html += _fld('waitingCost','Waiting charge',d.waitingCharge);
  html += _fld('tmSubsidyFare','Meter subsidy',d.meterSubsidy);
  html += _fld('tmSubsidyHoist','Hoist (council)',d.hoistCouncil);
  html += _fld('tmSubsidy','Total council',d.totalCouncil);
  html += _fld('tmPassengerPays','Passenger pays',d.passengerPays);
  html += _fld('startedAt_ISO','Start (ISO or epoch ms)',d.startedAtRaw||'');
  html += _fld('completedAt_ISO','End (ISO or epoch ms)',d.completedAtRaw||'');
  html += _fld('paymentMethod','Payment method',d.paymentMethod);
  html += _fld('distanceKm','Distance km',d.distanceKm);
  html += _fld('durationLabel','Duration',d.duration);
  html += _fld('tmTripCategory','Trip category',d.tripCategory);
  html += _fld('driverName','Driver',d.driverName);
  html += _fld('vehicleId','Vehicle / cab',d.vehicleId);
  html += '</div>';
  html += '<label style="display:flex;align-items:center;gap:6px;margin:12px 0 8px;font-size:12.5px"><input type="checkbox" name="resubmit" value="1"/> Mark status as submitted after save</label>';
  html += '<button type="submit" class="cp-btn cp-btn-g">Save trip fields</button>';
  html += '</form></details>';
  return html;
}`
    : `function buildEditPanel(d){ return ''; }`;

  return `<script>
var _ACTIONABLE = {submitted:1,company_approved:1,flagged:1,pending:1};
function _escAttr(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;'); }
function _fld(name,label,val,full){
  return '<div'+(full?' style="grid-column:1/-1"':'')+'><label>'+label+'</label><input class="cp-input" name="'+name+'" value="'+_escAttr(val)+'"/></div>';
}
${editFn}
function buildActionForms(d){
  var h = '<div style="display:flex;flex-wrap:wrap;gap:8px;align-items:flex-start;width:100%">';
  if(d.status==='archived'){
    h += '<form method="POST" action="/api/council-restore" onsubmit="return confirm(&#39;Restore this trip to its previous status?&#39;)">';
    h += '<input type="hidden" name="_token" value="'+_escAttr(_cpToken)+'"/>';
    h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
    h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
    h += '<input type="hidden" name="returnTo" value="'+_escAttr(_cpReturnTo)+'"/>';
    h += '<button type="submit" class="cp-btn cp-btn-g">&#8634; Restore</button></form>';
    h += '</div>';
    return h;
  }
  if(_ACTIONABLE[d.status]){
    h += '<form method="POST" action="/api/council-approve">';
    h += '<input type="hidden" name="_token" value="'+_escAttr(_cpToken)+'"/>';
    h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
    h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
    h += '<input type="hidden" name="action" value="approve"/>';
    h += '<input type="hidden" name="returnTo" value="'+_escAttr(_cpReturnTo)+'"/>';
    h += '<button type="submit" class="cp-btn cp-btn-g">&#10003; Approve</button></form>';
    h += '<form method="POST" action="/api/council-approve" style="display:flex;flex-wrap:wrap;gap:6px;align-items:center;padding:8px;border:1px solid #FFCDD2;border-radius:6px;background:#FFEBEE" onsubmit="return !!this.note.value.trim()||(alert(&#39;Reject note required&#39;),false)">';
    h += '<input type="hidden" name="_token" value="'+_escAttr(_cpToken)+'"/>';
    h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
    h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
    h += '<input type="hidden" name="action" value="reject"/>';
    h += '<input type="hidden" name="returnTo" value="'+_escAttr(_cpReturnTo)+'"/>';
    h += '<select name="flagReason" class="cp-input" style="width:auto">';
    h += '<option value="fare_mismatch">fare_mismatch</option>';
    h += '<option value="waiting_charged">waiting_charged</option>';
    h += '<option value="hoist_rate_mismatch">hoist_rate_mismatch</option>';
    h += '<option value="other">other</option></select>';
    h += '<input name="note" class="cp-input" placeholder="Reject note (required)" style="min-width:160px" required/>';
    h += '<button type="submit" class="cp-btn cp-btn-r">&#10007; Reject / Red-flag</button></form>';
    h += '<form method="POST" action="/api/council-approve" style="display:flex;flex-wrap:wrap;gap:6px;align-items:center;padding:8px;border:1px solid #FFE082;border-radius:6px;background:#FFF8E1" onsubmit="return !!this.note.value.trim()||(alert(&#39;Revision note required&#39;),false)">';
    h += '<input type="hidden" name="_token" value="'+_escAttr(_cpToken)+'"/>';
    h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
    h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
    h += '<input type="hidden" name="action" value="return"/>';
    h += '<input type="hidden" name="returnTo" value="'+_escAttr(_cpReturnTo)+'"/>';
    h += (d.status==='flagged' ? '<div style="flex-basis:100%;font-size:12px;color:#5d4037;margin-bottom:2px"><strong>Return unlocks company editing.</strong> Trip stays view-only for the company until you click Return — so council can review the original flagged data before anything is edited.</div>' : '');
    h += '<input name="note" class="cp-input" placeholder="Revision note (required)" style="min-width:160px" required/>';
    h += '<button type="submit" class="cp-btn" style="background:#E65100;color:#fff">&#8617; Return to company</button></form>';
  }
  h += '<form method="POST" action="/api/council-archive" style="display:flex;flex-wrap:wrap;gap:6px;align-items:center;padding:8px;border:1px solid #E0E0E0;border-radius:6px;background:#FAFAFA" onsubmit="return confirm(&#39;Archive this trip? You can restore it later.&#39;)">';
  h += '<input type="hidden" name="_token" value="'+_escAttr(_cpToken)+'"/>';
  h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
  h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
  h += '<input type="hidden" name="returnTo" value="'+_escAttr(_cpReturnTo)+'"/>';
  h += '<input name="note" class="cp-input" placeholder="Archive note (optional)" style="min-width:160px"/>';
  h += '<button type="submit" class="cp-btn" style="background:#757575;color:#fff">&#128193; Archive</button></form>';
  h += '</div>';
  return h;
}
function openCpDetail(i){
  var d = _cpTrips[i], html = _cpBodies[i];
  if(!d || !html) return;
  // Destroy previous Leaflet instance BEFORE replacing the map container DOM.
  cpDestroyTripMap();
  _cpMapGen++;
  var gen = _cpMapGen;
  document.getElementById('cp-detail-body').innerHTML = html + buildEditPanel(d);
  document.getElementById('cp-detail-title').textContent = 'Trip detail — ' + (d.id || '');
  document.getElementById('cp-detail-actions').innerHTML = buildActionForms(d);
  document.getElementById('cp-detail-ov').classList.add('open');
  initCpTripMap(d, gen);
}
function closeCpDetail(){
  _cpMapGen++;
  cpDestroyTripMap();
  document.getElementById('cp-detail-ov').classList.remove('open');
  var body = document.getElementById('cp-detail-body');
  if(body) body.innerHTML = '';
  var actions = document.getElementById('cp-detail-actions');
  if(actions) actions.innerHTML = '';
}
</script>`;
}

// ── Legacy search → unified Trips ─────────────────────────────────────────────
router.get('/council-portal/search', requirePortalAuth, (req, res) => {
  redirectLegacyTripPage(req, res, 'all');
});

// ── Legacy pending → unified Trips ────────────────────────────────────────────
router.get('/council-portal/pending', requirePortalAuth, (req, res) => {
  redirectLegacyTripPage(req, res, 'pending');
});

// ── Legacy anomalies → unified Trips ──────────────────────────────────────────
router.get('/council-portal/anomalies', requirePortalAuth, (req, res) => {
  redirectLegacyTripPage(req, res, 'flagged');
});

function parseTripKeysFromBody(body: any): Array<{ cid: string; rawKey: string }> {
  const raw = body.tripKeys != null ? body.tripKeys : body.trip;
  const list = Array.isArray(raw) ? raw : raw != null && raw !== '' ? [raw] : [];
  const out: Array<{ cid: string; rawKey: string }> = [];
  list.forEach((v: any) => {
    const s = String(v || '').trim();
    if (!s) return;
    const pipe = s.indexOf('|');
    if (pipe > 0) {
      out.push({ cid: s.slice(0, pipe), rawKey: s.slice(pipe + 1) });
      return;
    }
    const slash = s.indexOf('/');
    if (slash > 0) out.push({ cid: s.slice(0, slash), rawKey: s.slice(slash + 1) });
  });
  return out;
}

// ── Bulk approve clean submitted trips ─────────────────────────────────────────
router.post('/api/council-bulk-approve', (req, res) => {
  const token = (req.body._token as string) || '';
  const returnTo = normalizeCouncilReturnTo(req.body.returnTo, 'pending');
  const allClean = String(req.body.allClean || '') === '1';
  const filters = unifiedFiltersFromBody(req.body);
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(returnTo, te, filters);
  if (!sess) return res.redirect(base + '&msg=Invalid+request&mt=err');
  const selected = parseTripKeysFromBody(req.body);
  const selectedSet = new Set(selected.map((k) => k.cid + '/' + k.rawKey));
  loadCouncilTrips(sess.councilId, (_err: any, myTrips: any[]) => {
    scanAndRefreshTrips(myTrips, (scanned) => {
      const statusFilter = normalizeUnifiedTripStatus(filters.status || returnTo || 'pending');
      let candidates: any[];
      if (allClean) {
        // Respect active Trips filters (search / company / dates), not every pending trip
        candidates = filterTripsUnified(scanned, {
          status: statusFilter === 'all' ? 'pending' : statusFilter,
          q: filters.q,
          companyId: filters.company,
          from: filters.from,
          to: filters.to,
        }).filter((t) => String(t.status || '').toLowerCase() === 'submitted');
      } else {
        candidates = scanned.filter((t) => {
          if (String(t.status || '').toLowerCase() !== 'submitted') return false;
          return selectedSet.has(String(t._cid) + '/' + String(t._rawKey));
        });
      }
      if (candidates.length === 0) {
        return res.redirect(
          base +
            '&msg=' +
            encodeURIComponent(
              allClean
                ? 'No trips match the current filters to approve.'
                : 'No clean submitted trips to approve.',
            ) +
            '&mt=err',
        );
      }
      const now = Date.now();
      const who = sess.name || sess.councilId;
      let left = candidates.length;
      let ok = 0;
      candidates.forEach((t) => {
        fbWrite(
          'PATCH',
          'tmTripStatus/' + t._cid + '/' + t._rawKey,
          { status: 'approved', approvedAt: now, approvedBy: who },
          (err: any) => {
            const finishOne = () => {
              if (--left === 0) {
                res.redirect(
                  base +
                    '&msg=' +
                    encodeURIComponent('Approved ' + ok + ' trip(s).') +
                    '&mt=' +
                    (ok ? 'ok' : 'err'),
                );
              }
            };
            if (err) return finishOne();
            ok++;
            appendTripEvent(
              t._cid,
              t._rawKey,
              buildTripEvent('approved', {
                by: who,
                byRole: 'council',
                fromStatus: t.status || 'submitted',
                toStatus: 'approved',
              }),
              () => {
                afterCouncilApproveAddToBatch(
                  sess.councilId,
                  String(t._cid),
                  String(t._rawKey),
                  who,
                  t,
                  finishOne,
                );
              },
            );
          },
        );
      });
    });
  });
});

// ── Bulk return flagged trips ──────────────────────────────────────────────────
router.post('/api/council-bulk-return', (req, res) => {
  const token = (req.body._token as string) || '';
  const note = String(req.body.note || req.body.revisionNote || '').trim();
  const filters = unifiedFiltersFromBody(req.body);
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(req.body.returnTo || 'flagged', te, filters);
  if (!sess) return res.redirect(base + '&msg=Invalid+request&mt=err');
  if (!note) return res.redirect(base + '&msg=Revision+note+is+required&mt=err');
  const keys = parseTripKeysFromBody(req.body);
  if (keys.length === 0) {
    return res.redirect(base + '&msg=' + encodeURIComponent('Select at least one trip.') + '&mt=err');
  }
  const now = Date.now();
  const who = sess.name || sess.councilId;
  let left = keys.length;
  let ok = 0;
  keys.forEach(({ cid, rawKey }) => {
    fbRead('tmTripStatus/' + cid + '/' + rawKey, (e0: any, st: any) => {
      if (e0 || !st || st.councilId !== sess.councilId) {
        if (--left === 0) {
          res.redirect(
            base + '&msg=' + encodeURIComponent('Returned ' + ok + ' trip(s).') + '&mt=' + (ok ? 'ok' : 'err'),
          );
        }
        return;
      }
      const patch = {
        status: 'revision_needed',
        revisionNote: note,
        sentBackAt: now,
        sentBackBy: who,
        flagReasons: Array.isArray(st.flagReasons) ? st.flagReasons : [],
        anomalyDetail: st.anomalyDetail || null,
      };
      fbWrite('PATCH', 'tmTripStatus/' + cid + '/' + rawKey, patch, (err: any) => {
        const finishOne = () => {
          if (--left === 0) {
            res.redirect(
              base + '&msg=' + encodeURIComponent('Returned ' + ok + ' trip(s).') + '&mt=' + (ok ? 'ok' : 'err'),
            );
          }
        };
        if (err) return finishOne();
        ok++;
        appendTripEvent(
          cid,
          rawKey,
          buildTripEvent('returned', {
            by: who,
            byRole: 'council',
            note,
            fromStatus: st.status || null,
            toStatus: 'revision_needed',
          }),
          finishOne,
        );
      });
    });
  });
});

// ── Soft-archive / restore ─────────────────────────────────────────────────────
router.post('/api/council-archive', (req, res) => {
  const token = (req.body._token as string) || '';
  const tripCid = String(req.body.tripCid || '').trim();
  const tripRawKey = String(req.body.tripRawKey || '').trim();
  const note = String(req.body.note || '').trim();
  const returnTo = normalizeCouncilReturnTo(req.body.returnTo, 'pending');
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(returnTo, te);
  if (!sess || !tripCid || !tripRawKey) {
    return res.redirect(base + '&msg=Invalid+request&mt=err');
  }
  const who = sess.name || sess.councilId;
  fbRead('tmTripStatus/' + tripCid + '/' + tripRawKey, (e0: any, st: any) => {
    if (e0 || !st || st.councilId !== sess.councilId) {
      return res.redirect(base + '&msg=Trip+not+found+for+this+council&mt=err');
    }
    if (isArchivedStatus(st.status)) {
      return res.redirect(base + '&msg=' + encodeURIComponent('Trip is already archived.') + '&mt=err');
    }
    const patch = archivePatch(st.status, who, note || null);
    fbWrite('PATCH', 'tmTripStatus/' + tripCid + '/' + tripRawKey, patch, (err: any) => {
      if (err) return res.redirect(base + '&msg=Archive+failed&mt=err');
      appendTripEvent(
        tripCid,
        tripRawKey,
        buildTripEvent('archived', {
          by: who,
          byRole: 'council',
          fromStatus: String(patch.archivedFromStatus || st.status || ''),
          toStatus: 'archived',
          note: note || null,
        }),
        () => {
          res.redirect(base + '&msg=' + encodeURIComponent('Trip archived.') + '&mt=ok');
        },
      );
    });
  });
});

router.post('/api/council-bulk-archive', (req, res) => {
  const token = (req.body._token as string) || '';
  const note = String(req.body.note || '').trim();
  const returnTo = normalizeCouncilReturnTo(req.body.returnTo, 'pending');
  const allMatching = String(req.body.allMatching || '') === '1';
  const filters = unifiedFiltersFromBody(req.body);
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(returnTo, te, filters);
  if (!sess) return res.redirect(base + '&msg=Invalid+request&mt=err');
  const selected = parseTripKeysFromBody(req.body);
  const selectedSet = new Set(selected.map((k) => k.cid + '/' + k.rawKey));
  const who = sess.name || sess.councilId;

  const finishArchive = (candidates: any[]) => {
    const toArchive = candidates.filter((t) => !isArchivedStatus(t.status));
    if (toArchive.length === 0) {
      return res.redirect(base + '&msg=' + encodeURIComponent('No trips to archive.') + '&mt=err');
    }
    let left = toArchive.length;
    let ok = 0;
    toArchive.forEach((t) => {
      const patch = archivePatch(t.status, who, note || null);
      fbWrite('PATCH', 'tmTripStatus/' + t._cid + '/' + t._rawKey, patch, (err: any) => {
        const finishOne = () => {
          if (--left === 0) {
            res.redirect(
              base +
                '&msg=' +
                encodeURIComponent('Archived ' + ok + ' trip(s).') +
                '&mt=' +
                (ok ? 'ok' : 'err'),
            );
          }
        };
        if (err) return finishOne();
        ok++;
        appendTripEvent(
          t._cid,
          t._rawKey,
          buildTripEvent('archived', {
            by: who,
            byRole: 'council',
            fromStatus: String(patch.archivedFromStatus || t.status || ''),
            toStatus: 'archived',
            note: note || null,
          }),
          finishOne,
        );
      });
    });
  };

  loadCouncilTrips(sess.councilId, (_err: any, myTrips: any[]) => {
    const runWithScan = (scanned: any[]) => {
      if (allMatching) {
        const statusFilter = normalizeUnifiedTripStatus(filters.status || returnTo || 'pending');
        const matching = filterTripsUnified(scanned, {
          status: statusFilter,
          q: filters.q,
          companyId: filters.company,
          from: filters.from,
          to: filters.to,
        });
        return finishArchive(matching);
      }
      if (selected.length === 0) {
        return res.redirect(base + '&msg=' + encodeURIComponent('Select at least one trip.') + '&mt=err');
      }
      const candidates = scanned.filter((t) =>
        selectedSet.has(String(t._cid) + '/' + String(t._rawKey)),
      );
      finishArchive(candidates);
    };
    // Pending/flagged queues may need a fresh anomaly scan before acting
    if (returnTo === 'pending' || returnTo === 'anomalies' || returnTo === 'flagged') {
      scanAndRefreshTrips(myTrips, runWithScan);
      return;
    }
    runWithScan(myTrips);
  });
});

router.post('/api/council-restore', (req, res) => {
  const token = (req.body._token as string) || '';
  const tripCid = String(req.body.tripCid || '').trim();
  const tripRawKey = String(req.body.tripRawKey || '').trim();
  const returnTo = normalizeCouncilReturnTo(req.body.returnTo, 'archived');
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(returnTo, te);
  if (!sess || !tripCid || !tripRawKey) {
    return res.redirect(base + '&msg=Invalid+request&mt=err');
  }
  fbRead('tmTripStatus/' + tripCid + '/' + tripRawKey, (e0: any, st: any) => {
    if (e0 || !st || st.councilId !== sess.councilId) {
      return res.redirect(base + '&msg=Trip+not+found+for+this+council&mt=err');
    }
    if (!isArchivedStatus(st.status)) {
      return res.redirect(base + '&msg=' + encodeURIComponent('Trip is not archived.') + '&mt=err');
    }
    const patch = restorePatch(st);
    const who = sess.name || sess.councilId;
    fbWrite('PATCH', 'tmTripStatus/' + tripCid + '/' + tripRawKey, patch, (err: any) => {
      if (err) return res.redirect(base + '&msg=Restore+failed&mt=err');
      appendTripEvent(
        tripCid,
        tripRawKey,
        buildTripEvent('restored', {
          by: who,
          byRole: 'council',
          fromStatus: 'archived',
          toStatus: String(patch.status || ''),
        }),
        () => {
          res.redirect(base + '&msg=' + encodeURIComponent('Trip restored.') + '&mt=ok');
        },
      );
    });
  });
});

router.post('/api/council-bulk-restore', (req, res) => {
  const token = (req.body._token as string) || '';
  const returnTo = normalizeCouncilReturnTo(req.body.returnTo, 'archived');
  const allMatching = String(req.body.allMatching || '') === '1';
  const filters = unifiedFiltersFromBody(req.body);
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const base = councilReturnPath(returnTo, te, filters);
  if (!sess) return res.redirect(base + '&msg=Invalid+request&mt=err');
  const selected = parseTripKeysFromBody(req.body);
  const selectedSet = new Set(selected.map((k) => k.cid + '/' + k.rawKey));
  loadCouncilTrips(sess.councilId, (_err: any, myTrips: any[]) => {
    let candidates: any[];
    if (allMatching) {
      candidates = filterTripsUnified(myTrips, {
        status: 'archived',
        q: filters.q,
        companyId: filters.company,
        from: filters.from,
        to: filters.to,
      });
    } else {
      candidates = myTrips.filter(
        (t) =>
          isArchivedStatus(t.status) &&
          selectedSet.has(String(t._cid) + '/' + String(t._rawKey)),
      );
    }
    if (!allMatching && selected.length === 0) {
      return res.redirect(base + '&msg=' + encodeURIComponent('Select at least one trip.') + '&mt=err');
    }
    if (candidates.length === 0) {
      return res.redirect(
        base +
          '&msg=' +
          encodeURIComponent(
            allMatching
              ? 'No archived trips match the current filters.'
              : 'No archived trips to restore.',
          ) +
          '&mt=err',
      );
    }
    const who = sess.name || sess.councilId;
    let left = candidates.length;
    let ok = 0;
    candidates.forEach((t) => {
      const patch = restorePatch(t);
      fbWrite('PATCH', 'tmTripStatus/' + t._cid + '/' + t._rawKey, patch, (err: any) => {
        const finishOne = () => {
          if (--left === 0) {
            res.redirect(
              base +
                '&msg=' +
                encodeURIComponent('Restored ' + ok + ' trip(s).') +
                '&mt=' +
                (ok ? 'ok' : 'err'),
            );
          }
        };
        if (err) return finishOne();
        ok++;
        appendTripEvent(
          t._cid,
          t._rawKey,
          buildTripEvent('restored', {
            by: who,
            byRole: 'council',
            fromStatus: 'archived',
            toStatus: String(patch.status || ''),
          }),
          finishOne,
        );
      });
    });
  });
});

// ── Legacy archived → unified Trips ───────────────────────────────────────────
router.get('/council-portal/archived', requirePortalAuth, (req, res) => {
  redirectLegacyTripPage(req, res, 'archived');
});

// ── Scan one trip after SA/owner submit (same-origin; no portal session) ───────
router.post('/api/tm-scan-submitted', (req, res) => {
  const cid = String(req.body.cid || req.body.tripCid || '').trim();
  const rawKey = String(req.body.rawKey || req.body.tripRawKey || '').trim();
  const councilId = String(req.body.councilId || '').trim();
  if (!cid || !rawKey) {
    return res.status(400).json({ ok: false, error: 'cid and rawKey required' });
  }
  fbRead('tmTripStatus/' + cid + '/' + rawKey, (e0: any, st: any) => {
    if (e0 || !st) return res.status(404).json({ ok: false, error: 'status not found' });
    const cId = councilId || String(st.councilId || '');
    if (!cId) return res.status(400).json({ ok: false, error: 'councilId required' });
    loadCouncilTrips(cId, (_err: any, trips: any[]) => {
      scanAndRefreshTrips(trips, (scanned) => {
        const row = scanned.find(
          (t) => String(t._cid) === cid && String(t._rawKey) === rawKey,
        );
        res.json({
          ok: true,
          status: row ? row.status : st.status,
          flagReasons: row ? row.flagReasons || [] : st.flagReasons || [],
        });
      });
    });
  });
});

// ── Reports ────────────────────────────────────────────────────────────────────
function tripStartedMs(t: any): number {
  return tripActivityMs(t);
}

function filterTripsForReports(
  trips: any[],
  opts: { companyId?: string; from?: string; to?: string; includeArchived?: boolean },
): any[] {
  let rows = trips.slice();
  if (!opts.includeArchived) {
    rows = rows.filter((t) => !isArchivedStatus(t.status));
  }
  if (opts.companyId) rows = rows.filter((t) => String(t._cid) === opts.companyId);
  if (opts.from) {
    const fromMs = Date.parse(opts.from + 'T00:00:00');
    if (Number.isFinite(fromMs)) rows = rows.filter((t) => tripStartedMs(t) >= fromMs);
  }
  if (opts.to) {
    const toMs = Date.parse(opts.to + 'T23:59:59');
    if (Number.isFinite(toMs)) rows = rows.filter((t) => tripStartedMs(t) <= toMs);
  }
  rows.sort(compareTripsNewestFirst);
  return rows;
}

/** Static trip detail body (map placeholder + fare/expected meter). Client adds Leaflet + actions. */
function tripDetailModalHtml(d: TmTripDetail, stOrTrip?: any): string {
  const money = (n: number) => '$' + n.toFixed(2);
  const row = (l: string, v: string) =>
    `<div><div style="font-size:11px;color:#888;font-weight:600;margin-bottom:2px">${l}</div><div style="font-size:13px;font-weight:500">${v}</div></div>`;
  const frow = (l: string, v: string, c = '#333') =>
    `<tr><td style="padding:3px 0;color:${c}">${l}</td><td style="text-align:right;color:${c}">${v}</td></tr>`;
  const expectedBlock =
    d.expectedMeter != null
      ? `<div style="margin:10px 0 0;padding:10px 12px;border-radius:6px;background:${d.fareMismatch ? '#FFEBEE' : '#E8F5E9'};font-size:13px">
  <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;justify-content:space-between">
    <span>Expected meter (ref list): <strong>$${d.expectedMeter.toFixed(2)}</strong>
      &nbsp;·&nbsp; Actual: <strong>$${d.meterFare.toFixed(2)}</strong></span>
    ${d.fareMismatch ? '<span class="cp-bdg-mismatch">Fare mismatch</span>' : '<span class="cp-bdg-g">Within tolerance</span>'}
  </div>
</div>`
      : '';
  const revisionBlock = d.revisionNote
    ? `<div style="margin:12px 0 0;padding:10px 12px;border-radius:6px;background:#FFF8E1;border-left:4px solid #E65100;font-size:13px">
  <strong>Revision note</strong>
  <div style="margin-top:4px;color:#5d4037">${esc(d.revisionNote)}</div>
</div>`
    : '';
  return `
<div data-cid="${esc(d.cid)}" data-rawkey="${esc(d.rawKey)}" data-status="${esc(d.status)}">
<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px 18px;margin-bottom:14px">
  ${row('Job / Booking', esc(d.id))}
  ${row('Status', statusBadge(d.status))}
  ${row('Operator', esc(d.companyName))}
  ${row('Driver', esc(d.driverName))}
  ${row('Vehicle / Cab', esc(d.vehicleId))}
  ${row('Trip Category', esc(d.tripCategory))}
  ${row('Passenger (cardholder)', esc(d.passengerName))}
  ${row('Voucher / Cards', esc(d.allCards))}
  ${row('Pickup', esc(d.pickup))}
  ${row('Dropoff', esc(d.dropoff))}
  ${row('Start', esc(d.dateTime))}
  ${row('End', esc(d.endTime))}
  ${row('Distance', esc(d.distanceKm ? d.distanceKm + ' km' : '—'))}
  ${row('Duration', esc(d.duration))}
  ${row('Payment Method', esc(d.paymentMethod))}
  ${row('Passengers (TM)', String(d.passengerCount))}
</div>
${revisionBlock}
<div id="cp-trip-map-wrap">
  <div id="cp-trip-map-status" style="display:none"></div>
  <div id="cp-trip-map"></div>
  <pre id="cp-trip-map-debug"></pre>
</div>
${expectedBlock}
<div style="background:#F1F8E9;border-radius:6px;padding:14px;font-size:13px;margin-top:12px">
<strong>Fare Breakdown</strong>
<table style="width:100%;margin-top:8px">
${frow('Meter Fare (trip only)', money(d.meterFare))}
${d.expectedMeter != null ? frow('Expected meter (ref list)', money(d.expectedMeter), d.fareMismatch ? '#C62828' : '#2E7D32') : ''}
${d.waitingCharge > 0 ? frow('Waiting Charge (passenger pays, not TM)', money(d.waitingCharge), '#9e9e9e') : ''}
<tr><td colspan="2" style="padding:4px 0;border-top:1px dashed #ccc"></td></tr>
${d.splitNote ? frow(esc(d.splitNote), '', '#1565C0') : ''}
${frow('Line 1 — Meter subsidy', '<span style="color:#2E7D32;font-weight:600">' + money(d.meterSubsidy) + '</span>')}
${frow('Line 2 — Hoist (100% council)', '<span style="color:#2E7D32;font-weight:600">' + money(d.hoistCouncil) + '</span>')}
${d.hoistLines ? frow('&nbsp;&nbsp;' + esc(d.hoistLines), '', '#555') : ''}
<tr style="border-top:2px solid #ccc"><td style="padding:6px 0"><strong>Total Council Pays</strong></td>
<td style="text-align:right"><strong style="color:#2E7D32;font-size:15px">${money(d.totalCouncil)}</strong></td></tr>
${frow('Passenger Share (meter − subsidy)', money(d.passengerShare))}
${d.waitingCharge > 0 ? frow('+ Waiting Charge', money(d.waitingCharge)) : ''}
<tr style="border-top:2px solid #1B5E20"><td style="padding:6px 0"><strong>Passenger Total Pays</strong></td>
<td style="text-align:right"><strong style="font-size:15px">${money(d.passengerPays)}</strong>
 <span class="cp-bdg-b">${esc(d.paymentMethod)}</span></td></tr>
</table></div>
${stOrTrip ? tripHistoryHtml(stOrTrip) : ''}
</div>`;
}

router.get('/council-portal/reports', requirePortalAuth, (req, res) => {
  redirectLegacyTripPage(req, res, 'all');
});

// ── Claim Batches ──────────────────────────────────────────────────────────────
function cascadeBatchTripsToPaid(
  batch: any,
  companyCid: string,
  ym: string,
  who: string,
  done: () => void,
): void {
  const keys = resolveBatchTripKeys(batch, companyCid);
  if (!keys.length) return done();
  let left = keys.length;
  const now = Date.now();
  const patch = buildTripPaidPatch(who, now);
  keys.forEach(({ cid, rawKey }) => {
    fbWrite('PATCH', 'tmTripStatus/' + cid + '/' + rawKey, patch, () => {
      appendTripEvent(
        cid,
        rawKey,
        buildTripEvent('paid', {
          by: who,
          byRole: 'council',
          note: 'Claim batch ' + ym + ' marked paid',
          toStatus: 'paid',
        }),
        () => {
          if (--left <= 0) done();
        },
      );
    });
  });
}

router.get('/council-portal/batches', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const te = encodeURIComponent(token);
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const tab = normalizeClaimBatchStatusFilter(String(req.query.tab || 'submitted'));
  const filterFrom = String(req.query.from || '').trim();
  const filterTo = String(req.query.to || '').trim();
  const qKeep =
    (filterFrom ? '&from=' + encodeURIComponent(filterFrom) : '') +
    (filterTo ? '&to=' + encodeURIComponent(filterTo) : '');
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(msg)}</div>` : '';
  loadCouncilTrips(sess.councilId, (_eT: any, councilTrips: any[]) => {
    const tripByKey: Record<string, any> = {};
    let flaggedExcluded = 0;
    (councilTrips || []).forEach((t) => {
      tripByKey[String(t._cid) + '/' + String(t._rawKey)] = t;
      if (t.batchId) tripByKey['batch:' + String(t.batchId) + ':' + String(t._rawKey)] = t;
      if (String(t.status || '').toLowerCase() === 'flagged') flaggedExcluded++;
    });
    const claimNotice =
      `<p style="font-size:12.5px;color:#666;margin:-4px 0 14px;padding:10px 12px;background:#FFF8E1;border-left:4px solid #E65100;border-radius:4px">` +
      `Approving a trip automatically adds it to that month&rsquo;s claim batch. ` +
      `Trips with status flagged, revision_needed, rejected, or archived are excluded from claims. Only approved trips are claimable.` +
      (flaggedExcluded > 0
        ? `<div style="margin-top:6px">${flaggedExcluded} trip${flaggedExcluded === 1 ? '' : 's'} excluded this period — ` +
          `<a href="/council-portal/trips?t=${te}&status=flagged" style="color:#E65100;font-weight:600">View Flagged Trips</a></div>`
        : '') +
      `</p>`;
    fbRead('tmBatches/' + sess.councilId, (err: any, batchData: any) => {
      const data = !err && batchData && typeof batchData === 'object' ? batchData : {};
      const cidKeys = Object.keys(data);
      const nameCids = Array.from(
        new Set([
          ...cidKeys,
          ...(councilTrips || []).map((t: any) => String(t._cid || '')).filter(Boolean),
        ]),
      );
      let pending2 = Math.max(nameCids.length, 1);
      const namesMap: Record<string, string> = {};
      const kickBuild = () => {
        if (--pending2 === 0) buildBatchPage();
      };
      if (nameCids.length === 0) {
        pending2 = 1;
        kickBuild();
      } else {
        nameCids.forEach((cid) => {
          fbRead('superClients/' + cid, (_e2: any, sc: any) => {
            namesMap[cid] = sc && sc.name ? sc.name : 'Operator ' + cid;
            kickBuild();
          });
        });
      }
      function resolveBatchTripIds(b: any, cid: string): any[] {
        const rawList = Array.isArray(b.trips) ? b.trips : Array.isArray(b.tripIds) ? b.tripIds : [];
        if (!rawList.length) return [];
        return rawList.map((item: any) => {
          if (item && typeof item === 'object') {
            const rawKey = String(item.rawKey || item._rawKey || item.id || item.bookingId || '');
            const tCid = String(item.cid || item._cid || cid);
            return tripByKey[tCid + '/' + rawKey] || item;
          }
          const s = String(item || '');
          if (s.indexOf('/') > 0) return tripByKey[s] || { _rawKey: s, status: '' };
          return tripByKey[cid + '/' + s] || { _cid: cid, _rawKey: s, status: '' };
        });
      }
      function displayBatchTotals(b: any, cid: string): { totalTrips: number; totalSubsidy: number } {
        return computeDisplayBatchTotals(b, resolveBatchTripIds(b, cid));
      }
      function buildBatchPage() {
        const allBatches: any[] = [];
        cidKeys.forEach((cid) => {
          const months = data[cid] || {};
          Object.entries(months).forEach(([ym, b]: [string, any]) => {
            if (!b) return;
            const totals = displayBatchTotals(b, cid);
            const batchTrips = resolveBatchTripIds(b, cid);
            const hoistDays = aggregateHoistByDay(batchTrips);
            const displayHoist = +hoistDays.reduce((s, r) => s + r.hoistPays, 0).toFixed(2);
            const displayHoistUses = hoistDays.reduce((s, r) => s + r.uses, 0);
            allBatches.push({
              _cid: cid,
              _cname: namesMap[cid] || 'Operator ' + cid,
              _ym: ym,
              ...b,
              _displayTrips: totals.totalTrips,
              _displaySubsidy: totals.totalSubsidy,
              _displayHoist: displayHoist,
              _displayHoistUses: displayHoistUses,
              _hoistDays: hoistDays,
            });
          });
        });
        allBatches.sort((a, b) => (b._ym + b._cid).localeCompare(a._ym + a._cid));
        const batchStatusBadge = (s: string) => {
          const m: Record<string, string> = {
            draft: '<span style="background:#F5F5F5;color:#757575;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Draft</span>',
            submitted: '<span style="background:#E3F2FD;color:#1565C0;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Submitted</span>',
            approved: '<span style="background:#E8F5E9;color:#2E7D32;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Approved</span>',
            rejected: '<span style="background:#FFEBEE;color:#C62828;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Rejected</span>',
            revision_needed: '<span style="background:#FFF8E1;color:#E65100;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Needs Revision</span>',
            paid: '<span style="background:#E0F2F1;color:#00695C;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;border:1px solid #80CBC4">&#10003; Paid</span>',
          };
          return m[s] || `<span style="background:#F5F5F5;color:#757575;padding:2px 8px;border-radius:10px;font-size:11px">${esc(s)}</span>`;
        };
        const inDate = filterClaimBatches(allBatches, {
          status: 'all',
          from: filterFrom,
          to: filterTo,
        });
        const submitted = inDate.filter((b) => b.status === 'submitted');
        const approved = inDate.filter((b) => b.status === 'approved');
        const paid = inDate.filter((b) => b.status === 'paid');
        const flagged = inDate.filter((b) => isFlaggedClaimBatch(b));
        const filtered = filterClaimBatches(allBatches, {
          status: tab,
          from: filterFrom,
          to: filterTo,
        });
        const totalPending = submitted.reduce((s, b) => s + Number(b._displaySubsidy || 0), 0);
        const totalApproved = approved.reduce((s, b) => s + Number(b._displaySubsidy || 0), 0);
        const totalPaid = paid.reduce((s, b) => s + Number(b._displaySubsidy || b.paidAmount || 0), 0);
        const paidMissingProof = paid.filter((b) => proofMissingFlag(b)).length;
        const tabHref = (t: string) => `/council-portal/batches?t=${te}&tab=${t}${qKeep}`;
        const tabsHtml = `<div class="cp-tabs">
  <a class="cp-tab${tab === 'submitted' ? ' on' : ''}" href="${tabHref('submitted')}">Submitted<span class="cp-tab-n">${submitted.length}</span></a>
  <a class="cp-tab${tab === 'approved' ? ' on' : ''}" href="${tabHref('approved')}">Approved (unpaid)<span class="cp-tab-n">${approved.length}</span></a>
  <a class="cp-tab${tab === 'paid' ? ' on' : ''}" href="${tabHref('paid')}">Paid<span class="cp-tab-n">${paid.length}</span></a>
  <a class="cp-tab${tab === 'flagged' ? ' on' : ''}" href="${tabHref('flagged')}">Flagged<span class="cp-tab-n">${flagged.length}</span></a>
  <a class="cp-tab${tab === 'all' ? ' on' : ''}" href="${tabHref('all')}">All<span class="cp-tab-n">${inDate.length}</span></a>
</div>`;
        const statusOpts = [
          ['submitted', 'Submitted'],
          ['approved', 'Approved (unpaid)'],
          ['paid', 'Paid'],
          ['flagged', 'Flagged'],
          ['all', 'All'],
        ]
          .map(
            ([v, label]) =>
              `<option value="${v}"${tab === v ? ' selected' : ''}>${label}</option>`,
          )
          .join('');
        const filterBar = `<form method="GET" action="/council-portal/batches" class="cp-card" style="margin-bottom:14px;padding:12px 14px;display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end">
  <input type="hidden" name="t" value="${esc(token)}"/>
  <div>
    <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">Status</label>
    <select name="tab" class="cp-input" style="min-width:170px">${statusOpts}</select>
  </div>
  <div>
    <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">From</label>
    <input type="date" name="from" class="cp-input" value="${esc(filterFrom)}"/>
  </div>
  <div>
    <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">To</label>
    <input type="date" name="to" class="cp-input" value="${esc(filterTo)}"/>
  </div>
  <button type="submit" class="cp-btn cp-btn-g">Apply</button>
  ${
    tab !== 'submitted' || filterFrom || filterTo
      ? `<a href="/council-portal/batches?t=${te}" class="cp-btn" style="background:#eee;color:#333">Clear</a>`
      : ''
  }
  <p style="flex-basis:100%;font-size:11.5px;color:#888;margin:0">From/To filter by claim month (YYYY-MM). Flagged = rejected, needs revision, or paid without proof.</p>
</form>`;
        const rows = filtered
          .map((b) => {
            const subDt = b.submittedAt ? new Date(b.submittedAt).toLocaleDateString('en-NZ') : '—';
            const appDt = b.approvedAt ? new Date(b.approvedAt).toLocaleDateString('en-NZ') : '—';
            const paidDt = b.paidAt ? new Date(b.paidAt).toLocaleDateString('en-NZ') : '—';
            const proofCell = (() => {
              if (b.status !== 'paid') return '—';
              if (hasPaymentProof(b)) {
                const href =
                  String(b.paymentDocUrl || '').indexOf('rtdb:') === 0
                    ? `/api/council-batch-doc?t=${te}&cid=${encodeURIComponent(b._cid)}&ym=${encodeURIComponent(b._ym)}`
                    : esc(String(b.paymentDocUrl));
                return `<a class="cp-proof-ok" href="${href}" target="_blank" rel="noopener">&#128196; ${esc(b.paymentDocName || 'Download proof')}</a>`;
              }
              return `<span class="cp-proof-miss">${PROOF_MISSING_LABEL}</span>
<button type="button" class="cp-btn-sm" style="margin-left:6px;background:#E65100" onclick="cpAttachProof('${esc(b._cid)}','${esc(b._ym)}')">Upload</button>`;
            })();
            const actionBtns =
              b.status === 'submitted'
                ? `
<form method="POST" action="/api/council-batch-action" style="display:inline">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="cid" value="${esc(b._cid)}"/>
  <input type="hidden" name="ym" value="${esc(b._ym)}"/>
  <input type="hidden" name="action" value="approve"/>
  <input type="hidden" name="tab" value="${esc(tab)}"/>
  <input type="hidden" name="from" value="${esc(filterFrom)}"/>
  <input type="hidden" name="to" value="${esc(filterTo)}"/>
  <button type="submit" class="cp-btn cp-btn-g" style="margin-right:4px">&#10003; Approve All</button>
</form>
<form method="POST" action="/api/council-batch-action" style="display:inline" onsubmit="return confirm('Reject this batch?')">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="cid" value="${esc(b._cid)}"/>
  <input type="hidden" name="ym" value="${esc(b._ym)}"/>
  <input type="hidden" name="action" value="reject"/>
  <input type="hidden" name="tab" value="${esc(tab)}"/>
  <input type="hidden" name="from" value="${esc(filterFrom)}"/>
  <input type="hidden" name="to" value="${esc(filterTo)}"/>
  <button type="submit" class="cp-btn cp-btn-r">&#10007; Reject</button>
</form>`
                : b.status === 'approved'
                  ? `
<button type="button" class="cp-btn cp-btn-g" onclick="cpOpenMarkPaid('${esc(b._cid)}','${esc(b._ym)}',${Number(b._displaySubsidy || 0)})">&#128181; Mark Paid</button>`
                  : b.status === 'paid'
                    ? `<span style="font-size:12px;color:#555">${esc(b.payRef || b.paidRef || '')}${b.payRef || b.paidRef ? '<br>' : ''}<span style="color:#888;font-size:11px">Paid ${paidDt}</span></span>`
                    : '—';
            const hoistDays: Array<{ day: string; tripsWithHoist: number; uses: number; hoistPays: number }> =
              Array.isArray(b._hoistDays) ? b._hoistDays : [];
            const hoistTotal = Number(b._displayHoist || 0);
            const hoistUses = Number(b._displayHoistUses || 0);
            const hoistDayRows = hoistDays.length
              ? hoistDays
                  .map(
                    (r) =>
                      `<tr><td>${esc(r.day)}</td><td style="text-align:right">${r.tripsWithHoist}</td><td style="text-align:right">${r.uses}</td><td style="text-align:right">$${Number(r.hoistPays || 0).toFixed(2)}</td></tr>`,
                  )
                  .join('')
              : `<tr><td colspan="4" style="color:#aaa;font-style:italic">No hoist usage in this batch</td></tr>`;
            return `<tr>
<td style="font-weight:600">${esc(b._cname)}</td>
<td style="font-family:monospace">${esc(b._ym)}</td>
<td style="text-align:right">${b._displayTrips}</td>
<td style="text-align:right;font-weight:700;color:#2E7D32">$${Number(b._displaySubsidy || 0).toFixed(2)}</td>
<td style="text-align:right;font-size:12.5px">$${hoistTotal.toFixed(2)}</td>
<td>${batchStatusBadge(b.status)}</td>
<td style="font-size:12px;color:#666">${subDt}</td>
<td style="font-size:12px;color:#666">${appDt}</td>
<td style="font-size:12px">${proofCell}</td>
<td style="white-space:nowrap">${actionBtns}</td>
</tr>
<tr>
<td colspan="10" style="padding:6px 12px 12px;background:#FAFAFA">
<details>
<summary style="cursor:pointer;font-size:12.5px;font-weight:600;color:#33691E">Hoist by day — $${hoistTotal.toFixed(2)} · ${hoistUses} uses</summary>
<table class="cp-tbl" style="margin-top:8px;max-width:520px">
<thead><tr><th>Date</th><th style="text-align:right">Trips w/ hoist</th><th style="text-align:right">Uses</th><th style="text-align:right">Hoist $</th></tr></thead>
<tbody>${hoistDayRows}</tbody>
</table>
</details>
</td>
</tr>`;
          })
          .join('');
        const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:16px">Claim Batches</h2>
${noticeHtml}
${claimNotice}
${(() => {
  const defaultYm = new Date().toISOString().slice(0, 7);
  const companyOpts = companyFilterOptionsHtml(councilTrips || [], '');
  const approvedCount = (councilTrips || []).filter((t: any) => isClaimEligibleStatus(t.status)).length;
  return `<div class="cp-card" style="margin-bottom:16px;border:1px dashed #A5D6A7">
  <div class="cp-card-bd">
    <div style="font-size:13px;font-weight:700;color:#1B5E20;margin-bottom:6px">Rebuild / submit batch <span style="font-weight:500;color:#888;font-size:11.5px">(repair)</span></div>
    <p style="font-size:12.5px;color:#666;margin:0 0 10px">Approving a trip automatically adds it to that month&rsquo;s Submitted batch. Use this only to rebuild or refresh open batches from all <strong>approved</strong> trips (${approvedCount} claim-eligible trip${approvedCount === 1 ? '' : 's'} loaded).</p>
    <form method="POST" action="/api/council-batch-create" style="display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end">
      <input type="hidden" name="_token" value="${esc(token)}"/>
      <input type="hidden" name="tab" value="${esc(tab)}"/>
      <input type="hidden" name="from" value="${esc(filterFrom)}"/>
      <input type="hidden" name="to" value="${esc(filterTo)}"/>
      <div>
        <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">Operator</label>
        <select name="cid" class="cp-input" style="min-width:180px">
          <option value="">All operators with approved trips</option>
          ${companyOpts}
        </select>
      </div>
      <div>
        <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">Month (YYYY-MM)</label>
        <input name="ym" class="cp-input" value="${esc(defaultYm)}" placeholder="${esc(defaultYm)}" pattern="\\d{4}-\\d{2}" style="width:120px"/>
      </div>
      <button type="submit" class="cp-btn cp-btn-g">Rebuild / submit batch</button>
    </form>
  </div>
</div>`;
})()}
<div class="cp-stats" style="margin-bottom:18px">
  <div class="cp-stat"><div class="cp-stat-v">${submitted.length}</div><div class="cp-stat-l">Awaiting Approval</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totalPending.toFixed(2)}</div><div class="cp-stat-l">Pending Claim Value</div></div>
  <div class="cp-stat"><div class="cp-stat-v">${approved.length}</div><div class="cp-stat-l">Approved (unpaid)</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totalApproved.toFixed(2)}</div><div class="cp-stat-l">Approved Claim Value</div></div>
  <div class="cp-stat"><div class="cp-stat-v">${paid.length}</div><div class="cp-stat-l">Paid</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totalPaid.toFixed(2)}</div><div class="cp-stat-l">Paid Claim Value${paidMissingProof ? ` · <span style="color:#E65100;font-size:11px">${paidMissingProof} missing proof</span>` : ''}</div></div>
</div>
${filterBar}
${tabsHtml}
<div class="cp-card" style="overflow-x:auto">
<p style="font-size:13px;color:#666;padding:12px 16px 0">Flow: <strong>Submitted → Approved → Paid</strong>. Marking Paid cascades all trips in the batch to Paid. Proof of payment / invoice is optional but flagged if missing.</p>
${filtered.length ? `<table class="cp-tbl" style="margin-top:8px">
<thead><tr><th>Operator</th><th>Month</th><th style="text-align:right">Trips</th><th style="text-align:right">Council Claim</th><th style="text-align:right">Hoist</th><th>Status</th><th>Submitted</th><th>Approved</th><th>Proof</th><th>Action</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="cp-empty">No batches match these filters.</div>'}
</div>
<div class="cp-ov" id="cp-paid-ov" onclick="if(event.target===this)cpCloseMarkPaid()">
  <div class="cp-modal" style="width:480px" onclick="event.stopPropagation()">
    <div class="cp-modal-hd"><h3 id="cp-paid-title">Mark batch paid</h3>
      <button type="button" onclick="cpCloseMarkPaid()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
    <div class="cp-modal-bd">
      <p id="cp-paid-sub" style="font-size:13px;color:#666;margin-bottom:12px"></p>
      <label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Payment ref (optional)</label>
      <input id="cp-paid-ref" class="cp-input" style="width:100%;margin-bottom:10px" placeholder="Bank transfer / EFT ref"/>
      <label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Proof of payment / invoice (optional)</label>
      <input id="cp-paid-file" type="file" accept=".pdf,.png,.jpg,.jpeg,application/pdf,image/*" style="width:100%;margin-bottom:6px"/>
      <p style="font-size:11.5px;color:#888;margin-bottom:10px">PDF or image, max ~4.5 MB. If skipped, the batch is flagged &ldquo;${PROOF_MISSING_LABEL}&rdquo;.</p>
      <div id="cp-paid-err" style="display:none;color:#C62828;font-size:12.5px;margin-bottom:8px"></div>
    </div>
    <div class="cp-modal-ft">
      <button type="button" class="cp-btn" style="background:#eee;color:#333" onclick="cpCloseMarkPaid()">Cancel</button>
      <button type="button" class="cp-btn cp-btn-g" id="cp-paid-go" onclick="cpSubmitMarkPaid()">&#128181; Confirm Paid</button>
    </div>
  </div>
</div>
<script>
var _cpTok = ${JSON.stringify(token)};
var _cpTab = ${JSON.stringify(tab)};
var _cpFrom = ${JSON.stringify(filterFrom)};
var _cpTo = ${JSON.stringify(filterTo)};
var _paidCtx = null;
function cpOpenMarkPaid(cid, ym, amt){
  _paidCtx = { cid: cid, ym: ym, attachOnly: false };
  document.getElementById('cp-paid-title').textContent = 'Mark batch paid';
  document.getElementById('cp-paid-sub').textContent = 'Company '+cid+' · '+ym+(amt!=null?' · $'+Number(amt).toFixed(2):'');
  document.getElementById('cp-paid-ref').value = '';
  document.getElementById('cp-paid-file').value = '';
  document.getElementById('cp-paid-err').style.display = 'none';
  document.getElementById('cp-paid-go').textContent = 'Confirm Paid';
  document.getElementById('cp-paid-ov').classList.add('open');
}
function cpAttachProof(cid, ym){
  _paidCtx = { cid: cid, ym: ym, attachOnly: true };
  document.getElementById('cp-paid-title').textContent = 'Upload proof of payment';
  document.getElementById('cp-paid-sub').textContent = 'Company '+cid+' · '+ym;
  document.getElementById('cp-paid-ref').value = '';
  document.getElementById('cp-paid-file').value = '';
  document.getElementById('cp-paid-err').style.display = 'none';
  document.getElementById('cp-paid-go').textContent = 'Upload proof';
  document.getElementById('cp-paid-ov').classList.add('open');
}
function cpCloseMarkPaid(){ document.getElementById('cp-paid-ov').classList.remove('open'); _paidCtx=null; }
function cpReadFileAsDataUrl(file){
  return new Promise(function(resolve, reject){
    if(!file) return resolve(null);
    if(file.size > ${Math.floor(MAX_PROOF_BYTES)}) return reject(new Error('File too large (max ~4.5 MB)'));
    var r = new FileReader();
    r.onload = function(){ resolve(String(r.result||'')); };
    r.onerror = function(){ reject(new Error('Could not read file')); };
    r.readAsDataURL(file);
  });
}
function cpSubmitMarkPaid(){
  if(!_paidCtx) return;
  var errEl = document.getElementById('cp-paid-err');
  errEl.style.display = 'none';
  var fileInput = document.getElementById('cp-paid-file');
  var file = fileInput && fileInput.files && fileInput.files[0] ? fileInput.files[0] : null;
  if(_paidCtx.attachOnly && !file){
    errEl.textContent = 'Choose a proof file to upload.';
    errEl.style.display = 'block';
    return;
  }
  var btn = document.getElementById('cp-paid-go');
  btn.disabled = true;
  cpReadFileAsDataUrl(file).then(function(dataUrl){
    var body = {
      _token: _cpTok,
      cid: _paidCtx.cid,
      ym: _paidCtx.ym,
      action: _paidCtx.attachOnly ? 'attach_proof' : 'paid',
      tab: _cpTab,
      from: _cpFrom || '',
      to: _cpTo || '',
      payRef: (document.getElementById('cp-paid-ref').value||'').trim(),
      paymentDocName: file ? file.name : '',
      paymentDocContentType: file ? (file.type||'') : '',
      paymentDocBase64: dataUrl || ''
    };
    return fetch('/api/council-batch-action', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
      body: JSON.stringify(body)
    }).then(function(r){ return r.json().then(function(j){ return { ok: r.ok, j: j }; }); });
  }).then(function(res){
    btn.disabled = false;
    if(!res.ok || !res.j || !res.j.ok){
      errEl.textContent = (res.j && res.j.error) || 'Update failed';
      errEl.style.display = 'block';
      return;
    }
    var qs = 't='+encodeURIComponent(_cpTok)+'&tab='+encodeURIComponent(res.j.tab||_cpTab)+'&msg='+encodeURIComponent(res.j.msg||'Saved')+'&mt=ok';
    if(res.j.from || _cpFrom) qs += '&from='+encodeURIComponent(res.j.from||_cpFrom||'');
    if(res.j.to || _cpTo) qs += '&to='+encodeURIComponent(res.j.to||_cpTo||'');
    location.href = '/council-portal/batches?'+qs;
  }).catch(function(e){
    btn.disabled = false;
    errEl.textContent = e && e.message ? e.message : String(e);
    errEl.style.display = 'block';
  });
}
</script>`;
        res.send(portalPage('Claim Batches', renderNav(sess, token, 'batches'), body));
      }
    });
  });
});

router.post('/api/council-batch-create', (req, res) => {
  const token = (req.body._token as string) || '';
  const cidFilter = String(req.body.cid || '').trim();
  const ymFilter = String(req.body.ym || '').trim();
  const tab = normalizeClaimBatchStatusFilter(String(req.body.tab || 'submitted'));
  const filterFrom = String(req.body.from || '').trim();
  const filterTo = String(req.body.to || '').trim();
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const redirect = (msg: string, mt: string, t = tab) =>
    res.redirect(
      '/council-portal/batches?t=' +
        te +
        '&tab=' +
        encodeURIComponent(t) +
        (filterFrom ? '&from=' + encodeURIComponent(filterFrom) : '') +
        (filterTo ? '&to=' + encodeURIComponent(filterTo) : '') +
        '&msg=' +
        encodeURIComponent(msg) +
        '&mt=' +
        mt,
    );
  if (!sess) return redirect('Invalid session', 'err');
  if (ymFilter && !/^\d{4}-\d{2}$/.test(ymFilter)) {
    return redirect('Month must be YYYY-MM', 'err');
  }
  const who = sess.name || sess.councilId;
  loadCouncilTrips(sess.councilId, (_err: any, trips: any[]) => {
    const plans = planCouncilBatchCreates(trips || [], {
      councilId: sess.councilId,
      companyId: cidFilter || undefined,
      month: ymFilter || undefined,
      who,
      now: Date.now(),
    });
    if (!plans.length) {
      return redirect(
        'No approved trips found for that company/month. Approve trips first, then create the batch.',
        'err',
      );
    }
    let i = 0;
    let created = 0;
    let refreshed = 0;
    let skipped = 0;
    const runNext = () => {
      if (i >= plans.length) {
        const parts = [];
        if (created) parts.push(created + ' created');
        if (refreshed) parts.push(refreshed + ' refreshed');
        if (skipped) parts.push(skipped + ' skipped (already approved/paid)');
        return redirect(
          'Batch submit: ' + (parts.join(', ') || 'nothing written') + '.',
          created || refreshed ? 'ok' : 'err',
          'submitted',
        );
      }
      const plan = plans[i++];
      const path = 'tmBatches/' + sess.councilId + '/' + plan.pathSuffix;
      fbRead(path, (_eRead: any, existing: any) => {
        const decision = shouldWriteBatchCreate(existing);
        if (decision === 'skip') {
          skipped++;
          return runNext();
        }
        fbWrite('PATCH', path, plan.payload, (errW: any) => {
          if (!errW) {
            if (decision === 'refresh') refreshed++;
            else created++;
          } else {
            skipped++;
          }
          runNext();
        });
      });
    };
    runNext();
  });
});

router.post('/api/council-batch-action', (req, res) => {
  const wantsJson =
    String(req.headers.accept || '').indexOf('application/json') >= 0 ||
    String(req.headers['content-type'] || '').indexOf('application/json') >= 0;
  const token = (req.body._token as string) || '';
  const cid = (req.body.cid as string) || '';
  const ym = (req.body.ym as string) || '';
  const action = (req.body.action as string) || '';
  const payRef = ((req.body.payRef as string) || '').trim();
  const tab = normalizeClaimBatchStatusFilter(String(req.body.tab || 'submitted'));
  const filterFrom = String(req.body.from || '').trim();
  const filterTo = String(req.body.to || '').trim();
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  const redirect = (msg: string, mt: string, t = tab) => {
    if (wantsJson) {
      return res.status(mt === 'ok' ? 200 : 400).json({
        ok: mt === 'ok',
        msg,
        error: mt === 'ok' ? undefined : msg,
        tab: t,
        from: filterFrom || undefined,
        to: filterTo || undefined,
      });
    }
    return res.redirect(
      '/council-portal/batches?t=' +
        te +
        '&tab=' +
        encodeURIComponent(t) +
        (filterFrom ? '&from=' + encodeURIComponent(filterFrom) : '') +
        (filterTo ? '&to=' + encodeURIComponent(filterTo) : '') +
        '&msg=' +
        encodeURIComponent(msg) +
        '&mt=' +
        mt,
    );
  };
  if (!sess || !cid || !ym || !['approve', 'reject', 'paid', 'attach_proof'].includes(action)) {
    return redirect('Invalid request', 'err');
  }
  const path = 'tmBatches/' + sess.councilId + '/' + cid + '/' + ym;
  const who = sess.name || sess.councilId;

  const finishPaid = (batch: any, docMeta: any | null, attachOnly: boolean) => {
    const patch = attachOnly
      ? {
          paymentDocUrl: docMeta.paymentDocUrl,
          paymentDocName: docMeta.paymentDocName,
          paymentDocPath: docMeta.paymentDocPath,
          paymentDocUploadedAt: docMeta.paymentDocUploadedAt,
          paymentDocUploadedBy: who,
          paymentDocMissing: false,
        }
      : buildPaidBatchPatch({
          who,
          payRef,
          doc: docMeta
            ? {
                paymentDocUrl: docMeta.paymentDocUrl,
                paymentDocName: docMeta.paymentDocName,
                paymentDocPath: docMeta.paymentDocPath,
                paymentDocUploadedAt: docMeta.paymentDocUploadedAt,
                paymentDocUploadedBy: who,
                paymentDocMissing: false,
              }
            : null,
        });
    fbWrite('PATCH', path, patch, (err: any) => {
      if (err) return redirect('Update failed', 'err');
      if (attachOnly) {
        return redirect('Proof of payment uploaded.', 'ok', 'paid');
      }
      cascadeBatchTripsToPaid(batch || {}, cid, ym, who, () => {
        const miss = !docMeta;
        redirect(
          miss
            ? 'Batch marked paid (trips updated). Reminder: no proof uploaded.'
            : 'Batch marked paid; trips updated to Paid.',
          'ok',
          'paid',
        );
      });
    });
  };

  if (action === 'approve' || action === 'reject') {
    const patch =
      action === 'approve'
        ? { status: 'approved', approvedAt: Date.now(), approvedBy: who }
        : { status: 'rejected', rejectedAt: Date.now(), rejectedBy: who };
    return fbWrite('PATCH', path, patch, (err: any) => {
      if (err) return redirect('Update failed', 'err');
      redirect(action === 'approve' ? 'Batch approved.' : 'Batch rejected.', 'ok', action === 'approve' ? 'approved' : tab);
    });
  }

  // paid | attach_proof
  fbRead(path, (eRead: any, batch: any) => {
    if (eRead || !batch) return redirect('Batch not found', 'err');
    if (action === 'attach_proof' && String(batch.status || '') !== 'paid') {
      return redirect('Only paid batches can attach proof', 'err', 'paid');
    }
    if (action === 'paid' && String(batch.status || '') !== 'approved') {
      return redirect('Only approved batches can be marked paid', 'err', 'approved');
    }
    const b64 = String(req.body.paymentDocBase64 || '').trim();
    const docName = String(req.body.paymentDocName || '').trim() || 'proof.pdf';
    const docType = String(req.body.paymentDocContentType || '').trim();
    if (!b64) {
      if (action === 'attach_proof') return redirect('Proof file required', 'err', 'paid');
      return finishPaid(batch, null, false);
    }
    storeBatchProof(
      {
        councilId: sess.councilId,
        cid,
        ym,
        filename: docName,
        contentType: docType || undefined,
        dataBase64: b64,
        uploadedBy: who,
      },
      (errStore, stored) => {
        if (errStore || !stored) {
          return redirect(errStore ? errStore.message : 'Proof upload failed', 'err');
        }
        finishPaid(batch, stored, action === 'attach_proof');
      },
    );
  });
});

router.get('/api/council-batch-doc', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const cid = String(req.query.cid || '').trim();
  const ym = String(req.query.ym || '').trim();
  if (!cid || !ym) return res.status(400).send('Missing cid/ym');
  const rtdbPath = 'tmBatchDocs/' + sess.councilId + '/' + cid + '/' + ym;
  fbRead(rtdbPath, (err: any, doc: any) => {
    if (err || !doc || !doc.data) {
      // Maybe batch has external Storage URL
      return fbRead('tmBatches/' + sess.councilId + '/' + cid + '/' + ym, (e2: any, b: any) => {
        const url = b && b.paymentDocUrl ? String(b.paymentDocUrl) : '';
        if (url && url.indexOf('http') === 0) return res.redirect(url);
        return res.status(404).send('Document not found');
      });
    }
    try {
      const buf = Buffer.from(String(doc.data), 'base64');
      res.setHeader('Content-Type', doc.contentType || 'application/octet-stream');
      res.setHeader(
        'Content-Disposition',
        'inline; filename="' + String(doc.filename || 'proof.bin').replace(/"/g, '') + '"',
      );
      res.send(buf);
    } catch {
      res.status(500).send('Corrupt document');
    }
  });
});

// ── Approved Operators ─────────────────────────────────────────────────────────
router.get('/council-portal/operators', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(msg)}</div>` : '';
  fbRead('tmCompanyAccess', (err: any, allAccess: any) => {
    const approvedCids: string[] = [];
    if (allAccess) {
      Object.entries(allAccess).forEach(([cid, councils]: [string, any]) => {
        if (councils && councils[sess.councilId] && councils[sess.councilId].approved) {
          approvedCids.push(cid);
        }
      });
    }
    const emptyBody = `<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:16px">Approved Operators</h2>
<div class="cp-card"><div class="cp-empty">No operators are currently approved under your council.</div></div>`;
    if (approvedCids.length === 0) return res.send(portalPage('Approved Operators', renderNav(sess, token, 'operators'), emptyBody));
    // clients + tariffs + tmConfig per cid, plus drivers root + vehicles root
    let pending3 = approvedCids.length * 3 + 2;
    const clientMap: Record<string, any> = {};
    const tariffMap: Record<string, any> = {};
    const tmConfigMap: Record<string, any> = {};
    let driversRoot: Record<string, unknown> | null = null;
    let vehiclesRoot: Record<string, unknown> | null = null;
    function done3() {
      if (--pending3 === 0) buildOperatorsPage();
    }
    fbRead('drivers', (e: any, allDrivers: any) => {
      driversRoot = allDrivers && typeof allDrivers === 'object' ? allDrivers : {};
      done3();
    });
    fbRead('vehicles', (e: any, allVeh: any) => {
      vehiclesRoot = allVeh && typeof allVeh === 'object' ? allVeh : {};
      done3();
    });
    approvedCids.forEach(cid => {
      fbRead('superClients/' + cid, (e: any, sc: any) => { clientMap[cid] = sc || {}; done3(); });
      fbRead('tmTariffs/' + cid, (e: any, t: any) => { tariffMap[cid] = t || {}; done3(); });
      fbRead('companySettings/' + cid + '/tmConfig', (e: any, tc: any) => { tmConfigMap[cid] = tc || {}; done3(); });
    });
    function buildOperatorsPage() {
      const legacyProv = legacyTariffProvenance();
      const te = encodeURIComponent(token);
      const rosterByCid = Object.fromEntries(
        partitionOperatorRosters(approvedCids, driversRoot, listDriversForCompany).map((r) => [
          r.cid,
          r.drivers,
        ]),
      );
      const sections = approvedCids.map(cid => {
        const sc = clientMap[cid] || {};
        const tar = tariffMap[cid] || {};
        const tmCfg = tmConfigMap[cid] || {};
        const syncProv = classifyTmConfig(tmCfg);
        const drivers =
          rosterByCid[cid] || listDriversForCompany(driversRoot, cid, { activeOnly: true });
        const tarCar = tar.car || {};
        const tarVan = tar.van || {};
        const inp = (name: string, val: any) =>
          `<input class="cp-input" type="number" step="0.01" min="0" name="${name}" value="${esc(String(parseFloat(val || 0).toFixed(2)))}" style="width:90px;text-align:right"/>`;
        const tarHtml = `
<form method="POST" action="/api/council-tariff-save">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="cid" value="${esc(cid)}"/>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:10px">
  <div style="background:#F1F8E9;border-radius:6px;padding:12px">
    <div style="font-size:12px;font-weight:700;color:#33691E;margin-bottom:8px">&#128664; Standard Car Rates</div>
    <table style="font-size:12px;width:100%">
      <tr><td style="color:#666;padding:4px 0">Base Fare</td><td style="text-align:right">${inp('car_base', tarCar.base)}</td></tr>
      <tr><td style="color:#666;padding:4px 0">Per km</td><td style="text-align:right">${inp('car_perKm', tarCar.perKm)}</td></tr>
      <tr><td style="color:#666;padding:4px 0">Per min</td><td style="text-align:right">${inp('car_perMin', tarCar.perMin)}</td></tr>
      <tr><td style="color:#666;padding:4px 0">Stop/Wait</td><td style="text-align:right">${inp('car_stopFee', tarCar.stopFee)}</td></tr>
    </table>
  </div>
  <div style="background:#E8F5E9;border-radius:6px;padding:12px">
    <div style="font-size:12px;font-weight:700;color:#1B5E20;margin-bottom:8px">♿ Wheelchair Van Rates</div>
    <table style="font-size:12px;width:100%">
      <tr><td style="color:#666;padding:4px 0">Base Fare</td><td style="text-align:right">${inp('van_base', tarVan.base)}</td></tr>
      <tr><td style="color:#666;padding:4px 0">Per km</td><td style="text-align:right">${inp('van_perKm', tarVan.perKm)}</td></tr>
      <tr><td style="color:#666;padding:4px 0">Per min</td><td style="text-align:right">${inp('van_perMin', tarVan.perMin)}</td></tr>
      <tr><td style="color:#666;padding:4px 0">Stop/Wait</td><td style="text-align:right">${inp('van_stopFee', tarVan.stopFee)}</td></tr>
    </table>
  </div>
</div>
<div style="display:flex;align-items:center;gap:12px;margin-top:10px;flex-wrap:wrap">
  <button type="submit" class="cp-btn cp-btn-g">Save reference prices</button>
  ${tar.updatedAt ? `<span style="font-size:11px;color:#aaa">Last updated: ${new Date(tar.updatedAt).toLocaleString('en-NZ')}</span>` : ''}
</div>
</form>`;
        const driverRows = drivers.length ? drivers.map(d => {
          const name = [d.firstName, (d as any).lastName].filter(Boolean).join(' ') || String(d.name || '—');
          const veh = resolveDriverVehicle(vehiclesRoot, cid, d as Record<string, unknown>);
          const plate = veh.registration || '—';
          const cab = veh.taxiNumber || '—';
          const vehLabel = veh.label || '—';
          const vtype = veh.vehicleType || String((d as any).vehicleType || '—');
          const accessible = isDriverWav(d) ? '<span style="background:#E8F5E9;color:#2E7D32;padding:1px 6px;border-radius:8px;font-size:11px;font-weight:600">♿ WAV</span>' : '';
          const driverHist =
            name && name !== '—'
              ? `<a href="/council-portal/entity?t=${te}&type=driver&key=${encodeURIComponent(name)}" style="color:#2E7D32;font-weight:600">${esc(name)}</a>`
              : esc(name);
          return `<tr>
<td style="font-weight:500">${driverHist}</td>
<td style="font-family:monospace;font-size:11px">${esc(plate)}</td>
<td style="font-family:monospace;font-size:11px">${esc(cab)}</td>
<td>${esc(vehLabel)}</td>
<td style="font-size:12px;color:#666">${esc(vtype)}</td>
<td>${accessible}</td>
</tr>`;
        }).join('') : `<tr><td colspan="6" style="text-align:center;color:#aaa;font-style:italic;padding:12px">No drivers on file</td></tr>`;
        const pct = tmCfg.councilSubsidyPercent ?? tmCfg.councilPercent;
        const cap = tmCfg.councilCapAmount ?? tmCfg.capAmount;
        const hoist = tmCfg.hoistCostPerUnit ?? tmCfg.hoistUnitCost;
        return `
<div class="cp-card" style="margin-bottom:18px">
  <div class="cp-card-hd">
    <h3 style="font-size:15px">&#127970; ${esc(sc.name || cid)}</h3>
    <span style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
      <a href="/council-portal/entity?t=${te}&type=company&key=${encodeURIComponent(cid)}" class="cp-btn-sm" style="background:#E8F5E9;color:#1B5E20">Trip history</a>
      ${provenanceBadgeHtml(syncProv)}
      <span style="background:#E8F5E9;color:#2E7D32;padding:2px 8px;border-radius:10px;font-weight:600;font-size:11px">&#10003; Approved</span>
    </span>
  </div>
  <div style="padding:14px 18px">
    ${sc.phone || sc.email || sc.address ? `<div style="font-size:12.5px;color:#555;margin-bottom:10px;display:flex;gap:20px;flex-wrap:wrap">
      ${sc.phone ? `<span>&#128222; ${esc(sc.phone)}</span>` : ''}
      ${sc.email ? `<span>&#9993; ${esc(sc.email)}</span>` : ''}
      ${sc.address ? `<span>&#128205; ${esc(sc.address)}</span>` : ''}
    </div>` : ''}
    <div style="font-size:13px;font-weight:700;color:#1B5E20;margin-bottom:4px">Live TM economics ${provenanceBadgeHtml(syncProv)}</div>
    <p style="font-size:11.5px;color:#666;margin:0 0 8px">${esc(syncProv.detail)} — subsidy ${pct != null ? esc(String(pct)) + '%' : '—'}, cap $${cap != null ? Number(cap).toFixed(2) : '—'}, hoist $${hoist != null ? Number(hoist).toFixed(2) : '—'}/use</p>
    <div style="font-size:13px;font-weight:700;color:#1B5E20;margin:14px 0 6px;display:flex;align-items:center;gap:8px;flex-wrap:wrap">
      Reference price list ${provenanceBadgeHtml(legacyProv)}
      <span class="cp-ref-badge" title="Not live meter source of truth">Manual reference (not live meter SoT)</span>
    </div>
    <p style="font-size:11.5px;color:#888;margin:0 0 6px;line-height:1.4">Optional council-maintained rates for fare-mismatch checks in Reports. Not used for live metering or claims — drivers fare against the company tariff; subsidy comes from council TM config.</p>
    ${tarHtml}
    <div style="font-size:13px;font-weight:700;color:#1B5E20;margin:14px 0 6px">Drivers &amp; Vehicles (${drivers.length})</div>
    <div style="overflow-x:auto">
    <table class="cp-tbl">
      <thead><tr><th>Driver Name</th><th>Registration</th><th>Cab No</th><th>Vehicle</th><th>Type</th><th>Accessible</th></tr></thead>
      <tbody>${driverRows}</tbody>
    </table>
    </div>
  </div>
</div>`;
      }).join('');
      const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:4px">Approved Operators</h2>
${noticeHtml}
<p style="font-size:13px;color:#666;margin-bottom:16px">${approvedCids.length} operator(s) approved under your council for Total Mobility. Registration and cab number come from the company vehicle registry.</p>
${sections}`;
      res.send(portalPage('Approved Operators', renderNav(sess, token, 'operators'), body));
    }
  });
});

// ── Config (subsidy %, cap, hoist — dual-edit with SA + audit) ─────────────────
router.get('/council-portal/config', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
  fbRead('tmConfig/' + sess.councilId, (e1: any, cfg: any) => {
    fbRead('tmConfigAudit/' + sess.councilId, (e2: any, auditMap: any) => {
      cfg = cfg || {};
      const entries = Object.entries(auditMap || {})
        .map(([id, a]: [string, any]) => ({ id, ...(a || {}) }))
        .sort((a, b) => (b.at || 0) - (a.at || 0))
        .slice(0, 25);
      const auditRows = entries.length
        ? entries.map((a) => {
            const when = a.at ? new Date(a.at).toLocaleString('en-NZ') : '—';
            const role = a.byRole === 'council' ? 'Council' : 'Superadmin';
            const prev = a.previous || {};
            const next = a.next || {};
            return `<tr>
<td style="font-size:11px;white-space:nowrap">${esc(when)}</td>
<td><span class="cp-bdg-b">${esc(role)}</span> ${esc(a.byName || a.byEmail || '')}</td>
<td style="font-size:12px">% ${prev.subsidyPercent ?? '—'} → <strong>${next.subsidyPercent ?? '—'}</strong></td>
<td style="font-size:12px">$${Number(prev.capAmount ?? 0).toFixed(2)} → <strong>$${Number(next.capAmount ?? 0).toFixed(2)}</strong></td>
<td style="font-size:12px">$${Number(prev.hoistRatePerUse ?? 0).toFixed(2)} → <strong>$${Number(next.hoistRatePerUse ?? 0).toFixed(2)}</strong></td>
</tr>`;
          }).join('')
        : '<tr><td colspan="5" class="cp-empty">No changes recorded yet.</td></tr>';
      const body = `${noticeHtml}
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:6px">TM Financial Config</h2>
<p style="font-size:13px;color:#666;margin-bottom:16px">Edit subsidy %, per-trip cap, and hoist rate. Same fields Superadmin can edit. Hoist is always <strong>100% council-paid</strong> and is not part of the meter %/cap split. Changes sync to approved operators&rsquo; driver apps.</p>
<div class="cp-card">
<div class="cp-card-hd"><h3>Rates — ${esc(sess.name || sess.councilId)}</h3></div>
<div class="cp-card-bd">
<form method="POST" action="/api/council-config-save" style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;align-items:end">
<input type="hidden" name="_token" value="${esc(token)}"/>
<div><label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Subsidy % (1–100)</label>
<input type="number" name="subsidyPercent" required min="1" max="100" step="1"
  value="${esc(String(cfg.subsidyPercent ?? ''))}"
  style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:14px"/></div>
<div><label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Subsidy cap per trip ($0.01–500)</label>
<input type="number" name="capAmount" required min="0.01" max="500" step="0.01"
  value="${esc(String(cfg.capAmount ?? ''))}"
  style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:14px"/></div>
<div><label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Hoist fee per use ($0–200)</label>
<input type="number" name="hoistRatePerUse" required min="0" max="200" step="0.01"
  value="${esc(String(cfg.hoistRatePerUse ?? '0'))}"
  style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:14px"/></div>
<div style="grid-column:1/-1">
<button type="submit" class="cp-btn cp-btn-g">Save &amp; sync to operators</button>
<span style="font-size:12px;color:#888;margin-left:10px">Passenger pays $0 toward hoist.</span>
</div>
</form>
</div></div>
<div class="cp-card">
<div class="cp-card-hd"><h3>Change history</h3>
<span style="font-size:12px;color:#888">Who changed what (SA vs council)</span></div>
<table class="cp-tbl"><thead><tr><th>When</th><th>By</th><th>Subsidy %</th><th>Cap</th><th>Hoist / use</th></tr></thead>
<tbody>${auditRows}</tbody></table>
</div>`;
      res.send(portalPage('Config', renderNav(sess, token, 'config'), body));
    });
  });
});

router.post('/api/council-config-save', (req, res) => {
  const { _token, subsidyPercent, capAmount, hoistRatePerUse } = req.body;
  const sess = cpGetSession(_token);
  const te = encodeURIComponent(_token || '');
  if (!sess) return res.redirect('/council-portal?err=session');
  const pct = parseFloat(String(subsidyPercent));
  const cap = parseFloat(String(capAmount));
  const hoist = parseFloat(String(hoistRatePerUse));
  const verr = validateTmFinancials(pct, cap, hoist);
  if (verr) {
    return res.redirect(`/council-portal/config?t=${te}&msg=${encodeURIComponent(verr)}&mt=err`);
  }
  fbRead('tmConfig/' + sess.councilId, (err: any, prev: any) => {
    if (err || !prev) {
      return res.redirect(`/council-portal/config?t=${te}&msg=${encodeURIComponent('Council config not found')}&mt=err`);
    }
    const next = {
      ...prev,
      subsidyPercent: pct,
      capAmount: cap,
      hoistRatePerUse: hoist,
      hoistCoveredByCouncil: true,
      updatedAt: Date.now(),
    };
    const audit = {
      at: Date.now(),
      byRole: 'council',
      byName: sess.name || sess.councilId,
      byEmail: sess.email || '',
      councilId: sess.councilId,
      previous: {
        subsidyPercent: prev.subsidyPercent,
        capAmount: prev.capAmount,
        hoistRatePerUse: prev.hoistRatePerUse,
      },
      next: {
        subsidyPercent: pct,
        capAmount: cap,
        hoistRatePerUse: hoist,
      },
    };
    const auditKey = '-a' + Date.now();
    fbWrite('PUT', 'tmConfig/' + sess.councilId, next, (wErr: any) => {
      if (wErr) {
        return res.redirect(`/council-portal/config?t=${te}&msg=${encodeURIComponent('Save failed')}&mt=err`);
      }
      fbWrite('PUT', 'tmConfigAudit/' + sess.councilId + '/' + auditKey, audit, () => {
        syncCouncilTmConfigToApprovedCompanies(sess.councilId, next, () => {
          res.redirect(`/council-portal/config?t=${te}&msg=${encodeURIComponent('Saved. Driver apps synced for approved operators.')}&mt=ok`);
        });
      });
    });
  });
});

// ── CSV Export ─────────────────────────────────────────────────────────────────
router.get('/council-portal/export', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const filterCompany = String(req.query.company || '').trim();
  const filterFrom = String(req.query.from || '').trim();
  const filterTo = String(req.query.to || '').trim();
  const filterQ = String(req.query.q || '').trim();
  const filterStatusRaw = String(req.query.status || '').trim();
  const includeArchived = String(req.query.includeArchived || '') === '1';
  // Legacy month=YYYY-MM still supported
  const filterMonth = String(req.query.month || '').trim();
  const entityType = normalizeEntityType(String(req.query.entityType || ''));
  const entityKey = String(req.query.entityKey || '').trim();
  loadCouncilTrips(sess.councilId, (err: any, trips: any[]) => {
    let filtered: any[];
    if (filterStatusRaw) {
      filtered = filterTripsUnified(trips, {
        status: filterStatusRaw,
        q: filterQ,
        companyId: filterCompany,
        from: filterFrom,
        to: filterTo,
      });
    } else {
      filtered = filterTripsForReports(trips, {
        companyId: filterCompany || undefined,
        from: filterFrom || undefined,
        to: filterTo || undefined,
        includeArchived,
      });
      if (filterQ) filtered = filtered.filter((t) => tripMatchesSearch(t, filterQ));
    }
    if (filterMonth && !filterFrom && !filterTo && !filterStatusRaw) {
      filtered = trips
        .filter((t) => tripMonthKey(t) === filterMonth)
        .filter((t) => !filterCompany || String(t._cid) === filterCompany)
        .filter((t) => includeArchived || !isArchivedStatus(t.status))
        .filter((t) => !filterQ || tripMatchesSearch(t, filterQ))
        .sort((a, b) => tripActivityMs(a) - tripActivityMs(b));
    } else {
      filtered.sort((a, b) => tripActivityMs(a) - tripActivityMs(b));
    }
    if (entityType && entityKey) {
      filtered = filterTripsByEntity(filtered, entityType, entityKey);
    }
    const tariffCids = Array.from(new Set(filtered.map((t) => String(t._cid || '')).filter(Boolean)));
    const tariffByCid: Record<string, any> = {};
    let left = tariffCids.length;
    const emit = () => {
      const esc2 = (v: any) => '"' + String(v ?? '').replace(/"/g, '""') + '"';
      const rows = filtered
        .map((t) =>
          tmTripDetailToCsvRow(
            buildTmTripDetail(t, { refTariff: (tariffByCid[t._cid] || {}).car || null }),
          ).map(esc2).join(','),
        );
      const csv = [TM_TRIP_CSV_HEADERS.map(esc2).join(','), ...rows].join('\r\n');
      const rangeLabel =
        filterFrom || filterTo
          ? `${filterFrom || 'start'}_${filterTo || 'end'}`
          : filterMonth || 'All';
      const fname =
        'TM-Trips-' +
        rangeLabel +
        (filterCompany ? '-' + filterCompany : '') +
        '-' +
        sess.councilId +
        '.csv';
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', 'attachment; filename="' + fname + '"');
      res.send(csv);
    };
    if (left === 0) return emit();
    tariffCids.forEach((cid) => {
      fbRead('tmTariffs/' + cid, (eT: any, tar: any) => {
        tariffByCid[cid] = tar || {};
        if (--left <= 0) emit();
      });
    });
  });
});

// ── Entity trip history ────────────────────────────────────────────────────────
router.get('/council-portal/entity', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const te = encodeURIComponent(token);
  const typeRaw = String(req.query.type || '');
  const entityType = normalizeEntityType(typeRaw);
  const entityKey = String(req.query.key || '').trim();
  const filterFrom = String(req.query.from || '').trim();
  const filterTo = String(req.query.to || '').trim();
  const filterCompany = String(req.query.company || '').trim();
  if (!entityType || !entityKey || !ENTITY_TYPES.includes(entityType)) {
    return res.redirect(
      `/council-portal/trips?t=${te}&msg=${encodeURIComponent('Invalid entity type or key')}&mt=err`,
    );
  }

  loadCouncilTrips(sess.councilId, (_err: any, myTrips: any[]) => {
    let filtered = filterTripsForReports(myTrips || [], {
      companyId: filterCompany || undefined,
      from: filterFrom || undefined,
      to: filterTo || undefined,
      includeArchived: false,
    });
    filtered = filterTripsByEntity(filtered, entityType, entityKey);
    const totals = sumEntityTotals(filtered);
    const hoistDays = aggregateHoistByDay(filtered);
    const hoistUsesLabel = filtered.reduce((s, t) => s + hoistUsesOf(t), 0);
    const hoistPaysLabel = +filtered.reduce((s, t) => s + hoistPaysOf(t), 0).toFixed(2);
    const companyOpts = companyFilterOptionsHtml(myTrips || [], filterCompany);
    const typeLabel = entityType.charAt(0).toUpperCase() + entityType.slice(1);
    const exportQs =
      `&entityType=${encodeURIComponent(entityType)}` +
      `&entityKey=${encodeURIComponent(entityKey)}` +
      `&from=${encodeURIComponent(filterFrom)}` +
      `&to=${encodeURIComponent(filterTo)}` +
      `&company=${encodeURIComponent(filterCompany)}` +
      `&status=all`;

    const tariffCids = Array.from(new Set(filtered.map((t) => String(t._cid || '')).filter(Boolean)));
    loadTariffsForCids(tariffCids, (tariffByCid) => {
      const details = filtered.map((t) =>
        buildTmTripDetail(t, { refTariff: (tariffByCid[t._cid] || {}).car || null }),
      );
      const hoistRows = hoistDays.length
        ? hoistDays
            .map(
              (r) =>
                `<tr><td>${esc(r.day)}</td><td style="text-align:right">${r.tripsWithHoist}</td><td style="text-align:right">${r.uses}</td><td style="text-align:right">$${r.hoistPays.toFixed(2)}</td></tr>`,
            )
            .join('')
        : `<tr><td colspan="4" class="cp-empty">No hoist usage</td></tr>`;
      const tripRows = details.length
        ? details
            .map((d, idx) => {
              const t = filtered[idx];
              return `<tr>
<td style="font-family:monospace;font-size:12px">${esc(d.id || t._rawKey || '—')}</td>
<td>${esc(d.dateTime || '—')}</td>
<td style="font-size:12px;color:#555">${esc(d.companyName)}</td>
<td>${esc(d.driverName || '—')}</td>
<td>${esc(d.voucherNo || t.tmCardNumber || '—')}</td>
<td style="font-weight:700;color:#1B5E20">$${d.totalCouncil.toFixed(2)}</td>
<td>${statusBadge(d.status)}</td>
<td><button type="button" class="cp-btn-sm" onclick="openCpDetail(${idx})">Details</button>
<a class="cp-btn-sm" style="margin-left:4px;background:#eee;color:#333" href="/council-portal/trips?t=${te}&q=${encodeURIComponent(entityKey)}">Trips</a></td>
</tr>`;
            })
            .join('')
        : '';
      const bodyHtmlByIdx = details.map((d, idx) => {
        const src = filtered[idx] || {};
        return tripDetailModalHtml(d) + tripHistoryHtml(src);
      });
      const tripsJson = JSON.stringify(details).replace(/</g, '\\u003c');
      const bodiesJson = JSON.stringify(bodyHtmlByIdx).replace(/</g, '\\u003c');
      const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:4px">${esc(typeLabel)} — ${esc(entityKey)}</h2>
<p style="font-size:13px;color:#666;margin-bottom:14px">Trip history for this ${esc(entityType)}.
  <a href="/council-portal/trips?t=${te}" style="color:#2E7D32;font-weight:600">Back to Trips</a></p>
<form method="GET" action="/council-portal/entity" class="cp-card" style="margin-bottom:14px;padding:12px 14px;display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end">
  <input type="hidden" name="t" value="${esc(token)}"/>
  <input type="hidden" name="type" value="${esc(entityType)}"/>
  <input type="hidden" name="key" value="${esc(entityKey)}"/>
  <div>
    <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">From</label>
    <input type="date" name="from" class="cp-input" value="${esc(filterFrom)}"/>
  </div>
  <div>
    <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">To</label>
    <input type="date" name="to" class="cp-input" value="${esc(filterTo)}"/>
  </div>
  <div>
    <label style="display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:3px">Company</label>
    <select name="company" class="cp-input"><option value="">All Companies</option>${companyOpts}</select>
  </div>
  <button type="submit" class="cp-btn cp-btn-g">Apply</button>
  <a href="/council-portal/export?t=${te}${exportQs}" class="cp-btn cp-btn-g" style="margin-left:auto">&#11015; Download CSV</a>
</form>
<div class="cp-stats">
  <div class="cp-stat"><div class="cp-stat-v">${totals.trips}</div><div class="cp-stat-l">Trips</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totals.meterFare.toFixed(2)}</div><div class="cp-stat-l">Meter Fare</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totals.councilPays.toFixed(2)}</div><div class="cp-stat-l">Council $</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${hoistPaysLabel.toFixed(2)}</div><div class="cp-stat-l">Hoist $ (${hoistUsesLabel} uses)</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totals.passengerPays.toFixed(2)}</div><div class="cp-stat-l">Passenger Pays</div></div>
</div>
<div class="cp-card" style="margin-bottom:18px;padding:14px 18px">
  <h3 style="font-size:14px;color:#1B5E20;margin:0 0 10px">Hoist by day</h3>
  <table class="cp-tbl" style="max-width:560px">
    <thead><tr><th>Date</th><th style="text-align:right">Trips w/ hoist</th><th style="text-align:right">Uses</th><th style="text-align:right">Hoist $</th></tr></thead>
    <tbody>${hoistRows}</tbody>
  </table>
</div>
<div class="cp-card" style="overflow-x:auto">
  <div class="cp-card-hd"><h3>Trips</h3>
    <span style="font-size:12px;color:#888">${details.length} trip(s)</span></div>
  ${details.length ? `<table class="cp-tbl">
<thead><tr><th>Job</th><th>Date</th><th>Company</th><th>Driver</th><th>Card</th><th>Council $</th><th>Status</th><th>Actions</th></tr></thead>
<tbody>${tripRows}</tbody></table>` : '<div class="cp-empty">No trips for this entity and filters.</div>'}
</div>
${cpTripDetailOverlayHtml()}
${CP_TRIP_MAP_SCRIPT}
<script>
var _cpTrips = ${tripsJson};
var _cpBodies = ${bodiesJson};
var _cpToken = ${JSON.stringify(token)};
var _cpReturnTo = 'all';
</script>
${cpTripDetailBehaviorScript(false)}`;
      res.send(portalPage(typeLabel + ' history', renderNav(sess, token, 'trips'), body));
    });
  });
});

// ── Cards ──────────────────────────────────────────────────────────────────────
router.get('/council-portal/cards', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
  fbRead('tmCards', (err: any, allCards: any) => {
    const cards = Object.entries(allCards || {})
      .filter(([, c]: [string, any]) => c.councilId === sess.councilId)
      .sort((a: any, b: any) => (a[1].passengerName || '').localeCompare(b[1].passengerName || ''));
    const te = encodeURIComponent(token);
    const rows = cards.map(([id, c]: [string, any]) => {
      const active = c.active !== false;
      const balance = parseFloat(c.balance || 0).toFixed(2);
      const monthlyTrips = c.usageLimitMonthly ?? c.monthlyLimit;
      const dailyTrips = c.usageLimitDaily ?? c.maxFarePerTrip;
      const limit = monthlyTrips != null && monthlyTrips !== ''
        ? `${parseInt(String(monthlyTrips), 10) || 0}/mo`
        : '—';
      const daily = dailyTrips != null && dailyTrips !== ''
        ? `${parseInt(String(dailyTrips), 10) || 0}/day`
        : '—';
      const expiry = c.expiryDate ? esc(String(c.expiryDate).slice(0, 10)) : '—';
      return `<tr>
<td style="font-family:monospace;font-weight:600">${esc(id)}</td>
<td>${esc(c.passengerName || '—')}</td>
<td>${esc(c.passengerPhone || '—')}</td>
<td>${expiry}</td>
<td style="font-weight:600;color:#1B5E20">$${balance}</td>
<td>${limit}</td>
<td>${daily}</td>
<td><span class="${active ? 'cp-bdg-g' : 'cp-bdg-r'}">${active ? 'Active' : 'Inactive'}</span></td>
<td style="white-space:nowrap">
<a class="cp-btn-sm" href="/council-portal/cards/edit?t=${te}&id=${encodeURIComponent(id)}" style="margin-right:4px">Edit</a>
<a class="cp-btn-sm" href="/council-portal/entity?t=${te}&type=card&key=${encodeURIComponent(id)}" style="margin-right:4px;background:#E8F5E9;color:#1B5E20">History</a>
<form method="POST" action="/api/council-card-toggle" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="cardId" value="${esc(id)}"/>
<input type="hidden" name="active" value="${active ? 'false' : 'true'}"/>
<button type="submit" class="${active ? 'cp-tog-on' : 'cp-tog-off'}">${active ? 'Deactivate' : 'Activate'}</button>
</form>
</td></tr>`;
    }).join('');
    const body = `
${noticeHtml}
<div class="cp-card">
<div class="cp-card-hd"><h3>&#127938; TM Cards (${esc(sess.name || sess.councilId)})</h3>
<span style="display:flex;gap:10px;align-items:center">
  <span style="font-size:12px;color:#888">${cards.length} card(s)</span>
  <a href="/council-portal/cards/edit?t=${te}" class="cp-btn cp-btn-g">+ Add Card</a>
</span></div>
${cards.length ? `<table class="cp-tbl"><thead><tr><th>Card No</th><th>Passenger</th><th>Phone</th><th>Expiry</th><th>Balance</th><th>Monthly</th><th>Daily</th><th>Status</th><th>Actions</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="cp-empty">No cards found for this council. <a href="/council-portal/cards/edit?t=' + te + '">Add a card</a></div>'}
</div>`;
    res.send(portalPage('Cards', renderNav(sess, token, 'cards'), body));
  });
});

router.get('/council-portal/cards/edit', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const te = encodeURIComponent(token);
  const cardId = String(req.query.id || '').trim();
  const isAdd = !cardId;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';

  const renderForm = (c: any) => {
    const active = c.active !== false;
    const monthlyRaw = c.usageLimitMonthly ?? c.monthlyLimit;
    const dailyRaw = c.usageLimitDaily ?? c.maxFarePerTrip;
    const monthly = monthlyRaw != null && monthlyRaw !== '' ? String(parseInt(String(monthlyRaw), 10) || '') : '';
    const daily = dailyRaw != null && dailyRaw !== '' ? String(parseInt(String(dailyRaw), 10) || '') : '';
    const expiry = c.expiryDate ? String(c.expiryDate).slice(0, 10) : '';
    const body = `
${noticeHtml}
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:6px">${isAdd ? 'Add TM Card' : 'Edit TM Card'}</h2>
<p style="font-size:13px;color:#666;margin-bottom:14px"><a href="/council-portal/cards?t=${te}" style="color:#2E7D32;font-weight:600">&#8592; Back to Cards</a></p>
<div class="cp-card">
<div class="cp-card-bd">
<form method="POST" action="/api/council-card-save" style="display:grid;grid-template-columns:1fr 1fr;gap:14px;max-width:720px">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="mode" value="${isAdd ? 'create' : 'edit'}"/>
${!isAdd ? `<input type="hidden" name="originalId" value="${esc(cardId)}"/>` : ''}
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Card number${!isAdd ? ' (locked)' : ' *'}</label>
  <input class="cp-input" name="cardNumber" value="${esc(cardId)}" ${isAdd ? 'required' : 'readonly'} style="width:100%"/>
</div>
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Passenger name *</label>
  <input class="cp-input" name="passengerName" value="${esc(c.passengerName || '')}" required style="width:100%"/>
</div>
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Passenger phone</label>
  <input class="cp-input" name="passengerPhone" value="${esc(c.passengerPhone || '')}" style="width:100%"/>
</div>
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Expiry date</label>
  <input class="cp-input" type="date" name="expiryDate" value="${esc(expiry)}" style="width:100%"/>
</div>
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Card region</label>
  <input class="cp-input" name="cardRegion" value="${esc(c.cardRegion || '')}" style="width:100%"/>
</div>
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Status</label>
  <select class="cp-input" name="active" style="width:100%">
    <option value="true"${active ? ' selected' : ''}>Active</option>
    <option value="false"${!active ? ' selected' : ''}>Inactive</option>
  </select>
</div>
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Monthly trip limit</label>
  <input class="cp-input" type="number" min="0" step="1" name="usageLimitMonthly" value="${esc(monthly)}" placeholder="Unlimited" style="width:100%"/>
</div>
<div>
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Daily trip limit</label>
  <input class="cp-input" type="number" min="0" step="1" name="usageLimitDaily" value="${esc(daily)}" placeholder="Unlimited" style="width:100%"/>
</div>
<div style="grid-column:1/-1">
  <label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Notes</label>
  <input class="cp-input" name="notes" value="${esc(c.notes || '')}" style="width:100%"/>
</div>
<div style="grid-column:1/-1;display:flex;gap:10px">
  <button type="submit" class="cp-btn cp-btn-g">${isAdd ? 'Create card' : 'Save changes'}</button>
  <a href="/council-portal/cards?t=${te}" class="cp-btn" style="background:#eee;color:#333">Cancel</a>
</div>
</form>
</div>
</div>`;
    res.send(portalPage(isAdd ? 'Add Card' : 'Edit Card', renderNav(sess, token, 'cards'), body));
  };

  if (isAdd) return renderForm({});
  fbRead('tmCards/' + cardId, (err: any, card: any) => {
    if (err || !card) {
      return res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Card not found')}&mt=err`);
    }
    if (card.councilId !== sess.councilId) {
      return res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Access denied')}&mt=err`);
    }
    renderForm(card);
  });
});

router.post('/api/council-card-save', (req, res) => {
  const {
    _token,
    mode,
    originalId,
    cardNumber,
    passengerName,
    passengerPhone,
    expiryDate,
    cardRegion,
    notes,
    usageLimitMonthly,
    usageLimitDaily,
    active,
  } = req.body || {};
  const sess = cpGetSession(_token);
  if (!sess) return res.redirect('/council-portal?err=session');
  const te = encodeURIComponent(_token);
  const isCreate = String(mode || '') === 'create';
  const num = String(isCreate ? cardNumber : originalId || cardNumber || '')
    .trim()
    .replace(/\s+/g, '');
  const name = String(passengerName || '').trim();
  if (!num) {
    return res.redirect(
      `/council-portal/cards/edit?t=${te}${isCreate ? '' : '&id=' + encodeURIComponent(String(originalId || ''))}&msg=${encodeURIComponent('Card number required')}&mt=err`,
    );
  }
  if (!name) {
    return res.redirect(
      `/council-portal/cards/edit?t=${te}${isCreate ? '' : '&id=' + encodeURIComponent(num)}&msg=${encodeURIComponent('Passenger name required')}&mt=err`,
    );
  }
  const payload: any = {
    passengerName: name,
    passengerPhone: String(passengerPhone || '').trim() || null,
    expiryDate: String(expiryDate || '').trim() || null,
    cardRegion: String(cardRegion || '').trim() || null,
    notes: String(notes || '').trim() || null,
    active: String(active) !== 'false',
    councilId: sess.councilId,
    updatedAt: Date.now(),
    updatedBy: sess.name || sess.councilId,
  };
  if (usageLimitMonthly !== '' && usageLimitMonthly !== undefined) {
    payload.usageLimitMonthly = parseInt(String(usageLimitMonthly), 10) || null;
  } else {
    payload.usageLimitMonthly = null;
  }
  if (usageLimitDaily !== '' && usageLimitDaily !== undefined) {
    payload.usageLimitDaily = parseInt(String(usageLimitDaily), 10) || null;
  } else {
    payload.usageLimitDaily = null;
  }

  if (isCreate) {
    fbRead('tmCards/' + num, (err: any, existing: any) => {
      if (!err && existing) {
        return res.redirect(
          `/council-portal/cards/edit?t=${te}&msg=${encodeURIComponent('Card already exists')}&mt=err`,
        );
      }
      payload.createdAt = Date.now();
      payload.balance = 0;
      fbWrite('PUT', 'tmCards/' + num, payload, (e: any) => {
        if (e) {
          return res.redirect(
            `/council-portal/cards/edit?t=${te}&msg=${encodeURIComponent('Error: ' + e)}&mt=err`,
          );
        }
        res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Card created')}&mt=ok`);
      });
    });
    return;
  }

  fbRead('tmCards/' + num, (err: any, card: any) => {
    if (err || !card) {
      return res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Card not found')}&mt=err`);
    }
    if (card.councilId !== sess.councilId) {
      return res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Access denied')}&mt=err`);
    }
    // Card number locked on edit — never rewrite under a different key
    fbWrite('PATCH', 'tmCards/' + num, payload, (e: any) => {
      if (e) {
        return res.redirect(
          `/council-portal/cards/edit?t=${te}&id=${encodeURIComponent(num)}&msg=${encodeURIComponent('Error: ' + e)}&mt=err`,
        );
      }
      res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Card updated')}&mt=ok`);
    });
  });
});

router.post('/api/council-card-toggle', (req, res) => {
  const { _token, cardId, active } = req.body;
  const sess = cpGetSession(_token);
  if (!sess) return res.redirect('/council-portal?err=session');
  fbRead('tmCards/' + cardId, (err: any, card: any) => {
    if (err || !card) return res.redirect(`/council-portal/cards?t=${encodeURIComponent(_token)}&msg=${encodeURIComponent('Card not found')}&mt=err`);
    if (card.councilId !== sess.councilId) return res.redirect(`/council-portal/cards?t=${encodeURIComponent(_token)}&msg=${encodeURIComponent('Access denied')}&mt=err`);
    fbWrite('PATCH', 'tmCards/' + cardId, { active: active === 'true' }, (e: any) => {
      const te = encodeURIComponent(_token);
      if (e) return res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Error: ' + e)}&mt=err`);
      res.redirect(`/council-portal/cards?t=${te}&msg=${encodeURIComponent('Card updated')}&mt=ok`);
    });
  });
});

// ── Trip Limits (aligned with SA tmCards usageLimitMonthly / usageLimitDaily) ──
router.get('/council-portal/limits', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
  fbRead('tmCards', (err: any, allCards: any) => {
    const cards = Object.entries(allCards || {})
      .filter(([, c]: [string, any]) => c.councilId === sess.councilId)
      .sort((a: any, b: any) => (a[1].passengerName || '').localeCompare(b[1].passengerName || ''));
    const te = encodeURIComponent(token);
    const rows = cards.map(([id, c]: [string, any]) => {
      // Align with SA TM-Cards.aspx: usageLimitMonthly / usageLimitDaily (trip counts).
      const monthlyRaw = c.usageLimitMonthly ?? c.monthlyLimit;
      const dailyRaw = c.usageLimitDaily ?? c.maxFarePerTrip;
      const usageLimitMonthly = monthlyRaw != null && monthlyRaw !== '' ? String(parseInt(String(monthlyRaw), 10) || '') : '';
      const usageLimitDaily = dailyRaw != null && dailyRaw !== '' ? String(parseInt(String(dailyRaw), 10) || '') : '';
      return `<tr>
<td>${esc(id)}</td>
<td>${esc(c.passengerName || '—')}</td>
<td>
<form method="POST" action="/api/council-card-limits" style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="cardId" value="${esc(id)}"/>
<input type="number" name="usageLimitMonthly" value="${esc(usageLimitMonthly)}" placeholder="No monthly trip limit" min="0" step="1"
  style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:150px"/>
<input type="number" name="usageLimitDaily" value="${esc(usageLimitDaily)}" placeholder="No daily trip limit" min="0" step="1"
  style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:140px"/>
<button type="submit" class="cp-btn-sm">Save</button>
</form>
</td></tr>`;
    }).join('');
    const body = `<div class="cp-main">
${noticeHtml}
<div class="cp-card">
<div class="cp-card-hd"><h3>&#128176; Trip Limits — ${esc(sess.name || sess.councilId)}</h3>
<span style="font-size:12px;color:#888">Same fields as Superadmin TM Cards: monthly / daily trip limits per card</span></div>
${cards.length ? `<table class="cp-tbl"><thead><tr><th>Card No</th><th>Passenger</th><th>Monthly Trips / Daily Trips</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="cp-empty">No cards found for this council.</div>'}
</div>
<div class="cp-card" style="margin-top:18px">
<div class="cp-card-hd"><h3>&#127974; Council-Wide Default Limits</h3></div>
<div style="padding:16px 18px">
<form method="POST" action="/api/council-default-limits" style="display:flex;gap:16px;align-items:flex-end;flex-wrap:wrap">
<input type="hidden" name="_token" value="${esc(token)}"/>
<div><label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Default Monthly Trip Limit</label>
<input type="number" name="defaultUsageLimitMonthly" placeholder="Unlimited" min="0" step="1"
  style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:180px"/></div>
<div><label style="display:block;font-size:11.5px;font-weight:600;margin-bottom:4px">Default Daily Trip Limit</label>
<input type="number" name="defaultUsageLimitDaily" placeholder="Unlimited" min="0" step="1"
  style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:180px"/></div>
<button type="submit" class="cp-btn">Apply to All Cards</button>
</form>
</div>
</div>
</div>`;
    res.send(portalPage('Trip Limits', renderNav(sess, token, 'limits'), body));
  });
});

router.post('/api/council-card-limits', (req, res) => {
  const { _token, cardId, usageLimitMonthly, usageLimitDaily } = req.body;
  const sess = cpGetSession(_token);
  if (!sess) return res.redirect('/council-portal?err=session');
  const te = encodeURIComponent(_token);
  fbRead('tmCards/' + cardId, (err: any, card: any) => {
    if (err || !card) return res.redirect(`/council-portal/limits?t=${te}&msg=${encodeURIComponent('Card not found')}&mt=err`);
    if (card.councilId !== sess.councilId) return res.redirect(`/council-portal/limits?t=${te}&msg=${encodeURIComponent('Access denied')}&mt=err`);
    const patch: any = { updatedAt: Date.now() };
    // Write SA-canonical keys; clear legacy portal-only dollar keys if present.
    if (usageLimitMonthly !== '' && usageLimitMonthly !== undefined) {
      patch.usageLimitMonthly = parseInt(String(usageLimitMonthly), 10) || null;
    }
    if (usageLimitDaily !== '' && usageLimitDaily !== undefined) {
      patch.usageLimitDaily = parseInt(String(usageLimitDaily), 10) || null;
    }
    if (card.monthlyLimit !== undefined) patch.monthlyLimit = null;
    if (card.maxFarePerTrip !== undefined) patch.maxFarePerTrip = null;
    fbWrite('PATCH', 'tmCards/' + cardId, patch, (e: any) => {
      if (e) return res.redirect(`/council-portal/limits?t=${te}&msg=${encodeURIComponent('Error: ' + e)}&mt=err`);
      res.redirect(`/council-portal/limits?t=${te}&msg=${encodeURIComponent('Limits saved')}&mt=ok`);
    });
  });
});

router.post('/api/council-default-limits', (req, res) => {
  const { _token, defaultUsageLimitMonthly, defaultUsageLimitDaily } = req.body;
  const sess = cpGetSession(_token);
  if (!sess) return res.redirect('/council-portal?err=session');
  const te = encodeURIComponent(_token);
  fbRead('tmCards', (err: any, allCards: any) => {
    const cards = Object.entries(allCards || {})
      .filter(([, c]: [string, any]) => c.councilId === sess.councilId);
    if (cards.length === 0) return res.redirect(`/council-portal/limits?t=${te}&msg=${encodeURIComponent('No cards to update')}&mt=err`);
    let done = cards.length;
    cards.forEach(([id, c]: [string, any]) => {
      const patch: any = { updatedAt: Date.now() };
      if (defaultUsageLimitMonthly) patch.usageLimitMonthly = parseInt(String(defaultUsageLimitMonthly), 10) || null;
      if (defaultUsageLimitDaily) patch.usageLimitDaily = parseInt(String(defaultUsageLimitDaily), 10) || null;
      if (c && c.monthlyLimit !== undefined) patch.monthlyLimit = null;
      if (c && c.maxFarePerTrip !== undefined) patch.maxFarePerTrip = null;
      fbWrite('PATCH', 'tmCards/' + id, patch, () => { if (--done === 0) res.redirect(`/council-portal/limits?t=${te}&msg=${encodeURIComponent('Default limits applied to all cards')}&mt=ok`); });
    });
  });
});

export default router;
