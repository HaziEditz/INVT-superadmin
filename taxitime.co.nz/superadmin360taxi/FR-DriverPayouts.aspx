<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Freight &mdash; Driver Payouts &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="assets/js/jquery.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet"/>
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet"/>
<link href="assets/css/main.min.css" rel="stylesheet"/>
<link href="assets/css/Toast.css" rel="stylesheet"/>
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
.fd-bar{background:#283593;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.fd-bar h3{margin:0;font-size:15px;font-weight:600}
.fd-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.fd-tbl th{background:#E8EAF6;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #9FA8DA;white-space:nowrap;color:#283593}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tr:hover td{background:#F5F5F5}
.fd-btn{padding:7px 16px;background:#283593;color:#fff;border:none;border-radius:4px;font-size:13px;font-weight:600;cursor:pointer}
.fd-btn:hover{background:#1A237E}
.fd-btn-g{background:#2E7D32}.fd-btn-g:hover{background:#1B5E20}
.fd-btn-r{background:#C62828}.fd-btn-r:hover{background:#B71C1C}
.info-box{background:#E8EAF6;border-left:4px solid #283593;padding:12px 16px;border-radius:6px;font-size:13px;color:#283593;margin-bottom:18px}
.stat-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;margin-bottom:20px}
.stat-box{background:#fff;border-radius:6px;padding:14px 16px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #283593}
.stat-box.green{border-left-color:#2E7D32}.stat-box.orange{border-left-color:#E65100}
.stat-v{font-size:26px;font-weight:700;color:#283593;line-height:1.1}
.stat-box.green .stat-v{color:#2E7D32}.stat-box.orange .stat-v{color:#E65100}
.stat-l{font-size:11.5px;color:#888;margin-top:4px}
.bdg-g{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#E8F5E9;color:#2E7D32}
.bdg-r{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#FFEBEE;color:#C62828}
.bdg-a{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#FFF3E0;color:#E65100}
.bdg-b{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#E3F2FD;color:#1565C0}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Freight &mdash; Driver Payouts &mdash; BookaWaka Admin</label></div>
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
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Orders.aspx">All Orders</a></li>
      <li><a href="FR-Payouts.aspx">Company Payouts</a></li>
      <li><a href="FR-Reports.aspx">Reports</a></li>
      <li><a href="FR-Commission.aspx">Commission Rates</a></li>
      <li><a href="FR-DriverPayouts.aspx" style="font-weight:700;color:#283593">&#9658; Driver Payouts</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Restaurants.aspx">Restaurants</a></li>
      <li><a href="FD-Orders.aspx">All Orders</a></li>
      <li><a href="FD-Payouts.aspx">Payouts</a></li>
      <li><a href="FD-Commission.aspx">Commission Rates</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="fd-wrap">

<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;flex-wrap:wrap;gap:8px">
  <h2 style="font-size:18px;font-weight:700;color:#283593;margin:0">&#128184; Freight Driver Payouts</h2>
  <div style="display:flex;gap:8px;flex-wrap:wrap">
    <button class="fd-btn" onclick="loadAll()">&#8635; Refresh</button>
    <a href="FR-Commission.aspx" class="fd-btn" style="text-decoration:none">&#9881; Commission Settings</a>
  </div>
</div>
<p style="font-size:13px;color:#888;margin-bottom:14px">
  Manage driver earnings across all freight companies. Use <strong>Batch Payout</strong> to pay all drivers with pending weekly or monthly earnings for a company.
</p>

<div id="summary-stats" class="stat-grid" style="display:none">
  <div class="stat-box"><div class="stat-v" id="stat-companies">—</div><div class="stat-l">Companies with pending</div></div>
  <div class="stat-box orange"><div class="stat-v" id="stat-drivers">—</div><div class="stat-l">Drivers with pending pay</div></div>
  <div class="stat-box green"><div class="stat-v" id="stat-total">—</div><div class="stat-l">Total pending ($)</div></div>
</div>

<div id="earnings-wrap"></div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allData = {};

window._fbOnLogin = function(){ loadAll(); };

function loadAll() {
  document.getElementById('earnings-wrap').innerHTML = '<p style="text-align:center;padding:30px;color:#aaa">Loading driver earnings&hellip;</p>';
  Promise.all([
    adminRead('freightAccess'),
    adminRead('driverEarnings/freight'),
    adminRead('freightConfig/driverPay'),
    adminRead('driverPayouts/freight')
  ]).then(function(results){
    var companies = results[0] || {};
    var allEarnings = results[1] || {};
    var configs = results[2] || {};
    var payoutHistory = results[3] || {};
    allData = { companies: companies, allEarnings: allEarnings, configs: configs, payoutHistory: payoutHistory };
    renderSummary();
    renderCompanyCards();
  }).catch(function(e){ document.getElementById('earnings-wrap').innerHTML='<p style="color:#C62828;padding:20px">Error loading data: '+e.message+'</p>'; });
}

function renderSummary() {
  var companies = allData.companies, allEarnings = allData.allEarnings;
  var companiesWithPending = 0, totalDrivers = 0, totalPending = 0;
  Object.keys(allEarnings).forEach(function(cid){
    var hasPending = false;
    Object.values(allEarnings[cid]).forEach(function(e){
      var p = parseFloat(e.pendingAmount||0);
      if (p > 0) { totalDrivers++; totalPending += p; hasPending = true; }
    });
    if (hasPending) companiesWithPending++;
  });
  document.getElementById('stat-companies').textContent = companiesWithPending;
  document.getElementById('stat-drivers').textContent = totalDrivers;
  document.getElementById('stat-total').textContent = '$'+totalPending.toFixed(2);
  document.getElementById('summary-stats').style.display = '';
}

function renderCompanyCards() {
  var companies = allData.companies, allEarnings = allData.allEarnings, configs = allData.configs, payoutHistory = allData.payoutHistory;
  var html = '';
  Object.keys(companies).sort(function(a,b){ return (companies[a].name||'').localeCompare(companies[b].name||''); }).forEach(function(cid){
    var c = companies[cid];
    var earnings = allEarnings[cid] || {};
    var cfg = configs[cid] || {};
    var history = payoutHistory[cid] || {};
    var schedule = cfg.schedule || 'weekly';
    var model = cfg.model || 'flat';
    var amount = parseFloat(cfg.amount||0);
    var cfgStr = model==='flat' ? '$'+amount.toFixed(2)+' flat' : amount+'% of order';
    var totalPending = 0, driverCount = 0;
    var driverRows = Object.keys(earnings).map(function(did){
      var e = earnings[did];
      var p = parseFloat(e.pendingAmount||0);
      if (p > 0) { totalPending += p; driverCount++; }
      var delCount = e.deliveries ? Object.keys(e.deliveries).length : 0;
      var pendCount = e.deliveries ? Object.values(e.deliveries).filter(function(x){ return x.status==='pending'; }).length : 0;
      return '<tr>' +
        '<td style="font-weight:600">'+esc(did)+'</td>' +
        '<td style="color:#388E3C;font-weight:700">$'+p.toFixed(2)+'</td>' +
        '<td style="color:#555">$'+parseFloat(e.totalEarned||0).toFixed(2)+'</td>' +
        '<td>'+delCount+' total / '+pendCount+' unpaid</td>' +
        '<td>' + (p > 0 ?
          '<button onclick="payOneDriver(\''+cid+'\',\''+did+'\')" class="fd-btn fd-btn-g" style="padding:4px 10px;font-size:11.5px">Pay $'+p.toFixed(2)+'</button>' :
          '<span class="bdg-g">Up to date</span>') +
        '</td>' +
      '</tr>';
    }).join('');
    var historyRows = Object.entries(history).sort(function(a,b){ return (b[1].triggeredAt||0)-(a[1].triggeredAt||0); }).slice(0,10).map(function(pair){
      var p = pair[1];
      return '<tr>' +
        '<td style="font-size:11px;font-family:monospace">'+esc(p.driverId||'—')+'</td>' +
        '<td style="font-weight:600">$'+parseFloat(p.amount||0).toFixed(2)+'</td>' +
        '<td><span class="'+(p.schedule==='instant'?'bdg-r':'bdg-b')+'">'+esc(p.schedule||'—')+'</span></td>' +
        '<td>'+new Date(p.triggeredAt||0).toLocaleString('en-NZ')+'</td>' +
        '<td><span class="'+(p.status==='paid'?'bdg-g':'bdg-a')+'">'+esc(p.status||'pending')+'</span></td>' +
        '<td style="font-size:10px;color:#999;font-family:monospace">'+esc(p.stripeTransferId||'—').slice(0,24)+'</td>' +
      '</tr>';
    }).join('');
    var schedCol = schedule==='instant'?'#C62828':schedule==='weekly'?'#1565C0':'#5D4037';
    html += '<div class="fd-card">' +
      '<div class="fd-bar">' +
        '<div>' +
          '<h3>'+esc(c.name||cid)+'</h3>' +
          '<small style="opacity:.75;font-size:11.5px">'+esc(cid)+' &nbsp;|&nbsp; Pay: '+cfgStr+' &nbsp;|&nbsp; <span style="color:'+schedCol+'">'+schedule+' schedule</span></small>' +
        '</div>' +
        (schedule !== 'instant' && totalPending > 0 ?
          '<button onclick="batchPayout(\''+cid+'\')" class="fd-btn fd-btn-g" style="font-size:13px;padding:8px 18px">&#128184; Batch Pay All ($'+totalPending.toFixed(2)+')</button>'
          : (totalPending === 0 ? '<span class="bdg-g" style="font-size:12px">All paid up</span>' : '<span style="font-size:11.5px;opacity:.75">Instant — auto-paid on delivery</span>')
        ) +
      '</div>' +
      (Object.keys(earnings).length ?
        '<div style="overflow-x:auto"><table class="fd-tbl"><thead><tr><th>Driver ID</th><th>Pending ($)</th><th>Total Earned ($)</th><th>Deliveries</th><th>Action</th></tr></thead><tbody>'+driverRows+'</tbody></table></div>'
        : '<p style="padding:14px 18px;color:#aaa;font-size:13px">No driver earnings recorded yet.</p>'
      ) +
      (Object.keys(history).length ?
        '<div style="border-top:1px solid #f0f0f0;padding:10px 14px 2px"><p style="font-size:12px;font-weight:600;color:#555;margin-bottom:6px">Recent Payout History</p>' +
        '<div style="overflow-x:auto"><table class="fd-tbl"><thead><tr><th>Driver ID</th><th>Amount</th><th>Type</th><th>Date</th><th>Status</th><th>Stripe ID</th></tr></thead><tbody>'+historyRows+'</tbody></table></div></div>'
        : ''
      ) +
    '</div>';
  });
  if (!html) html = '<div class="info-box">No freight companies found. <a href="FR-Commission.aspx" style="color:#283593">Set up companies &rarr;</a></div>';
  document.getElementById('earnings-wrap').innerHTML = html;
}

function batchPayout(cid) {
  var cfg = allData.configs[cid] || {};
  if (!confirm('Trigger batch payout for all drivers in '+(allData.companies[cid]||{name:cid}).name+'?\nThis will create Stripe transfers for all drivers with a connected Stripe account.')) return;
  fetch('/api/sa-batch-driver-payouts', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ companyId: cid, schedule: cfg.schedule })
  }).then(function(r){ return r.json(); }).then(function(d){
    if (d.error) { toastr.error(d.error); return; }
    var paid = d.results.filter(function(r){ return r.status==='paid'; });
    var skipped = d.results.filter(function(r){ return r.status==='skipped'||r.status==='error'; });
    toastr.success(paid.length+' driver(s) paid, '+skipped.length+' skipped/error');
    loadAll();
  }).catch(function(){ toastr.error('Batch payout failed'); });
}

function payOneDriver(cid, did) {
  var e = (allData.allEarnings[cid]||{})[did]||{};
  var pending = parseFloat(e.pendingAmount||0);
  if (!confirm('Pay $'+pending.toFixed(2)+' to driver '+did+'?')) return;
  fetch('/api/sa-batch-driver-payouts', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ companyId: cid, driverId: did })
  }).then(function(r){ return r.json(); }).then(function(d){
    if (d.error) { toastr.error(d.error); return; }
    toastr.success('Payout triggered');
    loadAll();
  }).catch(function(){ toastr.error('Payout failed'); });
}

function adminRead(path) {
  return _fbGet(path);
}

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
