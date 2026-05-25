<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Company Payouts &mdash; BookaWaka Admin</title>
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
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-hist{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB;font-size:11px;padding:4px 10px}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.badge-paid{background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7}
.badge-pending{background:#FFF8E1;color:#E65100;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #FFE082}
.badge-none{background:#f5f5f5;color:#aaa;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #e0e0e0}
.sched-pill{font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px}
.sched-daily{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.sched-weekly{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.sched-monthly{background:#F3E5F5;color:#6A1B9A;border:1px solid #CE93D8}
.sched-manual{background:#f5f5f5;color:#888;border:1px solid #e0e0e0}
.summary-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(155px,1fr));gap:12px;padding:16px 18px;background:#F0F7FF;border-bottom:1px solid #BBDEFB}
.sum-box{background:#fff;border-radius:6px;padding:12px 14px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.sum-box .sum-lbl{font-size:11px;color:#888;font-weight:500;margin-bottom:4px}
.sum-box .sum-val{font-size:20px;font-weight:800;color:#1565C0}
.sum-box.green .sum-val{color:#2E7D32}.sum-box.orange .sum-val{color:#E65100}
.ctrl-bar{display:flex;align-items:center;gap:10px;padding:13px 18px;background:#F0F7FF;border-bottom:1px solid #BBDEFB;flex-wrap:wrap}
.filter-btn{padding:5px 13px;border-radius:16px;border:1.5px solid #1565C0;background:#fff;color:#1565C0;font-size:12px;font-weight:600;cursor:pointer;transition:all .15s}
.filter-btn.active{background:#1565C0;color:#fff}
.hist-panel{display:none;padding:12px 18px;background:#F9FBE7;border-top:1px solid #F0F4C3}
.hist-panel.open{display:block}
.hist-row{display:flex;align-items:center;gap:12px;padding:6px 0;border-bottom:1px solid #F0F4C3;font-size:12px;flex-wrap:wrap}
.hist-row:last-child{border-bottom:none}
.stripe-inp{width:220px;padding:5px 8px;border:1.5px solid #ddd;border-radius:4px;font-size:12px;font-family:monospace}
.stripe-inp:focus{outline:none;border-color:#1565C0}
.bk-trio{display:flex;gap:8px;font-size:11.5px;color:#666}
.bk-trio span{background:#F0F7FF;border-radius:4px;padding:2px 6px;border:1px solid #BBDEFB}
.bk-trio .bk-green{background:#E8F5E9;border-color:#A5D6A7;color:#2E7D32}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:10px;padding:28px;max-width:480px;width:95%;box-shadow:0 8px 30px rgba(0,0,0,.2)}
.modal-box h3{font-size:16px;font-weight:700;margin-bottom:14px;color:#263238}
.mf label{display:block;font-size:12px;font-weight:600;color:#555;margin-bottom:4px;margin-top:10px}
.mf input,.mf select{width:100%;padding:8px 10px;border:1.5px solid #ddd;border-radius:5px;font-size:13px}
.mf input:focus,.mf select:focus{outline:none;border-color:#1565C0}
.modal-actions{display:flex;gap:8px;justify-content:flex-end;margin-top:18px}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Company Payouts &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Payouts.aspx" style="font-weight:700;color:#1565C0">&#9658; Company Payouts</a></li>
      <li><a href="SA-SubscriptionBilling.aspx">Subscription Billing</a></li>
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

  <!-- Summary -->
  <div class="sa-card" id="summary-card">
    <div class="sa-bar">
      <h3>&#128176; Company Payouts — All Services (Taxi + Food + Freight)</h3>
      <div style="display:flex;gap:8px;flex-wrap:wrap">
        <button class="sa-btn sa-btn-g" onclick="batchPay('daily')">&#9889; Pay All Daily</button>
        <button class="sa-btn sa-btn-p" onclick="batchPay('weekly')">&#128197; Pay All Weekly</button>
        <button class="sa-btn" style="background:#6A1B9A;color:#fff" onclick="batchPay('monthly')">&#128336; Pay All Monthly</button>
        <button class="sa-btn sa-btn-n" onclick="loadPayouts()">&#8635; Refresh</button>
      </div>
    </div>
    <div class="summary-grid" id="sum-grid">
      <div class="sum-box"><div class="sum-lbl">Total Pending Payouts</div><div class="sum-val" id="s-total">—</div></div>
      <div class="sum-box green"><div class="sum-lbl">Companies with Balance</div><div class="sum-val" id="s-cos">—</div></div>
      <div class="sum-box orange"><div class="sum-lbl">Total Commission Earned</div><div class="sum-val" id="s-com">—</div></div>
      <div class="sum-box"><div class="sum-lbl">No Stripe Connected</div><div class="sum-val" id="s-nostripe" style="color:#C62828">—</div></div>
    </div>
  </div>

  <!-- Filter + Table -->
  <div class="sa-card">
    <div class="ctrl-bar">
      <span style="font-size:13px;font-weight:600;color:#555">Filter by Schedule:</span>
      <button class="filter-btn active" data-f="all" onclick="setFilter('all',this)">All</button>
      <button class="filter-btn" data-f="daily" onclick="setFilter('daily',this)">Daily</button>
      <button class="filter-btn" data-f="weekly" onclick="setFilter('weekly',this)">Weekly</button>
      <button class="filter-btn" data-f="monthly" onclick="setFilter('monthly',this)">Monthly</button>
      <input id="search-inp" type="text" placeholder="Search company name..." style="padding:5px 10px;border:1.5px solid #ddd;border-radius:4px;font-size:12px;min-width:180px" oninput="renderRows()"/>
    </div>
    <div style="overflow-x:auto">
      <table class="sa-tbl">
        <thead>
          <tr>
            <th>Company</th>
            <th>Stripe Connect</th>
            <th>Schedule</th>
            <th style="text-align:right">&#128661; Taxi</th>
            <th style="text-align:right">&#127829; Food</th>
            <th style="text-align:right">&#128666; Freight</th>
            <th style="text-align:right;color:#2E7D32">Net Pending</th>
            <th>Last Payout</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="co-tbody">
          <tr><td colspan="9" style="color:#aaa;text-align:center;padding:28px">Loading&#8230;</td></tr>
        </tbody>
      </table>
    </div>
  </div>

</div>
</div>

<!-- Pay Now Modal -->
<div class="modal-overlay" id="pay-modal">
  <div class="modal-box">
    <h3>&#128176; Confirm Payout</h3>
    <div style="background:#E8F5E9;border:1px solid #A5D6A7;border-radius:6px;padding:12px 14px;font-size:13px;margin-bottom:14px" id="pay-modal-info"></div>
    <div class="mf">
      <label>Notes (optional)</label>
      <input type="text" id="pay-notes" placeholder="e.g. Weekly payout 28 Apr"/>
    </div>
    <div class="modal-actions">
      <button class="sa-btn sa-btn-n" onclick="closeModal('pay-modal')">Cancel</button>
      <button class="sa-btn sa-btn-g" onclick="confirmPay()">&#9989; Transfer Now</button>
    </div>
  </div>
</div>

<!-- Edit Company Modal -->
<div class="modal-overlay" id="edit-modal">
  <div class="modal-box">
    <h3>&#9881;&#65039; Company Payout Settings</h3>
    <div id="edit-modal-name" style="font-size:13px;color:#888;margin-bottom:10px"></div>
    <div class="mf">
      <label>Payout Schedule</label>
      <select id="edit-schedule">
        <option value="daily">Daily</option>
        <option value="weekly">Weekly</option>
        <option value="monthly">Monthly</option>
      </select>
    </div>
    <div class="mf">
      <label>Stripe Connect ID (acct_…)</label>
      <input type="text" id="edit-stripe" placeholder="acct_1AbcXyz…" style="font-family:monospace"/>
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
var allCompanies = [];
var allHistory  = {};
var activeFilter = 'all';
var payTarget = null;
var editTarget = null;

function fmt(v){ return '$'+(parseFloat(v)||0).toFixed(2); }
function schedPill(s){
  var map={daily:'sched-daily Daily',weekly:'sched-weekly Weekly',monthly:'sched-monthly Monthly'};
  var cls = map[s]||'sched-manual Manual';
  return '<span class="sched-pill '+cls.split(' ')[0]+'">'+cls.split(' ')[1]+'</span>';
}

function loadPayouts(){
  document.getElementById('co-tbody').innerHTML='<tr><td colspan="9" style="color:#aaa;text-align:center;padding:28px">Loading&#8230;</td></tr>';
  fetch('/api/sa-company-payout-summary').then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    allCompanies = d.companies||[];
    allHistory   = d.history||{};
    renderSummary();
    renderRows();
  }).catch(e=>toastr.error('Failed to load: '+e.message));
}

function renderSummary(){
  var totalNet=0, withBal=0, totalCom=0, noStripe=0;
  allCompanies.forEach(function(c){
    totalNet+=c.totalNet||0;
    if((c.totalNet||0)>0) withBal++;
    totalCom+=(c.totalCommission||0);
    if(!c.stripeConnectId) noStripe++;
  });
  document.getElementById('s-total').textContent=fmt(totalNet);
  document.getElementById('s-cos').textContent=withBal;
  document.getElementById('s-com').textContent=fmt(totalCom);
  document.getElementById('s-nostripe').textContent=noStripe;
}

function renderRows(){
  var q=(document.getElementById('search-inp').value||'').toLowerCase();
  var filtered=allCompanies.filter(function(c){
    if(activeFilter!=='all' && c.payoutSchedule!==activeFilter) return false;
    if(q && !(c.companyName||'').toLowerCase().includes(q)) return false;
    return true;
  });
  if(!filtered.length){
    document.getElementById('co-tbody').innerHTML='<tr><td colspan="9" style="color:#aaa;text-align:center;padding:24px">No companies match filter</td></tr>';
    return;
  }
  var html=filtered.map(function(c){
    var stripeHtml = c.stripeConnectId
      ? '<span style="font-family:monospace;font-size:11px;background:#E8F5E9;color:#2E7D32;padding:2px 6px;border-radius:4px;border:1px solid #A5D6A7">&#9989; '+c.stripeConnectId.slice(0,14)+'&hellip;</span>'
      : '<span style="background:#FFEBEE;color:#C62828;font-size:11px;padding:2px 7px;border-radius:4px;border:1px solid #EF9A9A">&#9888; Not linked</span>';
    var lastPayout = c.lastPayoutAt ? new Date(c.lastPayoutAt).toLocaleDateString('en-NZ',{day:'2-digit',month:'short',year:'numeric'}) : '—';
    var netBadge = (c.totalNet||0)>0
      ? '<strong style="color:#2E7D32">'+fmt(c.totalNet)+'</strong>'
      : '<span style="color:#aaa">'+fmt(0)+'</span>';
    var payBtn = (c.totalNet||0)>0 && c.stripeConnectId
      ? '<button class="sa-btn sa-btn-g" onclick="openPay(\''+c.companyId+'\')">&#128176; Pay Now</button>'
      : '<button class="sa-btn sa-btn-n" disabled style="opacity:.5">Pay Now</button>';
    var histBtn = '<button class="sa-btn sa-btn-hist" onclick="toggleHist(\''+c.companyId+'\')">History</button>';
    var editBtn = '<button class="sa-btn sa-btn-n" onclick="openEdit(\''+c.companyId+'\')" style="font-size:11px">&#9881;</button>';
    var hist = allHistory[c.companyId]||[];
    var histRows = hist.length ? hist.map(function(p){
      var dt = p.triggeredAt ? new Date(p.triggeredAt).toLocaleDateString('en-NZ',{day:'2-digit',month:'short',year:'numeric'}) : '—';
      var bk = p.breakdown||{};
      return '<div class="hist-row"><span style="color:#888;min-width:90px">'+dt+'</span>'
        +'<span class="badge-paid">PAID</span>'
        +'<strong style="color:#2E7D32;min-width:70px">'+fmt(p.amount)+'</strong>'
        +'<span style="color:#888;font-size:11px">Taxi '+fmt(bk.taxi&&bk.taxi.net)+' &bull; Food '+fmt(bk.food&&bk.food.net)+' &bull; Freight '+fmt(bk.freight&&bk.freight.net)+'</span>'
        +(p.stripeTransferId ? '<span style="font-family:monospace;font-size:10px;color:#aaa">'+p.stripeTransferId+'</span>' : '')
        +'</div>';
    }).join('') : '<div style="color:#aaa;font-size:12px;padding:8px 0">No payout history yet</div>';
    return '<tr>'
      +'<td><strong>'+c.companyName+'</strong><br><span style="font-family:monospace;font-size:10px;color:#aaa">'+c.companyId+'</span></td>'
      +'<td>'+stripeHtml+'</td>'
      +'<td>'+schedPill(c.payoutSchedule)+'</td>'
      +'<td style="text-align:right;font-size:12.5px">'+fmt(c.taxi&&c.taxi.net)+'<br><span style="color:#aaa;font-size:10px">'+((c.taxi&&c.taxi.trips)||0)+' trips</span></td>'
      +'<td style="text-align:right;font-size:12.5px">'+fmt(c.food&&c.food.net)+'<br><span style="color:#aaa;font-size:10px">'+((c.food&&c.food.orders)||0)+' orders</span></td>'
      +'<td style="text-align:right;font-size:12.5px">'+fmt(c.freight&&c.freight.net)+'<br><span style="color:#aaa;font-size:10px">'+((c.freight&&c.freight.jobs)||0)+' jobs</span></td>'
      +'<td style="text-align:right">'+netBadge+'</td>'
      +'<td style="font-size:12px;color:#888">'+lastPayout+'</td>'
      +'<td style="white-space:nowrap"><div style="display:flex;gap:4px;flex-wrap:wrap">'+payBtn+' '+histBtn+' '+editBtn+'</div></td>'
      +'</tr>'
      +'<tr><td colspan="9" style="padding:0"><div class="hist-panel" id="hist-'+c.companyId+'">'+histRows+'</div></td></tr>';
  }).join('');
  document.getElementById('co-tbody').innerHTML=html;
}

function setFilter(f,btn){
  activeFilter=f;
  document.querySelectorAll('.filter-btn').forEach(function(b){b.classList.remove('active');});
  btn.classList.add('active');
  renderRows();
}

function toggleHist(cid){
  var el=document.getElementById('hist-'+cid);
  if(el) el.classList.toggle('open');
}

function openPay(cid){
  var c=allCompanies.find(function(x){return x.companyId===cid;});
  if(!c) return;
  payTarget=cid;
  document.getElementById('pay-modal-info').innerHTML=
    '<strong>'+c.companyName+'</strong><br>'
    +'Taxi: '+fmt(c.taxi&&c.taxi.net)+' ('+((c.taxi&&c.taxi.trips)||0)+' trips)<br>'
    +'Food: '+fmt(c.food&&c.food.net)+' ('+((c.food&&c.food.orders)||0)+' orders)<br>'
    +'Freight: '+fmt(c.freight&&c.freight.net)+' ('+((c.freight&&c.freight.jobs)||0)+' jobs)<br>'
    +'<strong style="font-size:15px">Total Net: '+fmt(c.totalNet)+'</strong><br>'
    +'<span style="font-size:11px;color:#888">Sending to: '+c.stripeConnectId+'</span>';
  document.getElementById('pay-notes').value='';
  document.getElementById('pay-modal').classList.add('open');
}

function confirmPay(){
  if(!payTarget) return;
  var notes=document.getElementById('pay-notes').value;
  var btn=document.querySelector('#pay-modal .sa-btn-g');
  btn.disabled=true; btn.textContent='Sending&#8230;';
  fetch('/api/sa-trigger-company-payout',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({companyId:payTarget,notes:notes})})
  .then(r=>r.json()).then(d=>{
    btn.disabled=false; btn.textContent='&#9989; Transfer Now';
    if(d.error){ toastr.error(d.error); return; }
    toastr.success('Paid '+fmt(d.amount)+' to '+payTarget);
    closeModal('pay-modal');
    loadPayouts();
  }).catch(e=>{ btn.disabled=false; toastr.error(e.message); });
}

function openEdit(cid){
  var c=allCompanies.find(function(x){return x.companyId===cid;});
  if(!c) return;
  editTarget=cid;
  document.getElementById('edit-modal-name').textContent=c.companyName+' ('+cid+')';
  document.getElementById('edit-schedule').value=c.payoutSchedule||'weekly';
  document.getElementById('edit-stripe').value=c.stripeConnectId||'';
  document.getElementById('edit-modal').classList.add('open');
}

function saveEdit(){
  if(!editTarget) return;
  var schedule=document.getElementById('edit-schedule').value;
  var stripe=document.getElementById('edit-stripe').value.trim();
  fetch('/api/sa-set-company-payout-schedule',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({companyId:editTarget,schedule:schedule,stripeConnectId:stripe})})
  .then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    toastr.success('Settings saved');
    closeModal('edit-modal');
    loadPayouts();
  }).catch(e=>toastr.error(e.message));
}

function batchPay(schedule){
  if(!confirm('Trigger '+schedule.toUpperCase()+' batch payout for all '+schedule+' schedule companies with pending balances?')) return;
  toastr.info('Processing batch payouts&#8230;');
  fetch('/api/sa-batch-company-payouts',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({schedule:schedule})})
  .then(r=>r.json()).then(d=>{
    if(d.error){ toastr.error(d.error); return; }
    toastr.success('Batch complete: '+d.paid+' paid out of '+d.total+' companies');
    loadPayouts();
  }).catch(e=>toastr.error(e.message));
}

function closeModal(id){ document.getElementById(id).classList.remove('open'); }
document.querySelectorAll('.modal-overlay').forEach(function(m){
  m.addEventListener('click',function(e){ if(e.target===m) m.classList.remove('open'); });
});

window._fbOnLogin = function(){ loadPayouts(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
