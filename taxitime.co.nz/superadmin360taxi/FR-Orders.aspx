<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Freight Delivery &mdash; Orders &mdash; BookaWaka Admin</title>
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
.fd-bar{background:#37474F;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.fd-bar h3{margin:0;font-size:15px;font-weight:600}
.fd-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.fd-tbl th{background:#ECEFF1;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #B0BEC5;white-space:nowrap;color:#37474F}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tr:hover td{background:#F5F5F5}
.bx{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600}
.bx-g{background:#E8F5E9;color:#2E7D32}.bx-r{background:#FFEBEE;color:#C62828}
.bx-o{background:#E3F2FD;color:#1565C0}.bx-b{background:#E3F2FD;color:#1565C0}
.bx-y{background:#FFF8E1;color:#F57F17}.bx-gr{background:#F5F5F5;color:#616161}
.bx-t{background:#E8F5E9;color:#1B5E20}
.fd-filter{display:flex;gap:12px;align-items:center;flex-wrap:wrap;padding:14px 18px;background:#ECEFF1;border-bottom:1px solid #CFD8DC}
.fd-filter select,.fd-filter input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.fd-filter label{font-size:12.5px;font-weight:600;color:#555}
.fd-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:18px}
.fd-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #37474F}
.fd-stat-v{font-size:24px;font-weight:700;color:#37474F;line-height:1.1}
.fd-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.fr-info-note{background:#ECEFF1;border-left:4px solid #546E7A;padding:10px 16px;border-radius:6px;font-size:13px;color:#546E7A;margin-bottom:18px}
.pod-tick{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.pod-yes{background:#E8F5E9;color:#2E7D32}
.pod-no{background:#FFEBEE;color:#C62828}
.pod-na{background:#F5F5F5;color:#9E9E9E}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Freight Delivery &mdash; Orders &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FD-Commission.aspx">Commission Rates</a></li>
      <li><a href="/restaurant-portal" target="_blank">Restaurant Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Orders.aspx" style="font-weight:700;color:#37474F">&#9658; All Orders</a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px;color:#37474F">&#128230; Freight Delivery &mdash; All Orders</h2>
<p style="font-size:13px;color:#888;margin-bottom:14px">Monitor all freight and parcel delivery orders. Filter by status or date.</p>
<div class="fr-info-note">&#9432; Freight orders are placed via the BookaWaka driver app once the Freight module is activated for a company. Orders appear here in real time.</div>

<div class="fd-stats" id="fr-stats">
  <div class="fd-stat"><div class="fd-stat-v" id="st-total">0</div><div class="fd-stat-l">Total Orders</div></div>
  <div class="fd-stat"><div class="fd-stat-v" id="st-pending" style="color:#F57F17">0</div><div class="fd-stat-l">Pending / Active</div></div>
  <div class="fd-stat"><div class="fd-stat-v" id="st-delivered" style="color:#2E7D32">0</div><div class="fd-stat-l">Delivered</div></div>
  <div class="fd-stat"><div class="fd-stat-v" id="st-rev">$0.00</div><div class="fd-stat-l">Total Revenue</div></div>
</div>

<div class="fd-card">
  <div class="fd-bar"><h3>&#128230; Freight Orders</h3></div>
  <div class="fd-filter">
    <label>Status:</label>
    <select id="fil-status" onchange="applyFilters()">
      <option value="">All</option>
      <option value="pending">Pending</option>
      <option value="assigned">Assigned</option>
      <option value="picked_up">Picked Up</option>
      <option value="in_transit">In Transit</option>
      <option value="delivered">Delivered</option>
      <option value="cancelled">Cancelled</option>
    </select>
    <label>Date:</label>
    <input type="date" id="fil-date" onchange="applyFilters()"/>
    <button onclick="clearFilters()" style="padding:6px 12px;border:1px solid #ddd;border-radius:4px;background:#fff;font-size:12px;cursor:pointer">Clear</button>
  </div>
  <div style="overflow-x:auto">
  <table class="fd-tbl">
    <thead>
      <tr>
        <th>Order ID</th>
        <th>Sender</th>
        <th>Recipient</th>
        <th>Package</th>
        <th>Delivery Fee</th>
        <th>Commission</th>
        <th>Driver</th>
        <th>Status</th>
        <th>Date</th>
        <th>Pickup ✓</th>
        <th>Delivered</th>
        <th>Delivered At</th>
      </tr>
    </thead>
    <tbody id="orders-body">
      <tr><td colspan="12" style="text-align:center;padding:30px;color:#aaa">Loading orders&hellip;</td></tr>
    </tbody>
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
var allOrders = [];

function statusBadge(s){
  var m={pending:'<span class="bx bx-y">Pending</span>',assigned:'<span class="bx bx-b">Assigned</span>',
    picked_up:'<span class="bx bx-o">Picked Up</span>',in_transit:'<span class="bx bx-b">In Transit</span>',
    delivered:'<span class="bx bx-g">Delivered</span>',cancelled:'<span class="bx bx-r">Cancelled</span>'};
  return m[s]||'<span class="bx bx-gr">'+escHtml(s)+'</span>';
}
function escHtml(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDate(ts){ return ts?new Date(ts).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}):'—'; }

function applyFilters(){
  var st=document.getElementById('fil-status').value;
  var dt=document.getElementById('fil-date').value;
  var filtered=allOrders.filter(function(o){
    if(st && o.status!==st) return false;
    if(dt && o.createdAt){
      var d=new Date(o.createdAt).toISOString().slice(0,10);
      if(d!==dt) return false;
    }
    return true;
  });
  renderOrders(filtered);
}

function clearFilters(){
  document.getElementById('fil-status').value='';
  document.getElementById('fil-date').value='';
  renderOrders(allOrders);
}

function podBadge(val, yesLabel, noLabel){
  if(val===true) return '<span class="pod-tick pod-yes">&#10003; '+(yesLabel||'Yes')+'</span>';
  if(val===false) return '<span class="pod-tick pod-no">&#10007; '+(noLabel||'No')+'</span>';
  return '<span class="pod-tick pod-na">—</span>';
}

function renderOrders(orders){
  var tbody=document.getElementById('orders-body');
  if(!orders.length){ tbody.innerHTML='<tr><td colspan="12" style="text-align:center;padding:30px;color:#aaa">No orders found.</td></tr>'; return; }
  var rows='';
  orders.forEach(function(o){
    var fee=+(o.deliveryFee||0);
    var commPct=+(o.commissionPct||10)/100;
    var comm=fee*commPct;
    rows+='<tr>' +
      '<td style="font-family:monospace;font-size:11px;color:#546E7A">'+escHtml((o._id||'').slice(-10))+'</td>' +
      '<td><div style="font-weight:600">'+escHtml(o.senderName||'—')+'</div><div style="font-size:11px;color:#888">'+escHtml(o.senderAddress||'')+'</div></td>' +
      '<td><div style="font-weight:600">'+escHtml(o.recipientName||'—')+'</div><div style="font-size:11px;color:#888">'+escHtml(o.recipientAddress||'')+'</div></td>' +
      '<td style="font-size:12px">'+escHtml(o.packageDesc||'—')+(o.weight?'<br><span style="color:#888">'+o.weight+'kg</span>':'')+'</td>' +
      '<td style="font-weight:600">$'+fee.toFixed(2)+'</td>' +
      '<td style="color:#C62828">-$'+comm.toFixed(2)+'</td>' +
      '<td style="font-size:12px;color:#555">'+escHtml(o.driverId||'Unassigned')+'</td>' +
      '<td>'+statusBadge(o.status)+'</td>' +
      '<td style="font-size:12px;color:#666;white-space:nowrap">'+fmtDate(o.createdAt)+'</td>' +
      '<td>'+podBadge(o.pickupConfirmed,'Confirmed')+'</td>' +
      '<td>'+podBadge(o.deliveryConfirmed,'Delivered','Not yet')+'</td>' +
      '<td style="font-size:12px;color:#666;white-space:nowrap">'+(o.deliveredAt?fmtDate(typeof o.deliveredAt==='string'?new Date(o.deliveredAt).getTime():o.deliveredAt):'—')+'</td>' +
    '</tr>';
  });
  tbody.innerHTML=rows;
}

function updateStats(orders){
  var total=orders.length;
  var pending=orders.filter(function(o){ return o.status&&o.status!=='delivered'&&o.status!=='cancelled'; }).length;
  var delivered=orders.filter(function(o){ return o.status==='delivered'; }).length;
  var rev=orders.filter(function(o){ return o.status==='delivered'; }).reduce(function(s,o){ return s+(+(o.deliveryFee||0)); },0);
  document.getElementById('st-total').textContent=total;
  document.getElementById('st-pending').textContent=pending;
  document.getElementById('st-delivered').textContent=delivered;
  document.getElementById('st-rev').textContent='$'+rev.toFixed(2);
}

window._fbOnLogin = function(){
  var urlCid=(new URLSearchParams(window.location.search)).get('cid');
  if(urlCid) COMPANY_ID=urlCid;
  _fbGet('freightOrders/'+COMPANY_ID).then(function(data){
    data=data||{};
    allOrders=Object.entries(data).map(function(e){ return Object.assign({_id:e[0]},e[1]); })
      .sort(function(a,b){ return (b.createdAt||0)-(a.createdAt||0); });
    updateStats(allOrders);
    applyFilters();
  });
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
