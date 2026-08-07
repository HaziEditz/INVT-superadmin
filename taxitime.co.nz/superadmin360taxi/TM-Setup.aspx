<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Setup Hub &mdash; BookaWaka Admin</title>
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
.bx-a{background:#FFF8E1;color:#E65100;border:1px solid #FFE082}
.notice{padding:11px 16px;border-radius:6px;font-size:13px;margin-bottom:16px}
.notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.cid-badge{font-family:monospace;background:#ECEFF1;color:#37474F;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700}
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt select{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.empty-row td{text-align:center;padding:36px;color:#aaa;font-style:italic}
.hub-snap{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px}
@media(max-width:960px){.hub-snap{grid-template-columns:1fr 1fr}}
@media(max-width:560px){.hub-snap{grid-template-columns:1fr}}
.snap-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);padding:16px 18px;border-top:3px solid #37474F}
.snap-card .snap-label{font-size:12px;color:#757575;font-weight:600;margin-bottom:6px}
.snap-card .snap-val{font-size:26px;font-weight:700;color:#263238;line-height:1.1}
.snap-card .snap-note{font-size:12px;color:#888;margin-top:8px;line-height:1.35}
.snap-card.snap-note-card{border-top-color:#1565C0}
.step-num{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;background:rgba(255,255,255,.2);font-size:12px;font-weight:700;margin-right:6px}
.quick-add{display:none;padding:16px 18px;background:#FAFAFA;border-bottom:1px solid #f0f0f0}
.quick-add.open{display:block}
.qa-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;align-items:end}
@media(max-width:900px){.qa-grid{grid-template-columns:1fr 1fr}}
.qa-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.qa-ff input{width:100%;padding:7px 9px;border:1.5px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.qa-ff input:focus{outline:none;border-color:#37474F}
.hub-footer{padding:16px 18px;font-size:13px;color:#666;line-height:1.6;background:#fafafa;border-top:1px solid #eee}
.hub-footer a{color:#1565C0;font-weight:600;text-decoration:none}
.hub-footer a:hover{text-decoration:underline}
.step-hint{padding:10px 18px;font-size:12px;color:#666;background:#F5F7FA;border-bottom:1px solid #f0f0f0}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">TM Setup Hub &mdash; BookaWaka Admin</label></div>
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
      <li><a href="TM-Setup.aspx" style="font-weight:700;color:#1565C0">&#9658; TM Setup Hub</a></li>
      <li><a href="TM-Council-Config.aspx">Council Config (Advanced)</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
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

<div id="page_content"><div id="page_content_inner">
<div class="tm-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:4px;color:#37474F">TM Setup Hub</h2>
<p style="font-size:13px;color:#888;margin-bottom:20px">Day-to-day Total Mobility onboarding: create councils, approve companies, and confirm driver-split sync. Use advanced pages only when you need full edit forms or legacy tools.</p>

<div id="pg-notice" style="display:none" class="notice"></div>

<!-- Dashboard snapshot -->
<div class="hub-snap" id="hub-snap">
  <div class="snap-card">
    <div class="snap-label">Active Councils</div>
    <div class="snap-val" id="snap-councils">—</div>
    <div class="snap-note" id="snap-councils-note">From tmConfig</div>
  </div>
  <div class="snap-card">
    <div class="snap-label">Approved company-links</div>
    <div class="snap-val" id="snap-approved">—</div>
    <div class="snap-note">Sum of approved tmCompanyAccess rows</div>
  </div>
  <div class="snap-card">
    <div class="snap-label">Companies with synced tmConfig</div>
    <div class="snap-val" id="snap-synced">—</div>
    <div class="snap-note">sourceCouncilId present</div>
  </div>
  <div class="snap-card snap-note-card">
    <div class="snap-label">Recent activity</div>
    <div class="snap-val" style="font-size:15px;font-weight:600;margin-top:4px" id="snap-activity">—</div>
    <div class="snap-note" id="snap-activity-note">Click Refresh after changes</div>
  </div>
</div>

<!-- Step 1: Councils -->
<div class="tm-card">
  <div class="tm-bar">
    <h3><span class="step-num">1</span> Create / manage councils <small id="step1-count" style="opacity:.75;font-size:12px"></small></h3>
    <div style="display:flex;gap:8px;flex-wrap:wrap">
      <a class="tm-btn tm-btn-wh" href="TM-Council-Config.aspx?new=1">+ Add Council</a>
      <button class="tm-btn tm-btn-wh" type="button" onclick="toggleQuickAdd()">Quick add</button>
      <button class="tm-btn tm-btn-wh" type="button" onclick="loadHub()">&#8635; Refresh</button>
    </div>
  </div>
  <div class="step-hint">Council economics (subsidy %, cap, hoist) live in <code>tmConfig</code>. Full portal password / limits: <a href="TM-Council-Config.aspx">Council Config (Advanced)</a>.</div>
  <div class="quick-add" id="quick-add">
    <div class="qa-grid">
      <div class="qa-ff"><label>Council Name *</label><input id="qa-name" placeholder="e.g. Invercargill City Council"/></div>
      <div class="qa-ff"><label>Region</label><input id="qa-region" placeholder="e.g. Invercargill"/></div>
      <div class="qa-ff"><label>Subsidy % *</label><input id="qa-pct" type="number" min="1" max="100" step="1" placeholder="75"/></div>
      <div class="qa-ff"><label>Cap ($) *</label><input id="qa-cap" type="number" min="0.01" max="500" step="0.01" placeholder="37.50"/></div>
      <div class="qa-ff"><label>Hoist / use ($)</label><input id="qa-hoist" type="number" min="0" max="200" step="0.01" placeholder="10.00"/></div>
    </div>
    <div style="margin-top:12px;display:flex;gap:8px;align-items:center;flex-wrap:wrap">
      <button class="tm-btn tm-btn-green" type="button" id="qa-save-btn" onclick="quickAddCouncil()">Save council</button>
      <button class="tm-btn tm-btn-n" type="button" onclick="toggleQuickAdd(false)">Cancel</button>
      <span id="qa-msg" style="font-size:12px;color:#666"></span>
    </div>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Council</th>
        <th>Region</th>
        <th>Subsidy %</th>
        <th>Cap ($)</th>
        <th>Hoist</th>
        <th>Status</th>
        <th>Actions</th>
      </tr></thead>
      <tbody id="step1-tb">
        <tr class="empty-row"><td colspan="7">Loading&#8230;</td></tr>
      </tbody>
    </table>
  </div>
</div>

<!-- Step 2: Approve companies -->
<div class="tm-card">
  <div class="tm-bar">
    <h3><span class="step-num">2</span> Approve companies <small id="step2-count" style="opacity:.75;font-size:12px"></small></h3>
  </div>
  <div class="step-hint">Select a council, then Approve / Revoke companies. Approve writes <code>tmCompanyAccess</code> and syncs council rates to <code>companySettings/{cid}/tmConfig</code>.</div>
  <div class="filt">
    <label style="font-size:13px;color:#666;font-weight:500">Council:</label>
    <select id="hub-council" onchange="onCouncilChange()"><option value="">Select a council&#8230;</option></select>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Company</th>
        <th>ID</th>
        <th>TM Access</th>
        <th>Config provenance</th>
        <th>Approved / Revoked</th>
        <th>Action</th>
      </tr></thead>
      <tbody id="step2-tb">
        <tr class="empty-row"><td colspan="6">Select a council to list companies.</td></tr>
      </tbody>
    </table>
  </div>
</div>

<!-- Step 3: Confirm sync -->
<div class="tm-card">
  <div class="tm-bar">
    <h3><span class="step-num">3</span> Confirm sync <small id="step3-count" style="opacity:.75;font-size:12px"></small></h3>
  </div>
  <div class="step-hint">Approved companies for the selected council — Synced / Manual / Not set from company tmConfig.</div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Company</th>
        <th>ID</th>
        <th>Sync status</th>
        <th>Detail</th>
        <th>Action</th>
      </tr></thead>
      <tbody id="step3-tb">
        <tr class="empty-row"><td colspan="5">Select a council in Step 2.</td></tr>
      </tbody>
    </table>
  </div>
  <div class="hub-footer">
    <strong>Advanced:</strong>
    <a href="TM-Council-Config.aspx">Council Config</a>
    &nbsp;·&nbsp;
    <a href="TM-Settings.aspx">TM Settings</a>
    &nbsp;·&nbsp;
    Manual company fallback: open a company in
    <a href="SA-Clients.aspx">SA-Clients</a>
    /
    <a href="SA-Company.aspx">SA-Company</a>
  </div>
</div>

</div></div></div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/modernizr/2.8.3/modernizr.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/fastclick/1.0.6/fastclick.min.js"></script>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/uikit_custom.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script src="assets/js/tm-provenance.js"></script>
<script>
var allCompanies = {};
var allCouncils  = {};
var allAccess    = {};
var companyTmConfigs = {}; // cid -> tmConfig object
var hubLoadedAt = null;

window._fbOnLogin = function() { loadHub(); };

function asObjectMap(raw) {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return {};
  return raw;
}

function normalizeCouncilMap(raw) {
  var out = {};
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return out;
  Object.keys(raw).forEach(function(k) {
    var v = raw[k];
    if (v && typeof v === 'object' && !Array.isArray(v)) out[k] = v;
  });
  return out;
}

/** Merge portal-access rows that have no tmConfig yet (same pattern as Council Config). */
function mergeAccessOrphans(configMap, accessMap) {
  var out = Object.assign({}, configMap || {});
  Object.keys(accessMap || {}).forEach(function(id) {
    if (out[id]) return;
    var acc = accessMap[id] || {};
    out[id] = {
      name: acc.name || id.replace(/^cncl_/, '').replace(/_/g, ' '),
      approverEmail: acc.email || '',
      active: acc.active !== false,
      capAmount: 0,
      subsidyPercent: 0,
      hoistRatePerUse: 0,
      _orphanAccess: true,
      notes: 'Restored from portal access — re-save to set subsidy/cap/hoist.'
    };
  });
  return out;
}

function loadHub() {
  var tb1 = document.getElementById('step1-tb');
  var tb2 = document.getElementById('step2-tb');
  var tb3 = document.getElementById('step3-tb');
  if (tb1) tb1.innerHTML = '<tr class="empty-row"><td colspan="7">Loading&#8230;</td></tr>';
  if (tb2) tb2.innerHTML = '<tr class="empty-row"><td colspan="6">Loading&#8230;</td></tr>';
  if (tb3) tb3.innerHTML = '<tr class="empty-row"><td colspan="5">Loading&#8230;</td></tr>';
  document.getElementById('snap-councils').textContent = '…';
  document.getElementById('snap-approved').textContent = '…';
  document.getElementById('snap-synced').textContent = '…';

  Promise.all([
    adminRead('superClients'),
    adminRead('tmConfig'),
    adminRead('tmCompanyAccess'),
    adminRead('tmCouncilAccess').catch(function() { return {}; })
  ]).then(function(res) {
    allCompanies = asObjectMap(res[0]);
    allAccess    = asObjectMap(res[2]);
    var accessMap = asObjectMap(res[3]);
    allCouncils  = mergeAccessOrphans(normalizeCouncilMap(res[1]), accessMap);
    hubLoadedAt  = Date.now();
    return loadCompanyTmConfigs();
  }).then(function() {
    renderSnapshot();
    renderStep1();
    populateCouncilSelect();
    renderStep2();
    renderStep3();
  }).catch(function(e) {
    var msg = (e && e.message) ? e.message : String(e);
    showNotice('Failed to load hub: ' + msg, 'err');
    if (tb1) {
      tb1.innerHTML = '<tr class="empty-row"><td colspan="7" style="color:#C62828">Failed to load: ' +
        esc(msg) + '</td></tr>';
    }
  });
}

/** Load companySettings/{cid}/tmConfig for all companies (for provenance badges). */
function loadCompanyTmConfigs() {
  var cids = Object.keys(allCompanies).filter(function(cid) {
    return allCompanies[cid] && typeof allCompanies[cid] === 'object';
  });
  if (!cids.length) {
    companyTmConfigs = {};
    return Promise.resolve();
  }
  return Promise.all(cids.map(function(cid) {
    return adminRead('companySettings/' + cid + '/tmConfig').then(function(cfg) {
      return { cid: cid, cfg: cfg };
    }).catch(function() {
      return { cid: cid, cfg: null };
    });
  })).then(function(rows) {
    companyTmConfigs = {};
    rows.forEach(function(r) {
      companyTmConfigs[r.cid] = (r.cfg && typeof r.cfg === 'object') ? r.cfg : null;
    });
  });
}

function renderSnapshot() {
  var councils = Object.entries(allCouncils).filter(function(kv) {
    return kv[1] && typeof kv[1] === 'object';
  });
  var activeCouncils = councils.filter(function(kv) { return kv[1].active !== false && !kv[1]._orphanAccess; });
  var approvedLinks = 0;
  Object.keys(allAccess).forEach(function(cid) {
    var row = allAccess[cid];
    if (!row || typeof row !== 'object') return;
    Object.keys(row).forEach(function(councilId) {
      if (row[councilId] && row[councilId].approved === true) approvedLinks++;
    });
  });
  var syncedCompanies = 0;
  Object.keys(companyTmConfigs).forEach(function(cid) {
    var cfg = companyTmConfigs[cid];
    if (cfg && String(cfg.sourceCouncilId || '').trim()) syncedCompanies++;
  });

  document.getElementById('snap-councils').textContent = String(activeCouncils.length);
  document.getElementById('snap-councils-note').textContent =
    councils.length === activeCouncils.length
      ? (councils.length + ' total in tmConfig')
      : (activeCouncils.length + ' active · ' + councils.length + ' total');
  document.getElementById('snap-approved').textContent = String(approvedLinks);
  document.getElementById('snap-synced').textContent = String(syncedCompanies);

  var latest = 0;
  councils.forEach(function(kv) {
    var t = kv[1].updatedAt;
    if (typeof t === 'number' && t > latest) latest = t;
  });
  Object.keys(allAccess).forEach(function(cid) {
    var row = allAccess[cid];
    if (!row || typeof row !== 'object') return;
    Object.keys(row).forEach(function(councilId) {
      var a = row[councilId] || {};
      [a.approvedAt, a.revokedAt].forEach(function(t) {
        if (typeof t === 'number' && t > latest) latest = t;
      });
    });
  });
  Object.keys(companyTmConfigs).forEach(function(cid) {
    var cfg = companyTmConfigs[cid];
    if (!cfg) return;
    [cfg.syncedFromCouncilAt, cfg.updatedAt, cfg.manualOverrideAt].forEach(function(t) {
      if (typeof t === 'number' && t > latest) latest = t;
    });
  });

  if (latest > 0) {
    document.getElementById('snap-activity').textContent =
      new Date(latest).toLocaleString('en-NZ', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
    document.getElementById('snap-activity-note').textContent = 'Latest council / access / sync timestamp';
  } else {
    document.getElementById('snap-activity').textContent = hubLoadedAt
      ? ('Loaded ' + new Date(hubLoadedAt).toLocaleTimeString('en-NZ', { hour: '2-digit', minute: '2-digit' }))
      : 'No activity yet';
    document.getElementById('snap-activity-note').textContent = 'No approval or sync timestamps found';
  }
}

function populateCouncilSelect() {
  var sel = document.getElementById('hub-council');
  if (!sel) return;
  var cur = sel.value;
  sel.innerHTML = '<option value="">Select a council&#8230;</option>';
  Object.entries(allCouncils).forEach(function(kv) {
    var id = kv[0], c = kv[1];
    if (!c || typeof c !== 'object') return;
    var opt = document.createElement('option');
    opt.value = id;
    opt.textContent = (c.name || id) + (c.active === false ? ' (inactive)' : '') + (c._orphanAccess ? ' (access only)' : '');
    if (id === cur) opt.selected = true;
    sel.appendChild(opt);
  });
}

function onCouncilChange() {
  renderStep2();
  renderStep3();
}

// ── Step 1 ────────────────────────────────────────────────────────────────────
function renderStep1() {
  var rows = Object.entries(allCouncils).filter(function(kv) {
    return kv[1] && typeof kv[1] === 'object';
  });
  document.getElementById('step1-count').textContent = rows.length ? ('— ' + rows.length) : '';
  if (!rows.length) {
    document.getElementById('step1-tb').innerHTML =
      '<tr class="empty-row"><td colspan="7">No councils yet. Use <strong>+ Add Council</strong> or Quick add.</td></tr>';
    return;
  }
  document.getElementById('step1-tb').innerHTML = rows.map(function(kv) {
    var id = kv[0], c = kv[1];
    var status = c._orphanAccess
      ? '<span class="bx bx-a">Access only</span>'
      : (c.active === false
        ? '<span class="bx bx-gr">Inactive</span>'
        : '<span class="bx bx-g">Active</span>');
    var hoist = c.hoistRatePerUse != null && c.hoistRatePerUse !== ''
      ? ('$' + Number(c.hoistRatePerUse).toFixed(2))
      : '—';
    return '<tr>' +
      '<td><strong>' + esc(c.name || id) + '</strong><br><span class="cid-badge">' + esc(id) + '</span></td>' +
      '<td>' + esc(c.region || '—') + '</td>' +
      '<td>' + (c.subsidyPercent != null ? esc(c.subsidyPercent) + '%' : '—') + '</td>' +
      '<td>' + (c.capAmount != null && c.capAmount !== '' ? ('$' + Number(c.capAmount).toFixed(2)) : '—') + '</td>' +
      '<td>' + hoist + '</td>' +
      '<td>' + status + '</td>' +
      '<td><a class="tm-btn tm-btn-blue" href="TM-Council-Config.aspx?edit=' + encodeURIComponent(id) + '">Edit</a></td>' +
      '</tr>';
  }).join('');
}

function toggleQuickAdd(force) {
  var el = document.getElementById('quick-add');
  var open = typeof force === 'boolean' ? force : !el.classList.contains('open');
  if (open) el.classList.add('open');
  else el.classList.remove('open');
  if (!open) {
    document.getElementById('qa-msg').textContent = '';
  }
}

function quickAddCouncil() {
  var nm = document.getElementById('qa-name').value.trim();
  var region = document.getElementById('qa-region').value.trim();
  var pct = parseFloat(document.getElementById('qa-pct').value);
  var cap = parseFloat(document.getElementById('qa-cap').value);
  var hoist = parseFloat(document.getElementById('qa-hoist').value);
  var msg = document.getElementById('qa-msg');
  var btn = document.getElementById('qa-save-btn');

  if (!nm) { msg.textContent = 'Council name is required.'; msg.style.color = '#C62828'; return; }
  if (isNaN(pct) || pct < 1 || pct > 100) { msg.textContent = 'Subsidy % must be 1–100.'; msg.style.color = '#C62828'; return; }
  if (isNaN(cap) || cap <= 0 || cap > 500) { msg.textContent = 'Cap must be between $0.01 and $500.'; msg.style.color = '#C62828'; return; }
  if (document.getElementById('qa-hoist').value !== '' && (isNaN(hoist) || hoist < 0 || hoist > 200)) {
    msg.textContent = 'Hoist fee must be $0–$200.'; msg.style.color = '#C62828'; return;
  }

  var key = 'cncl_' + nm.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
  if (!key || key === 'cncl_' || key.indexOf('/') >= 0) {
    msg.textContent = 'Invalid council id from name.'; msg.style.color = '#C62828'; return;
  }
  if (allCouncils[key] && !allCouncils[key]._orphanAccess) {
    if (!confirm('Council key "' + key + '" already exists. Overwrite subsidy/cap/hoist?')) return;
  }

  var data = {
    name: nm,
    region: region,
    approverEmail: (allCouncils[key] && allCouncils[key].approverEmail) || '',
    capAmount: cap,
    subsidyPercent: pct,
    hoistRatePerUse: isNaN(hoist) ? 0 : hoist,
    hoistCoveredByCouncil: true,
    maxHoistsPerTrip: (allCouncils[key] && allCouncils[key].maxHoistsPerTrip) || null,
    monthlyLimitPerPassenger: (allCouncils[key] && allCouncils[key].monthlyLimitPerPassenger) || null,
    dailyLimitPerPassenger: (allCouncils[key] && allCouncils[key].dailyLimitPerPassenger) || null,
    active: true,
    notes: (allCouncils[key] && allCouncils[key].notes) || '',
    updatedAt: Date.now()
  };

  btn.disabled = true;
  msg.textContent = 'Saving…'; msg.style.color = '#666';
  adminWrite('tmConfig/' + key, 'PUT', data)
    .then(function() {
      allCouncils[key] = data;
      msg.textContent = 'Saved ' + nm + '.'; msg.style.color = '#2E7D32';
      document.getElementById('qa-name').value = '';
      document.getElementById('qa-region').value = '';
      document.getElementById('qa-pct').value = '';
      document.getElementById('qa-cap').value = '';
      document.getElementById('qa-hoist').value = '';
      renderSnapshot();
      renderStep1();
      populateCouncilSelect();
      var sel = document.getElementById('hub-council');
      if (sel && !sel.value) {
        sel.value = key;
        onCouncilChange();
      }
      showNotice('Council "' + nm + '" saved to tmConfig/' + key + '.', 'ok');
      if (typeof syncCouncilTmConfigToApprovedCompanies === 'function') {
        return syncCouncilTmConfigToApprovedCompanies(key, data).catch(function() { return 0; });
      }
    })
    .catch(function(e) {
      msg.textContent = 'Save failed: ' + (e && e.message ? e.message : e);
      msg.style.color = '#C62828';
    })
    .then(function() { btn.disabled = false; });
}

// ── Step 2 ────────────────────────────────────────────────────────────────────
function provenanceHtmlFor(cid) {
  var P = window.BWTmProvenance;
  if (!P || typeof P.classifyTmConfig !== 'function') {
    var cfg = companyTmConfigs[cid];
    if (!cfg) return '<span class="bx bx-gr">Not set</span>';
    if (cfg.sourceCouncilId) return '<span class="bx bx-g">Synced</span>';
    return '<span class="bx bx-a">Manual</span>';
  }
  var p = P.classifyTmConfig(companyTmConfigs[cid]);
  return P.provenanceBadgeHtml(p);
}

function renderStep2() {
  var councilId = document.getElementById('hub-council') ? document.getElementById('hub-council').value : '';
  var companies = Object.entries(allCompanies).filter(function(kv) {
    return kv[1] && typeof kv[1] === 'object';
  });

  if (!councilId) {
    document.getElementById('step2-tb').innerHTML =
      '<tr class="empty-row"><td colspan="6">Select a council to list companies.</td></tr>';
    document.getElementById('step2-count').textContent = '';
    return;
  }
  if (!companies.length) {
    document.getElementById('step2-tb').innerHTML =
      '<tr class="empty-row"><td colspan="6">No companies registered yet.</td></tr>';
    document.getElementById('step2-count').textContent = '';
    return;
  }

  var council = allCouncils[councilId] || {};
  var approvedN = 0;
  var rows = companies.map(function(ckv) {
    var cid = ckv[0], co = ckv[1];
    var acc = (allAccess[cid] && allAccess[cid][councilId]) || null;
    var approved = acc && acc.approved === true;
    if (approved) approvedN++;
    var ts = approved
      ? (acc.approvedAt ? new Date(acc.approvedAt).toLocaleString('en-NZ', { day: '2-digit', month: 'short', year: 'numeric' }) : 'Yes')
      : (acc && acc.revokedAt ? 'Revoked ' + new Date(acc.revokedAt).toLocaleString('en-NZ', { day: '2-digit', month: 'short', year: 'numeric' }) : '—');
    var badge = approved
      ? '<span class="bx bx-g">&#10003; Approved</span>'
      : '<span class="bx bx-r">&#10005; Not Approved</span>';
    var cidE = escA(cid), councilE = escA(councilId);
    var btn = approved
      ? '<button class="tm-btn tm-btn-red" type="button" onclick="setAccess(\'' + cidE + '\',\'' + councilE + '\',false)">Revoke</button>'
      : '<button class="tm-btn tm-btn-green" type="button" onclick="setAccess(\'' + cidE + '\',\'' + councilE + '\',true)">Approve</button>';
    return '<tr>' +
      '<td><strong>' + esc(co.name || cid) + '</strong></td>' +
      '<td><span class="cid-badge">' + esc(cid) + '</span></td>' +
      '<td>' + badge + '</td>' +
      '<td>' + provenanceHtmlFor(cid) + '</td>' +
      '<td style="font-size:12px;color:#888">' + esc(ts) + '</td>' +
      '<td>' + btn + '</td>' +
      '</tr>';
  }).join('');

  document.getElementById('step2-tb').innerHTML = rows;
  document.getElementById('step2-count').textContent =
    '— ' + approvedN + ' approved / ' + companies.length + ' under ' + (council.name || councilId);
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
      var finish = function(extra) {
        renderSnapshot();
        renderStep2();
        renderStep3();
        showNotice(
          (co.name || cid) + (approve ? ' approved for TM under ' : ' TM access revoked for ') +
          (council.name || councilId) + '.' + (extra || ''),
          approve ? 'ok' : 'warn'
        );
      };
      if (approve && typeof syncCouncilTmConfigToCompany === 'function') {
        return syncCouncilTmConfigToCompany(cid, councilId)
          .then(function() {
            return adminRead('companySettings/' + cid + '/tmConfig').then(function(cfg) {
              companyTmConfigs[cid] = (cfg && typeof cfg === 'object') ? cfg : companyTmConfigs[cid];
              finish(' Driver-split subsidy rates synced from council.');
            }).catch(function() {
              finish(' Driver-split subsidy rates synced from council.');
            });
          })
          .catch(function(e) {
            finish(' (driver-split sync failed: ' + (e && e.message) + ')');
          });
      }
      finish();
    })
    .catch(function(e) { showNotice('Error: ' + e.message, 'err'); });
}

// ── Step 3 ────────────────────────────────────────────────────────────────────
function renderStep3() {
  var councilId = document.getElementById('hub-council') ? document.getElementById('hub-council').value : '';
  if (!councilId) {
    document.getElementById('step3-tb').innerHTML =
      '<tr class="empty-row"><td colspan="5">Select a council in Step 2.</td></tr>';
    document.getElementById('step3-count').textContent = '';
    return;
  }

  var approved = [];
  Object.keys(allCompanies).forEach(function(cid) {
    var co = allCompanies[cid];
    if (!co || typeof co !== 'object') return;
    var acc = allAccess[cid] && allAccess[cid][councilId];
    if (acc && acc.approved === true) approved.push({ cid: cid, co: co });
  });

  document.getElementById('step3-count').textContent = approved.length ? ('— ' + approved.length) : '';
  if (!approved.length) {
    document.getElementById('step3-tb').innerHTML =
      '<tr class="empty-row"><td colspan="5">No approved companies for this council yet.</td></tr>';
    return;
  }

  document.getElementById('step3-tb').innerHTML = approved.map(function(row) {
    var cid = row.cid, co = row.co;
    var P = window.BWTmProvenance;
    var p = P && typeof P.classifyTmConfig === 'function'
      ? P.classifyTmConfig(companyTmConfigs[cid])
      : { kind: 'unknown', label: 'Not set', detail: '' };
    var badge = P && typeof P.provenanceBadgeHtml === 'function'
      ? P.provenanceBadgeHtml(p)
      : ('<span class="bx bx-gr">' + esc(p.label) + '</span>');
    var resync = '<button class="tm-btn tm-btn-blue" type="button" onclick="resyncCompany(\'' +
      escA(cid) + '\',\'' + escA(councilId) + '\')">Re-sync</button>';
    var companyLink = '<a class="tm-btn tm-btn-n" href="SA-Company.aspx?cid=' + encodeURIComponent(cid) + '">SA-Company</a>';
    return '<tr>' +
      '<td><strong>' + esc(co.name || cid) + '</strong></td>' +
      '<td><span class="cid-badge">' + esc(cid) + '</span></td>' +
      '<td>' + badge + '</td>' +
      '<td style="font-size:12px;color:#888">' + esc(p.detail || '—') + '</td>' +
      '<td style="display:flex;gap:6px;flex-wrap:wrap">' + resync + companyLink + '</td>' +
      '</tr>';
  }).join('');
}

function resyncCompany(cid, councilId) {
  if (typeof syncCouncilTmConfigToCompany !== 'function') {
    showNotice('syncCouncilTmConfigToCompany not available.', 'err');
    return;
  }
  var co = allCompanies[cid] || {};
  syncCouncilTmConfigToCompany(cid, councilId)
    .then(function() {
      return adminRead('companySettings/' + cid + '/tmConfig');
    })
    .then(function(cfg) {
      companyTmConfigs[cid] = (cfg && typeof cfg === 'object') ? cfg : null;
      renderSnapshot();
      renderStep2();
      renderStep3();
      showNotice('Re-synced driver-split for ' + (co.name || cid) + '.', 'ok');
    })
    .catch(function(e) {
      showNotice('Re-sync failed: ' + (e && e.message ? e.message : e), 'err');
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
function esc(s)  { return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;'); }
function escA(s) { return String(s || '').replace(/'/g, "\\'"); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
