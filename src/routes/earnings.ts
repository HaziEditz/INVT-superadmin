import { Router } from 'express';
import { fbRead, fbWrite, fbReadP, fbWriteP } from '../firebase';
import { esc } from '../utils';

const router = Router();

const FIREBASE_WEB_API_KEY = 'AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA';
const https = require('https');

async function firebaseSignIn(email: string, password: string): Promise<string | null> {
  return new Promise((resolve) => {
    const body = JSON.stringify({ email, password, returnSecureToken: true });
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      port: 443,
      path: '/v1/accounts:signInWithPassword?key=' + FIREBASE_WEB_API_KEY,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) }
    };
    const req = https.request(opts, (resp: any) => {
      let raw = '';
      resp.on('data', (c: any) => raw += c);
      resp.on('end', () => {
        try {
          const d = JSON.parse(raw);
          resolve(d.idToken || null);
        } catch { resolve(null); }
      });
    });
    req.on('error', () => resolve(null));
    req.write(body);
    req.end();
  });
}

async function verifyFirebaseToken(idToken: string): Promise<string | null> {
  return new Promise((resolve) => {
    const body = JSON.stringify({ idToken });
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      port: 443,
      path: '/v1/accounts:lookup?key=' + FIREBASE_WEB_API_KEY,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) }
    };
    const req = https.request(opts, (resp: any) => {
      let raw = '';
      resp.on('data', (c: any) => raw += c);
      resp.on('end', () => {
        try {
          const d = JSON.parse(raw);
          resolve(d.users && d.users[0] && d.users[0].localId ? d.users[0].localId : null);
        } catch { resolve(null); }
      });
    });
    req.on('error', () => resolve(null));
    req.write(body);
    req.end();
  });
}

function _tsMs(raw: any): number {
  if (!raw) return 0;
  if (typeof raw === 'number') return raw;
  const n = Date.parse(raw as string);
  return isNaN(n) ? 0 : n;
}

async function calcCompanyEarnings(cid: string, sinceTs: number) {
  const since = sinceTs || 0;
  const safeRead = (p: string) => fbReadP(p).catch(() => null);
  const [sc, hailJobs, allBookings, foodOrds, freightOrds] = await Promise.all([
    safeRead('superClients/' + cid),
    safeRead('completedJobs/' + cid),
    safeRead('allbookings/' + cid),
    safeRead('foodOrders/' + cid),
    safeRead('freightOrders/' + cid)
  ]);
  const commPct = parseFloat((sc && sc.commissionPct) || 15);

  // Merge hail + dispatched taxi trips; completedJobs wins on duplicate key
  const mergedTaxi: Record<string, any> = {};
  Object.entries(allBookings || {}).forEach(([k, t]: [string, any]) => {
    const s = (t.status || t.Status || '').toLowerCase();
    if (s === 'completed') mergedTaxi[k] = t;
  });
  Object.entries(hailJobs || {}).forEach(([k, t]: [string, any]) => {
    mergedTaxi[k] = t;
  });

  let taxiGross = 0, taxiCom = 0, taxiNet = 0, taxiTrips = 0;
  Object.values(mergedTaxi).forEach((t: any) => {
    const ts = _tsMs(t.completedAt_ISO || t.CompletedAt_ISO || t.completedAt || t.createdAt || 0);
    if (ts > since) {
      const fare = parseFloat(t.fare || t.FinalFare || t.meterFare || 0);
      const com = fare * commPct / 100;
      taxiGross += fare; taxiCom += com; taxiNet += (fare - com); taxiTrips++;
    }
  });

  let foodGross = 0, foodCom = 0, foodNet = 0, foodOrders = 0;
  Object.values(foodOrds || {}).forEach((o: any) => {
    if (o.status !== 'delivered') return;
    const ts = _tsMs(o.completedAt || o.deliveredAt || o.createdAt || 0);
    if (ts > since) {
      foodGross += parseFloat(o.subtotal || o.amount || 0);
      foodCom += parseFloat(o.foodCommission || o.commission || 0);
      foodNet += parseFloat(o.restaurantPayout || 0);
      foodOrders++;
    }
  });

  let freightGross = 0, freightCom = 0, freightNet = 0, freightJobs = 0;
  Object.values(freightOrds || {}).forEach((o: any) => {
    if (o.deliveryConfirmed !== true && o.status !== 'delivered') return;
    const ts = _tsMs(o.deliveredAt || o.completedAt || o.createdAt || 0);
    if (ts > since) {
      freightGross += parseFloat(o.amount || 0);
      freightCom += parseFloat(o.freightCommission || o.commission || 0);
      freightNet += parseFloat(o.freightPayout || 0);
      freightJobs++;
    }
  });
  const totalNet = taxiNet + foodNet + freightNet;
  return {
    companyId: cid,
    companyName: (sc && sc.name) || ('Company ' + cid),
    stripeConnectId: (sc && sc.stripeConnectId) || null,
    payoutSchedule: (sc && sc.payoutSchedule) || 'weekly',
    lastPayoutAt: (sc && sc.lastPayoutAt) || 0,
    commissionPct: commPct,
    totalNet, totalGross: taxiGross + foodGross + freightGross,
    totalCommission: taxiCom + foodCom + freightCom,
    taxi: { gross: taxiGross, commission: taxiCom, net: taxiNet, trips: taxiTrips },
    food: { gross: foodGross, commission: foodCom, net: foodNet, orders: foodOrders },
    freight: { gross: freightGross, commission: freightCom, net: freightNet, jobs: freightJobs }
  };
}

function requireCompanyEarningsAuth(req: any, res: any, next: any) {
  const uid = req.session && req.session.companyEarningsUid;
  const cid = req.session && req.session.companyEarningsCid;
  if (!uid || !cid) return res.redirect('/company-earnings-portal');
  req.cepUid = uid; req.cepCid = cid; req.cepName = (req.session.companyEarningsName || cid);
  next();
}

// ── Login page ─────────────────────────────────────────────────────────────────
router.get('/company-earnings-portal', (req, res) => {
  const err = (req.query.err as string) || '';
  const errMsgs: Record<string, string> = {
    invalid: 'Invalid email or password.',
    missing: 'Please enter your email and password.',
    nodata: 'Account not found.',
    session: 'Session expired.'
  };
  const errHtml = err ? `<div style="background:#FFEBEE;color:#C62828;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px;border-left:4px solid #C62828">${esc(errMsgs[err] || err)}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Company Earnings Portal — BookaWaka</title>
<style>*{box-sizing:border-box;margin:0;padding:0}
body{background:linear-gradient(135deg,#0D47A1,#1565C0);min-height:100vh;display:flex;align-items:center;justify-content:center;font-family:'Segoe UI',system-ui,sans-serif}
.box{background:#fff;border-radius:10px;padding:40px;width:400px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25)}
h1{font-size:22px;color:#0D47A1;margin-bottom:4px}.sub{color:#888;font-size:13px;margin-bottom:28px}
label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
input{width:100%;padding:10px 12px;border:1px solid #ddd;border-radius:6px;font-size:14px;margin-bottom:18px}
input:focus{outline:none;border-color:#1565C0;box-shadow:0 0 0 3px rgba(21,101,192,.1)}
button{width:100%;padding:12px;background:#1565C0;color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:600;cursor:pointer}
button:hover{background:#0D47A1}.hint{text-align:center;font-size:12px;color:#aaa;margin-top:18px}</style>
</head><body><div class="box">
  <h1>&#128188; Company Earnings</h1>
  <p class="sub">BookaWaka &mdash; Operator Portal</p>
  ${errHtml}
  <form method="POST" action="/api/company-earnings-login">
    <label>Email Address</label>
    <input type="email" name="email" required autocomplete="email" placeholder="operator@yourcompany.com"/>
    <label>Password</label>
    <input type="password" name="password" required autocomplete="current-password"/>
    <button type="submit">Sign In</button>
  </form>
  <p class="hint">Contact your BookaWaka administrator for access.</p>
</div></body></html>`);
});

router.post('/api/company-earnings-login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.redirect('/company-earnings-portal?err=missing');
  try {
    const idToken = await firebaseSignIn(email, password);
    if (!idToken) return res.redirect('/company-earnings-portal?err=invalid');
    const uid = await verifyFirebaseToken(idToken);
    if (!uid) return res.redirect('/company-earnings-portal?err=nodata');
    const clients = await fbReadP('superClients');
    let matchCid: string | null = null, matchName: string | null = null;
    for (const [cid, sc] of Object.entries(clients || {}) as [string, any][]) {
      const access = await fbReadP('companyPortalAccess/' + cid);
      if (access && (access.uid === uid || access.email === email)) { matchCid = cid; matchName = sc.name || cid; break; }
    }
    if (!matchCid) return res.redirect('/company-earnings-portal?err=nodata');
    (req as any).session.companyEarningsUid = uid;
    (req as any).session.companyEarningsCid = matchCid;
    (req as any).session.companyEarningsName = matchName;
    res.redirect('/company-earnings-portal/dashboard');
  } catch (e) { res.redirect('/company-earnings-portal?err=invalid'); }
});

router.get('/company-earnings-portal/dashboard', requireCompanyEarningsAuth, async (req: any, res) => {
  const cid = req.cepCid, name = req.cepName;
  try {
    const sc = await fbReadP('superClients/' + cid);
    const earnings = await calcCompanyEarnings(cid, (sc && sc.lastPayoutAt) || 0);
    const payoutsRaw = await fbReadP('companyPayouts/' + cid);
    const payouts = Object.values(payoutsRaw || {}).sort((a: any, b: any) => (b.triggeredAt || 0) - (a.triggeredAt || 0)).slice(0, 10);
    const schedule = (sc && sc.payoutSchedule) || 'weekly';
    const lastPayout = (sc && sc.lastPayoutAt) ? new Date(sc.lastPayoutAt).toLocaleDateString('en-NZ', { day: '2-digit', month: 'short', year: 'numeric' }) : 'Never';
    const fmtAmt = (v: any) => '$' + parseFloat(v || 0).toFixed(2);
    const payoutRows = (payouts as any[]).map(p => {
      const dt = p.triggeredAt ? new Date(p.triggeredAt).toLocaleDateString('en-NZ', { day: '2-digit', month: 'short', year: 'numeric' }) : '—';
      const bk = p.breakdown || {};
      return `<tr>
        <td>${dt}</td>
        <td style="color:#2E7D32;font-weight:700">${fmtAmt(p.amount)}</td>
        <td><span style="background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7">PAID</span></td>
        <td style="font-size:11.5px;color:#666">Taxi ${fmtAmt(bk.taxi && bk.taxi.net)} · Food ${fmtAmt(bk.food && bk.food.net)} · Freight ${fmtAmt(bk.freight && bk.freight.net)}</td>
        <td style="font-family:monospace;font-size:11px;color:#999">${p.stripeTransferId || '—'}</td>
      </tr>`;
    }).join('') || '<tr><td colspan="5" style="color:#aaa;text-align:center;padding:18px">No payouts yet</td></tr>';
    const subDeduct = parseFloat((sc && sc.subscriptionDeductPending) || 0);
    const netAfterSub = earnings.totalNet - subDeduct;
    res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(name)} Earnings — BookaWaka</title>
<style>*{box-sizing:border-box;margin:0;padding:0}
body{background:#F3F6FB;font-family:'Segoe UI',system-ui,sans-serif;color:#222}
.hd{background:#0D47A1;color:#fff;padding:16px 28px;display:flex;align-items:center;justify-content:space-between}
.hd h1{font-size:17px;font-weight:700}.hd a{color:#90CAF9;font-size:13px;text-decoration:none}
.wrap{max-width:960px;margin:28px auto;padding:0 20px}
.stats{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:14px;margin-bottom:24px}
.stat{background:#fff;border-radius:8px;padding:16px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1)}
.stat .lbl{font-size:11px;color:#888;font-weight:500;margin-bottom:4px;text-transform:uppercase;letter-spacing:.4px}
.stat .val{font-size:24px;font-weight:800;color:#0D47A1}
.stat.green .val{color:#2E7D32}.stat.orange .val{color:#E65100}.stat.red .val{color:#C62828}
.card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:20px;overflow:hidden}
.card-hd{background:#0D47A1;color:#fff;padding:12px 18px;font-size:14px;font-weight:700}
.card-bd{padding:16px 18px}
.breakdown{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:16px}
.bk-box{background:#F0F7FF;border-radius:6px;padding:12px 14px;text-align:center;border:1px solid #BBDEFB}
.bk-box h4{font-size:12px;color:#1565C0;font-weight:700;margin-bottom:8px}
.bk-row{display:flex;justify-content:space-between;font-size:12px;color:#555;padding:2px 0}
.bk-row .bk-net{font-weight:700;color:#2E7D32}
table.ep-tbl{width:100%;border-collapse:collapse;font-size:13px}
.ep-tbl th{background:#E3F2FD;padding:9px 12px;text-align:left;font-weight:700;color:#0D47A1;border-bottom:2px solid #BBDEFB}
.ep-tbl td{padding:8px 12px;border-bottom:1px solid #f5f5f5}
.ep-tbl tr:hover td{background:#FFFDE7}
.info-bar{background:#E3F2FD;border:1px solid #BBDEFB;border-radius:6px;padding:12px 16px;font-size:13px;color:#1565C0;margin-bottom:16px;display:flex;align-items:center;gap:8px}
${subDeduct > 0 ? '.sub-notice{background:#FFF8E1;border:1px solid #FFE082;border-radius:6px;padding:12px 16px;font-size:13px;color:#E65100;margin-bottom:16px}' : ''}
</style></head>
<body>
<div class="hd"><h1>&#128188; ${esc(name)} — Earnings Dashboard</h1><a href="/api/company-earnings-logout">Sign Out</a></div>
<div class="wrap">
  <div class="info-bar">&#128197; Payout schedule: <strong>${schedule.charAt(0).toUpperCase() + schedule.slice(1)}</strong> &nbsp;|&nbsp; Last payout: <strong>${lastPayout}</strong> &nbsp;|&nbsp; ${sc && sc.stripeConnectId ? '&#9989; Stripe Connected' : '&#9888;&#65039; Stripe not connected — contact BookaWaka'}</div>
  ${subDeduct > 0 ? `<div class="sub-notice">&#128274; Subscription fee deduction pending: <strong>$${subDeduct.toFixed(2)}</strong> will be withheld from your next payout.</div>` : ''}
  <div class="stats">
    <div class="stat"><div class="lbl">Total Pending</div><div class="val">${fmtAmt(earnings.totalNet)}</div></div>
    <div class="stat"><div class="lbl">Net After Subscription</div><div class="val green">${fmtAmt(netAfterSub < 0 ? 0 : netAfterSub)}</div></div>
    <div class="stat orange"><div class="lbl">BookaWaka Commission</div><div class="val">${fmtAmt(earnings.totalCommission)}</div></div>
    <div class="stat"><div class="lbl">Gross Revenue</div><div class="val">${fmtAmt(earnings.totalGross)}</div></div>
  </div>
  <div class="card">
    <div class="card-hd">Earnings Breakdown — Since Last Payout</div>
    <div class="card-bd">
      <div class="breakdown">
        <div class="bk-box"><h4>&#128661; Taxi</h4>
          <div class="bk-row"><span>Trips</span><span>${earnings.taxi.trips}</span></div>
          <div class="bk-row"><span>Gross</span><span>${fmtAmt(earnings.taxi.gross)}</span></div>
          <div class="bk-row"><span>Commission (${earnings.commissionPct}%)</span><span style="color:#E65100">-${fmtAmt(earnings.taxi.commission)}</span></div>
          <div class="bk-row"><span>Net</span><span class="bk-net">${fmtAmt(earnings.taxi.net)}</span></div>
        </div>
        <div class="bk-box"><h4>&#127829; Food Delivery</h4>
          <div class="bk-row"><span>Orders</span><span>${earnings.food.orders}</span></div>
          <div class="bk-row"><span>Gross</span><span>${fmtAmt(earnings.food.gross)}</span></div>
          <div class="bk-row"><span>Commission</span><span style="color:#E65100">-${fmtAmt(earnings.food.commission)}</span></div>
          <div class="bk-row"><span>Net</span><span class="bk-net">${fmtAmt(earnings.food.net)}</span></div>
        </div>
        <div class="bk-box"><h4>&#128666; Freight</h4>
          <div class="bk-row"><span>Deliveries</span><span>${earnings.freight.jobs}</span></div>
          <div class="bk-row"><span>Gross</span><span>${fmtAmt(earnings.freight.gross)}</span></div>
          <div class="bk-row"><span>Commission</span><span style="color:#E65100">-${fmtAmt(earnings.freight.commission)}</span></div>
          <div class="bk-row"><span>Net</span><span class="bk-net">${fmtAmt(earnings.freight.net)}</span></div>
        </div>
      </div>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">Payout History</div>
    <div class="card-bd" style="padding:0">
      <table class="ep-tbl">
        <thead><tr><th>Date</th><th>Amount</th><th>Status</th><th>Breakdown</th><th>Stripe ID</th></tr></thead>
        <tbody>${payoutRows}</tbody>
      </table>
    </div>
  </div>
</div></body></html>`);
  } catch (e: any) { res.send('<p>Error: ' + esc(e.message) + '</p>'); }
});

router.get('/api/company-earnings-logout', (req, res) => {
  if ((req as any).session) {
    delete (req as any).session.companyEarningsUid;
    delete (req as any).session.companyEarningsCid;
    delete (req as any).session.companyEarningsName;
  }
  res.redirect('/company-earnings-portal');
});

// ── Company Payout APIs ────────────────────────────────────────────────────────
router.get('/api/sa-company-payout-summary', async (req, res) => {
  try {
    const clients = await fbReadP('superClients');
    if (!clients) return res.json({ companies: [] });
    const cids = Object.keys(clients);
    const results = await Promise.all(cids.map(async (cid: string) => {
      const sc = (clients as any)[cid];
      const sinceTs = sc.lastPayoutAt || 0;
      return calcCompanyEarnings(cid, sinceTs);
    }));
    const payoutsAll = await fbReadP('companyPayouts');
    const history: Record<string, any[]> = {};
    Object.entries(payoutsAll || {}).forEach(([cid, pMap]: [string, any]) => {
      history[cid] = Object.values(pMap).sort((a: any, b: any) => (b.triggeredAt || 0) - (a.triggeredAt || 0)).slice(0, 5);
    });
    res.json({ ok: true, companies: results, history });
  } catch (e: any) { res.json({ error: e.message }); }
});

router.post('/api/sa-trigger-company-payout', async (req, res) => {
  const { companyId, notes } = req.body;
  if (!companyId) return res.json({ error: 'companyId required' });
  try {
    const sc = await fbReadP('superClients/' + companyId);
    if (!sc) return res.json({ error: 'Company not found' });
    const stripeConnectId = sc.stripeConnectId;
    if (!stripeConnectId) return res.json({ error: 'No Stripe Connect account linked to this company' });
    const sinceTs = sc.lastPayoutAt || 0;
    const earnings = await calcCompanyEarnings(companyId, sinceTs);
    if (earnings.totalNet <= 0) return res.json({ error: 'No pending earnings to pay out' });
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    const transfer = await stripe.transfers.create({
      amount: Math.round(earnings.totalNet * 100),
      currency: 'nzd',
      destination: stripeConnectId,
      metadata: { companyId, type: 'company_payout', schedule: sc.payoutSchedule || 'manual', notes: notes || '' }
    });
    const payoutId = 'payout_' + Date.now();
    const now = Date.now();
    await Promise.all([
      fbWriteP('PUT', `companyPayouts/${companyId}/${payoutId}`, {
        amount: earnings.totalNet, grossAmount: earnings.totalGross, commission: earnings.totalCommission,
        breakdown: { taxi: earnings.taxi, food: earnings.food, freight: earnings.freight },
        stripeTransferId: transfer.id, triggeredAt: now, status: 'paid', notes: notes || '',
        schedule: sc.payoutSchedule || 'manual'
      }),
      fbWriteP('PATCH', `superClients/${companyId}`, { lastPayoutAt: now })
    ]);
    res.json({ ok: true, amount: earnings.totalNet, stripeTransferId: transfer.id, breakdown: earnings });
  } catch (e: any) { res.json({ error: e.message }); }
});

router.post('/api/sa-batch-company-payouts', async (req, res) => {
  const { schedule } = req.body;
  try {
    const clients = await fbReadP('superClients');
    if (!clients) return res.json({ ok: true, results: [] });
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    const results: any[] = [];
    for (const [cid, sc] of Object.entries(clients) as [string, any][]) {
      if (schedule && sc.payoutSchedule !== schedule) continue;
      if (!sc.stripeConnectId) { results.push({ companyId: cid, name: sc.name, status: 'skipped', reason: 'no Stripe Connect' }); continue; }
      const earnings = await calcCompanyEarnings(cid, sc.lastPayoutAt || 0);
      if (earnings.totalNet <= 0) { results.push({ companyId: cid, name: sc.name, status: 'skipped', reason: 'no pending earnings' }); continue; }
      try {
        const transfer = await stripe.transfers.create({
          amount: Math.round(earnings.totalNet * 100), currency: 'nzd', destination: sc.stripeConnectId,
          metadata: { companyId: cid, type: 'company_payout', schedule: sc.payoutSchedule || schedule || 'batch' }
        });
        const now = Date.now();
        await Promise.all([
          fbWriteP('PUT', `companyPayouts/${cid}/payout_${now}`, {
            amount: earnings.totalNet, breakdown: { taxi: earnings.taxi, food: earnings.food, freight: earnings.freight },
            stripeTransferId: transfer.id, triggeredAt: now, status: 'paid', schedule: sc.payoutSchedule || schedule
          }),
          fbWriteP('PATCH', `superClients/${cid}`, { lastPayoutAt: now })
        ]);
        results.push({ companyId: cid, name: sc.name, amount: earnings.totalNet, status: 'paid', stripeTransferId: transfer.id });
      } catch (se: any) { results.push({ companyId: cid, name: sc.name, status: 'error', reason: se.message }); }
    }
    res.json({ ok: true, results, total: results.length, paid: results.filter(r => r.status === 'paid').length });
  } catch (e: any) { res.json({ error: e.message }); }
});

router.post('/api/sa-set-company-payout-schedule', async (req, res) => {
  const { companyId, schedule, stripeConnectId } = req.body;
  if (!companyId) return res.json({ error: 'companyId required' });
  const patch: any = {};
  if (schedule) patch.payoutSchedule = schedule;
  if (stripeConnectId !== undefined) patch.stripeConnectId = stripeConnectId;
  try {
    await fbWriteP('PATCH', 'superClients/' + companyId, patch);
    res.json({ ok: true });
  } catch (e: any) { res.json({ error: e.message }); }
});

// ── Subscription Billing APIs ──────────────────────────────────────────────────
router.get('/api/sa-subscription-summary', async (req, res) => {
  try {
    const [clients, packages, billingMap] = await Promise.all([fbReadP('superClients'), fbReadP('superPackages'), fbReadP('companyBilling')]);
    const pkgMap = packages || {};
    const billing = billingMap || {};
    const companies = Object.entries(clients || {}).map(([cid, sc]: [string, any]) => {
      const b = (billing as any)[cid] || {};
      const pkgId = b.packageId || sc.packageId || '';
      const pkg = (pkgMap as any)[pkgId] || null;
      const bt = pkg ? (pkg.billingType || 'per_car_monthly') : 'per_car_monthly';
      const fleet = parseInt(b.contractedFleet || sc.fleetSize || sc.driverCount || 1);
      const overrideRate = (b.pricePerCarOverride !== undefined && b.pricePerCarOverride !== null && b.pricePerCarOverride !== '') ? parseFloat(b.pricePerCarOverride) : null;
      let pricePerCar = 0, monthlyFee = 0, minMonth = 0;
      if (bt === 'flat_annual') { monthlyFee = parseFloat(pkg ? pkg.flatPrice : 0) / 12; }
      else if (bt === 'flat_monthly') { monthlyFee = parseFloat(pkg ? pkg.flatPrice : 0); }
      else {
        pricePerCar = overrideRate !== null ? overrideRate : parseFloat(sc.monthlyOverride || (pkg && (pkg.pricePerCar || pkg.monthlyPrice)) || 0);
        minMonth = parseFloat((pkg && (pkg.minimumMonthly || pkg.minMonthly)) || 0);
        monthlyFee = Math.max(pricePerCar * fleet, minMonth);
      }
      return {
        companyId: cid, name: sc.name, packageId: pkgId, packageName: pkg ? pkg.name : 'No package',
        pricePerCar, fleetSize: fleet, monthlyFee, minMonth,
        stripeCustomerId: sc.stripeCustomerId || null,
        stripeConnectId: sc.stripeConnectId || null,
        nextBillingAt: sc.nextBillingAt || null,
        lastBilledAt: sc.lastBilledAt || null,
        subscriptionStatus: sc.subscriptionStatus || 'active',
        deductFromPayout: !!sc.deductFromPayout
      };
    });
    res.json({ ok: true, companies });
  } catch (e: any) { res.json({ error: e.message }); }
});

router.post('/api/sa-charge-subscription', async (req, res) => {
  const { companyId, deductFromPayout } = req.body;
  if (!companyId) return res.json({ error: 'companyId required' });
  try {
    const [sc, packages, billingData] = await Promise.all([fbReadP('superClients/' + companyId), fbReadP('superPackages'), fbReadP('companyBilling/' + companyId)]);
    if (!sc) return res.json({ error: 'Company not found' });
    const b = billingData || {};
    const pkgId = (b as any).packageId || sc.packageId || '';
    const pkg = (packages || {} as any)[pkgId] || null;
    const bt = pkg ? (pkg.billingType || 'per_car_monthly') : 'per_car_monthly';
    const fleet = parseInt((b as any).contractedFleet || sc.fleetSize || sc.driverCount || 1);
    const overrideRate = ((b as any).pricePerCarOverride !== undefined && (b as any).pricePerCarOverride !== null && (b as any).pricePerCarOverride !== '') ? parseFloat((b as any).pricePerCarOverride) : null;
    let monthlyFee: number;
    if (bt === 'flat_annual') { monthlyFee = parseFloat(pkg ? pkg.flatPrice : 0) / 12; }
    else if (bt === 'flat_monthly') { monthlyFee = parseFloat(pkg ? pkg.flatPrice : 0); }
    else {
      const pricePerCar = overrideRate !== null ? overrideRate : parseFloat(sc.monthlyOverride || (pkg && (pkg.pricePerCar || pkg.monthlyPrice)) || 0);
      const minMonth = parseFloat((pkg && (pkg.minimumMonthly || pkg.minMonthly)) || 0);
      monthlyFee = Math.max(pricePerCar * fleet, minMonth);
    }
    if (monthlyFee <= 0) return res.json({ error: 'Monthly fee is $0 — check package assignment' });
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    const now = Date.now();
    let chargeResult: any = null;
    if (deductFromPayout || sc.deductFromPayout) {
      await fbWriteP('PATCH', `superClients/${companyId}`, {
        subscriptionDeductPending: (parseFloat(sc.subscriptionDeductPending || 0) + monthlyFee),
        lastBilledAt: now, nextBillingAt: now + 30 * 24 * 60 * 60 * 1000,
        subscriptionStatus: 'deducted_from_payout', status: 'active'
      });
      chargeResult = { method: 'deduct_from_payout', amount: monthlyFee };
    } else if (sc.stripeCustomerId) {
      const paymentIntents = await stripe.paymentIntents.create({
        amount: Math.round(monthlyFee * 100), currency: 'nzd',
        customer: sc.stripeCustomerId, confirm: true, off_session: true,
        metadata: { companyId, type: 'subscription', packageId: sc.packageId || '' }
      });
      await fbWriteP('PATCH', `superClients/${companyId}`, {
        lastBilledAt: now, nextBillingAt: now + 30 * 24 * 60 * 60 * 1000,
        subscriptionStatus: 'paid', lastStripeChargeId: paymentIntents.id, status: 'active'
      });
      chargeResult = { method: 'stripe_charge', amount: monthlyFee, stripeId: paymentIntents.id };
    } else {
      return res.json({ error: 'No Stripe customer ID and deductFromPayout not set. Link a Stripe customer or enable deduction from payout.' });
    }
    res.json({ ok: true, companyId, monthlyFee, ...chargeResult });
  } catch (e: any) { res.json({ error: e.message }); }
});

router.post('/api/sa-set-subscription-config', async (req, res) => {
  const { companyId, stripeCustomerId, deductFromPayout, monthlyOverride, subscriptionStatus } = req.body;
  if (!companyId) return res.json({ error: 'companyId required' });
  const patch: any = {};
  if (stripeCustomerId !== undefined) patch.stripeCustomerId = stripeCustomerId || null;
  if (deductFromPayout !== undefined) patch.deductFromPayout = !!deductFromPayout;
  if (monthlyOverride !== undefined && monthlyOverride !== null && monthlyOverride !== '') patch.monthlyOverride = parseFloat(monthlyOverride);
  if (subscriptionStatus) {
    patch.subscriptionStatus = subscriptionStatus;
    // Keep superClients/{cid}/status in sync so dispatch app trial banner clears
    if (subscriptionStatus === 'suspended') patch.status = 'suspended';
    else if (['active', 'paid', 'deducted_from_payout'].includes(subscriptionStatus)) patch.status = 'active';
  }
  try {
    await fbWriteP('PATCH', 'superClients/' + companyId, patch);
    res.json({ ok: true });
  } catch (e: any) { res.json({ error: e.message }); }
});

// ── Driver Pay APIs ────────────────────────────────────────────────────────────
router.post('/api/sa-taxi-driver-pay', async (req, res) => {
  const { companyId, model, amount, schedule } = req.body;
  if (!companyId) return res.json({ error: 'companyId required' });
  try {
    await fbWriteP('PATCH', `taxiConfig/driverPay/${companyId}`, {
      model: model || 'flat', amount: parseFloat(amount || 0), schedule: schedule || 'weekly', updatedAt: Date.now()
    });
    res.json({ ok: true });
  } catch (e: any) { res.json({ error: e.message }); }
});

router.post('/api/sa-taxi-driver-batch-payout', async (req, res) => {
  const { companyId } = req.body;
  if (!companyId) return res.json({ error: 'companyId required' });
  try {
    const [drivers, earnings, payCfg] = await Promise.all([
      fbReadP('drivers/' + companyId),
      fbReadP('driverEarnings/taxi/' + companyId),
      fbReadP('taxiConfig/driverPay/' + companyId)
    ]);
    if (!payCfg) return res.json({ error: 'No driver pay config set for this company' });
    if (payCfg.schedule === 'instant') return res.json({ error: 'Company uses instant payouts' });
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    const results: any[] = [];
    for (const [did, e] of Object.entries(earnings || {}) as [string, any][]) {
      const pending = parseFloat(e.pendingAmount || 0);
      if (pending <= 0) continue;
      const drv = ((drivers || {}) as any)[did] || {};
      if (!drv.stripeExpressId) { results.push({ driverId: did, name: drv.name, status: 'skipped', reason: 'no Stripe account' }); continue; }
      try {
        const transfer = await stripe.transfers.create({
          amount: Math.round(pending * 100), currency: 'nzd', destination: drv.stripeExpressId,
          metadata: { companyId, driverId: did, type: 'taxi_driver_payout' }
        });
        await fbWriteP('PATCH', `driverEarnings/taxi/${companyId}/${did}`, { pendingAmount: 0, updatedAt: Date.now() });
        await fbWriteP('PUT', `driverPayouts/taxi/${companyId}/payout_${Date.now()}_${did}`, {
          driverId: did, amount: pending, stripeTransferId: transfer.id, triggeredAt: Date.now(), status: 'paid'
        });
        results.push({ driverId: did, name: drv.name, amount: pending, status: 'paid', stripeTransferId: transfer.id });
      } catch (se: any) { results.push({ driverId: did, name: drv.name, status: 'error', reason: se.message }); }
    }
    res.json({ ok: true, results });
  } catch (e: any) { res.json({ error: e.message }); }
});

export { calcCompanyEarnings };
export default router;
