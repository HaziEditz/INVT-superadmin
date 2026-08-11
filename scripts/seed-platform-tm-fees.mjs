/**
 * Slice 0 live bootstrap: ensure platformTmFees/defaults exists with chargeEnabled false.
 */
import https from 'https';
import fs from 'fs';

const env = fs.readFileSync('C:/Users/64275/Projects/INVT/.env', 'utf8');
function envVal(name) {
  const m = env.match(new RegExp('^' + name + '=(.*)$', 'm'));
  return m ? m[1].trim().replace(/^["']|["']$/g, '') : '';
}
const secret = envVal('BW_FIREBASE_SECRET') || envVal('FIREBASE_DB_SECRET');
if (!secret) {
  console.error('NO_SECRET');
  process.exit(1);
}
const db = 'https://bookawaka2026-564e1-default-rtdb.firebaseio.com';

function req(method, path, body) {
  return new Promise((resolve, reject) => {
    const data = body != null ? JSON.stringify(body) : null;
    const u = new URL(db + '/' + path + '.json?auth=' + encodeURIComponent(secret));
    const opts = {
      hostname: u.hostname,
      path: u.pathname + u.search,
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (data) opts.headers['Content-Length'] = Buffer.byteLength(data);
    const r = https.request(opts, (res) => {
      let d = '';
      res.on('data', (c) => (d += c));
      res.on('end', () => {
        try {
          resolve(JSON.parse(d));
        } catch {
          resolve(d);
        }
      });
    });
    r.on('error', reject);
    if (data) r.write(data);
    r.end();
  });
}

const existing = await req('GET', 'platformTmFees/defaults');
console.log('before', JSON.stringify(existing));
if (!existing || typeof existing !== 'object' || existing.councilFeePerTrip == null) {
  const payload = {
    councilFeePerTrip: 1,
    companyFeePerTrip: 0.5,
    chargeEnabled: false,
    seededAt: Date.now(),
    seededBy: 'slice0-bootstrap',
  };
  console.log('seeded', JSON.stringify(await req('PUT', 'platformTmFees/defaults', payload)));
} else {
  const next = { ...existing, chargeEnabled: false, verifiedAt: Date.now() };
  console.log('verified', JSON.stringify(await req('PUT', 'platformTmFees/defaults', next)));
}
const after = await req('GET', 'platformTmFees/defaults');
console.log('after', JSON.stringify(after));
console.log('chargeEnabled_explicit', after && after.chargeEnabled === true ? 'TRUE' : 'false');
