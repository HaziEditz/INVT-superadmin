<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Monthly Reports &mdash; BookaWaka Admin</title>
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
.tm-btn-p{background:#37474F;color:#fff}.tm-btn-p:hover{background:#263238}
.tm-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt select{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.sum-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:14px;padding:18px}
.sum-box{background:#f9f9f9;border-radius:6px;padding:14px 16px;border-left:4px solid #37474F}
.sum-box .sv{font-size:22px;font-weight:700;color:#37474F}
.sum-box .sl{font-size:12px;color:#9e9e9e;margin-top:2px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main">
  <div class="header_main_content">
    <nav class="uk-navbar">
      <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
      <div class="col-md-offset-2 col-md-4">
        <label style="color:#fff">TM Monthly Reports — BookaWaka Admin</label>
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
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
      <li><a href="TM-Reports.aspx" style="font-weight:700;color:#1565C0"><li><a href="TM-Reports.aspx" style="font-weight:700;color:#1565C0">&#9658; Monthly Reports</a></li>#9658; Monthly Reports</a></li>
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
  <div class="tm-bar">
    <h3>TM Monthly Reports <small id="rp-count" style="opacity:.75;font-size:12px"></small></h3>
    <div style="display:flex;gap:8px">
      <button class="tm-btn tm-btn-p" onclick="exportRPCSV()">Export CSV</button>
      <button class="tm-btn tm-btn-wh" onclick="refreshRP()">&#8635;</button>
    </div>
  </div>
  <div class="filt">
    <select id="rp-f-council" onchange="renderRP()"><option value="">All Councils</option></select>
    <select id="rp-f-month" onchange="renderRP()"><option value="">All Months</option></select>
    <select id="rp-f-status" onchange="renderRP()">
      <option value="">All Statuses</option>
      <option value="pending">Pending</option>
      <option value="flagged">Flagged</option>
      <option value="company_approved">Company Approved</option>
      <option value="approved">Council Approved</option>
    </select>
  </div>
  <div id="rp-summary" class="sum-grid"></div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Council</th><th>Month</th><th>Trips</th><th>Flagged</th><th>Total Fare</th>
        <th>TM Subsidy</th><th>Hoist Subsidy</th><th>Total Council Claim</th><th>Pax Total</th><th>Status Breakdown</th>
      </tr></thead>
      <tbody id="rp-tb"><tr><td colspan="10" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
    </table>
  </div>
</div>
<div class="tm-card" style="margin-top:0">
  <div class="tm-bar" style="background:#455A64">
    <h3>Trip Detail for Selection <small id="rp-detail-count" style="opacity:.75;font-size:12px"></small></h3>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Job ID</th><th>Driver</th><th>Vehicle</th><th>Card #</th><th>Passenger</th>
        <th>Date</th><th>Pickup</th><th>Dropoff</th><th>Dist</th><th>Fare</th><th>TM Sub.</th><th>Hoist</th><th>Pax Pays</th><th>Hoist Used</th><th>Status</th>
      </tr></thead>
      <tbody id="rp-detail-tb"><tr><td colspan="15" style="text-align:center;padding:20px;color:#9e9e9e">Select filters above to see trip detail.</td></tr></tbody>
    </table>
  </div>
</div>
</div>

  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/modernizr/2.8.3/modernizr.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/fastclick/1.0.6/fastclick.min.js"></script>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/uikit_custom.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var rpData = {}, rpCouncils = {};
window._fbOnLogin = function() {
  adminRead('tmConfig').then(function(d) { rpCouncils = d || {}; populateRPCouncils(); });
  loadRP();
};
function populateRPCouncils() {
  var o = '<option value="">All Councils</option>';
  Object.entries(rpCouncils).forEach(function(kv) { o += '<option value="' + kv[0] + '">' + ((kv[1].name) || kv[0]) + '</option>'; });
  document.getElementById('rp-f-council').innerHTML = o;
}
function mapTMTripRP(j, cid, rawKey) {
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
    tmSubsidyHoist: +(j.tmSubsidyHoist || 0),
    hoistTotal: +(j.hoistTotal || 0),
    passengerPays: +(j.tmPassengerPays || j.passengerPays || 0),
    totalCouncilPays: +(j.tmSubsidy || j.totalCouncilPays || j.fare || 0),
    waitingCharge: +(j.waitingCost || j.WaitingCost || 0),
    distance: j.distanceKm || '',
    hoistUsed: j.hoistUsed || false,
    hoistCount: j.hoistCount || 0,
    status: 'pending', flagReasons: []
  };
}
function loadRP() {
  adminRead('completedJobs').then(function(allJobs) {
    rpData = {};
    if (allJobs && typeof allJobs === 'object') {
      Object.entries(allJobs).forEach(function(cidEntry) {
        var cid = cidEntry[0], jobs = cidEntry[1] || {};
        Object.entries(jobs).forEach(function(jobEntry) {
          var rawKey = jobEntry[0], j = jobEntry[1];
          if (j.paymentType !== 'total_mobility') return;
          var id = j.bookingId || rawKey;
          rpData[id] = mapTMTripRP(j, cid, rawKey);
        });
      });
    }
    adminRead('tmTripStatus').then(function(statuses) {
      var s = statuses || {};
      Object.keys(rpData).forEach(function(id) {
        var t = rpData[id];
        var st = s[t._cid] && s[t._cid][t._rawKey];
        if (st) { t.status = st.status || t.status; t.flagReasons = st.flagReasons || []; }
      });
      buildMonthFilter(); renderRP();
    }).catch(function() { buildMonthFilter(); renderRP(); });
  }).catch(function() { buildMonthFilter(); renderRP(); });
}
function refreshRP() {
  loadRP();
}
function buildMonthFilter() {
  var months = {};
  Object.values(rpData).forEach(function(t) { if (t.startTime) months[t.startTime.slice(0,7)] = true; });
  var sorted = Object.keys(months).sort().reverse();
  var cur = document.getElementById('rp-f-month').value;
  var o = '<option value="">All Months</option>';
  sorted.forEach(function(m) { o += '<option value="' + m + '"' + (m === cur ? ' selected' : '') + '>' + m + '</option>'; });
  document.getElementById('rp-f-month').innerHTML = o;
}
function renderRP() {
  var fC = document.getElementById('rp-f-council').value;
  var fM = document.getElementById('rp-f-month').value;
  var fS = document.getElementById('rp-f-status').value;
  var filtered = Object.entries(rpData).filter(function(kv) {
    var t = kv[1];
    if (fC && t.councilId !== fC) return false;
    if (fM && (t.startTime || '').slice(0,7) !== fM) return false;
    if (fS && t.status !== fS) return false;
    return true;
  });
  document.getElementById('rp-count').textContent = filtered.length + ' trips';
  var cnames = {}; Object.entries(rpCouncils).forEach(function(kv) { cnames[kv[0]] = (kv[1].name) || kv[0]; });
  var agg = {};
  filtered.forEach(function(kv) {
    var t = kv[1];
    var month = (t.startTime || '').slice(0,7) || 'Unknown';
    var council = t.councilId || 'unknown';
    var aggKey = council + '||' + month;
    if (!agg[aggKey]) agg[aggKey] = { council: council, month: month, trips: 0, flagged: 0, totalFare: 0, tmSubFare: 0, tmSubHoist: 0, totalClaim: 0, paxTotal: 0, statuses: {} };
    var a = agg[aggKey];
    a.trips++;
    if (t.status === 'flagged') a.flagged++;
    a.totalFare += parseFloat(t.meterFare || 0);
    a.tmSubFare += parseFloat(t.tmSubsidyFare || 0);
    a.tmSubHoist += parseFloat(t.tmSubsidyHoist || 0);
    a.totalClaim += parseFloat(t.totalCouncilPays || 0);
    a.paxTotal += parseFloat(t.passengerPays || 0);
    a.statuses[t.status || 'pending'] = (a.statuses[t.status || 'pending'] || 0) + 1;
  });
  var totFare = 0, totClaim = 0, totTrips = 0, totFlagged = 0;
  Object.values(agg).forEach(function(a) { totFare += a.totalFare; totClaim += a.totalClaim; totTrips += a.trips; totFlagged += a.flagged; });
  document.getElementById('rp-summary').innerHTML =
    sumBox('Total Trips', totTrips, '') + sumBox('Flagged', totFlagged, '#B71C1C') +
    sumBox('Total Fare', '$' + totFare.toFixed(2), '') + sumBox('Total Council Claim', '$' + totClaim.toFixed(2), '#2E7D32');
  var rows = Object.values(agg).sort(function(a,b) { return b.month.localeCompare(a.month) || a.council.localeCompare(b.council); });
  document.getElementById('rp-tb').innerHTML = !rows.length
    ? '<tr><td colspan="10" style="text-align:center;padding:30px;color:#9e9e9e">No trips match the selected filters.</td></tr>'
    : rows.map(function(a) {
      var stBreak = Object.entries(a.statuses).map(function(kv) { return kv[0] + ':' + kv[1]; }).join(', ');
      return '<tr>' +
        '<td><strong>' + (cnames[a.council] || a.council) + '</strong></td>' +
        '<td>' + a.month + '</td>' +
        '<td style="font-weight:600">' + a.trips + '</td>' +
        '<td>' + (a.flagged > 0 ? '<span class="bx bx-r">' + a.flagged + '</span>' : '0') + '</td>' +
        '<td>$' + a.totalFare.toFixed(2) + '</td>' +
        '<td style="color:#2E7D32;font-weight:600">$' + a.tmSubFare.toFixed(2) + '</td>' +
        '<td style="color:#1565C0">$' + a.tmSubHoist.toFixed(2) + '</td>' +
        '<td style="font-weight:700;color:#2E7D32;font-size:14px">$' + a.totalClaim.toFixed(2) + '</td>' +
        '<td>$' + a.paxTotal.toFixed(2) + '</td>' +
        '<td style="font-size:11px;color:#9e9e9e">' + stBreak + '</td></tr>';
    }).join('');
  var detailRows = filtered.sort(function(a,b) { return (b[1].startTime || '').localeCompare(a[1].startTime || ''); });
  document.getElementById('rp-detail-count').textContent = detailRows.length + ' trips';
  document.getElementById('rp-detail-tb').innerHTML = !detailRows.length
    ? '<tr><td colspan="15" style="text-align:center;padding:20px;color:#9e9e9e">No trips.</td></tr>'
    : detailRows.map(function(kv) {
      var id = kv[0], t = kv[1];
      var dt = t.startTime ? (t.startTime.slice(0,10) + ' ' + t.startTime.slice(11,16)) : '\u2014';
      var stMap = { pending: '<span class="bx bx-gr">Pending</span>', flagged: '<span class="bx bx-r">Flagged</span>', company_approved: '<span class="bx bx-b">Co.Approved</span>', approved: '<span class="bx bx-g">Approved</span>', rejected: '<span class="bx bx-r">Rejected</span>' };
      return '<tr>' +
        '<td style="font-family:monospace;font-size:12px">' + id + '</td>' +
        '<td>' + (t.driverName || '\u2014') + '</td>' +
        '<td>' + (t.vehicleId || '\u2014') + '</td>' +
        '<td style="font-family:monospace">' + (t.cardNumber || '\u2014') + '</td>' +
        '<td>' + (t.passengerName || '\u2014') + '</td>' +
        '<td>' + dt + '</td>' +
        '<td>' + (t.pickup || '\u2014') + '</td>' +
        '<td>' + (t.dropoff || '\u2014') + '</td>' +
        '<td>' + (t.distance ? t.distance + ' km' : '\u2014') + '</td>' +
        '<td>$' + parseFloat(t.meterFare || 0).toFixed(2) + '</td>' +
        '<td style="color:#2E7D32;font-weight:600">$' + parseFloat(t.tmSubsidyFare || 0).toFixed(2) + '</td>' +
        '<td style="color:#1565C0">$' + parseFloat(t.tmSubsidyHoist || 0).toFixed(2) + '</td>' +
        '<td>$' + parseFloat(t.passengerPays || 0).toFixed(2) + '</td>' +
        '<td>' + (t.hoistUsed ? 'Yes (' + t.hoistCount + ')' : 'No') + '</td>' +
        '<td>' + (stMap[t.status] || t.status || '\u2014') + '</td></tr>';
    }).join('');
}
function sumBox(label, val, color) {
  return '<div class="sum-box"><div class="sv" style="' + (color ? 'color:' + color : '') + '">' + val + '</div><div class="sl">' + label + '</div></div>';
}
function exportRPCSV() {
  var fC = document.getElementById('rp-f-council').value;
  var fM = document.getElementById('rp-f-month').value;
  var fS = document.getElementById('rp-f-status').value;
  var cnames = {}; Object.entries(rpCouncils).forEach(function(kv) { cnames[kv[0]] = (kv[1].name) || kv[0]; });
  var rows = [['Job ID','Driver','Vehicle','Card #','Passenger','Council','Date','Pickup','Dropoff','Distance(km)','Meter Fare','TM Subsidy Fare','TM Subsidy Hoist','Total Council Pays','Passenger Pays','Hoist Used','Hoist Count','Waiting','Status','Flag Reasons']];
  Object.entries(rpData).forEach(function(kv) {
    var t = kv[1];
    if (fC && t.councilId !== fC) return;
    if (fM && (t.startTime || '').slice(0,7) !== fM) return;
    if (fS && t.status !== fS) return;
    rows.push([kv[0], t.driverName || '', t.vehicleId || '', t.cardNumber || '', t.passengerName || '',
      cnames[t.councilId] || t.councilId || '', t.startTime ? t.startTime.slice(0,16) : '',
      t.pickup || '', t.dropoff || '', t.distance || '',
      parseFloat(t.meterFare || 0).toFixed(2), parseFloat(t.tmSubsidyFare || 0).toFixed(2),
      parseFloat(t.tmSubsidyHoist || 0).toFixed(2), parseFloat(t.totalCouncilPays || 0).toFixed(2),
      parseFloat(t.passengerPays || 0).toFixed(2), t.hoistUsed ? 'Yes' : 'No', t.hoistCount || 0,
      parseFloat(t.waitingCharge || 0).toFixed(2), t.status || '', (t.flagReasons || []).join(';')]);
  });
  var csv = rows.map(function(r) { return r.map(function(v) { return '"' + String(v).replace(/"/g, '""') + '"'; }).join(','); }).join('\n');
  var blob = new Blob([csv], { type: 'text/csv' });
  var url = URL.createObjectURL(blob);
  var a = document.createElement('a');
  a.href = url; a.download = 'TM_Report_' + (fM || 'All') + '_' + (fC || 'AllCouncils') + '.csv';
  document.body.appendChild(a); a.click(); document.body.removeChild(a); URL.revokeObjectURL(url);
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
