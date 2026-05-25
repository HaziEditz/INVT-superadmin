<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Food Delivery &mdash; Payouts &mdash; BookaWaka Admin</title>
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
.fd-tbl tfoot td{background:#E3F2FD;font-weight:700;color:#0D47A1;border-top:2px solid #BBDEFB}
.bx{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600}
.bx-g{background:#E8F5E9;color:#2E7D32}.bx-y{background:#FFF8E1;color:#F57F17}
.bx-b{background:#E3F2FD;color:#1565C0}
.fd-tabs{display:flex;gap:0;border-bottom:2px solid #BBDEFB;margin-bottom:20px}
.fd-tab{padding:10px 24px;cursor:pointer;font-size:13px;font-weight:600;color:#888;border-bottom:3px solid transparent;margin-bottom:-2px}
.fd-tab.on{color:#1565C0;border-bottom-color:#1565C0;background:#F0F7FF}
.fd-controls{display:flex;gap:10px;align-items:center;margin-bottom:18px;flex-wrap:wrap;background:#F0F7FF;padding:14px 18px;border-radius:8px;border:1px solid #FFE0CC}
.fd-controls label{font-size:13px;font-weight:600;color:#555}
.fd-controls select{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:100px}
.fd-type-btn{padding:7px 16px;border:2px solid #BBDEFB;background:#fff;color:#888;border-radius:4px;cursor:pointer;font-size:13px;font-weight:600;transition:all .15s}
.fd-type-btn.on{background:#1565C0;color:#fff;border-color:#1565C0}
.fd-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.fd-btn-g{background:#2E7D32;color:#fff}.fd-btn-g:hover{background:#1B5E20}
.fd-btn-p{background:#1565C0;color:#fff}
.fd-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:18px}
.fd-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #1565C0}
.fd-stat-v{font-size:22px;font-weight:700;color:#1565C0}
.fd-stat-l{font-size:11.5px;color:#888;margin-top:4px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Food Delivery &mdash; Payouts &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FD-Payouts.aspx" style="font-weight:700;color:#1565C0">&#9658; Payouts</a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#128181; Payouts</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Review and mark driver and restaurant payouts. Filter by day, week or month.</p>

<div id="fd-payout-stats" class="fd-stats"></div>

<div class="fd-controls">
  <label>Period type:</label>
  <button class="fd-type-btn" id="btn-day" onclick="setType('day')">Per Day</button>
  <button class="fd-type-btn on" id="btn-week" onclick="setType('week')">Per Week</button>
  <button class="fd-type-btn" id="btn-month" onclick="setType('month')">Per Month</button>
  <label style="margin-left:8px">Period:</label>
  <select id="po-period" style="min-width:200px"></select>
  <button onclick="loadPayoutData()" class="fd-btn fd-btn-p">Load</button>
</div>

<div class="fd-tabs">
  <div class="fd-tab on" id="tab-drivers" onclick="switchTab('drivers')">&#128661; Driver Payouts</div>
  <div class="fd-tab" id="tab-restaurants" onclick="switchTab('restaurants')">&#127829; Restaurant Settlements</div>
</div>

<div id="pane-drivers">
<div class="fd-card">
  <div class="fd-bar"><h3>Driver Payouts</h3><small style="opacity:.75;font-size:12px">Commission deducted before payout</small></div>
  <div style="overflow-x:auto">
    <table class="fd-tbl">
      <thead><tr><th>Driver ID</th><th>Deliveries</th><th>Gross Delivery Fees</th>
        <th>Your Commission</th><th>Net to Driver</th><th>Status</th><th>Action</th></tr></thead>
      <tbody id="drv-tb"><tr><td colspan="7" style="text-align:center;padding:30px;color:#9e9e9e">Select a period and click Load.</td></tr></tbody>
      <tfoot><tr id="drv-foot" style="display:none">
        <td colspan="2" style="text-align:right">Totals:</td>
        <td id="dft-gross"></td><td id="dft-comm"></td><td id="dft-net"></td><td colspan="2"></td>
      </tr></tfoot>
    </table>
  </div>
</div></div>

<div id="pane-restaurants" style="display:none">
<div class="fd-card">
  <div class="fd-bar"><h3>Restaurant Settlements</h3><small style="opacity:.75;font-size:12px">Commission deducted before payout</small></div>
  <div style="overflow-x:auto">
    <table class="fd-tbl">
      <thead><tr><th>Restaurant</th><th>Orders</th><th>Gross Food Sales</th>
        <th>Your Commission</th><th>Net to Restaurant</th><th>Status</th><th>Action</th></tr></thead>
      <tbody id="rest-tb"><tr><td colspan="7" style="text-align:center;padding:30px;color:#9e9e9e">Select a period and click Load.</td></tr></tbody>
      <tfoot><tr id="rest-foot" style="display:none">
        <td colspan="2" style="text-align:right">Totals:</td>
        <td id="rft-gross"></td><td id="rft-comm"></td><td id="rft-net"></td><td colspan="2"></td>
      </tr></tfoot>
    </table>
  </div>
</div></div>

</div>
</div></div>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script src="assets/js/fd-multi-company.js"></script>
<script>
var allOrders = {};
var allRestaurants = {};
var allPayouts = {};
var activeTab = 'drivers';
var curType = 'week';

// ── Period key helpers ────────────────────────────────────────────────────────
function getWeekKey(ts) {
  var d = new Date(ts);
  d.setHours(0,0,0,0);
  var day = d.getDay() || 7;
  d.setDate(d.getDate() + 4 - day);
  var yearStart = new Date(d.getFullYear(), 0, 1);
  var weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
  return d.getFullYear() + '-W' + (weekNo < 10 ? '0' + weekNo : weekNo);
}
function getPeriodKey(ts, type) {
  if (!ts) return null;
  if (type === 'day')  return new Date(ts).toISOString().slice(0, 10);
  if (type === 'week') return getWeekKey(ts);
  return new Date(ts).toISOString().slice(0, 7);
}
function labelPeriod(key, type) {
  if (type === 'day') {
    var d = new Date(key + 'T12:00:00Z');
    return d.toLocaleDateString('en-NZ', {weekday:'short',day:'numeric',month:'short',year:'numeric'});
  }
  if (type === 'week') {
    var parts = key.match(/^(\d{4})-W(\d{2})$/);
    if (!parts) return key;
    var jan4 = new Date(parseInt(parts[1]), 0, 4);
    var monday = new Date(jan4.getTime() + (parseInt(parts[2]) - 1) * 7 * 86400000);
    monday.setDate(monday.getDate() - (monday.getDay() || 7) + 1);
    var sunday = new Date(monday.getTime() + 6 * 86400000);
    var fmt = function(d){ return d.toLocaleDateString('en-NZ',{day:'numeric',month:'short'}); };
    return 'Wk ' + parts[2] + ' · ' + fmt(monday) + ' – ' + fmt(sunday) + ' ' + parts[1];
  }
  var d = new Date(key + '-02');
  return d.toLocaleDateString('en-NZ', {month:'long', year:'numeric'});
}

// ── Init ─────────────────────────────────────────────────────────────────────
window._fbOnLogin = function() {
  Promise.all([
    adminRead('foodOrders/' + COMPANY_ID),
    adminRead('foodClients/' + COMPANY_ID),
    adminRead('foodPayouts/' + COMPANY_ID)
  ]).then(function(results) {
    allOrders     = results[0] || {};
    allRestaurants = results[1] || {};
    allPayouts     = results[2] || {};
    buildPeriodSelector();
  });
};

function setType(t) {
  curType = t;
  ['day','week','month'].forEach(function(x){
    document.getElementById('btn-'+x).classList.toggle('on', x===t);
  });
  buildPeriodSelector();
}

function buildPeriodSelector() {
  var keys = {};
  Object.values(allOrders).forEach(function(o) {
    var k = getPeriodKey(o.createdAt, curType);
    if (k) keys[k] = true;
  });
  var sorted = Object.keys(keys).sort().reverse();
  if (!sorted.length) sorted = [getPeriodKey(Date.now(), curType)];
  var sel = document.getElementById('po-period');
  sel.innerHTML = '';
  sorted.forEach(function(k) {
    var opt = document.createElement('option');
    opt.value = k; opt.textContent = labelPeriod(k, curType); sel.appendChild(opt);
  });
  loadPayoutData();
}

function loadPayoutData() {
  var period = document.getElementById('po-period').value;
  if (!period) return;
  var periodOrders = Object.entries(allOrders).filter(function(e) {
    var o = e[1];
    return o.status === 'delivered' && getPeriodKey(o.createdAt, curType) === period;
  });

  var drivers = {};
  periodOrders.forEach(function(e) {
    var o = e[1];
    var did = o.driverId || 'unassigned';
    if (!drivers[did]) drivers[did] = { deliveries:0, gross:0, commission:0, net:0 };
    drivers[did].deliveries++;
    drivers[did].gross      += parseFloat(o.deliveryFee||0);
    drivers[did].commission += parseFloat(o.deliveryCommission||0);
    drivers[did].net        += parseFloat(o.driverNet||0);
  });

  var rests = {};
  periodOrders.forEach(function(e) {
    var o = e[1];
    var rid = o.restaurantId || 'unknown';
    if (!rests[rid]) rests[rid] = { orders:0, gross:0, commission:0, net:0 };
    rests[rid].orders++;
    rests[rid].gross      += parseFloat(o.subtotal||0);
    rests[rid].commission += parseFloat(o.foodCommission||0);
    rests[rid].net        += parseFloat(o.restaurantPayout||0);
  });

  renderDrivers(drivers, period);
  renderRestaurants(rests, period);
  renderPayoutStats(drivers, rests);
}

function renderDrivers(drivers, period) {
  var tb = document.getElementById('drv-tb');
  var keys = Object.keys(drivers);
  if (!keys.length) {
    tb.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:30px;color:#9e9e9e">No delivered orders this period.</td></tr>';
    document.getElementById('drv-foot').style.display = 'none';
    return;
  }
  var tGross=0, tComm=0, tNet=0;
  tb.innerHTML = keys.map(function(did) {
    var d = drivers[did];
    tGross+=d.gross; tComm+=d.commission; tNet+=d.net;
    var saved = (allPayouts.drivers||{})[did]||{};
    var paidStatus = (saved[period]||{}).status || 'pending';
    var badge = paidStatus==='paid'?'<span class="bx bx-g">Paid</span>':'<span class="bx bx-y">Pending</span>';
    var btn = paidStatus==='paid'
      ? '<button class="fd-btn" style="background:#FFEBEE;color:#C62828;padding:5px 10px;font-size:12px" onclick="markDriver(\''+did+'\',\''+period+'\',\'pending\')">Unmark</button>'
      : '<button class="fd-btn fd-btn-g" style="padding:5px 10px;font-size:12px" onclick="markDriver(\''+did+'\',\''+period+'\',\'paid\')">Mark Paid</button>';
    return '<tr>'+
      '<td style="font-family:monospace">'+esc(did)+'</td>'+
      '<td style="font-weight:600">'+d.deliveries+'</td>'+
      '<td>$'+d.gross.toFixed(2)+'</td>'+
      '<td style="color:#1565C0;font-weight:700">-$'+d.commission.toFixed(2)+'</td>'+
      '<td style="color:#2E7D32;font-weight:700">$'+d.net.toFixed(2)+'</td>'+
      '<td>'+badge+'</td><td>'+btn+'</td>'+
    '</tr>';
  }).join('');
  document.getElementById('dft-gross').textContent='$'+tGross.toFixed(2);
  document.getElementById('dft-comm').textContent='-$'+tComm.toFixed(2);
  document.getElementById('dft-net').textContent='$'+tNet.toFixed(2);
  document.getElementById('drv-foot').style.display='';
}

function renderRestaurants(rests, period) {
  var tb = document.getElementById('rest-tb');
  var keys = Object.keys(rests);
  if (!keys.length) {
    tb.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:30px;color:#9e9e9e">No delivered orders this period.</td></tr>';
    document.getElementById('rest-foot').style.display = 'none';
    return;
  }
  var tGross=0, tComm=0, tNet=0;
  tb.innerHTML = keys.map(function(rid) {
    var r = rests[rid];
    tGross+=r.gross; tComm+=r.commission; tNet+=r.net;
    var rName = (allRestaurants[rid]||{}).name || rid;
    var saved = (allPayouts.restaurants||{})[rid]||{};
    var paidStatus = (saved[period]||{}).status || 'pending';
    var badge = paidStatus==='paid'?'<span class="bx bx-g">Paid</span>':'<span class="bx bx-y">Pending</span>';
    var btn = paidStatus==='paid'
      ? '<button class="fd-btn" style="background:#FFEBEE;color:#C62828;padding:5px 10px;font-size:12px" onclick="markRest(\''+rid+'\',\''+period+'\',\'pending\')">Unmark</button>'
      : '<button class="fd-btn fd-btn-g" style="padding:5px 10px;font-size:12px" onclick="markRest(\''+rid+'\',\''+period+'\',\'paid\')">Mark Paid</button>';
    return '<tr>'+
      '<td><strong>'+esc(rName)+'</strong></td>'+
      '<td style="font-weight:600">'+r.orders+'</td>'+
      '<td>$'+r.gross.toFixed(2)+'</td>'+
      '<td style="color:#1565C0;font-weight:700">-$'+r.commission.toFixed(2)+'</td>'+
      '<td style="color:#2E7D32;font-weight:700">$'+r.net.toFixed(2)+'</td>'+
      '<td>'+badge+'</td><td>'+btn+'</td>'+
    '</tr>';
  }).join('');
  document.getElementById('rft-gross').textContent='$'+tGross.toFixed(2);
  document.getElementById('rft-comm').textContent='-$'+tComm.toFixed(2);
  document.getElementById('rft-net').textContent='$'+tNet.toFixed(2);
  document.getElementById('rest-foot').style.display='';
}

function renderPayoutStats(drivers, rests) {
  var totalDriverNet=0, totalRestNet=0, totalComm=0;
  Object.values(drivers).forEach(function(d){ totalDriverNet+=d.net; totalComm+=d.commission; });
  Object.values(rests).forEach(function(r){ totalRestNet+=r.net; totalComm+=r.commission; });
  document.getElementById('fd-payout-stats').innerHTML =
    '<div class="fd-stat"><div class="fd-stat-v">$'+totalComm.toFixed(2)+'</div><div class="fd-stat-l">Your Commission This Period</div></div>'+
    '<div class="fd-stat"><div class="fd-stat-v">$'+totalRestNet.toFixed(2)+'</div><div class="fd-stat-l">To Pay Restaurants</div></div>'+
    '<div class="fd-stat"><div class="fd-stat-v">$'+totalDriverNet.toFixed(2)+'</div><div class="fd-stat-l">To Pay Drivers</div></div>'+
    '<div class="fd-stat"><div class="fd-stat-v">$'+(totalComm+totalRestNet+totalDriverNet).toFixed(2)+'</div><div class="fd-stat-l">Total Collected</div></div>';
}

function markDriver(driverId, period, status) {
  var data = { status: status, updatedAt: Date.now() };
  adminWrite('foodPayouts/' + COMPANY_ID + '/drivers/' + driverId + '/' + encodeKey(period), 'PUT', data).then(function() {
    if (!allPayouts.drivers) allPayouts.drivers = {};
    if (!allPayouts.drivers[driverId]) allPayouts.drivers[driverId] = {};
    allPayouts.drivers[driverId][encodeKey(period)] = data;
    loadPayoutData();
  }).catch(function(e){ alert('Update failed: ' + e.message); });
}

function markRest(restId, period, status) {
  var data = { status: status, updatedAt: Date.now() };
  adminWrite('foodPayouts/' + COMPANY_ID + '/restaurants/' + restId + '/' + encodeKey(period), 'PUT', data).then(function() {
    if (!allPayouts.restaurants) allPayouts.restaurants = {};
    if (!allPayouts.restaurants[restId]) allPayouts.restaurants[restId] = {};
    allPayouts.restaurants[restId][encodeKey(period)] = data;
    loadPayoutData();
  }).catch(function(e){ alert('Update failed: ' + e.message); });
}

function switchTab(tab) {
  activeTab = tab;
  document.getElementById('tab-drivers').classList.toggle('on', tab==='drivers');
  document.getElementById('tab-restaurants').classList.toggle('on', tab==='restaurants');
  document.getElementById('pane-drivers').style.display = tab==='drivers' ? '' : 'none';
  document.getElementById('pane-restaurants').style.display = tab==='restaurants' ? '' : 'none';
}

// Firebase keys cannot contain . # $ [ ] / — replace with _
function encodeKey(k) { return k.replace(/[.#$\[\]\/]/g,'_'); }
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body></html>
