/**
 * TM Phase 3 — fraud / anomaly detection for council claims.
 * Pure helpers (no Firebase I/O).
 */
import {
  expectedMeterFromTariff,
  type RefTariff,
} from './tmTripDetail';

export const ANOMALY_FARE_MISMATCH = 'fare_mismatch';
export const ANOMALY_CARD_REUSE_3MIN = 'same_card_reuse_3min';
export const ANOMALY_CARD_DIFF_TAXI = 'same_card_same_time_diff_taxi';

export type AnomalyReason =
  | typeof ANOMALY_FARE_MISMATCH
  | typeof ANOMALY_CARD_REUSE_3MIN
  | typeof ANOMALY_CARD_DIFF_TAXI
  | string;

export type AnomalyTripLike = {
  _cid?: string;
  _rawKey?: string;
  bookingId?: string;
  id?: string;
  status?: string;
  tmCardNumber?: string;
  tmVoucherNo?: string;
  cardNumber?: string;
  vehicleId?: string;
  taxiNumber?: string;
  VehicleNo?: string;
  fare?: number;
  tmMeterFare?: number;
  meterFare?: number;
  totalFare?: number;
  waitingCost?: number;
  waitingCharge?: number;
  distanceKm?: number | string;
  distance?: number | string;
  durationMin?: number | string;
  duration?: number | string;
  durationLabel?: string;
  startedAt_ISO?: string;
  startedAt?: string | number;
  completedAt_ISO?: string;
  completedAt?: string | number;
  flagReasons?: string[];
  anomalyDetail?: string;
};

export type AnomalyHit = {
  reasons: AnomalyReason[];
  detail: string;
};

export type AnomalyStatusPatch = {
  cid: string;
  rawKey: string;
  patch: Record<string, unknown>;
};

const REUSE_WINDOW_MS = 3 * 60 * 1000;

function num(v: unknown, fallback = 0): number {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

function str(v: unknown): string {
  return v == null ? '' : String(v).trim();
}

export function toTripMs(raw: unknown): number {
  if (raw == null || raw === '') return 0;
  if (typeof raw === 'number' || (typeof raw === 'string' && /^\d{10,13}$/.test(String(raw).trim()))) {
    let ms = Number(raw);
    if (ms < 1e12) ms *= 1000;
    return Number.isFinite(ms) ? ms : 0;
  }
  const p = Date.parse(String(raw));
  return Number.isFinite(p) ? p : 0;
}

export function tripCardNumbers(trip: AnomalyTripLike): string[] {
  const out: string[] = [];
  const primary = str(trip.tmCardNumber || trip.tmVoucherNo || trip.cardNumber).replace(/\s+/g, '');
  if (primary) out.push(primary);
  return out;
}

export function tripVehicleKey(trip: AnomalyTripLike): string {
  return str(trip.vehicleId || trip.taxiNumber || trip.VehicleNo).toUpperCase();
}

export function tripWindow(trip: AnomalyTripLike): { start: number; end: number } {
  const start =
    toTripMs(trip.startedAt_ISO || trip.startedAt) ||
    toTripMs(trip.completedAt_ISO || trip.completedAt);
  let end = toTripMs(trip.completedAt_ISO || trip.completedAt) || start;
  if (end < start) end = start;
  return { start, end };
}

function windowsOverlapOrWithin(a: { start: number; end: number }, b: { start: number; end: number }, withinMs: number): boolean {
  if (!a.start || !b.start) return false;
  if (a.start <= b.end && b.start <= a.end) return true;
  return Math.abs(a.start - b.start) <= withinMs;
}

function durationMinOf(trip: AnomalyTripLike): number {
  if (trip.durationMin != null && trip.durationMin !== '' && Number.isFinite(Number(trip.durationMin))) {
    return Number(trip.durationMin);
  }
  const label = str(trip.durationLabel);
  const m = label.match(/([\d.]+)\s*min/i);
  if (m) return Number(m[1]);
  const w = tripWindow(trip);
  if (w.start && w.end && w.end > w.start) return (w.end - w.start) / 60000;
  return 0;
}

function distanceKmOf(trip: AnomalyTripLike): number {
  const d = trip.distanceKm ?? trip.distance;
  return d != null && d !== '' && Number.isFinite(Number(d)) ? Number(d) : 0;
}

function meterFareOf(trip: AnomalyTripLike): number {
  return num(trip.tmMeterFare ?? trip.meterFare ?? trip.fare ?? trip.totalFare);
}

/** Claim batches may only include approved (or already paid) trips. */
export function isClaimEligibleStatus(status: string | null | undefined): boolean {
  const s = String(status || '').trim().toLowerCase();
  return s === 'approved' || s === 'paid';
}

/** Archived trips are soft-deleted from queues / claims / anomaly auto-moves. */
export function isActiveWorkflowStatus(status: string | null | undefined): boolean {
  const s = String(status || '').trim().toLowerCase();
  return s !== 'archived';
}

export function detectTripAnomalies(
  trip: AnomalyTripLike,
  opts?: { peers?: AnomalyTripLike[]; refTariff?: RefTariff | null },
): AnomalyHit {
  const reasons: AnomalyReason[] = [];
  const details: string[] = [];
  const peers = (opts?.peers || []).filter((p) => p && p !== trip);
  const selfKey = `${str(trip._cid)}/${str(trip._rawKey || trip.bookingId || trip.id)}`;

  const fare = meterFareOf(trip);
  const expected = expectedMeterFromTariff(
    opts?.refTariff,
    distanceKmOf(trip),
    durationMinOf(trip),
    0,
  );
  if (
    expected != null &&
    fare > 0 &&
    Math.abs(fare - expected) > Math.max(1, expected * 0.15)
  ) {
    reasons.push(ANOMALY_FARE_MISMATCH);
    details.push(
      `Fare mismatch: meter $${fare.toFixed(2)} vs ref $${expected.toFixed(2)}`,
    );
  }

  const cards = tripCardNumbers(trip);
  const selfWin = tripWindow(trip);
  const selfVeh = tripVehicleKey(trip);

  for (const card of cards) {
    for (const peer of peers) {
      const peerKey = `${str(peer._cid)}/${str(peer._rawKey || peer.bookingId || peer.id)}`;
      if (peerKey === selfKey) continue;
      const peerCards = tripCardNumbers(peer);
      if (!peerCards.includes(card)) continue;
      const peerWin = tripWindow(peer);
      if (!windowsOverlapOrWithin(selfWin, peerWin, REUSE_WINDOW_MS)) continue;

      if (!reasons.includes(ANOMALY_CARD_REUSE_3MIN)) {
        reasons.push(ANOMALY_CARD_REUSE_3MIN);
        details.push(`Card ${card} reused within 3 minutes (peer ${peerKey})`);
      }

      const peerVeh = tripVehicleKey(peer);
      if (selfVeh && peerVeh && selfVeh !== peerVeh) {
        if (!reasons.includes(ANOMALY_CARD_DIFF_TAXI)) {
          reasons.push(ANOMALY_CARD_DIFF_TAXI);
          details.push(
            `Card ${card} same window on different taxis (${selfVeh} vs ${peerVeh})`,
          );
        }
      }
    }
  }

  return { reasons, detail: details.join('; ') };
}

/**
 * Scan all trips; produce Firebase PATCH payloads for submitted/flagged rows that need status sync.
 * - Hits on submitted/flagged/revision_needed(with prior flags) → flagged + reasons
 * - Clean submitted that was flagged → stay/return to submitted and clear reasons
 * Does not downgrade approved/rejected/paid.
 */
export function applyAnomalyScan(
  trips: AnomalyTripLike[],
  tariffByCid: Record<string, { car?: RefTariff } | RefTariff | null | undefined>,
): AnomalyStatusPatch[] {
  const now = Date.now();
  const patches: AnomalyStatusPatch[] = [];

  for (const trip of trips) {
    const cid = str(trip._cid);
    const rawKey = str(trip._rawKey);
    if (!cid || !rawKey) continue;

    const status = str(trip.status || 'pending').toLowerCase();
    if (status === 'archived') continue;
    if (['approved', 'rejected', 'paid'].includes(status)) continue;
    // Only auto-move between submitted <-> flagged (and refresh flags on revision_needed for banner)
    if (!['submitted', 'flagged', 'revision_needed', 'pending', 'company_approved'].includes(status)) {
      continue;
    }

    const tariffNode = tariffByCid[cid];
    const refTariff =
      tariffNode && typeof tariffNode === 'object' && 'car' in (tariffNode as any)
        ? (tariffNode as any).car
        : (tariffNode as RefTariff | null | undefined);

    const hit = detectTripAnomalies(trip, { peers: trips, refTariff });
    const base = {
      anomalyScannedAt: now,
      flagReasons: hit.reasons,
      anomalyDetail: hit.detail || null,
    };

    if (hit.reasons.length) {
      if (status === 'revision_needed') {
        // Keep revision_needed; refresh flag metadata for owner warning.
        patches.push({ cid, rawKey, patch: { ...base } });
      } else if (status === 'flagged' || status === 'submitted' || status === 'pending' || status === 'company_approved') {
        patches.push({
          cid,
          rawKey,
          patch: {
            ...base,
            status: 'flagged',
            flaggedAt: now,
          },
        });
      }
    } else if (status === 'flagged') {
      patches.push({
        cid,
        rawKey,
        patch: {
          ...base,
          status: 'submitted',
          flagReasons: [],
          anomalyDetail: null,
        },
      });
    } else if (status === 'submitted') {
      // Refresh scan timestamp / clear stale reasons on clean submitted
      const prior = Array.isArray(trip.flagReasons) ? trip.flagReasons : [];
      if (prior.length || trip.anomalyDetail) {
        patches.push({
          cid,
          rawKey,
          patch: {
            anomalyScannedAt: now,
            flagReasons: [],
            anomalyDetail: null,
          },
        });
      }
    }
  }

  return patches;
}

export function partitionCleanAndFlagged(trips: AnomalyTripLike[]): {
  cleanSubmitted: AnomalyTripLike[];
  flagged: AnomalyTripLike[];
} {
  const cleanSubmitted: AnomalyTripLike[] = [];
  const flagged: AnomalyTripLike[] = [];
  for (const t of trips) {
    const st = str(t.status).toLowerCase();
    if (st === 'flagged') flagged.push(t);
    else if (st === 'submitted') cleanSubmitted.push(t);
  }
  return { cleanSubmitted, flagged };
}
