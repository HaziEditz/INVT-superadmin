<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Trips &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png" />
<script src="assets/js/jquery.min.js" type="text/javascript"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet" />
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet" />
<link href="assets/css/main.min.css" rel="stylesheet" />
<link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
<link href="toast/toastr.min.css" rel="stylesheet" />
<script src="toast/toastr.min.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
var config = {
  apiKey: "AIzaSyDIVSI_GRYG0hCPvc9h80QXZMxwZoejctQ",
  authDomain: "bookawaka2026-564e1.firebaseapp.com",
  databaseURL: "https://bookawaka2026-564e1-default-rtdb.firebaseio.com",
  projectId: "bookawaka2026-564e1",
  storageBucket: "bookawaka2026-564e1.firebasestorage.app"
};
firebase.initializeApp(config);
</script>
<style>
.tm-wrap{padding:20px}
.tm-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.tm-bar{background:#37474F;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between}
.tm-bar h3{margin:0;font-size:15px;font-weight:600}
.tm-tbl{width:100%;border-collapse:collapse;font-size:13px}
.tm-tbl th{background:#f5f5f5;padding:9px 11px;text-align:left;font-weight:600;border-bottom:2px solid #e0e0e0;white-space:nowrap}
.tm-tbl td{padding:8px 11px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.tm-tbl tr:hover td{background:#fafafa}
.bx{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600;white-space:nowrap}
.bx-g{background:#E8F5E9;color:#2E7D32}.bx-r{background:#FFEBEE;color:#C62828}
.bx-a{background:#FFF8E1;color:#1565C0}.bx-b{background:#E3F2FD;color:#1565C0}
.bx-gr{background:#F5F5F5;color:#616161}
.tm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.tm-btn-p{background:#37474F;color:#fff}.tm-btn-p:hover{background:#263238}
.tm-btn-e{background:#E3F2FD;color:#1565C0}.tm-btn-d{background:#FFEBEE;color:#C62828}
.tm-btn-ok{background:#E8F5E9;color:#2E7D32}
.tm-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.tm-ov{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:999;align-items:center;justify-content:center}
.tm-ov.open{display:flex}
.tm-modal{background:#fff;border-radius:8px;width:760px;max-width:95vw;max-height:92vh;overflow-y:auto;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.tm-mh{background:#37474F;color:#fff;padding:14px 18px;display:flex;align-items:center;justify-content:space-between;border-radius:8px 8px 0 0}
.tm-mh h3{margin:0;font-size:15px}
.tm-mb{padding:18px}.tm-mf{padding:12px 18px;border-top:1px solid #eee;display:flex;gap:8px;justify-content:flex-end}
.tm-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.tm-msg{margin-top:8px;font-size:13px}.tm-msg.ok{color:#2E7D32}.tm-msg.err{color:#C62828}
.fc{display:inline-block;background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;border-radius:10px;padding:1px 7px;font-size:11px;font-weight:600;margin:1px}
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt select,.filt input[type=text],.filt input[type=date]{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
#tt-trip-map { height:220px; border-radius:6px; margin-top:14px; z-index:1; }
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main">
  <div class="header_main_content">
    <nav class="uk-navbar">
      <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
      <div class="col-md-offset-2 col-md-4">
        <label style="color:#fff">TM Trips — BookaWaka Admin</label>
      </div>
      <div class="uk-navbar-flip">
        <ul class="uk-navbar-nav user_actions">
          <li data-uk-dropdown="{mode:'click',pos:'bottom-right'}">
            <a href="#" class="user_action_image"><img class="md-user-image" src="assets/img/bw-logo.png" alt=""/></a>
            <div class="uk-dropdown uk-dropdown-small">
              <ul class="uk-nav js-uk-prevent">
                <li><a href="Home.aspx">Dashboard</a></li>
                <li><a onclick="(function(){ window.location.href='SA-Login.aspx'; })()">Logout</a></li>
              </ul>
            </div>
          </li>
        </ul>
      </div>
    </nav>
  </div>
</header>
<aside id="sidebar_main">
  <div class="sidebar_main_header">
    <div class="sidebar_logo">
      <a href="Home.aspx" class="sSidebar_hide"><img src="assets/img/bw-logo.png" alt="" style="height:100px;width:100px;border-radius:50%"/></a>
      <a href="Home.aspx" class="sSidebar_show"><img src="assets/img/bw-logo.png" alt="" style="height:50px;width:50px;border-radius:50%"/></a>
    </div>
  </div>
  <div class="menu_section">
    <ul>
      <li title="Dashboard"><a href="Home.aspx"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Home</span></a></li>
      <li class="current_section" title="Master Entries"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Master Entries</span></a>
        <ul>
          <li><a href="Define%20Portal%20Contents.aspx">Define Portal Contents</a></li>
          <li><a href="Define%20Registration%20Packages.aspx">Registration Packages</a></li>
          <li><a href="AdminCountriesEntry.aspx">Define Service Countries</a></li>
          <li><a href="Define%20Traveling%20Entities.aspx">Define Traveling Entities</a></li>
          <li><a href="Define%20Currency.aspx">Define Currency</a></li>
          <li><a href="Define%20Payment%20Types.aspx">Define Payment Types</a></li>
          <li><a href="Define%20Vehicle.aspx">Define Vehicles</a></li>
          <li><a href="Define%20Time%20Zone.aspx">Define Time Zones</a></li>
          <li><a href="Define%20Traveling%20Conditions.aspx">Define Traveling Conditions</a></li>
          <li><a href="Define%20Duty%20Time.aspx">Define Duty Times</a></li>
          <li><a href="Define%20Distance%20Units.aspx">Define Distance Units</a></li>
        </ul>
      </li>
    <li class="current_section" title="Total Mobility"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8CC;</i></span><span class="menu_title">Total Mobility</span></a><ul>
      <li><a href="TM-Setup.aspx">TM Setup Hub</a></li>
      <li><a href="TM-Council-Config.aspx">Council Config (Advanced)</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx" style="font-weight:700;color:#1565C0">&#9658; All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
      <li><a href="TM-Platform-Fees.aspx">Platform Fees</a></li>
      <li><a href="TM-Clean-Scan.aspx">Clean-trip Scan</a></li>
      <li><a href="TM-Settlement.aspx">Settlement</a></li>
      <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
      <li><a href="TM-Settings.aspx">TM Settings (Advanced)</a></li>
      <li><a href="/council-portal" target="_blank">Council Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Pricing"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8A1;</i></span><span class="menu_title">Pricing</span></a><ul>
      <li><a href="Special-Tariffs.aspx">Special Tariffs</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Restaurants.aspx">Restaurants</a></li>
      <li><a href="FD-Orders.aspx">All Orders</a></li>
      <li><a href="FD-Payouts.aspx">Payouts</a></li>
      <li><a href="FD-Reports.aspx">Reports</a></li>
      <li><a href="FD-Commission.aspx">Commission Rates</a></li>
      <li><a href="/restaurant-portal" target="_blank">Restaurant Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Orders.aspx">All Orders</a></li>
      <li><a href="FR-Payouts.aspx">Payouts</a></li>
      <li><a href="FR-Reports.aspx">Reports</a></li>
      <li><a href="FR-Commission.aspx">Commission Rates</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content">
  <div id="page_content_inner">

<div class="tm-wrap">
<div class="tm-card">
  <div class="tm-bar">
    <h3>TM Trips <small id="tt-count" style="opacity:.75;font-size:12px"></small></h3>
    <button class="tm-btn tm-btn-wh" onclick="refreshTT()">&#8635;</button>
  </div>
  <div class="filt">
    <select id="tt-f-council" onchange="renderTT()"><option value="">All Councils</option></select>
    <select id="tt-f-company" onchange="renderTT()"><option value="">All Companies</option></select>
    <select id="tt-f-status" onchange="renderTT()">
      <option value="">All Statuses</option>
      <option value="pending">Pending</option>
      <option value="flagged">Flagged</option>
      <option value="company_approved">Company Approved</option>
      <option value="submitted">Sent to Council</option>
      <option value="approved">Council Approved</option>
      <option value="revision_needed">Needs Revision</option>
      <option value="rejected">Rejected</option>
      <option value="paid">Paid</option>
      <option value="archived">Archived</option>
    </select>
    <input type="date" id="tt-f-from" onchange="renderTT()"/>
    <input type="date" id="tt-f-to" onchange="renderTT()"/>
    <input type="text" id="tt-f-search" placeholder="Booking ID / Driver / Card #&#8230;" oninput="renderTT()" style="min-width:180px"/>
    <button class="tm-btn" style="background:#fff;border:1px solid #ddd;color:#333;font-size:12px" onclick="clearTTFilters()">Clear</button>
  </div>
  <div id="tt-bulk-bar" style="display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin:0 0 10px;padding:8px 10px;background:#FAFAFA;border:1px solid #eee;border-radius:6px">
    <label style="font-size:12px;color:#555"><input type="checkbox" id="tt-check-all" onchange="ttToggleAll(this.checked)"/> Select all matching</label>
    <input type="text" id="tt-archive-note" placeholder="Archive note (optional)" style="min-width:180px;padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12px"/>
    <button type="button" class="tm-btn" style="background:#546E7A;color:#fff" onclick="archiveSelectedTT()">Archive selected</button>
    <button type="button" class="tm-btn" style="background:#546E7A;color:#fff;opacity:.9" onclick="archiveAllMatchingTT()">Archive all matching filter</button>
    <button type="button" class="tm-btn tm-btn-ok" onclick="restoreSelectedTT()">Restore selected</button>
    <button type="button" class="tm-btn tm-btn-ok" style="opacity:.9" onclick="restoreAllMatchingTT()">Restore all matching filter</button>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th style="width:36px"></th>
        <th>Booking ID</th><th>Driver</th><th>Vehicle</th><th>Voucher #</th><th>Passenger</th><th>Council</th>
        <th>Date</th><th>Pickup</th><th>Dropoff</th><th>Fare</th><th>TM Sub.</th><th>Hoist</th><th>Uses</th><th>Pax Pays</th><th>Status</th><th>Actions</th>
      </tr></thead>
      <tbody id="tt-tb"><tr><td colspan="17" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
    </table>
  </div>
</div></div>

<div class="tm-ov" id="sb-ov">
<div class="tm-modal" style="width:480px">
  <div class="tm-mh" style="background:#E65100"><h3>Send Back to Company</h3>
    <button onclick="closeSendBack()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
  <div class="tm-mb">
    <p style="font-size:13px;color:#555;margin:0 0 12px">Describe what the company needs to fix or check before this trip can be resubmitted to the council.</p>
    <div class="tm-ff">
      <label>Revision Notes (required)</label>
      <textarea id="sb-notes" style="width:100%;min-height:90px;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box;resize:vertical" placeholder="e.g. Waiting charge must be removed. Voucher number does not match council records."></textarea>
    </div>
    <div id="sb-msg" style="margin-top:8px;font-size:13px;color:#C62828"></div>
  </div>
  <div class="tm-mf">
    <button class="tm-btn" style="background:#eee;color:#333" onclick="closeSendBack()">Cancel</button>
    <button class="tm-btn" style="background:#E65100;color:#fff" onclick="saveSendBack()">&#8617; Send Back to Company</button>
  </div>
</div></div>

<div class="tm-ov" id="tt-ov">
<div class="tm-modal">
  <div class="tm-mh"><h3 id="tt-dtitle">Trip Details</h3>
    <button onclick="closeTTDetail()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
  <div class="tm-mb" id="tt-detail-body"></div>
  <div class="tm-mf" id="tt-detail-foot"></div>
</div></div>

  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/modernizr/2.8.3/modernizr.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/fastclick/1.0.6/fastclick.min.js"></script>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/uikit_custom.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var ttData = {}, ttCouncils = {}, ttCards = {}, tmStatuses = {}, ttCompanies = {};
window._fbOnLogin = function() {
  Promise.all([
    adminRead('tmConfig'),
    adminRead('tmCards'),
    adminRead('superClients')
  ]).then(function(res) {
    ttCouncils = res[0] || {};
    ttCards    = res[1] || {};
    ttCompanies = res[2] || {};
    populateTTCouncils();
    loadTT();
  });
};
function populateTTCouncils() {
  var o = '<option value="">All Councils</option>';
  Object.entries(ttCouncils).forEach(function(kv) { o += '<option value="' + kv[0] + '">' + ((kv[1].name) || kv[0]) + '</option>'; });
  document.getElementById('tt-f-council').innerHTML = o;
}
function populateTTCompanies() {
  var sel = document.getElementById('tt-f-company');
  if (!sel) return;
  var old = sel.value;
  var map = {};
  Object.keys(ttData).forEach(function(id) {
    var cid = String((ttData[id] && ttData[id]._cid) || '').trim();
    if (!cid) return;
    var name = (ttCompanies[cid] && (ttCompanies[cid].name || ttCompanies[cid].companyName)) || ('Operator ' + cid);
    map[cid] = name;
  });
  var o = '<option value="">All Companies</option>';
  Object.keys(map).sort(function(a,b){ return map[a].localeCompare(map[b]); }).forEach(function(cid) {
    o += '<option value="' + cid + '"' + (cid === old ? ' selected' : '') + '>' + map[cid] + '</option>';
  });
  sel.innerHTML = o;
}

function calcTMSubsidy(meterFare, councilId) {
  var council = ttCouncils[councilId] || {};
  var r = window.calcTmMeterSubsidyFromCouncil
    ? window.calcTmMeterSubsidyFromCouncil(meterFare, council)
    : { ok: false, amount: null };
  // Never invent 75% / uncapped 99999 — missing config → 0 and flag on trip row.
  return r.ok ? r.amount : 0;
}
function councilTmRatesReady(councilId) {
  var council = ttCouncils[councilId] || {};
  var rates = window.resolveCouncilTmRates ? window.resolveCouncilTmRates(council) : { ready: false };
  return !!rates.ready;
}

/** Prefer tmTripCategory; else map driver source (hail/dispatch/…) — same as council trip detail. */
function resolveTripCategoryLabel(j) {
  var explicit = String(j.tmTripCategory || j.tripCategory || '').trim();
  if (explicit) return explicit;
  if (j.manuallyAddedByCompany === true || j.manuallyAddedByCompany === 'true') {
    return 'Manually added by company';
  }
  var raw = String(j.source || j.bookingSource || j.BookingSource || j.Source || j.via || '').toLowerCase().trim();
  if (!raw) return '';
  if (raw.indexOf('manual_owner') >= 0 || raw.indexOf('manual owner') >= 0) return 'Manually added by company';
  if (raw.indexOf('hail') >= 0 || raw.indexOf('driverapp') >= 0 || raw.indexOf('driver_app') >= 0 ||
      raw.indexOf('driver-app') >= 0 || raw.indexOf('street') >= 0 || raw === 'queue' || raw.indexOf('driverqueue') >= 0) {
    return 'Hail';
  }
  if (raw.indexOf('dispatch') >= 0 || raw.indexOf('console') >= 0) return 'Dispatch';
  if (raw.indexOf('web') >= 0) return 'Website';
  if (raw.indexOf('passenger') >= 0 || raw.indexOf('rider') >= 0 || raw.indexOf('pax') >= 0 || raw.indexOf('app') >= 0) {
    return 'Passenger app';
  }
  if (raw.indexOf('food') >= 0) return 'Food';
  if (raw.indexOf('freight') >= 0 || raw.indexOf('parcel') >= 0) return 'Freight';
  if (raw === 'driver_complete') return '';
  return raw.replace(/_/g, ' ');
}

function cleanDriverName(raw) {
  if (!raw) return '';
  raw = String(raw).trim();
  // If it looks like an email, extract and format the local part
  if (raw.indexOf('@') > -1) {
    raw = raw.split('@')[0].replace(/[._+]/g, ' ').trim();
    raw = raw.replace(/\b\w/g, function(c){ return c.toUpperCase(); });
  }
  return raw;
}

function mapTMTrip(j, cid, rawKey) {
  // tmPassengers — array of {cardNumber, cardholderName, expiryDate, needsHoist} — one entry per TM passenger
  // tmVoucherNumbers — flat array of card numbers — use when tmPassengers not present
  // A single trip CAN have 2+ TM passengers (e.g. a group ride); iterate all for accurate subsidy totals
  var tmPassengersList = Array.isArray(j.tmPassengers) ? j.tmPassengers : [];
  var voucherList      = Array.isArray(j.tmVoucherNumbers) ? j.tmVoucherNumbers : [];

  // Primary card — for council lookup and single-passenger compat
  var primaryPassenger = tmPassengersList[0] || {};
  var firstVoucherNum  = voucherList[0] || '';
  var cardNum = j.tmVoucherNo || j.cardNumber || primaryPassenger.cardNumber || firstVoucherNum || '';
  var card    = ttCards[cardNum] || {};
  var councilId = j.councilId || card.councilId || '';

  // All card numbers across all passengers — for display and per-passenger subsidy
  var allCardNums = tmPassengersList.length
    ? tmPassengersList.map(function(p){ return p.cardNumber||''; }).filter(Boolean)
    : (voucherList.length ? voucherList : (cardNum ? [cardNum] : []));

  // All passenger names joined — TM group ride shows all names
  var allPassengerNames = tmPassengersList.map(function(p){
    return p.cardholderName || (ttCards[p.cardNumber||'']||{}).passengerName || '';
  }).filter(Boolean);
  var passengerName = j.tmPassengerName || j.passengerName
    || (allPassengerNames.length ? allPassengerNames.join(' + ') : '')
    || card.passengerName || '';

  // Driver name — try all known field names, clean email if present
  var rawDriverName = j.driverFullName || j.driverDisplayName || j.driver_name || j.driverName || j.driverEmail || '';
  var driverName = cleanDriverName(rawDriverName);

  // Fare fields — prefer driver Phase 2A.1 breakdown when present (meter vs hoist separated).
  // estimatedFare is the passenger app's total trip fare (authoritative for multi-pax legacy).
  var waitingCharge = +(j.waitingCost || j.WaitingCost || j.waitingCharge || j.waitingFee || 0);
  var tmHoistCount  = +(j.tmHoistCount || j.hoistCount || 0);
  var hoistResolved = window.resolveHoistAmount
    ? window.resolveHoistAmount(j, ttCouncils[councilId] || {})
    : { amount: +(j.tmHoistFeeTotal || j.hoistTotal || j.hoistFee || j.tmSubsidyHoist || 0), configMissing: false };
  var hoistTotal = hoistResolved.amount;
  var hoistConfigMissing = !!hoistResolved.configMissing;
  var meterFare     = +(j.tmMeterFare || j.meterFare || 0);
  if (!meterFare) {
    // Legacy: total may have included hoist — subtract hoist when driver wrote hoist separately.
    var rawTotal = +(j.estimatedFare || j.fare || j.totalFare || j.tmTotalFare || 0);
    meterFare = (j.hoistTotal || j.tmSubsidyHoist || j.hoistFee)
      ? Math.max(0, rawTotal - hoistTotal)
      : rawTotal;
  }

  // Prefer driver-written meter subsidy when present; else recompute only with live council rates.
  var tmSubsidyFare;
  var subsidyConfigMissing = false;
  if (j.tmSubsidyFare != null && j.tmSubsidyFare !== '') {
    tmSubsidyFare = +j.tmSubsidyFare;
  } else if (allCardNums.length > 1) {
    // NZ TM multi-passenger: divide meter fare equally per card, apply cap per card, sum.
    var farePerCard = meterFare / allCardNums.length;
    var anyMissing = false;
    tmSubsidyFare = allCardNums.reduce(function(sum, cn) {
      var paxCouncilId = (ttCards[cn] || {}).councilId || councilId;
      if (!councilTmRatesReady(paxCouncilId)) anyMissing = true;
      return sum + calcTMSubsidy(farePerCard, paxCouncilId);
    }, 0);
    subsidyConfigMissing = anyMissing;
  } else if (councilTmRatesReady(councilId)) {
    tmSubsidyFare = calcTMSubsidy(meterFare, councilId);
  } else {
    tmSubsidyFare = 0;
    subsidyConfigMissing = true;
  }

  // Phase 2A.1 / NZ TM: hoist is always 100% council-paid; never enters meter %/cap.
  var tmSubsidyHoist = hoistTotal;
  if (j.tmSubsidyHoist != null && j.tmSubsidyHoist !== '') tmSubsidyHoist = +j.tmSubsidyHoist;
  var hasStoredCouncil = j.tmCouncilPays != null && j.tmCouncilPays !== '';
  var totalCouncilPays = hasStoredCouncil
    ? +j.tmCouncilPays
    : (subsidyConfigMissing
      ? null
      : +(tmSubsidyFare + tmSubsidyHoist).toFixed(2));

  // Passenger pays meter share + waiting only (never hoist).
  var passengerShareFare = meterFare - tmSubsidyFare;
  var passengerPays = (j.tmPassengerPays != null && j.tmPassengerPays !== '')
    ? +j.tmPassengerPays
    : (subsidyConfigMissing ? null : +(passengerShareFare + waitingCharge).toFixed(2));

  // Distance — try multiple field names driver apps may use
  var distRaw = j.distanceKm || j.distance || j.distanceTravelled || j.distanceTraveled
                || j.tripDistanceKm || j.tripDistance || j.distanceInKm || '';
  var distance = distRaw ? parseFloat(distRaw).toFixed(2) : '';

  // Pickup/dropoff coordinates for map
  var pickupLoc = j.pickupLocation || j.startLocation || {};
  var dropLoc   = j.dropLocation  || j.endLocation   || {};
  var pickupLat = +(j.pickupLat  || j.startLat  || pickupLoc.latitude  || pickupLoc.lat  || 0);
  var pickupLng = +(j.pickupLng  || j.pickupLon || j.startLng || j.startLon || pickupLoc.longitude || pickupLoc.lng || 0);
  var dropLat   = +(j.dropLat    || j.endLat    || j.dropoffLat  || dropLoc.latitude  || dropLoc.lat  || 0);
  var dropLng   = +(j.dropLng    || j.dropLon   || j.endLng || j.endLon || j.dropoffLng || dropLoc.longitude || dropLoc.lng || 0);

  return {
    _cid: cid, _rawKey: rawKey,
    councilId: councilId,
    driverName: driverName,
    vehicleId: j.vehicleId || j.vehicle || '',
    cardNumber: cardNum,
    passengerName: passengerName,
    startTime: j.startedAt_ISO || j.startedAt || '',
    endTime: j.completedAt_ISO || j.completedAt || j.timestamp || '',
    // Keep raw completion fields so Date column can fall back when start is missing.
    completedAt_ISO: j.completedAt_ISO || '',
    completedAt: j.completedAt || j.timestamp || '',
    pickup: j.pickupAddress || j.pickup || j.pickupLocation_address || (j.pickupLocation && j.pickupLocation.address) || '',
    dropoff: j.dropAddress || j.dropoff || j.dropLocation_address || (j.dropoffLocation && j.dropoffLocation.address) || j.destination || '',
    allCardNums: allCardNums,
    pickupLat: pickupLat, pickupLng: pickupLng,
    dropLat: dropLat, dropLng: dropLng,
    meterFare: meterFare,
    tmSubsidyFare: tmSubsidyFare,
    tmSubsidyHoist: tmSubsidyHoist,
    hoistTotal: hoistTotal,
    passengerShareFare: passengerShareFare,
    passengerPays: passengerPays,
    totalCouncilPays: totalCouncilPays,
    waitingCharge: waitingCharge,
    distance: distance,
    duration: j.durationLabel || j.duration || '',
    tmTripCategory: resolveTripCategoryLabel(j),
    manuallyAddedByCompany: !!(j.manuallyAddedByCompany === true || j.manuallyAddedByCompany === 'true' ||
      String(j.source || '').toLowerCase().indexOf('manual_owner') >= 0),
    tmHoistCount: tmHoistCount,
    tmHoists: Array.isArray(j.tmHoists) ? j.tmHoists : [],
    tmPassengerCount: allCardNums.length || 1,
    tmCouncilAmountApp: +(j.tmCouncilAmount || 0),   // as-calculated by passenger app (single-cap)
    tmPassengerAmountApp: +(j.tmPassengerAmount || 0), // passenger share as-calculated by app
    payMethod: j.paymentType || j.paymentMethod || (j.cardPayment ? 'card' : (j.cashPayment ? 'cash' : (j.accountPayment ? 'account' : ''))),
    companyId: cid,
    status: 'pending',
    flagReasons: [],
    vehicleHoistEquipped: j.vehicleHoistEquipped || false,
    tmConfigMissing: !!(subsidyConfigMissing || hoistConfigMissing)
  };
}

function loadTT() {
  document.getElementById('tt-tb').innerHTML = '<tr><td colspan="15" style="text-align:center;padding:40px;color:#9e9e9e">Loading\u2026</td></tr>';
  adminRead('completedJobs').then(function(allJobs) {
    ttData = {};
    if (allJobs && typeof allJobs === 'object') {
      Object.entries(allJobs).forEach(function(cidEntry) {
        var cid = cidEntry[0], jobs = cidEntry[1] || {};
        Object.entries(jobs).forEach(function(jobEntry) {
          var rawKey = jobEntry[0], j = jobEntry[1];
          if (typeof isTmCompletedJob === 'function' ? !isTmCompletedJob(j) : j.paymentType !== 'total_mobility') return;
          var id = j.bookingId || rawKey;
          ttData[id] = mapTMTrip(j, cid, rawKey);
        });
      });
    }
    adminRead('tmTripStatus').then(function(statuses) {
      tmStatuses = statuses || {};
      Object.keys(ttData).forEach(function(id) {
        var t = ttData[id];
        var st = tmStatuses[t._cid] && tmStatuses[t._cid][t._rawKey];
        if (st) {
          t.status      = st.status      || t.status;
          t.councilId   = st.councilId   || t.councilId;
          t.flagReasons = st.flagReasons || [];
          t.submittedAt = st.submittedAt || null;
          t.approvedAt  = st.approvedAt  || null;
          t.rejectedAt  = st.rejectedAt  || null;
          t.revisionNote = st.revisionNote || '';
          t.archivedAt = st.archivedAt || null;
          t.archivedBy = st.archivedBy || null;
          t.archivedFromStatus = st.archivedFromStatus || null;
          t.archiveNote = st.archiveNote || null;
          t.events = st.events || null;
          t.submittedAt = st.submittedAt || t.submittedAt;
          t.flaggedAt = st.flaggedAt || null;
          t.sentBackAt = st.sentBackAt || null;
          t.resubmittedAt = st.resubmittedAt || null;
          t.approvedAt = st.approvedAt || null;
          t.rejectedAt = st.rejectedAt || null;
          t.anomalyDetail = st.anomalyDetail || null;
          t.revisionNote = st.revisionNote || st.revisionNotes || t.revisionNote || '';
        }
      });
      renderTT();
      populateTTCompanies();
    }).catch(function() { renderTT(); populateTTCompanies(); });
  }).catch(function() {
    document.getElementById('tt-tb').innerHTML = '<tr><td colspan="15" style="text-align:center;padding:40px;color:#C62828">Error loading trips.</td></tr>';
  });
}

function refreshTT() {
  loadTT();
}

function clearTTFilters() {
  ['tt-f-council','tt-f-company','tt-f-status'].forEach(function(x) { var el=document.getElementById(x); if(el) el.value = ''; });
  ['tt-f-from','tt-f-to','tt-f-search'].forEach(function(x) { var el=document.getElementById(x); if(el) el.value = ''; });
  renderTT();
}
function renderTT() {
  var fC = document.getElementById('tt-f-council').value;
  var fCo = document.getElementById('tt-f-company') ? document.getElementById('tt-f-company').value : '';
  var fS = document.getElementById('tt-f-status').value;
  var fFrom = document.getElementById('tt-f-from').value;
  var fTo = document.getElementById('tt-f-to').value;
  var fQ = (document.getElementById('tt-f-search').value || '').toLowerCase();
  var entries = Object.entries(ttData).filter(function(kv) {
    var t = kv[1];
    if (fC && t.councilId !== fC) return false;
    if (fCo && String(t._cid || '') !== fCo) return false;
    if (fS && t.status !== fS) return false;
    var filterDt = (typeof tripDisplayTimeRaw === 'function' ? tripDisplayTimeRaw(t) : null) || t.startTime || t.endTime || '';
    if (fFrom && filterDt && _tzToDate(filterDt) < fFrom) return false;
    if (fTo && filterDt && _tzToDate(filterDt) > fTo) return false;
    if (fQ) { var s = (kv[0] + ' ' + (t.driverName || '') + ' ' + (t.cardNumber || '') + ' ' + ((t.allCardNums||[]).join(' ')) + ' ' + (t.passengerName || '') + ' ' + (t.vehicleId || '')).toLowerCase(); if (!s.includes(fQ)) return false; }
    return true;
  });
  entries.sort(function(a,b) { return tripActivityMs(b[1]) - tripActivityMs(a[1]); });
  document.getElementById('tt-count').textContent = entries.length + ' of ' + Object.keys(ttData).length + ' trip(s)';
  var checkAll = document.getElementById('tt-check-all');
  if (checkAll) checkAll.checked = false;
  if (!entries.length) { document.getElementById('tt-tb').innerHTML = '<tr><td colspan="17" style="text-align:center;padding:40px;color:#9e9e9e">No trips found.</td></tr>'; return; }
  var cnames = {}; Object.entries(ttCouncils).forEach(function(kv) { cnames[kv[0]] = (kv[1].name) || kv[0]; });
  document.getElementById('tt-tb').innerHTML = entries.map(function(kv) {
    var id = kv[0], t = kv[1], sid = "'" + String(id).replace(/\\/g,'\\\\').replace(/'/g,"\\'") + "'";
    var flags = (t.flagReasons || []);
    var statusBadge = ttStatusBadge(t.status);
    var flagHtml = flags.length ? flags.map(function(f) { return '<span class="fc">' + tmFlagReasonLabel(f) + '</span>'; }).join('') : '';
    var dtRaw = (typeof tripDisplayTimeRaw === 'function' ? tripDisplayTimeRaw(t) : null) || t.startTime || t.endTime || '';
    var dt = dtRaw ? _tzFmtDT(dtRaw) : '\u2014';
    var hoistAmt = parseFloat(t.hoistTotal || t.tmSubsidyHoist || 0);
    var uses = hoistUsesOf(t);
    var isArch = t.status === 'archived';
    var archBtn = isArch
      ? '<button class="tm-btn tm-btn-ok" onclick="restoreTT(' + sid + ')" title="Restore" style="margin-right:4px">Restore</button>'
      : '<button class="tm-btn" style="background:#546E7A;color:#fff;margin-right:4px" onclick="archiveTT(' + sid + ')" title="Archive">Archive</button>';
    return '<tr>' +
      '<td><input type="checkbox" class="tt-row-check" value="' + String(id).replace(/"/g,'&quot;') + '"/></td>' +
      '<td style="font-family:monospace;font-size:12px">' + id + '</td>' +
      '<td>' + (t.driverName || '\u2014') + '</td>' +
      '<td>' + (t.vehicleId || '\u2014') + (t.vehicleHoistEquipped ? '<br><span class="bx bx-b" style="font-size:10px">Hoist</span>' : '') + '</td>' +
      '<td style="font-family:monospace">' + ((t.allCardNums && t.allCardNums.length > 1) ? t.allCardNums.join('<br>') : (t.cardNumber || '\u2014')) + '</td>' +
      '<td>' + (t.passengerName || '\u2014') + '</td>' +
      '<td>' + (cnames[t.councilId] || t.councilId || '\u2014') + '</td>' +
      '<td style="white-space:nowrap">' + dt + '</td>' +
      '<td>' + (t.pickup || '\u2014') + '</td>' +
      '<td>' + (t.dropoff || '\u2014') + '</td>' +
      '<td style="font-weight:600">$' + parseFloat(t.meterFare || 0).toFixed(2) + '</td>' +
      '<td style="color:#2E7D32;font-weight:600">$' + parseFloat(t.tmSubsidyFare || 0).toFixed(2) +
        (t.tmConfigMissing ? '<div style="font-size:10px;color:#C62828;font-weight:600">config missing</div>' : '') + '</td>' +
      '<td>' + (hoistAmt > 0 ? '<span style="color:#1565C0;font-weight:600">$' + hoistAmt.toFixed(2) + '</span>' : '\u2014') + '</td>' +
      '<td>' + (uses > 0 ? uses : '\u2014') + '</td>' +
      '<td>' +
        '<strong>$' + parseFloat(t.passengerPays || 0).toFixed(2) + '</strong>' +
        (t.payMethod ? '<br><span class="bx" style="font-size:10px;margin-top:2px;background:#E3F2FD;color:#1565C0">' + t.payMethod + '</span>' : '') +
        (parseFloat(t.waitingCharge||0) > 0 ? '<br><span style="font-size:11px;color:#9e9e9e">incl. $' + parseFloat(t.waitingCharge).toFixed(2) + ' wait</span>' : '') +
      '</td>' +
      '<td>' + statusBadge + '<br>' + flagHtml + '</td>' +
      '<td style="white-space:nowrap">' +
        '<button class="tm-btn tm-btn-e" onclick="viewTT(' + sid + ')" style="margin-right:4px" title="View Details">&#128065;</button>' +
        archBtn +
        (!isArch && (t.status === 'pending' || t.status === 'flagged') ? '<button class="tm-btn tm-btn-ok" onclick="approveTT(' + sid + ')" title="Mark Company Approved" style="margin-right:4px">&#10003;</button>' : '') +
        (!isArch && t.status === 'company_approved' ? '<button class="tm-btn" style="background:#1565C0;color:#fff;margin-right:4px" onclick="submitToCouncil(' + sid + ')" title="Submit to Council">&#8679;</button>' : '') +
        (!isArch && t.status !== 'revision_needed' && t.status !== 'approved' && t.status !== 'paid' ? '<button class="tm-btn" style="background:#FFF8E1;color:#E65100;border:1px solid #FFE082" onclick="openSendBack(' + sid + ')" title="Send back to company">&#8617;</button>' : '') +
      '</td></tr>';
  }).join('');
}
function ttStatusBadge(s) {
  var map = {
    pending: '<span class="bx bx-gr">Pending</span>',
    flagged: '<span class="bx bx-r">\u26a0 Flagged</span>',
    company_approved: '<span class="bx bx-b">Co. Approved</span>',
    submitted: '<span class="bx" style="background:#E8EAF6;color:#283593">Sent to Council</span>',
    approved: '<span class="bx bx-g">\u2713 Council Approved</span>',
    revision_needed: '<span class="bx" style="background:#FFF3E0;color:#E65100">\u21a9 Needs Revision</span>',
    rejected: '<span class="bx bx-r">Rejected</span>',
    paid: '<span class="bx bx-g">\uD83D\uDCB5 Paid</span>',
    archived: '<span class="bx" style="background:#ECEFF1;color:#546E7A">Archived</span>'
  };
  return map[s] || ('<span class="bx bx-gr">' + (s || 'Unknown') + '</span>');
}
var _ttMap = null;
function viewTT(id) {
  var t = ttData[id] || {};
  var cnames = {}; Object.entries(ttCouncils).forEach(function(kv) { cnames[kv[0]] = (kv[1].name) || kv[0]; });
  var flags = (t.flagReasons || []);
  var flagHtml = flags.length ? '<div style="margin:10px 0;padding:10px;background:#FFEBEE;border-radius:4px;border-left:4px solid #C62828"><strong style="color:#C62828">\u26a0 Flag Reasons:</strong><br>' + flags.map(function(f) { return '<span class="fc">' + tmFlagReasonLabel(f) + '</span>'; }).join('') + (t.anomalyDetail ? '<div style="margin-top:6px;font-size:12px;color:#666">' + String(t.anomalyDetail) + '</div>' : '') + '</div>' : '';

  var council = ttCouncils[t.councilId] || {};
  var rates = window.resolveCouncilTmRates ? window.resolveCouncilTmRates(council) : { ready: false, pct: 0, cap: 0, uncapped: true };
  var subPct  = rates.ready ? rates.pct : null;
  var capAmt  = rates.ready && !rates.uncapped ? rates.cap : null;
  var configMissingNote = (!rates.ready || t.tmConfigMissing)
    ? ' <span style="color:#C62828;font-size:11px">(council TM config missing — not guessed)</span>'
    : '';
  var capNote = (rates.ready && !rates.uncapped && t.tmSubsidyFare < t.meterFare * subPct / 100)
    ? ' <span style="color:#E65100;font-size:11px">(capped at $' + capAmt.toFixed(2) + ')</span>' : '';

  var hasMap = (t.pickupLat && t.pickupLng && t.dropLat && t.dropLng);
  var mapHtml = hasMap ? '<div id="tt-trip-map"></div>' : '';

  document.getElementById('tt-dtitle').textContent = 'Trip ' + id;
  document.getElementById('tt-detail-body').innerHTML = flagHtml +
    '<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px 18px;font-size:13px">' +
    row2('Booking ID', id) + row2('Status', ttStatusBadge(t.status)) +
    row2('Driver', (t.driverName || '\u2014')) + row2('Vehicle', (t.vehicleId || '\u2014') + (t.vehicleHoistEquipped ? ' <span class="bx bx-b" style="font-size:10px">Hoist</span>' : '')) +
    row2('Voucher #', (t.allCardNums && t.allCardNums.length > 1 ? t.allCardNums.join(', ') : (t.cardNumber || '\u2014'))) + row2('Passenger', (t.passengerName || '\u2014')) +
    row2('Council', (cnames[t.councilId] || t.councilId || '\u2014')) + row2('Trip Category', (t.tmTripCategory || '\u2014')) +
    (t.manuallyAddedByCompany ? '<div style="grid-column:1/-1;margin-top:6px;padding:8px 10px;border-radius:6px;background:#E3F2FD;border-left:4px solid #1565C0;font-size:12px;color:#0D47A1"><strong>Manually added by company</strong></div>' : '') +
    row2('Pickup', (t.pickup || '\u2014')) + row2('Dropoff', (t.dropoff || '\u2014')) +
    row2('Start', _tzFmtDT(t.startTime)) + row2('End', _tzFmtDT(t.endTime)) +
    row2('Distance', (t.distance ? t.distance + ' km' : '\u2014')) + row2('Duration', (t.duration || '\u2014')) +
    '</div>' +
    mapHtml +
    '<div style="margin-top:14px;background:#F1F8E9;border-radius:6px;padding:14px;font-size:13px">' +
    '<strong>Fare Breakdown</strong>' +
    '<table style="width:100%;margin-top:8px">' +
    frow('Meter Fare (trip only)', '$' + parseFloat(t.meterFare || 0).toFixed(2)) +
    (parseFloat(t.waitingCharge||0) > 0 ? frow('Waiting Charge (passenger pays, not TM)', '$' + parseFloat(t.waitingCharge).toFixed(2), '#9e9e9e') : '') +
    '<tr><td colspan="2" style="padding:4px 0;border-top:1px dashed #ccc"></td></tr>' +
    (t.tmPassengerCount > 1 ? frow(t.tmPassengerCount + ' TM passengers — fare split $' + (t.meterFare/t.tmPassengerCount).toFixed(2) + '/card', '', '#1565C0') : '') +
    frow('Line 1 — Meter subsidy (' + (subPct != null ? (subPct + '% of meter') : 'config missing') + (t.tmPassengerCount > 1 ? ', per card' : '') + ')' + capNote + configMissingNote, '<span style="color:#2E7D32;font-weight:600">$' + parseFloat(t.tmSubsidyFare || 0).toFixed(2) + '</span>') +
    frow('Line 2 — Hoist fee (100% council, not in meter split)', '<span style="color:#2E7D32;font-weight:600">$' + parseFloat(t.tmSubsidyHoist || t.hoistTotal || 0).toFixed(2) + '</span>') +
    (function() {
      var hoists = Array.isArray(t.tmHoists) ? t.tmHoists : [];
      if (!hoists.length) return '';
      return hoists.map(function(h, i) {
        return frow('&nbsp;&nbsp;Hoist ' + (i + 1) + ' · card ' + (h.cardNumber || '—'),
          '$' + parseFloat(h.amount || 0).toFixed(2), '#555');
      }).join('');
    })() +
    '<tr style="border-top:2px solid #ccc"><td style="padding:6px 0"><strong>Total Council Pays</strong></td>' +
    '<td style="text-align:right"><strong style="color:#2E7D32;font-size:15px">$' + parseFloat(t.totalCouncilPays || 0).toFixed(2) + '</strong></td></tr>' +
    '<tr><td style="padding:2px 0;font-size:12px;color:#555">&nbsp;&nbsp;= Meter subsidy + hoist (separate line items)</td><td></td></tr>' +
    '<tr style="border-top:1px solid #e0e0e0"><td style="padding:6px 0">Passenger Share (meter \u2212 subsidy)</td><td style="text-align:right">$' + parseFloat(t.passengerShareFare || (t.meterFare - t.tmSubsidyFare) || 0).toFixed(2) + '</td></tr>' +
    (parseFloat(t.waitingCharge||0) > 0 ? '<tr><td style="padding:2px 0">+ Waiting Charge</td><td style="text-align:right">$' + parseFloat(t.waitingCharge).toFixed(2) + '</td></tr>' : '') +
    '<tr><td style="padding:2px 0;font-size:12px;color:#555">Hoist (passenger)</td><td style="text-align:right;font-size:12px;color:#555">$0.00</td></tr>' +
    '<tr style="border-top:2px solid #37474F"><td style="padding:6px 0"><strong>Passenger Total Pays</strong></td>' +
    '<td style="text-align:right"><strong style="font-size:15px">$' + parseFloat(t.passengerPays || 0).toFixed(2) + '</strong>' +
    (t.payMethod ? ' <span class="bx" style="font-size:10px;background:#E3F2FD;color:#1565C0">' + t.payMethod + '</span>' : '') + '</td></tr>' +
    '</table></div>';

  // Initialise Leaflet map if coordinates are available
  if (_ttMap) { _ttMap.remove(); _ttMap = null; }
  if (hasMap) {
    setTimeout(function(){
      var midLat = (t.pickupLat + t.dropLat) / 2;
      var midLng = (t.pickupLng + t.dropLng) / 2;
      _ttMap = L.map('tt-trip-map').setView([midLat, midLng], 13);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors', maxZoom: 19
      }).addTo(_ttMap);
      var greenIcon = L.divIcon({ html: '<div style="background:#2E7D32;color:#fff;border-radius:50%;width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;border:2px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.3)">P</div>', className:'', iconSize:[28,28], iconAnchor:[14,14] });
      var redIcon   = L.divIcon({ html: '<div style="background:#C62828;color:#fff;border-radius:50%;width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;border:2px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.3)">D</div>', className:'', iconSize:[28,28], iconAnchor:[14,14] });
      L.marker([t.pickupLat, t.pickupLng], {icon: greenIcon}).addTo(_ttMap)
        .bindPopup('<b>Pickup</b><br>' + (t.pickup || ''));
      L.marker([t.dropLat, t.dropLng], {icon: redIcon}).addTo(_ttMap)
        .bindPopup('<b>Dropoff</b><br>' + (t.dropoff || ''));
      L.polyline([[t.pickupLat, t.pickupLng],[t.dropLat, t.dropLng]], {
        color: '#1565C0', weight: 4, opacity: 0.75, dashArray: '8 6'
      }).addTo(_ttMap);
      _ttMap.fitBounds([[t.pickupLat, t.pickupLng],[t.dropLat, t.dropLng]], {padding:[30,30]});
    }, 120);
  }

  var histHtml = ttTripHistoryHtml(t);
  document.getElementById('tt-detail-body').innerHTML =
    document.getElementById('tt-detail-body').innerHTML + histHtml;

  var sid2 = "'" + String(id).replace(/\\/g,'\\\\').replace(/'/g,"\\'") + "'";
  var footBtns = '<button class="tm-btn" style="background:#eee;color:#333" onclick="closeTTDetail()">Close</button>';
  if (t.status === 'archived') {
    footBtns += '<button class="tm-btn tm-btn-ok" onclick="restoreTT(' + sid2 + ');closeTTDetail()">Restore</button>';
  } else {
    footBtns += '<button class="tm-btn" style="background:#546E7A;color:#fff" onclick="archiveTT(' + sid2 + ');closeTTDetail()">Archive</button>';
    if (t.status === 'pending' || t.status === 'flagged')
      footBtns += '<button class="tm-btn tm-btn-ok" onclick="approveTT(' + sid2 + ');closeTTDetail()">\u2713 Mark Company Approved</button>';
    if (t.status === 'company_approved')
      footBtns += '<button class="tm-btn" style="background:#1565C0;color:#fff" onclick="submitToCouncil(' + sid2 + ');closeTTDetail()">\u2B06 Submit to Council</button>';
    if (t.status !== 'revision_needed' && t.status !== 'approved' && t.status !== 'paid')
      footBtns += '<button class="tm-btn" style="background:#FFF8E1;color:#E65100;border:1px solid #FFE082" onclick="closeTTDetail();openSendBack(' + sid2 + ')">\u21A9 Send Back to Company</button>';
  }
  document.getElementById('tt-detail-foot').innerHTML = footBtns;
  document.getElementById('tt-ov').classList.add('open');
}
function closeTTDetail() {
  if (_ttMap) { _ttMap.remove(); _ttMap = null; }
  document.getElementById('tt-ov').classList.remove('open');
}
function row2(l, v) { return '<div class="tm-ff"><label>' + l + '</label><div style="padding:6px 0;font-weight:500">' + v + '</div></div>'; }
function frow(l, v, c) { return '<tr><td style="padding:3px 0;color:' + (c || '#333') + '">' + l + '</td><td style="text-align:right;color:' + (c || '#333') + '">' + v + '</td></tr>'; }
function ttNormalizeEvents(t) {
  var listed = [];
  if (t && t.events && typeof t.events === 'object') {
    Object.keys(t.events).forEach(function(k) {
      var e = t.events[k];
      if (!e || typeof e !== 'object') return;
      listed.push({
        at: Number(e.at) || 0, type: e.type || 'event', by: e.by || null, note: e.note || null,
        reasons: Array.isArray(e.reasons) ? e.reasons : null, fromStatus: e.fromStatus || null, toStatus: e.toStatus || null
      });
    });
  }
  if (listed.length) { listed.sort(function(a,b){ return a.at - b.at; }); return listed; }
  var synth = [];
  function push(type, at, extra) {
    var n = Number(at); if (!n) return;
    synth.push(Object.assign({ at: n, type: type, by: null, note: null, reasons: null }, extra || {}));
  }
  if (!t) return synth;
  push('submitted', t.submittedAt);
  push('flagged', t.flaggedAt, { reasons: t.flagReasons || null, note: t.anomalyDetail || null });
  push('returned', t.sentBackAt, { note: t.revisionNote || null });
  push('resubmitted', t.resubmittedAt);
  push('approved', t.approvedAt);
  push('rejected', t.rejectedAt);
  push('archived', t.archivedAt, { fromStatus: t.archivedFromStatus || null, note: t.archiveNote || null });
  synth.sort(function(a,b){ return a.at - b.at; });
  return synth;
}
function ttFormatEventLabel(e) {
  var labels = {
    submitted:'Submitted to council', flagged:'Flagged', returned:'Returned to company',
    owner_edited:'Edited by owner', resubmitted:'Resubmitted', approved:'Approved',
    rejected:'Rejected', archived:'Archived', restored:'Restored', council_edited:'Edited by council'
  };
  var line = labels[e.type] || e.type || 'Event';
  if (e.reasons && e.reasons.length) line += ' (' + e.reasons.join(', ') + ')';
  if (e.note) line += ' — ' + e.note;
  return line;
}
function ttTripHistoryHtml(t) {
  var events = ttNormalizeEvents(t);
  if (!events.length) return '';
  var rows = events.map(function(e) {
    var when = e.at ? new Date(e.at).toLocaleString('en-NZ') : '—';
    return '<div style="padding:8px 0 8px 12px;border-left:3px solid #1565C0;margin:0 0 6px 4px">' +
      '<div style="font-size:11px;color:#888">' + when + (e.by ? ' · ' + e.by : '') + '</div>' +
      '<div style="font-size:13px;font-weight:500;margin-top:2px">' + ttFormatEventLabel(e) + '</div></div>';
  }).join('');
  return '<div style="margin-top:16px"><strong style="font-size:13px;color:#1565C0">Trip history</strong>' + rows + '</div>';
}
function ttAppendEvent(t, ev) {
  if (!t) return Promise.resolve();
  var ek = '-e' + Date.now() + '_' + Math.random().toString(36).slice(2, 7);
  return adminWrite('tmTripStatus/' + t._cid + '/' + t._rawKey + '/events/' + ek, 'PUT', ev).then(function() {
    if (!t.events) t.events = {};
    t.events[ek] = ev;
  }).catch(function() {});
}
function approveTT(id) {
  if (!confirm('Mark trip ' + id + ' as Company Approved?')) return;
  var t = ttData[id]; if (!t) return;
  var path = 'tmTripStatus/' + t._cid + '/' + t._rawKey + '/status';
  adminWrite(path, 'PUT', 'company_approved')
    .then(function() { ttData[id].status = 'company_approved'; renderTT(); toastr.success('Trip marked as Company Approved.'); })
    .catch(function(e) { toastr.error('Error: ' + e); });
}
function submitToCouncil(id) {
  var t = ttData[id]; if (!t) return;
  var councilKeys = Object.keys(ttCouncils);
  var chosenCouncilId = t.councilId || '';
  if (!chosenCouncilId) {
    if (councilKeys.length === 1) {
      chosenCouncilId = councilKeys[0];
    } else if (councilKeys.length > 1) {
      var opts = councilKeys.map(function(k) { return (ttCouncils[k].name || k) + ' [' + k + ']'; });
      var pick = prompt('Select council to submit to:\n' + opts.map(function(o,i) { return (i+1) + '. ' + o; }).join('\n') + '\n\nEnter number:');
      var idx = parseInt(pick, 10) - 1;
      if (isNaN(idx) || idx < 0 || idx >= councilKeys.length) { toastr.warning('Submission cancelled.'); return; }
      chosenCouncilId = councilKeys[idx];
    } else {
      toastr.error('No councils configured. Please set up a council in TM-Council-Config first.');
      return;
    }
  }
  var councilName = (ttCouncils[chosenCouncilId] && ttCouncils[chosenCouncilId].name) || chosenCouncilId;
  if (!confirm('Submit trip ' + id + ' to ' + councilName + ' for approval?')) return;
  var path = 'tmTripStatus/' + t._cid + '/' + t._rawKey;
  adminWrite(path, 'PATCH', { status: 'submitted', councilId: chosenCouncilId, submittedAt: new Date().toISOString(), submittedBy: 'SA' })
    .then(function() {
      ttData[id].status = 'submitted';
      ttData[id].councilId = chosenCouncilId;
      return ttAppendEvent(ttData[id], {
        at: Date.now(), type: 'submitted', by: 'SA', byRole: 'sa', toStatus: 'submitted'
      });
    })
    .then(function() {
      renderTT();
      toastr.success('Trip submitted to ' + councilName + '.');
      // Phase 3: immediate anomaly scan (portal also re-scans on load)
      try {
        fetch('/api/tm-scan-submitted', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ cid: t._cid, rawKey: t._rawKey, councilId: chosenCouncilId }),
        }).then(function(r) { return r.json(); }).then(function(j) {
          if (j && j.ok && j.status === 'flagged') {
            ttData[id].status = 'flagged';
            ttData[id].flagReasons = j.flagReasons || [];
            renderTT();
            toastr.warning('Trip auto-flagged for council review (' + tmFlagReasonLabels(j.flagReasons || []).join(', ') + ').');
          }
        }).catch(function() {});
      } catch (e) {}
    })
    .catch(function(e) { toastr.error('Error: ' + e); });
}
var sbEid = null;
function openSendBack(id) {
  sbEid = id;
  document.getElementById('sb-notes').value = '';
  document.getElementById('sb-msg').textContent = '';
  document.getElementById('sb-ov').classList.add('open');
}
function closeSendBack() { document.getElementById('sb-ov').classList.remove('open'); }
function saveSendBack() {
  var id = sbEid; if (!id) return;
  var notes = document.getElementById('sb-notes').value.trim();
  if (!notes) { document.getElementById('sb-msg').textContent = 'Please enter revision notes for the company.'; return; }
  var t = ttData[id]; if (!t) return;
  var path = 'tmTripStatus/' + t._cid + '/' + t._rawKey;
  adminWrite(path, 'PATCH', { status: 'revision_needed', revisionNotes: notes, sentBackAt: new Date().toISOString(), sentBackBy: 'SA' })
    .then(function() {
      ttData[id].status = 'revision_needed';
      ttData[id].revisionNote = notes;
      return ttAppendEvent(ttData[id], {
        at: Date.now(), type: 'returned', by: 'SA', byRole: 'sa', toStatus: 'revision_needed', note: notes
      });
    })
    .then(function() { renderTT(); closeSendBack(); toastr.success('Trip sent back to company for revision.'); })
    .catch(function(e) { toastr.error('Error: ' + e); });
}
function ttMatchingIds() {
  var fC = document.getElementById('tt-f-council').value;
  var fS = document.getElementById('tt-f-status').value;
  var fFrom = document.getElementById('tt-f-from').value;
  var fTo = document.getElementById('tt-f-to').value;
  var fQ = (document.getElementById('tt-f-search').value || '').toLowerCase();
  return Object.entries(ttData).filter(function(kv) {
    var t = kv[1];
    if (fC && t.councilId !== fC) return false;
    if (fS && t.status !== fS) return false;
    var filterDt = (typeof tripDisplayTimeRaw === 'function' ? tripDisplayTimeRaw(t) : null) || t.startTime || t.endTime || '';
    if (fFrom && filterDt && _tzToDate(filterDt) < fFrom) return false;
    if (fTo && filterDt && _tzToDate(filterDt) > fTo) return false;
    if (fQ) {
      var s = (kv[0] + ' ' + (t.driverName || '') + ' ' + (t.cardNumber || '') + ' ' + ((t.allCardNums||[]).join(' ')) + ' ' + (t.passengerName || '') + ' ' + (t.vehicleId || '')).toLowerCase();
      if (!s.includes(fQ)) return false;
    }
    return true;
  }).map(function(kv) { return kv[0]; });
}
function ttSelectedIds() {
  return Array.prototype.map.call(document.querySelectorAll('.tt-row-check:checked'), function(el) { return el.value; });
}
function ttToggleAll(on) {
  document.querySelectorAll('.tt-row-check').forEach(function(el) { el.checked = !!on; });
}
function ttArchivePatch(fromStatus, note) {
  var prior = String(fromStatus || 'submitted').toLowerCase();
  if (prior === 'archived') prior = 'submitted';
  var patch = {
    status: 'archived',
    archivedAt: Date.now(),
    archivedBy: 'SA',
    archivedFromStatus: prior,
    archiveNote: note ? note : null
  };
  return patch;
}
function ttRestorePatch(t) {
  var from = String((t && t.archivedFromStatus) || 'submitted').toLowerCase();
  if (from === 'archived') from = 'submitted';
  return {
    status: from,
    archivedAt: null,
    archivedBy: null,
    archivedFromStatus: null,
    archiveNote: null,
    restoredAt: Date.now()
  };
}
function archiveTT(id) {
  var t = ttData[id]; if (!t || t.status === 'archived') return;
  if (!confirm('Archive trip ' + id + '? You can restore it later.')) return;
  var note = (document.getElementById('tt-archive-note') && document.getElementById('tt-archive-note').value || '').trim();
  var path = 'tmTripStatus/' + t._cid + '/' + t._rawKey;
  var patch = ttArchivePatch(t.status, note);
  adminWrite(path, 'PATCH', patch)
    .then(function() {
      Object.keys(patch).forEach(function(k) { ttData[id][k] = patch[k]; });
      return ttAppendEvent(ttData[id], {
        at: Date.now(), type: 'archived', by: 'SA', byRole: 'sa',
        fromStatus: patch.archivedFromStatus, toStatus: 'archived', note: patch.archiveNote
      });
    })
    .then(function() {
      renderTT();
      toastr.success('Trip archived.');
    })
    .catch(function(e) { toastr.error('Error: ' + e); });
}
function restoreTT(id) {
  var t = ttData[id]; if (!t || t.status !== 'archived') return;
  if (!confirm('Restore trip ' + id + ' to ' + (t.archivedFromStatus || 'submitted') + '?')) return;
  var path = 'tmTripStatus/' + t._cid + '/' + t._rawKey;
  var patch = ttRestorePatch(t);
  adminWrite(path, 'PATCH', patch)
    .then(function() {
      ttData[id].status = patch.status;
      ttData[id].archivedAt = null;
      ttData[id].archivedBy = null;
      ttData[id].archivedFromStatus = null;
      ttData[id].archiveNote = null;
      return ttAppendEvent(ttData[id], {
        at: Date.now(), type: 'restored', by: 'SA', byRole: 'sa', toStatus: patch.status
      });
    })
    .then(function() {
      renderTT();
      toastr.success('Trip restored.');
    })
    .catch(function(e) { toastr.error('Error: ' + e); });
}
function archiveIds(ids) {
  if (!ids.length) { toastr.warning('Select at least one trip.'); return; }
  var note = (document.getElementById('tt-archive-note') && document.getElementById('tt-archive-note').value || '').trim();
  if (!confirm('Archive ' + ids.length + ' trip(s)?')) return;
  var left = ids.length, ok = 0;
  ids.forEach(function(id) {
    var t = ttData[id];
    if (!t || t.status === 'archived') { if (--left === 0) done(); return; }
    var patch = ttArchivePatch(t.status, note);
    adminWrite('tmTripStatus/' + t._cid + '/' + t._rawKey, 'PATCH', patch)
      .then(function() {
        Object.keys(patch).forEach(function(k) { ttData[id][k] = patch[k]; });
        ok++;
        if (--left === 0) done();
      })
      .catch(function() { if (--left === 0) done(); });
  });
  function done() { renderTT(); toastr.success('Archived ' + ok + ' trip(s).'); }
}
function restoreIds(ids) {
  if (!ids.length) { toastr.warning('Select at least one trip.'); return; }
  if (!confirm('Restore ' + ids.length + ' trip(s)?')) return;
  var left = ids.length, ok = 0;
  ids.forEach(function(id) {
    var t = ttData[id];
    if (!t || t.status !== 'archived') { if (--left === 0) done(); return; }
    var patch = ttRestorePatch(t);
    adminWrite('tmTripStatus/' + t._cid + '/' + t._rawKey, 'PATCH', patch)
      .then(function() {
        ttData[id].status = patch.status;
        ttData[id].archivedAt = null;
        ttData[id].archivedBy = null;
        ttData[id].archivedFromStatus = null;
        ttData[id].archiveNote = null;
        ok++;
        if (--left === 0) done();
      })
      .catch(function() { if (--left === 0) done(); });
  });
  function done() { renderTT(); toastr.success('Restored ' + ok + ' trip(s).'); }
}
function archiveSelectedTT() { archiveIds(ttSelectedIds()); }
function restoreSelectedTT() { restoreIds(ttSelectedIds()); }
function archiveAllMatchingTT() {
  var ids = ttMatchingIds().filter(function(id) { return ttData[id] && ttData[id].status !== 'archived'; });
  archiveIds(ids);
}
function restoreAllMatchingTT() {
  var ids = ttMatchingIds().filter(function(id) { return ttData[id] && ttData[id].status === 'archived'; });
  restoreIds(ids);
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
