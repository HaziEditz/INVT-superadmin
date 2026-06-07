var COMPANY_ID = null;          // Set after login resolves — null for SA admins, a CID string for owner-portal users
var IS_SUPER_ADMIN = false;     // true when the logged-in user is a BookaWaka SA admin

/* ── Firebase Proxy Helpers ───────────────────────────────────────────────────
   All Firebase reads/writes go via /api/fb on the server, which authenticates
   using the FIREBASE_DB_SECRET. No client-side Firebase auth needed.
   ─────────────────────────────────────────────────────────────────────────── */

function _fbGet(path, opts) {
  var qs = '/api/fb?path=' + encodeURIComponent(path);
  if (opts) {
    if (opts.limitToLast) qs += '&limitToLast=' + opts.limitToLast;
    if (opts.orderBy)     qs += '&orderBy=' + encodeURIComponent(opts.orderBy);
  }
  return fetch(qs).then(function(r) {
    return r.json().then(function(data) {
      if (data && typeof data === 'object' && typeof data.error === 'string' && Object.keys(data).length === 1) {
        throw new Error(data.error);
      }
      return data;
    });
  });
}
function _fbPost(path, method, data) {
  return fetch('/api/fb', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ path: path, method: method, data: data })
  }).then(function(r) { return r.json(); });
}

/* Build a full Firebase-compatible snapshot object from a raw value */
function _makeSnap(val, pathKey) {
  return {
    val:      function() { return val; },
    exists:   function() { return val !== null && val !== undefined; },
    key:      pathKey || null,
    forEach:  function(cb) {
      if (val && typeof val === 'object') {
        Object.keys(val).forEach(function(k) { cb(_makeSnap(val[k], k)); });
      }
    },
    child:    function(c) { return _makeSnap(val && val[c] !== undefined ? val[c] : null, c); },
    numChildren: function() { return val && typeof val === 'object' ? Object.keys(val).length : 0; }
  };
}

/* Ref shim with options (limitToLast, orderBy) — opts are carried through the chain */
function _makeRefWithOpts(path, opts) {
  var _pathKey = path.split('/').pop();
  var shim = _makeRef(path);
  shim.once = function(evt, cb) {
    var p = _fbGet(path, opts).then(function(val) {
      if (opts && opts.limitToLast && val && typeof val === 'object') {
        var keys = Object.keys(val);
        if (keys.length > opts.limitToLast) {
          var trimmed = {};
          keys.slice(-opts.limitToLast).forEach(function(k) { trimmed[k] = val[k]; });
          val = trimmed;
        }
      }
      return _makeSnap(val, _pathKey);
    });
    if (typeof cb === 'function') { p.then(cb).catch(function(){}); return; }
    return p;
  };
  /* Allow further chaining — merge new opts on top of existing ones */
  shim.limitToLast  = function(n) { return _makeRefWithOpts(path, Object.assign({}, opts, { limitToLast: n })); };
  shim.orderByChild = function(f) { return _makeRefWithOpts(path, Object.assign({}, opts, { orderBy: f })); };
  shim.orderByKey   = function()  { return _makeRefWithOpts(path, Object.assign({}, opts, { orderBy: '$key' })); };
  shim.orderByValue = function()  { return _makeRefWithOpts(path, Object.assign({}, opts, { orderBy: '$value' })); };
  shim.startAt = function() { return shim; };
  shim.endAt   = function() { return shim; };
  return shim;
}

/* Ref shim — mimics firebase.database().ref(path) API */
function _makeRef(path) {
  var _pathKey = path.split('/').pop();
  return {
    once: function(evt, cb) {
      var p = _fbGet(path).then(function(val) {
        return _makeSnap(val, _pathKey);
      });
      if (typeof cb === 'function') { p.then(cb).catch(function(){}); return; }
      return p;
    },
    on: function(evt, cb, errCb) {
      function poll() {
        _fbGet(path).then(function(val) {
          try { cb(_makeSnap(val, _pathKey)); } catch(e) {}
        }).catch(function(e) { if (typeof errCb === 'function') errCb(e); });
      }
      poll();
      return setInterval(poll, 6000);
    },
    off: function(iv) { if (iv) clearInterval(iv); },
    update: function(data) { return _fbPost(path, 'PATCH', data); },
    set:    function(data) { return _fbPost(path, 'PUT', data); },
    remove: function()     { return _fbPost(path, 'DELETE', null); },
    push:   function(data) {
      var key = '-' + Date.now() + Math.random().toString(36).slice(2, 7);
      return _fbPost(path + '/' + key, 'PUT', data).then(function(r) {
        return { key: key };
      });
    },
    child:  function(c)    { return _makeRef(path + '/' + c); },
    orderByChild: function(f) { return _makeRefWithOpts(path, { orderBy: f }); },
    orderByKey:   function()  { return _makeRefWithOpts(path, { orderBy: '$key' }); },
    orderByValue: function()  { return _makeRefWithOpts(path, { orderBy: '$value' }); },
    startAt: function() { return _makeRef(path); },
    endAt:   function() { return _makeRef(path); },
    limitToLast: function(n) { return _makeRefWithOpts(path, { limitToLast: n, orderBy: '$key' }); }
  };
}

/* db shim — drop-in replacement for firebase.database() */
var db = { ref: function(path) { return _makeRef(path); } };

/* Public helpers used by some pages */
window.adminRead  = function(p) { return _fbGet(p); };
window.adminWrite = function(p, method, data) { return _fbPost(p, method, data); };
window.adminListen = function(p, cb, ms) {
  var iv = setInterval(function() {
    _fbGet(p).then(cb).catch(function(){});
  }, ms || 6000);
  _fbGet(p).then(cb).catch(function(){});
  return iv;
};
window.fbProxy = {
  read: _fbGet,
  set:  function(p,d) { return _fbPost(p,'PUT',d); },
  patch: function(p,d){ return _fbPost(p,'PATCH',d); },
  remove: function(p) { return _fbPost(p,'DELETE',null); }
};

/* ── SA View-As Banner ────────────────────────────────────────────────────────
   Injected on every page when an SA admin is viewing as another company.
   ─────────────────────────────────────────────────────────────────────────── */
function _injectViewAsBanner(cidName, cid) {
  if (document.getElementById('sa-view-banner')) return;
  var banner = document.createElement('div');
  banner.id = 'sa-view-banner';
  banner.style.cssText = [
    'position:fixed', 'top:0', 'left:0', 'right:0', 'z-index:999999',
    'background:#E65100', 'color:#fff',
    'padding:9px 18px',
    'font-size:13px', 'font-weight:600',
    'display:flex', 'align-items:center', 'justify-content:space-between',
    'gap:12px', 'box-shadow:0 2px 8px rgba(0,0,0,.35)',
    'font-family:inherit'
  ].join(';');
  banner.innerHTML =
    '<div style="display:flex;align-items:center;gap:10px">' +
      '<span style="font-size:16px">&#128065;</span>' +
      '<span>Viewing as: <strong>' + _escBanner(cidName) + '</strong>' +
      '&ensp;<span style="opacity:.65;font-weight:400;font-size:12px">Company ID: ' + _escBanner(cid) + '</span></span>' +
    '</div>' +
    '<a id="sa-view-exit" href="SA-Clients.aspx" ' +
      'style="background:rgba(0,0,0,.28);color:#fff;padding:5px 16px;border-radius:4px;' +
             'text-decoration:none;font-size:12px;border:1px solid rgba(255,255,255,.35);' +
             'white-space:nowrap;cursor:pointer">' +
      '&#x2715;&nbsp; Exit View' +
    '</a>';
  document.body.insertBefore(banner, document.body.firstChild);

  var exitBtn = document.getElementById('sa-view-exit');
  if (exitBtn) {
    exitBtn.addEventListener('click', function() {
      try { sessionStorage.removeItem('saViewToken'); } catch(e) {}
    });
  }

  /* Push the fixed header down so it doesn't hide under the banner */
  function _pushHeader() {
    var h = document.getElementById('header_main');
    if (h) { h.style.top = '40px'; }
    var pc = document.getElementById('page_content');
    if (pc) { pc.style.paddingTop = ((parseInt(pc.style.paddingTop) || 0) + 40) + 'px'; }
    var sb = document.getElementById('sidebar_main');
    if (sb) { sb.style.top = ((parseInt(sb.style.top) || 70) + 40) + 'px'; }
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', _pushHeader);
  } else {
    _pushHeader();
  }
}

function _escBanner(s) {
  return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/* ── SA "View as Company" launcher ───────────────────────────────────────────
   Call from any SA page: openViewAs(cid, companyName)
   Validates with the server and opens the dashboard in the current tab.
   ─────────────────────────────────────────────────────────────────────────── */
window.openViewAs = function(cid, cidName) {
  if (!cid) { alert('No Company ID'); return; }
  var user = (typeof firebase !== 'undefined' && firebase.auth) ? firebase.auth().currentUser : null;
  if (!user) { alert('Not logged in'); return; }
  var btn = document.getElementById('view-as-btn-' + cid);
  if (btn) { btn.disabled = true; btn.textContent = 'Opening…'; }
  fetch('/api/admin/view-as', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ cid: cid, cidName: cidName || cid, saUid: user.uid })
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.token) {
      window.location.href = 'Home.aspx?saView=' + encodeURIComponent(d.token);
    } else {
      if (btn) { btn.disabled = false; btn.textContent = '👁 View as'; }
      alert('Error: ' + (d.error || 'unknown'));
    }
  })
  .catch(function() {
    if (btn) { btn.disabled = false; btn.textContent = '👁 View as'; }
    alert('Network error — please try again');
  });
};

/* ── Auth-aware init ──────────────────────────────────────────────────────────
   Waits for Firebase Auth state, then determines the user's role:

   1. Check superAdmins/{uid} — if true, user is a BookaWaka SA admin.
      Sets IS_SUPER_ADMIN = true, COMPANY_ID stays null.
      Then handles the View-As flow for viewing as a specific company.

   2. Otherwise look up adminAccess/{cid}/{uid} — sets COMPANY_ID for
      owner-portal users. (Non-SA path.)

   Redirects to SA-Login.aspx if no user is authenticated.
   ─────────────────────────────────────────────────────────────────────────── */
function _resolveCompanyAndInit() {
  if (typeof firebase === 'undefined' || !firebase.auth) {
    if (typeof window._fbOnLogin === 'function') window._fbOnLogin();
    return;
  }

  firebase.auth().onAuthStateChanged(function(user) {
    if (!user) {
      var here = window.location.pathname;
      if (here.indexOf('SA-Login') === -1) {
        window.location.href = 'SA-Login.aspx';
      }
      return;
    }

    var uid = user.uid;

    /* Step 1: Check if this user is a BookaWaka SA admin */
    _fbGet('superAdmins/' + uid).then(function(saVal) {
      if (saVal === true) {
        IS_SUPER_ADMIN = true;
        window.IS_SUPER_ADMIN = true;
        COMPANY_ID = null;
        console.log('[tm-helpers] SA admin confirmed for uid', uid);
        _handleViewAs(uid);
        return;
      }

      /* Step 2: Not SA — look up owner company via adminAccess */
      _fbGet('adminAccess').then(function(accessMap) {
        var foundCid = null;
        if (accessMap && typeof accessMap === 'object') {
          Object.keys(accessMap).forEach(function(cid) {
            if (!foundCid && accessMap[cid] && accessMap[cid][uid] === true) {
              foundCid = cid;
            }
          });
        }
        if (foundCid) {
          COMPANY_ID = foundCid;
          console.log('[tm-helpers] Owner company resolved to', COMPANY_ID, 'for uid', uid);
        } else {
          console.warn('[tm-helpers] No role found for uid', uid, '— access may be denied by the page');
        }
        _wireCompanyPortalLinks();
        if (typeof window._fbOnLogin === 'function') window._fbOnLogin();
      }).catch(function(err) {
        console.error('[tm-helpers] adminAccess lookup failed:', err);
        if (typeof window._fbOnLogin === 'function') window._fbOnLogin();
      });
    }).catch(function(err) {
      console.error('[tm-helpers] superAdmins lookup failed:', err);
      if (typeof window._fbOnLogin === 'function') window._fbOnLogin();
    });
  });
}

/* ── View-As flow (SA admins only) ───────────────────────────────────────────
   Checks for a ?saView= token or sessionStorage token, validates it, and
   switches COMPANY_ID to the target company for the duration of the session.
   ─────────────────────────────────────────────────────────────────────────── */
function _handleViewAs(uid) {
  var urlParams = new URLSearchParams(window.location.search);
  var urlToken  = urlParams.get('saView');

  /* Persist token from URL to sessionStorage and clean the URL */
  if (urlToken) {
    try { sessionStorage.setItem('saViewToken', urlToken); } catch(e) {}
    var cleaned = window.location.pathname;
    var remainingParams = [];
    urlParams.forEach(function(v, k) { if (k !== 'saView') remainingParams.push(k + '=' + encodeURIComponent(v)); });
    if (remainingParams.length) cleaned += '?' + remainingParams.join('&');
    if (window.history && window.history.replaceState) {
      window.history.replaceState({}, '', cleaned);
    }
  }

  var token = urlToken || (function(){ try { return sessionStorage.getItem('saViewToken'); } catch(e){ return null; } })();

  if (token) {
    fetch('/api/admin/sa-view-session?token=' + encodeURIComponent(token))
      .then(function(r) { return r.json(); })
      .then(function(d) {
        if (d.cid) {
          COMPANY_ID = d.cid;
          window.SA_VIEW_AS = { cid: d.cid, cidName: d.cidName };
          console.log('[tm-helpers] View-As mode: COMPANY_ID =', COMPANY_ID);
          _wireCompanyPortalLinks();
          _injectViewAsBanner(d.cidName, d.cid);
        } else {
          try { sessionStorage.removeItem('saViewToken'); } catch(e) {}
          console.warn('[tm-helpers] View-As token invalid:', d.error);
        }
        if (typeof window._fbOnLogin === 'function') window._fbOnLogin();
      })
      .catch(function(err) {
        try { sessionStorage.removeItem('saViewToken'); } catch(e) {}
        console.error('[tm-helpers] View-As session check failed:', err);
        if (typeof window._fbOnLogin === 'function') window._fbOnLogin();
      });
    return;
  }

  /* No view-as token — SA admin on their own portal */
  _wireCompanyPortalLinks();
  if (typeof window._fbOnLogin === 'function') window._fbOnLogin();
}

/* ── Company Portal link wiring ───────────────────────────────────────────────
   Updates every "Company Portal" sidebar link to include ?cid=COMPANY_ID so
   the server-side redirect carries the company context through.
   SA admins have COMPANY_ID=null so links are hidden — they use View-As instead.
   ─────────────────────────────────────────────────────────────────────────── */
function _wireCompanyPortalLinks() {
  var links = document.querySelectorAll('a[href="/company-portal"], a[href^="/company-portal?"]');
  links.forEach(function(a) {
    if (!COMPANY_ID) {
      a.style.display = 'none'; /* SA admins don't have their own owner portal */
    } else {
      a.href = '/company-portal?cid=' + encodeURIComponent(COMPANY_ID);
      a.title = 'Open Owner Portal for company ' + COMPANY_ID;
    }
  });
}

document.addEventListener('DOMContentLoaded', _resolveCompanyAndInit);

/* ── Timezone Utilities ──────────────────────────────────────────────────────
   RULE FOR ALL APPS:
   • Store ALL timestamps in Firebase as UTC ISO 8601 strings produced by
     new Date().toISOString()  →  e.g. "2026-01-01T11:00:00.000Z"
   • NEVER store local-time strings without an explicit timezone offset.
   • DISPLAY and GROUP by converting UTC → the company's configured IANA timezone.
   • NEVER use new Date().setHours(0,0,0,0) for "midnight" — that anchors to
     whatever timezone the server/device happens to be in.
   • NEVER use .toISOString().slice(0,10) for a local date — toISOString() is
     always UTC, which may be a different calendar day from the local date.

   PLATFORM_TZ is the SA portal default. Company-specific pages should pass
   the company's configured timezone stored at companySettings/{cid}/timezone.
   ─────────────────────────────────────────────────────────────────────────── */
window.PLATFORM_TZ = 'Pacific/Auckland';

/** Current date string "YYYY-MM-DD" in the given IANA timezone */
window._tzDateStr = function(tz) {
  return new Date().toLocaleDateString('en-CA', {timeZone: tz || window.PLATFORM_TZ});
};

/** Current month string "YYYY-MM" in the given IANA timezone */
window._tzCurMonth = function(tz) {
  return window._tzDateStr(tz).slice(0, 7);
};

/** Convert a UTC ISO string or ms timestamp → "YYYY-MM-DD" in the given timezone */
window._tzToDate = function(val, tz) {
  if (!val) return '';
  return new Date(val).toLocaleDateString('en-CA', {timeZone: tz || window.PLATFORM_TZ});
};

/** Convert a UTC ISO string or ms timestamp → "YYYY-MM" in the given timezone */
window._tzToMonth = function(val, tz) {
  return window._tzToDate(val, tz).slice(0, 7);
};

/** Format a UTC value as a human-readable local datetime string */
window._tzFmtDT = function(val, tz) {
  if (!val) return '\u2014';
  return new Date(val).toLocaleString('en-NZ', {
    timeZone: tz || window.PLATFORM_TZ,
    day: 'numeric', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
};

/** Start of today as UTC epoch ms, anchored to the given IANA timezone.
 *  Example: for Pacific/Auckland (UTC+13), NZ midnight on May 6
 *  is at UTC May 5 11:00 — NOT UTC May 6 00:00. */
window._tzTodayStart = function(tz) {
  tz = tz || window.PLATFORM_TZ;
  var now = new Date();
  // Today's date in target TZ using en-CA locale (guaranteed YYYY-MM-DD format)
  var dateStr = now.toLocaleDateString('en-CA', {timeZone: tz});
  // TZ midnight treated as if it were UTC → gives us an epoch anchor
  var tzMidnightUTC = new Date(dateStr + 'T00:00:00Z').getTime();
  // Current TZ clock time treated as if it were UTC (sv locale gives "YYYY-MM-DD HH:MM:SS")
  var tzNowStr = now.toLocaleString('sv', {timeZone: tz});
  var tzNowAsUTC = new Date(tzNowStr.replace(' ', 'T') + 'Z').getTime();
  // offsetMs = actual UTC epoch − TZ epoch (negative east of UTC, e.g. NZ = −13h)
  var offsetMs = now.getTime() - tzNowAsUTC;
  // Shift the midnight anchor by the same offset → actual UTC ms for TZ midnight
  return tzMidnightUTC + offsetMs;
};

/** End of today (start of tomorrow) as UTC epoch ms, anchored to the given timezone */
window._tzTodayEnd = function(tz) {
  return window._tzTodayStart(tz) + 86400000;
};

/** Start of the current month as UTC epoch ms, anchored to the given timezone */
window._tzMonthStart = function(tz) {
  tz = tz || window.PLATFORM_TZ;
  var now = new Date();
  var dateStr = now.toLocaleDateString('en-CA', {timeZone: tz}); // YYYY-MM-DD
  var monthStart = dateStr.slice(0, 8) + '01'; // YYYY-MM-01
  var tzMidnightUTC = new Date(monthStart + 'T00:00:00Z').getTime();
  var tzNowStr = now.toLocaleString('sv', {timeZone: tz});
  var tzNowAsUTC = new Date(tzNowStr.replace(' ', 'T') + 'Z').getTime();
  var offsetMs = now.getTime() - tzNowAsUTC;
  return tzMidnightUTC + offsetMs;
};

/** Per-car (or flat-normalized) rate from a superPackages record */
window._planPerCarRate = function(pkg) {
  if (!pkg) return 0;
  var bt = pkg.billingType || 'per_car_monthly';
  if (bt === 'flat_monthly') return +(pkg.flatPrice || 0);
  if (bt === 'flat_annual') return +(pkg.flatPrice || 0) / 12;
  return +(pkg.pricePerCar || pkg.monthlyPrice || 0);
};

/** Derive billing status from package + optional overrides */
window._resolvePlanStatus = function(planData) {
  if (planData.status) return planData.status;
  var pkgId = planData.packageId;
  var pkg = planData.packageMeta;
  if (planData.clearTrial || (pkgId && pkgId !== 'pkg_trial' && pkg && !pkg.trialDays)) return 'active';
  if (pkgId === 'pkg_trial' || (pkg && pkg.trialDays > 0) || planData.trialEnd) return 'trial';
  return pkgId ? 'active' : 'trial';
};

/**
 * Single source of truth — sync plan/billing to all Firebase nodes at once.
 * Writes: companySettings/{cid}/plan, companySettings/{cid}/billing,
 *         superBilling/{cid}/info, superClients/{cid}, companyBilling/{cid}
 */
window.updateCompanyPlan = function(companyId, planData) {
  planData = planData || {};
  var cid = String(companyId);
  var hasPackage = planData.packageId !== undefined || planData.packageName !== undefined;
  var hasRate = planData.monthlyRate !== undefined || planData.pricePerCarOverride !== undefined;
  var hasBillingDates = planData.billingStartDate !== undefined || planData.startDate !== undefined || planData.nextDueDate !== undefined;
  var hasBillingExtras = planData.contractedFleet !== undefined || planData.pricePerCarOverride !== undefined || planData.notes !== undefined;
  var fullPlanSync = hasPackage || hasRate || hasBillingDates || planData.monthlyFee !== undefined || hasBillingExtras;

  var pkgId = planData.packageId;
  var pkgName = planData.packageName;
  var pkg = planData.packageMeta || null;
  var status = window._resolvePlanStatus(planData);
  var isTrial = status === 'trial';
  var monthlyRate = planData.monthlyRate;
  if (monthlyRate === undefined && planData.pricePerCarOverride != null) {
    monthlyRate = planData.pricePerCarOverride;
  }
  var nowIso = planData.updatedAt || new Date().toISOString();
  var nowMs = planData.updatedAtMs || Date.now();
  var startDate = planData.billingStartDate || planData.startDate;

  var superClientsPatch = {
    status: status,
    subscriptionStatus: status,
    updatedAt: nowMs
  };
  if (hasPackage) {
    superClientsPatch.packageId = pkgId || null;
    superClientsPatch.packageName = pkgName || null;
  }
  if (hasRate) superClientsPatch.packagePrice = monthlyRate != null ? monthlyRate : null;
  if (isTrial) {
    if (hasPackage) superClientsPatch.plan = pkgName || null;
    if (planData.trialEnd != null) superClientsPatch.trialEnd = planData.trialEnd;
    if (planData.trialStart != null) superClientsPatch.trialStart = planData.trialStart;
    if (planData.trialDays != null) superClientsPatch.trialDays = planData.trialDays;
  } else if (fullPlanSync && planData.clearTrial !== false) {
    superClientsPatch.plan = null;
    superClientsPatch.trialEnd = null;
    superClientsPatch.trialEndsAt = null;
    superClientsPatch.trialStart = null;
    superClientsPatch.trialStartedAt = null;
    superClientsPatch.trialDays = null;
    superClientsPatch.onTrial = null;
    superClientsPatch.isTrial = null;
    superClientsPatch.trial = null;
  }

  var writes = [db.ref('superClients/' + cid).update(superClientsPatch)];

  if (fullPlanSync) {
    var planNode = {
      name: pkgName != null ? pkgName : null,
      status: status,
      rate: monthlyRate != null ? monthlyRate : null,
      packageId: pkgId != null ? pkgId : null
    };
    var billingPatch = {
      packageId: pkgId != null ? pkgId : null,
      monthlyRate: monthlyRate != null ? monthlyRate : null,
      billingStartDate: startDate || null,
      nextDueDate: planData.nextDueDate || null,
      updatedAt: nowIso
    };
    var superBillingInfo = {
      packageId: pkgId != null ? pkgId : null,
      packageName: pkgName != null ? pkgName : null,
      monthlyFee: planData.monthlyFee != null ? planData.monthlyFee : null,
      startDate: startDate || null,
      nextDueDate: planData.nextDueDate || null,
      status: status,
      updatedAt: nowMs
    };
    if (startDate) superBillingInfo.billingStart = startDate;

    var companyBillingPatch = { updatedAt: nowIso };
    if (hasPackage) companyBillingPatch.packageId = pkgId || null;
    if (planData.contractedFleet !== undefined) companyBillingPatch.contractedFleet = planData.contractedFleet;
    if (planData.pricePerCarOverride !== undefined) companyBillingPatch.pricePerCarOverride = planData.pricePerCarOverride;
    if (planData.notes !== undefined) companyBillingPatch.notes = planData.notes;

    writes.push(
      db.ref('companySettings/' + cid + '/plan').set(planNode),
      db.ref('companySettings/' + cid + '/billing').update(billingPatch),
      db.ref('superBilling/' + cid + '/info').update(superBillingInfo),
      db.ref('companyBilling/' + cid).update(companyBillingPatch)
    );

    var isPaid = status === 'active' && pkgId && pkgId !== 'pkg_trial';
    if (isPaid && pkg && pkg.modules && planData.enableModules !== false) {
      var featurePatch = {};
      var modulePatch = {};
      ['taxi', 'food', 'freight'].forEach(function(m) {
        if (pkg.modules[m]) {
          featurePatch[m] = true;
          modulePatch[m] = true;
        }
      });
      if (Object.keys(featurePatch).length) {
        writes.push(db.ref('companySettings/' + cid + '/features').update(featurePatch));
      }
      if (Object.keys(modulePatch).length) {
        writes.push(db.ref('superClients/' + cid + '/modules').update(modulePatch));
      }
    }
  } else {
    writes.push(
      db.ref('companySettings/' + cid + '/plan').update({ status: status }),
      db.ref('superBilling/' + cid + '/info').update({ status: status, updatedAt: nowMs }),
      db.ref('companyBilling/' + cid).update({ updatedAt: nowIso })
    );
  }

  return Promise.all(writes);
};
