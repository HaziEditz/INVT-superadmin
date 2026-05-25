<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Flagged Trips &mdash; BookaWaka Admin</title>
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
  apiKey: "AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",
  authDomain: "taxilatest.firebaseapp.com",
  databaseURL: "https://taxilatest.firebaseio.com",
  projectId: "taxilatest",
  storageBucket: "taxilatest.appspot.com"
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
.bx-b{background:#E3F2FD;color:#1565C0}.bx-gr{background:#F5F5F5;color:#616161}
.tm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.tm-btn-p{background:#37474F;color:#fff}.tm-btn-e{background:#E3F2FD;color:#1565C0}
.tm-btn-ok{background:#E8F5E9;color:#2E7D32}.tm-btn-am{background:#FFF8E1;color:#1565C0}
.tm-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.tm-ov{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:999;align-items:center;justify-content:center}
.tm-ov.open{display:flex}
.tm-modal{background:#fff;border-radius:8px;width:700px;max-width:95vw;max-height:92vh;overflow-y:auto;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.tm-mh{background:#37474F;color:#fff;padding:14px 18px;display:flex;align-items:center;justify-content:space-between;border-radius:8px 8px 0 0}
.tm-mh h3{margin:0;font-size:15px}
.tm-mb{padding:18px}.tm-mf{padding:12px 18px;border-top:1px solid #eee;display:flex;gap:8px;justify-content:flex-end}
.tm-fg{display:grid;grid-template-columns:1fr 1fr;gap:12px 18px}
.tm-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.tm-ff input,.tm-ff select{width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.tm-ff input:focus,.tm-ff select:focus{outline:none;border-color:#37474F}
.tm-msg{margin-top:8px;font-size:13px}.tm-msg.ok{color:#2E7D32}.tm-msg.err{color:#C62828}
.fc{display:inline-block;background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;border-radius:10px;padding:1px 7px;font-size:11px;font-weight:600;margin:1px}
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt select{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main">
  <div class="header_main_content">
    <nav class="uk-navbar">
      <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
      <div class="col-md-offset-2 col-md-4">
        <label style="color:#fff">TM Flagged Trips — BookaWaka Admin</label>
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
      <li><a href="TM-Council-Config.aspx">Council Config</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx" style="font-weight:700;color:#1565C0">&#9658; Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
      <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
      <li><a href="TM-Settings.aspx">TM Settings</a></li>
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
  <div class="tm-bar" style="background:#B71C1C">
    <h3>Flagged TM Trips <small id="fl-count" style="opacity:.85;font-size:12px"></small></h3>
    <button class="tm-btn tm-btn-wh" onclick="refreshFL()">&#8635;</button>
  </div>
  <div class="filt">
    <select id="fl-f-council" onchange="renderFL()"><option value="">All Councils</option></select>
    <select id="fl-f-reason" onchange="renderFL()">
      <option value="">All Flag Reasons</option>
      <option value="waiting_charged">Waiting Charged</option>
      <option value="hoist_vehicle_mismatch">Hoist Vehicle Mismatch</option>
      <option value="hoist_count_exceeded">Hoist Count Exceeded</option>
      <option value="hoist_rate_mismatch">Hoist Rate Mismatch</option>
      <option value="fare_mismatch">Fare Mismatch</option>
      <option value="limit_exceeded_daily">Daily Limit Exceeded</option>
      <option value="limit_exceeded_monthly">Monthly Limit Exceeded</option>
      <option value="card_inactive">Card Inactive</option>
      <option value="unapproved_tariff">Unapproved Tariff</option>
    </select>
    <select id="fl-f-stage" onchange="renderFL()">
      <option value="">All Stages</option>
      <option value="flagged">Awaiting Company Fix</option>
      <option value="company_approved">Awaiting Council</option>
      <option value="rejected">Rejected by Council</option>
    </select>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Job ID</th><th>Driver</th><th>Card #</th><th>Council</th><th>Date</th>
        <th>Fare</th><th>TM Sub.</th><th>Flag Reasons</th><th>Stage</th><th>Actions</th>
      </tr></thead>
      <tbody id="fl-tb"><tr><td colspan="10" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
    </table>
  </div>
</div></div>

<div class="tm-ov" id="fl-ov">
<div class="tm-modal">
  <div class="tm-mh" style="background:#B71C1C"><h3 id="fl-etitle">Resolve Flagged Trip</h3>
    <button onclick="closeFLEdit()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
  <div class="tm-mb">
    <div id="fl-flag-box" style="padding:10px;background:#FFEBEE;border-radius:4px;border-left:4px solid #C62828;margin-bottom:14px"></div>
    <div class="tm-fg">
      <div class="tm-ff"><label>Meter Fare ($)</label><input id="fl-fare" type="number" step="0.01" min="0"/></div>
      <div class="tm-ff"><label>Waiting Charge ($) — must be 0 for TM</label><input id="fl-wait" type="number" step="0.01" min="0"/></div>
      <div class="tm-ff"><label>Hoist Used</label>
        <select id="fl-hoist"><option value="false">No</option><option value="true">Yes</option></select></div>
      <div class="tm-ff"><label>Hoist Count</label><input id="fl-hcnt" type="number" min="0" value="0"/></div>
      <div class="tm-ff" style="grid-column:1/-1"><label>Resolution Notes</label><input id="fl-resnote" placeholder="Explain what was corrected&#8230;"/></div>
    </div>
    <div id="fl-msg" class="tm-msg"></div>
  </div>
  <div class="tm-mf">
    <button class="tm-btn" style="background:#eee;color:#333" onclick="closeFLEdit()">Cancel</button>
    <button class="tm-btn tm-btn-am" onclick="saveFL(false)">Save &amp; Keep Flagged</button>
    <button class="tm-btn tm-btn-ok" onclick="saveFL(true)">Save &amp; Company Approve</button>
  </div>
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
var flData = {}, flAllTM = {}, flCouncils = {}, flEid = null;
window._fbOnLogin = function() {
  adminRead('tmConfig').then(function(d) { flCouncils = d || {}; populateFLCouncils(); });
  loadFL();
};
function populateFLCouncils() {
  var o = '<option value="">All Councils</option>';
  Object.entries(flCouncils).forEach(function(kv) { o += '<option value="' + kv[0] + '">' + ((kv[1].name) || kv[0]) + '</option>'; });
  document.getElementById('fl-f-council').innerHTML = o;
}
function mapTMTripFL(j, cid, rawKey) {
  return {
    _cid: cid, _rawKey: rawKey,
    councilId: j.councilId || '',
    driverName: j.driverName || '',
    vehicleId: j.vehicleId || '',
    cardNumber: j.tmVoucherNo || j.cardNumber || '',
    passengerName: j.tmPassengerName || j.passengerName || '',
    startTime: j.startedAt_ISO || j.startedAt || '',
    pickup: j.pickupAddress || j.pickup || '',
    dropoff: j.dropAddress || j.dropoff || '',
    meterFare: +(j.fare || j.meterFare || 0),
    tmSubsidyFare: +(j.tmSubsidy || j.tmSubsidyFare || 0),
    hoistUsed: j.hoistUsed || false, hoistCount: j.hoistCount || 0, hoistTotal: +(j.hoistTotal || 0),
    passengerPays: +(j.tmPassengerPays || j.passengerPays || 0),
    totalCouncilPays: +(j.tmSubsidy || j.totalCouncilPays || j.fare || 0),
    waitingCharge: +(j.waitingCost || j.WaitingCost || 0),
    status: 'pending', flagReasons: [], resolutionNote: ''
  };
}
function loadFL() {
  adminRead('completedJobs').then(function(allJobs) {
    flAllTM = {};
    if (allJobs && typeof allJobs === 'object') {
      Object.entries(allJobs).forEach(function(cidEntry) {
        var cid = cidEntry[0], jobs = cidEntry[1] || {};
        Object.entries(jobs).forEach(function(jobEntry) {
          var rawKey = jobEntry[0], j = jobEntry[1];
          if (j.paymentType !== 'total_mobility') return;
          var id = j.bookingId || rawKey;
          flAllTM[id] = mapTMTripFL(j, cid, rawKey);
        });
      });
    }
    adminRead('tmTripStatus').then(function(statuses) {
      var s = statuses || {};
      flData = {};
      Object.keys(flAllTM).forEach(function(id) {
        var t = flAllTM[id];
        var st = s[t._cid] && s[t._cid][t._rawKey];
        if (st) {
          t.status = st.status || t.status;
          t.flagReasons = st.flagReasons || [];
          t.resolutionNote = st.resolutionNote || '';
          if (st.meterFare !== undefined) t.meterFare = +st.meterFare;
          if (st.tmSubsidyFare !== undefined) t.tmSubsidyFare = +st.tmSubsidyFare;
          if (st.totalCouncilPays !== undefined) t.totalCouncilPays = +st.totalCouncilPays;
          if (st.passengerPays !== undefined) t.passengerPays = +st.passengerPays;
        }
        var flaggedStatuses = ['flagged','company_approved','rejected','revision_needed'];
        if (flaggedStatuses.indexOf(t.status) !== -1) flData[id] = t;
      });
      renderFL();
    }).catch(function() { renderFL(); });
  }).catch(function() { renderFL(); });
}
function refreshFL() {
  document.getElementById('fl-tb').innerHTML = '<tr><td colspan="10" style="text-align:center;padding:30px;color:#9e9e9e">Refreshing\u2026</td></tr>';
  loadFL();
}
function renderFL() {
  var fC = document.getElementById('fl-f-council').value;
  var fR = document.getElementById('fl-f-reason').value;
  var fSt = document.getElementById('fl-f-stage').value;
  var entries = Object.entries(flData).filter(function(kv) {
    var t = kv[1];
    if (fC && t.councilId !== fC) return false;
    if (fR && !(t.flagReasons || []).includes(fR)) return false;
    if (fSt && t.status !== fSt) return false;
    return true;
  });
  entries.sort(function(a,b) { return (b[1].startTime || '').localeCompare(a[1].startTime || ''); });
  document.getElementById('fl-count').textContent = entries.length + ' flagged trip(s)';
  if (!entries.length) { document.getElementById('fl-tb').innerHTML = '<tr><td colspan="10" style="text-align:center;padding:40px;color:#9e9e9e">No flagged trips \u2014 all clear!</td></tr>'; return; }
  var cnames = {}; Object.entries(flCouncils).forEach(function(kv) { cnames[kv[0]] = (kv[1].name) || kv[0]; });
  document.getElementById('fl-tb').innerHTML = entries.map(function(kv) {
    var id = kv[0], t = kv[1], sid = "'" + String(id).replace(/\\/g,'\\\\').replace(/'/g,"\\'") + "'";
    var flags = (t.flagReasons || []).map(function(f) { return '<span class="fc">' + f + '</span>'; }).join('');
    var stageMap = { flagged: '<span class="bx bx-r">Needs Fix</span>', company_approved: '<span class="bx bx-b">Sent to Council</span>', rejected: '<span class="bx bx-r">Rejected</span>' };
    var dt = t.startTime ? (t.startTime.slice(0,10) + ' ' + t.startTime.slice(11,16)) : '\u2014';
    return '<tr style="background:#FFF8F8">' +
      '<td style="font-family:monospace;font-size:12px;font-weight:600">' + id + '</td>' +
      '<td>' + (t.driverName || '\u2014') + '</td>' +
      '<td style="font-family:monospace">' + (t.cardNumber || '\u2014') + '</td>' +
      '<td>' + (cnames[t.councilId] || t.councilId || '\u2014') + '</td>' +
      '<td>' + dt + '</td>' +
      '<td>$' + parseFloat(t.meterFare || 0).toFixed(2) + '</td>' +
      '<td style="color:#2E7D32;font-weight:600">$' + parseFloat(t.tmSubsidyFare || 0).toFixed(2) + '</td>' +
      '<td>' + flags + '</td>' +
      '<td>' + (stageMap[t.status] || t.status) + '</td>' +
      '<td style="white-space:nowrap">' +
        '<button class="tm-btn tm-btn-e" onclick="editFL(' + sid + ')" style="margin-right:4px">Fix</button>' +
        (t.status === 'flagged' ? '<button class="tm-btn tm-btn-ok" onclick="approveFL(' + sid + ')" title="Mark Company Approved">\u2713</button>' : '') +
      '</td></tr>';
  }).join('');
}
function editFL(id) {
  flEid = id; var t = flData[id] || {};
  document.getElementById('fl-etitle').textContent = 'Fix Trip ' + id;
  var flags = (t.flagReasons || []).map(function(f) { return '<span class="fc">' + f + '</span>'; }).join('');
  document.getElementById('fl-flag-box').innerHTML = '<strong style="color:#C62828">Flags:</strong> ' + flags;
  document.getElementById('fl-fare').value = t.meterFare || '';
  document.getElementById('fl-wait').value = t.waitingCharge || 0;
  document.getElementById('fl-hoist').value = t.hoistUsed ? 'true' : 'false';
  document.getElementById('fl-hcnt').value = t.hoistCount || 0;
  document.getElementById('fl-resnote').value = t.resolutionNote || '';
  document.getElementById('fl-msg').textContent = '';
  document.getElementById('fl-ov').classList.add('open');
}
function closeFLEdit() { document.getElementById('fl-ov').classList.remove('open'); }
function saveFL(doApprove) {
  var id = flEid; if (!id) return;
  var fare = parseFloat(document.getElementById('fl-fare').value);
  var wait = parseFloat(document.getElementById('fl-wait').value) || 0;
  if (isNaN(fare) || fare < 0) { flMsg('Enter valid fare.', false); return; }
  if (wait > 0) { flMsg('Waiting charge must be 0 for TM trips.', false); return; }
  var t = flData[id] || {};
  var councilCfg = flCouncils[t.councilId] || {};
  var pct = (councilCfg.subsidyPercent || 75) / 100;
  var cap = councilCfg.capAmount || 37.50;
  var hoistUsed = document.getElementById('fl-hoist').value === 'true';
  var hoistCnt = parseInt(document.getElementById('fl-hcnt').value) || 0;
  var hoistRate = councilCfg.hoistRatePerUse || 0;
  var hoistTotal = hoistUsed ? hoistRate * hoistCnt : 0;
  var tmSubFare = Math.min(fare * pct, cap);
  var tmSubHoist = councilCfg.hoistCoveredByCouncil !== false ? hoistTotal : 0;
  var totalCouncil = tmSubFare + tmSubHoist;
  var paxPays = fare + hoistTotal - totalCouncil;
  var updates = {
    meterFare: fare, waitingCharge: 0, hoistUsed: hoistUsed, hoistCount: hoistCnt, hoistTotal: hoistTotal,
    tmSubsidyFare: parseFloat(tmSubFare.toFixed(2)), tmSubsidyHoist: parseFloat(tmSubHoist.toFixed(2)),
    totalCouncilPays: parseFloat(totalCouncil.toFixed(2)), passengerPays: parseFloat(paxPays.toFixed(2)),
    resolutionNote: document.getElementById('fl-resnote').value.trim(),
    status: doApprove ? 'company_approved' : 'flagged',
    companyApproved: doApprove, updatedAt: Date.now()
  };
  var t = flData[id] || {};
  var path = 'tmTripStatus/' + t._cid + '/' + t._rawKey;
  adminWrite(path, 'PATCH', updates)
    .then(function() {
      Object.assign(flData[id], updates);
      if (doApprove) { delete flData[id]; }
      renderFL(); closeFLEdit(); toastr.success('Trip updated.');
    }).catch(function(e) { flMsg('Save failed: ' + e, false); });
}
function approveFL(id) {
  if (!confirm('Mark trip ' + id + ' as Company Approved and send to council queue?')) return;
  var t = flData[id]; if (!t) return;
  var path = 'tmTripStatus/' + t._cid + '/' + t._rawKey;
  adminWrite(path, 'PATCH', { status: 'company_approved', companyApproved: true, updatedAt: Date.now() })
    .then(function() {
      if (flData[id]) flData[id].status = 'company_approved';
      renderFL(); toastr.success('Trip moved to council queue.');
    }).catch(function(e) { toastr.error('Error: ' + e); });
}
function flMsg(m, ok) { var el = document.getElementById('fl-msg'); el.textContent = m; el.className = 'tm-msg ' + (ok ? 'ok' : 'err'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
