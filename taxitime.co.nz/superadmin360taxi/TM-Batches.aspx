<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Claim Batches &mdash; BookaWaka Admin</title>
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
.tm-wrap{padding:20px}
.tm-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.tm-bar{background:#37474F;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.tm-bar h3{margin:0;font-size:15px;font-weight:600}
.tm-tbl{width:100%;border-collapse:collapse;font-size:13px}
.tm-tbl th{background:#f5f5f5;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #e0e0e0;white-space:nowrap;color:#37474F}
.tm-tbl td{padding:9px 11px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.tm-tbl tr:hover td{background:#fafafa}
.tm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:600}
.tm-btn-p{background:#37474F;color:#fff}.tm-btn-p:hover{background:#263238}
.tm-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.tm-btn-blue{background:#1565C0;color:#fff}.tm-btn-blue:hover{background:#0D47A1}
.tm-btn-green{background:#2E7D32;color:#fff}.tm-btn-green:hover{background:#1B5E20}
.tm-btn-amber{background:#FFF8E1;color:#E65100;border:1px solid #FFE082}
.tm-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.tm-btn-view{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.bx{display:inline-block;padding:3px 10px;border-radius:10px;font-size:11px;font-weight:700;white-space:nowrap}
.bx-draft{background:#F5F5F5;color:#616161;border:1px solid #E0E0E0}
.bx-submitted{background:#E8EAF6;color:#283593;border:1px solid #C5CAE9}
.bx-approved{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.bx-revision{background:#FFF3E0;color:#E65100;border:1px solid #FFCC80}
.bx-paid{background:#E0F2F1;color:#00695C;border:1px solid #80CBC4}
.bx-flag{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;margin-bottom:22px}
.kpi{background:#fff;border-radius:8px;box-shadow:0 1px 5px rgba(0,0,0,.1);padding:16px 20px;border-left:5px solid #37474F}
.kpi.blue{border-left-color:#1565C0}
.kpi.green{border-left-color:#2E7D32}
.kpi.amber{border-left-color:#E65100}
.kpi.teal{border-left-color:#00695C}
.kpi-val{font-size:28px;font-weight:700;color:#263238;line-height:1}
.kpi-lbl{font-size:12px;color:#90A4AE;margin-top:5px;font-weight:500}
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt select,.filt input[type=month]{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.cid-badge{font-family:monospace;background:#ECEFF1;color:#37474F;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700}
/* Modal */
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:10px;padding:28px;max-width:520px;width:95%;box-shadow:0 8px 30px rgba(0,0,0,.22)}
.modal-box h3{font-size:16px;font-weight:700;margin-bottom:6px;color:#263238}
.modal-sub{font-size:13px;color:#aaa;margin-bottom:16px}
.modal-field{margin-bottom:14px}
.modal-field label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
.modal-field input,.modal-field select,.modal-field textarea{width:100%;padding:9px 12px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;font-family:inherit}
.modal-field input:focus,.modal-field select:focus,.modal-field textarea:focus{outline:none;border-color:#37474F}
.modal-actions{display:flex;gap:8px;justify-content:flex-end;margin-top:18px}
.modal-info{background:#ECEFF1;border-left:4px solid #37474F;padding:10px 14px;border-radius:4px;font-size:13px;color:#37474F;margin-bottom:14px;line-height:1.5}
/* Trips detail panel */
.trips-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1010;align-items:flex-start;justify-content:center;padding:30px 0;overflow-y:auto}
.trips-overlay.open{display:flex}
.trips-box{background:#fff;border-radius:10px;width:96%;max-width:1100px;box-shadow:0 8px 40px rgba(0,0,0,.25);margin:auto}
.trips-hdr{background:#37474F;color:#fff;padding:14px 20px;display:flex;align-items:center;justify-content:space-between;border-radius:10px 10px 0 0}
.trips-hdr h3{margin:0;font-size:15px}
.close-x{background:none;border:none;color:#fff;font-size:22px;cursor:pointer;line-height:1;padding:0}
.trip-stat-row{display:flex;gap:10px;flex-wrap:wrap;padding:14px 20px;background:#F5F5F5;border-bottom:1px solid #e0e0e0}
.trip-stat{background:#fff;border-radius:6px;padding:9px 14px;min-width:100px;box-shadow:0 1px 3px rgba(0,0,0,.07)}
.trip-stat .tsv{font-size:18px;font-weight:700;color:#37474F}
.trip-stat .tsl{font-size:11px;color:#aaa;margin-top:2px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">TM Claim Batches &mdash; BookaWaka Admin</label></div>
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
      <li><a href="TM-Batches.aspx" style="font-weight:700;color:#1565C0">&#9658; Claim Batches</a></li>
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
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
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
<div class="tm-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:4px;color:#37474F">&#128203; TM Claim Batches</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">Monthly groupings of Total Mobility trips per company and council — track each batch from submission through to council payment.</p>

<div class="kpi-row" id="kpi-row">
  <div class="kpi"><div class="kpi-val" id="kpi-total">—</div><div class="kpi-lbl">Total Batches</div></div>
  <div class="kpi amber"><div class="kpi-val" id="kpi-draft">—</div><div class="kpi-lbl">Ready to Submit</div></div>
  <div class="kpi blue"><div class="kpi-val" id="kpi-submitted">—</div><div class="kpi-lbl">Awaiting Council</div></div>
  <div class="kpi green"><div class="kpi-val" id="kpi-approved">—</div><div class="kpi-lbl">Council Approved</div></div>
  <div class="kpi teal"><div class="kpi-val" id="kpi-paid">—</div><div class="kpi-lbl">Paid This Year</div></div>
  <div class="kpi" style="border-left-color:#2E7D32"><div class="kpi-val" id="kpi-claim" style="font-size:20px">—</div><div class="kpi-lbl">Total Claimed (All Time)</div></div>
</div>

<div class="tm-card">
  <div class="tm-bar">
    <h3>&#128203; Batches <small id="batch-count" style="opacity:.75;font-size:12px"></small></h3>
    <button class="tm-btn tm-btn-wh" onclick="loadAll()">&#8635; Refresh</button>
  </div>
  <div class="filt">
    <select id="f-council" onchange="renderBatches()"><option value="">All Councils</option></select>
    <select id="f-company" onchange="renderBatches()"><option value="">All Companies</option></select>
    <input type="month" id="f-month" onchange="renderBatches()" title="Filter by month"/>
    <select id="f-status" onchange="renderBatches()">
      <option value="">All Statuses</option>
      <option value="draft">Draft (Not Yet Submitted)</option>
      <option value="submitted">Submitted to Council</option>
      <option value="approved">Council Approved</option>
      <option value="revision_needed">Needs Revision</option>
      <option value="paid">Paid</option>
    </select>
    <button class="tm-btn tm-btn-n" onclick="clearFilters()">Clear</button>
  </div>
  <div style="overflow-x:auto">
  <table class="tm-tbl">
    <thead><tr>
      <th>Company</th>
      <th>Council</th>
      <th>Month</th>
      <th>Trips</th>
      <th>Flagged</th>
      <th>Trip Statuses</th>
      <th>Total Claim</th>
      <th>Batch Status</th>
      <th>Submitted</th>
      <th>Approved / Paid</th>
      <th>Actions</th>
    </tr></thead>
    <tbody id="batch-tb">
      <tr><td colspan="11" style="text-align:center;padding:40px;color:#9e9e9e">Loading&hellip;</td></tr>
    </tbody>
  </table>
  </div>
</div>

</div>
</div></div>

<!-- Submit to Council Modal -->
<div class="modal-overlay" id="modal-submit">
  <div class="modal-box">
    <h3>&#8679; Submit Batch to Council</h3>
    <div class="modal-sub" id="submit-sub"></div>
    <div class="modal-info" id="submit-info"></div>
    <div class="modal-field">
      <label>Reference Number <span style="color:#aaa;font-weight:400;font-size:11px">optional</span></label>
      <input type="text" id="submit-ref" placeholder="e.g. ICC-TM-2026-04 or leave blank"/>
    </div>
    <div class="modal-field">
      <label>Notes <span style="color:#aaa;font-weight:400;font-size:11px">optional</span></label>
      <textarea id="submit-notes" rows="2" placeholder="Any notes for internal records"></textarea>
    </div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-submit')" class="tm-btn tm-btn-n">Cancel</button>
      <button onclick="confirmSubmit()" class="tm-btn tm-btn-blue">&#8679; Submit to Council</button>
    </div>
  </div>
</div>

<!-- Approve / Revision Modal -->
<div class="modal-overlay" id="modal-approve">
  <div class="modal-box">
    <h3 id="approve-title">Council Decision</h3>
    <div class="modal-sub" id="approve-sub"></div>
    <div class="modal-info" id="approve-info"></div>
    <div class="modal-field" id="approve-ref-wrap">
      <label>Council Reference / Claim Number <span style="color:#aaa;font-weight:400;font-size:11px">optional</span></label>
      <input type="text" id="approve-ref" placeholder="e.g. Council claim reference"/>
    </div>
    <div class="modal-field" id="approve-revision-wrap" style="display:none">
      <label>Revision Notes <span style="color:#C62828">*</span></label>
      <textarea id="approve-revision" rows="3" placeholder="What the company needs to fix before resubmitting"></textarea>
    </div>
    <div class="modal-field">
      <label>Notes <span style="color:#aaa;font-weight:400;font-size:11px">optional</span></label>
      <textarea id="approve-notes" rows="2" placeholder="Any internal notes"></textarea>
    </div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-approve')" class="tm-btn tm-btn-n">Cancel</button>
      <button id="approve-confirm-btn" onclick="confirmApprove()" class="tm-btn tm-btn-green">&#10003; Mark Approved</button>
    </div>
  </div>
</div>

<!-- Mark Paid Modal -->
<div class="modal-overlay" id="modal-paid">
  <div class="modal-box">
    <h3>&#128176; Record Council Payment</h3>
    <div class="modal-sub" id="paid-sub"></div>
    <div class="modal-info" id="paid-info"></div>
    <div class="modal-field">
      <label>Amount Received (NZD) <span style="color:#37474F">*</span></label>
      <input type="number" id="paid-amount" step="0.01" min="0" placeholder="0.00" style="font-size:18px;font-weight:700"/>
    </div>
    <div class="modal-field">
      <label>Payment Date <span style="color:#37474F">*</span></label>
      <input type="date" id="paid-date"/>
    </div>
    <div class="modal-field">
      <label>Payment Reference</label>
      <input type="text" id="paid-ref" placeholder="Bank transfer ref, EFT number, etc."/>
    </div>
    <div class="modal-field">
      <label>Notes <span style="color:#aaa;font-weight:400;font-size:11px">optional</span></label>
      <input type="text" id="paid-notes" placeholder="Any additional payment notes"/>
    </div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-paid')" class="tm-btn tm-btn-n">Cancel</button>
      <button onclick="confirmPaid()" class="tm-btn" style="background:#00695C;color:#fff">&#128176; Record Payment</button>
    </div>
  </div>
</div>

<!-- Trip Detail Panel -->
<div class="trips-overlay" id="trips-overlay">
  <div class="trips-box">
    <div class="trips-hdr">
      <h3 id="trips-title">Batch Trips</h3>
      <button class="close-x" onclick="closeTrips()">&#x2715;</button>
    </div>
    <div class="trip-stat-row" id="trips-stats"></div>
    <div style="padding:16px 20px 6px;display:flex;gap:8px;flex-wrap:wrap;align-items:center;border-bottom:1px solid #eee">
      <span style="font-size:13px;font-weight:600;color:#555">Filter:</span>
      <select id="td-f-status" onchange="renderTripDetail()" style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12px">
        <option value="">All Statuses</option>
        <option value="pending">Pending</option>
        <option value="flagged">Flagged</option>
        <option value="company_approved">Company Approved</option>
        <option value="submitted">Submitted</option>
        <option value="approved">Approved</option>
        <option value="revision_needed">Needs Revision</option>
        <option value="paid">Paid</option>
      </select>
      <button onclick="exportBatchCSV()" class="tm-btn" style="background:#37474F;color:#fff;font-size:11px;margin-left:auto">&#128229; Export CSV</button>
    </div>
    <div style="overflow-x:auto;max-height:55vh">
    <table class="tm-tbl" style="min-width:900px">
      <thead><tr>
        <th>Job ID</th><th>Date</th><th>Driver</th><th>Card #</th><th>Passenger</th>
        <th>Pickup</th><th>Dropoff</th><th>Fare</th><th>TM Sub.</th><th>Hoist</th><th>Pax Pays</th><th>Total Claim</th><th>Status</th>
      </tr></thead>
      <tbody id="trips-tb"></tbody>
    </table>
    </div>
    <div style="padding:14px 20px;border-top:1px solid #eee;display:flex;justify-content:flex-end">
      <button onclick="closeTrips()" class="tm-btn tm-btn-n">Close</button>
    </div>
  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/modernizr/2.8.3/modernizr.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/fastclick/1.0.6/fastclick.min.js"></script>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/uikit_custom.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
/* ── globals ───────────────────────────────────── */
var allTrips    = {};   // id → trip object (enriched with tmTripStatus)
var allCouncils = {};   // councilId → {name, subsidyRate, ...}
var allCompanies= {};   // cid → {name, ...}
var allBatches  = {};   // councilId → cid → month → batch record
var batches     = [];   // computed array of batch objects for render

var activeBatch = null; // the batch currently in a modal/detail view
var approveMode = '';   // 'approve' or 'revision'

/* ── helpers ───────────────────────────────────── */
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmt(n){ return '$'+(+n||0).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g,','); }
function fmtDate(ts){ return ts?new Date(ts).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'}):'—'; }
function fmtMonth(m){
  var p=m.split('-');
  return new Date(+p[0],+p[1]-1,1).toLocaleDateString('en-NZ',{month:'long',year:'numeric'});
}
function batchKey(councilId,cid,month){ return councilId+'||'+cid+'||'+month; }
function tripMonth(t){ return (t.startTime||'').slice(0,7); }

function statusBadge(s){
  var map={
    draft:       '<span class="bx bx-draft">Draft</span>',
    submitted:   '<span class="bx bx-submitted">&#8679; Submitted</span>',
    approved:    '<span class="bx bx-approved">&#10003; Approved</span>',
    revision_needed: '<span class="bx bx-revision">&#8617; Needs Revision</span>',
    paid:        '<span class="bx bx-paid">&#128176; Paid</span>'
  };
  return map[s]||('<span class="bx bx-draft">'+esc(s)+'</span>');
}
function tripBadge(s){
  var map={
    pending:          '<span class="bx" style="background:#f5f5f5;color:#616161;border:1px solid #e0e0e0;font-size:10px">Pending</span>',
    flagged:          '<span class="bx bx-flag" style="font-size:10px">&#9888; Flagged</span>',
    company_approved: '<span class="bx" style="background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB;font-size:10px">Co. Approved</span>',
    submitted:        '<span class="bx bx-submitted" style="font-size:10px">Submitted</span>',
    approved:         '<span class="bx bx-approved" style="font-size:10px">&#10003; Approved</span>',
    revision_needed:  '<span class="bx bx-revision" style="font-size:10px">Revision</span>',
    rejected:         '<span class="bx bx-flag" style="font-size:10px">Rejected</span>',
    paid:             '<span class="bx bx-paid" style="font-size:10px">Paid</span>'
  };
  return map[s]||('<span class="bx" style="font-size:10px">'+esc(s||'?')+'</span>');
}

/* ── load ──────────────────────────────────────── */
window._fbOnLogin = function(){
  loadAll();
};

function loadAll(){
  document.getElementById('batch-tb').innerHTML='<tr><td colspan="11" style="text-align:center;padding:40px;color:#9e9e9e">Loading&hellip;</td></tr>';
  Promise.all([
    adminRead('tmConfig'),
    adminRead('superClients'),
    adminRead('completedJobs'),
    adminRead('tmTripStatus'),
    adminRead('tmBatches')
  ]).then(function(res){
    allCouncils  = res[0]||{};
    allCompanies = res[1]||{};
    var completedJobs = res[2]||{};
    var tmStatuses    = res[3]||{};
    allBatches        = res[4]||{};

    /* build allTrips */
    allTrips = {};
    Object.entries(completedJobs).forEach(function(cidEntry){
      var cid=cidEntry[0], jobs=cidEntry[1]||{};
      Object.entries(jobs).forEach(function(je){
        var rawKey=je[0], j=je[1];
        if(j.paymentType!=='total_mobility') return;
        var id=j.bookingId||rawKey;
        var t={
          _cid:cid, _rawKey:rawKey,
          councilId: j.councilId||'',
          driverName: j.driverName||'',
          vehicleId:  j.vehicleId||'',
          cardNumber: j.tmVoucherNo||j.cardNumber||'',
          passengerName: j.tmPassengerName||j.passengerName||'',
          startTime:  j.startedAt_ISO||j.startedAt||'',
          pickup:     j.pickupAddress||j.pickup||'',
          dropoff:    j.dropAddress||j.dropoff||'',
          meterFare:  +(j.fare||j.meterFare||0),
          tmSubsidyFare: +(j.tmSubsidy||j.tmSubsidyFare||0),
          tmSubsidyHoist: +(j.tmSubsidyHoist||0),
          hoistTotal: +(j.hoistTotal||0),
          passengerPays: +(j.tmPassengerPays||j.passengerPays||0),
          totalCouncilPays: +(j.tmSubsidy||j.totalCouncilPays||j.fare||0),
          waitingCharge: +(j.waitingCost||j.WaitingCost||0),
          distance:   j.distanceKm||'',
          status:'pending', flagReasons:[]
        };
        /* overlay tmTripStatus */
        var st=tmStatuses[cid]&&tmStatuses[cid][rawKey];
        if(st){
          t.status      = st.status      || t.status;
          t.councilId   = st.councilId   || t.councilId;
          t.flagReasons = st.flagReasons || [];
          t.submittedAt = st.submittedAt ||null;
          t.approvedAt  = st.approvedAt  ||null;
          t.revisionNote= st.revisionNote||'';
        }
        allTrips[id]=t;
      });
    });

    populateFilters();
    computeBatches();
    renderBatches();
  }).catch(function(e){
    document.getElementById('batch-tb').innerHTML='<tr><td colspan="11" style="text-align:center;padding:40px;color:#C62828">Error loading data: '+esc(String(e))+'</td></tr>';
  });
}

/* ── build filter dropdowns ─────────────────────── */
function populateFilters(){
  var councilSel=document.getElementById('f-council');
  var companySel=document.getElementById('f-company');
  var cOld=councilSel.value, coOld=companySel.value;
  var cOpts='<option value="">All Councils</option>';
  Object.entries(allCouncils).forEach(function(kv){
    cOpts+='<option value="'+esc(kv[0])+'"'+(kv[0]===cOld?' selected':'')+'>'+esc(kv[1].name||kv[0])+'</option>';
  });
  councilSel.innerHTML=cOpts;
  var coOpts='<option value="">All Companies</option>';
  Object.entries(allCompanies).sort(function(a,b){ return (a[1].name||a[0]).localeCompare(b[1].name||b[0]); }).forEach(function(kv){
    coOpts+='<option value="'+esc(kv[0])+'"'+(kv[0]===coOld?' selected':'')+'>'+esc(kv[1].name||kv[0])+'</option>';
  });
  companySel.innerHTML=coOpts;
}

/* ── compute batches ────────────────────────────── */
function computeBatches(){
  var agg={};
  Object.entries(allTrips).forEach(function(kv){
    var id=kv[0], t=kv[1];
    var month=tripMonth(t); if(!month) return;
    var cid=t._cid, councilId=t.councilId||'unknown';
    var bk=batchKey(councilId,cid,month);
    if(!agg[bk]) agg[bk]={
      batchKey:bk, councilId:councilId, cid:cid, month:month,
      trips:[], totalClaim:0, flagged:0, statuses:{}
    };
    var a=agg[bk];
    a.trips.push(id);
    a.totalClaim+=t.totalCouncilPays;
    if(t.status==='flagged') a.flagged++;
    a.statuses[t.status]=(a.statuses[t.status]||0)+1;
  });

  batches=Object.values(agg).map(function(a){
    /* look up saved batch record */
    var saved=(allBatches[a.councilId]&&allBatches[a.councilId][a.cid]&&allBatches[a.councilId][a.cid][a.month])||{};
    a.batchStatus = saved.status||'draft';
    a.submittedAt = saved.submittedAt||null;
    a.submittedRef= saved.submittedRef||'';
    a.approvedAt  = saved.approvedAt||null;
    a.approvedRef = saved.approvedRef||'';
    a.paidAt      = saved.paidAt||null;
    a.paidAmount  = saved.paidAmount||null;
    a.paidRef     = saved.paidRef||'';
    a.revisionNote= saved.revisionNote||'';
    a.notes       = saved.notes||'';
    return a;
  }).sort(function(a,b){
    return b.month.localeCompare(a.month)||a.councilId.localeCompare(b.councilId)||(allCompanies[a.cid]&&allCompanies[a.cid].name||a.cid).localeCompare(allCompanies[b.cid]&&allCompanies[b.cid].name||b.cid);
  });
}

/* ── render ─────────────────────────────────────── */
function renderBatches(){
  var fC=document.getElementById('f-council').value;
  var fCo=document.getElementById('f-company').value;
  var fM=document.getElementById('f-month').value;
  var fS=document.getElementById('f-status').value;

  var filtered=batches.filter(function(b){
    if(fC && b.councilId!==fC) return false;
    if(fCo && b.cid!==fCo) return false;
    if(fM && b.month!==fM) return false;
    if(fS && b.batchStatus!==fS) return false;
    return true;
  });

  /* KPIs from ALL batches */
  var kDraft=0,kSub=0,kApp=0,kPaid=0,kClaim=0;
  var curYear=new Date().getFullYear();
  batches.forEach(function(b){
    if(b.batchStatus==='draft') kDraft++;
    else if(b.batchStatus==='submitted') kSub++;
    else if(b.batchStatus==='approved') kApp++;
    if(b.batchStatus==='paid'&&b.month.startsWith(String(curYear))) kPaid++;
    kClaim+=b.totalClaim;
  });
  document.getElementById('kpi-total').textContent=batches.length;
  document.getElementById('kpi-draft').textContent=kDraft;
  document.getElementById('kpi-submitted').textContent=kSub;
  document.getElementById('kpi-approved').textContent=kApp;
  document.getElementById('kpi-paid').textContent=kPaid;
  document.getElementById('kpi-claim').textContent=fmt(kClaim);
  document.getElementById('batch-count').textContent=filtered.length+' of '+batches.length+' batch(es)';

  if(!filtered.length){
    document.getElementById('batch-tb').innerHTML='<tr><td colspan="11" style="text-align:center;padding:40px;color:#9e9e9e">No batches match the current filters.</td></tr>';
    return;
  }

  document.getElementById('batch-tb').innerHTML=filtered.map(function(b){
    var coName=esc((allCompanies[b.cid]&&allCompanies[b.cid].name)||'Operator '+b.cid);
    var cnName=esc((allCouncils[b.councilId]&&allCouncils[b.councilId].name)||b.councilId);
    var stBreak=Object.entries(b.statuses).map(function(kv){
      return '<span style="font-size:11px;color:#888">'+esc(kv[0])+':'+kv[1]+'</span>';
    }).join(' &bull; ');
    var submittedCol=b.submittedAt?'<span style="font-size:12px">'+fmtDate(b.submittedAt)+(b.submittedRef?'<br><span style="color:#888;font-family:monospace">'+esc(b.submittedRef)+'</span>':'')+'</span>':'<span style="color:#ccc">—</span>';
    var paidCol='<span style="color:#ccc">—</span>';
    if(b.batchStatus==='approved'&&b.approvedAt) paidCol='<span style="font-size:12px;color:#2E7D32">Approved '+fmtDate(b.approvedAt)+'</span>';
    if(b.batchStatus==='paid'&&b.paidAt) paidCol='<span style="font-size:12px;color:#00695C">Paid '+fmtDate(b.paidAt)+(b.paidAmount?'<br><strong>'+fmt(b.paidAmount)+'</strong>':'')+'</span>';
    if(b.batchStatus==='revision_needed') paidCol='<span style="font-size:12px;color:#E65100">Revision requested</span>';

    var bkStr=esc(b.batchKey);
    var actions='<button class="tm-btn tm-btn-view" style="margin-right:4px" onclick="openTrips(\''+bkStr+'\')">&#128065; View Trips</button>';
    if(b.batchStatus==='draft'){
      actions+='<button class="tm-btn tm-btn-blue" onclick="openSubmit(\''+bkStr+'\')">&#8679; Submit</button>';
    } else if(b.batchStatus==='submitted'){
      actions+='<button class="tm-btn tm-btn-green" style="margin-right:4px" onclick="openApprove(\''+bkStr+'\',\'approve\')">&#10003; Approve</button>';
      actions+='<button class="tm-btn tm-btn-amber" onclick="openApprove(\''+bkStr+'\',\'revision\')">&#8617; Revision</button>';
    } else if(b.batchStatus==='approved'){
      actions+='<button class="tm-btn" style="background:#00695C;color:#fff" onclick="openPaid(\''+bkStr+'\')">&#128176; Mark Paid</button>';
    } else if(b.batchStatus==='revision_needed'){
      actions+='<button class="tm-btn tm-btn-blue" onclick="openSubmit(\''+bkStr+'\')">&#8679; Resubmit</button>';
    }

    return '<tr>'+
      '<td><span class="cid-badge">'+esc(b.cid)+'</span> <strong>'+coName+'</strong></td>'+
      '<td>'+cnName+'</td>'+
      '<td style="white-space:nowrap;font-weight:600">'+esc(fmtMonth(b.month))+'</td>'+
      '<td style="text-align:center;font-weight:700;font-size:15px">'+b.trips.length+'</td>'+
      '<td style="text-align:center">'+(b.flagged>0?'<span class="bx bx-flag">'+b.flagged+'</span>':'<span style="color:#ccc">0</span>')+'</td>'+
      '<td style="font-size:11.5px">'+stBreak+'</td>'+
      '<td style="font-weight:700;color:#2E7D32;font-size:14px">'+fmt(b.totalClaim)+'</td>'+
      '<td>'+statusBadge(b.batchStatus)+'</td>'+
      '<td>'+submittedCol+'</td>'+
      '<td>'+paidCol+'</td>'+
      '<td style="white-space:nowrap">'+actions+'</td>'+
    '</tr>';
  }).join('');
}

function clearFilters(){
  ['f-council','f-company','f-status'].forEach(function(x){ document.getElementById(x).value=''; });
  document.getElementById('f-month').value='';
  renderBatches();
}

/* ── modal helpers ──────────────────────────────── */
function getBatch(bk){ return batches.find(function(b){ return b.batchKey===bk; })||null; }
function coName(cid){ return (allCompanies[cid]&&allCompanies[cid].name)||'Operator '+cid; }
function cnName(cid){ return (allCouncils[cid]&&allCouncils[cid].name)||cid; }
function closeModal(id){ document.getElementById(id).classList.remove('open'); }

/* ── Submit modal ───────────────────────────────── */
function openSubmit(bk){
  var b=getBatch(bk); if(!b) return;
  activeBatch=b;
  document.getElementById('submit-sub').textContent=coName(b.cid)+' · '+cnName(b.councilId)+' · '+fmtMonth(b.month);
  document.getElementById('submit-info').innerHTML=
    '<strong>'+b.trips.length+' trips</strong> · Total claim: <strong style="color:#2E7D32">'+fmt(b.totalClaim)+'</strong>'+
    (b.flagged>0?'<br><span style="color:#C62828">&#9888; '+b.flagged+' flagged trip(s) included — consider resolving first.</span>':'');
  document.getElementById('submit-ref').value=b.submittedRef||'';
  document.getElementById('submit-notes').value=b.notes||'';
  document.getElementById('modal-submit').classList.add('open');
}
function confirmSubmit(){
  if(!activeBatch) return;
  var b=activeBatch;
  var ref=document.getElementById('submit-ref').value.trim();
  var notes=document.getElementById('submit-notes').value.trim();
  var payload={status:'submitted',submittedAt:Date.now(),submittedRef:ref||null,notes:notes||null,claimAmount:b.totalClaim,tripCount:b.trips.length};
  saveBatch(b,payload).then(function(){
    toastr.success('Batch submitted to council.');
    closeModal('modal-submit');
    loadAll();
  }).catch(function(e){ toastr.error('Error: '+e); });
}

/* ── Approve / Revision modal ───────────────────── */
function openApprove(bk, mode){
  var b=getBatch(bk); if(!b) return;
  activeBatch=b; approveMode=mode;
  var isRev=(mode==='revision');
  document.getElementById('approve-title').textContent=isRev?'&#8617; Request Revision':'&#10003; Mark Council Approved';
  document.getElementById('approve-sub').textContent=coName(b.cid)+' · '+cnName(b.councilId)+' · '+fmtMonth(b.month);
  document.getElementById('approve-info').innerHTML='<strong>'+b.trips.length+' trips</strong> · Claimed: <strong style="color:#2E7D32">'+fmt(b.totalClaim)+'</strong>';
  document.getElementById('approve-ref-wrap').style.display=isRev?'none':'';
  document.getElementById('approve-revision-wrap').style.display=isRev?'':'none';
  document.getElementById('approve-confirm-btn').textContent=isRev?'&#8617; Request Revision':'&#10003; Mark Approved';
  document.getElementById('approve-confirm-btn').style.background=isRev?'#E65100':'#2E7D32';
  document.getElementById('approve-ref').value='';
  document.getElementById('approve-revision').value='';
  document.getElementById('approve-notes').value='';
  document.getElementById('modal-approve').classList.add('open');
}
function confirmApprove(){
  if(!activeBatch) return;
  var b=activeBatch;
  var isRev=(approveMode==='revision');
  if(isRev&&!document.getElementById('approve-revision').value.trim()){
    toastr.warning('Please enter revision notes before requesting revision.');
    return;
  }
  var payload=isRev
    ?{status:'revision_needed',revisionNote:document.getElementById('approve-revision').value.trim(),notes:document.getElementById('approve-notes').value.trim()||null}
    :{status:'approved',approvedAt:Date.now(),approvedRef:document.getElementById('approve-ref').value.trim()||null,notes:document.getElementById('approve-notes').value.trim()||null};
  saveBatch(b,payload).then(function(){
    toastr.success(isRev?'Revision requested.':'Batch marked as council approved.');
    closeModal('modal-approve');
    loadAll();
  }).catch(function(e){ toastr.error('Error: '+e); });
}

/* ── Paid modal ─────────────────────────────────── */
function openPaid(bk){
  var b=getBatch(bk); if(!b) return;
  activeBatch=b;
  document.getElementById('paid-sub').textContent=coName(b.cid)+' · '+cnName(b.councilId)+' · '+fmtMonth(b.month);
  document.getElementById('paid-info').innerHTML='Claimed: <strong style="color:#2E7D32">'+fmt(b.totalClaim)+'</strong> across <strong>'+b.trips.length+' trips</strong>';
  document.getElementById('paid-amount').value=b.totalClaim.toFixed(2);
  document.getElementById('paid-date').value=new Date().toISOString().split('T')[0];
  document.getElementById('paid-ref').value='';
  document.getElementById('paid-notes').value='';
  document.getElementById('modal-paid').classList.add('open');
}
function confirmPaid(){
  if(!activeBatch) return;
  var b=activeBatch;
  var amount=+(document.getElementById('paid-amount').value||0);
  var date=document.getElementById('paid-date').value;
  if(!amount||!date){ toastr.warning('Amount and date are required.'); return; }
  var payload={
    status:'paid',
    paidAt:Date.now(),
    paidDate:date,
    paidAmount:amount,
    paidRef:document.getElementById('paid-ref').value.trim()||null,
    notes:document.getElementById('paid-notes').value.trim()||null
  };
  saveBatch(b,payload).then(function(){
    toastr.success('Payment recorded. Batch marked as paid.');
    closeModal('modal-paid');
    loadAll();
  }).catch(function(e){ toastr.error('Error: '+e); });
}

/* ── save batch to Firebase ─────────────────────── */
function saveBatch(b, payload){
  var path='tmBatches/'+b.councilId+'/'+b.cid+'/'+b.month;
  return adminWrite(path,'PATCH',payload);
}

/* ── Trip detail panel ──────────────────────────── */
var detailBatch=null;
function openTrips(bk){
  var b=getBatch(bk); if(!b) return;
  detailBatch=b;
  document.getElementById('trips-title').textContent=
    coName(b.cid)+' · '+cnName(b.councilId)+' · '+fmtMonth(b.month)+' ('+b.trips.length+' trips)';
  document.getElementById('td-f-status').value='';
  renderTripDetail();
  document.getElementById('trips-overlay').classList.add('open');
}
function closeTrips(){ document.getElementById('trips-overlay').classList.remove('open'); detailBatch=null; }
function renderTripDetail(){
  if(!detailBatch) return;
  var fS=document.getElementById('td-f-status').value;
  var trips=detailBatch.trips.map(function(id){ return {id:id,t:allTrips[id]}; }).filter(function(x){
    return x.t && (!fS||x.t.status===fS);
  }).sort(function(a,b){ return (b.t.startTime||'').localeCompare(a.t.startTime||''); });

  /* stat bar */
  var totClaim=0,totFare=0,totHoist=0,totPax=0,cntFlag=0;
  trips.forEach(function(x){ var t=x.t; totClaim+=t.totalCouncilPays; totFare+=t.meterFare; totHoist+=t.hoistTotal; totPax+=t.passengerPays; if(t.status==='flagged') cntFlag++; });
  document.getElementById('trips-stats').innerHTML=
    statBox(trips.length,'Trips shown','#37474F')+
    statBox(fmt(totFare),'Meter Fares','')+
    statBox(fmt(totClaim),'Total Claim','#2E7D32')+
    statBox(fmt(totPax),'Pax Pays','')+
    (cntFlag>0?statBox(cntFlag,'Flagged','#C62828'):'');

  if(!trips.length){
    document.getElementById('trips-tb').innerHTML='<tr><td colspan="13" style="text-align:center;padding:24px;color:#9e9e9e">No trips match filter.</td></tr>';
    return;
  }
  document.getElementById('trips-tb').innerHTML=trips.map(function(x){
    var id=x.id, t=x.t;
    var dt=t.startTime?(t.startTime.slice(0,10)+' '+t.startTime.slice(11,16)):'—';
    var hoistAmt=parseFloat(t.hoistTotal||0);
    return '<tr>'+
      '<td style="font-family:monospace;font-size:11px">'+esc(id)+'</td>'+
      '<td style="white-space:nowrap;font-size:12px">'+esc(dt)+'</td>'+
      '<td>'+esc(t.driverName||'—')+'</td>'+
      '<td style="font-family:monospace;font-size:12px">'+esc(t.cardNumber||'—')+'</td>'+
      '<td>'+esc(t.passengerName||'—')+'</td>'+
      '<td style="font-size:12px">'+esc(t.pickup||'—')+'</td>'+
      '<td style="font-size:12px">'+esc(t.dropoff||'—')+'</td>'+
      '<td>$'+parseFloat(t.meterFare||0).toFixed(2)+'</td>'+
      '<td style="color:#2E7D32;font-weight:600">$'+parseFloat(t.tmSubsidyFare||0).toFixed(2)+'</td>'+
      '<td>'+(hoistAmt>0?'<span style="color:#1565C0;font-weight:600">$'+hoistAmt.toFixed(2)+'</span>':'—')+'</td>'+
      '<td>$'+parseFloat(t.passengerPays||0).toFixed(2)+'</td>'+
      '<td style="font-weight:700;color:#2E7D32">$'+parseFloat(t.totalCouncilPays||0).toFixed(2)+'</td>'+
      '<td>'+tripBadge(t.status)+'</td>'+
    '</tr>';
  }).join('');
}
function statBox(val,lbl,color){
  return '<div class="trip-stat"><div class="tsv"'+(color?' style="color:'+color+'"':'')+'>'+val+'</div><div class="tsl">'+lbl+'</div></div>';
}

/* ── Export CSV for a batch ─────────────────────── */
function exportBatchCSV(){
  if(!detailBatch) return;
  var b=detailBatch;
  var rows=[['Job ID','Date','Driver','Vehicle','Card #','Passenger','Pickup','Dropoff','Distance(km)','Meter Fare','TM Subsidy Fare','TM Subsidy Hoist','Hoist Total','Passenger Pays','Total Council Pays','Waiting','Status']];
  b.trips.forEach(function(id){
    var t=allTrips[id]; if(!t) return;
    rows.push([id, t.startTime?t.startTime.slice(0,16):'', t.driverName||'', t.vehicleId||'', t.cardNumber||'', t.passengerName||'',
      t.pickup||'', t.dropoff||'', t.distance||'',
      (t.meterFare||0).toFixed(2),(t.tmSubsidyFare||0).toFixed(2),(t.tmSubsidyHoist||0).toFixed(2),
      (t.hoistTotal||0).toFixed(2),(t.passengerPays||0).toFixed(2),(t.totalCouncilPays||0).toFixed(2),
      (t.waitingCharge||0).toFixed(2), t.status||'']);
  });
  var csv=rows.map(function(r){ return r.map(function(v){ return '"'+String(v).replace(/"/g,'""')+'"'; }).join(','); }).join('\n');
  var blob=new Blob([csv],{type:'text/csv'});
  var url=URL.createObjectURL(blob);
  var a=document.createElement('a');
  a.href=url; a.download='TM_Batch_'+b.cid+'_'+b.councilId+'_'+b.month+'.csv';
  document.body.appendChild(a); a.click(); document.body.removeChild(a); URL.revokeObjectURL(url);
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
