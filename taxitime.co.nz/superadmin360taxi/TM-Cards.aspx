<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Passenger Cards &mdash; BookaWaka Admin</title>
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
.tm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.tm-btn-p{background:#37474F;color:#fff}.tm-btn-p:hover{background:#263238}
.tm-btn-e{background:#E3F2FD;color:#1565C0}.tm-btn-d{background:#FFEBEE;color:#C62828}
.tm-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.tm-ov{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:999;align-items:center;justify-content:center}
.tm-ov.open{display:flex}
.tm-modal{background:#fff;border-radius:8px;width:680px;max-width:95vw;max-height:92vh;overflow-y:auto;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.tm-mh{background:#37474F;color:#fff;padding:14px 18px;display:flex;align-items:center;justify-content:space-between;border-radius:8px 8px 0 0}
.tm-mh h3{margin:0;font-size:15px}
.tm-mb{padding:18px}.tm-mf{padding:12px 18px;border-top:1px solid #eee;display:flex;gap:8px;justify-content:flex-end}
.tm-fg{display:grid;grid-template-columns:1fr 1fr;gap:12px 18px}
.tm-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.tm-ff input,.tm-ff select{width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.tm-ff input:focus,.tm-ff select:focus{outline:none;border-color:#37474F}
.tm-msg{margin-top:8px;font-size:13px}.tm-msg.ok{color:#2E7D32}.tm-msg.err{color:#C62828}
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt select,.filt input[type=text]{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main">
  <div class="header_main_content">
    <nav class="uk-navbar">
      <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
      <div class="col-md-offset-2 col-md-4">
        <label style="color:#fff">TM Passenger Cards — BookaWaka Admin</label>
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
      <li><a href="TM-Cards.aspx" style="font-weight:700;color:#1565C0">&#9658; Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
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
  <div class="tm-bar">
    <h3>TM Passenger Cards <small id="card-count" style="opacity:.75;font-size:12px"></small></h3>
    <div style="display:flex;gap:8px">
      <button class="tm-btn tm-btn-p" onclick="openCard()">+ Add Card</button>
      <button class="tm-btn tm-btn-wh" onclick="refreshCards()">&#8635;</button>
    </div>
  </div>
  <div class="filt">
    <select id="card-f-council" onchange="renderCards()"><option value="">All Councils</option></select>
    <select id="card-f-status" onchange="renderCards()"><option value="">All</option><option value="true">Active</option><option value="false">Inactive</option></select>
    <input type="text" id="card-f-search" placeholder="Search card # or name&#8230;" oninput="renderCards()" style="min-width:200px"/>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Card Number</th><th>Passenger Name</th><th>Council</th><th>Region</th>
        <th>Monthly Limit</th><th>Daily Limit</th><th>Notes</th><th>Status</th><th>Actions</th>
      </tr></thead>
      <tbody id="card-tb"><tr><td colspan="9" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
    </table>
  </div>
</div></div>

<div class="tm-ov" id="card-ov">
<div class="tm-modal">
  <div class="tm-mh"><h3 id="card-mtitle">Add TM Card</h3>
    <button onclick="closeCard()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
  <div class="tm-mb"><div class="tm-fg">
    <div class="tm-ff"><label>Card Number *</label><input id="cd-num" placeholder="e.g. 413196"/></div>
    <div class="tm-ff"><label>Passenger Name *</label><input id="cd-name" placeholder="Full name"/></div>
    <div class="tm-ff"><label>Council</label>
      <select id="cd-council"><option value="">&#8212; Select Council &#8212;</option></select></div>
    <div class="tm-ff"><label>Card Region</label><input id="cd-region" placeholder="Auto-filled from council"/></div>
    <div class="tm-ff"><label>Monthly Trip Limit</label><input id="cd-ml" type="number" min="0" placeholder="Leave blank = use council default"/></div>
    <div class="tm-ff"><label>Daily Trip Limit</label><input id="cd-dl" type="number" min="0" placeholder="Leave blank = use council default"/></div>
    <div class="tm-ff"><label>Status</label>
      <select id="cd-act"><option value="true">Active</option><option value="false">Inactive / Suspended</option></select></div>
    <div class="tm-ff" style="grid-column:1/-1"><label>Notes</label><input id="cd-notes" placeholder="Any notes about this card or passenger"/></div>
  </div>
  <div id="card-msg" class="tm-msg"></div></div>
  <div class="tm-mf">
    <button class="tm-btn" style="background:#eee;color:#333" onclick="closeCard()">Cancel</button>
    <button class="tm-btn tm-btn-p" onclick="saveCard()">Save Card</button>
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
var cardData = {}, councilData = {}, cardEid = null;
window._fbOnLogin = function() {
  adminListen('tmCards', function(d) { cardData = d || {}; renderCards(); });
  adminRead('tmConfig').then(function(d) { councilData = d || {}; populateCouncilDropdowns(); });
};
function populateCouncilDropdowns() {
  var opts = '<option value="">\u2014 Select Council \u2014</option>';
  Object.entries(councilData).forEach(function(kv) { opts += '<option value="' + kv[0] + '">' + ((kv[1].name) || kv[0]) + '</option>'; });
  document.getElementById('cd-council').innerHTML = opts;
  var fopts = '<option value="">All Councils</option>';
  Object.entries(councilData).forEach(function(kv) { fopts += '<option value="' + kv[0] + '">' + ((kv[1].name) || kv[0]) + '</option>'; });
  document.getElementById('card-f-council').innerHTML = fopts;
}
function refreshCards() {
  document.getElementById('card-tb').innerHTML = '<tr><td colspan="9" style="text-align:center;padding:30px;color:#9e9e9e">Refreshing\u2026</td></tr>';
  adminRead('tmCards').then(function(d) { cardData = d || {}; renderCards(); });
}
function renderCards() {
  var fCouncil = document.getElementById('card-f-council').value;
  var fStatus = document.getElementById('card-f-status').value;
  var fSearch = (document.getElementById('card-f-search').value || '').toLowerCase();
  var entries = Object.entries(cardData).filter(function(kv) {
    var c = kv[1];
    if (fCouncil && c.councilId !== fCouncil) return false;
    if (fStatus !== '' && String(c.active !== false) !== fStatus) return false;
    if (fSearch && !(kv[0].toLowerCase().includes(fSearch) || (c.passengerName || '').toLowerCase().includes(fSearch))) return false;
    return true;
  });
  document.getElementById('card-count').textContent = Object.keys(cardData).length + ' card(s)';
  if (!entries.length) { document.getElementById('card-tb').innerHTML = '<tr><td colspan="9" style="text-align:center;padding:40px;color:#9e9e9e">No cards found.</td></tr>'; return; }
  var cnames = {};
  Object.entries(councilData).forEach(function(kv) { cnames[kv[0]] = (kv[1].name) || kv[0]; });
  document.getElementById('card-tb').innerHTML = entries.map(function(kv) {
    var id = kv[0], c = kv[1], sid = JSON.stringify(id);
    return '<tr>' +
      '<td style="font-family:monospace;font-weight:600">' + id + '</td>' +
      '<td>' + (c.passengerName || '\u2014') + '</td>' +
      '<td>' + (cnames[c.councilId] || c.councilId || '\u2014') + '</td>' +
      '<td>' + (c.cardRegion || '\u2014') + '</td>' +
      '<td>' + (c.usageLimitMonthly || '\u2014') + '</td>' +
      '<td>' + (c.usageLimitDaily || '\u2014') + '</td>' +
      '<td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">' + (c.notes || '\u2014') + '</td>' +
      '<td>' + (c.active !== false ? '<span class="bx bx-g">Active</span>' : '<span class="bx bx-r">Inactive</span>') + '</td>' +
      '<td style="white-space:nowrap">' +
        '<button class="tm-btn tm-btn-e" onclick="editCard(' + sid + ')" style="margin-right:4px">Edit</button>' +
        '<button class="tm-btn tm-btn-d" onclick="delCard(' + sid + ')">Delete</button>' +
      '</td></tr>';
  }).join('');
}
function openCard() {
  cardEid = null; document.getElementById('card-mtitle').textContent = 'Add TM Card';
  ['cd-num','cd-name','cd-region','cd-ml','cd-dl','cd-notes'].forEach(function(x) { document.getElementById(x).value = ''; });
  document.getElementById('cd-council').value = ''; document.getElementById('cd-act').value = 'true';
  document.getElementById('cd-num').removeAttribute('readonly');
  document.getElementById('card-msg').textContent = ''; document.getElementById('card-ov').classList.add('open');
}
function closeCard() { document.getElementById('card-ov').classList.remove('open'); }
function editCard(id) {
  cardEid = id; var c = cardData[id] || {};
  document.getElementById('card-mtitle').textContent = 'Edit TM Card';
  document.getElementById('cd-num').value = id; document.getElementById('cd-num').setAttribute('readonly', 'readonly');
  document.getElementById('cd-name').value = c.passengerName || '';
  document.getElementById('cd-council').value = c.councilId || '';
  document.getElementById('cd-region').value = c.cardRegion || '';
  document.getElementById('cd-ml').value = c.usageLimitMonthly || '';
  document.getElementById('cd-dl').value = c.usageLimitDaily || '';
  document.getElementById('cd-act').value = c.active === false ? 'false' : 'true';
  document.getElementById('cd-notes').value = c.notes || '';
  document.getElementById('card-msg').textContent = ''; document.getElementById('card-ov').classList.add('open');
}
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('cd-council').addEventListener('change', function() {
    var cid = this.value, cn = councilData[cid] || {};
    if (cid && cn.region) document.getElementById('cd-region').value = cn.region;
  });
});
function saveCard() {
  var num = (document.getElementById('cd-num').value || '').trim().replace(/\s+/g, '');
  var nm = document.getElementById('cd-name').value.trim();
  if (!num) { cardMsg('Card number required.', false); return; }
  if (!nm) { cardMsg('Passenger name required.', false); return; }
  var cid = document.getElementById('cd-council').value;
  var cn = councilData[cid] || {};
  var data = {
    passengerName: nm, councilId: cid,
    cardRegion: document.getElementById('cd-region').value.trim() || (cn.region || ''),
    usageLimitMonthly: parseInt(document.getElementById('cd-ml').value) || null,
    usageLimitDaily: parseInt(document.getElementById('cd-dl').value) || null,
    active: document.getElementById('cd-act').value === 'true',
    notes: document.getElementById('cd-notes').value.trim(), updatedAt: Date.now()
  };
  adminWrite('tmCards/' + num, 'PUT', data).then(function() {
    cardData[num] = data; renderCards(); closeCard();
  }).catch(function(e) { cardMsg('Save failed: ' + e.message, false); });
}
function delCard(id) {
  if (!confirm('Delete card ' + id + ' (' + ((cardData[id] || {}).passengerName || '') + ')?')) return;
  adminWrite('tmCards/' + id, 'DELETE', null).then(function() { delete cardData[id]; renderCards(); })
    .catch(function(e) { alert('Delete failed: ' + e.message); });
}
function cardMsg(m, ok) { var el = document.getElementById('card-msg'); el.textContent = m; el.className = 'tm-msg ' + (ok ? 'ok' : 'err'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
