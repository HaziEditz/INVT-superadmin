<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Company Billing &mdash; BookaWaka Admin</title>
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
<script>firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});</script>
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-bar.green{background:#2E7D32}
.sa-bar.amber{background:#E65100}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-tbl tr.row-overdue td{background:#FFF5F5}
.sa-tbl tr.row-unpaid td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none;white-space:nowrap}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}.sa-btn-s:hover{background:#C8E6C9}
.sa-btn-w{background:#FFF9C4;color:#F57F17;border:1px solid #FFF176}.sa-btn-w:hover{background:#FFF176}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-o{background:#E65100;color:#fff}.sa-btn-o:hover{background:#BF360C}
.sa-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.sa-ff input:focus,.sa-ff select:focus{outline:none;border-color:#1565C0}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.badge-paid{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-unpaid{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.badge-overdue{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.badge-active{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-suspended{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.cid-badge{font-family:monospace;background:#E3F2FD;color:#1565C0;padding:2px 7px;border-radius:4px;font-size:12px;font-weight:700}
.co-header{padding:16px 18px;background:#F0F7FF;border-bottom:1px solid #BBDEFB;display:flex;align-items:center;gap:16px;flex-wrap:wrap}
.co-name{font-size:18px;font-weight:700;color:#333}
.co-meta{font-size:12.5px;color:#888;margin-top:2px}
.pkg-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:12px;padding:16px 18px}
.inv-form{display:none;padding:16px 18px;background:#F0F7FF;border-top:1px solid #BBDEFB}
.inv-form.open{display:block}
.inv-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:12px;margin-bottom:12px}
.stat-chips{display:flex;gap:10px;flex-wrap:wrap;padding:14px 18px;border-bottom:1px solid #f5f5f5}
.stat-box{border-radius:6px;padding:11px 16px;min-width:110px;text-align:center}
.stat-box .stat-n{font-size:22px;font-weight:700}
.stat-box .stat-l{font-size:11px;color:#888;margin-top:2px}
.ov-stat-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:12px;padding:16px 18px;border-bottom:1px solid #f5f5f5}
.ov-stat{border-radius:6px;padding:14px 16px;border-left:4px solid}
.ov-stat .n{font-size:26px;font-weight:700}
.ov-stat .l{font-size:12px;color:#aaa;margin-top:4px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff" id="page-title-lbl">Company Billing &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Billing.aspx" style="font-weight:700;color:#1565C0">&#9658; Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
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

<div id="sa-notice" class="sa-notice"></div>

<!-- ═══════════════════════════════════════════════════════════════
     OVERVIEW MODE  (no ?cid= in URL)
═══════════════════════════════════════════════════════════════ -->
<div id="view-overview" style="display:none">
  <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:16px">
    <h2 style="font-size:18px;font-weight:700;color:#263238;margin:0">&#128179; Billing Overview</h2>
    <div style="display:flex;gap:8px">
      <button onclick="openBatchModal()" class="sa-btn sa-btn-p" style="font-size:12px">&#9889; Batch Generate Invoices</button>
      <button onclick="loadOverview()" class="sa-btn sa-btn-n" style="font-size:12px">&#8635; Refresh</button>
    </div>
  </div>

  <div class="sa-card">
    <div class="ov-stat-row">
      <div class="ov-stat" style="background:#FFEBEE;border-color:#C62828"><div class="n" style="color:#C62828" id="ov-overdue">—</div><div class="l">Overdue Invoices</div></div>
      <div class="ov-stat" style="background:#E3F2FD;border-color:#1565C0"><div class="n" style="color:#1565C0" id="ov-unpaid">—</div><div class="l">Unpaid Invoices</div></div>
      <div class="ov-stat" style="background:#FFF3E0;border-color:#E65100"><div class="n" style="color:#E65100" id="ov-outstanding">—</div><div class="l">Total Outstanding</div></div>
      <div class="ov-stat" style="background:#E8F5E9;border-color:#2E7D32"><div class="n" style="color:#2E7D32" id="ov-collected">—</div><div class="l">Total Collected</div></div>
    </div>
    <div style="padding:0 18px 14px">
      <div id="ov-loading" style="text-align:center;padding:30px;color:#aaa;font-size:13px">Loading billing data&hellip;</div>
      <div id="ov-filter-bar" style="display:none;display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px;align-items:center">
        <span style="font-size:12px;color:#888">Filter:</span>
        <button onclick="filterOverview('all')" id="fil-all" class="sa-btn sa-btn-p" style="font-size:11px">All</button>
        <button onclick="filterOverview('overdue')" id="fil-overdue" class="sa-btn sa-btn-n" style="font-size:11px">Overdue</button>
        <button onclick="filterOverview('unpaid')" id="fil-unpaid" class="sa-btn sa-btn-n" style="font-size:11px">Unpaid</button>
        <button onclick="filterOverview('ok')" id="fil-ok" class="sa-btn sa-btn-n" style="font-size:11px">Up to date</button>
        <input id="ov-search" type="text" placeholder="Search company&hellip;" oninput="renderOverviewTable()" style="padding:5px 10px;border:1px solid #ddd;border-radius:4px;font-size:12px;margin-left:auto;width:180px"/>
        <button onclick="sendAllOverdueReminders()" class="sa-btn sa-btn-o" style="font-size:11px" title="Send reminder emails to all companies with overdue invoices">&#9993; Remind All Overdue</button>
        <button onclick="autoMarkOverdue()" class="sa-btn" style="font-size:11px;background:#E65100;color:#fff;border:none" title="Scan all unpaid invoices and mark those past due date as overdue">&#9888; Auto-Mark Overdue</button>
      </div>
      <div style="overflow-x:auto">
      <table class="sa-tbl" id="ov-tbl" style="display:none">
        <thead>
          <tr>
            <th>Company</th>
            <th>Plan</th>
            <th>Monthly Fee</th>
            <th>Latest Invoice</th>
            <th>Outstanding</th>
            <th>Next Due</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="ov-body"></tbody>
      </table>
      </div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════
     SINGLE-COMPANY MODE  (?cid= provided)
═══════════════════════════════════════════════════════════════ -->
<div id="view-company" style="display:none">

  <div style="margin-bottom:14px;display:flex;align-items:center;gap:10px;flex-wrap:wrap">
    <a href="SA-Billing.aspx" class="sa-btn sa-btn-n" style="font-size:12px">&#8592; All Billing</a>
    <a id="link-company" href="#" class="sa-btn sa-btn-n" style="font-size:12px">&#128065; Company Details</a>
    <a id="link-email" href="#" class="sa-btn sa-btn-n" style="font-size:12px">&#9993; Send Email</a>
  </div>

  <!-- Company header -->
  <div class="sa-card" id="co-header-card">
    <div class="co-header">
      <div>
        <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
          <span class="cid-badge" id="co-cid"></span>
          <span class="co-name" id="co-name"></span>
          <span id="co-status-badge"></span>
        </div>
        <div class="co-meta" id="co-meta"></div>
      </div>
      <div style="margin-left:auto;display:flex;gap:8px">
        <button class="sa-btn sa-btn-s" id="btn-activate" style="display:none" onclick="setCompanyStatus('active')">&#10003; Activate</button>
        <button class="sa-btn sa-btn-d" id="btn-suspend" style="display:none" onclick="setCompanyStatus('suspended')">Suspend</button>
      </div>
    </div>
  </div>

  <!-- Package assignment -->
  <div class="sa-card" id="pkg-card">
    <div class="sa-bar"><h3>&#128230; Subscription Package</h3>
      <button onclick="generateInvoice()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px">&#9889; Generate This Month&apos;s Invoice</button>
    </div>
    <div class="pkg-grid">
      <div class="sa-ff">
        <label>Package</label>
        <select id="pkg-sel"><option value="">-- select package --</option></select>
      </div>
      <div class="sa-ff">
        <label>Monthly Fee (NZD) <span style="color:#aaa;font-size:11px">override if needed</span></label>
        <input id="pkg-fee" type="number" min="0" step="1" placeholder="e.g. 199"/>
      </div>
      <div class="sa-ff">
        <label>Billing Start Date</label>
        <input id="pkg-start" type="date"/>
      </div>
      <div class="sa-ff">
        <label>Next Due Date</label>
        <input id="pkg-due" type="date"/>
      </div>
    </div>
    <div style="padding:0 18px 16px;display:flex;gap:8px;align-items:center">
      <button class="sa-btn sa-btn-p" onclick="savePackageAssign()">Save Package</button>
      <span id="pkg-msg" style="font-size:12.5px;color:#888"></span>
    </div>
  </div>

  <!-- Plan Compliance Panel -->
  <div class="sa-card" id="plan-compliance-card" style="display:none">
    <div class="sa-bar" style="background:#37474F">
      <h3>&#128203; Plan Compliance</h3>
      <span id="plan-compliance-badge" style="font-size:12px;font-weight:700;padding:3px 12px;border-radius:12px;background:rgba(255,255,255,.15)"></span>
    </div>
    <div id="plan-compliance-body" style="padding:16px 18px;display:flex;gap:24px;flex-wrap:wrap;align-items:flex-start"></div>
  </div>

  <!-- Invoice stats + history -->
  <div class="sa-card" id="inv-stats">
    <div class="sa-bar">
      <h3>&#128179; Invoice History</h3>
      <button class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px" onclick="toggleInvForm()">&#43; Add Invoice</button>
    </div>
    <div class="stat-chips">
      <div class="stat-box" style="background:#E8F5E9"><div class="stat-n" style="color:#2E7D32" id="s-paid">0</div><div class="stat-l">Paid</div></div>
      <div class="stat-box" style="background:#E3F2FD"><div class="stat-n" style="color:#1565C0" id="s-unpaid">0</div><div class="stat-l">Unpaid</div></div>
      <div class="stat-box" style="background:#FFEBEE"><div class="stat-n" style="color:#C62828" id="s-overdue">0</div><div class="stat-l">Overdue</div></div>
      <div class="stat-box" style="background:#f5f5f5"><div class="stat-n" style="color:#333" id="s-total">$0</div><div class="stat-l">Total Collected</div></div>
    </div>

    <!-- Add invoice form -->
    <div id="inv-form" class="inv-form">
      <div style="font-size:13px;font-weight:600;color:#1565C0;margin-bottom:10px">&#43; Add Invoice</div>
      <div class="inv-grid">
        <div class="sa-ff"><label>Period (Month) <span style="color:#C62828">*</span></label><input id="inv-period" type="month"/></div>
        <div class="sa-ff"><label>Amount (NZD) <span style="color:#C62828">*</span></label><input id="inv-amount" type="number" min="0" step="0.01" placeholder="e.g. 199.00"/></div>
        <div class="sa-ff"><label>Status</label>
          <select id="inv-status">
            <option value="unpaid">Unpaid</option>
            <option value="paid">Paid</option>
            <option value="overdue">Overdue</option>
          </select>
        </div>
        <div class="sa-ff"><label>Payment Reference <span style="color:#aaa;font-size:11px">optional</span></label><input id="inv-ref" placeholder="e.g. Bank transfer #1234"/></div>
      </div>
      <div class="sa-ff" style="margin-bottom:10px;max-width:400px">
        <label>Notes <span style="color:#aaa;font-size:11px">optional</span></label>
        <input id="inv-notes" placeholder="Any notes about this invoice"/>
      </div>
      <div style="display:flex;gap:8px;align-items:center">
        <button class="sa-btn sa-btn-p" onclick="addInvoice()">Save Invoice</button>
        <button class="sa-btn sa-btn-n" onclick="toggleInvForm()">Cancel</button>
        <span id="inv-msg" style="font-size:12.5px;color:#888"></span>
      </div>
    </div>

    <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead><tr>
        <th>Period</th><th>Amount</th><th>Status</th>
        <th>Paid Date</th><th>Reference</th><th>Notes</th><th>Actions</th>
      </tr></thead>
      <tbody id="inv-body">
        <tr><td colspan="7" style="text-align:center;padding:24px;color:#aaa">No invoices yet. Click "+ Add Invoice" to log the first month.</td></tr>
      </tbody>
    </table>
    </div>
  </div>

  <!-- Stripe Live Status Card -->
  <div class="sa-card">
    <div class="sa-bar" style="background:#635BFF"><h3>&#9889; Stripe Payments</h3>
      <span id="stripe-mode-badge" style="font-size:11px;background:rgba(255,255,255,.2);padding:2px 10px;border-radius:10px">Loading&hellip;</span>
    </div>
    <div style="padding:14px 18px">
      <p style="font-size:12.5px;color:#555;margin-bottom:12px">
        Click <strong style="color:#635BFF">&#9889; Stripe</strong> on any unpaid invoice to generate a secure Stripe Checkout payment link. The invoice auto-marks as paid once the card is charged.
      </p>
      <div id="stripe-recent" style="font-size:12px;color:#aaa">Loading recent payments&hellip;</div>
    </div>
  </div>

</div><!-- /view-company -->

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var cid = (new URLSearchParams(window.location.search)).get('cid') || '';
var companyData = {};
var allPackages = {};
var ovData = []; // overview data
var ovFilter = 'all';

/* ── Utilities ─────────────────────────────────────────────────────────────── */
function escHtml(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtMonth(m){ if(!m) return '—'; var p=m.split('-'); return new Date(+p[0],+p[1]-1,1).toLocaleDateString('en-NZ',{month:'long',year:'numeric'}); }
function fmtDate(d){ return d?new Date(d).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'}):'—'; }
function showNotice(msg,type){
  var el=document.getElementById('sa-notice');
  el.className='sa-notice '+(type||'ok'); el.textContent=msg; el.style.display='block';
  setTimeout(function(){ el.style.display='none'; },4000);
}

function getPackagePerCarRate(pkg){
  if(!pkg) return 0;
  var bt=pkg.billingType||'per_car_monthly';
  if(bt==='flat_monthly') return +(pkg.flatPrice||0);
  if(bt==='flat_annual') return +(pkg.flatPrice||0)/12;
  return +(pkg.pricePerCar||pkg.monthlyPrice||0);
}

function formatPackageOptionLabel(p){
  var bt=p.billingType||'per_car_monthly';
  if(bt==='flat_annual') return p.name+' — $'+(+(p.flatPrice||0)).toFixed(2)+'/yr';
  if(bt==='flat_monthly') return p.name+' — $'+(+(p.flatPrice||0)).toFixed(2)+'/mo';
  return p.name+' — $'+(+(p.pricePerCar||p.monthlyPrice||0)).toFixed(2)+'/car/mo';
}

function getPackageDefaultMonthlyFee(pkg, fleetSize){
  if(!pkg) return '';
  var bt=pkg.billingType||'per_car_monthly';
  var fleet=+(fleetSize||0);
  if(bt==='flat_annual') return ((+(pkg.flatPrice||0))/12).toFixed(2);
  if(bt==='flat_monthly') return +(pkg.flatPrice||0)||'';
  var ppc=+(pkg.pricePerCar||pkg.monthlyPrice||0);
  var monthly=fleet>0?ppc*fleet:ppc;
  var minM=+(pkg.minimumMonthly||0);
  return Math.max(monthly,minM)||'';
}

/* ── OVERVIEW MODE ─────────────────────────────────────────────────────────── */
function loadOverview(){
  document.getElementById('ov-loading').style.display='block';
  document.getElementById('ov-tbl').style.display='none';
  document.getElementById('ov-filter-bar').style.display='none';
  fetch('/api/admin/billing-overview')
    .then(function(r){ return r.json(); })
    .then(function(rows){
      ovData = rows || [];
      // Stats
      var totalOverdue=0, totalUnpaid=0, totalOutstanding=0, totalCollected=0;
      ovData.forEach(function(r){
        totalOverdue += r.overdue||0;
        totalUnpaid  += r.unpaid||0;
        totalOutstanding += r.outstanding||0;
        totalCollected   += r.collected||0;
      });
      document.getElementById('ov-overdue').textContent = totalOverdue;
      document.getElementById('ov-unpaid').textContent  = totalUnpaid;
      document.getElementById('ov-outstanding').textContent = '$'+totalOutstanding.toFixed(2);
      document.getElementById('ov-collected').textContent   = '$'+totalCollected.toFixed(2);
      document.getElementById('ov-loading').style.display='none';
      document.getElementById('ov-tbl').style.display='';
      document.getElementById('ov-filter-bar').style.display='flex';
      renderOverviewTable();
    })
    .catch(function(e){
      document.getElementById('ov-loading').textContent='Error loading billing data: '+String(e.message||e);
    });
}

function filterOverview(f){
  ovFilter = f;
  ['all','overdue','unpaid','ok'].forEach(function(k){
    var btn=document.getElementById('fil-'+k);
    if(btn) btn.className = k===f ? 'sa-btn sa-btn-p' : 'sa-btn sa-btn-n';
    if(btn) btn.style.fontSize='11px';
  });
  renderOverviewTable();
}

function renderOverviewTable(){
  var search = (document.getElementById('ov-search').value||'').toLowerCase();
  var rows = ovData.filter(function(r){
    if(!r.cid) return false;
    if(ovFilter==='overdue' && r.overdue===0) return false;
    if(ovFilter==='unpaid'  && r.unpaid===0)  return false;
    if(ovFilter==='ok'      && (r.overdue>0||r.unpaid>0)) return false;
    if(search && (r.name||'').toLowerCase().indexOf(search)===-1 && (r.cid||'').indexOf(search)===-1) return false;
    return true;
  });
  var tbody=document.getElementById('ov-body');
  if(!rows.length){
    tbody.innerHTML='<tr><td colspan="7" style="text-align:center;padding:24px;color:#aaa">No companies match this filter.</td></tr>';
    return;
  }
  var html='';
  rows.forEach(function(r){
    var cls = r.overdue>0?'row-overdue':r.unpaid>0?'row-unpaid':'';
    var latestBadge='<span class="badge" style="background:#f5f5f5;color:#aaa;border:1px solid #e0e0e0">No invoices</span>';
    if(r.latestInvoice){
      var st=r.latestInvoice.status;
      latestBadge = st==='paid'?'<span class="badge badge-paid">&#10003; Paid</span>'
        :st==='overdue'?'<span class="badge badge-overdue">&#9888; Overdue</span>'
        :'<span class="badge badge-unpaid">Unpaid</span>';
      latestBadge += ' <span style="font-size:11px;color:#aaa">'+fmtMonth(r.latestInvoice.period)+'</span>';
    }
    var statusBadge = r.status==='suspended'
      ? '<span class="badge badge-suspended">Suspended</span>'
      : '<span class="badge badge-active">Active</span>';
    var hasPending = r.overdue>0||r.unpaid>0;
    var reminderBtn = (hasPending && r.email)
      ? '<button onclick="sendOverviewReminder(\''+escAttr(r.cid)+'\',\''+escAttr(r.name)+'\',\''+escAttr(r.email)+'\')" class="sa-btn sa-btn-o" style="font-size:11px">&#9993; Remind</button> '
      : '';
    html += '<tr class="'+cls+'">' +
      '<td><a href="SA-Billing.aspx?cid='+escAttr(r.cid)+'" style="font-weight:700;color:#1565C0;text-decoration:none">'+escHtml(r.name)+'</a>' +
        ' <span class="cid-badge">'+escHtml(r.cid)+'</span>' +
        '<div style="margin-top:3px">'+statusBadge+'</div></td>' +
      '<td style="font-size:12px;color:#555">'+(r.plan?escHtml(r.plan):'<span style="color:#ccc">—</span>')+'</td>' +
      '<td style="font-weight:600">'+(r.monthlyFee?'$'+Number(r.monthlyFee).toFixed(2):'<span style="color:#ccc">—</span>')+'</td>' +
      '<td>'+latestBadge+'</td>' +
      '<td style="font-weight:700;color:'+(r.outstanding>0?'#C62828':'#aaa')+'">'+(r.outstanding>0?'$'+r.outstanding.toFixed(2):'$0.00')+'</td>' +
      '<td style="font-size:12px;color:#555">'+(r.nextDueDate?fmtDate(r.nextDueDate):'<span style="color:#ccc">—</span>')+'</td>' +
      '<td style="white-space:nowrap">' +
        reminderBtn +
        '<a href="SA-Billing.aspx?cid='+escAttr(r.cid)+'" class="sa-btn sa-btn-p" style="font-size:11px;text-decoration:none">&#128179; Manage</a>' +
      '</td>' +
    '</tr>';
  });
  tbody.innerHTML = html;
}

function escAttr(s){ return String(s||'').replace(/"/g,'&quot;').replace(/'/g,'&#39;'); }

function sendOverviewReminder(cid, name, email){
  if(!confirm('Send a billing reminder email to '+email+' for '+name+'?')) return;
  // Get the most recent unpaid/overdue invoice for this company
  _fbGet('superBilling/'+cid+'/invoices').then(function(invs){
    invs = invs||{};
    var pending = Object.entries(invs).filter(function(e){ return e[1].status!=='paid'; })
      .sort(function(a,b){ return (b[1].period||'').localeCompare(a[1].period||''); });
    if(!pending.length){ showNotice('No outstanding invoices for '+name,'warn'); return; }
    var inv = pending[0][1];
    sendReminder(cid, name, email, inv.period, inv.amount, inv.status);
  });
}

function sendReminder(cid, name, email, period, amount, status){
  fetch('/api/admin/send-billing-reminder',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({cid:cid, companyName:name, email:email, period:period, amount:amount, status:status})
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){
      toastr.success('Reminder sent to '+email);
      showNotice('Billing reminder sent to '+email,'ok');
    } else {
      toastr.error(d.error||'Failed to send');
      showNotice('Error: '+(d.error||'unknown'),'err');
    }
  }).catch(function(){ toastr.error('Network error'); });
}

/* ── SINGLE-COMPANY MODE ───────────────────────────────────────────────────── */
function showNotice2(msg,type){
  toastr[type==='err'?'error':type==='warn'?'warning':'success'](msg);
  showNotice(msg,type);
}

function setCompanyStatus(status){
  db.ref('superClients/'+cid+'/status').set(status).then(function(){
    showNotice('Company status set to '+status,'ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function renderCompany(c){
  companyData=c||{};
  document.getElementById('co-cid').textContent=cid;
  document.getElementById('co-name').textContent=c.name||cid;
  document.getElementById('co-meta').textContent=(c.city?c.city+', ':'')+(c.country||'')+(c.contactEmail?' · '+c.contactEmail:'');
  document.getElementById('link-company').href='SA-Company.aspx?cid='+cid;
  document.getElementById('link-email').href='SA-Email.aspx?cid='+cid;
  var isSuspended=c.status==='suspended';
  document.getElementById('co-status-badge').innerHTML=isSuspended
    ?'<span class="badge badge-suspended">Suspended</span>'
    :'<span class="badge badge-active">Active</span>';
  document.getElementById('btn-activate').style.display=isSuspended?'':'none';
  document.getElementById('btn-suspend').style.display=isSuspended?'none':'';
  document.getElementById('page-title-lbl').textContent=(c.name||cid)+' Billing — BookaWaka Admin';
  renderPlanCompliance();
}

function renderPlanCompliance(){
  var c = companyData;
  var card = document.getElementById('plan-compliance-card');
  var body = document.getElementById('plan-compliance-body');
  var badge = document.getElementById('plan-compliance-badge');
  if(!c || !Object.keys(c).length || !Object.keys(allPackages).length){ card.style.display='none'; return; }

  var pkgId = c.packageId;
  var pkg = pkgId ? allPackages[pkgId] : null;

  if(!pkg){
    card.style.display='';
    badge.textContent='No Plan Assigned';
    badge.style.background='rgba(230,81,0,.3)';
    body.innerHTML='<div style="color:#E65100;font-size:13px;font-weight:600">&#9888; This company has no subscription package assigned.<br><span style="font-weight:400;color:#888">Use the form above to assign a plan, then generate their first invoice.</span></div>';
    return;
  }

  var mods = [
    {key:'taxi',    label:'Taxi',           icon:'&#128663;'},
    {key:'food',    label:'Food Delivery',  icon:'&#127829;'},
    {key:'freight', label:'Freight',        icon:'&#128230;'}
  ];

  var overPlan = mods.filter(function(m){ return c.modules && c.modules[m.key] && !(pkg.modules && pkg.modules[m.key]); });
  var inPlan   = mods.filter(function(m){ return pkg.modules && pkg.modules[m.key]; });

  var statusOk = !overPlan.length;
  badge.textContent = statusOk ? 'Compliant' : 'Over Plan';
  badge.style.background = statusOk ? 'rgba(46,125,50,.4)' : 'rgba(198,40,40,.4)';

  var ppc  = +(pkg.pricePerCar || pkg.monthlyPrice || 0);
  var minM = +(pkg.minimumMonthly || 0);

  var pricingHtml =
    '<div style="min-width:180px">' +
      '<div style="font-size:11px;font-weight:700;color:#607D8B;text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px">Pricing</div>' +
      '<div style="font-size:20px;font-weight:700;color:#1565C0">' + (ppc ? '$'+ppc.toFixed(2) : '—') + '<span style="font-size:13px;font-weight:400;color:#888"> /car/mo</span></div>' +
      (minM ? '<div style="font-size:12px;color:#888;margin-top:2px">Min. $'+minM.toFixed(0)+'/month</div>' : '') +
      (pkg.trialDays ? '<div style="font-size:12px;color:#E65100;margin-top:2px">&#9201; '+pkg.trialDays+'-day trial</div>' : '') +
    '</div>';

  var modRows = mods.map(function(m){
    var inPkg = pkg.modules && pkg.modules[m.key];
    var coHas = c.modules && c.modules[m.key];
    var status, statusStyle;
    if (inPkg && coHas)  { status='Included & enabled';   statusStyle='color:#2E7D32;font-weight:600'; }
    else if (inPkg)      { status='In plan, not enabled'; statusStyle='color:#888'; }
    else if (coHas)      { status='Enabled — NOT in plan';statusStyle='color:#C62828;font-weight:700'; }
    else                 { status='Not applicable';       statusStyle='color:#ccc'; }
    return '<tr>' +
      '<td style="padding:6px 10px 6px 0;font-size:13px">'+m.icon+' '+m.label+'</td>' +
      '<td style="padding:6px 8px;font-size:13px;'+statusStyle+'">'+status+'</td>' +
      '</tr>';
  }).join('');

  var modulesHtml =
    '<div style="min-width:260px">' +
      '<div style="font-size:11px;font-weight:700;color:#607D8B;text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px">Module Compliance</div>' +
      '<table style="border-collapse:collapse;font-size:12.5px"><tbody>' + modRows + '</tbody></table>' +
    '</div>';

  var overHtml = overPlan.length
    ? '<div style="background:#FFEBEE;border:1px solid #FFCDD2;border-radius:8px;padding:12px 16px;min-width:220px">' +
        '<div style="font-size:12px;font-weight:700;color:#C62828;margin-bottom:4px">&#9888; Plan Overage</div>' +
        '<div style="font-size:12px;color:#555">The following modules are <strong>enabled</strong> on this company but are <strong>not included</strong> in their plan:</div>' +
        '<ul style="margin:8px 0 0;padding-left:18px;font-size:12px;color:#C62828">' +
          overPlan.map(function(m){ return '<li>'+m.icon+' '+m.label+'</li>'; }).join('') +
        '</ul>' +
        '<div style="font-size:11.5px;color:#888;margin-top:6px">Consider upgrading their plan or disabling these modules in All Companies.</div>' +
      '</div>'
    : '';

  body.innerHTML = pricingHtml + modulesHtml + overHtml;
  card.style.display = '';
}

function toggleInvForm(){
  var f=document.getElementById('inv-form');
  f.classList.toggle('open');
  document.getElementById('inv-msg').textContent='';
  if(f.classList.contains('open')){
    var now=new Date();
    document.getElementById('inv-period').value=now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0');
    var fee=document.getElementById('pkg-fee').value;
    if(fee && !document.getElementById('inv-amount').value) document.getElementById('inv-amount').value=fee;
  }
}

function generateInvoice(){
  var fee=document.getElementById('pkg-fee').value;
  if(!fee){ showNotice('Set a monthly fee above first, then save the package before generating an invoice.','warn'); return; }
  var f=document.getElementById('inv-form');
  if(!f.classList.contains('open')) f.classList.add('open');
  var now=new Date();
  document.getElementById('inv-period').value=now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0');
  document.getElementById('inv-amount').value=fee;
  document.getElementById('inv-status').value='unpaid';
  document.getElementById('inv-msg').textContent='';
  document.getElementById('inv-period').scrollIntoView({behavior:'smooth',block:'nearest'});
}

function renderPackageOptions(pkgs, currentPkgId){
  var sel=document.getElementById('pkg-sel');
  sel.innerHTML='<option value="">-- no package assigned --</option>';
  Object.keys(pkgs).sort(function(a,b){ return (pkgs[a].sortOrder||99)-(pkgs[b].sortOrder||99); }).forEach(function(id){
    var p=pkgs[id];
    if(p.active===false) return;
    var opt=document.createElement('option');
    opt.value=id;
    opt.textContent=formatPackageOptionLabel(p);
    if(id===currentPkgId) opt.selected=true;
    sel.appendChild(opt);
  });
  var fleetSize=companyData&&(companyData.fleetSize||companyData.fleet||0);
  sel.onchange=function(){
    var pid=sel.value;
    if(pid && pkgs[pid]) document.getElementById('pkg-fee').value=getPackageDefaultMonthlyFee(pkgs[pid], fleetSize);
  };
}

function savePackageAssign(){
  var pkgId=document.getElementById('pkg-sel').value;
  var fee=+(document.getElementById('pkg-fee').value||0);
  var start=document.getElementById('pkg-start').value;
  var due=document.getElementById('pkg-due').value;
  var pkg=pkgId&&allPackages[pkgId]?allPackages[pkgId]:null;
  var pkgName=pkg?pkg.name:'';
  var monthlyRate=pkg?getPackagePerCarRate(pkg):null;
  updateCompanyPlan(cid,{
    packageId:pkgId||null,
    packageName:pkgName,
    packageMeta:pkg,
    monthlyRate:monthlyRate,
    monthlyFee:fee||null,
    billingStartDate:start||null,
    nextDueDate:due||null,
    clearTrial:!!(pkg&&!pkg.trialDays&&pkgId!=='pkg_trial')
  }).then(function(){
    var msg=document.getElementById('pkg-msg');
    msg.style.color='#2E7D32'; msg.textContent='&#10003; Package saved across all billing nodes';
    if(companyData){
      companyData.packageId=pkgId||null;
      companyData.packageName=pkgName;
      companyData.status=(pkg&&!pkg.trialDays&&pkgId!=='pkg_trial')?'active':'trial';
    }
    console.log('[Billing] updateCompanyPlan', { companyId: cid, plan: pkgName, packageId: pkgId });
    setTimeout(function(){ msg.textContent=''; },3000);
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function addInvoice(){
  var period=document.getElementById('inv-period').value;
  var amount=+(document.getElementById('inv-amount').value||0);
  if(!period||!amount){ document.getElementById('inv-msg').textContent='Period and Amount are required.'; return; }
  var status=document.getElementById('inv-status').value;
  var ref=document.getElementById('inv-ref').value.trim();
  var notes=document.getElementById('inv-notes').value.trim();
  var invId='inv_'+period.replace('-','')+'_'+Date.now();
  db.ref('superBilling/'+cid+'/invoices/'+invId).set({
    period:period, amount:amount, status:status,
    paidDate:status==='paid'?new Date().toISOString().split('T')[0]:null,
    paidRef:ref||null, notes:notes||null,
    createdAt:new Date().toISOString()
  }).then(function(){
    showNotice('Invoice for '+fmtMonth(period)+' added.','ok');
    toggleInvForm();
    ['inv-amount','inv-ref','inv-notes'].forEach(function(i){ document.getElementById(i).value=''; });
    document.getElementById('inv-status').value='unpaid';
  }).catch(function(e){ document.getElementById('inv-msg').textContent='Error: '+e.message; });
}

function updateInvStatus(invId, status){
  var upd={status:status};
  if(status==='paid') upd.paidDate=new Date().toISOString().split('T')[0];
  db.ref('superBilling/'+cid+'/invoices/'+invId).update(upd).then(function(){
    showNotice('Invoice updated to '+status,'ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

var _markPaidInvId=null;
function openMarkPaidModal(invId, period, amount){
  _markPaidInvId=invId;
  document.getElementById('mp-period').textContent=fmtMonth(period)+' — $'+Number(amount||0).toFixed(2);
  document.getElementById('mp-date').value=new Date().toISOString().slice(0,10);
  document.getElementById('mp-ref').value='';
  document.getElementById('mp-notes').value='';
  document.getElementById('mp-msg').textContent='';
  document.getElementById('mp-btn').disabled=false;
  document.getElementById('modal-mark-paid').style.display='flex';
}
function closeMarkPaidModal(){ document.getElementById('modal-mark-paid').style.display='none'; _markPaidInvId=null; }
function confirmMarkPaid(){
  if(!_markPaidInvId) return;
  var date=document.getElementById('mp-date').value;
  var ref=document.getElementById('mp-ref').value.trim();
  var notes=document.getElementById('mp-notes').value.trim();
  var btn=document.getElementById('mp-btn');
  btn.disabled=true; btn.textContent='Saving…';
  var upd={status:'paid',paidDate:date||new Date().toISOString().slice(0,10)};
  if(ref) upd.paidRef=ref;
  if(notes) upd.notes=notes;
  db.ref('superBilling/'+cid+'/invoices/'+_markPaidInvId).update(upd).then(function(){
    var ts=Date.now(); var rand=Math.random().toString(36).substr(2,5);
    db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:'invoice_marked_paid',actor:(firebase.auth().currentUser||{}).email||'sa',cid:cid,cidName:companyData.name||cid,detail:'Invoice marked paid'+(ref?' — Ref: '+ref:'')+'  '+document.getElementById('mp-period').textContent,ts:ts});
    closeMarkPaidModal();
    showNotice('Invoice marked as paid.','ok');
    btn.textContent='&#10003; Mark Paid';
  }).catch(function(e){ document.getElementById('mp-msg').textContent='Error: '+(e.message||e); btn.disabled=false; btn.textContent='&#10003; Mark Paid'; });
}

/* ── Overdue bulk reminder ─────────────────────────────────────────────────── */
function sendAllOverdueReminders(){
  var overdueRows=ovData.filter(function(r){ return r.overdue>0 && r.email; });
  if(!overdueRows.length){ showNotice('No overdue companies with an email on file.','warn'); return; }
  if(!confirm('Send overdue billing reminders to '+overdueRows.length+' compan'+(overdueRows.length!==1?'ies':'y')+'?')) return;
  var sent=0, failed=0;
  function next(i){
    if(i>=overdueRows.length){
      showNotice('Reminders sent: '+sent+(failed?' | '+failed+' failed':''),'ok');
      return;
    }
    var r=overdueRows[i];
    _fbGet('superBilling/'+r.cid+'/invoices').then(function(invs){
      invs=invs||{};
      var od=Object.entries(invs).filter(function(e){ return e[1].status==='overdue'||e[1].status==='unpaid'; })
        .sort(function(a,b){ return (b[1].period||'').localeCompare(a[1].period||''); });
      if(!od.length){ next(i+1); return; }
      var inv=od[0][1];
      sendReminder(r.cid, r.name, r.email, inv.period, inv.amount, inv.status);
      sent++;
      setTimeout(function(){ next(i+1); }, 400);
    }).catch(function(){ failed++; next(i+1); });
  }
  next(0);
}

/* ── Auto-mark overdue ───────────────────────────── */
function autoMarkOverdue(){
  if(!confirm('Scan all unpaid invoices and mark those past their due date as overdue?')) return;
  fetch('/api/admin/mark-overdue-invoices',{method:'POST',headers:{'Content-Type':'application/json'}})
    .then(function(r){return r.json();})
    .then(function(d){
      if(d.error){ showNotice('Error: '+d.error,'err'); return; }
      if(d.marked===0){ showNotice('No invoices needed marking — all up to date.','warn'); return; }
      showNotice('&#10003; Marked '+d.marked+' invoice'+(d.marked!==1?'s':'')+' as overdue.','ok');
      loadOverview();
    }).catch(function(e){ showNotice('Network error: '+e.message,'err'); });
}

/* ── Send formal invoice email ───────────────────── */
function sendInvoiceEmail(invId, period, amount, status){
  var email=(companyData&&companyData.email)||'';
  if(!email){ showNotice('No email address on file for this company.','err'); return; }
  if(!confirm('Send formal invoice email for '+fmtMonth(period)+' ($'+Number(amount).toFixed(2)+') to '+email+'?')) return;
  fetch('/api/admin/send-invoice',{
    method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({cid:cid,companyName:companyData.name||cid,email:email,period:period,amount:amount,status:status,invoiceId:invId})
  }).then(function(r){return r.json();})
    .then(function(d){
      if(d.error){ showNotice('Error: '+d.error,'err'); return; }
      showNotice('Invoice sent to '+email,'ok');
    }).catch(function(e){ showNotice('Network error: '+e.message,'err'); });
}

/* ── Print / PDF invoice ─────────────────────────── */
function printInvoice(invId, period, amount){
  var cname=(companyData&&companyData.name)||cid;
  var periodLabel=fmtMonth(period);
  var w=window.open('','_blank','width=800,height=700');
  w.document.write('<!DOCTYPE html><html><head><meta charset="utf-8"><title>Invoice '+period+'</title><style>'
    +'body{font-family:Arial,sans-serif;margin:0;padding:30px;color:#263238}'
    +'.hdr{background:#1565C0;color:#fff;padding:24px 28px;border-radius:8px 8px 0 0}'
    +'.hdr h1{margin:0;font-size:22px}  .hdr p{margin:4px 0 0;opacity:.8;font-size:13px}'
    +'.body{padding:24px 28px;border:1px solid #e0e0e0;border-top:none;border-radius:0 0 8px 8px}'
    +'.meta{display:flex;justify-content:space-between;margin-bottom:20px}'
    +'.meta-block .label{font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:#aaa;font-weight:700;margin-bottom:3px}'
    +'.meta-block .val{font-size:14px;font-weight:700}'
    +'table{width:100%;border-collapse:collapse;font-size:14px;margin-bottom:20px}'
    +'th{background:#E3F2FD;padding:10px 12px;text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:#0D47A1}'
    +'td{padding:12px;border-bottom:1px solid #f0f0f0}'
    +'.total-row td{font-weight:700;background:#f8f9fa;font-size:17px;color:#1565C0}'
    +'.footer{margin-top:20px;font-size:11px;color:#aaa;text-align:center}'
    +'@media print{button{display:none}}'
    +'</style></head><body>'
    +'<div class="hdr"><h1>&#128179; TAX INVOICE</h1><p>BookaWaka Platform</p></div>'
    +'<div class="body">'
    +'<div class="meta">'
    +'<div class="meta-block"><div class="label">Billed To</div><div class="val">'+cname+'</div><div style="font-size:12px;color:#888">Company ID: '+cid+'</div></div>'
    +'<div class="meta-block" style="text-align:right"><div class="label">Invoice Date</div><div class="val">'+new Date().toLocaleDateString('en-NZ',{day:'numeric',month:'long',year:'numeric'})+'</div></div>'
    +'</div>'
    +'<table><thead><tr><th>Description</th><th>Period</th><th style="text-align:right">Amount (NZD)</th></tr></thead>'
    +'<tbody>'
    +'<tr><td>BookaWaka SaaS Subscription</td><td>'+periodLabel+'</td><td style="text-align:right;font-weight:700">$'+Number(amount).toFixed(2)+'</td></tr>'
    +'</tbody>'
    +'<tfoot><tr class="total-row"><td colspan="2" style="text-align:right">Total Due</td><td style="text-align:right">$'+Number(amount).toFixed(2)+' NZD</td></tr></tfoot>'
    +'</table>'
    +'<div class="footer">BookaWaka &bull; bookawaka.co.nz &bull; Invoice ID: '+invId+'</div>'
    +'<div style="text-align:center;margin-top:16px"><button onclick="window.print()" style="padding:10px 24px;background:#1565C0;color:#fff;border:none;border-radius:6px;font-size:14px;cursor:pointer">Print / Save as PDF</button></div>'
    +'</div></body></html>');
  w.document.close();
}

function deleteInvoice(invId){
  if(!confirm('Delete this invoice?')) return;
  db.ref('superBilling/'+cid+'/invoices/'+invId).remove().then(function(){
    showNotice('Invoice deleted.','ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

/* ── Stripe functions ─────────────────────────────── */
function stripeChargeInvoice(invId, period, amount){
  if(!cid){ showNotice('No company selected.','warn'); return; }
  var email=(companyData&&companyData.contactEmail)||'';
  var name=(companyData&&companyData.name)||cid;
  if(!amount||amount<=0){ showNotice('Invoice amount must be greater than zero.','warn'); return; }
  if(!confirm('Generate a Stripe payment link for $'+Number(amount).toFixed(2)+' NZD?\n\nThis will open the Stripe Checkout page in a new tab. Once paid, the invoice will auto-update to Paid.')){return;}
  showNotice('Creating Stripe payment link…','ok');
  fetch('/api/stripe/create-invoice-checkout',{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({cid:cid,invoiceId:invId,companyName:name,email:email,period:period,amount:amount})
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok&&d.url){
      showNotice('Stripe link created! Opening payment page…','ok');
      window.open(d.url,'_blank');
    } else {
      showNotice('Stripe error: '+(d.error||'Unknown error'),'err');
    }
  }).catch(function(e){ showNotice('Network error: '+e.message,'err'); });
}

function loadStripeStatus(){
  fetch('/api/stripe/config').then(function(r){ return r.json(); }).then(function(d){
    var badge=document.getElementById('stripe-mode-badge');
    if(badge) badge.textContent = d.mode==='test' ? '🧪 TEST MODE' : '✅ LIVE MODE';
  }).catch(function(){});

  fetch('/api/stripe/recent-payments').then(function(r){ return r.json(); }).then(function(d){
    var el=document.getElementById('stripe-recent');
    if(!el) return;
    if(!d.payments||!d.payments.length){ el.textContent='No Stripe payments yet.'; return; }
    var rows=d.payments.slice(0,8).map(function(p){
      var badge=p.status==='paid'
        ?'<span style="background:#E8F5E9;color:#2E7D32;padding:1px 7px;border-radius:8px;font-size:11px;font-weight:700">&#10003; Paid</span>'
        :'<span style="background:#FFF8E1;color:#F57F17;padding:1px 7px;border-radius:8px;font-size:11px;font-weight:700">'+p.status+'</span>';
      var co=(p.metadata&&p.metadata.companyName)||'—';
      var dt=new Date(p.created*1000).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'});
      return '<tr>'
        +'<td style="padding:5px 8px;font-size:12px;color:#263238">'+escHtml(co)+'</td>'
        +'<td style="padding:5px 8px;font-weight:700">$'+p.amount+' '+p.currency.toUpperCase()+'</td>'
        +'<td style="padding:5px 8px">'+badge+'</td>'
        +'<td style="padding:5px 8px;font-size:11px;color:#aaa">'+dt+'</td>'
        +'<td style="padding:5px 8px;font-size:11px;color:#aaa;font-family:monospace">'+p.id.slice(-12)+'</td>'
        +'</tr>';
    }).join('');
    el.innerHTML='<table style="width:100%;border-collapse:collapse"><thead><tr>'
      +'<th style="text-align:left;padding:4px 8px;font-size:11px;color:#888;font-weight:700">Company</th>'
      +'<th style="text-align:left;padding:4px 8px;font-size:11px;color:#888;font-weight:700">Amount</th>'
      +'<th style="text-align:left;padding:4px 8px;font-size:11px;color:#888;font-weight:700">Status</th>'
      +'<th style="text-align:left;padding:4px 8px;font-size:11px;color:#888;font-weight:700">Date</th>'
      +'<th style="text-align:left;padding:4px 8px;font-size:11px;color:#888;font-weight:700">Session</th>'
      +'</tr></thead><tbody>'+rows+'</tbody></table>';
  }).catch(function(e){ var el=document.getElementById('stripe-recent'); if(el) el.textContent='Could not load Stripe data: '+e.message; });
}

/* Check URL for stripe redirect result */
(function(){
  var params=new URLSearchParams(window.location.search);
  if(params.get('stripe')==='success'){
    var inv=params.get('inv');
    showNotice('&#9889; Stripe payment completed! Invoice '+inv+' has been marked as paid.','ok');
    window.history.replaceState({},document.title,window.location.pathname+'?cid='+params.get('cid'));
  }
  if(params.get('stripe')==='cancel'){
    showNotice('Stripe payment was cancelled. The invoice remains unpaid.','warn');
    window.history.replaceState({},document.title,window.location.pathname+'?cid='+params.get('cid'));
  }
})();

function sendInvoiceReminder(invId, period, amount, status){
  var email=(companyData.contactEmail||companyData.email||'').trim();
  var name=companyData.name||cid;
  if(!email){ showNotice('No email on file for this company. Add it in Company Details first.','warn'); return; }
  if(!confirm('Send a billing reminder to '+email+' for '+fmtMonth(period)+'?')) return;
  sendReminder(cid, name, email, period, amount, status);
}

function renderInvoices(data){
  var tbody=document.getElementById('inv-body');
  if(!data){
    tbody.innerHTML='<tr><td colspan="7" style="text-align:center;padding:24px;color:#aaa">No invoices yet. Click "+ Add Invoice" to log the first month.</td></tr>';
    updateStats({});
    return;
  }
  updateStats(data);
  var rows='';
  Object.keys(data).sort(function(a,b){ return (data[b].period||'').localeCompare(data[a].period||''); }).forEach(function(id){
    var inv=data[id];
    var statusBadge=inv.status==='paid'?'<span class="badge badge-paid">&#10003; Paid</span>'
      :inv.status==='overdue'?'<span class="badge badge-overdue">&#9888; Overdue</span>'
      :'<span class="badge badge-unpaid">Unpaid</span>';
    var actions='';
    if(inv.status!=='paid')    actions+='<button class="sa-btn sa-btn-s" style="font-size:10px" onclick="openMarkPaidModal(\''+id+'\',\''+escAttr(inv.period||'')+'\','+Number(inv.amount||0)+')">&#10003; Mark Paid</button> ';
    if(inv.status!=='paid')    actions+='<button class="sa-btn" style="font-size:10px;background:#635BFF;color:#fff;border:none" onclick="stripeChargeInvoice(\''+id+'\',\''+escAttr(inv.period||'')+'\','+Number(inv.amount||0)+')" title="Collect payment via Stripe">&#9889; Stripe</button> ';
    if(inv.status!=='overdue') actions+='<button class="sa-btn sa-btn-d" style="font-size:10px" onclick="updateInvStatus(\''+id+'\',\'overdue\')">Overdue</button> ';
    if(inv.status!=='unpaid')  actions+='<button class="sa-btn sa-btn-n" style="font-size:10px" onclick="updateInvStatus(\''+id+'\',\'unpaid\')">Unpaid</button> ';
    if(inv.status!=='paid')    actions+='<button class="sa-btn sa-btn-o" style="font-size:10px" onclick="sendInvoiceReminder(\''+id+'\',\''+escAttr(inv.period||'')+'\','+Number(inv.amount||0)+',\''+escAttr(inv.status||'')+'\')">&#9993; Remind</button> ';
    actions+='<button class="sa-btn sa-btn-n" style="font-size:10px;background:#E3F2FD;color:#1565C0;border-color:#BBDEFB" onclick="sendInvoiceEmail(\''+id+'\',\''+escAttr(inv.period||'')+'\','+Number(inv.amount||0)+',\''+escAttr(inv.status||'')+'\')" title="Send formal invoice email">&#128179; Invoice</button> ';
    actions+='<button class="sa-btn sa-btn-n" style="font-size:10px" onclick="printInvoice(\''+id+'\',\''+escAttr(inv.period||'')+'\','+Number(inv.amount||0)+')" title="Print / save as PDF">&#128438; Print</button> ';
    actions+='<button class="sa-btn sa-btn-n" style="font-size:10px;color:#C62828" onclick="deleteInvoice(\''+id+'\')">&#128465;</button>';
    var rowCls = inv.status==='overdue'?'row-overdue':inv.status==='unpaid'?'row-unpaid':'';
    rows+='<tr class="'+rowCls+'">' +
      '<td style="font-weight:600">'+fmtMonth(inv.period||'')+'</td>' +
      '<td style="font-weight:700">$'+Number(inv.amount||0).toFixed(2)+'</td>' +
      '<td>'+statusBadge+'</td>' +
      '<td style="font-size:12px;color:#555">'+fmtDate(inv.paidDate)+'</td>' +
      '<td style="font-size:12px;color:#555">'+escHtml(inv.paidRef||'—')+'</td>' +
      '<td style="font-size:12px;color:#888;max-width:150px">'+escHtml(inv.notes||'')+'</td>' +
      '<td style="white-space:nowrap">'+actions+'</td>' +
    '</tr>';
  });
  tbody.innerHTML=rows||'<tr><td colspan="7" style="text-align:center;padding:24px;color:#aaa">No invoices.</td></tr>';
}

function updateStats(data){
  var paid=0,unpaid=0,overdue=0,total=0;
  Object.values(data||{}).forEach(function(inv){
    if(inv.status==='paid'){ paid++; total+=+(inv.amount||0); }
    else if(inv.status==='overdue') overdue++;
    else unpaid++;
  });
  document.getElementById('s-paid').textContent=paid;
  document.getElementById('s-unpaid').textContent=unpaid;
  document.getElementById('s-overdue').textContent=overdue;
  document.getElementById('s-total').textContent='$'+total.toFixed(2);
}

/* ── Batch Email Helper ──────────────────────────── */
function sendBatchInvoiceEmails(period, clients, billing){
  var companies=Object.entries(clients).filter(function(e){
    var cid=e[0], c=e[1];
    if(c.status==='suspended'||c.status==='rejected') return false;
    var email=c.email||c.contactEmail;
    if(!email) return false;
    var invoices=(billing[cid]&&billing[cid].invoices)||{};
    return Object.values(invoices).some(function(inv){ return inv.period===period; });
  });
  var sent=0, failed=0;
  function next(i){
    if(i>=companies.length){
      showNotice('Invoice emails: '+sent+' sent'+(failed?' ('+failed+' failed)':''), failed?'warn':'ok');
      return;
    }
    var cid=companies[i][0], c=companies[i][1];
    var email=c.email||c.contactEmail;
    var invoices=(billing[cid]&&billing[cid].invoices)||{};
    var inv=Object.values(invoices).find(function(inv){ return inv.period===period; })||{};
    fetch('/api/admin/send-invoice',{
      method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({cid:cid,companyName:c.name||cid,email:email,period:period,amount:inv.amount||0,status:inv.status||'unpaid'})
    }).then(function(r){return r.json();}).then(function(d){
      if(d.ok) sent++; else failed++;
      next(i+1);
    }).catch(function(){ failed++; next(i+1); });
  }
  next(0);
}

/* ── Batch Invoice Generation ─────────────────────────────────────────────── */
var allBillingClients = {};
function openBatchModal(){
  document.getElementById('modal-batch').style.display='flex';
  document.getElementById('batch-result').style.display='none';
  document.getElementById('batch-result').innerHTML='';
  document.getElementById('batch-confirm-btn').disabled=false;
  document.getElementById('batch-confirm-btn').textContent='⚡ Generate Invoices';
  // Set default period to current month
  var now=new Date();
  document.getElementById('batch-period').value=now.getFullYear()+'-'+(String(now.getMonth()+1).padStart(2,'0'));
  document.getElementById('batch-amount').value='';
  document.getElementById('batch-skip-existing').checked=true;
}
function closeBatchModal(){ document.getElementById('modal-batch').style.display='none'; }
function confirmBatch(){
  var period=document.getElementById('batch-period').value;
  if(!period){ alert('Select a billing period'); return; }
  var fixedAmt=+(document.getElementById('batch-amount').value||0);
  var skipExisting=document.getElementById('batch-skip-existing').checked;
  var btn=document.getElementById('batch-confirm-btn');
  btn.disabled=true; btn.textContent='Generating…';
  var resultEl=document.getElementById('batch-result');
  // Load all clients and their billing info
  Promise.all([
    _fbGet('superClients'),
    _fbGet('superBilling')
  ]).then(function(results){
    var clients=results[0]||{};
    var billing=results[1]||{};
    var writes=[], skipped=0, created=0, noFee=0;
    Object.entries(clients).forEach(function(entry){
      var cid=entry[0], c=entry[1];
      if(c.status==='suspended'||c.status==='rejected') return;
      var info=(billing[cid]&&billing[cid].info)||{};
      var amount=fixedAmt>0?fixedAmt:+(info.monthlyFee||0);
      if(!amount){ noFee++; return; }
      // Check if invoice already exists for this period
      var invoices=(billing[cid]&&billing[cid].invoices)||{};
      var existsForPeriod=Object.values(invoices).some(function(inv){ return inv.period===period; });
      if(existsForPeriod&&skipExisting){ skipped++; return; }
      var invId='inv_'+period.replace('-','')+'_'+Date.now()+'_'+Math.random().toString(36).substr(2,4);
      writes.push(db.ref('superBilling/'+cid+'/invoices/'+invId).set({period:period,amount:amount,status:'unpaid',createdAt:new Date().toISOString(),batchGenerated:true}));
      created++;
    });
    var emailAfter=document.getElementById('batch-email-companies').checked;
    return Promise.all(writes).then(function(){
      resultEl.style.display='block';
      resultEl.className='sa-notice ok';
      resultEl.innerHTML='<strong>&#10003; Done.</strong> Created <strong>'+created+'</strong> invoice'+(created!==1?'s':'')+' for <strong>'+fmtMonth(period)+'</strong>.'+
        (skipped?' <span style="color:#555">'+skipped+' skipped (already had invoice).</span>':'')+
        (noFee?' <span style="color:#aaa">'+noFee+' skipped (no monthly fee set).</span>':'');
      btn.disabled=false; btn.textContent='⚡ Generate Invoices';
      loadOverview();
      if(emailAfter && created>0){
        resultEl.innerHTML+=' <span style="color:#1565C0">Sending invoice emails&hellip;</span>';
        sendBatchInvoiceEmails(period, clients, billing);
      }
    });
  }).catch(function(e){
    resultEl.style.display='block';
    resultEl.className='sa-notice err';
    resultEl.textContent='Error: '+String(e.message||e);
    btn.disabled=false; btn.textContent='⚡ Generate Invoices';
  });
}

/* ── Init ──────────────────────────────────────────────────────────────────── */
window._fbOnLogin = function(){
  loadStripeStatus();
  if(!cid){
    document.getElementById('view-overview').style.display='';
    loadOverview();
    return;
  }

  document.getElementById('view-company').style.display='';

  _fbGet('superClients/'+cid).then(function(data){
    if(!data){ showNotice('Company "'+cid+'" not found.','err'); return; }
    renderCompany(data);
  });

  _fbGet('superPackages').then(function(data){
    allPackages=data||{};
    renderPlanCompliance();
    Promise.all([
      _fbGet('superBilling/'+cid+'/info'),
      _fbGet('companySettings/'+cid)
    ]).then(function(results){
      var info=results[0]||{};
      var settings=results[1]||{};
      var csBilling=settings.billing||{};
      var pkgId=info.packageId||csBilling.packageId||'';
      if(!pkgId && typeof settings.plan==='string'){
        Object.keys(allPackages).forEach(function(pid){
          if(allPackages[pid].name===settings.plan) pkgId=pid;
        });
      }
      renderPackageOptions(allPackages, pkgId);
      if(info.monthlyFee) document.getElementById('pkg-fee').value=info.monthlyFee;
      else if(csBilling.monthlyRate && companyData){
        var fleet=+(companyData.fleetSize||companyData.fleet||0);
        document.getElementById('pkg-fee').value=fleet>0?csBilling.monthlyRate*fleet:csBilling.monthlyRate;
      }
      if(info.startDate||csBilling.billingStartDate) document.getElementById('pkg-start').value=info.startDate||csBilling.billingStartDate;
      if(info.nextDueDate||csBilling.nextDueDate) document.getElementById('pkg-due').value=info.nextDueDate||csBilling.nextDueDate;
    });
  });

  _fbGet('superBilling/'+cid+'/invoices').then(function(data){ renderInvoices(data); });
};
</script>

<!-- Mark Paid Modal -->
<div id="modal-mark-paid" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9999;align-items:center;justify-content:center;padding:20px">
  <div style="background:#fff;border-radius:10px;padding:28px;max-width:420px;width:100%;box-shadow:0 8px 30px rgba(0,0,0,.25)">
    <h3 style="font-size:16px;font-weight:700;color:#2E7D32;margin-bottom:10px">&#10003; Mark Invoice Paid</h3>
    <div id="mp-period" style="font-weight:700;font-size:14px;padding:10px 14px;background:#E8F5E9;border:1px solid #A5D6A7;border-radius:8px;margin-bottom:16px"></div>
    <div style="display:grid;gap:12px;margin-bottom:16px">
      <div>
        <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:5px">Payment Date <span style="color:#C62828">*</span></label>
        <input id="mp-date" type="date" style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:5px">Payment Reference <span style="color:#aaa;font-weight:400">(optional)</span></label>
        <input id="mp-ref" type="text" placeholder="e.g. Bank transfer #1234 / Stripe ch_xxx" style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:5px">Notes <span style="color:#aaa;font-weight:400">(optional)</span></label>
        <input id="mp-notes" type="text" placeholder="e.g. Partial payment, balance due next month" style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/>
      </div>
    </div>
    <div id="mp-msg" style="font-size:12px;color:#C62828;margin-bottom:8px"></div>
    <div style="display:flex;gap:8px;justify-content:flex-end">
      <button onclick="closeMarkPaidModal()" class="sa-btn sa-btn-n">Cancel</button>
      <button id="mp-btn" onclick="confirmMarkPaid()" class="sa-btn sa-btn-s" style="font-weight:700">&#10003; Mark Paid</button>
    </div>
  </div>
</div>

<!-- Batch Invoice Modal -->
<div id="modal-batch" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9999;align-items:center;justify-content:center;padding:20px">
  <div style="background:#fff;border-radius:10px;padding:28px;max-width:480px;width:100%;box-shadow:0 8px 30px rgba(0,0,0,.25)">
    <h3 style="font-size:16px;font-weight:700;color:#1565C0;margin-bottom:16px">&#9889; Batch Generate Invoices</h3>
    <p style="font-size:13px;color:#555;margin-bottom:16px">Creates one invoice per active company for the selected period. Companies with no monthly fee set (unless you provide a fixed amount below) are skipped.</p>
    <div style="display:grid;gap:14px;margin-bottom:16px">
      <div>
        <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:5px">Billing Period <span style="color:#C62828">*</span></label>
        <input id="batch-period" type="month" style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:5px">Fixed Amount Override <span style="color:#aaa;font-weight:400">(optional — leave blank to use each company's package fee)</span></label>
        <input id="batch-amount" type="number" min="0" step="0.01" placeholder="e.g. 149.00" style="width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/>
      </div>
      <div>
        <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13px">
          <input type="checkbox" id="batch-skip-existing" checked style="width:15px;height:15px;accent-color:#1565C0"/>
          Skip companies that already have an invoice for this period
        </label>
        <label style="display:flex;align-items:center;gap:6px;font-size:13px;cursor:pointer;margin-top:8px">
        <input type="checkbox" id="batch-email-companies" style="width:15px;height:15px;accent-color:#1565C0"/>
          Also email invoice to each company after generating
        </label>
      </div>
    </div>
    <div id="batch-result" class="sa-notice" style="display:none;margin-bottom:14px"></div>
    <div style="display:flex;gap:8px;justify-content:flex-end">
      <button onclick="closeBatchModal()" class="sa-btn sa-btn-n">Close</button>
      <button id="batch-confirm-btn" onclick="confirmBatch()" class="sa-btn sa-btn-p" style="font-weight:700">&#9889; Generate Invoices</button>
    </div>
  </div>
</div>

<script src="assets/js/bw-customize.js"></script>
</body>
</html>
