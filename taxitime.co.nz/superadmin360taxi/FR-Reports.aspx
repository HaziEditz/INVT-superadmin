<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Freight Delivery &mdash; Reports &mdash; BookaWaka Admin</title>
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
.fd-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:20px}
.fd-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #37474F}
.fd-stat.green{border-left-color:#2E7D32}.fd-stat.red{border-left-color:#C62828}.fd-stat.blue{border-left-color:#1565C0}
.fd-stat-v{font-size:24px;font-weight:700;color:#37474F;line-height:1.1}
.fd-stat.green .fd-stat-v{color:#2E7D32}.fd-stat.red .fd-stat-v{color:#C62828}.fd-stat.blue .fd-stat-v{color:#1565C0}
.fd-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.period-btn{padding:7px 18px;border:1px solid #ddd;border-radius:4px;background:#fff;font-size:13px;cursor:pointer;font-weight:500}
.period-btn.active{background:#37474F;color:#fff;border-color:#37474F;font-weight:700}
.fd-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.fd-tbl th{background:#ECEFF1;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #B0BEC5;color:#37474F}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tfoot td{background:#ECEFF1;font-weight:700;color:#37474F;border-top:2px solid #B0BEC5}
.fd-tbl tr:hover td{background:#F5F5F5}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Freight Delivery &mdash; Reports &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FR-Orders.aspx">All Orders</a></li>
      <li><a href="FR-Payouts.aspx">Payouts</a></li>
      <li><a href="FR-Reports.aspx" style="font-weight:700;color:#37474F">&#9658; Reports</a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px;color:#37474F">&#128202; Freight Delivery &mdash; Revenue Reports</h2>
<p style="font-size:13px;color:#888;margin-bottom:14px">Freight revenue breakdown for this company. Toggle period to view daily, weekly, or monthly summaries.</p>

<div style="display:flex;gap:8px;margin-bottom:20px;flex-wrap:wrap">
  <button class="period-btn active" id="btn-day" onclick="setPeriod('day')">Today</button>
  <button class="period-btn" id="btn-week" onclick="setPeriod('week')">This Week</button>
  <button class="period-btn" id="btn-month" onclick="setPeriod('month')">This Month</button>
  <button class="period-btn" id="btn-all" onclick="setPeriod('all')">All Time</button>
</div>

<div class="fd-stats" id="rpt-stats">
  <div class="fd-stat"><div class="fd-stat-v" id="rpt-orders">0</div><div class="fd-stat-l">Orders</div></div>
  <div class="fd-stat blue"><div class="fd-stat-v" id="rpt-rev">$0.00</div><div class="fd-stat-l">Gross Revenue</div></div>
  <div class="fd-stat red"><div class="fd-stat-v" id="rpt-comm">$0.00</div><div class="fd-stat-l">BookaWaka Commission</div></div>
  <div class="fd-stat green"><div class="fd-stat-v" id="rpt-net">$0.00</div><div class="fd-stat-l">Company Net</div></div>
</div>

<div class="fd-card">
  <div class="fd-bar"><h3 id="rpt-title">&#128230; Today's Freight Breakdown</h3></div>
  <div style="overflow-x:auto">
  <table class="fd-tbl">
    <thead>
      <tr>
        <th>Period</th>
        <th>Orders</th>
        <th>Delivered</th>
        <th>Cancelled</th>
        <th>Gross Revenue</th>
        <th>Commission</th>
        <th>Net to Company</th>
        <th>Avg. Delivery Fee</th>
      </tr>
    </thead>
    <tbody id="rpt-body">
      <tr><td colspan="8" style="text-align:center;padding:30px;color:#aaa">Loading&hellip;</td></tr>
    </tbody>
    <tfoot><tr>
      <td>Totals</td>
      <td id="ft-orders">0</td>
      <td id="ft-del">0</td>
      <td id="ft-canc">0</td>
      <td id="ft-gross">$0.00</td>
      <td id="ft-comm">$0.00</td>
      <td id="ft-net">$0.00</td>
      <td id="ft-avg">$0.00</td>
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
var allOrders=[];
var curPeriod='day';
var commPct=10;

function setPeriod(p){
  curPeriod=p;
  ['day','week','month','all'].forEach(function(x){ document.getElementById('btn-'+x).classList.remove('active'); });
  document.getElementById('btn-'+p).classList.add('active');
  renderReport();
}

function filterByPeriod(orders,period){
  var now=new Date();
  return orders.filter(function(o){
    if(!o.createdAt || o.status!=='delivered') return false;
    var d=new Date(o.createdAt);
    if(period==='day') return d.toDateString()===now.toDateString();
    if(period==='week'){
      var startOfWeek=new Date(now); startOfWeek.setDate(now.getDate()-now.getDay()); startOfWeek.setHours(0,0,0,0);
      return d>=startOfWeek;
    }
    if(period==='month') return d.getFullYear()===now.getFullYear()&&d.getMonth()===now.getMonth();
    return true;
  });
}

function groupByDay(orders){
  var groups={};
  orders.forEach(function(o){
    var key=new Date(o.createdAt).toISOString().slice(0,10);
    if(!groups[key]) groups[key]={orders:[],cancelled:0};
    groups[key].orders.push(o);
  });
  return groups;
}
function groupByWeek(orders){
  var groups={};
  orders.forEach(function(o){
    var d=new Date(o.createdAt);
    var startOfWeek=new Date(d); startOfWeek.setDate(d.getDate()-d.getDay()); startOfWeek.setHours(0,0,0,0);
    var key=startOfWeek.toISOString().slice(0,10);
    if(!groups[key]) groups[key]={orders:[],cancelled:0};
    groups[key].orders.push(o);
  });
  return groups;
}
function groupByMonth(orders){
  var groups={};
  orders.forEach(function(o){
    var key=new Date(o.createdAt).toISOString().slice(0,7);
    if(!groups[key]) groups[key]={orders:[],cancelled:0};
    groups[key].orders.push(o);
  });
  return groups;
}

function makeRow(label,ords,allForPeriod){
  var delivered=ords.filter(function(o){ return o.status==='delivered'; });
  var cancelled=allForPeriod.filter(function(o){ return o.status==='cancelled'&&new Date(o.createdAt).toISOString().slice(0,label.length)===label; });
  var gross=delivered.reduce(function(s,o){ return s+(+(o.deliveryFee||0)); },0);
  var comm=gross*(commPct/100);
  var net=gross-comm;
  var avg=delivered.length?gross/delivered.length:0;
  return {label:label,total:ords.length,delivered:delivered.length,cancelled:cancelled.length,gross:gross,comm:comm,net:net,avg:avg};
}

function renderReport(){
  var titleMap={day:"Today's",week:"This Week's",month:"This Month's",all:'All-Time'};
  document.getElementById('rpt-title').textContent='&#128230; '+titleMap[curPeriod]+' Freight Breakdown';
  var delivered=allOrders.filter(function(o){ return o.status==='delivered'&&inPeriod(o,curPeriod); });
  var totalOrders=allOrders.filter(function(o){ return inPeriod(o,curPeriod); }).length;
  var gross=delivered.reduce(function(s,o){ return s+(+(o.deliveryFee||0)); },0);
  var comm=gross*(commPct/100);
  var net=gross-comm;
  document.getElementById('rpt-orders').textContent=totalOrders;
  document.getElementById('rpt-rev').textContent='$'+gross.toFixed(2);
  document.getElementById('rpt-comm').textContent='$'+comm.toFixed(2);
  document.getElementById('rpt-net').textContent='$'+net.toFixed(2);

  var tbody=document.getElementById('rpt-body');
  var rows=[];
  var periodOrders=allOrders.filter(function(o){ return inPeriod(o,curPeriod); });
  var groups;
  if(curPeriod==='day'){
    var hours={};
    periodOrders.forEach(function(o){
      var h=new Date(o.createdAt).getHours();
      var label=h+':00';
      if(!hours[label]) hours[label]=[];
      hours[label].push(o);
    });
    groups=hours;
  } else if(curPeriod==='week'){
    var days={};
    periodOrders.forEach(function(o){
      var label=new Date(o.createdAt).toLocaleDateString('en-NZ',{weekday:'short',day:'numeric',month:'short'});
      if(!days[label]) days[label]=[];
      days[label].push(o);
    });
    groups=days;
  } else if(curPeriod==='month'){
    var wks={};
    periodOrders.forEach(function(o){
      var d=new Date(o.createdAt);
      var wk='Week '+Math.ceil(d.getDate()/7);
      if(!wks[wk]) wks[wk]=[];
      wks[wk].push(o);
    });
    groups=wks;
  } else {
    var months={};
    periodOrders.forEach(function(o){
      var label=new Date(o.createdAt).toLocaleDateString('en-NZ',{month:'long',year:'numeric'});
      if(!months[label]) months[label]=[];
      months[label].push(o);
    });
    groups=months;
  }

  var totals={total:0,del:0,canc:0,gross:0,comm:0,net:0,avgSum:0,avgCnt:0};
  var rowHtml='';
  Object.keys(groups).forEach(function(label){
    var ords=groups[label];
    var del=ords.filter(function(o){ return o.status==='delivered'; });
    var canc=ords.filter(function(o){ return o.status==='cancelled'; });
    var gross=del.reduce(function(s,o){ return s+(+(o.deliveryFee||0)); },0);
    var comm=gross*(commPct/100);
    var net=gross-comm;
    var avg=del.length?gross/del.length:0;
    totals.total+=ords.length; totals.del+=del.length; totals.canc+=canc.length;
    totals.gross+=gross; totals.comm+=comm; totals.net+=net;
    if(del.length){ totals.avgSum+=gross; totals.avgCnt+=del.length; }
    rowHtml+='<tr>' +
      '<td style="font-weight:600">'+label+'</td>' +
      '<td>'+ords.length+'</td>' +
      '<td style="color:#2E7D32;font-weight:600">'+del.length+'</td>' +
      '<td style="color:#C62828">'+canc.length+'</td>' +
      '<td style="font-weight:600">$'+gross.toFixed(2)+'</td>' +
      '<td style="color:#C62828">-$'+comm.toFixed(2)+'</td>' +
      '<td style="color:#1565C0;font-weight:700">$'+net.toFixed(2)+'</td>' +
      '<td style="color:#555">$'+avg.toFixed(2)+'</td>' +
    '</tr>';
  });
  if(!rowHtml) rowHtml='<tr><td colspan="8" style="text-align:center;padding:30px;color:#aaa">No freight orders in this period.</td></tr>';
  tbody.innerHTML=rowHtml;
  var avgAll=totals.avgCnt?totals.avgSum/totals.avgCnt:0;
  document.getElementById('ft-orders').textContent=totals.total;
  document.getElementById('ft-del').textContent=totals.del;
  document.getElementById('ft-canc').textContent=totals.canc;
  document.getElementById('ft-gross').textContent='$'+totals.gross.toFixed(2);
  document.getElementById('ft-comm').textContent='$'+totals.comm.toFixed(2);
  document.getElementById('ft-net').textContent='$'+totals.net.toFixed(2);
  document.getElementById('ft-avg').textContent='$'+avgAll.toFixed(2);
}

function inPeriod(o,period){
  if(!o.createdAt) return false;
  var d=new Date(o.createdAt);
  var now=new Date();
  if(period==='day') return d.toDateString()===now.toDateString();
  if(period==='week'){
    var sw=new Date(now); sw.setDate(now.getDate()-now.getDay()); sw.setHours(0,0,0,0);
    return d>=sw;
  }
  if(period==='month') return d.getFullYear()===now.getFullYear()&&d.getMonth()===now.getMonth();
  return true;
}

window._fbOnLogin = function(){
  var urlCid=(new URLSearchParams(window.location.search)).get('cid');
  if(urlCid) COMPANY_ID=urlCid;
  Promise.all([
    _fbGet('freightConfig/defaults'),
    _fbGet('freightOrders/'+COMPANY_ID)
  ]).then(function(results){
    var d=results[0]||{};
    commPct=d.commissionPct!==undefined?+d.commissionPct:10;
    var data=results[1]||{};
    allOrders=Object.entries(data).map(function(e){ return Object.assign({_id:e[0]},e[1]); });
    renderReport();
  });
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
