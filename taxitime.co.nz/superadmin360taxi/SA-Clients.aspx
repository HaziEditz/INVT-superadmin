<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Taxi Companies &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}.sa-btn-s:hover{background:#C8E6C9}
.sa-btn-w{background:#FFF9C4;color:#F57F17;border:1px solid #FFF176}.sa-btn-w:hover{background:#FFF176}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.badge-you{background:#1565C0;color:#fff;font-size:10px;font-weight:700;padding:2px 7px;border-radius:10px;margin-left:6px;vertical-align:middle}
.badge-active{background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7}
.badge-suspended{background:#FFEBEE;color:#C62828;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #FFCDD2}
.mod-chip{display:inline-flex;align-items:center;gap:3px;padding:3px 9px;border-radius:12px;font-size:11px;font-weight:600;cursor:pointer;border:1px solid transparent;transition:all .15s;user-select:none}
.mod-on{background:#E8F5E9;color:#2E7D32;border-color:#A5D6A7}
.mod-off{background:#f5f5f5;color:#aaa;border-color:#e0e0e0}
.mod-chip:hover{opacity:.8}
.sa-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.sa-ff input,.sa-ff select{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.sa-ff input:focus,.sa-ff select:focus{outline:none;border-color:#1565C0}
.add-form{display:none;padding:18px;background:#F0F7FF;border-top:1px solid #BBDEFB}
.add-form.open{display:block}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:9999;align-items:center;justify-content:center;padding:20px}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:14px;box-shadow:0 20px 60px rgba(0,0,0,.3);padding:28px;width:100%;max-width:480px}
.add-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:12px;margin-bottom:14px}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.cid-badge{font-family:monospace;background:#E3F2FD;color:#1565C0;padding:2px 7px;border-radius:4px;font-size:12px;font-weight:700}
.edit-row-inner{background:#F0F7FF;padding:14px 16px;border-top:1px solid #BBDEFB}
.edit-row-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(170px,1fr));gap:10px;margin-bottom:12px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Taxi Companies &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Clients.aspx" style="font-weight:700;color:#1565C0">&#9658; All Companies</a></li>
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
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#127970; Taxi Companies</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">
  All taxi companies registered on the BookaWaka platform. Each company gets its own admin panel and can be assigned modules (Taxi / Food / Freight) based on their package.
</p>

<div id="sa-notice" style="display:none" class="sa-notice"></div>

<div class="sa-card">
  <div class="sa-bar">
    <h3>&#127970; Registered Companies</h3>
    <div style="display:flex;gap:6px;flex-wrap:wrap">
      <button class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px" onclick="exportCsv()">&#8659; Export CSV</button>
      <button class="sa-btn sa-btn-p" onclick="toggleAddForm()">&#43; Add Company</button>
    </div>
  </div>
  <!-- Bulk action bar -->
  <div id="bulk-bar" style="display:none;padding:10px 18px;background:#E3F2FD;border-bottom:1px solid #BBDEFB;align-items:center;gap:12px;flex-wrap:wrap">
    <span id="bulk-count" style="font-size:13px;font-weight:700;color:#1565C0"></span>
    <button onclick="bulkSuspend()" class="sa-btn sa-btn-w" style="font-size:11px">&#9940; Suspend Selected</button>
    <button onclick="bulkActivate()" class="sa-btn sa-btn-s" style="font-size:11px">&#10003; Activate Selected</button>
    <button onclick="clearBulk()" class="sa-btn sa-btn-n" style="font-size:11px;margin-left:auto">&#10005; Clear</button>
  </div>

  <!-- Add company form -->
  <div id="add-form" class="add-form">
    <div style="font-size:13px;font-weight:600;color:#1565C0;margin-bottom:12px">&#43; Register New Company</div>
    <div class="add-grid">
      <div class="sa-ff"><label>Company ID <span style="color:#C62828">*</span></label><input id="f-id" type="text" placeholder="Generating…" title="Auto-generated — you can change it"/><span id="f-id-hint" style="display:block;font-size:11px;color:#888;margin-top:3px">Auto-generated — you can change it</span></div>
      <div class="sa-ff"><label>Company Name <span style="color:#C62828">*</span></label><input id="f-name" type="text" placeholder="e.g. CityTaxi Auckland"/></div>
      <div class="sa-ff"><label>City</label><input id="f-city" type="text" placeholder="e.g. Auckland"/></div>
      <div class="sa-ff"><label>Country</label><input id="f-country" type="text" placeholder="e.g. New Zealand"/></div>
      <div class="sa-ff"><label>Contact Email</label><input id="f-email" type="email" placeholder="admin@company.com"/></div>
      <div class="sa-ff"><label>Contact Phone</label><input id="f-phone" type="text" placeholder="+64 21 000 000"/></div>
      <div class="sa-ff"><label>Payout Schedule</label>
        <select id="f-sched">
          <option value="weekly">Weekly</option>
          <option value="monthly">Monthly</option>
        </select>
      </div>
    </div>
    <div style="margin-bottom:12px">
      <div style="font-size:12px;color:#757575;font-weight:500;margin-bottom:6px">Enabled Modules</div>
      <label style="display:inline-flex;align-items:center;gap:6px;margin-right:16px;font-size:13px;cursor:pointer">
        <input type="checkbox" id="f-m-taxi" checked/> Taxi / Rides
      </label>
      <label style="display:inline-flex;align-items:center;gap:6px;margin-right:16px;font-size:13px;cursor:pointer">
        <input type="checkbox" id="f-m-food"/> Food Delivery
      </label>
      <label style="display:inline-flex;align-items:center;gap:6px;font-size:13px;cursor:pointer">
        <input type="checkbox" id="f-m-freight"/> Freight / Parcels
      </label>
    </div>
    <div style="display:flex;gap:8px;align-items:center">
      <button class="sa-btn sa-btn-p" onclick="saveNewCompany()">Save Company</button>
      <button class="sa-btn sa-btn-n" onclick="toggleAddForm()">Cancel</button>
      <span id="add-msg" style="font-size:12.5px;color:#888"></span>
    </div>
  </div>

  <div style="overflow-x:auto">
  <table class="sa-tbl" id="clients-tbl">
    <thead>
      <tr>
        <th style="width:32px;text-align:center"><input type="checkbox" id="bulk-select-all" title="Select all" onchange="toggleSelectAll(this.checked)" style="cursor:pointer;accent-color:#1565C0"/></th>
        <th>Company ID</th>
        <th>Name</th>
        <th>City / Country</th>
        <th>Active Services</th>
        <th>Plan</th>
        <th>Payout</th>
        <th>Status</th>
        <th>Contact</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody id="clients-body">
      <tr><td colspan="9" style="text-align:center;padding:30px;color:#aaa">Loading companies&hellip;</td></tr>
    </tbody>
  </table>
  </div>
</div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var SUPER_PATH = 'superClients';
var allPackages = {}, allFoodClients = {};

function showNotice(msg, type){
  var el = document.getElementById('sa-notice');
  el.className = 'sa-notice ' + type;
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(function(){ el.style.display = 'none'; }, 4000);
}

function toggleAddForm(){
  var f = document.getElementById('add-form');
  var isOpening = !f.classList.contains('open');
  f.classList.toggle('open');
  document.getElementById('add-msg').textContent = '';
  if(isOpening){
    var fidEl = document.getElementById('f-id');
    var hint = document.getElementById('f-id-hint');
    fidEl.value = '';
    fidEl.placeholder = 'Generating…';
    if(hint) hint.textContent = 'Loading next available ID…';
    _fbGet(SUPER_PATH).then(function(data){
      data = data || {};
      var maxId = 1000;
      Object.keys(data).forEach(function(k){
        var n = parseInt(k, 10);
        if(!isNaN(n) && n > maxId) maxId = n;
      });
      var nextId = String(maxId + 1);
      fidEl.value = nextId;
      fidEl.placeholder = nextId;
      if(hint) hint.textContent = 'Auto-generated — you can change it';
    }).catch(function(){
      fidEl.placeholder = 'e.g. 2001';
      if(hint) hint.textContent = 'Could not auto-generate — enter manually';
    });
  }
}

function moduleChips(modules, cid){
  var chips = '';
  var defs = [{key:'taxi',label:'&#128663; Taxi'},{key:'food',label:'&#127829; Food'},{key:'freight',label:'&#128230; Freight'}];
  defs.forEach(function(d){
    var on = modules && modules[d.key];
    chips += '<span class="mod-chip '+(on?'mod-on':'mod-off')+'" data-mod="'+d.key+'" title="Click to toggle '+d.label+'">'+d.label+'</span>';
    if (on && d.key === 'food' && cid && allFoodClients[cid]) {
      var rnames = Object.values(allFoodClients[cid]).map(function(r){ return escHtml(r.name||''); }).filter(Boolean);
      if (rnames.length) chips += '<div style="font-size:10.5px;color:#E65100;margin-top:2px;line-height:1.4">' + rnames.map(function(n){ return '&#x2022; '+n; }).join('<br>') + '</div>';
    }
    if (on && d.key === 'freight' && cid && allFoodClients['freight_'+cid]) {
      var fname = allFoodClients['freight_'+cid].name;
      if (fname) chips += '<div style="font-size:10.5px;color:#4E342E;margin-top:2px">&#x2022; '+escHtml(fname)+'</div>';
    }
    chips += ' ';
  });
  return chips;
}

function planCell(c) {
  var pkgId = c.packageId;
  if (!pkgId || !allPackages[pkgId]) {
    var msg = !pkgId ? 'No plan' : 'Plan?';
    return '<span style="background:#FFF3E0;color:#E65100;font-size:11px;font-weight:700;padding:2px 8px;border-radius:8px;border:1px solid #FFCC80" title="No subscription package assigned">&#9888; '+msg+'</span>';
  }
  var p = allPackages[pkgId];
  var ppc = +(p.pricePerCar || p.monthlyPrice || 0);
  var minM = +(p.minimumMonthly || 0);
  var mods = ['taxi','food','freight'];
  var overPlan = mods.filter(function(m) {
    return c.modules && c.modules[m] && !(p.modules && p.modules[m]);
  });
  var planBadge = '<span style="background:#E3F2FD;color:#1565C0;font-size:11px;font-weight:700;padding:2px 8px;border-radius:8px;border:1px solid #BBDEFB">'+escHtml(p.name||pkgId)+'</span>';
  var priceHtml = ppc
    ? '<div style="font-size:10.5px;color:#888;margin-top:2px">$'+ppc.toFixed(2)+'/car/mo'+(minM?' · min $'+minM.toFixed(0):'')+'</div>'
    : '';
  var compHtml = overPlan.length
    ? '<div style="color:#C62828;font-size:11px;font-weight:600;margin-top:3px" title="Modules enabled but not in plan">&#9888; Over plan: '+overPlan.join(', ')+'</div>'
    : '<div style="color:#2E7D32;font-size:11px;margin-top:3px">&#10003; Compliant</div>';
  return planBadge + priceHtml + compHtml;
}

function renderClients(data){
  var openEdit = document.querySelector('[id^="edit-row-"][style*="table-row"]');
  if(openEdit) return;
  var tbody = document.getElementById('clients-body');
  if(!data){ tbody.innerHTML='<tr><td colspan="10" style="text-align:center;padding:30px;color:#aaa">No companies registered yet. Click "+ Add Company" to begin.</td></tr>'; return; }
  var rows = '';
  Object.keys(data).sort().forEach(function(cid){
    var c = data[cid];
    var isYou = false;
    var statusBadge = c.status === 'suspended'
      ? '<span class="badge-suspended">Suspended</span>'
      : '<span class="badge-active">Active</span>';
    rows += '<tr data-cid="'+cid+'">' +
      '<td style="text-align:center">'+(isYou?'':'<input type="checkbox" class="co-chk" data-cid="'+escAttr(cid)+'" data-name="'+escAttr(c.name||cid)+'" data-status="'+escAttr(c.status||'active')+'" onchange="updateBulkBar()" style="cursor:pointer;accent-color:#1565C0"/>')+'</td>'+
      '<td><span class="cid-badge">'+cid+'</span>'+(isYou?'<span class="badge-you">Your Co.</span>':'')+'</td>' +
      '<td style="font-weight:600">'+escHtml(c.name||'—')+((c.notes||c.internalNotes)?'<span title="'+escAttr(c.notes||c.internalNotes||'')+'" style="display:inline-block;margin-left:5px;font-size:11px;color:#FB8C00;cursor:default">&#128203;</span>':'')+(c.ownerGroupId?'<span style="display:inline-block;margin-left:5px;background:#F3E5F5;color:#4A148C;font-size:10px;font-weight:700;padding:1px 6px;border-radius:8px;border:1px solid #CE93D8;cursor:pointer" onclick="window.location.href=\'SA-OwnerGroups.aspx\'" title="Part of an owner group">&#128101; Group</span>':'')+'</td>' +
      '<td style="color:#555">'+escHtml((c.city||'')+(c.city&&c.country?', ':'')+( c.country||''))+'</td>' +
      '<td class="mod-chips">'+moduleChips(c.modules, cid)+'</td>' +
      '<td>'+planCell(c)+'</td>' +
      '<td style="font-size:12px;color:#555;text-transform:capitalize">'+(c.payoutSchedule||'weekly')+'</td>' +
      '<td>'+statusBadge+'</td>' +
      '<td style="font-size:12px">' +
        (c.contactEmail
          ? '<a href="mailto:'+escHtml(c.contactEmail)+'" style="color:#1565C0;text-decoration:none;display:inline-flex;align-items:center;gap:3px" title="Send email to '+escHtml(c.contactEmail)+'"><i class="material-icons" style="font-size:14px">email</i>'+escHtml(c.contactEmail)+'</a>'
          : '') +
        (c.contactPhone
          ? '<div style="color:#888;margin-top:2px"><i class="material-icons" style="font-size:13px;vertical-align:middle">phone</i> '+escHtml(c.contactPhone)+'</div>'
          : '') +
        (!c.contactEmail && !c.contactPhone ? '<span style="color:#ccc">—</span>' : '') +
      '</td>' +
      '<td style="white-space:nowrap">' +
        '<a href="SA-Company.aspx?cid='+cid+'" class="sa-btn sa-btn-p" style="font-size:11px;text-decoration:none">&#128065; Details</a> ' +
        (isYou ? '' : '<button id="view-as-btn-'+cid+'" class="sa-btn sa-btn-n" style="font-size:11px" onclick="openViewAs(\''+escAttr(cid)+'\',\''+escAttr(c.name||cid)+'\')">&#128065; View as</button> ') +
        '<button class="sa-btn sa-btn-n" style="font-size:11px" onclick="toggleEditRow(\''+cid+'\')">&#9998; Edit</button> ' +
        (c.status==='suspended'
          ? '<button class="sa-btn sa-btn-s" style="font-size:11px" onclick="setStatus(\''+cid+'\',\'active\')">Activate</button>'
          : '<button class="sa-btn sa-btn-w" style="font-size:11px" onclick="openSuspendModal(\''+cid+'\')">Suspend</button>') +
        ' <a href="SA-Billing.aspx?cid='+cid+'" class="sa-btn sa-btn-p" style="font-size:11px;text-decoration:none">&#128179; Billing</a>' +
        ' <button class="sa-btn sa-btn-d del-company-btn" style="font-size:11px" data-cid="'+escAttr(cid)+'" data-name="'+escAttr(c.name||cid)+'">&#128465; Delete</button>' +
      '</td>' +
    '</tr>' +
    '<tr id="edit-row-'+cid+'" style="display:none"><td colspan="10" style="padding:0">' +
      '<div class="edit-row-inner">' +
        '<div style="font-size:12.5px;font-weight:600;color:#1565C0;margin-bottom:10px">&#9998; Edit Company: '+escHtml(c.name||cid)+'</div>' +
        '<div class="edit-row-grid">' +
          '<div class="sa-ff"><label>Company Name</label><input id="ec-name-'+cid+'" value="'+escHtml(c.name||'')+'"/></div>' +
          '<div class="sa-ff"><label>City</label><input id="ec-city-'+cid+'" value="'+escHtml(c.city||'')+'"/></div>' +
          '<div class="sa-ff"><label>Country</label><input id="ec-country-'+cid+'" value="'+escHtml(c.country||'')+'"/></div>' +
          '<div class="sa-ff"><label>Contact Email</label><input id="ec-email-'+cid+'" type="email" value="'+escHtml(c.contactEmail||'')+'"/></div>' +
          '<div class="sa-ff"><label>Contact Phone</label><input id="ec-phone-'+cid+'" value="'+escHtml(c.contactPhone||'')+'"/></div>' +
          '<div class="sa-ff"><label>Payout Schedule</label>' +
            '<select id="ec-sched-'+cid+'">' +
              '<option value="weekly"'+((c.payoutSchedule||'weekly')==='weekly'?' selected':'')+'>Weekly</option>' +
              '<option value="monthly"'+(c.payoutSchedule==='monthly'?' selected':'')+'>Monthly</option>' +
            '</select>' +
          '</div>' +
          '<div class="sa-ff"><label>Subscription Package</label>' +
            '<select id="ec-pkg-'+cid+'">' + buildPkgOptions(c.packageId) + '</select>' +
          '</div>' +
        '</div>' +
        '<div class="sa-ff" style="margin-bottom:12px">' +
          '<label>Internal Notes <span style="color:#aaa;font-size:10px;font-weight:400">(not visible to company)</span></label>' +
          '<textarea id="ec-notes-'+cid+'" rows="2" style="width:100%;padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;font-family:inherit;box-sizing:border-box;resize:vertical">'+escHtml(c.notes||c.internalNotes||'')+'</textarea>' +
        '</div>' +
        '<div style="display:flex;gap:8px;margin-bottom:14px;align-items:center">' +
          '<button class="sa-btn sa-btn-p" style="font-size:11px" onclick="saveCompanyEdit(\''+cid+'\')">Save Changes</button>' +
          '<button class="sa-btn sa-btn-n" style="font-size:11px" onclick="toggleEditRow(\''+cid+'\')">Cancel</button>' +
          '<span style="flex:1"></span>' +
          '<button class="sa-btn" style="font-size:11px;background:#FFEBEE;color:#C62828;border:1px solid #EF9A9A" onclick="wipeTestData(\''+cid+'\')" title="Delete trips from test drivers (D001/D002) and skeleton booking stubs for this company">&#129529; Wipe Test Data</button>' +
        '</div>' +
        '<div style="border-top:1px solid #BBDEFB;padding-top:12px">' +
          '<div style="font-size:12px;font-weight:600;color:#37474F;margin-bottom:8px">&#128273; Company Portal Password</div>' +
          '<div style="font-size:12px;color:#888;margin-bottom:8px">This is the password the company owner uses to log into the <strong>Company Portal</strong>.</div>' +
          '<div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">' +
            '<input id="ec-pass-'+cid+'" type="password" placeholder="New password" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:180px"/>' +
            '<button class="sa-btn sa-btn-s" style="font-size:11px" onclick="setCompanyPassword(\''+cid+'\')">Set Password</button>' +
            '<span id="ec-pass-msg-'+cid+'" style="font-size:12px;color:#555"></span>' +
          '</div>' +
        '</div>' +
      '</div>' +
    '</td></tr>';
  });
  tbody.innerHTML = rows;

  tbody.querySelectorAll('.mod-chip').forEach(function(chip){
    chip.addEventListener('click', function(){
      var row = this.closest('tr');
      var cid = row.dataset.cid;
      var mod = this.dataset.mod;
      var isOn = this.classList.contains('mod-on');

      // Over-plan guard: warn before enabling a module not in the assigned plan
      if (!isOn) {
        var c = allCompanies && allCompanies[cid];
        var pkg = c && c.packageId && allPackages && allPackages[c.packageId];
        if (pkg && !(pkg.modules && pkg.modules[mod])) {
          var modLabel = {taxi:'Taxi',food:'Food Delivery',freight:'Freight'}[mod] || mod;
          if (!confirm(modLabel + ' is not included in the \u201c' + (pkg.name || c.packageId) + '\u201d plan.\n\nEnabling it will put this company over their plan. Continue anyway?')) return;
        }
      }

      var upd = {}; upd['modules/'+mod] = !isOn;
      db.ref(SUPER_PATH+'/'+cid).update(upd).then(function(){
        showNotice('Module updated for company '+cid, 'ok');
      }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
    });
  });

  tbody.querySelectorAll('.del-company-btn').forEach(function(btn){
    btn.addEventListener('click', function(){
      openDeleteModal(this.dataset.cid, this.dataset.name);
    });
  });
}

var suspendTargetCid = null, suspendTargetName = '';
function writeClientAudit(action, cid, cidName, detail){
  var saEmail=(firebase.auth().currentUser||{}).email||'sa-admin';
  var ts=Date.now();
  var rand=Math.random().toString(36).slice(2,7).toUpperCase();
  db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:action,actor:saEmail,cid:String(cid||''),cidName:cidName||'',detail:detail||'',ts:ts});
}
function openSuspendModal(cid){
  suspendTargetCid=cid;
  var c=allCompanies[cid]||{};
  suspendTargetName=c.name||cid;
  document.getElementById('suspend-company-name').textContent=suspendTargetName+' (ID: '+cid+')';
  document.getElementById('suspend-reason').value='';
  document.getElementById('modal-suspend').classList.add('open');
}
function closeSuspendModal(){ document.getElementById('modal-suspend').classList.remove('open'); }
function confirmSuspend(){
  var reason=(document.getElementById('suspend-reason').value||'').trim();
  if(!reason){ showNotice('Please enter a reason for suspension.','err'); return; }
  var btn=document.getElementById('suspend-confirm-btn');
  btn.disabled=true; btn.textContent='Suspending…';
  var now=Date.now();
  db.ref(SUPER_PATH+'/'+suspendTargetCid).update({status:'suspended',suspendReason:reason,suspendedAt:now,sessionRevoke:now}).then(function(){
    writeClientAudit('company_suspended',suspendTargetCid,suspendTargetName,'Suspended — reason: '+reason+' | sessions revoked');
    closeSuspendModal();
    showNotice(suspendTargetName+' suspended successfully.','ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); })
    .finally(function(){ btn.disabled=false; btn.textContent='Suspend Company'; });
}
function setStatus(cid, newStatus){
  var c=allCompanies[cid]||{};
  var name=c.name||cid;
  var upd={status:newStatus};
  if(newStatus==='active'){ upd.suspendReason=null; upd.suspendedAt=null; }
  db.ref(SUPER_PATH+'/'+cid).update(upd).then(function(){
    if(newStatus==='active') writeClientAudit('company_reactivated',cid,name,'Company reactivated');
    showNotice('Company '+cid+' '+(newStatus==='active'?'reactivated':'updated')+' successfully.','ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function buildPkgOptions(currentPkgId){
  var opts = '<option value="">-- No package assigned --</option>';
  Object.keys(allPackages).sort(function(a,b){
    return (allPackages[a].sortOrder||99)-(allPackages[b].sortOrder||99);
  }).forEach(function(id){
    var p = allPackages[id];
    var sel = id === currentPkgId ? ' selected' : '';
    opts += '<option value="'+id+'"'+sel+'>'+escHtml(p.name||id)+(p.monthlyPrice!=null?' — $'+p.monthlyPrice+'/mo':'')+'</option>';
  });
  return opts;
}

function toggleEditRow(cid){
  var row = document.getElementById('edit-row-'+cid);
  if(!row) return;
  var isOpen = row.style.display !== 'none';
  row.style.display = isOpen ? 'none' : 'table-row';
}

function wipeTestData(cid){
  var name = (allCompanies[cid] && allCompanies[cid].name) || cid;
  var idsRaw = prompt(
    'Wipe test data for "'+name+'"\n\n'+
    'This deletes from this company:\n'+
    '  • All trips by the listed test driver IDs (allbookings + completedJobs)\n'+
    '  • All "skeleton" booking stubs (records with status only, no fare/address/driver)\n'+
    '  • driverEarnings entries for those test drivers\n\n'+
    'Real bookings and other drivers are NOT touched.\n\n'+
    'Test driver IDs to wipe (comma-separated):',
    'D001,D002'
  );
  if(idsRaw===null) return;
  var ids = idsRaw.split(',').map(function(s){return s.trim();}).filter(Boolean);
  if(!ids.length){ showNotice('No driver IDs provided.','err'); return; }
  if(!confirm('Confirm: delete test trips for drivers ['+ids.join(', ')+'] from company '+cid+'?\n\nThis cannot be undone.')) return;
  showNotice('Wiping test data…','ok');
  fetch('/api/admin/wipe-test-data',{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({cid:cid, testDriverIds:ids, wipeStubs:true})
  }).then(function(r){return r.json();}).then(function(j){
    if(j.error){ showNotice('Error: '+j.error,'err'); return; }
    var d = j.deleted || {};
    showNotice('Deleted: '+d.allbookings+' allbookings, '+d.completedJobs+' completedJobs, '+d.driverEarnings+' driverEarnings.','ok');
    writeClientAudit('test_data_wiped',cid,name,'Wiped test data: drivers=['+ids.join(',')+'], allbookings='+d.allbookings+', completedJobs='+d.completedJobs);
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function saveCompanyEdit(cid){
  var name = document.getElementById('ec-name-'+cid).value.trim();
  if(!name){ showNotice('Company name cannot be empty.','err'); return; }
  var pkgId = document.getElementById('ec-pkg-'+cid).value;
  var pkg = pkgId && allPackages[pkgId] ? allPackages[pkgId] : null;
  var pkgName = pkg ? pkg.name : '';
  var upd = {
    name:    name,
    city:    document.getElementById('ec-city-'+cid).value.trim(),
    country: document.getElementById('ec-country-'+cid).value.trim(),
    contactEmail: document.getElementById('ec-email-'+cid).value.trim(),
    contactPhone: document.getElementById('ec-phone-'+cid).value.trim(),
    payoutSchedule: document.getElementById('ec-sched-'+cid).value,
    packageId:   pkgId || null,
    packageName: pkgName || null,
    notes: document.getElementById('ec-notes-'+cid).value.trim() || null
  };
  // When a paid package is assigned, clear legacy trial fields so other pages
  // (SA-Billing, Owner Portal) stop showing "Free Trial" / "free_trial".
  // Trial-type packages (pkg_trial / trialDays > 0) keep the trial fields intact.
  if (pkg && !pkg.trialDays && pkgId !== 'pkg_trial') {
    upd.plan          = null;
    upd.trialEnd      = null;
    upd.trialEndsAt   = null;
    upd.trialStart    = null;
    upd.trialStartedAt = null;
    upd.trialDays     = null;
    upd.onTrial       = null;
    upd.isTrial       = null;
    upd.trial         = null;
    upd.subscriptionStatus = 'active';
  }
  db.ref(SUPER_PATH+'/'+cid).update(upd).then(function(){
    showNotice('Company '+cid+' updated successfully.','ok');
    toggleEditRow(cid);
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function setCompanyPassword(cid){
  var pass = document.getElementById('ec-pass-'+cid).value;
  var msg  = document.getElementById('ec-pass-msg-'+cid);
  if(!pass || pass.length < 4){ msg.style.color='#C62828'; msg.textContent='Password must be at least 4 characters.'; return; }
  var name = document.getElementById('ec-name-'+cid).value.trim();
  msg.style.color='#888'; msg.textContent='Saving…';
  fetch('/api/set-company-password', {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ cid: cid, name: name||('Company '+cid), password: pass })
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){
      msg.style.color='#2E7D32';
      msg.textContent='✓ Password set. Login at /company-portal with ID '+cid+'.';
      document.getElementById('ec-pass-'+cid).value='';
    } else {
      msg.style.color='#C62828';
      msg.textContent='Error: '+(d.error||'unknown');
    }
  }).catch(function(e){ msg.style.color='#C62828'; msg.textContent='Error: '+e.message; });
}

function saveNewCompany(){
  var cid = (document.getElementById('f-id').value||'').trim();
  var name = (document.getElementById('f-name').value||'').trim();
  if(!cid||!name){ document.getElementById('add-msg').textContent='Company ID and Name are required.'; return; }
  var email = document.getElementById('f-email').value.trim();
  var payload = {
    name: name,
    city: document.getElementById('f-city').value.trim(),
    country: document.getElementById('f-country').value.trim(),
    contactEmail: email,
    contactPhone: document.getElementById('f-phone').value.trim(),
    payoutSchedule: document.getElementById('f-sched').value,
    status: 'active',
    joinedAt: new Date().toISOString(),
    modules: {
      taxi: document.getElementById('f-m-taxi').checked,
      food: document.getElementById('f-m-food').checked,
      freight: document.getElementById('f-m-freight').checked
    }
  };
  _fbGet(SUPER_PATH+'/'+cid).then(function(data){
    if(data){ document.getElementById('add-msg').textContent='Company ID '+cid+' already exists.'; return; }
    return db.ref(SUPER_PATH+'/'+cid).set(payload).then(function(){
      ['f-id','f-name','f-city','f-country','f-email','f-phone'].forEach(function(i){ document.getElementById(i).value=''; });
      document.getElementById('f-m-taxi').checked=true;
      document.getElementById('f-m-food').checked=false;
      document.getElementById('f-m-freight').checked=false;
      toggleAddForm();
      if(email){
        fetch('/api/admin/grant-access',{
          method:'POST',
          headers:{'Content-Type':'application/json'},
          body: JSON.stringify({email:email, companyId:cid})
        }).then(function(r){ return r.json(); }).then(function(d){
          if(d.success){
            showNotice('Company '+cid+' registered and panel access granted to '+email+'.','ok');
          } else {
            showNotice('Company '+cid+' registered. Owner panel access not auto-granted (owner must sign up to Firebase first). Use "Grant Access" from the company row.','warn');
          }
        }).catch(function(){ showNotice('Company '+cid+' registered. Could not auto-grant panel access — use manual Grant Access.','warn'); });
      } else {
        showNotice('Company '+cid+' registered. No owner email provided — use Grant Access to enable owner panel login.','ok');
      }
    });
  }).catch(function(e){ document.getElementById('add-msg').textContent='Error: '+e.message; });
}

function escHtml(s){ return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function escAttr(s){ return String(s).replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/'/g,'&#39;'); }


var _deleteTarget = null;

function openDeleteModal(cid, name) {
  _deleteTarget = { cid: cid, name: name };
  document.getElementById('del-company-name').textContent = name + ' (ID: ' + cid + ')';
  document.getElementById('del-confirm-input').value = '';
  document.getElementById('del-error').textContent = '';
  document.getElementById('del-btn').disabled = true;
  document.getElementById('modal-delete').classList.add('open');
}

function closeDeleteModal() {
  document.getElementById('modal-delete').classList.remove('open');
  _deleteTarget = null;
}

function confirmDeleteCompany() {
  if (!_deleteTarget) return;
  var typed = (document.getElementById('del-confirm-input').value || '').trim().toUpperCase();
  if (typed !== 'DELETE') {
    document.getElementById('del-error').textContent = 'Please type DELETE exactly to confirm.';
    return;
  }
  var cid = _deleteTarget.cid;
  var btn = document.getElementById('del-btn');
  btn.disabled = true;
  btn.textContent = 'Deleting…';
  document.getElementById('del-error').textContent = '';
  fetch('/api/company/delete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ cid: cid })
  }).then(function(r){ return r.json(); }).then(function(d){
    if (d.ok) {
      var deletedName = _deleteTarget ? _deleteTarget.name : cid;
      closeDeleteModal();
      showNotice(deletedName + ' has been permanently deleted.', 'ok');
    } else {
      document.getElementById('del-error').textContent = 'Error: ' + (d.error || 'unknown');
      btn.disabled = false;
      btn.textContent = 'Permanently Delete';
    }
  }).catch(function(e){
    document.getElementById('del-error').textContent = 'Error: ' + e.message;
    btn.disabled = false;
    btn.textContent = 'Permanently Delete';
  });
}

/* ── Bulk actions ──────────────────────────────────────────────────────────── */
function toggleSelectAll(checked){
  document.querySelectorAll('.co-chk').forEach(function(chk){ chk.checked=checked; });
  updateBulkBar();
}
function updateBulkBar(){
  var checked=document.querySelectorAll('.co-chk:checked');
  var bar=document.getElementById('bulk-bar');
  var lbl=document.getElementById('bulk-count');
  if(checked.length===0){ bar.style.display='none'; }
  else { bar.style.display='flex'; lbl.textContent=checked.length+' compan'+(checked.length!==1?'ies':'y')+' selected'; }
}
function clearBulk(){
  document.querySelectorAll('.co-chk').forEach(function(chk){ chk.checked=false; });
  var allChk=document.getElementById('bulk-select-all'); if(allChk) allChk.checked=false;
  updateBulkBar();
}
function _getCheckedCids(){
  return Array.from(document.querySelectorAll('.co-chk:checked')).map(function(chk){ return {cid:chk.dataset.cid,name:chk.dataset.name,status:chk.dataset.status}; });
}
function bulkSuspend(){
  var items=_getCheckedCids().filter(function(i){ return i.status!=='suspended'; });
  if(!items.length){ showNotice('No active companies selected.','warn'); return; }
  if(!confirm('Suspend '+items.length+' compan'+(items.length!==1?'ies':'y')+'?')) return;
  var writes=items.map(function(i){ return db.ref(SUPER_PATH+'/'+i.cid).update({status:'suspended',suspendedAt:Date.now(),suspendReason:'Bulk suspended by SA admin'}); });
  Promise.all(writes).then(function(){
    showNotice('Suspended '+items.length+' compan'+(items.length!==1?'ies':'y')+'.','ok');
    clearBulk();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}
function bulkActivate(){
  var items=_getCheckedCids().filter(function(i){ return i.status==='suspended'; });
  if(!items.length){ showNotice('No suspended companies selected.','warn'); return; }
  if(!confirm('Activate '+items.length+' compan'+(items.length!==1?'ies':'y')+'?')) return;
  var writes=items.map(function(i){ return db.ref(SUPER_PATH+'/'+i.cid).update({status:'active',suspendedAt:null,suspendReason:null}); });
  Promise.all(writes).then(function(){
    showNotice('Activated '+items.length+' compan'+(items.length!==1?'ies':'y')+'.','ok');
    clearBulk();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}
function exportCsv(){
  if(!allCompanies||!Object.keys(allCompanies).length){ showNotice('No companies loaded yet.','warn'); return; }
  var lines=['Company ID,Name,City,Country,Status,Plan,Payout Schedule,Contact Email,Contact Phone,Modules'];
  Object.entries(allCompanies).forEach(function(entry){
    var cid=entry[0], c=entry[1];
    var mods=[];
    if(c.modules){ if(c.modules.taxi) mods.push('Taxi'); if(c.modules.food) mods.push('Food'); if(c.modules.freight) mods.push('Freight'); }
    lines.push([cid,'"'+(c.name||'').replace(/"/g,'""')+'"',c.city||'',c.country||'',c.status||'active',c.packageName||c.packageId||'',c.payoutSchedule||'weekly',c.contactEmail||'',c.contactPhone||c.phone||'',mods.join('/')].join(','));
  });
  var blob=new Blob([lines.join('\n')],{type:'text/csv'});
  var a=document.createElement('a');
  a.href=URL.createObjectURL(blob);
  a.download='companies-'+new Date().toISOString().slice(0,10)+'.csv';
  a.click();
}

window._fbOnLogin = function(){
  _fbGet('foodClients').then(function(fc){ allFoodClients = fc && typeof fc === 'object' ? fc : {}; }).catch(function(){});
  _fbGet('superPackages').then(function(pkgs){
    allPackages = pkgs && typeof pkgs === 'object' ? pkgs : {};
    _fbGet(SUPER_PATH).then(function(data){
      _fbGet('foodClients').then(function(fc){ allFoodClients = fc && typeof fc === 'object' ? fc : {}; }).catch(function(){});
      renderClients(data);
    });
  }).catch(function(){
    _fbGet(SUPER_PATH).then(function(data){
      renderClients(data);
    });
  });
};
</script>
<div class="modal-overlay" id="modal-delete">
  <div class="modal-box" style="max-width:440px">
    <h3 style="color:#C62828;font-size:16px;font-weight:700;margin-bottom:6px">&#128465; Delete Company</h3>
    <p style="font-size:13px;color:#555;margin-bottom:4px">You are about to permanently delete:</p>
    <div id="del-company-name" style="font-weight:700;color:#0F172A;font-size:14px;padding:10px 14px;background:#FEF2F2;border:1px solid #FECACA;border-radius:8px;margin-bottom:14px"></div>
    <p style="font-size:13px;color:#DC2626;margin-bottom:14px;line-height:1.6"><strong>This cannot be undone.</strong> All company data will be permanently removed — including billing records, payout history, and access credentials.</p>
    <div style="margin-bottom:12px">
      <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:6px;text-transform:uppercase;letter-spacing:.05em">Type <code style="background:#FEE2E2;color:#C62828;padding:1px 5px;border-radius:4px">DELETE</code> to confirm</label>
      <input id="del-confirm-input" type="text" placeholder="DELETE" autocomplete="off"
        style="width:100%;padding:10px 12px;border:1.5px solid #FECACA;border-radius:8px;font-size:14px;font-family:monospace;letter-spacing:.05em"
        oninput="document.getElementById('del-btn').disabled=this.value.trim().toUpperCase()!=='DELETE'"/>
    </div>
    <div id="del-error" style="color:#C62828;font-size:12px;margin-bottom:10px;min-height:16px"></div>
    <div style="display:flex;gap:10px">
      <button id="del-btn" class="sa-btn sa-btn-d" style="flex:1;justify-content:center;font-size:13px;font-weight:700;padding:10px" onclick="confirmDeleteCompany()" disabled>Permanently Delete</button>
      <button class="sa-btn sa-btn-n" style="flex:1;justify-content:center;font-size:13px;padding:10px" onclick="closeDeleteModal()">Cancel</button>
    </div>
  </div>
</div>
<div class="modal-overlay" id="modal-suspend">
  <div class="modal-box" style="max-width:440px">
    <h3 style="color:#E65100">&#128683; Suspend Company</h3>
    <div id="suspend-company-name" style="font-weight:700;color:#0F172A;font-size:14px;padding:10px 14px;background:#FFF3E0;border:1px solid #FFCC80;border-radius:8px;margin-bottom:14px"></div>
    <p style="font-size:13px;color:#555;margin-bottom:10px">The company will be suspended immediately. Their panel access will remain but bookings may be blocked depending on app configuration. This action is logged.</p>
    <div style="margin-bottom:14px">
      <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:6px;text-transform:uppercase;letter-spacing:.05em">Reason for Suspension <span style="color:#C62828">*</span></label>
      <textarea id="suspend-reason" rows="3" placeholder="e.g. Unpaid invoices — 3 months overdue" style="width:100%;padding:10px 12px;border:1.5px solid #FFCC80;border-radius:8px;font-size:13px;font-family:inherit;box-sizing:border-box;resize:vertical"></textarea>
    </div>
    <div style="display:flex;gap:10px">
      <button id="suspend-confirm-btn" class="sa-btn sa-btn-w" style="flex:1;justify-content:center;font-size:13px;font-weight:700;padding:10px" onclick="confirmSuspend()">Suspend Company</button>
      <button class="sa-btn sa-btn-n" style="flex:1;justify-content:center;font-size:13px;padding:10px" onclick="closeSuspendModal()">Cancel</button>
    </div>
  </div>
</div>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
