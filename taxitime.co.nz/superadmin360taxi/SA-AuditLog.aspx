<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Audit Log &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="assets/js/jquery.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet"/>
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet"/>
<link href="assets/css/main.min.css" rel="stylesheet"/>
<link href="assets/css/Toast.css" rel="stylesheet"/>
<link href="assets/css/bootstrap.min.css" rel="stylesheet"/>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}.sa-btn-n:hover{background:#eee}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;color:#0D47A1;font-size:12px;white-space:nowrap}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:last-child td{border-bottom:none}
.sa-tbl tr:hover td{background:#FAFEFF}
.filter-bar{display:flex;gap:10px;padding:14px 18px;background:#F8FBFF;border-bottom:1px solid #e8f0fe;flex-wrap:wrap;align-items:flex-end}
.filter-bar label{font-size:11px;font-weight:700;color:#666;text-transform:uppercase;letter-spacing:.04em;display:block;margin-bottom:3px}
.filter-bar select,.filter-bar input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:140px}
.filter-bar select:focus,.filter-bar input:focus{outline:none;border-color:#1565C0}
.badge{display:inline-block;font-size:11px;font-weight:700;padding:2px 9px;border-radius:10px;white-space:nowrap}
.badge-approved{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-rejected{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.badge-activated{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.badge-deactivated{background:#FFF3E0;color:#E65100;border:1px solid #FFCC80}
.badge-onboarded{background:#F3E5F5;color:#6A1B9A;border:1px solid #CE93D8}
.badge-access-granted{background:#E8F5E9;color:#1B5E20;border:1px solid #81C784}
.badge-access-revoked{background:#FFEBEE;color:#B71C1C;border:1px solid #EF9A9A}
.badge-default{background:#F5F5F5;color:#555;border:1px solid #ddd}
.ts-cell{white-space:nowrap;font-size:12px;color:#666}
.cid-link{color:#1565C0;font-weight:600;text-decoration:none;font-size:12px}
.cid-link:hover{text-decoration:underline}
.empty-row td{text-align:center;padding:40px;color:#aaa;font-size:13px}
.stats-row{display:flex;gap:12px;padding:14px 18px;background:#fff;border-bottom:1px solid #f0f0f0;flex-wrap:wrap}
.stat-chip{background:#F3F8FF;border:1px solid #BBDEFB;border-radius:20px;padding:4px 14px;font-size:12px;color:#1565C0;font-weight:600}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Audit Log &mdash; BookaWaka Admin</label></div>
  <div class="uk-navbar-flip"><ul class="uk-navbar-nav user_actions">
    <li data-uk-dropdown="{mode:'click',pos:'bottom-right'}">
      <a href="#" class="user_action_image"><img class="md-user-image" src="assets/img/bw-logo.png" alt=""/></a>
      <div class="uk-dropdown uk-dropdown-small"><ul class="uk-nav js-uk-prevent">
        <li><a href="Home.aspx">Dashboard</a></li>
        <li><a onclick="window.location.href='SA-Login.aspx'">Logout</a></li>
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
      <li><a href="SA-AuditLog.aspx" style="font-weight:700;color:#1565C0">&#9658; Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-Email.aspx">Send Email</a></li>
      <li><a href="SA-EmailLog.aspx">Email Sent Log</a></li>
      <li><a href="SA-Reports.aspx">Revenue Reports</a></li>
      <li><a href="SA-MasterReport.aspx">&#128202; Platform Overview</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="SA-Registrations.aspx">Registrations</a></li>
      <li><a href="SA-Alerts.aspx">System Alerts</a></li>
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
      <li><a href="SA-Broadcast.aspx">Broadcast</a></li>
      <li><a href="SA-Sessions.aspx">Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx">Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#128196; SA Audit Log</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">All key actions performed in the Super Admin portal — approvals, access grants, deactivations, and onboardings. Newest entries first.</p>

<div class="sa-card">
  <div class="sa-bar">
    <h3>&#128202; Activity Log</h3>
    <div style="display:flex;gap:8px;align-items:center">
      <span id="log-status" style="font-size:12px;opacity:.85"></span>
      <button class="sa-btn sa-btn-n" onclick="loadLog()" style="color:#fff;background:rgba(255,255,255,.2);border-color:rgba(255,255,255,.3)">&#8635; Refresh</button>
      <button class="sa-btn sa-btn-n" onclick="exportCsv()" style="color:#fff;background:rgba(255,255,255,.2);border-color:rgba(255,255,255,.3)">&#8595; CSV</button>
    </div>
  </div>

  <!-- Stats chips -->
  <div class="stats-row" id="stats-row" style="display:none"></div>

  <!-- Filters -->
  <div class="filter-bar">
    <div>
      <label>Action Type</label>
      <select id="f-action" onchange="applyFilters()">
        <option value="">All actions</option>
        <option value="company_approved">Company Approved</option>
        <option value="company_rejected">Company Rejected</option>
        <option value="company_activated">Company Activated</option>
        <option value="company_deactivated">Company Deactivated</option>
        <option value="company_onboarded">Direct Onboarded</option>
        <option value="access_granted">Access Granted</option>
        <option value="access_revoked">Access Revoked</option>
      </select>
    </div>
    <div>
      <label>Company ID</label>
      <input type="text" id="f-cid" placeholder="e.g. 890051" oninput="applyFilters()" style="max-width:130px"/>
    </div>
    <div>
      <label>Actor / Email</label>
      <input type="text" id="f-actor" placeholder="Search actor..." oninput="applyFilters()" style="max-width:180px"/>
    </div>
    <div>
      <label>From Date</label>
      <input type="date" id="f-from" onchange="applyFilters()"/>
    </div>
    <div>
      <label>To Date</label>
      <input type="date" id="f-to" onchange="applyFilters()"/>
    </div>
    <div style="padding-bottom:1px">
      <button class="sa-btn sa-btn-n" onclick="clearFilters()">Clear</button>
    </div>
  </div>

  <!-- Table -->
  <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead>
        <tr>
          <th>Time</th>
          <th>Action</th>
          <th>Actor</th>
          <th>Company</th>
          <th>Detail</th>
        </tr>
      </thead>
      <tbody id="log-body">
        <tr class="empty-row"><td colspan="5">Loading audit log...</td></tr>
      </tbody>
    </table>
  </div>
  <div id="log-footer" style="padding:10px 18px;font-size:12px;color:#aaa;text-align:right"></div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var ALL_ENTRIES = [];

var ACTION_LABELS = {
  company_approved:   { label: 'Company Approved',   cls: 'badge-approved' },
  company_rejected:   { label: 'Company Rejected',   cls: 'badge-rejected' },
  company_activated:  { label: 'Company Activated',  cls: 'badge-activated' },
  company_deactivated:{ label: 'Company Deactivated',cls: 'badge-deactivated' },
  company_onboarded:  { label: 'Direct Onboarded',   cls: 'badge-onboarded' },
  access_granted:     { label: 'Access Granted',     cls: 'badge-access-granted' },
  access_revoked:     { label: 'Access Revoked',     cls: 'badge-access-revoked' }
};

function esc(s) {
  return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function fmtTs(ts) {
  if (!ts) return '—';
  var d = new Date(ts);
  var pad = function(n) { return n < 10 ? '0'+n : n; };
  return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate())
    +' '+pad(d.getHours())+':'+pad(d.getMinutes())+':'+pad(d.getSeconds());
}

function actionBadge(action) {
  var a = ACTION_LABELS[action];
  if (!a) return '<span class="badge badge-default">'+esc(action)+'</span>';
  return '<span class="badge '+a.cls+'">'+esc(a.label)+'</span>';
}

function loadLog() {
  document.getElementById('log-status').textContent = 'Loading...';
  fetch('/api/admin/audit-log')
    .then(function(r) { return r.json(); })
    .then(function(d) {
      ALL_ENTRIES = d.entries || [];
      document.getElementById('log-status').textContent = ALL_ENTRIES.length + ' entries';
      buildStats();
      applyFilters();
    })
    .catch(function(e) {
      document.getElementById('log-status').textContent = 'Error loading log';
      document.getElementById('log-body').innerHTML = '<tr class="empty-row"><td colspan="5">Failed to load audit log: '+esc(String(e))+'</td></tr>';
    });
}

function buildStats() {
  var counts = {};
  ALL_ENTRIES.forEach(function(e) {
    counts[e.action] = (counts[e.action] || 0) + 1;
  });
  var html = '';
  Object.keys(ACTION_LABELS).forEach(function(k) {
    if (counts[k]) {
      html += '<span class="stat-chip">'+esc(ACTION_LABELS[k].label)+': <strong>'+counts[k]+'</strong></span>';
    }
  });
  var sr = document.getElementById('stats-row');
  if (html) { sr.innerHTML = html; sr.style.display = 'flex'; }
  else sr.style.display = 'none';
}

function applyFilters() {
  var fAction = document.getElementById('f-action').value;
  var fCid    = (document.getElementById('f-cid').value || '').trim().toLowerCase();
  var fActor  = (document.getElementById('f-actor').value || '').trim().toLowerCase();
  var fFrom   = document.getElementById('f-from').value;
  var fTo     = document.getElementById('f-to').value;
  var fromTs  = fFrom ? new Date(fFrom).getTime() : 0;
  var toTs    = fTo   ? new Date(fTo).getTime() + 86399999 : Infinity;

  var filtered = ALL_ENTRIES.filter(function(e) {
    if (fAction && e.action !== fAction) return false;
    if (fCid && !String(e.cid || '').toLowerCase().includes(fCid)) return false;
    if (fActor && !String(e.actor || '').toLowerCase().includes(fActor)) return false;
    if (e.ts < fromTs || e.ts > toTs) return false;
    return true;
  });

  renderTable(filtered);
}

function renderTable(entries) {
  var tbody = document.getElementById('log-body');
  if (!entries.length) {
    tbody.innerHTML = '<tr class="empty-row"><td colspan="5">No entries match the current filters.</td></tr>';
    document.getElementById('log-footer').textContent = '';
    return;
  }

  var html = '';
  entries.forEach(function(e) {
    var cidCell = e.cid
      ? '<a href="SA-Company.aspx?cid='+esc(e.cid)+'" class="cid-link">'+esc(e.cidName || e.cid)+'</a>'
        +'<div style="font-size:11px;color:#aaa">ID: '+esc(e.cid)+'</div>'
      : '<span style="color:#ccc">—</span>';

    html += '<tr>'
      + '<td class="ts-cell">'+esc(fmtTs(e.ts))+'</td>'
      + '<td>'+actionBadge(e.action)+'</td>'
      + '<td style="font-size:12px;overflow-wrap:break-word;word-break:break-word;max-width:180px">'+esc(e.actor || '—')+'</td>'
      + '<td>'+cidCell+'</td>'
      + '<td style="font-size:12px;color:#555;overflow-wrap:break-word;word-break:break-word;max-width:260px">'+esc(e.detail || '—')+'</td>'
      + '</tr>';
  });

  tbody.innerHTML = html;
  document.getElementById('log-footer').textContent = 'Showing ' + entries.length + ' of ' + ALL_ENTRIES.length + ' entries';
}

function clearFilters() {
  document.getElementById('f-action').value = '';
  document.getElementById('f-cid').value    = '';
  document.getElementById('f-actor').value  = '';
  document.getElementById('f-from').value   = '';
  document.getElementById('f-to').value     = '';
  applyFilters();
}

function exportCsv() {
  var fAction = document.getElementById('f-action').value;
  var fCid    = (document.getElementById('f-cid').value || '').trim().toLowerCase();
  var fActor  = (document.getElementById('f-actor').value || '').trim().toLowerCase();
  var fFrom   = document.getElementById('f-from').value;
  var fTo     = document.getElementById('f-to').value;
  var fromTs  = fFrom ? new Date(fFrom).getTime() : 0;
  var toTs    = fTo   ? new Date(fTo).getTime() + 86399999 : Infinity;

  var filtered = ALL_ENTRIES.filter(function(e) {
    if (fAction && e.action !== fAction) return false;
    if (fCid && !String(e.cid || '').toLowerCase().includes(fCid)) return false;
    if (fActor && !String(e.actor || '').toLowerCase().includes(fActor)) return false;
    if (e.ts < fromTs || e.ts > toTs) return false;
    return true;
  });

  var rows = [['Time','Action','Actor','Company ID','Company Name','Detail']];
  filtered.forEach(function(e) {
    rows.push([fmtTs(e.ts), e.action || '', e.actor || '', e.cid || '', e.cidName || '', e.detail || '']);
  });

  var csv = rows.map(function(r) {
    return r.map(function(v) { return '"' + String(v).replace(/"/g,'""') + '"'; }).join(',');
  }).join('\r\n');

  var blob = new Blob([csv], {type:'text/csv'});
  var url  = URL.createObjectURL(blob);
  var a    = document.createElement('a');
  a.href   = url;
  a.download = 'bookawaka-audit-log-' + new Date().toISOString().slice(0,10) + '.csv';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

/* Load on auth ready — guarded so multiple _fbOnLogin calls don't stack intervals */
var _logLoaded = false;
var _logInterval = null;
window._fbOnLogin = function() {
  if (_logLoaded) return;
  _logLoaded = true;
  loadLog();
  if (_logInterval) clearInterval(_logInterval);
  _logInterval = setInterval(loadLog, 60000);
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
