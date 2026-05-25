require('dotenv').config();

import express from 'express';
import path from 'path';
import fs from 'fs';
import session from 'express-session';

import jobsRouter      from './routes/jobs';
import passengerRouter from './routes/passenger';
import towingRouter    from './routes/towing';
import stripeRouter    from './routes/stripe';
import freightRouter   from './routes/freight';
import councilRouter   from './routes/council';
import earningsRouter  from './routes/earnings';
import restaurantRouter from './routes/restaurant';
import rentalRouter    from './routes/rental';
import saAdminRouter   from './routes/sa-admin';
import saWalletRouter  from './routes/sa-wallet';
import { startNormalizer } from './normalizer';
import { startNotificationRelay } from './notificationRelay';
import { hydrateAllSessions } from './sessions';

process.on('uncaughtException', (err) => {
  console.error('[uncaughtException]', err.message, err.stack);
});
process.on('unhandledRejection', (reason) => {
  console.error('[unhandledRejection]', reason);
});

const app = express();
const PORT = 5000;
const ROOT = path.join(process.cwd(), 'taxitime.co.nz', 'superadmin360taxi');

// ── Rate limiter (in-memory, per IP) ─────────────────────────────────────────
const _rlMap = new Map<string, { count: number; resetAt: number }>();
function _checkRateLimit(key: string, limit: number, windowMs: number): boolean {
  const now = Date.now();
  let entry = _rlMap.get(key);
  if (!entry || now > entry.resetAt) {
    entry = { count: 0, resetAt: now + windowMs };
  }
  entry.count++;
  _rlMap.set(key, entry);
  return entry.count <= limit;
}
// Clean up expired entries every 10 minutes
setInterval(() => {
  const now = Date.now();
  _rlMap.forEach((v, k) => { if (now > v.resetAt) _rlMap.delete(k); });
}, 10 * 60 * 1000);

// Apply rate limiting to login + public-facing auth endpoints
app.use((req, res, next) => {
  const loginPaths = ['/api/sa-login', '/api/login', '/api/portal-login',
    '/council-portal/login', '/freight-portal/login', '/restaurant-portal/login',
    '/towing-portal/login', '/rental-portal/login', '/company-earnings-portal/login'];
  if (req.method === 'POST' && loginPaths.some(p => req.path.startsWith(p))) {
    const ip = (req.headers['x-forwarded-for'] as string || req.socket.remoteAddress || 'unknown').split(',')[0].trim();
    if (!_checkRateLimit('login:' + ip, 15, 15 * 60 * 1000)) {
      console.warn(`[rate-limit] Login blocked for IP ${ip} on ${req.path}`);
      return res.status(429).json({ error: 'Too many login attempts. Please try again in 15 minutes.' });
    }
  }
  next();
});

// ── Body parsers ───────────────────────────────────────────────────────────────
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true, limit: '2mb' }));

// ── Session (company-earnings portal + any other portal that needs it) ────────
app.use(session({
  secret: process.env.SESSION_SECRET || 'bw-session-secret-2026',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 8 * 60 * 60 * 1000 }
}));

// ── CORS — restrict to known origins ─────────────────────────────────────────
function _isAllowedOrigin(origin: string | undefined): boolean {
  if (!origin) return true; // server-to-server requests (no Origin header)
  if (origin.endsWith('.replit.dev')) return true;
  if (origin.endsWith('.replit.app')) return true;
  if (origin.endsWith('.spock.replit.dev')) return true;
  if (origin.endsWith('.riker.replit.dev')) return true;
  if (origin.includes('taxilatest.firebaseapp.com')) return true;
  if (origin.includes('bookawaka.com') || origin.includes('bookawaka.co.nz')) return true;
  const extra = process.env.CORS_ALLOWED_ORIGINS || '';
  if (extra && extra.split(',').map(s => s.trim()).some(o => origin.includes(o))) return true;
  return false;
}
app.use((req, res, next) => {
  const origin = req.headers.origin as string | undefined;
  const allowedOrigin = _isAllowedOrigin(origin) ? (origin || '*') : 'null';
  res.setHeader('Access-Control-Allow-Origin', allowedOrigin);
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Api-Key,X-Admin-Key');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  if (req.method === 'OPTIONS') { res.status(204).end(); return; }
  next();
});

// ── Request logger (API routes only) ─────────────────────────────────────────
app.use((req, _res, next) => {
  if (req.path.startsWith('/api/') || req.path.startsWith('/rent/') || req.path.startsWith('/council') || req.path.startsWith('/payment')) {
    console.log(`[req] ${req.method} ${req.path}`, Object.keys(req.body || {}).length ? JSON.stringify(req.body).slice(0, 200) : '');
  }
  next();
});

// ── API & portal routers ──────────────────────────────────────────────────────
app.use(jobsRouter);
app.use(passengerRouter);
app.use(towingRouter);
app.use(stripeRouter);
app.use(freightRouter);
app.use(councilRouter);
app.use(earningsRouter);
app.use(restaurantRouter);
app.use(rentalRouter);
app.use(saAdminRouter);
app.use(saWalletRouter);

// ── Static file serving ───────────────────────────────────────────────────────
const mimeTypes: Record<string, string> = {
  '.html': 'text/html', '.aspx': 'text/html', '.css': 'text/css',
  '.js': 'application/javascript', '.json': 'application/json',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
  '.gif': 'image/gif', '.svg': 'image/svg+xml', '.ico': 'image/x-icon',
  '.woff': 'font/woff', '.woff2': 'font/woff2', '.ttf': 'font/ttf',
  '.eot': 'application/vnd.ms-fontobject', '.otf': 'font/otf',
  '.map': 'application/json', '.txt': 'text/plain'
};

app.use((req, res, next) => {
  let urlPath = req.path;
  if (urlPath === '/' || urlPath === '') urlPath = '/Home.aspx';
  const filePath = path.join(ROOT, urlPath);
  if (!filePath.startsWith(ROOT)) { res.status(403).end('Forbidden'); return; }

  fs.stat(filePath, (err, stat) => {
    if (err) {
      fs.readFile(filePath, (e2, data) => {
        if (e2) { next(); return; }
        const ext = path.extname(filePath).toLowerCase();
        res.setHeader('Content-Type', mimeTypes[ext] || 'application/octet-stream');
        res.end(data);
      });
      return;
    }
    if (stat.isDirectory()) {
      const idx  = path.join(filePath, 'Home.aspx');
      const idx2 = path.join(filePath, 'index.html');
      const pick = fs.existsSync(idx) ? idx : fs.existsSync(idx2) ? idx2 : null;
      if (!pick) { next(); return; }
      fs.readFile(pick, (e2, data) => {
        if (e2) { next(); return; }
        res.setHeader('Content-Type', 'text/html');
        res.end(data);
      });
    } else {
      fs.readFile(filePath, (e2, data) => {
        if (e2) { next(); return; }
        const ext = path.extname(filePath).toLowerCase();
        res.setHeader('Content-Type', mimeTypes[ext] || 'application/octet-stream');
        res.end(data);
      });
    }
  });
});

// ── 404 fallback ──────────────────────────────────────────────────────────────
app.use((req, res) => {
  if (req.path.startsWith('/api/')) {
    console.warn(`[404] ${req.method} ${req.path}`, Object.keys(req.body || {}).length ? JSON.stringify(req.body).slice(0, 300) : '');
  }
  res.status(404).json({ error: 'Not found', path: req.path, hint: 'Check PLATFORM-INTEGRATION-CHECKLIST.md for correct endpoint paths' });
});

// ── Start server ──────────────────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log(`[BookaWaka] Server listening on port ${PORT}`);
  hydrateAllSessions().catch(e => console.error('[sessions] hydrate failed:', e?.message || e));
  startNormalizer();
  startNotificationRelay();
});

export default app;
