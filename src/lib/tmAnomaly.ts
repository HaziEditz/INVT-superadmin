/**
 * TM Phase 3 — fraud / anomaly detection for council claims.
 * Pure helpers (no Firebase I/O).
 */
import {
  expectedMeterFromTariff,
  type RefTariff,
} from './tmTripDetail';
import { tripDayKey, tripMonthKeyNz } from './tmUnifiedTrips';

export const ANOMALY_FARE_MISMATCH = 'fare_mismatch';
export const ANOMALY_CARD_REUSE_3MIN = 'same_card_reuse_3min';
export const ANOMALY_CARD_DIFF_TAXI = 'same_card_same_time_diff_taxi';
export const ANOMALY_LIMIT_DAILY = 'limit_exceeded_daily';
export const ANOMALY_LIMIT_MONTHLY = 'limit_exceeded_monthly';
export const ANOMALY_CARD_EXPIRED = 'card_expired';
/** Near-zero movement + short duration (or sentinel 0,0 coords + short duration). */
export const ANOMALY_IMPLAUSIBLE_SHORT = 'implausible_short_trip';

/** Distance below this (km) counts as near-zero for the short-trip rule. */
export const IMPLAUSIBLE_SHORT_MAX_KM = 0.1;
/** Duration below this (minutes) counts as short for the short-trip rule. */
export const IMPLAUSIBLE_SHORT_MAX_MIN = 3;

export type AnomalyReason =
  | typeof ANOMALY_FARE_MISMATCH
  | typeof ANOMALY_CARD_REUSE_3MIN
  | typeof ANOMALY_CARD_DIFF_TAXI
  | typeof ANOMALY_LIMIT_DAILY
  | typeof ANOMALY_LIMIT_MONTHLY
  | typeof ANOMALY_CARD_EXPIRED
  | typeof ANOMALY_IMPLAUSIBLE_SHORT
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
  tmCardExpiry?: string;
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
  pickupLat?: number | string;
  pickupLng?: number | string;
  pickupLon?: number | string;
  dropLat?: number | string;
  dropLng?: number | string;
  dropLon?: number | string;
  pickupLatLng?: string;
  dropLatLng?: string;
  DropLatLng?: string;
  PickupLatLng?: string;
  pickupLocation?: { lat?: number; latitude?: number; lng?: number; lon?: number; longitude?: number };
  dropLocation?: { lat?: number; latitude?: number; lng?: number; lon?: number; longitude?: number };
  dropoffLocation?: { lat?: number; latitude?: number; lng?: number; lon?: number; longitude?: number };
  startLocation?: { lat?: number; latitude?: number; lng?: number; lon?: number; longitude?: number };
  endLocation?: { lat?: number; latitude?: number; lng?: number; lon?: number; longitude?: number };
};

/** Registry row from tmCards/{cardNumber} (limits are trip counts). */
export type AnomalyCardLike = {
  expiryDate?: string | null;
  usageLimitDaily?: number | string | null;
  usageLimitMonthly?: number | string | null;
  /** Legacy aliases still present on some cards. */
  monthlyLimit?: number | string | null;
  maxFarePerTrip?: number | string | null;
  active?: boolean | null;
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
  if (trip.duration != null && trip.duration !== '' && Number.isFinite(Number(trip.duration))) {
    return Number(trip.duration);
  }
  const w = tripWindow(trip);
  if (w.start && w.end && w.end > w.start) return (w.end - w.start) / 60000;
  return 0;
}

function distanceKmOf(trip: AnomalyTripLike): number {
  const d = trip.distanceKm ?? trip.distance;
  return d != null && d !== '' && Number.isFinite(Number(d)) ? Number(d) : 0;
}

/** True when a lat/lng pair is the classic 0,0 GPS sentinel (not a real NZ point). */
export function isSentinelCoordPair(lat: unknown, lng: unknown): boolean {
  if (lat == null || lat === '' || lng == null || lng === '') return false;
  const la = Number(lat);
  const ln = Number(lng);
  if (!Number.isFinite(la) || !Number.isFinite(ln)) return false;
  return Math.abs(la) < 1e-5 && Math.abs(ln) < 1e-5;
}

function parseLatLngString(raw: unknown): { lat: number; lng: number } | null {
  const s = str(raw);
  if (!s) return null;
  const m = s.match(/^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$/);
  if (!m) return null;
  const lat = Number(m[1]);
  const lng = Number(m[2]);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
  return { lat, lng };
}

function tripEndpointCoords(trip: AnomalyTripLike): {
  pickup: { lat: number; lng: number } | null;
  drop: { lat: number; lng: number } | null;
} {
  const pickupLoc = trip.pickupLocation || trip.startLocation || {};
  const dropLoc = trip.dropLocation || trip.endLocation || trip.dropoffLocation || {};
  const fromPickupStr = parseLatLngString(trip.pickupLatLng || trip.PickupLatLng);
  const fromDropStr = parseLatLngString(trip.dropLatLng || trip.DropLatLng);

  const pickupLat = num(
    trip.pickupLat ?? (pickupLoc as any).latitude ?? (pickupLoc as any).lat ?? fromPickupStr?.lat,
    NaN,
  );
  const pickupLng = num(
    trip.pickupLng ??
      trip.pickupLon ??
      (pickupLoc as any).longitude ??
      (pickupLoc as any).lng ??
      (pickupLoc as any).lon ??
      fromPickupStr?.lng,
    NaN,
  );
  const dropLat = num(
    trip.dropLat ?? (dropLoc as any).latitude ?? (dropLoc as any).lat ?? fromDropStr?.lat,
    NaN,
  );
  const dropLng = num(
    trip.dropLng ??
      trip.dropLon ??
      (dropLoc as any).longitude ??
      (dropLoc as any).lng ??
      (dropLoc as any).lon ??
      fromDropStr?.lng,
    NaN,
  );

  return {
    pickup: Number.isFinite(pickupLat) && Number.isFinite(pickupLng) ? { lat: pickupLat, lng: pickupLng } : null,
    drop: Number.isFinite(dropLat) && Number.isFinite(dropLng) ? { lat: dropLat, lng: dropLng } : null,
  };
}

/**
 * True when either endpoint is the 0,0 sentinel.
 * Sentinel coords must not be treated as a real trip distance of zero in this check.
 */
export function hasInvalidTripCoords(trip: AnomalyTripLike): boolean {
  const { pickup, drop } = tripEndpointCoords(trip);
  if (pickup && isSentinelCoordPair(pickup.lat, pickup.lng)) return true;
  if (drop && isSentinelCoordPair(drop.lat, drop.lng)) return true;
  return false;
}

/**
 * Recorded distance for the short-trip rule.
 * Returns null when distance is unknown (do not invent zero from blank fields alone).
 */
export function recordedDistanceKm(trip: AnomalyTripLike): number | null {
  const raw = trip.distanceKm ?? trip.distance;
  if (raw == null || raw === '') return null;
  const n = Number(raw);
  return Number.isFinite(n) ? n : null;
}

/**
 * Implausible short / static trip:
 * - duration under IMPLAUSIBLE_SHORT_MAX_MIN, AND
 * - (recorded distance under IMPLAUSIBLE_SHORT_MAX_KM, OR invalid 0,0 sentinel coords).
 * Payment-agnostic: any trip the scanner sees can hit this rule.
 * Requires an explicit duration signal (field or start/end window) — blank jobs are not treated as 0 min.
 */
export function isImplausibleShortTrip(trip: AnomalyTripLike): boolean {
  const hasExplicitDur =
    (trip.durationMin != null && trip.durationMin !== '') ||
    (trip.duration != null && trip.duration !== '') ||
    !!str(trip.durationLabel);
  const win = tripWindow(trip);
  const hasWindowDur = !!(win.start && win.end && win.end > win.start);
  if (!hasExplicitDur && !hasWindowDur) return false;

  const dur = durationMinOf(trip);
  if (!Number.isFinite(dur) || dur >= IMPLAUSIBLE_SHORT_MAX_MIN) return false;

  if (hasInvalidTripCoords(trip)) return true;

  const dist = recordedDistanceKm(trip);
  if (dist == null) return false;
  return dist < IMPLAUSIBLE_SHORT_MAX_KM;
}

function meterFareOf(trip: AnomalyTripLike): number {
  return num(trip.tmMeterFare ?? trip.meterFare ?? trip.fare ?? trip.totalFare);
}

function tripIdentity(trip: AnomalyTripLike): string {
  return `${str(trip._cid)}/${str(trip._rawKey || trip.bookingId || trip.id)}`;
}

/** Rejected / archived trips do not count toward daily/monthly card limits. */
export function isUsageCountableStatus(status: string | null | undefined): boolean {
  const s = str(status).toLowerCase();
  return s !== 'archived' && s !== 'rejected';
}

function positiveIntLimit(raw: unknown): number | null {
  if (raw == null || raw === '') return null;
  const n = parseInt(String(raw), 10);
  if (!Number.isFinite(n) || n <= 0) return null;
  return n;
}

export function cardDailyTripLimit(card: AnomalyCardLike | null | undefined): number | null {
  if (!card) return null;
  return positiveIntLimit(card.usageLimitDaily ?? card.maxFarePerTrip);
}

export function cardMonthlyTripLimit(card: AnomalyCardLike | null | undefined): number | null {
  if (!card) return null;
  return positiveIntLimit(card.usageLimitMonthly ?? card.monthlyLimit);
}

/** Normalize MM/YY (driver-entered) to YYYY-MM-DD = last day of that month. */
export function mmYyToExpiryDate(raw: unknown): string | null {
  const s = str(raw);
  if (!s) return null;
  const m = s.match(/^(\d{1,2})\s*[\/\-]\s*(\d{2}|\d{4})$/);
  if (!m) return null;
  const month = parseInt(m[1], 10);
  let year = parseInt(m[2], 10);
  if (!Number.isFinite(month) || month < 1 || month > 12) return null;
  if (!Number.isFinite(year)) return null;
  if (year < 100) year += year >= 70 ? 1900 : 2000;
  const lastDay = new Date(Date.UTC(year, month, 0)).getUTCDate();
  return `${year}-${String(month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;
}

/** Prefer registry expiryDate (YYYY-MM-DD); fall back to trip tmCardExpiry MM/YY. */
export function resolveCardExpiryDate(
  card: AnomalyCardLike | null | undefined,
  trip?: AnomalyTripLike | null,
): string | null {
  const fromCard = str(card?.expiryDate).slice(0, 10);
  if (/^\d{4}-\d{2}-\d{2}$/.test(fromCard)) return fromCard;
  return mmYyToExpiryDate(trip?.tmCardExpiry);
}

/**
 * Card is expired at trip time when the trip's NZ calendar day is after the expiry date
 * (card remains valid through its expiry day inclusive).
 */
export function isCardExpiredAtTrip(
  trip: AnomalyTripLike,
  card: AnomalyCardLike | null | undefined,
): boolean {
  const expiry = resolveCardExpiryDate(card, trip);
  if (!expiry) return false;
  const day = tripDayKey(trip as any);
  if (!day) return false;
  return day > expiry;
}

/**
 * 1-based chronological ordinal of this trip among usage-countable same-card peers
 * in the NZ day or month bucket. 0 if bucket/card unknown.
 */
export function cardUsageOrdinal(
  trip: AnomalyTripLike,
  peers: AnomalyTripLike[],
  card: string,
  bucket: 'day' | 'month',
): number {
  const selfKey = tripIdentity(trip);
  const selfBucket = bucket === 'day' ? tripDayKey(trip as any) : tripMonthKeyNz(trip as any);
  if (!selfBucket || !card) return 0;

  const seen = new Set<string>();
  const cohort: { key: string; ms: number }[] = [];
  const all = [trip, ...(peers || [])];
  for (const p of all) {
    if (!p || !isUsageCountableStatus(p.status)) continue;
    const cards = tripCardNumbers(p);
    if (!cards.includes(card)) continue;
    const b = bucket === 'day' ? tripDayKey(p as any) : tripMonthKeyNz(p as any);
    if (b !== selfBucket) continue;
    const key = tripIdentity(p);
    if (!key || key === '/' || seen.has(key)) continue;
    seen.add(key);
    const w = tripWindow(p);
    cohort.push({ key, ms: w.start || w.end || 0 });
  }
  cohort.sort((a, b) => a.ms - b.ms || a.key.localeCompare(b.key));
  const idx = cohort.findIndex((c) => c.key === selfKey);
  return idx < 0 ? 0 : idx + 1;
}

export function lookupAnomalyCard(
  cardsByNumber: Record<string, AnomalyCardLike> | null | undefined,
  cardNumber: string,
): AnomalyCardLike | null {
  if (!cardsByNumber || !cardNumber) return null;
  const direct = cardsByNumber[cardNumber];
  if (direct) return direct;
  const compact = cardNumber.replace(/\s+/g, '');
  if (cardsByNumber[compact]) return cardsByNumber[compact];
  // Case-insensitive fallback
  const want = compact.toLowerCase();
  for (const [k, v] of Object.entries(cardsByNumber)) {
    if (String(k).replace(/\s+/g, '').toLowerCase() === want) return v;
  }
  return null;
}

/** Claim batches may only include approved (or already paid) trips. */
export function isClaimEligibleStatus(status: string | null | undefined): boolean {
  const s = String(status || '').trim().toLowerCase();
  return s === 'approved' || s === 'paid';
}

/**
 * True if this trip was ever anomaly-flagged (even if later cleared / resubmitted).
 * Uses flaggedAt and event log — does not change detection rules.
 */
export function tripWasEverFlagged(
  trip: AnomalyTripLike & {
    flaggedAt?: unknown;
    events?: Record<string, unknown> | null;
  },
): boolean {
  const flaggedAt = trip?.flaggedAt;
  if (flaggedAt != null && flaggedAt !== '' && Number(flaggedAt) !== 0) return true;
  const events = trip?.events;
  if (events && typeof events === 'object') {
    for (const ev of Object.values(events)) {
      if (!ev || typeof ev !== 'object') continue;
      const row = ev as { type?: unknown; toStatus?: unknown };
      const type = String(row.type || '')
        .trim()
        .toLowerCase();
      const to = String(row.toStatus || '')
        .trim()
        .toLowerCase();
      if (type === 'flagged' || to === 'flagged') return true;
    }
  }
  return false;
}

/**
 * True if this trip was ever edited by owner/council/SA (even if later clean).
 * Uses editedAt and event log — does not change edit UI or detection rules.
 */
export function tripWasEverEdited(
  trip: AnomalyTripLike & {
    editedAt?: unknown;
    events?: Record<string, unknown> | null;
  },
): boolean {
  const editedAt = trip?.editedAt;
  if (editedAt != null && editedAt !== '' && Number(editedAt) !== 0) return true;
  const events = trip?.events;
  if (events && typeof events === 'object') {
    for (const ev of Object.values(events)) {
      if (!ev || typeof ev !== 'object') continue;
      const type = String((ev as { type?: unknown }).type || '')
        .trim()
        .toLowerCase();
      if (type === 'owner_edited' || type === 'council_edited' || type === 'sa_edited') {
        return true;
      }
    }
  }
  return false;
}

/**
 * Clean submitted trips that have never been flagged and never edited may auto-approve.
 * Previously-flagged or edited trips (even if now clean) still require manual council approval.
 */
export function shouldAutoApproveCleanTrip(
  trip: AnomalyTripLike & {
    flaggedAt?: unknown;
    editedAt?: unknown;
    events?: Record<string, unknown> | null;
  },
): boolean {
  if (!trip || typeof trip !== 'object') return false;
  const st = String(trip.status || '')
    .trim()
    .toLowerCase();
  if (st !== 'submitted') return false;
  if (tripWasEverFlagged(trip)) return false;
  if (tripWasEverEdited(trip)) return false;
  const reasons = Array.isArray(trip.flagReasons)
    ? trip.flagReasons.map((r) => String(r || '').trim()).filter(Boolean)
    : [];
  if (reasons.length) return false;
  const detail = String(trip.anomalyDetail || '').trim();
  if (detail) return false;
  return true;
}

/** Archived trips are soft-deleted from queues / claims / anomaly auto-moves. */
export function isActiveWorkflowStatus(status: string | null | undefined): boolean {
  const s = String(status || '').trim().toLowerCase();
  return s !== 'archived';
}

export function detectTripAnomalies(
  trip: AnomalyTripLike,
  opts?: {
    peers?: AnomalyTripLike[];
    refTariff?: RefTariff | null;
    cardsByNumber?: Record<string, AnomalyCardLike> | null;
  },
): AnomalyHit {
  const reasons: AnomalyReason[] = [];
  const details: string[] = [];
  const peers = (opts?.peers || []).filter((p) => p && p !== trip);
  const selfKey = tripIdentity(trip);

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

  if (isImplausibleShortTrip(trip)) {
    reasons.push(ANOMALY_IMPLAUSIBLE_SHORT);
    const dur = durationMinOf(trip);
    const dist = recordedDistanceKm(trip);
    if (hasInvalidTripCoords(trip)) {
      details.push(
        `Implausible short trip: ${dur.toFixed(1)} min with invalid 0,0 GPS sentinel (not a real distance)`,
      );
    } else {
      details.push(
        `Implausible short trip: ${dist != null ? dist.toFixed(3) : '?'} km in ${dur.toFixed(1)} min`,
      );
    }
  }

  const cards = tripCardNumbers(trip);
  const selfWin = tripWindow(trip);
  const selfVeh = tripVehicleKey(trip);

  for (const card of cards) {
    for (const peer of peers) {
      const peerKey = tripIdentity(peer);
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

    const registry = lookupAnomalyCard(opts?.cardsByNumber, card);
    if (isCardExpiredAtTrip(trip, registry)) {
      if (!reasons.includes(ANOMALY_CARD_EXPIRED)) {
        reasons.push(ANOMALY_CARD_EXPIRED);
        const expiry = resolveCardExpiryDate(registry, trip) || '?';
        details.push(`Card ${card} expired on ${expiry} (trip day after expiry)`);
      }
    }

    const dailyLimit = cardDailyTripLimit(registry);
    if (dailyLimit != null) {
      const ordinal = cardUsageOrdinal(trip, peers, card, 'day');
      if (ordinal > dailyLimit && !reasons.includes(ANOMALY_LIMIT_DAILY)) {
        reasons.push(ANOMALY_LIMIT_DAILY);
        details.push(
          `Card ${card} daily trip limit exceeded (${ordinal}/${dailyLimit} on ${tripDayKey(trip as any) || 'day'})`,
        );
      }
    }

    const monthlyLimit = cardMonthlyTripLimit(registry);
    if (monthlyLimit != null) {
      const ordinal = cardUsageOrdinal(trip, peers, card, 'month');
      if (ordinal > monthlyLimit && !reasons.includes(ANOMALY_LIMIT_MONTHLY)) {
        reasons.push(ANOMALY_LIMIT_MONTHLY);
        details.push(
          `Card ${card} monthly trip limit exceeded (${ordinal}/${monthlyLimit} in ${tripMonthKeyNz(trip as any) || 'month'})`,
        );
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
  cardsByNumber?: Record<string, AnomalyCardLike> | null,
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

    const hit = detectTripAnomalies(trip, {
      peers: trips,
      refTariff,
      cardsByNumber: cardsByNumber || null,
    });
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
