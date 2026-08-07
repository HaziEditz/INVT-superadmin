import { Router, Request, Response, NextFunction } from 'express';
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

const router = Router();

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
#cp-trip-map{height:220px;border-radius:6px;margin-top:12px;z-index:1}
.cp-bdg-mismatch{background:#FFEBEE;color:#C62828;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.cp-edit-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px 12px;margin-top:10px}
.cp-edit-grid label{display:block;font-size:11px;color:#666;font-weight:600;margin-bottom:2px}
.cp-edit-grid input,.cp-edit-grid select,.cp-edit-grid textarea{width:100%;padding:6px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px}
.cp-ref-badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:#FFF8E1;color:#E65100;border:1px solid #FFE082}
`;

function renderNav(session: any, token: string, activePage: string): string {
  const te = encodeURIComponent(token);
  const pages: [string, string][] = [
    ['dashboard', '&#128202; Dashboard'],
    ['trips', '&#128661; Trips'],
    ['flagged', '&#128681; Pending Approval'],
    ['batches', '&#128196; Claim Batches'],
    ['cards', '&#127938; Cards'],
    ['limits', '&#128176; Trip Limits'],
    ['config', '&#9881; Config'],
    ['operators', '&#127970; Operators'],
    ['reports', '&#128203; Reports']
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
    flagged:          '<span class="cp-bdg-r">Flagged</span>'
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
            approvedBy: st.approvedBy, rejectedBy: st.rejectedBy, revisionNote: st.revisionNote, batchId: st.batchId
          });
        });
      });
      cb(null, result);
    }
  });
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

function councilReturnPath(returnTo: string, te: string): string {
  const page = returnTo === 'reports' ? 'reports' : 'flagged';
  return '/council-portal/' + page + '?t=' + te;
}

// ── Approve / reject / return individual trip ─────────────────────────────────
router.post('/api/council-approve', (req, res) => {
  const token = (req.body._token as string) || '';
  const tripCid = (req.body.tripCid as string) || '';
  const tripRawKey = (req.body.tripRawKey as string) || '';
  const action = (req.body.action as string) || '';
  const returnTo = String(req.body.returnTo || 'flagged').trim() === 'reports' ? 'reports' : 'flagged';
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
    if (action === 'approve') {
      patch = { status: 'approved', approvedAt: now, approvedBy: who };
      msg = 'Trip approved successfully.';
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
    } else {
      patch = {
        status: 'revision_needed',
        revisionNote: note,
        sentBackAt: now,
        sentBackBy: who,
      };
      msg = 'Trip returned to company for revision.';
    }
    fbWrite('PATCH', 'tmTripStatus/' + tripCid + '/' + tripRawKey, patch, (err: any) => {
      if (err) return res.redirect(base + '&msg=Update+failed&mt=err');
      res.redirect(base + '&msg=' + encodeURIComponent(msg) + '&mt=ok');
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
  const returnTo = String(req.body.returnTo || 'reports').trim() === 'flagged' ? 'flagged' : 'reports';
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
    const finish = () => {
      if (!resubmit) {
        return res.redirect(base + '&msg=' + encodeURIComponent('Trip fields updated.') + '&mt=ok');
      }
      fbWrite(
        'PATCH',
        'tmTripStatus/' + tripCid + '/' + tripRawKey,
        {
          status: 'submitted',
          resubmittedAt: Date.now(),
          resubmittedBy: sess.name || sess.councilId,
        },
        (e2: any) => {
          if (e2) return res.redirect(base + '&msg=Job+saved+but+status+update+failed&mt=err');
          res.redirect(base + '&msg=' + encodeURIComponent('Trip updated and marked submitted.') + '&mt=ok');
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
      const thisMonthTrips = myTrips.filter(t => (t.startedAt_ISO || '').slice(0, 7) === curMonth);
      let totalCouncilPays = 0, pendingCount = 0;
      thisMonthTrips.forEach(t => {
        totalCouncilPays += parseFloat(t.tmSubsidy || 0);
        if (t.status === 'submitted') pendingCount++;
      });
      const avg = thisMonthTrips.length ? (totalCouncilPays / thisMonthTrips.length).toFixed(2) : '0.00';
      const recent = [...myTrips].sort((a, b) => (b.startedAt_ISO || '').localeCompare(a.startedAt_ISO || '')).slice(0, 10);
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
  ${pendingCount > 0 ? `<div class="cp-stat flag"><div class="cp-stat-v">${pendingCount}</div><div class="cp-stat-l">Awaiting Your Approval</div></div>` : ''}
</div>
${configHtml}
<div class="cp-card">
  <div class="cp-card-hd"><h3>Recent TM activity (${recent.length})</h3>
    <a href="/council-portal/trips?t=${encodeURIComponent(token)}" style="font-size:12px;color:#2E7D32">View all &rarr;</a></div>
  ${recent.length ? `<table class="cp-tbl"><thead><tr><th>Voucher No.</th><th>Passenger</th><th>Operator</th><th>Date</th><th>Fare</th><th>Council Pays</th><th>Status</th></tr></thead>
<tbody>${recentRows}</tbody></table>` : '<div class="cp-empty">No trips submitted to this council yet.</div>'}
</div>`;
      res.send(portalPage('Dashboard', renderNav(sess, token, 'dashboard'), body));
      });
    });
  });
});

// ── Trips ──────────────────────────────────────────────────────────────────────
router.get('/council-portal/trips', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const filterMonth = (req.query.month as string) || '';
  const te = encodeURIComponent(token);
  loadCouncilTrips(sess.councilId, (err: any, myTrips: any[]) => {
    const months: Record<string, boolean> = {};
    myTrips.forEach(t => { if (t.startedAt_ISO) months[t.startedAt_ISO.slice(0, 7)] = true; });
    const sortedMonths = Object.keys(months).sort().reverse();
    let displayTrips = filterMonth ? myTrips.filter(t => (t.startedAt_ISO || '').slice(0, 7) === filterMonth) : myTrips;
    displayTrips.sort((a, b) => (b.startedAt_ISO || '').localeCompare(a.startedAt_ISO || ''));
    let totalFare = 0, totalCouncil = 0, totalPax = 0;
    displayTrips.forEach(t => {
      totalFare += parseFloat(t.fare || 0);
      totalCouncil += parseFloat(t.tmSubsidy || 0);
      totalPax += parseFloat(t.tmPassengerPays || 0);
    });
    const monthOpts = sortedMonths.map(m => `<option value="${esc(m)}" ${m === filterMonth ? 'selected' : ''}>${m}</option>`).join('');
    let totalMeterSub = 0, totalHoist = 0;
    displayTrips.forEach(t => {
      totalMeterSub += parseFloat(t.tmSubsidyFare || 0);
      totalHoist += parseFloat(t.tmSubsidyHoist || 0);
    });
    const rows = displayTrips.map(t => {
      const dt = t.startedAt_ISO ? t.startedAt_ISO.slice(0, 16).replace('T', ' ') : '—';
      const meterSub = parseFloat(t.tmSubsidyFare || 0);
      const hoistSub = parseFloat(t.tmSubsidyHoist || 0);
      return `<tr><td style="font-family:monospace;font-size:11px">${esc(t.tmVoucherNo || '—')}</td>
<td>${esc(t.tmPassengerName || '—')}</td>
<td style="font-size:12px;color:#555">${esc(t._companyName || '—')}</td>
<td>${esc(t.tmTripCategory || '—')}</td>
<td>${dt}</td>
<td>${esc(t.source || '—')}</td>
<td>$${parseFloat(t.fare || 0).toFixed(2)}</td>
<td style="color:#2E7D32">$${meterSub.toFixed(2)}</td>
<td style="color:#2E7D32">$${hoistSub.toFixed(2)}</td>
<td style="font-weight:700;color:#1B5E20">$${parseFloat(t.tmSubsidy || 0).toFixed(2)}</td>
<td>$${parseFloat(t.tmPassengerPays || 0).toFixed(2)}</td>
<td>${statusBadge(t.status)}</td></tr>`;
    }).join('');
    const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:16px">Trips</h2>
<p style="font-size:12.5px;color:#666;margin:-8px 0 14px">Council totals split into <strong>meter subsidy</strong> (% + cap) and <strong>hoist</strong> (100% council) — separate line items.</p>
<div class="cp-month-row">
  <form method="GET" action="/council-portal/trips" style="display:flex;gap:10px;align-items:center">
    <input type="hidden" name="t" value="${esc(token)}"/>
    <label>Month:</label>
    <select name="month"><option value="">All Months</option>${monthOpts}</select>
    <button type="submit" class="cp-btn cp-btn-g" style="padding:7px 14px">Filter</button>
    ${filterMonth ? `<a href="/council-portal/trips?t=${te}" class="cp-btn" style="background:#eee;color:#333">Clear</a>` : ''}
  </form>
  <span style="font-size:13px;color:#666">${displayTrips.length} trip(s)</span>
  <a href="/council-portal/export?t=${te}${filterMonth ? '&month=' + esc(filterMonth) : ''}" class="cp-btn cp-btn-g" style="margin-left:auto">&#11015; Download CSV</a>
</div>
<div class="cp-card" style="overflow-x:auto">
${displayTrips.length ? `<table class="cp-tbl">
<thead><tr><th>Voucher No.</th><th>Passenger</th><th>Operator</th><th>Category</th><th>Date</th><th>Pickup</th><th>Meter Fare</th><th>Meter Subsidy</th><th>Hoist (council)</th><th>Total Council</th><th>Pax Pays</th><th>Status</th></tr></thead>
<tbody>${rows}</tbody>
<tfoot><tr><td colspan="6" style="text-align:right">Totals:</td>
<td>$${totalFare.toFixed(2)}</td>
<td>$${totalMeterSub.toFixed(2)}</td>
<td>$${totalHoist.toFixed(2)}</td>
<td>$${totalCouncil.toFixed(2)}</td><td>$${totalPax.toFixed(2)}</td><td></td></tr></tfoot>
</table>` : '<div class="cp-empty">No trips found.</div>'}
</div>`;
    res.send(portalPage('Trips', renderNav(sess, token, 'trips'), body));
  });
});

// ── Flagged / Pending Approval ─────────────────────────────────────────────────
router.get('/council-portal/flagged', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const te = encodeURIComponent(token);
  loadCouncilTrips(sess.councilId, (err: any, myTrips: any[]) => {
    const pending = myTrips.filter(t => t.status === 'submitted');
    pending.sort((a, b) => (b.startedAt_ISO || '').localeCompare(a.startedAt_ISO || ''));
    const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(msg)}</div>` : '';
    const rows = pending.map(t => {
      const d = buildTmTripDetail(t);
      const dt = d.dateTime || '—';
      const submittedDt = t.submittedAt ? new Date(t.submittedAt).toLocaleString('en-NZ') : '—';
      return `<tr>
<td style="font-family:monospace;font-size:11px">${esc(d.voucherNo)}</td>
<td>${esc(d.passengerName)}</td>
<td style="font-size:12px;color:#555">${esc(d.companyName)}</td>
<td>${esc(d.tripCategory)}</td>
<td>${esc(dt)}</td>
<td>${esc(d.pickup)}</td>
<td>$${d.meterFare.toFixed(2)}</td>
<td style="font-weight:700;color:#2E7D32">$${d.totalCouncil.toFixed(2)}</td>
<td>$${d.passengerPays.toFixed(2)}</td>
<td style="font-size:11px;color:#888">${submittedDt}</td>
<td style="white-space:nowrap">
  <form method="POST" action="/api/council-approve" style="display:inline">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="approve"/>
    <input type="hidden" name="returnTo" value="flagged"/>
    <button type="submit" class="cp-btn cp-btn-g" style="margin-right:4px">&#10003; Approve</button>
  </form>
  <form method="POST" action="/api/council-approve" style="display:inline" onsubmit="return cpRejectTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="reject"/>
    <input type="hidden" name="returnTo" value="flagged"/>
    <input type="hidden" name="flagReason" value=""/>
    <input type="hidden" name="note" value=""/>
    <button type="submit" class="cp-btn cp-btn-r" style="margin-right:4px">&#10007; Reject</button>
  </form>
  <form method="POST" action="/api/council-approve" style="display:inline" onsubmit="return cpReturnTrip(this)">
    <input type="hidden" name="_token" value="${esc(token)}"/>
    <input type="hidden" name="tripCid" value="${esc(t._cid)}"/>
    <input type="hidden" name="tripRawKey" value="${esc(t._rawKey)}"/>
    <input type="hidden" name="action" value="return"/>
    <input type="hidden" name="returnTo" value="flagged"/>
    <input type="hidden" name="note" value=""/>
    <button type="submit" class="cp-btn" style="background:#E65100;color:#fff">&#8617; Return</button>
  </form>
</td></tr>`;
    }).join('');
    const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:16px">Pending Approval (${pending.length})</h2>
${noticeHtml}
<p style="font-size:13px;color:#666;margin-bottom:16px">These trips have been reviewed and submitted to your council by BookaWaka. Approve, reject (with reason), or return to the company for revision.</p>
<div class="cp-card" style="overflow-x:auto">
${pending.length ? `<table class="cp-tbl">
<thead><tr><th>Voucher No.</th><th>Passenger</th><th>Operator</th><th>Category</th><th>Date</th><th>Pickup</th><th>Fare</th><th>Council Pays</th><th>Pax Pays</th><th>Submitted</th><th>Action</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="cp-empty">No trips pending your approval. All clear!</div>'}
</div>
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
</script>`;
    res.send(portalPage('Pending Approval', renderNav(sess, token, 'flagged'), body));
  });
});

// ── Reports ────────────────────────────────────────────────────────────────────
function tripStartedMs(t: any): number {
  const iso = t.startedAt_ISO || t.startedAt || t.completedAt_ISO || '';
  const ms = Date.parse(iso);
  return Number.isFinite(ms) ? ms : 0;
}

function filterTripsForReports(
  trips: any[],
  opts: { companyId?: string; from?: string; to?: string },
): any[] {
  let rows = trips.slice();
  if (opts.companyId) rows = rows.filter((t) => String(t._cid) === opts.companyId);
  if (opts.from) {
    const fromMs = Date.parse(opts.from + 'T00:00:00');
    if (Number.isFinite(fromMs)) rows = rows.filter((t) => tripStartedMs(t) >= fromMs);
  }
  if (opts.to) {
    const toMs = Date.parse(opts.to + 'T23:59:59');
    if (Number.isFinite(toMs)) rows = rows.filter((t) => tripStartedMs(t) <= toMs);
  }
  rows.sort((a, b) => (b.startedAt_ISO || '').localeCompare(a.startedAt_ISO || ''));
  return rows;
}

function hasValidTripCoords(d: TmTripDetail): boolean {
  return (
    Number.isFinite(d.pickupLat) &&
    Number.isFinite(d.pickupLng) &&
    d.pickupLat !== 0 &&
    d.pickupLng !== 0
  );
}

/** Static trip detail body (map placeholder + fare/expected meter). Client adds Leaflet + actions. */
function tripDetailModalHtml(d: TmTripDetail): string {
  const money = (n: number) => '$' + n.toFixed(2);
  const row = (l: string, v: string) =>
    `<div><div style="font-size:11px;color:#888;font-weight:600;margin-bottom:2px">${l}</div><div style="font-size:13px;font-weight:500">${v}</div></div>`;
  const frow = (l: string, v: string, c = '#333') =>
    `<tr><td style="padding:3px 0;color:${c}">${l}</td><td style="text-align:right;color:${c}">${v}</td></tr>`;
  const showMap = hasValidTripCoords(d);
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
${showMap ? '<div id="cp-trip-map"></div>' : ''}
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
</div>`;
}

router.get('/council-portal/reports', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const filterCompany = String(req.query.company || '').trim();
  const filterFrom = String(req.query.from || '').trim();
  const filterTo = String(req.query.to || '').trim();
  const te = encodeURIComponent(token);
  loadCouncilTrips(sess.councilId, (err: any, myTrips: any[]) => {
    fbRead('tmCompanyAccess', (eAcc: any, allAccess: any) => {
      const approvedCids: string[] = [];
      const nameByCid: Record<string, string> = {};
      myTrips.forEach((t) => {
        if (t._cid) nameByCid[t._cid] = t._companyName || ('Operator ' + t._cid);
      });
      if (allAccess) {
        Object.entries(allAccess).forEach(([cid, councils]: [string, any]) => {
          if (councils && councils[sess.councilId] && councils[sess.councilId].approved) {
            approvedCids.push(cid);
            if (!nameByCid[cid]) nameByCid[cid] = 'Operator ' + cid;
          }
        });
      }
      // Resolve missing company names
      const needNames = approvedCids.filter(
        (c) => !nameByCid[c] || String(nameByCid[c]).startsWith('Operator '),
      );
      let pendingNames = needNames.length;
      const finish = () => {
        const displayTrips = filterTripsForReports(myTrips, {
          companyId: filterCompany || undefined,
          from: filterFrom || undefined,
          to: filterTo || undefined,
        });
        const tariffCids = Array.from(
          new Set(
            displayTrips
              .map((t) => String(t._cid || ''))
              .concat(approvedCids)
              .filter(Boolean),
          ),
        );
        const tariffByCid: Record<string, any> = {};
        let pendingTariffs = tariffCids.length;
        const renderReports = () => {
          const details = displayTrips.map((t) =>
            buildTmTripDetail(t, { refTariff: (tariffByCid[t._cid] || {}).car || null }),
          );
          let totTrips = details.length,
            totFare = 0,
            totCouncil = 0,
            totPax = 0;
          details.forEach((d) => {
            totFare += d.meterFare;
            totCouncil += d.totalCouncil;
            totPax += d.passengerPays;
          });
          const companyOpts = approvedCids
            .concat(Object.keys(nameByCid).filter((c) => approvedCids.indexOf(c) === -1))
            .filter((c, i, a) => a.indexOf(c) === i)
            .sort((a, b) => (nameByCid[a] || a).localeCompare(nameByCid[b] || b))
            .map(
              (cid) =>
                `<option value="${esc(cid)}" ${cid === filterCompany ? 'selected' : ''}>${esc(nameByCid[cid] || cid)}</option>`,
            )
            .join('');
          const exportQs =
            `&company=${encodeURIComponent(filterCompany)}` +
            `&from=${encodeURIComponent(filterFrom)}` +
            `&to=${encodeURIComponent(filterTo)}`;
          const summaryRows = details
            .map((d, idx) => {
              const mismatchMark = d.fareMismatch
                ? ' <span class="cp-bdg-mismatch" title="Fare mismatch vs reference">!</span>'
                : '';
              return `<tr class="cp-row-click" data-idx="${idx}" onclick="openRptDetail(${idx})">
<td>${esc(d.dateTime)}</td>
<td>${esc(d.companyName)}</td>
<td>${esc(d.passengerName)}</td>
<td style="font-family:monospace;font-size:11px">${esc(d.voucherNo)}</td>
<td>${esc(d.pickup)}</td>
<td>${esc(d.dropoff)}</td>
<td>$${d.meterFare.toFixed(2)}${mismatchMark}</td>
<td style="font-weight:700;color:#1B5E20">$${d.totalCouncil.toFixed(2)}</td>
<td>$${d.passengerPays.toFixed(2)}</td>
<td>${statusBadge(d.status)}</td>
<td><button type="button" class="cp-btn-sm" onclick="event.stopPropagation();openRptDetail(${idx})">Details</button></td>
</tr>`;
            })
            .join('');
          const bodyHtmlByIdx = details.map((d) => tripDetailModalHtml(d));
          const tripsJson = JSON.stringify(details).replace(/</g, '\\u003c');
          const bodiesJson = JSON.stringify(bodyHtmlByIdx).replace(/</g, '\\u003c');
          const msg = (req.query.msg as string) || '';
          const mt = (req.query.mt as string) || '';
          const noticeHtml = msg
            ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(msg)}</div>`
            : '';
          const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:6px">Reports</h2>
${noticeHtml}
<p style="font-size:13px;color:#666;margin-bottom:14px">Filter by company and date range. Click a row for full trip detail, map, fare check, and council actions.</p>
<div class="cp-month-row">
  <form method="GET" action="/council-portal/reports" style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap">
    <input type="hidden" name="t" value="${esc(token)}"/>
    <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">Company</label>
      <select name="company" class="cp-input"><option value="">All Companies</option>${companyOpts}</select></div>
    <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">From</label>
      <input type="date" name="from" class="cp-input" value="${esc(filterFrom)}"/></div>
    <div><label style="display:block;font-size:11px;color:#666;margin-bottom:3px">To</label>
      <input type="date" name="to" class="cp-input" value="${esc(filterTo)}"/></div>
    <button type="submit" class="cp-btn cp-btn-g">Apply</button>
    ${filterCompany || filterFrom || filterTo ? `<a href="/council-portal/reports?t=${te}" class="cp-btn" style="background:#eee;color:#333">Clear</a>` : ''}
  </form>
  <a href="/council-portal/export?t=${te}${exportQs}" class="cp-btn cp-btn-g" style="margin-left:auto">&#11015; Download full CSV</a>
</div>
<div class="cp-stats">
  <div class="cp-stat"><div class="cp-stat-v">${totTrips}</div><div class="cp-stat-l">Trips in selection</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totFare.toFixed(2)}</div><div class="cp-stat-l">Total Meter Fare</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totCouncil.toFixed(2)}</div><div class="cp-stat-l">Total Council Claim</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totPax.toFixed(2)}</div><div class="cp-stat-l">Total Passenger Pays</div></div>
</div>
<div class="cp-card" style="overflow-x:auto">
  <div class="cp-card-hd"><h3>Trip summary</h3>
    <span style="font-size:12px;color:#888">${details.length} trip(s) — click for full detail</span></div>
  ${details.length ? `<table class="cp-tbl">
<thead><tr><th>Date</th><th>Operator</th><th>Passenger</th><th>Voucher</th><th>Pickup</th><th>Dropoff</th><th>Meter</th><th>Council</th><th>Pax Pays</th><th>Status</th><th></th></tr></thead>
<tbody>${summaryRows}</tbody></table>` : '<div class="cp-empty">No trips for this selection.</div>'}
</div>
<div class="cp-ov" id="rpt-ov" onclick="if(event.target===this)closeRptDetail()">
  <div class="cp-modal" onclick="event.stopPropagation()">
    <div class="cp-modal-hd"><h3 id="rpt-dtitle">Trip detail</h3>
      <button type="button" onclick="closeRptDetail()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
    <div class="cp-modal-bd" id="rpt-detail-body"></div>
    <div class="cp-modal-ft" id="rpt-detail-ft" style="flex-wrap:wrap;justify-content:space-between;align-items:flex-start">
      <div id="rpt-actions" style="flex:1;display:flex;flex-wrap:wrap;gap:8px;align-items:flex-start"></div>
      <button type="button" class="cp-btn" style="background:#eee;color:#333" onclick="closeRptDetail()">Close</button>
    </div>
  </div>
</div>
<script>
var _rptTrips = ${tripsJson};
var _rptBodies = ${bodiesJson};
var _rptToken = ${JSON.stringify(token)};
var _rptMap = null;
var _ACTIONABLE = {submitted:1,company_approved:1,flagged:1,pending:1};
function _escAttr(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;'); }
function _fld(name,label,val,full){
  return '<div'+(full?' style="grid-column:1/-1"':'')+'><label>'+label+'</label><input class="cp-input" name="'+name+'" value="'+_escAttr(val)+'"/></div>';
}
function buildEditPanel(d){
  var html = '<details style="margin-top:14px;border:1px solid #FFE082;border-radius:6px;padding:10px 12px;background:#FFFDE7" '+(d.status==='revision_needed'?'open':'')+'>';
  html += '<summary style="cursor:pointer;font-weight:700;color:#E65100">Edit all fields</summary>';
  html += '<form method="POST" action="/api/council-trip-edit" style="margin-top:10px">';
  html += '<input type="hidden" name="_token" value="'+_escAttr(_rptToken)+'"/>';
  html += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
  html += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
  html += '<input type="hidden" name="returnTo" value="reports"/>';
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
}
function buildActionForms(d){
  if(!_ACTIONABLE[d.status] && d.status!=='revision_needed') return '';
  if(!_ACTIONABLE[d.status]) return '';
  var h = '<div style="display:flex;flex-wrap:wrap;gap:8px;align-items:flex-start;width:100%">';
  h += '<form method="POST" action="/api/council-approve">';
  h += '<input type="hidden" name="_token" value="'+_escAttr(_rptToken)+'"/>';
  h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
  h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
  h += '<input type="hidden" name="action" value="approve"/>';
  h += '<input type="hidden" name="returnTo" value="reports"/>';
  h += '<button type="submit" class="cp-btn cp-btn-g">&#10003; Approve</button></form>';
  h += '<form method="POST" action="/api/council-approve" style="display:flex;flex-wrap:wrap;gap:6px;align-items:center;padding:8px;border:1px solid #FFCDD2;border-radius:6px;background:#FFEBEE" onsubmit="return !!this.note.value.trim()||(alert(&#39;Reject note required&#39;),false)">';
  h += '<input type="hidden" name="_token" value="'+_escAttr(_rptToken)+'"/>';
  h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
  h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
  h += '<input type="hidden" name="action" value="reject"/>';
  h += '<input type="hidden" name="returnTo" value="reports"/>';
  h += '<select name="flagReason" class="cp-input" style="width:auto">';
  h += '<option value="fare_mismatch">fare_mismatch</option>';
  h += '<option value="waiting_charged">waiting_charged</option>';
  h += '<option value="hoist_rate_mismatch">hoist_rate_mismatch</option>';
  h += '<option value="other">other</option></select>';
  h += '<input name="note" class="cp-input" placeholder="Reject note (required)" style="min-width:160px" required/>';
  h += '<button type="submit" class="cp-btn cp-btn-r">&#10007; Reject / Red-flag</button></form>';
  h += '<form method="POST" action="/api/council-approve" style="display:flex;flex-wrap:wrap;gap:6px;align-items:center;padding:8px;border:1px solid #FFE082;border-radius:6px;background:#FFF8E1" onsubmit="return !!this.note.value.trim()||(alert(&#39;Revision note required&#39;),false)">';
  h += '<input type="hidden" name="_token" value="'+_escAttr(_rptToken)+'"/>';
  h += '<input type="hidden" name="tripCid" value="'+_escAttr(d.cid)+'"/>';
  h += '<input type="hidden" name="tripRawKey" value="'+_escAttr(d.rawKey)+'"/>';
  h += '<input type="hidden" name="action" value="return"/>';
  h += '<input type="hidden" name="returnTo" value="reports"/>';
  h += '<input name="note" class="cp-input" placeholder="Revision note (required)" style="min-width:160px" required/>';
  h += '<button type="submit" class="cp-btn" style="background:#E65100;color:#fff">&#8617; Return to company</button></form>';
  h += '</div>';
  return h;
}
function initRptMap(d){
  if(_rptMap){ try{_rptMap.remove();}catch(e){} _rptMap=null; }
  var el = document.getElementById('cp-trip-map');
  if(!el || typeof L==='undefined') return;
  var plat = Number(d.pickupLat), plng = Number(d.pickupLng);
  var dlat = Number(d.dropLat), dlng = Number(d.dropLng);
  if(!plat && !plng) return;
  _rptMap = L.map(el).setView([plat, plng], 13);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19, attribution: '&copy; OpenStreetMap'
  }).addTo(_rptMap);
  var bounds = [];
  var m1 = L.marker([plat, plng]).addTo(_rptMap).bindPopup('Pickup');
  bounds.push([plat, plng]);
  if(dlat && dlng){
    L.marker([dlat, dlng]).addTo(_rptMap).bindPopup('Dropoff');
    bounds.push([dlat, dlng]);
    L.polyline([[plat,plng],[dlat,dlng]], {color:'#1B5E20',weight:3}).addTo(_rptMap);
  }
  if(bounds.length>1) _rptMap.fitBounds(bounds, {padding:[24,24]});
  setTimeout(function(){ if(_rptMap) _rptMap.invalidateSize(); }, 120);
}
function openRptDetail(i){
  var d = _rptTrips[i], html = _rptBodies[i];
  if(!d || !html) return;
  document.getElementById('rpt-detail-body').innerHTML = html + buildEditPanel(d);
  document.getElementById('rpt-dtitle').textContent = 'Trip detail — ' + (d.id || '');
  document.getElementById('rpt-actions').innerHTML = buildActionForms(d);
  document.getElementById('rpt-ov').classList.add('open');
  initRptMap(d);
}
function closeRptDetail(){
  document.getElementById('rpt-ov').classList.remove('open');
  if(_rptMap){ try{_rptMap.remove();}catch(e){} _rptMap=null; }
}
</script>`;
          res.send(portalPage('Reports', renderNav(sess, token, 'reports'), body));
        };
        if (pendingTariffs === 0) return renderReports();
        tariffCids.forEach((cid) => {
          fbRead('tmTariffs/' + cid, (eT: any, tar: any) => {
            tariffByCid[cid] = tar || {};
            if (--pendingTariffs <= 0) renderReports();
          });
        });
      };
      if (pendingNames === 0) return finish();
      needNames.forEach((cid) => {
        fbRead('superClients/' + cid, (eN: any, sc: any) => {
          if (sc && sc.name) nameByCid[cid] = sc.name;
          if (--pendingNames <= 0) finish();
        });
      });
    });
  });
});

// ── Claim Batches ──────────────────────────────────────────────────────────────
router.get('/council-portal/batches', requirePortalAuth, (req, res) => {
  const sess = (req as any).cpSession;
  const token = (req as any).cpToken;
  const te = encodeURIComponent(token);
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const noticeHtml = msg ? `<div class="cp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(msg)}</div>` : '';
  fbRead('tmBatches/' + sess.councilId, (err: any, batchData: any) => {
    const emptyBody = `<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:16px">Claim Batches</h2>
${noticeHtml}<div class="cp-card"><div class="cp-empty">No batches found.</div></div>`;
    if (err || !batchData) return res.send(portalPage('Claim Batches', renderNav(sess, token, 'batches'), emptyBody));
    const cidKeys = Object.keys(batchData);
    if (cidKeys.length === 0) return res.send(portalPage('Claim Batches', renderNav(sess, token, 'batches'), emptyBody));
    let pending2 = cidKeys.length;
    const namesMap: Record<string, string> = {};
    cidKeys.forEach(cid => {
      fbRead('superClients/' + cid, (e2: any, sc: any) => {
        namesMap[cid] = (sc && sc.name) ? sc.name : ('Operator ' + cid);
        if (--pending2 === 0) buildBatchPage();
      });
    });
    function buildBatchPage() {
      const allBatches: any[] = [];
      cidKeys.forEach(cid => {
        const months = batchData[cid] || {};
        Object.entries(months).forEach(([ym, b]: [string, any]) => {
          if (!b) return;
          allBatches.push({ _cid: cid, _cname: namesMap[cid], _ym: ym, ...b });
        });
      });
      allBatches.sort((a, b) => (b._ym + b._cid).localeCompare(a._ym + a._cid));
      const batchStatusBadge = (s: string) => {
        const m: Record<string, string> = {
          draft: '<span style="background:#F5F5F5;color:#757575;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Draft</span>',
          submitted: '<span style="background:#E3F2FD;color:#1565C0;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Submitted</span>',
          approved: '<span style="background:#E8F5E9;color:#2E7D32;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Approved</span>',
          rejected: '<span style="background:#FFEBEE;color:#C62828;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600">Rejected</span>',
          paid: '<span style="background:#E8F5E9;color:#1B5E20;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;border:1px solid #A5D6A7">&#10003; Paid</span>'
        };
        return m[s] || `<span style="background:#F5F5F5;color:#757575;padding:2px 8px;border-radius:10px;font-size:11px">${esc(s)}</span>`;
      };
      const rows = allBatches.map(b => {
        const subDt = b.submittedAt ? new Date(b.submittedAt).toLocaleDateString('en-NZ') : '—';
        const appDt = b.approvedAt ? new Date(b.approvedAt).toLocaleDateString('en-NZ') : '—';
        const paidDt = b.paidAt ? new Date(b.paidAt).toLocaleDateString('en-NZ') : '—';
        const actionBtns = b.status === 'submitted' ? `
<form method="POST" action="/api/council-batch-action" style="display:inline">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="cid" value="${esc(b._cid)}"/>
  <input type="hidden" name="ym" value="${esc(b._ym)}"/>
  <input type="hidden" name="action" value="approve"/>
  <button type="submit" class="cp-btn cp-btn-g" style="margin-right:4px">&#10003; Approve All</button>
</form>
<form method="POST" action="/api/council-batch-action" style="display:inline" onsubmit="return confirm('Reject this batch?')">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="cid" value="${esc(b._cid)}"/>
  <input type="hidden" name="ym" value="${esc(b._ym)}"/>
  <input type="hidden" name="action" value="reject"/>
  <button type="submit" class="cp-btn cp-btn-r">&#10007; Reject</button>
</form>` : b.status === 'approved' ? `
<form method="POST" action="/api/council-batch-action" style="display:inline">
  <input type="hidden" name="_token" value="${esc(token)}"/>
  <input type="hidden" name="cid" value="${esc(b._cid)}"/>
  <input type="hidden" name="ym" value="${esc(b._ym)}"/>
  <input type="hidden" name="action" value="paid"/>
  <input type="text" name="payRef" placeholder="Payment ref (optional)" style="padding:4px 8px;border:1px solid #ccc;border-radius:4px;font-size:12px;width:150px;margin-right:4px"/>
  <button type="submit" class="cp-btn cp-btn-g">&#128181; Mark Paid</button>
</form>` : b.status === 'paid' ? `<span style="font-size:12px;color:#555">${esc(b.payRef || '')}${b.payRef ? '<br>' : ''}<span style="color:#888;font-size:11px">Paid ${paidDt}</span></span>` : '—';
        return `<tr>
<td style="font-weight:600">${esc(b._cname)}</td>
<td style="font-family:monospace">${esc(b._ym)}</td>
<td style="text-align:right">${b.totalTrips || 0}</td>
<td style="text-align:right;font-weight:700;color:#2E7D32">$${parseFloat(b.totalSubsidy || 0).toFixed(2)}</td>
<td>${batchStatusBadge(b.status)}</td>
<td style="font-size:12px;color:#666">${subDt}</td>
<td style="font-size:12px;color:#666">${appDt}</td>
<td style="white-space:nowrap">${actionBtns}</td>
</tr>`;
      }).join('');
      const submitted = allBatches.filter(b => b.status === 'submitted');
      const approved = allBatches.filter(b => b.status === 'approved');
      const totalPending = submitted.reduce((s, b) => s + parseFloat(b.totalSubsidy || 0), 0);
      const totalApproved = approved.reduce((s, b) => s + parseFloat(b.totalSubsidy || 0), 0);
      const body = `
<h2 style="font-size:18px;font-weight:700;color:#1B5E20;margin-bottom:16px">Claim Batches</h2>
${noticeHtml}
<div class="cp-stats" style="margin-bottom:18px">
  <div class="cp-stat"><div class="cp-stat-v">${submitted.length}</div><div class="cp-stat-l">Awaiting Your Approval</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totalPending.toFixed(2)}</div><div class="cp-stat-l">Pending Claim Value</div></div>
  <div class="cp-stat"><div class="cp-stat-v">${approved.length}</div><div class="cp-stat-l">Approved (unpaid)</div></div>
  <div class="cp-stat"><div class="cp-stat-v">$${totalApproved.toFixed(2)}</div><div class="cp-stat-l">Approved Claim Value</div></div>
</div>
<div class="cp-card" style="overflow-x:auto">
<p style="font-size:13px;color:#666;padding:12px 16px 0">Batches are submitted monthly by each taxi operator. Approve a batch to confirm all trips in it. Once approved, mark it paid when your payment is processed.</p>
${allBatches.length ? `<table class="cp-tbl" style="margin-top:8px">
<thead><tr><th>Operator</th><th>Month</th><th style="text-align:right">Trips</th><th style="text-align:right">Council Claim</th><th>Status</th><th>Submitted</th><th>Approved</th><th>Action</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="cp-empty">No batches yet.</div>'}
</div>`;
      res.send(portalPage('Claim Batches', renderNav(sess, token, 'batches'), body));
    }
  });
});

router.post('/api/council-batch-action', (req, res) => {
  const token = (req.body._token as string) || '';
  const cid = (req.body.cid as string) || '';
  const ym = (req.body.ym as string) || '';
  const action = (req.body.action as string) || '';
  const payRef = ((req.body.payRef as string) || '').trim();
  const sess = cpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !cid || !ym || !['approve', 'reject', 'paid'].includes(action)) {
    return res.redirect('/council-portal/batches?t=' + te + '&msg=Invalid+request&mt=err');
  }
  const path = 'tmBatches/' + sess.councilId + '/' + cid + '/' + ym;
  let patch: any;
  if (action === 'approve') {
    patch = { status: 'approved', approvedAt: Date.now(), approvedBy: sess.name || sess.councilId };
  } else if (action === 'reject') {
    patch = { status: 'rejected', rejectedAt: Date.now(), rejectedBy: sess.name || sess.councilId };
  } else {
    patch = { status: 'paid', paidAt: Date.now(), paidBy: sess.name || sess.councilId };
    if (payRef) patch.payRef = payRef;
  }
  fbWrite('PATCH', path, patch, (err: any) => {
    if (err) return res.redirect('/council-portal/batches?t=' + te + '&msg=Update+failed&mt=err');
    const msgs: Record<string, string> = { approve: 'Batch approved.', reject: 'Batch rejected.', paid: 'Batch marked as paid.' };
    res.redirect('/council-portal/batches?t=' + te + '&msg=' + encodeURIComponent(msgs[action]) + '&mt=ok');
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
      const sections = approvedCids.map(cid => {
        const sc = clientMap[cid] || {};
        const tar = tariffMap[cid] || {};
        const tmCfg = tmConfigMap[cid] || {};
        const syncProv = classifyTmConfig(tmCfg);
        const drivers = listDriversForCompany(driversRoot, cid, { activeOnly: true });
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
          const name = [d.firstName, d.lastName].filter(Boolean).join(' ') || String(d.name || '—');
          const veh = resolveDriverVehicle(vehiclesRoot, cid, d as Record<string, unknown>);
          const plate = veh.registration || '—';
          const cab = veh.taxiNumber || '—';
          const vehLabel = veh.label || '—';
          const vtype = veh.vehicleType || String(d.vehicleType || '—');
          const accessible = isDriverWav(d) ? '<span style="background:#E8F5E9;color:#2E7D32;padding:1px 6px;border-radius:8px;font-size:11px;font-weight:600">♿ WAV</span>' : '';
          return `<tr>
<td style="font-weight:500">${esc(name)}</td>
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
  // Legacy month=YYYY-MM still supported
  const filterMonth = String(req.query.month || '').trim();
  loadCouncilTrips(sess.councilId, (err: any, trips: any[]) => {
    let filtered = filterTripsForReports(trips, {
      companyId: filterCompany || undefined,
      from: filterFrom || undefined,
      to: filterTo || undefined,
    });
    if (filterMonth && !filterFrom && !filterTo) {
      filtered = trips
        .filter((t) => (t.startedAt_ISO || '').slice(0, 7) === filterMonth)
        .filter((t) => !filterCompany || String(t._cid) === filterCompany)
        .sort((a, b) => (a.startedAt_ISO || '').localeCompare(b.startedAt_ISO || ''));
    } else {
      filtered.sort((a, b) => (a.startedAt_ISO || '').localeCompare(b.startedAt_ISO || ''));
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
      // Canonical SA fields: usageLimitMonthly / usageLimitDaily (trip counts).
      // Fall back to legacy portal keys if present on older writes.
      const monthlyTrips = c.usageLimitMonthly ?? c.monthlyLimit;
      const dailyTrips = c.usageLimitDaily ?? c.maxFarePerTrip;
      const limit = monthlyTrips != null && monthlyTrips !== ''
        ? `${parseInt(String(monthlyTrips), 10) || 0}/mo`
        : '—';
      const daily = dailyTrips != null && dailyTrips !== ''
        ? `${parseInt(String(dailyTrips), 10) || 0}/day`
        : '—';
      return `<tr>
<td>${esc(id)}</td>
<td>${esc(c.passengerName || '—')}</td>
<td>${esc(c.passengerPhone || '—')}</td>
<td style="font-weight:600;color:#1B5E20">$${balance}</td>
<td>${limit}</td>
<td>${daily}</td>
<td><span class="${active ? 'cp-bdg-g' : 'cp-bdg-r'}">${active ? 'Active' : 'Inactive'}</span></td>
<td>
<form method="POST" action="/api/council-card-toggle" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="cardId" value="${esc(id)}"/>
<input type="hidden" name="active" value="${active ? 'false' : 'true'}"/>
<button type="submit" class="${active ? 'cp-tog-on' : 'cp-tog-off'}">${active ? 'Deactivate' : 'Activate'}</button>
</form>
</td></tr>`;
    }).join('');
    const body = `<div class="cp-main">
${noticeHtml}
<div class="cp-card">
<div class="cp-card-hd"><h3>&#127938; TM Cards (${esc(sess.name || sess.councilId)})</h3>
<span style="font-size:12px;color:#888">${cards.length} card(s)</span></div>
${cards.length ? `<table class="cp-tbl"><thead><tr><th>Card No</th><th>Passenger</th><th>Phone</th><th>Balance</th><th>Monthly Trips</th><th>Daily Trips</th><th>Status</th><th>Action</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="cp-empty">No cards found for this council.</div>'}
</div></div>`;
    res.send(portalPage('Cards', renderNav(sess, token, 'cards'), body));
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
