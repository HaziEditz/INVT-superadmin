<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Freight Delivery &mdash; Payouts &mdash; BookaWaka Admin</title>
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
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<style>
.fd-wrap{padding:20px}
.fd-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.fd-bar{background:#37474F;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.fd-bar h3{margin:0;font-size:15px;font-weight:600}
.fd-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:20px}
.fd-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #37474F}
.fd-stat.green{border-left-color:#2E7D32}.fd-stat.blue{border-left-color:#1565C0}.fd-stat.red{border-left-color:#C62828}
.fd-stat-v{font-size:24px;font-weight:700;color:#37474F;line-height:1.1}
.fd-stat.green .fd-stat-v{color:#2E7D32}.fd-stat.blue .fd-stat-v{color:#1565C0}.fd-stat.red .fd-stat-v{color:#C62828}
.fd-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.period-btn{padding:7px 18px;border:1px solid #ddd;border-radius:4px;background:#fff;font-size:13px;cursor:pointer;font-weight:500}
.period-btn.active{background:#37474F;color:#fff;border-color:#37474F;font-weight:700}
.fd-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.fd-tbl th{background:#ECEFF1;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #B0BEC5;color:#37474F;white-space:nowrap}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tfoot td{background:#ECEFF1;font-weight:700;color:#37474F;border-top:2px solid #B0BEC5}
.fd-tbl tr:hover td{background:#F5F5F5}
.bx{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600}
.bx-g{background:#E8F5E9;color:#2E7D32}.bx-y{background:#FFF8E1;color:#F57F17}.bx-b{background:#E3F2FD;color:#1565C0}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Freight Delivery &mdash; Payouts &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FR-Payouts.aspx" style="font-weight:700;color:#37474F">&#9658; Payouts</a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px;color:#37474F">&#128181; Freight Delivery &mdash; Driver Payouts</h2>
<p style="font-size:13px;color:#888;margin-bottom:14px">See how much each driver earned from freight deliveries. Toggle the period to see different timeframes.</p>

<div style="display:flex;gap:8px;margin-bottom:20px;flex-wrap:wrap">
  <button class="period-btn active" id="btn-day" onclick="setPeriod('day')">Today</button>
  <button class="period-btn" id="btn-week" onclick="setPeriod('week')">This Week</button>
  <button class="period-btn" id="btn-month" onclick="setPeriod('month')">This Month</button>
</div>

<div class="fd-stats">
  <div class="fd-stat"><div class="fd-stat-v" id="st-drivers">0</div><div class="fd-stat-l">Active Drivers</div></div>
  <div class="fd-stat blue"><div class="fd-stat-v" id="st-deliveries">0</div><div class="fd-stat-l">Deliveries Completed</div></div>
  <div class="fd-stat green"><div class="fd-stat-v" id="st-total">$0.00</div><div class="fd-stat-l">Total Driver Earnings</div></div>
  <div class="fd-stat red"><div class="fd-stat-v" id="st-comm">$0.00</div><div class="fd-stat-l">BookaWaka Commission</div></div>
</div>

<div class="fd-card">
  <div class="fd-bar"><h3 id="payout-title">&#128230; Today's Driver Payouts</h3></div>
  <div style="overflow-x:auto">
  <table class="fd-tbl">
    <thead>
      <tr>
        <th>Driver ID</th>
        <th>Deliveries</th>
        <th>Gross Fees Collected</th>
        <th>BookaWaka Commission</th>
        <th>Driver Earnings</th>
        <th>Avg. per Delivery</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody id="payout-body">
      <tr><td colspan="7" style="text-align:center;padding:30px;color:#aaa">Loading&hellip;</td></tr>
    </tbody>
    <tfoot><tr>
      <td>Totals</td>
      <td id="ft-del">0</td>
      <td id="ft-gross">$0.00</td>
      <td id="ft-comm">$0.00</td>
      <td id="ft-earn">$0.00</td>
      <td>—</td>
      <td>—</td>
    </tr></tfoot>
  </table>
  </div>
</div>

<div class="fd-card">
  <div class="fd-bar"><h3>&#128221; Mark Freight Payout Paid</h3></div>
  <div style="padding:18px">
    <p style="font-size:13px;color:#555;margin-bottom:14px">After paying a driver for their freight deliveries, record it here. This is logged to <code>freightPayouts/{companyId}/{driverId}</code> in Firebase.</p>
    <div style="display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap">
      <div>
        <label style="display:block;font-size:12px;font-weight:600;color:#555;margin-bottom:4px">Driver ID</label>
        <input id="pay-driver" type="text" style="padding:8px 12px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:150px" placeholder="e.g. DRV001"/>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:600;color:#555;margin-bottom:4px">Amount ($)</label>
        <input id="pay-amount" type="number" min="0" step="0.01" style="padding:8px 12px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:120px" placeholder="0.00"/>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:600;color:#555;margin-bottom:4px">Period</label>
        <input id="pay-period" type="text" style="padding:8px 12px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:130px" placeholder="e.g. 2026-W17"/>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:600;color:#555;margin-bottom:4px">Reference</label>
        <input id="pay-ref" type="text" style="padding:8px 12px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:160px" placeholder="Bank ref or transfer ID"/>
      </div>
      <button onclick="markPaid()" style="padding:9px 20px;background:#37474F;color:#fff;border:none;border-radius:4px;font-size:13px;font-weight:600;cursor:pointer">&#10003; Mark Paid</button>
    </div>
    <div id="pay-msg" style="margin-top:10px;font-size:13px"></div>
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
  ['day','week','month'].forEach(function(x){ document.getElementById('btn-'+x).classList.remove('active'); });
  document.getElementById('btn-'+p).classList.add('active');
  renderPayouts();
}

function inPeriod(o,period){
  if(!o.createdAt||o.status!=='delivered') return false;
  var d=new Date(o.createdAt); var now=new Date();
  if(period==='day') return d.toDateString()===now.toDateString();
  if(period==='week'){ var sw=new Date(now);sw.setDate(now.getDate()-now.getDay());sw.setHours(0,0,0,0);return d>=sw; }
  if(period==='month') return d.getFullYear()===now.getFullYear()&&d.getMonth()===now.getMonth();
  return true;
}

function renderPayouts(){
  var titleMap={day:'Today\'s',week:'This Week\'s',month:'This Month\'s'};
  document.getElementById('payout-title').textContent='&#128230; '+titleMap[curPeriod]+' Driver Payouts';
  var periodOrders=allOrders.filter(function(o){ return inPeriod(o,curPeriod); });
  var byDriver={};
  periodOrders.forEach(function(o){
    var did=o.driverId||'Unassigned';
    if(!byDriver[did]) byDriver[did]={deliveries:0,gross:0};
    byDriver[did].deliveries++;
    byDriver[did].gross+=+(o.deliveryFee||0);
  });
  var drivers=Object.keys(byDriver);
  document.getElementById('st-drivers').textContent=drivers.length;
  var totDel=periodOrders.length;
  var totGross=periodOrders.reduce(function(s,o){ return s+(+(o.deliveryFee||0)); },0);
  var totComm=totGross*(commPct/100);
  var totEarn=totGross-totComm;
  document.getElementById('st-deliveries').textContent=totDel;
  document.getElementById('st-total').textContent='$'+totEarn.toFixed(2);
  document.getElementById('st-comm').textContent='$'+totComm.toFixed(2);

  var tbody=document.getElementById('payout-body');
  if(!drivers.length){
    tbody.innerHTML='<tr><td colspan="7" style="text-align:center;padding:30px;color:#aaa">No freight deliveries in this period.</td></tr>';
    ['ft-del','ft-gross','ft-comm','ft-earn'].forEach(function(id){ document.getElementById(id).textContent=id.includes('del')?'0':'$0.00'; });
    return;
  }
  var rows='';
  drivers.sort(function(a,b){ return byDriver[b].gross-byDriver[a].gross; }).forEach(function(did){
    var d=byDriver[did];
    var comm=d.gross*(commPct/100);
    var earn=d.gross-comm;
    var avg=d.deliveries?earn/d.deliveries:0;
    rows+='<tr>' +
      '<td style="font-family:monospace;font-size:12px">'+did+'</td>' +
      '<td style="font-weight:600">'+d.deliveries+'</td>' +
      '<td>$'+d.gross.toFixed(2)+'</td>' +
      '<td style="color:#C62828">-$'+comm.toFixed(2)+'</td>' +
      '<td style="font-weight:700;color:#1565C0">$'+earn.toFixed(2)+'</td>' +
      '<td>$'+avg.toFixed(2)+'</td>' +
      '<td><span class="bx bx-y">Pending</span></td>' +
    '</tr>';
  });
  tbody.innerHTML=rows;
  document.getElementById('ft-del').textContent=totDel;
  document.getElementById('ft-gross').textContent='$'+totGross.toFixed(2);
  document.getElementById('ft-comm').textContent='$'+totComm.toFixed(2);
  document.getElementById('ft-earn').textContent='$'+totEarn.toFixed(2);
}

function markPaid(){
  var did=(document.getElementById('pay-driver').value||'').trim();
  var amt=parseFloat(document.getElementById('pay-amount').value)||0;
  var period=(document.getElementById('pay-period').value||'').trim();
  var ref=(document.getElementById('pay-ref').value||'').trim();
  if(!did||!amt){ var m=document.getElementById('pay-msg'); m.style.color='#C62828'; m.textContent='Please enter driver ID and amount.'; return; }
  var key=period||new Date().toISOString().slice(0,10);
  var record={amount:amt,period:period,ref:ref,paidAt:Date.now(),paidBy:'super-admin'};
  db.ref('freightPayouts/'+COMPANY_ID+'/'+did+'/'+key.replace(/[^a-zA-Z0-9-]/g,'_')).set(record).then(function(){
    var m=document.getElementById('pay-msg'); m.style.color='#2E7D32';
    m.textContent='&#10003; Payout of $'+amt.toFixed(2)+' recorded for driver '+did;
    document.getElementById('pay-driver').value='';
    document.getElementById('pay-amount').value='';
    document.getElementById('pay-period').value='';
    document.getElementById('pay-ref').value='';
    setTimeout(function(){ m.textContent=''; },5000);
  });
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
    renderPayouts();
  });
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
