<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Towing &mdash; BookaWaka Admin</title>
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
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});</script>
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#E65100;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-bar.dark{background:#BF360C}
.sa-bar.grey{background:#546E7A}
.sa-bar.green{background:#2E7D32}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#E65100;color:#fff}.sa-btn-p:hover{background:#BF360C}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-g{background:#2E7D32;color:#fff}.sa-btn-g:hover{background:#1B5E20}
.sa-btn-r{background:#C62828;color:#fff}.sa-btn-r:hover{background:#B71C1C}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32;display:block}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828;display:block}
.sa-ff label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:6px;font-size:13px;box-sizing:border-box;font-family:inherit}
.sa-ff input:focus,.sa-ff select:focus{outline:none;border-color:#E65100}
.set-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;padding:18px}
.set-section{border-bottom:1px solid #f5f5f5}
.set-section:last-child{border-bottom:none}
.set-section-hdr{padding:14px 18px;font-size:13px;font-weight:700;color:#E65100;background:#FFF3E0;display:flex;align-items:center;gap:6px}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#FFF3E0;padding:10px 14px;text-align:left;font-weight:700;color:#BF360C;border-bottom:2px solid #FFCCBC;white-space:nowrap}
.sa-tbl td{padding:10px 14px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFF8F5}
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;padding:18px}
.kpi-box{background:#FFF8F5;border-radius:8px;padding:16px 18px;border-left:4px solid #E65100;text-align:center}
.kpi-box.blue{border-left-color:#1565C0;background:#F0F7FF}
.kpi-box.green{border-left-color:#2E7D32;background:#F1F8E9}
.kpi-box.grey{border-left-color:#546E7A;background:#ECEFF1}
.kpi-box.red{border-left-color:#C62828;background:#FFEBEE}
.kpi-val{font-size:28px;font-weight:800;color:#E65100;line-height:1}
.kpi-box.blue .kpi-val{color:#1565C0}
.kpi-box.green .kpi-val{color:#2E7D32}
.kpi-box.grey .kpi-val{color:#546E7A}
.kpi-box.red .kpi-val{color:#C62828}
.kpi-lbl{font-size:11px;color:#90A4AE;margin-top:5px;font-weight:600;text-transform:uppercase}
.toggle-row{display:flex;align-items:center;gap:14px;padding:14px 18px;flex-wrap:wrap;border-bottom:1px solid #f5f5f5}
.toggle-row:last-child{border-bottom:none}
.toggle-label{font-size:13px;font-weight:600;color:#374151;flex:1;min-width:200px}
.toggle-label small{display:block;font-size:11px;font-weight:400;color:#9e9e9e;margin-top:2px}
.toggle-btn{min-width:80px;padding:7px 16px;border-radius:20px;border:none;cursor:pointer;font-size:13px;font-weight:700;transition:background .2s}
.co-card{display:flex;align-items:center;gap:14px;padding:14px 18px;border-bottom:1px solid #f5f5f5;flex-wrap:wrap}
.co-card:last-child{border-bottom:none}
.co-avatar{width:42px;height:42px;border-radius:50%;background:#E65100;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:15px;flex-shrink:0}
.co-info{flex:1;min-width:160px}
.co-name{font-weight:700;font-size:13px;color:#263238}
.co-sub{font-size:11px;color:#9e9e9e;margin-top:2px}
.filter-row{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:12px 18px;border-bottom:1px solid #f5f5f5}
.filter-row select,.filter-row input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px}
.status-dot{width:8px;height:8px;border-radius:50%;display:inline-block;margin-right:5px}
.dot-pending{background:#F57F17}.dot-assigned{background:#1565C0}.dot-enroute{background:#6A1B9A}.dot-completed{background:#2E7D32}.dot-cancelled{background:#C62828}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">&#128667; Towing &mdash; BookaWaka Admin</label></div>
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
    <li class="current_section" title="Towing"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Towing</span></a><ul>
      <li><a href="SA-Towing.aspx" style="font-weight:700;color:#E65100">&#9658; Towing Dashboard</a></li>
      <li><a href="SA-Towing.aspx#jobs">All Jobs</a></li>
      <li><a href="SA-Towing.aspx#config">Platform Config</a></li>
      <li><a href="/towing-portal" target="_blank">Owner Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Rental Cars"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE531;</i></span><span class="menu_title">Rental Cars</span></a><ul>
      <li><a href="SA-Rental.aspx">Rental Dashboard</a></li>
      <li><a href="/rental-portal" target="_blank">Owner Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Restaurants.aspx">Restaurants</a></li>
      <li><a href="FD-Orders.aspx">All Orders</a></li>
    </ul></li>
    <li class="current_section" title="Freight"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight</span></a><ul>
      <li><a href="FR-Orders.aspx">All Orders</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;color:#263238;margin:0 0 4px">&#128667; Towing Platform</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">Manage towing companies, jobs, commission, and platform-wide settings.</p>

<div id="tw-notice" class="sa-notice"></div>

<!-- KPI Row -->
<div class="sa-card">
  <div class="kpi-row">
    <div class="kpi-box"><div class="kpi-val" id="kpi-companies">—</div><div class="kpi-lbl">Companies</div></div>
    <div class="kpi-box blue"><div class="kpi-val" id="kpi-trucks">—</div><div class="kpi-lbl">Trucks</div></div>
    <div class="kpi-box" style="border-left-color:#F57F17;background:#FFF8E1"><div class="kpi-val" style="color:#F57F17" id="kpi-active">—</div><div class="kpi-lbl">Active Jobs</div></div>
    <div class="kpi-box green"><div class="kpi-val" id="kpi-completed">—</div><div class="kpi-lbl">Completed</div></div>
    <div class="kpi-box grey"><div class="kpi-val" id="kpi-insurance">—</div><div class="kpi-lbl">Insurance Jobs</div></div>
    <div class="kpi-box" style="border-left-color:#6A1B9A;background:#F3E5F5"><div class="kpi-val" style="color:#6A1B9A" id="kpi-commission">$—</div><div class="kpi-lbl">Commission (Stripe)</div></div>
    <div class="kpi-box" style="border-left-color:#00695C;background:#E0F2F1"><div class="kpi-val" style="color:#00695C" id="kpi-crosssell">—</div><div class="kpi-lbl">Taxi Cross-Sells</div></div>
  </div>
</div>

<!-- Analytics Charts -->
<div class="sa-card" id="analytics">
  <div class="sa-bar grey"><h3>&#128202; Analytics</h3>
    <button onclick="renderCharts()" class="sa-btn sa-btn-n" style="color:#fff;border-color:rgba(255,255,255,.3);background:rgba(255,255,255,.15);font-size:12px">&#8635; Refresh</button>
  </div>
  <div style="display:grid;grid-template-columns:2fr 1fr;border-bottom:1px solid #f0f0f0">
    <div style="padding:16px 18px;border-right:1px solid #f0f0f0">
      <div style="font-weight:700;font-size:11px;color:#546E7A;margin-bottom:10px;text-transform:uppercase;letter-spacing:.5px">Jobs — Last 30 Days</div>
      <canvas id="chart-trend" height="90"></canvas>
    </div>
    <div style="padding:16px 18px">
      <div style="font-weight:700;font-size:11px;color:#546E7A;margin-bottom:10px;text-transform:uppercase;letter-spacing:.5px">Payment Breakdown</div>
      <canvas id="chart-payment" height="180"></canvas>
    </div>
  </div>
  <div style="padding:16px 18px">
    <div style="font-weight:700;font-size:11px;color:#546E7A;margin-bottom:10px;text-transform:uppercase;letter-spacing:.5px">Jobs by Company</div>
    <canvas id="chart-company" height="60"></canvas>
  </div>
</div>

<!-- Platform Config -->
<div class="sa-card" id="config">
  <div class="sa-bar"><h3>&#9881; Platform Configuration</h3>
    <button onclick="savePlatformConfig()" class="sa-btn" style="background:rgba(255,255,255,.2);color:#fff;border:1px solid rgba(255,255,255,.4)">&#10003; Save Config</button>
  </div>
  <div class="set-section">
    <div class="set-section-hdr">&#128667; Towing Module</div>
    <div class="toggle-row">
      <div class="toggle-label">Platform Towing<small>Enable towing module across the platform</small></div>
      <button id="btn-enabled" class="toggle-btn" onclick="toggleConfig('enabled')" style="background:#ccc;color:#fff">Off</button>
    </div>
    <div class="toggle-row">
      <div class="toggle-label">Taxi Cross-Sell<small>Offer discounted taxi ride to stranded towing customers</small></div>
      <button id="btn-crosssell" class="toggle-btn" onclick="toggleConfig('crosssell')" style="background:#ccc;color:#fff">Off</button>
    </div>
  </div>
  <div class="set-section">
    <div class="set-section-hdr">&#128181; Commission &amp; Fees</div>
    <div class="set-grid sa-ff">
      <div><label>Stripe Commission % <small style="font-weight:400;color:#aaa">(Stripe-paid jobs)</small></label><input type="number" id="cfg-commission" min="0" max="50" step="0.5" placeholder="12"/></div>
      <div><label>Insurance Flat Fee ($) <small style="font-weight:400;color:#aaa">(per insurance job)</small></label><input type="number" id="cfg-insurance-fee" min="0" step="0.5" placeholder="12"/></div>
      <div><label>Taxi Cross-Sell Discount %</label><input type="number" id="cfg-crosssell-pct" min="0" max="100" step="1" placeholder="15"/></div>
    </div>
  </div>
</div>

<!-- Towing Companies -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#128667; Towing Companies</h3>
    <button onclick="loadAll()" class="sa-btn sa-btn-n" style="color:#fff;border-color:rgba(255,255,255,.3);background:rgba(255,255,255,.15)">&#8635; Refresh</button>
  </div>
  <div id="companies-list"><div style="padding:30px;text-align:center;color:#aaa">Loading&hellip;</div></div>
</div>

<!-- Set Portal Password -->
<div class="sa-card">
  <div class="sa-bar dark"><h3>&#128273; Set Owner Portal Password</h3></div>
  <div style="padding:18px" class="sa-ff">
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr auto;gap:12px;align-items:end;flex-wrap:wrap">
      <div><label>Company ID</label><input type="text" id="pw-cid" placeholder="e.g. 620611"/></div>
      <div><label>Company Name</label><input type="text" id="pw-name" placeholder="e.g. Acme Towing Ltd"/></div>
      <div><label>Email</label><input type="email" id="pw-email" placeholder="owner@example.com"/></div>
      <div><label>Password</label><input type="password" id="pw-pass" placeholder="Min 8 chars"/></div>
    </div>
    <div style="margin-top:12px">
      <button onclick="setPortalPassword()" class="sa-btn sa-btn-p">&#128273; Set Password &amp; Enable Access</button>
      <span id="pw-msg" style="margin-left:14px;font-size:12.5px"></span>
    </div>
  </div>
</div>

<!-- Unassigned Jobs -->
<div class="sa-card" id="unassigned">
  <div class="sa-bar dark"><h3>&#9888; Unassigned Tow Jobs <span id="unassigned-badge" style="background:rgba(255,255,255,.25);padding:2px 9px;border-radius:10px;font-size:12px;margin-left:8px;display:none"></span></h3>
    <div style="display:flex;align-items:center;gap:10px">
      <span id="unassigned-refreshed" style="font-size:11px;opacity:.65;white-space:nowrap"></span>
      <span style="font-size:11px;background:rgba(255,255,255,.18);padding:2px 8px;border-radius:10px;color:#FFCCBC">&#128257; Auto 30s</span>
      <button onclick="loadAll()" class="sa-btn sa-btn-n" style="color:#fff;border-color:rgba(255,255,255,.3);background:rgba(255,255,255,.15)">&#8635; Refresh</button>
    </div>
  </div>
  <div id="unassigned-wrap"><div style="padding:24px;text-align:center;color:#aaa">Loading&hellip;</div></div>
</div>

<!-- Assign Job Modal -->
<div id="assign-modal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:200;align-items:center;justify-content:center">
  <div style="background:#fff;border-radius:8px;width:500px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25);overflow:hidden">
    <div style="background:#E65100;color:#fff;padding:14px 20px;display:flex;align-items:center;justify-content:space-between">
      <strong style="font-size:14px">&#128667; Assign Job to Towing Company</strong>
      <button onclick="closeAssignModal()" style="background:none;border:none;color:#fff;font-size:20px;cursor:pointer">&times;</button>
    </div>
    <div style="padding:20px" class="sa-ff">
      <input type="hidden" id="assign-jobid"/>
      <div id="assign-job-summary" style="background:#FFF3E0;border-left:4px solid #E65100;padding:10px 14px;border-radius:4px;font-size:12.5px;color:#BF360C;margin-bottom:16px"></div>
      <div style="margin-bottom:14px"><label>Assign to Company *</label>
        <select id="assign-company"><option value="">— Select a towing company —</option></select>
      </div>
      <div><label>Note to Dispatcher (optional)</label>
        <textarea id="assign-note" rows="2" placeholder="Any special instructions for the towing company…" style="width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:5px;font-size:13px;font-family:inherit"></textarea>
      </div>
      <div id="assign-msg" style="margin-top:10px;font-size:12.5px"></div>
    </div>
    <div style="padding:14px 20px;border-top:1px solid #f0f0f0;display:flex;justify-content:flex-end;gap:10px">
      <button onclick="closeAssignModal()" class="sa-btn sa-btn-n">Cancel</button>
      <button onclick="confirmAssign()" class="sa-btn sa-btn-p">&#10003; Assign Job</button>
    </div>
  </div>
</div>

<!-- All Jobs -->
<div class="sa-card" id="jobs">
  <div class="sa-bar grey"><h3>&#128222; All Tow Jobs</h3></div>
  <div class="filter-row">
    <select id="f-status" onchange="renderJobs()"><option value="">All statuses</option><option value="pending">Pending</option><option value="assigned">Assigned</option><option value="enroute">En Route</option><option value="arrived">Arrived</option><option value="loading">Loading</option><option value="dropoff">To Drop-off</option><option value="completed">Completed</option><option value="cancelled">Cancelled</option></select>
    <select id="f-payment" onchange="renderJobs()"><option value="">All payment types</option><option value="stripe">Stripe</option><option value="insurance">Insurance</option><option value="thirdparty">Third Party</option><option value="cash">Cash</option></select>
    <select id="f-company" onchange="renderJobs()"><option value="">All companies</option></select>
    <input type="date" id="f-date" onchange="renderJobs()" style="font-size:12.5px"/>
    <button onclick="document.getElementById('f-status').value='';document.getElementById('f-payment').value='';document.getElementById('f-company').value='';document.getElementById('f-date').value='';renderJobs()" class="sa-btn sa-btn-n" style="font-size:12px">&#10005; Clear</button>
  </div>
  <div id="jobs-wrap"><div style="padding:30px;text-align:center;color:#aaa">Loading&hellip;</div></div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var db = firebase.database();
var allJobs = [];
var allUnassigned = [];
var allCompanies = {};
var twConfig = {};
var configToggles = { enabled: false, crosssell: false };

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDt(ts){ if(!ts) return '—'; return new Date(ts).toLocaleString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}); }
function fmtMoney(v){ return '$'+(parseFloat(v)||0).toFixed(2); }

function showNotice(msg, type){
  var el = document.getElementById('tw-notice');
  el.className = 'sa-notice '+(type||'ok');
  el.textContent = msg;
  el.style.display = 'block';
  if(type !== 'err') setTimeout(function(){ el.style.display='none'; }, 4000);
}

function loadAll(){
  Promise.all([
    _fbGet('bwConfig/towing').then(function(v){ return v||{}; }),
    _fbGet('towingPortalAccess').then(function(v){ return v||{}; }),
    _fbGet('towingFleet').then(function(v){ return v||{}; }),
    _fbGet('towingJobs').then(function(v){ return v||{}; }),
    _fbGet('towingJobs/unassigned').then(function(v){ return v||{}; })
  ]).then(function(results){
    twConfig = results[0];
    var access = results[1];
    var fleet = results[2];
    var jobsByCompany = results[3];
    var unassignedData = results[4];

    // Apply platform config
    configToggles.enabled = !!twConfig.enabled;
    configToggles.crosssell = !!twConfig.taxiCrossSellEnabled;
    document.getElementById('cfg-commission').value = twConfig.commissionRate || 12;
    document.getElementById('cfg-insurance-fee').value = twConfig.insuranceFlatFee || 12;
    document.getElementById('cfg-crosssell-pct').value = twConfig.taxiCrossSellDiscount || 15;
    updateToggleBtn('btn-enabled', configToggles.enabled);
    updateToggleBtn('btn-crosssell', configToggles.crosssell);

    // Build companies map
    allCompanies = {};
    Object.keys(access).forEach(function(cid){
      var a = access[cid];
      var trucks = fleet[cid] ? Object.keys(fleet[cid]).length : 0;
      allCompanies[cid] = { cid:cid, name:a.name||cid, email:a.email||'', active:a.active, trucks:trucks };
    });

    // Flatten jobs
    allJobs = [];
    Object.keys(jobsByCompany).forEach(function(cid){
      var cJobs = jobsByCompany[cid];
      Object.keys(cJobs).forEach(function(jid){
        allJobs.push(Object.assign({ _cid:cid, _jid:jid }, cJobs[jid]));
      });
    });
    allJobs.sort(function(a,b){ return (b.createdAt||0)-(a.createdAt||0); });

    // Count trucks across all companies
    var totalTrucks = 0;
    Object.values(fleet).forEach(function(cFleet){ totalTrucks += Object.keys(cFleet||{}).length; });

    // KPIs
    var active = allJobs.filter(function(j){ return ['pending','assigned','enroute','arrived','loading','dropoff'].indexOf(j.status||'pending')>-1; });
    var completed = allJobs.filter(function(j){ return j.status==='completed'; });
    var insurance = allJobs.filter(function(j){ return j.paymentType==='insurance'||j.paymentType==='thirdparty'; });
    var crossSells = allJobs.filter(function(j){ return j.taxiCrossSellUsed; });
    var commission = completed.filter(function(j){ return j.paymentType==='stripe'; }).reduce(function(s,j){ return s+(parseFloat(j.commission)||0); },0);
    document.getElementById('kpi-companies').textContent = Object.keys(allCompanies).length;
    document.getElementById('kpi-trucks').textContent = totalTrucks;
    document.getElementById('kpi-active').textContent = active.length;
    document.getElementById('kpi-completed').textContent = completed.length;
    document.getElementById('kpi-insurance').textContent = insurance.length;
    document.getElementById('kpi-commission').textContent = fmtMoney(commission);
    document.getElementById('kpi-crosssell').textContent = crossSells.length;

    // Unassigned jobs
    allUnassigned = Object.keys(unassignedData).filter(function(k){ return k !== 'unassigned'; }).map(function(jid){
      return Object.assign({_jid:jid}, unassignedData[jid]);
    });
    allUnassigned.sort(function(a,b){ return (b.createdAt||0)-(a.createdAt||0); });

    // Populate assign-company dropdown
    var sel = document.getElementById('assign-company');
    sel.innerHTML = '<option value="">— Select a towing company —</option>';
    Object.values(allCompanies).forEach(function(c){
      sel.innerHTML += '<option value="'+esc(c.cid)+'">'+esc(c.name)+'</option>';
    });

    renderCompanies();
    renderJobs();
    renderUnassigned();
    populateCompanyFilter();
    renderCharts();
  }).catch(function(e){
    showNotice('Error loading data: '+e.message,'err');
  });
}

function renderUnassigned(){
  var wrap = document.getElementById('unassigned-wrap');
  var badge = document.getElementById('unassigned-badge');
  if(!allUnassigned.length){
    wrap.innerHTML='<div style="padding:24px;text-align:center;color:#aaa">&#10003; No unassigned jobs — all clear.</div>';
    badge.style.display='none';
    return;
  }
  badge.textContent = allUnassigned.length + ' pending';
  badge.style.display='inline';
  var html='<table class="tw-tbl"><thead><tr><th>Job ID</th><th>Customer</th><th>Pickup</th><th>Drop-off</th><th>Vehicle</th><th>Problem</th><th>Payment</th><th>Received</th><th></th></tr></thead><tbody>';
  allUnassigned.forEach(function(j){
    html+='<tr>'+
      '<td><code style="font-size:11px">'+esc(j.jobId||j._jid)+'</code></td>'+
      '<td><strong>'+esc(j.customerName)+'</strong><br><span style="font-size:11px;color:#888">'+esc(j.customerPhone)+'</span></td>'+
      '<td style="max-width:160px;font-size:12px">'+esc(j.pickup)+'</td>'+
      '<td style="max-width:140px;font-size:12px">'+esc(j.dropoff)+'</td>'+
      '<td style="font-size:12px">'+esc(j.vehicleYear+' '+j.vehicleMake+' '+j.vehicleModel)+'<br><span style="color:#888">'+esc(j.vehicleRego||'—')+'</span></td>'+
      '<td><span style="font-size:12px;font-weight:600">'+esc(j.problem)+'</span>'+(j.problemNotes?'<br><span style="font-size:11px;color:#888">'+esc(j.problemNotes)+'</span>':'')+'</td>'+
      '<td><span class="job-badge '+esc(j.paymentType)+'">'+esc((j.paymentType||'').toUpperCase())+'</span></td>'+
      '<td style="font-size:11px;white-space:nowrap">'+fmtDt(j.createdAt)+'</td>'+
      '<td><button onclick="openAssignModal(\''+esc(j._jid)+'\')" class="sa-btn sa-btn-p" style="white-space:nowrap;font-size:12px">&#128667; Assign</button></td>'+
    '</tr>';
  });
  html+='</tbody></table>';
  wrap.innerHTML=html;
}

function openAssignModal(jobId){
  var j = allUnassigned.find(function(x){ return x._jid===jobId; });
  if(!j) return;
  document.getElementById('assign-jobid').value = jobId;
  document.getElementById('assign-job-summary').innerHTML =
    '<strong>'+esc(j.customerName)+'</strong> &mdash; '+esc(j.vehicleMake+' '+j.vehicleModel+(j.vehicleRego?' ('+j.vehicleRego+')':''))+
    '<br>&#128205; <strong>From:</strong> '+esc(j.pickup)+'<br>&#128205; <strong>To:</strong> '+esc(j.dropoff)+
    '<br>&#128296; '+esc(j.problem)+(j.problemNotes?' &mdash; '+esc(j.problemNotes):'')+
    '<br><span style="font-size:11px;color:#888">Payment: <strong>'+esc((j.paymentType||'').toUpperCase())+'</strong> &middot; Received: '+fmtDt(j.createdAt)+'</span>';
  document.getElementById('assign-note').value='';
  document.getElementById('assign-msg').textContent='';
  var modal = document.getElementById('assign-modal');
  modal.style.display='flex';
}

function closeAssignModal(){
  document.getElementById('assign-modal').style.display='none';
}

function confirmAssign(){
  var jobId = document.getElementById('assign-jobid').value;
  var cid = document.getElementById('assign-company').value;
  var note = document.getElementById('assign-note').value.trim();
  var msgEl = document.getElementById('assign-msg');
  if(!cid){ msgEl.innerHTML='<span style="color:#C62828">Please select a towing company.</span>'; return; }
  msgEl.innerHTML='<span style="color:#888">Assigning&hellip;</span>';
  fetch('/api/towing-assign-job', {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({ jobId:jobId, cid:cid, note:note })
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){
      closeAssignModal();
      showNotice('Job assigned to '+esc(d.companyName||cid)+'!','ok');
      loadAll();
    } else {
      msgEl.innerHTML='<span style="color:#C62828">Error: '+esc(d.error||'Unknown error')+'</span>';
    }
  }).catch(function(e){
    msgEl.innerHTML='<span style="color:#C62828">Network error: '+esc(e.message)+'</span>';
  });
}

function updateToggleBtn(btnId, on){
  var btn = document.getElementById(btnId);
  if(!btn) return;
  btn.textContent = on ? 'On' : 'Off';
  btn.style.background = on ? '#2E7D32' : '#ccc';
}

function toggleConfig(key){
  configToggles[key] = !configToggles[key];
  updateToggleBtn(key==='enabled'?'btn-enabled':'btn-crosssell', configToggles[key]);
}

function savePlatformConfig(){
  var data = {
    enabled: configToggles.enabled,
    commissionRate: parseFloat(document.getElementById('cfg-commission').value)||12,
    insuranceFlatFee: parseFloat(document.getElementById('cfg-insurance-fee').value)||12,
    taxiCrossSellEnabled: configToggles.crosssell,
    taxiCrossSellDiscount: parseFloat(document.getElementById('cfg-crosssell-pct').value)||15,
    updatedAt: Date.now()
  };
  db.ref('bwConfig/towing').set(data).then(function(){
    showNotice('Platform config saved.','ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function renderCompanies(){
  var wrap = document.getElementById('companies-list');
  var cids = Object.keys(allCompanies);
  if(!cids.length){ wrap.innerHTML='<div style="padding:24px;text-align:center;color:#aaa">No towing companies set up yet. Use the password form above to add one.</div>'; return; }
  wrap.innerHTML = cids.map(function(cid){
    var c = allCompanies[cid];
    var cJobs = allJobs.filter(function(j){ return j._cid===cid; });
    var active = cJobs.filter(function(j){ return ['pending','assigned','enroute','arrived','loading','dropoff'].indexOf(j.status||'pending')>-1; }).length;
    var total = cJobs.length;
    return '<div class="co-card">'
      +'<div class="co-avatar">'+(esc(c.name||cid).charAt(0).toUpperCase())+'</div>'
      +'<div class="co-info">'
        +'<div class="co-name">'+esc(c.name||cid)+'</div>'
        +'<div class="co-sub">CID: '+esc(cid)+' &bull; '+c.trucks+' truck'+(c.trucks!==1?'s':'')+' &bull; '+total+' jobs &bull; '+active+' active</div>'
        +'<div class="co-sub">'+esc(c.email||'—')+'</div>'
      +'</div>'
      +'<div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">'
        +'<div class="sa-ff" style="display:flex;gap:6px;align-items:center">'
          +'<label style="margin:0;font-size:12px;white-space:nowrap">Commission %</label>'
          +'<input type="number" id="comm-'+esc(cid)+'" value="'+(c.commissionOverride||'')+'" placeholder="default" style="width:80px;padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12px"/>'
          +'<button onclick="saveCommission(\''+esc(cid)+'\')" class="sa-btn sa-btn-p" style="padding:5px 10px;font-size:12px">Save</button>'
        +'</div>'
        +'<a href="/towing-portal?cid='+esc(cid)+'" target="_blank" class="sa-btn sa-btn-n" style="font-size:12px">&#128279; Portal</a>'
        +'<span style="background:'+(c.active?'#E8F5E9':'#FFEBEE')+';color:'+(c.active?'#2E7D32':'#C62828')+';padding:3px 10px;border-radius:12px;font-size:11px;font-weight:700">'+(c.active?'Active':'Inactive')+'</span>'
      +'</div>'
    +'</div>';
  }).join('');
}

function saveCommission(cid){
  var val = parseFloat(document.getElementById('comm-'+cid).value);
  var data = isNaN(val) ? null : val;
  db.ref('towingConfig/'+cid+'/commissionOverride').set(data).then(function(){
    showNotice('Commission override saved for '+cid,'ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function populateCompanyFilter(){
  var sel = document.getElementById('f-company');
  sel.innerHTML = '<option value="">All companies</option>';
  Object.values(allCompanies).forEach(function(c){
    sel.innerHTML += '<option value="'+esc(c.cid)+'">'+esc(c.name)+'</option>';
  });
}

function statusBadge(s){
  var map = {
    pending:   '<span style="background:#FFF3E0;color:#E65100;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">Pending</span>',
    assigned:  '<span style="background:#E3F2FD;color:#1565C0;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">Assigned</span>',
    enroute:   '<span style="background:#F3E5F5;color:#6A1B9A;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">En Route</span>',
    arrived:   '<span style="background:#E8EAF6;color:#283593;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">Arrived</span>',
    loading:   '<span style="background:#E0F7FA;color:#006064;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">Loading</span>',
    dropoff:   '<span style="background:#FFF8E1;color:#F57F17;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">To Drop-off</span>',
    completed: '<span style="background:#E8F5E9;color:#2E7D32;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">&#10003; Completed</span>',
    cancelled: '<span style="background:#FFEBEE;color:#C62828;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">&#10007; Cancelled</span>'
  };
  return map[s||'pending'] || '<span style="background:#f5f5f5;color:#555;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">'+esc(s||'—')+'</span>';
}

function paymentBadge(p){
  var map = {
    stripe:     '<span style="background:#E8F5E9;color:#2E7D32;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">&#128179; Stripe</span>',
    insurance:  '<span style="background:#E3F2FD;color:#1565C0;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">&#127962; Insurance</span>',
    thirdparty: '<span style="background:#FFF3E0;color:#E65100;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">&#128104;&#8205;&#128665; 3rd Party</span>',
    cash:       '<span style="background:#F3E5F5;color:#6A1B9A;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700">&#128181; Cash</span>'
  };
  return map[p||''] || '<span style="background:#f5f5f5;color:#555;padding:2px 9px;border-radius:10px;font-size:11px">'+esc(p||'—')+'</span>';
}

function renderJobs(){
  var statusF = document.getElementById('f-status').value;
  var paymentF = document.getElementById('f-payment').value;
  var companyF = document.getElementById('f-company').value;
  var dateF = document.getElementById('f-date').value;
  var list = allJobs.filter(function(j){
    if(statusF && (j.status||'pending')!==statusF) return false;
    if(paymentF && (j.paymentType||'')!==paymentF) return false;
    if(companyF && j._cid!==companyF) return false;
    if(dateF){
      var d = new Date(j.createdAt||0).toISOString().slice(0,10);
      if(d!==dateF) return false;
    }
    return true;
  });
  var wrap = document.getElementById('jobs-wrap');
  if(!list.length){ wrap.innerHTML='<div style="padding:28px;text-align:center;color:#aaa;font-style:italic">No jobs match your filter.</div>'; return; }
  var rows = list.map(function(j){
    var co = allCompanies[j._cid];
    return '<tr>'
      +'<td style="font-family:monospace;font-size:11.5px;color:#888">'+esc(j._jid||'—')+'</td>'
      +'<td style="font-weight:600;font-size:12px">'+esc((co&&co.name)||j._cid)+'</td>'
      +'<td style="font-weight:600">'+esc(j.customerName||'—')+'</td>'
      +'<td style="font-size:12px">'+esc(j.customerPhone||'—')+'</td>'
      +'<td style="font-size:12px;max-width:160px">'+esc(j.pickup||'—')+'</td>'
      +'<td style="font-size:12px;max-width:140px">'+esc(j.dropoff||'—')+'</td>'
      +'<td style="font-size:12px">'+esc((j.vehicleMake||'')+(j.vehicleModel?' '+j.vehicleModel:''))+'</td>'
      +'<td>'+paymentBadge(j.paymentType)+'</td>'
      +'<td>'+statusBadge(j.status)+'</td>'
      +'<td style="font-size:11px;color:#888;white-space:nowrap">'+fmtDt(j.createdAt)+'</td>'
      +'<td style="font-size:12px;color:#2E7D32;font-weight:700">'+(j.totalEstimate?fmtMoney(j.totalEstimate):'—')+'</td>'
      +'<td style="font-size:11px">'+(j.taxiCrossSellUsed?'<span style="background:#E0F2F1;color:#00695C;padding:2px 7px;border-radius:10px;font-size:11px;font-weight:700">&#128661; Taxi booked</span>':'—')+'</td>'
    +'</tr>';
  }).join('');
  wrap.innerHTML = '<div style="overflow-x:auto"><table class="sa-tbl"><thead><tr>'
    +'<th>Job ID</th><th>Company</th><th>Customer</th><th>Phone</th><th>Pickup</th><th>Drop-off</th><th>Vehicle</th><th>Payment</th><th>Status</th><th>Date</th><th>Estimate</th><th>Cross-sell</th>'
    +'</tr></thead><tbody>'+rows+'</tbody></table></div>';
}

function setPortalPassword(){
  var cid = document.getElementById('pw-cid').value.trim();
  var name = document.getElementById('pw-name').value.trim();
  var email = document.getElementById('pw-email').value.trim().toLowerCase();
  var pass = document.getElementById('pw-pass').value;
  var msg = document.getElementById('pw-msg');
  if(!cid||!name||!email||!pass){ msg.style.color='#C62828'; msg.textContent='All fields required.'; return; }
  if(pass.length<8){ msg.style.color='#C62828'; msg.textContent='Password must be at least 8 characters.'; return; }
  msg.style.color='#888'; msg.textContent='Saving…';
  fetch('/api/set-towing-password', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({companyId:cid, name:name, email:email, password:pass})
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){ msg.style.color='#2E7D32'; msg.textContent='&#10003; Access granted. Portal: '+window.location.protocol+'//'+window.location.host+'/towing-portal'; loadAll(); }
    else { msg.style.color='#C62828'; msg.textContent='Error: '+(d.error||'Unknown'); }
  }).catch(function(e){ msg.style.color='#C62828'; msg.textContent='Network error.'; });
}

var _charts = {};
function renderCharts(){
  if(typeof Chart === 'undefined') return;
  var allJobsCombined = allJobs.concat(allUnassigned);

  // 1. Jobs trend — last 30 days
  var now = Date.now();
  var days = {};
  for(var i=29;i>=0;i--){
    var d=new Date(now - i*864e5);
    var key=d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')+'-'+String(d.getDate()).padStart(2,'0');
    days[key]=0;
  }
  allJobsCombined.forEach(function(j){
    var d=new Date(j.createdAt||0);
    var key=d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')+'-'+String(d.getDate()).padStart(2,'0');
    if(Object.prototype.hasOwnProperty.call(days,key)) days[key]++;
  });
  var trendLabels=Object.keys(days).map(function(k){ var d=new Date(k+'T12:00:00'); return (d.getMonth()+1)+'/'+(d.getDate()); });
  var trendData=Object.values(days);
  if(_charts.trend) _charts.trend.destroy();
  var ctx1=document.getElementById('chart-trend');
  if(ctx1) _charts.trend=new Chart(ctx1,{
    type:'line',
    data:{labels:trendLabels,datasets:[{label:'Jobs',data:trendData,borderColor:'#E65100',backgroundColor:'rgba(230,81,0,.12)',tension:.35,pointRadius:2,fill:true}]},
    options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{stepSize:1,precision:0}},x:{ticks:{maxTicksLimit:10,font:{size:10}}}}}
  });

  // 2. Payment breakdown doughnut
  var payCount={stripe:0,insurance:0,thirdparty:0,cash:0};
  allJobsCombined.forEach(function(j){ var p=j.paymentType||'cash'; if(Object.prototype.hasOwnProperty.call(payCount,p)) payCount[p]++; });
  if(_charts.payment) _charts.payment.destroy();
  var ctx2=document.getElementById('chart-payment');
  if(ctx2) _charts.payment=new Chart(ctx2,{
    type:'doughnut',
    data:{labels:['Stripe','Insurance','3rd Party','Cash'],datasets:[{data:[payCount.stripe,payCount.insurance,payCount.thirdparty,payCount.cash],backgroundColor:['#2E7D32','#1565C0','#E65100','#6A1B9A'],borderWidth:2,borderColor:'#fff'}]},
    options:{responsive:true,plugins:{legend:{position:'bottom',labels:{font:{size:11},boxWidth:12}}}}
  });

  // 3. Jobs by company bar
  var coNames=[],coJobCounts=[];
  Object.values(allCompanies).forEach(function(c){
    var cnt=allJobs.filter(function(j){ return j._cid===c.cid; }).length;
    coNames.push(c.name||c.cid);
    coJobCounts.push(cnt);
  });
  if(_charts.company) _charts.company.destroy();
  var ctx3=document.getElementById('chart-company');
  if(ctx3 && coNames.length){
    _charts.company=new Chart(ctx3,{
      type:'bar',
      data:{labels:coNames,datasets:[{label:'Total Jobs',data:coJobCounts,backgroundColor:'#E65100',borderRadius:4}]},
      options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{stepSize:1,precision:0}},x:{ticks:{font:{size:11}}}}}
    });
  } else if(ctx3){
    ctx3.parentElement.innerHTML='<div style="text-align:center;color:#aaa;padding:16px;font-size:13px">No companies set up yet.</div>';
  }
}

var _autoRefreshTimer = null;

function loadUnassignedOnly(){
  _fbGet('towingJobs/unassigned').then(function(data){
    data = data||{};
    var newList = Object.keys(data).filter(function(k){ return k !== 'unassigned'; }).map(function(jid){
      return Object.assign({_jid:jid}, data[jid]);
    });
    newList.sort(function(a,b){ return (b.createdAt||0)-(a.createdAt||0); });
    var prevCount = allUnassigned.length;
    allUnassigned = newList;
    renderUnassigned();
    renderCharts();
    var el = document.getElementById('unassigned-refreshed');
    if(el) el.textContent = 'Updated '+new Date().toLocaleTimeString('en-NZ',{hour:'2-digit',minute:'2-digit',second:'2-digit'});
    if(newList.length > prevCount){
      var diff = newList.length - prevCount;
      showNotice('\u26a0 '+diff+' new unassigned tow job'+(diff>1?'s':'')+' received!','warn');
    }
  }).catch(function(e){ console.warn('[auto-refresh]',e.message); });
}

window._fbOnLogin = function(){
  loadAll();
  if(_autoRefreshTimer) clearInterval(_autoRefreshTimer);
  _autoRefreshTimer = setInterval(loadUnassignedOnly, 30000);
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
