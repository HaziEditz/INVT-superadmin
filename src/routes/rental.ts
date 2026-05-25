import { Router, Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import { fbRead, fbWrite, fbReadP, fbWriteP, fbAuthSignIn, fbAuthCreate } from '../firebase';
import { esc, getStripe, getResendClient, logAudit, generateJobId } from '../utils';
import { rentalSessions, genToken, SESSION_TTL, persistSessionDirect, unpersistSessionDirect } from '../sessions';
import { rentIsAvailable, rentCalcPricing, rentDays } from '../rentalHelpers';

const router = Router();

// ── Pending bookings store ────────────────────────────────────────────────────
const rentalPendingBookings = new Map<string, any>();
const RENT_PENDING_TTL = 30 * 60 * 1000;
const RN_TTL = 24 * 60 * 60 * 1000;

// ── Session helpers ───────────────────────────────────────────────────────────
function rnSetSession(companyId: string, name: string, email: string): string {
  const token = genToken(64);
  const sess = { companyId, name, email, exp: Date.now() + RN_TTL };
  rentalSessions[token] = sess;
  persistSessionDirect('rental', token, sess);
  return token;
}

function rnGetSession(token: string): any | null {
  if (!token) return null;
  const s = rentalSessions[token];
  if (!s) return null;
  if (Date.now() > s.exp) { delete rentalSessions[token]; unpersistSessionDirect('rental', token); return null; }
  s.exp = Date.now() + RN_TTL;
  return s;
}

function requireRentalAuth(req: any, res: Response, next: NextFunction): void {
  const token = req.query.t || '';
  const session = rnGetSession(token);
  if (!session) { res.redirect('/rental-portal?err=session'); return; }
  req.rnSession = session;
  req.rnToken = token;
  next();
}

// ── CSS ───────────────────────────────────────────────────────────────────────
const RENT_CSS = `
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#F8FFFE;color:#263238;font-size:14px}
a{color:inherit;text-decoration:none}
.rent-nav{background:#004D40;color:#fff;padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100;box-shadow:0 2px 10px rgba(0,0,0,.2)}
.rent-nav-brand{font-size:16px;font-weight:700;display:flex;align-items:center;gap:8px}
.rent-nav-links{display:flex;gap:4px}
.rent-nav-links a{color:rgba(255,255,255,.8);padding:8px 14px;border-radius:4px;font-size:13px;transition:all .15s}
.rent-nav-links a:hover{background:rgba(255,255,255,.1);color:#fff}
.rent-hero{background:linear-gradient(135deg,#004D40 0%,#00695C 60%,#00897B 100%);color:#fff;padding:56px 24px 0;text-align:center}
.rent-hero h1{font-size:36px;font-weight:800;margin-bottom:10px;text-shadow:0 2px 8px rgba(0,0,0,.2)}
.rent-hero p{font-size:16px;opacity:.85;margin-bottom:36px}
.rent-search-box{background:#fff;border-radius:12px;padding:28px 24px;box-shadow:0 8px 32px rgba(0,0,0,.18);max-width:860px;margin:0 auto 0;position:relative;bottom:-1px}
.rent-search-grid{display:grid;grid-template-columns:1fr 1fr 1fr auto;gap:14px;align-items:end}
@media(max-width:700px){.rent-search-grid{grid-template-columns:1fr}}
.rent-ff label{display:block;font-size:11.5px;font-weight:700;color:#374151;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px}
.rent-ff input,.rent-ff select{width:100%;padding:11px 14px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:14px;font-family:inherit;color:#263238}
.rent-ff input:focus,.rent-ff select:focus{outline:none;border-color:#00695C;box-shadow:0 0 0 3px rgba(0,105,92,.1)}
.rent-btn{padding:12px 24px;background:#00695C;color:#fff;border:none;border-radius:8px;font-size:14px;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:6px;white-space:nowrap}
.rent-btn:hover{background:#004D40}
.rent-btn-lg{padding:16px 36px;font-size:16px;border-radius:10px}
.rent-btn-blue{background:#1565C0}.rent-btn-blue:hover{background:#0D47A1}
.rent-btn-outline{background:transparent;border:2px solid #00695C;color:#00695C}
.rent-btn-outline:hover{background:#E0F2F1}
.rent-main{padding:40px 24px;max-width:1100px;margin:0 auto}
.rent-section-hdr{font-size:13px;font-weight:700;color:#00695C;margin-bottom:18px;display:flex;align-items:center;gap:8px}
.rent-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:20px}
.rent-card{background:#fff;border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,.08);overflow:hidden;transition:box-shadow .2s;border:1px solid #f0f0f0}
.rent-card:hover{box-shadow:0 6px 24px rgba(0,0,0,.14)}
.rent-card-img{height:140px;background:linear-gradient(135deg,#E0F2F1,#B2DFDB);display:flex;align-items:center;justify-content:center;font-size:64px}
.rent-card-body{padding:16px}
.rent-card-title{font-size:16px;font-weight:700;color:#263238;margin-bottom:4px}
.rent-card-sub{font-size:12px;color:#90A4AE;margin-bottom:10px}
.rent-card-price{font-size:24px;font-weight:800;color:#00695C}
.rent-card-price span{font-size:13px;font-weight:400;color:#90A4AE}
.rent-features{display:flex;gap:8px;flex-wrap:wrap;margin:10px 0}
.rent-feat{font-size:11.5px;background:#F5F5F5;color:#555;padding:3px 10px;border-radius:20px}
.rent-badge{display:inline-block;padding:3px 10px;border-radius:12px;font-size:11.5px;font-weight:700}
.rent-badge-g{background:#E8F5E9;color:#2E7D32}
.rent-badge-b{background:#E3F2FD;color:#1565C0}
.rent-badge-y{background:#FFF8E1;color:#F57F17}
.rent-badge-t{background:#E0F2F1;color:#00695C}
.rent-divider{height:1px;background:#f0f0f0;margin:20px 0}
.rent-2col{display:grid;grid-template-columns:2fr 1fr;gap:24px;align-items:start}
@media(max-width:768px){.rent-2col{grid-template-columns:1fr}}
.rent-sticky{position:sticky;top:72px}
.rent-summary-card{background:#fff;border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,.08);padding:20px;border:1px solid #f0f0f0}
.rent-notice{padding:14px 16px;border-radius:8px;margin-bottom:18px;font-size:13px}
.rent-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.rent-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.rent-notice.info{background:#E0F2F1;color:#004D40;border-left:4px solid #00695C}
.rent-step{display:flex;align-items:start;gap:14px;padding:14px 0;border-bottom:1px solid #f5f5f5}
.rent-step:last-child{border-bottom:none}
.rent-step-num{width:28px;height:28px;border-radius:50%;background:#00695C;color:#fff;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;flex-shrink:0}
.rent-addon-row{display:flex;align-items:center;gap:12px;padding:10px 14px;border:1.5px solid #e0e0e0;border-radius:8px;margin-bottom:8px;cursor:pointer;transition:all .15s}
.rent-addon-row.selected{border-color:#00695C;background:#E0F2F1}
.rent-ins-cards{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:16px}
@media(max-width:640px){.rent-ins-cards{grid-template-columns:1fr}}
.rent-ins-card{border:2px solid #e0e0e0;border-radius:8px;padding:14px;cursor:pointer;transition:all .15s;text-align:center}
.rent-ins-card:hover{border-color:#00695C}
.rent-ins-card.selected{border-color:#00695C;background:#E0F2F1}
.rent-ins-card.sel-standard{border-color:#1565C0;background:#E3F2FD}
.rent-ins-card.sel-full{border-color:#2E7D32;background:#E8F5E9}
.rent-ins-name{font-weight:700;font-size:13px;margin-bottom:4px}
.rent-ins-price{font-size:18px;font-weight:800;color:#00695C;margin:4px 0}
.rent-ins-excess{font-size:11px;color:#888}
#stripe-card-element{padding:12px 14px;border:1.5px solid #e0e0e0;border-radius:8px;margin-bottom:4px}
#stripe-card-element.StripeElement--focus{border-color:#00695C;box-shadow:0 0 0 3px rgba(0,105,92,.1)}
#card-errors{color:#C62828;font-size:12.5px;margin-top:4px;min-height:18px}
.rent-confirm-box{max-width:640px;margin:0 auto;text-align:center}
.rent-confirm-icon{font-size:72px;margin-bottom:16px}
.rent-r2r-card{background:linear-gradient(135deg,#004D40,#00695C);color:#fff;border-radius:12px;padding:28px;margin-top:24px;text-align:center}
.rent-r2r-card h3{font-size:20px;font-weight:700;margin-bottom:8px}
.rent-r2r-card p{opacity:.85;font-size:14px;margin-bottom:20px}
.rent-footer{background:#263238;color:rgba(255,255,255,.6);text-align:center;padding:24px;font-size:12.5px;margin-top:60px}
`;

const RN_CSS = `
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#F0FAF7;color:#333;font-size:14px;min-height:100vh}
a{color:inherit;text-decoration:none}
.rn-nav{background:#00695C;color:#fff;height:52px;padding:0 24px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100;box-shadow:0 2px 8px rgba(0,0,0,.25)}
.rn-nav-brand{font-size:15px;font-weight:700;display:flex;align-items:center;gap:6px}
.rn-nav-links{display:flex}
.rn-nav-links a{color:rgba(255,255,255,.78);padding:17px 12px;font-size:12.5px;display:flex;align-items:center;gap:4px;border-bottom:3px solid transparent;transition:all .15s}
.rn-nav-links a:hover{background:rgba(255,255,255,.1);color:#fff}
.rn-nav-links a.on{color:#fff;border-bottom-color:#A7FFEB;background:rgba(255,255,255,.08)}
.rn-nav-right{font-size:12px;opacity:.75;display:flex;align-items:center;gap:14px}
.rn-main{padding:22px 24px;max-width:1280px;margin:0 auto}
.rn-card{background:#fff;border-radius:6px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:18px;overflow:hidden}
.rn-card-hd{padding:13px 18px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.rn-card-hd h3{font-size:14px;font-weight:700;color:#00695C;display:flex;align-items:center;gap:6px}
.rn-card-bd{padding:16px 18px}
.rn-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:18px}
.rn-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #00695C}
.rn-stat.blue{border-left-color:#1565C0}.rn-stat.orange{border-left-color:#E65100}.rn-stat.purple{border-left-color:#6A1B9A}
.rn-stat-v{font-size:26px;font-weight:700;color:#00695C;line-height:1.1}
.rn-stat.blue .rn-stat-v{color:#1565C0}.rn-stat.orange .rn-stat-v{color:#E65100}.rn-stat.purple .rn-stat-v{color:#6A1B9A}
.rn-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.rn-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.rn-tbl th{background:#E0F2F1;padding:9px 11px;text-align:left;font-size:11.5px;font-weight:700;color:#00695C;border-bottom:2px solid #B2DFDB;white-space:nowrap}
.rn-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.rn-tbl tr:last-child td{border-bottom:none}
.rn-tbl tr:hover td{background:#F0FAF7}
.rn-empty{text-align:center;color:#aaa;padding:24px;font-style:italic}
.rn-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:12.5px;font-weight:600;text-decoration:none}
.rn-btn-g{background:#00695C;color:#fff}.rn-btn-g:hover{background:#004D40}
.rn-btn-b{background:#1565C0;color:#fff}.rn-btn-b:hover{background:#0D47A1}
.rn-btn-o{background:#E65100;color:#fff}.rn-btn-r{background:#C62828;color:#fff}
.rn-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.rn-notice{padding:12px 16px;border-radius:6px;margin-bottom:16px;font-size:13px}
.rn-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.rn-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.rn-ff label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:4px}
.rn-ff input,.rn-ff select,.rn-ff textarea{width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:5px;font-size:13px;box-sizing:border-box;font-family:inherit}
.rn-ff input:focus,.rn-ff select:focus{outline:none;border-color:#00695C}
.rn-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px}
.rn-grid-3{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:12px}
.rn-bdg-y{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:#FFF8E1;color:#F57F17}
.rn-bdg-b{background:#E3F2FD;color:#1565C0;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.rn-bdg-g{background:#E8F5E9;color:#2E7D32;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.rn-bdg-t{background:#E0F2F1;color:#00695C;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.rn-bdg-r{background:#FFEBEE;color:#C62828;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.rn-bdg-gr{background:#F5F5F5;color:#757575;display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.rn-section-hdr{padding:11px 18px;font-size:12.5px;font-weight:700;color:#00695C;background:#E0F2F1;border-bottom:1px solid #B2DFDB}
.rn-filter{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:14px}
.rn-filter select,.rn-filter input[type=date]{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.cal-grid{display:grid;grid-template-columns:repeat(7,1fr);gap:3px;margin-top:8px}
.cal-day{padding:8px 4px;text-align:center;border-radius:4px;font-size:12px;cursor:pointer;border:1px solid #e0e0e0;background:#fff}
.cal-day.blocked{background:#FFCDD2;color:#C62828;font-weight:700;border-color:#EF9A9A}
.cal-day.today{font-weight:700;outline:2px solid #00695C}
.cal-day.past{opacity:.4;cursor:default}
.cal-day:hover:not(.past){background:#E0F2F1}
.cal-hdr{text-align:center;font-size:11px;font-weight:700;color:#888;padding:4px}
`;

// ── Layout helpers ────────────────────────────────────────────────────────────
function rentNav(): string {
  return `<nav class="rent-nav">
  <div class="rent-nav-brand">&#128663; <span>BookaWaka Rentals</span></div>
  <div class="rent-nav-links">
    <a href="/rent">Search</a>
    <a href="/rent/booking">My Booking</a>
    <a href="/ride">Book a Taxi</a>
    <a href="/">Home</a>
  </div>
</nav>`;
}

function rentPage(title: string, body: string): string {
  return `<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} &mdash; BookaWaka Rentals</title>
<style>${RENT_CSS}</style></head>
<body>${rentNav()}<div class="rent-main">${body}</div>
<footer class="rent-footer">&copy; ${new Date().getFullYear()} BookaWaka. All rights reserved.</footer>
</body></html>`;
}

function renderRnNav(session: any, token: string, activePage: string): string {
  const te = encodeURIComponent(token);
  const pages: [string, string][] = [
    ['dashboard',     '&#128202; Dashboard'],
    ['reservations',  '&#128203; Reservations'],
    ['fleet',         '&#128663; Fleet'],
    ['availability',  '&#128197; Availability'],
    ['taxi-requests', '&#128664; Taxi Requests'],
    ['config',        '&#9881; Config']
  ];
  const links = pages.map(([pg, lbl]) =>
    `<a href="/rental-portal/${pg}?t=${te}" class="${activePage === pg ? 'on' : ''}">${lbl}</a>`
  ).join('');
  return `<nav class="rn-nav">
  <div class="rn-nav-brand">&#128663; <span>${esc(session.name || 'Rental Portal')}</span></div>
  <div class="rn-nav-links">${links}</div>
  <div class="rn-nav-right">
    <span>${esc(session.email || '')}</span>
    <a href="/api/rental-logout?t=${te}" style="color:#A7FFEB">Sign Out</a>
  </div>
</nav>`;
}

function rnPage(title: string, nav: string, body: string): string {
  return `<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} &mdash; Rental Portal</title>
<style>${RN_CSS}</style></head>
<body>${nav}<div class="rn-main">${body}</div></body></html>`;
}

function rnResBadge(s: string): string {
  const m: Record<string, string> = {
    pending:   '<span class="rn-bdg-y">Pending</span>',
    confirmed: '<span class="rn-bdg-b">Confirmed</span>',
    active:    '<span class="rn-bdg-t">Active</span>',
    completed: '<span class="rn-bdg-g">Completed</span>',
    cancelled: '<span class="rn-bdg-r">Cancelled</span>'
  };
  return m[s] || `<span class="rn-bdg-gr">${esc(s || 'unknown')}</span>`;
}

function rnVehicleBadge(s: string): string {
  if (s === 'available')   return '<span class="rn-bdg-g">Available</span>';
  if (s === 'maintenance') return '<span class="rn-bdg-y">Maintenance</span>';
  if (s === 'retired')     return '<span class="rn-bdg-gr">Retired</span>';
  return `<span class="rn-bdg-gr">${esc(s || '—')}</span>`;
}

// ── Email builders ────────────────────────────────────────────────────────────
function buildRentalCustomerEmail(d: any): string {
  const { customer, reservation, vehicle, companyName, promoCode, r2rConfig, pricing, jobId, cancelToken, baseUrl } = d;
  const fmt = (n: any) => '$' + parseFloat(n || 0).toFixed(2);
  const pickupFmt = reservation.pickupDate ? new Date(reservation.pickupDate).toLocaleDateString('en-NZ', { weekday: 'short', day: 'numeric', month: 'long', year: 'numeric' }) : '—';
  const returnFmt = reservation.returnDate ? new Date(reservation.returnDate).toLocaleDateString('en-NZ', { weekday: 'short', day: 'numeric', month: 'long', year: 'numeric' }) : '—';
  const insLabel: Record<string, string> = { basic: 'Basic Cover (up to $3,000 excess)', standard: 'Standard Protection ($800 excess)', full: 'Full Protection (Zero Excess)' };
  const insLabelStr = insLabel[reservation.insuranceTier] || reservation.insuranceTier || 'Basic';
  const addonsHtml = reservation.selectedAddons && reservation.selectedAddons.length
    ? reservation.selectedAddons.map((a: string) => `<tr><td style="padding:5px 0;color:#666;font-size:13px">${esc(a)}</td><td style="padding:5px 0;font-size:13px;text-align:right">Included</td></tr>`).join('')
    : '';
  const depositRow = pricing.depositAmount > 0 ? `<tr style="border-top:1px solid #e0e0e0"><td style="padding:8px 0;color:#555;font-size:13px">Security deposit (held, refundable)</td><td style="padding:8px 0;font-size:13px;text-align:right;color:#F57F17;font-weight:700">${fmt(pricing.depositAmount)}</td></tr>` : '';
  const promoSection = promoCode && r2rConfig ? `
<table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:0">
<tr><td bgcolor="#E8F5E9" style="padding:20px 28px;border-radius:6px">
  <p style="margin:0 0 6px;font-size:14px;font-weight:700;color:#2E7D32">&#127881; Your Ride-to-Rental Discount Code</p>
  <p style="margin:0 0 12px;font-size:13px;color:#388E3C">You saved on a rental — now save ${r2rConfig.discountPercent}% on your taxi ride to pick it up!</p>
  <div style="background:#fff;border:2px dashed #4CAF50;border-radius:6px;padding:12px 18px;text-align:center;margin-bottom:12px">
    <span style="font-size:22px;font-weight:900;font-family:monospace;color:#1B5E20;letter-spacing:3px">${esc(promoCode)}</span>
  </div>
  <p style="margin:0;font-size:11.5px;color:#666">Valid for 7 days &mdash; single use &mdash; <a href="${baseUrl}/ride?promo=${esc(promoCode)}" style="color:#2E7D32;font-weight:700;text-decoration:none">Book your taxi ride &rarr;</a></p>
</td></tr></table>` : '';
  const cancelSection = `<p style="font-size:12px;color:#888;margin-top:4px">Need to cancel? <a href="${baseUrl}/rent/cancel?token=${cancelToken}" style="color:#00796B">Click here</a> (free cancellation more than 48 hrs before pickup)</p>`;
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:28px 12px">
<tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 1px 6px rgba(0,0,0,.08)">
  <tr><td bgcolor="#004D40" style="padding:32px 32px 24px;text-align:center">
    <h1 style="margin:0 0 6px;font-size:24px;font-weight:800;color:#fff">&#10003; Booking Confirmed!</h1>
    <p style="margin:0;font-size:14px;color:#A7FFEB">Reference: <strong>${esc(jobId)}</strong></p>
  </td></tr>
  <tr><td style="padding:24px 32px 0">
    <p style="margin:0 0 4px;font-size:15px;font-weight:600;color:#212121">Hi ${esc(customer.name || 'there')},</p>
    <p style="margin:0 0 20px;font-size:13.5px;color:#555">Your rental booking with <strong>${esc(companyName)}</strong> is confirmed. Here's your summary:</p>
    <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #e0e0e0;border-radius:6px;margin-bottom:20px">
      <tr><td colspan="2" bgcolor="#E0F2F1" style="padding:10px 16px;font-size:13px;font-weight:700;color:#004D40">&#128663; Vehicle &amp; Dates</td></tr>
      <tr><td style="padding:8px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5;width:140px">Vehicle</td><td style="padding:8px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${esc(vehicle.make || '')} ${esc(vehicle.model || '')}${vehicle.rego ? ' (' + esc(vehicle.rego) + ')' : ''}</td></tr>
      <tr><td style="padding:8px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Pickup</td><td style="padding:8px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${esc(pickupFmt)}</td></tr>
      <tr><td style="padding:8px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Return</td><td style="padding:8px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${esc(returnFmt)}</td></tr>
      <tr><td style="padding:8px 16px;color:#666;font-size:13px">Rental days</td><td style="padding:8px 16px;font-size:13px;font-weight:600">${reservation.billingDays || '—'}</td></tr>
    </table>
    <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #e0e0e0;border-radius:6px;margin-bottom:20px">
      <tr><td colspan="2" bgcolor="#E0F2F1" style="padding:10px 16px;font-size:13px;font-weight:700;color:#004D40">&#128179; Pricing Summary</td></tr>
      <tr><td style="padding:8px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Rental (${reservation.billingDays} days)</td><td style="padding:8px 16px;font-size:13px;text-align:right;border-bottom:1px solid #f5f5f5">${fmt(pricing.rentalBase)}</td></tr>
      <tr><td style="padding:8px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Insurance — ${esc(insLabelStr)}</td><td style="padding:8px 16px;font-size:13px;text-align:right;border-bottom:1px solid #f5f5f5">${fmt(pricing.insTotal)}</td></tr>
      ${addonsHtml}
      <tr style="background:#f9fafb"><td style="padding:10px 16px;font-size:14px;font-weight:700;color:#004D40;border-top:2px solid #e0e0e0">Total charged today</td><td style="padding:10px 16px;font-size:15px;font-weight:800;text-align:right;color:#004D40;border-top:2px solid #e0e0e0">${fmt(pricing.subtotal)}</td></tr>
      ${depositRow}
    </table>
    ${promoSection ? '<div style="margin-bottom:20px">' + promoSection + '</div>' : ''}
    <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #FFF9C4;border-radius:6px;background:#FFFDE7;margin-bottom:20px">
      <tr><td style="padding:14px 18px;font-size:13px;color:#5D4037">
        <strong style="display:block;margin-bottom:6px">&#128203; What to bring on pickup day:</strong>
        <ul style="margin:0;padding-left:18px;color:#5D4037;font-size:13px;line-height:1.7">
          <li>Valid driver's licence</li>
          <li>Your booking reference: <strong>${esc(jobId)}</strong></li>
          <li>The payment card used for this booking</li>
        </ul>
      </td></tr>
    </table>
    <p style="font-size:13px;color:#555;margin-bottom:4px">Questions? Contact <strong>${esc(companyName)}</strong> directly or reply to this email.</p>
    <p style="font-size:12px;color:#888;margin-bottom:4px">&#128203; <a href="${baseUrl}/rent/booking?email=${encodeURIComponent(customer.email || '')}&job=${encodeURIComponent(jobId)}" style="color:#00796B">View your booking online</a> anytime — no login required.</p>
    ${cancelSection}
  </td></tr>
  <tr><td bgcolor="#004D40" style="padding:18px 32px;text-align:center">
    <p style="margin:0;font-size:12px;color:#80CBC4">BookaWaka Rental &mdash; booking platform</p>
  </td></tr>
</table>
</td></tr>
</table>
</body></html>`;
}

function buildRentalOwnerEmail(d: any): string {
  const { customer, reservation, vehicle, companyName, pricing, jobId, baseUrl } = d;
  const fmt = (n: any) => '$' + parseFloat(n || 0).toFixed(2);
  const pickupFmt = reservation.pickupDate ? new Date(reservation.pickupDate).toLocaleDateString('en-NZ', { weekday: 'short', day: 'numeric', month: 'long', year: 'numeric' }) : '—';
  const returnFmt = reservation.returnDate ? new Date(reservation.returnDate).toLocaleDateString('en-NZ', { weekday: 'short', day: 'numeric', month: 'long', year: 'numeric' }) : '—';
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:28px 12px">
<tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 1px 6px rgba(0,0,0,.08)">
  <tr><td bgcolor="#1B5E20" style="padding:28px 32px;text-align:center">
    <h1 style="margin:0 0 6px;font-size:22px;font-weight:800;color:#fff">&#128276; New Rental Booking</h1>
    <p style="margin:0;font-size:14px;color:#A5D6A7">Reference: <strong>${esc(jobId)}</strong></p>
  </td></tr>
  <tr><td style="padding:24px 32px">
    <p style="margin:0 0 18px;font-size:13.5px;color:#333">A new booking has been confirmed for <strong>${esc(companyName)}</strong> via BookaWaka Rental.</p>
    <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #e0e0e0;border-radius:6px;margin-bottom:18px">
      <tr><td colspan="2" bgcolor="#E8F5E9" style="padding:10px 16px;font-size:13px;font-weight:700;color:#1B5E20">&#128100; Customer Details</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5;width:130px">Name</td><td style="padding:7px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${esc(customer.name || '—')}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Email</td><td style="padding:7px 16px;font-size:13px;border-bottom:1px solid #f5f5f5">${esc(customer.email || '—')}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Phone</td><td style="padding:7px 16px;font-size:13px;border-bottom:1px solid #f5f5f5">${esc(customer.phone || '—')}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px">Licence</td><td style="padding:7px 16px;font-size:13px">${esc(customer.licence || '—')}</td></tr>
    </table>
    <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #e0e0e0;border-radius:6px;margin-bottom:18px">
      <tr><td colspan="2" bgcolor="#E8F5E9" style="padding:10px 16px;font-size:13px;font-weight:700;color:#1B5E20">&#128663; Booking Details</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5;width:130px">Vehicle</td><td style="padding:7px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${esc(vehicle.make || '')} ${esc(vehicle.model || '')}${vehicle.rego ? ' (' + esc(vehicle.rego) + ')' : ''}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Pickup</td><td style="padding:7px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${esc(pickupFmt)}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Return</td><td style="padding:7px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${esc(returnFmt)}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Days</td><td style="padding:7px 16px;font-size:13px;font-weight:600;border-bottom:1px solid #f5f5f5">${reservation.billingDays || '—'}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Insurance</td><td style="padding:7px 16px;font-size:13px;text-transform:capitalize;border-bottom:1px solid #f5f5f5">${esc(reservation.insuranceTier || 'basic')}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Gross Total</td><td style="padding:7px 16px;font-size:13px;font-weight:700;border-bottom:1px solid #f5f5f5">${fmt(pricing.subtotal)}</td></tr>
      <tr><td style="padding:7px 16px;color:#666;font-size:13px;border-bottom:1px solid #f5f5f5">Platform commission (${pricing.commissionRate || 12}%)</td><td style="padding:7px 16px;font-size:13px;color:#C62828;border-bottom:1px solid #f5f5f5">− ${fmt(pricing.commission)}</td></tr>
      <tr style="background:#f9fafb"><td style="padding:9px 16px;font-size:14px;font-weight:700;color:#1B5E20">Your net payout</td><td style="padding:9px 16px;font-size:15px;font-weight:800;color:#1B5E20">${fmt(pricing.ownerNet)}</td></tr>
    </table>
    <p style="font-size:13px;color:#555;margin-bottom:6px">Log in to your owner portal to manage this reservation:</p>
    <a href="${baseUrl}/rental-portal" style="display:inline-block;background:#2E7D32;color:#fff;font-weight:700;font-size:14px;padding:11px 22px;border-radius:5px;text-decoration:none">Open Owner Portal &rarr;</a>
  </td></tr>
  <tr><td bgcolor="#1B5E20" style="padding:16px 32px;text-align:center">
    <p style="margin:0;font-size:12px;color:#81C784">BookaWaka Rental &mdash; powered by BookaWaka</p>
  </td></tr>
</table>
</td></tr>
</table>
</body></html>`;
}

// ── GET /rent ─────────────────────────────────────────────────────────────────
router.get('/rent', async (req: Request, res: Response) => {
  const today    = new Date().toISOString().slice(0, 10);
  const tomorrow = new Date(Date.now() + 86400000).toISOString().slice(0, 10);
  const pickup  = (req.query.pickup  as string) || today;
  const retDate = (req.query.return  as string) || tomorrow;
  const cat     = (req.query.cat     as string) || '';
  const cats = ['Economy', 'Compact', 'Standard', 'SUV', '4WD', 'Luxury', 'People Mover', 'Ute/Truck'];
  const catOpts = cats.map(c => `<option value="${esc(c)}" ${c === cat ? 'selected' : ''}>${esc(c)}</option>`).join('');
  const searchHero = `
<div class="rent-hero">
  <h1>&#128663; Rent a Car</h1>
  <p>Browse vehicles from trusted local rental companies &mdash; pick up, drive, return.</p>
  <div class="rent-search-box">
    <form method="GET" action="/rent/browse">
      <div class="rent-search-grid">
        <div class="rent-ff"><label>Pickup Date</label><input type="date" name="pickup" value="${esc(pickup)}" min="${today}" required/></div>
        <div class="rent-ff"><label>Return Date</label><input type="date" name="return" value="${esc(retDate)}" min="${today}" required/></div>
        <div class="rent-ff"><label>Category</label><select name="cat"><option value="">All Categories</option>${catOpts}</select></div>
        <div><button type="submit" class="rent-btn" style="width:100%;justify-content:center">&#128269; Search</button></div>
      </div>
    </form>
  </div>
</div>
<div style="height:32px"></div>
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin-bottom:40px">
  <div style="background:#fff;border-radius:10px;padding:22px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,.07);border-top:4px solid #00695C"><div style="font-size:32px;margin-bottom:8px">&#128197;</div><div style="font-weight:700;margin-bottom:4px">Book Online</div><div style="font-size:12px;color:#888">Instant confirmation, no queues</div></div>
  <div style="background:#fff;border-radius:10px;padding:22px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,.07);border-top:4px solid #1565C0"><div style="font-size:32px;margin-bottom:8px">&#128663;</div><div style="font-weight:700;margin-bottom:4px">All Categories</div><div style="font-size:12px;color:#888">Economy to luxury, 4WD to utes</div></div>
  <div style="background:#fff;border-radius:10px;padding:22px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,.07);border-top:4px solid #2E7D32"><div style="font-size:32px;margin-bottom:8px">&#128274;</div><div style="font-weight:700;margin-bottom:4px">Secure Deposit</div><div style="font-size:12px;color:#888">Deposit held &amp; released on return</div></div>
  <div style="background:#fff;border-radius:10px;padding:22px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,.07);border-top:4px solid #E65100"><div style="font-size:32px;margin-bottom:8px">&#128664;</div><div style="font-weight:700;margin-bottom:4px">Ride-to-Rental</div><div style="font-size:12px;color:#888">Taxi to the depot after booking</div></div>
</div>`;
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Rent a Car &mdash; BookaWaka</title>
<style>${RENT_CSS}</style></head>
<body>${rentNav()}${searchHero}<div class="rent-main"></div>
<footer class="rent-footer">&copy; ${new Date().getFullYear()} BookaWaka. All rights reserved.</footer>
</body></html>`);
});

// ── GET /rent/browse ──────────────────────────────────────────────────────────
router.get('/rent/browse', async (req: Request, res: Response) => {
  const pickup  = (req.query.pickup as string) || '';
  const retDate = (req.query.return as string) || '';
  const cat     = (req.query.cat    as string) || '';
  const today   = new Date().toISOString().slice(0, 10);
  if (!pickup || !retDate || pickup >= retDate || pickup < today) {
    return res.redirect('/rent?err=dates');
  }
  const days = rentDays(pickup, retDate);
  try {
    const [config, portalAccess] = await Promise.all([
      fbReadP('bwConfig/rental'),
      fbReadP('rentalPortalAccess')
    ]);
    if (!config || config.enabled === false) {
      return res.send(rentPage('Search Results', '<div class="rent-notice info">&#128663; Rental booking is not available right now. Please check back soon.</div>'));
    }
    const companies = Object.entries(portalAccess || {}).filter(([, a]: any) => a && a.active !== false);
    if (!companies.length) {
      return res.send(rentPage('Search Results', '<div class="rent-notice info">No rental companies are currently available.</div>'));
    }
    const companyData = await Promise.all(companies.map(async ([cid, acc]: any) => {
      const [fleet, avail] = await Promise.all([
        fbReadP('rentalFleet/' + cid),
        fbReadP('rentalAvailability/' + cid)
      ]);
      return { cid, name: acc.name || cid, fleet: fleet || {}, avail: avail || {} };
    }));
    const defCommission = parseFloat((config && config.defaultCommission) || 12);
    const allVehicles: any[] = [];
    companyData.forEach(({ cid, name, fleet, avail }) => {
      Object.entries(fleet).forEach(([vid, v]: any) => {
        if (v.status !== 'available') return;
        if (cat && v.category !== cat) return;
        if (!rentIsAvailable(avail, vid, pickup, retDate)) return;
        allVehicles.push({ vid, cid, companyName: name, v });
      });
    });
    allVehicles.sort((a, b) => parseFloat(a.v.pricePerDay || 0) - parseFloat(b.v.pricePerDay || 0));
    const catIcons: Record<string, string> = { Economy: '&#128697;', Compact: '&#128699;', Standard: '&#128664;', SUV: '&#128649;', '4WD': '&#128666;', Luxury: '&#128140;', 'People Mover': '&#128659;', 'Ute/Truck': '&#128658;' };
    const cards = allVehicles.map(({ vid, cid, companyName, v }) => {
      const total = days * parseFloat(v.pricePerDay || 0);
      const icon = catIcons[v.category] || '&#128663;';
      const qp = `cid=${encodeURIComponent(cid)}&vid=${encodeURIComponent(vid)}&pickup=${encodeURIComponent(pickup)}&return=${encodeURIComponent(retDate)}`;
      const cardImg = v.imageUrl
        ? `<img src="${esc(v.imageUrl)}" alt="${esc(v.make || '')} ${esc(v.model || '')}" style="width:100%;height:100%;object-fit:cover;display:block" loading="lazy"/>`
        : icon;
      return `<div class="rent-card">
  <div class="rent-card-img" style="${v.imageUrl ? 'padding:0;overflow:hidden;' : ''}">${cardImg}</div>
  <div class="rent-card-body">
    <div class="rent-card-title">${esc(v.year || '')} ${esc(v.make || '—')} ${esc(v.model || '')}</div>
    <div class="rent-card-sub">${esc(companyName)} &middot; ${esc(v.rego || '—')}</div>
    <div class="rent-features">
      <span class="rent-feat">&#128101; ${v.seats || 5} seats</span>
      <span class="rent-feat">${v.transmission === 'manual' ? 'Manual' : 'Auto'}</span>
      <span class="rent-feat">${esc(v.category || '—')}</span>
      ${v.mileagePolicy && v.mileagePolicy.type === 'unlimited' ? '<span class="rent-feat">&#10003; Unlimited km</span>' : ''}
    </div>
    <div style="display:flex;align-items:baseline;gap:6px;margin:10px 0">
      <div class="rent-card-price">$${parseFloat(v.pricePerDay || 0).toFixed(0)}<span>/day</span></div>
      <div style="font-size:12px;color:#888">($${total.toFixed(2)} for ${days} day${days !== 1 ? 's' : ''})</div>
    </div>
    <div style="font-size:12px;color:#888;margin-bottom:12px">Deposit: $${parseFloat(v.depositAmount || 0).toFixed(0)} &bull; Min age: ${v.minDriverAge || 21}</div>
    <a href="/rent/book?${qp}" class="rent-btn" style="width:100%;justify-content:center;display:flex">Book Now &rarr;</a>
  </div>
</div>`;
    }).join('');
    const cats = ['Economy', 'Compact', 'Standard', 'SUV', '4WD', 'Luxury', 'People Mover', 'Ute/Truck'];
    const catLinks = cats.map(c =>
      `<a href="/rent/browse?pickup=${encodeURIComponent(pickup)}&return=${encodeURIComponent(retDate)}&cat=${encodeURIComponent(c)}" style="font-size:12px;padding:5px 12px;border-radius:20px;border:1.5px solid ${c === cat ? '#00695C' : '#e0e0e0'};background:${c === cat ? '#E0F2F1' : '#fff'};color:${c === cat ? '#00695C' : '#555'};white-space:nowrap">${esc(c)}</a>`
    ).join('');
    const body = `
<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;margin-bottom:20px">
  <div>
    <h2 style="font-size:20px;font-weight:800;color:#263238;margin-bottom:4px">${allVehicles.length} vehicle${allVehicles.length !== 1 ? 's' : ''} available</h2>
    <div style="font-size:13px;color:#888">${esc(pickup)} &rarr; ${esc(retDate)} &middot; ${days} day${days !== 1 ? 's' : ''} &middot; ${cat || 'All categories'}</div>
  </div>
  <a href="/rent?pickup=${encodeURIComponent(pickup)}&return=${encodeURIComponent(retDate)}&cat=${encodeURIComponent(cat)}" class="rent-btn-outline rent-btn" style="font-size:13px">&#9664; Modify Search</a>
</div>
<div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px;align-items:center">
  <span style="font-size:12px;font-weight:600;color:#888">Category:</span>
  <a href="/rent/browse?pickup=${encodeURIComponent(pickup)}&return=${encodeURIComponent(retDate)}" style="font-size:12px;padding:5px 12px;border-radius:20px;border:1.5px solid ${!cat ? '#00695C' : '#e0e0e0'};background:${!cat ? '#E0F2F1' : '#fff'};color:${!cat ? '#00695C' : '#555'}">All</a>
  ${catLinks}
</div>
${allVehicles.length ? `<div class="rent-grid">${cards}</div>` : '<div class="rent-notice info">No vehicles available for those dates. Try different dates or remove the category filter.</div>'}`;
    res.send(rentPage(`${allVehicles.length} Available`, body));
  } catch (e: any) {
    console.error('[rent/browse]', e.message);
    res.send(rentPage('Search Results', `<div class="rent-notice err">Error loading results: ${esc(e.message)}</div>`));
  }
});

// ── GET /rent/book ────────────────────────────────────────────────────────────
router.get('/rent/book', async (req: Request, res: Response) => {
  const { cid, vid } = req.query as any;
  const pickup  = req.query.pickup  as string;
  const retDate = req.query.return  as string;
  const err     = (req.query.err    as string) || '';
  if (!cid || !vid || !pickup || !retDate) return res.redirect('/rent');
  const days = rentDays(pickup, retDate);
  try {
    const [vehicle, avail, addons, insurance, config, rentalCfg, portalAcc] = await Promise.all([
      fbReadP('rentalFleet/' + cid + '/' + vid),
      fbReadP('rentalAvailability/' + cid + '/' + vid),
      fbReadP('rentalAddons/' + cid),
      fbReadP('rentalInsurance/' + cid),
      fbReadP('bwConfig/rental'),
      fbReadP('rentalConfig/' + cid),
      fbReadP('rentalPortalAccess/' + cid)
    ]);
    if (!vehicle) return res.redirect('/rent/browse?pickup=' + encodeURIComponent(pickup) + '&return=' + encodeURIComponent(retDate) + '&err=notvehicle');
    if (!rentIsAvailable({ [vid]: avail || {} }, vid, pickup, retDate)) {
      return res.redirect('/rent/browse?pickup=' + encodeURIComponent(pickup) + '&return=' + encodeURIComponent(retDate) + '&err=unavailable');
    }
    const companyName = (portalAcc && portalAcc.name) || cid;
    const commissionRate = (rentalCfg && rentalCfg.commission !== undefined) ? parseFloat(rentalCfg.commission) : parseFloat((config && config.defaultCommission) || 12);
    const stripeKey = process.env.STRIPE_PUBLISHABLE_KEY || '';
    const qBack = `cid=${encodeURIComponent(cid)}&vid=${encodeURIComponent(vid)}&pickup=${encodeURIComponent(pickup)}&return=${encodeURIComponent(retDate)}`;
    const insTiers = [
      { key: 'basic',    label: 'Basic',             excess: 3000, desc: 'Included — $3,000 excess for any damage' },
      { key: 'standard', label: 'Standard',           excess: 800,  desc: 'Reduces excess to $800' },
      { key: 'full',     label: 'Full / Zero Excess', excess: 0,    desc: 'Zero excess — fully covered' }
    ];
    const insCols = insTiers.map(it => {
      const t2 = insurance && insurance[it.key];
      const ppd = t2 ? parseFloat(t2.pricePerDay || 0) : (it.key === 'basic' ? 0 : it.key === 'standard' ? 12 : 25);
      const total = ppd * days;
      return `<div class="rent-ins-card" data-tier="${it.key}" data-ppd="${ppd}" onclick="selectIns(this)">
<div class="rent-ins-name">${it.label}</div>
<div class="rent-ins-price">${ppd === 0 ? 'Included' : '$' + ppd.toFixed(2) + '/day'}</div>
<div class="rent-ins-excess">$${it.excess.toLocaleString()} excess</div>
${total > 0 ? `<div style="font-size:11px;color:#888;margin-top:4px">$${total.toFixed(2)} total</div>` : ''}
<div style="font-size:11px;color:#888;margin-top:4px">${it.desc}</div>
</div>`;
    }).join('');
    const addonDefs = [
      { key: 'additionalDriver', label: 'Additional Driver',  icon: '&#128101;', per: 'per day' },
      { key: 'youngDriver',      label: 'Young Driver (<25)', icon: '&#127938;', per: 'per day' },
      { key: 'gps',              label: 'GPS / Satnav',       icon: '&#128205;', per: 'per day' },
      { key: 'childSeat',        label: 'Child Seat',         icon: '&#128692;', per: 'per day' },
      { key: 'boosterSeat',      label: 'Booster Seat',       icon: '&#128692;', per: 'per day' },
      { key: 'roofRack',         label: 'Roof Rack',          icon: '&#127959;', per: 'flat' },
      { key: 'snowChains',       label: 'Snow Chains',        icon: '&#10052;',  per: 'flat' }
    ];
    const addonRows = addonDefs.map(ad => {
      const ao = addons && addons[ad.key];
      if (!ao || ao.enabled === false) return '';
      const price = ad.per === 'flat' ? parseFloat(ao.priceFlat || 0) : parseFloat(ao.pricePerDay || 0);
      if (price <= 0) return '';
      const total = ad.per === 'flat' ? price : price * days;
      return `<div class="rent-addon-row" data-key="${ad.key}" data-price="${price}" data-per="${ad.per}" onclick="toggleAddon(this)">
<input type="checkbox" style="pointer-events:none" class="addon-check"/>
<div style="font-size:20px">${ad.icon}</div>
<div style="flex:1"><div style="font-weight:600;font-size:13px">${ad.label}</div>
<div style="font-size:11.5px;color:#888">$${price.toFixed(2)} ${ad.per === 'flat' ? '/ booking' : '/ day'} &bull; $${total.toFixed(2)} total</div></div>
</div>`;
    }).filter(Boolean).join('');
    const rentalBase = days * parseFloat(vehicle.pricePerDay || 0);
    const errHtml = err ? `<div class="rent-notice err">Payment failed: ${esc(decodeURIComponent(err))}. Please try again.</div>` : '';
    const body = `
${errHtml}
<div style="margin-bottom:20px">
  <a href="/rent/browse?${qBack}" style="font-size:13px;color:#00695C;display:inline-flex;align-items:center;gap:4px">&#8592; Back to results</a>
</div>
<div class="rent-2col">
  <div>
    <div style="background:#fff;border-radius:10px;padding:18px;box-shadow:0 2px 8px rgba(0,0,0,.07);margin-bottom:20px;display:flex;gap:16px;align-items:center;border:1px solid #f0f0f0">
      ${vehicle.imageUrl
        ? `<div style="width:90px;height:64px;border-radius:8px;overflow:hidden;flex-shrink:0;border:1px solid #f0f0f0"><img src="${esc(vehicle.imageUrl)}" alt="${esc(vehicle.make || '')} ${esc(vehicle.model || '')}" style="width:100%;height:100%;object-fit:cover" loading="lazy"/></div>`
        : `<div style="font-size:48px;width:64px;text-align:center;flex-shrink:0">&#128663;</div>`}
      <div>
        <div style="font-size:18px;font-weight:800;color:#263238">${esc(vehicle.year || '')} ${esc(vehicle.make || '')} ${esc(vehicle.model || '')}</div>
        <div style="font-size:13px;color:#888;margin-top:2px">${esc(companyName)} &middot; ${esc(vehicle.rego || '')} &middot; ${esc(vehicle.category || '')}</div>
        <div style="display:flex;gap:8px;margin-top:6px;flex-wrap:wrap">
          <span class="rent-feat" style="background:#F5F5F5;padding:3px 10px;border-radius:20px;font-size:11.5px;color:#555">&#128101; ${vehicle.seats || 5} seats</span>
          <span class="rent-feat" style="background:#F5F5F5;padding:3px 10px;border-radius:20px;font-size:11.5px;color:#555">${vehicle.transmission === 'manual' ? 'Manual' : 'Auto'}</span>
          ${vehicle.mileagePolicy && vehicle.mileagePolicy.type === 'unlimited' ? '<span class="rent-feat" style="background:#F5F5F5;padding:3px 10px;border-radius:20px;font-size:11.5px;color:#555">Unlimited km</span>' : ''}
        </div>
      </div>
    </div>
    <div style="background:#fff;border-radius:10px;padding:20px;box-shadow:0 2px 8px rgba(0,0,0,.07);margin-bottom:20px;border:1px solid #f0f0f0">
      <h3 style="font-size:15px;font-weight:700;margin-bottom:14px;color:#263238">&#127794; Protection Level</h3>
      <div class="rent-ins-cards">${insCols}</div>
      <input type="hidden" id="selected-ins" value="basic"/>
    </div>
    ${addonRows ? `<div style="background:#fff;border-radius:10px;padding:20px;box-shadow:0 2px 8px rgba(0,0,0,.07);margin-bottom:20px;border:1px solid #f0f0f0">
    <h3 style="font-size:15px;font-weight:700;margin-bottom:14px;color:#263238">&#10133; Add-ons &amp; Extras</h3>
    ${addonRows}
    </div>` : ''}
    <div style="background:#fff;border-radius:10px;padding:20px;box-shadow:0 2px 8px rgba(0,0,0,.07);margin-bottom:20px;border:1px solid #f0f0f0">
      <h3 style="font-size:15px;font-weight:700;margin-bottom:14px;color:#263238">&#128100; Driver Details</h3>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px">
        <div class="rent-ff"><label>Full Name</label><input type="text" id="c-name" placeholder="As on driver's licence" required/></div>
        <div class="rent-ff"><label>Email Address</label><input type="email" id="c-email" placeholder="you@example.com" required/></div>
        <div class="rent-ff"><label>Phone Number</label><input type="tel" id="c-phone" placeholder="+64 21 000 0000" required/></div>
        <div class="rent-ff"><label>Date of Birth</label><input type="date" id="c-dob" required/></div>
        <div class="rent-ff" style="grid-column:span 2"><label>Driver Licence Number</label><input type="text" id="c-licence" placeholder="e.g. AB123456" required/></div>
      </div>
    </div>
    <div style="background:#fff;border-radius:10px;padding:20px;box-shadow:0 2px 8px rgba(0,0,0,.07);border:1px solid #f0f0f0">
      <h3 style="font-size:15px;font-weight:700;margin-bottom:4px;color:#263238">&#128179; Payment</h3>
      <p style="font-size:12.5px;color:#888;margin-bottom:16px">Your card will be charged the rental total and a separate authorization hold placed for the security deposit.</p>
      ${stripeKey ? `<div class="rent-ff"><label>Card Details</label>
      <div id="stripe-card-element"></div>
      <div id="card-errors"></div></div>
      <div id="pay-status" style="font-size:13px;color:#888;margin-top:10px;display:none"></div>
      <button id="pay-btn" onclick="submitPayment()" class="rent-btn rent-btn-lg" style="width:100%;justify-content:center;margin-top:16px">
        &#128274; Pay &amp; Confirm Booking
      </button>` : `<div class="rent-notice info">Payment system not configured. Please contact the rental company directly.</div>`}
    </div>
  </div>
  <div class="rent-sticky">
    <div class="rent-summary-card">
      <h3 style="font-size:15px;font-weight:700;margin-bottom:14px;color:#263238">&#128203; Booking Summary</h3>
      <div style="font-size:13px;color:#888;margin-bottom:12px">
        <div style="margin-bottom:4px">&#128197; ${esc(pickup)} &rarr; ${esc(retDate)}</div>
        <div>${days} day${days !== 1 ? 's' : ''}</div>
      </div>
      <div class="rent-divider"></div>
      <div id="summary-lines" style="font-size:13px">
        <div style="display:flex;justify-content:space-between;margin-bottom:6px">
          <span>Rental (${days}d × $${parseFloat(vehicle.pricePerDay || 0).toFixed(2)})</span>
          <span id="sum-rental">$${rentalBase.toFixed(2)}</span>
        </div>
        <div id="sum-ins-row" style="display:flex;justify-content:space-between;margin-bottom:6px">
          <span id="sum-ins-label">Insurance (Basic)</span>
          <span id="sum-ins">Included</span>
        </div>
        <div id="sum-addons-row" style="display:none;justify-content:space-between;margin-bottom:6px">
          <span>Add-ons</span>
          <span id="sum-addons">$0.00</span>
        </div>
        <div class="rent-divider"></div>
        <div style="display:flex;justify-content:space-between;margin-bottom:10px;font-size:15px;font-weight:700">
          <span>Total to pay now</span>
          <span id="sum-total" style="color:#00695C">$${rentalBase.toFixed(2)}</span>
        </div>
        <div style="background:#E0F2F1;border-radius:6px;padding:10px 12px;font-size:12px;color:#004D40;margin-bottom:6px">
          &#128274; Security deposit: <strong>$${parseFloat(vehicle.depositAmount || 0).toFixed(2)}</strong><br>
          Authorization hold — released on return (minus any deductions)
        </div>
      </div>
    </div>
    <div style="margin-top:14px;font-size:12px;color:#888;line-height:1.6">
      &#128274; Secure payment via Stripe<br>
      &#10003; Free cancellation 48hrs before pickup<br>
      &#128663; Managed by ${esc(companyName)}
    </div>
  </div>
</div>
<script src="https://js.stripe.com/v3/"></script>
<script>
const STRIPE_KEY = ${JSON.stringify(stripeKey)};
const CID = ${JSON.stringify(cid)};
const VID = ${JSON.stringify(vid)};
const PICKUP = ${JSON.stringify(pickup)};
const RETURN_DATE = ${JSON.stringify(retDate)};
const DAYS = ${days};
const RENTAL_BASE = ${parseFloat(vehicle.pricePerDay || 0)};
const DEPOSIT = ${parseFloat(vehicle.depositAmount || 0)};
let stripe, cardElement, selectedIns='basic', addonTotals={};
if (STRIPE_KEY) {
  stripe = Stripe(STRIPE_KEY);
  const elements = stripe.elements();
  cardElement = elements.create('card', { style:{ base:{fontSize:'15px',color:'#263238',fontFamily:'system-ui,sans-serif','::placeholder':{color:'#aaa'}} } });
  cardElement.mount('#stripe-card-element');
  cardElement.on('change', e => { document.getElementById('card-errors').textContent = e.error?e.error.message:''; });
}
function selectIns(el) {
  document.querySelectorAll('.rent-ins-card').forEach(c => { c.className='rent-ins-card'; });
  const tier = el.dataset.tier;
  el.className = 'rent-ins-card ' + (tier==='basic'?'':'sel-'+(tier==='standard'?'standard':'full'));
  selectedIns = tier;
  document.getElementById('selected-ins').value = tier;
  updateSummary();
}
document.querySelector('[data-tier="basic"]').click();
function toggleAddon(el) {
  const cb = el.querySelector('.addon-check');
  cb.checked = !cb.checked;
  el.classList.toggle('selected', cb.checked);
  const key = el.dataset.key, price = parseFloat(el.dataset.price), per = el.dataset.per;
  if (cb.checked) addonTotals[key] = per==='flat' ? price : price * DAYS;
  else delete addonTotals[key];
  updateSummary();
}
function updateSummary() {
  const insEl = document.querySelector('[data-tier="'+selectedIns+'"]');
  const insPpd = insEl ? parseFloat(insEl.dataset.ppd) : 0;
  const insTotal = insPpd * DAYS;
  const addonSum = Object.values(addonTotals).reduce((s,v)=>s+v,0);
  const total = RENTAL_BASE * DAYS + insTotal + addonSum;
  document.getElementById('sum-ins-label').textContent = 'Insurance (' + selectedIns.charAt(0).toUpperCase() + selectedIns.slice(1) + ')';
  document.getElementById('sum-ins').textContent = insTotal > 0 ? '$'+insTotal.toFixed(2) : 'Included';
  if (addonSum > 0) { document.getElementById('sum-addons-row').style.display='flex'; document.getElementById('sum-addons').textContent='$'+addonSum.toFixed(2); }
  else { document.getElementById('sum-addons-row').style.display='none'; }
  document.getElementById('sum-total').textContent = '$'+total.toFixed(2);
}
async function submitPayment() {
  const btn = document.getElementById('pay-btn'), status = document.getElementById('pay-status');
  const name=document.getElementById('c-name').value.trim(), email=document.getElementById('c-email').value.trim();
  const phone=document.getElementById('c-phone').value.trim(), dob=document.getElementById('c-dob').value;
  const licence=document.getElementById('c-licence').value.trim();
  if (!name||!email||!phone||!dob||!licence) { alert('Please fill in all driver details.'); return; }
  if (!stripe || !cardElement) return;
  btn.disabled=true; btn.textContent='Processing…'; status.style.display='block'; status.textContent='Creating booking…';
  const selectedAddons = Object.keys(addonTotals);
  try {
    const r = await fetch('/api/rent/payment-intent', { method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ cid:CID, vid:VID, pickupDate:PICKUP, returnDate:RETURN_DATE, insuranceTier:selectedIns, selectedAddons, customer:{name,email,phone,dob,licence} }) });
    const pi = await r.json();
    if (!pi.rentalClientSecret) throw new Error(pi.error||'Failed to create payment');
    status.textContent = 'Charging rental total…';
    const r1 = await stripe.confirmCardPayment(pi.rentalClientSecret, { payment_method: { card: cardElement, billing_details: { name, email } } });
    if (r1.error) throw new Error(r1.error.message);
    let depositPaymentIntentId = null;
    if (pi.depositClientSecret) {
      status.textContent = 'Authorizing security deposit…';
      const r2 = await stripe.confirmCardPayment(pi.depositClientSecret, { payment_method: r1.paymentIntent.payment_method });
      if (r2.error) throw new Error(r2.error.message);
      depositPaymentIntentId = r2.paymentIntent.id;
    }
    status.textContent = 'Confirming booking…';
    const r3 = await fetch('/api/rent/confirm-booking', { method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ bookingToken: pi.bookingToken, rentalPaymentIntentId: r1.paymentIntent.id, depositPaymentIntentId }) });
    const conf = await r3.json();
    if (!conf.ok) throw new Error(conf.error||'Booking failed');
    window.location.href = '/rent/confirm?j=' + encodeURIComponent(conf.jobId) + '&cid=' + encodeURIComponent(CID) + '&rid=' + encodeURIComponent(conf.reservationId);
  } catch(e) {
    btn.disabled=false; btn.textContent='&#128274; Pay & Confirm Booking';
    status.style.display='none';
    document.getElementById('card-errors').textContent = e.message;
  }
}
</script>`;
    res.send(rentPage('Book: ' + (vehicle.make || '') + ' ' + (vehicle.model || ''), body));
  } catch (e: any) {
    console.error('[rent/book]', e.message);
    res.send(rentPage('Book', `<div class="rent-notice err">Error loading booking: ${esc(e.message)}</div>`));
  }
});

// ── POST /api/rent/payment-intent ─────────────────────────────────────────────
router.post('/api/rent/payment-intent', async (req: Request, res: Response) => {
  try {
    const { cid, vid, pickupDate, returnDate, insuranceTier, selectedAddons, customer } = req.body;
    if (!cid || !vid || !pickupDate || !returnDate || !customer) return res.status(400).json({ error: 'Missing fields' });
    const days = rentDays(pickupDate, returnDate);
    const [vehicle, addons, insurance, config, rentalCfg] = await Promise.all([
      fbReadP('rentalFleet/' + cid + '/' + vid),
      fbReadP('rentalAddons/' + cid),
      fbReadP('rentalInsurance/' + cid),
      fbReadP('bwConfig/rental'),
      fbReadP('rentalConfig/' + cid)
    ]);
    if (!vehicle) return res.json({ error: 'Vehicle not found' });
    const commissionRate = (rentalCfg && rentalCfg.commission !== undefined) ? parseFloat(rentalCfg.commission) : parseFloat((config && config.defaultCommission) || 12);
    const pricing = rentCalcPricing(vehicle, addons, selectedAddons || [], insuranceTier || 'basic', insurance, days, commissionRate);
    if (pricing.subtotal <= 0) return res.json({ error: 'Invalid pricing calculation' });
    const stripe = getStripe();
    const meta = { cid, vid, pickupDate, returnDate, insuranceTier: insuranceTier || 'basic', customerEmail: customer.email || '', customerName: customer.name || '' };
    const rentalPI = await stripe.paymentIntents.create({
      amount: Math.round(pricing.subtotal * 100),
      currency: 'nzd',
      capture_method: 'automatic',
      description: `Rental: ${vehicle.make || ''} ${vehicle.model || ''} — ${days} days`,
      receipt_email: customer.email || undefined,
      metadata: meta
    });
    let depositPI: any = null;
    if (pricing.depositAmount > 0) {
      depositPI = await stripe.paymentIntents.create({
        amount: Math.round(pricing.depositAmount * 100),
        currency: 'nzd',
        capture_method: 'manual',
        description: `Security deposit: ${vehicle.make || ''} ${vehicle.model || ''} rental`,
        metadata: { ...meta, type: 'deposit' }
      });
    }
    const bookingToken = crypto.randomBytes(24).toString('hex');
    rentalPendingBookings.set(bookingToken, {
      cid, vid, pickupDate, returnDate, days, insuranceTier: insuranceTier || 'basic',
      selectedAddons: selectedAddons || [], customer, pricing, createdAt: Date.now(),
      hasDeposit: pricing.depositAmount > 0
    });
    const cutoff = Date.now() - RENT_PENDING_TTL;
    rentalPendingBookings.forEach((v: any, k: string) => { if (v.createdAt < cutoff) rentalPendingBookings.delete(k); });
    res.json({ rentalClientSecret: rentalPI.client_secret, depositClientSecret: depositPI ? depositPI.client_secret : null, bookingToken, pricing });
  } catch (e: any) {
    console.error('[rent/payment-intent]', e.message);
    res.status(500).json({ error: e.message });
  }
});

// ── POST /api/rent/confirm-booking ────────────────────────────────────────────
router.post('/api/rent/confirm-booking', async (req: Request, res: Response) => {
  try {
    const { bookingToken, rentalPaymentIntentId, depositPaymentIntentId } = req.body;
    if (!bookingToken) return res.status(400).json({ error: 'Missing bookingToken' });
    const pending = rentalPendingBookings.get(bookingToken);
    if (!pending) return res.status(400).json({ error: 'Booking not found or expired' });
    rentalPendingBookings.delete(bookingToken);
    const { cid, vid, pickupDate, returnDate, days, insuranceTier, selectedAddons, customer, pricing } = pending;
    const [vehicle, portalAcc, r2rConfig] = await Promise.all([
      fbReadP('rentalFleet/' + cid + '/' + vid),
      fbReadP('rentalPortalAccess/' + cid),
      fbReadP('bwConfig/rental/rideToRental')
    ]);
    const companyName = (portalAcc && portalAcc.name) || cid;
    const jobId = await generateJobId(cid);
    const reservationId = 'RES' + Date.now();
    const now = Date.now();
    const cancelToken = crypto.randomBytes(16).toString('hex');
    let promoCode: string | null = null;
    if (r2rConfig && r2rConfig.enabled && r2rConfig.discountPercent > 0) {
      promoCode = 'R2R-' + jobId.slice(-6).toUpperCase();
    }
    const reservation: any = {
      jobId, reservationId,
      companyId: cid, vehicleId: vid,
      customerName: customer.name, customerEmail: customer.email, customerId: customer.email,
      customerPhone: customer.phone, customerDOB: customer.dob, customerLicence: customer.licence,
      pickupDate, returnDate, billingDays: days,
      insuranceTier, selectedAddons,
      pricing: { ...pricing, rentalPaymentIntentId, depositPaymentIntentId },
      deposit: { amount: pricing.depositAmount, status: depositPaymentIntentId ? 'authorized' : 'none', depositPaymentIntentId: depositPaymentIntentId || null },
      rentalPaymentIntentId,
      cancelToken,
      promoCode,
      status: 'confirmed',
      source: 'rental',
      createdAt: now, updatedAt: now
    };
    const avUpdates: Record<string, any> = {};
    let d = new Date(pickupDate), end = new Date(returnDate);
    while (d < end) {
      avUpdates['rentalAvailability/' + cid + '/' + vid + '/' + d.toISOString().slice(0, 10)] = 'blocked';
      d.setDate(d.getDate() + 1);
    }
    const writes = [
      fbWriteP('PUT', 'rentalReservations/' + cid + '/' + reservationId, reservation),
      fbWriteP('PUT', 'allbookings/' + cid + '/' + jobId, {
        jobId, companyId: cid, source: 'rental', status: 'confirmed',
        passenger: { name: customer.name, email: customer.email, phone: customer.phone },
        fare: { amount: pricing.subtotal, currency: 'NZD' },
        rentalRef: reservationId, createdAt: now
      }),
      fbWriteP('PATCH', '', avUpdates),
      fbWriteP('PUT', 'rentalCancelTokens/' + cancelToken, { cid, reservationId, createdAt: now }),
      fbWriteP('PUT', 'rentalBookingIndex/' + jobId, { cid, reservationId, customerEmail: (customer.email || '').toLowerCase() })
    ];
    if (rentalPaymentIntentId) writes.push(fbWriteP('PUT', 'rentalPaymentIntentIndex/' + rentalPaymentIntentId, { cid, reservationId }));
    if (promoCode) {
      writes.push(fbWriteP('PUT', 'rentalPromos/' + promoCode, {
        code: promoCode, discountPercent: r2rConfig.discountPercent,
        used: false, customerEmail: customer.email, rentalJobId: jobId,
        createdAt: now, expiresAt: now + 7 * 24 * 60 * 60 * 1000
      }));
    }
    await Promise.all(writes);
    console.log('[rent/confirm]', jobId, '| company:', cid, '| vehicle:', vid, '| total: $' + pricing.subtotal.toFixed(2));
    const baseUrl = 'https://' + (process.env.REPLIT_DOMAINS || '').split(',')[0];
    setImmediate(async () => {
      try {
        const resend = await getResendClient();
        if (!resend) return;
        await resend.emails.send({
          from: 'BookaWaka <info@bookawaka.com>',
          to: customer.email,
          subject: `Booking Confirmed: ${jobId} — ${(vehicle || {}).make || ''} ${(vehicle || {}).model || ''}`,
          html: buildRentalCustomerEmail({ customer, reservation, vehicle: vehicle || {}, companyName, promoCode, r2rConfig, pricing, jobId, cancelToken, baseUrl })
        });
        console.log('[rent/email] customer confirmation sent to', customer.email);
        if (portalAcc && portalAcc.email) {
          await resend.emails.send({
            from: 'BookaWaka <info@bookawaka.com>',
            to: portalAcc.email,
            subject: `New Rental Booking: ${jobId}`,
            html: buildRentalOwnerEmail({ customer, reservation, vehicle: vehicle || {}, companyName, pricing, jobId, baseUrl })
          });
          console.log('[rent/email] owner notification sent to', portalAcc.email);
        }
      } catch (emailErr: any) {
        console.error('[rent/email] error:', emailErr.message);
      }
    });
    res.json({ ok: true, jobId, reservationId, companyName, promoCode });
  } catch (e: any) {
    console.error('[rent/confirm-booking]', e.message);
    res.status(500).json({ error: e.message });
  }
});

// ── GET /rent/cancel ──────────────────────────────────────────────────────────
router.get('/rent/cancel', async (req: Request, res: Response) => {
  const token = req.query.token as string;
  if (!token) return res.redirect('/rent');
  try {
    const tokenData = await fbReadP('rentalCancelTokens/' + token);
    if (!tokenData) {
      return res.send(rentPage('Cancel Booking', `<div style="text-align:center;padding:60px 20px"><div style="font-size:48px;margin-bottom:16px">&#10060;</div><h2 style="color:#C62828">Invalid Link</h2><p style="color:#666">This cancellation link is invalid or has already been used.</p><a href="/rent" style="color:#00796B">Back to BookaWaka Rental</a></div>`));
    }
    const { cid, reservationId } = tokenData;
    const [reservation, fleetNode] = await Promise.all([
      fbReadP('rentalReservations/' + cid + '/' + reservationId),
      fbReadP('rentalFleet/' + cid)
    ]);
    if (!reservation) {
      return res.send(rentPage('Cancel Booking', `<div style="text-align:center;padding:60px 20px"><h2 style="color:#C62828">Reservation Not Found</h2><a href="/rent" style="color:#00796B">Back to BookaWaka Rental</a></div>`));
    }
    const fleet = fleetNode || {};
    const v = fleet[reservation.vehicleId] || {};
    const vName = v.make ? `${esc(v.make)} ${esc(v.model || '')}` : esc(reservation.vehicleId || 'Vehicle');
    const pickup = reservation.pickupDate ? new Date(reservation.pickupDate) : null;
    const hoursToPickup = pickup ? (pickup.getTime() - Date.now()) / 3600000 : 999;
    const canCancel = ['confirmed', 'pending'].includes(reservation.status) && hoursToPickup >= 48;
    const alreadyCancelled = reservation.status === 'cancelled';
    const fmt = (n: any) => '$' + parseFloat(n || 0).toFixed(2);
    const pickupFmt = pickup ? pickup.toLocaleDateString('en-NZ', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }) : '—';
    let bodyHtml: string;
    if (alreadyCancelled) {
      bodyHtml = `<div style="text-align:center;padding:40px 0"><div style="font-size:48px;margin-bottom:12px">&#128308;</div><h2 style="color:#C62828;margin-bottom:8px">Booking Already Cancelled</h2><p style="color:#666">Reservation <strong>${esc(reservation.jobId || reservationId)}</strong> has already been cancelled.</p><a href="/rent" style="color:#00796B">Back to BookaWaka Rental</a></div>`;
    } else if (!canCancel) {
      bodyHtml = `<div style="text-align:center;padding:40px 0"><div style="font-size:48px;margin-bottom:12px">&#128683;</div><h2 style="color:#F57F17;margin-bottom:8px">Cancellation Not Available</h2><p style="color:#555">${hoursToPickup < 48 ? 'Cancellations are not permitted within 48 hours of pickup.' : 'This reservation cannot be cancelled in its current state.'}</p><p style="font-size:13px;color:#888">Please contact the rental company directly.</p><a href="/rent" style="color:#00796B">Back to BookaWaka Rental</a></div>`;
    } else {
      bodyHtml = `
<h2 style="font-size:20px;font-weight:700;color:#B71C1C;margin-bottom:18px">&#128465; Cancel Booking</h2>
<div style="background:#fff3e0;border-left:4px solid #FF6F00;padding:14px 18px;border-radius:4px;margin-bottom:20px;font-size:13.5px;color:#5D4037">
  <strong>Free cancellation</strong> — you will receive a full refund to your original payment method within 3-5 business days.
</div>
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;margin-bottom:24px">
  <table style="width:100%;border-collapse:collapse;font-size:13.5px">
    <tr><td style="padding:6px 0;color:#666;width:140px">Booking ref</td><td style="font-weight:700;color:#004D40">${esc(reservation.jobId || reservationId)}</td></tr>
    <tr><td style="padding:6px 0;color:#666">Vehicle</td><td style="font-weight:600">${vName}</td></tr>
    <tr><td style="padding:6px 0;color:#666">Pickup date</td><td style="font-weight:600">${esc(pickupFmt)}</td></tr>
    <tr><td style="padding:6px 0;color:#666">Duration</td><td>${reservation.billingDays || '—'} day${reservation.billingDays !== 1 ? 's' : ''}</td></tr>
    <tr><td style="padding:6px 0;color:#666">Amount paid</td><td style="font-weight:700">${fmt(reservation.pricing && reservation.pricing.subtotal)}</td></tr>
  </table>
</div>
<form method="POST" action="/api/rent/cancel-booking" onsubmit="this.querySelector('button').disabled=true;this.querySelector('button').textContent='Processing…'">
  <input type="hidden" name="token" value="${esc(token)}"/>
  <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
    <button type="submit" style="background:#C62828;color:#fff;border:none;padding:13px 28px;border-radius:6px;font-size:15px;font-weight:700;cursor:pointer">&#10003; Yes, Cancel My Booking</button>
    <a href="/rent" style="font-size:14px;color:#666">Keep my booking</a>
  </div>
</form>`;
    }
    res.send(rentPage('Cancel Booking', `<div style="max-width:560px;margin:48px auto;padding:0 20px">${bodyHtml}</div>`));
  } catch (e: any) {
    console.error('[rent/cancel]', e.message);
    res.send(rentPage('Cancel Booking', `<div style="text-align:center;padding:60px 20px"><h2 style="color:#C62828">Error</h2><p>${String(e.message)}</p></div>`));
  }
});

// ── POST /api/rent/cancel-booking ─────────────────────────────────────────────
router.post('/api/rent/cancel-booking', async (req: Request, res: Response) => {
  const { token } = req.body;
  if (!token) return res.redirect('/rent');
  try {
    const tokenData = await fbReadP('rentalCancelTokens/' + token);
    if (!tokenData) {
      return res.send(rentPage('Cancel Booking', `<div style="text-align:center;padding:60px 20px"><h2 style="color:#C62828">Invalid Link</h2><p>This cancellation link is invalid or has already been used.</p><a href="/rent">Back to BookaWaka Rental</a></div>`));
    }
    const { cid, reservationId } = tokenData;
    const r = await fbReadP('rentalReservations/' + cid + '/' + reservationId);
    if (!r) return res.send(rentPage('Cancel Booking', `<div style="text-align:center;padding:60px 20px"><h2 style="color:#C62828">Reservation Not Found</h2><a href="/rent">Back</a></div>`));
    if (!['confirmed', 'pending'].includes(r.status)) {
      return res.send(rentPage('Cancel Booking', `<div style="text-align:center;padding:60px 20px"><h2 style="color:#F57F17">Cannot Cancel</h2><p>This reservation is currently <strong>${r.status}</strong> and cannot be cancelled online.</p><a href="/rent">Back to BookaWaka Rental</a></div>`));
    }
    const pickup = new Date(r.pickupDate).getTime();
    if ((pickup - Date.now()) / 3600000 < 48) {
      return res.send(rentPage('Cancel Booking', `<div style="text-align:center;padding:60px 20px"><h2 style="color:#F57F17">Too Close to Pickup</h2><p>Cancellations are not available within 48 hours of pickup. Please contact the rental company directly.</p><a href="/rent">Back</a></div>`));
    }
    const stripe = getStripe();
    let stripeNote = '';
    if (r.rentalPaymentIntentId) {
      try { await stripe.refunds.create({ payment_intent: r.rentalPaymentIntentId }); stripeNote += 'Rental refunded. '; }
      catch (se: any) { console.error('[rent/cancel] refund error:', se.message); stripeNote += 'Refund may need manual review. '; }
    }
    if (r.deposit && r.deposit.depositPaymentIntentId) {
      try { await stripe.paymentIntents.cancel(r.deposit.depositPaymentIntentId); stripeNote += 'Deposit hold released.'; }
      catch (se: any) { console.error('[rent/cancel] deposit cancel error:', se.message); }
    }
    if (r.vehicleId && r.pickupDate && r.returnDate) {
      const avUpdates: Record<string, any> = {};
      let d = new Date(r.pickupDate), end = new Date(r.returnDate);
      while (d < end) { avUpdates['rentalAvailability/' + cid + '/' + r.vehicleId + '/' + d.toISOString().slice(0, 10)] = null; d.setDate(d.getDate() + 1); }
      await fbWriteP('PATCH', '', avUpdates);
    }
    await Promise.all([
      fbWriteP('PATCH', 'rentalReservations/' + cid + '/' + reservationId, { status: 'cancelled', cancelledAt: Date.now(), cancelledBy: 'customer', updatedAt: Date.now() }),
      fbWriteP('PUT', 'rentalCancelTokens/' + token, null)
    ]);
    console.log('[rent/cancel] reservation', reservationId, 'cancelled by customer.', stripeNote);
    res.send(rentPage('Booking Cancelled', `<div style="text-align:center;padding:60px 20px"><div style="font-size:56px;margin-bottom:12px">&#10003;</div><h2 style="color:#2E7D32;margin-bottom:8px">Booking Cancelled</h2><p style="color:#555;margin-bottom:6px">Your booking <strong>${esc(r.jobId || reservationId)}</strong> has been cancelled.</p><p style="font-size:13px;color:#888;margin-bottom:24px">${esc(stripeNote) || 'Your refund will appear within 3-5 business days.'}</p><a href="/rent" style="background:#00796B;color:#fff;padding:11px 24px;border-radius:6px;text-decoration:none;font-weight:700">Book Again</a></div>`));
  } catch (e: any) {
    console.error('[rent/cancel-booking]', e.message);
    res.send(rentPage('Error', `<div style="text-align:center;padding:60px 20px"><h2 style="color:#C62828">Error</h2><p>${String(e.message)}</p></div>`));
  }
});

// ── GET /api/rent/validate-promo ──────────────────────────────────────────────
router.get('/api/rent/validate-promo', async (req: Request, res: Response) => {
  const code = req.query.code as string;
  if (!code) return res.json({ valid: false, reason: 'No code provided' });
  try {
    const promo = await fbReadP('rentalPromos/' + code.toUpperCase().trim());
    if (!promo) return res.json({ valid: false, reason: 'Code not found' });
    if (promo.used) return res.json({ valid: false, reason: 'Code already used' });
    if (promo.expiresAt && Date.now() > promo.expiresAt) return res.json({ valid: false, reason: 'Code expired' });
    res.json({ valid: true, discountPercent: promo.discountPercent, rentalJobId: promo.rentalJobId });
  } catch (e: any) {
    res.status(500).json({ valid: false, reason: 'Server error' });
  }
});

// ── POST /api/rent/use-promo ──────────────────────────────────────────────────
router.post('/api/rent/use-promo', async (req: Request, res: Response) => {
  const { code } = req.body;
  if (!code) return res.status(400).json({ error: 'Missing code' });
  try {
    const promo = await fbReadP('rentalPromos/' + code.toUpperCase().trim());
    if (!promo) return res.json({ ok: false, error: 'Code not found' });
    if (promo.used) return res.json({ ok: false, error: 'Code already used' });
    if (promo.expiresAt && Date.now() > promo.expiresAt) return res.json({ ok: false, error: 'Code expired' });
    await fbWriteP('PATCH', 'rentalPromos/' + code.toUpperCase().trim(), { used: true, usedAt: Date.now() });
    res.json({ ok: true, discountPercent: promo.discountPercent });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// ── GET /rent/booking ─────────────────────────────────────────────────────────
router.get('/rent/booking', async (req: Request, res: Response) => {
  const email = req.query.email as string;
  const job   = req.query.job   as string;
  let resultHtml = '';
  if (email && job) {
    try {
      const jobKey = job.trim().toUpperCase();
      const idx = await fbReadP('rentalBookingIndex/' + jobKey);
      if (!idx || (idx.customerEmail || '').toLowerCase() !== email.toLowerCase().trim()) {
        resultHtml = `<div class="rent-notice" style="background:#FFF3F3;border:1px solid #FFCDD2;color:#C62828;padding:14px 18px;border-radius:8px;margin-top:20px">No booking found with that reference and email. Please double-check both fields.</div>`;
      } else {
        const { cid, reservationId } = idx;
        const [r, fleetNode] = await Promise.all([
          fbReadP('rentalReservations/' + cid + '/' + reservationId),
          fbReadP('rentalFleet/' + cid)
        ]);
        if (!r) {
          resultHtml = `<div class="rent-notice" style="background:#FFF3F3;border:1px solid #FFCDD2;color:#C62828;padding:14px 18px;border-radius:8px;margin-top:20px">Reservation record not found.</div>`;
        } else {
          const v = (fleetNode || {})[r.vehicleId] || {};
          const vName = v.make ? `${esc(v.make)} ${esc(v.model || '')}` : esc(r.vehicleId || 'Vehicle');
          const fmt = (n: any) => '$' + parseFloat(n || 0).toFixed(2);
          const fmtDate = (ts: any) => ts ? new Date(ts).toLocaleDateString('en-NZ', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }) : '—';
          const pickupMs = r.pickupDate ? new Date(r.pickupDate).getTime() : 0;
          const hoursUntil = pickupMs ? (pickupMs - Date.now()) / 3600000 : 0;
          const canCancel = ['confirmed', 'pending'].includes(r.status) && hoursUntil >= 48 && r.cancelToken;
          const statusColor: Record<string, string> = { confirmed: '#2E7D32', pending: '#F57F17', active: '#1565C0', completed: '#00695C', cancelled: '#C62828' };
          const sColor = statusColor[r.status] || '#555';
          resultHtml = `<div style="background:#fff;border-radius:10px;padding:24px;box-shadow:0 2px 10px rgba(0,0,0,.08);margin-top:24px;text-align:left">
  <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;margin-bottom:20px;padding-bottom:16px;border-bottom:1px solid #f0f0f0">
    <div>
      <div style="font-size:11px;color:#888;margin-bottom:2px;text-transform:uppercase;letter-spacing:.5px">Booking Reference</div>
      <div style="font-size:21px;font-weight:900;font-family:monospace;color:#004D40">${esc(r.jobId || reservationId)}</div>
    </div>
    <span style="background:${sColor};color:#fff;padding:6px 16px;border-radius:20px;font-size:13px;font-weight:700;text-transform:capitalize">${esc(r.status || 'unknown')}</span>
  </div>
  <table style="width:100%;font-size:13.5px;border-collapse:collapse">
    <tr><td style="padding:7px 0;color:#666;width:150px">Vehicle</td><td style="font-weight:600">${vName}${v.rego ? ' (' + esc(v.rego) + ')' : ''}</td></tr>
    <tr><td style="padding:7px 0;color:#666">Pickup date</td><td style="font-weight:600">${fmtDate(r.pickupDate)}</td></tr>
    <tr><td style="padding:7px 0;color:#666">Return date</td><td style="font-weight:600">${fmtDate(r.returnDate)}</td></tr>
    <tr><td style="padding:7px 0;color:#666">Duration</td><td>${r.billingDays || '—'} day${r.billingDays !== 1 ? 's' : ''}</td></tr>
    <tr><td style="padding:7px 0;color:#666">Insurance</td><td style="text-transform:capitalize">${esc(r.insuranceTier || 'basic')}</td></tr>
    <tr><td style="padding:7px 0;color:#666">Total paid</td><td style="font-weight:700;color:#004D40">${fmt(r.pricing && r.pricing.subtotal)}</td></tr>
    ${r.deposit && r.deposit.amount > 0 ? `<tr><td style="padding:7px 0;color:#666">Security deposit</td><td>${fmt(r.deposit.amount)} <span style="font-size:11px;color:#888">(${esc(r.deposit.status || 'held')})</span></td></tr>` : ''}
  </table>
  ${r.promoCode ? `<div style="margin-top:16px;background:#E8F5E9;border-radius:6px;padding:12px 16px;font-size:13px"><strong style="color:#2E7D32">&#127881; Ride-to-Rental code:</strong> <span style="font-family:monospace;font-size:16px;font-weight:900;color:#1B5E20;letter-spacing:2px">${esc(r.promoCode)}</span> &nbsp;<a href="/ride?promo=${encodeURIComponent(r.promoCode)}" style="font-size:12px;color:#00695C">Book taxi &rarr;</a></div>` : ''}
  ${canCancel ? `<div style="margin-top:16px"><a href="/rent/cancel?token=${esc(r.cancelToken)}" style="background:#C62828;color:#fff;padding:10px 22px;border-radius:6px;text-decoration:none;font-size:13px;font-weight:700">Cancel Booking</a><span style="font-size:12px;color:#888;margin-left:10px">Free if cancelled 48+ hrs before pickup</span></div>` : ''}
  ${r.status === 'cancelled' ? `<div style="margin-top:16px;background:#FFEBEE;border-radius:6px;padding:12px 16px;font-size:13px;color:#C62828">This booking has been cancelled.</div>` : ''}
</div>`;
        }
      }
    } catch (e: any) {
      resultHtml = `<div class="rent-notice" style="background:#FFF3F3;border:1px solid #FFCDD2;color:#C62828;padding:14px 18px;border-radius:8px;margin-top:20px">Error: ${esc(e.message)}</div>`;
    }
  }
  const body = `<div style="max-width:540px;margin:40px auto;padding:0 16px">
<h2 style="font-size:22px;font-weight:800;color:#263238;margin-bottom:4px">&#128203; Find My Booking</h2>
<p style="font-size:14px;color:#888;margin-bottom:24px">Enter your email and booking reference to view your reservation.</p>
<form method="GET" action="/rent/booking" style="background:#fff;border-radius:10px;padding:24px;box-shadow:0 2px 10px rgba(0,0,0,.08)">
  <div style="margin-bottom:16px">
    <label style="display:block;font-size:13px;font-weight:600;color:#263238;margin-bottom:6px">Email address</label>
    <input type="email" name="email" value="${esc(email || '')}" required style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:6px;font-size:14px;box-sizing:border-box" placeholder="you@example.com"/>
  </div>
  <div style="margin-bottom:20px">
    <label style="display:block;font-size:13px;font-weight:600;color:#263238;margin-bottom:6px">Booking reference</label>
    <input type="text" name="job" value="${esc(job || '')}" required style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:6px;font-size:14px;box-sizing:border-box;font-family:monospace;text-transform:uppercase" placeholder="e.g. BWR-123456"/>
  </div>
  <button type="submit" style="width:100%;background:#00795C;color:#fff;border:none;padding:12px;border-radius:6px;font-size:15px;font-weight:700;cursor:pointer">Find My Booking &rarr;</button>
</form>
${resultHtml}
</div>`;
  res.send(rentPage('My Booking', body));
});

// ── GET /ride ─────────────────────────────────────────────────────────────────
router.get('/ride', async (req: Request, res: Response) => {
  const { promo, success, ref, err } = req.query as any;
  if (success === '1') {
    const body = `<div style="max-width:500px;margin:60px auto;padding:0 20px;text-align:center">
  <div style="font-size:60px;margin-bottom:20px">&#9989;</div>
  <h2 style="font-size:24px;font-weight:800;color:#263238;margin-bottom:8px">Taxi Request Received!</h2>
  <p style="color:#555;margin-bottom:6px">Reference: <strong style="font-family:monospace;color:#00695C">${esc(ref || '—')}</strong></p>
  <p style="font-size:13.5px;color:#666;margin-bottom:28px">We've received your taxi request and will confirm your driver by phone shortly.</p>
  <a href="/" class="rent-btn" style="display:inline-flex">&#127968; Back to Home</a>
</div>`;
    return res.send(rentPage('Taxi Booked', body));
  }
  let promoInfo: any = null;
  if (promo) {
    try {
      const p = await fbReadP('rentalPromos/' + (promo as string).toUpperCase().trim());
      if (p && !p.used && (!p.expiresAt || Date.now() < p.expiresAt)) promoInfo = p;
    } catch (e) { /* ignore */ }
  }
  const errMsg = err ? `<div style="background:#FFF3F3;border:1px solid #FFCDD2;color:#C62828;padding:12px 16px;border-radius:8px;margin-bottom:20px">Please fill in all required fields.</div>` : '';
  const promoBlock = promoInfo ? `<div style="background:#E8F5E9;border:1px solid #A5D6A7;border-radius:8px;padding:14px 18px;margin-bottom:20px;display:flex;align-items:center;gap:14px">
  <div style="font-size:28px">&#127881;</div>
  <div>
    <div style="font-size:13.5px;font-weight:700;color:#2E7D32">${promoInfo.discountPercent}% discount applied!</div>
    <div style="font-size:12px;color:#388E3C">Code: <strong style="font-family:monospace">${esc((promo || '').toUpperCase())}</strong></div>
  </div>
</div>` : '';
  const body = `<div style="max-width:540px;margin:40px auto;padding:0 16px">
<h2 style="font-size:22px;font-weight:800;color:#263238;margin-bottom:4px">&#128664; Book a Taxi</h2>
<p style="font-size:14px;color:#888;margin-bottom:24px">Get a ride to your rental car pickup — or anywhere you need to go.</p>
${errMsg}${promoBlock}
<form method="POST" action="/api/ride/book" style="background:#fff;border-radius:10px;padding:24px;box-shadow:0 2px 10px rgba(0,0,0,.08)">
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:14px">
    <div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:5px">Your name</label><input type="text" name="name" required style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:6px;font-size:14px;box-sizing:border-box" placeholder="Jane Smith"/></div>
    <div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:5px">Phone number</label><input type="tel" name="phone" required style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:6px;font-size:14px;box-sizing:border-box" placeholder="+64 21 000 0000"/></div>
  </div>
  <div style="margin-bottom:14px"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:5px">Pickup address</label><input type="text" name="pickup" required style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:6px;font-size:14px;box-sizing:border-box" placeholder="e.g. 123 Queen St, Auckland"/></div>
  <div style="margin-bottom:14px"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:5px">Destination</label><input type="text" name="destination" required style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:6px;font-size:14px;box-sizing:border-box" placeholder="Rental company address or anywhere"/></div>
  <div style="margin-bottom:14px"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:5px">Pickup date &amp; time</label><input type="datetime-local" name="scheduledAt" required style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:6px;font-size:14px;box-sizing:border-box"/></div>
  <div style="margin-bottom:20px">
    <label style="display:block;font-size:13px;font-weight:600;margin-bottom:5px">Discount code <span style="font-size:11px;font-weight:400;color:#888">(from your rental confirmation)</span></label>
    <input type="text" name="promoCode" value="${esc(promo || '')}" style="width:100%;padding:10px 12px;border:1.5px solid ${promoInfo ? '#4CAF50' : '#e0e0e0'};border-radius:6px;font-size:14px;box-sizing:border-box;font-family:monospace;text-transform:uppercase" placeholder="e.g. R2R-A4F9B2"/>
  </div>
  <button type="submit" style="width:100%;background:#00795C;color:#fff;border:none;padding:13px;border-radius:6px;font-size:15px;font-weight:700;cursor:pointer">&#128664; Confirm Taxi Request &rarr;</button>
  <p style="font-size:11.5px;color:#888;margin-top:12px;text-align:center">A driver will be confirmed and you'll be contacted by phone.</p>
</form>
</div>`;
  res.send(rentPage('Book a Taxi', body));
});

// ── POST /api/ride/book ───────────────────────────────────────────────────────
router.post('/api/ride/book', async (req: Request, res: Response) => {
  const { name, phone, pickup, destination, scheduledAt, promoCode } = req.body;
  if (!name || !phone || !pickup || !destination || !scheduledAt) {
    return res.redirect('/ride?err=missing');
  }
  try {
    let discountPercent = 0;
    let promoApplied: string | null = null;
    const code = (promoCode || '').toUpperCase().trim();
    if (code) {
      const promo = await fbReadP('rentalPromos/' + code);
      if (promo && !promo.used && (!promo.expiresAt || Date.now() < promo.expiresAt)) {
        discountPercent = promo.discountPercent || 0;
        promoApplied = code;
        await fbWriteP('PATCH', 'rentalPromos/' + code, { used: true, usedAt: Date.now(), usedFor: 'taxi' });
      }
    }
    const requestId = 'RIDE' + Date.now();
    const now = Date.now();
    await fbWriteP('PUT', 'rentalTaxiRequests/' + requestId, {
      requestId,
      customerName: name.trim(), customerPhone: phone.trim(),
      pickup: pickup.trim(), destination: destination.trim(),
      scheduledAt: scheduledAt.trim(),
      promoCode: promoApplied, discountPercent,
      status: 'pending', createdAt: now
    });
    console.log('[ride/book]', requestId, '| promo:', promoApplied || 'none', '| discount:', discountPercent + '%');
    const baseUrl = 'https://' + (process.env.REPLIT_DOMAINS || '').split(',')[0];
    setImmediate(async () => {
      try {
        const resend = await getResendClient();
        if (!resend) return;
        await resend.emails.send({
          from: 'BookaWaka <info@bookawaka.com>',
          to: 'info@bookawaka.com',
          subject: `New Taxi Request ${requestId}${promoApplied ? ' (' + discountPercent + '% promo)' : ''}`,
          html: `<!DOCTYPE html><html><body style="font-family:Arial,sans-serif;padding:20px;max-width:520px">
<h2 style="color:#00695C;margin-bottom:16px">&#128664; New Taxi Booking Request</h2>
<table style="width:100%;border-collapse:collapse;font-size:14px">
<tr><td style="padding:8px 12px;background:#E0F2F1;font-weight:700;width:130px">Ref</td><td style="padding:8px 12px;border:1px solid #e0e0e0;font-family:monospace">${esc(requestId)}</td></tr>
<tr><td style="padding:8px 12px;background:#E0F2F1;font-weight:700">Customer</td><td style="padding:8px 12px;border:1px solid #e0e0e0">${esc(name)}</td></tr>
<tr><td style="padding:8px 12px;background:#E0F2F1;font-weight:700">Phone</td><td style="padding:8px 12px;border:1px solid #e0e0e0">${esc(phone)}</td></tr>
<tr><td style="padding:8px 12px;background:#E0F2F1;font-weight:700">Pickup</td><td style="padding:8px 12px;border:1px solid #e0e0e0">${esc(pickup)}</td></tr>
<tr><td style="padding:8px 12px;background:#E0F2F1;font-weight:700">Destination</td><td style="padding:8px 12px;border:1px solid #e0e0e0">${esc(destination)}</td></tr>
<tr><td style="padding:8px 12px;background:#E0F2F1;font-weight:700">Scheduled</td><td style="padding:8px 12px;border:1px solid #e0e0e0">${esc(scheduledAt)}</td></tr>
${promoApplied ? `<tr><td style="padding:8px 12px;background:#C8E6C9;font-weight:700;color:#2E7D32">Promo code</td><td style="padding:8px 12px;border:1px solid #e0e0e0;font-weight:700;color:#2E7D32;font-family:monospace">${esc(promoApplied)} (${discountPercent}% discount)</td></tr>` : ''}
</table>
<p style="margin-top:18px;font-size:12px;color:#888">View requests at ${baseUrl}/SA-Rental.aspx</p>
</body></html>`
        });
      } catch (e: any) { console.error('[ride/book email]', e.message); }
    });
    res.redirect('/ride?success=1&ref=' + encodeURIComponent(requestId));
  } catch (e: any) {
    console.error('[ride/book]', e.message);
    res.redirect('/ride?err=' + encodeURIComponent(e.message));
  }
});

// ── GET /rent/confirm ─────────────────────────────────────────────────────────
router.get('/rent/confirm', async (req: Request, res: Response) => {
  const { j: jobId, cid, rid: reservationId } = req.query as any;
  if (!jobId || !cid || !reservationId) return res.redirect('/rent');
  try {
    const [reservation, vehicle, config] = await Promise.all([
      fbReadP('rentalReservations/' + cid + '/' + reservationId),
      fbReadP('rentalFleet/' + cid),
      fbReadP('bwConfig/rental')
    ]);
    const res2 = reservation || {};
    const v = (vehicle && vehicle[res2.vehicleId]) || {};
    const r2r = config && config.rideToRental;
    const r2rEnabled = r2r && r2r.enabled && r2r.discountPercent > 0;
    const promoCode = res2.promoCode || null;
    const r2rHtml = r2rEnabled ? `<div class="rent-r2r-card">
  <h3>&#128664; Get a Taxi to Your Rental</h3>
  <p>${esc(r2r.message || 'Book a discounted taxi ride to pick up your rental car.')}</p>
  <div style="font-size:36px;font-weight:800;color:#A7FFEB;margin-bottom:16px">${r2r.discountPercent}% OFF</div>
  <a href="/ride${promoCode ? '?promo=' + encodeURIComponent(promoCode) : ''}" class="rent-btn" style="background:#fff;color:#004D40;display:inline-flex">Book a Taxi Now &rarr;</a>
  ${promoCode
    ? `<div style="margin-top:14px;background:rgba(255,255,255,.15);border-radius:8px;padding:10px 16px">
        <div style="font-size:11px;opacity:.8;margin-bottom:4px">Your personal discount code (valid 7 days, single use):</div>
        <div style="font-size:22px;font-weight:900;font-family:monospace;letter-spacing:3px;color:#A7FFEB">${esc(promoCode)}</div>
       </div>`
    : `<div style="font-size:12px;opacity:.7;margin-top:10px">Show this page to your driver at pickup</div>`}
</div>` : '';
    const pricing = res2.pricing || {};
    const body = `<div class="rent-confirm-box">
  <div class="rent-confirm-icon">&#9989;</div>
  <h1 style="font-size:28px;font-weight:800;color:#263238;margin-bottom:8px">Booking Confirmed!</h1>
  <p style="font-size:15px;color:#888;margin-bottom:28px">Your confirmation reference is <strong style="color:#00695C">${esc(jobId)}</strong></p>
  <div class="rent-notice ok" style="text-align:left">A confirmation email has been sent to <strong>${esc(res2.customerEmail || '')}</strong></div>
  <div style="background:#fff;border-radius:10px;padding:22px;box-shadow:0 2px 10px rgba(0,0,0,.08);margin-bottom:20px;text-align:left">
    <h3 style="font-size:15px;font-weight:700;margin-bottom:16px;color:#263238">&#128203; Booking Details</h3>
    <table style="width:100%;font-size:13px;border-collapse:collapse">
      <tr><td style="color:#888;padding:5px 0;width:140px">Vehicle</td><td style="font-weight:600">${esc(v.year || '')} ${esc(v.make || '')} ${esc(v.model || '')} (${esc(v.rego || res2.vehicleId || '')})</td></tr>
      <tr><td style="color:#888;padding:5px 0">Pickup</td><td style="font-weight:600">${esc(res2.pickupDate || '—')}</td></tr>
      <tr><td style="color:#888;padding:5px 0">Return</td><td style="font-weight:600">${esc(res2.returnDate || '—')}</td></tr>
      <tr><td style="color:#888;padding:5px 0">Duration</td><td style="font-weight:600">${res2.billingDays || '—'} days</td></tr>
      <tr><td style="color:#888;padding:5px 0">Rental Total</td><td style="font-weight:700;color:#00695C">$${parseFloat(pricing.subtotal || 0).toFixed(2)}</td></tr>
      <tr><td style="color:#888;padding:5px 0">Deposit Hold</td><td style="font-weight:600">$${parseFloat(pricing.depositAmount || 0).toFixed(2)} <span style="font-size:11px;color:#888">(released on return)</span></td></tr>
      <tr><td style="color:#888;padding:5px 0">Insurance</td><td style="font-weight:600;text-transform:capitalize">${esc(res2.insuranceTier || 'basic')}</td></tr>
    </table>
  </div>
  ${r2rHtml}
  <div style="margin-top:24px;display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
    <a href="/rent" class="rent-btn rent-btn-outline">&#128663; Search More Cars</a>
    <a href="/" class="rent-btn">&#127968; Home</a>
  </div>
</div>`;
    res.send(rentPage('Booking Confirmed — ' + jobId, body));
  } catch (e: any) {
    console.error('[rent/confirm]', e.message);
    res.send(rentPage('Confirmed', `<div class="rent-notice ok">Booking reference: <strong>${esc(jobId)}</strong>. Check your email for details.</div>`));
  }
});

// ── GET /api/admin/rental-revenue ─────────────────────────────────────────────
router.get('/api/admin/rental-revenue', async (req: Request, res: Response) => {
  try {
    const [allRes, config, allCfg] = await Promise.all([
      fbReadP('rentalReservations'),
      fbReadP('bwConfig/rental'),
      fbReadP('rentalConfig')
    ]);
    const defRate = parseFloat((config && config.defaultCommission) || 12);
    const result: Record<string, any> = {};
    const all = allRes || {};
    Object.entries(all).forEach(([cid, reservations]: any) => {
      const rate = (allCfg && allCfg[cid] && allCfg[cid].commission !== undefined) ? parseFloat(allCfg[cid].commission) : defRate;
      let total = 0, commission = 0, count = 0, active = 0, thisMonth = 0;
      const curMonth = new Date().toISOString().slice(0, 7);
      Object.values(reservations || {}).forEach((r: any) => {
        if (r.status === 'cancelled') return;
        const rt = parseFloat(r.pricing && r.pricing.subtotal || 0);
        total += rt; commission += rt * rate / 100; count++;
        if (r.status === 'active') active++;
        if (r.createdAt && new Date(r.createdAt).toISOString().slice(0, 7) === curMonth) thisMonth += rt;
      });
      result[cid] = { total, commission, commissionRate: rate, count, active, thisMonth };
    });
    res.json({ ok: true, data: result, defRate });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// ── Rental Portal — Login ─────────────────────────────────────────────────────
router.get('/rental-portal', (req: Request, res: Response) => {
  const err = (req.query.err as string) || '';
  const errMsgs: Record<string, string> = {
    invalid: 'Invalid email or password.',
    missing: 'Please enter your email and password.',
    nodata: 'No rental portal access found for this account.',
    session: 'Your session has expired. Please sign in again.'
  };
  const errHtml = err ? `<div style="background:#FFEBEE;color:#C62828;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px;border-left:4px solid #C62828">${esc(errMsgs[err] || 'Sign in error.')}</div>` : '';
  res.send(`<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Rental Portal &mdash; BookaWaka</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:linear-gradient(135deg,#004D40,#00695C);min-height:100vh;display:flex;align-items:center;justify-content:center;font-family:'Segoe UI',system-ui,sans-serif}
.box{background:#fff;border-radius:10px;padding:40px;width:420px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.box h1{font-size:22px;color:#00695C;margin-bottom:4px}
.box p{color:#888;font-size:13px;margin-bottom:28px}
label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
input{width:100%;padding:10px 12px;border:1px solid #ddd;border-radius:6px;font-size:14px;margin-bottom:18px;box-sizing:border-box}
input:focus{outline:none;border-color:#00695C;box-shadow:0 0 0 3px rgba(0,105,92,.1)}
button{width:100%;padding:12px;background:#00695C;color:#fff;border:none;border-radius:6px;font-size:15px;font-weight:600;cursor:pointer}
button:hover{background:#004D40}
.hint{text-align:center;font-size:12px;color:#aaa;margin-top:18px}
</style></head>
<body>
<div class="box">
  <h1>&#128663; Rental Portal</h1>
  <p>BookaWaka &mdash; Vehicle Rental Management</p>
  ${errHtml}
  <form method="POST" action="/api/rental-login">
    <label>Email Address</label>
    <input type="email" name="email" placeholder="owner@rentalcompany.com" required autocomplete="email"/>
    <label>Password</label>
    <input type="password" name="password" required autocomplete="current-password"/>
    <button type="submit">Sign In</button>
  </form>
  <p class="hint">Forgot your password?<br>Contact your BookaWaka administrator.</p>
</div>
</body></html>`);
});

router.post('/api/rental-login', (req: Request, res: Response) => {
  const email    = (req.body.email    || '').trim().toLowerCase();
  const password =  req.body.password || '';
  if (!email || !password) return res.redirect('/rental-portal?err=missing');
  fbAuthSignIn(email, password, (authErr: any) => {
    if (authErr) return res.redirect('/rental-portal?err=invalid');
    fbRead('rentalPortalAccess', (err: any, data: any) => {
      if (err || !data) return res.redirect('/rental-portal?err=nodata');
      const entries = Object.entries(data);
      const match = entries.find(([, v]: any) => v && v.email && v.email.toLowerCase() === email && v.active !== false);
      if (!match) return res.redirect('/rental-portal?err=nodata');
      const [companyId, acc] = match as any;
      const token = rnSetSession(companyId, acc.name || companyId, email);
      res.redirect('/rental-portal/dashboard?t=' + encodeURIComponent(token));
    });
  });
});

router.get('/api/rental-logout', (req: Request, res: Response) => {
  const t = (req.query.t as string) || '';
  delete rentalSessions[t];
  unpersistSessionDirect('rental', t);
  res.redirect('/rental-portal');
});

// ── POST /api/set-rental-password ─────────────────────────────────────────────
router.post('/api/set-rental-password', (req: Request, res: Response) => {
  const { companyId, name, email, password } = req.body;
  if (!companyId || !email || !password) return res.status(400).json({ error: 'Missing fields' });
  if (password.length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' });
  const emailClean = email.toLowerCase().trim();
  fbAuthCreate(emailClean, password, (authErr: any) => {
    if (authErr && authErr.message !== 'EMAIL_EXISTS') return res.json({ error: authErr.message || 'Failed to create account' });
    const data = { email: emailClean, name: name || companyId, companyId, active: true, createdAt: Date.now() };
    fbWrite('PUT', 'rentalPortalAccess/' + companyId, data, (err: any) => {
      if (err) return res.json({ error: String(err) });
      res.json({ ok: true });
    });
  });
});

// ── Rental Portal — Dashboard ─────────────────────────────────────────────────
router.get('/rental-portal/dashboard', requireRentalAuth, (req: any, res: Response) => {
  const sess = req.rnSession, token = req.rnToken;
  const te = encodeURIComponent(token);
  const cid = sess.companyId;
  const today = new Date().toISOString().slice(0, 10);
  const curMonth = today.slice(0, 7);
  Promise.all([fbReadP('rentalFleet/' + cid), fbReadP('rentalReservations/' + cid)])
    .then(([fleet, reservations]) => {
      const fl = fleet || {};
      const rs = reservations || {};
      const vehicles = Object.keys(fl).length;
      const allRes = Object.entries(rs);
      const active   = allRes.filter(([, r]: any) => r.status === 'active').length;
      const pending  = allRes.filter(([, r]: any) => r.status === 'pending').length;
      const thisMonth = allRes.filter(([, r]: any) => r.createdAt && new Date(r.createdAt).toISOString().slice(0, 7) === curMonth);
      let monthRevenue = 0;
      thisMonth.forEach(([, r]: any) => { if (r.status !== 'cancelled' && r.pricing) monthRevenue += parseFloat(r.pricing.subtotal || 0); });
      const upcoming = allRes
        .filter(([, r]: any) => (r.status === 'confirmed' || r.status === 'pending') && r.pickupDate >= today)
        .sort((a: any, b: any) => (a[1].pickupDate || '') > (b[1].pickupDate || '') ? 1 : -1)
        .slice(0, 10);
      const recent = allRes
        .filter(([, r]: any) => r.status === 'completed')
        .sort((a: any, b: any) => (b[1].updatedAt || 0) - (a[1].updatedAt || 0))
        .slice(0, 5);
      const upcomingRows = upcoming.map(([id, r]: any) => {
        const v = fl[r.vehicleId] || {};
        const vName = v.make ? `${esc(v.make)} ${esc(v.model || '')}` : esc(r.vehicleId || '—');
        return `<tr>
<td style="font-family:monospace;font-size:11px;color:#00695C">${esc(id.slice(-8))}</td>
<td>${esc(r.customerName || r.customerId || '—')}</td>
<td>${vName}</td>
<td style="font-weight:600">${esc(r.pickupDate || '—')}</td>
<td>${esc(r.returnDate || '—')}</td>
<td style="font-weight:600">${r.pricing ? '$' + parseFloat(r.pricing.subtotal || 0).toFixed(2) : '—'}</td>
<td>${rnResBadge(r.status)}</td>
<td><a href="/rental-portal/reservations?t=${te}&id=${esc(id)}" class="rn-btn rn-btn-g" style="font-size:11px;padding:4px 10px">Manage</a></td>
</tr>`;
      }).join('');
      const recentRows = recent.map(([id, r]: any) => {
        const v = fl[r.vehicleId] || {};
        const deductTotal = r.deductions ? Object.values(r.deductions).reduce((s: number, v: any) => s + parseFloat(v || 0), 0) : 0;
        return `<tr>
<td style="font-family:monospace;font-size:11px">${esc(id.slice(-8))}</td>
<td>${esc(r.customerName || r.customerId || '—')}</td>
<td>${v.make ? `${esc(v.make)} ${esc(v.model || '')}` : esc(r.vehicleId || '—')}</td>
<td>${esc(r.pickupDate || '—')} → ${esc(r.returnDate || '—')}</td>
<td style="font-weight:600">$${parseFloat(r.pricing && r.pricing.subtotal || 0).toFixed(2)}</td>
<td style="color:${deductTotal > 0 ? '#C62828' : '#888'}">$${deductTotal.toFixed(2)}</td>
</tr>`;
      }).join('');
      const body = `<h2 style="font-size:18px;font-weight:700;color:#00695C;margin-bottom:16px">&#128202; Dashboard</h2>
<div class="rn-stats">
  <div class="rn-stat"><div class="rn-stat-v">${vehicles}</div><div class="rn-stat-l">Total Vehicles</div></div>
  <div class="rn-stat blue"><div class="rn-stat-v">${pending}</div><div class="rn-stat-l">Pending Confirmations</div></div>
  <div class="rn-stat orange"><div class="rn-stat-v">${active}</div><div class="rn-stat-l">Active Rentals</div></div>
  <div class="rn-stat" style="border-left-color:#2E7D32"><div class="rn-stat-v" style="color:#2E7D32">$${monthRevenue.toFixed(2)}</div><div class="rn-stat-l">Revenue This Month</div></div>
</div>
<div class="rn-card">
  <div class="rn-card-hd"><h3>&#128197; Upcoming Pickups (next 7 days)</h3>
    <a href="/rental-portal/reservations?t=${te}" class="rn-btn rn-btn-g" style="font-size:12px">All Reservations &rarr;</a></div>
  ${upcoming.length ? `<div style="overflow-x:auto"><table class="rn-tbl"><thead><tr><th>ID</th><th>Customer</th><th>Vehicle</th><th>Pickup</th><th>Return</th><th>Total</th><th>Status</th><th>Action</th></tr></thead><tbody>${upcomingRows}</tbody></table></div>` : '<div class="rn-empty">No upcoming pickups.</div>'}
</div>
<div class="rn-card">
  <div class="rn-card-hd"><h3>&#10003; Recent Completions</h3></div>
  ${recent.length ? `<div style="overflow-x:auto"><table class="rn-tbl"><thead><tr><th>ID</th><th>Customer</th><th>Vehicle</th><th>Dates</th><th>Rental Total</th><th>Deductions</th></tr></thead><tbody>${recentRows}</tbody></table></div>` : '<div class="rn-empty">No completed rentals yet.</div>'}
</div>`;
      res.send(rnPage('Dashboard', renderRnNav(sess, token, 'dashboard'), body));
    })
    .catch((e: any) => res.send(rnPage('Dashboard', renderRnNav(sess, token, 'dashboard'), `<div class="rn-notice err">Error loading data: ${esc(e.message)}</div>`)));
});

// ── Rental Portal — Reservations ──────────────────────────────────────────────
router.get('/rental-portal/reservations', requireRentalAuth, (req: any, res: Response) => {
  const sess = req.rnSession, token = req.rnToken;
  const te = encodeURIComponent(token);
  const cid = sess.companyId;
  const filterStatus = (req.query.status as string) || '';
  const focusId = (req.query.id as string) || '';
  const msg = (req.query.msg as string) || '', mt = (req.query.mt as string) || '';
  Promise.all([fbReadP('rentalFleet/' + cid), fbReadP('rentalReservations/' + cid)])
    .then(([fleet, reservations]) => {
      const fl = fleet || {};
      const rs = reservations || {};
      let allRes: any[] = Object.entries(rs);
      if (filterStatus) allRes = allRes.filter(([, r]: any) => r.status === filterStatus);
      allRes.sort((a: any, b: any) => (b[1].createdAt || 0) - (a[1].createdAt || 0));
      const noticeHtml = msg ? `<div class="rn-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
      const rows = allRes.map(([id, r]: any) => {
        const v = fl[r.vehicleId] || {};
        const vName = v.make ? `${esc(v.make)} ${esc(v.model || '')} (${esc(v.rego || '')})` : esc(r.vehicleId || '—');
        const insurLabel: Record<string, string> = { basic: 'Basic', standard: 'Standard', full: 'Full / Zero Excess' };
        const depStatus = r.deposit ? esc(r.deposit.status || 'held') : '—';
        const deductTotal = Object.values(r.deductions || {}).reduce((s: number, v: any) => s + parseFloat(v || 0), 0);
        let actions = '';
        if (r.status === 'pending' || r.status === 'confirmed') {
          actions += `<form method="POST" action="/api/rental-reservation-action" style="display:inline;margin-right:4px">
<input type="hidden" name="t" value="${esc(token)}"/><input type="hidden" name="reservationId" value="${esc(id)}"/><input type="hidden" name="action" value="confirm-pickup"/>
<button type="submit" class="rn-btn rn-btn-g" style="font-size:11px;padding:4px 8px" onclick="return confirm('Confirm vehicle pickup for this reservation?')">&#10003; Pickup</button></form>`;
          actions += `<form method="POST" action="/api/rental-cancel-booking" style="display:inline">
<input type="hidden" name="t" value="${esc(token)}"/><input type="hidden" name="reservationId" value="${esc(id)}"/>
<button type="submit" class="rn-btn rn-btn-r" style="font-size:11px;padding:4px 8px" onclick="return confirm('Cancel and refund this reservation? This will issue a Stripe refund.')">&#8855; Cancel &amp; Refund</button></form>`;
        } else if (r.status === 'active') {
          actions += `<a href="/rental-portal/return?t=${te}&id=${esc(id)}" class="rn-btn rn-btn-b" style="font-size:11px;padding:4px 8px">&#8617; Process Return</a>`;
        }
        return `<tr style="${focusId === id ? 'background:#E0F7FA;' : ''}">
<td style="font-family:monospace;font-size:11px;color:#00695C;font-weight:700">${esc(r.jobId || id.slice(-8))}</td>
<td>${esc(r.customerName || r.customerId || '—')}</td>
<td style="font-size:12px">${vName}</td>
<td style="white-space:nowrap">${esc(r.pickupDate || '—')}</td>
<td style="white-space:nowrap">${esc(r.returnDate || '—')}</td>
<td style="text-align:center">${r.billingDays || '—'}</td>
<td style="font-weight:700">$${parseFloat(r.pricing && r.pricing.subtotal || 0).toFixed(2)}</td>
<td>${esc(r.deposit ? '$' + parseFloat(r.deposit.amount || 0).toFixed(2) : '—')} <span style="font-size:10px;color:#888">(${depStatus})</span></td>
<td>${esc(insurLabel[r.insuranceTier] || r.insuranceTier || '—')}</td>
<td>${deductTotal > 0 ? '<span style="color:#C62828;font-weight:700">$' + deductTotal.toFixed(2) + '</span>' : '—'}</td>
<td>${rnResBadge(r.status)}</td>
<td style="white-space:nowrap">${actions || '—'}</td>
</tr>`;
      }).join('');
      const statusOpts = ['', 'pending', 'confirmed', 'active', 'completed', 'cancelled']
        .map(s => `<option value="${s}" ${s === filterStatus ? 'selected' : ''}>${s || 'All Statuses'}</option>`).join('');
      const body = `<h2 style="font-size:18px;font-weight:700;color:#00695C;margin-bottom:16px">&#128203; Reservations (${allRes.length})</h2>
${noticeHtml}
<div class="rn-filter">
  <form method="GET" action="/rental-portal/reservations" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap">
    <input type="hidden" name="t" value="${esc(token)}"/>
    <label style="font-size:13px;font-weight:500">Status:</label>
    <select name="status">${statusOpts}</select>
    <button type="submit" class="rn-btn rn-btn-g" style="padding:7px 14px">Filter</button>
    <a href="/rental-portal/reservations?t=${te}" class="rn-btn rn-btn-n">Clear</a>
  </form>
</div>
<div class="rn-card" style="overflow-x:auto">
${allRes.length ? `<table class="rn-tbl"><thead><tr>
<th>Job ID</th><th>Customer</th><th>Vehicle</th><th>Pickup</th><th>Return</th><th>Days</th><th>Total</th><th>Deposit</th><th>Insurance</th><th>Deductions</th><th>Status</th><th>Action</th>
</tr></thead><tbody>${rows}</tbody></table>` : '<div class="rn-empty">No reservations found.</div>'}
</div>`;
      res.send(rnPage('Reservations', renderRnNav(sess, token, 'reservations'), body));
    })
    .catch((e: any) => res.send(rnPage('Reservations', renderRnNav(sess, token, 'reservations'), `<div class="rn-notice err">Error: ${esc(e.message)}</div>`)));
});

// ── Rental Portal — Process Return Page ───────────────────────────────────────
router.get('/rental-portal/return', requireRentalAuth, (req: any, res: Response) => {
  const sess = req.rnSession, token = req.rnToken;
  const te = encodeURIComponent(token);
  const cid = sess.companyId;
  const resId = (req.query.id as string) || '';
  if (!resId) return res.redirect('/rental-portal/reservations?t=' + te);
  Promise.all([fbReadP('rentalReservations/' + cid + '/' + resId), fbReadP('rentalFleet/' + cid)])
    .then(([r, fleet]) => {
      if (!r) return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Reservation+not+found&mt=err');
      const fl = fleet || {};
      const v = fl[r.vehicleId] || {};
      const vName = v.make ? `${esc(v.make)} ${esc(v.model || '')} ${esc(v.year || '')} (${esc(v.rego || '')})` : esc(r.vehicleId || 'Vehicle');
      const odometerPickup = r.odometer && r.odometer.pickup ? r.odometer.pickup : 0;
      const policyType = (v.mileagePolicy && v.mileagePolicy.type) || 'unlimited';
      const includedPerDay = (v.mileagePolicy && v.mileagePolicy.includedPerDay) || 0;
      const extraKmRate = (v.mileagePolicy && v.mileagePolicy.extraKmRate) || 0;
      const totalIncluded = policyType === 'daily' ? (r.billingDays || 1) * includedPerDay : (policyType === 'total' ? includedPerDay : 0);
      const body = `<h2 style="font-size:18px;font-weight:700;color:#00695C;margin-bottom:6px">&#8617; Process Vehicle Return</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">Job: <strong>${esc(r.jobId || resId)}</strong> &mdash; ${esc(r.customerName || r.customerId || 'Customer')} &mdash; ${vName}</p>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-bottom:18px">
  <div class="rn-card">
    <div class="rn-card-hd"><h3>&#128203; Booking Summary</h3></div>
    <div class="rn-card-bd" style="font-size:13px">
      <table style="width:100%;border-collapse:collapse">
        <tr><td style="padding:4px 0;color:#666;width:140px">Pickup date</td><td style="font-weight:600">${esc(r.pickupDate || '—')}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Return date</td><td style="font-weight:600">${esc(r.returnDate || '—')}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Billing days</td><td style="font-weight:600">${r.billingDays || '—'}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Rental total</td><td style="font-weight:600">$${parseFloat(r.pricing && r.pricing.subtotal || 0).toFixed(2)}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Deposit held</td><td style="font-weight:600">$${parseFloat(r.deposit && r.deposit.amount || 0).toFixed(2)}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Insurance</td><td style="font-weight:600;text-transform:capitalize">${esc(r.insuranceTier || 'basic')}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Odometer at pickup</td><td style="font-weight:600">${odometerPickup ? odometerPickup + ' km' : 'Not recorded'}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Mileage policy</td><td style="font-weight:600;text-transform:capitalize">${policyType}${totalIncluded ? ' (' + totalIncluded + ' km included)' : ''}</td></tr>
        <tr><td style="padding:4px 0;color:#666">Extra km rate</td><td style="font-weight:600">${extraKmRate ? '$' + extraKmRate + '/km' : 'N/A'}</td></tr>
      </table>
    </div>
  </div>
  <div class="rn-card">
    <div class="rn-card-hd"><h3>&#128269; Insurance Cover</h3></div>
    <div class="rn-card-bd" style="font-size:13px">
      ${r.insuranceTier === 'full' ? '<div style="background:#E8F5E9;padding:12px;border-radius:4px;color:#2E7D32;font-weight:700;font-size:14px">&#10003; Full Protection — Zero Excess<br><span style="font-weight:400;font-size:12px">Customer pays nothing for damage</span></div>'
        : r.insuranceTier === 'standard' ? '<div style="background:#E3F2FD;padding:12px;border-radius:4px;color:#1565C0;font-weight:700;font-size:14px">Standard Protection — $800 Excess<br><span style="font-weight:400;font-size:12px">Customer pays up to $800 for damage</span></div>'
        : '<div style="background:#FFF8E1;padding:12px;border-radius:4px;color:#F57F17;font-weight:700;font-size:14px">Basic Cover — $3,000 Excess<br><span style="font-weight:400;font-size:12px">Customer pays up to $3,000 for damage</span></div>'}
      <p style="color:#888;font-size:12px;margin-top:10px">Damage amount entered below will be charged up to the excess limit.</p>
    </div>
  </div>
</div>
<div class="rn-card">
  <div class="rn-card-hd"><h3>&#9998; Return Details — Enter Charges</h3></div>
  <div class="rn-card-bd">
    <form method="POST" action="/api/rental-return-process">
      <input type="hidden" name="t" value="${esc(token)}"/>
      <input type="hidden" name="reservationId" value="${esc(resId)}"/>
      <div class="rn-grid" style="margin-bottom:16px">
        <div class="rn-ff"><label>Actual Return Date/Time</label><input type="datetime-local" name="returnedAt" required/></div>
        <div class="rn-ff"><label>Odometer at Return (km)</label><input type="number" name="odometerReturn" min="0" placeholder="e.g. 46250"/></div>
        <div class="rn-ff"><label>Fuel Missing (litres)</label><input type="number" name="fuelMissingLitres" min="0" step="0.1" placeholder="0 = full tank returned"/></div>
        <div class="rn-ff"><label>Fuel Price per Litre ($)</label><input type="number" name="fuelPricePerLitre" min="0" step="0.01" placeholder="e.g. 2.80"/></div>
        <div class="rn-ff"><label>Fuel Admin Fee ($)</label><input type="number" name="fuelAdminFee" min="0" step="0.01" placeholder="e.g. 15.00"/></div>
        <div class="rn-ff"><label>Late Return Fee ($)</label><input type="number" name="lateFee" min="0" step="0.01" placeholder="0"/></div>
        <div class="rn-ff"><label>Damage Charge ($)</label><input type="number" name="damageAmount" min="0" step="0.01" placeholder="0"/></div>
        <div class="rn-ff" style="grid-column:span 2"><label>Damage Notes</label><input type="text" name="damageNotes" placeholder="e.g. scratch on rear bumper, missing side mirror"/></div>
      </div>
      <div style="background:#E0F2F1;padding:14px;border-radius:6px;margin-bottom:16px;font-size:12.5px;color:#004D40">
        <strong>How deductions work:</strong> The amounts you enter will be subtracted from the deposit ($${parseFloat(r.deposit && r.deposit.amount || 0).toFixed(2)} held). The remainder is released back to the customer.
      </div>
      <div style="display:flex;gap:10px;align-items:center">
        <button type="submit" class="rn-btn rn-btn-g" style="padding:10px 24px;font-size:14px">&#10003; Process Return &amp; Release Deposit</button>
        <a href="/rental-portal/reservations?t=${te}" class="rn-btn rn-btn-n">Cancel</a>
      </div>
    </form>
  </div>
</div>`;
      res.send(rnPage('Process Return', renderRnNav(sess, token, 'reservations'), body));
    })
    .catch((e: any) => res.send(rnPage('Return', renderRnNav(sess, token, 'reservations'), `<div class="rn-notice err">Error: ${esc(e.message)}</div>`)));
});

// ── POST /api/rental-reservation-action ───────────────────────────────────────
router.post('/api/rental-reservation-action', (req: Request, res: Response) => {
  const { t, reservationId, action } = req.body;
  const sess = rnGetSession(t || '');
  const te = encodeURIComponent(t || '');
  if (!sess || !reservationId || !['confirm-pickup', 'cancel'].includes(action)) {
    return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Invalid+request&mt=err');
  }
  const cid = sess.companyId;
  const path = 'rentalReservations/' + cid + '/' + reservationId;
  const updates: any = { status: action === 'cancel' ? 'cancelled' : 'active', updatedAt: Date.now() };
  if (action === 'confirm-pickup') updates['odometer.pickupRecordedAt'] = Date.now();
  fbWrite('PATCH', path, updates, (err: any) => {
    if (err) return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Update+failed&mt=err');
    const msg = action === 'cancel' ? 'Reservation+cancelled' : 'Pickup+confirmed+%E2%80%94+rental+is+now+active';
    res.redirect('/rental-portal/reservations?t=' + te + '&msg=' + msg + '&mt=ok');
  });
});

// ── POST /api/rental-cancel-booking ──────────────────────────────────────────
router.post('/api/rental-cancel-booking', async (req: Request, res: Response) => {
  const { t, reservationId } = req.body;
  const sess = rnGetSession(t || '');
  const te = encodeURIComponent(t || '');
  if (!sess || !reservationId) return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Session+expired&mt=err');
  const cid = sess.companyId;
  try {
    const r = await fbReadP('rentalReservations/' + cid + '/' + reservationId);
    if (!r) return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Reservation+not+found&mt=err');
    if (!['confirmed', 'pending'].includes(r.status)) {
      return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Cannot+cancel+%E2%80%94+status+is+%22' + encodeURIComponent(r.status) + '%22&mt=err');
    }
    const stripe = getStripe();
    let notes = '';
    if (r.rentalPaymentIntentId) {
      try { await stripe.refunds.create({ payment_intent: r.rentalPaymentIntentId }); notes += 'Rental refunded. '; }
      catch (se: any) { notes += 'Refund error: ' + se.message + ' '; console.error('[rental-cancel]', se.message); }
    }
    if (r.deposit && r.deposit.depositPaymentIntentId) {
      try { await stripe.paymentIntents.cancel(r.deposit.depositPaymentIntentId); notes += 'Deposit released.'; }
      catch (se: any) { console.error('[rental-cancel deposit]', se.message); }
    }
    if (r.vehicleId && r.pickupDate && r.returnDate) {
      const avUpdates: Record<string, any> = {};
      let d = new Date(r.pickupDate), end = new Date(r.returnDate);
      while (d < end) { avUpdates['rentalAvailability/' + cid + '/' + r.vehicleId + '/' + d.toISOString().slice(0, 10)] = null; d.setDate(d.getDate() + 1); }
      await fbWriteP('PATCH', '', avUpdates);
    }
    await fbWriteP('PATCH', 'rentalReservations/' + cid + '/' + reservationId, { status: 'cancelled', cancelledAt: Date.now(), cancelledBy: 'owner', cancelNote: notes.trim(), updatedAt: Date.now() });
    console.log('[rental-cancel]', reservationId, '| owner:', cid, '|', notes);
    res.redirect('/rental-portal/reservations?t=' + te + '&msg=' + encodeURIComponent('Reservation cancelled. ' + notes.trim()) + '&mt=ok');
  } catch (e: any) {
    console.error('[rental-cancel-booking]', e.message);
    res.redirect('/rental-portal/reservations?t=' + te + '&msg=' + encodeURIComponent('Error: ' + e.message) + '&mt=err');
  }
});

// ── POST /api/admin/rental-cancel ─────────────────────────────────────────────
router.post('/api/admin/rental-cancel', async (req: Request, res: Response) => {
  const { cid, reservationId } = req.body;
  if (!cid || !reservationId) return res.status(400).json({ error: 'Missing cid or reservationId' });
  try {
    const r = await fbReadP('rentalReservations/' + cid + '/' + reservationId);
    if (!r) return res.status(404).json({ error: 'Reservation not found' });
    if (!['confirmed', 'pending'].includes(r.status)) return res.json({ error: 'Cannot cancel — status is "' + r.status + '"' });
    const stripe = getStripe();
    let notes = '';
    if (r.rentalPaymentIntentId) {
      try { await stripe.refunds.create({ payment_intent: r.rentalPaymentIntentId }); notes += 'Rental refunded. '; }
      catch (se: any) { notes += 'Refund error: ' + se.message + ' '; console.error('[admin-rental-cancel]', se.message); }
    }
    if (r.deposit && r.deposit.depositPaymentIntentId) {
      try { await stripe.paymentIntents.cancel(r.deposit.depositPaymentIntentId); notes += 'Deposit released.'; }
      catch (se: any) { console.error('[admin-rental-cancel deposit]', se.message); }
    }
    if (r.vehicleId && r.pickupDate && r.returnDate) {
      const avUpdates: Record<string, any> = {};
      let d = new Date(r.pickupDate), end = new Date(r.returnDate);
      while (d < end) { avUpdates['rentalAvailability/' + cid + '/' + r.vehicleId + '/' + d.toISOString().slice(0, 10)] = null; d.setDate(d.getDate() + 1); }
      await fbWriteP('PATCH', '', avUpdates);
    }
    await fbWriteP('PATCH', 'rentalReservations/' + cid + '/' + reservationId, { status: 'cancelled', cancelledAt: Date.now(), cancelledBy: 'superadmin', cancelNote: notes.trim(), updatedAt: Date.now() });
    console.log('[admin-rental-cancel]', reservationId, '| cid:', cid, '|', notes);
    res.json({ ok: true, notes: notes.trim() });
  } catch (e: any) {
    console.error('[admin-rental-cancel]', e.message);
    res.status(500).json({ error: e.message });
  }
});

// ── POST /api/rental-return-process ──────────────────────────────────────────
router.post('/api/rental-return-process', async (req: Request, res: Response) => {
  const { t, reservationId, returnedAt, odometerReturn, fuelMissingLitres, fuelPricePerLitre, fuelAdminFee, lateFee, damageAmount, damageNotes } = req.body;
  const sess = rnGetSession(t || '');
  const te = encodeURIComponent(t || '');
  if (!sess || !reservationId) return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Session+expired&mt=err');
  const cid = sess.companyId;
  try {
    const r = await fbReadP('rentalReservations/' + cid + '/' + reservationId);
    if (!r) return res.redirect('/rental-portal/reservations?t=' + te + '&msg=Reservation+not+found&mt=err');
    const v = (await fbReadP('rentalFleet/' + cid + '/' + (r.vehicleId || ''))) || {};
    const odomPickup = (r.odometer && r.odometer.pickup) || 0;
    const odomRet = parseFloat(odometerReturn) || 0;
    const kmUsed = odomRet > odomPickup ? odomRet - odomPickup : 0;
    const policyType = (v.mileagePolicy && v.mileagePolicy.type) || 'unlimited';
    const includedPerDay = parseFloat(v.mileagePolicy && v.mileagePolicy.includedPerDay || 0);
    const extraKmRateVal = parseFloat(v.mileagePolicy && v.mileagePolicy.extraKmRate || 0);
    const totalIncluded = policyType === 'daily' ? (r.billingDays || 1) * includedPerDay : (policyType === 'total' ? includedPerDay : 99999);
    const extraKm = Math.max(0, kmUsed - totalIncluded);
    const extraKmCharge = extraKm > 0 && extraKmRateVal > 0 ? extraKm * extraKmRateVal : 0;
    const fuelLitres = parseFloat(fuelMissingLitres) || 0;
    const fuelRate = parseFloat(fuelPricePerLitre) || 0;
    const fuelAdmin = parseFloat(fuelAdminFee) || 0;
    const fuelCharge = fuelLitres > 0 ? (fuelLitres * fuelRate) + fuelAdmin : 0;
    const late = parseFloat(lateFee) || 0;
    const rawDamage = parseFloat(damageAmount) || 0;
    const excessMap: Record<string, number> = { basic: 3000, standard: 800, full: 0 };
    const maxExcess = excessMap[r.insuranceTier] !== undefined ? excessMap[r.insuranceTier] : 3000;
    const actualDamage = Math.min(rawDamage, maxExcess);
    const totalDeductions = fuelCharge + late + extraKmCharge + actualDamage;
    const depositHeld = parseFloat(r.deposit && r.deposit.amount || 0);
    const depositRelease = Math.max(0, depositHeld - totalDeductions);
    const depositCapture = Math.min(totalDeductions, depositHeld);
    let stripeDepositStatus = totalDeductions <= 0 ? 'released' : 'partial';
    let stripeNote = '';
    const depositPiId = r.deposit && r.deposit.depositPaymentIntentId;
    if (depositPiId) {
      try {
        const stripe = getStripe();
        if (depositCapture > 0) {
          await stripe.paymentIntents.capture(depositPiId, { amount_to_capture: Math.round(depositCapture * 100) });
          stripeDepositStatus = 'captured';
          stripeNote = `Stripe captured $${depositCapture.toFixed(2)} of deposit`;
        } else {
          await stripe.paymentIntents.cancel(depositPiId);
          stripeDepositStatus = 'released';
          stripeNote = 'Stripe deposit authorization cancelled (full release)';
        }
        console.log('[rental-return] Stripe deposit:', stripeNote, '| PI:', depositPiId);
      } catch (stripeErr: any) {
        console.error('[rental-return] Stripe error:', stripeErr.message);
        stripeNote = 'Stripe error: ' + stripeErr.message;
        stripeDepositStatus = 'stripe_error';
      }
    }
    const updates: any = {
      status: 'completed', updatedAt: Date.now(),
      returnedAt: returnedAt || new Date().toISOString(),
      'odometer.return': odomRet, 'odometer.kmUsed': kmUsed,
      deductions: { fuelShortfall: fuelCharge, lateFee: late, extraKm: extraKmCharge, damage: actualDamage },
      deductionTotal: totalDeductions, depositCapture, depositRelease,
      damageNotes: damageNotes || '',
      'deposit.status': stripeDepositStatus, 'deposit.stripeNote': stripeNote
    };
    await fbWriteP('PATCH', 'rentalReservations/' + cid + '/' + reservationId, updates);
    if (r.vehicleId && r.pickupDate && r.returnDate) {
      const avUpdates: Record<string, any> = {};
      const d = new Date(r.pickupDate), end = new Date(r.returnDate);
      while (d <= end) { avUpdates['rentalAvailability/' + cid + '/' + r.vehicleId + '/' + d.toISOString().slice(0, 10)] = null; d.setDate(d.getDate() + 1); }
      fbWrite('PATCH', '', avUpdates, () => {});
    }
    const stripeMsg = depositPiId ? (stripeNote ? ' | ' + stripeNote : '') : ' (no Stripe PI on record)';
    const msg = encodeURIComponent(`Return processed. Deductions: $${totalDeductions.toFixed(2)}. Deposit release: $${depositRelease.toFixed(2)}${stripeMsg}`);
    res.redirect('/rental-portal/reservations?t=' + te + '&msg=' + msg + '&mt=ok');
  } catch (e: any) {
    console.error('[rental-return-process]', e.message);
    res.redirect('/rental-portal/reservations?t=' + te + '&msg=' + encodeURIComponent('Error: ' + e.message) + '&mt=err');
  }
});

// ── Rental Portal — Fleet ─────────────────────────────────────────────────────
router.get('/rental-portal/fleet', requireRentalAuth, (req: any, res: Response) => {
  const sess = req.rnSession, token = req.rnToken;
  const te = encodeURIComponent(token);
  const cid = sess.companyId;
  const msg = (req.query.msg as string) || '', mt = (req.query.mt as string) || '';
  const editId = (req.query.edit as string) || '';
  fbReadP('rentalFleet/' + cid).then((fleet: any) => {
    const fl = fleet || {};
    const vehicles = Object.entries(fl);
    const noticeHtml = msg ? `<div class="rn-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
    const editV: any = editId ? (fl[editId] || {}) : {};
    const cats = ['Economy', 'Compact', 'Standard', 'SUV', '4WD', 'Luxury', 'People Mover', 'Ute/Truck'];
    const statuses = ['available', 'maintenance', 'retired'];
    function sel(arr: string[], cur: string, nm: string) {
      return `<select name="${nm}">` + arr.map(o => `<option value="${o}" ${o === cur ? 'selected' : ''}>${o}</option>`).join('') + '</select>';
    }
    const formBody = `<div class="rn-card">
  <div class="rn-card-hd"><h3>${editId ? '&#9998; Edit Vehicle' : '&#43; Add New Vehicle'}</h3>
    ${editId ? `<a href="/rental-portal/fleet?t=${te}" class="rn-btn rn-btn-n" style="font-size:12px">Cancel Edit</a>` : ''}</div>
  <div class="rn-card-bd">
    <form method="POST" action="/api/rental-fleet-save">
      <input type="hidden" name="t" value="${esc(token)}"/>
      <input type="hidden" name="vehicleId" value="${esc(editId)}"/>
      <div class="rn-section-hdr">Vehicle Details</div>
      <div class="rn-grid" style="padding:14px 0">
        <div class="rn-ff"><label>Make</label><input type="text" name="make" value="${esc(editV.make || '')}" required/></div>
        <div class="rn-ff"><label>Model</label><input type="text" name="model" value="${esc(editV.model || '')}" required/></div>
        <div class="rn-ff"><label>Year</label><input type="number" name="year" value="${esc(String(editV.year || ''))}" min="1990" max="2030"/></div>
        <div class="rn-ff"><label>Colour</label><input type="text" name="colour" value="${esc(editV.colour || '')}"/></div>
        <div class="rn-ff"><label>Registration</label><input type="text" name="rego" value="${esc(editV.rego || '')}"/></div>
        <div class="rn-ff"><label>Category</label>${sel(cats, editV.category || 'Economy', 'category')}</div>
        <div class="rn-ff"><label>Seats</label><input type="number" name="seats" value="${esc(String(editV.seats || 5))}" min="2" max="20"/></div>
        <div class="rn-ff"><label>Transmission</label><select name="transmission"><option value="automatic" ${(editV.transmission || 'automatic') === 'automatic' ? 'selected' : ''}>Automatic</option><option value="manual" ${editV.transmission === 'manual' ? 'selected' : ''}>Manual</option></select></div>
        <div class="rn-ff"><label>Status</label>${sel(statuses, editV.status || 'available', 'status')}</div>
        <div class="rn-ff"><label>Minimum Driver Age</label><input type="number" name="minDriverAge" value="${esc(String(editV.minDriverAge || 21))}" min="16" max="30"/></div>
      </div>
      <div class="rn-section-hdr">Pricing</div>
      <div class="rn-grid" style="padding:14px 0">
        <div class="rn-ff"><label>Daily Rate ($)</label><input type="number" name="pricePerDay" value="${esc(String(editV.pricePerDay || ''))}" step="0.01" min="0" required/></div>
        <div class="rn-ff"><label>Hourly Rate ($)</label><input type="number" name="pricePerHour" value="${esc(String(editV.pricePerHour || ''))}" step="0.01" min="0"/></div>
        <div class="rn-ff"><label>Weekly Rate ($)</label><input type="number" name="pricePerWeek" value="${esc(String(editV.pricePerWeek || ''))}" step="0.01" min="0"/></div>
        <div class="rn-ff"><label>Deposit Amount ($)</label><input type="number" name="depositAmount" value="${esc(String(editV.depositAmount || ''))}" step="0.01" min="0" required/></div>
      </div>
      <div class="rn-section-hdr">Mileage Policy</div>
      <div class="rn-grid" style="padding:14px 0">
        <div class="rn-ff"><label>Mileage Policy</label>
          <select name="mileageType">
            <option value="unlimited" ${(editV.mileagePolicy && editV.mileagePolicy.type || 'unlimited') === 'unlimited' ? 'selected' : ''}>Unlimited km</option>
            <option value="daily" ${(editV.mileagePolicy && editV.mileagePolicy.type) === 'daily' ? 'selected' : ''}>Daily km limit</option>
            <option value="total" ${(editV.mileagePolicy && editV.mileagePolicy.type) === 'total' ? 'selected' : ''}>Total km cap</option>
          </select>
        </div>
        <div class="rn-ff"><label>Included km</label><input type="number" name="includedKm" value="${esc(String(editV.mileagePolicy && editV.mileagePolicy.includedPerDay || ''))}" min="0"/></div>
        <div class="rn-ff"><label>Extra km Rate ($/km)</label><input type="number" name="extraKmRate" value="${esc(String(editV.mileagePolicy && editV.mileagePolicy.extraKmRate || ''))}" step="0.01" min="0"/></div>
      </div>
      <div class="rn-section-hdr">Vehicle Photo</div>
      <div style="padding:14px 0 8px">
        <div class="rn-ff"><label>Photo URL</label>
          <input type="url" name="imageUrl" value="${esc(editV.imageUrl || '')}" placeholder="https://example.com/car.jpg" style="font-family:monospace;font-size:12px"/>
          ${editV.imageUrl ? `<div style="margin-top:8px"><img src="${esc(editV.imageUrl)}" alt="Preview" style="height:80px;border-radius:4px;object-fit:cover;border:1px solid #e0e0e0"/></div>` : ''}
        </div>
      </div>
      <div style="padding-top:8px;display:flex;gap:10px">
        <button type="submit" class="rn-btn rn-btn-g" style="padding:10px 24px">&#10003; ${editId ? 'Save Changes' : 'Add Vehicle'}</button>
        <a href="/rental-portal/fleet?t=${te}" class="rn-btn rn-btn-n">Cancel</a>
      </div>
    </form>
  </div>
</div>`;
    const vehicleRows = vehicles.map(([vid, v]: any) => {
      const miles = v.mileagePolicy ? (v.mileagePolicy.type === 'unlimited' ? 'Unlimited' : `${v.mileagePolicy.includedPerDay || 0} km/day, $${v.mileagePolicy.extraKmRate || 0}/km`) : 'Unlimited';
      return `<tr>
<td style="font-weight:700">${esc(v.make || '—')} ${esc(v.model || '')}</td>
<td>${esc(v.year || '—')}</td>
<td>${esc(v.rego || '—')}</td>
<td>${esc(v.category || '—')}</td>
<td style="text-align:center">${v.seats || '—'}</td>
<td style="font-weight:700">$${parseFloat(v.pricePerDay || 0).toFixed(2)}/day</td>
<td>$${parseFloat(v.depositAmount || 0).toFixed(2)}</td>
<td style="font-size:11px">${esc(miles)}</td>
<td>${rnVehicleBadge(v.status)}</td>
<td style="white-space:nowrap">
  <a href="/rental-portal/fleet?t=${te}&edit=${esc(vid)}" class="rn-btn rn-btn-n" style="font-size:11px;padding:4px 8px;margin-right:4px">&#9998; Edit</a>
  <form method="POST" action="/api/rental-fleet-delete" style="display:inline" onsubmit="return confirm('Delete ${esc(v.make || '')} ${esc(v.model || '')}?')">
    <input type="hidden" name="t" value="${esc(token)}"/><input type="hidden" name="vehicleId" value="${esc(vid)}"/>
    <button type="submit" class="rn-btn rn-btn-r" style="font-size:11px;padding:4px 8px">&#10005;</button>
  </form>
</td></tr>`;
    }).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#00695C;margin-bottom:16px">&#128663; Fleet Management (${vehicles.length} vehicle${vehicles.length !== 1 ? 's' : ''})</h2>
${noticeHtml}${formBody}
<div class="rn-card" style="overflow-x:auto">
  <div class="rn-card-hd"><h3>&#128663; Your Fleet</h3></div>
  ${vehicles.length ? `<table class="rn-tbl"><thead><tr><th>Vehicle</th><th>Year</th><th>Rego</th><th>Category</th><th>Seats</th><th>Daily Rate</th><th>Deposit</th><th>Mileage</th><th>Status</th><th>Actions</th></tr></thead><tbody>${vehicleRows}</tbody></table>` : '<div class="rn-empty">No vehicles yet. Add your first vehicle above.</div>'}
</div>`;
    res.send(rnPage('Fleet', renderRnNav(sess, token, 'fleet'), body));
  }).catch((e: any) => res.send(rnPage('Fleet', renderRnNav(sess, token, 'fleet'), `<div class="rn-notice err">Error: ${esc(e.message)}</div>`)));
});

router.post('/api/rental-fleet-save', (req: Request, res: Response) => {
  const { t, vehicleId, make, model, year, colour, rego, category, seats, transmission, status, minDriverAge, pricePerDay, pricePerHour, pricePerWeek, depositAmount, mileageType, includedKm, extraKmRate } = req.body;
  const sess = rnGetSession(t || '');
  const te = encodeURIComponent(t || '');
  if (!sess) return res.redirect('/rental-portal/fleet?t=' + te + '&msg=Session+expired&mt=err');
  if (!make || !model || !pricePerDay || !depositAmount) return res.redirect('/rental-portal/fleet?t=' + te + '&msg=Please+fill+all+required+fields&mt=err');
  const cid = sess.companyId;
  const data: any = {
    make: make.trim(), model: model.trim(), year: parseInt(year) || 0, colour: (colour || '').trim(), rego: (rego || '').trim().toUpperCase(),
    category, seats: parseInt(seats) || 5, transmission: transmission || 'automatic',
    status: status || 'available', minDriverAge: parseInt(minDriverAge) || 21,
    pricePerDay: parseFloat(pricePerDay), depositAmount: parseFloat(depositAmount),
    mileagePolicy: { type: mileageType || 'unlimited', includedPerDay: parseFloat(includedKm) || 0, extraKmRate: parseFloat(extraKmRate) || 0 },
    updatedAt: Date.now()
  };
  if (pricePerHour) data.pricePerHour = parseFloat(pricePerHour);
  if (pricePerWeek) data.pricePerWeek = parseFloat(pricePerWeek);
  if (req.body.imageUrl && req.body.imageUrl.trim()) data.imageUrl = req.body.imageUrl.trim();
  if (!vehicleId) data.createdAt = Date.now();
  const vid = vehicleId || ('V' + Date.now());
  fbWrite(vehicleId ? 'PATCH' : 'PUT', 'rentalFleet/' + cid + '/' + vid, data, (err: any) => {
    if (err) return res.redirect('/rental-portal/fleet?t=' + te + '&msg=Save+failed&mt=err');
    const msg = vehicleId ? 'Vehicle+updated' : encodeURIComponent(`${make} ${model} added`);
    res.redirect('/rental-portal/fleet?t=' + te + '&msg=' + msg + '&mt=ok');
  });
});

router.post('/api/rental-fleet-delete', (req: Request, res: Response) => {
  const { t, vehicleId } = req.body;
  const sess = rnGetSession(t || '');
  const te = encodeURIComponent(t || '');
  if (!sess || !vehicleId) return res.redirect('/rental-portal/fleet?t=' + te + '&msg=Invalid+request&mt=err');
  fbWrite('DELETE', 'rentalFleet/' + sess.companyId + '/' + vehicleId, null, (err: any) => {
    if (err) return res.redirect('/rental-portal/fleet?t=' + te + '&msg=Delete+failed&mt=err');
    res.redirect('/rental-portal/fleet?t=' + te + '&msg=Vehicle+removed&mt=ok');
  });
});

// ── Rental Portal — Availability Calendar ─────────────────────────────────────
router.get('/rental-portal/availability', requireRentalAuth, (req: any, res: Response) => {
  const sess = req.rnSession, token = req.rnToken;
  const te = encodeURIComponent(token);
  const cid = sess.companyId;
  const msg = (req.query.msg as string) || '', mt = (req.query.mt as string) || '';
  const selectedVehicle = (req.query.vid as string) || '';
  const monthParam = (req.query.month as string) || new Date().toISOString().slice(0, 7);
  Promise.all([fbReadP('rentalFleet/' + cid), fbReadP('rentalAvailability/' + cid)])
    .then(([fleet, avail]) => {
      const fl = fleet || {};
      const av = avail || {};
      const noticeHtml = msg ? `<div class="rn-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
      const vehicleOpts = Object.entries(fl).map(([vid, v]: any) =>
        `<option value="${esc(vid)}" ${vid === selectedVehicle ? 'selected' : ''}>${esc(v.make || '')} ${esc(v.model || '')} — ${esc(v.rego || vid)}</option>`
      ).join('');
      let calHtml = '';
      if (selectedVehicle && fl[selectedVehicle]) {
        const vAv: any = av[selectedVehicle] || {};
        const [yr, mo] = monthParam.split('-').map(Number);
        const firstDay = new Date(yr, mo - 1, 1);
        const lastDay = new Date(yr, mo, 0);
        const startWeekday = firstDay.getDay();
        const today = new Date().toISOString().slice(0, 10);
        const prevMonth = new Date(yr, mo - 2, 1).toISOString().slice(0, 7);
        const nextMonth = new Date(yr, mo, 1).toISOString().slice(0, 7);
        let cal = '<div class="cal-grid">';
        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].forEach(d => { cal += `<div class="cal-hdr">${d}</div>`; });
        for (let i = 0; i < startWeekday; i++) cal += '<div></div>';
        for (let d = 1; d <= lastDay.getDate(); d++) {
          const dateStr = `${yr}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
          const blocked = vAv[dateStr] === 'blocked';
          const past = dateStr < today;
          const cls = ['cal-day', blocked ? 'blocked' : '', dateStr === today ? 'today' : '', past ? 'past' : ''].filter(Boolean).join(' ');
          const action = !past ? `onclick="toggleDay('${esc(selectedVehicle)}','${dateStr}',${blocked})"` : '';
          cal += `<div class="${cls}" title="${dateStr}" ${action}>${d}</div>`;
        }
        cal += '</div>';
        const moName = firstDay.toLocaleString('en', { month: 'long', year: 'numeric' });
        calHtml = `<div class="rn-card">
  <div class="rn-card-hd" style="justify-content:space-between">
    <h3>&#128197; ${moName} — ${esc((fl[selectedVehicle] as any).make || '')} ${esc((fl[selectedVehicle] as any).model || '')} (${esc((fl[selectedVehicle] as any).rego || selectedVehicle)})</h3>
    <div style="display:flex;gap:8px">
      <a href="/rental-portal/availability?t=${te}&vid=${esc(selectedVehicle)}&month=${prevMonth}" class="rn-btn rn-btn-n" style="font-size:12px">&#8592; Prev</a>
      <a href="/rental-portal/availability?t=${te}&vid=${esc(selectedVehicle)}&month=${nextMonth}" class="rn-btn rn-btn-n" style="font-size:12px">Next &#8594;</a>
    </div>
  </div>
  <div class="rn-card-bd">
    <div style="font-size:12px;color:#888;margin-bottom:10px">Click a date to block/unblock it. <span style="background:#FFCDD2;color:#C62828;padding:2px 8px;border-radius:4px;font-weight:700">Blocked</span> = not available for new bookings.</div>
    ${cal}
  </div>
</div>
<script>
function toggleDay(vid, date, isBlocked) {
  fetch('/api/rental-availability-set', { method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ t: ${JSON.stringify(token)}, vehicleId: vid, date, blocked: !isBlocked })
  }).then(r=>r.json()).then(d => { if(d.ok) location.reload(); else alert('Error: ' + (d.error||'Unknown')); });
}
</script>`;
      }
      const body = `<h2 style="font-size:18px;font-weight:700;color:#00695C;margin-bottom:16px">&#128197; Availability Calendar</h2>
${noticeHtml}
<div class="rn-card">
  <div class="rn-card-hd"><h3>Select Vehicle</h3></div>
  <div class="rn-card-bd">
    <form method="GET" action="/rental-portal/availability" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap">
      <input type="hidden" name="t" value="${esc(token)}"/>
      <input type="hidden" name="month" value="${esc(monthParam)}"/>
      <select name="vid" style="padding:8px 12px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:240px">
        <option value="">— Select a vehicle —</option>
        ${vehicleOpts}
      </select>
      <button type="submit" class="rn-btn rn-btn-g">View Calendar</button>
    </form>
    ${!Object.keys(fl).length ? '<p style="color:#aaa;font-size:13px;margin-top:10px">Add vehicles in Fleet management first.</p>' : ''}
  </div>
</div>
${calHtml}`;
      res.send(rnPage('Availability', renderRnNav(sess, token, 'availability'), body));
    })
    .catch((e: any) => res.send(rnPage('Availability', renderRnNav(sess, token, 'availability'), `<div class="rn-notice err">Error: ${esc(e.message)}</div>`)));
});

router.post('/api/rental-availability-set', (req: Request, res: Response) => {
  const { t, vehicleId, date, blocked } = req.body;
  const sess = rnGetSession(t || '');
  if (!sess || !vehicleId || !date) return res.json({ error: 'Invalid request' });
  const path = 'rentalAvailability/' + sess.companyId + '/' + vehicleId + '/' + date;
  if (blocked) {
    fbWrite('PUT', path, 'blocked', (err: any) => err ? res.json({ error: String(err) }) : res.json({ ok: true }));
  } else {
    fbWrite('DELETE', path, null, (err: any) => err ? res.json({ error: String(err) }) : res.json({ ok: true }));
  }
});

// ── Rental Portal — Config ────────────────────────────────────────────────────
router.get('/rental-portal/config', requireRentalAuth, (req: any, res: Response) => {
  const sess = req.rnSession, token = req.rnToken;
  const te = encodeURIComponent(token);
  const cid = sess.companyId;
  const msg = (req.query.msg as string) || '', mt = (req.query.mt as string) || '';
  Promise.all([
    fbReadP('rentalPolicy/' + cid),
    fbReadP('rentalLocations/' + cid),
    fbReadP('rentalAddons/' + cid),
    fbReadP('rentalInsurance/' + cid)
  ]).then(([policy, locations, addons, insurance]) => {
    const p = policy || {};
    const l = locations || {};
    const a = addons || {};
    const ins = insurance || {};
    const noticeHtml = msg ? `<div class="rn-notice ${mt === 'ok' ? 'ok' : 'err'}">${esc(decodeURIComponent(msg))}</div>` : '';
    function fv(obj: any, key: string, def: any = '') { const v = obj[key]; return v !== undefined ? v : def; }
    const locRows = Object.entries(l).map(([lid, loc]: any) =>
      `<tr><td>${esc(loc.name || '—')}</td><td>${esc(loc.address || '—')}</td><td style="font-weight:600">${loc.surcharge >= 0 ? '$' + parseFloat(loc.surcharge || 0).toFixed(2) : '—'}</td>
<td style="font-size:11px">${esc(loc.pickupHours || '—')}</td>
<td><form method="POST" action="/api/rental-location-delete" style="display:inline">
<input type="hidden" name="t" value="${esc(token)}"/><input type="hidden" name="locationId" value="${esc(lid)}"/>
<button type="submit" class="rn-btn rn-btn-r" style="font-size:11px;padding:3px 8px" onclick="return confirm('Delete location?')">&#10005;</button></form></td></tr>`
    ).join('');
    const addonDefs: [string, string, string][] = [
      ['additionalDriver', 'Additional Driver', 'perDay'], ['youngDriver', 'Young Driver (<25 yrs)', 'perDay'],
      ['gps', 'GPS / Satnav', 'perDay'], ['childSeat', 'Child Seat', 'perDay'], ['boosterSeat', 'Booster Seat', 'perDay'],
      ['roofRack', 'Roof Rack', 'flat'], ['snowChains', 'Snow Chains', 'flat']
    ];
    const addonRows = addonDefs.map(([key, label, ptype]) => {
      const ao: any = a[key] || {};
      const pkey = ptype === 'flat' ? 'priceFlat' : 'pricePerDay';
      return `<tr>
<td style="font-weight:600">${label}</td>
<td><select name="addon_${key}_enabled" style="width:80px"><option value="true" ${ao.enabled !== false ? 'selected' : ''}>On</option><option value="false" ${ao.enabled === false ? 'selected' : ''}>Off</option></select></td>
<td><input type="number" name="addon_${key}_price" value="${esc(String(ao[pkey] || ''))}" step="0.01" min="0" placeholder="$ amount" style="width:100px"/></td>
<td style="font-size:12px;color:#888">${ptype === 'flat' ? 'Flat / booking' : 'Per day'}</td></tr>`;
    }).join('');
    const insTiers: [string, string, string, string][] = [
      ['basic', 'Basic (included, $0)', '#FFF8E1', '#E65100'],
      ['standard', 'Standard Protection', '#E3F2FD', '#1565C0'],
      ['full', 'Full / Zero Excess', '#E8F5E9', '#2E7D32']
    ];
    const insTierRows = insTiers.map(([tier, label, bg, col]) => {
      const t2: any = ins[tier] || {};
      return `<div style="background:${bg};border-radius:8px;padding:14px">
<div style="font-weight:700;color:${col};margin-bottom:10px">${label}</div>
<div class="rn-ff" style="margin-bottom:8px"><label>Excess Amount ($)</label><input type="number" name="ins_${tier}_excess" value="${esc(String(t2.excess !== undefined ? t2.excess : tier === 'basic' ? 3000 : tier === 'standard' ? 800 : 0))}" min="0" step="1"/></div>
<div class="rn-ff" style="margin-bottom:8px"><label>Price per Day ($)</label><input type="number" name="ins_${tier}_price" value="${esc(String(t2.pricePerDay !== undefined ? t2.pricePerDay : tier === 'basic' ? 0 : ''))}" min="0" step="0.01" ${tier === 'basic' ? 'readonly style="background:#f5f5f5"' : ''}/></div>
<div class="rn-ff"><label>What's covered</label><input type="text" name="ins_${tier}_covers" value="${esc((t2.covers || []).join(', '))}" placeholder="e.g. third party, windscreen"/></div>
</div>`;
    }).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#00695C;margin-bottom:16px">&#9881; Rental Configuration</h2>
${noticeHtml}
<form method="POST" action="/api/rental-config-save">
<input type="hidden" name="t" value="${esc(token)}"/><input type="hidden" name="section" value="policy"/>
<div class="rn-card">
  <div class="rn-card-hd"><h3>&#128179; Billing &amp; Time Policy</h3><button type="submit" class="rn-btn rn-btn-g" style="font-size:12px">&#10003; Save</button></div>
  <div class="rn-card-bd">
    <div class="rn-grid" style="margin-bottom:14px">
      <div class="rn-ff"><label>Min Rental Period</label>
        <select name="minPeriod"><option value="hourly" ${fv(p,'minPeriod')==='hourly'?'selected':''}>Hourly</option><option value="halfday" ${fv(p,'minPeriod')==='halfday'?'selected':''}>Half day</option><option value="daily" ${'daily'===fv(p,'minPeriod','daily')?'selected':''}>Full day</option></select></div>
      <div class="rn-ff"><label>Fuel Policy</label>
        <select name="fuelPolicy"><option value="full-to-full" ${fv(p,'fuelPolicy','full-to-full')==='full-to-full'?'selected':''}>Full-to-Full</option><option value="prepurchase" ${fv(p,'fuelPolicy')==='prepurchase'?'selected':''}>Pre-purchase</option><option value="inclusive" ${fv(p,'fuelPolicy')==='inclusive'?'selected':''}>Fuel Inclusive</option></select></div>
      <div class="rn-ff"><label>Mileage Unit</label>
        <select name="mileageUnit"><option value="km" ${fv(p,'mileageUnit','km')==='km'?'selected':''}>Kilometres</option><option value="miles" ${fv(p,'mileageUnit')==='miles'?'selected':''}>Miles</option></select></div>
    </div>
    <div class="rn-section-hdr">Late Return Penalties</div>
    <div class="rn-grid" style="padding:14px 0">
      <div class="rn-ff"><label>Grace Period (minutes)</label><input type="number" name="graceMins" value="${esc(String(fv(p,'graceMins',30)))}" min="0"/></div>
      <div class="rn-ff"><label>Hourly Late Fee ($/hr)</label><input type="number" name="lateHourlyRate" value="${esc(String(fv(p,'lateHourlyRate',20)))}" min="0" step="0.01"/></div>
      <div class="rn-ff"><label>Full Day Threshold (hours late)</label><input type="number" name="fullDayThresholdHrs" value="${esc(String(fv(p,'fullDayThresholdHrs',3)))}" min="1"/></div>
    </div>
    <div class="rn-section-hdr">Early Return &amp; Cancellation</div>
    <div class="rn-grid" style="padding:14px 0">
      <div class="rn-ff"><label>Early Return Policy</label>
        <select name="earlyReturnPolicy"><option value="no-refund" ${fv(p,'earlyReturnPolicy','no-refund')==='no-refund'?'selected':''}>No refund for unused days</option><option value="full-days" ${fv(p,'earlyReturnPolicy')==='full-days'?'selected':''}>Refund unused full days</option><option value="full-refund" ${fv(p,'earlyReturnPolicy')==='full-refund'?'selected':''}>Full refund</option></select></div>
      <div class="rn-ff"><label>Free Cancellation (hours before pickup)</label><input type="number" name="freeCancelHrs" value="${esc(String(fv(p,'freeCancelHrs',48)))}" min="0"/></div>
      <div class="rn-ff"><label>Late Cancel Fee ($)</label><input type="number" name="lateCancelFee" value="${esc(String(fv(p,'lateCancelFee',50)))}" min="0" step="0.01"/></div>
    </div>
  </div>
</div>
</form>
<form method="POST" action="/api/rental-config-save">
<input type="hidden" name="t" value="${esc(token)}"/><input type="hidden" name="section" value="addons"/>
<div class="rn-card">
  <div class="rn-card-hd"><h3>&#10133; Add-ons &amp; Extras</h3><button type="submit" class="rn-btn rn-btn-g" style="font-size:12px">&#10003; Save</button></div>
  <div class="rn-card-bd">
    <table class="rn-tbl" style="margin-bottom:14px"><thead><tr><th>Add-on</th><th>Enabled</th><th>Price</th><th>Type</th></tr></thead><tbody>${addonRows}</tbody></table>
  </div>
</div>
</form>
<form method="POST" action="/api/rental-config-save">
<input type="hidden" name="t" value="${esc(token)}"/><input type="hidden" name="section" value="insurance"/>
<div class="rn-card">
  <div class="rn-card-hd"><h3>&#127794; Insurance Tiers</h3><button type="submit" class="rn-btn rn-btn-g" style="font-size:12px">&#10003; Save</button></div>
  <div class="rn-card-bd"><div class="rn-grid-3" style="margin-bottom:14px">${insTierRows}</div></div>
</div>
</form>
<div class="rn-card">
  <div class="rn-card-hd"><h3>&#128205; Pickup Locations</h3></div>
  <div class="rn-card-bd">
    <form method="POST" action="/api/rental-location-add" style="margin-bottom:16px">
      <input type="hidden" name="t" value="${esc(token)}"/>
      <div class="rn-grid" style="margin-bottom:10px">
        <div class="rn-ff"><label>Location Name</label><input type="text" name="name" placeholder="e.g. Airport Branch" required/></div>
        <div class="rn-ff"><label>Address</label><input type="text" name="address" placeholder="e.g. 123 Airport Rd" required/></div>
        <div class="rn-ff"><label>Pickup Hours</label><input type="text" name="pickupHours" placeholder="e.g. Mon–Fri 8am–5pm"/></div>
        <div class="rn-ff"><label>Surcharge ($)</label><input type="number" name="surcharge" step="0.01" placeholder="0"/></div>
        <div class="rn-ff"><label>One-Way Fee ($)</label><input type="number" name="oneWayFee" step="0.01" placeholder="0"/></div>
      </div>
      <button type="submit" class="rn-btn rn-btn-g" style="font-size:12px">&#43; Add Location</button>
    </form>
    ${Object.keys(l).length ? `<table class="rn-tbl"><thead><tr><th>Name</th><th>Address</th><th>Surcharge</th><th>Hours</th><th>Remove</th></tr></thead><tbody>${locRows}</tbody></table>` : '<div class="rn-empty">No locations yet.</div>'}
  </div>
</div>`;
    res.send(rnPage('Config', renderRnNav(sess, token, 'config'), body));
  }).catch((e: any) => res.send(rnPage('Config', renderRnNav(sess, token, 'config'), `<div class="rn-notice err">Error: ${esc(e.message)}</div>`)));
});

router.post('/api/rental-config-save', (req: Request, res: Response) => {
  const sess = rnGetSession(req.body.t || '');
  const te = encodeURIComponent(req.body.t || '');
  if (!sess) return res.redirect('/rental-portal/config?t=' + te + '&msg=Session+expired&mt=err');
  const cid = sess.companyId;
  const { section } = req.body;
  let path: string, data: any;
  if (section === 'policy') {
    path = 'rentalPolicy/' + cid;
    data = {
      minPeriod: req.body.minPeriod || 'daily', fuelPolicy: req.body.fuelPolicy || 'full-to-full',
      mileageUnit: req.body.mileageUnit || 'km', graceMins: parseInt(req.body.graceMins) || 30,
      lateHourlyRate: parseFloat(req.body.lateHourlyRate) || 20, fullDayThresholdHrs: parseInt(req.body.fullDayThresholdHrs) || 3,
      earlyReturnPolicy: req.body.earlyReturnPolicy || 'no-refund', freeCancelHrs: parseInt(req.body.freeCancelHrs) || 48,
      lateCancelFee: parseFloat(req.body.lateCancelFee) || 0, updatedAt: Date.now()
    };
  } else if (section === 'addons') {
    path = 'rentalAddons/' + cid;
    const addonKeys = ['additionalDriver', 'youngDriver', 'gps', 'childSeat', 'boosterSeat', 'roofRack', 'snowChains'];
    const flatKeys = ['roofRack', 'snowChains'];
    data = {};
    addonKeys.forEach(k => {
      const pkey = flatKeys.includes(k) ? 'priceFlat' : 'pricePerDay';
      data[k] = { enabled: req.body['addon_' + k + '_enabled'] === 'true', [pkey]: parseFloat(req.body['addon_' + k + '_price']) || 0 };
    });
  } else if (section === 'insurance') {
    path = 'rentalInsurance/' + cid;
    data = {};
    ['basic', 'standard', 'full'].forEach(tier => {
      const coversStr = req.body['ins_' + tier + '_covers'] || '';
      data[tier] = {
        excess: parseFloat(req.body['ins_' + tier + '_excess']) || 0,
        pricePerDay: parseFloat(req.body['ins_' + tier + '_price']) || 0,
        covers: coversStr ? coversStr.split(',').map((s: string) => s.trim()).filter(Boolean) : []
      };
    });
  } else {
    return res.redirect('/rental-portal/config?t=' + te + '&msg=Invalid+section&mt=err');
  }
  fbWrite('PUT', path, data, (err: any) => {
    if (err) return res.redirect('/rental-portal/config?t=' + te + '&msg=Save+failed&mt=err');
    res.redirect('/rental-portal/config?t=' + te + '&msg=Saved+successfully&mt=ok');
  });
});

// ── Rental Portal — Taxi Requests ─────────────────────────────────────────────
router.get('/rental-portal/taxi-requests', requireRentalAuth, async (req: any, res: Response) => {
  const sess = req.rnSession, token = req.rnToken;
  const te = encodeURIComponent(token);
  try {
    const [taxiSnap, promosSnap, allbookings] = await Promise.all([
      fbReadP('rentalTaxiRequests'),
      fbReadP('rentalPromos'),
      fbReadP('allbookings/' + sess.companyId)
    ]);
    const allTaxi = taxiSnap || {};
    const allPromos = promosSnap || {};
    const myJobs = new Set(Object.keys(allbookings || {}));
    const requests: any[] = Object.values(allTaxi)
      .filter((r: any) => {
        if (!r.promoCode) return true;
        const promo = allPromos[r.promoCode];
        return promo && myJobs.has(promo.rentalJobId);
      })
      .sort((a: any, b: any) => (b.createdAt || 0) - (a.createdAt || 0));
    const fmtDt = (ts: any) => ts ? new Date(ts).toLocaleString('en-NZ', { dateStyle: 'short', timeStyle: 'short' } as any) : '—';
    const statusBadge = (s: string) => {
      const c: Record<string, string> = { pending: '#F57F17', confirmed: '#2E7D32', completed: '#00695C', cancelled: '#C62828' };
      return `<span style="background:${c[s] || '#888'};color:#fff;padding:2px 10px;border-radius:12px;font-size:11px;font-weight:700;text-transform:capitalize">${esc(s || 'pending')}</span>`;
    };
    const rows = requests.map((r: any) => `<tr>
  <td style="font-family:monospace;font-weight:700;font-size:12px;color:#00695C">${esc(r.requestId || '—')}</td>
  <td style="font-weight:600">${esc(r.customerName || '—')}</td>
  <td>${esc(r.customerPhone || '—')}</td>
  <td style="font-size:12px">${esc(r.pickup || '—')}</td>
  <td style="font-size:12px">${esc(r.destination || '—')}</td>
  <td style="font-size:12px">${fmtDt(r.scheduledAt ? new Date(r.scheduledAt).getTime() : 0)}</td>
  <td>${r.promoCode ? `<span style="font-family:monospace;font-weight:700;color:#1B5E20">${esc(r.promoCode)}</span>` : '<span style="color:#aaa">—</span>'}</td>
  <td>${r.discountPercent ? `<span style="color:#2E7D32;font-weight:700">${r.discountPercent}% off</span>` : '—'}</td>
  <td>${statusBadge(r.status)}</td>
  <td style="font-size:11px;color:#888">${fmtDt(r.createdAt)}</td>
</tr>`).join('');
    const body = `<h2 style="font-size:18px;font-weight:700;color:#00695C;margin-bottom:16px">&#128664; Taxi Ride Requests (${requests.length})</h2>
<p style="font-size:13px;color:#888;margin-bottom:20px">Customers who used their Ride-to-Rental discount code to book a taxi ride to your pickup location.</p>
<div class="rn-card" style="overflow-x:auto">
  ${requests.length ? `<table class="rn-tbl">
  <thead><tr><th>Ref</th><th>Customer</th><th>Phone</th><th>Pickup From</th><th>Coming To</th><th>Scheduled</th><th>Promo Code</th><th>Discount</th><th>Status</th><th>Submitted</th></tr></thead>
  <tbody>${rows}</tbody>
</table>` : '<div class="rn-empty">No taxi requests yet.</div>'}
</div>`;
    res.send(rnPage('Taxi Requests', renderRnNav(sess, token, 'taxi-requests'), body));
  } catch (e: any) {
    res.send(rnPage('Taxi Requests', renderRnNav(sess, token, 'taxi-requests'), `<div class="rn-notice err">Error: ${esc(e.message)}</div>`));
  }
});

router.post('/api/rental-location-add', (req: Request, res: Response) => {
  const sess = rnGetSession(req.body.t || '');
  const te = encodeURIComponent(req.body.t || '');
  if (!sess) return res.redirect('/rental-portal/config?t=' + te + '&msg=Session+expired&mt=err');
  const { name, address, pickupHours, surcharge, oneWayFee } = req.body;
  if (!name || !address) return res.redirect('/rental-portal/config?t=' + te + '&msg=Name+and+address+required&mt=err');
  const data = { name: name.trim(), address: address.trim(), pickupHours: pickupHours || '', surcharge: parseFloat(surcharge) || 0, oneWayFee: parseFloat(oneWayFee) || 0, createdAt: Date.now() };
  fbWrite('PUT', 'rentalLocations/' + sess.companyId + '/L' + Date.now(), data, (err: any) => {
    if (err) return res.redirect('/rental-portal/config?t=' + te + '&msg=Save+failed&mt=err');
    res.redirect('/rental-portal/config?t=' + te + '&msg=' + encodeURIComponent(name + ' added') + '&mt=ok');
  });
});

router.post('/api/rental-location-delete', (req: Request, res: Response) => {
  const sess = rnGetSession(req.body.t || '');
  const te = encodeURIComponent(req.body.t || '');
  if (!sess || !req.body.locationId) return res.redirect('/rental-portal/config?t=' + te + '&msg=Invalid+request&mt=err');
  fbWrite('DELETE', 'rentalLocations/' + sess.companyId + '/' + req.body.locationId, null, (err: any) => {
    if (err) return res.redirect('/rental-portal/config?t=' + te + '&msg=Delete+failed&mt=err');
    res.redirect('/rental-portal/config?t=' + te + '&msg=Location+removed&mt=ok');
  });
});

export default router;
