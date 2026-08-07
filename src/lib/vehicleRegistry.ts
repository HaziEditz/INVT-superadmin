/**
 * Resolve plate (registration) + cab/taxi number from the company vehicle registry.
 * Owner panel writes vehicles/{cid}/{taxiNumber} with registration + taxiNumber;
 * drivers link via assignedVehicles (taxi numbers), not plate fields on the driver profile.
 */

export type VehicleInfo = {
  taxiNumber: string;
  registration: string;
  make: string;
  model: string;
  vehicleType: string;
  label: string;
};

function asRecord(v: unknown): Record<string, unknown> | null {
  if (!v || typeof v !== 'object' || Array.isArray(v)) return null;
  return v as Record<string, unknown>;
}

/** Read one vehicle node — company-scoped or flat push-key shape. */
export function readVehicleNode(node: unknown, fallbackTaxi = ''): VehicleInfo | null {
  const o = asRecord(node);
  if (!o) return null;
  const taxiNumber = String(
    o.taxiNumber || o.vehicleNo || o.taxiNo || o.cabNumber || o.CabNumber || fallbackTaxi || '',
  ).trim();
  const registration = String(
    o.registration || o.plate || o.plateNumber || o.licensePlate || o.rego || '',
  )
    .trim()
    .toUpperCase();
  const make = String(o.make || o.vehicleMake || '').trim();
  const model = String(o.model || o.vehicleModel || '').trim();
  const vehicleType = String(o.vehicleType || o.type || o.VehicleType || '').trim();
  if (!taxiNumber && !registration && !make && !model) return null;
  const label = [make, model].filter(Boolean).join(' ') || taxiNumber || registration || '—';
  return { taxiNumber, registration, make, model, vehicleType, label };
}

export function companyVehicleMap(
  vehiclesRoot: Record<string, unknown> | null | undefined,
  companyId: string,
): Record<string, VehicleInfo> {
  const cid = String(companyId || '').trim();
  const out: Record<string, VehicleInfo> = {};
  if (!cid || !vehiclesRoot || typeof vehiclesRoot !== 'object') return out;

  const bucket = asRecord(vehiclesRoot[cid]);
  if (bucket) {
    for (const [key, val] of Object.entries(bucket)) {
      const info = readVehicleNode(val, key);
      if (!info) continue;
      const mapKey = (info.taxiNumber || key).toLowerCase();
      out[mapKey] = info;
      if (key.toLowerCase() !== mapKey) out[key.toLowerCase()] = info;
    }
  }

  // Flat legacy nodes with companyId on the vehicle itself
  for (const [key, val] of Object.entries(vehiclesRoot)) {
    if (key === cid) continue;
    const o = asRecord(val);
    if (!o) continue;
    const rowCid = String(o.companyId || o.company_id || '').trim();
    if (rowCid !== cid) continue;
    const info = readVehicleNode(o, key);
    if (!info) continue;
    const mapKey = (info.taxiNumber || key).toLowerCase();
    if (!out[mapKey]) out[mapKey] = info;
  }
  return out;
}

function assignedTaxiNos(driver: Record<string, unknown>): string[] {
  const out: string[] = [];
  const arr = driver.assignedVehicles;
  if (Array.isArray(arr)) {
    for (const v of arr) {
      if (v == null) continue;
      if (typeof v === 'object') {
        const o = v as Record<string, unknown>;
        const n = String(o.taxiNumber || o.vehicleNo || o.id || '').trim();
        if (n) out.push(n);
      } else {
        const n = String(v).trim();
        if (n) out.push(n);
      }
    }
  } else if (arr && typeof arr === 'object') {
    for (const v of Object.values(arr as Record<string, unknown>)) {
      const n = String(v || '').trim();
      if (n) out.push(n);
    }
  }
  for (const k of ['taxiNumber', 'vehicleNo', 'currentTaxi', 'currentVehicle', 'vehicleId', 'taxi']) {
    const n = String(driver[k] || '').trim();
    if (n && !out.includes(n)) out.push(n);
  }
  return out;
}

/** Primary assigned vehicle for a driver (first match in company registry). */
export function resolveDriverVehicle(
  vehiclesRoot: Record<string, unknown> | null | undefined,
  companyId: string,
  driver: Record<string, unknown>,
): VehicleInfo {
  const map = companyVehicleMap(vehiclesRoot, companyId);
  const taxis = assignedTaxiNos(driver);
  for (const t of taxis) {
    const hit = map[t.toLowerCase()];
    if (hit) return hit;
  }
  // Fallback: driver profile fields (often empty in practice)
  const registration = String(
    driver.licensePlate || driver.vehiclePlate || driver.registration || driver.plate || '',
  )
    .trim()
    .toUpperCase();
  const taxiNumber = taxis[0] || String(driver.taxiNumber || driver.vehicleNo || '').trim();
  const make = String(driver.vehicleMake || '').trim();
  const model = String(driver.vehicleModel || driver.vehicle || '').trim();
  const vehicleType = String(driver.vehicleType || '').trim();
  return {
    taxiNumber,
    registration,
    make,
    model,
    vehicleType,
    label: [make, model].filter(Boolean).join(' ') || taxiNumber || registration || '—',
  };
}
