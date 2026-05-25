<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Shift Logs &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#37474F;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none}
.sa-btn-n{background:rgba(255,255,255,.18);color:#fff;border:1px solid rgba(255,255,255,.3)}.sa-btn-n:hover{background:rgba(255,255,255,.28)}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#ECEFF1;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #CFD8DC;color:#37474F;font-size:12px;white-space:nowrap}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:last-child td{border-bottom:none}
.sa-tbl tr:hover td{background:#FAFEFE}
.filter-bar{display:flex;gap:10px;padding:12px 18px;background:#FAFAFA;border-bottom:1px solid #ECEFF1;flex-wrap:wrap;align-items:flex-end}
.filter-bar label{font-size:11px;font-weight:700;color:#666;text-transform:uppercase;letter-spacing:.04em;display:block;margin-bottom:3px}
.filter-bar select,.filter-bar input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:140px}
.filter-bar select:focus,.filter-bar input:focus{outline:none;border-color:#37474F}
.stats-row{display:flex;gap:12px;padding:14px 18px;background:#fff;border-bottom:1px solid #ECEFF1;flex-wrap:wrap}
.stat-chip{background:#ECEFF1;border:1px solid #CFD8DC;border-radius:20px;padding:4px 14px;font-size:12px;color:#37474F;font-weight:600}
.stat-chip.green{background:#E8F5E9;border-color:#A5D6A7;color:#2E7D32}
.stat-chip.blue{background:#E3F2FD;border-color:#BBDEFB;color:#1565C0}
.stat-chip.orange{background:#FFF3E0;border-color:#FFCC80;color:#E65100}
.bx{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600;white-space:nowrap}
.bx-active{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.bx-done{background:#ECEFF1;color:#546E7A}
.bx-break{background:#FFF9C4;color:#F57F17}
.empty-row td{text-align:center;padding:50px;color:#aaa;font-size:13px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Shift Logs &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx" style="font-weight:700;color:#1565C0">&#9658; Shift Logs</a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:4px">&#128203; Driver Shift Logs</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">Shift sessions recorded by the driver app across all companies. Includes start/end times, break durations, and vehicle ID.</p>

<div class="sa-card">
  <div class="sa-bar">
    <h3>&#128337; All Shift Sessions</h3>
    <div style="display:flex;gap:8px;align-items:center">
      <span id="sl-status" style="font-size:12px;opacity:.8"></span>
      <button class="sa-btn sa-btn-n" onclick="loadShiftLogs()">&#8635; Refresh</button>
      <button class="sa-btn sa-btn-n" onclick="exportCsv()">&#8595; CSV</button>
    </div>
  </div>

  <!-- Stats -->
  <div class="stats-row" id="sl-stats" style="display:none"></div>

  <!-- Filters -->
  <div class="filter-bar">
    <div>
      <label>Company</label>
      <select id="sl-f-company" onchange="renderLogs()"><option value="">All Companies</option></select>
    </div>
    <div>
      <label>Status</label>
      <select id="sl-f-status" onchange="renderLogs()">
        <option value="">All</option>
        <option value="active">Active (on shift)</option>
        <option value="completed">Completed</option>
      </select>
    </div>
    <div>
      <label>From</label>
      <input type="date" id="sl-f-from" onchange="renderLogs()"/>
    </div>
    <div>
      <label>To</label>
      <input type="date" id="sl-f-to" onchange="renderLogs()"/>
    </div>
    <div>
      <label>Driver / Vehicle</label>
      <input type="text" id="sl-f-search" placeholder="Name or vehicle ID&hellip;" oninput="renderLogs()" style="min-width:180px"/>
    </div>
    <button class="sa-btn" style="background:#fff;border:1px solid #ddd;color:#555;font-size:12px;align-self:flex-end" onclick="clearFilters()">Clear</button>
  </div>

  <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead><tr>
        <th>Driver</th>
        <th>Company</th>
        <th>Vehicle</th>
        <th>Shift Start</th>
        <th>Shift End</th>
        <th>Duration</th>
        <th>Break Time</th>
        <th>Net Work</th>
        <th>Status</th>
      </tr></thead>
      <tbody id="sl-tb"><tr class="empty-row"><td colspan="9">Loading&hellip;</td></tr></tbody>
    </table>
  </div>
  <div id="sl-foot" style="padding:10px 18px;font-size:12px;color:#aaa;border-top:1px solid #f0f0f0"></div>
</div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allLogs = [];
var allCompanies = {};

window._fbOnLogin = function() {
  _fbGet('superClients').then(function(d) {
    allCompanies = d || {};
    populateCompanyFilter();
    loadShiftLogs();
  }).catch(function() {
    loadShiftLogs();
  });
};

function populateCompanyFilter() {
  var o = '<option value="">All Companies</option>';
  Object.entries(allCompanies).forEach(function(e) {
    o += '<option value="' + e[0] + '">' + esc(e[1].name || e[0]) + '</option>';
  });
  document.getElementById('sl-f-company').innerHTML = o;
}

function loadShiftLogs() {
  document.getElementById('sl-status').textContent = 'Loading\u2026';
  document.getElementById('sl-tb').innerHTML = '<tr class="empty-row"><td colspan="9">Loading\u2026</td></tr>';
  document.getElementById('sl-stats').style.display = 'none';

  _fbGet('shiftLogs').then(function(data) {
    allLogs = [];
    data = data || {};

    Object.entries(data).forEach(function(cidEntry) {
      var cid = cidEntry[0];
      var companyName = (allCompanies[cid] && allCompanies[cid].name) || cid;
      var byDriver = cidEntry[1] || {};

      Object.entries(byDriver).forEach(function(drvEntry) {
        var driverId = drvEntry[0];
        var sessions = drvEntry[1] || {};

        // sessions may be keyed by sessionId, or the driver node IS the session
        var sessionEntries = [];
        var firstVal = Object.values(sessions)[0];
        if (firstVal && (firstVal.startTime || firstVal.status)) {
          // each value is a session record
          Object.entries(sessions).forEach(function(se) {
            sessionEntries.push({ sessionId: se[0], rec: se[1] });
          });
        } else {
          // the driver node itself is a single session
          sessionEntries.push({ sessionId: driverId, rec: sessions });
        }

        sessionEntries.forEach(function(se) {
          var r = se.rec || {};
          if (!r.startTime && !r.status) return;

          var startTs  = r.startTime  ? new Date(r.startTime).getTime()  : 0;
          var endTs    = r.endTime    ? new Date(r.endTime).getTime()    : 0;
          var totalMin = +(r.totalMinutes || 0);
          var breakMin = +(r.breakMinutes || 0);

          // Calculate duration from timestamps if totalMinutes not set
          if (!totalMin && startTs && endTs) {
            totalMin = Math.round((endTs - startTs) / 60000);
          }
          var netMin = totalMin - breakMin;
          if (netMin < 0) netMin = 0;

          allLogs.push({
            sessionId:   se.sessionId,
            driverId:    driverId,
            cid:         cid,
            companyName: companyName,
            driverName:  r.driverName || driverId,
            vehicleId:   r.vehicleId  || '',
            startTime:   r.startTime  || '',
            endTime:     r.endTime    || '',
            startTs:     startTs,
            endTs:       endTs,
            totalMin:    totalMin,
            breakMin:    breakMin,
            netMin:      netMin,
            status:      r.status || (r.endTime ? 'completed' : 'active')
          });
        });
      });
    });

    allLogs.sort(function(a, b) { return b.startTs - a.startTs; });
    updateStats();
    renderLogs();
    document.getElementById('sl-status').textContent = 'Last loaded: ' + new Date().toLocaleTimeString('en-NZ');
  }).catch(function(e) {
    console.error('shiftLogs load error:', e);
    document.getElementById('sl-tb').innerHTML = '<tr class="empty-row"><td colspan="9" style="color:#C62828">No shift data yet &mdash; Firebase rules may not be configured, or no drivers have started a shift.</td></tr>';
    document.getElementById('sl-status').textContent = '';
  });
}

function updateStats() {
  var now = Date.now();
  var tStart = _tzTodayStart(); // Pacific/Auckland midnight as UTC ms

  var active = allLogs.filter(function(l) { return l.status === 'active'; }).length;
  var todaySessions = allLogs.filter(function(l) { return l.startTs >= tStart; });
  var totalHoursToday = todaySessions.reduce(function(s, l) { return s + (l.totalMin || 0); }, 0);
  var breakHoursToday = todaySessions.reduce(function(s, l) { return s + (l.breakMin || 0); }, 0);
  var totalSessions = allLogs.length;

  var chips = '';
  chips += '<span class="stat-chip' + (active > 0 ? ' green' : '') + '">' + active + ' active now</span>';
  chips += '<span class="stat-chip blue">' + todaySessions.length + ' sessions today</span>';
  chips += '<span class="stat-chip">' + fmtMins(totalHoursToday) + ' work today</span>';
  if (breakHoursToday > 0) chips += '<span class="stat-chip orange">' + fmtMins(breakHoursToday) + ' breaks today</span>';
  chips += '<span class="stat-chip">' + totalSessions + ' total sessions</span>';

  var el = document.getElementById('sl-stats');
  el.innerHTML = chips;
  el.style.display = 'flex';
}

function renderLogs() {
  var fC  = document.getElementById('sl-f-company').value;
  var fS  = document.getElementById('sl-f-status').value;
  var fFr = document.getElementById('sl-f-from').value;
  var fTo = document.getElementById('sl-f-to').value;
  var fQ  = (document.getElementById('sl-f-search').value || '').toLowerCase();

  var filtered = allLogs.filter(function(l) {
    if (fC && l.cid !== fC) return false;
    if (fS && l.status !== fS) return false;
    if (fFr && l.startTime && _tzToDate(l.startTime) < fFr) return false;
    if (fTo && l.startTime && _tzToDate(l.startTime) > fTo) return false;
    if (fQ) {
      var hay = ((l.driverName || '') + ' ' + (l.vehicleId || '') + ' ' + (l.driverId || '')).toLowerCase();
      if (!hay.includes(fQ)) return false;
    }
    return true;
  });

  document.getElementById('sl-foot').textContent = filtered.length + ' of ' + allLogs.length + ' session(s)';

  if (!filtered.length) {
    document.getElementById('sl-tb').innerHTML = '<tr class="empty-row"><td colspan="9">No sessions match your filters.</td></tr>';
    return;
  }

  document.getElementById('sl-tb').innerHTML = filtered.map(function(l) {
    var startStr = l.startTime ? fmtDT(l.startTime) : '\u2014';
    var endStr   = l.endTime   ? fmtDT(l.endTime)   : (l.status === 'active' ? '<span style="color:#2E7D32;font-weight:600">On shift</span>' : '\u2014');
    var statusBadge = l.status === 'active'
      ? '<span class="bx bx-active">&#9679; Active</span>'
      : '<span class="bx bx-done">Completed</span>';
    var netClass = l.netMin < 240 ? 'color:#E65100' : 'color:#2E7D32';
    return '<tr>' +
      '<td><strong>' + esc(l.driverName) + '</strong><br><span style="font-size:11px;color:#aaa">' + esc(l.driverId) + '</span></td>' +
      '<td>' + esc(l.companyName) + '</td>' +
      '<td>' + (l.vehicleId ? esc(l.vehicleId) : '\u2014') + '</td>' +
      '<td style="white-space:nowrap">' + startStr + '</td>' +
      '<td style="white-space:nowrap">' + endStr + '</td>' +
      '<td>' + (l.totalMin ? fmtMins(l.totalMin) : '\u2014') + '</td>' +
      '<td>' + (l.breakMin > 0 ? '<span class="bx bx-break">' + fmtMins(l.breakMin) + '</span>' : '\u2014') + '</td>' +
      '<td style="font-weight:600;' + netClass + '">' + (l.netMin ? fmtMins(l.netMin) : '\u2014') + '</td>' +
      '<td>' + statusBadge + '</td>' +
    '</tr>';
  }).join('');
}

function clearFilters() {
  ['sl-f-company','sl-f-status'].forEach(function(id) { document.getElementById(id).value = ''; });
  ['sl-f-from','sl-f-to','sl-f-search'].forEach(function(id) { document.getElementById(id).value = ''; });
  renderLogs();
}

function fmtDT(iso) { return _tzFmtDT(iso); } // Pacific/Auckland
function fmtMins(m) {
  m = Math.round(m || 0);
  if (m < 60) return m + 'm';
  return Math.floor(m/60) + 'h ' + (m%60) + 'm';
}
function esc(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

function exportCsv() {
  var fC  = document.getElementById('sl-f-company').value;
  var fS  = document.getElementById('sl-f-status').value;
  var fFr = document.getElementById('sl-f-from').value;
  var fTo = document.getElementById('sl-f-to').value;
  var fQ  = (document.getElementById('sl-f-search').value || '').toLowerCase();
  var rows = allLogs.filter(function(l) {
    if (fC && l.cid !== fC) return false;
    if (fS && l.status !== fS) return false;
    if (fFr && l.startTime && _tzToDate(l.startTime) < fFr) return false;
    if (fTo && l.startTime && _tzToDate(l.startTime) > fTo) return false;
    if (fQ) { var hay = ((l.driverName||'')+' '+(l.vehicleId||'')).toLowerCase(); if(!hay.includes(fQ)) return false; }
    return true;
  });
  var csv = 'Driver,Driver ID,Company,Vehicle,Shift Start,Shift End,Total Mins,Break Mins,Net Mins,Status\n';
  rows.forEach(function(l) {
    csv += [
      '"'+(l.driverName||'').replace(/"/g,'""')+'"',
      '"'+l.driverId+'"',
      '"'+(l.companyName||'').replace(/"/g,'""')+'"',
      '"'+(l.vehicleId||'')+'"',
      l.startTime||'',
      l.endTime||'',
      l.totalMin||0,
      l.breakMin||0,
      l.netMin||0,
      l.status||''
    ].join(',') + '\n';
  });
  var blob = new Blob([csv], {type:'text/csv'});
  var a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'shift-logs-' + _tzDateStr() + '.csv';
  a.click();
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
