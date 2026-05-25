<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Council Config &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png" />
<script src="assets/js/jquery.min.js" type="text/javascript"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet" />
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet" />
<link href="assets/css/main.min.css" rel="stylesheet" />
<link href="assets/css/Toast.css" rel="stylesheet" />
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
.bx-a{background:#FFF8E1;color:#1565C0}.bx-b{background:#E3F2FD;color:#1565C0}
.bx-gr{background:#F5F5F5;color:#616161}
.tm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.tm-btn-p{background:#37474F;color:#fff}.tm-btn-p:hover{background:#263238}
.tm-btn-e{background:#E3F2FD;color:#1565C0}.tm-btn-d{background:#FFEBEE;color:#C62828}
.tm-btn-ok{background:#E8F5E9;color:#2E7D32}.tm-btn-am{background:#FFF8E1;color:#1565C0}
.tm-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.tm-ov{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:999;align-items:center;justify-content:center}
.tm-ov.open{display:flex}
.tm-modal{background:#fff;border-radius:8px;width:680px;max-width:95vw;max-height:92vh;overflow-y:auto;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.tm-mh{background:#37474F;color:#fff;padding:14px 18px;display:flex;align-items:center;justify-content:space-between;border-radius:8px 8px 0 0}
.tm-mh h3{margin:0;font-size:15px}
.tm-mb{padding:18px}.tm-mf{padding:12px 18px;border-top:1px solid #eee;display:flex;gap:8px;justify-content:flex-end}
.tm-fg{display:grid;grid-template-columns:1fr 1fr;gap:12px 18px}
.tm-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.tm-ff input,.tm-ff select,.tm-ff textarea{width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.tm-ff input:focus,.tm-ff select:focus{outline:none;border-color:#37474F}
.tm-ff input.cc-err,.tm-ff select.cc-err{border-color:#C62828!important;background:#fff5f5!important;box-shadow:0 0 0 2px rgba(198,40,40,.15)!important}
.tm-msg{margin-top:8px;font-size:13px}.tm-msg.ok{color:#2E7D32}.tm-msg.err{color:#C62828}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main">
  <div class="header_main_content">
    <nav class="uk-navbar">
      <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
      <div class="col-md-offset-2 col-md-4">
        <label style="color:#fff">TM Council Config — BookaWaka Admin</label>
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
    <h3>TM Council Config <small id="cc-count" style="opacity:.75;font-size:12px"></small></h3>
    <div style="display:flex;gap:8px">
      <button class="tm-btn tm-btn-p" onclick="openCC()">+ Add Council</button>
      <button class="tm-btn tm-btn-wh" onclick="refreshCC()">&#8635;</button>
    </div>
  </div>
  <div style="overflow-x:auto">
    <table class="tm-tbl">
      <thead><tr>
        <th>Council Name</th><th>Region</th><th>Cap ($)</th><th>Subsidy %</th>
        <th>Hoist/Use ($)</th><th>Hoist By</th><th>Monthly Limit</th><th>Daily Limit</th>
        <th>Portal Login Email</th><th>Last Login</th><th>Status</th><th>Actions</th>
      </tr></thead>
      <tbody id="cc-tb"><tr><td colspan="12" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
    </table>
  </div>
</div></div>

<div class="tm-ov" id="cc-ov">
<div class="tm-modal">
  <div class="tm-mh"><h3 id="cc-mtitle">Add Council</h3>
    <button onclick="closeCC()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1">&#x2715;</button></div>
  <div class="tm-mb"><div class="tm-fg">
    <div class="tm-ff" style="grid-column:1/-1"><label>Council Name *</label><input id="cc-name" placeholder="e.g. Invercargill City Council"/></div>
    <div class="tm-ff"><label>Region</label><input id="cc-region" placeholder="e.g. Invercargill"/></div>
    <div class="tm-ff"><label>Approver Email</label><input id="cc-email" type="email" placeholder="council@example.govt.nz"/></div>
    <div class="tm-ff"><label>Subsidy Cap per Trip ($) *</label><input id="cc-cap" type="number" step="0.01" min="0" placeholder="37.50"/></div>
    <div class="tm-ff"><label>Subsidy Percentage (%) *</label><input id="cc-pct" type="number" step="1" min="1" max="100" placeholder="75"/></div>
    <div class="tm-ff"><label>Hoist Fee per Use ($)</label><input id="cc-hrate" type="number" step="0.01" min="0" placeholder="10.00"/></div>
    <div class="tm-ff"><label>Hoist Covered By</label>
      <select id="cc-hcov"><option value="true">Council</option><option value="false">Passenger</option></select></div>
    <div class="tm-ff"><label>Max Hoists per Trip</label><input id="cc-hmx" type="number" min="0" placeholder="2"/></div>
    <div class="tm-ff"><label>Monthly Trip Limit per Passenger</label><input id="cc-ml" type="number" min="0" placeholder="No limit"/></div>
    <div class="tm-ff"><label>Daily Trip Limit per Passenger</label><input id="cc-dl" type="number" min="0" placeholder="No limit"/></div>
    <div class="tm-ff"><label>Status</label>
      <select id="cc-act"><option value="true">Active</option><option value="false">Inactive</option></select></div>
    <div class="tm-ff"><label>Notes</label><input id="cc-notes" placeholder="Optional notes"/></div>
    <div style="grid-column:1/-1;border-top:1px solid #e8e8e8;margin-top:6px;padding-top:14px">
      <p style="font-size:12px;font-weight:600;color:#37474F;margin-bottom:6px">&#x1F511; Council Portal Access</p>
      <div id="cc-access-status" style="margin-bottom:8px"></div>
    </div>
    <div class="tm-ff"><label>Portal Login Email</label><input id="cc-portal-email" type="email" readonly style="background:#f5f5f5;color:#555"/></div>
    <div class="tm-ff"><label>Set / Reset Portal Password</label><input id="cc-pw" type="password" placeholder="Leave blank to keep existing"/></div>
    <div class="tm-ff"><label>Confirm Password</label><input id="cc-pw2" type="password" placeholder="Re-enter new password"/></div>
    <div class="tm-ff" style="grid-column:1/-1"><p style="font-size:11.5px;color:#888">The portal email follows the Approver Email above. To reset the password, enter a new one and save. Council staff can log in at <strong>/council-portal</strong> to view and approve trips.</p></div>
  </div>
  <div id="cc-msg" class="tm-msg"></div></div>
  <div class="tm-mf">
    <button class="tm-btn" style="background:#eee;color:#333" onclick="closeCC()">Cancel</button>
    <button class="tm-btn tm-btn-p" onclick="saveCC()">Save Council</button>
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
var ccData = {}, ccAccess = {}, ccEid = null;

window._fbOnLogin = function() { loadCC(); };

function loadCC() {
  adminRead('tmCouncilAccess').then(function(a) { ccAccess = a || {}; });
  adminListen('tmConfig', function(d) {
    ccData = d || {};
    adminRead('tmCouncilAccess').then(function(a) { ccAccess = a || {}; renderCC(); });
  });
}
function refreshCC() {
  document.getElementById('cc-tb').innerHTML = '<tr><td colspan="12" style="text-align:center;padding:30px;color:#9e9e9e">Refreshing\u2026</td></tr>';
  Promise.all([adminRead('tmConfig'), adminRead('tmCouncilAccess')]).then(function(res) {
    ccData = res[0] || {}; ccAccess = res[1] || {}; renderCC();
  });
}
function renderCC() {
  var e = Object.entries(ccData);
  document.getElementById('cc-count').textContent = e.length + ' council(s)';
  if (!e.length) { document.getElementById('cc-tb').innerHTML = '<tr><td colspan="12" style="text-align:center;padding:40px;color:#9e9e9e">No councils configured yet.</td></tr>'; return; }
  document.getElementById('cc-tb').innerHTML = e.map(function(kv) {
    var id = kv[0], c = kv[1];
    var eid = id.replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    var acc = ccAccess[id] || {};
    var portalEmail = acc.email || c.approverEmail || '';
    var hasAccess = !!(acc.email && acc.passwordHash);
    var lastLogin = acc.lastLogin ? new Date(acc.lastLogin).toLocaleString('en-NZ', {day:'2-digit',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}) : '\u2014';
    var portalCell = hasAccess
      ? '<span style="font-size:12px">' + portalEmail + '</span><br><span class="bx bx-g" style="font-size:10px;margin-top:2px">&#x2713; Access Set</span>'
      : (portalEmail
          ? '<span style="font-size:12px;color:#888">' + portalEmail + '</span><br><span class="bx bx-r" style="font-size:10px;margin-top:2px">No Password Set</span>'
          : '<span class="bx bx-r" style="font-size:10px">Not Configured</span>');
    return '<tr>' +
      '<td><strong>' + (c.name || '\u2014') + '</strong></td>' +
      '<td>' + (c.region || '\u2014') + '</td>' +
      '<td style="font-weight:600;color:#2E7D32">$' + parseFloat(c.capAmount || 0).toFixed(2) + '</td>' +
      '<td>' + (c.subsidyPercent || 0) + '%</td>' +
      '<td>$' + parseFloat(c.hoistRatePerUse || 0).toFixed(2) + '</td>' +
      '<td>' + (c.hoistCoveredByCouncil === false ? 'Passenger' : 'Council') + '</td>' +
      '<td>' + (c.monthlyLimitPerPassenger || '\u2014') + '</td>' +
      '<td>' + (c.dailyLimitPerPassenger || '\u2014') + '</td>' +
      '<td>' + portalCell + '</td>' +
      '<td style="font-size:12px;color:#666">' + lastLogin + '</td>' +
      '<td>' + (c.active !== false ? '<span class="bx bx-g">Active</span>' : '<span class="bx bx-r">Inactive</span>') + '</td>' +
      '<td style="white-space:nowrap">' +
        '<button class="tm-btn tm-btn-e" onclick="editCC(\'' + eid + '\')" style="margin-right:4px">Edit</button>' +
        '<button class="tm-btn tm-btn-d" onclick="delCC(\'' + eid + '\')">Delete</button>' +
      '</td></tr>';
  }).join('');
}
function ccClearPwFields() {
  document.getElementById('cc-pw').value = ''; document.getElementById('cc-pw2').value = '';
}
function ccHighlight(id) {
  var el = document.getElementById(id);
  el.classList.add('cc-err');
  el.scrollIntoView({ behavior: 'smooth', block: 'center' });
  el.focus();
  var off = function() { el.classList.remove('cc-err'); el.removeEventListener('input', off); el.removeEventListener('change', off); };
  el.addEventListener('input', off); el.addEventListener('change', off);
}
function ccClearHighlights() {
  ['cc-name','cc-cap','cc-pct','cc-email','cc-pw','cc-pw2'].forEach(function(id) {
    document.getElementById(id).classList.remove('cc-err');
  });
}
function ccSyncPortalEmail() {
  document.getElementById('cc-portal-email').value = document.getElementById('cc-email').value.trim();
}
function openCC() {
  ccEid = null; document.getElementById('cc-mtitle').textContent = 'Add Council';
  ['cc-name','cc-region','cc-email','cc-cap','cc-pct','cc-hrate','cc-hmx','cc-ml','cc-dl','cc-notes'].forEach(function(x) { document.getElementById(x).value = ''; });
  document.getElementById('cc-hcov').value = 'true'; document.getElementById('cc-act').value = 'true';
  document.getElementById('cc-msg').textContent = '';
  document.getElementById('cc-access-status').innerHTML = '';
  ccClearPwFields(); ccSyncPortalEmail();
  document.getElementById('cc-email').addEventListener('input', ccSyncPortalEmail);
  document.getElementById('cc-ov').classList.add('open');
}
function closeCC() { document.getElementById('cc-ov').classList.remove('open'); ccClearHighlights(); }
function editCC(id) {
  ccEid = id; var c = ccData[id] || {}, acc = ccAccess[id] || {};
  document.getElementById('cc-mtitle').textContent = 'Edit Council';
  document.getElementById('cc-name').value = c.name || '';
  document.getElementById('cc-region').value = c.region || '';
  document.getElementById('cc-email').value = c.approverEmail || '';
  document.getElementById('cc-cap').value = c.capAmount || '';
  document.getElementById('cc-pct').value = c.subsidyPercent || '';
  document.getElementById('cc-hrate').value = c.hoistRatePerUse || '';
  document.getElementById('cc-hcov').value = c.hoistCoveredByCouncil === false ? 'false' : 'true';
  document.getElementById('cc-hmx').value = c.maxHoistsPerTrip || '';
  document.getElementById('cc-ml').value = c.monthlyLimitPerPassenger || '';
  document.getElementById('cc-dl').value = c.dailyLimitPerPassenger || '';
  document.getElementById('cc-act').value = c.active === false ? 'false' : 'true';
  document.getElementById('cc-notes').value = c.notes || '';
  document.getElementById('cc-msg').textContent = '';
  ccClearPwFields();
  var portalEmailEl = document.getElementById('cc-portal-email');
  portalEmailEl.value = acc.email || c.approverEmail || '';
  var hasAccess = !!(acc.email && acc.passwordHash);
  var lastLogin = acc.lastLogin ? new Date(acc.lastLogin).toLocaleString('en-NZ') : null;
  var statusNote = hasAccess
    ? '&#x2713; Portal access is set. Leave password blank to keep current password.' + (lastLogin ? ' Last login: ' + lastLogin + '.' : '')
    : 'No portal access configured yet. Set a password below to enable login.';
  document.getElementById('cc-access-status').innerHTML = '<span style="color:' + (hasAccess ? '#2E7D32' : '#C62828') + ';font-size:12px">' + statusNote + '</span>';
  document.getElementById('cc-email').addEventListener('input', ccSyncPortalEmail);
  document.getElementById('cc-ov').classList.add('open');
}
function saveCC() {
  var nm = document.getElementById('cc-name').value.trim(),
      cap = parseFloat(document.getElementById('cc-cap').value),
      pct = parseFloat(document.getElementById('cc-pct').value);
  ccClearHighlights();
  if (!nm) { ccMsg('Council name is required.', false); ccHighlight('cc-name'); return; }
  if (isNaN(cap) || cap <= 0) { ccMsg('Enter a valid subsidy cap amount ($).', false); ccHighlight('cc-cap'); return; }
  if (isNaN(pct) || pct < 1 || pct > 100) { ccMsg('Subsidy % must be between 1 and 100.', false); ccHighlight('cc-pct'); return; }
  var pw = document.getElementById('cc-pw').value.trim();
  var pw2 = document.getElementById('cc-pw2').value.trim();
  if (pw && pw.length < 6) { ccMsg('Password must be at least 6 characters.', false); ccHighlight('cc-pw'); return; }
  if (pw && pw !== pw2) { ccMsg('Passwords do not match \u2014 re-enter both fields.', false); ccHighlight('cc-pw'); ccHighlight('cc-pw2'); return; }
  var email = document.getElementById('cc-email').value.trim();
  if (pw && !email) { ccMsg('Please enter an Approver Email \u2014 this becomes the portal login username.', false); ccHighlight('cc-email'); return; }
  var key = ccEid || ('cncl_' + nm.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, ''));
  var data = {
    name: nm, region: document.getElementById('cc-region').value.trim(),
    approverEmail: email, capAmount: cap, subsidyPercent: pct,
    hoistRatePerUse: parseFloat(document.getElementById('cc-hrate').value) || 0,
    hoistCoveredByCouncil: document.getElementById('cc-hcov').value === 'true',
    maxHoistsPerTrip: parseInt(document.getElementById('cc-hmx').value) || null,
    monthlyLimitPerPassenger: parseInt(document.getElementById('cc-ml').value) || null,
    dailyLimitPerPassenger: parseInt(document.getElementById('cc-dl').value) || null,
    active: document.getElementById('cc-act').value === 'true',
    notes: document.getElementById('cc-notes').value.trim(), updatedAt: Date.now()
  };
  adminWrite('tmConfig/' + key, 'PUT', data).then(function() {
    ccData[key] = data;
    if (pw) {
      return fetch('/api/set-council-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ councilId: key, email: email, password: pw })
      }).then(function(r) { return r.json(); }).then(function(res) {
        if (res.error) { ccMsg('Council saved but portal password failed: ' + res.error, false); }
        else { ccMsg('Council saved + portal access set!', true); setTimeout(function() { renderCC(); closeCC(); }, 1800); }
      }).catch(function(e) { ccMsg('Council saved but portal password error: ' + e.message, false); });
    }
    renderCC(); closeCC();
  }).catch(function(e) { ccMsg('Save failed: ' + e.message, false); });
}
function delCC(id) {
  if (!confirm('Delete council "' + ((ccData[id] || {}).name || id) + '"?')) return;
  adminWrite('tmConfig/' + id, 'DELETE', null).then(function() { delete ccData[id]; renderCC(); })
    .catch(function(e) { alert('Delete failed: ' + e.message); });
}
function ccMsg(m, ok) { var el = document.getElementById('cc-msg'); el.textContent = m; el.className = 'tm-msg ' + (ok ? 'ok' : 'err'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
