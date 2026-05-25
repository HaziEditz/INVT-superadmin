/**
 * Server-side notification relay — mirrors the former client-side relay in
 * Bookawaka-Driver-Portal (DriverContext.tsx).
 *
 * Legacy dispatch consoles sometimes write job offers to notification/{vehicleId}
 * (e.g. "TAXI02"). The driver app listens on notification/{driverId} (e.g. "D002").
 * This service forwards vehicle-keyed writes to the matching driverId path so offers
 * arrive even when the driver app is backgrounded or killed.
 */

import https from 'https';
import { DB_HOSTNAME, DB_SECRET, fbReadP, fbWriteP } from './firebase';

const TAG = '[notif-relay]';
const MAP_REFRESH_MS = 5 * 60 * 1000;
const RECONNECT_MS = 5000;

const vehicleToDriver = new Map<string, string>();
const driverIdKeys = new Set<string>();
const inFlight = new Set<string>();

let streamReady = false;
let reconnectTimer: ReturnType<typeof setTimeout> | null = null;

function isOwnOutgoing(data: Record<string, unknown>, vid: string, did: string): boolean {
  const bookingIdStr = String(data.bookingid ?? data.BookingId ?? '');
  const parts = bookingIdStr.split(',');
  const notifSender = parts[4]?.trim() ?? '';
  const isFromDispatcher = parts.some((p) => p.trim() === 'Dispatcher');
  return !isFromDispatcher && (notifSender === vid || notifSender === did);
}

async function refreshDriverMaps(): Promise<void> {
  try {
    vehicleToDriver.clear();
    driverIdKeys.clear();

    const drivers = await fbReadP('drivers');
    if (drivers && typeof drivers === 'object') {
      for (const d of Object.values(drivers) as Record<string, unknown>[]) {
        if (!d || typeof d !== 'object') continue;
        const did = String(d.dispatcherId ?? d.id ?? '').trim();
        if (!did) continue;
        driverIdKeys.add(did);

        const allocated = d.allocatedVehicles;
        if (allocated && typeof allocated === 'object') {
          for (const [vid, on] of Object.entries(allocated as Record<string, unknown>)) {
            if (on) vehicleToDriver.set(vid, did);
          }
        }
        const taxi = d.allocatedTaxi;
        if (taxi) vehicleToDriver.set(String(taxi), did);
      }
    }

    const online = await fbReadP('online');
    if (online && typeof online === 'object') {
      for (const vehicles of Object.values(online) as Record<string, unknown>[]) {
        if (!vehicles || typeof vehicles !== 'object') continue;
        for (const [vid, node] of Object.entries(vehicles)) {
          if (!node || typeof node !== 'object') continue;
          const current = (node as Record<string, unknown>).current;
          if (!current || typeof current !== 'object') continue;
          const cur = current as Record<string, unknown>;
          const did = String(cur.driverid ?? cur.driverId ?? cur.DriverId ?? '').trim();
          if (did) vehicleToDriver.set(vid, did);
        }
      }
    }

    console.log(`${TAG} maps refreshed — ${driverIdKeys.size} driver ids, ${vehicleToDriver.size} vehicle mappings`);
  } catch (err: any) {
    console.error(`${TAG} map refresh failed:`, err?.message || err);
  }
}

async function relayVehicleNotification(vid: string, data: Record<string, unknown>): Promise<void> {
  if (inFlight.has(vid)) return;
  if (vid.endsWith('_TM')) return;

  const did = vehicleToDriver.get(vid);
  if (!did || did === vid) return;
  if (driverIdKeys.has(vid)) return;

  if (isOwnOutgoing(data, vid, did)) {
    console.log(`${TAG} own outgoing at notification/${vid} — leaving for dispatcher`);
    return;
  }

  inFlight.add(vid);
  try {
    console.log(`${TAG} relay notification/${vid} → notification/${did}`);
    await fbWriteP('PUT', `notification/${did}`, data);
    await fbWriteP('DELETE', `notification/${vid}`, null);
  } catch (err: any) {
    console.error(`${TAG} relay failed ${vid} → ${did}:`, err?.message || err);
  } finally {
    inFlight.delete(vid);
  }
}

function handleStreamEvent(eventType: string, path: string, data: unknown): void {
  if (eventType !== 'put') return;

  // Skip the initial bulk sync — only relay live deltas so a server restart
  // does not re-fire stale offers already sitting in Firebase.
  if (path === '/') {
    streamReady = true;
    return;
  }
  if (!streamReady) return;
  if (data === null || data === undefined) return;
  if (typeof data !== 'object') return;

  const key = path.replace(/^\//, '');
  if (!key) return;
  relayVehicleNotification(key, data as Record<string, unknown>).catch(() => {});
}

function parseSseBlock(block: string, onEvent: (type: string, dataLine: string) => void): void {
  let eventType = 'message';
  let dataLine = '';
  for (const line of block.split('\n')) {
    if (line.startsWith('event:')) eventType = line.slice(6).trim();
    else if (line.startsWith('data:')) dataLine = line.slice(5).trim();
  }
  if (dataLine) onEvent(eventType, dataLine);
}

function connectNotificationStream(): void {
  if (!DB_SECRET) {
    console.warn(`${TAG} FIREBASE_DB_SECRET not set — relay disabled`);
    return;
  }

  streamReady = false;
  const qs = `auth=${encodeURIComponent(DB_SECRET)}`;
  const req = https.request(
    {
      hostname: DB_HOSTNAME,
      path: `/notification.json?${qs}`,
      method: 'GET',
      headers: { Accept: 'text/event-stream' },
    },
    (res) => {
      if (res.statusCode !== 200) {
        console.error(`${TAG} stream HTTP ${res.statusCode} — reconnecting in ${RECONNECT_MS}ms`);
        scheduleReconnect();
        return;
      }

      console.log(`${TAG} Firebase SSE connected on /notification`);
      let buffer = '';

      res.on('data', (chunk: Buffer) => {
        buffer += chunk.toString('utf8');
        let sep: number;
        while ((sep = buffer.indexOf('\n\n')) >= 0) {
          const block = buffer.slice(0, sep);
          buffer = buffer.slice(sep + 2);
          parseSseBlock(block, (eventType, dataLine) => {
            try {
              const parsed = JSON.parse(dataLine) as { path?: string; data?: unknown };
              handleStreamEvent(eventType, parsed.path ?? '', parsed.data);
            } catch (err: any) {
              console.warn(`${TAG} bad SSE payload:`, err?.message || err);
            }
          });
        }
      });

      res.on('end', () => {
        console.warn(`${TAG} stream ended — reconnecting in ${RECONNECT_MS}ms`);
        scheduleReconnect();
      });
    }
  );

  req.on('error', (err) => {
    console.error(`${TAG} stream error:`, err.message, `— reconnecting in ${RECONNECT_MS}ms`);
    scheduleReconnect();
  });
  req.end();
}

function scheduleReconnect(): void {
  if (reconnectTimer) return;
  reconnectTimer = setTimeout(() => {
    reconnectTimer = null;
    connectNotificationStream();
  }, RECONNECT_MS);
}

export function startNotificationRelay(): void {
  if (!DB_SECRET) {
    console.warn(`${TAG} disabled — set FIREBASE_DB_SECRET to enable`);
    return;
  }

  refreshDriverMaps()
    .then(() => connectNotificationStream())
    .catch((err) => console.error(`${TAG} startup failed:`, err?.message || err));

  setInterval(() => {
    refreshDriverMaps().catch(() => {});
  }, MAP_REFRESH_MS);
}
