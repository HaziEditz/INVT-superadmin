import { Router, Request, Response, NextFunction } from 'express';
import { fbRead, fbWrite, fbAuthCreate, fbAuthSignIn, fbAuthSendReset } from '../firebase';
import { esc, getStripe, getResendClient } from '../utils';
import { rpGetSession, rpSetSession, rpDeleteSession, restaurantSessions } from '../sessions';

const router = Router();

const OWNER_PORTAL_URL = process.env.OWNER_PORTAL_URL || 'https://portal.bookawaka.co.nz';

// ── CSS ───────────────────────────────────────────────────────────────────────
const RP_CSS = `
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#FFF8F5;color:#333;font-size:14px;min-height:100vh}
a{color:inherit;text-decoration:none}
.rp-nav{background:#BF360C;color:#fff;height:52px;padding:0 24px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100;box-shadow:0 2px 8px rgba(0,0,0,.25)}
.rp-nav-brand{font-size:15px;font-weight:700;display:flex;align-items:center;gap:6px}
.rp-nav-links{display:flex}
.rp-nav-links a{color:rgba(255,255,255,.78);padding:17px 13px;font-size:12.5px;display:flex;align-items:center;gap:4px;border-bottom:3px solid transparent;transition:all .15s}
.rp-nav-links a:hover{background:rgba(255,255,255,.1);color:#fff}
.rp-nav-links a.on{color:#fff;border-bottom-color:#FFAB40;background:rgba(255,255,255,.08)}
.rp-nav-right{font-size:12px;opacity:.75;display:flex;align-items:center;gap:14px}
.rp-main{padding:22px 24px;max-width:1280px;margin:0 auto}
.rp-card{background:#fff;border-radius:6px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:18px;overflow:hidden}
.rp-card-hd{padding:13px 18px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between}
.rp-card-hd h3{font-size:14px;font-weight:700;color:#BF360C;display:flex;align-items:center;gap:6px}
.rp-card-bd{padding:16px 18px}
.rp-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:18px}
.rp-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #E65100}
.rp-stat.green{border-left-color:#2E7D32}.rp-stat.blue{border-left-color:#1565C0}
.rp-stat-v{font-size:26px;font-weight:700;color:#E65100;line-height:1.1}
.rp-stat.green .rp-stat-v{color:#2E7D32}.rp-stat.blue .rp-stat-v{color:#1565C0}
.rp-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.rp-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.rp-tbl th{background:#FFF3E0;padding:9px 11px;text-align:left;font-size:11.5px;font-weight:700;color:#BF360C;border-bottom:2px solid #FFCC80;white-space:nowrap}
.rp-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.rp-tbl tr:last-child td{border-bottom:none}
.rp-tbl tr:hover td{background:#FFFDE7}
.rp-empty{text-align:center;color:#aaa;padding:24px;font-style:italic}
.rp-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:600}
.rp-btn-o{background:#E65100;color:#fff}.rp-btn-g{background:#2E7D32;color:#fff}.rp-btn-r{background:#C62828;color:#fff}
.rp-bdg-y{display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600;background:#FFF8E1;color:#F57F17}
.rp-bdg-o{background:#FFF3E0;color:#E65100;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.rp-bdg-b{background:#E3F2FD;color:#1565C0;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.rp-bdg-g{background:#E8F5E9;color:#2E7D32;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.rp-bdg-r{background:#FFEBEE;color:#C62828;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.rp-bdg-gr{background:#F5F5F5;color:#757575;display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600}
.rp-filter{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:16px}
.rp-filter select{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.rp-filter label{font-size:13px;font-weight:500;color:#555}
.rp-notice{padding:12px 16px;border-radius:6px;margin-bottom:16px;font-size:13px}
.rp-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.rp-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.rp-tog-on{background:#E8F5E9;color:#2E7D32;border:1px solid #C8E6C9;padding:4px 10px;border-radius:12px;font-size:11.5px;font-weight:600;cursor:pointer}
.rp-tog-off{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;padding:4px 10px;border-radius:12px;font-size:11.5px;font-weight:600;cursor:pointer}
`;

function renderRpNav(session: any, token: string, activePage: string): string {
  const te = encodeURIComponent(token);
  const pages: [string, string][] = [
    ['dashboard', '&#128202; Dashboard'],
    ['orders', '&#128203; Orders'],
    ['menu', '&#127829; Menu'],
    ['hours', '&#128336; Hours'],
    ['earnings', '&#128200; Earnings'],
    ['payouts', '&#128181; Payouts'],
    ['settings', '&#9881; Settings']
  ];
  const links = pages.map(([pg, lbl]) =>
    `<a href="/restaurant-portal/${pg}?t=${te}" class="${activePage === pg ? 'on' : ''}">${lbl}</a>`
  ).join('');
  return `<nav class="rp-nav">
  <div class="rp-nav-brand">&#127829; <span>${esc(session.name || 'Restaurant Portal')}</span></div>
  <div class="rp-nav-links">${links}</div>
  <div class="rp-nav-right">
    <span>${esc(session.email || '')}</span>
    <a href="/api/restaurant-logout?t=${te}" style="opacity:1;color:#FFAB40">Sign Out</a>
  </div>
</nav>`;
}

function rpPage(title: string, nav: string, body: string): string {
  return `<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} &mdash; Restaurant Portal</title>
<style>${RP_CSS}</style></head>
<body>${nav}<div class="rp-main">${body}</div></body></html>`;
}

function rpOrderBadge(s: string): string {
  const m: Record<string, string> = {
    pending: '<span class="rp-bdg-y">Pending</span>',
    accepted: '<span class="rp-bdg-b">Accepted</span>',
    preparing: '<span class="rp-bdg-o">Preparing</span>',
    ready: '<span class="rp-bdg-b">Ready</span>',
    picked_up: '<span class="rp-bdg-b">Picked Up</span>',
    delivered: '<span class="rp-bdg-g">Delivered</span>',
    cancelled: '<span class="rp-bdg-r">Cancelled</span>'
  };
  return m[s] || `<span class="rp-bdg-gr">${esc(s)}</span>`;
}

function requireRestaurantAuth(req: Request, res: Response, next: NextFunction): void {
  const token = (req.query.t as string) || '';
  const session = rpGetSession(token);
  if (!session) { res.redirect('/restaurant-portal?err=session'); return; }
  (req as any).rpSession = session;
  (req as any).rpToken = token;
  next();
}

// ── Set restaurant password (called from SA admin) ────────────────────────────
router.post('/api/set-restaurant-password', (req, res) => {
  const { restaurantId, email, password, companyId } = req.body;
  if (!restaurantId || !email || !password) return res.status(400).json({ error: 'Missing fields' });
  if ((password as string).length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' });
  const emailClean = (email as string).toLowerCase().trim();
  fbAuthCreate(emailClean, password, (authErr: any, authUser: any) => {
    if (authErr) {
      if (authErr.message === 'EMAIL_EXISTS') {
        return res.json({ error: 'A login account already exists for this email. Use Send Reset Email to set a new password.' });
      }
      return res.json({ error: authErr.message || 'Failed to create login account' });
    }
    const data: any = { email: emailClean, uid: authUser.uid, companyId: companyId || '', active: true, createdAt: Date.now() };
    fbWrite('PUT', 'foodRestaurantAccess/' + restaurantId, data, (err: any) => {
      if (err) return res.json({ error: String(err) });
      res.json({ ok: true, uid: authUser.uid });
    });
  });
});

// ── Login / logout ─────────────────────────────────────────────────────────────
router.post('/api/restaurant-login', (req, res) => {
  const email = ((req.body.email as string) || '').trim().toLowerCase();
  const password = (req.body.password as string) || '';
  if (!email || !password) return res.redirect('/restaurant-portal?err=missing');
  fbAuthSignIn(email, password, (authErr: any, authUser: any) => {
    if (authErr) return res.redirect('/restaurant-portal?err=invalid');
    fbRead('foodRestaurantAccess', (err: any, data: any) => {
      if (err || !data) return res.redirect('/restaurant-portal?err=nodata');
      let matched: any = null;
      for (const [rid, acc] of Object.entries(data) as [string, any][]) {
        if (acc && acc.uid === authUser.uid && acc.active !== false) {
          matched = { restaurantId: rid, ...acc }; break;
        }
      }
      if (!matched) return res.redirect('/restaurant-portal?err=invalid');
      const companyId = matched.companyId || '';
      fbRead('foodClients/' + companyId + '/' + matched.restaurantId, (e2: any, cfg: any) => {
        const name = cfg && cfg.name ? cfg.name : matched.restaurantId;
        const token = rpSetSession(matched.restaurantId, name, email, companyId);
        fbWrite('PUT', 'foodRestaurantAccess/' + matched.restaurantId + '/lastLogin', Date.now(), () => {});
        res.redirect('/restaurant-portal/dashboard?t=' + encodeURIComponent(token));
      });
    });
  });
});

router.get('/api/restaurant-logout', (req, res) => {
  const tok = (req.query.t as string) || '';
  if (tok) rpDeleteSession(tok as string);
  res.redirect('/restaurant-portal');
});

// ── Send portal reset email ───────────────────────────────────────────────────
router.post('/api/send-portal-reset', (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Email required' });
  fbAuthSendReset((email as string).toLowerCase().trim(), (err: any) => {
    if (err) return res.json({ error: err.message || 'Could not send reset email' });
    res.json({ ok: true, message: 'Password reset email sent to ' + email });
  });
});

// ── Company Portal redirect ───────────────────────────────────────────────────
router.get('/company-portal', (req, res) => {
  const cid = req.query.cid ? '?cid=' + encodeURIComponent(req.query.cid as string) : '';
  res.redirect(302, OWNER_PORTAL_URL + '/Default.aspx' + cid);
});

// ── Login page ─────────────────────────────────────────────────────────────────
router.get('/restaurant-portal', (req, res) => {
  const err = (req.query.err as string) || '';
  const errMsgs: Record<string, string> = {
    invalid: 'Invalid email or password.',
    missing: 'Please enter your email and password.',
    nodata: 'Unable to verify credentials.',
    session: 'Your session has expired. Please sign in again.'
  };
  const errHtml = err ? `<div class="err-msg">${esc(errMsgs[err] || 'Sign in error.')}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Restaurant Portal &mdash; BookaWaka</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:linear-gradient(135deg,#BF360C,#E65100);min-height:100vh;display:flex;align-items:center;justify-content:center;font-family:'Segoe UI',system-ui,sans-serif}
.box{background:#fff;border-radius:10px;padding:40px;width:400px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.box h1{font-size:22px;color:#BF360C;margin-bottom:4px}
.box p{color:#888;font-size:13px;margin-bottom:28px}
label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
input{width:100%;padding:10px 12px;border:1px solid #ddd;border-radius:6px;font-size:14px;margin-bottom:18px;box-sizing:border-box}
input:focus{outline:none;border-color:#E65100;box-shadow:0 0 0 3px rgba(230,81,0,.1)}
button{width:100%;padding:12px;background:#E65100;color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:600;cursor:pointer}
button:hover{background:#BF360C}
.err-msg{background:#FFEBEE;color:#C62828;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px;border-left:4px solid #C62828}
.hint{text-align:center;font-size:12px;color:#aaa;margin-top:18px}
</style></head>
<body>
<div class="box">
  <h1>&#127829; Restaurant Portal</h1>
  <p>BookaWaka &mdash; Food Delivery System</p>
  ${errHtml}
  <form method="POST" action="/api/restaurant-login">
    <label>Email Address</label>
    <input type="email" name="email" placeholder="owner@yourrestaurant.com" required autocomplete="email"/>
    <label>Password</label>
    <input type="password" name="password" required autocomplete="current-password"/>
    <button type="submit">Sign In</button>
  </form>
  <p class="hint">Forgot your password?<br>Contact your BookaWaka administrator.</p>
</div>
</body></html>`);
});

// ── Dashboard ──────────────────────────────────────────────────────────────────
router.get('/restaurant-portal/dashboard', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  const now = new Date();
  const today = now.toISOString().slice(0, 10);
  const curMonth = now.toISOString().slice(0, 7);
  fbRead('foodOrders/' + (sess.companyId || ''), (err: any, orders: any) => {
    fbRead('foodClients/' + (sess.companyId || '') + '/' + sess.restaurantId, (e2: any, cfg: any) => {
      const allOrds = orders || {};
      const myOrders = Object.entries(allOrds).filter(([, o]: [string, any]) => o.restaurantId === sess.restaurantId);
      const todayOrds = myOrders.filter(([, o]: [string, any]) => o.createdAt && new Date(o.createdAt).toISOString().slice(0, 10) === today);
      const monthOrds = myOrders.filter(([, o]: [string, any]) => o.createdAt && new Date(o.createdAt).toISOString().slice(0, 7) === curMonth);
      const pending = myOrders.filter(([, o]: [string, any]) => o.status === 'pending').length;
      let todayRev = 0, monthRev = 0;
      todayOrds.forEach(([, o]: [string, any]) => { if (o.status === 'delivered') todayRev += parseFloat(o.restaurantPayout || 0); });
      monthOrds.forEach(([, o]: [string, any]) => { if (o.status === 'delivered') monthRev += parseFloat(o.restaurantPayout || 0); });
      const recent = [...myOrders].sort((a: any, b: any) => (b[1].createdAt || 0) - (a[1].createdAt || 0)).slice(0, 8);
      const recentRows = recent.map(([id, o]: [string, any]) => {
        const dt = o.createdAt ? new Date(o.createdAt).toLocaleString('en-NZ', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' }) : '—';
        const items = (o.items || []).map((i: any) => `${i.qty || 1}x ${esc(i.name || '')}`).join(', ') || '—';
        return `<tr><td style="font-family:monospace;font-size:11px">${esc(id.slice(-8))}</td>
<td>${esc(o.customerName || '—')}</td><td style="font-size:11.5px;color:#666">${items}</td>
<td>${dt}</td><td style="font-weight:600">$${parseFloat(o.subtotal || 0).toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:700">$${parseFloat(o.restaurantPayout || 0).toFixed(2)}</td>
<td>${rpOrderBadge(o.status)}</td></tr>`;
      }).join('');
      const cfgHtml = cfg ? `<div class="rp-card"><div class="rp-card-hd"><h3>Store Settings</h3></div><div class="rp-card-bd">
<table style="font-size:13px;width:100%">
<tr><td style="padding:4px 8px;color:#666">Delivery Radius</td><td style="padding:4px 8px;font-weight:500">${cfg.deliveryRadius || '—'} km</td>
    <td style="padding:4px 8px;color:#666">Delivery Fee</td><td style="padding:4px 8px;font-weight:500">$${parseFloat(cfg.deliveryFee || 0).toFixed(2)}</td></tr>
<tr><td style="padding:4px 8px;color:#666">Minimum Order</td><td style="padding:4px 8px;font-weight:500">$${parseFloat(cfg.minOrder || 0).toFixed(2)}</td>
    <td style="padding:4px 8px;color:#666">Avg Prep Time</td><td style="padding:4px 8px;font-weight:500">${cfg.prepTime || '—'} min</td></tr>
<tr><td style="padding:4px 8px;color:#666">Food Commission</td><td style="padding:4px 8px;font-weight:500;color:#E65100">${cfg.foodCommissionPct || 0}%</td>
    <td style="padding:4px 8px;color:#666">Payout Schedule</td><td style="padding:4px 8px;font-weight:500">${cfg.payoutSchedule || 'weekly'}</td></tr>
</table></div></div>` : '';
      const body = `<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:16px">Dashboard &mdash; ${esc(today)}</h2>
<div class="rp-stats">
  <div class="rp-stat"><div class="rp-stat-v">${todayOrds.length}</div><div class="rp-stat-l">Orders Today</div></div>
  <div class="rp-stat green"><div class="rp-stat-v">$${todayRev.toFixed(2)}</div><div class="rp-stat-l">Your Revenue Today</div></div>
  <div class="rp-stat"><div class="rp-stat-v">${monthOrds.length}</div><div class="rp-stat-l">Orders This Month</div></div>
  <div class="rp-stat green"><div class="rp-stat-v">$${monthRev.toFixed(2)}</div><div class="rp-stat-l">Your Revenue This Month</div></div>
  ${pending > 0 ? `<div class="rp-stat blue"><div class="rp-stat-v">${pending}</div><div class="rp-stat-l">Pending Orders</div></div>` : ''}
</div>
${cfgHtml}
<div class="rp-card">
  <div class="rp-card-hd"><h3>Recent Orders</h3>
    <a href="/restaurant-portal/orders?t=${encodeURIComponent(token)}" style="font-size:12px;color:#E65100">View all &rarr;</a></div>
  ${recent.length ? `<table class="rp-tbl"><thead><tr><th>Order</th><th>Customer</th><th>Items</th><th>Time</th><th>Subtotal</th><th>Your Share</th><th>Status</th></tr></thead>
<tbody>${recentRows}</tbody></table>` : '<div class="rp-empty">No orders yet.</div>'}
</div>`;
      res.send(rpPage('Dashboard', renderRpNav(sess, token, 'dashboard'), body));
    });
  });
});

// ── Order actions ──────────────────────────────────────────────────────────────
router.post('/api/restaurant-order-action', (req, res) => {
  const token = (req.body._token as string) || '';
  const orderId = (req.body.orderId as string) || '';
  const action = (req.body.action as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  const validActions = ['accepted', 'preparing', 'ready', 'cancelled'];
  if (!sess || !orderId || !validActions.includes(action)) {
    return res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Invalid+request&mt=err');
  }
  const cid = sess.companyId || '';
  const patch: any = { status: action, [`${action}At`]: Date.now() };
  fbWrite('PATCH', 'foodOrders/' + cid + '/' + orderId, patch, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Update+failed&mt=err');
    // When the order is "ready" for pickup, push it into the dispatch queue so
    // drivers actually get notified. Dispatch listens on pendingjobs/{cid}/* —
    // it has NO listener on foodOrders/* (per PLATFORM-INTEGRATION-CHECKLIST).
    if (action === 'ready') {
      // Guard against duplicate dispatch if owner toggles preparing → ready → preparing → ready.
      // Only write to pendingjobs if no record exists yet for this orderId.
      fbRead('pendingjobs/' + cid + '/' + orderId, (eExist: any, existing: any) => {
        if (!eExist && existing) return; // already dispatched, do not re-push
        fbRead('foodOrders/' + cid + '/' + orderId, (e2: any, order: any) => {
          if (e2 || !order) return; // best-effort, status already updated
          fbRead('foodClients/' + cid + '/' + sess.restaurantId, (_e3: any, rest: any) => {
            const r = rest || {};
            const pj: any = {
              bookingId: orderId,
              bookingType: 'food',
              jobType: 'food',
              serviceType: 'food',
              restaurantId: sess.restaurantId,
              restaurantName: r.name || sess.name || '',
              PickupAddress: r.address || '',
              pickupAddress: r.address || '',
              pickupLocation: r.location || null,
              DropoffAddress: order.deliveryAddress || order.dropoffAddress || '',
              dropoffAddress: order.deliveryAddress || order.dropoffAddress || '',
              dropoffLocation: order.dropoffLocation || order.deliveryLocation || null,
              CustomerName: order.customerName || '',
              customerName: order.customerName || '',
              CustomerPhone: order.customerPhone || '',
              customerPhone: order.customerPhone || '',
              FinalFare: order.deliveryFee || 0,
              fare: order.deliveryFee || 0,
              total: order.total || 0,
              subtotal: order.subtotal || 0,
              PaymentType: (order.paymentMethod || 'card'),
              paymentMethod: (order.paymentMethod || 'card'),
              paymentStatus: order.paymentStatus || '',
              items: order.items || [],
              Status: 'Pending',
              status: 'Pending',
              CreatedAt: Date.now(),
              createdAt: Date.now(),
              source: 'restaurant-portal'
            };
            fbWrite('PUT', 'pendingjobs/' + cid + '/' + orderId, pj, () => {});
          });
        });
      });
    }
    res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Order+updated&mt=ok');
  });
});

// ── Orders ─────────────────────────────────────────────────────────────────────
router.get('/restaurant-portal/orders', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  const filterStatus = (req.query.status as string) || '';
  const filterMonth = (req.query.month as string) || '';
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const te = encodeURIComponent(token);
  fbRead('foodOrders/' + (sess.companyId || ''), (err: any, orders: any) => {
    const allOrds = orders || {};
    let myOrders = Object.entries(allOrds).filter(([, o]: [string, any]) => o.restaurantId === sess.restaurantId);
    const months: Record<string, boolean> = {};
    myOrders.forEach(([, o]: [string, any]) => { if (o.createdAt) months[new Date(o.createdAt).toISOString().slice(0, 7)] = true; });
    const sortedMonths = Object.keys(months).sort().reverse();
    if (filterStatus) myOrders = myOrders.filter(([, o]: [string, any]) => o.status === filterStatus);
    if (filterMonth) myOrders = myOrders.filter(([, o]: [string, any]) => o.createdAt && new Date(o.createdAt).toISOString().slice(0, 7) === filterMonth);
    myOrders.sort((a: any, b: any) => (b[1].createdAt || 0) - (a[1].createdAt || 0));
    const monthOpts = sortedMonths.map(m => `<option value="${esc(m)}" ${m === filterMonth ? 'selected' : ''}>${m}</option>`).join('');
    const noticeHtml = msg ? `<div class="rp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
    const rows = myOrders.map(([id, o]: [string, any]) => {
      const dt = o.createdAt ? new Date(o.createdAt).toLocaleString('en-NZ', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' }) : '—';
      const items = (o.items || []).map((i: any) => `${i.qty || 1}&#215;${esc(i.name || '')}`).join(', ') || '—';
      const actionBtns: string[] = [];
      if (o.status === 'pending') {
        actionBtns.push(`<form method="POST" action="/api/restaurant-order-action" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="action" value="accepted"/>
<button type="submit" class="rp-btn rp-btn-g" style="margin-right:4px">Accept</button></form>`);
        actionBtns.push(`<form method="POST" action="/api/restaurant-order-action" style="display:inline" onsubmit="return confirm('Cancel this order?')">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="action" value="cancelled"/>
<button type="submit" class="rp-btn rp-btn-r">Cancel</button></form>`);
      } else if (o.status === 'accepted') {
        actionBtns.push(`<form method="POST" action="/api/restaurant-order-action" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="action" value="preparing"/>
<button type="submit" class="rp-btn rp-btn-o">Mark Preparing</button></form>`);
      } else if (o.status === 'preparing') {
        actionBtns.push(`<form method="POST" action="/api/restaurant-order-action" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="action" value="ready"/>
<button type="submit" class="rp-btn rp-btn-g">Mark Ready</button></form>`);
      } else if (o.status === 'ready' || o.status === 'picked_up') {
        // Manual delivery completion (for testing or where dispatch hasn't called the API yet).
        // Prompts for an optional driver ID — blank = compute payouts without writing driverEarnings.
        actionBtns.push(`<form method="POST" action="/api/restaurant-order-mark-delivered" style="display:inline" onsubmit="var d=prompt('Driver ID for earnings (leave blank to skip):',''); this.driverId.value=d||''; return true;">
<input type="hidden" name="_token" value="${esc(token)}"/><input type="hidden" name="orderId" value="${esc(id)}"/><input type="hidden" name="driverId" value=""/>
<button type="submit" class="rp-btn rp-btn-g">Mark Delivered</button></form>`);
      }
      return `<tr><td style="font-family:monospace;font-size:11px">${esc(id.slice(-8))}</td>
<td>${esc(o.customerName || '—')}</td><td style="font-size:11.5px">${items}</td>
<td style="white-space:nowrap">${dt}</td>
<td>$${parseFloat(o.subtotal || 0).toFixed(2)}</td>
<td style="color:#E65100">$${parseFloat(o.deliveryFee || 0).toFixed(2)}</td>
<td style="font-weight:700">$${parseFloat(o.total || 0).toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:700">$${parseFloat(o.restaurantPayout || 0).toFixed(2)}</td>
<td>${rpOrderBadge(o.status)}</td>
<td style="white-space:nowrap">${actionBtns.join('') || '—'}</td></tr>`;
    }).join('');
    const statusOpts = ['', 'pending', 'accepted', 'preparing', 'ready', 'picked_up', 'delivered', 'cancelled']
      .map(s => `<option value="${s}" ${s === filterStatus ? 'selected' : ''}>${s || 'All Statuses'}</option>`).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:16px">Orders (${myOrders.length})</h2>
${noticeHtml}
<div class="rp-filter">
  <form method="GET" action="/restaurant-portal/orders" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap">
    <input type="hidden" name="t" value="${esc(token)}"/>
    <label>Status:</label><select name="status">${statusOpts}</select>
    <label>Month:</label><select name="month"><option value="">All Months</option>${monthOpts}</select>
    <button type="submit" class="rp-btn rp-btn-o" style="padding:7px 14px">Filter</button>
    <a href="/restaurant-portal/orders?t=${te}" class="rp-btn" style="background:#eee;color:#333;padding:7px 12px">Clear</a>
  </form>
</div>
<div class="rp-card" style="overflow-x:auto">
${myOrders.length ? `<table class="rp-tbl"><thead><tr><th>Order</th><th>Customer</th><th>Items</th><th>Time</th><th>Subtotal</th><th>Delivery</th><th>Total</th><th>Your Share</th><th>Status</th><th>Action</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="rp-empty">No orders found.</div>'}
</div>`;
    res.send(rpPage('Orders', renderRpNav(sess, token, 'orders'), body));
  });
});

// ── Menu toggle ────────────────────────────────────────────────────────────────
router.post('/api/restaurant-menu-toggle', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const available = req.body.available === 'true';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !itemId) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Invalid+request&mt=err');
  fbWrite('PATCH', 'foodMenu/' + sess.restaurantId + '/items/' + itemId, { available, updatedAt: Date.now() }, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Update+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Item+updated&mt=ok');
  });
});

// ── Menu page ──────────────────────────────────────────────────────────────────
router.get('/restaurant-portal/menu', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const te = encodeURIComponent(token);
  fbRead('foodMenu/' + sess.restaurantId, (err: any, menu: any) => {
    const m = menu || {};
    const cats = m.categories || {};
    const items = m.items || {};
    const noticeHtml = msg ? `<div class="rp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
    const catList = Object.keys(cats).sort((a, b) => (cats[a].sortOrder || 0) - (cats[b].sortOrder || 0));
    const itemsHtml = catList.length ? catList.map(catId => {
      const cat = cats[catId];
      const catItems = Object.entries(items).filter(([, it]: [string, any]) => it.category === catId)
        .sort((a: any, b: any) => (a[1].sortOrder || 0) - (b[1].sortOrder || 0));
      const itemRows = catItems.map(([iid, it]: [string, any]) => {
        const avail = it.available !== false;
        const toggleBtn = `<form method="POST" action="/api/restaurant-menu-toggle" style="display:inline">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(iid)}"/>
<input type="hidden" name="available" value="${avail ? 'false' : 'true'}"/>
<button type="submit" class="${avail ? 'rp-tog-on' : 'rp-tog-off'}">${avail ? '&#10003; Available' : '&#10005; Unavailable'}</button></form>`;
        const imgThumb = it.imageUrl ? `<img src="${esc(it.imageUrl)}" alt="" style="width:48px;height:48px;object-fit:cover;border-radius:4px;border:1px solid #eee"/>` : '<span style="color:#bbb;font-size:11px">—</span>';
        const editForm = `<tr id="edit_${esc(iid)}" style="display:none;background:#FFF8E1"><td colspan="6" style="padding:12px">
<form method="POST" action="/api/restaurant-menu-edit-item" onsubmit="return rpReadImg(this,'imgEdit_${esc(iid)}')" style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(iid)}"/>
<input type="hidden" name="imageUrl" value="${esc(it.imageUrl || '')}"/>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Name</label>
<input type="text" name="name" value="${esc(it.name || '')}" required style="padding:6px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:180px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Description</label>
<input type="text" name="description" value="${esc(it.description || '')}" style="padding:6px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:220px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Price ($)</label>
<input type="number" name="price" value="${it.price || 0}" step="0.01" min="0" style="padding:6px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:90px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Image (optional, &lt;2MB)</label>
<input type="file" id="imgEdit_${esc(iid)}" accept="image/*" style="font-size:11.5px"/></div>
<button type="submit" class="rp-btn rp-btn-o">Save</button>
<button type="button" onclick="document.getElementById('edit_${esc(iid)}').style.display='none'" class="rp-btn" style="background:#eee;color:#333">Cancel</button>
<a href="/restaurant-portal/menu/options?item=${esc(iid)}&amp;t=${te}" class="rp-btn" style="background:#FFE0B2;color:#BF360C;text-decoration:none;display:inline-block">&#9881; Manage Options &amp; Add-ons</a>
</form>
<form method="POST" action="/api/restaurant-menu-delete-item" style="display:inline;margin-left:8px" onsubmit="return confirm('Delete this item?')">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(iid)}"/>
<button type="submit" class="rp-btn rp-btn-r">Delete</button>
</form>
</td></tr>`;
        const vCount = Object.keys(it.variants || {}).length;
        const mCount = Object.keys(it.modifiers || {}).length;
        const optsBadge = (vCount || mCount) ? `<div style="font-size:11px;color:#E65100;margin-top:3px">${vCount ? vCount + ' variant' + (vCount !== 1 ? 's' : '') : ''}${vCount && mCount ? ', ' : ''}${mCount ? mCount + ' add-on group' + (mCount !== 1 ? 's' : '') : ''}</div>` : '';
        return `<tr><td style="width:60px">${imgThumb}</td><td style="font-weight:500">${esc(it.name || '—')}</td>
<td style="font-size:12px;color:#666">${esc(it.description || '—')}${optsBadge}</td>
<td style="font-weight:700;color:#E65100">$${parseFloat(it.price || 0).toFixed(2)}</td>
<td>${toggleBtn}</td>
<td><button type="button" onclick="var r=document.getElementById('edit_${esc(iid)}');r.style.display=r.style.display==='none'?'table-row':'none'" class="rp-btn" style="background:#FFF3E0;color:#E65100;font-size:11px">Edit</button></td></tr>
${editForm}`;
      }).join('');
      const addItemForm = `<tr style="background:#FFFDE7"><td colspan="6" style="padding:10px">
<form method="POST" action="/api/restaurant-menu-add-item" onsubmit="return rpReadImg(this,'imgAdd_${esc(catId)}')" style="display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="catId" value="${esc(catId)}"/>
<input type="hidden" name="imageUrl" value=""/>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Item Name *</label>
<input type="text" name="name" required placeholder="e.g. Burger" style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:160px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Price ($) *</label>
<input type="number" name="price" step="0.01" min="0" required style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:80px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Description</label>
<input type="text" name="description" placeholder="Optional" style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:200px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Image (optional)</label>
<input type="file" id="imgAdd_${esc(catId)}" accept="image/*" style="font-size:11.5px"/></div>
<button type="submit" class="rp-btn rp-btn-g" style="font-size:11px">+ Add Item</button>
</form>
</td></tr>`;
      return `<div class="rp-card" style="margin-bottom:16px">
<div class="rp-card-hd"><h3>&#127829; ${esc(cat.name || catId)}</h3>
<form method="POST" action="/api/restaurant-menu-delete-category" style="display:inline" onsubmit="return confirm('Delete this category and all its items?')">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="catId" value="${esc(catId)}"/>
<button type="submit" class="rp-btn rp-btn-r" style="font-size:11px">Delete Category</button>
</form></div>
<table class="rp-tbl"><thead><tr><th style="width:60px">Img</th><th>Item</th><th>Description</th><th>Price</th><th>Available</th><th>Edit</th></tr></thead>
<tbody>${itemRows}${addItemForm}</tbody></table>
</div>`;
    }).join('') : '<div class="rp-notice" style="background:#FFF3E0;color:#E65100;border-left:4px solid #E65100;margin-bottom:16px">No categories yet. Add a category below to start building your menu.</div>';
    const addCatForm = `<div class="rp-card" style="margin-bottom:16px">
<div class="rp-card-hd"><h3>&#10010; Add Category</h3></div>
<div class="rp-card-bd">
<form method="POST" action="/api/restaurant-menu-add-category" style="display:flex;gap:10px;align-items:center">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="text" name="catName" required placeholder="e.g. Burgers, Drinks, Desserts" style="padding:8px 12px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:240px"/>
<button type="submit" class="rp-btn rp-btn-o">Add Category</button>
</form>
</div></div>`;
    // Client-side helper: read file input, downscale to <=600px JPEG @ 0.7,
    // stuff base64 result into the form's hidden imageUrl field, then submit.
    const imgScript = `<script>
function rpReadImg(form, fileInputId){
  var fi = document.getElementById(fileInputId);
  if (!fi || !fi.files || !fi.files[0]) return true; // no new file, submit as-is
  var f = fi.files[0];
  if (f.size > 2*1024*1024) { alert('Image too large — must be under 2MB.'); return false; }
  var reader = new FileReader();
  reader.onload = function(ev){
    var img = new Image();
    img.onload = function(){
      var max = 600;
      var w = img.width, h = img.height;
      if (w > h && w > max) { h = Math.round(h*max/w); w = max; }
      else if (h >= w && h > max) { w = Math.round(w*max/h); h = max; }
      var canvas = document.createElement('canvas');
      canvas.width = w; canvas.height = h;
      canvas.getContext('2d').drawImage(img, 0, 0, w, h);
      var b64 = canvas.toDataURL('image/jpeg', 0.7);
      if (b64.length > 250000) { alert('Image still too large after compression. Try a smaller photo.'); return; }
      form.querySelector('input[name=imageUrl]').value = b64;
      form.submit();
    };
    img.src = ev.target.result;
  };
  reader.readAsDataURL(f);
  return false; // wait for async load+resize, then submit programmatically
}
</script>`;
    const body = `<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:8px">Menu Management</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Add, edit, and manage your menu categories and items. Photos are auto-resized to 600px and compressed.</p>
${noticeHtml}${addCatForm}${itemsHtml}${imgScript}`;
    res.send(rpPage('Menu', renderRpNav(sess, token, 'menu'), body));
  });
});

// ── Menu APIs ──────────────────────────────────────────────────────────────────
router.post('/api/restaurant-menu-add-category', (req, res) => {
  const token = (req.body._token as string) || '';
  const catName = ((req.body.catName as string) || '').trim();
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !catName) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Invalid+request&mt=err');
  const catId = 'cat_' + Date.now();
  fbWrite('PUT', 'foodMenu/' + sess.restaurantId + '/categories/' + catId, { name: catName, sortOrder: Date.now(), createdAt: Date.now() }, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Failed+to+add+category&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Category+added&mt=ok');
  });
});

// Validate a base64 data-URL image. Returns the string if valid, else '' (drop).
function rpValidImg(s: any): string {
  const str = typeof s === 'string' ? s : '';
  if (!str) return '';
  if (!/^data:image\/(jpeg|jpg|png|webp);base64,/.test(str)) return '';
  if (str.length > 300000) return ''; // ~225KB raw — guardrail
  return str;
}

router.post('/api/restaurant-menu-add-item', (req, res) => {
  const token = (req.body._token as string) || '';
  const name = ((req.body.name as string) || '').trim();
  const description = ((req.body.description as string) || '').trim();
  const price = parseFloat(req.body.price || 0);
  const catId = (req.body.catId as string) || '';
  const imageUrl = rpValidImg(req.body.imageUrl);
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !name || !catId || isNaN(price)) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Invalid+request&mt=err');
  const itemId = 'item_' + Date.now();
  const data: any = { name, description, price, category: catId, available: true, sortOrder: Date.now(), createdAt: Date.now() };
  if (imageUrl) data.imageUrl = imageUrl;
  fbWrite('PUT', 'foodMenu/' + sess.restaurantId + '/items/' + itemId, data, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Failed+to+add+item&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect('/restaurant-portal/menu?t=' + te + '&msg=' + encodeURIComponent(name + ' added') + '&mt=ok');
  });
});

router.post('/api/restaurant-menu-edit-item', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const name = ((req.body.name as string) || '').trim();
  const description = ((req.body.description as string) || '').trim();
  const price = parseFloat(req.body.price || 0);
  const imageUrl = rpValidImg(req.body.imageUrl);
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !itemId || !name || isNaN(price)) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Invalid+request&mt=err');
  const patch: any = { name, description, price, updatedAt: Date.now() };
  // Only overwrite imageUrl if a non-empty valid value was supplied; otherwise leave existing image untouched.
  if (imageUrl) patch.imageUrl = imageUrl;
  fbWrite('PATCH', 'foodMenu/' + sess.restaurantId + '/items/' + itemId, patch, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Update+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Item+updated&mt=ok');
  });
});

router.post('/api/restaurant-menu-delete-item', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !itemId) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Invalid+request&mt=err');
  fbWrite('DELETE', 'foodMenu/' + sess.restaurantId + '/items/' + itemId, null, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Delete+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Item+deleted&mt=ok');
  });
});

router.post('/api/restaurant-menu-delete-category', (req, res) => {
  const token = (req.body._token as string) || '';
  const catId = (req.body.catId as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !catId) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Invalid+request&mt=err');
  fbWrite('DELETE', 'foodMenu/' + sess.restaurantId + '/categories/' + catId, null, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Delete+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Category+deleted&mt=ok');
  });
});

// ── Opening Hours ──────────────────────────────────────────────────────────────
router.get('/restaurant-portal/hours', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const te = encodeURIComponent(token);
  const DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  fbRead('foodClients/' + (sess.companyId || '') + '/' + sess.restaurantId + '/hours', (err: any, hours: any) => {
    const h = hours || {};
    const noticeHtml = msg ? `<div class="rp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
    const dayRows = DAYS.map(day => {
      const d = h[day] || {};
      const isClosed = d.closed === true;
      return `<tr>
<td style="padding:10px 14px;font-weight:600;text-transform:capitalize;width:130px">${day}</td>
<td style="padding:10px 14px">
  <label style="display:flex;align-items:center;gap:6px;font-size:13px">
    <input type="checkbox" name="closed_${day}" value="1" ${isClosed ? 'checked' : ''} onchange="toggleDay('${day}',this.checked)"/>
    Closed all day
  </label>
</td>
<td id="times_${day}" style="padding:10px 14px;display:${isClosed ? 'none' : 'flex'};gap:10px;align-items:center">
  <label style="font-size:12px;color:#666">Open</label>
  <input type="time" name="open_${day}" value="${esc(d.open || '09:00')}" style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/>
  <label style="font-size:12px;color:#666">Close</label>
  <input type="time" name="close_${day}" value="${esc(d.close || '21:00')}" style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:13px"/>
</td>
</tr>`;
    }).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:8px">Opening Hours</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Set your regular opening and closing times for each day of the week.</p>
${noticeHtml}
<div class="rp-card">
<div class="rp-card-hd"><h3>&#128336; Weekly Hours</h3></div>
<div class="rp-card-bd">
<form method="POST" action="/api/restaurant-hours-save">
<input type="hidden" name="_token" value="${esc(token)}"/>
<table style="width:100%">${dayRows}</table>
<div style="margin-top:16px">
<button type="submit" class="rp-btn rp-btn-g" style="padding:10px 24px">Save Hours</button>
</div>
</form>
</div></div>
<script>
function toggleDay(day,closed){
  var el=document.getElementById('times_'+day);
  if(el) el.style.display=closed?'none':'flex';
}
</script>`;
    res.send(rpPage('Opening Hours', renderRpNav(sess, token, 'hours'), body));
  });
});

router.post('/api/restaurant-hours-save', (req, res) => {
  const token = (req.body._token as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess) return res.redirect('/restaurant-portal/hours?t=' + te + '&msg=Session+expired&mt=err');
  const DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  const hours: Record<string, any> = {};
  DAYS.forEach(day => {
    hours[day] = {
      closed: req.body['closed_' + day] === '1',
      open: req.body['open_' + day] || '09:00',
      close: req.body['close_' + day] || '21:00'
    };
  });
  fbWrite('PUT', 'foodClients/' + (sess.companyId || '') + '/' + sess.restaurantId + '/hours', hours, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/hours?t=' + te + '&msg=Save+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect('/restaurant-portal/hours?t=' + te + '&msg=Hours+saved+successfully&mt=ok');
  });
});

// ── Mirror helper ──────────────────────────────────────────────────────────────
// `foodClients/{cid}/{rid}` is the SA + owner source of truth, but the passenger
// app and customer-facing website read from `fdRestaurants/{cid}/{rid}` per
// PLATFORM-INTEGRATION-CHECKLIST.md. We mirror config + menu + hours into
// `fdRestaurants` after every owner/menu/SA write so the customer side sees
// fresh data. Best-effort — failures are logged, never block the user.
function rpMirrorToFdRestaurants(cid: string, rid: string): void {
  if (!cid || !rid) return;
  fbRead('foodClients/' + cid + '/' + rid, (e1: any, cfg: any) => {
    if (e1 || !cfg) return;
    fbRead('foodMenu/' + rid, (_e2: any, menu: any) => {
      const m = menu || {};
      // Strip portal-only / sensitive fields before publishing customer-side.
      const { notes: _notes, ...publicCfg } = cfg;
      const payload: any = {
        ...publicCfg,
        rid,
        cid,
        menu: {
          categories: m.categories || {},
          items: m.items || {}
        },
        mirroredAt: Date.now()
      };
      fbWrite('PUT', 'fdRestaurants/' + cid + '/' + rid, payload, (e3: any) => {
        if (e3) console.error('[mirror→fdRestaurants]', cid, rid, e3);
      });
    });
  });
}

// ── Settings ───────────────────────────────────────────────────────────────────
// Shows everything SA configured (read-only) + the small set of fields the
// restaurant owner can edit themselves (description, cuisine, cover photo, phone).
router.get('/restaurant-portal/settings', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const te = encodeURIComponent(token);
  fbRead('foodClients/' + (sess.companyId || '') + '/' + sess.restaurantId, (err: any, cfg: any) => {
    const c = cfg || {};
    const noticeHtml = msg ? `<div class="rp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
    const cover = c.coverImage ? `<img src="${esc(c.coverImage)}" alt="" style="width:200px;height:120px;object-fit:cover;border-radius:6px;border:1px solid #eee"/>` : '<div style="width:200px;height:120px;background:#f5f5f5;border-radius:6px;display:flex;align-items:center;justify-content:center;color:#bbb;font-size:12px">No cover image</div>';
    const ro = (label: string, val: any, suffix = '') => `<tr><td style="padding:7px 12px;color:#666;width:200px">${esc(label)}</td><td style="padding:7px 12px;font-weight:600">${esc(String(val ?? '—'))}${suffix}</td></tr>`;
    const body = `<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:8px">Settings</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Your restaurant profile and the rates set by BookaWaka.</p>
${noticeHtml}
<div class="rp-card">
<div class="rp-card-hd"><h3>&#127859; Profile (you can edit)</h3></div>
<div class="rp-card-bd">
<form method="POST" action="/api/restaurant-settings-save" onsubmit="return rpReadCover(this)">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="coverImage" value="${esc(c.coverImage || '')}"/>
<div style="display:flex;gap:24px;align-items:flex-start;flex-wrap:wrap">
<div>${cover}<div style="margin-top:8px"><label style="font-size:12px;color:#666;display:block;margin-bottom:4px">Change cover photo (max 2MB)</label><input type="file" id="rp-cover-file" accept="image/*" style="font-size:12px"/></div></div>
<div style="flex:1;min-width:300px;display:grid;grid-template-columns:1fr 1fr;gap:12px 18px">
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Cuisine type</label><input type="text" name="cuisine" value="${esc(c.cuisine || '')}" placeholder="e.g. Italian, Indian, Burgers" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Contact phone</label><input type="text" name="phone" value="${esc(c.phone || '')}" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/></div>
<div style="grid-column:1/-1"><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Description (shown to customers)</label><textarea name="description" rows="3" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box;font-family:inherit">${esc(c.description || '')}</textarea></div>
</div></div>
<div style="margin-top:16px"><button type="submit" class="rp-btn rp-btn-o">Save Profile</button></div>
</form>
</div></div>

<div class="rp-card">
<div class="rp-card-hd"><h3>&#128666; Delivery &amp; Operations (you can edit)</h3></div>
<div class="rp-card-bd">
<form method="POST" action="/api/restaurant-settings-save">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="section" value="operations"/>
<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px 18px">
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Delivery radius (km)</label><input type="number" name="deliveryRadius" step="0.5" min="0.5" value="${c.deliveryRadius || ''}" placeholder="5" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Default delivery fee ($)</label><input type="number" name="deliveryFee" step="0.50" min="0" value="${c.deliveryFee || ''}" placeholder="8.00" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Minimum order ($)</label><input type="number" name="minOrder" step="0.50" min="0" value="${c.minOrder || ''}" placeholder="15.00" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Average prep time (min)</label><input type="number" name="prepTime" step="1" min="5" value="${c.prepTime || ''}" placeholder="25" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/></div>
<div><label style="display:block;font-size:12px;font-weight:600;margin-bottom:4px">Payout schedule</label><select name="payoutSchedule" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box">
<option value="weekly" ${(c.payoutSchedule || 'weekly') === 'weekly' ? 'selected' : ''}>Weekly</option>
<option value="monthly" ${c.payoutSchedule === 'monthly' ? 'selected' : ''}>Monthly</option>
<option value="daily" ${c.payoutSchedule === 'daily' ? 'selected' : ''}>Daily</option>
</select></div>
</div>
<div style="margin-top:14px"><button type="submit" class="rp-btn rp-btn-o">Save Operations</button></div>
</form>
</div></div>

<div class="rp-card">
<div class="rp-card-hd"><h3>&#128205; Account &amp; Rates (set by BookaWaka)</h3></div>
<div class="rp-card-bd">
<table style="width:100%;font-size:13px;border-collapse:collapse">
${ro('Restaurant name', c.name)}
${ro('Email', c.email)}
${ro('Owner / contact name', c.contactName)}
${ro('Address', c.address)}
${ro('Food commission', (c.foodCommissionPct ?? '—') + (c.foodCommissionPct != null ? '%' : ''))}
${ro('Delivery commission', (c.deliveryCommissionPct ?? '—') + (c.deliveryCommissionPct != null ? '%' : ''))}
${ro('Status', c.active === false ? 'Inactive' : 'Active')}
</table>
<p style="font-size:12px;color:#888;margin-top:14px">Commission rates are set by your BookaWaka administrator. To change them, contact support.</p>
<details style="margin-top:10px"><summary style="font-size:11.5px;color:#999;cursor:pointer">Connection details (for support)</summary>
<div style="font-family:monospace;font-size:11px;color:#666;margin-top:6px;padding:6px 8px;background:#fafafa;border:1px solid #eee;border-radius:4px">
Company ID: ${esc(sess.companyId || '(missing)')}<br/>Restaurant ID: ${esc(sess.restaurantId || '(missing)')}<br/>Data found: ${cfg ? 'yes' : 'no — empty record at foodClients/' + esc(sess.companyId || '') + '/' + esc(sess.restaurantId || '')}
</div></details>
</div></div>
<script>
function rpReadCover(form){
  var fi = document.getElementById('rp-cover-file');
  if (!fi || !fi.files || !fi.files[0]) return true;
  var f = fi.files[0];
  if (f.size > 2*1024*1024) { alert('Image too large — must be under 2MB.'); return false; }
  var reader = new FileReader();
  reader.onload = function(ev){
    var img = new Image();
    img.onload = function(){
      var max = 1000;
      var w = img.width, h = img.height;
      if (w > h && w > max) { h = Math.round(h*max/w); w = max; }
      else if (h >= w && h > max) { w = Math.round(w*max/h); h = max; }
      var canvas = document.createElement('canvas');
      canvas.width = w; canvas.height = h;
      canvas.getContext('2d').drawImage(img, 0, 0, w, h);
      var b64 = canvas.toDataURL('image/jpeg', 0.75);
      if (b64.length > 400000) { alert('Image still too large after compression. Try a smaller photo.'); return; }
      form.querySelector('input[name=coverImage]').value = b64;
      form.submit();
    };
    img.src = ev.target.result;
  };
  reader.readAsDataURL(f);
  return false;
}
</script>`;
    res.send(rpPage('Settings', renderRpNav(sess, token, 'settings'), body));
  });
});

router.post('/api/restaurant-settings-save', (req, res) => {
  const token = (req.body._token as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess) return res.redirect('/restaurant-portal/settings?t=' + te + '&msg=Session+expired&mt=err');
  const cid = sess.companyId || '';
  const section = ((req.body.section as string) || 'profile');
  const patch: any = { updatedAt: Date.now() };
  if (section === 'operations') {
    // Owner-editable operational fields. Bounded to safe ranges so a typo
    // can't put the restaurant into a non-functional state.
    const dr = parseFloat(req.body.deliveryRadius || '');
    const df = parseFloat(req.body.deliveryFee || '');
    const mo = parseFloat(req.body.minOrder || '');
    const pt = parseInt(req.body.prepTime || '', 10);
    const ps = (req.body.payoutSchedule as string) || 'weekly';
    if (!isNaN(dr) && dr > 0 && dr <= 50)   patch.deliveryRadius = dr;
    if (!isNaN(df) && df >= 0 && df <= 200) patch.deliveryFee = df;
    if (!isNaN(mo) && mo >= 0 && mo <= 500) patch.minOrder = mo;
    if (!isNaN(pt) && pt >= 5 && pt <= 240) patch.prepTime = pt;
    if (['weekly', 'monthly', 'daily'].indexOf(ps) >= 0) patch.payoutSchedule = ps;
  } else {
    patch.description = ((req.body.description as string) || '').trim().slice(0, 1000);
    patch.cuisine     = ((req.body.cuisine as string) || '').trim().slice(0, 80);
    patch.phone       = ((req.body.phone as string) || '').trim().slice(0, 40);
    const raw = typeof req.body.coverImage === 'string' ? req.body.coverImage : '';
    if (raw && /^data:image\/(jpeg|jpg|png|webp);base64,/.test(raw) && raw.length <= 500000) patch.coverImage = raw;
  }
  fbWrite('PATCH', 'foodClients/' + cid + '/' + sess.restaurantId, patch, (err: any) => {
    if (err) return res.redirect('/restaurant-portal/settings?t=' + te + '&msg=Save+failed&mt=err');
    rpMirrorToFdRestaurants(cid, sess.restaurantId);
    res.redirect('/restaurant-portal/settings?t=' + te + '&msg=' + (section === 'operations' ? 'Operations+saved' : 'Profile+saved') + '&mt=ok');
  });
});

// ── Earnings ───────────────────────────────────────────────────────────────────
router.get('/restaurant-portal/earnings', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  const view = (req.query.view as string) || 'monthly';
  const te = encodeURIComponent(token);
  fbRead('foodOrders/' + (sess.companyId || ''), (err: any, orders: any) => {
    const allOrds = orders || {};
    const myDelivered = Object.entries(allOrds).filter(([, o]: [string, any]) => o.restaurantId === sess.restaurantId && o.status === 'delivered');
    const daily: Record<string, any> = {}, weekly: Record<string, any> = {}, monthly: Record<string, any> = {}, yearly: Record<string, any> = {};
    myDelivered.forEach(([, o]: [string, any]) => {
      if (!o.createdAt) return;
      const d = new Date(o.createdAt);
      const day = d.toISOString().slice(0, 10);
      const yr = d.getFullYear();
      const wk = `${yr}-W${String(Math.ceil(((d.getTime() - new Date(yr, 0, 1).getTime()) / 86400000 + 1) / 7)).padStart(2, '0')}`;
      const mon = d.toISOString().slice(0, 7);
      const net = parseFloat(o.restaurantPayout || 0);
      const com = parseFloat(o.foodCommission || 0);
      const gross = parseFloat(o.subtotal || 0);
      const maps = [daily, weekly, monthly, yearly];
      const keys = [day, wk, mon, String(yr)];
      maps.forEach((map, i) => {
        const key = keys[i];
        if (!map[key]) map[key] = { orders: 0, gross: 0, commission: 0, net: 0 };
        map[key].orders++; map[key].gross += gross; map[key].commission += com; map[key].net += net;
      });
    });
    const views: Record<string, any> = { daily, weekly, monthly, yearly };
    const data = views[view] || monthly;
    const sorted = Object.keys(data).sort().reverse();
    const totalOrders = sorted.reduce((s, k) => s + data[k].orders, 0);
    const totalNet = sorted.reduce((s, k) => s + data[k].net, 0);
    const totalCom = sorted.reduce((s, k) => s + data[k].commission, 0);
    const rows = sorted.map(k => {
      const d = data[k];
      return `<tr><td style="font-weight:600">${esc(k)}</td><td>${d.orders}</td>
<td>$${d.gross.toFixed(2)}</td>
<td style="color:#E65100">$${d.commission.toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:700">$${d.net.toFixed(2)}</td></tr>`;
    }).join('');
    const tabs = ['daily', 'weekly', 'monthly', 'yearly'].map(v =>
      `<a href="/restaurant-portal/earnings?t=${te}&view=${v}" style="padding:7px 16px;border-radius:4px;font-size:13px;font-weight:600;background:${v === view ? '#E65100' : '#f5f5f5'};color:${v === view ? '#fff' : '#555'};text-decoration:none;text-transform:capitalize">${v}</a>`
    ).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:8px">Earnings Reports</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Your revenue breakdown — commission is what BookaWaka deducts; your net is what you receive.</p>
<div style="display:flex;gap:8px;margin-bottom:16px">${tabs}</div>
<div class="rp-stats">
  <div class="rp-stat"><div class="rp-stat-v">${totalOrders}</div><div class="rp-stat-l">Total Orders (${view})</div></div>
  <div class="rp-stat green"><div class="rp-stat-v">$${totalNet.toFixed(2)}</div><div class="rp-stat-l">Your Net Earnings</div></div>
  <div class="rp-stat"><div class="rp-stat-v">$${totalCom.toFixed(2)}</div><div class="rp-stat-l">Total Commission Paid</div></div>
</div>
<div class="rp-card" style="overflow-x:auto">
${rows.length ? `<table class="rp-tbl"><thead><tr><th>Period</th><th>Orders</th><th>Gross Sales</th><th>Commission</th><th>Your Earnings</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="rp-empty">No completed orders yet.</div>'}
</div>`;
    res.send(rpPage('Earnings', renderRpNav(sess, token, 'earnings'), body));
  });
});

// ── Payouts ────────────────────────────────────────────────────────────────────
router.get('/restaurant-portal/payouts', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  fbRead('foodOrders/' + (sess.companyId || ''), (err: any, orders: any) => {
    fbRead('foodPayouts/' + (sess.companyId || '') + '/restaurants/' + sess.restaurantId, (e2: any, payouts: any) => {
      const allOrds = orders || {};
      const myDelivered = Object.entries(allOrds).filter(([, o]: [string, any]) => o.restaurantId === sess.restaurantId && o.status === 'delivered');
      const periods: Record<string, any> = {};
      myDelivered.forEach(([, o]: [string, any]) => {
        if (!o.createdAt) return;
        const p = new Date(o.createdAt).toISOString().slice(0, 7);
        if (!periods[p]) periods[p] = { orders: 0, gross: 0, commission: 0, net: 0 };
        periods[p].orders++;
        periods[p].gross += parseFloat(o.subtotal || 0);
        periods[p].commission += parseFloat(o.foodCommission || 0);
        periods[p].net += parseFloat(o.restaurantPayout || 0);
      });
      const savedPayouts = payouts || {};
      const sortedPeriods = Object.keys(periods).sort().reverse();
      const rows = sortedPeriods.map(p => {
        const d = periods[p];
        const paidStatus = (savedPayouts[p] || {}).status || 'pending';
        const badge = paidStatus === 'paid' ? '<span class="rp-bdg-g">Paid</span>' : '<span class="rp-bdg-y">Pending</span>';
        const paidDate = (savedPayouts[p] || {}).updatedAt ? new Date((savedPayouts[p] || {}).updatedAt).toLocaleDateString('en-NZ') : '—';
        return `<tr><td style="font-weight:600">${p}</td><td>${d.orders}</td>
<td>$${d.gross.toFixed(2)}</td>
<td style="color:#E65100">-$${d.commission.toFixed(2)}</td>
<td style="color:#2E7D32;font-weight:700">$${d.net.toFixed(2)}</td>
<td>${badge}</td><td>${paidStatus === 'paid' ? paidDate : '—'}</td></tr>`;
      }).join('');
      const body = `<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:8px">Settlement Statements</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Your monthly revenue after BookaWaka commission is deducted. Payouts marked <strong>Paid</strong> have been transferred to your account.</p>
<div class="rp-card" style="overflow-x:auto">
${sortedPeriods.length ? `<table class="rp-tbl"><thead><tr><th>Period</th><th>Orders</th><th>Gross Sales</th><th>Commission Deducted</th><th>Your Payout</th><th>Status</th><th>Paid Date</th></tr></thead>
<tbody>${rows}</tbody></table>` : '<div class="rp-empty">No completed orders yet.</div>'}
</div>`;
      res.send(rpPage('Payouts', renderRpNav(sess, token, 'payouts'), body));
    });
  });
});

// ── Stripe Connect ─────────────────────────────────────────────────────────────
router.post('/api/stripe/connect/create-account', async (req, res) => {
  try {
    const { entityType, entityId, companyId, email, name } = req.body;
    if (!entityType || !entityId || !email) return res.status(400).json({ error: 'entityType, entityId and email required' });
    const stripe = getStripe();
    const account = await stripe.accounts.create({
      type: 'express', country: 'NZ', email,
      capabilities: { card_payments: { requested: true }, transfers: { requested: true } },
      business_type: 'individual',
      metadata: { entityType, entityId, companyId: companyId || '' }
    });
    const fbPath = entityType === 'restaurant' ? `foodRestaurantAccess/${entityId}/stripeConnectId` :
      entityType === 'freight' ? `freightAccess/${entityId}/stripeConnectId` : null;
    if (fbPath) fbWrite('PUT', fbPath, account.id, () => {});
    res.json({ ok: true, accountId: account.id });
  } catch (err: any) {
    console.error('[stripe-connect] create-account error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post('/api/stripe/connect/onboard-link', async (req, res) => {
  try {
    const { accountId } = req.body;
    if (!accountId) return res.status(400).json({ error: 'accountId required' });
    const stripe = getStripe();
    const baseUrl = `https://${(process.env.REPLIT_DOMAINS || '').split(',')[0]}`;
    const link = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `${baseUrl}/api/stripe/connect/onboard-link`,
      return_url: `${baseUrl}/SA-FD-Restaurants.aspx?connect=done`,
      type: 'account_onboarding'
    });
    res.json({ ok: true, url: link.url });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/api/stripe/connect/create-payment', async (req, res) => {
  try {
    const { amount, currency, connectedAccountId, applicationFeeAmount, description, metadata } = req.body;
    if (!amount || !connectedAccountId) return res.status(400).json({ error: 'amount and connectedAccountId required' });
    const stripe = getStripe();
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(Number(amount) * 100),
      currency: (currency || 'nzd').toLowerCase(),
      application_fee_amount: Math.round(Number(applicationFeeAmount || 0) * 100),
      transfer_data: { destination: connectedAccountId },
      description: description || 'BookaWaka payment',
      metadata: metadata || {}
    });
    res.json({ ok: true, clientSecret: paymentIntent.client_secret, paymentIntentId: paymentIntent.id });
  } catch (err: any) {
    console.error('[stripe-connect] create-payment error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ── Item Options Page (variants + modifier groups) ─────────────────────────────
router.get('/restaurant-portal/menu/options', requireRestaurantAuth, (req, res) => {
  const sess = (req as any).rpSession;
  const token = (req as any).rpToken;
  const itemId = (req.query.item as string) || '';
  const msg = (req.query.msg as string) || '';
  const mt = (req.query.mt as string) || '';
  const te = encodeURIComponent(token);
  if (!itemId) return res.redirect('/restaurant-portal/menu?t=' + te);
  fbRead('foodMenu/' + sess.restaurantId + '/items/' + itemId, (err: any, item: any) => {
    if (err || !item) return res.redirect('/restaurant-portal/menu?t=' + te + '&msg=Item+not+found&mt=err');
    const variants = item.variants || {};
    const modifiers = item.modifiers || {};
    const noticeHtml = msg ? `<div class="rp-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
    const vSorted = Object.entries(variants).sort((a: any, b: any) => (a[1].sortOrder || 0) - (b[1].sortOrder || 0));
    const vRows = vSorted.map(([vid, v]: [string, any]) => {
      const pd = parseFloat(v.priceDelta || 0);
      return `<tr><td style="font-weight:500">${esc(v.name || '')}</td>
<td style="font-weight:600;color:#E65100">${pd >= 0 ? '+' : ''}$${pd.toFixed(2)}</td>
<td><form method="POST" action="/api/restaurant-variant-delete" style="display:inline" onsubmit="return confirm('Remove this variant?')">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(itemId)}"/>
<input type="hidden" name="vid" value="${esc(vid)}"/>
<button type="submit" class="rp-btn rp-btn-r" style="font-size:11px">Remove</button></form></td></tr>`;
    }).join('');
    const mSorted = Object.entries(modifiers).sort((a: any, b: any) => (a[1].sortOrder || 0) - (b[1].sortOrder || 0));
    const mGroupCards = mSorted.map(([gid, g]: [string, any]) => {
      const opts = g.options || {};
      const oSorted = Object.entries(opts).sort((a: any, b: any) => (a[1].sortOrder || 0) - (b[1].sortOrder || 0));
      const oRows = oSorted.map(([oid, o]: [string, any]) => `<tr>
<td style="font-weight:500">${esc(o.name || '')}</td><td>$${parseFloat(o.price || 0).toFixed(2)}</td>
<td><form method="POST" action="/api/restaurant-modoption-delete" style="display:inline" onsubmit="return confirm('Remove this add-on?')">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(itemId)}"/>
<input type="hidden" name="gid" value="${esc(gid)}"/>
<input type="hidden" name="oid" value="${esc(oid)}"/>
<button type="submit" class="rp-btn rp-btn-r" style="font-size:11px">Remove</button></form></td></tr>`).join('');
      return `<div class="rp-card" style="margin-bottom:12px">
<div class="rp-card-hd"><h3>${esc(g.name || '')} <small style="font-weight:400;color:#888">${g.required ? '(required)' : '(optional)'} &middot; ${g.multi ? 'multi-select' : 'single choice'}</small></h3>
<form method="POST" action="/api/restaurant-modgroup-delete" style="display:inline" onsubmit="return confirm('Delete the whole group and its options?')">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(itemId)}"/>
<input type="hidden" name="gid" value="${esc(gid)}"/>
<button type="submit" class="rp-btn rp-btn-r" style="font-size:11px">Delete Group</button></form>
</div>
<div class="rp-card-bd">
${oRows.length ? `<table class="rp-tbl"><thead><tr><th>Option</th><th>Extra Price</th><th>Action</th></tr></thead><tbody>${oRows}</tbody></table>` : '<div style="color:#888;font-size:13px;padding:8px 0">No options in this group yet.</div>'}
<form method="POST" action="/api/restaurant-modoption-save" style="margin-top:12px;display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap;border-top:1px dashed #eee;padding-top:10px">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(itemId)}"/>
<input type="hidden" name="gid" value="${esc(gid)}"/>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Option Name *</label>
<input type="text" name="name" required placeholder="e.g. Cheese" style="padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:170px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Extra Price ($)</label>
<input type="number" name="price" step="0.01" min="0" value="0" style="padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:90px"/></div>
<button type="submit" class="rp-btn rp-btn-g" style="font-size:12px">+ Add Option</button>
</form>
</div></div>`;
    }).join('');
    const body = `<div style="margin-bottom:8px"><a href="/restaurant-portal/menu?t=${te}" style="color:#E65100;text-decoration:none;font-size:13px">&larr; Back to Menu</a></div>
<h2 style="font-size:18px;font-weight:700;color:#BF360C;margin-bottom:8px">${esc(item.name || 'Item')} &mdash; Options &amp; Add-ons</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px"><strong>Variants</strong> are exclusive choices (e.g. size &mdash; customer picks one). <strong>Add-on groups</strong> let customers add optional extras like sauces or toppings.</p>
${noticeHtml}
<div class="rp-card" style="margin-bottom:20px">
<div class="rp-card-hd"><h3>&#127869; Variants (size, style, etc.)</h3></div>
<div class="rp-card-bd">
${vRows ? `<table class="rp-tbl"><thead><tr><th>Variant Name</th><th>Price &Delta;</th><th>Action</th></tr></thead><tbody>${vRows}</tbody></table>` : '<div style="color:#888;font-size:13px;padding:8px 0">No variants yet. Add one below if this item has size or style choices.</div>'}
<form method="POST" action="/api/restaurant-variant-save" style="margin-top:12px;display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap;border-top:1px dashed #eee;padding-top:10px">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(itemId)}"/>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Variant Name *</label>
<input type="text" name="name" required placeholder="e.g. Large" style="padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:180px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Price &Delta; ($, 0 = same as base)</label>
<input type="number" name="priceDelta" step="0.01" value="0" style="padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:120px"/></div>
<button type="submit" class="rp-btn rp-btn-g" style="font-size:12px">+ Add Variant</button>
</form>
</div></div>
<h3 style="font-size:15px;font-weight:700;color:#BF360C;margin-bottom:10px">Modifier Groups</h3>
${mGroupCards || '<div class="rp-empty" style="margin-bottom:12px">No add-on groups yet. Add one below &mdash; e.g. "Extras", "Sauces", "Spice Level".</div>'}
<div class="rp-card">
<div class="rp-card-hd"><h3>+ New Modifier Group</h3></div>
<div class="rp-card-bd">
<form method="POST" action="/api/restaurant-modgroup-save" style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap">
<input type="hidden" name="_token" value="${esc(token)}"/>
<input type="hidden" name="itemId" value="${esc(itemId)}"/>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Group Name *</label>
<input type="text" name="name" required placeholder="e.g. Extras, Sauces" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:220px"/></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Required?</label>
<select name="required" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px"><option value="false">Optional</option><option value="true">Required</option></select></div>
<div><label style="display:block;font-size:11px;font-weight:600;margin-bottom:3px">Selection Type</label>
<select name="multi" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px"><option value="false">Single choice</option><option value="true">Multi-select</option></select></div>
<button type="submit" class="rp-btn rp-btn-o">Create Group</button>
</form>
</div></div>`;
    res.send(rpPage('Item Options', renderRpNav(sess, token, 'menu'), body));
  });
});

// ── Variant CRUD ───────────────────────────────────────────────────────────────
router.post('/api/restaurant-variant-save', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const vidRaw = ((req.body.vid as string) || '').replace(/[^a-zA-Z0-9_-]/g, '');
  const vid = vidRaw || ('v_' + Date.now()); // never allow empty — would overwrite parent /variants node
  const name = ((req.body.name as string) || '').trim().slice(0, 60);
  const priceDelta = parseFloat(req.body.priceDelta || 0);
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  const back = '/restaurant-portal/menu/options?item=' + encodeURIComponent(itemId) + '&t=' + te;
  if (!sess || !itemId || !name) return res.redirect(back + '&msg=Invalid+request&mt=err');
  const data = { name, priceDelta: isNaN(priceDelta) ? 0 : priceDelta, sortOrder: Date.now() };
  fbWrite('PUT', 'foodMenu/' + sess.restaurantId + '/items/' + itemId + '/variants/' + vid, data, (err: any) => {
    if (err) return res.redirect(back + '&msg=Save+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect(back + '&msg=Variant+saved&mt=ok');
  });
});

router.post('/api/restaurant-variant-delete', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const vid = (req.body.vid as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  const back = '/restaurant-portal/menu/options?item=' + encodeURIComponent(itemId) + '&t=' + te;
  if (!sess || !itemId || !vid) return res.redirect(back + '&msg=Invalid+request&mt=err');
  fbWrite('DELETE', 'foodMenu/' + sess.restaurantId + '/items/' + itemId + '/variants/' + vid, null, (err: any) => {
    if (err) return res.redirect(back + '&msg=Delete+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect(back + '&msg=Variant+removed&mt=ok');
  });
});

// ── Modifier Group + Option CRUD ───────────────────────────────────────────────
router.post('/api/restaurant-modgroup-save', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const gidRaw = ((req.body.gid as string) || '').replace(/[^a-zA-Z0-9_-]/g, '');
  const gid = gidRaw || ('g_' + Date.now()); // never allow empty — would overwrite parent /modifiers node
  const name = ((req.body.name as string) || '').trim().slice(0, 60);
  const required = req.body.required === 'true';
  const multi = req.body.multi === 'true';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  const back = '/restaurant-portal/menu/options?item=' + encodeURIComponent(itemId) + '&t=' + te;
  if (!sess || !itemId || !name) return res.redirect(back + '&msg=Invalid+request&mt=err');
  const data = { name, required, multi, sortOrder: Date.now() };
  fbWrite('PATCH', 'foodMenu/' + sess.restaurantId + '/items/' + itemId + '/modifiers/' + gid, data, (err: any) => {
    if (err) return res.redirect(back + '&msg=Save+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect(back + '&msg=Group+saved&mt=ok');
  });
});

router.post('/api/restaurant-modgroup-delete', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const gid = (req.body.gid as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  const back = '/restaurant-portal/menu/options?item=' + encodeURIComponent(itemId) + '&t=' + te;
  if (!sess || !itemId || !gid) return res.redirect(back + '&msg=Invalid+request&mt=err');
  fbWrite('DELETE', 'foodMenu/' + sess.restaurantId + '/items/' + itemId + '/modifiers/' + gid, null, (err: any) => {
    if (err) return res.redirect(back + '&msg=Delete+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect(back + '&msg=Group+deleted&mt=ok');
  });
});

router.post('/api/restaurant-modoption-save', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const gid = (req.body.gid as string) || '';
  const oidRaw = ((req.body.oid as string) || '').replace(/[^a-zA-Z0-9_-]/g, '');
  const oid = oidRaw || ('o_' + Date.now()); // never allow empty — would overwrite parent /options node
  const name = ((req.body.name as string) || '').trim().slice(0, 60);
  const price = parseFloat(req.body.price || 0);
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  const back = '/restaurant-portal/menu/options?item=' + encodeURIComponent(itemId) + '&t=' + te;
  if (!sess || !itemId || !gid || !name) return res.redirect(back + '&msg=Invalid+request&mt=err');
  const data = { name, price: isNaN(price) ? 0 : price, sortOrder: Date.now() };
  fbWrite('PUT', 'foodMenu/' + sess.restaurantId + '/items/' + itemId + '/modifiers/' + gid + '/options/' + oid, data, (err: any) => {
    if (err) return res.redirect(back + '&msg=Save+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect(back + '&msg=Option+saved&mt=ok');
  });
});

router.post('/api/restaurant-modoption-delete', (req, res) => {
  const token = (req.body._token as string) || '';
  const itemId = (req.body.itemId as string) || '';
  const gid = (req.body.gid as string) || '';
  const oid = (req.body.oid as string) || '';
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  const back = '/restaurant-portal/menu/options?item=' + encodeURIComponent(itemId) + '&t=' + te;
  if (!sess || !itemId || !gid || !oid) return res.redirect(back + '&msg=Invalid+request&mt=err');
  fbWrite('DELETE', 'foodMenu/' + sess.restaurantId + '/items/' + itemId + '/modifiers/' + gid + '/options/' + oid, null, (err: any) => {
    if (err) return res.redirect(back + '&msg=Delete+failed&mt=err');
    rpMirrorToFdRestaurants(sess.companyId || '', sess.restaurantId);
    res.redirect(back + '&msg=Option+removed&mt=ok');
  });
});

// ── Delivery completion: compute payouts + write driver earnings ───────────────
// Single source of truth for the money split on a completed food delivery:
//   foodCommission     = subtotal     * foodCommissionPct     / 100
//   restaurantPayout   = subtotal     - foodCommission
//   deliveryCommission = deliveryFee  * deliveryCommissionPct / 100
//   driverPay          = deliveryFee  - deliveryCommission
// Writes to foodOrders/{cid}/{orderId} (drives owner Earnings/Payouts pages)
// and driverEarnings/food/{cid}/{driverId}/{orderId} (canonical food earnings
// path — parallel to driverEarnings/taxi/{cid}/{driverId} per replit.md).
// Also clears pendingjobs/{cid}/{orderId} so it doesn't linger after dispatch.
function rpComputeAndWriteDelivery(
  cid: string,
  orderId: string,
  driverId: string,
  vehicleId: string,
  cb: (err: any, result?: any) => void
): void {
  if (!cid || !orderId) return cb(new Error('cid_and_orderId_required'));
  fbRead('foodOrders/' + cid + '/' + orderId, (e1: any, order: any) => {
    if (e1 || !order) return cb(new Error('order_not_found'));
    fbRead('foodClients/' + cid + '/' + (order.restaurantId || ''), (_e2: any, rest: any) => {
      const r = rest || {};
      const subtotal = parseFloat(order.subtotal || 0);
      const deliveryFee = parseFloat(order.deliveryFee || 0);
      const foodPct = parseFloat(r.foodCommissionPct != null ? r.foodCommissionPct : 15);
      const delPct  = parseFloat(r.deliveryCommissionPct != null ? r.deliveryCommissionPct : 10);
      const foodCommission     = +(subtotal    * foodPct / 100).toFixed(2);
      const restaurantPayout   = +(subtotal    - foodCommission).toFixed(2);
      const deliveryCommission = +(deliveryFee * delPct / 100).toFixed(2);
      const driverPay          = +(deliveryFee - deliveryCommission).toFixed(2);
      const now = Date.now();
      const orderPatch: any = {
        status: 'delivered',
        deliveredAt: now,
        foodCommission, restaurantPayout, deliveryCommission, driverPay,
        foodCommissionPct: foodPct, deliveryCommissionPct: delPct
      };
      if (driverId)  orderPatch.driverId  = driverId;
      if (vehicleId) orderPatch.vehicleId = vehicleId;
      fbWrite('PATCH', 'foodOrders/' + cid + '/' + orderId, orderPatch, (e3: any) => {
        if (e3) return cb(e3);
        const result = { orderId, subtotal, deliveryFee, foodCommission, restaurantPayout, deliveryCommission, driverPay };
        // Clear from dispatch queue regardless of driver
        fbWrite('DELETE', 'pendingjobs/' + cid + '/' + orderId, null, () => {});
        if (!driverId) return cb(null, result); // no driver = skip earnings write
        const earnings: any = {
          orderId,
          restaurantId: order.restaurantId || '',
          driverPay,
          deliveryFee,
          deliveryCommission,
          vehicleId: vehicleId || '',
          completedAt: now,
          paymentMethod: order.paymentMethod || 'card'
        };
        fbWrite('PUT', 'driverEarnings/food/' + cid + '/' + driverId + '/' + orderId, earnings, (e4: any) => {
          if (e4) console.error('[food-delivery-complete] driverEarnings write failed', e4);
          cb(null, result);
        });
      });
    });
  });
}

// External endpoint: dispatch / driver app calls this when a delivery completes.
// Requires `X-Admin-Key` header matching `BW_ADMIN_KEY`. Body: {cid, orderId, driverId?, vehicleId?}
router.post('/api/food-delivery-complete', (req, res) => {
  const key = req.headers['x-admin-key'];
  if (!process.env.BW_ADMIN_KEY || key !== process.env.BW_ADMIN_KEY) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  const { cid, orderId, driverId, vehicleId } = req.body || {};
  if (!cid || !orderId) return res.status(400).json({ error: 'cid_and_orderId_required' });
  rpComputeAndWriteDelivery(String(cid), String(orderId), String(driverId || ''), String(vehicleId || ''), (err: any, result: any) => {
    if (err) return res.status(500).json({ error: err.message || 'failed' });
    res.json({ ok: true, ...result });
  });
});

// Owner-side manual delivery completion (session auth, no admin key).
// Driver ID is optional — blank just populates restaurant-side splits without
// writing driverEarnings (useful for testing the Earnings/Payouts reports).
router.post('/api/restaurant-order-mark-delivered', (req, res) => {
  const token = (req.body._token as string) || '';
  const orderId = (req.body.orderId as string) || '';
  const driverId = ((req.body.driverId as string) || '').trim();
  const sess = rpGetSession(token);
  const te = encodeURIComponent(token);
  if (!sess || !orderId) return res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Invalid+request&mt=err');
  // Ownership + status state-machine guard: verify the order belongs to this
  // restaurant and is in a deliverable state before running the money split.
  fbRead('foodOrders/' + (sess.companyId || '') + '/' + orderId, (eO: any, ord: any) => {
    if (eO || !ord) return res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Order+not+found&mt=err');
    if (ord.restaurantId !== sess.restaurantId) {
      return res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Not+your+order&mt=err');
    }
    if (ord.status !== 'ready' && ord.status !== 'picked_up') {
      return res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Order+is+not+ready+for+delivery&mt=err');
    }
    rpComputeAndWriteDelivery(sess.companyId || '', orderId, driverId, '', (err: any) => {
      if (err) return res.redirect('/restaurant-portal/orders?t=' + te + '&msg=' + encodeURIComponent(err.message || 'Update failed') + '&mt=err');
      res.redirect('/restaurant-portal/orders?t=' + te + '&msg=Order+marked+delivered&mt=ok');
    });
  });
});

export default router;
