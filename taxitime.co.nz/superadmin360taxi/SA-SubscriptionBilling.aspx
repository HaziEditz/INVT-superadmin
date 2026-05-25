<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Subscription Billing &mdash; BookaWaka Admin</title>
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
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-g{background:#2E7D32;color:#fff}.sa-btn-g:hover{background:#1B5E20}
.sa-btn-o{background:#E65100;color:#fff}.sa-btn-o:hover{background:#BF360C}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sum-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(155px,1fr));gap:12px;padding:16px 18px;background:#F0F7FF;border-bottom:1px solid #BBDEFB}
.sum-box{background:#fff;border-radius:6px;padding:12px 14px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.sum-box .sum-lbl{font-size:11px;color:#888;font-weight:500;margin-bottom:4px}
.sum-box .sum-val{font-size:20px;font-weight:800;color:#1565C0}
.sum-box.green .sum-val{color:#2E7D32}.sum-box.orange .sum-val{color:#E65100}.sum-box.red .sum-val{color:#C62828}
.badge-paid{background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7}
.badge-deducted{background:#E3F2FD;color:#1565C0;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #BBDEFB}
.badge-due{background:#FFF8E1;color:#E65100;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #FFE082}
.badge-suspended{background:#FFEBEE;color:#C62828;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #EF9A9A}
.badge-none{background:#f5f5f5;color:#aaa;font-size:11px;padding:2px 8px;border-radius:10px;border:1px solid #e0e0e0}
.ctrl-bar{display:flex;align-items:center;gap:10px;padding:13px 18px;background:#F0F7FF;border-bottom:1px solid #BBDEFB;flex-wrap:wrap}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:10px;padding:28px;max-width:480px;width:95%;box-shadow:0 8px 30px rgba(0,0,0,.2)}
.modal-box h3{font-size:16px;font-weight:700;margin-bottom:14px;color:#263238}
.mf label{display:block;font-size:12px;font-weight:600;color:#555;margin-bottom:4px;margin-top:12px}
.mf input,.mf select{width:100%;padding:8px 10px;border:1.5px solid #ddd;border-radius:5px;font-size:13px}
.mf input:focus,.mf select:focus{outline:none;border-color:#1565C0}
.modal-actions{display:flex;gap:8px;justify-content:flex-end;margin-top:18px}
.info-box{background:#E3F2FD;border-left:4px solid #1565C0;padding:10px 14px;border-radius:4px;font-size:13px;color:#0D47A1;margin-bottom:14px;line-height:1.6}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Subscription Billing &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-SubscriptionBilling.aspx" style="font-weight:700;color:#1565C0">&#9658; Subscription Billing</a></li>
      <li><a href="SA-TaxiDriverPay.aspx">Taxi Driver Pay</a></li>
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

  <div class="sa-card">
    <div class="sa-bar">
      <h3>&#128274; Subscription Billing — Monthly Package Fees</h3>
      <div style="display:flex;gap:8px;flex-wrap:wrap">
        <button class="sa-btn sa-btn-g" onclick="batchCharge()">&#9889; Charge All Due Today</button>
        <button class="sa-btn sa-btn-n" onclick="loadBilling()">&#8635; Refresh</button>
        <a class="sa-btn sa-btn-p" href="SA-Packages.aspx">&#128230; Manage Packages</a>
      </div>
    </div>
    <div class="sum-grid" id="sum-grid">
      <div class="sum-box"><div class="sum-lbl">Total Monthly Revenue</div><div class="sum-val" id="s-total">—</div></div>
      <div class="sum-box green"><div class="sum-lbl">Paid This Month</div><div class="sum-val" id="s-paid">—</div></div>
      <div class="sum-box orange"><div class="sum-lbl">Due / Overdue</div><div class="sum-val" id="s-due">—</div></div>
      <div class="sum-box red"><div class="sum-lbl">No Billing Method</div><div class="sum-val" id="s-nobill">—</div></div>
    </div>
    <div class="ctrl-bar">
      <input id="search-inp" type="text" placeholder="Search company name..." style="padding:5px 10px;border:1.5px solid #ddd;border-radius:4px;font-size:12px;min-width:200px" oninput="renderRows()"/>
      <span style="font-size:12px;color:#888">Filter:</span>
      <button class="sa-btn sa-btn-n filter-btn active" data-f="all" onclick="setFilter('all',this)">All</button>
      <button class="sa-btn sa-btn-n filter-btn" data-f="due" onclick="setFilter('due',this)">Due Now</button>
      <button class="sa-btn sa-btn-n filter-btn" data-f="paid" onclick="setFilter('paid',this)">Paid</button>
      <button class="sa-btn sa-btn-n filter-btn" data-f="deduct" onclick="setFilter('deduct',this)">Deduct from Payout</button>
    </div>
    <div style="overflow-x:auto">
      <table class="sa-tbl">
        <thead>
          <tr>
            <th>Company</th>
            <th>Package</th>
            <th style="text-align:right">Fleet</th>
            <th style="text-align:right">Monthly Fee</th>
            <th>Billing Method</th>
            <th>Next Billing</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="sub-tbody">
          <tr><td colspan="8" style="color:#aaa;text-align:center;padding:28px">Loading&#8230;</td></tr>
        </tbody>
      </table>
    </div>
  </div>

</div>
</div>

<!-- Charge Modal -->
<div class="modal-overlay" id="charge-modal">
  <div class="modal-box">
    <h3>&#128274; Confirm Subscription Charge</h3>
    <div id="charge-modal-info" class="info-box"></div>
    <div class="mf">
      <label>Billing Method</label>
      <select id="charge-method">
        <option value="stripe">Charge Stripe card on file</option>
        <option value="deduct">Deduct from next earnings payout</option>
      </select>
    </div>
    <div style="background:#FFF8E1;border-left:3px solid #FFD54F;padding:9px 12px;font-size:12px;color:#795548;border-radius:4px;margin-top:10px">
      <strong>Deduct from payout:</strong> The subscription fee will be held from the company's next BookaWaka earnings payout. No card charge is needed.
    </div>
    <div class="modal-actions">
      <button class="sa-btn sa-btn-n" onclick="closeModal('charge-modal')">Cancel</button>
      <button class="sa-btn sa-btn-g" id="charge-confirm-btn" onclick="confirmCharge()">&#9989; Charge Now</button>
    </div>
  </div>
</div>

<!-- Edit Billing Modal -->
<div class="modal-overlay" id="edit-modal">
  <div class="modal-box">
    <h3>&#9881;&#65039; Billing Settings</h3>
    <div id="edit-modal-name" style="font-size:13px;color:#888;margin-bottom:10px"></div>
    <div class="mf">
      <label>Stripe Customer ID (cus_…)</label>
      <input type="text" id="edit-stripe-cust" placeholder="cus_1AbcXyz…" style="font-family:monospace"/>
      <div style="font-size:11px;color:#888;margin-top:4px">Required to charge card on file. Create customer in Stripe dashboard first.</div>
    </div>
    <div class="mf">
      <label>Deduct subscription from earnings payout</label>
      <select id="edit-deduct">
        <option value="false">No — charge Stripe card</option>
        <option value="true">Yes — deduct from payout</option>
      </select>
    </div>
    <div class="mf">
      <label>Monthly fee override ($) — leave blank to use package rate</label>
      <input type="number" id="edit-override" step="0.50" min="0" placeholder="e.g. 99.00"/>
    </div>
    <div class="mf">
      <label>Suspend Billing</label>
      <select id="edit-suspend">
        <option value="false">No — billing active</option>
        <option value="true">Yes — suspend billing</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="sa-btn sa-btn-n" onclick="closeModal('edit-modal')">Cancel</button>
      <button class="sa-btn sa-btn-p" onclick="saveEdit()">&#128190; Save</button>
    </div>
  </div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allCompanies=[];
var activeFilter='all';
var chargeTarget=null;
var editTarget=null;

function fmt(v){ return '$'+(parseFloat(v)||0).toFixed(2); }

function loadBilling(){
  document.getElementById('sub-tbody').innerHTML='<tr><td colspan="8" style="color:#aaa;text-align:center;padding:28px">Loading&#8230;</td></tr>';
  fetch('/api/sa-subscription-summary').then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    allCompanies=d.companies||[];
    renderSummary();
    renderRows();
  }).catch(e=>toastr.error('Failed: '+e.message));
}

function renderSummary(){
  var total=0, paid=0, due=0, nobill=0, now=Date.now();
  allCompanies.forEach(function(c){
    total+=c.monthlyFee||0;
    var isDue = !c.nextBillingAt || c.nextBillingAt<=now;
    var isPaid = !isDue || c.subscriptionStatus==='paid';
    if(c.subscriptionStatus==='paid') paid++;
    else if(isDue) due++;
    if(!c.stripeCustomerId && !c.deductFromPayout) nobill++;
  });
  document.getElementById('s-total').textContent=fmt(total);
  document.getElementById('s-paid').textContent=paid;
  document.getElementById('s-due').textContent=due;
  document.getElementById('s-nobill').textContent=nobill;
}

function renderRows(){
  var q=(document.getElementById('search-inp').value||'').toLowerCase();
  var now=Date.now();
  var filtered=allCompanies.filter(function(c){
    var isDue=!c.nextBillingAt||c.nextBillingAt<=now;
    if(activeFilter==='due' && !isDue) return false;
    if(activeFilter==='paid' && c.subscriptionStatus!=='paid') return false;
    if(activeFilter==='deduct' && !c.deductFromPayout) return false;
    if(q && !(c.name||'').toLowerCase().includes(q)) return false;
    return true;
  });
  if(!filtered.length){
    document.getElementById('sub-tbody').innerHTML='<tr><td colspan="8" style="color:#aaa;text-align:center;padding:24px">No companies match filter</td></tr>';
    return;
  }
  var html=filtered.map(function(c){
    var isDue=!c.nextBillingAt||c.nextBillingAt<=now;
    var statusBadge;
    if(c.subscriptionStatus==='suspended') statusBadge='<span class="badge-suspended">SUSPENDED</span>';
    else if(c.subscriptionStatus==='paid') statusBadge='<span class="badge-paid">PAID</span>';
    else if(c.subscriptionStatus==='deducted_from_payout') statusBadge='<span class="badge-deducted">DEDUCTED</span>';
    else if(isDue) statusBadge='<span class="badge-due">DUE</span>';
    else statusBadge='<span class="badge-none">UPCOMING</span>';
    var billMethod;
    if(c.deductFromPayout) billMethod='<span style="background:#E3F2FD;color:#1565C0;font-size:11px;padding:2px 8px;border-radius:4px;border:1px solid #BBDEFB">Deduct from Payout</span>';
    else if(c.stripeCustomerId) billMethod='<span style="background:#E8F5E9;color:#2E7D32;font-size:11px;padding:2px 8px;border-radius:4px;border:1px solid #A5D6A7">Stripe card</span>';
    else billMethod='<span style="background:#FFEBEE;color:#C62828;font-size:11px;padding:2px 8px;border-radius:4px;border:1px solid #EF9A9A">None set</span>';
    var nextBill=c.nextBillingAt ? new Date(c.nextBillingAt).toLocaleDateString('en-NZ',{day:'2-digit',month:'short',year:'numeric'}) : 'Not set';
    var canCharge=c.subscriptionStatus!=='suspended' && c.monthlyFee>0;
    var chargeBtn=canCharge
      ? '<button class="sa-btn sa-btn-g" onclick="openCharge(\''+c.companyId+'\')">&#128176; Charge</button>'
      : '<button class="sa-btn sa-btn-n" disabled style="opacity:.5">Charge</button>';
    return '<tr>'
      +'<td><strong>'+c.name+'</strong><br><span style="font-family:monospace;font-size:10px;color:#aaa">'+c.companyId+'</span></td>'
      +'<td style="font-size:12px">'+c.packageName+'</td>'
      +'<td style="text-align:right">'+c.fleetSize+' cars</td>'
      +'<td style="text-align:right;font-weight:700;color:#1565C0">'+fmt(c.monthlyFee)+'</td>'
      +'<td>'+billMethod+'</td>'
      +'<td style="font-size:12px;color:#888">'+nextBill+'</td>'
      +'<td>'+statusBadge+'</td>'
      +'<td style="white-space:nowrap"><div style="display:flex;gap:4px">'+chargeBtn
        +' <button class="sa-btn sa-btn-n" onclick="openEdit(\''+c.companyId+'\')" style="font-size:11px">&#9881;</button></div></td>'
      +'</tr>';
  }).join('');
  document.getElementById('sub-tbody').innerHTML=html;
}

function setFilter(f,btn){
  activeFilter=f;
  document.querySelectorAll('.filter-btn').forEach(function(b){b.classList.remove('active');});
  btn.classList.add('active');
  renderRows();
}

function openCharge(cid){
  var c=allCompanies.find(function(x){return x.companyId===cid;});
  if(!c) return;
  chargeTarget=cid;
  document.getElementById('charge-modal-info').innerHTML=
    '<strong>'+c.name+'</strong><br>'
    +'Package: '+c.packageName+'<br>'
    +'Fleet: '+c.fleetSize+' cars &times; '+fmt(c.pricePerCar)+'/car<br>'
    +'<strong style="font-size:15px">Monthly Fee: '+fmt(c.monthlyFee)+'</strong>';
  document.getElementById('charge-method').value=c.deductFromPayout?'deduct':'stripe';
  document.getElementById('charge-modal').classList.add('open');
}

function confirmCharge(){
  if(!chargeTarget) return;
  var method=document.getElementById('charge-method').value;
  var btn=document.getElementById('charge-confirm-btn');
  btn.disabled=true; btn.textContent='Processing&#8230;';
  fetch('/api/sa-charge-subscription',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({companyId:chargeTarget,deductFromPayout:method==='deduct'})})
  .then(r=>r.json()).then(d=>{
    btn.disabled=false; btn.textContent='&#9989; Charge Now';
    if(d.error){ toastr.error(d.error); return; }
    toastr.success('Charged '+fmt(d.monthlyFee)+' via '+(d.method==='deduct_from_payout'?'payout deduction':'Stripe'));
    closeModal('charge-modal');
    loadBilling();
  }).catch(e=>{ btn.disabled=false; toastr.error(e.message); });
}

function openEdit(cid){
  var c=allCompanies.find(function(x){return x.companyId===cid;});
  if(!c) return;
  editTarget=cid;
  document.getElementById('edit-modal-name').textContent=c.name+' ('+cid+')';
  document.getElementById('edit-stripe-cust').value=c.stripeCustomerId||'';
  document.getElementById('edit-deduct').value=c.deductFromPayout?'true':'false';
  document.getElementById('edit-override').value=c.pricePerCar||'';
  document.getElementById('edit-suspend').value=c.subscriptionStatus==='suspended'?'true':'false';
  document.getElementById('edit-modal').classList.add('open');
}

function saveEdit(){
  if(!editTarget) return;
  var stripeCustomerId=document.getElementById('edit-stripe-cust').value.trim();
  var deductFromPayout=document.getElementById('edit-deduct').value==='true';
  var monthlyOverride=document.getElementById('edit-override').value;
  var suspend=document.getElementById('edit-suspend').value==='true';
  var patch={deductFromPayout:deductFromPayout};
  if(stripeCustomerId) patch.stripeCustomerId=stripeCustomerId;
  if(monthlyOverride) patch.monthlyOverride=parseFloat(monthlyOverride);
  if(suspend) patch.subscriptionStatus='suspended';
  fetch('/api/sa-set-company-payout-schedule',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({companyId:editTarget,...patch})})
  .then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    // Also patch subscription fields directly
    fetch('/api/sa-set-subscription-config',{method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({companyId:editTarget,stripeCustomerId,deductFromPayout,monthlyOverride:monthlyOverride||null,subscriptionStatus:suspend?'suspended':'active'})})
    .then(r=>r.json()).then(d2=>{
      if(d2&&d2.error){ toastr.error(d2.error); return; }
      toastr.success('Billing settings saved');
      closeModal('edit-modal');
      loadBilling();
    });
  }).catch(e=>toastr.error(e.message));
}

function batchCharge(){
  if(!confirm('Charge all companies whose subscription is due today? This will process Stripe charges and payout deductions.')) return;
  toastr.info('Processing subscription billing&#8230;');
  fetch('/api/sa-batch-subscription-billing',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({})})
  .then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    toastr.success('Billing complete: '+d.charged+' charged out of '+d.total+' companies');
    loadBilling();
  }).catch(e=>toastr.error(e.message));
}

function closeModal(id){ document.getElementById(id).classList.remove('open'); }
document.querySelectorAll('.modal-overlay').forEach(function(m){
  m.addEventListener('click',function(e){ if(e.target===m) m.classList.remove('open'); });
});

window._fbOnLogin = function(){ loadBilling(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
