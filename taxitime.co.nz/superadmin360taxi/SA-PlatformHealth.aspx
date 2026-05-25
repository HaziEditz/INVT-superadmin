<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Platform Health &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#1B5E20;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.sa-btn-n{background:rgba(255,255,255,.18);color:#fff;border:1px solid rgba(255,255,255,.3)}.sa-btn-n:hover{background:rgba(255,255,255,.28)}

/* Summary strip */
.sum-strip{display:flex;gap:0;overflow-x:auto}
.sum-box{flex:1;min-width:130px;padding:18px 16px;text-align:center;border-right:1px solid #f0f0f0}
.sum-box:last-child{border-right:none}
.sum-num{font-size:28px;font-weight:700;line-height:1}
.sum-lbl{font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.05em;margin-top:4px}

/* Module health matrix */
.mh-tbl{width:100%;border-collapse:collapse;font-size:12px}
.mh-tbl th{padding:8px 10px;text-align:center;font-weight:700;font-size:11px;text-transform:uppercase;letter-spacing:.03em;border-bottom:2px solid #e8f5e9;background:#F1F8E9;color:#2E7D32;white-space:nowrap}
.mh-tbl th:first-child{text-align:left;min-width:160px;background:#F9FBE7;color:#33691E}
.mh-tbl td{padding:7px 10px;border-bottom:1px solid #f5f5f5;text-align:center;vertical-align:middle}
.mh-tbl td:first-child{text-align:left;font-weight:600;font-size:12px}
.mh-tbl tr:last-child td{border-bottom:none}
.mh-tbl tr:hover td{background:#FAFFFE}

/* Status indicators */
.dot{display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border-radius:50%;font-size:13px;font-weight:700;cursor:default}
.dot-green{background:#E8F5E9;color:#2E7D32;border:2px solid #81C784}
.dot-amber{background:#FFF8E1;color:#F57F17;border:2px solid #FFD54F}
.dot-red{background:#FFEBEE;color:#C62828;border:2px solid #EF9A9A}
.dot-grey{background:#F5F5F5;color:#bbb;border:2px solid #E0E0E0}
.dot-blue{background:#E3F2FD;color:#1565C0;border:2px solid #90CAF9}

/* Legend */
.legend{display:flex;gap:16px;padding:10px 18px;background:#FAFAFA;border-top:1px solid #F1F8E9;flex-wrap:wrap;font-size:12px;color:#666;align-items:center}
.legend-item{display:flex;align-items:center;gap:5px}

/* Warning cards */
.warn-list{padding:14px 18px}
.warn-item{display:flex;align-items:flex-start;gap:10px;padding:9px 12px;border-radius:6px;margin-bottom:8px;font-size:13px}
.warn-item:last-child{margin-bottom:0}
.warn-red{background:#FFF3F3;border-left:3px solid #F44336}
.warn-amber{background:#FFFBF0;border-left:3px solid #FFC107}
.warn-blue{background:#F0F4FF;border-left:3px solid #1565C0}
.warn-icon{font-size:16px;margin-top:1px;flex-shrink:0}

/* Config table */
.cfg-tbl{width:100%;border-collapse:collapse;font-size:12px}
.cfg-tbl th{padding:7px 12px;text-align:left;background:#F9FBE7;font-weight:700;font-size:11px;text-transform:uppercase;color:#33691E;border-bottom:2px solid #E8F5E9}
.cfg-tbl td{padding:7px 12px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.cfg-tbl tr:last-child td{border-bottom:none}
.cfg-ok{color:#2E7D32;font-weight:600}
.cfg-miss{color:#C62828;font-weight:600}
.cfg-part{color:#E65100;font-weight:600}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Platform Health &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-Email.aspx">Send Email</a></li>
      <li><a href="SA-EmailLog.aspx">Email Sent Log</a></li>
      <li><a href="SA-Reports.aspx">Revenue Reports</a></li>
      <li><a href="SA-MasterReport.aspx">&#128202; Platform Overview</a></li>
      <li><a href="SA-PlatformHealth.aspx" style="font-weight:700;color:#1565C0">&#9658; Platform Health</a></li>
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

<div style="display:flex;align-items:flex-start;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:18px">
  <div>
    <h2 style="font-size:18px;font-weight:700;margin:0 0 4px">&#128994; Platform Health Check</h2>
    <p style="font-size:13px;color:#888;margin:0">Real-time view of which features are active across every company. Green = data exists and recent. Use this to spot silent gaps before they cost money.</p>
  </div>
  <div style="display:flex;gap:8px;align-items:center">
    <span id="ph-status" style="font-size:12px;color:#888"></span>
    <button class="sa-btn" style="background:#1B5E20;color:#fff;border:none" onclick="runHealthCheck()">&#8635; Refresh</button>
    <button class="sa-btn" style="background:#fff;border:1px solid #ddd;color:#555;font-size:12px" onclick="exportCsv()">&#8595; Export CSV</button>
  </div>
</div>

<!-- Platform summary strip -->
<div class="sa-card">
  <div class="sum-strip" id="ph-summary">
    <div class="sum-box"><div class="sum-num" id="s-companies">—</div><div class="sum-lbl">Total Companies</div></div>
    <div class="sum-box"><div class="sum-num" id="s-active" style="color:#2E7D32">—</div><div class="sum-lbl">Active (7d)</div></div>
    <div class="sum-box"><div class="sum-num" id="s-drivers" style="color:#1565C0">—</div><div class="sum-lbl">Drivers On Shift</div></div>
    <div class="sum-box"><div class="sum-num" id="s-warnings" style="color:#E65100">—</div><div class="sum-lbl">Config Warnings</div></div>
    <div class="sum-box"><div class="sum-num" id="s-dead" style="color:#C62828">—</div><div class="sum-lbl">No Activity (30d)</div></div>
  </div>
</div>

<!-- Warnings panel -->
<div class="sa-card" id="warn-card" style="display:none">
  <div class="sa-bar" style="background:#E65100"><h3>&#9888; Configuration Warnings</h3><span id="warn-count" style="font-size:12px;opacity:.8"></span></div>
  <div class="warn-list" id="warn-list"></div>
</div>

<!-- Module health matrix -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#128202; Per-Company Module Health</h3>
    <div style="display:flex;gap:8px;align-items:center">
      <input type="text" id="ph-search" placeholder="Filter companies…" oninput="renderMatrix()" style="padding:5px 10px;border-radius:4px;border:1px solid rgba(255,255,255,.4);background:rgba(255,255,255,.15);color:#fff;font-size:12px;min-width:160px;outline:none"/>
    </div>
  </div>
  <div style="overflow-x:auto">
    <table class="mh-tbl">
      <thead><tr id="mh-head">
        <th>Company</th>
        <th title="Hail / street pickup trips (completedJobs)">&#x1F695; Taxi (hail)</th>
        <th title="Dispatched taxi trips (allbookings)">&#x1F4CD; Taxi (dispatch)</th>
        <th title="Total Mobility subsidised trips">&#x267F; Total Mobility</th>
        <th title="Food delivery orders">&#x1F355; Food</th>
        <th title="Freight / courier orders">&#x1F4E6; Freight</th>
        <th title="Towing requests">&#x1F69B; Towing</th>
        <th title="Car rental bookings">&#x1F697; Rental</th>
        <th title="ACC client trips">&#x1FA7A; ACC</th>
        <th title="Business account usage">&#x1F3E2; Business Acc.</th>
        <th title="Driver shift logs recorded">&#x23F1; Shift Logs</th>
        <th title="Payment gateway configured">&#x1F4B3; Payments</th>
        <th title="Last any activity">Last Activity</th>
      </tr></thead>
      <tbody id="mh-tb"><tr><td colspan="13" style="text-align:center;padding:50px;color:#aaa">Loading health data&hellip;</td></tr></tbody>
    </table>
  </div>
  <div class="legend">
    <strong style="color:#555;font-size:11px">LEGEND:</strong>
    <span class="legend-item"><span class="dot dot-green">&#10003;</span> Active (data found)</span>
    <span class="legend-item"><span class="dot dot-amber">!</span> Old (data &gt;30 days)</span>
    <span class="legend-item"><span class="dot dot-red">&times;</span> No data</span>
    <span class="legend-item"><span class="dot dot-grey">&mdash;</span> N/A</span>
    <span class="legend-item"><span class="dot dot-blue">&#9679;</span> Active NOW</span>
  </div>
</div>

<!-- Module deep-dive -->
<div class="sa-card">
  <div class="sa-bar" style="background:#0D47A1"><h3>&#x1F527; Feature Configuration Status</h3></div>
  <div style="overflow-x:auto">
    <table class="cfg-tbl">
      <thead><tr>
        <th>Company</th>
        <th>TM Council Config</th>
        <th>TM Cards</th>
        <th>FD Restaurants</th>
        <th>Business Accounts</th>
        <th>ACC Clients</th>
        <th>Drivers Registered</th>
        <th>Status</th>
      </tr></thead>
      <tbody id="cfg-tb"><tr><td colspan="8" style="text-align:center;padding:30px;color:#aaa">Loading&hellip;</td></tr></tbody>
    </table>
  </div>
</div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allCompanies = {};
var healthData   = {};  // cid → module results
var warnings     = [];

/* ─── Paths checked per module ──────────────────────────────────── */
// tsField: primary timestamp field name; tsFieldAlt: fallback if primary missing
// Driver app confirmed: completedAt_ISO = ISO string, completedAt = NZ display string (do NOT use for math)
var MODULES = [
  { key:'taxi',      label:'Taxi (hail)',    path:function(cid){ return 'completedJobs/'+cid; },    tsField:'completedAt_ISO', tsFieldAlt:'completedAt' },
  { key:'dispatch',  label:'Taxi (dispatch)',path:function(cid){ return 'allbookings/'+cid; },      tsField:'completedAt_ISO', tsFieldAlt:'CompletedAt_ISO', tsFieldAlt2:'completedAt', statusFilter:'completed' },
  { key:'tm',        label:'TM',             path:function(cid){ return 'tmTripStatus/'+cid; },     tsField:'completedAt_ISO', tsFieldAlt:'completedAt' },
  { key:'food',      label:'Food',           path:function(cid){ return 'fdOrders/'+cid; },         tsField:'createdAt' },
  { key:'freight',   label:'Freight',        path:function(cid){ return 'frOrders/'+cid; },        tsField:'createdAt' },
  { key:'towing',    label:'Towing',         path:function(cid){ return 'towingJobs/'+cid; },      tsField:'createdAt' },
  { key:'rental',    label:'Rental',         path:function(cid){ return 'rentalBookings/'+cid; },  tsField:'createdAt' },
  { key:'acc',       label:'ACC',            path:function(cid){ return 'accClients/'+cid; },      tsField:'createdAt' },
  { key:'biz',       label:'BizAcc',         path:function(cid){ return 'businessAccounts/'+cid; },tsField:'createdAt' },
  { key:'shifts',    label:'Shifts',         path:function(cid){ return 'shiftLogs/'+cid; },       tsField:'startTime' }
];

var THIRTY_DAYS = 30 * 24 * 60 * 60 * 1000;
var SEVEN_DAYS  =  7 * 24 * 60 * 60 * 1000;

window._fbOnLogin = function() {
  Promise.all([
    _fbGet('superClients').then(function(v){ return v||{}; }),
    _fbGet('tmConfig').then(function(v){ return v||{}; }),
    _fbGet('tmCards').then(function(v){ return v||{}; }),
    _fbGet('fdRestaurants').then(function(v){ return v||{}; }),
    _fbGet('businessAccounts').then(function(v){ return v||{}; }),
    _fbGet('accClients').then(function(v){ return v||{}; })
  ]).then(function(res){
    allCompanies       = res[0];
    window._tmConfig   = res[1];
    window._tmCards    = res[2];
    window._fdRests    = res[3];
    window._bizAccAll  = res[4];
    window._accAll     = res[5];
    document.getElementById('s-companies').textContent = Object.keys(allCompanies).length;
    runHealthCheck();
  });
};

function runHealthCheck() {
  document.getElementById('ph-status').textContent = 'Checking\u2026';
  document.getElementById('mh-tb').innerHTML = '<tr><td colspan="13" style="text-align:center;padding:50px;color:#aaa">Loading\u2026</td></tr>';
  document.getElementById('cfg-tb').innerHTML = '<tr><td colspan="8" style="text-align:center;padding:30px;color:#aaa">Loading\u2026</td></tr>';
  healthData = {};
  warnings   = [];

  var cids = Object.keys(allCompanies);
  if (!cids.length) {
    document.getElementById('mh-tb').innerHTML = '<tr><td colspan="13" style="text-align:center;padding:50px;color:#aaa">No companies found.</td></tr>';
    return;
  }

  var now = Date.now();
  var pending = 0;

  // Also check active drivers via shiftLogs
  _fbGet('shiftLogs').then(function(allShifts) {
    window._allShifts = allShifts || {};
    var activeDriverCount = 0;
    Object.values(window._allShifts).forEach(function(byDriver) {
      Object.values(byDriver || {}).forEach(function(sessions) {
        if (sessions && typeof sessions === 'object') {
          Object.values(sessions).forEach(function(s) {
            if ((s||{}).status === 'active') activeDriverCount++;
          });
          // also handle driver node = single session
          if ((sessions||{}).status === 'active') activeDriverCount++;
        }
      });
    });
    document.getElementById('s-drivers').textContent = activeDriverCount;
  }).catch(function(){ document.getElementById('s-drivers').textContent = '—'; });

  cids.forEach(function(cid) {
    healthData[cid] = { cid: cid, modules: {} };
    var tasks = MODULES.map(function(mod) {
      return _fbGet(mod.path(cid), {limitToLast: 5, orderBy: '$key'})
        .then(function(data) {
          if (!data || typeof data !== 'object' || !Object.keys(data).length) {
            healthData[cid].modules[mod.key] = { status: 'none', lastTs: 0 };
            return;
          }
          // Find most recent timestamp; use tsFieldAlt if primary is a display string not ISO
          var maxTs = 0;
          Object.values(data).forEach(function(entry) {
            var rawTs = (entry||{})[mod.tsField]
              || (mod.tsFieldAlt  ? (entry||{})[mod.tsFieldAlt]  : 0)
              || (mod.tsFieldAlt2 ? (entry||{})[mod.tsFieldAlt2] : 0)
              || 0;
            // If statusFilter set, skip entries that don't match
            // Handle both Status:"Completed" (historical) and status:"completed" (new records)
            if (mod.statusFilter) {
              var entryStatus = ((entry||{}).status || (entry||{}).Status || '').toLowerCase();
              if (entryStatus !== mod.statusFilter && entryStatus !== 'done') return;
            }
            var ts = typeof rawTs === 'number' ? rawTs : new Date(rawTs).getTime();
            if (!isNaN(ts) && ts > maxTs) maxTs = ts;
          });
          // For shifts: check active status
          var hasActive = false;
          if (mod.key === 'shifts') {
            Object.values(data).forEach(function(driverSessions) {
              Object.values(driverSessions || {}).forEach(function(s) {
                if ((s||{}).status === 'active') hasActive = true;
              });
              if ((driverSessions||{}).status === 'active') hasActive = true;
            });
          }
          var age = now - maxTs;
          var status = hasActive ? 'active' : (maxTs === 0 ? 'data' : (age < THIRTY_DAYS ? 'recent' : 'old'));
          healthData[cid].modules[mod.key] = { status: status, lastTs: maxTs, count: Object.keys(data).length };
        })
        .catch(function() {
          healthData[cid].modules[mod.key] = { status: 'none', lastTs: 0 };
        });
    });

    // Payment config check
    var payTask = _fbGet('companySettings/'+cid+'/paymentGateway')
      .then(function(pg) {
        healthData[cid].paymentConfig = pg ? 'configured' : 'missing';
      })
      .catch(function() { healthData[cid].paymentConfig = 'unknown'; });

    pending++;
    Promise.all(tasks.concat([payTask])).then(function() {
      pending--;
      if (pending === 0) onAllDone();
    });
  });
}

function onAllDone() {
  buildWarnings();
  renderMatrix();
  renderConfigTable();
  updateSummaryStats();
  document.getElementById('ph-status').textContent = 'Last checked: ' + new Date().toLocaleTimeString('en-NZ', {timeZone: PLATFORM_TZ});
}

function updateSummaryStats() {
  var cids = Object.keys(healthData);
  var now = Date.now();
  var activeCount = 0, deadCount = 0;
  cids.forEach(function(cid) {
    var mods = healthData[cid].modules;
    var anyRecent = Object.values(mods).some(function(m) { return m.status === 'recent' || m.status === 'active'; });
    var anyData   = Object.values(mods).some(function(m) { return m.status !== 'none'; });
    var latestTs  = Math.max.apply(null, Object.values(mods).map(function(m){ return m.lastTs||0; }));
    if (anyRecent) activeCount++;
    if (!anyData || (latestTs > 0 && now - latestTs > 30*24*3600000)) deadCount++;
  });
  document.getElementById('s-active').textContent  = activeCount;
  document.getElementById('s-dead').textContent    = deadCount;
  document.getElementById('s-warnings').textContent = warnings.length;
}

function buildWarnings() {
  warnings = [];
  var cids = Object.keys(allCompanies);

  cids.forEach(function(cid) {
    var name = (allCompanies[cid]||{}).name || cid;
    var hd   = healthData[cid] || {};
    var mods = hd.modules || {};

    // Check: company has taxi data but no shift logs = drivers not using driver app
    if ((mods.taxi||{}).status !== 'none' && (mods.shifts||{}).status === 'none') {
      warnings.push({sev:'amber', msg: name + ': Has taxi trips but no driver shift logs — driver app may not be logging shifts', cid:cid});
    }
    // TM data but no TM config
    if ((mods.tm||{}).status !== 'none') {
      var hasTmConfig = window._tmConfig && Object.keys(window._tmConfig).length > 0;
      if (!hasTmConfig) {
        warnings.push({sev:'red', msg: name + ': Has TM trips but no council config set — subsidies may be calculated wrong', cid:cid});
      }
    }
    // Company suspended but still has activity
    if ((allCompanies[cid]||{}).status === 'suspended') {
      var anyActivity = Object.values(mods).some(function(m){ return m.status !== 'none'; });
      if (anyActivity) {
        warnings.push({sev:'amber', msg: name + ': Suspended company still showing data activity — review if intended', cid:cid});
      }
    }
    // No data at all = possibly never went live
    var anyData = Object.values(mods).some(function(m){ return m.status !== 'none'; });
    if (!anyData) {
      warnings.push({sev:'blue', msg: name + ': No activity recorded in any module — company may not be live yet', cid:cid});
    }
    // Payment not configured
    if (hd.paymentConfig === 'missing') {
      warnings.push({sev:'red', msg: name + ': No payment gateway configured — cannot process paid bookings', cid:cid});
    }
  });

  // Platform-level checks
  if (!window._tmCards || Object.keys(window._tmCards).length === 0) {
    warnings.push({sev:'red', msg: 'Platform: No Total Mobility passenger cards found — TM module cannot validate passengers', cid:null});
  }

  var warnCard = document.getElementById('warn-card');
  var warnList = document.getElementById('warn-list');
  if (!warnings.length) {
    warnCard.style.display = 'none';
    return;
  }
  warnCard.style.display = '';
  document.getElementById('warn-count').textContent = warnings.length + ' issue' + (warnings.length===1?'':'s') + ' found';
  warnList.innerHTML = warnings.map(function(w) {
    var icon = w.sev === 'red' ? '&#x1F6A8;' : w.sev === 'amber' ? '&#x26A0;&#xFE0F;' : '&#x2139;&#xFE0F;';
    var cls  = 'warn-' + w.sev;
    var link = w.cid ? ' <a href="SA-Clients.aspx?cid='+esc(w.cid)+'" style="font-size:11px;color:#1565C0">View company</a>' : '';
    return '<div class="warn-item '+cls+'"><span class="warn-icon">'+icon+'</span><span>'+esc(w.msg)+link+'</span></div>';
  }).join('');
}

function dotHtml(mod) {
  if (!mod) return dot('grey', '&mdash;', 'No check run');
  switch (mod.status) {
    case 'active':  return dot('blue',  '&#9679;', 'Active right now');
    case 'recent':  return dot('green', '&#10003;', 'Has data (within 30 days). Last: ' + fmtTs(mod.lastTs));
    case 'data':    return dot('green', '&#10003;', 'Has data. Last: ' + fmtTs(mod.lastTs));
    case 'old':     return dot('amber', '!',       'Data found but older than 30 days. Last: ' + fmtTs(mod.lastTs));
    case 'none':    return dot('red',   '&times;', 'No data found in Firebase');
    default:        return dot('grey',  '&mdash;', '');
  }
}
function dot(cls, char, title) {
  return '<span class="dot dot-'+cls+'" title="'+title+'">'+char+'</span>';
}
function fmtTs(ts) {
  if (!ts) return 'unknown';
  var d = ts < 1e12 ? ts * 1000 : ts;
  return new Date(d).toLocaleDateString('en-NZ', {timeZone: PLATFORM_TZ, day:'numeric', month:'short', year:'numeric'});
}

var _matrixData = [];

function renderMatrix() {
  var q = (document.getElementById('ph-search').value || '').toLowerCase();
  var cids = Object.keys(healthData);
  _matrixData = cids.map(function(cid) {
    return { cid: cid, name: (allCompanies[cid]||{}).name || cid, hd: healthData[cid] };
  }).sort(function(a,b){ return a.name.localeCompare(b.name); });

  var filtered = q ? _matrixData.filter(function(r){ return r.name.toLowerCase().includes(q) || r.cid.toLowerCase().includes(q); }) : _matrixData;

  if (!filtered.length) {
    document.getElementById('mh-tb').innerHTML = '<tr><td colspan="13" style="text-align:center;padding:30px;color:#aaa">No companies match filter.</td></tr>';
    return;
  }

  document.getElementById('mh-tb').innerHTML = filtered.map(function(r) {
    var mods = r.hd.modules || {};
    var pay  = r.hd.paymentConfig;
    var payDot = pay === 'configured' ? dot('green','&#10003;','Payment gateway configured')
               : pay === 'missing'    ? dot('red','&times;','No payment gateway')
               : dot('grey','&mdash;','Unknown');
    var lastTs = Math.max.apply(null, Object.values(mods).map(function(m){ return m.lastTs||0; }));
    var lastStr = lastTs > 0 ? fmtTs(lastTs) : '<span style="color:#ccc">—</span>';
    var status = (allCompanies[r.cid]||{}).status || '';
    var nameHtml = esc(r.name);
    if (status === 'suspended') nameHtml += ' <span style="font-size:10px;color:#C62828;background:#FFEBEE;padding:1px 5px;border-radius:8px">SUSPENDED</span>';
    return '<tr>' +
      '<td><a href="SA-Clients.aspx?cid='+esc(r.cid)+'" style="color:#1B5E20;text-decoration:none">'+nameHtml+'</a><br><span style="font-size:10px;color:#bbb">'+r.cid+'</span></td>' +
      '<td>' + dotHtml(mods.taxi)     + '</td>' +
      '<td>' + dotHtml(mods.dispatch) + '</td>' +
      '<td>' + dotHtml(mods.tm)       + '</td>' +
      '<td>' + dotHtml(mods.food)    + '</td>' +
      '<td>' + dotHtml(mods.freight) + '</td>' +
      '<td>' + dotHtml(mods.towing)  + '</td>' +
      '<td>' + dotHtml(mods.rental)  + '</td>' +
      '<td>' + dotHtml(mods.acc)     + '</td>' +
      '<td>' + dotHtml(mods.biz)     + '</td>' +
      '<td>' + dotHtml(mods.shifts)  + '</td>' +
      '<td>' + payDot + '</td>' +
      '<td style="font-size:11px;color:#888;white-space:nowrap">' + lastStr + '</td>' +
    '</tr>';
  }).join('');
}

function renderConfigTable() {
  var rows = Object.entries(allCompanies).sort(function(a,b){ return ((a[1].name||a[0]).localeCompare(b[1].name||b[0])); });
  document.getElementById('cfg-tb').innerHTML = rows.map(function(e) {
    var cid  = e[0];
    var comp = e[1];
    var name = comp.name || cid;
    var status = comp.status || 'active';

    // TM config: check if any council config references this company (or exists at all)
    var tmCfgCount = Object.keys(window._tmConfig||{}).length;
    var tmCfgHtml  = tmCfgCount > 0 ? '<span class="cfg-ok">&#10003; '+tmCfgCount+' council(s)</span>' : '<span class="cfg-miss">&#x2715; None</span>';

    // TM cards
    var tmCardCount = Object.keys(window._tmCards||{}).length;
    var tmCardHtml  = tmCardCount > 0 ? '<span class="cfg-ok">&#10003; '+tmCardCount+' cards</span>' : '<span class="cfg-miss">&#x2715; 0 cards</span>';

    // FD restaurants for this company
    var fdForCid = (window._fdRests||{})[cid];
    var fdCount  = fdForCid ? Object.keys(fdForCid).length : 0;
    var fdHtml   = fdCount > 0 ? '<span class="cfg-ok">&#10003; '+fdCount+' restaurant(s)</span>' : '<span style="color:#aaa">&mdash;</span>';

    // Business accounts
    var bizForCid = (window._bizAccAll||{})[cid];
    var bizCount  = bizForCid ? Object.keys(bizForCid).length : 0;
    var bizHtml   = bizCount > 0 ? '<span class="cfg-ok">&#10003; '+bizCount+' account(s)</span>' : '<span style="color:#aaa">&mdash;</span>';

    // ACC clients
    var accForCid = (window._accAll||{})[cid];
    var accCount  = accForCid ? Object.keys(accForCid).length : 0;
    var accHtml   = accCount > 0 ? '<span class="cfg-ok">&#10003; '+accCount+' client(s)</span>' : '<span style="color:#aaa">&mdash;</span>';

    // Drivers (from health data shifts)
    var hd = healthData[cid] || {};
    var shiftsStatus = (hd.modules||{}).shifts || {};
    var driversHtml = shiftsStatus.status !== 'none' && shiftsStatus.status
      ? '<span class="cfg-ok">&#10003; Has data</span>'
      : '<span class="cfg-miss">&#x2715; No shifts</span>';

    var statusHtml = status === 'suspended'
      ? '<span style="color:#C62828;font-weight:600">Suspended</span>'
      : '<span style="color:#2E7D32;font-weight:600">Active</span>';

    return '<tr>' +
      '<td><strong>'+esc(name)+'</strong><br><span style="font-size:10px;color:#bbb">'+cid+'</span></td>' +
      '<td>'+tmCfgHtml+'</td>' +
      '<td>'+tmCardHtml+'</td>' +
      '<td>'+fdHtml+'</td>' +
      '<td>'+bizHtml+'</td>' +
      '<td>'+accHtml+'</td>' +
      '<td>'+driversHtml+'</td>' +
      '<td>'+statusHtml+'</td>' +
    '</tr>';
  }).join('');
}

function exportCsv() {
  var rows = [['Company','CID','Taxi','TM','Food','Freight','Towing','Rental','ACC','Business Acc','Shifts','Payment Config','Last Activity']];
  _matrixData.forEach(function(r) {
    var mods = r.hd.modules || {};
    var lastTs = Math.max.apply(null, Object.values(mods).map(function(m){ return m.lastTs||0; }));
    rows.push([
      r.name, r.cid,
      (mods.taxi||{}).status||'none',
      (mods.tm||{}).status||'none',
      (mods.food||{}).status||'none',
      (mods.freight||{}).status||'none',
      (mods.towing||{}).status||'none',
      (mods.rental||{}).status||'none',
      (mods.acc||{}).status||'none',
      (mods.biz||{}).status||'none',
      (mods.shifts||{}).status||'none',
      r.hd.paymentConfig||'unknown',
      lastTs > 0 ? fmtTs(lastTs) : 'never'
    ]);
  });
  var csv = rows.map(function(r){ return r.map(function(c){ return '"'+(c||'').toString().replace(/"/g,'""')+'"'; }).join(','); }).join('\n');
  var a = document.createElement('a');
  a.href = URL.createObjectURL(new Blob([csv], {type:'text/csv'}));
  a.download = 'platform-health-' + _tzDateStr() + '.csv';
  a.click();
}

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
