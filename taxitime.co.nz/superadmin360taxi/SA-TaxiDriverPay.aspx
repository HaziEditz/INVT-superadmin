<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Taxi Driver Pay &mdash; BookaWaka Admin</title>
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
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-g{background:#2E7D32;color:#fff}.sa-btn-g:hover{background:#1B5E20}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
select.inline-sel,input.inline-inp{padding:5px 8px;border:1.5px solid #ddd;border-radius:4px;font-size:12px;background:#fff}
select.inline-sel:focus,input.inline-inp:focus{outline:none;border-color:#1565C0}
.sched-pill{font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px}
.sched-instant{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.sched-weekly{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.sched-monthly{background:#F3E5F5;color:#6A1B9A;border:1px solid #CE93D8}
.info-card{background:#F0F7FF;border-left:4px solid #1565C0;padding:12px 16px;font-size:13px;color:#0D47A1;border-radius:4px;margin:16px 18px}
.sum-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(155px,1fr));gap:12px;padding:16px 18px;background:#F0F7FF;border-bottom:1px solid #BBDEFB}
.sum-box{background:#fff;border-radius:6px;padding:12px 14px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.sum-box .sum-lbl{font-size:11px;color:#888;font-weight:500;margin-bottom:4px}
.sum-box .sum-val{font-size:20px;font-weight:800;color:#1565C0}
.sum-box.green .sum-val{color:#2E7D32}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Taxi Driver Pay &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FR-Reports.aspx">Reports</a></li>
      <li><a href="FR-Commission.aspx">Commission Rates</a></li>
      <li><a href="FR-DriverPayouts.aspx">Driver Payouts</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-SubscriptionBilling.aspx">Subscription Billing</a></li>
      <li><a href="SA-TaxiDriverPay.aspx" style="font-weight:700;color:#1565C0">&#9658; Taxi Driver Pay</a></li>
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
    </ul></li>
  </ul></div>
</aside>
<div id="page_content_inner">
<div class="sa-wrap">

  <!-- How it works -->
  <div class="sa-card">
    <div class="sa-bar"><h3>&#128661; Taxi Driver Pay Settings</h3></div>
    <div class="info-card">
      <strong>How taxi driver pay works:</strong> Set a pay model (flat $ per trip or % of fare) and schedule (instant, weekly, monthly) per company.
      When a trip completes, the driver's share is calculated and credited to their earnings wallet.
      Instant payouts transfer to the driver's Stripe Express account immediately. Weekly/monthly payouts are triggered via the batch payout button on this page.
      <br><br>
      <strong>Driver earnings path:</strong> <code>driverEarnings/taxi/{companyId}/{driverId}</code> &mdash;
      Drivers need a Stripe Express account connected to receive payouts.
    </div>
  </div>

  <!-- Pay Config per Company -->
  <div class="sa-card">
    <div class="sa-bar">
      <h3>Driver Pay Configuration — Per Company</h3>
      <button class="sa-btn sa-btn-n" onclick="loadData()">&#8635; Refresh</button>
    </div>
    <div class="sum-grid">
      <div class="sum-box"><div class="sum-lbl">Total Companies</div><div class="sum-val" id="s-total">—</div></div>
      <div class="sum-box green"><div class="sum-lbl">Pay Config Set</div><div class="sum-val" id="s-configured">—</div></div>
      <div class="sum-box"><div class="sum-lbl">Not Configured</div><div class="sum-val" id="s-unconf" style="color:#E65100">—</div></div>
    </div>
    <div style="overflow-x:auto">
      <table class="sa-tbl" id="pay-tbl">
        <thead>
          <tr>
            <th>Company</th>
            <th>Pay Model</th>
            <th>Amount</th>
            <th>Schedule</th>
            <th>Driver Earnings Pending</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="pay-tbody">
          <tr><td colspan="6" style="color:#aaa;text-align:center;padding:28px">Loading&#8230;</td></tr>
        </tbody>
      </table>
    </div>
  </div>

</div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allClients={};
var allPayCfg={};
var allEarnings={};

function fmt(v){ return '$'+(parseFloat(v)||0).toFixed(2); }

function loadData(){
  document.getElementById('pay-tbody').innerHTML='<tr><td colspan="6" style="color:#aaa;text-align:center;padding:28px">Loading&#8230;</td></tr>';
  Promise.all([
    _fbGet('superClients'),
    _fbGet('taxiConfig/driverPay'),
    _fbGet('driverEarnings/taxi')
  ]).then(function(results){
    allClients = results[0]||{};
    allPayCfg  = results[1]||{};
    allEarnings= results[2]||{};
    renderSummary();
    renderRows();
  }).catch(function(e){ toastr.error('Load failed: '+e.message); });
}

function renderSummary(){
  var total=Object.keys(allClients).length;
  var cfg=Object.keys(allPayCfg).length;
  document.getElementById('s-total').textContent=total;
  document.getElementById('s-configured').textContent=cfg;
  document.getElementById('s-unconf').textContent=total-cfg;
}

function renderRows(){
  var cids=Object.keys(allClients);
  if(!cids.length){
    document.getElementById('pay-tbody').innerHTML='<tr><td colspan="6" style="color:#aaa;text-align:center;padding:24px">No companies found</td></tr>';
    return;
  }
  var html=cids.map(function(cid){
    var sc=allClients[cid]||{};
    var cfg=allPayCfg[cid]||{};
    var drvEarnings=allEarnings[cid]||{};
    var pendingTotal=0;
    Object.values(drvEarnings).forEach(function(de){ pendingTotal+=parseFloat(de.pendingAmount||0); });
    var pendingBadge=pendingTotal>0
      ? '<strong style="color:#2E7D32">'+fmt(pendingTotal)+'</strong>'
      : '<span style="color:#aaa">'+fmt(0)+'</span>';
    var modelSel='<select class="inline-sel" id="model-'+cid+'" onchange="toggleAmountLabel(\''+cid+'\')">'
      +'<option value="flat"'+(cfg.model==='flat'?' selected':'')+'> Flat $ / trip</option>'
      +'<option value="percent"'+(cfg.model==='percent'?' selected':'')+'> % of fare</option>'
      +'</select>';
    var amtInp='<input class="inline-inp" type="number" id="amt-'+cid+'" value="'+(cfg.amount||0)+'" step="0.50" min="0" style="width:75px"/> '
      +'<span id="amtlbl-'+cid+'" style="font-size:11px;color:#888">'+(cfg.model==='percent'?'%':'$')+'</span>';
    var schedSel='<select class="inline-sel" id="sched-'+cid+'">'
      +'<option value="instant"'+(cfg.schedule==='instant'?' selected':'')+'>Instant</option>'
      +'<option value="weekly"'+(cfg.schedule==='weekly'?' selected':'')+'>Weekly</option>'
      +'<option value="monthly"'+(cfg.schedule==='monthly'?' selected':'')+'>Monthly</option>'
      +'</select>';
    var saveBtn='<button class="sa-btn sa-btn-p" onclick="saveRow(\''+cid+'\')">&#128190; Save</button>';
    var payBtn=pendingTotal>0
      ? '<button class="sa-btn sa-btn-g" style="margin-left:4px" onclick="triggerBatchPay(\''+cid+'\')">&#128176; Pay Drivers</button>'
      : '';
    return '<tr>'
      +'<td><strong>'+(sc.name||cid)+'</strong><br><span style="font-family:monospace;font-size:10px;color:#aaa">'+cid+'</span></td>'
      +'<td>'+modelSel+'</td>'
      +'<td>'+amtInp+'</td>'
      +'<td>'+schedSel+'</td>'
      +'<td>'+pendingBadge+'</td>'
      +'<td style="white-space:nowrap">'+saveBtn+payBtn+'</td>'
      +'</tr>';
  }).join('');
  document.getElementById('pay-tbody').innerHTML=html;
}

function toggleAmountLabel(cid){
  var model=document.getElementById('model-'+cid).value;
  document.getElementById('amtlbl-'+cid).textContent=model==='percent'?'%':'$';
}

function saveRow(cid){
  var model=document.getElementById('model-'+cid).value;
  var amount=parseFloat(document.getElementById('amt-'+cid).value||0);
  var schedule=document.getElementById('sched-'+cid).value;
  fetch('/api/sa-taxi-driver-pay',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({companyId:cid,model:model,amount:amount,schedule:schedule})})
  .then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    toastr.success('Driver pay saved for '+(allClients[cid]&&allClients[cid].name||cid));
    allPayCfg[cid]={model:model,amount:amount,schedule:schedule};
    renderSummary();
  }).catch(e=>toastr.error(e.message));
}

function triggerBatchPay(cid){
  if(!confirm('Trigger driver payouts for '+(allClients[cid]&&allClients[cid].name||cid)+'?')) return;
  fetch('/api/sa-taxi-driver-batch-payout',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({companyId:cid})})
  .then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    var paid=(d.results||[]).filter(function(r){return r.status==='paid';}).length;
    toastr.success('Paid '+paid+' driver(s)');
    loadData();
  }).catch(e=>toastr.error(e.message));
}

window._fbOnLogin = function(){ loadData(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
