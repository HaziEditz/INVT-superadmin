/**
 * Resolve plate (registration) + cab/taxi number from company vehicle registry.
 * Mirror of src/lib/vehicleRegistry.ts for browser / node:test.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.BWVehicleRegistry = factory();
  }
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  function asRecord(v) {
    if (!v || typeof v !== 'object' || Array.isArray(v)) return null;
    return v;
  }

  function readVehicleNode(node, fallbackTaxi) {
    var o = asRecord(node);
    if (!o) return null;
    var taxiNumber = String(
      o.taxiNumber || o.vehicleNo || o.taxiNo || o.cabNumber || o.CabNumber || fallbackTaxi || '',
    ).trim();
    var registration = String(
      o.registration || o.plate || o.plateNumber || o.licensePlate || o.rego || '',
    )
      .trim()
      .toUpperCase();
    var make = String(o.make || o.vehicleMake || '').trim();
    var model = String(o.model || o.vehicleModel || '').trim();
    var vehicleType = String(o.vehicleType || o.type || o.VehicleType || '').trim();
    if (!taxiNumber && !registration && !make && !model) return null;
    var label = [make, model].filter(Boolean).join(' ') || taxiNumber || registration || '—';
    return { taxiNumber: taxiNumber, registration: registration, make: make, model: model, vehicleType: vehicleType, label: label };
  }

  function companyVehicleMap(vehiclesRoot, companyId) {
    var cid = String(companyId || '').trim();
    var out = {};
    if (!cid || !vehiclesRoot || typeof vehiclesRoot !== 'object') return out;
    var bucket = asRecord(vehiclesRoot[cid]);
    if (bucket) {
      Object.keys(bucket).forEach(function (key) {
        var info = readVehicleNode(bucket[key], key);
        if (!info) return;
        var mapKey = (info.taxiNumber || key).toLowerCase();
        out[mapKey] = info;
        if (key.toLowerCase() !== mapKey) out[key.toLowerCase()] = info;
      });
    }
    Object.keys(vehiclesRoot).forEach(function (key) {
      if (key === cid) return;
      var o = asRecord(vehiclesRoot[key]);
      if (!o) return;
      var rowCid = String(o.companyId || o.company_id || '').trim();
      if (rowCid !== cid) return;
      var info = readVehicleNode(o, key);
      if (!info) return;
      var mapKey = (info.taxiNumber || key).toLowerCase();
      if (!out[mapKey]) out[mapKey] = info;
    });
    return out;
  }

  function assignedTaxiNos(driver) {
    var out = [];
    var arr = driver && driver.assignedVehicles;
    if (Array.isArray(arr)) {
      arr.forEach(function (v) {
        if (v == null) return;
        if (typeof v === 'object') {
          var n = String(v.taxiNumber || v.vehicleNo || v.id || '').trim();
          if (n) out.push(n);
        } else {
          var n2 = String(v).trim();
          if (n2) out.push(n2);
        }
      });
    } else if (arr && typeof arr === 'object') {
      Object.keys(arr).forEach(function (k) {
        var n = String(arr[k] || '').trim();
        if (n) out.push(n);
      });
    }
    ['taxiNumber', 'vehicleNo', 'currentTaxi', 'currentVehicle', 'vehicleId', 'taxi'].forEach(function (k) {
      var n = String((driver && driver[k]) || '').trim();
      if (n && out.indexOf(n) === -1) out.push(n);
    });
    return out;
  }

  function resolveDriverVehicle(vehiclesRoot, companyId, driver) {
    var map = companyVehicleMap(vehiclesRoot, companyId);
    var taxis = assignedTaxiNos(driver || {});
    for (var i = 0; i < taxis.length; i++) {
      var hit = map[taxis[i].toLowerCase()];
      if (hit) return hit;
    }
    var registration = String(
      (driver && (driver.licensePlate || driver.vehiclePlate || driver.registration || driver.plate)) || '',
    )
      .trim()
      .toUpperCase();
    var taxiNumber = taxis[0] || String((driver && (driver.taxiNumber || driver.vehicleNo)) || '').trim();
    var make = String((driver && driver.vehicleMake) || '').trim();
    var model = String((driver && (driver.vehicleModel || driver.vehicle)) || '').trim();
    var vehicleType = String((driver && driver.vehicleType) || '').trim();
    return {
      taxiNumber: taxiNumber,
      registration: registration,
      make: make,
      model: model,
      vehicleType: vehicleType,
      label: [make, model].filter(Boolean).join(' ') || taxiNumber || registration || '—',
    };
  }

  return {
    readVehicleNode: readVehicleNode,
    companyVehicleMap: companyVehicleMap,
    resolveDriverVehicle: resolveDriverVehicle,
  };
});
