/**
 * Data Normalizer — runs every 30 s on the SA server.
 *
 * Silently corrects known bad values and fires notifications:
 *
 *  1. vehiclestatus: driver app writes "Away" to the top-level
 *     online/{cid}/{vid} node on GPS updates, but writes the correct
 *     value ("Available") to online/{cid}/{vid}/current/vehiclestatus.
 *     When current says Available but top-level says Away, we patch.
 *
 *  2. paymentStatus: web booking page writes paymentStatus:"cash" for
 *     cash bookings instead of "paid".  Dispatch filter requires "paid".
 *     We correct it automatically in pendingjobs (Scheduled jobs skipped).
 *
 *  3. bookingNotifications: when a new booking lands in pendingjobs from
 *     web or passenger app, send confirmation email to client and
 *     notification email to company owner (fires once per booking).
 */

import { fbReadP, fbWriteP } from './firebase';
import { getResendClient } from './utils';

const INTERVAL_MS = 30_000;
const FROM_EMAIL   = 'BookaWaka <info@bookawaka.com>';

// ─── 1. vehiclestatus normalizer ─────────────────────────────────────────────

async function normalizeVehicleStatus(): Promise<void> {
  try {
    const onlineRoot = await fbReadP('online');
    if (!onlineRoot || typeof onlineRoot !== 'object') return;

    const patches: Promise<any>[] = [];

    for (const cid of Object.keys(onlineRoot)) {
      const vehicles = onlineRoot[cid];
      if (!vehicles || typeof vehicles !== 'object') continue;

      for (const vid of Object.keys(vehicles)) {
        const v = vehicles[vid];
        if (!v || typeof v !== 'object') continue;

        const topStatus     = v.vehiclestatus;
        const currentStatus = v.current?.vehiclestatus;
        const isOnline      = v.current?.online === true || v.current?.online === 'true';
        const hasDispatchQueue = v.queueWaitSince != null || v.current?.joboffer;

        if (isOnline && currentStatus === 'Available' && topStatus === 'Away' && !hasDispatchQueue) {
          console.log(`[normalizer] vehiclestatus fix: online/${cid}/${vid} Away → Available`);
          patches.push(
            fbWriteP('PATCH', `online/${cid}/${vid}`, { vehiclestatus: 'Available' })
              .catch(err => console.error(`[normalizer] vehiclestatus patch failed ${cid}/${vid}:`, err.message))
          );
        }
      }
    }

    if (patches.length) await Promise.all(patches);
  } catch (err: any) {
    console.error('[normalizer] vehiclestatus error:', err.message);
  }
}

// ─── 2. paymentStatus normalizer ─────────────────────────────────────────────

async function normalizePaymentStatus(): Promise<void> {
  try {
    const pendingRoot = await fbReadP('pendingjobs');
    if (!pendingRoot || typeof pendingRoot !== 'object') return;

    const patches: Promise<any>[] = [];

    for (const cid of Object.keys(pendingRoot)) {
      const jobs = pendingRoot[cid];
      if (!jobs || typeof jobs !== 'object') continue;

      for (const jobId of Object.keys(jobs)) {
        const job = jobs[jobId];
        if (!job || typeof job !== 'object') continue;

        // Cash bookings must have paymentStatus:"paid" — anything else blocks dispatch.
        // Skip Scheduled jobs — they are not yet due and must not be sent to dispatch early.
        const jobStatus = (job.Status || job.status || '').toLowerCase();
        if (job.paymentMethod === 'cash' && job.paymentStatus !== 'paid' && jobStatus !== 'scheduled') {
          console.log(`[normalizer] paymentStatus fix: pendingjobs/${cid}/${jobId} "${job.paymentStatus}" → "paid"`);
          patches.push(
            fbWriteP('PATCH', `pendingjobs/${cid}/${jobId}`, { paymentStatus: 'paid' })
              .catch(err => console.error(`[normalizer] paymentStatus patch failed ${cid}/${jobId}:`, err.message))
          );
        }
      }
    }

    if (patches.length) await Promise.all(patches);
  } catch (err: any) {
    console.error('[normalizer] paymentStatus error:', err.message);
  }
}

// ─── 3. booking notifications ─────────────────────────────────────────────────

function fmtBookingTime(isoStr: string): string {
  try {
    const d = new Date(isoStr);
    return d.toLocaleString('en-NZ', {
      timeZone: 'Pacific/Auckland',
      weekday: 'short', day: 'numeric', month: 'short',
      hour: 'numeric', minute: '2-digit', hour12: true
    });
  } catch { return isoStr; }
}

function buildClientEmail(job: any, jobId: string): string {
  const pickup  = (job.PickAddress  || job.pickupLocation?.address  || job.pickup?.address  || 'N/A');
  const dropoff = (job.DropAddress  || job.dropoffLocation?.address || job.dropoff?.address || 'N/A');
  const name    = job.PassengerName || job.passenger?.name || 'Valued Customer';
  const isScheduled = (job.Status || job.status || '').toLowerCase() === 'scheduled';
  const timeLabel = isScheduled
    ? `Scheduled for ${fmtBookingTime(job.ScheduledFor || job.scheduledFor)}`
    : 'As soon as possible';
  const payment = job.paymentMethod === 'cash' ? 'Cash' : 'Card';
  const service = (job.ServiceType || job.serviceType || 'taxi');
  const serviceLabel = service.charAt(0).toUpperCase() + service.slice(1);

  return `
<div style="font-family:sans-serif;max-width:520px;margin:0 auto;color:#333">
  <div style="background:#00695C;padding:24px;border-radius:8px 8px 0 0">
    <h1 style="color:#fff;margin:0;font-size:22px">Booking Confirmed</h1>
    <p style="color:#b2dfdb;margin:4px 0 0">BookaWaka — Ref: ${jobId}</p>
  </div>
  <div style="background:#f9f9f9;padding:24px;border-radius:0 0 8px 8px;border:1px solid #e0e0e0">
    <p style="margin:0 0 16px">Hi ${name},</p>
    <p style="margin:0 0 16px">Your booking has been received. Here are the details:</p>
    <table style="width:100%;border-collapse:collapse;font-size:14px">
      <tr><td style="padding:8px 0;color:#666;width:130px">Service</td><td style="font-weight:600">${serviceLabel}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Pickup</td><td>${pickup}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Drop-off</td><td>${dropoff}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Time</td><td style="font-weight:600">${timeLabel}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Payment</td><td>${payment}</td></tr>
    </table>
    <p style="margin:20px 0 4px;font-size:13px;color:#888">Need to cancel or change your booking? Reply to this email or contact the company directly.</p>
  </div>
</div>`.trim();
}

function buildOwnerEmail(job: any, jobId: string, companyName: string): string {
  const pickup  = (job.PickAddress  || job.pickupLocation?.address  || job.pickup?.address  || 'N/A');
  const dropoff = (job.DropAddress  || job.dropoffLocation?.address || job.dropoff?.address || 'N/A');
  const passenger = job.PassengerName || job.passenger?.name || 'Unknown';
  const phone     = job.PassengerPhone || job.passenger?.phone || '';
  const isScheduled = (job.Status || job.status || '').toLowerCase() === 'scheduled';
  const timeLabel = isScheduled
    ? fmtBookingTime(job.ScheduledFor || job.scheduledFor)
    : 'ASAP';
  const source = job.WebBooking ? 'Web Booking' : (job.CreatedBy === 'WEB' ? 'Web Booking' : 'Passenger App');
  const payment = job.paymentMethod === 'cash' ? 'Cash' : 'Card';

  return `
<div style="font-family:sans-serif;max-width:520px;margin:0 auto;color:#333">
  <div style="background:#1565C0;padding:24px;border-radius:8px 8px 0 0">
    <h1 style="color:#fff;margin:0;font-size:20px">New Booking — ${isScheduled ? 'Scheduled' : 'Immediate'}</h1>
    <p style="color:#90CAF9;margin:4px 0 0">${companyName} | Ref: ${jobId}</p>
  </div>
  <div style="background:#f9f9f9;padding:24px;border-radius:0 0 8px 8px;border:1px solid #e0e0e0">
    <table style="width:100%;border-collapse:collapse;font-size:14px">
      <tr><td style="padding:8px 0;color:#666;width:130px">Source</td><td style="font-weight:600">${source}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Passenger</td><td>${passenger}${phone ? ' — ' + phone : ''}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Pickup</td><td>${pickup}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Drop-off</td><td>${dropoff}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Time</td><td style="font-weight:600;color:#1565C0">${timeLabel}</td></tr>
      <tr><td style="padding:8px 0;color:#666">Payment</td><td>${payment}</td></tr>
    </table>
    <p style="margin:20px 0 4px;font-size:13px;color:#888">Log in to your dispatch console to manage this booking.</p>
  </div>
</div>`.trim();
}

async function normalizeBookingNotifications(): Promise<void> {
  try {
    const pendingRoot = await fbReadP('pendingjobs');
    if (!pendingRoot || typeof pendingRoot !== 'object') return;

    const resend = await getResendClient();
    if (!resend) return;

    for (const cid of Object.keys(pendingRoot)) {
      const jobs = pendingRoot[cid];
      if (!jobs || typeof jobs !== 'object') continue;

      // Read company details once per company, only if needed
      let companyData: any = null;

      for (const jobId of Object.keys(jobs)) {
        const job = jobs[jobId];
        if (!job || typeof job !== 'object') continue;

        // Email responsibility split (confirmed 2026-05-07 with website dev):
        //   Scheduled cash  → SA portal sends both emails (website suppressed for this case)
        //   Immediate cash  → website sends both emails; SA portal does nothing
        //   Card (any)      → website sends emails; card bookings don't reach pendingjobs
        //                     until after Stripe confirms, so SA portal never sees them in time
        //
        // SA portal rule: only fire for scheduled + non-card bookings.

        const jobStatus = (job.Status || job.status || '').toLowerCase();
        const isScheduled = jobStatus === 'scheduled' || !!(job.ScheduledFor || job.scheduledFor);
        if (!isScheduled) continue;

        // Skip cancelled/completed jobs
        if (['cancelled', 'completed', 'assigned'].includes(jobStatus)) continue;

        // Card bookings: website handles all emails — SA portal must not double-send.
        // (Card records also don't land in pendingjobs until post-Stripe, so this is a safety net.)
        const paymentMethod = (job.paymentMethod || '').toLowerCase();
        if (paymentMethod === 'card' || paymentMethod === 'stripe') continue;

        // Skip if already notified
        if (job.ownerNotifiedAt && job.clientNotifiedAt) continue;

        // Only fire for external-source bookings (web or passenger app), not dispatch console jobs
        const isWebBooking = job.WebBooking || job.CreatedBy === 'WEB' ||
                             (job.source || '').toLowerCase() === 'web' ||
                             (job.source || '').toLowerCase() === 'passenger';
        if (!isWebBooking) continue;

        // Load company data once per company
        if (!companyData) {
          companyData = await fbReadP(`superClients/${cid}`).catch(() => null);
        }

        const ownerEmail    = companyData?.email;
        const companyName   = companyData?.name || cid;
        const passengerEmail = job.PassengerEmail || job.passenger?.email || null;

        const sends: Promise<any>[] = [];
        const flags: Record<string, any> = {};

        if (!job.clientNotifiedAt && passengerEmail) {
          sends.push(
            (resend as any).emails.send({
              from: FROM_EMAIL,
              to: passengerEmail,
              subject: `Your BookaWaka booking is confirmed — Ref ${jobId}`,
              html: buildClientEmail(job, jobId)
            }).catch((e: any) => console.error(`[normalizer] client email failed ${jobId}:`, e.message))
          );
          flags.clientNotifiedAt = Date.now();
          console.log(`[normalizer] client email → ${passengerEmail} for booking ${jobId}`);
        }

        if (!job.ownerNotifiedAt && ownerEmail) {
          sends.push(
            (resend as any).emails.send({
              from: FROM_EMAIL,
              to: ownerEmail,
              subject: `New booking received — ${companyName} | Ref ${jobId}`,
              html: buildOwnerEmail(job, jobId, companyName)
            }).catch((e: any) => console.error(`[normalizer] owner email failed ${jobId}:`, e.message))
          );
          flags.ownerNotifiedAt = Date.now();
          console.log(`[normalizer] owner email → ${ownerEmail} for booking ${jobId}`);
        }

        if (sends.length) {
          await Promise.all(sends);
          await fbWriteP('PATCH', `pendingjobs/${cid}/${jobId}`, flags).catch(() => {});
        }
      }
    }
  } catch (err: any) {
    console.error('[normalizer] bookingNotifications error:', err.message);
  }
}

// ─── 4. Stale pendingjobs cleanup ─────────────────────────────────────────────
// If a job in pendingjobs has Status=Assigned but rideStatus/{cid}/{jobId}
// says Completed or Cancelled, the dispatch console never removed it.
// These ghost records cause auto-assign to re-offer already-finished jobs.

async function normalizeStalePendingJobs(): Promise<void> {
  try {
    const pendingRoot = await fbReadP('pendingjobs');
    if (!pendingRoot || typeof pendingRoot !== 'object') return;

    const deletions: Promise<any>[] = [];

    for (const cid of Object.keys(pendingRoot)) {
      const jobs = pendingRoot[cid];
      if (!jobs || typeof jobs !== 'object') continue;

      for (const jobId of Object.keys(jobs)) {
        const job = jobs[jobId];
        if (!job || typeof job !== 'object') continue;

        const jobStatus = (job.Status || job.status || '').toLowerCase();
        // Only check Assigned jobs — Pending ones may legitimately not have rideStatus yet
        if (jobStatus !== 'assigned') continue;

        // Look up rideStatus to see if the trip actually finished
        const rideStatus = await fbReadP(`rideStatus/${cid}/${jobId}`).catch(() => null);
        if (!rideStatus) continue;

        const rs = (rideStatus.status || '').toLowerCase();
        if (rs === 'completed' || rs === 'cancelled') {
          console.log(`[normalizer] stale pendingjob: ${cid}/${jobId} is ${jobStatus} in pendingjobs but rideStatus=${rs} — removing`);
          deletions.push(
            fbWriteP('DELETE', `pendingjobs/${cid}/${jobId}`, null)
              .catch(err => console.error(`[normalizer] stale delete failed ${cid}/${jobId}:`, err.message))
          );
        }
      }
    }

    if (deletions.length) await Promise.all(deletions);
  } catch (err: any) {
    console.error('[normalizer] stalePendingJobs error:', err.message);
  }
}

// ─── Runner ───────────────────────────────────────────────────────────────────

async function runNormalizer(): Promise<void> {
  await Promise.all([
    normalizeVehicleStatus(),
    normalizePaymentStatus(),
    normalizeBookingNotifications(),
    normalizeStalePendingJobs()
  ]);
}

export function startNormalizer(): void {
  console.log('[normalizer] started — polling every 30 s');
  runNormalizer();
  setInterval(runNormalizer, INTERVAL_MS);
}
