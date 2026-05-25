<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>ACC Clients &mdash; BookaWaka Admin</title>
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
<script>firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});</script>
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#E65100;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-bar.blue{background:#1565C0}
.sa-bar.green{background:#2E7D32}
.sa-bar.purple{background:#4527A0}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#E65100;color:#fff}.sa-btn-p:hover{background:#BF360C}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}.sa-btn-n:hover{background:#eee}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32;display:block}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828;display:block}
.sa-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00;display:block}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#FFF3E0;padding:10px 14px;text-align:left;font-weight:700;color:#BF360C;border-bottom:2px solid #FFCCBC;white-space:nowrap}
.sa-tbl td{padding:9px 14px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFF8F5}
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;padding:18px}
.kpi-box{background:#FFF8F5;border-radius:8px;padding:16px 18px;border-left:4px solid #E65100;text-align:center}
.kpi-box.blue{border-left-color:#1565C0;background:#F0F7FF}
.kpi-box.green{border-left-color:#2E7D32;background:#F1F8E9}
.kpi-box.grey{border-left-color:#546E7A;background:#ECEFF1}
.kpi-box.purple{border-left-color:#4527A0;background:#EDE7F6}
.kpi-box.red{border-left-color:#C62828;background:#FFEBEE}
.kpi-val{font-size:28px;font-weight:800;color:#E65100;line-height:1}
.kpi-box.blue .kpi-val{color:#1565C0}
.kpi-box.green .kpi-val{color:#2E7D32}
.kpi-box.grey .kpi-val{color:#546E7A}
.kpi-box.purple .kpi-val{color:#4527A0}
.kpi-box.red .kpi-val{color:#C62828}
.kpi-lbl{font-size:11px;color:#90A4AE;margin-top:5px;font-weight:600;text-transform:uppercase}
.filter-row{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:12px 18px;border-bottom:1px solid #f5f5f5}
.filter-row select,.filter-row input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px}
.badge{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700}
.badge-active{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-expired{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.badge-upcoming{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.badge-none{background:#ECEFF1;color:#546E7A;border:1px solid #CFD8DC}
.badge-wav{background:#EDE7F6;color:#4527A0;border:1px solid #CE93D8}
.cid-badge{font-family:monospace;background:#FFF3E0;color:#E65100;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700}
.claim-badge{font-family:monospace;background:#EDE7F6;color:#4527A0;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700}
.sa-empty{padding:40px;text-align:center;color:#bbb;font-size:13px}
.po-sub{font-size:11px;color:#9e9e9e;margin-top:2px}
.trips-bar-wrap{background:#f5f5f5;border-radius:4px;height:6px;width:80px;display:inline-block;vertical-align:middle;margin-left:6px;overflow:hidden}
.trips-bar{height:6px;border-radius:4px;background:#2E7D32;transition:width .3s}
.trips-bar.warn{background:#F57F17}
.trips-bar.danger{background:#C62828}
.expand-btn{background:none;border:none;cursor:pointer;color:#E65100;font-size:12px;font-weight:600;padding:2px 8px;border-radius:4px}
.expand-btn:hover{background:#FFF3E0}
.po-detail-row{display:none}
.po-detail-row.open{display:table-row}
.po-table{width:100%;border-collapse:collapse;font-size:12px;margin:0}
.po-table th{background:#F3E5F5;padding:7px 12px;font-weight:700;color:#4527A0;text-align:left;white-space:nowrap}
.po-table td{padding:7px 12px;border-bottom:1px solid #f5f5f5}
.po-table tr:last-child td{border-bottom:none}
.row-action{background:none;border:1px solid #e0e0e0;border-radius:4px;padding:3px 7px;cursor:pointer;font-size:11px;color:#555;margin-right:3px}
.row-action:hover{background:#FFF3E0;border-color:#FFCCBC;color:#E65100}
.row-action.danger:hover{background:#FFEBEE;border-color:#FFCDD2;color:#C62828}
.pct-badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7;font-family:monospace}
.pct-badge.partial{background:#FFF8E1;color:#E65100;border-color:#FFE082}
.pct-badge.zero{background:#FFEBEE;color:#C62828;border-color:#FFCDD2}
.acc-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:9000;align-items:flex-start;justify-content:center;padding:40px 16px;overflow-y:auto}
.acc-modal-bg.open{display:flex}
.acc-modal{background:#fff;border-radius:8px;max-width:640px;width:100%;box-shadow:0 8px 28px rgba(0,0,0,.25)}
.acc-modal-head{background:#E65100;color:#fff;padding:13px 18px;border-radius:8px 8px 0 0;display:flex;align-items:center;justify-content:space-between}
.acc-modal-head h3{margin:0;font-size:15px;font-weight:600}
.acc-modal-head .close{background:none;border:none;color:#fff;font-size:22px;cursor:pointer;line-height:1}
.acc-modal-body{padding:18px}
.acc-modal-body .row{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px}
.acc-modal-body .row.single{grid-template-columns:1fr}
.acc-modal-body label{display:block;font-size:12px;font-weight:700;color:#555;margin-bottom:4px}
.acc-modal-body input[type=text],.acc-modal-body input[type=number],.acc-modal-body input[type=date],.acc-modal-body input[type=email],.acc-modal-body select,.acc-modal-body textarea{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.acc-modal-body textarea{min-height:60px;font-family:inherit}
.acc-modal-body .hint{font-size:11px;color:#9e9e9e;margin-top:3px}
.acc-modal-foot{padding:14px 18px;border-top:1px solid #f0f0f0;display:flex;gap:8px;justify-content:flex-end}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">&#127973; ACC Clients &mdash; BookaWaka Admin</label></div>
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
    <li class="current_section" title="Total Mobility"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8CC;</i></span><span class="menu_title">Total Mobility</span></a><ul>
      <li><a href="TM-Council-Config.aspx">Council Config</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
      <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
      <li><a href="TM-Settings.aspx">TM Settings</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Restaurants.aspx">Restaurants</a></li>
      <li><a href="FD-Orders.aspx">All Orders</a></li>
      <li><a href="FD-Payouts.aspx">Payouts</a></li>
      <li><a href="FD-Reports.aspx">Reports</a></li>
      <li><a href="FD-Commission.aspx">Commission Rates</a></li>
    </ul></li>
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Orders.aspx">All Orders</a></li>
      <li><a href="FR-Payouts.aspx">Payouts</a></li>
      <li><a href="FR-Reports.aspx">Reports</a></li>
      <li><a href="FR-Commission.aspx">Commission Rates</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-OwnerGroups.aspx">Owner Groups</a></li>
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
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="SA-Registrations.aspx">Registrations</a></li>
      <li><a href="SA-Alerts.aspx">System Alerts</a></li>
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
      <li><a href="SA-Broadcast.aspx">Broadcast</a></li>
      <li><a href="SA-Sessions.aspx">Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx">Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx" style="font-weight:700;color:#E65100">&#9658; ACC Clients</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#127973; ACC Clients — Platform Overview</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">
  HQ view of all ACC clients and their purchase orders across every company. Supplier ID: <strong>VEND-VAI714</strong>. Subsidy % is what the council/ACC covers — the passenger pays the remainder by Account, ACC claim or any other allowed method. Use <em>+ Add</em> to create, or the pencil to edit.
</p>

<div id="sa-notice" style="display:none" class="sa-notice"></div>

<!-- KPIs -->
<div class="sa-card">
  <div class="kpi-row">
    <div class="kpi-box"><div class="kpi-val" id="kpi-clients">—</div><div class="kpi-lbl">Total Clients</div></div>
    <div class="kpi-box blue"><div class="kpi-val" id="kpi-pos">—</div><div class="kpi-lbl">Total POs</div></div>
    <div class="kpi-box green"><div class="kpi-val" id="kpi-active-pos">—</div><div class="kpi-lbl">Active POs</div></div>
    <div class="kpi-box red"><div class="kpi-val" id="kpi-expired">—</div><div class="kpi-lbl">Expired POs</div></div>
    <div class="kpi-box purple"><div class="kpi-val" id="kpi-wav">—</div><div class="kpi-lbl">WAV Required</div></div>
    <div class="kpi-box grey"><div class="kpi-val" id="kpi-companies">—</div><div class="kpi-lbl">Companies</div></div>
  </div>
</div>

<!-- Tabs -->
<div class="sa-card">
  <div style="display:flex;border-bottom:2px solid #f0f0f0">
    <button class="tab-btn active" onclick="switchTab('clients')" id="tab-clients" style="padding:12px 20px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:700;color:#E65100;border-bottom:2px solid #E65100;margin-bottom:-2px">ACC Clients</button>
    <button class="tab-btn" onclick="switchTab('pos')" id="tab-pos" style="padding:12px 20px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:600;color:#9e9e9e">Purchase Orders</button>
  </div>

  <!-- Clients tab -->
  <div id="view-clients">
    <div class="filter-row">
      <input id="f-search-c" type="text" placeholder="Search name, claim #, phone…" style="min-width:220px" oninput="applyClientFilter()"/>
      <select id="f-company-c" onchange="applyClientFilter()"><option value="">All Companies</option></select>
      <select id="f-wav" onchange="applyClientFilter()">
        <option value="">All Clients</option>
        <option value="yes">WAV Required</option>
        <option value="no">No WAV</option>
      </select>
      <button class="sa-btn sa-btn-p" style="font-size:12px;margin-left:auto" onclick="openClientModal(null)">&#43; Add Client</button>
      <button class="sa-btn" style="background:rgba(230,81,0,.1);color:#E65100;border:1px solid #FFCCBC;font-size:12px" onclick="exportClientsCsv()">&#8659; Export CSV</button>
      <button class="sa-btn sa-btn-n" style="font-size:12px" onclick="loadData()">&#8635; Refresh</button>
      <span id="f-count-c" style="font-size:12px;color:#9e9e9e"></span>
    </div>
    <div style="overflow-x:auto">
      <div class="sa-empty" id="clients-loading">Loading ACC clients…</div>
      <table class="sa-tbl" id="clients-tbl" style="display:none">
        <thead>
          <tr>
            <th></th>
            <th>Claim #</th>
            <th>Client Name</th>
            <th>Company</th>
            <th>Phone</th>
            <th>Service Code</th>
            <th>WAV</th>
            <th>Active PO</th>
            <th>Subsidy %</th>
            <th>Trips Remaining</th>
            <th>PO Expires</th>
            <th></th>
          </tr>
        </thead>
        <tbody id="clients-body"></tbody>
      </table>
      <div class="sa-empty" id="clients-empty" style="display:none">No ACC clients found.</div>
    </div>
  </div>

  <!-- POs tab -->
  <div id="view-pos" style="display:none">
    <div class="filter-row">
      <input id="f-search-p" type="text" placeholder="Search PO #, claim #, manager, branch…" style="min-width:220px" oninput="applyPoFilter()"/>
      <select id="f-company-p" onchange="applyPoFilter()"><option value="">All Companies</option></select>
      <select id="f-po-status" onchange="applyPoFilter()">
        <option value="">All Statuses</option>
        <option value="active">Active</option>
        <option value="expired">Expired</option>
        <option value="upcoming">Upcoming</option>
      </select>
      <button class="sa-btn" style="background:rgba(230,81,0,.1);color:#E65100;border:1px solid #FFCCBC;font-size:12px;margin-left:auto" onclick="exportPosCsv()">&#8659; Export CSV</button>
      <span id="f-count-p" style="font-size:12px;color:#9e9e9e"></span>
      <span style="font-size:11px;color:#9e9e9e;flex-basis:100%;margin-top:4px">Tip: open a client in the <em>ACC Clients</em> tab and use <em>+ PO</em> to add a purchase order for that client.</span>
    </div>
    <div style="overflow-x:auto">
      <div class="sa-empty" id="pos-loading" style="display:none">Loading…</div>
      <table class="sa-tbl" id="pos-tbl" style="display:none">
        <thead>
          <tr>
            <th>PO #</th>
            <th>Claim #</th>
            <th>Client Name</th>
            <th>Company</th>
            <th>Date From</th>
            <th>Date To</th>
            <th>Qty</th>
            <th>Used</th>
            <th>Remaining</th>
            <th>Max $/Trip</th>
            <th>Manager</th>
            <th>Branch</th>
            <th>Subsidy %</th>
            <th>Status</th>
            <th></th>
          </tr>
        </thead>
        <tbody id="pos-body"></tbody>
      </table>
      <div class="sa-empty" id="pos-empty" style="display:none">No purchase orders found.</div>
    </div>
  </div>
</div>

</div>
</div></div>

<script src="assets/js/tm-helpers.js"></script>
<script>
var db = firebase.database();
var allCompanies = {};
var allClients = [];
var allPos = [];

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function showNotice(msg, type){
  var el = document.getElementById('sa-notice');
  el.className = 'sa-notice ' + type;
  el.textContent = msg;
  el.style.display = 'block';
  if(type !== 'err') setTimeout(function(){ el.style.display='none'; }, 4000);
}

function switchTab(t){
  document.getElementById('view-clients').style.display = t==='clients' ? '' : 'none';
  document.getElementById('view-pos').style.display = t==='pos' ? '' : 'none';
  document.getElementById('tab-clients').style.cssText = t==='clients'
    ? 'padding:12px 20px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:700;color:#E65100;border-bottom:2px solid #E65100;margin-bottom:-2px'
    : 'padding:12px 20px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:600;color:#9e9e9e';
  document.getElementById('tab-pos').style.cssText = t==='pos'
    ? 'padding:12px 20px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:700;color:#E65100;border-bottom:2px solid #E65100;margin-bottom:-2px'
    : 'padding:12px 20px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:600;color:#9e9e9e';
}

function poStatus(po){
  var today = new Date().toISOString().slice(0,10);
  if(po.dateTo && po.dateTo < today) return 'expired';
  if(po.dateFrom && po.dateFrom > today) return 'upcoming';
  return 'active';
}

function tripsRemaining(po){
  var qty = parseInt(po.qty || po.qtyApproved || 0);
  var used = parseInt(po.tripsUsed || 0);
  return Math.max(0, qty - used);
}

// JS-string escaper for safely embedding values inside single-quoted JS strings
// that live inside HTML onclick attributes. Wrap with esc() afterwards for HTML safety.
function jsq(s){ return String(s==null?'':s).replace(/\\/g,'\\\\').replace(/'/g,'\\\''); }

function loadData(){
  document.getElementById('clients-loading').style.display = 'block';
  document.getElementById('clients-tbl').style.display = 'none';
  document.getElementById('clients-empty').style.display = 'none';

  _fbGet('superClients').then(function(clients){
    allCompanies = clients || {};

    ['f-company-c','f-company-p'].forEach(function(id){
      var sel = document.getElementById(id);
      var prev = sel.value;
      sel.innerHTML = '<option value="">All Companies</option>';
      Object.entries(allCompanies).sort(function(a,b){ return (a[1].name||'').localeCompare(b[1].name||''); }).forEach(function(e){
        sel.innerHTML += '<option value="'+esc(e[0])+'">'+esc(e[1].name||e[0])+'</option>';
      });
      sel.value = prev;
    });

    var cids = Object.keys(allCompanies);
    if(!cids.length){
      document.getElementById('clients-loading').style.display = 'none';
      document.getElementById('clients-empty').style.display = 'block';
      return;
    }

    allClients = [];
    allPos = [];
    var done = 0;

    cids.forEach(function(cid){
      var companyName = (allCompanies[cid] && allCompanies[cid].name) || cid;
      _fbGet('accClients/'+cid).then(function(data){
        data = data || {};
        Object.entries(data).forEach(function(e){
          var client = e[1] || {};
          var clientId = e[0];
          var pos = client.purchaseOrders || client.pos || {};
          var poList = Object.entries(pos).map(function(pe){
            var po = pe[1] || {};
            return Object.assign({ _poId: pe[0], _clientId: clientId, _cid: cid, _companyName: companyName, _clientName: client.name||client.clientName||'', _claimNumber: client.claimNumber||client.claim||'' }, po);
          });

          // Find active PO for today
          var activePo = poList.find(function(p){ return poStatus(p) === 'active'; }) || null;

          allClients.push({
            clientId: clientId,
            cid: cid,
            companyName: companyName,
            name: client.name || client.clientName || '',
            phone: client.phone || '',
            claimNumber: client.claimNumber || client.claim || '',
            serviceCode: client.serviceCode || '',
            wheelchair: !!(client.wheelchair || client.wavRequired),
            notes: client.notes || '',
            // Client-level default subsidy %. PO-level overrides this when set.
            // Default 100 = council/ACC fully covers (matches legacy behaviour).
            percentPaid: (typeof client.percentPaid === 'number') ? client.percentPaid : 100,
            activePo: activePo,
            poList: poList
          });

          poList.forEach(function(po){ allPos.push(po); });
        });
      }).catch(function(){}).finally(function(){
        done++;
        if(done === cids.length){
          document.getElementById('clients-loading').style.display = 'none';
          updateKpis();
          applyClientFilter();
          applyPoFilter();
        }
      });
    });
  }).catch(function(e){
    document.getElementById('clients-loading').textContent = 'Error: ' + e.message;
  });
}

function updateKpis(){
  var activePos = allPos.filter(function(p){ return poStatus(p) === 'active'; }).length;
  var expiredPos = allPos.filter(function(p){ return poStatus(p) === 'expired'; }).length;
  var wav = allClients.filter(function(c){ return c.wheelchair; }).length;
  var cos = new Set(allClients.map(function(c){ return c.cid; })).size;
  document.getElementById('kpi-clients').textContent = allClients.length;
  document.getElementById('kpi-pos').textContent = allPos.length;
  document.getElementById('kpi-active-pos').textContent = activePos;
  document.getElementById('kpi-expired').textContent = expiredPos;
  document.getElementById('kpi-wav').textContent = wav;
  document.getElementById('kpi-companies').textContent = cos;
}

function applyClientFilter(){
  var search = (document.getElementById('f-search-c').value || '').toLowerCase();
  var cid = document.getElementById('f-company-c').value;
  var wav = document.getElementById('f-wav').value;

  var filtered = allClients.filter(function(c){
    if(cid && c.cid !== cid) return false;
    if(wav === 'yes' && !c.wheelchair) return false;
    if(wav === 'no' && c.wheelchair) return false;
    if(search){
      var hay = (c.name+' '+c.claimNumber+' '+c.phone+' '+c.serviceCode).toLowerCase();
      if(hay.indexOf(search) === -1) return false;
    }
    return true;
  });

  document.getElementById('f-count-c').textContent = filtered.length + ' client' + (filtered.length !== 1 ? 's' : '');

  var tbody = document.getElementById('clients-body');
  if(!filtered.length){
    document.getElementById('clients-tbl').style.display = 'none';
    document.getElementById('clients-empty').style.display = 'block';
    return;
  }
  document.getElementById('clients-empty').style.display = 'none';
  document.getElementById('clients-tbl').style.display = 'table';

  tbody.innerHTML = filtered.map(function(c, i){
    var wavBadge = c.wheelchair ? '<span class="badge badge-wav">&#9855; WAV</span>' : '';
    var activePo = c.activePo;
    var poCell, tripsCell, expiryCell;
    // Effective subsidy = active PO override (if set) else client-level default
    var effectivePct = (activePo && typeof activePo.percentPaid === 'number') ? activePo.percentPaid : c.percentPaid;
    var pctClass = effectivePct >= 100 ? '' : effectivePct === 0 ? ' zero' : ' partial';
    var pctCell = '<span class="pct-badge'+pctClass+'">'+effectivePct+'%</span>';
    if(activePo){
      var rem = tripsRemaining(activePo);
      var qty = parseInt(activePo.qty || activePo.qtyApproved || 0);
      var pct = qty > 0 ? Math.min(100, Math.round((rem/qty)*100)) : 0;
      var barClass = pct > 50 ? '' : pct > 20 ? ' warn' : ' danger';
      poCell = '<span style="font-size:12px;font-weight:600">'+esc(activePo.poNumber||activePo._poId)+'</span>';
      tripsCell = rem+'/'+qty+'<span class="trips-bar-wrap"><span class="trips-bar'+barClass+'" style="width:'+pct+'%"></span></span>';
      expiryCell = activePo.dateTo ? '<span style="font-size:12px">'+esc(activePo.dateTo)+'</span>' : '—';
    } else {
      poCell = '<span style="color:#bbb;font-size:12px">No active PO</span>';
      tripsCell = '—';
      expiryCell = '—';
    }
    var rowId = 'po-detail-'+i;
    var clientKey = c.cid+'|'+c.clientId;
    var poRows = c.poList.length ? c.poList.map(function(p){
      var st = poStatus(p);
      var stBadge = st==='active'?'<span class="badge badge-active">Active</span>':st==='expired'?'<span class="badge badge-expired">Expired</span>':'<span class="badge badge-upcoming">Upcoming</span>';
      var r2 = tripsRemaining(p);
      var q2 = parseInt(p.qty||p.qtyApproved||0);
      var poPctTxt = (typeof p.percentPaid === 'number') ? p.percentPaid+'%' : '<span style="color:#bbb">(client)</span>';
      var poRef = p._cid+'|'+p._clientId+'|'+p._poId;
      return '<tr>'
        +'<td>'+esc(p.poNumber||p._poId)+'</td>'
        +'<td>'+esc(p.dateFrom||'—')+'</td>'
        +'<td>'+esc(p.dateTo||'—')+'</td>'
        +'<td>'+q2+'</td><td>'+parseInt(p.tripsUsed||0)+'</td><td>'+r2+'</td>'
        +'<td>'+(p.maxPrice?'$'+p.maxPrice:'—')+'</td>'
        +'<td>'+esc(p.managerName||'—')+'</td>'
        +'<td>'+esc(p.branch||p.city||'—')+'</td>'
        +'<td style="font-size:12px">'+poPctTxt+'</td>'
        +'<td>'+stBadge+'</td>'
        +'<td style="white-space:nowrap"><button class="row-action" onclick="openPoModal(\''+esc(jsq(poRef))+'\')" title="Edit PO">&#9998;</button><button class="row-action danger" onclick="deletePo(\''+esc(jsq(poRef))+'\')" title="Delete PO">&#10005;</button></td>'
        +'</tr>';
    }).join('') : '<tr><td colspan="12" style="color:#bbb;font-size:12px;padding:10px">No purchase orders recorded yet.</td></tr>';

    return '<tr>'
      +'<td><button class="expand-btn" onclick="togglePoDetail(\''+rowId+'\')" title="Show POs">&#9660;</button></td>'
      +'<td><span class="claim-badge">'+esc(c.claimNumber||'—')+'</span></td>'
      +'<td style="font-weight:600">'+esc(c.name||'—')+'</td>'
      +'<td><span class="cid-badge">'+esc(c.cid)+'</span> '+esc(c.companyName)+'</td>'
      +'<td>'+esc(c.phone||'—')+'</td>'
      +'<td style="font-size:12px">'+esc(c.serviceCode||'—')+'</td>'
      +'<td>'+wavBadge+'</td>'
      +'<td>'+poCell+'</td>'
      +'<td>'+pctCell+'</td>'
      +'<td>'+tripsCell+'</td>'
      +'<td>'+expiryCell+'</td>'
      +'<td style="white-space:nowrap"><button class="row-action" onclick="openClientModal(\''+esc(jsq(clientKey))+'\')" title="Edit client">&#9998;</button><button class="row-action" onclick="openPoModal(\''+esc(jsq(clientKey+'|NEW'))+'\')" title="Add PO">&#43;PO</button><button class="row-action danger" onclick="deleteClient(\''+esc(jsq(clientKey))+'\')" title="Delete client">&#10005;</button></td>'
      +'</tr>'
      +'<tr id="'+rowId+'" class="po-detail-row"><td colspan="12" style="padding:0;background:#fafafa">'
      +'<div style="padding:10px 18px 14px">'
      +'<div style="font-size:11px;font-weight:700;color:#4527A0;margin-bottom:6px;text-transform:uppercase">Purchase Orders for '+esc(c.name)+'</div>'
      +'<table class="po-table"><thead><tr><th>PO #</th><th>From</th><th>To</th><th>Qty</th><th>Used</th><th>Remaining</th><th>Max $/Trip</th><th>Manager</th><th>Branch</th><th>Subsidy %</th><th>Status</th><th></th></tr></thead><tbody>'+poRows+'</tbody></table>'
      +'</div></td></tr>';
  }).join('');
}

function togglePoDetail(id){
  var row = document.getElementById(id);
  if(!row) return;
  var open = row.classList.contains('open');
  row.classList.toggle('open', !open);
  var btn = row.previousSibling && row.previousSibling.querySelector('.expand-btn');
  if(btn) btn.textContent = open ? '▼' : '▲';
}

function applyPoFilter(){
  var search = (document.getElementById('f-search-p').value || '').toLowerCase();
  var cid = document.getElementById('f-company-p').value;
  var status = document.getElementById('f-po-status').value;

  var filtered = allPos.filter(function(p){
    if(cid && p._cid !== cid) return false;
    if(status && poStatus(p) !== status) return false;
    if(search){
      var hay = ((p.poNumber||'')+' '+(p._claimNumber||'')+' '+(p.managerName||'')+' '+(p.branch||p.city||'')+' '+(p._clientName||'')).toLowerCase();
      if(hay.indexOf(search) === -1) return false;
    }
    return true;
  });

  document.getElementById('f-count-p').textContent = filtered.length + ' PO' + (filtered.length !== 1 ? 's' : '');

  var tbody = document.getElementById('pos-body');
  if(!filtered.length){
    document.getElementById('pos-tbl').style.display = 'none';
    document.getElementById('pos-empty').style.display = 'block';
    return;
  }
  document.getElementById('pos-empty').style.display = 'none';
  document.getElementById('pos-tbl').style.display = 'table';

  tbody.innerHTML = filtered.map(function(p){
    var st = poStatus(p);
    var stBadge = st==='active'?'<span class="badge badge-active">Active</span>':st==='expired'?'<span class="badge badge-expired">Expired</span>':'<span class="badge badge-upcoming">Upcoming</span>';
    var qty = parseInt(p.qty||p.qtyApproved||0);
    var used = parseInt(p.tripsUsed||0);
    var rem = Math.max(0, qty-used);
    var poRef = p._cid+'|'+p._clientId+'|'+p._poId;
    var pctTxt = (typeof p.percentPaid === 'number')
      ? '<span class="pct-badge'+(p.percentPaid>=100?'':p.percentPaid===0?' zero':' partial')+'">'+p.percentPaid+'%</span>'
      : '<span style="color:#bbb;font-size:11px">(uses client)</span>';
    return '<tr>'
      +'<td style="font-weight:600;font-family:monospace">'+esc(p.poNumber||p._poId)+'</td>'
      +'<td><span class="claim-badge">'+esc(p._claimNumber||'—')+'</span></td>'
      +'<td>'+esc(p._clientName||'—')+'</td>'
      +'<td><span class="cid-badge">'+esc(p._cid)+'</span> '+esc(p._companyName)+'</td>'
      +'<td style="font-size:12px">'+esc(p.dateFrom||'—')+'</td>'
      +'<td style="font-size:12px">'+esc(p.dateTo||'—')+'</td>'
      +'<td>'+qty+'</td>'
      +'<td>'+used+'</td>'
      +'<td style="font-weight:700;color:'+(rem===0?'#C62828':rem<5?'#F57F17':'#2E7D32')+'">'+rem+'</td>'
      +'<td>'+(p.maxPrice?'$'+esc(p.maxPrice):'—')+'</td>'
      +'<td style="font-size:12px">'+esc(p.managerName||'—')+'<br><span style="color:#9e9e9e">'+esc(p.managerEmail||p.branch||'')+'</span></td>'
      +'<td style="font-size:12px">'+esc(p.branch||p.city||'—')+'</td>'
      +'<td>'+pctTxt+'</td>'
      +'<td>'+stBadge+'</td>'
      +'<td style="white-space:nowrap"><button class="row-action" onclick="openPoModal(\''+esc(jsq(poRef))+'\')" title="Edit PO">&#9998;</button><button class="row-action danger" onclick="deletePo(\''+esc(jsq(poRef))+'\')" title="Delete PO">&#10005;</button></td>'
      +'</tr>';
  }).join('');
}

function exportClientsCsv(){
  var headers = ['Claim #','Client Name','Company ID','Company','Phone','Service Code','WAV','Subsidy %','Active PO','Trips Remaining','PO Expires'];
  var rows = allClients.map(function(c){
    var ap = c.activePo;
    var eff = (ap && typeof ap.percentPaid==='number') ? ap.percentPaid : c.percentPaid;
    return [c.claimNumber, c.name, c.cid, c.companyName, c.phone, c.serviceCode, c.wheelchair?'Yes':'No', eff, ap?(ap.poNumber||ap._poId):'', ap?tripsRemaining(ap):'', ap?ap.dateTo:''].map(function(v){ return '"'+(String(v==null?'':v).replace(/"/g,'""'))+'"'; }).join(',');
  });
  var csv = headers.join(',') + '\n' + rows.join('\n');
  var a = document.createElement('a');
  a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
  a.download = 'acc-clients-' + new Date().toISOString().slice(0,10) + '.csv';
  a.click();
}

function exportPosCsv(){
  var headers = ['PO #','Claim #','Client Name','Company ID','Company','Date From','Date To','Qty','Used','Remaining','Max $/Trip','Manager','Manager Email','Branch','Override %','Effective %','Status'];
  var rows = allPos.map(function(p){
    var qty=parseInt(p.qty||p.qtyApproved||0); var used=parseInt(p.tripsUsed||0);
    var poPct = (typeof p.percentPaid==='number') ? p.percentPaid : '';
    // Effective = PO override > client default > 100. Look up client default from allClients.
    var client = allClients.find(function(c){ return c.cid===p._cid && c.clientId===p._clientId; });
    var clientPct = client ? client.percentPaid : 100;
    var effPct = (typeof p.percentPaid==='number') ? p.percentPaid : clientPct;
    return [p.poNumber||p._poId, p._claimNumber, p._clientName, p._cid, p._companyName, p.dateFrom, p.dateTo, qty, used, Math.max(0,qty-used), p.maxPrice||'', p.managerName||'', p.managerEmail||'', p.branch||p.city||'', poPct, effPct, poStatus(p)].map(function(v){ return '"'+(String(v==null?'':v).replace(/"/g,'""'))+'"'; }).join(',');
  });
  var csv = headers.join(',') + '\n' + rows.join('\n');
  var a = document.createElement('a');
  a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
  a.download = 'acc-purchase-orders-' + new Date().toISOString().slice(0,10) + '.csv';
  a.click();
}

/* ── Edit modal ─────────────────────────────────────────────────────────── */
// Keys are "cid|clientId" for clients and "cid|clientId|poId" for POs.
// poId === 'NEW' means create a new PO under that client.
// clientId on a CLIENT modal can be blank (= new client) or 'NEW' on the company select.
var _modalMode = null;     // 'client' | 'po'
var _modalKey  = null;     // current key being edited

function _findClient(cid, clientId){
  return allClients.find(function(c){ return c.cid===cid && c.clientId===clientId; });
}
function _findPo(cid, clientId, poId){
  return allPos.find(function(p){ return p._cid===cid && p._clientId===clientId && p._poId===poId; });
}
function _slug(s){
  return String(s||'').toLowerCase().replace(/[^a-z0-9]+/g,'_').replace(/^_+|_+$/g,'').slice(0,40);
}

function openClientModal(key){
  _modalMode = 'client';
  _modalKey = key; // null = new
  var c = null;
  if(key){
    var p = key.split('|'); c = _findClient(p[0], p[1]);
  }
  // Company select — only show companies that have ACC enabled (or all if SA wants).
  var companyOpts = '<option value="">— Select company —</option>' +
    Object.entries(allCompanies).sort(function(a,b){ return (a[1].name||'').localeCompare(b[1].name||''); })
      .map(function(e){ return '<option value="'+esc(e[0])+'"'+(c && c.cid===e[0]?' selected':'')+'>'+esc(e[1].name||e[0])+' ('+esc(e[0])+')</option>'; }).join('');
  document.getElementById('acc-modal-title').textContent = c ? 'Edit ACC Client' : 'Add ACC Client';
  document.getElementById('acc-modal-body').innerHTML =
    '<div class="row"><div><label>Company *</label>'+
      (c ? '<input type="text" disabled value="'+esc((allCompanies[c.cid]&&allCompanies[c.cid].name)||c.cid)+' ('+esc(c.cid)+')"/><input type="hidden" id="m-cid" value="'+esc(c.cid)+'"/>'
         : '<select id="m-cid">'+companyOpts+'</select>')+
    '</div><div><label>Claim Number *</label><input type="text" id="m-claim" value="'+esc(c?c.claimNumber:'')+'" placeholder="e.g. 10003254"/></div></div>'+
    '<div class="row"><div><label>Client Name *</label><input type="text" id="m-name" value="'+esc(c?c.name:'')+'"/></div>'+
    '<div><label>Phone</label><input type="text" id="m-phone" value="'+esc(c?c.phone:'')+'"/></div></div>'+
    '<div class="row"><div><label>Service Code</label><input type="text" id="m-svc" value="'+esc(c?c.serviceCode:'')+'" placeholder="e.g. ST-01"/></div>'+
    '<div><label>WAV Required</label><select id="m-wav"><option value="no"'+(c&&c.wheelchair?'':' selected')+'>No</option><option value="yes"'+(c&&c.wheelchair?' selected':'')+'>Yes — Wheelchair</option></select></div></div>'+
    '<div class="row"><div><label>Default Subsidy % *</label><input type="number" id="m-pct" min="0" max="100" step="1" value="'+(c?c.percentPaid:100)+'"/><div class="hint">What council/ACC covers. Passenger pays the remainder. POs can override per-PO.</div></div>'+
    '<div><label>Notes</label><textarea id="m-notes" placeholder="Internal notes (optional)">'+esc(c?c.notes:'')+'</textarea></div></div>';
  document.getElementById('acc-modal-foot').innerHTML =
    '<button class="sa-btn sa-btn-n" onclick="closeAccModal()">Cancel</button>'+
    '<button class="sa-btn sa-btn-p" onclick="saveClient()">'+(c?'Save Changes':'Create Client')+'</button>';
  document.getElementById('acc-modal-bg').classList.add('open');
}

function openPoModal(key){
  _modalMode = 'po';
  _modalKey = key;
  var parts = key.split('|');
  var cid = parts[0], clientId = parts[1], poId = parts[2];
  var po = (poId && poId !== 'NEW') ? _findPo(cid, clientId, poId) : null;
  var client = _findClient(cid, clientId);
  if(!client){ showNotice('Client not found for that PO', 'err'); return; }
  document.getElementById('acc-modal-title').textContent = po ? 'Edit Purchase Order' : 'Add Purchase Order';
  document.getElementById('acc-modal-body').innerHTML =
    '<div style="background:#FFF8F5;border-left:4px solid #E65100;padding:9px 12px;border-radius:4px;margin-bottom:14px;font-size:12px">'+
      '<strong>'+esc(client.name)+'</strong> · Claim '+esc(client.claimNumber||'—')+' · '+esc(client.companyName)+' <span class="cid-badge">'+esc(cid)+'</span>'+
    '</div>'+
    '<input type="hidden" id="m-po-cid" value="'+esc(cid)+'"/>'+
    '<input type="hidden" id="m-po-client" value="'+esc(clientId)+'"/>'+
    '<input type="hidden" id="m-po-id" value="'+esc(po?poId:'')+'"/>'+
    '<div class="row"><div><label>PO Number *</label><input type="text" id="m-po-num" value="'+esc(po?(po.poNumber||po._poId):'')+'" placeholder="e.g. PO-2026-014"/></div>'+
    '<div><label>Trips Approved (Qty) *</label><input type="number" id="m-po-qty" min="0" step="1" value="'+esc(po?(po.qty||po.qtyApproved||0):'')+'"/></div></div>'+
    '<div class="row"><div><label>Date From *</label><input type="date" id="m-po-from" value="'+esc(po?po.dateFrom:'')+'"/></div>'+
    '<div><label>Date To *</label><input type="date" id="m-po-to" value="'+esc(po?po.dateTo:'')+'"/></div></div>'+
    '<div class="row"><div><label>Max $ per Trip</label><input type="number" id="m-po-max" min="0" step="0.01" value="'+esc(po?(po.maxPrice||''):'')+'"/></div>'+
    '<div><label>Subsidy % Override</label><input type="number" id="m-po-pct" min="0" max="100" step="1" value="'+(po && typeof po.percentPaid==='number'?po.percentPaid:'')+'" placeholder="Leave blank to use client default ('+client.percentPaid+'%)"/><div class="hint">Per-PO override. Blank = use client default.</div></div></div>'+
    '<div class="row"><div><label>Manager Name</label><input type="text" id="m-po-mgr" value="'+esc(po?(po.managerName||''):'')+'"/></div>'+
    '<div><label>Manager Email</label><input type="email" id="m-po-mgremail" value="'+esc(po?(po.managerEmail||''):'')+'"/></div></div>'+
    '<div class="row"><div><label>Branch / City</label><input type="text" id="m-po-branch" value="'+esc(po?(po.branch||po.city||''):'')+'"/></div>'+
    '<div><label>Trips Used (counter)</label><input type="number" id="m-po-used" min="0" step="1" value="'+esc(po?(po.tripsUsed||0):0)+'"/><div class="hint">Auto-incremented by dispatch on each trip. Adjust only to correct mistakes.</div></div></div>';
  document.getElementById('acc-modal-foot').innerHTML =
    '<button class="sa-btn sa-btn-n" onclick="closeAccModal()">Cancel</button>'+
    '<button class="sa-btn sa-btn-p" onclick="savePo()">'+(po?'Save Changes':'Create PO')+'</button>';
  document.getElementById('acc-modal-bg').classList.add('open');
}

function closeAccModal(){
  document.getElementById('acc-modal-bg').classList.remove('open');
  _modalMode = null; _modalKey = null;
}

function saveClient(){
  var cidEl = document.getElementById('m-cid');
  var cid = cidEl ? (cidEl.value || '').trim() : '';
  var name = (document.getElementById('m-name').value || '').trim();
  var claim = (document.getElementById('m-claim').value || '').trim();
  var pctRaw = (document.getElementById('m-pct').value || '').trim();
  var pct = pctRaw === '' ? 100 : parseInt(pctRaw, 10);
  if(!cid){ showNotice('Please select a company', 'err'); return; }
  if(!name){ showNotice('Client name is required', 'err'); return; }
  if(!claim){ showNotice('Claim number is required', 'err'); return; }
  if(isNaN(pct) || pct < 0 || pct > 100){ showNotice('Subsidy % must be between 0 and 100', 'err'); return; }
  var clientId = _modalKey ? _modalKey.split('|')[1] : ('acc_'+_slug(claim||name)+'_'+Date.now().toString(36)+'_'+Math.random().toString(36).slice(2,6));
  var body = {
    name: name,
    claimNumber: claim,
    phone: (document.getElementById('m-phone').value || '').trim(),
    serviceCode: (document.getElementById('m-svc').value || '').trim(),
    wheelchair: document.getElementById('m-wav').value === 'yes',
    percentPaid: pct,
    notes: (document.getElementById('m-notes').value || '').trim(),
    updatedAt: Date.now()
  };
  if(!_modalKey) body.createdAt = Date.now();
  _fbPost('accClients/'+cid+'/'+clientId, 'PATCH', body).then(function(r){
    if(r && r.error){ showNotice('Save failed: '+r.error, 'err'); return; }
    showNotice(_modalKey?'Client updated.':'Client created.', 'ok');
    closeAccModal();
    loadData();
  }).catch(function(e){ showNotice('Save failed: '+e.message, 'err'); });
}

function savePo(){
  var cid = document.getElementById('m-po-cid').value;
  var clientId = document.getElementById('m-po-client').value;
  var poId = document.getElementById('m-po-id').value;
  var poNum = (document.getElementById('m-po-num').value || '').trim();
  var qty = parseInt(document.getElementById('m-po-qty').value, 10);
  var dateFrom = (document.getElementById('m-po-from').value || '').trim();
  var dateTo = (document.getElementById('m-po-to').value || '').trim();
  var maxPrice = (document.getElementById('m-po-max').value || '').trim();
  var pctRaw = (document.getElementById('m-po-pct').value || '').trim();
  var used = parseInt(document.getElementById('m-po-used').value, 10);
  if(!poNum){ showNotice('PO Number is required', 'err'); return; }
  if(isNaN(qty) || qty < 0){ showNotice('Trips Approved (Qty) must be a non-negative number', 'err'); return; }
  if(!dateFrom || !dateTo){ showNotice('Date From and Date To are required', 'err'); return; }
  if(dateTo < dateFrom){ showNotice('Date To must be on or after Date From', 'err'); return; }
  if(pctRaw !== ''){
    var pPct = parseInt(pctRaw, 10);
    if(isNaN(pPct) || pPct < 0 || pPct > 100){ showNotice('Subsidy % override must be 0–100 or blank', 'err'); return; }
  }
  var body = {
    poNumber: poNum,
    qty: qty,
    dateFrom: dateFrom,
    dateTo: dateTo,
    maxPrice: maxPrice ? parseFloat(maxPrice) : null,
    managerName: (document.getElementById('m-po-mgr').value || '').trim(),
    managerEmail: (document.getElementById('m-po-mgremail').value || '').trim(),
    branch: (document.getElementById('m-po-branch').value || '').trim(),
    tripsUsed: isNaN(used) ? 0 : used,
    percentPaid: pctRaw === '' ? null : parseInt(pctRaw, 10),
    updatedAt: Date.now()
  };
  if(!poId) body.createdAt = Date.now();
  var pid = poId || ('po_'+_slug(poNum)+'_'+Date.now().toString(36)+'_'+Math.random().toString(36).slice(2,6));
  _fbPost('accClients/'+cid+'/'+clientId+'/purchaseOrders/'+pid, 'PATCH', body).then(function(r){
    if(r && r.error){ showNotice('Save failed: '+r.error, 'err'); return; }
    showNotice(poId?'PO updated.':'PO created.', 'ok');
    closeAccModal();
    loadData();
  }).catch(function(e){ showNotice('Save failed: '+e.message, 'err'); });
}

function deleteClient(key){
  var p = key.split('|'); var cid = p[0]; var clientId = p[1];
  var c = _findClient(cid, clientId);
  if(!c){ return; }
  if(!confirm('Delete ACC client "'+(c.name||clientId)+'" and ALL their purchase orders?\n\nThis cannot be undone.')) return;
  _fbPost('accClients/'+cid+'/'+clientId, 'DELETE', null).then(function(r){
    if(r && r.error && !String(r.error).includes('null')){ showNotice('Delete failed: '+r.error, 'err'); return; }
    showNotice('Client deleted.', 'ok');
    loadData();
  }).catch(function(e){ showNotice('Delete failed: '+e.message, 'err'); });
}

function deletePo(ref){
  var p = ref.split('|'); var cid = p[0], clientId = p[1], poId = p[2];
  var po = _findPo(cid, clientId, poId);
  if(!po){ return; }
  if(!confirm('Delete PO "'+(po.poNumber||poId)+'"? This cannot be undone.')) return;
  _fbPost('accClients/'+cid+'/'+clientId+'/purchaseOrders/'+poId, 'DELETE', null).then(function(r){
    if(r && r.error && !String(r.error).includes('null')){ showNotice('Delete failed: '+r.error, 'err'); return; }
    showNotice('PO deleted.', 'ok');
    loadData();
  }).catch(function(e){ showNotice('Delete failed: '+e.message, 'err'); });
}

window._fbOnLogin = function(){ loadData(); };
</script>

<!-- Edit modal -->
<div class="acc-modal-bg" id="acc-modal-bg" onclick="if(event.target===this) closeAccModal()">
  <div class="acc-modal">
    <div class="acc-modal-head">
      <h3 id="acc-modal-title">Edit</h3>
      <button class="close" onclick="closeAccModal()" title="Close">&times;</button>
    </div>
    <div class="acc-modal-body" id="acc-modal-body"></div>
    <div class="acc-modal-foot" id="acc-modal-foot"></div>
  </div>
</div>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
