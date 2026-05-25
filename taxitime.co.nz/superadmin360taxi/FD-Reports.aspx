<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Food Delivery &mdash; Reports &mdash; BookaWaka Admin</title>
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
.fd-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(155px,1fr));gap:14px;margin-bottom:20px}
.fd-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1)}
.fd-stat.main{border-left:4px solid #1565C0}.fd-stat.green{border-left:4px solid #2E7D32}.fd-stat.blue{border-left:4px solid #1565C0}
.fd-stat-v{font-size:22px;font-weight:700;line-height:1.1}
.fd-stat.main .fd-stat-v{color:#1565C0}.fd-stat.green .fd-stat-v{color:#2E7D32}.fd-stat.blue .fd-stat-v{color:#1565C0}
.fd-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.fd-controls{display:flex;gap:10px;align-items:center;margin-bottom:20px;flex-wrap:wrap;background:#F0F7FF;padding:14px 18px;border-radius:8px;border:1px solid #FFE0CC}
.fd-controls label{font-size:13px;font-weight:600;color:#555}
.fd-controls select{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:100px}
.fd-type-btn{padding:7px 16px;border:2px solid #BBDEFB;background:#fff;color:#888;border-radius:4px;cursor:pointer;font-size:13px;font-weight:600;transition:all .15s}
.fd-type-btn.on{background:#1565C0;color:#fff;border-color:#1565C0}
.fd-bar-wrap{background:#E0E0E0;border-radius:4px;height:8px;overflow:hidden;min-width:80px}
.fd-bar-fill{background:#1565C0;height:100%;border-radius:4px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Food Delivery &mdash; Reports &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FD-Reports.aspx" style="font-weight:700;color:#1565C0">&#9658; Reports</a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#128202; Financial Reports</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Commission breakdown — filter by day, week or month.</p>

<div class="fd-controls">
  <label>View by:</label>
  <button class="fd-type-btn on" id="btn-day" onclick="setType('day')">Per Day</button>
  <button class="fd-type-btn" id="btn-week" onclick="setType('week')">Per Week</button>
  <button class="fd-type-btn" id="btn-month" onclick="setType('month')">Per Month</button>
  <label style="margin-left:8px">Period:</label>
  <select id="rpt-period" style="min-width:180px"></select>
  <button onclick="loadReport()" style="padding:7px 16px;background:#1565C0;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:13px;font-weight:600">Load</button>
</div>

<div id="rpt-stats" class="fd-stats"></div>

<div class="fd-card">
  <div class="fd-bar"><h3>Per-Restaurant Breakdown</h3></div>
  <table class="fd-tbl">
    <thead><tr>
      <th>Restaurant</th><th>Orders</th><th>Gross Food Sales</th>
      <th>Food Commission</th><th>Net to Restaurant</th><th>Avg Order Value</th><th>Top Item</th>
    </tr></thead>
    <tbody id="rpt-rest-tb"><tr><td colspan="7" style="text-align:center;padding:30px;color:#9e9e9e">Select a period and click Load.</td></tr></tbody>
    <tfoot><tr id="rpt-rest-foot" style="display:none">
      <td style="text-align:right">Totals:</td>
      <td id="rft2-orders"></td><td id="rft2-gross"></td>
      <td id="rft2-comm"></td><td id="rft2-net"></td><td colspan="2"></td>
    </tr></tfoot>
  </table>
</div>

<div class="fd-card">
  <div class="fd-bar"><h3 id="chart-title">Commission Chart</h3></div>
  <div id="rpt-chart" style="padding:20px">
    <p style="color:#9e9e9e;text-align:center">Load a report to view chart.</p>
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
var curType = 'day';

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
    adminRead('foodClients/' + COMPANY_ID)
  ]).then(function(r) {
    allOrders = r[0] || {};
    allRestaurants = r[1] || {};
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
  if (!sorted.length) {
    sorted = [getPeriodKey(Date.now(), curType)];
  }
  var sel = document.getElementById('rpt-period');
  sel.innerHTML = '';
  sorted.forEach(function(k) {
    var opt = document.createElement('option');
    opt.value = k; opt.textContent = labelPeriod(k, curType); sel.appendChild(opt);
  });
  loadReport();
}

function loadReport() {
  var period = document.getElementById('rpt-period').value;
  if (!period) return;
  var delivered = Object.entries(allOrders).filter(function(e) {
    var o = e[1];
    return o.status === 'delivered' && getPeriodKey(o.createdAt, curType) === period;
  });

  var tOrders=0, tGross=0, tFcomm=0, tDcomm=0, tNet=0, tDrvNet=0;
  delivered.forEach(function(e) {
    var o = e[1];
    tOrders++; tGross+=parseFloat(o.subtotal||0);
    tFcomm+=parseFloat(o.foodCommission||0); tDcomm+=parseFloat(o.deliveryCommission||0);
    tNet+=parseFloat(o.restaurantPayout||0); tDrvNet+=parseFloat(o.driverNet||0);
  });
  var tYou = tFcomm + tDcomm;
  var lbl = labelPeriod(period, curType);
  document.getElementById('chart-title').textContent = 'Commission Chart — ' + lbl;

  document.getElementById('rpt-stats').innerHTML =
    stat(tOrders,'Delivered Orders','main')+
    stat('$'+tGross.toFixed(2),'Gross Food Sales','main')+
    stat('$'+tYou.toFixed(2),'Your Total Commission','green')+
    stat('$'+tFcomm.toFixed(2),'Food Commission','blue')+
    stat('$'+tDcomm.toFixed(2),'Delivery Commission','blue')+
    stat('$'+tNet.toFixed(2),'Paid to Restaurants','')+
    stat('$'+tDrvNet.toFixed(2),'Paid to Drivers','');

  // Per-restaurant aggregate
  var rests = {};
  delivered.forEach(function(e) {
    var o = e[1];
    var rid = o.restaurantId || 'unknown';
    if (!rests[rid]) rests[rid] = { orders:0, gross:0, fcomm:0, net:0, items:{} };
    rests[rid].orders++; rests[rid].gross+=parseFloat(o.subtotal||0);
    rests[rid].fcomm+=parseFloat(o.foodCommission||0); rests[rid].net+=parseFloat(o.restaurantPayout||0);
    (o.items||[]).forEach(function(it) {
      var nm = it.name||'?';
      rests[rid].items[nm] = (rests[rid].items[nm]||0) + (it.qty||1);
    });
  });

  var tb = document.getElementById('rpt-rest-tb');
  var rkeys = Object.keys(rests);
  if (!rkeys.length) {
    tb.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:30px;color:#9e9e9e">No delivered orders for this period.</td></tr>';
    document.getElementById('rpt-rest-foot').style.display='none';
    renderChart([]);
    return;
  }
  var tot2o=0,tot2g=0,tot2c=0,tot2n=0;
  var maxGross = Math.max.apply(null, rkeys.map(function(r){return rests[r].gross;}));
  tb.innerHTML = rkeys.sort(function(a,b){return rests[b].gross-rests[a].gross;}).map(function(rid) {
    var r = rests[rid]; tot2o+=r.orders; tot2g+=r.gross; tot2c+=r.fcomm; tot2n+=r.net;
    var rName = (allRestaurants[rid]||{}).name||rid;
    var avg = r.orders ? (r.gross/r.orders).toFixed(2) : '0.00';
    var topItem = Object.keys(r.items).sort(function(a,b){return r.items[b]-r.items[a];})[0]||'—';
    var barPct = maxGross ? Math.round((r.gross/maxGross)*100) : 0;
    return '<tr>'+
      '<td><strong>'+esc(rName)+'</strong></td>'+
      '<td style="font-weight:600">'+r.orders+'</td>'+
      '<td><div style="display:flex;align-items:center;gap:8px">'+
        '<div class="fd-bar-wrap"><div class="fd-bar-fill" style="width:'+barPct+'%"></div></div>'+
        '<span>$'+r.gross.toFixed(2)+'</span></div></td>'+
      '<td style="color:#1565C0;font-weight:700">$'+r.fcomm.toFixed(2)+'</td>'+
      '<td style="color:#2E7D32;font-weight:700">$'+r.net.toFixed(2)+'</td>'+
      '<td>$'+avg+'</td>'+
      '<td style="font-size:12px;color:#888">'+esc(topItem)+'</td>'+
    '</tr>';
  }).join('');
  document.getElementById('rft2-orders').textContent=tot2o;
  document.getElementById('rft2-gross').textContent='$'+tot2g.toFixed(2);
  document.getElementById('rft2-comm').textContent='$'+tot2c.toFixed(2);
  document.getElementById('rft2-net').textContent='$'+tot2n.toFixed(2);
  document.getElementById('rpt-rest-foot').style.display='';
  renderChart(rkeys.map(function(rid){ return { name:(allRestaurants[rid]||{}).name||rid, comm:rests[rid].fcomm, gross:rests[rid].gross }; }));
}

function renderChart(rows) {
  var el = document.getElementById('rpt-chart');
  if (!rows.length) { el.innerHTML = '<p style="color:#9e9e9e;text-align:center">No data.</p>'; return; }
  var maxC = Math.max.apply(null, rows.map(function(r){return r.comm;})) || 1;
  el.innerHTML = '<div style="font-size:12px;color:#555;margin-bottom:12px;font-weight:700">Food Commission by Restaurant</div>' +
    rows.sort(function(a,b){return b.comm-a.comm;}).map(function(r) {
      var pct = Math.round((r.comm/maxC)*100);
      return '<div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">'+
        '<div style="width:160px;font-size:12px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;text-align:right;color:#555">'+esc(r.name)+'</div>'+
        '<div style="flex:1;background:#EEE;border-radius:4px;height:24px;overflow:hidden">'+
          '<div style="width:'+pct+'%;background:#1565C0;height:100%;border-radius:4px;display:flex;align-items:center;padding-left:8px;min-width:2px">'+
            (pct>15?'<span style="color:#fff;font-size:11px;font-weight:700;white-space:nowrap">$'+r.comm.toFixed(2)+'</span>':'')+
          '</div>'+
        '</div>'+
        '<span style="font-size:12px;font-weight:700;color:#1565C0;min-width:48px;text-align:right">$'+r.comm.toFixed(2)+'</span>'+
      '</div>';
    }).join('');
}

function stat(v,l,cls){ return '<div class="fd-stat '+cls+'"><div class="fd-stat-v">'+v+'</div><div class="fd-stat-l">'+l+'</div></div>'; }
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body></html>
