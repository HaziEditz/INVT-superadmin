<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Platform Overview &mdash; BookaWaka Admin</title>
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
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
<style>
/* Layout */
.mr-wrap{padding:20px}
.mr-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:18px;overflow:hidden}
.mr-bar{padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;color:#fff}
.mr-bar h3{margin:0;font-size:15px;font-weight:600}

/* Summary banner */
.sum-banner{background:linear-gradient(135deg,#1565C0,#0D47A1);color:#fff;border-radius:8px;padding:20px 24px;margin-bottom:18px;box-shadow:0 2px 8px rgba(21,101,192,.3)}
.sum-banner h2{margin:0 0 16px;font-size:16px;font-weight:600;opacity:.9}
.sum-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:12px}
.sum-box{background:rgba(255,255,255,.12);border-radius:8px;padding:14px 16px;text-align:center}
.sum-box .sv{font-size:24px;font-weight:800;line-height:1;margin-bottom:4px}
.sum-box .sl{font-size:11.5px;opacity:.8;font-weight:500}
.sum-box.green{background:rgba(46,125,50,.35)}
.sum-box.amber{background:rgba(230,81,0,.35)}
.sum-box.purple{background:rgba(106,27,154,.35)}
.sum-box.teal{background:rgba(0,105,92,.35)}

/* Filters */
.mr-filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:12px 18px;background:#F5F5F5;border-bottom:1px solid #e0e0e0}
.mr-filt label{font-size:12px;font-weight:600;color:#555}
.mr-filt select,.mr-filt input[type=date]{padding:6px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;font-family:inherit}
.mr-filt select:focus,.mr-filt input:focus{outline:none;border-color:#1565C0}
.filt-btn{padding:6px 14px;border:none;border-radius:4px;background:#1565C0;color:#fff;font-size:12px;font-weight:600;cursor:pointer}
.filt-btn:hover{background:#0D47A1}
.filt-date-wrap{display:none;gap:8px;align-items:center}
.filt-date-wrap.open{display:flex}

/* Tabs */
.tab-bar{display:flex;gap:0;overflow-x:auto;border-bottom:2px solid #e0e0e0;background:#fff}
.tab-btn{padding:11px 18px;border:none;border-bottom:3px solid transparent;background:none;cursor:pointer;font-size:13px;font-weight:500;color:#757575;white-space:nowrap;transition:.15s;margin-bottom:-2px}
.tab-btn:hover{color:#1565C0;background:#F0F7FF}
.tab-btn.active{color:#1565C0;border-bottom-color:#1565C0;font-weight:700;background:#F0F7FF}
.tab-panel{display:none;padding:18px}
.tab-panel.active{display:block}

/* Tables */
.mr-tbl{width:100%;border-collapse:collapse;font-size:13px}
.mr-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.mr-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.mr-tbl tr:hover td{background:#FFFDE7}
.mr-tbl tr:last-child td{border-bottom:none}
.mr-tbl tfoot td{background:#E3F2FD;font-weight:700;border-top:2px solid #BBDEFB}
.mr-tbl.green th{background:#E8F5E9;color:#1B5E20;border-bottom-color:#A5D6A7}
.mr-tbl.green tfoot td{background:#E8F5E9;border-top-color:#A5D6A7}
.mr-tbl.purple th{background:#F3E5F5;color:#6A1B9A;border-bottom-color:#CE93D8}
.mr-tbl.purple tfoot td{background:#F3E5F5;border-top-color:#CE93D8}
.mr-tbl.amber th{background:#FFF3E0;color:#E65100;border-bottom-color:#FFCC80}
.mr-tbl.amber tfoot td{background:#FFF3E0;border-top-color:#FFCC80}
.mr-tbl.teal th{background:#E0F2F1;color:#00695C;border-bottom-color:#80CBC4}
.mr-tbl.teal tfoot td{background:#E0F2F1;border-top-color:#80CBC4}
.mr-tbl.slate th{background:#ECEFF1;color:#37474F;border-bottom-color:#B0BEC5}
.mr-tbl.slate tfoot td{background:#ECEFF1;border-top-color:#B0BEC5}

/* Pills / badges */
.pill{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600;white-space:nowrap}
.pill-ok{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.pill-err{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.pill-warn{background:#FFF3E0;color:#E65100;border:1px solid #FFCC80}
.pill-info{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.pill-grey{background:#F5F5F5;color:#757575;border:1px solid #E0E0E0}

/* Sub-summary row inside a tab */
.tab-sum{display:flex;gap:12px;flex-wrap:wrap;padding:14px 0 18px}
.tsb{background:#F0F7FF;border-radius:6px;padding:10px 16px;min-width:120px;text-align:center}
.tsb.green{background:#F1F8E9}.tsb.purple{background:#F8F0FF}.tsb.amber{background:#FFF8F0}.tsb.teal{background:#E0F7F5}.tsb.grey{background:#FAFAFA}
.tsb .tv{font-size:20px;font-weight:800;color:#1565C0}
.tsb.green .tv{color:#2E7D32}.tsb.purple .tv{color:#6A1B9A}.tsb.amber .tv{color:#E65100}.tsb.teal .tv{color:#00695C}.tsb.grey .tv{color:#37474F}
.tsb .tl{font-size:11px;color:#888;margin-top:2px}

/* Loading overlay */
.mr-loading{text-align:center;padding:40px;color:#aaa;font-size:14px}
.spinner{display:inline-block;width:24px;height:24px;border:3px solid #e0e0e0;border-top-color:#1565C0;border-radius:50%;animation:spin .8s linear infinite;vertical-align:middle;margin-right:8px}
@keyframes spin{to{transform:rotate(360deg)}}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Platform Overview &mdash; BookaWaka Admin</label></div>
  <div class="uk-navbar-flip"><ul class="uk-navbar-nav user_actions">
    <li data-uk-dropdown="{mode:'click',pos:'bottom-right'}">
      <a href="#" class="user_action_image"><img class="md-user-image" src="assets/img/bw-logo.png" alt=""/></a>
      <div class="uk-dropdown uk-dropdown-small"><ul class="uk-nav js-uk-prevent">
        <li><a href="Home.aspx">Dashboard</a></li>
        <li><a onclick="window.location.href='SA-Login.aspx'">Logout</a></li>
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
    <li class="current_section" title="Total Mobility"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8CC;</i></span><span class="menu_title">Total Mobility</span></a><ul>
      <li><a href="TM-Council-Config.aspx">Council Config</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
      <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Reports.aspx">Reports</a></li>
    </ul></li>
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Reports.aspx">Reports</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Reports.aspx">Revenue Reports</a></li>
      <li><a href="SA-MasterReport.aspx" style="font-weight:700;color:#1565C0">&#9658; Platform Overview</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-SubscriptionBilling.aspx">Subscription Billing</a></li>
      <li><a href="SA-TaxiDriverPay.aspx">Taxi Driver Pay</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="mr-wrap">

<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;margin-bottom:14px">
  <div>
    <h2 style="font-size:18px;font-weight:700;margin:0 0 3px">&#128202; Platform Overview</h2>
    <p style="font-size:13px;color:#888;margin:0">All modules in one place &mdash; Taxi &bull; Food &bull; Freight &bull; TM &bull; Driver Pay &bull; Subscriptions &bull; Payouts</p>
  </div>
  <button class="filt-btn" onclick="reloadAll()" style="display:flex;align-items:center;gap:5px">&#8635; Refresh</button>
</div>

<!-- Date Filter -->
<div class="mr-card">
  <div class="mr-filt">
    <label>Period:</label>
    <select id="filt-period" onchange="onPeriodChange()">
      <option value="today">Today</option>
      <option value="week">This Week</option>
      <option value="month" selected>This Month</option>
      <option value="year">This Year</option>
      <option value="all">All Time</option>
      <option value="custom">Custom Range</option>
    </select>
    <div class="filt-date-wrap" id="custom-dates">
      <label>From:</label><input type="date" id="filt-from"/>
      <label>To:</label><input type="date" id="filt-to"/>
      <button class="filt-btn" onclick="reloadAll()">Apply</button>
    </div>
    <span id="filt-label" style="font-size:12px;color:#888;margin-left:6px"></span>
  </div>
</div>

<!-- Summary Banner -->
<div id="summary-banner" class="sum-banner">
  <h2>&#127381; Platform Totals <span id="sum-period-label" style="font-weight:400;opacity:.75;font-size:13px"></span></h2>
  <div class="sum-grid" id="sum-grid">
    <div class="sum-box"><div class="sv" id="sg-gross">—</div><div class="sl">Total Gross Revenue</div></div>
    <div class="sum-box green"><div class="sv" id="sg-bw">—</div><div class="sl">BookaWaka Commission</div></div>
    <div class="sum-box amber"><div class="sv" id="sg-payout">—</div><div class="sl">Paid Out to Companies</div></div>
    <div class="sum-box purple"><div class="sv" id="sg-tm">—</div><div class="sl">TM Council Claims</div></div>
    <div class="sum-box teal"><div class="sv" id="sg-sub">—</div><div class="sl">Subscription Fees Collected</div></div>
    <div class="sum-box"><div class="sv" id="sg-trips">—</div><div class="sl">Taxi Trips</div></div>
    <div class="sum-box"><div class="sv" id="sg-food">—</div><div class="sl">Food Orders</div></div>
    <div class="sum-box"><div class="sv" id="sg-freight">—</div><div class="sl">Freight Deliveries</div></div>
  </div>
</div>

<!-- Tab Navigation -->
<div class="mr-card" style="overflow:visible">
  <div class="tab-bar">
    <button class="tab-btn active" onclick="showTab('all',this)">&#128202; All Totals</button>
    <button class="tab-btn" onclick="showTab('taxi',this)">&#128663; Taxi</button>
    <button class="tab-btn" onclick="showTab('food',this)">&#127829; Food Delivery</button>
    <button class="tab-btn" onclick="showTab('freight',this)">&#128230; Freight</button>
    <button class="tab-btn" onclick="showTab('tm',this)">&#9851; Total Mobility</button>
    <button class="tab-btn" onclick="showTab('driver',this)">&#128184; Driver Pay</button>
    <button class="tab-btn" onclick="showTab('subs',this)">&#128176; Subscriptions</button>
    <button class="tab-btn" onclick="showTab('payouts',this)">&#128262; Payouts</button>
  </div>

  <!-- ALL TOTALS -->
  <div id="tab-all" class="tab-panel active">
    <div id="mr-loading" class="mr-loading"><span class="spinner"></span> Loading all data&hellip;</div>
    <div id="all-content" style="display:none">
      <div class="tab-sum" id="all-sum"></div>
      <div style="overflow-x:auto"><table class="mr-tbl" id="all-tbl">
        <thead><tr>
          <th>Company</th>
          <th>&#128663; Taxi Gross</th><th>&#127829; Food Gross</th><th>&#128230; Freight Gross</th>
          <th>Total Gross</th><th>BW Commission</th><th>Net Owed</th><th>Last Payout</th>
        </tr></thead>
        <tbody id="all-tbody"></tbody>
        <tfoot><tr id="all-tfoot">
          <td><strong>TOTAL</strong></td><td id="ft-taxi"></td><td id="ft-food"></td><td id="ft-fr"></td>
          <td id="ft-gross"></td><td id="ft-bw"></td><td id="ft-net"></td><td></td>
        </tr></tfoot>
      </table></div>
    </div>
  </div>

  <!-- TAXI -->
  <div id="tab-taxi" class="tab-panel">
    <div class="tab-sum" id="taxi-sum"></div>
    <div style="overflow-x:auto"><table class="mr-tbl" id="taxi-tbl">
      <thead><tr>
        <th>Company</th><th>Trips</th><th>Gross Fare</th><th>Commission %</th>
        <th>BW Commission</th><th>Company Net</th>
        <th>Cash</th><th>Card / Stripe</th><th>Account</th><th>TM</th>
      </tr></thead>
      <tbody id="taxi-tbody"></tbody>
      <tfoot><tr>
        <td><strong>TOTAL</strong></td>
        <td id="tx-trips"></td><td id="tx-gross"></td><td></td>
        <td id="tx-com"></td><td id="tx-net"></td>
        <td id="tx-cash"></td><td id="tx-card"></td><td id="tx-acct"></td><td id="tx-tm-fare"></td>
      </tr></tfoot>
    </table></div>
  </div>

  <!-- FOOD -->
  <div id="tab-food" class="tab-panel">
    <div class="tab-sum" id="food-sum"></div>
    <div style="overflow-x:auto"><table class="mr-tbl green" id="food-tbl">
      <thead><tr>
        <th>Company</th><th>Orders</th><th>Order Value</th>
        <th>Commission</th><th>Restaurant Payout</th><th>Driver Tips</th>
      </tr></thead>
      <tbody id="food-tbody"></tbody>
      <tfoot><tr>
        <td><strong>TOTAL</strong></td>
        <td id="fd-orders"></td><td id="fd-gross"></td>
        <td id="fd-com"></td><td id="fd-net"></td><td id="fd-tips"></td>
      </tr></tfoot>
    </table></div>
  </div>

  <!-- FREIGHT -->
  <div id="tab-freight" class="tab-panel">
    <div class="tab-sum" id="freight-sum"></div>
    <div style="overflow-x:auto"><table class="mr-tbl purple" id="freight-tbl">
      <thead><tr>
        <th>Company</th><th>Deliveries</th><th>Gross Amount</th>
        <th>Commission</th><th>Net Payout</th>
      </tr></thead>
      <tbody id="freight-tbody"></tbody>
      <tfoot><tr>
        <td><strong>TOTAL</strong></td>
        <td id="fr-jobs"></td><td id="fr-gross"></td>
        <td id="fr-com"></td><td id="fr-net"></td>
      </tr></tfoot>
    </table></div>
  </div>

  <!-- TM -->
  <div id="tab-tm" class="tab-panel">
    <div class="tab-sum" id="tm-sum"></div>
    <div style="overflow-x:auto"><table class="mr-tbl teal" id="tm-tbl">
      <thead><tr>
        <th>Company</th><th>TM Trips</th><th>Total Meter Fare</th>
        <th>TM Subsidy</th><th>Hoist Subsidy</th><th>Council Total Claim</th><th>Passenger Pays</th>
      </tr></thead>
      <tbody id="tm-tbody"></tbody>
      <tfoot><tr>
        <td><strong>TOTAL</strong></td>
        <td id="tm-trips"></td><td id="tm-fare"></td>
        <td id="tm-sub"></td><td id="tm-hoist"></td><td id="tm-claim"></td><td id="tm-pax"></td>
      </tr></tfoot>
    </table></div>
  </div>

  <!-- DRIVER PAY -->
  <div id="tab-driver" class="tab-panel">
    <div class="tab-sum" id="driver-sum"></div>
    <div style="font-size:13px;font-weight:600;color:#E65100;margin-bottom:10px">&#128663; Taxi Drivers</div>
    <div style="overflow-x:auto"><table class="mr-tbl amber" id="taxi-drv-tbl">
      <thead><tr>
        <th>Company</th><th>Driver</th><th>Total Earned</th><th>Pending (Unpaid)</th><th>Last Paid</th>
      </tr></thead>
      <tbody id="taxi-drv-tbody"><tr><td colspan="5" style="text-align:center;color:#aaa;padding:20px">No taxi driver earnings recorded yet.</td></tr></tbody>
      <tfoot><tr>
        <td colspan="2"><strong>TOTAL</strong></td>
        <td id="td-earned"></td><td id="td-pending"></td><td></td>
      </tr></tfoot>
    </table></div>
    <div style="font-size:13px;font-weight:600;color:#6A1B9A;margin:20px 0 10px">&#128230; Freight Drivers</div>
    <div style="overflow-x:auto"><table class="mr-tbl purple" id="fr-drv-tbl">
      <thead><tr>
        <th>Company</th><th>Driver</th><th>Total Earned</th><th>Pending (Unpaid)</th><th>Deliveries</th>
      </tr></thead>
      <tbody id="fr-drv-tbody"><tr><td colspan="5" style="text-align:center;color:#aaa;padding:20px">No freight driver earnings recorded yet.</td></tr></tbody>
      <tfoot><tr>
        <td colspan="2"><strong>TOTAL</strong></td>
        <td id="fd-earned"></td><td id="fd-pending"></td><td></td>
      </tr></tfoot>
    </table></div>
  </div>

  <!-- SUBSCRIPTIONS -->
  <div id="tab-subs" class="tab-panel">
    <div class="tab-sum" id="subs-sum"></div>
    <div style="overflow-x:auto"><table class="mr-tbl slate" id="subs-tbl">
      <thead><tr>
        <th>Company</th><th>Period</th><th>Amount</th><th>Status</th><th>Method</th><th>Paid At</th>
      </tr></thead>
      <tbody id="subs-tbody"></tbody>
      <tfoot><tr>
        <td colspan="2"><strong>TOTAL</strong></td>
        <td id="sb-total"></td><td id="sb-status"></td><td></td><td></td>
      </tr></tfoot>
    </table></div>
  </div>

  <!-- PAYOUTS -->
  <div id="tab-payouts" class="tab-panel">
    <div class="tab-sum" id="payouts-sum"></div>
    <div style="overflow-x:auto"><table class="mr-tbl" id="payouts-tbl">
      <thead><tr>
        <th>Date</th><th>Company</th><th>Amount</th>
        <th>Taxi</th><th>Food</th><th>Freight</th>
        <th>Stripe Transfer</th><th>Notes</th>
      </tr></thead>
      <tbody id="payouts-tbody"></tbody>
      <tfoot><tr>
        <td colspan="2"><strong>TOTAL PAID OUT</strong></td>
        <td id="po-total"></td><td id="po-taxi"></td><td id="po-food"></td><td id="po-fr"></td><td colspan="2"></td>
      </tr></tfoot>
    </table></div>
  </div>

</div>
</div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
/* ══════════════════════════════════════════════════════
   PLATFORM OVERVIEW — Master Report
   ══════════════════════════════════════════════════════ */

var allData = {};

function $e(id){ return document.getElementById(id); }
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmt(n){ return '$'+(+(n||0)).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g,','); }
function fmtN(n){ return String(+(n||0)).replace(/\B(?=(\d{3})+(?!\d))/g,','); }

/* ── Date range ──────────────────────────────────────── */
function getRange(){
  var p=$e('filt-period').value;
  var now=Date.now();
  var d=new Date(); d.setHours(0,0,0,0);
  if(p==='today') return { from:d.getTime(), to:now, label:'Today' };
  if(p==='week'){
    var w=new Date(d); w.setDate(d.getDate()-((d.getDay()+6)%7));
    return { from:w.getTime(), to:now, label:'This Week' };
  }
  if(p==='month'){
    var m=new Date(d.getFullYear(),d.getMonth(),1);
    return { from:m.getTime(), to:now, label:'This Month' };
  }
  if(p==='year'){
    var y=new Date(d.getFullYear(),0,1);
    return { from:y.getTime(), to:now, label:'This Year' };
  }
  if(p==='custom'){
    var fv=$e('filt-from').value, tv=$e('filt-to').value;
    var fr=fv?new Date(fv).getTime():0;
    var to=tv?new Date(tv).getTime()+86399999:now;
    return { from:fr, to:to, label:fv+' \u2192 '+tv };
  }
  return { from:0, to:now, label:'All Time' };
}
function onPeriodChange(){
  var p=$e('filt-period').value;
  $e('custom-dates').classList.toggle('open',p==='custom');
  if(p!=='custom') reloadAll();
}

/* ── Tab switching ───────────────────────────────────── */
function showTab(id,btn){
  document.querySelectorAll('.tab-panel').forEach(function(el){ el.classList.remove('active'); });
  document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
  document.getElementById('tab-'+id).classList.add('active');
  btn.classList.add('active');
}

/* ── Helpers ─────────────────────────────────────────── */
function tsBox(cls,val,lbl){ return '<div class="tsb '+cls+'"><div class="tv">'+val+'</div><div class="tl">'+lbl+'</div></div>'; }
function emptyRow(cols,msg){ return '<tr><td colspan="'+cols+'" style="text-align:center;color:#aaa;padding:24px;font-style:italic">'+msg+'</td></tr>'; }

/* ── Load all data ───────────────────────────────────── */
function reloadAll(){
  var range=getRange();
  $e('sum-period-label').textContent='('+range.label+')';
  $e('mr-loading').style.display='block';
  $e('all-content').style.display='none';

  Promise.all([
    adminRead('completedJobs'),
    adminRead('foodOrders'),
    adminRead('freightOrders'),
    adminRead('driverEarnings'),
    adminRead('superBilling'),
    adminRead('companyPayouts'),
    adminRead('superClients'),
    adminRead('allbookings')
  ]).then(function(results){
    allData = {
      jobs:        results[0]||{},
      food:        results[1]||{},
      freight:     results[2]||{},
      drivers:     results[3]||{},
      billing:     results[4]||{},
      payouts:     results[5]||{},
      clients:     results[6]||{},
      allbookings: results[7]||{}
    };
    $e('mr-loading').style.display='none';
    $e('all-content').style.display='block';
    renderAll(range);
  }).catch(function(e){
    $e('mr-loading').innerHTML='<span style="color:#C62828">Error loading data: '+esc(e.message)+'</span>';
  });
}

/* ══════════════════ RENDER ALL ══════════════════ */
function renderAll(range){
  var from=range.from, to=range.to;
  var clients=allData.clients;
  var cnames={};
  Object.entries(clients).forEach(function(kv){ cnames[kv[0]]=kv[1].name||kv[0]; });

  // ── 1) TAXI TRIPS ──────────────────────────────
  // Merge completedJobs (hail) + allbookings (dispatched) per cid.
  // allbookings records use PascalCase field names on historical data:
  //   fare → FinalFare, completedAt_ISO → CompletedAt_ISO, status → Status
  // Dedup by booking key — completedJobs wins if same key appears in both.
  var mergedJobs={};
  Object.entries(allData.jobs).forEach(function(kv){
    var cid=kv[0], jobs=kv[1]||{};
    if(!mergedJobs[cid]) mergedJobs[cid]={};
    Object.entries(jobs).forEach(function(jkv){ mergedJobs[cid][jkv[0]]=jkv[1]; });
  });
  Object.entries(allData.allbookings).forEach(function(kv){
    var cid=kv[0], jobs=kv[1]||{};
    if(!mergedJobs[cid]) mergedJobs[cid]={};
    Object.entries(jobs).forEach(function(jkv){
      var key=jkv[0], j=jkv[1];
      var st=(j.status||j.Status||'').toLowerCase();
      if(st!=='completed') return;
      if(!mergedJobs[cid][key]) mergedJobs[cid][key]=j;
    });
  });

  var taxiByCompany={}, tmByCompany={};
  Object.entries(mergedJobs).forEach(function(cidEntry){
    var cid=cidEntry[0], jobs=cidEntry[1]||{};
    var co=clients[cid]||{};
    var commPct=+(co.commissionPct||15);
    if(!taxiByCompany[cid]) taxiByCompany[cid]={name:cnames[cid]||cid,trips:0,gross:0,com:0,net:0,cash:0,card:0,acct:0,tmFare:0,commPct:commPct};
    if(!tmByCompany[cid]) tmByCompany[cid]={name:cnames[cid]||cid,trips:0,fare:0,sub:0,hoist:0,claim:0,pax:0};
    Object.values(jobs).forEach(function(j){
      var rawTs=j.completedAt_ISO||j.CompletedAt_ISO||j.completedAt||j.startedAt||j.createdAt||0;
      var ts=rawTs?(typeof rawTs==='number'?rawTs:new Date(rawTs).getTime()):0;
      if(ts<from||ts>to) return;
      var fare=+(j.fare||j.FinalFare||j.meterFare||0);
      var isTM=(j.paymentType||j.paymentMethod||j.PaymentType||'').toLowerCase()==='total_mobility';
      if(isTM){
        var t=tmByCompany[cid];
        t.trips++; t.fare+=fare;
        t.sub+=+(j.tmSubsidy||j.tmSubsidyFare||0);
        t.hoist+=+(j.tmHoistFeeTotal||j.tmSubsidyHoist||0);
        t.claim+=+(j.tmSubsidy||j.tmSubsidyFare||0)+(+(j.tmHoistFeeTotal||j.tmSubsidyHoist||0));
        t.pax+=+(j.tmPassengerAmount||j.tmPassengerPays||j.passengerPays||0);
        var tx=taxiByCompany[cid];
        tx.trips++; tx.gross+=fare; tx.com+=fare*commPct/100; tx.net+=fare*(1-commPct/100); tx.tmFare+=fare;
      } else {
        var tx=taxiByCompany[cid];
        tx.trips++; tx.gross+=fare;
        var com=fare*commPct/100;
        tx.com+=com; tx.net+=fare-com;
        var pt=(j.paymentType||j.paymentMethod||j.PaymentType||'').toLowerCase();
        if(pt==='cash'||pt==='1') tx.cash+=fare;
        else if(pt==='account'||pt==='acc'||pt==='2') tx.acct+=fare;
        else tx.card+=fare;
      }
    });
  });

  // ── 2) FOOD ORDERS ────────────────────────────
  var foodByCompany={};
  Object.entries(allData.food).forEach(function(cidEntry){
    var cid=cidEntry[0], orders=cidEntry[1]||{};
    if(!foodByCompany[cid]) foodByCompany[cid]={name:cnames[cid]||cid,orders:0,gross:0,com:0,net:0,tips:0};
    Object.values(orders).forEach(function(o){
      if(o.status!=='delivered') return;
      var rawTs=o.completedAt||o.deliveredAt||o.createdAt||0;
      var ts=rawTs?(typeof rawTs==='number'?rawTs:new Date(rawTs).getTime()):0;
      if(ts<from||ts>to) return;
      var fc=foodByCompany[cid];
      fc.orders++; fc.gross+=+(o.subtotal||o.amount||0);
      fc.com+=+(o.foodCommission||o.commission||0);
      fc.net+=+(o.restaurantPayout||0);
      fc.tips+=+(o.tip||o.tipAmount||0);
    });
  });

  // ── 3) FREIGHT ORDERS ─────────────────────────
  var frByCompany={};
  Object.entries(allData.freight).forEach(function(cidEntry){
    var cid=cidEntry[0], orders=cidEntry[1]||{};
    if(!frByCompany[cid]) frByCompany[cid]={name:cnames[cid]||cid,jobs:0,gross:0,com:0,net:0};
    Object.values(orders).forEach(function(o){
      if(o.deliveryConfirmed!==true&&o.status!=='delivered') return;
      var rawTs=o.deliveredAt||o.completedAt||o.createdAt||0;
      var ts=rawTs?(typeof rawTs==='number'?rawTs:new Date(rawTs).getTime()):0;
      if(ts<from||ts>to) return;
      var fc=frByCompany[cid];
      fc.jobs++; fc.gross+=+(o.amount||0);
      fc.com+=+(o.freightCommission||o.commission||0);
      fc.net+=+(o.freightPayout||0);
    });
  });

  // ── 4) DRIVER EARNINGS ────────────────────────
  var taxiDrivers=[], frDrivers=[];
  var drvData=allData.drivers||{};
  // Taxi
  Object.entries(drvData.taxi||{}).forEach(function(cidEntry){
    var cid=cidEntry[0], drivers=cidEntry[1]||{};
    Object.entries(drivers).forEach(function(dEntry){
      var did=dEntry[0], d=dEntry[1]||{};
      taxiDrivers.push({cid:cid,cname:cnames[cid]||cid,did:did,name:d.name||d.driverName||did,earned:+(d.totalEarned||0),pending:+(d.pendingAmount||0),lastPaid:d.lastPaidAt||''});
    });
  });
  // Freight
  Object.entries(drvData.freight||{}).forEach(function(cidEntry){
    var cid=cidEntry[0], drivers=cidEntry[1]||{};
    Object.entries(drivers).forEach(function(dEntry){
      var did=dEntry[0], d=dEntry[1]||{};
      var deliveries=Object.keys(d.deliveries||{}).length;
      frDrivers.push({cid:cid,cname:cnames[cid]||cid,did:did,name:d.name||d.driverName||did,earned:+(d.totalEarned||0),pending:+(d.pendingAmount||0),deliveries:deliveries});
    });
  });

  // ── 5) SUBSCRIPTION INVOICES ──────────────────
  var subRows=[];
  Object.entries(allData.billing).forEach(function(cidEntry){
    var cid=cidEntry[0], b=cidEntry[1]||{};
    Object.entries(b.invoices||{}).forEach(function(invEntry){
      var invId=invEntry[0], inv=invEntry[1]||{};
      // paidAt = Unix ms (Stripe webhook); paidDate = 'YYYY-MM-DD' (SA admin UI)
      var paidTs = inv.paidAt ? +(inv.paidAt) : (inv.paidDate ? new Date(inv.paidDate).getTime() : 0);
      var ts = inv.createdAt ? new Date(inv.createdAt).getTime() : paidTs;
      if(ts && (ts<from||ts>to)) return;
      subRows.push({
        cid:cid, cname:cnames[cid]||cid, period:inv.period||'',
        amount:+(inv.amount||0), status:inv.status||'unpaid',
        method:inv.paidVia||inv.paidRef||inv.method||'',
        paidTs:paidTs
      });
    });
  });

  // ── 6) COMPANY PAYOUTS ────────────────────────
  var payoutRows=[];
  Object.entries(allData.payouts).forEach(function(cidEntry){
    var cid=cidEntry[0], pMap=cidEntry[1]||{};
    Object.values(pMap).forEach(function(p){
      var ts=+(p.triggeredAt||p.paidAt||0);
      if(ts<from||ts>to) return;
      var bd=p.breakdown||{};
      payoutRows.push({
        cid:cid, cname:cnames[cid]||cid,
        amount:+(p.amount||0),
        taxiNet:+((bd.taxi&&bd.taxi.net)||p.taxiNet||0),
        foodNet:+((bd.food&&bd.food.net)||p.foodNet||0),
        freightNet:+((bd.freight&&bd.freight.net)||p.freightNet||0),
        stripeId:p.stripeTransferId||p.transferId||'',
        notes:p.notes||'', ts:ts
      });
    });
  });
  payoutRows.sort(function(a,b){return b.ts-a.ts;});

  /* ════ RENDER TABS ════ */
  renderSummaryBanner(taxiByCompany,foodByCompany,frByCompany,tmByCompany,subRows,payoutRows);
  renderAllTab(taxiByCompany,foodByCompany,frByCompany,clients);
  renderTaxiTab(taxiByCompany);
  renderFoodTab(foodByCompany);
  renderFreightTab(frByCompany);
  renderTMTab(tmByCompany);
  renderDriverTab(taxiDrivers,frDrivers);
  renderSubsTab(subRows);
  renderPayoutsTab(payoutRows);
}

/* ── Summary Banner ─────────────────────────────────── */
function renderSummaryBanner(tx,fd,fr,tm,subs,po){
  var taxiGross=Object.values(tx).reduce(function(s,c){return s+c.gross;},0);
  var foodGross=Object.values(fd).reduce(function(s,c){return s+c.gross;},0);
  var frGross=Object.values(fr).reduce(function(s,c){return s+c.gross;},0);
  var totalGross=taxiGross+foodGross+frGross;
  var taxiCom=Object.values(tx).reduce(function(s,c){return s+c.com;},0);
  var foodCom=Object.values(fd).reduce(function(s,c){return s+c.com;},0);
  var frCom=Object.values(fr).reduce(function(s,c){return s+c.com;},0);
  var totalCom=taxiCom+foodCom+frCom;
  var paidOut=po.reduce(function(s,p){return s+p.amount;},0);
  var tmClaim=Object.values(tm).reduce(function(s,c){return s+c.claim;},0);
  var subCollected=subs.filter(function(s){return s.status==='paid';}).reduce(function(s,i){return s+i.amount;},0);
  var taxiTrips=Object.values(tx).reduce(function(s,c){return s+c.trips;},0);
  var foodOrders=Object.values(fd).reduce(function(s,c){return s+c.orders;},0);
  var frJobs=Object.values(fr).reduce(function(s,c){return s+c.jobs;},0);
  $e('sg-gross').textContent=fmt(totalGross);
  $e('sg-bw').textContent=fmt(totalCom);
  $e('sg-payout').textContent=fmt(paidOut);
  $e('sg-tm').textContent=fmt(tmClaim);
  $e('sg-sub').textContent=fmt(subCollected);
  $e('sg-trips').textContent=fmtN(taxiTrips);
  $e('sg-food').textContent=fmtN(foodOrders);
  $e('sg-freight').textContent=fmtN(frJobs);
}

/* ── All Totals Tab ──────────────────────────────────── */
function renderAllTab(tx,fd,fr,clients){
  var cids=new Set([].concat(Object.keys(tx),Object.keys(fd),Object.keys(fr)));
  var allSum={gross:0,com:0,net:0,taxiG:0,foodG:0,frG:0};
  var rows=[];
  Array.from(cids).sort(function(a,b){return ((clients[a]&&clients[a].name)||a).localeCompare((clients[b]&&clients[b].name)||b);}).forEach(function(cid){
    var t=tx[cid]||{gross:0,com:0,net:0,trips:0};
    var f=fd[cid]||{gross:0,com:0,net:0,orders:0};
    var r=fr[cid]||{gross:0,com:0,net:0,jobs:0};
    var gross=t.gross+f.gross+r.gross;
    var com=t.com+f.com+r.com;
    var net=t.net+f.net+r.net;
    var co=clients[cid]||{};
    var lastPay=co.lastPayoutAt?(new Date(co.lastPayoutAt).toLocaleDateString()):'—';
    allSum.gross+=gross; allSum.com+=com; allSum.net+=net;
    allSum.taxiG+=t.gross; allSum.foodG+=f.gross; allSum.frG+=r.gross;
    rows.push('<tr>'
      +'<td><div style="font-weight:600;color:#1565C0">'+esc((co.name||cid))+'</div><div style="font-size:10.5px;color:#aaa;font-family:monospace">'+esc(cid)+'</div></td>'
      +'<td>'+fmt(t.gross)+(t.trips?'<br><span style="font-size:11px;color:#aaa">'+t.trips+' trips</span>':'')+'</td>'
      +'<td>'+fmt(f.gross)+(f.orders?'<br><span style="font-size:11px;color:#aaa">'+f.orders+' orders</span>':'')+'</td>'
      +'<td>'+fmt(r.gross)+(r.jobs?'<br><span style="font-size:11px;color:#aaa">'+r.jobs+' jobs</span>':'')+'</td>'
      +'<td style="font-weight:700">'+fmt(gross)+'</td>'
      +'<td style="color:#2E7D32;font-weight:600">'+fmt(com)+'</td>'
      +'<td style="color:#E65100;font-weight:600">'+fmt(net)+'</td>'
      +'<td style="font-size:12px;color:#888">'+esc(lastPay)+'</td>'
      +'</tr>');
  });
  $e('all-tbody').innerHTML=rows.length?rows.join(''):emptyRow(8,'No transactions in this period.');
  $e('ft-taxi').textContent=fmt(allSum.taxiG);
  $e('ft-food').textContent=fmt(allSum.foodG);
  $e('ft-fr').textContent=fmt(allSum.frG);
  $e('ft-gross').textContent=fmt(allSum.gross);
  $e('ft-bw').textContent=fmt(allSum.com);
  $e('ft-net').textContent=fmt(allSum.net);
  // sub-summary
  $e('all-sum').innerHTML=
    tsBox('',''+fmtN(Object.values(tx).reduce(function(s,c){return s+c.trips;},0)),'Total Taxi Trips')
    +tsBox('green',''+fmtN(Object.values(fd).reduce(function(s,c){return s+c.orders;},0)),'Food Orders')
    +tsBox('purple',''+fmtN(Object.values(fr).reduce(function(s,c){return s+c.jobs;},0)),'Freight Deliveries')
    +tsBox('',''+fmt(allSum.gross),'Total Gross')
    +tsBox('green',''+fmt(allSum.com),'BW Commission')
    +tsBox('amber',''+fmt(allSum.net),'Net to Companies');
}

/* ── Taxi Tab ───────────────────────────────────────── */
function renderTaxiTab(tx){
  var tots={trips:0,gross:0,com:0,net:0,cash:0,card:0,acct:0,tm:0};
  var rows=Object.values(tx).sort(function(a,b){return b.gross-a.gross;}).map(function(c){
    tots.trips+=c.trips;tots.gross+=c.gross;tots.com+=c.com;tots.net+=c.net;
    tots.cash+=c.cash;tots.card+=c.card;tots.acct+=c.acct;tots.tm+=c.tmFare;
    return '<tr><td><strong style="color:#1565C0">'+esc(c.name)+'</strong></td>'
      +'<td>'+fmtN(c.trips)+'</td><td>'+fmt(c.gross)+'</td>'
      +'<td><span class="pill pill-info">'+c.commPct+'%</span></td>'
      +'<td>'+fmt(c.com)+'</td><td style="font-weight:700">'+fmt(c.net)+'</td>'
      +'<td>'+fmt(c.cash)+'</td><td>'+fmt(c.card)+'</td><td>'+fmt(c.acct)+'</td><td>'+fmt(c.tmFare)+'</td>'
      +'</tr>';
  });
  $e('taxi-tbody').innerHTML=rows.length?rows.join(''):emptyRow(10,'No taxi trips in this period.');
  $e('tx-trips').textContent=fmtN(tots.trips);$e('tx-gross').textContent=fmt(tots.gross);
  $e('tx-com').textContent=fmt(tots.com);$e('tx-net').textContent=fmt(tots.net);
  $e('tx-cash').textContent=fmt(tots.cash);$e('tx-card').textContent=fmt(tots.card);
  $e('tx-acct').textContent=fmt(tots.acct);$e('tx-tm-fare').textContent=fmt(tots.tm);
  $e('taxi-sum').innerHTML=
    tsBox('',''+fmtN(tots.trips),'Total Trips')
    +tsBox('',''+fmt(tots.gross),'Gross Fare')
    +tsBox('green',''+fmt(tots.com),'BW Commission')
    +tsBox('amber',''+fmt(tots.net),'Company Net')
    +tsBox('',''+fmt(tots.cash),'Cash Paid')
    +tsBox('',''+fmt(tots.card),'Card / Stripe')
    +tsBox('teal',''+fmt(tots.tm),'TM Trips Fare');
}

/* ── Food Tab ────────────────────────────────────────── */
function renderFoodTab(fd){
  var tots={orders:0,gross:0,com:0,net:0,tips:0};
  var rows=Object.values(fd).sort(function(a,b){return b.gross-a.gross;}).map(function(c){
    tots.orders+=c.orders;tots.gross+=c.gross;tots.com+=c.com;tots.net+=c.net;tots.tips+=c.tips;
    return '<tr><td><strong style="color:#1B5E20">'+esc(c.name)+'</strong></td>'
      +'<td>'+fmtN(c.orders)+'</td><td>'+fmt(c.gross)+'</td>'
      +'<td>'+fmt(c.com)+'</td><td style="font-weight:700">'+fmt(c.net)+'</td><td>'+fmt(c.tips)+'</td>'
      +'</tr>';
  });
  $e('food-tbody').innerHTML=rows.length?rows.join(''):emptyRow(6,'No food orders in this period.');
  $e('fd-orders').textContent=fmtN(tots.orders);$e('fd-gross').textContent=fmt(tots.gross);
  $e('fd-com').textContent=fmt(tots.com);$e('fd-net').textContent=fmt(tots.net);$e('fd-tips').textContent=fmt(tots.tips);
  $e('food-sum').innerHTML=
    tsBox('green',''+fmtN(tots.orders),'Orders Delivered')
    +tsBox('green',''+fmt(tots.gross),'Total Order Value')
    +tsBox('',''+fmt(tots.com),'BW Commission')
    +tsBox('amber',''+fmt(tots.net),'Restaurant Payouts')
    +tsBox('',''+fmt(tots.tips),'Driver Tips');
}

/* ── Freight Tab ─────────────────────────────────────── */
function renderFreightTab(fr){
  var tots={jobs:0,gross:0,com:0,net:0};
  var rows=Object.values(fr).sort(function(a,b){return b.gross-a.gross;}).map(function(c){
    tots.jobs+=c.jobs;tots.gross+=c.gross;tots.com+=c.com;tots.net+=c.net;
    return '<tr><td><strong style="color:#6A1B9A">'+esc(c.name)+'</strong></td>'
      +'<td>'+fmtN(c.jobs)+'</td><td>'+fmt(c.gross)+'</td>'
      +'<td>'+fmt(c.com)+'</td><td style="font-weight:700">'+fmt(c.net)+'</td>'
      +'</tr>';
  });
  $e('freight-tbody').innerHTML=rows.length?rows.join(''):emptyRow(5,'No freight deliveries in this period.');
  $e('fr-jobs').textContent=fmtN(tots.jobs);$e('fr-gross').textContent=fmt(tots.gross);
  $e('fr-com').textContent=fmt(tots.com);$e('fr-net').textContent=fmt(tots.net);
  $e('freight-sum').innerHTML=
    tsBox('purple',''+fmtN(tots.jobs),'Deliveries')
    +tsBox('purple',''+fmt(tots.gross),'Gross Amount')
    +tsBox('',''+fmt(tots.com),'BW Commission')
    +tsBox('amber',''+fmt(tots.net),'Net Payouts');
}

/* ── TM Tab ──────────────────────────────────────────── */
function renderTMTab(tm){
  var tots={trips:0,fare:0,sub:0,hoist:0,claim:0,pax:0};
  var rows=Object.values(tm).sort(function(a,b){return b.trips-a.trips;}).map(function(c){
    tots.trips+=c.trips;tots.fare+=c.fare;tots.sub+=c.sub;tots.hoist+=c.hoist;tots.claim+=c.claim;tots.pax+=c.pax;
    return '<tr><td><strong style="color:#00695C">'+esc(c.name)+'</strong></td>'
      +'<td>'+fmtN(c.trips)+'</td><td>'+fmt(c.fare)+'</td>'
      +'<td>'+fmt(c.sub)+'</td><td>'+fmt(c.hoist)+'</td>'
      +'<td style="font-weight:700">'+fmt(c.claim)+'</td><td>'+fmt(c.pax)+'</td>'
      +'</tr>';
  });
  $e('tm-tbody').innerHTML=rows.length?rows.join(''):emptyRow(7,'No TM trips in this period.');
  $e('tm-trips').textContent=fmtN(tots.trips);$e('tm-fare').textContent=fmt(tots.fare);
  $e('tm-sub').textContent=fmt(tots.sub);$e('tm-hoist').textContent=fmt(tots.hoist);
  $e('tm-claim').textContent=fmt(tots.claim);$e('tm-pax').textContent=fmt(tots.pax);
  $e('tm-sum').innerHTML=
    tsBox('teal',''+fmtN(tots.trips),'TM Trips')
    +tsBox('teal',''+fmt(tots.fare),'Total Meter Fare')
    +tsBox('',''+fmt(tots.sub),'TM Subsidy (Fare)')
    +tsBox('',''+fmt(tots.hoist),'Hoist Subsidy')
    +tsBox('teal',''+fmt(tots.claim),'Total Council Claim')
    +tsBox('',''+fmt(tots.pax),'Passenger Pays');
}

/* ── Driver Tab ──────────────────────────────────────── */
function renderDriverTab(taxiDrvs,frDrvs){
  // Taxi drivers
  var txTots={earned:0,pending:0};
  var txRows=taxiDrvs.sort(function(a,b){return b.pending-a.pending;}).map(function(d){
    txTots.earned+=d.earned;txTots.pending+=d.pending;
    return '<tr><td>'+esc(d.cname)+'</td><td><strong>'+esc(d.name)+'</strong></td>'
      +'<td>'+fmt(d.earned)+'</td>'
      +'<td>'+(d.pending>0?'<span class="pill pill-warn">'+fmt(d.pending)+'</span>':'<span class="pill pill-ok">'+fmt(0)+'</span>')+'</td>'
      +'<td style="font-size:11.5px;color:#888">'+esc(d.lastPaid?new Date(+d.lastPaid).toLocaleDateString():'Never paid')+'</td>'
      +'</tr>';
  });
  $e('taxi-drv-tbody').innerHTML=txRows.length?txRows.join(''):emptyRow(5,'No taxi driver earnings recorded.');
  $e('td-earned').textContent=fmt(txTots.earned);$e('td-pending').textContent=fmt(txTots.pending);

  // Freight drivers
  var frTots={earned:0,pending:0};
  var frRows=frDrvs.sort(function(a,b){return b.pending-a.pending;}).map(function(d){
    frTots.earned+=d.earned;frTots.pending+=d.pending;
    return '<tr><td>'+esc(d.cname)+'</td><td><strong>'+esc(d.name)+'</strong></td>'
      +'<td>'+fmt(d.earned)+'</td>'
      +'<td>'+(d.pending>0?'<span class="pill pill-warn">'+fmt(d.pending)+'</span>':'<span class="pill pill-ok">'+fmt(0)+'</span>')+'</td>'
      +'<td>'+fmtN(d.deliveries)+'</td>'
      +'</tr>';
  });
  $e('fr-drv-tbody').innerHTML=frRows.length?frRows.join(''):emptyRow(5,'No freight driver earnings recorded.');
  $e('fd-earned').textContent=fmt(frTots.earned);$e('fd-pending').textContent=fmt(frTots.pending);

  $e('driver-sum').innerHTML=
    tsBox('amber',''+fmtN(taxiDrvs.length),'Taxi Drivers')
    +tsBox('amber',''+fmt(txTots.earned),'Taxi Total Earned')
    +tsBox('amber',''+fmt(txTots.pending),'Taxi Pending Pay')
    +tsBox('purple',''+fmtN(frDrvs.length),'Freight Drivers')
    +tsBox('purple',''+fmt(frTots.earned),'Freight Total Earned')
    +tsBox('purple',''+fmt(frTots.pending),'Freight Pending Pay');
}

/* ── Subscriptions Tab ────────────────────────────────── */
function renderSubsTab(subs){
  var tots={total:0,paid:0,unpaid:0,overdue:0};
  var rows=subs.sort(function(a,b){return (b.period||'').localeCompare(a.period||'');}).map(function(s){
    tots.total+=s.amount;
    if(s.status==='paid') tots.paid+=s.amount;
    else if(s.status==='overdue') tots.overdue+=s.amount;
    else tots.unpaid+=s.amount;
    var pill=s.status==='paid'?'pill-ok':s.status==='overdue'?'pill-err':'pill-warn';
    return '<tr><td><strong>'+esc(s.cname)+'</strong></td>'
      +'<td>'+esc(s.period||'—')+'</td>'
      +'<td style="font-weight:700">'+fmt(s.amount)+'</td>'
      +'<td><span class="pill '+pill+'">'+esc(s.status)+'</span></td>'
      +'<td style="font-size:12px;color:#888">'+esc(s.method||'—')+'</td>'
      +'<td style="font-size:12px;color:#888">'+esc(s.paidTs?new Date(s.paidTs).toLocaleDateString():'—')+'</td>'
      +'</tr>';
  });
  $e('subs-tbody').innerHTML=rows.length?rows.join(''):emptyRow(6,'No subscription invoices in this period.');
  $e('sb-total').textContent=fmt(tots.total);
  $e('sb-status').innerHTML='<span class="pill pill-ok">Paid: '+fmt(tots.paid)+'</span> '
    +'<span class="pill pill-warn">Due: '+fmt(tots.unpaid)+'</span> '
    +'<span class="pill pill-err">Overdue: '+fmt(tots.overdue)+'</span>';
  $e('subs-sum').innerHTML=
    tsBox('',''+fmtN(subs.length),'Total Invoices')
    +tsBox('green',''+fmt(tots.paid),'Collected')
    +tsBox('amber',''+fmt(tots.unpaid),'Outstanding')
    +tsBox('',''+fmt(tots.overdue),'Overdue');
}

/* ── Payouts Tab ──────────────────────────────────────── */
function renderPayoutsTab(payouts){
  var tots={total:0,taxi:0,food:0,fr:0};
  var rows=payouts.map(function(p){
    tots.total+=p.amount;tots.taxi+=p.taxiNet;tots.food+=p.foodNet;tots.fr+=p.freightNet;
    var dt=p.ts?new Date(p.ts).toLocaleString():'—';
    return '<tr><td style="font-size:12px;white-space:nowrap">'+esc(dt)+'</td>'
      +'<td><strong>'+esc(p.cname)+'</strong></td>'
      +'<td style="font-weight:700;color:#1565C0">'+fmt(p.amount)+'</td>'
      +'<td style="font-size:12px">'+fmt(p.taxiNet)+'</td>'
      +'<td style="font-size:12px">'+fmt(p.foodNet)+'</td>'
      +'<td style="font-size:12px">'+fmt(p.freightNet)+'</td>'
      +'<td style="font-size:11px;font-family:monospace;color:#888">'+esc(p.stripeId||'—')+'</td>'
      +'<td style="font-size:12px;color:#888">'+esc(p.notes||'')+'</td>'
      +'</tr>';
  });
  $e('payouts-tbody').innerHTML=rows.length?rows.join(''):emptyRow(8,'No payouts in this period.');
  $e('po-total').textContent=fmt(tots.total);
  $e('po-taxi').textContent=fmt(tots.taxi);
  $e('po-food').textContent=fmt(tots.food);
  $e('po-fr').textContent=fmt(tots.fr);
  $e('payouts-sum').innerHTML=
    tsBox('',''+fmtN(payouts.length),'Total Payouts')
    +tsBox('amber',''+fmt(tots.total),'Total Paid Out')
    +tsBox('',''+fmt(tots.taxi),'Taxi Net')
    +tsBox('green',''+fmt(tots.food),'Food Net')
    +tsBox('purple',''+fmt(tots.fr),'Freight Net');
}

/* ── Init ─────────────────────────────────────────────── */
window._fbOnLogin = function(){
  // Set current month default dates for reference
  var now=new Date();
  var y=now.getFullYear(), m=String(now.getMonth()+1).padStart(2,'0');
  $e('filt-from').value=y+'-'+m+'-01';
  $e('filt-to').value=y+'-'+m+'-'+String(new Date(y,now.getMonth()+1,0).getDate()).padStart(2,'0');
  reloadAll();
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
