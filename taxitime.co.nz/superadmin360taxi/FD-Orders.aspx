<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Food Delivery &mdash; Orders &mdash; BookaWaka Admin</title>
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
firebase.initializeApp({
  apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",
  authDomain:"taxilatest.firebaseapp.com",
  databaseURL:"https://taxilatest.firebaseio.com",
  projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"
});
</script>
<style>
.fd-wrap{padding:20px}
.fd-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.fd-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between}
.fd-bar h3{margin:0;font-size:15px;font-weight:600}
.fd-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.fd-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tr:hover td{background:#FFFDE7}
.fd-tbl tfoot td{background:#E3F2FD;font-weight:700;color:#0D47A1;border-top:2px solid #BBDEFB}
.bx{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600}
.bx-g{background:#E8F5E9;color:#2E7D32}.bx-r{background:#FFEBEE;color:#C62828}
.bx-o{background:#E3F2FD;color:#1565C0}.bx-b{background:#E3F2FD;color:#1565C0}
.bx-y{background:#FFF8E1;color:#F57F17}.bx-gr{background:#F5F5F5;color:#616161}
.fd-filter{display:flex;gap:12px;align-items:center;flex-wrap:wrap;padding:14px 18px;background:#F0F7FF;border-bottom:1px solid #FFE0CC}
.fd-filter select,.fd-filter input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.fd-filter label{font-size:12.5px;font-weight:600;color:#555}
.fd-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:18px}
.fd-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #1565C0}
.fd-stat-v{font-size:24px;font-weight:700;color:#1565C0;line-height:1.1}
.fd-stat-l{font-size:11.5px;color:#888;margin-top:4px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Food Delivery &mdash; Orders &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FD-Orders.aspx" style="font-weight:700;color:#1565C0">&#9658; All Orders</a></li>
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
  <div id="fd-stats-row" class="fd-stats"></div>
  <div class="fd-card">
    <div class="fd-bar"><h3>&#128203; All Orders <small id="fd-ord-count" style="opacity:.75;font-size:12px"></small></h3>
      <button class="fd-btn" style="background:rgba(255,255,255,.15);color:#fff" onclick="loadOrders()">&#8635; Refresh</button>
    </div>
    <div class="fd-filter">
      <label>Restaurant:</label>
      <select id="flt-rest"><option value="">All Restaurants</option></select>
      <label>Status:</label>
      <select id="flt-status">
        <option value="">All</option>
        <option value="pending">Pending</option>
        <option value="accepted">Accepted</option>
        <option value="preparing">Preparing</option>
        <option value="ready">Ready for Pickup</option>
        <option value="picked_up">Picked Up</option>
        <option value="delivered">Delivered</option>
        <option value="cancelled">Cancelled</option>
      </select>
      <label>Month:</label>
      <select id="flt-month"><option value="">All Months</option></select>
      <button onclick="applyFilters()" style="padding:7px 14px;background:#1565C0;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:13px;font-weight:600">Filter</button>
      <button onclick="clearFilters()" style="padding:7px 14px;background:#eee;color:#333;border:none;border-radius:4px;cursor:pointer;font-size:13px">Clear</button>
    </div>
    <div style="overflow-x:auto">
      <table class="fd-tbl">
        <thead><tr>
          <th>Order ID</th><th>Restaurant</th><th>Customer</th><th>Date &amp; Time</th>
          <th>Subtotal</th><th>Delivery Fee</th><th>Total</th>
          <th>Food Comm</th><th>Deliv Comm</th><th>Your Total</th>
          <th>Rest Payout</th><th>Driver Net</th><th>Status</th>
        </tr></thead>
        <tbody id="fd-ord-tb"><tr><td colspan="13" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
        <tfoot><tr id="fd-ord-foot" style="display:none">
          <td colspan="4" style="text-align:right">Totals:</td>
          <td id="ft-sub"></td><td id="ft-dfee"></td><td id="ft-tot"></td>
          <td id="ft-fcomm" style="color:#1565C0"></td><td id="ft-dcomm" style="color:#1565C0"></td>
          <td id="ft-you" style="color:#2E7D32"></td>
          <td id="ft-rest"></td><td id="ft-drv"></td><td></td>
        </tr></tfoot>
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
var allOrders = {};
var allRestaurants = {};

window._fbOnLogin = function() {
  adminRead('foodClients/' + COMPANY_ID).then(function(d){
    allRestaurants = d || {};
    populateRestaurantFilter();
  });
  loadOrders();
};

function loadOrders() {
  document.getElementById('fd-ord-tb').innerHTML = '<tr><td colspan="13" style="text-align:center;padding:30px;color:#9e9e9e">Loading&#8230;</td></tr>';
  adminRead('foodOrders/' + COMPANY_ID).then(function(d){
    allOrders = d || {};
    populateMonthFilter();
    applyFilters();
  }).catch(function(){ renderOrders([]); });
}

function populateRestaurantFilter() {
  var sel = document.getElementById('flt-rest');
  var cur = sel.value;
  sel.innerHTML = '<option value="">All Restaurants</option>';
  Object.keys(allRestaurants).sort(function(a,b){ return (allRestaurants[a].name||'').localeCompare(allRestaurants[b].name||''); }).forEach(function(id){
    var opt = document.createElement('option');
    opt.value = id; opt.textContent = allRestaurants[id].name || id;
    if (id === cur) opt.selected = true;
    sel.appendChild(opt);
  });
}

function populateMonthFilter() {
  var months = {};
  Object.values(allOrders).forEach(function(o){ if (o.createdAt) months[new Date(o.createdAt).toISOString().slice(0,7)] = true; });
  var sel = document.getElementById('flt-month');
  var cur = sel.value;
  sel.innerHTML = '<option value="">All Months</option>';
  Object.keys(months).sort().reverse().forEach(function(m){
    var opt = document.createElement('option');
    opt.value = m; opt.textContent = m;
    if (m === cur) opt.selected = true;
    sel.appendChild(opt);
  });
}

function applyFilters() {
  var restF   = document.getElementById('flt-rest').value;
  var statusF = document.getElementById('flt-status').value;
  var monthF  = document.getElementById('flt-month').value;
  var filtered = Object.entries(allOrders).filter(function(e){
    var o = e[1];
    if (restF   && o.restaurantId !== restF) return false;
    if (statusF && o.status !== statusF) return false;
    if (monthF  && (!o.createdAt || new Date(o.createdAt).toISOString().slice(0,7) !== monthF)) return false;
    return true;
  });
  renderOrders(filtered);
}

function clearFilters() {
  document.getElementById('flt-rest').value = '';
  document.getElementById('flt-status').value = '';
  document.getElementById('flt-month').value = '';
  applyFilters();
}

var statusMap = {
  pending:'<span class="bx bx-y">Pending</span>',
  accepted:'<span class="bx bx-b">Accepted</span>',
  preparing:'<span class="bx bx-o">Preparing</span>',
  ready:'<span class="bx" style="background:#F3E5F5;color:#6A1B9A">Ready</span>',
  picked_up:'<span class="bx bx-b">Picked Up</span>',
  delivered:'<span class="bx bx-g">Delivered</span>',
  cancelled:'<span class="bx bx-r">Cancelled</span>'
};

function renderOrders(entries) {
  var tb = document.getElementById('fd-ord-tb');
  document.getElementById('fd-ord-count').textContent = '(' + entries.length + ' orders)';
  if (!entries.length) {
    tb.innerHTML = '<tr><td colspan="13" style="text-align:center;padding:40px;color:#9e9e9e">No orders found.</td></tr>';
    document.getElementById('fd-ord-foot').style.display = 'none';
    renderStats(entries);
    return;
  }
  entries.sort(function(a,b){ return (b[1].createdAt||0)-(a[1].createdAt||0); });
  var tSub=0,tDfee=0,tTot=0,tFcomm=0,tDcomm=0,tYou=0,tRest=0,tDrv=0;
  tb.innerHTML = entries.map(function(e){
    var id=e[0],o=e[1];
    var dt = o.createdAt ? new Date(o.createdAt).toLocaleString('en-NZ',{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'}) : '—';
    var sub=parseFloat(o.subtotal||0), dfee=parseFloat(o.deliveryFee||0), tot=parseFloat(o.total||0);
    var fc=parseFloat(o.foodCommission||0), dc=parseFloat(o.deliveryCommission||0);
    var you=fc+dc, rest=parseFloat(o.restaurantPayout||0), drv=parseFloat(o.driverNet||0);
    tSub+=sub;tDfee+=dfee;tTot+=tot;tFcomm+=fc;tDcomm+=dc;tYou+=you;tRest+=rest;tDrv+=drv;
    var rName = (allRestaurants[o.restaurantId]||{}).name || o.restaurantName || o.restaurantId || '—';
    return '<tr>' +
      '<td style="font-family:monospace;font-size:11px">'+esc(id.slice(-8))+'</td>' +
      '<td>'+esc(rName)+'</td>' +
      '<td>'+esc(o.customerName||'—')+'</td>' +
      '<td style="white-space:nowrap">'+dt+'</td>' +
      '<td>$'+sub.toFixed(2)+'</td>' +
      '<td>$'+dfee.toFixed(2)+'</td>' +
      '<td style="font-weight:600">$'+tot.toFixed(2)+'</td>' +
      '<td style="color:#1565C0;font-weight:700">$'+fc.toFixed(2)+'</td>' +
      '<td style="color:#1565C0;font-weight:700">$'+dc.toFixed(2)+'</td>' +
      '<td style="color:#2E7D32;font-weight:700">$'+you.toFixed(2)+'</td>' +
      '<td>$'+rest.toFixed(2)+'</td>' +
      '<td>$'+drv.toFixed(2)+'</td>' +
      '<td>'+(statusMap[o.status]||('<span class="bx bx-gr">'+esc(o.status||'—')+'</span>'))+'</td>' +
    '</tr>';
  }).join('');
  document.getElementById('ft-sub').textContent='$'+tSub.toFixed(2);
  document.getElementById('ft-dfee').textContent='$'+tDfee.toFixed(2);
  document.getElementById('ft-tot').textContent='$'+tTot.toFixed(2);
  document.getElementById('ft-fcomm').textContent='$'+tFcomm.toFixed(2);
  document.getElementById('ft-dcomm').textContent='$'+tDcomm.toFixed(2);
  document.getElementById('ft-you').textContent='$'+tYou.toFixed(2);
  document.getElementById('ft-rest').textContent='$'+tRest.toFixed(2);
  document.getElementById('ft-drv').textContent='$'+tDrv.toFixed(2);
  document.getElementById('fd-ord-foot').style.display='';
  renderStats(entries);
}

function renderStats(entries) {
  var delivered = entries.filter(function(e){ return e[1].status==='delivered'; });
  var tYou=0,tRest=0,tDrv=0;
  delivered.forEach(function(e){
    var o=e[1];
    tYou += parseFloat(o.foodCommission||0)+parseFloat(o.deliveryCommission||0);
    tRest += parseFloat(o.restaurantPayout||0);
    tDrv  += parseFloat(o.driverNet||0);
  });
  document.getElementById('fd-stats-row').innerHTML =
    stat(entries.length,'Total Orders','') +
    stat(delivered.length,'Completed Orders','') +
    stat('$'+tYou.toFixed(2),'Your Commission (delivered)','') +
    stat('$'+tRest.toFixed(2),'Restaurant Payouts','') +
    stat('$'+tDrv.toFixed(2),'Driver Payouts','');
}

function stat(v,l){ return '<div class="fd-stat"><div class="fd-stat-v">'+v+'</div><div class="fd-stat-l">'+l+'</div></div>'; }
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body></html>
