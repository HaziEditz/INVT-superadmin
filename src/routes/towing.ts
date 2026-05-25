import { Router } from 'express';
import { fbReadP, fbWriteP } from '../firebase';
import { esc, getResendClient, getStripe, twHash } from '../utils';
import { towingSessions, persistSessionDirect, unpersistSessionDirect } from '../sessions';
import crypto from 'crypto';

const router = Router();

// ── Session management (backed by Firebase via persistSessionDirect) ─────────
const TW_TTL = 24 * 60 * 60 * 1000;

function twMakeToken() { return crypto.randomBytes(32).toString('hex'); }
function twSetSession(companyId: string, name: string, email: string) {
  const t = twMakeToken();
  const sess = { companyId, name, email, exp: Date.now() + TW_TTL };
  towingSessions[t] = sess;
  persistSessionDirect('towing', t, sess);
  return t;
}
function twGetSession(token: string) {
  if (!token) return null;
  const s = towingSessions[token];
  if (!s) return null;
  if (Date.now() > s.exp) { delete towingSessions[token]; unpersistSessionDirect('towing', token); return null; }
  return s;
}
function requireTowingAuth(req: any, res: any, next: any) {
  const token = req.query.t || '';
  const session = twGetSession(token);
  if (!session) return res.redirect('/towing-portal?err=session');
  req.twSession = session; req.twToken = token; next();
}
// ── CSS & helpers ──────────────────────────────────────────────────────────────
const TW_CSS = `
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#FFF8F5;color:#333;font-size:14px;min-height:100vh}
a{color:inherit;text-decoration:none}
.tw-nav{background:#E65100;color:#fff;height:52px;padding:0 24px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100;box-shadow:0 2px 8px rgba(0,0,0,.3)}
.tw-nav-brand{font-size:15px;font-weight:700;display:flex;align-items:center;gap:6px}
.tw-nav-links{display:flex}
.tw-nav-links a{color:rgba(255,255,255,.8);padding:17px 11px;font-size:12.5px;display:flex;align-items:center;gap:4px;border-bottom:3px solid transparent;transition:all .15s}
.tw-nav-links a:hover{background:rgba(255,255,255,.12);color:#fff}
.tw-nav-links a.on{color:#fff;border-bottom-color:#FFCCBC;background:rgba(255,255,255,.1)}
.tw-nav-right{font-size:12px;opacity:.8;display:flex;align-items:center;gap:14px}
.tw-main{padding:22px 24px;max-width:1280px;margin:0 auto}
.tw-card{background:#fff;border-radius:6px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:18px;overflow:hidden}
.tw-card-hd{padding:13px 18px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.tw-card-hd h3{font-size:14px;font-weight:700;color:#E65100;display:flex;align-items:center;gap:6px}
.tw-card-bd{padding:16px 18px}
.tw-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;margin-bottom:18px}
.tw-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #E65100}
.tw-stat.blue{border-left-color:#1565C0}.tw-stat.green{border-left-color:#2E7D32}.tw-stat.purple{border-left-color:#6A1B9A}.tw-stat.teal{border-left-color:#00695C}
.tw-stat-v{font-size:26px;font-weight:700;color:#E65100;line-height:1.1}
.tw-stat.blue .tw-stat-v{color:#1565C0}.tw-stat.green .tw-stat-v{color:#2E7D32}.tw-stat.purple .tw-stat-v{color:#6A1B9A}.tw-stat.teal .tw-stat-v{color:#00695C}
.tw-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.tw-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.tw-tbl th{background:#FFF3E0;padding:9px 11px;text-align:left;font-size:11.5px;font-weight:700;color:#BF360C;border-bottom:2px solid #FFCCBC;white-space:nowrap}
.tw-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.tw-tbl tr:last-child td{border-bottom:none}
.tw-tbl tr:hover td{background:#FFF8F5}
.tw-empty{text-align:center;color:#aaa;padding:24px;font-style:italic}
.tw-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:12.5px;font-weight:600;text-decoration:none}
.tw-btn-p{background:#E65100;color:#fff}.tw-btn-p:hover{background:#BF360C}
.tw-btn-g{background:#2E7D32;color:#fff}.tw-btn-g:hover{background:#1B5E20}
.tw-btn-r{background:#C62828;color:#fff}.tw-btn-r:hover{background:#B71C1C}
.tw-btn-b{background:#1565C0;color:#fff}.tw-btn-b:hover{background:#0D47A1}
.tw-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.tw-notice{padding:12px 16px;border-radius:6px;margin-bottom:16px;font-size:13px}
.tw-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.tw-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.tw-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.tw-ff label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:4px}
.tw-ff input,.tw-ff select,.tw-ff textarea{width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:5px;font-size:13px;box-sizing:border-box;font-family:inherit}
.tw-ff input:focus,.tw-ff select:focus{outline:none;border-color:#E65100}
.tw-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px}
.tw-grid-2{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.tw-grid-3{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:12px}
.tw-bdg-y{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:#FFF8E1;color:#F57F17}
.tw-bdg-b{background:#E3F2FD;color:#1565C0;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.tw-bdg-g{background:#E8F5E9;color:#2E7D32;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.tw-bdg-o{background:#FFF3E0;color:#E65100;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.tw-bdg-r{background:#FFEBEE;color:#C62828;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.tw-bdg-gr{background:#F5F5F5;color:#757575;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.tw-section-hdr{padding:11px 18px;font-size:12.5px;font-weight:700;color:#E65100;background:#FFF3E0;border-bottom:1px solid #FFCCBC}
.tw-filter{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:14px}
.tw-filter select,.tw-filter input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.truck-card{border:1.5px solid #f0f0f0;border-radius:6px;padding:14px;display:flex;flex-direction:column;gap:10px}
.truck-card:hover{border-color:#FFCCBC;background:#FFFBF9}
.truck-card-hd{display:flex;justify-content:space-between;align-items:flex-start}
.truck-name{font-weight:700;font-size:13.5px;color:#263238}
.truck-sub{font-size:11.5px;color:#888;margin-top:3px}
.driver-row{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid #f5f5f5}
.driver-row:last-child{border-bottom:none}
.driver-av{width:38px;height:38px;border-radius:50%;background:#E65100;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:14px;flex-shrink:0}
.modal-backdrop{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:200;align-items:center;justify-content:center}
.modal-backdrop.open{display:flex}
.modal-box{background:#fff;border-radius:8px;width:520px;max-width:96vw;max-height:90vh;overflow-y:auto;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.modal-hd{padding:16px 20px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between}
.modal-hd h4{font-size:15px;font-weight:700;color:#E65100;margin:0}
.modal-bd{padding:20px}
.modal-ft{padding:14px 20px;border-top:1px solid #f0f0f0;display:flex;justify-content:flex-end;gap:10px}
@media(max-width:680px){.tw-nav-links a{padding:17px 7px;font-size:11.5px}.tw-grid-2{grid-template-columns:1fr}}
`;

function renderTwNav(session: any, token: string, activePage: string) {
  const te = encodeURIComponent(token);
  const pages: [string, string][] = [
    ['dashboard', '&#127968; Dashboard'],
    ['jobs',      '&#128222; Jobs'],
    ['fleet',     '&#128667; Fleet'],
    ['drivers',   '&#128104;&#8205;&#128296; Drivers'],
    ['invoice',   '&#128203; Invoice'],
    ['config',    '&#9881; Settings']
  ];
  const links = pages.map(([pg, lbl]) =>
    `<a href="/towing-portal/${pg}?t=${te}" class="${activePage===pg?'on':''}">${lbl}</a>`
  ).join('');
  return `<nav class="tw-nav">
  <div class="tw-nav-brand">&#128667; <span>${esc(session.name||'Towing Portal')}</span></div>
  <div class="tw-nav-links">${links}</div>
  <div class="tw-nav-right">
    <span style="opacity:.7">${esc(session.email||'')}</span>
    <a href="/api/towing-logout?t=${te}" style="color:#FFCCBC">Sign Out</a>
  </div>
</nav>`;
}

function twPage(title: string, nav: string, body: string) {
  return `<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} &mdash; Towing Portal</title>
<style>${TW_CSS}</style></head>
<body>${nav}<div class="tw-main">${body}</div></body></html>`;
}

function twStatusBadge(s: string) {
  const m: any = {
    pending:   '<span class="tw-bdg-o">Pending</span>',
    assigned:  '<span class="tw-bdg-b">Assigned</span>',
    enroute:   '<span style="background:#F3E5F5;color:#6A1B9A;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700">En Route</span>',
    arrived:   '<span class="tw-bdg-b">Arrived</span>',
    loading:   '<span class="tw-bdg-y">Loading</span>',
    dropoff:   '<span class="tw-bdg-y">To Drop-off</span>',
    completed: '<span class="tw-bdg-g">&#10003; Completed</span>',
    cancelled: '<span class="tw-bdg-r">&#10007; Cancelled</span>'
  };
  return m[s||'pending'] || `<span class="tw-bdg-gr">${esc(s||'—')}</span>`;
}

function twPayBadge(p: string) {
  const m: any = {
    stripe:     '<span class="tw-bdg-g">&#128179; Stripe</span>',
    insurance:  '<span class="tw-bdg-b">&#127962; Insurance</span>',
    thirdparty: '<span class="tw-bdg-o">3rd Party Ins.</span>',
    cash:       '<span style="background:#F3E5F5;color:#6A1B9A;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700">&#128181; Cash</span>'
  };
  return m[p||''] || `<span class="tw-bdg-gr">${esc(p||'—')}</span>`;
}

// ── Login page ─────────────────────────────────────────────────────────────────
router.get('/towing-portal', (req, res) => {
  const err = (req.query.err as string) || '';
  const cid = (req.query.cid as string) || '';
  const errMsgs: any = {
    invalid:'Invalid email or password.',
    missing:'Please enter your email and password.',
    nodata:'No towing portal access found for this account.',
    session:'Your session has expired. Please sign in again.',
    inactive:'This account has been deactivated. Contact BookaWaka support.'
  };
  const errHtml = err ? `<div style="background:#FFEBEE;color:#C62828;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px;border-left:4px solid #C62828">${esc(errMsgs[err]||'Sign in error.')}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Towing Portal &mdash; BookaWaka</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:linear-gradient(135deg,#BF360C,#E65100);min-height:100vh;display:flex;align-items:center;justify-content:center;font-family:'Segoe UI',system-ui,sans-serif}
.box{background:#fff;border-radius:10px;padding:40px;width:420px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.box h1{font-size:22px;color:#E65100;margin-bottom:4px}
.box p{font-size:13px;color:#888;margin-bottom:24px}
label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
input{width:100%;padding:10px 13px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;font-family:inherit;margin-bottom:14px}
input:focus{outline:none;border-color:#E65100}
button{width:100%;padding:12px;background:#E65100;color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:700;cursor:pointer}
button:hover{background:#BF360C}
.footer{text-align:center;margin-top:18px;font-size:12px;color:#aaa}
</style></head>
<body><div class="box">
  <h1>&#128667; Towing Portal</h1>
  <p>BookaWaka Towing Owner Access</p>
  ${errHtml}
  <form method="POST" action="/api/towing-login">
    ${cid ? `<input type="hidden" name="cid" value="${esc(cid)}"/>` : ''}
    <label>Email Address</label>
    <input type="email" name="email" placeholder="owner@towingco.co.nz" required autocomplete="email"/>
    <label>Password</label>
    <input type="password" name="password" placeholder="Your password" required/>
    <button type="submit">Sign In</button>
  </form>
  <div class="footer">Problems? Contact <a href="mailto:support@bookawaka.co.nz" style="color:#E65100">support@bookawaka.co.nz</a></div>
</div></body></html>`);
});

router.post('/api/towing-login', (req, res) => {
  const email = (req.body.email || '').trim().toLowerCase();
  const password = req.body.password || '';
  if (!email || !password) return res.redirect('/towing-portal?err=missing');
  const hash = twHash(password);
  fbReadP('towingPortalAccess').then((data: any) => {
    if (!data) return res.redirect('/towing-portal?err=nodata');
    const entry = Object.entries(data).find(([, v]: any) => v && v.email === email && v.passwordHash === hash);
    if (!entry) return res.redirect('/towing-portal?err=invalid');
    const [cid, info]: any = entry;
    if (info.active === false) return res.redirect('/towing-portal?err=inactive');
    const token = twSetSession(cid, info.name || cid, email);
    res.redirect(`/towing-portal/dashboard?t=${encodeURIComponent(token)}`);
  }).catch(() => res.redirect('/towing-portal?err=invalid'));
});

router.get('/api/towing-logout', (req, res) => {
  const t = (req.query.t as string) || '';
  delete towingSessions[t];
  unpersistSessionDirect('towing', t);
  res.redirect('/towing-portal');
});

// ── SA: Set Towing Portal Password ────────────────────────────────────────────
router.post('/api/set-towing-password', (req, res) => {
  const { companyId, name, email, password } = req.body;
  if (!companyId || !name || !email || !password) return res.json({ ok: false, error: 'All fields required' });
  if (password.length < 8) return res.json({ ok: false, error: 'Password must be at least 8 characters' });
  const data = { email: email.toLowerCase(), name, passwordHash: twHash(password), active: true, updatedAt: Date.now() };
  fbWriteP('PUT', `towingPortalAccess/${companyId}`, data)
    .then(() => res.json({ ok: true }))
    .catch((e: any) => res.json({ ok: false, error: e.message }));
});

// ── Dashboard ─────────────────────────────────────────────────────────────────
router.get('/towing-portal/dashboard', requireTowingAuth, (req: any, res) => {
  const sess = req.twSession;
  const token = req.twToken;
  const cid = sess.companyId;
  const te = encodeURIComponent(token);
  Promise.all([
    fbReadP(`towingJobs/${cid}`).then((d: any) => d || {}),
    fbReadP(`towingFleet/${cid}`).then((d: any) => d || {}),
    fbReadP(`towingDrivers/${cid}`).then((d: any) => d || {}),
    fbReadP(`towingConfig/${cid}`).then((d: any) => d || {})
  ]).then(([jobs, fleet, drivers]) => {
    const jobList = Object.entries(jobs).map(([k, v]: any) => ({ id: k, ...v }))
      .sort((a: any, b: any) => (b.createdAt || 0) - (a.createdAt || 0));
    const active = jobList.filter((j: any) => ['pending','assigned','enroute','arrived','loading','dropoff'].includes(j.status || 'pending'));
    const completed = jobList.filter((j: any) => j.status === 'completed');
    const insurance = jobList.filter((j: any) => j.paymentType === 'insurance' || j.paymentType === 'thirdparty');
    const truckCount = Object.keys(fleet).length;
    const driverCount = Object.keys(drivers).length;
    const revenue = completed.filter((j: any) => j.paymentType === 'stripe').reduce((s: number, j: any) => s + (parseFloat(j.totalEstimate) || 0), 0);
    const statsHtml = `<div class="tw-stats">
      <div class="tw-stat"><div class="tw-stat-v">${active.length}</div><div class="tw-stat-l">Active Jobs</div></div>
      <div class="tw-stat green"><div class="tw-stat-v">${completed.length}</div><div class="tw-stat-l">Completed Jobs</div></div>
      <div class="tw-stat blue"><div class="tw-stat-v">${truckCount}</div><div class="tw-stat-l">Trucks in Fleet</div></div>
      <div class="tw-stat purple"><div class="tw-stat-v">${driverCount}</div><div class="tw-stat-l">Drivers</div></div>
      <div class="tw-stat teal"><div class="tw-stat-v">${insurance.length}</div><div class="tw-stat-l">Insurance Jobs</div></div>
      <div class="tw-stat green"><div class="tw-stat-v">$${revenue.toFixed(2)}</div><div class="tw-stat-l">Stripe Revenue</div></div>
    </div>`;
    const recentRows = jobList.slice(0, 10).map((j: any) => `<tr>
      <td style="font-size:11px;color:#888;font-family:monospace">${esc(j.id)}</td>
      <td style="font-weight:600">${esc(j.customerName||'—')}</td>
      <td style="font-size:12px">${esc(j.pickup||'—')}</td>
      <td>${twPayBadge(j.paymentType)}</td>
      <td>${twStatusBadge(j.status)}</td>
      <td style="font-size:11.5px;color:#888;white-space:nowrap">${j.createdAt ? new Date(j.createdAt).toLocaleString('en-NZ',{day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'}) : '—'}</td>
      <td><a href="/towing-portal/jobs?t=${te}" class="tw-btn tw-btn-n" style="font-size:11.5px;padding:4px 10px">View</a></td>
    </tr>`).join('');
    const activeAlert = active.length ? `<div class="tw-notice warn">&#128161; You have <strong>${active.length}</strong> active job${active.length!==1?'s':''} right now. <a href="/towing-portal/jobs?t=${te}" style="color:#E65100;font-weight:700;text-decoration:underline">View Jobs &rarr;</a></div>` : '';
    const body = `${activeAlert}
    ${statsHtml}
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128222; Recent Jobs</h3><a href="/towing-portal/jobs?t=${te}" class="tw-btn tw-btn-p">View All</a></div>
      <div style="overflow-x:auto">
        ${jobList.length ? `<table class="tw-tbl"><thead><tr><th>Job ID</th><th>Customer</th><th>Pickup</th><th>Payment</th><th>Status</th><th>Date</th><th></th></tr></thead><tbody>${recentRows}</tbody></table>` : '<div class="tw-empty">No jobs yet. Jobs will appear here when bookings come in.</div>'}
      </div>
    </div>`;
    res.send(twPage('Dashboard', renderTwNav(sess, token, 'dashboard'), body));
  }).catch((e: any) => res.send(twPage('Dashboard', renderTwNav(sess, token, 'dashboard'), `<div class="tw-notice err">Error loading dashboard: ${esc(e.message)}</div>`)));
});

// ── Jobs ──────────────────────────────────────────────────────────────────────
router.get('/towing-portal/jobs', requireTowingAuth, (req: any, res) => {
  const sess = req.twSession;
  const token = req.twToken;
  const cid = sess.companyId;
  const te = encodeURIComponent(token);
  Promise.all([
    fbReadP(`towingJobs/${cid}`).then((d: any) => d || {}),
    fbReadP(`towingDrivers/${cid}`).then((d: any) => d || {})
  ]).then(([jobs, drivers]) => {
    const jobList = Object.entries(jobs).map(([k, v]: any) => ({ id: k, ...v }))
      .sort((a: any, b: any) => (b.createdAt || 0) - (a.createdAt || 0));
    const statusOpts = ['pending','assigned','enroute','arrived','loading','dropoff','completed','cancelled'].map(s =>
      `<option value="${s}">${s.charAt(0).toUpperCase()+s.slice(1)}</option>`).join('');
    const driverOpts = Object.entries(drivers).map(([k, v]: any) =>
      `<option value="${k}">${esc(v.name||k)}</option>`).join('');
    const rows = jobList.map((j: any) => {
      const d: any = (drivers as any)[j.driverId] || {};
      const hasNotes = j.status === 'completed' || j.paymentType === 'insurance' || j.paymentType === 'thirdparty';
      const notesIndicator = (j.completionNotes || j.finalMileage || j.actualAmount) ? ' <span style="color:#2E7D32;font-size:10px">&#10003;</span>' : '';
      return `<tr>
        <td style="font-size:11px;color:#888;font-family:monospace">${esc(j.id)}</td>
        <td><div style="font-weight:600;font-size:12.5px">${esc(j.customerName||'—')}</div><div style="font-size:11px;color:#888">${esc(j.customerPhone||'')}</div></td>
        <td style="font-size:12px;max-width:150px">${esc(j.pickup||'—')}</td>
        <td style="font-size:12px;max-width:140px">${esc(j.dropoff||'—')}</td>
        <td style="font-size:11.5px">${esc((j.vehicleMake||'')+(j.vehicleModel?' '+j.vehicleModel:'')+(j.vehicleRego?' ('+j.vehicleRego+')':''))}</td>
        <td>${twPayBadge(j.paymentType)}</td>
        <td>${twStatusBadge(j.status)}</td>
        <td style="font-size:11.5px">${esc(d.name||j.driverId||'—')}</td>
        <td style="white-space:nowrap;font-size:11.5px">${j.createdAt ? new Date(j.createdAt).toLocaleString('en-NZ',{day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'}) : '—'}</td>
        <td style="font-weight:700;color:#2E7D32">${j.actualAmount ? '<span title="Actual">$'+parseFloat(j.actualAmount).toFixed(2)+'</span>' : j.totalEstimate ? '<span style="color:#aaa" title="Estimate">~$'+parseFloat(j.totalEstimate).toFixed(2)+'</span>' : '—'}</td>
        <td style="white-space:nowrap">
          <button onclick="openJobModal('${esc(j.id)}','${esc(j.status||'pending')}')" class="tw-btn tw-btn-p" style="font-size:11px;padding:4px 8px">Update</button>
          <button onclick="shareTrack('${esc(j.id)}')" class="tw-btn tw-btn-n" style="font-size:11px;padding:4px 8px;margin-left:3px" title="Copy tracking link">&#128279;</button>
          ${hasNotes ? `<button onclick="openNotesModal('${esc(j.id)}','${esc(String(j.finalMileage||''))}','${esc(String(j.actualAmount||''))}','${esc((j.completionNotes||'').replace(/'/g,'&apos;'))}')" class="tw-btn tw-btn-n" style="font-size:11px;padding:4px 8px;margin-left:3px" title="Add job notes">&#128203;${notesIndicator}</button>` : ''}
          ${j.status === 'completed' ? `<a href="/towing-portal/invoice?jobId=${esc(j.id)}&t=${te}" target="_blank" class="tw-btn tw-btn-n" style="font-size:11px;padding:4px 8px;margin-left:3px;text-decoration:none" title="Print Invoice">&#129534;</a>` : ''}
        </td>
      </tr>`;
    }).join('');
    const body = `
    <div id="job-notice" style="display:none"></div>
    <div id="track-toast" style="display:none;position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#263238;color:#fff;padding:10px 20px;border-radius:6px;font-size:13px;z-index:999;white-space:nowrap"></div>
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128222; All Jobs</h3><span style="font-size:12px;color:#888">${jobList.length} total</span></div>
      <div style="overflow-x:auto">
        ${jobList.length ? `<table class="tw-tbl"><thead><tr><th>Job ID</th><th>Customer</th><th>Pickup</th><th>Drop-off</th><th>Vehicle</th><th>Payment</th><th>Status</th><th>Driver</th><th>Date</th><th>Amount</th><th></th></tr></thead><tbody>${rows}</tbody></table>` : '<div class="tw-empty">No jobs yet.</div>'}
      </div>
    </div>
    <div id="job-modal" class="modal-backdrop">
      <div class="modal-box">
        <div class="modal-hd"><h4>&#128222; Update Job Status</h4><button onclick="closeModal()" style="background:none;border:none;font-size:20px;cursor:pointer;color:#888">&times;</button></div>
        <div class="modal-bd tw-ff">
          <input type="hidden" id="modal-jid"/>
          <div style="margin-bottom:12px"><label>New Status</label>
            <select id="modal-status">${statusOpts}</select>
          </div>
          <div style="margin-bottom:12px"><label>Assign Driver</label>
            <select id="modal-driver"><option value="">— No change —</option>${driverOpts}</select>
          </div>
          <div><label>Dispatch Notes (optional)</label>
            <textarea id="modal-notes" rows="3" placeholder="Any notes about this job update…" style="width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:5px;font-size:13px;font-family:inherit"></textarea>
          </div>
        </div>
        <div class="modal-ft">
          <button onclick="closeModal()" class="tw-btn tw-btn-n">Cancel</button>
          <button onclick="saveJobUpdate()" class="tw-btn tw-btn-p">Save Update</button>
        </div>
      </div>
    </div>
    <div id="notes-modal" class="modal-backdrop">
      <div class="modal-box">
        <div class="modal-hd"><h4>&#128203; Job Notes &amp; Completion Details</h4><button onclick="closeNotesModal()" style="background:none;border:none;font-size:20px;cursor:pointer;color:#888">&times;</button></div>
        <div class="modal-bd tw-ff">
          <input type="hidden" id="notes-jid"/>
          <p style="font-size:12px;color:#888;margin-bottom:14px">Record final mileage, actual amount charged, and any completion notes. Used for invoicing insurance jobs.</p>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px">
            <div><label>Final Mileage (km)</label>
              <input type="number" id="notes-mileage" min="0" step="0.1" placeholder="e.g. 12.4" style="width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:5px;font-size:13px"/>
            </div>
            <div><label>Actual Amount Charged ($)</label>
              <input type="number" id="notes-amount" min="0" step="0.01" placeholder="e.g. 145.00" style="width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:5px;font-size:13px"/>
            </div>
          </div>
          <div><label>Completion Notes</label>
            <textarea id="notes-text" rows="4" placeholder="e.g. Vehicle delivered to Smith's Garage. Customer paid cash top-up of $30. Claim ref: INS-2024-8834" style="width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:5px;font-size:13px;font-family:inherit"></textarea>
          </div>
          <div id="notes-msg" style="margin-top:8px;font-size:12.5px"></div>
        </div>
        <div class="modal-ft">
          <button onclick="closeNotesModal()" class="tw-btn tw-btn-n">Cancel</button>
          <button onclick="saveNotes()" class="tw-btn tw-btn-p">&#128190; Save Notes</button>
        </div>
      </div>
    </div>
    <script>
    function openJobModal(id, status){ document.getElementById('modal-jid').value=id; document.getElementById('modal-status').value=status; document.getElementById('modal-notes').value=''; document.getElementById('job-modal').classList.add('open'); }
    function closeModal(){ document.getElementById('job-modal').classList.remove('open'); }
    function saveJobUpdate(){
      var jid=document.getElementById('modal-jid').value, status=document.getElementById('modal-status').value, driver=document.getElementById('modal-driver').value, notes=document.getElementById('modal-notes').value;
      fetch('/api/towing-job-action',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({jobId:jid,status:status,driverId:driver||null,notes:notes,t:'${te}'})})
        .then(r=>r.json()).then(d=>{
          var n=document.getElementById('job-notice'); n.className='tw-notice '+(d.ok?'ok':'err'); n.textContent=d.ok?'Job updated.':('Error: '+(d.error||'Unknown')); n.style.display='block';
          if(d.ok){ closeModal(); setTimeout(function(){ window.location.reload(); },1200); }
        }).catch(function(){ var n=document.getElementById('job-notice'); n.className='tw-notice err'; n.textContent='Network error.'; n.style.display='block'; });
    }
    function shareTrack(jobId){
      var url = window.location.origin+'/tow/track?id='+jobId;
      if(navigator.clipboard){ navigator.clipboard.writeText(url).then(function(){ showToast('Tracking link copied to clipboard'); }); }
      else { prompt('Copy this tracking link:', url); }
    }
    function showToast(msg){ var t=document.getElementById('track-toast'); t.textContent=msg; t.style.display='block'; setTimeout(function(){ t.style.display='none'; },2500); }
    function openNotesModal(id, mileage, amount, notes){ document.getElementById('notes-jid').value=id; document.getElementById('notes-mileage').value=mileage||''; document.getElementById('notes-amount').value=amount||''; document.getElementById('notes-text').value=notes||''; document.getElementById('notes-msg').textContent=''; document.getElementById('notes-modal').classList.add('open'); }
    function closeNotesModal(){ document.getElementById('notes-modal').classList.remove('open'); }
    function saveNotes(){
      var jid=document.getElementById('notes-jid').value;
      var mileage=document.getElementById('notes-mileage').value;
      var amount=document.getElementById('notes-amount').value;
      var notes=document.getElementById('notes-text').value.trim();
      var msg=document.getElementById('notes-msg'); msg.textContent='Saving\u2026'; msg.style.color='#888';
      fetch('/api/towing-job-notes',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({jobId:jid,finalMileage:mileage?parseFloat(mileage):null,actualAmount:amount?parseFloat(amount):null,completionNotes:notes,t:'${te}'})})
        .then(r=>r.json()).then(d=>{
          if(d.ok){ msg.style.color='#2E7D32'; msg.textContent='\u2713 Notes saved.'; setTimeout(function(){ closeNotesModal(); window.location.reload(); },1000); }
          else { msg.style.color='#C62828'; msg.textContent='Error: '+(d.error||'Unknown'); }
        }).catch(function(){ msg.style.color='#C62828'; msg.textContent='Network error.'; });
    }
    document.getElementById('job-modal').addEventListener('click',function(e){ if(e.target===this) closeModal(); });
    document.getElementById('notes-modal').addEventListener('click',function(e){ if(e.target===this) closeNotesModal(); });
    </script>`;
    res.send(twPage('Jobs', renderTwNav(sess, token, 'jobs'), body));
  }).catch((e: any) => res.send(twPage('Jobs', renderTwNav(sess, token, 'jobs'), `<div class="tw-notice err">Error: ${esc(e.message)}</div>`)));
});

// ── Invoice (single job print + monthly insurance) ────────────────────────────
router.get('/towing-portal/invoice', requireTowingAuth, async (req: any, res) => {
  const sess = req.twSession;
  const token = req.twToken;
  const cid = sess.companyId;
  const te = encodeURIComponent(token);
  const jobId = req.query.jobId as string;

  // Single job print invoice
  if (jobId) {
    try {
      const [job, access] = await Promise.all([
        fbReadP(`towingJobs/${cid}/${jobId}`).catch(() => ({})).then((d: any) => d || {}),
        fbReadP(`towingPortalAccess/${cid}`).catch(() => ({})).then((d: any) => d || {})
      ]);
      const companyName = access.name || cid;
      const companyPhone = access.phone || '';
      const companyEmail = access.email || '';
      const dateStr = new Date(job.completedAt || job.updatedAt || job.createdAt || Date.now())
        .toLocaleDateString('en-NZ', { day: 'numeric', month: 'long', year: 'numeric' });
      const amount = job.actualAmount
        ? '$' + parseFloat(job.actualAmount).toFixed(2)
        : job.totalEstimate
          ? '~$' + parseFloat(job.totalEstimate).toFixed(2) + ' (estimate)'
          : '—';
      const isThirdParty = job.paymentType === 'insurance' || job.paymentType === 'thirdparty';
      res.send(`<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Invoice ${esc(jobId)} &mdash; ${esc(companyName)}</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',Arial,sans-serif;background:#f5f5f5;color:#333;font-size:14px}
.page{max-width:700px;margin:30px auto;background:#fff;border-radius:8px;box-shadow:0 2px 12px rgba(0,0,0,.12);overflow:hidden}
.inv-hdr{background:#E65100;color:#fff;padding:28px 32px;display:flex;align-items:flex-start;justify-content:space-between;gap:16px}
.inv-title{font-size:30px;font-weight:900;letter-spacing:-1px}
.inv-co{font-size:15px;font-weight:700;margin-top:5px;opacity:.92}
.inv-co-sub{font-size:12px;opacity:.7;margin-top:3px}
.inv-meta{text-align:right;min-width:160px}
.inv-meta-lbl{font-size:10px;text-transform:uppercase;letter-spacing:.06em;opacity:.7;margin-bottom:2px}
.inv-meta-val{font-size:14px;font-weight:700;font-family:monospace}
.inv-body{padding:28px 32px}
.section{margin-bottom:24px}
.section-hdr{font-size:10.5px;font-weight:800;color:#E65100;text-transform:uppercase;letter-spacing:.1em;padding-bottom:7px;border-bottom:2px solid #FFF3E0;margin-bottom:12px}
.grid-2{display:grid;grid-template-columns:1fr 1fr;gap:10px 20px}
.field-lbl{font-size:11px;color:#9e9e9e;text-transform:uppercase;font-weight:600;letter-spacing:.04em;margin-bottom:2px}
.field-val{font-size:13.5px;color:#263238;font-weight:500}
.amount-box{background:#FFF3E0;border:2px solid #E65100;border-radius:8px;padding:20px 24px;display:flex;align-items:center;justify-content:space-between}
.amount-lbl{font-size:14px;font-weight:600;color:#555}
.amount-val{font-size:34px;font-weight:900;color:#E65100}
.notes-box{background:#F9F9F9;border-radius:6px;padding:14px 16px;font-size:13px;color:#444;line-height:1.6;border-left:3px solid #E65100}
.inv-ftr{padding:16px 32px;border-top:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between}
.inv-ftr-txt{font-size:11px;color:#bbb}
.print-btn{background:#E65100;color:#fff;border:none;padding:10px 22px;border-radius:6px;font-size:13px;font-weight:700;cursor:pointer}
.print-btn:hover{background:#BF360C}
@media print{
  body{background:#fff}
  .page{box-shadow:none;margin:0;border-radius:0;max-width:100%}
  .print-btn,.no-print{display:none!important}
}
</style></head><body>
<div class="page">
  <div class="inv-hdr">
    <div>
      <div class="inv-title">&#128667; INVOICE</div>
      <div class="inv-co">${esc(companyName)}</div>
      <div class="inv-co-sub">Towing Service${companyPhone ? ' &bull; ' + esc(companyPhone) : ''}${companyEmail ? ' &bull; ' + esc(companyEmail) : ''}</div>
    </div>
    <div class="inv-meta">
      <div class="inv-meta-lbl">Job / Invoice ID</div>
      <div class="inv-meta-val">${esc(jobId)}</div>
      <div style="margin-top:10px"><div class="inv-meta-lbl">Date</div><div style="font-size:13px;font-weight:600">${dateStr}</div></div>
      <div style="margin-top:10px"><div class="inv-meta-lbl">Status</div><div style="font-size:12px;font-weight:700;color:#fff;background:rgba(255,255,255,.25);display:inline-block;padding:2px 10px;border-radius:10px">${esc((job.status||'—').toUpperCase())}</div></div>
    </div>
  </div>
  <div class="inv-body">
    <div class="section">
      <div class="section-hdr">Customer</div>
      <div class="grid-2">
        <div><div class="field-lbl">Name</div><div class="field-val">${esc(job.customerName||'—')}</div></div>
        <div><div class="field-lbl">Phone</div><div class="field-val">${esc(job.customerPhone||'—')}</div></div>
        ${job.customerEmail ? `<div><div class="field-lbl">Email</div><div class="field-val">${esc(job.customerEmail)}</div></div>` : ''}
      </div>
    </div>
    <div class="section">
      <div class="section-hdr">Service Details</div>
      <div class="grid-2">
        <div><div class="field-lbl">Pickup</div><div class="field-val">${esc(job.pickup||'—')}</div></div>
        <div><div class="field-lbl">Drop-off</div><div class="field-val">${esc(job.dropoff||'—')}</div></div>
        <div><div class="field-lbl">Vehicle</div><div class="field-val">${esc([(job.vehicleYear||''),(job.vehicleMake||''),(job.vehicleModel||'')].filter(Boolean).join(' ')+(job.vehicleRego?' ('+job.vehicleRego+')':''))}</div></div>
        <div><div class="field-lbl">Problem / Service</div><div class="field-val">${esc(job.problem||'—')}${job.problemNotes?`<br><span style="font-size:12px;color:#888">${esc(job.problemNotes)}</span>`:''}</div></div>
        ${job.finalMileage ? `<div><div class="field-lbl">Distance</div><div class="field-val">${esc(String(job.finalMileage))} km</div></div>` : ''}
        <div><div class="field-lbl">Payment Method</div><div class="field-val" style="text-transform:capitalize">${esc((job.paymentType||'cash').replace(/_/g,' '))}</div></div>
        ${job.driverId ? `<div><div class="field-lbl">Driver ID</div><div class="field-val" style="font-family:monospace;font-size:12px">${esc(job.driverId)}</div></div>` : ''}
      </div>
    </div>
    <div class="section">
      <div class="section-hdr">Amount</div>
      <div class="amount-box">
        <div>
          <div class="amount-lbl">Total${job.actualAmount ? ' (Actual Charged)' : job.totalEstimate ? ' (Estimate)' : ''}</div>
          ${isThirdParty ? '<div style="font-size:12px;color:#888;margin-top:3px">Third-party billing &mdash; see completion notes for claim reference</div>' : ''}
        </div>
        <div class="amount-val">${amount}</div>
      </div>
    </div>
    ${job.completionNotes ? `<div class="section">
      <div class="section-hdr">Completion Notes</div>
      <div class="notes-box">${esc(job.completionNotes)}</div>
    </div>` : ''}
  </div>
  <div class="inv-ftr">
    <div class="inv-ftr-txt">Generated by BookaWaka Towing Platform &bull; taxitime.co.nz</div>
    <button class="print-btn no-print" onclick="window.print()">&#128424; Print / Save PDF</button>
  </div>
</div>
</body></html>`);
    } catch (e: any) {
      res.send(`<h1>Error</h1><p>${esc(e.message)}</p>`);
    }
    return;
  }

  // Monthly insurance invoice
  const now = new Date();
  const monthParam = (req.query.month as string) || `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}`;
  const [mYear, mMonth] = monthParam.split('-').map(Number);
  try {
    const [jobs, platformCfg, companyCfg] = await Promise.all([
      fbReadP(`towingJobs/${cid}`).then((d: any) => d || {}),
      fbReadP('bwConfig/towing').then((d: any) => d || {}),
      fbReadP(`towingConfig/${cid}`).then((d: any) => d || {})
    ]);
    const flatFee = parseFloat(companyCfg.insuranceFlatFee || platformCfg.insuranceFlatFee || 12);
    const jobList = Object.entries(jobs).map(([k,v]: any) => ({id:k,...v})).sort((a: any,b: any)=>(b.createdAt||0)-(a.createdAt||0));
    const insJobs = jobList.filter((j: any) => {
      if (!['insurance','thirdparty'].includes(j.paymentType)) return false;
      const d = new Date(j.createdAt||0);
      return d.getFullYear()===mYear && d.getMonth()+1===mMonth;
    });
    const total = insJobs.length * flatFee;
    const monthLabel = new Date(mYear, mMonth-1, 1).toLocaleString('en-NZ',{month:'long',year:'numeric'});
    const monthOpts = Array.from({length:12},(_,i)=>{
      const d = new Date(now.getFullYear(), now.getMonth()-i, 1);
      const val = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}`;
      const lbl = d.toLocaleString('en-NZ',{month:'long',year:'numeric'});
      return `<option value="${val}"${val===monthParam?' selected':''}>${lbl}</option>`;
    }).join('');
    const rows = insJobs.length ? insJobs.map((j: any) => `<tr>
      <td style="font-family:monospace;font-size:11px;color:#888">${esc(j.id)}</td>
      <td style="font-size:12px">${j.createdAt ? new Date(j.createdAt).toLocaleDateString('en-NZ',{day:'numeric',month:'short'}) : '—'}</td>
      <td style="font-weight:600">${esc(j.customerName||'—')}</td>
      <td style="font-size:12px">${esc(j.vehicleRego||j.vehicleMake||'—')}</td>
      <td>${j.paymentType==='insurance'?'<span class="tw-bdg-b">Own Insurance</span>':'<span class="tw-bdg-o">3rd Party</span>'}</td>
      <td>${esc(j.insuranceCompany||j.thirdPartyInsurer||'—')}</td>
      <td style="font-weight:700;color:#E65100">$${flatFee.toFixed(2)}</td>
    </tr>`).join('') : `<tr><td colspan="7" style="text-align:center;color:#aaa;padding:24px;font-style:italic">No insurance jobs in ${monthLabel}</td></tr>`;

    const body = `
<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;margin-bottom:18px">
  <h2 style="font-size:18px;font-weight:700;color:#E65100">&#128203; Monthly Invoice &mdash; ${esc(monthLabel)}</h2>
  <div style="display:flex;gap:10px;align-items:center">
    <select onchange="location.href='/towing-portal/invoice?t=${te}&month='+this.value" style="padding:6px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px">${monthOpts}</select>
    <button onclick="window.print()" class="tw-btn tw-btn-p" style="background:#E65100">&#128424; Print</button>
  </div>
</div>
<div class="tw-stats" style="margin-bottom:18px">
  <div class="tw-stat"><div class="tw-stat-v">${insJobs.length}</div><div class="tw-stat-l">Insurance Jobs</div></div>
  <div class="tw-stat"><div class="tw-stat-v">$${flatFee.toFixed(2)}</div><div class="tw-stat-l">Flat Fee per Job</div></div>
  <div class="tw-stat green"><div class="tw-stat-v green" style="color:#2E7D32">$${total.toFixed(2)}</div><div class="tw-stat-l">Total Due to BookaWaka</div></div>
</div>
<div class="tw-card">
  <div class="tw-card-hd"><h3>&#127962; Insurance &amp; 3rd-Party Jobs &mdash; ${esc(monthLabel)}</h3></div>
  <div style="overflow-x:auto">
    <table class="tw-tbl">
      <thead><tr><th>Job ID</th><th>Date</th><th>Customer</th><th>Vehicle / Rego</th><th>Type</th><th>Insurer</th><th>Fee Due</th></tr></thead>
      <tbody>${rows}</tbody>
      ${insJobs.length ? `<tfoot><tr><td colspan="6" style="padding:10px 11px;font-weight:700;text-align:right;color:#555;font-size:13px">Total due for ${esc(monthLabel)}:</td><td style="padding:10px 11px;font-weight:700;color:#E65100;font-size:15px">$${total.toFixed(2)}</td></tr></tfoot>` : ''}
    </table>
  </div>
</div>
<div class="tw-card tw-card-bd" style="font-size:12.5px;color:#666;line-height:1.6">
  <strong style="color:#E65100">Payment Instructions</strong><br>
  Please pay the total amount above to BookaWaka by the 20th of the following month.<br>
  Bank: &lt;YOUR BANK DETAILS&gt; &nbsp;&bull;&nbsp; Reference: <code style="background:#f5f5f5;padding:2px 6px;border-radius:3px">${esc(cid)}-${monthParam}</code><br>
  Questions? Email <a href="mailto:billing@bookawaka.co.nz" style="color:#E65100">billing@bookawaka.co.nz</a>
</div>
<style>@media print{.tw-nav,.no-print{display:none!important}.tw-main{padding:0}}</style>`;

    res.send(twPage(`Invoice — ${monthLabel}`, renderTwNav(sess, token, 'invoice'), body));
  } catch (e: any) {
    res.send(twPage('Invoice', renderTwNav(sess, token, 'invoice'), `<div class="tw-notice err">Error loading invoice: ${esc(e.message)}</div>`));
  }
});

// ── Fleet ─────────────────────────────────────────────────────────────────────
router.get('/towing-portal/fleet', requireTowingAuth, (req: any, res) => {
  const sess = req.twSession;
  const token = req.twToken;
  const cid = sess.companyId;
  const te = encodeURIComponent(token);
  fbReadP(`towingFleet/${cid}`).then((data: any) => {
    const fleet = data || {};
    const truckTypeOpts = ['flatbed','wheel-lift','heavy recovery','multi-car'].map(t =>
      `<option value="${t}">${t.charAt(0).toUpperCase()+t.slice(1)}</option>`).join('');
    const statusOpts = `<option value="active">Active</option><option value="inactive">Inactive</option><option value="maintenance">Maintenance</option>`;
    const cards = Object.entries(fleet).map(([k, v]: any) => {
      const typeLabel = (v.type||'flatbed').charAt(0).toUpperCase()+(v.type||'flatbed').slice(1);
      return `<div class="truck-card">
        <div class="truck-card-hd">
          <div>
            <div class="truck-name">&#128667; ${esc(v.name||k)}</div>
            <div class="truck-sub">${typeLabel} &bull; Plate: ${esc(v.plate||'—')} &bull; ${esc(v.year||'—')}</div>
            <div class="truck-sub">Capacity: ${esc(String(v.capacity||1))} vehicle(s)</div>
          </div>
          <span class="tw-bdg-${v.status==='active'?'g':v.status==='maintenance'?'y':'gr'}">${esc(v.status||'active')}</span>
        </div>
        <div style="display:flex;gap:8px;flex-wrap:wrap">
          <button onclick="editTruck('${esc(k)}','${esc(v.name||'')}','${esc(v.plate||'')}','${esc(v.type||'flatbed')}','${esc(String(v.capacity||1))}','${esc(v.year||'')}','${esc(v.status||'active')}')" class="tw-btn tw-btn-p" style="font-size:12px;padding:5px 11px">&#9998; Edit</button>
          <button onclick="deleteTruck('${esc(k)}','${esc(v.name||k)}')" class="tw-btn tw-btn-r" style="font-size:12px;padding:5px 11px">&#128465; Delete</button>
        </div>
      </div>`;
    }).join('');
    const body = `
    <div id="fleet-notice"></div>
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128667; Fleet (${Object.keys(fleet).length} Trucks)</h3>
        <button onclick="openTruckModal()" class="tw-btn tw-btn-p">&#43; Add Truck</button>
      </div>
      <div class="tw-card-bd">
        ${Object.keys(fleet).length ? `<div class="tw-grid">${cards}</div>` : '<div class="tw-empty">No trucks yet. Add your first truck above.</div>'}
      </div>
    </div>
    <div id="truck-modal" class="modal-backdrop">
      <div class="modal-box">
        <div class="modal-hd"><h4 id="truck-modal-title">&#128667; Add Truck</h4><button onclick="closeTruckModal()" style="background:none;border:none;font-size:20px;cursor:pointer;color:#888">&times;</button></div>
        <div class="modal-bd tw-ff">
          <input type="hidden" id="truck-id"/>
          <div class="tw-grid" style="margin-bottom:12px">
            <div><label>Truck Name / ID *</label><input type="text" id="truck-name" placeholder="e.g. Truck 1, Big Blue"/></div>
            <div><label>Plate Number *</label><input type="text" id="truck-plate" placeholder="e.g. ABC123"/></div>
          </div>
          <div class="tw-grid" style="margin-bottom:12px">
            <div><label>Type *</label><select id="truck-type">${truckTypeOpts}</select></div>
            <div><label>Capacity (vehicles) *</label><input type="number" id="truck-cap" min="1" max="10" value="1"/></div>
            <div><label>Year</label><input type="text" id="truck-year" placeholder="e.g. 2022"/></div>
            <div><label>Status</label><select id="truck-status">${statusOpts}</select></div>
          </div>
        </div>
        <div class="modal-ft">
          <button onclick="closeTruckModal()" class="tw-btn tw-btn-n">Cancel</button>
          <button onclick="saveTruck()" class="tw-btn tw-btn-p">Save Truck</button>
        </div>
      </div>
    </div>
    <script>
    function showFleetNotice(msg,type){ var n=document.getElementById('fleet-notice'); n.className='tw-notice '+type; n.textContent=msg; n.style.display='block'; if(type!=='err') setTimeout(function(){n.style.display='none';},3500); }
    function openTruckModal(id,name,plate,type,cap,year,status){
      document.getElementById('truck-modal-title').textContent=(id?'Edit':'Add')+' Truck';
      document.getElementById('truck-id').value=id||'';
      document.getElementById('truck-name').value=name||'';
      document.getElementById('truck-plate').value=plate||'';
      document.getElementById('truck-type').value=type||'flatbed';
      document.getElementById('truck-cap').value=cap||1;
      document.getElementById('truck-year').value=year||'';
      document.getElementById('truck-status').value=status||'active';
      document.getElementById('truck-modal').classList.add('open');
    }
    function editTruck(id,name,plate,type,cap,year,status){ openTruckModal(id,name,plate,type,cap,year,status); }
    function closeTruckModal(){ document.getElementById('truck-modal').classList.remove('open'); }
    function saveTruck(){
      var data={ truckId:document.getElementById('truck-id').value||null, name:document.getElementById('truck-name').value.trim(), plate:document.getElementById('truck-plate').value.trim().toUpperCase(), type:document.getElementById('truck-type').value, capacity:parseInt(document.getElementById('truck-cap').value)||1, year:document.getElementById('truck-year').value.trim(), status:document.getElementById('truck-status').value, t:'${te}' };
      if(!data.name||!data.plate){ showFleetNotice('Name and plate are required.','err'); return; }
      fetch('/api/towing-fleet-save',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)})
        .then(r=>r.json()).then(d=>{ if(d.ok){ showFleetNotice('Truck saved.','ok'); closeTruckModal(); setTimeout(function(){window.location.reload();},1200); } else showFleetNotice('Error: '+(d.error||'Unknown'),'err'); })
        .catch(function(){ showFleetNotice('Network error.','err'); });
    }
    function deleteTruck(id,name){
      if(!confirm('Delete '+name+'? This cannot be undone.')) return;
      fetch('/api/towing-fleet-delete',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({truckId:id,t:'${te}'})})
        .then(r=>r.json()).then(d=>{ if(d.ok){ showFleetNotice('Truck deleted.','ok'); setTimeout(function(){window.location.reload();},1200); } else showFleetNotice('Error: '+(d.error||'Unknown'),'err'); })
        .catch(function(){ showFleetNotice('Network error.','err'); });
    }
    document.getElementById('truck-modal').addEventListener('click',function(e){ if(e.target===this) closeTruckModal(); });
    </script>`;
    res.send(twPage('Fleet', renderTwNav(sess, token, 'fleet'), body));
  }).catch((e: any) => res.send(twPage('Fleet', renderTwNav(sess, token, 'fleet'), `<div class="tw-notice err">Error: ${esc(e.message)}</div>`)));
});

// ── Drivers ───────────────────────────────────────────────────────────────────
router.get('/towing-portal/drivers', requireTowingAuth, (req: any, res) => {
  const sess = req.twSession;
  const token = req.twToken;
  const cid = sess.companyId;
  const te = encodeURIComponent(token);
  Promise.all([
    fbReadP(`towingDrivers/${cid}`).then((d: any) => d || {}),
    fbReadP(`towingFleet/${cid}`).then((d: any) => d || {})
  ]).then(([drivers, fleet]) => {
    const truckOpts = `<option value="">— No truck assigned —</option>` + Object.entries(fleet).map(([k, v]: any) =>
      `<option value="${k}">${esc(v.name||k)} (${esc(v.plate||'—')})</option>`).join('');
    const statusOpts = `<option value="active">Active</option><option value="inactive">Inactive</option>`;
    const rows = Object.entries(drivers).map(([k, v]: any) => {
      const truck: any = (fleet as any)[v.truckId] || {};
      return `<div class="driver-row">
        <div class="driver-av">${(esc(v.name||k)).charAt(0).toUpperCase()}</div>
        <div style="flex:1">
          <div style="font-weight:700;font-size:13px">${esc(v.name||k)}</div>
          <div style="font-size:11.5px;color:#888">${esc(v.phone||'—')} &bull; Licence: ${esc(v.licence||'—')}</div>
          <div style="font-size:11.5px;color:#888">Truck: ${esc(truck.name||v.truckId||'—')}</div>
        </div>
        <span class="tw-bdg-${v.status==='active'?'g':'r'}" style="margin-right:8px">${esc(v.status||'active')}</span>
        <button onclick="editDriver('${esc(k)}','${esc(v.name||'')}','${esc(v.phone||'')}','${esc(v.licence||'')}','${esc(v.truckId||'')}','${esc(v.status||'active')}')" class="tw-btn tw-btn-p" style="font-size:12px;padding:5px 10px;margin-right:6px">&#9998; Edit</button>
        <button onclick="deleteDriver('${esc(k)}','${esc(v.name||k)}')" class="tw-btn tw-btn-r" style="font-size:12px;padding:5px 10px">&#128465;</button>
      </div>`;
    }).join('');
    const body = `
    <div id="drv-notice"></div>
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128104;&#8205;&#128296; Drivers (${Object.keys(drivers).length})</h3>
        <button onclick="openDrvModal()" class="tw-btn tw-btn-p">&#43; Add Driver</button>
      </div>
      <div class="tw-card-bd">
        ${Object.keys(drivers).length ? rows : '<div class="tw-empty">No drivers yet. Add your first driver above.</div>'}
      </div>
    </div>
    <div id="drv-modal" class="modal-backdrop">
      <div class="modal-box">
        <div class="modal-hd"><h4 id="drv-modal-title">&#128104;&#8205;&#128296; Add Driver</h4><button onclick="closeDrvModal()" style="background:none;border:none;font-size:20px;cursor:pointer;color:#888">&times;</button></div>
        <div class="modal-bd tw-ff">
          <input type="hidden" id="drv-id"/>
          <div class="tw-grid" style="margin-bottom:12px">
            <div><label>Full Name *</label><input type="text" id="drv-name" placeholder="Driver full name"/></div>
            <div><label>Phone *</label><input type="tel" id="drv-phone" placeholder="+64 21 XXX XXXX"/></div>
          </div>
          <div class="tw-grid" style="margin-bottom:12px">
            <div><label>Licence Number</label><input type="text" id="drv-licence" placeholder="NZ licence number"/></div>
            <div><label>Assigned Truck</label><select id="drv-truck">${truckOpts}</select></div>
            <div><label>Status</label><select id="drv-status">${statusOpts}</select></div>
          </div>
        </div>
        <div class="modal-ft">
          <button onclick="closeDrvModal()" class="tw-btn tw-btn-n">Cancel</button>
          <button onclick="saveDriver()" class="tw-btn tw-btn-p">Save Driver</button>
        </div>
      </div>
    </div>
    <script>
    function showDrvNotice(msg,type){ var n=document.getElementById('drv-notice'); n.className='tw-notice '+type; n.textContent=msg; n.style.display='block'; if(type!=='err') setTimeout(function(){n.style.display='none';},3500); }
    function openDrvModal(id,name,phone,lic,truck,status){
      document.getElementById('drv-modal-title').textContent=(id?'Edit':'Add')+' Driver';
      document.getElementById('drv-id').value=id||'';
      document.getElementById('drv-name').value=name||'';
      document.getElementById('drv-phone').value=phone||'';
      document.getElementById('drv-licence').value=lic||'';
      document.getElementById('drv-truck').value=truck||'';
      document.getElementById('drv-status').value=status||'active';
      document.getElementById('drv-modal').classList.add('open');
    }
    function editDriver(id,name,phone,lic,truck,status){ openDrvModal(id,name,phone,lic,truck,status); }
    function closeDrvModal(){ document.getElementById('drv-modal').classList.remove('open'); }
    function saveDriver(){
      var data={ driverId:document.getElementById('drv-id').value||null, name:document.getElementById('drv-name').value.trim(), phone:document.getElementById('drv-phone').value.trim(), licence:document.getElementById('drv-licence').value.trim(), truckId:document.getElementById('drv-truck').value||null, status:document.getElementById('drv-status').value, t:'${te}' };
      if(!data.name||!data.phone){ showDrvNotice('Name and phone are required.','err'); return; }
      fetch('/api/towing-driver-save',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)})
        .then(r=>r.json()).then(d=>{ if(d.ok){ showDrvNotice('Driver saved.','ok'); closeDrvModal(); setTimeout(function(){window.location.reload();},1200); } else showDrvNotice('Error: '+(d.error||'Unknown'),'err'); })
        .catch(function(){ showDrvNotice('Network error.','err'); });
    }
    function deleteDriver(id,name){
      if(!confirm('Delete driver '+name+'? This cannot be undone.')) return;
      fetch('/api/towing-driver-delete',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({driverId:id,t:'${te}'})})
        .then(r=>r.json()).then(d=>{ if(d.ok){ showDrvNotice('Driver deleted.','ok'); setTimeout(function(){window.location.reload();},1200); } else showDrvNotice('Error: '+(d.error||'Unknown'),'err'); })
        .catch(function(){ showDrvNotice('Network error.','err'); });
    }
    document.getElementById('drv-modal').addEventListener('click',function(e){ if(e.target===this) closeDrvModal(); });
    </script>`;
    res.send(twPage('Drivers', renderTwNav(sess, token, 'drivers'), body));
  }).catch((e: any) => res.send(twPage('Drivers', renderTwNav(sess, token, 'drivers'), `<div class="tw-notice err">Error: ${esc(e.message)}</div>`)));
});

// ── Config (Settings) ─────────────────────────────────────────────────────────
router.get('/towing-portal/config', requireTowingAuth, (req: any, res) => {
  const sess = req.twSession;
  const token = req.twToken;
  const cid = sess.companyId;
  const te = encodeURIComponent(token);
  Promise.all([
    fbReadP(`towingConfig/${cid}`).then((d: any) => d || {}),
    fbReadP(`towingDrivers/${cid}`).then((d: any) => d || {})
  ]).then(([cfg, drivers]) => {
    const g = (k: string, def: any) => esc(String(cfg[k] !== undefined ? cfg[k] : def));
    const ch = (k: string) => cfg[k] ? 'checked' : '';
    const surcharges = cfg.surcharges || {};
    const driverOpts = `<option value="">— None —</option>` + Object.entries(drivers).map(([k, v]: any) =>
      `<option value="${k}" ${cfg.onCallDriverId===k?'selected':''}>${esc(v.name||k)}</option>`).join('');
    const hours = cfg.operatingHours || {};
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const hoursGrid = days.map(d => {
      const h = (hours as any)[d] || {};
      return `<div style="display:flex;align-items:center;gap:8px;padding:6px 0;border-bottom:1px solid #f5f5f5;flex-wrap:wrap">
        <span style="width:36px;font-weight:700;font-size:12.5px">${d}</span>
        <input type="checkbox" id="day-${d}" ${h.open?'checked':''} style="width:auto"/>
        <label for="day-${d}" style="font-size:12px;margin:0;cursor:pointer">Open</label>
        <input type="time" id="open-${d}" value="${esc(h.openTime||'08:00')}" style="width:100px;padding:4px 7px;font-size:12px;border:1px solid #ddd;border-radius:4px"/>
        <span style="font-size:12px;color:#888">to</span>
        <input type="time" id="close-${d}" value="${esc(h.closeTime||'17:00')}" style="width:100px;padding:4px 7px;font-size:12px;border:1px solid #ddd;border-radius:4px"/>
      </div>`;
    }).join('');
    const body = `
    <div id="cfg-notice"></div>
    <form onsubmit="saveConfig(event)">
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128181; Pricing</h3></div>
      <div class="tw-card-bd tw-ff">
        <div class="tw-grid">
          <div><label>Base Callout Fee ($) *</label><input type="number" id="c-callout" value="${g('calloutFee','95')}" min="0" step="0.50" required/></div>
          <div><label>Per KM Rate ($) *</label><input type="number" id="c-kmrate" value="${g('kmRate','3.50')}" min="0" step="0.10" required/></div>
          <div><label>Min Charge ($)</label><input type="number" id="c-mincharge" value="${g('minCharge','0')}" min="0" step="0.50"/></div>
        </div>
        <div style="margin-top:16px;font-size:12.5px;font-weight:700;color:#BF360C;margin-bottom:8px">Surcharges</div>
        <div class="tw-grid">
          <div><label>Motorcycle (+$)</label><input type="number" id="c-sur-moto" value="${esc(String(surcharges.motorcycle||0))}" min="0" step="0.50"/></div>
          <div><label>SUV / Van (+$)</label><input type="number" id="c-sur-suv" value="${esc(String(surcharges.suv||0))}" min="0" step="0.50"/></div>
          <div><label>Heavy Vehicle (+$)</label><input type="number" id="c-sur-heavy" value="${esc(String(surcharges.heavy||0))}" min="0" step="0.50"/></div>
          <div><label>After Hours (+$)</label><input type="number" id="c-sur-aft" value="${esc(String(surcharges.afterHours||0))}" min="0" step="0.50"/></div>
          <div><label>Public Holiday (+$)</label><input type="number" id="c-sur-ph" value="${esc(String(surcharges.publicHoliday||0))}" min="0" step="0.50"/></div>
          <div><label>Winching Fee (+$)</label><input type="number" id="c-sur-winch" value="${esc(String(surcharges.winching||0))}" min="0" step="0.50"/></div>
        </div>
      </div>
    </div>
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#127968; Operating Hours &amp; After Hours</h3></div>
      <div class="tw-card-bd">
        <div style="margin-bottom:14px">${hoursGrid}</div>
        <div style="display:flex;gap:14px;align-items:center;padding-top:8px;flex-wrap:wrap">
          <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-weight:600;font-size:13px"><input type="checkbox" id="c-aft-hours" ${ch('afterHoursEnabled')} style="width:auto"/> Accept after-hours jobs</label>
          <div class="tw-ff" style="flex:1;min-width:180px"><label>On-Call Driver (after hours)</label><select id="c-oncall">${driverOpts}</select></div>
        </div>
      </div>
    </div>
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128663; Service Area</h3></div>
      <div class="tw-card-bd tw-ff">
        <div class="tw-grid">
          <div><label>Service Area / Suburbs</label><input type="text" id="c-area" value="${g('serviceArea','')}" placeholder="e.g. Auckland CBD, North Shore, Waitakere"/></div>
          <div><label>Max Job Distance (km)</label><input type="number" id="c-maxkm" value="${g('maxDistance','50')}" min="1"/></div>
        </div>
      </div>
    </div>
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128179; Payment Options</h3></div>
      <div class="tw-card-bd">
        <div style="display:flex;flex-direction:column;gap:10px">
          <label style="display:flex;align-items:center;gap:10px;cursor:pointer;font-size:13px"><input type="checkbox" id="c-stripe" ${ch('acceptStripe')||'checked'} style="width:auto"/> Accept Stripe (online payment)</label>
          <label style="display:flex;align-items:center;gap:10px;cursor:pointer;font-size:13px"><input type="checkbox" id="c-insurance" ${ch('acceptInsurance')} style="width:auto"/> Accept insurance jobs</label>
          <label style="display:flex;align-items:center;gap:10px;cursor:pointer;font-size:13px"><input type="checkbox" id="c-cash" ${ch('acceptCash')} style="width:auto"/> Accept cash on delivery</label>
        </div>
      </div>
    </div>
    <div class="tw-card">
      <div class="tw-card-hd"><h3>&#128276; Notifications</h3></div>
      <div class="tw-card-bd tw-ff">
        <div class="tw-grid">
          <div><label>Dispatcher Email</label><input type="email" id="c-notify-email" value="${g('notifyEmail','')}" placeholder="dispatch@towingco.co.nz"/></div>
          <div><label>Dispatcher Phone (SMS)</label><input type="tel" id="c-notify-sms" value="${g('notifyPhone','')}" placeholder="+64 21 XXX XXXX"/></div>
        </div>
      </div>
    </div>
    <div style="margin-bottom:18px">
      <button type="submit" class="tw-btn tw-btn-p" style="font-size:14px;padding:10px 24px">&#10003; Save All Settings</button>
    </div>
    </form>
    <script>
    function saveConfig(e){
      e.preventDefault();
      var days=['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
      var opHours={};
      days.forEach(function(d){ opHours[d]={ open:document.getElementById('day-'+d).checked, openTime:document.getElementById('open-'+d).value, closeTime:document.getElementById('close-'+d).value }; });
      var data={
        calloutFee:parseFloat(document.getElementById('c-callout').value)||95,
        kmRate:parseFloat(document.getElementById('c-kmrate').value)||3.5,
        minCharge:parseFloat(document.getElementById('c-mincharge').value)||0,
        surcharges:{ motorcycle:parseFloat(document.getElementById('c-sur-moto').value)||0, suv:parseFloat(document.getElementById('c-sur-suv').value)||0, heavy:parseFloat(document.getElementById('c-sur-heavy').value)||0, afterHours:parseFloat(document.getElementById('c-sur-aft').value)||0, publicHoliday:parseFloat(document.getElementById('c-sur-ph').value)||0, winching:parseFloat(document.getElementById('c-sur-winch').value)||0 },
        operatingHours:opHours,
        afterHoursEnabled:document.getElementById('c-aft-hours').checked,
        onCallDriverId:document.getElementById('c-oncall').value||null,
        serviceArea:document.getElementById('c-area').value.trim(),
        maxDistance:parseInt(document.getElementById('c-maxkm').value)||50,
        acceptStripe:document.getElementById('c-stripe').checked,
        acceptInsurance:document.getElementById('c-insurance').checked,
        acceptCash:document.getElementById('c-cash').checked,
        notifyEmail:document.getElementById('c-notify-email').value.trim(),
        notifyPhone:document.getElementById('c-notify-sms').value.trim(),
        t:'${te}'
      };
      var n=document.getElementById('cfg-notice'); n.className='tw-notice warn'; n.textContent='Saving\u2026'; n.style.display='block';
      fetch('/api/towing-config-save',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)})
        .then(r=>r.json()).then(d=>{ n.className='tw-notice '+(d.ok?'ok':'err'); n.textContent=d.ok?'Settings saved successfully.':('Error: '+(d.error||'Unknown')); })
        .catch(function(){ n.className='tw-notice err'; n.textContent='Network error.'; });
    }
    </script>`;
    res.send(twPage('Settings', renderTwNav(sess, token, 'config'), body));
  }).catch((e: any) => res.send(twPage('Settings', renderTwNav(sess, token, 'config'), `<div class="tw-notice err">Error: ${esc(e.message)}</div>`)));
});

// ── API Routes ────────────────────────────────────────────────────────────────
router.post('/api/towing-fleet-save', (req, res) => {
  const token = req.body.t || '';
  const sess = twGetSession(token);
  if (!sess) return res.json({ ok: false, error: 'Not authenticated' });
  const { truckId, name, plate, type, capacity, year, status } = req.body;
  if (!name || !plate) return res.json({ ok: false, error: 'Name and plate required' });
  const cid = sess.companyId;
  const id = truckId || `truck_${Date.now()}`;
  const data: any = { name, plate, type: type || 'flatbed', capacity: parseInt(capacity) || 1, year: year || '', status: status || 'active', updatedAt: Date.now() };
  if (!truckId) data.createdAt = Date.now();
  fbWriteP(truckId ? 'PATCH' : 'PUT', `towingFleet/${cid}/${id}`, data)
    .then(() => res.json({ ok: true, truckId: id }))
    .catch((e: any) => res.json({ ok: false, error: e.message }));
});

router.post('/api/towing-fleet-delete', (req, res) => {
  const token = req.body.t || '';
  const sess = twGetSession(token);
  if (!sess) return res.json({ ok: false, error: 'Not authenticated' });
  const { truckId } = req.body;
  if (!truckId) return res.json({ ok: false, error: 'truckId required' });
  fbWriteP('DELETE', `towingFleet/${sess.companyId}/${truckId}`, null)
    .then(() => res.json({ ok: true }))
    .catch((e: any) => res.json({ ok: false, error: e.message }));
});

router.post('/api/towing-driver-save', (req, res) => {
  const token = req.body.t || '';
  const sess = twGetSession(token);
  if (!sess) return res.json({ ok: false, error: 'Not authenticated' });
  const { driverId, name, phone, licence, truckId, status } = req.body;
  if (!name || !phone) return res.json({ ok: false, error: 'Name and phone required' });
  const cid = sess.companyId;
  const id = driverId || `drv_${Date.now()}`;
  const data: any = { name, phone, licence: licence || '', truckId: truckId || null, status: status || 'active', updatedAt: Date.now() };
  if (!driverId) data.createdAt = Date.now();
  fbWriteP(driverId ? 'PATCH' : 'PUT', `towingDrivers/${cid}/${id}`, data)
    .then(() => res.json({ ok: true, driverId: id }))
    .catch((e: any) => res.json({ ok: false, error: e.message }));
});

router.post('/api/towing-driver-delete', (req, res) => {
  const token = req.body.t || '';
  const sess = twGetSession(token);
  if (!sess) return res.json({ ok: false, error: 'Not authenticated' });
  const { driverId } = req.body;
  if (!driverId) return res.json({ ok: false, error: 'driverId required' });
  fbWriteP('DELETE', `towingDrivers/${sess.companyId}/${driverId}`, null)
    .then(() => res.json({ ok: true }))
    .catch((e: any) => res.json({ ok: false, error: e.message }));
});

router.post('/api/towing-config-save', (req, res) => {
  const token = req.body.t || '';
  const sess = twGetSession(token);
  if (!sess) return res.json({ ok: false, error: 'Not authenticated' });
  const { t: _t, ...cfgData } = req.body;
  cfgData.updatedAt = Date.now();
  fbWriteP('PATCH', `towingConfig/${sess.companyId}`, cfgData)
    .then(() => res.json({ ok: true }))
    .catch((e: any) => res.json({ ok: false, error: e.message }));
});

router.post('/api/towing-job-notes', (req, res) => {
  const token = req.body.t || '';
  const sess = twGetSession(token);
  if (!sess) return res.json({ ok: false, error: 'Not authenticated' });
  const { jobId, finalMileage, actualAmount, completionNotes } = req.body;
  if (!jobId) return res.json({ ok: false, error: 'jobId required' });
  const cid = sess.companyId;
  const update: any = { updatedAt: Date.now() };
  if (finalMileage !== null && finalMileage !== undefined) update.finalMileage = parseFloat(finalMileage) || 0;
  if (actualAmount !== null && actualAmount !== undefined) update.actualAmount = parseFloat(actualAmount) || 0;
  if (completionNotes !== undefined) update.completionNotes = completionNotes || '';
  fbWriteP('PATCH', `towingJobs/${cid}/${jobId}`, update)
    .then(() => res.json({ ok: true }))
    .catch((e: any) => res.json({ ok: false, error: e.message }));
});

router.post('/api/towing-job-action', async (req, res) => {
  try {
    const token = req.body.t || '';
    const sess = twGetSession(token);
    if (!sess) return res.json({ ok: false, error: 'Not authenticated' });
    const { jobId, status, driverId, notes } = req.body;
    if (!jobId) return res.json({ ok: false, error: 'jobId required' });
    const cid = sess.companyId;

    const job = await fbReadP(`towingJobs/${cid}/${jobId}`).catch(() => null) || {};

    const update: any = { status: status || 'pending', updatedAt: Date.now() };
    if (driverId) update.driverId = driverId;
    if (notes) update.dispatchNotes = notes;
    await fbWriteP('PATCH', `towingJobs/${cid}/${jobId}`, update);

    const notifyStatuses = ['enroute', 'arrived', 'completed'];
    if (job.customerEmail && notifyStatuses.includes(status)) {
      setImmediate(async () => {
        try {
          const { client: rc, fromEmail } = await getResendClient();
          const access = await fbReadP(`towingPortalAccess/${cid}`).catch(() => ({})) || {};
          const companyName = (access as any).name || cid;
          const trackUrl = `https://taxitime.co.nz/tow/track?id=${jobId}`;
          const msgs: any = {
            enroute: {
              subj: `\u{1F69B} Your tow truck is on the way \u2014 ${companyName}`,
              head: '#E65100', icon: '\u{1F69B}', headline: 'Your Tow Truck is On the Way',
              body: `Your driver from <strong>${companyName}</strong> is now heading to your location. Keep your phone nearby \u2014 they may call before arriving.`
            },
            arrived: {
              subj: `\u2705 Your driver has arrived \u2014 ${companyName}`,
              head: '#2E7D32', icon: '\u2705', headline: 'Your Driver Has Arrived',
              body: `Your driver from <strong>${companyName}</strong> has arrived at your location.`
            },
            completed: {
              subj: `\u{1F3C1} Your tow job is complete \u2014 ${companyName}`,
              head: '#1565C0', icon: '\u{1F3C1}', headline: 'Tow Job Completed',
              body: `Your tow job with <strong>${companyName}</strong> has been completed.${job.actualAmount ? ' Total charged: <strong>$' + parseFloat(job.actualAmount).toFixed(2) + '</strong>.' : ''}`
            }
          };
          const m = msgs[status];
          if (m) {
            await rc.emails.send({
              from: fromEmail,
              to: job.customerEmail,
              subject: m.subj,
              html: `<div style="font-family:sans-serif;max-width:480px">
<div style="background:${m.head};color:#fff;padding:18px 24px;border-radius:8px 8px 0 0"><h2 style="margin:0;font-size:18px">${m.icon} ${m.headline}</h2></div>
<div style="background:#fff;padding:20px 24px;border:1px solid #eee;border-radius:0 0 8px 8px">
<p style="font-size:14px;color:#333;margin:0 0 16px">Hi <strong>${job.customerName || 'there'}</strong>, ${m.body}</p>
<table style="width:100%;border-collapse:collapse;font-size:13px;margin-bottom:16px">
<tr><td style="padding:5px 0;color:#888;width:110px">Job ID</td><td style="padding:5px 0;font-weight:600;font-family:monospace">${jobId}</td></tr>
<tr><td style="padding:5px 0;color:#888">Pickup</td><td style="padding:5px 0">${job.pickup || '—'}</td></tr>
<tr><td style="padding:5px 0;color:#888">Drop-off</td><td style="padding:5px 0">${job.dropoff || '—'}</td></tr>
</table>
<a href="${trackUrl}" style="display:inline-block;background:#E65100;color:#fff;padding:11px 22px;border-radius:6px;text-decoration:none;font-weight:700;font-size:14px">&#128249; Track Your Job &rarr;</a>
</div></div>`
            });
          }
        } catch (err: any) { console.error('[job-action-email]', status, err.message); }
      });
    }

    res.json({ ok: true });
  } catch (e: any) {
    res.json({ ok: false, error: e.message });
  }
});

// ── Public Towing Booking Page (/tow) ─────────────────────────────────────────
router.get('/tow', (req, res) => {
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Request a Tow &mdash; BookaWaka</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#FFF8F5;color:#333;font-size:14px}
.header{background:#E65100;color:#fff;padding:16px 24px;display:flex;align-items:center;gap:14px}
.header h1{font-size:20px;font-weight:700}
.header p{font-size:13px;opacity:.85;margin-top:2px}
.wrap{max-width:680px;margin:0 auto;padding:24px 16px}
.card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:18px;overflow:hidden}
.card-hd{padding:12px 18px;background:#FFF3E0;border-bottom:1px solid #FFCCBC;font-weight:700;font-size:13.5px;color:#BF360C;display:flex;align-items:center;gap:6px}
.card-bd{padding:18px}
label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
input,select,textarea{width:100%;padding:9px 12px;border:1.5px solid #ddd;border-radius:6px;font-size:13.5px;box-sizing:border-box;font-family:inherit;margin-bottom:14px}
input:focus,select:focus,textarea:focus{outline:none;border-color:#E65100}
.grid-2{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.payment-opts{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px}
.pay-opt{border:2px solid #ddd;border-radius:8px;padding:12px;cursor:pointer;transition:all .15s;text-align:center}
.pay-opt:hover{border-color:#E65100}
.pay-opt.selected{border-color:#E65100;background:#FFF3E0}
.pay-opt-icon{font-size:24px;margin-bottom:4px}
.pay-opt-label{font-size:12px;font-weight:700;color:#263238}
.pay-opt-sub{font-size:11px;color:#888;margin-top:2px}
.pay-detail{display:none;padding:12px;background:#FFF8F5;border-radius:6px;border:1px solid #FFCCBC;margin-bottom:14px}
.pay-detail.show{display:block}
.submit-btn{width:100%;padding:14px;background:#E65100;color:#fff;border:none;border-radius:8px;font-size:16px;font-weight:700;cursor:pointer;margin-top:4px}
.submit-btn:hover{background:#BF360C}
.submit-btn:disabled{background:#ccc;cursor:not-allowed}
.notice{padding:12px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32;display:block}
.notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828;display:block}
.crosssell{background:#E0F2F1;border-radius:8px;padding:16px 18px;border:1px solid #B2DFDB;margin-top:14px;display:none}
.crosssell h4{color:#00695C;font-size:14px;font-weight:700;margin-bottom:6px}
@media(max-width:520px){.grid-2,.payment-opts{grid-template-columns:1fr}}
</style>
<script src="https://js.stripe.com/v3/"></script>
<script>window.__STRIPE_PK__ = '${process.env.STRIPE_PUBLISHABLE_KEY || ''}';</script>
</head>
<body>
<div class="header">
  <div>&#128667;</div>
  <div><h1>Request a Tow</h1><p>BookaWaka Towing &mdash; Fast, reliable roadside help</p></div>
</div>
<div class="wrap">
  <div id="form-notice" class="notice"></div>
  <form id="tow-form" onsubmit="submitTow(event)">
  <div class="card">
    <div class="card-hd">&#128205; Your Location &amp; Drop-off</div>
    <div class="card-bd">
      <label>Current Location (where is the vehicle?) *</label>
      <input type="text" id="t-pickup" placeholder="Street address or describe your location" required/>
      <label>Drop-off Address *</label>
      <input type="text" id="t-dropoff" placeholder="Home, garage, towing yard, or other address" required/>
      <label>Schedule</label>
      <select id="t-schedule">
        <option value="now">Right now &mdash; I need a tow ASAP</option>
        <option value="later">Schedule for later</option>
      </select>
      <div id="schedule-time" style="display:none;margin-top:-6px">
        <label>Preferred Date &amp; Time</label>
        <input type="datetime-local" id="t-scheduledAt"/>
      </div>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">&#128663; Your Vehicle</div>
    <div class="card-bd">
      <div class="grid-2">
        <div><label>Make *</label><input type="text" id="t-make" placeholder="e.g. Toyota" required/></div>
        <div><label>Model *</label><input type="text" id="t-model" placeholder="e.g. Corolla" required/></div>
      </div>
      <div class="grid-2">
        <div><label>Year</label><input type="text" id="t-year" placeholder="e.g. 2019"/></div>
        <div><label>Colour</label><input type="text" id="t-colour" placeholder="e.g. Red"/></div>
      </div>
      <div class="grid-2">
        <div><label>Registration Plate</label><input type="text" id="t-rego" placeholder="e.g. ABC123"/></div>
        <div><label>Problem *</label>
          <select id="t-problem" required>
            <option value="">Select&hellip;</option>
            <option value="breakdown">Breakdown / Won't start</option>
            <option value="accident">Accident damage</option>
            <option value="flat-tyre">Flat tyre (needs towing)</option>
            <option value="locked-out">Keys locked inside</option>
            <option value="fuel">Run out of fuel</option>
            <option value="other">Other</option>
          </select>
        </div>
      </div>
      <div id="problem-notes-wrap" style="display:none">
        <label>Describe the problem</label>
        <textarea id="t-problem-notes" rows="2" placeholder="Any extra details&hellip;"></textarea>
      </div>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">&#128100; Your Details</div>
    <div class="card-bd">
      <div class="grid-2">
        <div><label>Full Name *</label><input type="text" id="t-name" placeholder="Your name" required/></div>
        <div><label>Phone Number *</label><input type="tel" id="t-phone" placeholder="+64 21 XXX XXXX" required/></div>
      </div>
      <label>Email (for updates)</label>
      <input type="email" id="t-email" placeholder="you@example.com"/>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">&#128179; Payment</div>
    <div class="card-bd">
      <div class="payment-opts">
        <div class="pay-opt" id="pay-stripe" onclick="selectPayment('stripe')">
          <div class="pay-opt-icon">&#128179;</div>
          <div class="pay-opt-label">Pay Now</div>
          <div class="pay-opt-sub">Card via Stripe (upfront)</div>
        </div>
        <div class="pay-opt" id="pay-insurance" onclick="selectPayment('insurance')">
          <div class="pay-opt-icon">&#127962;</div>
          <div class="pay-opt-label">My Insurance</div>
          <div class="pay-opt-sub">Your own insurer pays</div>
        </div>
        <div class="pay-opt" id="pay-thirdparty" onclick="selectPayment('thirdparty')">
          <div class="pay-opt-icon">&#128104;&#8205;&#128665;</div>
          <div class="pay-opt-label">Third Party</div>
          <div class="pay-opt-sub">Other driver's insurance</div>
        </div>
        <div class="pay-opt" id="pay-cash" onclick="selectPayment('cash')">
          <div class="pay-opt-icon">&#128181;</div>
          <div class="pay-opt-label">Pay Later / Cash</div>
          <div class="pay-opt-sub">Pay driver on arrival</div>
        </div>
      </div>
      <input type="hidden" id="t-payment" value=""/>
      <div id="ins-detail" class="pay-detail">
        <div class="grid-2">
          <div><label>Your Insurance Company</label><input type="text" id="t-ins-co" placeholder="e.g. AA Insurance"/></div>
          <div><label>Policy Number</label><input type="text" id="t-ins-policy" placeholder="Your policy number"/></div>
        </div>
      </div>
      <div id="tp-detail" class="pay-detail">
        <p style="font-size:12px;color:#888;margin-bottom:10px">Enter the other driver's insurance details if they gave them.</p>
        <div class="grid-2">
          <div><label>Other Driver's Insurer</label><input type="text" id="t-tp-ins" placeholder="e.g. State Insurance"/></div>
          <div><label>Other Driver's Policy No.</label><input type="text" id="t-tp-policy" placeholder="If known"/></div>
        </div>
        <div class="grid-2">
          <div><label>Other Driver's Plate</label><input type="text" id="t-tp-plate" placeholder="e.g. XYZ789"/></div>
          <div><label>Police Report No.</label><input type="text" id="t-tp-police" placeholder="If applicable"/></div>
        </div>
      </div>
      <div id="stripe-detail" class="pay-detail">
        <div id="stripe-card-element" style="padding:12px;border:1.5px solid #ddd;border-radius:6px;margin-bottom:4px"></div>
        <div id="stripe-card-error" style="color:#C62828;font-size:12.5px;margin-top:4px;display:none"></div>
      </div>
    </div>
  </div>
  <button type="submit" class="submit-btn" id="submit-btn">&#128667; Request Tow</button>
  </form>
  <div id="crosssell-box" class="crosssell" style="display:none">
    <h4>&#128661; Need a taxi or rideshare instead?</h4>
    <p style="font-size:13px;color:#444">Book a ride while you wait for your tow truck.</p>
    <a href="https://taxitime.co.nz" style="display:inline-block;margin-top:10px;background:#E65100;color:#fff;padding:9px 18px;border-radius:6px;font-weight:700;font-size:13px;text-decoration:none">Book a Ride &rarr;</a>
  </div>
</div>
<script>
var selectedPayment = '';
var stripeInstance = null;
var stripeCardElement = null;
if(window.__STRIPE_PK__){
  stripeInstance = Stripe(window.__STRIPE_PK__);
  var elements = stripeInstance.elements();
  stripeCardElement = elements.create('card',{style:{base:{fontSize:'14px',color:'#263238'}}});
}
document.getElementById('t-schedule').addEventListener('change',function(){ document.getElementById('schedule-time').style.display=this.value==='later'?'block':'none'; });
document.getElementById('t-problem').addEventListener('change',function(){ document.getElementById('problem-notes-wrap').style.display=this.value==='other'?'block':'none'; });
function selectPayment(type){
  selectedPayment=type;
  ['stripe','insurance','thirdparty','cash'].forEach(function(t){ document.getElementById('pay-'+t).classList.remove('selected'); });
  document.getElementById('pay-'+type).classList.add('selected');
  document.getElementById('t-payment').value=type;
  document.getElementById('ins-detail').classList.toggle('show',type==='insurance');
  document.getElementById('tp-detail').classList.toggle('show',type==='thirdparty');
  document.getElementById('stripe-detail').classList.toggle('show',type==='stripe');
  if(type==='stripe'&&stripeCardElement&&!stripeCardElement._mounted){
    stripeCardElement.mount('#stripe-card-element');
    stripeCardElement._mounted=true;
  }
}
function collectFormData(extra){
  return Object.assign({
    customerName:document.getElementById('t-name').value.trim(),
    customerPhone:document.getElementById('t-phone').value.trim(),
    customerEmail:document.getElementById('t-email').value.trim(),
    pickup:document.getElementById('t-pickup').value.trim(),
    dropoff:document.getElementById('t-dropoff').value.trim(),
    vehicleMake:document.getElementById('t-make').value.trim(),
    vehicleModel:document.getElementById('t-model').value.trim(),
    vehicleYear:document.getElementById('t-year').value.trim(),
    vehicleColour:document.getElementById('t-colour').value.trim(),
    vehicleRego:document.getElementById('t-rego').value.trim().toUpperCase(),
    problem:document.getElementById('t-problem').value,
    problemNotes:document.getElementById('t-problem-notes')?document.getElementById('t-problem-notes').value.trim():'',
    paymentType:selectedPayment,
    schedule:document.getElementById('t-schedule').value,
    scheduledAt:document.getElementById('t-scheduledAt').value||null,
    insuranceCompany:document.getElementById('t-ins-co').value.trim(),
    policyNo:document.getElementById('t-ins-policy').value.trim(),
    thirdPartyInsurer:document.getElementById('t-tp-ins').value.trim(),
    thirdPartyPolicy:document.getElementById('t-tp-policy').value.trim(),
    thirdPartyPlate:document.getElementById('t-tp-plate').value.trim().toUpperCase(),
    policeReportNo:document.getElementById('t-tp-police').value.trim()
  }, extra||{});
}
function doSubmitRequest(data, btn){
  fetch('/api/tow-request',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)})
    .then(function(r){ return r.json(); }).then(function(d){
      if(d.ok){
        document.getElementById('tow-form').style.display='none';
        var n=document.getElementById('form-notice'); n.className='notice ok';
        var trackUrl = window.location.origin+'/tow/track?id='+d.jobId;
        n.innerHTML='<strong style="font-size:15px">&#10003; Tow request submitted!</strong>'
          +'<div style="margin:10px 0 4px">Booking ref: <strong style="font-size:15px;color:#1B5E20">'+d.jobId+'</strong></div>'
          +'<div style="margin:12px 0;display:flex;gap:8px;flex-wrap:wrap">'
            +'<a href="'+trackUrl+'" target="_blank" style="background:#E65100;color:#fff;padding:9px 16px;border-radius:6px;text-decoration:none;font-weight:700;font-size:13px">&#128249; Track Your Job</a>'
          +'</div>'
          +'<div style="font-size:12px">We\'ll assign a tow truck shortly and send you an email.</div>';
        n.style.display='block';
        document.getElementById('crosssell-box').style.display='block';
        window.scrollTo(0,0);
      } else {
        var n=document.getElementById('form-notice'); n.className='notice err'; n.textContent='Error: '+(d.error||'Please try again.'); n.style.display='block';
        btn.disabled=false; btn.textContent='&#128667; Request Tow';
      }
    }).catch(function(){
      var n=document.getElementById('form-notice'); n.className='notice err'; n.textContent='Network error \u2014 please try again.'; n.style.display='block';
      btn.disabled=false; btn.textContent='&#128667; Request Tow';
    });
}
function submitTow(e){
  e.preventDefault();
  if(!selectedPayment){ alert('Please select a payment method.'); return; }
  var btn=document.getElementById('submit-btn'); btn.disabled=true; btn.textContent='Submitting\u2026';
  if(selectedPayment==='stripe'){
    if(!stripeInstance||!stripeCardElement){
      var n=document.getElementById('form-notice'); n.className='notice err'; n.textContent='Stripe not loaded. Please refresh and try again.'; n.style.display='block';
      btn.disabled=false; btn.textContent='&#128667; Request Tow'; return;
    }
    btn.textContent='Processing payment\u2026';
    fetch('/api/towing-payment-intent',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({})})
      .then(function(r){ return r.json(); }).then(function(d){
        if(!d.ok){ throw new Error(d.error||'Payment setup failed'); }
        var name = document.getElementById('t-name').value.trim();
        return stripeInstance.confirmCardPayment(d.clientSecret,{payment_method:{card:stripeCardElement,billing_details:{name:name}}});
      }).then(function(result){
        if(result.error){
          var errEl=document.getElementById('stripe-card-error'); errEl.textContent=result.error.message; errEl.style.display='block';
          btn.disabled=false; btn.textContent='&#128667; Request Tow'; return;
        }
        btn.textContent='Submitting\u2026';
        doSubmitRequest(collectFormData({stripePaymentIntentId:result.paymentIntent.id}), btn);
      }).catch(function(err){
        var n=document.getElementById('form-notice'); n.className='notice err'; n.textContent='Payment error: '+err.message; n.style.display='block';
        btn.disabled=false; btn.textContent='&#128667; Request Tow';
      });
    return;
  }
  doSubmitRequest(collectFormData(), btn);
}
</script>
</body></html>`);
});

// ── Public Towing Booking API ──────────────────────────────────────────────────
router.post('/api/tow-request', async (req, res) => {
  try {
    const {
      customerName, customerPhone, customerEmail,
      pickup, dropoff, vehicleMake, vehicleModel, vehicleYear, vehicleColour, vehicleRego,
      problem, problemNotes, paymentType, schedule, scheduledAt,
      insuranceCompany, policyNo,
      thirdPartyInsurer, thirdPartyPolicy, thirdPartyPlate, policeReportNo
    } = req.body;

    if (!customerName || !customerPhone || !pickup || !dropoff || !vehicleMake || !vehicleModel || !problem || !paymentType) {
      return res.json({ ok: false, error: 'Missing required fields' });
    }

    const now = Date.now();
    const jobId = `TW${now}`;
    const record: any = {
      jobId, source: 'towing',
      customerName, customerPhone, customerEmail: customerEmail || '',
      pickup, dropoff,
      vehicleMake, vehicleModel, vehicleYear: vehicleYear || '', vehicleColour: vehicleColour || '', vehicleRego: vehicleRego || '',
      problem, problemNotes: problemNotes || '',
      paymentType, schedule: schedule || 'now', scheduledAt: scheduledAt || null,
      insuranceCompany: insuranceCompany || '', policyNo: policyNo || '',
      thirdPartyInsurer: thirdPartyInsurer || '', thirdPartyPolicy: thirdPartyPolicy || '',
      thirdPartyPlate: thirdPartyPlate || '', policeReportNo: policeReportNo || '',
      status: 'pending', createdAt: now, updatedAt: now
    };

    await fbWriteP('PUT', `towingJobs/unassigned/${jobId}`, record);
    await fbWriteP('PUT', `towingJobIndex/${jobId}`, { companyId: 'unassigned', createdAt: now, status: 'pending', paymentType });

    setImmediate(async () => {
      try {
        const { client: rc, fromEmail } = await getResendClient();
        const dtStr = new Date(now).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
        const baseUrl = 'https://' + (process.env.REPLIT_DOMAINS || '').split(',')[0];
        await rc.emails.send({
          from: fromEmail,
          to: fromEmail,
          subject: `\u{1F69B} New Tow Request \u2014 ${record.customerName} \u2014 ${record.problem}`,
          html: `<div style="font-family:sans-serif;max-width:520px">
<h2 style="color:#E65100">\u{1F69B} New Tow Request Received</h2>
<p style="color:#888;font-size:13px;margin-bottom:16px">${dtStr} NZT &nbsp;&bull;&nbsp; Job ID: <code>${jobId}</code></p>
<table style="width:100%;border-collapse:collapse;font-size:14px">
<tr><td style="padding:6px 0;color:#555;width:130px">Customer</td><td style="padding:6px 0;font-weight:600">${record.customerName} &mdash; ${record.customerPhone}</td></tr>
<tr><td style="padding:6px 0;color:#555">Pickup</td><td style="padding:6px 0">${record.pickup}</td></tr>
<tr><td style="padding:6px 0;color:#555">Drop-off</td><td style="padding:6px 0">${record.dropoff}</td></tr>
<tr><td style="padding:6px 0;color:#555">Vehicle</td><td style="padding:6px 0">${record.vehicleYear} ${record.vehicleMake} ${record.vehicleModel}${record.vehicleRego ? ' (' + record.vehicleRego + ')' : ''}</td></tr>
<tr><td style="padding:6px 0;color:#555">Problem</td><td style="padding:6px 0;font-weight:600;color:#C62828">${record.problem}${record.problemNotes ? ' \u2014 ' + record.problemNotes : ''}</td></tr>
<tr><td style="padding:6px 0;color:#555">Payment</td><td style="padding:6px 0">${(record.paymentType || '').toUpperCase()}</td></tr>
</table>
<div style="margin-top:18px"><a href="${baseUrl}/SA-Towing.aspx#unassigned" style="background:#E65100;color:#fff;padding:10px 20px;border-radius:6px;text-decoration:none;font-weight:600;font-size:14px">Assign Job Now \u2192</a></div>
</div>`
        });
      } catch (emailErr: any) {
        console.error('[tow-notify] email error:', emailErr.message);
      }
    });

    const { stripePaymentIntentId } = req.body;
    if (paymentType === 'stripe' && stripePaymentIntentId) {
      setImmediate(async () => {
        try {
          const stripe = getStripe();
          const pi = await stripe.paymentIntents.retrieve(stripePaymentIntentId);
          const confirmed = pi.status === 'succeeded';
          await fbWriteP('PATCH', `towingJobs/unassigned/${jobId}`, { paymentConfirmed: confirmed, paymentStatus: pi.status });
          await fbWriteP('PATCH', `towingJobIndex/${jobId}`, { paymentConfirmed: confirmed });
        } catch (ve: any) { console.error('[tow-verify]', ve.message); }
      });
    }

    res.json({ ok: true, jobId });
  } catch (e: any) {
    res.json({ ok: false, error: e.message });
  }
});

// ── Towing Payment Intent ──────────────────────────────────────────────────────
router.post('/api/towing-payment-intent', async (_req, res) => {
  try {
    const stripe = getStripe();
    const cfg = await fbReadP('bwConfig/towing') || {};
    const baseFeeCents = Math.round((parseFloat(cfg.baseCalloutFee) || 95) * 100);
    const pi = await stripe.paymentIntents.create({
      amount: baseFeeCents,
      currency: 'nzd',
      description: 'BookaWaka Towing — Base Callout Fee',
      metadata: { source: 'towing_public', createdAt: String(Date.now()) }
    });
    res.json({ ok: true, clientSecret: pi.client_secret, amountCents: baseFeeCents });
  } catch (e: any) {
    res.json({ ok: false, error: e.message });
  }
});

// ── Towing Job Assignment (SA) ─────────────────────────────────────────────────
router.post('/api/towing-assign-job', async (req, res) => {
  try {
    const { jobId, cid, note } = req.body;
    if (!jobId || !cid) return res.json({ ok: false, error: 'Missing jobId or cid' });

    const job = await fbReadP(`towingJobs/unassigned/${jobId}`);
    if (!job) return res.json({ ok: false, error: 'Job not found in unassigned queue' });

    const now = Date.now();
    const updated = Object.assign({}, job, { status: 'assigned', assignedAt: now, assignedToCid: cid, dispatchNote: note || '', updatedAt: now });

    await fbWriteP('PUT', `towingJobs/${cid}/${jobId}`, updated);
    await fbWriteP('DELETE', `towingJobs/unassigned/${jobId}`, null);
    await fbWriteP('PATCH', `towingJobIndex/${jobId}`, { companyId: cid, status: 'assigned', assignedAt: now });

    const access = await fbReadP(`towingPortalAccess/${cid}`) || {};
    const cfg = await fbReadP(`towingConfig/${cid}`) || {};
    const companyName = (access as any).name || cid;
    const dispatchEmail = (cfg as any).notifyEmail || (access as any).email || '';

    if (dispatchEmail) {
      setImmediate(async () => {
        try {
          const { client: rc, fromEmail } = await getResendClient();
          const dtStr = new Date(now).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
          await rc.emails.send({
            from: fromEmail,
            to: dispatchEmail,
            subject: `\u{1F69B} New Tow Job Assigned \u2014 ${job.customerName} \u2014 ${job.pickup}`,
            html: `<div style="font-family:sans-serif;max-width:520px">
<h2 style="color:#E65100">\u{1F69B} New Job Assigned to You</h2>
<p style="color:#888;font-size:13px">${dtStr} NZT &nbsp;&bull;&nbsp; Job ID: <code>${jobId}</code></p>
${note ? `<div style="background:#FFF3E0;border-left:4px solid #E65100;padding:10px 14px;border-radius:4px;margin:12px 0;font-size:13px"><strong>Dispatcher Note:</strong> ${note}</div>` : ''}
<table style="width:100%;border-collapse:collapse;font-size:14px;margin-top:12px">
<tr><td style="padding:6px 0;color:#555;width:130px">Customer</td><td style="padding:6px 0;font-weight:600">${job.customerName} &mdash; ${job.customerPhone}</td></tr>
<tr><td style="padding:6px 0;color:#555">Pickup</td><td style="padding:6px 0">${job.pickup}</td></tr>
<tr><td style="padding:6px 0;color:#555">Drop-off</td><td style="padding:6px 0">${job.dropoff}</td></tr>
<tr><td style="padding:6px 0;color:#555">Vehicle</td><td style="padding:6px 0">${job.vehicleYear || ''} ${job.vehicleMake} ${job.vehicleModel}${job.vehicleRego ? ' (' + job.vehicleRego + ')' : ''}</td></tr>
<tr><td style="padding:6px 0;color:#555">Problem</td><td style="padding:6px 0;font-weight:600;color:#C62828">${job.problem}${job.problemNotes ? ' \u2014 ' + job.problemNotes : ''}</td></tr>
<tr><td style="padding:6px 0;color:#555">Payment</td><td style="padding:6px 0">${(job.paymentType || '').toUpperCase()}</td></tr>
</table>
</div>`
          });
        } catch (err: any) { console.error('[assign-email] dispatcher:', err.message); }
      });
    }

    if (job.customerEmail) {
      setImmediate(async () => {
        try {
          const { client: rc, fromEmail } = await getResendClient();
          const trackUrl = `https://taxitime.co.nz/tow/track?id=${jobId}`;
          await rc.emails.send({
            from: fromEmail,
            to: job.customerEmail,
            subject: `\u2705 Your tow is confirmed \u2014 ${companyName} is on the way`,
            html: `<div style="font-family:sans-serif;max-width:480px">
<h2 style="color:#2E7D32">\u2705 Your Tow Request is Confirmed</h2>
<p style="font-size:14px;color:#333">Hi <strong>${job.customerName}</strong>, your tow has been assigned to <strong>${companyName}</strong>. They'll be in touch shortly.</p>
<table style="width:100%;border-collapse:collapse;font-size:14px;margin:16px 0">
<tr><td style="padding:6px 0;color:#555;width:120px">Job ID</td><td style="padding:6px 0;font-weight:600;font-family:monospace">${jobId}</td></tr>
<tr><td style="padding:6px 0;color:#555">Pickup</td><td style="padding:6px 0">${job.pickup}</td></tr>
<tr><td style="padding:6px 0;color:#555">Drop-off</td><td style="padding:6px 0">${job.dropoff}</td></tr>
<tr><td style="padding:6px 0;color:#555">Towing Co.</td><td style="padding:6px 0">${companyName}</td></tr>
</table>
<div style="margin:18px 0"><a href="${trackUrl}" style="background:#E65100;color:#fff;padding:11px 22px;border-radius:6px;text-decoration:none;font-weight:700;font-size:14px">&#128249; Track Your Job \u2192</a></div>
</div>`
          });
        } catch (err: any) { console.error('[assign-email] customer:', err.message); }
      });
    }

    res.json({ ok: true, companyName });
  } catch (e: any) {
    res.json({ ok: false, error: e.message });
  }
});

// ── Join as Towing Operator ────────────────────────────────────────────────────
router.get('/join-towing', (_req, res) => {
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Join as a Towing Operator &mdash; BookaWaka</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#FFF8F5;color:#333;font-size:14px}
.header{background:#E65100;color:#fff;padding:20px 24px;text-align:center}
.header h1{font-size:22px;font-weight:700;margin-bottom:4px}
.header p{font-size:13px;opacity:.85}
.wrap{max-width:640px;margin:0 auto;padding:28px 16px}
.card{background:#fff;border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,.1);padding:28px;margin-bottom:20px}
.card h2{font-size:16px;font-weight:700;color:#E65100;margin-bottom:18px;display:flex;align-items:center;gap:8px}
label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
input,select,textarea{width:100%;padding:9px 12px;border:1.5px solid #ddd;border-radius:6px;font-size:13.5px;font-family:inherit;margin-bottom:14px}
input:focus,select:focus,textarea:focus{outline:none;border-color:#E65100}
.grid-2{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.check-row{display:flex;align-items:center;gap:10px;margin-bottom:14px}
.check-row input{width:auto;margin:0}
.submit-btn{width:100%;padding:14px;background:#E65100;color:#fff;border:none;border-radius:8px;font-size:15px;font-weight:700;cursor:pointer;transition:.15s}
.submit-btn:hover{background:#BF360C}
.submit-btn:disabled{background:#aaa;cursor:not-allowed}
.notice{padding:14px 18px;border-radius:8px;margin-bottom:18px;font-size:14px;display:none}
.notice.ok{background:#E8F5E9;color:#1B5E20;border:1px solid #A5D6A7}
.notice.err{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.benefits{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:24px}
.benefit{background:#fff;border-radius:8px;padding:14px;border:1px solid #FFCCBC;text-align:center}
.benefit .icon{font-size:26px;margin-bottom:6px}
.benefit p{font-size:12px;color:#555}
@media(max-width:520px){.grid-2,.benefits{grid-template-columns:1fr}}
</style>
</head>
<body>
<div class="header">
  <div style="font-size:40px;margin-bottom:8px">&#128667;</div>
  <h1>Join as a Towing Operator</h1>
  <p>Partner with BookaWaka and grow your towing business</p>
</div>
<div class="wrap">
  <div class="benefits">
    <div class="benefit"><div class="icon">&#128241;</div><p>Jobs delivered to your phone in real-time</p></div>
    <div class="benefit"><div class="icon">&#128179;</div><p>Fast online payments, weekly payouts</p></div>
    <div class="benefit"><div class="icon">&#128202;</div><p>Your own operator dashboard &amp; reports</p></div>
    <div class="benefit"><div class="icon">&#127942;</div><p>Join NZ's fastest-growing transport platform</p></div>
  </div>
  <div id="form-notice" class="notice"></div>
  <form id="join-form" onsubmit="submitForm(event)">
    <div class="card">
      <h2>&#127970; Company Details</h2>
      <label>Company Name *</label>
      <input type="text" id="j-company" placeholder="Your towing company name" required/>
      <div class="grid-2">
        <div><label>City / Region *</label><input type="text" id="j-city" placeholder="e.g. Auckland" required/></div>
        <div><label>Business Number (GST)</label><input type="text" id="j-regno" placeholder="GST or NZBN if applicable"/></div>
      </div>
      <label>Website (optional)</label>
      <input type="url" id="j-website" placeholder="https://yourcompany.co.nz"/>
    </div>
    <div class="card">
      <h2>&#128667; Fleet Information</h2>
      <div class="grid-2">
        <div><label>Number of Tow Trucks *</label><input type="number" id="j-fleet" min="1" placeholder="e.g. 3" required/></div>
        <div><label>Operating Hours</label><input type="text" id="j-hours" placeholder="e.g. 7am\u20137pm Mon\u2013Sun"/></div>
      </div>
      <label>Truck Types (select all that apply)</label>
      <div style="display:flex;flex-wrap:wrap;gap:10px;margin-bottom:14px" id="truck-types">
        <label style="display:flex;align-items:center;gap:6px;font-weight:400;font-size:13px;cursor:pointer"><input type="checkbox" value="flatbed"> Flatbed</label>
        <label style="display:flex;align-items:center;gap:6px;font-weight:400;font-size:13px;cursor:pointer"><input type="checkbox" value="wheel-lift"> Wheel Lift</label>
        <label style="display:flex;align-items:center;gap:6px;font-weight:400;font-size:13px;cursor:pointer"><input type="checkbox" value="integrated"> Integrated</label>
        <label style="display:flex;align-items:center;gap:6px;font-weight:400;font-size:13px;cursor:pointer"><input type="checkbox" value="heavy-duty"> Heavy Duty</label>
        <label style="display:flex;align-items:center;gap:6px;font-weight:400;font-size:13px;cursor:pointer"><input type="checkbox" value="motorcycle"> Motorcycle</label>
      </div>
      <div class="check-row">
        <input type="checkbox" id="j-afterhours"/>
        <label for="j-afterhours" style="margin:0;font-weight:400;font-size:13px;cursor:pointer">We offer after-hours / 24/7 service</label>
      </div>
    </div>
    <div class="card">
      <h2>&#128100; Contact Person</h2>
      <div class="grid-2">
        <div><label>Contact Name *</label><input type="text" id="j-name" placeholder="Your full name" required/></div>
        <div><label>Mobile Number *</label><input type="tel" id="j-phone" placeholder="+64 21 XXX XXXX" required/></div>
      </div>
      <label>Email Address *</label>
      <input type="email" id="j-email" placeholder="dispatcher@yourcompany.co.nz" required/>
      <label>Anything else you'd like to tell us?</label>
      <textarea id="j-message" rows="3" placeholder="Service area, specialisations, questions\u2026"></textarea>
    </div>
    <button type="submit" class="submit-btn" id="join-btn">&#128667; Submit Application</button>
  </form>
</div>
<script>
function submitForm(e){
  e.preventDefault();
  var btn=document.getElementById('join-btn'); btn.disabled=true; btn.textContent='Submitting\u2026';
  var trucks=[];
  document.querySelectorAll('#truck-types input:checked').forEach(function(cb){ trucks.push(cb.value); });
  var data={
    company:document.getElementById('j-company').value.trim(),
    city:document.getElementById('j-city').value.trim(),
    regNo:document.getElementById('j-regno').value.trim(),
    website:document.getElementById('j-website').value.trim(),
    towingFleetSize:document.getElementById('j-fleet').value.trim(),
    operatingHours:document.getElementById('j-hours').value.trim(),
    truckTypes:trucks.join(', '),
    afterHours:document.getElementById('j-afterhours').checked,
    contactName:document.getElementById('j-name').value.trim(),
    phone:document.getElementById('j-phone').value.trim(),
    email:document.getElementById('j-email').value.trim(),
    message:document.getElementById('j-message').value.trim()
  };
  fetch('/api/join-towing',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)})
    .then(function(r){ return r.json(); }).then(function(d){
      if(d.ok){
        document.getElementById('join-form').style.display='none';
        var n=document.getElementById('form-notice'); n.className='notice ok';
        n.innerHTML='<strong>\u2705 Application received!</strong><br>Thanks, <strong>'+d.name+'</strong> \u2014 our team will review your application and be in touch within 1\u20132 business days.';
        n.style.display='block'; window.scrollTo(0,0);
      } else {
        var n=document.getElementById('form-notice'); n.className='notice err'; n.textContent='Error: '+(d.error||'Please try again.'); n.style.display='block';
        btn.disabled=false; btn.textContent='&#128667; Submit Application';
      }
    }).catch(function(){
      var n=document.getElementById('form-notice'); n.className='notice err'; n.textContent='Network error \u2014 please try again.'; n.style.display='block';
      btn.disabled=false; btn.textContent='&#128667; Submit Application';
    });
}
</script>
</body></html>`);
});

router.post('/api/join-towing', async (req, res) => {
  try {
    const { company, city, regNo, website, towingFleetSize, operatingHours, truckTypes, afterHours, contactName, phone, email, message } = req.body;
    if (!company || !city || !contactName || !phone || !email) {
      return res.json({ ok: false, error: 'Please fill in all required fields.' });
    }
    const now = Date.now();
    const reqId = `TW_APP_${now}`;
    const record: any = {
      serviceType: 'towing',
      company, name: contactName, email, phone,
      area: city, country: 'New Zealand',
      regNo: regNo || '', website: website || '',
      towingFleetSize: towingFleetSize || '',
      operatingHours: operatingHours || '',
      truckTypes: Array.isArray(truckTypes) ? truckTypes.join(', ') : (truckTypes || ''),
      afterHours: !!afterHours,
      message: message || '',
      status: 'pending',
      submittedAt: now
    };
    await fbWriteP('PUT', `onboardRequests/${reqId}`, record);

    setImmediate(async () => {
      try {
        const { client: rc, fromEmail } = await getResendClient();
        const baseUrl = 'https://' + (process.env.REPLIT_DOMAINS || '').split(',')[0];
        await rc.emails.send({
          from: fromEmail,
          to: fromEmail,
          subject: `\u{1F69B} New Towing Operator Application \u2014 ${company} (${city})`,
          html: `<div style="font-family:sans-serif;max-width:480px">
<h2 style="color:#E65100">\u{1F69B} New Towing Operator Application</h2>
<table style="width:100%;border-collapse:collapse;font-size:14px;margin-top:12px">
<tr><td style="padding:6px 0;color:#555;width:140px">Company</td><td style="padding:6px 0;font-weight:600">${company}</td></tr>
<tr><td style="padding:6px 0;color:#555">Location</td><td style="padding:6px 0">${city}, NZ</td></tr>
<tr><td style="padding:6px 0;color:#555">Contact</td><td style="padding:6px 0">${contactName} &mdash; ${phone}</td></tr>
<tr><td style="padding:6px 0;color:#555">Email</td><td style="padding:6px 0">${email}</td></tr>
<tr><td style="padding:6px 0;color:#555">Fleet Size</td><td style="padding:6px 0">${towingFleetSize} tow trucks</td></tr>
<tr><td style="padding:6px 0;color:#555">Truck Types</td><td style="padding:6px 0">${record.truckTypes || '—'}</td></tr>
<tr><td style="padding:6px 0;color:#555">After-Hours</td><td style="padding:6px 0">${afterHours ? '\u2713 Yes' : 'No'}</td></tr>
${message ? `<tr><td style="padding:6px 0;color:#555">Message</td><td style="padding:6px 0">${message}</td></tr>` : ''}
</table>
<div style="margin-top:18px"><a href="${baseUrl}/SA-Onboard.aspx" style="background:#E65100;color:#fff;padding:10px 20px;border-radius:6px;text-decoration:none;font-weight:600">Review Application \u2192</a></div>
</div>`
        });
      } catch (err: any) { console.error('[join-towing] notify error:', err.message); }
    });

    res.json({ ok: true, name: contactName });
  } catch (e: any) {
    res.json({ ok: false, error: e.message });
  }
});

// ── Public Job Tracking Page (/tow/track?id=) ──────────────────────────────────
router.get('/tow/track', async (req, res) => {
  const jobId = ((req.query.id as string) || '').trim();
  if (!jobId) return res.send(`<!DOCTYPE html><html><head><meta charset="utf-8"><title>Track Tow Job</title></head><body style="font-family:sans-serif;padding:40px;text-align:center"><h2 style="color:#E65100">No job ID provided</h2><p>Please check your confirmation email for the tracking link.</p></body></html>`);

  const trackCSS = `*{box-sizing:border-box;margin:0;padding:0}body{font-family:'Segoe UI',system-ui,sans-serif;background:#FFF8F5;color:#333;min-height:100vh}
.hdr{background:#E65100;color:#fff;padding:16px 24px;text-align:center}.hdr h1{font-size:18px;font-weight:700}.hdr p{font-size:12px;opacity:.8;margin-top:2px}
.wrap{max-width:560px;margin:32px auto;padding:0 16px}
.card{background:#fff;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,.1);padding:24px;margin-bottom:18px}
.job-id{font-family:monospace;font-size:13px;color:#E65100;font-weight:700;background:#FFF3E0;padding:4px 10px;border-radius:4px;display:inline-block;margin-bottom:16px}
.info-row{display:flex;gap:8px;padding:7px 0;border-bottom:1px solid #f5f5f5;font-size:13.5px}
.info-row:last-child{border-bottom:none}.info-lbl{color:#888;width:100px;flex-shrink:0}
.stepper{display:flex;flex-direction:column;gap:0}
.step{display:flex;align-items:flex-start;gap:14px;padding:12px 0;position:relative}
.step:not(:last-child)::after{content:'';position:absolute;left:15px;top:40px;width:2px;height:calc(100% - 16px);background:#e0e0e0}
.step.done::after{background:#E65100}
.step-dot{width:32px;height:32px;border-radius:50%;border:3px solid #e0e0e0;background:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;z-index:1}
.step.done .step-dot{border-color:#E65100;background:#E65100;color:#fff}
.step.active .step-dot{border-color:#E65100;background:#FFF3E0;color:#E65100;animation:pulse-dot 1.5s infinite}
@keyframes pulse-dot{0%,100%{box-shadow:0 0 0 0 rgba(230,81,0,.4)}50%{box-shadow:0 0 0 6px rgba(230,81,0,0)}}
.step-info{padding-top:5px}.step-title{font-weight:700;font-size:13.5px;color:#333}
.step.done .step-title{color:#E65100}.step.active .step-title{color:#E65100}
.step-sub{font-size:12px;color:#aaa;margin-top:2px}
.badge{display:inline-block;padding:3px 10px;border-radius:10px;font-size:11.5px;font-weight:700}
.badge-pend{background:#FFF3E0;color:#E65100}.badge-asgn{background:#E3F2FD;color:#1565C0}
.badge-done{background:#E8F5E9;color:#2E7D32}.badge-cancel{background:#FFEBEE;color:#C62828}
.err{text-align:center;padding:40px;color:#C62828}`;

  try {
    const idx = await fbReadP(`towingJobIndex/${jobId}`);
    if (!idx) return res.send(`<!DOCTYPE html><html><head><meta charset="utf-8"><title>Job Not Found</title><style>${trackCSS}</style></head><body><div class="hdr"><h1>&#128667; BookaWaka Towing</h1></div><div class="wrap"><div class="card err"><h2>Job Not Found</h2><p style="margin-top:8px;color:#888">No tow job found with ID <strong>${esc(jobId)}</strong>. Please check your confirmation email.</p></div></div></body></html>`);

    const cid = idx.companyId || 'unassigned';
    const jobPath = cid === 'unassigned' ? `towingJobs/unassigned/${jobId}` : `towingJobs/${cid}/${jobId}`;
    const [job, access] = await Promise.all([
      fbReadP(jobPath).then((d: any) => d || {}),
      cid !== 'unassigned' ? fbReadP(`towingPortalAccess/${cid}`).then((d: any) => d || {}) : Promise.resolve({})
    ]);
    const companyName = (access as any).name || (cid !== 'unassigned' ? cid : 'Being allocated...');
    const status = job.status || idx.status || 'pending';
    const fmtDt = (ts: number) => ts ? new Date(ts).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' }) : '—';

    const statusOrder = ['pending','assigned','enroute','arrived','loading','dropoff','completed','cancelled'];
    const statusIdx = statusOrder.indexOf(status);
    const isDone = (s: string) => statusIdx >= statusOrder.indexOf(s);
    const isActive = (s: string) => status === s;

    const stepClass = (done: boolean, active: boolean) => done ? 'step done' : active ? 'step active' : 'step';
    const stepDot = (done: boolean, active: boolean) => done ? '&#10003;' : active ? '&#9654;' : '';

    const cancelled = status === 'cancelled';
    const steps = cancelled ? `<div class="step"><div class="step-dot" style="border-color:#C62828;background:#FFEBEE;color:#C62828">&#10007;</div><div class="step-info"><div class="step-title" style="color:#C62828">Job Cancelled</div><div class="step-sub">This tow job has been cancelled.</div></div></div>` :
      [
        { key:'pending',   done: true,                              active: status==='pending',   title:'Request Submitted',  sub:`Received ${fmtDt(job.createdAt)}` },
        { key:'assigned',  done: isDone('assigned'),                active: isActive('assigned'),  title:'Assigned to Company', sub: isDone('assigned') ? companyName : 'Waiting for dispatch' },
        { key:'enroute',   done: isDone('enroute'),                 active: isActive('enroute'),   title:'Driver En Route',    sub: isDone('enroute') ? `Heading to ${job.pickup||'your location'}` : 'Not yet dispatched' },
        { key:'arrived',   done: isDone('arrived'),                 active: isActive('arrived'),   title:'Arrived On Scene',   sub: isDone('arrived') ? 'Driver is at your location' : '' },
        { key:'loading',   done: isDone('loading')||isDone('dropoff'), active: isActive('loading')||isActive('dropoff'), title:'Vehicle Being Loaded', sub: '' },
        { key:'completed', done: isDone('completed'),               active: false,                title:'Completed',          sub: isDone('completed') ? `Finished ${fmtDt(job.updatedAt)}` : '' }
      ].map(st => `<div class="${stepClass(st.done,st.active)}"><div class="step-dot">${stepDot(st.done,st.active)}</div><div class="step-info"><div class="step-title">${st.title}</div>${st.sub?`<div class="step-sub">${esc(st.sub)}</div>`:''}</div></div>`).join('');

    const payBadge: any = { stripe:'<span class="badge badge-done">&#128179; Paid (Stripe)</span>', insurance:'<span class="badge badge-asgn">&#127962; Insurance</span>', thirdparty:'<span class="badge badge-pend">3rd Party Ins.</span>', cash:'<span class="badge" style="background:#F3E5F5;color:#6A1B9A">&#128181; Cash on Arrival</span>' };

    res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Track Your Tow \u2014 ${esc(jobId)}</title>
<style>${trackCSS}</style>
</head><body>
<div class="hdr"><h1>&#128667; BookaWaka Towing \u2014 Job Tracker</h1><p>Live status for your tow request</p></div>
<div class="wrap">
  <div class="card">
    <div class="job-id">Job #${esc(jobId)}</div>
    ${job.customerName ? `<div class="info-row"><span class="info-lbl">Customer</span><span>${esc(job.customerName)}</span></div>` : ''}
    ${job.pickup ? `<div class="info-row"><span class="info-lbl">Pickup</span><span>${esc(job.pickup)}</span></div>` : ''}
    ${job.dropoff ? `<div class="info-row"><span class="info-lbl">Drop-off</span><span>${esc(job.dropoff)}</span></div>` : ''}
    ${job.vehicleMake ? `<div class="info-row"><span class="info-lbl">Vehicle</span><span>${esc((job.vehicleYear||'')+' '+job.vehicleMake+' '+job.vehicleModel+(job.vehicleRego?' ('+job.vehicleRego+')':''))}</span></div>` : ''}
    ${payBadge[job.paymentType||''] ? `<div class="info-row"><span class="info-lbl">Payment</span><span>${payBadge[job.paymentType||'']}</span></div>` : ''}
    ${cid!=='unassigned'&&companyName ? `<div class="info-row"><span class="info-lbl">Towing Co.</span><span style="font-weight:600">${esc(companyName)}</span></div>` : ''}
  </div>
  <div class="card">
    <h3 style="font-size:14px;font-weight:700;color:#E65100;margin-bottom:16px">&#128249; Job Status</h3>
    <div class="stepper">${steps}</div>
  </div>
  <p style="text-align:center;font-size:12px;color:#aaa;margin-top:8px">Page auto-refreshes every 60 seconds &bull; Booking ref: <code>${esc(jobId)}</code></p>
</div>
<script>setTimeout(function(){ location.reload(); }, 60000);</script>
</body></html>`);
  } catch (e: any) {
    res.send(`<!DOCTYPE html><html><head><meta charset="utf-8"><style>${trackCSS}</style></head><body><div class="hdr"><h1>&#128667; BookaWaka Towing</h1></div><div class="wrap"><div class="card err"><p>Error loading job: ${esc(e.message)}</p></div></div></body></html>`);
  }
});

export default router;
