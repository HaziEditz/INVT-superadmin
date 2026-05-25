<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Settings &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="assets/js/jquery.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet"/>
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet"/>
<link href="assets/css/main.min.css" rel="stylesheet"/>
<link href="assets/css/Toast.css" rel="stylesheet"/>
<link href="assets/css/bootstrap.min.css" rel="stylesheet"/>
<link href="toast/toastr.min.css" rel="stylesheet"/>
<script src="toast/toastr.min.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<style>
.tm-wrap{padding:20px}
.tm-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:24px;overflow:hidden}
.tm-bar{background:#37474F;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.tm-bar h3{margin:0;font-size:15px;font-weight:600}
.tm-tbl{width:100%;border-collapse:collapse;font-size:13px}
.tm-tbl th{background:#f5f5f5;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #e0e0e0;white-space:nowrap;color:#37474F}
.tm-tbl td{padding:9px 11px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.tm-tbl tr:hover td{background:#fafafa}
.tm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:600}
.tm-btn-p{background:#37474F;color:#fff}.tm-btn-p:hover{background:#263238}
.tm-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.tm-btn-green{background:#2E7D32;color:#fff}.tm-btn-green:hover{background:#1B5E20}
.tm-btn-red{background:#C62828;color:#fff}.tm-btn-red:hover{background:#B71C1C}
.tm-btn-blue{background:#1565C0;color:#fff}.tm-btn-blue:hover{background:#0D47A1}
.tm-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.bx{display:inline-block;padding:3px 10px;border-radius:10px;font-size:11px;font-weight:700;white-space:nowrap}
.bx-g{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.bx-r{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.bx-gr{background:#F5F5F5;color:#757575;border:1px solid #E0E0E0}
.bx-b{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.notice{padding:11px 16px;border-radius:6px;font-size:13px;margin-bottom:16px}
.notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.cid-badge{font-family:monospace;background:#ECEFF1;color:#37474F;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700}
/* Tariff modal */
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:10px;padding:28px;max-width:580px;width:95%;box-shadow:0 8px 30px rgba(0,0,0,.22);max-height:90vh;overflow-y:auto}
.modal-box h3{font-size:16px;font-weight:700;margin-bottom:4px;color:#263238}
.modal-sub{font-size:13px;color:#aaa;margin-bottom:18px}
.tariff-section{background:#F9FAFB;border:1px solid #E8EAED;border-radius:6px;padding:14px 16px;margin-bottom:16px}
.tariff-section h4{font-size:13px;font-weight:700;color:#37474F;margin-bottom:12px;display:flex;align-items:center;gap:6px}
.tariff-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.tf label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.tf input{width:100%;padding:7px 9px;border:1.5px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.tf input:focus{outline:none;border-color:#37474F}
.modal-actions{display:flex;gap:8px;justify-content:flex-end;margin-top:18px}
.modal-msg{font-size:13px;margin-top:8px}.modal-msg.ok{color:#2E7D32}.modal-msg.err{color:#C62828}
/* Filter bar */
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt select{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
/* Empty */
.empty-row td{text-align:center;padding:36px;color:#aaa;font-style:italic}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">TM Settings &mdash; BookaWaka Admin</label></div>
  <div class="uk-navbar-flip"><ul class="uk-navbar-nav user_actions">
    <li data-uk-dropdown="{mode:'click',pos:'bottom-right'}">
      <a href="#" class="user_action_image"><img class="md-user-image" src="assets/img/bw-logo.png" alt=""/></a>
      <div class="uk-dropdown uk-dropdown-small"><ul class="uk-nav js-uk-prevent">
        <li><a href="Home.aspx">Dashboard</a></li>
        <li><a onclick="(function(){ window.location.href='SA-Login.aspx'; })()">Logout</a></li>
      </ul></div>
    </li>
  </ul></div>
</nav></div></header>

<aside id="sidebar_main">
  <div class="sidebar_main_header"><div class="sidebar_logo">
    <a href="Home.aspx" class="sSidebar_hide"><img src="assets/img/bw-logo.png" alt="" style="height:100px;width:100px;border-radius:50%"/></a>
    <a href="Home.aspx" class="sSidebar_show"><img src="assets/img/bw-logo.png" alt="" style="height:50px;width:50px;border-radius:50%"/></a>
  </div></div>
  <div class="menu_section"><ul>
    <li title="Dashboard"><a href="Home.aspx"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Home</span></a></li>
    <li class="current_section" title="Master Entries"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Master Entries</span></a><ul>
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
    </ul></li>
    <li class="current_section" title="Total Mobility"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8CC;</i></span><span class="menu_title">Total Mobility</span></a><ul>
      <li><a href="TM-Council-Config.aspx">Council Config</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
      <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
      <li><a href="TM-Settings.aspx" style="font-weight:700;color:#1565C0">&#9658; TM Settings</a></li>
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

<div id="page_content"><div id="page_content_inner">
<div class="tm-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:4px;color:#37474F">&#9881; TM Settings</h2>
<p style="font-size:13px;color:#888;margin-bottom:20px">Approve companies to operate Total Mobility under each council, and set per-company TM fare tariffs (car &amp; wheelchair van). These are read by the Passenger App and Driver App in real time.</p>

<div id="pg-notice" style="display:none" class="notice"></div>

<!-- ── Section 1: Company TM Approval ─────────────────────────────────────── -->
<div class="tm-card">
  <div class="tm-bar">
    <h3>&#10003; Company TM Approval <small id="approval-count" style="opacity:.75;font-size:12px"></small></h3>
    <button class="tm-btn tm-btn-wh" onclick="loadAll()">&#8635; Refresh</button>
  </div>
  <div class="filt">
    <label style="font-size:13px;color:#666;font-weight:500">Filter by Council:</label>
    <select id="f-council" onchange="renderApproval()"><option value="">All Councils</option></select>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Company</th>
        <th>ID</th>
        <th>Council</th>
        <th>TM Status</th>
        <th>Approved / Revoked</th>
        <th>Action</th>
      </tr></thead>
      <tbody id="approval-tb">
        <tr class="empty-row"><td colspan="6">Loading&#8230;</td></tr>
      </tbody>
    </table>
  </div>
</div>

<!-- ── Section 2: TM Tariffs per Company ──────────────────────────────────── -->
<div class="tm-card">
  <div class="tm-bar">
    <h3>&#128667; TM Fare Tariffs <small style="opacity:.75;font-size:12px">(per company)</small></h3>
    <button class="tm-btn tm-btn-wh" onclick="renderTariffs()">&#8635; Refresh</button>
  </div>
  <p style="padding:10px 18px 0;font-size:12.5px;color:#888">Set the metered rates used to calculate TM fares. Each company can have different car and wheelchair van rates. The passenger app uses these to show the fare estimate and split.</p>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Company</th>
        <th>&#128665; Car — Base</th>
        <th>&#128665; Car — /km</th>
        <th>&#128665; Car — /min</th>
        <th>&#128665; Car — Stop</th>
        <th>&#9855; Van — Base</th>
        <th>&#9855; Van — /km</th>
        <th>&#9855; Van — /min</th>
        <th>&#9855; Van — Stop</th>
        <th>Last Updated</th>
        <th>Action</th>
      </tr></thead>
      <tbody id="tariff-tb">
        <tr class="empty-row"><td colspan="11">Loading&#8230;</td></tr>
      </tbody>
    </table>
  </div>
</div>

</div></div></div>

<!-- ── Tariff Edit Modal ──────────────────────────────────────────────────── -->
<div class="modal-overlay" id="tariff-modal">
<div class="modal-box">
  <h3>&#128667; Set TM Tariffs</h3>
  <div class="modal-sub" id="tariff-modal-sub">Company name</div>

  <div class="tariff-section">
    <h4>&#128665; Standard Car Rate</h4>
    <div class="tariff-grid">
      <div class="tf"><label>Base Fare ($)</label><input type="number" id="t-car-base" step="0.01" min="0" placeholder="e.g. 3.50"/></div>
      <div class="tf"><label>Per Kilometre ($)</label><input type="number" id="t-car-km" step="0.01" min="0" placeholder="e.g. 2.20"/></div>
      <div class="tf"><label>Per Minute ($)</label><input type="number" id="t-car-min" step="0.01" min="0" placeholder="e.g. 0.45"/></div>
      <div class="tf"><label>Stop / Waiting Fee ($)</label><input type="number" id="t-car-stop" step="0.01" min="0" placeholder="e.g. 0.00"/></div>
    </div>
  </div>

  <div class="tariff-section">
    <h4>&#9855; Wheelchair Van Rate</h4>
    <div class="tariff-grid">
      <div class="tf"><label>Base Fare ($)</label><input type="number" id="t-van-base" step="0.01" min="0" placeholder="e.g. 5.00"/></div>
      <div class="tf"><label>Per Kilometre ($)</label><input type="number" id="t-van-km" step="0.01" min="0" placeholder="e.g. 2.80"/></div>
      <div class="tf"><label>Per Minute ($)</label><input type="number" id="t-van-min" step="0.01" min="0" placeholder="e.g. 0.55"/></div>
      <div class="tf"><label>Stop / Waiting Fee ($)</label><input type="number" id="t-van-stop" step="0.01" min="0" placeholder="e.g. 0.00"/></div>
    </div>
  </div>

  <div class="modal-msg" id="tariff-modal-msg"></div>
  <div class="modal-actions">
    <button class="tm-btn tm-btn-n" onclick="closeTariffModal()">Cancel</button>
    <button class="tm-btn tm-btn-p" id="tariff-save-btn" onclick="saveTariff()">Save Tariffs</button>
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
var allCompanies = {};
var allCouncils  = {};
var allAccess    = {};
var allTariffs   = {};
var _tariffCid   = null;

window._fbOnLogin = function() { loadAll(); };

function loadAll() {
  document.getElementById('approval-tb').innerHTML  = '<tr class="empty-row"><td colspan="6">Loading&#8230;</td></tr>';
  document.getElementById('tariff-tb').innerHTML    = '<tr class="empty-row"><td colspan="11">Loading&#8230;</td></tr>';
  Promise.all([
    adminRead('superClients'),
    adminRead('tmConfig'),
    adminRead('tmCompanyAccess'),
    adminRead('tmTariffs')
  ]).then(function(res) {
    allCompanies = res[0] || {};
    allCouncils  = res[1] || {};
    allAccess    = res[2] || {};
    allTariffs   = res[3] || {};
    populateCouncilFilter();
    renderApproval();
    renderTariffs();
  }).catch(function(e) {
    showNotice('Failed to load data: ' + e.message, 'err');
  });
}

function populateCouncilFilter() {
  var sel = document.getElementById('f-council');
  var cur = sel.value;
  sel.innerHTML = '<option value="">All Councils</option>';
  Object.entries(allCouncils).forEach(function(kv) {
    var opt = document.createElement('option');
    opt.value = kv[0];
    opt.textContent = kv[1].name || kv[0];
    if (kv[0] === cur) opt.selected = true;
    sel.appendChild(opt);
  });
}

// ── Approval Section ──────────────────────────────────────────────────────────
function renderApproval() {
  var filterCouncil = document.getElementById('f-council').value;
  var companies = Object.entries(allCompanies);
  var councils  = Object.entries(allCouncils).filter(function(kv) {
    return !filterCouncil || kv[0] === filterCouncil;
  });

  if (!companies.length) {
    document.getElementById('approval-tb').innerHTML = '<tr class="empty-row"><td colspan="6">No companies registered yet.</td></tr>';
    document.getElementById('approval-count').textContent = '';
    return;
  }
  if (!councils.length) {
    document.getElementById('approval-tb').innerHTML = '<tr class="empty-row"><td colspan="6">No councils configured yet — add one in TM Council Config first.</td></tr>';
    document.getElementById('approval-count').textContent = '';
    return;
  }

  var rows = [];
  companies.forEach(function(ckv) {
    var cid = ckv[0], co = ckv[1];
    councils.forEach(function(nkv) {
      var councilId = nkv[0], council = nkv[1];
      var acc = (allAccess[cid] && allAccess[cid][councilId]) || null;
      var approved = acc && acc.approved === true;
      var ts = approved
        ? (acc.approvedAt ? new Date(acc.approvedAt).toLocaleString('en-NZ',{day:'2-digit',month:'short',year:'numeric'}) : 'Yes')
        : (acc && acc.revokedAt ? 'Revoked ' + new Date(acc.revokedAt).toLocaleString('en-NZ',{day:'2-digit',month:'short',year:'numeric'}) : '—');
      var badge = approved
        ? '<span class="bx bx-g">&#10003; Approved</span>'
        : '<span class="bx bx-r">&#10005; Not Approved</span>';
      var cidE = escA(cid), councilE = escA(councilId);
      var btn = approved
        ? '<button class="tm-btn tm-btn-red" onclick="setAccess(\''+cidE+'\',\''+councilE+'\',false)">Revoke</button>'
        : '<button class="tm-btn tm-btn-green" onclick="setAccess(\''+cidE+'\',\''+councilE+'\',true)">Approve</button>';
      rows.push('<tr>' +
        '<td><strong>' + esc(co.name || cid) + '</strong></td>' +
        '<td><span class="cid-badge">' + esc(cid) + '</span></td>' +
        '<td>' + esc(council.name || councilId) + '</td>' +
        '<td>' + badge + '</td>' +
        '<td style="font-size:12px;color:#888">' + esc(ts) + '</td>' +
        '<td>' + btn + '</td>' +
        '</tr>');
    });
  });

  document.getElementById('approval-tb').innerHTML = rows.join('') || '<tr class="empty-row"><td colspan="6">No results.</td></tr>';
  document.getElementById('approval-count').textContent = '— ' + companies.length + ' company / ' + councils.length + ' council combination(s)';
}

function setAccess(cid, councilId, approve) {
  var co = allCompanies[cid] || {};
  var council = allCouncils[councilId] || {};
  var confirmed = confirm(
    (approve ? 'Approve ' : 'Revoke TM access for ') +
    (co.name || cid) + ' under ' + (council.name || councilId) + '?'
  );
  if (!confirmed) return;
  var now = Date.now();
  var patch = approve
    ? { approved: true, approvedAt: now, revokedAt: null }
    : { approved: false, revokedAt: now, approvedAt: null };
  adminWrite('tmCompanyAccess/' + cid + '/' + councilId, 'PUT', patch)
    .then(function() {
      if (!allAccess[cid]) allAccess[cid] = {};
      allAccess[cid][councilId] = patch;
      renderApproval();
      showNotice(
        (co.name || cid) + (approve ? ' approved for TM under ' : ' TM access revoked for ') + (council.name || councilId) + '.',
        approve ? 'ok' : 'warn'
      );
    })
    .catch(function(e) { showNotice('Error: ' + e.message, 'err'); });
}

// ── Tariff Section ────────────────────────────────────────────────────────────
function renderTariffs() {
  var companies = Object.entries(allCompanies);
  if (!companies.length) {
    document.getElementById('tariff-tb').innerHTML = '<tr class="empty-row"><td colspan="11">No companies registered yet.</td></tr>';
    return;
  }
  var rows = companies.map(function(ckv) {
    var cid = ckv[0], co = ckv[1];
    var t = allTariffs[cid] || {};
    var car = t.car || {};
    var van = t.van || {};
    var hasRates = !!(car.base || car.perKm || van.base || van.perKm);
    var fmt = function(v) { return v != null && v !== '' ? '$' + parseFloat(v).toFixed(2) : '<span style="color:#ccc">—</span>'; };
    var updated = t.updatedAt ? new Date(t.updatedAt).toLocaleString('en-NZ',{day:'2-digit',month:'short',year:'numeric'}) : '<span style="color:#ccc">Not set</span>';
    var cidE = escA(cid);
    return '<tr>' +
      '<td><strong>' + esc(co.name || cid) + '</strong><br><span class="cid-badge">' + esc(cid) + '</span></td>' +
      '<td>' + fmt(car.base) + '</td>' +
      '<td>' + fmt(car.perKm) + '</td>' +
      '<td>' + fmt(car.perMin) + '</td>' +
      '<td>' + fmt(car.stopFee) + '</td>' +
      '<td>' + fmt(van.base) + '</td>' +
      '<td>' + fmt(van.perKm) + '</td>' +
      '<td>' + fmt(van.perMin) + '</td>' +
      '<td>' + fmt(van.stopFee) + '</td>' +
      '<td style="font-size:12px;color:#888">' + updated + '</td>' +
      '<td><button class="tm-btn tm-btn-blue" onclick="openTariffModal(\'' + cidE + '\')">' + (hasRates ? '&#9998; Edit' : '+ Set Rates') + '</button></td>' +
      '</tr>';
  }).join('');
  document.getElementById('tariff-tb').innerHTML = rows;
}

function openTariffModal(cid) {
  _tariffCid = cid;
  var co  = allCompanies[cid] || {};
  var t   = allTariffs[cid]   || {};
  var car = t.car || {};
  var van = t.van || {};
  document.getElementById('tariff-modal-sub').textContent = (co.name || cid) + '  (ID: ' + cid + ')';
  document.getElementById('t-car-base').value  = car.base    != null ? car.base    : '';
  document.getElementById('t-car-km').value    = car.perKm   != null ? car.perKm   : '';
  document.getElementById('t-car-min').value   = car.perMin  != null ? car.perMin  : '';
  document.getElementById('t-car-stop').value  = car.stopFee != null ? car.stopFee : '';
  document.getElementById('t-van-base').value  = van.base    != null ? van.base    : '';
  document.getElementById('t-van-km').value    = van.perKm   != null ? van.perKm   : '';
  document.getElementById('t-van-min').value   = van.perMin  != null ? van.perMin  : '';
  document.getElementById('t-van-stop').value  = van.stopFee != null ? van.stopFee : '';
  document.getElementById('tariff-modal-msg').textContent = '';
  document.getElementById('tariff-save-btn').disabled = false;
  document.getElementById('tariff-modal').classList.add('open');
}
function closeTariffModal() {
  document.getElementById('tariff-modal').classList.remove('open');
  _tariffCid = null;
}
function saveTariff() {
  if (!_tariffCid) return;
  var btn = document.getElementById('tariff-save-btn');
  btn.disabled = true;
  var data = {
    car: {
      base:    parseFloat(document.getElementById('t-car-base').value)  || 0,
      perKm:   parseFloat(document.getElementById('t-car-km').value)    || 0,
      perMin:  parseFloat(document.getElementById('t-car-min').value)   || 0,
      stopFee: parseFloat(document.getElementById('t-car-stop').value)  || 0
    },
    van: {
      base:    parseFloat(document.getElementById('t-van-base').value)  || 0,
      perKm:   parseFloat(document.getElementById('t-van-km').value)    || 0,
      perMin:  parseFloat(document.getElementById('t-van-min').value)   || 0,
      stopFee: parseFloat(document.getElementById('t-van-stop').value)  || 0
    },
    updatedAt: Date.now()
  };
  adminWrite('tmTariffs/' + _tariffCid, 'PUT', data)
    .then(function() {
      allTariffs[_tariffCid] = data;
      renderTariffs();
      closeTariffModal();
      showNotice('Tariffs saved for ' + esc((allCompanies[_tariffCid] || {}).name || _tariffCid) + '. Passenger app will pick these up immediately.', 'ok');
    })
    .catch(function(e) {
      document.getElementById('tariff-modal-msg').textContent = 'Save failed: ' + e.message;
      document.getElementById('tariff-modal-msg').className = 'modal-msg err';
      btn.disabled = false;
    });
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function showNotice(msg, type) {
  var el = document.getElementById('pg-notice');
  el.className = 'notice ' + (type || 'ok');
  el.textContent = msg;
  el.style.display = 'block';
  clearTimeout(el._t);
  el._t = setTimeout(function() { el.style.display = 'none'; }, 6000);
}
function esc(s)  { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function escA(s) { return String(s||'').replace(/'/g,"\\'"); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
