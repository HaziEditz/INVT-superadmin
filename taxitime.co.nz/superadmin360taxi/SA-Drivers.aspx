<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>All Drivers &mdash; BookaWaka Admin</title>
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
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-tbl tr:last-child td{border-bottom:none}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1;color:#fff}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}.sa-btn-s:hover{background:#C8E6C9}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-w{background:#FFF9C4;color:#F57F17;border:1px solid #FFF176}
.sa-btn-o{background:#E65100;color:#fff}.sa-btn-o:hover{background:#BF360C;color:#fff}
.badge-active{background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7;white-space:nowrap}
.badge-inactive{background:#FFEBEE;color:#C62828;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #FFCDD2;white-space:nowrap}
.badge-pending{background:#FFF9C4;color:#E65100;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #FFE082;white-space:nowrap}
.badge-approved{background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7;white-space:nowrap}
.badge-rejected{background:#FFEBEE;color:#C62828;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #FFCDD2;white-space:nowrap}
.badge-wav{background:#E8F5E9;color:#1B5E20;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7}
.badge-std{background:#F5F5F5;color:#757575;font-size:11px;font-weight:600;padding:2px 8px;border-radius:10px}
.sa-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px;padding:16px 18px;background:#F8FBFF;border-bottom:1px solid #e8f0fe}
.sa-stat{text-align:center}
.sa-stat-v{font-size:28px;font-weight:700;color:#1565C0;line-height:1}
.sa-stat-l{font-size:11.5px;color:#90A4AE;margin-top:4px}
.filter-row{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:12px 18px;background:#F8FBFF;border-bottom:1px solid #e8f0fe}
.filter-row select,.filter-row input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:150px}
.filter-row label{font-size:13px;font-weight:500;color:#555;white-space:nowrap}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.drv-avatar{width:34px;height:34px;border-radius:50%;object-fit:cover;border:2px solid #e0e0e0}
.drv-avatar-placeholder{width:34px;height:34px;border-radius:50%;background:#E3F2FD;color:#1565C0;display:inline-flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;border:2px solid #BBDEFB}
/* Tabs */
.tab-bar{display:flex;gap:0;border-bottom:2px solid #e0e0e0;margin-bottom:18px}
.tab-btn{padding:10px 22px;border:none;background:none;font-size:13px;font-weight:600;color:#888;cursor:pointer;border-bottom:3px solid transparent;margin-bottom:-2px;transition:color .15s,border-color .15s;display:flex;align-items:center;gap:6px}
.tab-btn.active{color:#1565C0;border-bottom-color:#1565C0}
.tab-btn:hover{color:#1565C0}
.tab-pane{display:none}.tab-pane.active{display:block}
.pending-badge{background:#E65100;color:#fff;font-size:10px;font-weight:700;padding:1px 6px;border-radius:10px;min-width:18px;text-align:center}
/* Modal */
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:9999;align-items:center;justify-content:center;padding:20px}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:14px;box-shadow:0 20px 60px rgba(0,0,0,.3);padding:28px;width:100%;max-width:540px;max-height:92vh;overflow-y:auto}
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px 20px;margin-bottom:14px}
.detail-item label{display:block;font-size:11px;color:#90A4AE;font-weight:600;text-transform:uppercase;letter-spacing:.04em;margin-bottom:2px}
.detail-item span{font-size:13px;color:#333;font-weight:500}
.sa-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
/* Transfer panel inside modal */
.transfer-panel{display:none;background:#FFF9C4;border:1px solid #FFE082;border-radius:8px;padding:14px;margin-top:14px}
.transfer-panel.open{display:block}
.tr-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:10px}
/* Transfer requests table */
.tr-req-row-pending td{background:#FFFDE7}
.arrow-badge{display:inline-flex;align-items:center;gap:6px;font-size:12px}
.reject-panel{display:none;margin-top:8px}
.reject-panel.open{display:block}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">All Drivers &mdash; BookaWaka Admin</label></div>
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
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
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
      <li><a href="SA-Drivers.aspx" style="font-weight:700;color:#1565C0">&#9658; All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-Email.aspx">Send Email</a></li>
      <li><a href="SA-EmailLog.aspx">Email Sent Log</a></li>
      <li><a href="SA-Reports.aspx">Revenue Reports</a></li>
      <li><a href="SA-MasterReport.aspx">&#128202; Platform Overview</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="SA-Registrations.aspx">Registrations</a></li>
      <li><a href="SA-Alerts.aspx">System Alerts</a></li>
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
      <li><a href="SA-Broadcast.aspx">Broadcast</a></li>
      <li><a href="SA-Sessions.aspx">Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx">Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#128665; All Drivers</h2>
<p style="font-size:13px;color:#888;margin-bottom:14px">Manage all drivers across every company. Use the Transfer Requests tab to review and approve driver transfer requests.</p>

<div id="sa-notice" style="display:none" class="sa-notice"></div>

<!-- Tab bar -->
<div class="tab-bar">
  <button class="tab-btn active" id="tab-btn-drivers" onclick="switchTab('drivers')">&#128665; All Drivers</button>
  <button class="tab-btn" id="tab-btn-transfers" onclick="switchTab('transfers')">
    &#8646; Transfer Requests
    <span class="pending-badge" id="pending-count" style="display:none">0</span>
  </button>
</div>

<!-- ═══ TAB: ALL DRIVERS ═══ -->
<div class="tab-pane active" id="tab-drivers">
<div class="sa-card">
  <div id="drv-bulk-bar" style="display:none;padding:10px 18px;background:#E8F5E9;border-bottom:1px solid #A5D6A7;align-items:center;gap:10px;flex-wrap:wrap">
    <span id="drv-bulk-label" style="font-size:13px;font-weight:600;color:#1B5E20"></span>
    <button onclick="bulkApprove()" class="sa-btn sa-btn-s" style="font-size:12px">&#10003; Activate Selected</button>
    <button onclick="bulkReject()" class="sa-btn sa-btn-d" style="font-size:12px">&#10007; Deactivate Selected</button>
    <button onclick="clearBulk()" class="sa-btn sa-btn-n" style="font-size:12px">Clear</button>
  </div>
  <div class="sa-bar">
    <h3>&#128665; Driver Registry</h3>
    <span id="drv-count" style="font-size:12px;opacity:.8"></span>
    <button onclick="exportDriversCsv()" class="sa-btn sa-btn-n" style="font-size:11px;background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.35)">&#8595; Export CSV</button>
  </div>
  <div class="sa-stats">
    <div class="sa-stat"><div class="sa-stat-v" id="st-total">&#8230;</div><div class="sa-stat-l">Total Drivers</div></div>
    <div class="sa-stat"><div class="sa-stat-v" id="st-active" style="color:#2E7D32">&#8230;</div><div class="sa-stat-l">Active</div></div>
    <div class="sa-stat"><div class="sa-stat-v" id="st-inactive" style="color:#C62828">&#8230;</div><div class="sa-stat-l">Inactive</div></div>
    <div class="sa-stat"><div class="sa-stat-v" id="st-wav" style="color:#1B5E20">&#8230;</div><div class="sa-stat-l">WAV Drivers</div></div>
    <div class="sa-stat"><div class="sa-stat-v" id="st-cos">&#8230;</div><div class="sa-stat-l">Companies</div></div>
  </div>
  <div class="filter-row">
    <label>Company:</label>
    <select id="f-company" onchange="applyFilters()"><option value="">All Companies</option></select>
    <label>Status:</label>
    <select id="f-status" onchange="applyFilters()">
      <option value="">All</option><option value="active">Active</option><option value="inactive">Inactive</option>
    </select>
    <label>Type:</label>
    <select id="f-type" onchange="applyFilters()">
      <option value="">All Vehicles</option><option value="wav">WAV / Wheelchair</option><option value="standard">Standard</option>
    </select>
    <label>Service:</label>
    <select id="f-service" onchange="applyFilters()">
      <option value="">All Services</option>
      <option value="taxi">&#128663; Taxi</option>
      <option value="food">&#127828; Food</option>
      <option value="freight">&#128666; Freight</option>
      <option value="tm">&#9855; TM</option>
    </select>
    <input id="f-search" type="text" placeholder="Search name, plate, email&#8230;" oninput="applyFilters()" style="min-width:200px"/>
    <button class="sa-btn sa-btn-n" onclick="clearFilters()">Clear</button>
  </div>
  <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead><tr>
        <th style="width:38px;text-align:center"><input type="checkbox" id="drv-select-all" onchange="toggleSelectAll(this.checked)" style="cursor:pointer" title="Select all"/></th>
        <th>Driver</th><th>Company</th><th>Vehicle</th><th>Plate</th>
        <th>Type</th><th>Phone / Email</th><th>Status</th><th>Actions</th>

      </tr></thead>
      <tbody id="drv-tbody">
        <tr><td colspan="9" style="text-align:center;padding:30px;color:#aaa">Loading drivers&#8230;</td></tr>
      </tbody>
    </table>
  </div>
  <div id="drv-empty" style="display:none;text-align:center;padding:32px;color:#aaa;font-style:italic">No drivers match the current filter.</div>
</div>
</div>

<!-- ═══ TAB: TRANSFER REQUESTS ═══ -->
<div class="tab-pane" id="tab-transfers">
<div class="sa-card">
  <div class="sa-bar" style="background:#E65100">
    <h3>&#8646; Driver Transfer Requests</h3>
    <div style="display:flex;gap:8px;align-items:center">
      <select id="tr-filter" onchange="renderTransferRequests()" style="padding:5px 10px;border-radius:4px;border:none;font-size:12px">
        <option value="pending">Pending only</option>
        <option value="all">All requests</option>
        <option value="approved">Approved</option>
        <option value="rejected">Rejected</option>
      </select>
    </div>
  </div>
  <div style="padding:10px 18px;background:#FFF3E0;border-bottom:1px solid #FFE0B2;font-size:12.5px;color:#BF360C">
    <strong>Pending requests</strong> are submitted by drivers via the BookaWaka driver app. Review each one and approve or reject.
    You can also manually transfer any driver using the <strong>Transfer</strong> button in their profile.
  </div>
  <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead><tr>
        <th>Driver</th><th>From Company</th><th>&#8594; To Company</th>
        <th>Vehicle</th><th>Requested</th><th>Status</th><th>Actions</th>
      </tr></thead>
      <tbody id="tr-tbody">
        <tr><td colspan="7" style="text-align:center;padding:30px;color:#aaa">Loading&#8230;</td></tr>
      </tbody>
    </table>
  </div>
  <div id="tr-empty" style="display:none;text-align:center;padding:32px;color:#aaa;font-style:italic">No transfer requests found.</div>
</div>
</div>

</div>
</div></div>

<!-- ═══ Driver Detail Modal ═══ -->
<div id="modal-driver" class="modal-overlay">
  <div class="modal-box">
    <div style="display:flex;align-items:center;gap:14px;margin-bottom:20px">
      <div id="md-avatar-wrap"></div>
      <div>
        <div id="md-name" style="font-size:18px;font-weight:700;color:#1565C0"></div>
        <div id="md-company" style="font-size:13px;color:#888;margin-top:2px"></div>
      </div>
      <span id="md-status-badge" style="margin-left:auto"></span>
    </div>
    <div style="font-size:12px;font-weight:700;color:#1565C0;text-transform:uppercase;letter-spacing:.05em;margin-bottom:10px">Driver Details</div>
    <div class="detail-grid" id="md-detail-grid"></div>
    <div style="font-size:12px;font-weight:700;color:#1565C0;text-transform:uppercase;letter-spacing:.05em;margin:14px 0 10px">Vehicle Details</div>
    <div class="detail-grid" id="md-vehicle-grid"></div>

    <!-- Allowed Services Panel -->
    <div style="margin:16px 0 0;padding:14px;background:#F3E5F5;border-radius:8px;border:1.5px solid #CE93D8">
      <div style="font-size:12px;font-weight:700;color:#4A148C;text-transform:uppercase;letter-spacing:.05em;margin-bottom:10px">&#127986; Allowed Services</div>
      <p style="font-size:11.5px;color:#7B1FA2;margin:0 0 12px">Controls which job types this driver can receive. Dispatch will only assign jobs for enabled services. Owner Panel sets this; SA can override.</p>
      <div id="md-services-grid" style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px"></div>
      <div style="display:flex;gap:8px;align-items:center;margin-top:12px">
        <button class="sa-btn" style="background:#4A148C;color:#fff;font-size:12px" onclick="saveDriverServices()">&#10003; Save Services</button>
        <span id="md-svc-msg" style="font-size:11px;color:#888"></span>
      </div>
    </div>

    <!-- Transfer Panel (inside modal) -->
    <div id="md-transfer-panel" class="transfer-panel">
      <div style="font-size:13px;font-weight:700;color:#E65100;margin-bottom:10px">&#8646; Manual Transfer</div>
      <div class="tr-grid">
        <div class="sa-ff">
          <label>Transfer to Company <span style="color:#C62828">*</span></label>
          <select id="md-tr-company">
            <option value="">— Select new company —</option>
          </select>
        </div>
        <div class="sa-ff">
          <label>Driver owns vehicle?</label>
          <select id="md-tr-owns">
            <option value="no">No — company vehicle, stays behind</option>
            <option value="yes">Yes — owner-operator</option>
          </select>
        </div>
      </div>
      <div id="md-tr-vehicle-row" style="display:none;margin-bottom:10px">
        <div class="sa-ff">
          <label>Transfer vehicle to new company?</label>
          <select id="md-tr-vehicle">
            <option value="yes">Yes — take vehicle with them</option>
            <option value="no">No — leave vehicle behind</option>
          </select>
        </div>
      </div>
      <div class="sa-ff" style="margin-bottom:10px">
        <label>Reason / Notes <span style="color:#aaa;font-weight:400">optional</span></label>
        <input id="md-tr-note" placeholder="e.g. Relocating to Queenstown"/>
      </div>
      <div style="display:flex;gap:8px;align-items:center">
        <button class="sa-btn sa-btn-o" onclick="executeManualTransfer()">&#10003; Confirm Transfer</button>
        <button class="sa-btn sa-btn-n" onclick="closeTransferPanel()">Cancel</button>
        <span id="md-tr-msg" style="font-size:12px;color:#C62828"></span>
      </div>
      <div style="font-size:11.5px;color:#90A4AE;margin-top:8px">&#9432; Past trip history stays with the old company. This action takes effect immediately.</div>
    </div>

    <div style="display:flex;gap:8px;margin-top:20px;justify-content:flex-end;flex-wrap:wrap">
      <button id="md-toggle-btn" class="sa-btn" onclick="toggleDriverStatus()"></button>
      <button class="sa-btn sa-btn-w" onclick="openTransferPanel()" id="md-transfer-btn">&#8646; Transfer</button>
      <button class="sa-btn sa-btn-n" onclick="closeModal()">Close</button>
    </div>
    <div id="md-msg" style="font-size:12px;color:#C62828;margin-top:8px;text-align:right"></div>
  </div>
</div>

<!-- ═══ Reject Reason Modal ═══ -->
<div id="modal-reject" class="modal-overlay">
  <div class="modal-box" style="max-width:400px">
    <div style="font-size:16px;font-weight:700;color:#C62828;margin-bottom:14px">&#10007; Reject Transfer Request</div>
    <p style="font-size:13px;color:#555;margin-bottom:14px">The driver will be notified that their request was rejected. Provide a reason so they understand why.</p>
    <div class="sa-ff" style="margin-bottom:14px">
      <label>Reason <span style="color:#C62828">*</span></label>
      <textarea id="reject-reason" rows="3" placeholder="e.g. Position not currently available in that city."></textarea>
    </div>
    <div style="display:flex;gap:8px;justify-content:flex-end">
      <button class="sa-btn sa-btn-d" onclick="confirmReject()">Reject Request</button>
      <button class="sa-btn sa-btn-n" onclick="closeRejectModal()">Cancel</button>
    </div>
    <div id="reject-msg" style="font-size:12px;color:#C62828;margin-top:8px;text-align:right"></div>
  </div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allDrivers = [];
var allCompanies = {};
var allTransferRequests = {};
var currentDriverUid = null;
var rejectingRequestId = null;

/* ───── helpers ───── */
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function showNotice(msg, type) {
  var el = document.getElementById('sa-notice');
  el.className = 'sa-notice ' + (type || 'ok');
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(function(){ el.style.display='none'; }, 4500);
}

function driverName(d) {
  if (d.firstName || d.lastName) return [d.firstName, d.lastName].filter(Boolean).join(' ');
  return d.name || d.displayName || '(No name)';
}
function driverVehicle(d) {
  if (d.vehicleMake && d.vehicleModel) return d.vehicleMake + ' ' + d.vehicleModel;
  return d.vehicle || d.vehicleName || '—';
}
function driverPlate(d) { return d.licensePlate || d.vehiclePlate || d.plate || '—'; }
function isWav(d) {
  return !!(d.isWheelchairAccessible || d.accessible || d.wav ||
    (d.vehicleType && d.vehicleType.toLowerCase().indexOf('wheelchair') !== -1) ||
    (d.vehicleType && d.vehicleType.toLowerCase().indexOf('wav') !== -1));
}
function isActive(d) { return d.active !== false && d.status !== 'inactive' && d.status !== 'suspended'; }
function initials(d) {
  var n = driverName(d);
  return n.split(' ').map(function(p){ return p[0]||''; }).slice(0,2).join('').toUpperCase() || '?';
}
function fmtDate(ts) {
  if (!ts) return '—';
  var d = new Date(ts);
  return d.toLocaleDateString('en-NZ') + ' ' + d.toLocaleTimeString('en-NZ', {hour:'2-digit',minute:'2-digit'});
}
function coName(cid) { return cid ? (allCompanies[cid] && allCompanies[cid].name || cid) : '—'; }

/* ───── tabs ───── */
function switchTab(name) {
  ['drivers','transfers'].forEach(function(t) {
    document.getElementById('tab-'+t).classList.toggle('active', t===name);
    document.getElementById('tab-btn-'+t).classList.toggle('active', t===name);
  });
  if (name === 'transfers') renderTransferRequests();
}

/* ───── load data ───── */
function loadData() {
  Promise.all([
    _fbGet('superClients'),
    _fbGet('drivers'),
    _fbGet('driverTransferRequests')
  ]).then(function(results) {
    allCompanies = results[0] || {};
    var raw = results[1] || {};
    // Flatten both structures:
    // 1. Nested: drivers/{cid}/{uid} — Driver App / SA writes
    // 2. Flat:   drivers/{pushKey}   — Owner Portal writes
    var flat = [];
    var seenUids = {};
    Object.entries(raw).forEach(function(e){
      var key = e[0], val = e[1];
      if(!val || typeof val !== 'object') return;
      // Detect nested company bucket: key is a numeric CID and val contains uid-keyed objects
      var firstChildKey = Object.keys(val)[0];
      var firstChildVal = firstChildKey ? val[firstChildKey] : null;
      if(firstChildVal && typeof firstChildVal === 'object' && (firstChildVal.email || firstChildVal.uid || firstChildVal.companyId)){
        // Nested bucket — expand children
        Object.entries(val).forEach(function(e2){
          if(!seenUids[e2[0]] && e2[1] && typeof e2[1]==='object'){
            seenUids[e2[0]] = true;
            flat.push(Object.assign({ _uid: e2[0] }, e2[1]));
          }
        });
      } else if(!seenUids[key] && (val.email || val.uid || val.companyId)){
        // Flat record
        seenUids[key] = true;
        flat.push(Object.assign({ _uid: key }, val));
      }
    });
    allDrivers = flat;
    allTransferRequests = results[2] || {};

    // Populate company filter
    var sel = document.getElementById('f-company');
    Object.keys(allCompanies).sort(function(a,b){
      return (allCompanies[a].name||a).localeCompare(allCompanies[b].name||b);
    }).forEach(function(cid) {
      var opt = document.createElement('option');
      opt.value = cid;
      opt.textContent = allCompanies[cid].name || cid;
      sel.appendChild(opt);
    });

    // Pre-select company from URL param (e.g. coming from SA-Company "Drivers" button)
    var urlCid = new URLSearchParams(window.location.search).get('cid');
    if (urlCid && document.getElementById('f-company').querySelector('option[value="'+urlCid+'"]')) {
      document.getElementById('f-company').value = urlCid;
    }

    updateStats(allDrivers);
    applyFilters();
    updatePendingBadge();

    // Refresh transfer requests on load
    _fbGet('driverTransferRequests').then(function(data) {
      allTransferRequests = data || {};
      updatePendingBadge();
    });
  });
}

function updatePendingBadge() {
  var pending = Object.values(allTransferRequests).filter(function(r){ return r.status === 'pending'; }).length;
  var badge = document.getElementById('pending-count');
  badge.textContent = pending;
  badge.style.display = pending > 0 ? 'inline-block' : 'none';
}

/* ───── drivers tab ───── */
function updateStats(list) {
  var active = list.filter(isActive).length;
  var wav = list.filter(isWav).length;
  var cos = new Set(list.map(function(d){ return d.companyId; }).filter(Boolean)).size;
  document.getElementById('st-total').textContent = list.length;
  document.getElementById('st-active').textContent = active;
  document.getElementById('st-inactive').textContent = list.length - active;
  document.getElementById('st-wav').textContent = wav;
  document.getElementById('st-cos').textContent = cos;
}

/* ── Allowed Services helpers ────────────────────── */
var SVC_DEFS = [
  {key:'taxi',    label:'Taxi',    icon:'&#128663;', color:'#1565C0', bg:'#E3F2FD'},
  {key:'food',    label:'Food',    icon:'&#127828;', color:'#2E7D32', bg:'#E8F5E9'},
  {key:'freight', label:'Freight', icon:'&#128666;', color:'#E65100', bg:'#FFF3E0'},
  {key:'tm',      label:'TM',      icon:'&#9855;',   color:'#6A1B9A', bg:'#F3E5F5'}
];

function driverServices(d){
  var s=d.allowedServices||{};
  return {
    taxi:    s.taxi    !== false,   // default ON
    food:    s.food    === true,    // default OFF unless set
    freight: s.freight === true,    // default OFF unless set
    tm:      s.tm      === true     // default OFF unless set
  };
}

function svcBadges(d){
  var sv=driverServices(d);
  return SVC_DEFS.filter(function(f){ return sv[f.key]; }).map(function(f){
    return '<span style="background:'+f.bg+';color:'+f.color+';font-size:10px;font-weight:700;padding:1px 6px;border-radius:8px;white-space:nowrap;border:1px solid '+f.bg+'">'+f.icon+' '+f.label+'</span>';
  }).join(' ');
}

function renderServicesPanel(d){
  var sv=driverServices(d);
  var grid=document.getElementById('md-services-grid');
  if(!grid) return;
  grid.innerHTML=SVC_DEFS.map(function(f){
    var on=sv[f.key];
    return '<label style="display:flex;align-items:center;gap:7px;padding:8px 10px;border:1.5px solid '+(on?f.color:'#e0e0e0')+';border-radius:6px;cursor:pointer;background:'+(on?f.bg:'#fafafa')+'">'
      +'<input type="checkbox" id="svc-'+f.key+'" '+(on?'checked':'')+' style="cursor:pointer;accent-color:'+f.color+'">'
      +'<span style="font-size:12px;font-weight:600;color:#263238">'+f.icon+' '+f.label+'</span>'
      +'</label>';
  }).join('');
  document.getElementById('md-svc-msg').textContent='';
}

function saveDriverServices(){
  if(!currentDriverUid) return;
  var updates={};
  SVC_DEFS.forEach(function(f){
    var el=document.getElementById('svc-'+f.key);
    if(el) updates[f.key]=el.checked;
  });
  db.ref('drivers/'+currentDriverUid+'/allowedServices').update(updates).then(function(){
    var d=allDrivers.find(function(x){ return x._uid===currentDriverUid; });
    if(d) d.allowedServices=Object.assign(d.allowedServices||{},updates);
    document.getElementById('md-svc-msg').textContent='Saved ✓';
    document.getElementById('md-svc-msg').style.color='#2E7D32';
    applyFilters();
  }).catch(function(e){
    document.getElementById('md-svc-msg').textContent='Error: '+e.message;
    document.getElementById('md-svc-msg').style.color='#C62828';
  });
}

function applyFilters() {
  var fCo = document.getElementById('f-company').value;
  var fSt = document.getElementById('f-status').value;
  var fTy = document.getElementById('f-type').value;
  var fSvc= document.getElementById('f-service').value;
  var fSr = (document.getElementById('f-search').value || '').toLowerCase();
  var filtered = allDrivers.filter(function(d) {
    if (fCo && d.companyId !== fCo) return false;
    if (fSt === 'active' && !isActive(d)) return false;
    if (fSt === 'inactive' && isActive(d)) return false;
    if (fTy === 'wav' && !isWav(d)) return false;
    if (fTy === 'standard' && isWav(d)) return false;
    if (fSvc) { var sv=driverServices(d); if(!sv[fSvc]) return false; }
    if (fSr) {
      var h = [driverName(d), driverPlate(d), d.email||'', d.phone||'', d.companyId||''].join(' ').toLowerCase();
      if (h.indexOf(fSr) === -1) return false;
    }
    return true;
  });
  document.getElementById('drv-count').textContent = filtered.length + ' driver(s)';
  renderTable(filtered);
}

function clearFilters() {
  ['f-company','f-status','f-type','f-service'].forEach(function(id){ document.getElementById(id).value=''; });
  document.getElementById('f-search').value = '';
  applyFilters();
}

function renderTable(list) {
  var tbody = document.getElementById('drv-tbody');
  var empty = document.getElementById('drv-empty');
  if (!list.length) { tbody.innerHTML=''; empty.style.display='block'; return; }
  empty.style.display = 'none';
  var sorted = list.slice().sort(function(a,b){
    var ca = coName(a.companyId), cb = coName(b.companyId);
    if (ca !== cb) return ca.localeCompare(cb);
    return driverName(a).localeCompare(driverName(b));
  });
  tbody.innerHTML = sorted.map(function(d) {
    var cname = coName(d.companyId);
    var active = isActive(d);
    var wav = isWav(d);
    var avatar = (d.profilePhoto||d.photo||d.photoURL)
      ? '<img src="'+esc(d.profilePhoto||d.photo||d.photoURL)+'" class="drv-avatar" onerror="this.style.display=\'none\'"/>'
      : '<div class="drv-avatar-placeholder">'+esc(initials(d))+'</div>';
    return '<tr>'+
      '<td style="text-align:center"><input type="checkbox" class="drv-chk" data-uid="'+esc(d._uid)+'" onchange="updateBulkBar()" style="cursor:pointer"/></td>'+
      '<td>'+avatar+'</td>'+
      '<td><div style="font-weight:600;color:#1565C0;cursor:pointer" onclick="openModal(\''+esc(d._uid)+'\')">'+esc(driverName(d))+'</div>'+
        (d.email?'<div style="font-size:11px;color:#aaa">'+esc(d.email)+'</div>':'')+
        '<div style="margin-top:3px;display:flex;flex-wrap:wrap;gap:2px">'+svcBadges(d)+'</div></td>'+
      '<td><span style="font-size:12px">'+esc(cname)+'</span>'+
        (d.companyId?'<div style="font-size:10px;font-family:monospace;color:#aaa">ID: '+esc(d.companyId)+'</div>':'')+'</td>'+
      '<td>'+esc(driverVehicle(d))+'</td>'+
      '<td style="font-family:monospace;font-size:12px">'+esc(driverPlate(d))+'</td>'+
      '<td>'+(wav?'<span class="badge-wav">&#9855; WAV</span>':'<span class="badge-std">Standard</span>')+'</td>'+
      '<td style="font-size:12px">'+
        (d.phone?'<div>&#128222; '+esc(d.phone)+'</div>':'')+
        (d.email?'<div style="color:#aaa">&#9993; '+esc(d.email)+'</div>':'')+'</td>'+
      '<td>'+(active?'<span class="badge-active">Active</span>':'<span class="badge-inactive">Inactive</span>')+'</td>'+
      '<td style="white-space:nowrap">'+
        '<button class="sa-btn sa-btn-p" style="font-size:11px;padding:4px 9px;margin-right:4px" onclick="openModal(\''+esc(d._uid)+'\')">&#128065; View</button>'+
        (active
          ?'<button class="sa-btn sa-btn-d" style="font-size:11px;padding:4px 9px" onclick="quickToggle(\''+esc(d._uid)+'\',false)">Deactivate</button>'
          :'<button class="sa-btn sa-btn-s" style="font-size:11px;padding:4px 9px" onclick="quickToggle(\''+esc(d._uid)+'\',true)">Activate</button>')+
      '</td>'+
    '</tr>';
  }).join('');
}

/* ── Bulk Select & Actions ───────────────────────── */
function toggleSelectAll(checked){
  document.querySelectorAll('.drv-chk').forEach(function(chk){ chk.checked=checked; });
  updateBulkBar();
}
function updateBulkBar(){
  var selected=Array.from(document.querySelectorAll('.drv-chk:checked'));
  var bar=document.getElementById('drv-bulk-bar');
  if(selected.length){
    bar.style.display='flex';
    document.getElementById('drv-bulk-label').textContent=selected.length+' driver'+(selected.length!==1?'s':'')+' selected';
  } else {
    bar.style.display='none';
  }
}
function getSelectedUids(){
  return Array.from(document.querySelectorAll('.drv-chk:checked')).map(function(c){ return c.dataset.uid; });
}
function clearBulk(){
  document.querySelectorAll('.drv-chk').forEach(function(c){ c.checked=false; });
  var selAll=document.getElementById('drv-select-all'); if(selAll) selAll.checked=false;
  document.getElementById('drv-bulk-bar').style.display='none';
}
function bulkApprove(){
  var uids=getSelectedUids();
  if(!uids.length) return;
  if(!confirm('Activate '+uids.length+' selected driver'+(uids.length!==1?'s':'')+' ?')) return;
  var done=0;
  uids.forEach(function(uid){
    db.ref('drivers/'+uid).update({active:true}).then(function(){
      var d=allDrivers.find(function(x){return x._uid===uid;}); if(d) d.active=true;
      if(++done===uids.length){ clearBulk(); applyFilters(); showNotice(done+' driver'+(done!==1?'s':'')+' activated.','ok'); }
    });
  });
}
function bulkReject(){
  var uids=getSelectedUids();
  if(!uids.length) return;
  if(!confirm('Deactivate '+uids.length+' selected driver'+(uids.length!==1?'s':'')+' ?')) return;
  var done=0;
  uids.forEach(function(uid){
    db.ref('drivers/'+uid).update({active:false}).then(function(){
      var d=allDrivers.find(function(x){return x._uid===uid;}); if(d) d.active=false;
      if(++done===uids.length){ clearBulk(); applyFilters(); showNotice(done+' driver'+(done!==1?'s':'')+' deactivated.','ok'); }
    });
  });
}
/* ── Export Drivers CSV ──────────────────────────── */
function exportDriversCsv(){
  if(!allDrivers.length){ showNotice('No drivers loaded yet.','err'); return; }
  var rows=[['Name','Email','Phone','Company','Company ID','Vehicle','Plate','Type','Status']];
  allDrivers.forEach(function(d){
    rows.push([
      driverName(d),
      d.email||'',
      d.phone||d.mobileNumber||'',
      coName(d.companyId),
      d.companyId||'',
      driverVehicle(d),
      driverPlate(d),
      isWav(d)?'WAV':'Standard',
      isActive(d)?'Active':'Inactive'
    ]);
  });
  var csv=rows.map(function(r){
    return r.map(function(c){
      var s=String(c==null?'':c);
      return s.indexOf(',')!==-1||s.indexOf('"')!==-1||s.indexOf('\n')!==-1?'"'+s.replace(/"/g,'""')+'"':s;
    }).join(',');
  }).join('\r\n');
  var blob=new Blob(['\uFEFF'+csv],{type:'text/csv;charset=utf-8'});
  var url=URL.createObjectURL(blob);
  var a=document.createElement('a'); a.href=url; a.download='drivers-'+new Date().toISOString().slice(0,10)+'.csv';
  document.body.appendChild(a); a.click();
  setTimeout(function(){document.body.removeChild(a);URL.revokeObjectURL(url);},500);
}

function quickToggle(uid, activate) {
  db.ref('drivers/'+uid).update({active:activate}).then(function(){
    var d = allDrivers.find(function(x){ return x._uid===uid; });
    if (d) d.active = activate;
    applyFilters();
    showNotice(driverName(d||{})+(activate?' activated.':' deactivated.'),'ok');
  }).catch(function(err){ showNotice('Update failed: '+String(err),'err'); });
}

/* ───── driver modal ───── */
function openModal(uid) {
  var d = allDrivers.find(function(x){ return x._uid===uid; });
  if (!d) return;
  currentDriverUid = uid;
  closeTransferPanel();

  var cname = coName(d.companyId);
  var active = isActive(d);
  var wav = isWav(d);

  var avatarHtml = (d.profilePhoto||d.photo||d.photoURL)
    ? '<img src="'+esc(d.profilePhoto||d.photo||d.photoURL)+'" style="width:56px;height:56px;border-radius:50%;object-fit:cover;border:3px solid #e0e0e0"/>'
    : '<div style="width:56px;height:56px;border-radius:50%;background:#E3F2FD;color:#1565C0;display:flex;align-items:center;justify-content:center;font-size:22px;font-weight:700;border:3px solid #BBDEFB">'+esc(initials(d))+'</div>';
  document.getElementById('md-avatar-wrap').innerHTML = avatarHtml;
  document.getElementById('md-name').textContent = driverName(d);
  document.getElementById('md-company').textContent = '\u{1F3E0} ' + cname;
  document.getElementById('md-status-badge').innerHTML = active
    ? '<span class="badge-active">Active</span>'
    : '<span class="badge-inactive">Inactive</span>';

  document.getElementById('md-detail-grid').innerHTML = [
    ['UID', d._uid], ['Company', cname],
    ['Email', d.email||'—'], ['Phone', d.phone||'—'],
    ['Licence #', d.licenceNumber||d.driverLicence||'—'],
    ['Registered', d.createdAt ? new Date(d.createdAt).toLocaleDateString('en-NZ') : '—']
  ].map(function(r){
    return '<div class="detail-item"><label>'+esc(r[0])+'</label><span style="overflow-wrap:break-word;word-break:break-word">'+esc(r[1])+'</span></div>';
  }).join('');

  document.getElementById('md-vehicle-grid').innerHTML = [
    ['Make / Model', driverVehicle(d)],
    ['Plate', driverPlate(d)],
    ['Type', d.vehicleType||'—'],
    ['Year', d.vehicleYear||'—'],
    ['Colour', d.vehicleColour||d.vehicleColor||'—'],
    ['WAV', wav ? '&#9855; Yes' : 'No']
  ].map(function(r){
    return '<div class="detail-item"><label>'+esc(r[0])+'</label><span>'+r[1]+'</span></div>';
  }).join('');

  var btn = document.getElementById('md-toggle-btn');
  btn.className = 'sa-btn ' + (active ? 'sa-btn-d' : 'sa-btn-s');
  btn.textContent = active ? 'Deactivate Driver' : 'Activate Driver';
  document.getElementById('md-msg').textContent = '';
  renderServicesPanel(d);
  document.getElementById('modal-driver').classList.add('open');
}

function closeModal() {
  document.getElementById('modal-driver').classList.remove('open');
  currentDriverUid = null;
  closeTransferPanel();
}

function toggleDriverStatus() {
  if (!currentDriverUid) return;
  var d = allDrivers.find(function(x){ return x._uid===currentDriverUid; });
  if (!d) return;
  var newActive = !isActive(d);
  db.ref('drivers/'+currentDriverUid).update({active:newActive}).then(function(){
    d.active = newActive;
    applyFilters();
    openModal(currentDriverUid);
    document.getElementById('md-msg').style.color = '#2E7D32';
    document.getElementById('md-msg').textContent = newActive ? 'Driver activated.' : 'Driver deactivated.';
  }).catch(function(err){
    document.getElementById('md-msg').style.color = '#C62828';
    document.getElementById('md-msg').textContent = 'Error: '+String(err);
  });
}

/* ───── transfer panel (manual SA transfer) ───── */
function openTransferPanel() {
  var panel = document.getElementById('md-transfer-panel');
  if (panel.classList.contains('open')) { closeTransferPanel(); return; }

  // Populate company dropdown (all except current)
  var d = allDrivers.find(function(x){ return x._uid===currentDriverUid; });
  var sel = document.getElementById('md-tr-company');
  sel.innerHTML = '<option value="">— Select new company —</option>';
  Object.keys(allCompanies).sort(function(a,b){
    return (allCompanies[a].name||a).localeCompare(allCompanies[b].name||b);
  }).forEach(function(cid){
    if (d && cid === d.companyId) return; // skip current company
    var bw = allCompanies[cid].bookawakaOperated ? ' [BookaWaka]' : '';
    var opt = document.createElement('option');
    opt.value = cid;
    opt.textContent = (allCompanies[cid].name||cid) + bw;
    sel.appendChild(opt);
  });

  document.getElementById('md-tr-note').value = '';
  document.getElementById('md-tr-owns').value = 'no';
  document.getElementById('md-tr-vehicle-row').style.display = 'none';
  document.getElementById('md-tr-msg').textContent = '';
  panel.classList.add('open');

  // Show/hide vehicle transfer question
  document.getElementById('md-tr-owns').onchange = function() {
    document.getElementById('md-tr-vehicle-row').style.display =
      this.value === 'yes' ? 'block' : 'none';
  };
}

function closeTransferPanel() {
  document.getElementById('md-transfer-panel').classList.remove('open');
}

function executeManualTransfer() {
  var d = allDrivers.find(function(x){ return x._uid===currentDriverUid; });
  if (!d) return;
  var newCid = document.getElementById('md-tr-company').value;
  var ownsVehicle = document.getElementById('md-tr-owns').value === 'yes';
  var transferVehicle = ownsVehicle && document.getElementById('md-tr-vehicle').value === 'yes';
  var note = document.getElementById('md-tr-note').value.trim();
  var msg = document.getElementById('md-tr-msg');

  if (!newCid) { msg.textContent = 'Please select a company.'; return; }
  msg.textContent = 'Transferring…';

  var fromCid = d.companyId;
  var plate = driverPlate(d);

  // Check plate conflict if transferring vehicle
  var checkPlate = (transferVehicle && plate !== '—')
    ? _fbGet('drivers').then(function(allDr){ var r={}; Object.entries(allDr||{}).forEach(function(e){ if(e[1]&&e[1].companyId===newCid) r[e[0]]=e[1]; }); return r; })
    : Promise.resolve(null);

  checkPlate.then(function(existing) {
    if (existing) {
      var existing = existing || {};
      var conflict = Object.values(existing).find(function(dr){
        return (dr.licensePlate||dr.vehiclePlate||dr.plate) === plate && dr._uid !== currentDriverUid;
      });
      if (conflict) {
        msg.style.color = '#C62828';
        msg.textContent = 'Plate "'+plate+'" already exists at the destination company. Resolve before transferring vehicle.';
        return;
      }
    }

    // Execute transfer
    var patch = { companyId: newCid };
    return db.ref('drivers/'+currentDriverUid).update(patch).then(function(){
      // Log the transfer
      return db.ref('driverTransferRequests').push({
        driverUid: currentDriverUid,
        driverName: driverName(d),
        fromCompanyId: fromCid,
        toCompanyId: newCid,
        ownsVehicle: ownsVehicle,
        vehicleTransferred: transferVehicle,
        vehiclePlate: plate,
        note: note || null,
        status: 'approved',
        initiatedBy: 'superadmin',
        createdAt: new Date().toISOString(),
        resolvedAt: new Date().toISOString()
      });
    }).then(function(){
      d.companyId = newCid;
      msg.style.color = '#2E7D32';
      msg.textContent = 'Transfer complete.';
      applyFilters();
      sendTransferEmail(d, fromCid, newCid, driverVehicle(d), plate, note);
      setTimeout(function(){ closeModal(); showNotice(driverName(d)+' transferred to '+coName(newCid)+'.','ok'); }, 800);
    });
  }).catch(function(err){
    msg.style.color = '#C62828';
    msg.textContent = 'Error: '+String(err);
  });
}

/* ───── transfer requests tab ───── */
function renderTransferRequests() {
  var filter = document.getElementById('tr-filter').value;
  var tbody = document.getElementById('tr-tbody');
  var empty = document.getElementById('tr-empty');

  var list = Object.entries(allTransferRequests).filter(function(e){
    if (filter === 'all') return true;
    return e[1].status === filter;
  }).sort(function(a,b){
    return (b[1].createdAt||'').localeCompare(a[1].createdAt||'');
  });

  if (!list.length) {
    tbody.innerHTML = '';
    empty.style.display = 'block';
    return;
  }
  empty.style.display = 'none';

  tbody.innerHTML = list.map(function(entry){
    var rid = entry[0], r = entry[1];
    var statusBadge = r.status === 'pending'
      ? '<span class="badge-pending">&#9679; Pending</span>'
      : r.status === 'approved'
        ? '<span class="badge-approved">&#10003; Approved</span>'
        : '<span class="badge-rejected">&#10007; Rejected</span>';

    var vehicleInfo = r.ownsVehicle
      ? (r.vehicleTransferred ? '&#128664; Vehicle transferred' : '&#128664; Owns vehicle, stayed behind')
      : '&#127968; Company vehicle';

    var actions = '';
    if (r.status === 'pending') {
      actions =
        '<button class="sa-btn sa-btn-s" style="font-size:11px;margin-right:4px" onclick="approveTransfer(\''+esc(rid)+'\')">&#10003; Approve</button>'+
        '<button class="sa-btn sa-btn-d" style="font-size:11px" onclick="openRejectModal(\''+esc(rid)+'\')">&#10007; Reject</button>';
    } else {
      actions = '<span style="font-size:11.5px;color:#aaa">'+fmtDate(r.resolvedAt)+'</span>';
      if (r.rejectionReason) {
        actions += '<div style="font-size:11px;color:#C62828;margin-top:3px">Reason: '+esc(r.rejectionReason)+'</div>';
      }
    }

    var initiatedBy = r.initiatedBy === 'superadmin'
      ? '<div style="font-size:10.5px;color:#1565C0;margin-top:2px">&#9881; SA-initiated</div>'
      : '<div style="font-size:10.5px;color:#888;margin-top:2px">&#128100; Driver-requested</div>';

    return '<tr class="'+(r.status==='pending'?'tr-req-row-pending':'')+'">'+
      '<td><div style="font-weight:600">'+esc(r.driverName||r.driverUid||'—')+'</div>'+
        initiatedBy+
        (r.note?'<div style="font-size:11px;color:#777;margin-top:2px;font-style:italic">&#8220;'+esc(r.note)+'&#8221;</div>':'')+'</td>'+
      '<td style="font-size:12px">'+esc(coName(r.fromCompanyId))+'</td>'+
      '<td style="font-size:12px"><strong style="color:#1565C0">'+esc(coName(r.toCompanyId))+'</strong></td>'+
      '<td style="font-size:12px">'+vehicleInfo+'<br><span style="font-family:monospace;font-size:11px;color:#aaa">'+esc(r.vehiclePlate||'')+'</span></td>'+
      '<td style="font-size:12px;color:#888">'+fmtDate(r.createdAt)+'</td>'+
      '<td>'+statusBadge+'</td>'+
      '<td style="white-space:nowrap">'+actions+'</td>'+
    '</tr>';
  }).join('');
}

function sendTransferEmail(driverData, fromCid, toCid, vehicleInfo, plate, note) {
  if (!driverData || !driverData.email) return; // no email on file, skip silently
  fetch('/api/send-transfer-email', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      driverName: driverName(driverData),
      driverEmail: driverData.email,
      fromCompany: coName(fromCid),
      toCompany: coName(toCid),
      vehicleInfo: vehicleInfo || '—',
      plate: plate || '—',
      note: note || ''
    })
  }).then(function(res){ return res.json(); }).then(function(json){
    if (json.ok) {
      showNotice('Approval email sent to ' + driverData.email + '.', 'ok');
    } else {
      console.warn('Email send issue:', json.error);
    }
  }).catch(function(err){ console.warn('Email send failed:', err); });
}

function approveTransfer(rid) {
  var r = allTransferRequests[rid];
  if (!r) return;
  var d = allDrivers.find(function(x){ return x._uid===r.driverUid; });
  if (!d) { showNotice('Driver not found in local data.','err'); return; }

  db.ref('drivers/'+r.driverUid).update({ companyId: r.toCompanyId }).then(function(){
    return db.ref('driverTransferRequests/'+rid).update({
      status: 'approved',
      resolvedAt: new Date().toISOString()
    });
  }).then(function(){
    d.companyId = r.toCompanyId;
    allTransferRequests[rid].status = 'approved';
    allTransferRequests[rid].resolvedAt = new Date().toISOString();
    applyFilters();
    renderTransferRequests();
    updatePendingBadge();
    showNotice((r.driverName||'Driver')+' transferred to '+coName(r.toCompanyId)+'.','ok');
    sendTransferEmail(d, r.fromCompanyId, r.toCompanyId, driverVehicle(d), driverPlate(d), r.note);
    var auditKey = 'LOG'+Date.now()+'_'+Math.random().toString(36).slice(2,7);
    db.ref('superAuditLog/'+auditKey).set({action:'driver_transfer_approved',actor:(firebase.auth().currentUser||{}).email||'sa-admin',cid:r.toCompanyId,cidName:coName(r.toCompanyId),detail:(r.driverName||r.driverUid||'Driver')+' transferred from '+coName(r.fromCompanyId)+' to '+coName(r.toCompanyId),ts:Date.now()});
  }).catch(function(err){ showNotice('Error: '+String(err),'err'); });
}

/* ───── reject modal ───── */
function openRejectModal(rid) {
  rejectingRequestId = rid;
  document.getElementById('reject-reason').value = '';
  document.getElementById('reject-msg').textContent = '';
  document.getElementById('modal-reject').classList.add('open');
}
function closeRejectModal() {
  document.getElementById('modal-reject').classList.remove('open');
  rejectingRequestId = null;
}
function sendRejectionEmail(driverData, fromCid, toCid, reason) {
  if (!driverData || !driverData.email) return;
  fetch('/api/send-transfer-email', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      type: 'rejected',
      driverName: driverName(driverData),
      driverEmail: driverData.email,
      fromCompany: coName(fromCid),
      toCompany: coName(toCid),
      rejectionReason: reason
    })
  }).then(function(res){ return res.json(); }).then(function(json){
    if (json.ok) {
      showNotice('Decline notice sent to ' + driverData.email + '.', 'ok');
    } else {
      console.warn('Rejection email issue:', json.error);
    }
  }).catch(function(err){ console.warn('Rejection email failed:', err); });
}

function confirmReject() {
  var reason = document.getElementById('reject-reason').value.trim();
  if (!reason) { document.getElementById('reject-msg').textContent = 'Please enter a reason.'; return; }
  document.getElementById('reject-msg').textContent = 'Saving…';
  var rid = rejectingRequestId;
  var r = allTransferRequests[rid] || {};
  db.ref('driverTransferRequests/'+rid).update({
    status: 'rejected',
    rejectionReason: reason,
    resolvedAt: new Date().toISOString()
  }).then(function(){
    allTransferRequests[rid].status = 'rejected';
    allTransferRequests[rid].rejectionReason = reason;
    allTransferRequests[rid].resolvedAt = new Date().toISOString();
    closeRejectModal();
    renderTransferRequests();
    updatePendingBadge();
    showNotice('Transfer request rejected.','ok');
    var d = allDrivers.find(function(x){ return x._uid === r.driverUid; });
    if (d) sendRejectionEmail(d, r.fromCompanyId, r.toCompanyId, reason);
    var auditKey = 'LOG'+Date.now()+'_'+Math.random().toString(36).slice(2,7);
    db.ref('superAuditLog/'+auditKey).set({action:'driver_transfer_rejected',actor:(firebase.auth().currentUser||{}).email||'sa-admin',cid:r.toCompanyId,cidName:coName(r.toCompanyId),detail:(r.driverName||r.driverUid||'Driver')+' transfer from '+coName(r.fromCompanyId)+' rejected; reason: '+reason,ts:Date.now()});
  }).catch(function(err){
    document.getElementById('reject-msg').textContent = 'Error: '+String(err);
  });
}

/* ───── close modals on backdrop ───── */
document.getElementById('modal-driver').addEventListener('click', function(e){ if(e.target===this) closeModal(); });
document.getElementById('modal-reject').addEventListener('click', function(e){ if(e.target===this) closeRejectModal(); });

window._fbOnLogin = function(){ loadData(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
