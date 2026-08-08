/**
 * One-shot: seed a 2-hoist WAV acceptance trip for visibility checks.
 * Usage: node scripts/seed-hoist2-acceptance.mjs
 */
import https from 'https';

const JOB_ID = 'ZZHOIST2ACCEPT01';
const CID = '860869';
const COUNCIL = 'cncl_invercargill_city_council_test';
const HOST = 'invt-admin-production.up.railway.app';

function post(path, body) {
  const payload = JSON.stringify(body);
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: HOST,
        path,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        },
        timeout: 30000,
      },
      (res) => {
        let d = '';
        res.on('data', (c) => (d += c));
        res.on('end', () => resolve({ status: res.statusCode, body: d }));
      },
    );
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

function get(path) {
  return new Promise((resolve, reject) => {
    https
      .get({ hostname: HOST, path, timeout: 30000 }, (res) => {
        let d = '';
        res.on('data', (c) => (d += c));
        res.on('end', () => resolve({ status: res.statusCode, body: d }));
      })
      .on('error', reject);
  });
}

const now = Date.now();
const started = new Date(now - 60 * 60 * 1000).toISOString();
const completed = new Date(now).toISOString();

const job = {
  bookingId: JOB_ID,
  jobId: JOB_ID,
  isTotalMobility: true,
  tmPaymentType: 'total_mobility',
  paymentCategory: 'total_mobility',
  paymentType: 'Total Mobility',
  fare: 20,
  tmMeterFare: 20,
  tmSubsidyFare: 13,
  tmSubsidyHoist: 22,
  hoistTotal: 22,
  tmHoistCount: 2,
  hoistCount: 2,
  tmHoists: [
    { cardNumber: 'ZZCARDHOIST1', amount: 11, cardName: 'Alice Hoist' },
    { cardNumber: 'ZZCARDHOIST1', amount: 11, cardName: 'Alice Hoist' },
  ],
  tmSubsidy: 35,
  tmCouncilPays: 35,
  tmPassengerPays: 7,
  tmCardNumber: 'ZZCARDHOIST1',
  tmVoucherNo: 'ZZCARDHOIST1',
  tmCardName: 'Alice Hoist',
  tmPassengerName: 'Alice Hoist',
  councilId: COUNCIL,
  tmCouncilId: COUNCIL,
  vehicleId: '201',
  vehicleHoistEquipped: true,
  driverName: 'Acceptance Driver',
  pickupAddress: '305 Kelvin Street, Invercargill',
  dropAddress: '1 Don Street, Invercargill',
  startedAt_ISO: started,
  completedAt_ISO: completed,
  distanceKm: 4.2,
  durationLabel: '12 min',
};

const status = {
  status: 'approved',
  councilId: COUNCIL,
  companyId: CID,
  submittedAt: now,
  approvedAt: now,
  source: 'acceptance_seed',
};

const w1 = await post('/api/admin-write', {
  path: `completedJobs/${CID}/${JOB_ID}`,
  method: 'PUT',
  data: job,
});
console.log('job write', w1.status, w1.body.slice(0, 200));

const w2 = await post('/api/admin-write', {
  path: `tmTripStatus/${CID}/${JOB_ID}`,
  method: 'PUT',
  data: status,
});
console.log('status write', w2.status, w2.body.slice(0, 200));

const r = await get(
  `/api/admin-read?path=${encodeURIComponent(`completedJobs/${CID}/${JOB_ID}`)}`,
);
const parsed = JSON.parse(r.body);
const d = parsed.data || parsed;
console.log('verify', {
  tmHoistCount: d.tmHoistCount,
  hoistCount: d.hoistCount,
  tmSubsidyHoist: d.tmSubsidyHoist,
  tmHoists: Array.isArray(d.tmHoists) ? d.tmHoists.length : 0,
  tmSubsidy: d.tmSubsidy,
});
