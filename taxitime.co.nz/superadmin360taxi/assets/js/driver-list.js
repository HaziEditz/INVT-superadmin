/**
 * Merge nested drivers/{cid}/{uid} + flat drivers/{key} with companyId,
 * then dedupe by person identity (uid / email / dispatcherId / phone).
 * Nested records win over flat duplicates.
 * Keep in sync with src/lib/driverList.ts
 */
(function (root) {
  'use strict';

  function looksLikeDriver(d) {
    if (!d || typeof d !== 'object') return false;
    return !!(
      d.email ||
      d.uid ||
      d.dispatcherId ||
      d.firstName ||
      d.lastName ||
      d.name ||
      d.phone ||
      d.mobileNumber ||
      d.mobile
    );
  }

  function isDriverActive(d) {
    return d.active !== false && d.status !== 'inactive' && d.status !== 'suspended';
  }

  function isDriverWav(d) {
    var vt = String(d.vehicleType || '').toLowerCase();
    return !!(
      d.isWheelchairAccessible ||
      d.accessible ||
      d.wav ||
      vt.indexOf('wheelchair') !== -1 ||
      vt.indexOf('wav') !== -1
    );
  }

  function looksLikeFirebasePushKey(k) {
    return typeof k === 'string' && k.charAt(0) === '-';
  }

  function driverIdentityKeys(rtdbKey, d) {
    var keys = [];
    var uid = String(d.uid || d.dispatcherId || d.id || '')
      .trim()
      .toLowerCase();
    if (uid) {
      keys.push('uid:' + uid);
    } else if (rtdbKey && !looksLikeFirebasePushKey(rtdbKey)) {
      keys.push('uid:' + String(rtdbKey).trim().toLowerCase());
    }
    var email = String(d.email || '')
      .trim()
      .toLowerCase();
    if (email) keys.push('email:' + email);
    var phone = String(d.phone || d.mobileNumber || d.mobile || '').replace(/\D/g, '');
    if (phone.length >= 7) keys.push('phone:' + phone);
    if (!keys.length && rtdbKey) keys.push('key:' + rtdbKey);
    return keys;
  }

  function isNestedCompanyBucket(key, val) {
    var kids = Object.keys(val || {});
    if (!kids.length) return false;
    var sample = null;
    for (var i = 0; i < kids.length; i++) {
      var c = val[kids[i]];
      if (c && typeof c === 'object') {
        sample = c;
        break;
      }
    }
    if (!sample) return false;
    return looksLikeDriver(sample) && !looksLikeDriver(val);
  }

  function listDriversForCompany(raw, companyId, opts) {
    opts = opts || {};
    var cid = String(companyId || '').trim();
    if (!cid || !raw || typeof raw !== 'object') return [];

    var nested = [];
    var flat = [];
    var nestedBucket = raw[cid];
    if (nestedBucket && typeof nestedBucket === 'object' && !Array.isArray(nestedBucket)) {
      Object.keys(nestedBucket).forEach(function (uid) {
        var d = nestedBucket[uid];
        if (!looksLikeDriver(d)) return;
        nested.push(Object.assign({}, d, { _uid: uid, _source: 'nested' }));
      });
    }

    Object.keys(raw).forEach(function (key) {
      if (key === cid) return;
      var val = raw[key];
      if (!val || typeof val !== 'object' || Array.isArray(val)) return;
      if (isNestedCompanyBucket(key, val)) return;
      if (!looksLikeDriver(val)) return;
      var rowCid = String(val.companyId || val.company_id || '').trim();
      if (rowCid !== cid) return;
      flat.push(Object.assign({}, val, { _uid: key, _source: 'flat' }));
    });

    var ordered = nested.concat(flat);
    var seen = {};
    var out = [];
    ordered.forEach(function (d) {
      var idKeys = driverIdentityKeys(String(d._uid || ''), d);
      for (var i = 0; i < idKeys.length; i++) {
        if (seen[idKeys[i]]) return;
      }
      idKeys.forEach(function (k) {
        seen[k] = true;
      });
      if (opts.activeOnly && !isDriverActive(d)) return;
      out.push(d);
    });
    return out;
  }

  function flattenAllDrivers(raw) {
    if (!raw || typeof raw !== 'object') return [];
    var nested = [];
    var flat = [];
    Object.keys(raw).forEach(function (key) {
      var val = raw[key];
      if (!val || typeof val !== 'object' || Array.isArray(val)) return;
      if (isNestedCompanyBucket(key, val)) {
        Object.keys(val).forEach(function (uid) {
          var d = val[uid];
          if (!looksLikeDriver(d)) return;
          nested.push(
            Object.assign({}, d, {
              _uid: uid,
              companyId: String(d.companyId || d.company_id || key),
              _source: 'nested',
            }),
          );
        });
        return;
      }
      if (!looksLikeDriver(val)) return;
      flat.push(Object.assign({}, val, { _uid: key, _source: 'flat' }));
    });
    var ordered = nested.concat(flat);
    var seen = {};
    var out = [];
    ordered.forEach(function (d) {
      var idKeys = driverIdentityKeys(String(d._uid || ''), d);
      for (var i = 0; i < idKeys.length; i++) {
        if (seen[idKeys[i]]) return;
      }
      idKeys.forEach(function (k) {
        seen[k] = true;
      });
      out.push(d);
    });
    return out;
  }

  var api = {
    looksLikeDriver: looksLikeDriver,
    isDriverActive: isDriverActive,
    isDriverWav: isDriverWav,
    driverIdentityKeys: driverIdentityKeys,
    listDriversForCompany: listDriversForCompany,
    flattenAllDrivers: flattenAllDrivers,
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;
  }
  root.BWDriverList = api;
})(typeof window !== 'undefined' ? window : globalThis);
