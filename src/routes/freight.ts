import { Router, Request, Response, NextFunction } from 'express';
import { fbRead, fbWrite, fbReadP } from '../firebase';
import { esc, getStripe } from '../utils';
import { freightSessions, fpGetSession, fpSetSession, fpDeleteSession } from '../sessions';

const router = Router();

/* ── CSS & Helpers ─────────────────────────────────────────────────────────── */
const FP_CSS = `
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#F3F4F9;color:#333;font-size:14px;min-height:100vh}
a{color:inherit;text-decoration:none}
.fp-nav{background:#283593;color:#fff;height:52px;padding:0 24px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100;box-shadow:0 2px 8px rgba(0,0,0,.25)}
.fp-nav-brand{font-size:15px;font-weight:700;display:flex;align-items:center;gap:6px}
.fp-nav-links{display:flex}
.fp-nav-links a{color:rgba(255,255,255,.78);padding:17px 13px;font-size:12.5px;display:flex;align-items:center;gap:4px;border-bottom:3px solid transparent;transition:all .15s}
.fp-nav-links a:hover{background:rgba(255,255,255,.1);color:#fff}
.fp-nav-links a.on{color:#fff;border-bottom-color:#82B1FF;background:rgba(255,255,255,.08)}
.fp-nav-right{font-size:12px;opacity:.75;display:flex;align-items:center;gap:14px}
.fp-main{padding:22px 24px;max-width:1280px;margin:0 auto}
.fp-card{background:#fff;border-radius:6px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:18px;overflow:hidden}
.fp-card-hd{padding:13px 18px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between}
.fp-card-hd h3{font-size:14px;font-weight:700;color:#283593}
.fp-card-bd{padding:16px 18px}
.fp-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:14px;margin-bottom:18px}
.fp-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #283593}
.fp-stat.green{border-left-color:#2E7D32}.fp-stat.warn{border-left-color:#E65100}
.fp-stat-v{font-size:26px;font-weight:700;color:#283593;line-height:1.1}
.fp-stat.green .fp-stat-v{color:#2E7D32}.fp-stat.warn .fp-stat-v{color:#E65100}
.fp-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.fp-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.fp-tbl th{background:#E8EAF6;padding:9px 11px;text-align:left;font-size:11.5px;font-weight:700;color:#283593;border-bottom:2px solid #C5CAE9;white-space:nowrap}
.fp-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fp-tbl tr:last-child td{border-bottom:none}
.fp-tbl tr:hover td{background:#F5F7FF}
.fp-empty{text-align:center;color:#aaa;padding:24px;font-style:italic}
.fp-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:12.5px;font-weight:600}
.fp-btn-b{background:#283593;color:#fff}.fp-btn-g{background:#2E7D32;color:#fff}.fp-btn-r{background:#C62828;color:#fff}.fp-btn-o{background:#E65100;color:#fff}
.fp-notice{padding:12px 16px;border-radius:6px;margin-bottom:16px;font-size:13px}
.fp-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.fp-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.fp-bdg-b{display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600;background:#E8EAF6;color:#283593}
.fp-bdg-g{background:#E8F5E9;color:#2E7D32;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.fp-bdg-r{background:#FFEBEE;color:#C62828;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.fp-bdg-a{background:#FFF3E0;color:#E65100;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.fp-bdg-gr{background:#F5F5F5;color:#757575;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
`;

function renderFpNav(session: any, token: string, activePage: string) {
  const te = encodeURIComponent(token);
  const pages: [string, string][] = [
    ['dashboard', '&#128202; Dashboard'],
    ['orders', '&#128666; Orders'],
    ['drivers', '&#128101; Drivers'],
    ['driver-earnings', '&#128184; Driver Pay'],
    ['earnings', '&#128200; Earnings'],
    ['payouts', '&#128181; Payouts'],
    ['zones', '&#128205; Zones'],
    ['documents', '&#128196; Documents']
  ];
  const links = pages.map(([pg, lbl]) =>
    `<a href="/freight-portal/${pg}?t=${te}" class="${activePage === pg ? 'on' : ''}">${lbl}</a>`
  ).join('');
  return `<nav class="fp-nav">
  <div class="fp-nav-brand">&#128666; <span>${esc(session.name || 'Freight Portal')}</span></div>
  <div class="fp-nav-links">${links}</div>
  <div class="fp-nav-right">
    <span>${esc(session.email || '')}</span>
    <a href="/api/freight-logout?t=${te}" style="opacity:1;color:#82B1FF">Sign Out</a>
  </div>
</nav>`;
}

function fpPage(title: string, nav: string, body: string) {
  return `<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} &mdash; Freight Portal</title>
<style>${FP_CSS}</style></head>
<body>${nav}<div class="fp-main">${body}</div></body></html>`;
}

function fpOrderBadge(s: string) {
  const m: Record<string, string> = {
    pending: '<span class="fp-bdg-gr">Pending</span>',
    assigned: '<span class="fp-bdg-b">Assigned</span>',
    in_transit: '<span class="fp-bdg-a">In Transit</span>',
    delivered: '<span class="fp-bdg-g">Delivered</span>',
    cancelled: '<span class="fp-bdg-r">Cancelled</span>'
  };
  return m[s] || `<span class="fp-bdg-gr">${esc(s || 'pending')}</span>`;
}

/* ── Auth Middleware ────────────────────────────────────────────────────────── */
function requireFreightAuth(req: any, res: Response, next: NextFunction) {
  const token = (req.query.t || req.body?._token || '') as string;
  const sess = fpGetSession(token);
  if (!sess) return res.redirect('/freight-portal?err=session');
  req.fpSession = sess; req.fpToken = token; next();
}

/* ── Login / Logout ────────────────────────────────────────────────────────── */
router.get('/freight-portal', (req: any, res) => {
  const err = req.query.err || '';
  const errMsgs: Record<string, string> = { invalid: 'Invalid email or password.', missing: 'Please enter your email and password.', nodata: 'Unable to verify credentials.', session: 'Your session has expired. Please sign in again.' };
  const errHtml = err ? `<div style="background:#FFEBEE;color:#C62828;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px;border-left:4px solid #C62828">${esc(errMsgs[err] || 'Sign in error.')}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Freight Portal &mdash; BookaWaka</title>
<style>*{box-sizing:border-box;margin:0;padding:0}body{background:linear-gradient(135deg,#1A237E,#283593);min-height:100vh;display:flex;align-items:center;justify-content:center;font-family:'Segoe UI',system-ui,sans-serif}.box{background:#fff;border-radius:10px;padding:40px;width:400px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25)}.box h1{font-size:22px;color:#283593;margin-bottom:4px}.box p{color:#888;font-size:13px;margin-bottom:28px}label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}input{width:100%;padding:10px 12px;border:1px solid #ddd;border-radius:6px;font-size:14px;margin-bottom:18px}input:focus{outline:none;border-color:#283593;box-shadow:0 0 0 3px rgba(40,53,147,.1)}button{width:100%;padding:12px;background:#283593;color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:600;cursor:pointer}button:hover{background:#1A237E}.hint{text-align:center;font-size:12px;color:#aaa;margin-top:18px}</style></head>
<body><div class="box">
  <h1>&#128666; Freight Portal</h1>
  <p>BookaWaka &mdash; Freight Management System</p>
  ${errHtml}
  <form method="POST" action="/api/freight-login">
    <label>Email Address</label>
    <input type="email" name="email" placeholder="operator@yourcompany.com" required autocomplete="email"/>
    <label>Password</label>
    <input type="password" name="password" required autocomplete="current-password"/>
    <button type="submit">Sign In</button>
  </form>
  <p class="hint">Forgot your password?<br>Contact your BookaWaka administrator to reset access.</p>
</div></body></html>`);
});

router.post('/api/freight-login', (req: any, res) => {
  const { fbAuthSignIn } = require('../firebase');
  const email = (req.body.email || '').trim().toLowerCase();
  const password = req.body.password || '';
  if (!email || !password) return res.redirect('/freight-portal?err=missing');
  fbAuthSignIn(email, password, (authErr: any, authUser: any) => {
    if (authErr) return res.redirect('/freight-portal?err=invalid');
    fbRead('freightAccess', (err: any, data: any) => {
      if (err || !data) return res.redirect('/freight-portal?err=nodata');
      let matched: any = null;
      for (const [fid, acc] of Object.entries(data as Record<string, any>)) {
        if (acc && acc.uid === authUser.uid && acc.active !== false) {
          matched = { freightCompanyId: fid, ...acc }; break;
        }
      }
      if (!matched) return res.redirect('/freight-portal?err=invalid');
      const token = fpSetSession(matched.freightCompanyId, matched.name || matched.freightCompanyId, email, matched.companyId || '');
      fbWrite('PUT', 'freightAccess/' + matched.freightCompanyId + '/lastLogin', Date.now(), () => {});
      res.redirect('/freight-portal/dashboard?t=' + encodeURIComponent(token));
    });
  });
});

router.get('/api/freight-logout', (req: any, res) => {
  const tok = req.query.t || '';
  if (tok) fpDeleteSession(tok as string);
  res.redirect('/freight-portal');
});

/* ── Dashboard ──────────────────────────────────────────────────────────────── */
router.get('/freight-portal/dashboard', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  const now = new Date();
  const today = now.toISOString().slice(0, 10);
  const curMonth = now.toISOString().slice(0, 7);
  fbRead('freightOrders/' + sess.freightCompanyId, (err: any, orders: any) => {
    fbRead('freightDrivers/' + sess.freightCompanyId, (_e2: any, driversData: any) => {
      const allOrds = orders ? Object.entries(orders as Record<string, any>) : [];
      const todayOrds = allOrds.filter(([, o]: any) => o.createdAt && new Date(o.createdAt).toISOString().slice(0, 10) === today);
      const monthOrds = allOrds.filter(([, o]: any) => o.createdAt && new Date(o.createdAt).toISOString().slice(0, 7) === curMonth);
      const pending = allOrds.filter(([, o]: any) => o.status === 'pending').length;
      const inTransit = allOrds.filter(([, o]: any) => o.status === 'in_transit').length;
      const driverCount = driversData ? Object.keys(driversData).length : 0;
      const activeDrivers = driversData ? Object.values(driversData as Record<string, any>).filter((d: any) => d.active !== false).length : 0;
      let monthEarnings = 0;
      monthOrds.forEach(([, o]: any) => { if (o.status === 'delivered') monthEarnings += parseFloat(o.freightPayout || 0); });
      const recent = [...allOrds].sort((a: any, b: any) => (b[1].createdAt || 0) - (a[1].createdAt || 0)).slice(0, 8);
      const recentRows = recent.map(([id, o]: any) => {
        const dt = o.createdAt ? new Date(o.createdAt).toLocaleString('en-NZ', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' }) : '—';
        const driver = driversData && o.driverId && driversData[o.driverId] ? esc(driversData[o.driverId].name || '—') : '—';
        return `<tr><td style="font-family:monospace;font-size:11px">${esc(id.slice(-8))}</td>
<td>${esc(o.customerName || '—')}</td><td>${esc(o.pickupAddress || '—')}</td>
<td>${esc(o.deliveryAddress || '—')}</td><td>${driver}</td><td>${dt}</td>
<td style="font-weight:700">$${parseFloat(o.amount || 0).toFixed(2)}</td>
<td>${fpOrderBadge(o.status)}</td></tr>`;
      }).join('');
      const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:16px">Dashboard &mdash; ${esc(today)}</h2>
<div class="fp-stats">
  <div class="fp-stat"><div class="fp-stat-v">${todayOrds.length}</div><div class="fp-stat-l">Orders Today</div></div>
  <div class="fp-stat warn"><div class="fp-stat-v">${pending}</div><div class="fp-stat-l">Pending Orders</div></div>
  <div class="fp-stat warn"><div class="fp-stat-v">${inTransit}</div><div class="fp-stat-l">In Transit</div></div>
  <div class="fp-stat green"><div class="fp-stat-v">$${monthEarnings.toFixed(2)}</div><div class="fp-stat-l">Earnings This Month</div></div>
  <div class="fp-stat"><div class="fp-stat-v">${activeDrivers}/${driverCount}</div><div class="fp-stat-l">Active Drivers</div></div>
</div>
<div class="fp-card">
<div class="fp-card-hd"><h3>Recent Orders</h3>
<a href="/freight-portal/orders?t=${encodeURIComponent(token)}" style="font-size:12px;color:#283593">View all &rarr;</a></div>
${recent.length ? `<div style="overflow-x:auto"><table class="fp-tbl"><thead><tr><th>Order</th><th>Customer</th><th>Pickup</th><th>Delivery</th><th>Driver</th><th>Time</th><th>Amount</th><th>Status</th></tr></thead>
<tbody>${recentRows}</tbody></table></div>` : '<div class="fp-empty">No orders yet.</div>'}
</div>`;
      res.send(fpPage('Dashboard', renderFpNav(sess, token, 'dashboard'), body));
    });
  });
});

/* ── Orders ─────────────────────────────────────────────────────────────────── */
router.get('/freight-portal/orders', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  const filterStatus = req.query.status || '';
  const filterMonth = req.query.month || '';
  const msg = req.query.msg || '', mt = req.query.mt || '';
  const te = encodeURIComponent(token);
  fbRead('freightOrders/' + sess.freightCompanyId, (err: any, orders: any) => {
    fbRead('freightDrivers/' + sess.freightCompanyId, (_e2: any, driversData: any) => {
      const allOrds = orders ? Object.entries(orders as Record<string, any>) : [];
      const months: Record<string, boolean> = {};
      allOrds.forEach(([, o]: any) => { if (o.createdAt) months[new Date(o.createdAt).toISOString().slice(0, 7)] = true; });
      const sortedMonths = Object.keys(months).sort().reverse();
      let filtered = [...allOrds];
      if (filterStatus) filtered = filtered.filter(([, o]: any) => o.status === filterStatus);
      if (filterMonth) filtered = filtered.filter(([, o]: any) => o.createdAt && new Date(o.createdAt).toISOString().slice(0, 7) === filterMonth);
      filtered.sort((a: any, b: any) => (b[1].createdAt || 0) - (a[1].createdAt || 0));
      const noticeHtml = msg ? `<div class="fp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg as string))}</div>` : '';
      const driverOpts = driversData ? Object.entries(driversData as Record<string, any>).filter(([, d]: any) => d.active !== false).map(([did, d]: any) => `<option value="${esc(did)}">${esc(d.name || did)}</option>`).join('') : '';
      const rows = filtered.map(([id, o]: any) => {
        const dt = o.createdAt ? new Date(o.createdAt).toLocaleString('en-NZ', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' }) : '—';
        const driver = driversData && o.driverId && (driversData as any)[o.driverId] ? esc((driversData as any)[o.driverId].name || '—') : '—';
        const actionForms: string[] = [];
        if (o.status === 'pending' && driverOpts) {
          actionForms.push(`<form method="POST" action="/api/freight-order-action" style="display:inline-flex;gap:4px;align-items:center">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="action" value="assigned"/>
<select name="driverId" style="padding:3px 6px;border:1px solid #ccc;border-radius:4px;font-size:11.5px">${driverOpts}</select>
<button type="submit" class="fp-btn fp-btn-b" style="padding:4px 10px;font-size:11.5px">Assign</button></form>`);
        }
        if (o.status === 'assigned') {
          actionForms.push(`<form method="POST" action="/api/freight-order-action" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="action" value="in_transit"/>
<button type="submit" class="fp-btn fp-btn-o" style="padding:4px 10px;font-size:11.5px">In Transit</button></form>`);
        }
        if (o.status === 'in_transit') {
          actionForms.push(`<form method="POST" action="/api/freight-order-action" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="action" value="delivered"/>
<button type="submit" class="fp-btn fp-btn-g" style="padding:4px 10px;font-size:11.5px">Mark Delivered</button></form>`);
        }
        return `<tr><td style="font-family:monospace;font-size:11px">${esc(id.slice(-8))}</td>
<td>${esc(o.customerName || '—')}</td><td style="font-size:11.5px">${esc(o.pickupAddress || '—')}</td>
<td style="font-size:11.5px">${esc(o.deliveryAddress || '—')}</td>
<td>${driver}</td><td style="white-space:nowrap">${dt}</td>
<td>$${parseFloat(o.amount || 0).toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:700">$${parseFloat(o.freightPayout || 0).toFixed(2)}</td>
<td>${fpOrderBadge(o.status)}</td>
<td style="white-space:nowrap">${actionForms.join('') || '—'}</td></tr>`;
      }).join('');
      const statusOpts = ['', 'pending', 'assigned', 'in_transit', 'delivered', 'cancelled'].map(s =>
        `<option value="${s}" ${s === filterStatus ? 'selected' : ''}>${s || 'All Statuses'}</option>`).join('');
      const monthOpts = sortedMonths.map(m => `<option value="${esc(m)}" ${m === filterMonth ? 'selected' : ''}>${m}</option>`).join('');
      const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:16px">Orders (${filtered.length})</h2>
${noticeHtml}
<div style="margin-bottom:16px">
<form method="GET" action="/freight-portal/orders" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap">
<input type="hidden" name="t" value="${esc(token)}"/>
<label>Status:</label><select name="status">${statusOpts}</select>
<label>Month:</label><select name="month"><option value="">All Months</option>${monthOpts}</select>
<button type="submit" class="fp-btn fp-btn-b" style="padding:7px 14px">Filter</button>
<a href="/freight-portal/orders?t=${te}" style="padding:7px 12px;background:#eee;color:#333;border-radius:4px;font-size:12.5px">Clear</a>
</form></div>
<div class="fp-card" style="overflow-x:auto">
${rows.length ? `<table class="fp-tbl"><thead><tr><th>Order</th><th>Customer</th><th>Pickup</th><th>Delivery</th><th>Driver</th><th>Time</th><th>Amount</th><th>Your Share</th><th>Status</th><th>Action</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="fp-empty">No orders found.</div>'}
</div>`;
      res.send(fpPage('Orders', renderFpNav(sess, token, 'orders'), body));
    });
  });
});

router.post('/api/freight-order-action', (req: any, res) => {
  const token = req.body._token || '';
  const orderId = req.body.orderId || '';
  const action = req.body.action || '';
  const driverId = req.body.driverId || '';
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  const validActions = ['assigned', 'in_transit', 'delivered', 'cancelled'];
  if (!sess || !orderId || !validActions.includes(action)) return res.redirect('/freight-portal/orders?t=' + te + '&msg=Invalid+request&mt=err');
  const patch: any = { status: action, [`${action}At`]: Date.now() };
  if (action === 'assigned' && driverId) patch.driverId = driverId;
  fbWrite('PATCH', 'freightOrders/' + sess.freightCompanyId + '/' + orderId, patch, (err: any) => {
    if (err) return res.redirect('/freight-portal/orders?t=' + te + '&msg=Update+failed&mt=err');
    if (action === 'delivered') {
      fbRead('freightOrders/' + sess.freightCompanyId + '/' + orderId, (_e2: any, order: any) => {
        if (!order) return;
        const assignedDriverId = order.driverId;
        if (!assignedDriverId) return;
        fbRead('freightConfig/driverPay/' + sess.freightCompanyId, (_e3: any, cfg: any) => {
          if (!cfg) return;
          const orderAmount = parseFloat(order.amount || 0);
          let driverPay = 0;
          if (cfg.model === 'flat') driverPay = parseFloat(cfg.amount || 0);
          else if (cfg.model === 'percent') driverPay = orderAmount * (parseFloat(cfg.amount || 0) / 100);
          if (driverPay <= 0) return;
          const earningsPath = `driverEarnings/freight/${sess.freightCompanyId}/${assignedDriverId}`;
          fbRead(earningsPath, (_e4: any, existing: any) => {
            const prev = existing || {};
            const pendingAmt = parseFloat(prev.pendingAmount || 0) + driverPay;
            const total = parseFloat(prev.totalEarned || 0) + driverPay;
            const deliveries = prev.deliveries || {};
            deliveries[orderId] = { amount: driverPay, status: 'pending', createdAt: Date.now(), orderId };
            fbWrite('PUT', earningsPath, { pendingAmount: pendingAmt, totalEarned: total, deliveries, updatedAt: Date.now() }, () => {
              if (cfg.schedule === 'instant') {
                fbRead('freightDrivers/' + sess.freightCompanyId + '/' + assignedDriverId, (_e5: any, drv: any) => {
                  if (!drv || !drv.stripeExpressId) return;
                  const stripe = getStripe();
                  stripe.transfers.create({
                    amount: Math.round(driverPay * 100), currency: 'nzd', destination: drv.stripeExpressId,
                    transfer_group: orderId, metadata: { orderId, companyId: sess.freightCompanyId, driverId: assignedDriverId }
                  }).then((transfer: any) => {
                    deliveries[orderId].status = 'paid'; deliveries[orderId].paidAt = Date.now(); deliveries[orderId].stripeTransferId = transfer.id;
                    fbWrite('PATCH', earningsPath, { pendingAmount: Math.max(0, pendingAmt - driverPay), deliveries, updatedAt: Date.now() }, () => {});
                    fbWrite('PUT', `driverPayouts/freight/${sess.freightCompanyId}/payout_${Date.now()}`, {
                      driverId: assignedDriverId, amount: driverPay, schedule: 'instant', status: 'paid', stripeTransferId: transfer.id, triggeredAt: Date.now(), orderId
                    }, () => {});
                  }).catch(() => {});
                });
              }
            });
          });
        });
      });
    }
    res.redirect('/freight-portal/orders?t=' + te + '&msg=Order+updated&mt=ok');
  });
});

/* ── Drivers ────────────────────────────────────────────────────────────────── */
router.get('/freight-portal/drivers', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  const msg = req.query.msg || '', mt = req.query.mt || '';
  const te = encodeURIComponent(token);
  fbRead('freightDrivers/' + sess.freightCompanyId, (err: any, data: any) => {
    const drivers = data ? Object.entries(data as Record<string, any>) : [];
    const noticeHtml = msg ? `<div class="fp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg as string))}</div>` : '';
    const rows = drivers.map(([did, d]: any) => {
      const active = d.active !== false;
      return `<tr>
<td style="font-weight:600">${esc(d.name || '—')}</td>
<td>${esc(d.phone || '—')}</td>
<td>${esc(d.email || '—')}</td>
<td>${esc(d.vehicleType || '—')}</td>
<td>${esc(d.licensePlate || '—')}</td>
<td>${active ? '<span class="fp-bdg-g">Active</span>' : '<span class="fp-bdg-r">Inactive</span>'}</td>
<td style="white-space:nowrap">
<form method="POST" action="/api/freight-driver-toggle" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="driverId" value="${esc(did)}"/>
<input type="hidden" name="active" value="${active ? 'false' : 'true'}"/>
<button type="submit" class="fp-btn ${active ? 'fp-btn-r' : 'fp-btn-g'}" style="padding:3px 10px;font-size:11.5px">${active ? 'Deactivate' : 'Activate'}</button>
</form>
</td></tr>`;
    }).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:8px">Driver Management</h2>
${noticeHtml}
<div class="fp-card">
<div class="fp-card-hd"><h3>&#43; Add New Driver</h3></div>
<div class="fp-card-bd">
<form method="POST" action="/api/freight-driver-save" style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;align-items:end">
<input type="hidden" name="_token" value="${esc(token)}"/>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Full Name *</label>
<input type="text" name="name" required style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Phone</label>
<input type="text" name="phone" style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Email</label>
<input type="email" name="email" style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Vehicle Type</label>
<input type="text" name="vehicleType" placeholder="e.g. Van, Truck" style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">License Plate</label>
<input type="text" name="licensePlate" style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<button type="submit" class="fp-btn fp-btn-b">Add Driver</button>
</form></div></div>
<div class="fp-card">
<div class="fp-card-hd"><h3>Your Drivers (${drivers.length})</h3></div>
${drivers.length ? `<div style="overflow-x:auto"><table class="fp-tbl"><thead><tr><th>Name</th><th>Phone</th><th>Email</th><th>Vehicle</th><th>Plate</th><th>Status</th><th>Action</th></tr></thead>
<tbody>${rows}</tbody></table></div>` : '<div class="fp-empty">No drivers added yet.</div>'}
</div>`;
    res.send(fpPage('Drivers', renderFpNav(sess, token, 'drivers'), body));
  });
});

router.post('/api/freight-driver-save', (req: any, res) => {
  const token = req.body._token || '';
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess) return res.redirect('/freight-portal/drivers?t=' + te + '&msg=Session+expired&mt=err');
  const name = (req.body.name || '').trim();
  if (!name) return res.redirect('/freight-portal/drivers?t=' + te + '&msg=Name+required&mt=err');
  const driverId = 'drv_' + Date.now();
  const data = { name, phone: req.body.phone || '', email: req.body.email || '', vehicleType: req.body.vehicleType || '', licensePlate: req.body.licensePlate || '', active: true, createdAt: Date.now() };
  fbWrite('PUT', 'freightDrivers/' + sess.freightCompanyId + '/' + driverId, data, (err: any) => {
    if (err) return res.redirect('/freight-portal/drivers?t=' + te + '&msg=Save+failed&mt=err');
    res.redirect('/freight-portal/drivers?t=' + te + '&msg=' + encodeURIComponent(name + ' added') + '&mt=ok');
  });
});

router.post('/api/freight-driver-toggle', (req: any, res) => {
  const token = req.body._token || '';
  const driverId = req.body.driverId || '';
  const active = req.body.active === 'true';
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !driverId) return res.redirect('/freight-portal/drivers?t=' + te + '&msg=Invalid&mt=err');
  fbWrite('PATCH', 'freightDrivers/' + sess.freightCompanyId + '/' + driverId, { active }, (err: any) => {
    if (err) return res.redirect('/freight-portal/drivers?t=' + te + '&msg=Update+failed&mt=err');
    res.redirect('/freight-portal/drivers?t=' + te + '&msg=Driver+updated&mt=ok');
  });
});

/* ── Driver Earnings ────────────────────────────────────────────────────────── */
router.get('/freight-portal/driver-earnings', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  const msg = req.query.msg || '', mt = req.query.mt || '';
  const te = encodeURIComponent(token);
  const noticeHtml = msg ? `<div class="fp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg as string))}</div>` : '';
  Promise.all([
    new Promise(r => fbRead('freightDrivers/' + sess.freightCompanyId, (_e: any, d: any) => r(d || {}))),
    new Promise(r => fbRead('driverEarnings/freight/' + sess.freightCompanyId, (_e: any, d: any) => r(d || {}))),
    new Promise(r => fbRead('freightConfig/driverPay/' + sess.freightCompanyId, (_e: any, d: any) => r(d || {}))),
    new Promise(r => fbRead('driverPayouts/freight/' + sess.freightCompanyId, (_e: any, d: any) => r(d || {})))
  ]).then(([drivers, earnings, payCfg, payouts]: any[]) => {
    const modelLabel = payCfg.model === 'flat' ? `$${parseFloat(payCfg.amount || 0).toFixed(2)} flat per delivery`
      : payCfg.model === 'percent' ? `${parseFloat(payCfg.amount || 0)}% of order value` : 'Not configured';
    const scheduleLabel = payCfg.schedule === 'instant' ? 'Instant (on delivery)' : payCfg.schedule === 'weekly' ? 'Weekly batch' : payCfg.schedule === 'monthly' ? 'Monthly batch' : '—';
    const driverRows = Object.entries(drivers as Record<string, any>).map(([did, d]: any) => {
      const e = (earnings as any)[did] || {};
      const pending = parseFloat(e.pendingAmount || 0);
      const totalEarned = parseFloat(e.totalEarned || 0);
      const deliveryCount = e.deliveries ? Object.keys(e.deliveries).length : 0;
      const pendingCount = e.deliveries ? Object.values(e.deliveries as Record<string, any>).filter((x: any) => x.status === 'pending').length : 0;
      const hasStripe = !!d.stripeExpressId;
      const payoutBtn = payCfg.schedule !== 'instant' && pending > 0 ? `<form method="POST" action="/api/freight-driver-payout" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="driverId" value="${esc(did)}"/>
<button type="submit" class="fp-btn fp-btn-b" style="padding:4px 10px;font-size:12px"${!hasStripe ? ' disabled title="Driver needs Stripe account"' : ''}>Pay Now $${pending.toFixed(2)}</button>
</form>` : '';
      const stripeBtn = !hasStripe ? `<form method="POST" action="/api/driver-stripe-onboard" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="driverId" value="${esc(did)}"/>
<input type="hidden" name="driverName" value="${esc(d.name || '')}"/>
<input type="hidden" name="driverEmail" value="${esc(d.email || '')}"/>
<button type="submit" class="fp-btn fp-btn-g" style="padding:4px 10px;font-size:12px">Connect Stripe</button>
</form>` : `<span class="fp-bdg-g">&#10003; Stripe Connected</span>`;
      return `<tr>
<td style="font-weight:600">${esc(d.name || '—')}</td><td>${esc(d.phone || '—')}</td>
<td style="color:#388E3C;font-weight:700">$${pending.toFixed(2)}</td>
<td style="color:#555">$${totalEarned.toFixed(2)}</td>
<td>${deliveryCount} total / ${pendingCount} unpaid</td>
<td>${stripeBtn}</td>
<td style="white-space:nowrap">${payoutBtn}</td>
</tr>`;
    }).join('');
    const payoutRows = Object.entries(payouts as Record<string, any>).sort((a: any, b: any) => b[1].triggeredAt - a[1].triggeredAt).slice(0, 30).map(([_pid, p]: any) => {
      const drv = (drivers as any)[p.driverId] || {};
      return `<tr>
<td>${esc(drv.name || p.driverId)}</td>
<td style="font-weight:600;color:#283593">$${parseFloat(p.amount || 0).toFixed(2)}</td>
<td>${esc(p.schedule || '—')}</td>
<td>${p.triggeredAt ? new Date(p.triggeredAt).toLocaleString('en-NZ') : '—'}</td>
<td><span class="${p.status === 'paid' ? 'fp-bdg-g' : 'fp-bdg-a'}">${esc(p.status || 'pending')}</span></td>
<td style="font-size:11px;color:#999;font-family:monospace">${esc(p.stripeTransferId || '—')}</td>
</tr>`;
    }).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:8px">Driver Pay &amp; Earnings</h2>
${noticeHtml}
<div class="fp-card" style="margin-bottom:16px">
<div class="fp-card-hd"><h3>&#128179; Current Driver Pay Config</h3><span style="font-size:12px;color:#888">Set by BookaWaka admin</span></div>
<div class="fp-card-bd" style="display:flex;gap:24px;flex-wrap:wrap">
<div><span style="font-size:12px;font-weight:600;color:#555;display:block;margin-bottom:2px">Pay Model</span><span style="font-size:15px;font-weight:700;color:#283593">${modelLabel}</span></div>
<div><span style="font-size:12px;font-weight:600;color:#555;display:block;margin-bottom:2px">Payout Schedule</span><span style="font-size:15px;font-weight:700;color:#283593">${scheduleLabel}</span></div>
</div>
</div>
<div class="fp-card">
<div class="fp-card-hd"><h3>&#128101; Driver Earnings Summary</h3></div>
${Object.keys(drivers as Record<string, any>).length ? `<div style="overflow-x:auto"><table class="fp-tbl"><thead><tr>
<th>Driver</th><th>Phone</th><th>Pending ($)</th><th>Total Earned ($)</th><th>Deliveries</th><th>Stripe</th><th>Payout</th>
</tr></thead><tbody>${driverRows}</tbody></table></div>` : '<div class="fp-empty">No drivers yet.</div>'}
</div>
<div class="fp-card" style="margin-top:16px">
<div class="fp-card-hd"><h3>&#128196; Payout History (last 30)</h3></div>
${Object.keys(payouts as Record<string, any>).length ? `<div style="overflow-x:auto"><table class="fp-tbl"><thead><tr>
<th>Driver</th><th>Amount</th><th>Schedule</th><th>Triggered</th><th>Status</th><th>Stripe Transfer ID</th>
</tr></thead><tbody>${payoutRows}</tbody></table></div>` : '<div class="fp-empty">No payouts yet.</div>'}
</div>`;
    res.send(fpPage('Driver Pay', renderFpNav(sess, token, 'driver-earnings'), body));
  });
});

router.post('/api/freight-driver-payout', (req: any, res) => {
  const token = req.body._token || '';
  const driverId = req.body.driverId || '';
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !driverId) return res.redirect('/freight-portal/driver-earnings?t=' + te + '&msg=Invalid+request&mt=err');
  const earningsPath = `driverEarnings/freight/${sess.freightCompanyId}/${driverId}`;
  Promise.all([
    new Promise(r => fbRead(earningsPath, (_e: any, d: any) => r(d || {}))),
    new Promise(r => fbRead('freightDrivers/' + sess.freightCompanyId + '/' + driverId, (_e: any, d: any) => r(d || {})))
  ]).then(async ([earnings, driver]: any[]) => {
    const pending = parseFloat(earnings.pendingAmount || 0);
    if (pending <= 0) return res.redirect(`/freight-portal/driver-earnings?t=${te}&msg=${encodeURIComponent('No pending earnings')}&mt=err`);
    if (!driver.stripeExpressId) return res.redirect(`/freight-portal/driver-earnings?t=${te}&msg=${encodeURIComponent('Driver needs Stripe account connected first')}&mt=err`);
    try {
      const stripe = getStripe();
      const transfer = await stripe.transfers.create({ amount: Math.round(pending * 100), currency: 'nzd', destination: driver.stripeExpressId, metadata: { companyId: sess.freightCompanyId, driverId, type: 'batch_payout' } });
      const deliveries = earnings.deliveries || {};
      Object.keys(deliveries).forEach(k => { if (deliveries[k].status === 'pending') { deliveries[k].status = 'paid'; deliveries[k].paidAt = Date.now(); deliveries[k].stripeTransferId = transfer.id; } });
      fbWrite('PATCH', earningsPath, { pendingAmount: 0, deliveries, updatedAt: Date.now() }, () => {});
      fbWrite('PUT', `driverPayouts/freight/${sess.freightCompanyId}/payout_${Date.now()}`, { driverId, amount: pending, schedule: 'manual', status: 'paid', stripeTransferId: transfer.id, triggeredAt: Date.now() }, () => {});
      res.redirect(`/freight-portal/driver-earnings?t=${te}&msg=${encodeURIComponent('$' + pending.toFixed(2) + ' paid to ' + driver.name)}&mt=ok`);
    } catch (e: any) {
      res.redirect(`/freight-portal/driver-earnings?t=${te}&msg=${encodeURIComponent('Stripe error: ' + e.message)}&mt=err`);
    }
  });
});

router.post('/api/driver-stripe-onboard', async (req: any, res) => {
  const token = req.body._token || '';
  const driverId = req.body.driverId || '';
  const driverName = (req.body.driverName || '').trim();
  const driverEmail = (req.body.driverEmail || '').trim();
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !driverId) return res.redirect('/freight-portal/driver-earnings?t=' + te + '&msg=Invalid&mt=err');
  try {
    const stripe = getStripe();
    const account = await stripe.accounts.create({ type: 'express', country: 'NZ', email: driverEmail || undefined, metadata: { driverId, companyId: sess.freightCompanyId, driverName } });
    await new Promise(r => fbWrite('PATCH', 'freightDrivers/' + sess.freightCompanyId + '/' + driverId, { stripeExpressId: account.id }, r));
    const link = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: `${req.protocol}://${req.get('host')}/freight-portal/driver-earnings?t=${te}&msg=${encodeURIComponent('Stripe onboarding refreshed')}&mt=err`,
      return_url: `${req.protocol}://${req.get('host')}/freight-portal/driver-earnings?t=${te}&msg=${encodeURIComponent(driverName + ' Stripe account connected')}&mt=ok`,
      type: 'account_onboarding'
    });
    res.redirect(link.url);
  } catch (e: any) {
    res.redirect(`/freight-portal/driver-earnings?t=${te}&msg=${encodeURIComponent('Stripe error: ' + e.message)}&mt=err`);
  }
});

/* ── Earnings ───────────────────────────────────────────────────────────────── */
router.get('/freight-portal/earnings', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  const view = req.query.view || 'monthly';
  const te = encodeURIComponent(token);
  fbRead('freightOrders/' + sess.freightCompanyId, (err: any, orders: any) => {
    const allOrds = orders ? Object.entries(orders as Record<string, any>) : [];
    const delivered = allOrds.filter(([, o]: any) => o.status === 'delivered');
    const daily: any = {}, weekly: any = {}, monthly: any = {}, yearly: any = {};
    delivered.forEach(([, o]: any) => {
      if (!o.createdAt) return;
      const d = new Date(o.createdAt);
      const day = d.toISOString().slice(0, 10);
      const yr = d.getFullYear();
      const wk = `${yr}-W${String(Math.ceil(((d.getTime() - new Date(yr, 0, 1).getTime()) / 86400000 + 1) / 7)).padStart(2, '0')}`;
      const mon = d.toISOString().slice(0, 7);
      const net = parseFloat(o.freightPayout || 0);
      const com = parseFloat(o.freightCommission || 0);
      const gross = parseFloat(o.amount || 0);
      [daily, weekly, monthly, yearly].forEach((map, i) => {
        const key = [day, wk, mon, String(yr)][i];
        if (!map[key]) map[key] = { orders: 0, gross: 0, commission: 0, net: 0 };
        map[key].orders++; map[key].gross += gross; map[key].commission += com; map[key].net += net;
      });
    });
    const data: any = { daily, weekly, monthly, yearly }[view as string] || monthly;
    const sorted = Object.keys(data).sort().reverse();
    const totalOrders = sorted.reduce((s, k) => s + data[k].orders, 0);
    const totalNet = sorted.reduce((s, k) => s + data[k].net, 0);
    const totalCom = sorted.reduce((s, k) => s + data[k].commission, 0);
    const rows = sorted.map(k => {
      const d = data[k];
      return `<tr><td style="font-weight:600">${esc(k)}</td><td>${d.orders}</td>
<td>$${d.gross.toFixed(2)}</td><td style="color:#E65100">$${d.commission.toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:700">$${d.net.toFixed(2)}</td></tr>`;
    }).join('');
    const tabs = ['daily', 'weekly', 'monthly', 'yearly'].map(v =>
      `<a href="/freight-portal/earnings?t=${te}&view=${v}" style="padding:7px 16px;border-radius:4px;font-size:13px;font-weight:600;background:${v === view ? '#283593' : '#f5f5f5'};color:${v === view ? '#fff' : '#555'};text-decoration:none;text-transform:capitalize">${v}</a>`
    ).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:8px">Earnings Reports</h2>
<div style="display:flex;gap:8px;margin-bottom:16px">${tabs}</div>
<div class="fp-stats">
  <div class="fp-stat"><div class="fp-stat-v">${totalOrders}</div><div class="fp-stat-l">Total Deliveries</div></div>
  <div class="fp-stat green"><div class="fp-stat-v">$${totalNet.toFixed(2)}</div><div class="fp-stat-l">Your Net Earnings</div></div>
  <div class="fp-stat"><div class="fp-stat-v">$${totalCom.toFixed(2)}</div><div class="fp-stat-l">Commission Paid</div></div>
</div>
<div class="fp-card" style="overflow-x:auto">
${rows.length ? `<table class="fp-tbl"><thead><tr><th>Period</th><th>Deliveries</th><th>Gross</th><th>Commission</th><th>Your Earnings</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="fp-empty">No completed deliveries yet.</div>'}
</div>`;
    res.send(fpPage('Earnings', renderFpNav(sess, token, 'earnings'), body));
  });
});

/* ── Payouts ────────────────────────────────────────────────────────────────── */
router.get('/freight-portal/payouts', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  fbRead('freightOrders/' + sess.freightCompanyId, (_err: any, orders: any) => {
    fbRead('freightPayouts/' + sess.freightCompanyId, (_e2: any, payouts: any) => {
      const allOrds = orders ? Object.entries(orders as Record<string, any>) : [];
      const delivered = allOrds.filter(([, o]: any) => o.status === 'delivered');
      const periods: Record<string, any> = {};
      delivered.forEach(([, o]: any) => {
        if (!o.createdAt) return;
        const p = new Date(o.createdAt).toISOString().slice(0, 7);
        if (!periods[p]) periods[p] = { orders: 0, gross: 0, commission: 0, net: 0 };
        periods[p].orders++; periods[p].gross += parseFloat(o.amount || 0);
        periods[p].commission += parseFloat(o.freightCommission || 0); periods[p].net += parseFloat(o.freightPayout || 0);
      });
      const saved = payouts || {};
      const sorted = Object.keys(periods).sort().reverse();
      const rows = sorted.map(p => {
        const d = periods[p];
        const paidStatus = (saved[p] || {}).status || 'pending';
        const badge = paidStatus === 'paid' ? '<span class="fp-bdg-g">Paid</span>' : '<span class="fp-bdg-gr">Pending</span>';
        const paidDate = (saved[p] || {}).updatedAt ? new Date((saved[p] || {}).updatedAt).toLocaleDateString('en-NZ') : '—';
        return `<tr><td style="font-weight:600">${p}</td><td>${d.orders}</td>
<td>$${d.gross.toFixed(2)}</td>
<td style="color:#E65100">-$${d.commission.toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:700">$${d.net.toFixed(2)}</td>
<td>${badge}</td><td>${paidStatus === 'paid' ? paidDate : '—'}</td></tr>`;
      }).join('');
      const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:8px">Settlement Statements</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Monthly revenue after BookaWaka commission.</p>
<div class="fp-card" style="overflow-x:auto">
${sorted.length ? `<table class="fp-tbl"><thead><tr><th>Period</th><th>Deliveries</th><th>Gross</th><th>Commission</th><th>Your Payout</th><th>Status</th><th>Paid Date</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="fp-empty">No completed deliveries yet.</div>'}
</div>`;
      res.send(fpPage('Payouts', renderFpNav(sess, token, 'payouts'), body));
    });
  });
});

/* ── Zones ──────────────────────────────────────────────────────────────────── */
router.get('/freight-portal/zones', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  const msg = req.query.msg || '', mt = req.query.mt || '';
  const te = encodeURIComponent(token);
  fbRead('freightAccess/' + sess.freightCompanyId + '/serviceZones', (_err: any, zones: any) => {
    const z = zones || [];
    const zoneList = Array.isArray(z) ? z : Object.values(z as object);
    const noticeHtml = msg ? `<div class="fp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg as string))}</div>` : '';
    const zoneItems = (zoneList as string[]).map((zone, i) => `<div style="display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #f5f5f5">
<span style="font-size:13px">${esc(zone)}</span>
<form method="POST" action="/api/freight-zone-delete" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="zoneIndex" value="${i}"/>
<button type="submit" class="fp-btn fp-btn-r" style="padding:3px 10px;font-size:11.5px" onclick="return confirm('Remove zone?')">Remove</button></form>
</div>`).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:8px">Service Zones</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Define the areas where your freight company operates.</p>
${noticeHtml}
<div class="fp-card"><div class="fp-card-hd"><h3>&#43; Add Zone</h3></div><div class="fp-card-bd">
<form method="POST" action="/api/freight-zone-add" style="display:flex;gap:10px;align-items:flex-end">
<input type="hidden" name="_token" value="${esc(token)}"/>
<div style="flex:1"><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Zone / Area Name</label>
<input type="text" name="zone" placeholder="e.g. Auckland CBD" required style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<button type="submit" class="fp-btn fp-btn-b">Add Zone</button>
</form></div></div>
<div class="fp-card"><div class="fp-card-hd"><h3>&#128205; Your Service Zones (${zoneList.length})</h3></div>
<div class="fp-card-bd">${zoneList.length ? zoneItems : '<div class="fp-empty">No service zones defined yet.</div>'}</div></div>`;
    res.send(fpPage('Zones', renderFpNav(sess, token, 'zones'), body));
  });
});

router.post('/api/freight-zone-add', (req: any, res) => {
  const token = req.body._token || '';
  const zone = (req.body.zone || '').trim();
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !zone) return res.redirect('/freight-portal/zones?t=' + te + '&msg=Invalid+request&mt=err');
  fbRead('freightAccess/' + sess.freightCompanyId + '/serviceZones', (_err: any, zones: any) => {
    const z = (Array.isArray(zones) ? zones : (zones ? Object.values(zones as object) : [])) as string[];
    z.push(zone);
    fbWrite('PUT', 'freightAccess/' + sess.freightCompanyId + '/serviceZones', z, (e: any) => {
      if (e) return res.redirect('/freight-portal/zones?t=' + te + '&msg=Save+failed&mt=err');
      res.redirect('/freight-portal/zones?t=' + te + '&msg=Zone+added&mt=ok');
    });
  });
});

router.post('/api/freight-zone-delete', (req: any, res) => {
  const token = req.body._token || '';
  const zoneIndex = parseInt(req.body.zoneIndex || '0', 10);
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess) return res.redirect('/freight-portal/zones?t=' + te + '&msg=Session+expired&mt=err');
  fbRead('freightAccess/' + sess.freightCompanyId + '/serviceZones', (_err: any, zones: any) => {
    const z = (Array.isArray(zones) ? zones : (zones ? Object.values(zones as object) : [])) as string[];
    z.splice(zoneIndex, 1);
    fbWrite('PUT', 'freightAccess/' + sess.freightCompanyId + '/serviceZones', z, (e: any) => {
      if (e) return res.redirect('/freight-portal/zones?t=' + te + '&msg=Delete+failed&mt=err');
      res.redirect('/freight-portal/zones?t=' + te + '&msg=Zone+removed&mt=ok');
    });
  });
});

/* ── Documents ──────────────────────────────────────────────────────────────── */
router.get('/freight-portal/documents', requireFreightAuth, (req: any, res) => {
  const sess = req.fpSession, token = req.fpToken;
  const msg = req.query.msg || '', mt = req.query.mt || '';
  const te = encodeURIComponent(token);
  fbRead('freightDocuments/' + sess.freightCompanyId, (_err: any, docs: any) => {
    const allDocs = docs ? Object.entries(docs as Record<string, any>).sort((a: any, b: any) => (b[1].uploadedAt || 0) - (a[1].uploadedAt || 0)) : [];
    const noticeHtml = msg ? `<div class="fp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg as string))}</div>` : '';
    const rows = allDocs.map(([docId, d]: any) => {
      const dt = d.uploadedAt ? new Date(d.uploadedAt).toLocaleString('en-NZ', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '—';
      return `<tr><td>${esc(d.filename || docId)}</td><td>${esc(d.orderId || '—')}</td>
<td>${esc(d.type || '—')}</td><td>${dt}</td>
<td>${esc(d.notes || '—')}</td></tr>`;
    }).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#283593;margin-bottom:8px">Documents</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Upload proof of delivery and other compliance documents.</p>
${noticeHtml}
<div class="fp-card"><div class="fp-card-hd"><h3>&#128196; Upload Document</h3></div><div class="fp-card-bd">
<form method="POST" action="/api/freight-doc-upload" style="display:grid;grid-template-columns:1fr 1fr;gap:12px;align-items:end">
<input type="hidden" name="_token" value="${esc(token)}"/>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Document Type</label>
<select name="docType" style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px">
<option>Proof of Delivery</option><option>Invoice</option><option>Insurance</option><option>License</option><option>Other</option>
</select></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Related Order ID (optional)</label>
<input type="text" name="orderId" style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Notes</label>
<input type="text" name="notes" style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">File Name *</label>
<input type="text" name="filename" required style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/></div>
<button type="submit" class="fp-btn fp-btn-b" style="grid-column:span 2">Submit Document Record</button>
</form></div></div>
<div class="fp-card"><div class="fp-card-hd"><h3>Uploaded Documents (${allDocs.length})</h3></div>
${allDocs.length ? `<div style="overflow-x:auto"><table class="fp-tbl"><thead><tr><th>File</th><th>Order ID</th><th>Type</th><th>Uploaded</th><th>Notes</th></tr></thead>
<tbody>${rows}</tbody></table></div>` : '<div class="fp-empty">No documents uploaded yet.</div>'}
</div>`;
    res.send(fpPage('Documents', renderFpNav(sess, token, 'documents'), body));
  });
});

router.post('/api/freight-doc-upload', (req: any, res) => {
  const token = req.body._token || '';
  const sess = fpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess) return res.redirect('/freight-portal/documents?t=' + te + '&msg=Session+expired&mt=err');
  const filename = (req.body.filename || '').trim();
  if (!filename) return res.redirect('/freight-portal/documents?t=' + te + '&msg=Filename+required&mt=err');
  const docId = 'doc_' + Date.now();
  const data = { filename, type: req.body.docType || 'Other', orderId: req.body.orderId || '', notes: req.body.notes || '', uploadedAt: Date.now(), uploadedBy: sess.email };
  fbWrite('PUT', 'freightDocuments/' + sess.freightCompanyId + '/' + docId, data, (err: any) => {
    if (err) return res.redirect('/freight-portal/documents?t=' + te + '&msg=Upload+failed&mt=err');
    res.redirect('/freight-portal/documents?t=' + te + '&msg=Document+recorded&mt=ok');
  });
});

/* ── SA: Driver Pay API Endpoints ─────────────────────────────────────────── */
router.post('/api/sa-freight-driver-pay', (req: any, res) => {
  const { companyId, model, amount, schedule } = req.body;
  if (!companyId || !model || amount === undefined || !schedule) return res.json({ error: 'Missing fields' });
  const data = { model, amount: parseFloat(amount) || 0, schedule, updatedAt: Date.now() };
  fbWrite('PUT', 'freightConfig/driverPay/' + companyId, data, (err: any) => {
    if (err) return res.json({ error: String(err) });
    res.json({ ok: true });
  });
});

router.post('/api/sa-food-driver-pay', (req: any, res) => {
  const { companyId, restaurantId, model, amount, schedule } = req.body;
  if (!companyId || !restaurantId || !model || amount === undefined || !schedule) return res.json({ error: 'Missing fields' });
  fbWrite('PATCH', 'foodClients/' + companyId + '/' + restaurantId, {
    driverPayModel: model, driverPayAmount: parseFloat(amount) || 0, driverPaySchedule: schedule
  }, (err: any) => {
    if (err) return res.json({ error: String(err) });
    res.json({ ok: true });
  });
});

router.get('/api/sa-driver-earnings', (_req, res) => {
  Promise.all([
    new Promise(r => fbRead('driverEarnings/freight', (_e: any, d: any) => r(d || {}))),
    new Promise(r => fbRead('freightAccess', (_e: any, d: any) => r(d || {})))
  ]).then(([freightEarnings, companies]: any[]) => {
    const result: any[] = [];
    Object.entries(freightEarnings as Record<string, any>).forEach(([cid, drivers]) => {
      const company = (companies as any)[cid] || {};
      Object.entries(drivers as Record<string, any>).forEach(([did, e]: any) => {
        const pending = parseFloat(e.pendingAmount || 0);
        if (pending > 0) result.push({ type: 'freight', companyId: cid, companyName: company.name || cid, driverId: did, pendingAmount: pending, totalEarned: parseFloat(e.totalEarned || 0), deliveryCount: e.deliveries ? Object.keys(e.deliveries).length : 0 });
      });
    });
    res.json(result);
  });
});

router.post('/api/sa-batch-driver-payouts', async (req: any, res) => {
  const { companyId, schedule, driverId: singleDriverId } = req.body;
  if (!companyId) return res.json({ error: 'companyId required' });
  try {
    const [drivers, earnings, payCfg] = await Promise.all([
      new Promise(r => fbRead('freightDrivers/' + companyId, (_e: any, d: any) => r(d || {}))),
      new Promise(r => fbRead('driverEarnings/freight/' + companyId, (_e: any, d: any) => r(d || {}))),
      new Promise(r => fbRead('freightConfig/driverPay/' + companyId, (_e: any, d: any) => r(d || {})))
    ]) as any[];
    if (!singleDriverId && payCfg.schedule === 'instant') return res.json({ error: 'Company uses instant payouts' });
    if (!singleDriverId && schedule && payCfg.schedule !== schedule) return res.json({ error: `Company schedule is ${payCfg.schedule}, not ${schedule}` });
    const stripe = getStripe();
    const results: any[] = [];
    const earningsEntries = singleDriverId ? Object.entries(earnings as Record<string, any>).filter(([did]) => did === singleDriverId) : Object.entries(earnings as Record<string, any>);
    for (const [did, e] of earningsEntries as any[]) {
      const pending = parseFloat(e.pendingAmount || 0);
      if (pending <= 0) continue;
      const drv = (drivers as any)[did] || {};
      if (!drv.stripeExpressId) { results.push({ driverId: did, name: drv.name, status: 'skipped', reason: 'no Stripe account' }); continue; }
      try {
        const transfer = await stripe.transfers.create({ amount: Math.round(pending * 100), currency: 'nzd', destination: drv.stripeExpressId, metadata: { companyId, driverId: did, type: 'batch_payout', schedule: payCfg.schedule } });
        const deliveries = e.deliveries || {};
        Object.keys(deliveries).forEach(k => { if (deliveries[k].status === 'pending') { deliveries[k].status = 'paid'; deliveries[k].paidAt = Date.now(); deliveries[k].stripeTransferId = transfer.id; } });
        await new Promise(r => fbWrite('PATCH', `driverEarnings/freight/${companyId}/${did}`, { pendingAmount: 0, deliveries, updatedAt: Date.now() }, r));
        await new Promise(r => fbWrite('PUT', `driverPayouts/freight/${companyId}/payout_${Date.now()}_${did}`, { driverId: did, amount: pending, schedule: payCfg.schedule, status: 'paid', stripeTransferId: transfer.id, triggeredAt: Date.now() }, r));
        results.push({ driverId: did, name: drv.name, amount: pending, status: 'paid', stripeTransferId: transfer.id });
      } catch (se: any) { results.push({ driverId: did, name: drv.name, status: 'error', reason: se.message }); }
    }
    res.json({ ok: true, results, total: results.length });
  } catch (e: any) { res.json({ error: e.message }); }
});

export default router;
