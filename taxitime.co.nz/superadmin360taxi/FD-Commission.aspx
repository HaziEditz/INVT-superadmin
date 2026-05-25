<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Food Delivery &mdash; Commission Rates &mdash; BookaWaka Admin</title>
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
.fd-wrap{padding:20px}
.fd-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.fd-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between}
.fd-bar h3{margin:0;font-size:15px;font-weight:600}
.fd-tbl{width:100%;border-collapse:collapse;font-size:13px}
.fd-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tr:hover td{background:#FFFDE7}
.fd-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500}
.fd-btn-p{background:#1565C0;color:#fff}.fd-btn-p:hover{background:#0D47A1}
.fd-btn-s{background:#E8F5E9;color:#2E7D32}.fd-btn-s:hover{background:#C8E6C9}
.fd-btn-c{background:#f5f5f5;color:#555}
.fd-defaults{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:20px;max-width:600px}
.fd-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.fd-ff input,.fd-ff select{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.fd-ff input:focus{outline:none;border-color:#1565C0}
.fd-inline-edit{display:none;align-items:center;gap:6px}
.fd-inline-edit.open{display:flex}
.fd-inline-edit input{width:70px;padding:5px 7px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.fd-inline-edit input:focus{outline:none;border-color:#1565C0}
.comm-val{font-weight:700;color:#1565C0}
.deliv-val{font-weight:700;color:#1565C0}
.fd-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px}
.fd-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.fd-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Food Delivery &mdash; Commission Rates &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FD-Commission.aspx" style="font-weight:700;color:#1565C0">&#9658; Commission Rates</a></li>
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
<div class="fd-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#128181; Commission Rates</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">
  Set default rates applied when adding new restaurants, then adjust per-restaurant below.<br>
  <strong style="color:#1565C0">Food commission</strong> applies to the food subtotal &nbsp;&#8226;&nbsp;
  <strong style="color:#1565C0">Delivery commission</strong> applies to the driver delivery fee.
</p>

<div id="fd-notice" style="display:none" class="fd-notice"></div>

<!-- Global defaults card -->
<div class="fd-card">
  <div class="fd-bar"><h3>&#9881; Global Defaults (pre-fill for new restaurants)</h3></div>
  <div style="padding:18px">
    <div class="fd-defaults">
      <div class="fd-ff">
        <label>Default Food Commission %</label>
        <input id="def-fcomm" type="number" step="0.5" min="0" max="50" placeholder="e.g. 15"/>
      </div>
      <div class="fd-ff">
        <label>Default Delivery Commission %</label>
        <input id="def-dcomm" type="number" step="0.5" min="0" max="50" placeholder="e.g. 10"/>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
      <button class="fd-btn fd-btn-p" onclick="saveDefaults()">Save Defaults</button>
      <span id="def-msg" style="font-size:12.5px;color:#888"></span>
    </div>
  </div>
</div>

<!-- Per-restaurant table -->
<div class="fd-card">
  <div class="fd-bar">
    <h3>Per-Restaurant Commission Rates <small id="comm-count" style="opacity:.75;font-size:12px"></small></h3>
    <button onclick="loadData()" style="background:rgba(255,255,255,.15);color:#fff;border:none;cursor:pointer;padding:5px 10px;border-radius:4px;font-size:12px">&#8635; Refresh</button>
  </div>
  <div style="overflow-x:auto">
    <table class="fd-tbl">
      <thead><tr>
        <th>Restaurant</th>
        <th>Food Comm %<br><span style="font-weight:400;font-size:11px;color:#888">on food subtotal</span></th>
        <th>Delivery Comm %<br><span style="font-weight:400;font-size:11px;color:#888">on delivery fee</span></th>
        <th>Driver Pay<br><span style="font-weight:400;font-size:11px;color:#888">flat $ or %</span></th>
        <th>Driver Schedule</th>
        <th>Example: $50 food + $8 delivery</th>
        <th>Payout Schedule</th>
        <th>Status</th>
        <th>Edit</th>
      </tr></thead>
      <tbody id="comm-tb"><tr><td colspan="9" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
    </table>
  </div>
</div>

</div>
</div></div>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script src="assets/js/fd-multi-company.js"></script>
<script>
var restaurants = {};
var defaults = {};

window._fbOnLogin = function() {
  Promise.all([
    adminRead('foodClients/' + COMPANY_ID),
    adminRead('foodConfig/' + COMPANY_ID + '/commissionDefaults')
  ]).then(function(r){
    restaurants = r[0] || {};
    defaults = r[1] || {};
    document.getElementById('def-fcomm').value = defaults.foodCommissionPct || '';
    document.getElementById('def-dcomm').value = defaults.deliveryCommissionPct || '';
    renderTable();
  });
};

function loadData() {
  adminRead('foodClients/' + COMPANY_ID).then(function(d){
    restaurants = d || {};
    renderTable();
  });
}

function renderTable() {
  var keys = Object.keys(restaurants);
  document.getElementById('comm-count').textContent = '(' + keys.length + ')';
  var tb = document.getElementById('comm-tb');
  if (!keys.length) {
    tb.innerHTML = '<tr><td colspan="9" style="text-align:center;padding:40px;color:#9e9e9e">No restaurants yet. <a href="FD-Restaurants.aspx" style="color:#1565C0">Add one here.</a></td></tr>';
    return;
  }
  keys.sort(function(a,b){ return (restaurants[a].name||'').localeCompare(restaurants[b].name||''); });
  tb.innerHTML = keys.map(function(id) {
    var r = restaurants[id];
    var fc = parseFloat(r.foodCommissionPct||0);
    var dc = parseFloat(r.deliveryCommissionPct||0);
    var dpModel = r.driverPayModel||'flat';
    var dpAmount = parseFloat(r.driverPayAmount||0);
    var dpSchedule = r.driverPaySchedule||'weekly';
    var exFood = 50 * fc / 100;
    var exDeliv = 8 * dc / 100;
    var exTotal = exFood + exDeliv;
    var exRestPay = 50 - exFood;
    var dpDisplay = dpModel==='flat' ? '$'+dpAmount.toFixed(2)+' flat' : dpAmount+'% of fee';
    var schedColor = dpSchedule==='instant'?'#C62828':dpSchedule==='weekly'?'#1565C0':'#5D4037';
    var active = r.active !== false;
    return '<tr id="row-'+id+'">' +
      '<td><strong>'+esc(r.name||'—')+'</strong><br><small style="color:#999">'+esc(r.email||'')+'</small></td>' +
      '<td>' +
        '<div id="disp-fc-'+id+'"><span class="comm-val">'+fc+'%</span></div>' +
        '<div class="fd-inline-edit" id="edit-fc-'+id+'">' +
          '<input type="number" step="0.5" min="0" max="50" value="'+fc+'" id="inp-fc-'+id+'" style="width:75px"/>' +
          '<span style="font-size:12px;color:#888">%</span>' +
        '</div>' +
      '</td>' +
      '<td>' +
        '<div id="disp-dc-'+id+'"><span class="deliv-val">'+dc+'%</span></div>' +
        '<div class="fd-inline-edit" id="edit-dc-'+id+'">' +
          '<input type="number" step="0.5" min="0" max="50" value="'+dc+'" id="inp-dc-'+id+'" style="width:75px"/>' +
          '<span style="font-size:12px;color:#888">%</span>' +
        '</div>' +
      '</td>' +
      '<td>' +
        '<div id="disp-dp-'+id+'"><span style="font-weight:700;color:#283593">'+dpDisplay+'</span></div>' +
        '<div class="fd-inline-edit" id="edit-dp-'+id+'" style="flex-direction:column;gap:4px">' +
          '<div style="display:flex;gap:6px;align-items:center">' +
            '<select id="sel-dpm-'+id+'" style="padding:4px;border:1px solid #ddd;border-radius:4px;font-size:12px">' +
              '<option value="flat"'+(dpModel==='flat'?' selected':'')+'>Flat $</option>' +
              '<option value="percent"'+(dpModel==='percent'?' selected':'')+'>% of fee</option>' +
            '</select>' +
            '<input type="number" step="0.01" min="0" value="'+dpAmount+'" id="inp-dp-'+id+'" style="width:65px;padding:4px;border:1px solid #ddd;border-radius:4px;font-size:12px"/>' +
          '</div>' +
          '<select id="sel-dps-'+id+'" style="padding:4px;border:1px solid #ddd;border-radius:4px;font-size:12px">' +
            '<option value="instant"'+(dpSchedule==='instant'?' selected':'')+'>Instant</option>' +
            '<option value="weekly"'+(dpSchedule==='weekly'?' selected':'')+'>Weekly</option>' +
            '<option value="monthly"'+(dpSchedule==='monthly'?' selected':'')+'>Monthly</option>' +
          '</select>' +
        '</div>' +
      '</td>' +
      '<td><span style="font-size:12px;font-weight:600;color:'+schedColor+'">'+dpSchedule+'</span></td>' +
      '<td style="font-size:12px;color:#555">' +
        '<span style="color:#1565C0">$'+exFood.toFixed(2)+'</span> food + ' +
        '<span style="color:#1565C0">$'+exDeliv.toFixed(2)+'</span> deliv = ' +
        '<strong>$'+exTotal.toFixed(2)+'</strong> BW<br>' +
        '<span style="color:#2E7D32">$'+exRestPay.toFixed(2)+'</span> rest.' +
      '</td>' +
      '<td style="font-size:12px">'+esc(r.payoutSchedule||'weekly')+'</td>' +
      '<td><span style="display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600;' +
        (active?'background:#E8F5E9;color:#2E7D32':'background:#FFEBEE;color:#C62828') + '">' +
        (active?'Active':'Inactive')+'</span></td>' +
      '<td style="white-space:nowrap">' +
        '<div id="btn-edit-'+id+'">' +
          '<button class="fd-btn fd-btn-p" onclick="startEdit(\''+id+'\')" style="font-size:12px;padding:5px 11px">Edit</button>' +
        '</div>' +
        '<div id="btn-save-'+id+'" style="display:none;gap:6px;flex-wrap:nowrap;align-items:center">' +
          '<button class="fd-btn fd-btn-s" onclick="saveRow(\''+id+'\')" style="font-size:12px;padding:5px 11px">Save</button>' +
          '<button class="fd-btn fd-btn-c" onclick="cancelEdit(\''+id+'\')" style="font-size:12px;padding:5px 11px">Cancel</button>' +
        '</div>' +
      '</td>' +
    '</tr>';
  }).join('');
}

function startEdit(id) {
  ['fc','dc'].forEach(function(k){
    document.getElementById('disp-'+k+'-'+id).style.display='none';
    document.getElementById('edit-'+k+'-'+id).classList.add('open');
  });
  document.getElementById('disp-dp-'+id).style.display='none';
  document.getElementById('edit-dp-'+id).classList.add('open');
  document.getElementById('btn-edit-'+id).style.display='none';
  document.getElementById('btn-save-'+id).style.display='flex';
  document.getElementById('inp-fc-'+id).focus();
}

function cancelEdit(id) {
  var r = restaurants[id];
  document.getElementById('inp-fc-'+id).value = r.foodCommissionPct||0;
  document.getElementById('inp-dc-'+id).value = r.deliveryCommissionPct||0;
  document.getElementById('inp-dp-'+id).value = r.driverPayAmount||0;
  ['fc','dc'].forEach(function(k){
    document.getElementById('disp-'+k+'-'+id).style.display='';
    document.getElementById('edit-'+k+'-'+id).classList.remove('open');
  });
  document.getElementById('disp-dp-'+id).style.display='';
  document.getElementById('edit-dp-'+id).classList.remove('open');
  document.getElementById('btn-edit-'+id).style.display='';
  document.getElementById('btn-save-'+id).style.display='none';
}

function saveRow(id) {
  var fc = parseFloat(document.getElementById('inp-fc-'+id).value);
  var dc = parseFloat(document.getElementById('inp-dc-'+id).value);
  var dpModel = document.getElementById('sel-dpm-'+id).value;
  var dpAmount = parseFloat(document.getElementById('inp-dp-'+id).value)||0;
  var dpSchedule = document.getElementById('sel-dps-'+id).value;
  if (isNaN(fc)||fc<0||fc>100) { showNotice('Invalid food commission for '+esc(restaurants[id].name||id), false); return; }
  if (isNaN(dc)||dc<0||dc>100) { showNotice('Invalid delivery commission for '+esc(restaurants[id].name||id), false); return; }
  var patch = { foodCommissionPct: fc, deliveryCommissionPct: dc, driverPayModel: dpModel, driverPayAmount: dpAmount, driverPaySchedule: dpSchedule, updatedAt: Date.now() };
  var p1 = adminWrite('foodClients/' + COMPANY_ID + '/' + id, 'PATCH', patch);
  var p2 = fetch('/api/sa-food-driver-pay', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ companyId: COMPANY_ID, restaurantId: id, model: dpModel, amount: dpAmount, schedule: dpSchedule })
  });
  Promise.all([p1, p2]).then(function(){
    restaurants[id].foodCommissionPct = fc;
    restaurants[id].deliveryCommissionPct = dc;
    restaurants[id].driverPayModel = dpModel;
    restaurants[id].driverPayAmount = dpAmount;
    restaurants[id].driverPaySchedule = dpSchedule;
    cancelEdit(id);
    showNotice('Saved commission + driver pay for '+esc(restaurants[id].name||id), true);
    renderTable();
  }).catch(function(e){ showNotice('Save failed: '+e.message, false); });
}

function saveDefaults() {
  var fc = parseFloat(document.getElementById('def-fcomm').value);
  var dc = parseFloat(document.getElementById('def-dcomm').value);
  if (isNaN(fc)||fc<0) { document.getElementById('def-msg').textContent='Enter a valid food %'; return; }
  if (isNaN(dc)||dc<0) { document.getElementById('def-msg').textContent='Enter a valid delivery %'; return; }
  var data = { foodCommissionPct: fc, deliveryCommissionPct: dc, updatedAt: Date.now() };
  adminWrite('foodConfig/' + COMPANY_ID + '/commissionDefaults', 'PUT', data).then(function(){
    defaults = data;
    document.getElementById('def-msg').textContent = '&#10003; Saved!';
    document.getElementById('def-msg').style.color = '#2E7D32';
    setTimeout(function(){ document.getElementById('def-msg').textContent=''; }, 2500);
  }).catch(function(e){
    document.getElementById('def-msg').textContent = 'Save failed: ' + e.message;
    document.getElementById('def-msg').style.color = '#C62828';
  });
}

function showNotice(msg, ok) {
  var el = document.getElementById('fd-notice');
  el.textContent = msg;
  el.className = 'fd-notice ' + (ok?'ok':'err');
  el.style.display = '';
  clearTimeout(el._t);
  el._t = setTimeout(function(){ el.style.display='none'; }, 3500);
}

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body></html>
