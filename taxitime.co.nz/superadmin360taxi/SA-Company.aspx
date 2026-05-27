<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Company Details &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-bar.green{background:#2E7D32}
.sa-bar.amber{background:#E65100}
.sa-bar.red{background:#C62828}
.sa-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box;font-family:inherit}
.sa-ff input:focus,.sa-ff select:focus,.sa-ff textarea:focus{outline:none;border-color:#1565C0}
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}.sa-btn-s:hover{background:#C8E6C9}
.sa-btn-w{background:#FFF9C4;color:#F57F17;border:1px solid #FFF176}.sa-btn-w:hover{background:#FFF176}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.edit-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;padding:18px}
.edit-grid-wide{grid-column:1/-1}
.co-header{padding:20px 22px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px}
.co-name{font-size:20px;font-weight:700;color:#263238}
.co-id{font-family:monospace;background:#E3F2FD;color:#1565C0;padding:3px 10px;border-radius:4px;font-size:13px;font-weight:700;margin-left:8px}
.badge{display:inline-block;padding:3px 10px;border-radius:12px;font-size:12px;font-weight:700}
.badge-active{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-trial{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.badge-suspended{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.badge-grace{background:#FFF3E0;color:#E65100;border:1px solid #FFCC80}
.connect-badge{display:inline-block;padding:4px 12px;border-radius:14px;font-size:12px;font-weight:700}
.connect-not-started{background:#f5f5f5;color:#757575;border:1px solid #e0e0e0}
.connect-pending{background:#FFF8E1;color:#F57F17;border:1px solid #FFE082}
.connect-complete{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.quick-actions{display:flex;gap:8px;flex-wrap:wrap;padding:14px 18px;border-bottom:1px solid #f5f5f5;background:#FAFAFA}
.user-row{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;border-bottom:1px solid #f8f8f8;font-size:13px;flex-wrap:wrap;gap:8px}
.user-row:last-child{border-bottom:none}
.uid-mono{font-family:monospace;font-size:11px;color:#aaa}
.mod-chip{display:inline-flex;align-items:center;gap:3px;padding:5px 12px;border-radius:14px;font-size:12px;font-weight:600;cursor:pointer;border:1px solid transparent;transition:all .15s;user-select:none;margin-right:6px}
.mod-on{background:#E8F5E9;color:#2E7D32;border-color:#A5D6A7}
.mod-off{background:#f5f5f5;color:#aaa;border-color:#e0e0e0}
.mod-chip:hover{opacity:.8}
.stat-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:12px;padding:16px 18px}
.stat-box{background:#F8F9FA;border-radius:6px;padding:12px 14px;border-left:3px solid #1565C0}
.stat-val{font-size:22px;font-weight:700;color:#1565C0}
.stat-lbl{font-size:11px;color:#aaa;margin-top:3px}
.danger-zone{padding:16px 18px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff" id="page-title">Company Details &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Clients.aspx" style="font-weight:700;color:#1565C0">&#9658; All Companies</a></li>
      <li><a href="SA-OwnerGroups.aspx">Owner Groups</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
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

<div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;flex-wrap:wrap">
  <a href="SA-Clients.aspx" class="sa-btn sa-btn-n" style="font-size:12px">&#8592; All Companies</a>
  <span style="color:#ccc">|</span>
  <span id="breadcrumb" style="font-size:13px;color:#888">Loading&hellip;</span>
</div>

<div id="sa-notice" class="sa-notice"></div>
<div id="page-loading" style="text-align:center;padding:60px;color:#aaa;font-size:14px">Loading company&hellip;</div>
<div id="page-content-wrap" style="display:none">

<!-- Company header -->
<div class="sa-card">
  <div class="co-header">
    <div>
      <span class="co-name" id="hdr-name"></span>
      <span class="co-id" id="hdr-cid"></span>
      <span id="hdr-status" style="margin-left:8px"></span>
    </div>
    <div style="font-size:12px;color:#aaa" id="hdr-meta"></div>
  </div>
  <div class="quick-actions">
    <button id="qa-viewas" onclick="openViewAs(CID, companyData.name||CID)" class="sa-btn" style="font-size:12px;background:#4A148C;color:#fff;border:none">&#128065; View as Company</button>
    <a id="qa-email" href="#" class="sa-btn sa-btn-p" style="font-size:12px">&#9993; Send Email</a>
    <a id="qa-billing" href="#" class="sa-btn sa-btn-n" style="font-size:12px">&#128179; Billing</a>
    <a id="qa-drivers" href="#" class="sa-btn sa-btn-n" style="font-size:12px">&#128663; Drivers</a>
    <button id="qa-suspend" onclick="openCoSuspend()" class="sa-btn sa-btn-w" style="font-size:12px">&#9940; Suspend</button>
    <button onclick="forceRevokeSession()" class="sa-btn sa-btn-d" style="font-size:12px" title="Immediately invalidates any active dispatch sessions for this company without suspending the account">&#128683; Force Revoke Sessions</button>
  </div>
  <div class="stat-row">
    <div class="stat-box"><div class="stat-val" id="stat-drivers">—</div><div class="stat-lbl">Drivers</div></div>
    <div class="stat-box" style="border-left-color:#2E7D32"><div class="stat-val" style="color:#2E7D32" id="stat-status">—</div><div class="stat-lbl">Status</div></div>
    <div class="stat-box" style="border-left-color:#F57F17"><div class="stat-val" style="color:#F57F17" id="stat-created">—</div><div class="stat-lbl">Onboarded</div></div>
    <div class="stat-box" style="border-left-color:#7B1FA2"><div class="stat-val" style="color:#7B1FA2" id="stat-plan">—</div><div class="stat-lbl">Plan</div></div>
  </div>
</div>

<!-- Edit form -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#9998; Company Details</h3></div>
  <div class="edit-grid">
    <div class="sa-ff"><label>Company Name <span style="color:#C62828">*</span></label><input id="f-name" type="text"/></div>
    <div class="sa-ff"><label>Contact Name</label><input id="f-contact" type="text"/></div>
    <div class="sa-ff"><label>Contact Email (login)</label><input id="f-email" type="email"/></div>
    <div class="sa-ff"><label>Contact Phone</label><input id="f-phone" type="text"/></div>
    <div class="sa-ff"><label>City / Area</label><input id="f-city" type="text"/></div>
    <div class="sa-ff"><label>Country</label><input id="f-country" type="text"/></div>
    <div class="sa-ff"><label>Payout Schedule</label>
      <select id="f-sched">
        <option value="weekly">Weekly</option>
        <option value="monthly">Monthly</option>
      </select>
    </div>
    <div class="sa-ff"><label>Plan / Package</label><input id="f-plan" type="text" placeholder="e.g. Professional"/></div>
    <div class="sa-ff edit-grid-wide"><label>Internal Notes</label><textarea id="f-notes" rows="3" placeholder="Internal notes — not visible to the company"></textarea></div>
    <div class="sa-ff edit-grid-wide">
      <label>Active Modules</label>
      <div style="margin-top:6px">
        <span class="mod-chip" id="mod-taxi" onclick="toggleMod('taxi')">&#128663; Taxi</span>
        <span class="mod-chip" id="mod-food" onclick="toggleMod('food')">&#127829; Food Delivery</span>
        <span class="mod-chip" id="mod-freight" onclick="toggleMod('freight')">&#128230; Freight</span>
      </div>
    </div>
  </div>
  <div style="padding:0 18px 18px;display:flex;gap:8px;align-items:center;flex-wrap:wrap">
    <button onclick="saveDetails()" class="sa-btn sa-btn-p">&#10003; Save Changes</button>
    <button onclick="loadCompany()" class="sa-btn sa-btn-n">&#8635; Reset</button>
    <span id="save-msg" style="font-size:12.5px;color:#888"></span>
  </div>
</div>

<!-- Owner Group Membership -->
<div class="sa-card" id="owner-group-card">
  <div class="sa-bar" style="background:#4A148C"><h3>&#128101; Owner Group</h3></div>
  <div style="padding:14px 18px">
    <div id="og-current" style="margin-bottom:12px;font-size:13px;color:#555">Loading&hellip;</div>
    <div style="display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap">
      <div class="sa-ff" style="flex:1;min-width:180px;margin:0">
        <label>Assign to Owner Group</label>
        <select id="og-select"><option value="">— No group / standalone —</option></select>
      </div>
      <button class="sa-btn" style="background:#4A148C;color:#fff" onclick="saveOwnerGroup()">&#10003; Save</button>
      <a href="SA-OwnerGroups.aspx" class="sa-btn sa-btn-n" style="font-size:12px">&#128101; Manage Groups</a>
      <span id="og-msg" style="font-size:12px;color:#888"></span>
    </div>
    <p style="font-size:11.5px;color:#9E9E9E;margin:10px 0 0">Linking writes <code>ownerGroupId</code> to this company and <code>companyIds/{cid}</code> to the group record. Drivers can then be shared across group companies from SA-OwnerGroups.</p>
  </div>
</div>

<!-- Panel access -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#128273; Owner Panel Access</h3><button onclick="loadPanelUsers()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;font-size:12px;border:1px solid rgba(255,255,255,.3)">&#8635; Refresh</button></div>
  <div id="panel-users-wrap">
    <div style="padding:16px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>
  </div>
  <div style="padding:14px 18px;border-top:1px solid #f5f5f5;display:flex;gap:10px;flex-wrap:wrap;align-items:center">
    <div style="flex:1;min-width:200px">
      <div style="font-size:12px;color:#555;margin-bottom:6px">Add access by Firebase UID:</div>
      <div style="display:flex;gap:8px">
        <input id="grant-uid-inp" type="text" placeholder="Firebase UID (28 chars)" style="flex:1;padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12px;font-family:monospace"/>
        <button onclick="grantByUid()" class="sa-btn sa-btn-s" style="font-size:12px">&#128275; Grant</button>
      </div>
    </div>
    <div style="border-left:1px solid #eee;padding-left:12px">
      <div style="font-size:12px;color:#555;margin-bottom:6px">Send password reset email:</div>
      <button onclick="sendPasswordReset()" id="reset-pwd-btn" class="sa-btn sa-btn-w" style="font-size:12px">&#128274; Send Reset Email</button>
    </div>
  </div>
</div>

<!-- Feature Flags -->
<div class="sa-card" id="features-card">
  <div class="sa-bar" style="background:#4527A0"><h3>&#127986; Per-Company Feature Flags</h3>
    <button onclick="saveFeatureFlags()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px">&#10003; Save Flags</button>
  </div>
  <div style="padding:16px 18px">
    <p style="font-size:12px;color:#888;margin:0 0 14px">Written to <code style="background:#F3E5F5;padding:1px 5px;border-radius:3px;font-size:11px">companySettings/{companyId}/features</code> — the Owner Panel and dispatch app read from this same path.</p>
    <div id="feature-flags-grid" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px"></div>
    <div id="ff-save-msg" style="font-size:12px;color:#888;margin-top:10px"></div>
  </div>
</div>

<!-- ACC Vendor ID — per company -->
<div class="sa-card" id="acc-vendor-card">
  <div class="sa-bar" style="background:#4527A0"><h3>&#127973; ACC Supplier ID</h3>
    <span style="font-size:11px;opacity:.7">Written to <code>companySettings/{companyId}/accVendorId</code></span>
  </div>
  <div style="padding:16px 18px">
    <p style="font-size:12px;color:#888;margin:0 0 14px">
      Each taxi company has their own ACC supplier registration number. This ID is printed on every ACC invoice the owner panel generates.
      It is <strong>not shared</strong> between companies — every company enters their own.
    </p>
    <div style="display:flex;align-items:flex-end;gap:10px;flex-wrap:wrap">
      <div style="flex:1;min-width:200px;max-width:320px">
        <label style="display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px">ACC Vendor / Supplier ID</label>
        <input id="acc-vendor-input" type="text" placeholder="e.g. VEND-XXXXXX" style="width:100%;padding:9px 11px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;font-family:monospace;box-sizing:border-box"/>
        <div style="font-size:11px;color:#9e9e9e;margin-top:4px">From this company's ACC supplier registration letter</div>
      </div>
      <button onclick="saveAccVendorId()" class="sa-btn" style="background:#4527A0;color:#fff;border:none;white-space:nowrap">&#10003; Save Vendor ID</button>
    </div>
    <div id="acc-vendor-msg" style="font-size:12px;margin-top:10px"></div>
  </div>
</div>

<!-- Payment Methods — per company -->
<div class="sa-card" id="payment-card">
  <div class="sa-bar" style="background:#E65100"><h3>&#128179; Payment Methods</h3>
    <span style="font-size:11px;opacity:.7">Written to <code>companySettings/{companyId}/paymentMethods</code></span>
  </div>
  <div style="padding:16px 18px">
    <p style="font-size:12px;color:#888;margin:0 0 14px">Company-level control. Only applies when the <strong>platform-wide cash switch</strong> (SA-Settings) is also ON. If the platform switch is OFF, cash is hidden everywhere regardless of this setting.</p>
    <div style="display:flex;align-items:center;gap:16px;flex-wrap:wrap">
      <div>
        <div style="font-size:13px;font-weight:600;color:#374151;margin-bottom:4px">Cash Payments for this company</div>
        <div style="font-size:11px;color:#888">Passenger app shows/hides cash option for this company's bookings</div>
      </div>
      <button id="co-cash-btn" onclick="toggleCompanyCash()" style="min-width:90px;padding:8px 18px;border-radius:20px;border:none;cursor:pointer;font-size:13px;font-weight:700;transition:background .2s">Loading…</button>
    </div>
    <div id="co-cash-msg" style="font-size:12px;color:#888;margin-top:10px"></div>
  </div>
</div>

<!-- Stripe Connect Express -->
<div class="sa-card" id="stripe-connect-card">
  <div class="sa-bar" style="background:#635BFF"><h3>&#128279; Stripe Connect</h3>
    <span id="stripe-connect-badge" class="connect-badge connect-not-started">Not started</span>
  </div>
  <div style="padding:16px 18px">
    <p style="font-size:12px;color:#888;margin:0 0 14px">
      Express Connect onboarding for card payments on the passenger website. When a company is approved, an onboarding link is emailed to the owner automatically.
    </p>
    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:12px;margin-bottom:14px;font-size:13px">
      <div><span style="color:#888">Account ID</span><br/><code id="stripe-connect-account-id" style="font-size:12px">—</code></div>
      <div><span style="color:#888">Charges enabled</span><br/><span id="stripe-connect-charges">—</span></div>
      <div><span style="color:#888">Link sent</span><br/><span id="stripe-connect-link-sent">—</span></div>
    </div>
    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
      <button onclick="resendStripeConnectLink()" class="sa-btn" style="background:#635BFF;color:#fff;border:none">&#9993; Resend onboarding email</button>
      <span id="stripe-connect-msg" style="font-size:12px;color:#888"></span>
    </div>
  </div>
</div>

<!-- Stripe keys — per company (legacy / optional) -->
<div class="sa-card" id="stripe-config-card">
  <div class="sa-bar" style="background:#635BFF"><h3>&#128179; Stripe Configuration</h3>
    <span style="font-size:11px;opacity:.7">Saved to <code>stripeConfig/{companyId}</code></span>
  </div>
  <div style="padding:16px 18px">
    <p style="font-size:12px;color:#888;margin:0 0 14px">
      Legacy per-company Stripe keys (optional). New companies should use Stripe Connect above. Connect account ID is used for passenger card payments when onboarding is complete.
    </p>
    <div class="edit-grid" style="padding:0">
      <div class="sa-ff edit-grid-wide">
        <label>Stripe Publishable Key</label>
        <input id="stripe-pub-key" type="text" placeholder="pk_live_… or pk_test_…" autocomplete="off" spellcheck="false"/>
        <div style="font-size:11px;color:#9e9e9e;margin-top:4px">Safe to expose in client apps — starts with <code>pk_</code></div>
      </div>
      <div class="sa-ff edit-grid-wide">
        <label>Stripe Secret Key</label>
        <input id="stripe-secret-key" type="password" placeholder="sk_live_… or sk_test_…" autocomplete="new-password" spellcheck="false"/>
        <div style="font-size:11px;color:#9e9e9e;margin-top:4px">Server-side only — starts with <code>sk_</code>. Never share publicly.</div>
      </div>
      <div class="sa-ff edit-grid-wide">
        <label>Stripe Webhook Secret</label>
        <input id="stripe-webhook-secret" type="password" placeholder="whsec_…" autocomplete="new-password" spellcheck="false"/>
        <div style="font-size:11px;color:#9e9e9e;margin-top:4px">From the Stripe Dashboard webhook endpoint — starts with <code>whsec_</code></div>
      </div>
    </div>
    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin-top:14px">
      <button onclick="saveStripeConfig()" class="sa-btn" style="background:#635BFF;color:#fff;border:none">&#10003; Save Stripe Keys</button>
      <span id="stripe-config-status" style="font-size:12px;color:#888"></span>
    </div>
    <div id="stripe-config-msg" style="font-size:12px;margin-top:10px"></div>
  </div>
</div>

<!-- Owner Panel Settings mirror -->
<div class="sa-card" id="owner-settings-card">
  <div class="sa-bar" style="background:#00695C"><h3>&#127970; Owner Panel Settings</h3>
    <span style="font-size:11px;opacity:.7">Reads from <code>companySettings/{companyId}</code></span>
  </div>
  <div id="owner-settings-body" style="padding:16px 18px;font-size:13px;color:#aaa">Loading&hellip;</div>
</div>

<!-- Live Bookings from Passenger App -->
<div class="sa-card">
  <div class="sa-bar" style="background:#1565C0"><h3>&#128204; Recent Bookings</h3>
    <span style="font-size:11px;opacity:.7">Reads from <code>allbookings/{companyId}</code> — written by Passenger App</span>
  </div>
  <div id="bookings-loading" style="padding:20px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>
  <div style="overflow-x:auto;display:none" id="bookings-wrap">
    <table class="sa-tbl" id="bookings-tbl">
      <thead><tr><th>Booking ID</th><th>Passenger</th><th>Pickup</th><th>Drop-off</th><th>Status</th><th>Driver</th><th>Time</th><th>Job Status</th></tr></thead>
      <tbody id="bookings-tbody"></tbody>
    </table>
  </div>
</div>

<!-- Driver App Registrations -->
<div class="sa-card">
  <div class="sa-bar" style="background:#37474F"><h3>&#128663; Driver App Registrations</h3>
    <span style="font-size:11px;opacity:.7">Reads from <code>driverRegistrations/{companyId}</code> — written by Driver App</span>
  </div>
  <div id="drvreg-loading" style="padding:20px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>
  <div style="overflow-x:auto;display:none" id="drvreg-wrap">
    <table class="sa-tbl" id="drvreg-tbl">
      <thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Registered</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody id="drvreg-tbody"></tbody>
    </table>
  </div>
</div>

<!-- Drivers list -->
<div class="sa-card">
  <div class="sa-bar" style="background:#37474F"><h3>&#128663; Drivers</h3>
    <div style="display:flex;gap:8px;align-items:center">
      <button onclick="toggleDriversList()" id="drivers-toggle-btn" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;font-size:12px;border:1px solid rgba(255,255,255,.3)">&#9660; Show</button>
      <a id="qa-drivers-link" href="#" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;font-size:12px;border:1px solid rgba(255,255,255,.3)">All Drivers &#8599;</a>
    </div>
  </div>
  <div id="drivers-list-wrap" style="display:none;padding:0 18px 14px"></div>
</div>

<!-- Billing summary -->
<div class="sa-card">
  <div class="sa-bar" style="background:#1B5E20"><h3>&#128179; Billing Summary</h3><a id="qa-billing-link" href="#" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;font-size:12px;border:1px solid rgba(255,255,255,.3)">Open Full Billing &#8599;</a></div>
  <div id="billing-summary-wrap" style="padding:16px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>
</div>

<!-- Recent audit activity -->
<div class="sa-card">
  <div class="sa-bar" style="background:#263238"><h3>&#128203; Recent Audit Activity</h3><a href="SA-AuditLog.aspx" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;font-size:12px;border:1px solid rgba(255,255,255,.3)">Full Audit Log &#8599;</a></div>
  <div id="audit-log-wrap" style="padding:16px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>
</div>

<!-- Danger zone -->
<div class="sa-card">
  <div class="sa-bar red"><h3>&#9888; Danger Zone</h3></div>
  <div class="danger-zone" style="display:flex;gap:12px;flex-wrap:wrap;align-items:center">
    <div style="flex:1">
      <div style="font-size:13px;font-weight:600;color:#263238;margin-bottom:4px">Delete Company</div>
      <div style="font-size:12px;color:#888">Permanently removes the company record and revokes all panel access. Cannot be undone.</div>
    </div>
    <button onclick="openDelete()" class="sa-btn sa-btn-d">&#128465; Delete Company</button>
  </div>
</div>

</div><!-- /page-content-wrap -->
</div>
</div></div>

<!-- Suspend confirmation modal -->
<div id="modal-suspend-co" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9999;align-items:center;justify-content:center;padding:20px">
  <div style="background:#fff;border-radius:10px;padding:28px;max-width:440px;width:100%;box-shadow:0 8px 30px rgba(0,0,0,.25)">
    <h3 style="font-size:16px;font-weight:700;color:#E65100;margin-bottom:12px">&#9940; Suspend Company</h3>
    <div id="susp-co-name" style="font-weight:700;font-size:14px;padding:10px 14px;background:#FFF3E0;border:1px solid #FFCC80;border-radius:8px;margin-bottom:14px"></div>
    <p style="font-size:13px;color:#555;margin-bottom:10px">The company will be suspended immediately. Their panel access remains but bookings may be restricted. This action is logged.</p>
    <div style="margin-bottom:16px">
      <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:6px;text-transform:uppercase;letter-spacing:.05em">Reason for Suspension <span style="color:#C62828">*</span></label>
      <textarea id="susp-co-reason" rows="3" placeholder="e.g. Unpaid invoices — 3 months overdue" style="width:100%;padding:10px 12px;border:1.5px solid #FFCC80;border-radius:8px;font-size:13px;font-family:inherit;box-sizing:border-box;resize:vertical"></textarea>
    </div>
    <div style="display:flex;gap:8px;justify-content:flex-end">
      <button onclick="closeCoSuspend()" class="sa-btn sa-btn-n">Cancel</button>
      <button onclick="confirmCoSuspend()" class="sa-btn sa-btn-w" style="font-weight:700">&#9940; Suspend Company</button>
    </div>
  </div>
</div>

<!-- Delete confirmation modal -->
<div id="modal-delete" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9999;align-items:center;justify-content:center;padding:20px">
  <div style="background:#fff;border-radius:10px;padding:28px;max-width:420px;width:100%;box-shadow:0 8px 30px rgba(0,0,0,.25)">
    <h3 style="font-size:16px;font-weight:700;color:#C62828;margin-bottom:12px">&#128465; Delete Company</h3>
    <p style="font-size:13px;color:#555;margin-bottom:16px">This will permanently delete <strong id="del-name"></strong> and revoke all owner panel access. Type <strong>DELETE</strong> to confirm.</p>
    <input id="del-confirm" type="text" placeholder="Type DELETE to confirm" style="width:100%;padding:9px 12px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;margin-bottom:12px" oninput="document.getElementById('del-btn').disabled=this.value!=='DELETE'"/>
    <div id="del-err" style="color:#C62828;font-size:12px;margin-bottom:10px"></div>
    <div style="display:flex;gap:8px;justify-content:flex-end">
      <button onclick="closeDelete()" class="sa-btn sa-btn-n">Cancel</button>
      <button id="del-btn" onclick="confirmDelete()" class="sa-btn sa-btn-d" disabled>&#128465; Delete</button>
    </div>
  </div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var CID = new URLSearchParams(window.location.search).get('cid') || '';
var companyData = {};
var modules = { taxi: false, food: false, freight: false };

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDate(ts){ return ts ? new Date(ts).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'}) : '—'; }

function showNotice(msg, type){
  var el = document.getElementById('sa-notice');
  el.className = 'sa-notice ' + (type||'ok');
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(function(){ el.style.display='none'; }, 4000);
}

function statusBadge(status){
  var map = {
    active: '<span class="badge badge-active">Active</span>',
    trial:  '<span class="badge badge-trial">Trial</span>',
    suspended: '<span class="badge badge-suspended">Suspended</span>',
    grace: '<span class="badge badge-grace">Grace Period</span>'
  };
  return map[status] || '<span class="badge" style="background:#f5f5f5;color:#888;border:1px solid #e0e0e0">'+esc(status)+'</span>';
}

function loadCompany(){
  if(!CID){ document.getElementById('page-loading').textContent='No Company ID specified. Return to All Companies.'; return; }
  _fbGet('superClients/'+CID).then(function(data){
    if(!data){ document.getElementById('page-loading').textContent='Company '+CID+' not found.'; return; }
    companyData = data || {};
    renderCompany();
    document.getElementById('page-loading').style.display='none';
    document.getElementById('page-content-wrap').style.display='block';
    loadDriverCount();
    loadPanelUsers();
    loadBillingSummary();
    loadAuditSummary();
    loadOwnerGroupCard();
  }).catch(function(err){
    document.getElementById('page-loading').textContent='Error loading company: '+String(err);
  });
}

function renderCompany(){
  var c = companyData;
  var name = c.name || CID;
  document.title = name + ' — BookaWaka Admin';
  document.getElementById('page-title').textContent = name + ' — BookaWaka Admin';
  document.getElementById('breadcrumb').textContent = name + ' (ID: ' + CID + ')';
  document.getElementById('hdr-name').textContent = name;
  document.getElementById('hdr-cid').textContent = CID;
  document.getElementById('hdr-status').innerHTML = statusBadge(c.status || 'active');
  document.getElementById('hdr-meta').textContent = 'Onboarded ' + fmtDate(c.createdAt || c.joinedAt);
  document.getElementById('stat-status').textContent = (c.status||'active').charAt(0).toUpperCase()+(c.status||'active').slice(1);
  document.getElementById('stat-created').textContent = fmtDate(c.createdAt || c.joinedAt);
  document.getElementById('stat-plan').textContent = c.plan || c.packageName || '—';

  var qaEmail = document.getElementById('qa-email');
  var qaBilling = document.getElementById('qa-billing');
  var qaDrivers = document.getElementById('qa-drivers');
  qaEmail.href = 'SA-Email.aspx?cid='+CID;
  qaBilling.href = 'SA-Billing.aspx?cid='+CID;
  qaDrivers.href = 'SA-Drivers.aspx?cid='+CID;

  var suspBtn = document.getElementById('qa-suspend');
  if(c.status === 'suspended'){
    suspBtn.textContent = '✓ Reactivate Company';
    suspBtn.className = 'sa-btn sa-btn-s';
    suspBtn.onclick = activateCompany;
  } else {
    suspBtn.textContent = '⊘ Suspend Company';
    suspBtn.className = 'sa-btn sa-btn-w';
    suspBtn.onclick = openCoSuspend;
  }
  var drLink = document.getElementById('qa-drivers-link');
  if(drLink) drLink.href = 'SA-Drivers.aspx?cid='+CID;

  document.getElementById('f-name').value = c.name || '';
  document.getElementById('f-contact').value = c.contactName || '';
  document.getElementById('f-email').value = c.email || c.contactEmail || '';
  document.getElementById('f-phone').value = c.contactPhone || c.phone || '';
  document.getElementById('f-city').value = c.city || c.area || '';
  document.getElementById('f-country').value = c.country || '';
  document.getElementById('f-sched').value = c.payoutSchedule || 'weekly';
  document.getElementById('f-plan').value = c.plan || c.packageName || '';
  document.getElementById('f-notes').value = c.notes || '';
  var qaViewas = document.getElementById('qa-viewas');
  if (qaViewas) qaViewas.style.display = '';

  modules = { taxi: !!(c.modules && c.modules.taxi), food: !!(c.modules && c.modules.food), freight: !!(c.modules && c.modules.freight) };
  ['taxi','food','freight'].forEach(function(m){
    var chip = document.getElementById('mod-'+m);
    chip.className = 'mod-chip ' + (modules[m] ? 'mod-on' : 'mod-off');
  });
  document.getElementById('save-msg').textContent = '';
}

function toggleMod(m){
  modules[m] = !modules[m];
  var chip = document.getElementById('mod-'+m);
  chip.className = 'mod-chip ' + (modules[m] ? 'mod-on' : 'mod-off');
}

function saveDetails(){
  var name = document.getElementById('f-name').value.trim();
  if(!name){ showNotice('Company name cannot be empty','err'); return; }
  var msg = document.getElementById('save-msg');
  msg.style.color='#888'; msg.textContent='Saving…';
  var upd = {
    name: name,
    contactName: document.getElementById('f-contact').value.trim(),
    email: document.getElementById('f-email').value.trim(),
    contactEmail: document.getElementById('f-email').value.trim(),
    contactPhone: document.getElementById('f-phone').value.trim(),
    phone: document.getElementById('f-phone').value.trim(),
    city: document.getElementById('f-city').value.trim(),
    area: document.getElementById('f-city').value.trim(),
    country: document.getElementById('f-country').value.trim(),
    payoutSchedule: document.getElementById('f-sched').value,
    plan: document.getElementById('f-plan').value.trim(),
    notes: document.getElementById('f-notes').value.trim(),
    modules: { taxi: modules.taxi, food: modules.food, freight: modules.freight },
    updatedAt: Date.now()
  };
  db.ref('superClients/'+CID).update(upd).then(function(){
    Object.assign(companyData, upd);
    renderCompany();
    msg.style.color='#2E7D32'; msg.textContent='✓ Saved successfully';
    setTimeout(function(){ msg.textContent=''; }, 3000);
    showNotice('Company details saved', 'ok');
  }).catch(function(e){
    msg.style.color='#C62828'; msg.textContent='Error: '+String(e.message||e);
    showNotice('Save failed: '+String(e.message||e), 'err');
  });
}

function openCoSuspend(){
  document.getElementById('susp-co-name').textContent = (companyData.name||CID) + ' (ID: ' + CID + ')';
  document.getElementById('susp-co-reason').value = '';
  document.getElementById('modal-suspend-co').style.display = 'flex';
}
function closeCoSuspend(){ document.getElementById('modal-suspend-co').style.display = 'none'; }
function confirmCoSuspend(){
  var reason = (document.getElementById('susp-co-reason').value||'').trim();
  if(!reason){ showNotice('Please enter a reason for suspension','warn'); return; }
  var saEmail = (firebase.auth().currentUser||{}).email || 'sa-admin';
  var now = Date.now();
  db.ref('superClients/'+CID).update({status:'suspended',suspendReason:reason,suspendedAt:now,sessionRevoke:now}).then(function(){
    companyData.status = 'suspended'; companyData.suspendReason = reason;
    renderCompany();
    closeCoSuspend();
    showNotice('Company suspended — active dispatch sessions revoked','warn');
    var ts=Date.now(), rand=Math.random().toString(36).substr(2,5).toUpperCase();
    db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:'company_suspended',actor:saEmail,cid:CID,cidName:companyData.name||CID,detail:'Suspended — reason: '+reason+' | sessions revoked',ts:ts});
  }).catch(function(e){ showNotice('Error: '+String(e.message||e),'err'); });
}
/* ── Force Revoke Sessions ───────────────────────── */
function forceRevokeSession(){
  if(!confirm('Force-revoke all active dispatch sessions for '+esc(companyData.name||CID)+'?\n\nTheir session token will be invalidated immediately — dispatchers will be logged out on their next request. The account will NOT be suspended.')) return;
  var saEmail=(firebase.auth().currentUser||{}).email||'sa-admin';
  var now=Date.now();
  db.ref('superClients/'+CID).update({sessionRevoke:now}).then(function(){
    showNotice('Session revocation signal sent — dispatchers will be logged out immediately','warn');
    var ts=Date.now(), rand=Math.random().toString(36).substr(2,5).toUpperCase();
    db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:'session_revoked',actor:saEmail,cid:CID,cidName:companyData.name||CID,detail:'Admin force-revoked all dispatch sessions',ts:ts});
  }).catch(function(e){ showNotice('Error: '+String(e.message||e),'err'); });
}

/* ── Feature Flags ───────────────────────────────── */
var FEATURE_DEFS = [
  {key:'tmEnabled',        label:'Taxi Meter (TM)',        icon:'&#9939;',   desc:'TM hardware integration'},
  {key:'autoDispatch',     label:'Auto-Dispatch',          icon:'&#128736;', desc:'Automatic job assignment'},
  {key:'wavEnabled',       label:'WAV Bookings',           icon:'&#9855;',   desc:'Wheelchair accessible vehicles'},
  {key:'foodDelivery',     label:'Food Delivery',          icon:'&#127828;', desc:'Food delivery module'},
  {key:'freightEnabled',   label:'Freight',                icon:'&#128666;', desc:'Freight / courier jobs'},
  {key:'rentalEnabled',    label:'Rental Cars',            icon:'&#128663;', desc:'Vehicle rental module — full fleet & booking management'},
  {key:'bookingsEnabled',  label:'Online Bookings',        icon:'&#128203;', desc:'Customer booking portal'},
  {key:'smsNotifications', label:'SMS Notifications',      icon:'&#128241;', desc:'SMS alerts to passengers'},
  {key:'driverApp',        label:'Driver App Access',      icon:'&#128663;', desc:'Mobile driver app enabled'},
  {key:'dispatchPortal',   label:'Dispatch Portal',        icon:'&#128187;', desc:'Web dispatch panel access'},
  {key:'reportsEnabled',   label:'Company Reports',        icon:'&#128202;', desc:'Revenue/activity reports'},
  {key:'businessAccounts', label:'Business Accounts',      icon:'&#127970;', desc:'Corporate account billing — owner panel Business Accounts tab'},
  {key:'accEnabled',       label:'ACC Claims',             icon:'&#127973;', desc:'ACC client & purchase order management — owner panel ACC tab and dispatcher lookup'}
];
var _currentFlags = {};

function loadFeatureFlags(){
  _fbGet('companySettings/'+CID+'/features').then(function(data){
    _currentFlags = data||{};
    renderFeatureFlags();
  });
}

function renderFeatureFlags(){
  var grid=document.getElementById('feature-flags-grid');
  if(!grid) return;
  grid.innerHTML=FEATURE_DEFS.map(function(f){
    var on=_currentFlags[f.key]!==false; // default ON unless explicitly false
    return '<label style="display:flex;align-items:flex-start;gap:10px;padding:10px 12px;border:1.5px solid '+(on?'#7C4DFF':'#e0e0e0')+';border-radius:6px;cursor:pointer;background:'+(on?'#EDE7F6':'#fafafa')+';transition:all .15s">'
      +'<input type="checkbox" id="ff-'+f.key+'" '+(on?'checked':'')+' onchange="onFlagChange(\''+f.key+'\',this.checked)" style="width:16px;height:16px;margin-top:1px;cursor:pointer;accent-color:#4527A0"/>'
      +'<div>'
        +'<div style="font-weight:700;font-size:12.5px;color:#263238">'+f.icon+' '+f.label+'</div>'
        +'<div style="font-size:11px;color:#888;margin-top:1px">'+f.desc+'</div>'
      +'</div>'
      +'</label>';
  }).join('');
}

function onFlagChange(key, checked){
  _currentFlags[key]=checked;
  renderFeatureFlags();
  document.getElementById('ff-save-msg').textContent='Unsaved changes — click Save Flags';
  document.getElementById('ff-save-msg').style.color='#E65100';
}

function saveFeatureFlags(){
  var updates={};
  FEATURE_DEFS.forEach(function(f){ updates[f.key]=_currentFlags[f.key]!==false; });
  db.ref('companySettings/'+CID+'/features').update(updates).then(function(){
    db.ref('superClients/'+CID+'/features').update(updates); // keep superClients in sync
    var saEmail=(firebase.auth().currentUser||{}).email||'sa-admin';
    var ts=Date.now(), rand=Math.random().toString(36).substr(2,5).toUpperCase();
    var changed=FEATURE_DEFS.filter(function(f){ return updates[f.key]===false; }).map(function(f){ return f.label+': OFF'; });
    db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:'feature_flags_updated',actor:saEmail,cid:CID,cidName:companyData.name||CID,detail:'Feature flags saved'+(changed.length?' — disabled: '+changed.join(', '):''),ts:ts});
    showNotice('Feature flags saved for '+esc(companyData.name||CID),'ok');
    document.getElementById('ff-save-msg').textContent='Saved at '+new Date().toLocaleTimeString();
    document.getElementById('ff-save-msg').style.color='#2E7D32';
  }).catch(function(e){ showNotice('Error saving flags: '+e.message,'err'); });
}

function activateCompany(){
  if(!confirm('Reactivate '+esc(companyData.name||CID)+'? This will restore their access.')) return;
  var saEmail = (firebase.auth().currentUser||{}).email || 'sa-admin';
  db.ref('superClients/'+CID).update({status:'active',suspendReason:null,suspendedAt:null}).then(function(){
    companyData.status = 'active'; companyData.suspendReason = null;
    renderCompany();
    showNotice('Company reactivated','ok');
    var ts=Date.now(), rand=Math.random().toString(36).substr(2,5).toUpperCase();
    db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:'company_activated',actor:saEmail,cid:CID,cidName:companyData.name||CID,detail:'Company reactivated',ts:ts});
  }).catch(function(e){ showNotice('Error: '+String(e.message||e),'err'); });
}

function _loadDriversForCID(){
  return Promise.all([
    _fbGet('drivers/'+CID),
    _fbGet('drivers')
  ]).then(function(results){
    var nested = results[0] || {};
    var root   = results[1] || {};
    var seen   = {};
    var list   = [];
    Object.entries(nested).forEach(function(e){
      if(e[1] && typeof e[1]==='object'){ seen[e[0]]=true; list.push([e[0],e[1]]); }
    });
    Object.entries(root).forEach(function(e){
      var key=e[0], val=e[1];
      if(!seen[key] && val && typeof val==='object' && String(val.companyId||val.company_id||'')===String(CID)){
        list.push([key,val]);
      }
    });
    return list;
  });
}
var _driversCache = null;
function loadDriverCount(){
  _loadDriversForCID().then(function(list){
    _driversCache = list;
    document.getElementById('stat-drivers').textContent = list.length;
  }).catch(function(){ document.getElementById('stat-drivers').textContent='?'; });
}

var _driversVisible = false;
function toggleDriversList(){
  _driversVisible = !_driversVisible;
  var wrap = document.getElementById('drivers-list-wrap');
  var btn  = document.getElementById('drivers-toggle-btn');
  wrap.style.display = _driversVisible ? 'block' : 'none';
  btn.textContent = _driversVisible ? '▲ Hide' : '▼ Show';
  if(_driversVisible && wrap.innerHTML.trim()==='') renderDriversList();
}
function renderDriversList(){
  var wrap = document.getElementById('drivers-list-wrap');
  if(_driversCache === null){
    wrap.innerHTML='<div style="padding:14px 0;color:#aaa;font-size:13px">Loading drivers&hellip;</div>';
    _loadDriversForCID().then(function(list){
      _driversCache = list;
      document.getElementById('stat-drivers').textContent = list.length;
      _renderDriverTable(wrap);
    }).catch(function(){ wrap.innerHTML='<div style="padding:14px 0;color:#C62828;font-size:13px">Error loading drivers.</div>'; });
    return;
  }
  _renderDriverTable(wrap);
}
function _renderDriverTable(wrap){
  var list = _driversCache;
  if(!list.length){ wrap.innerHTML='<div style="padding:14px 0;color:#aaa;font-size:13px">No drivers found for this company.</div>'; return; }
  var statusMap={approved:'<span style="background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7;border-radius:10px;padding:2px 8px;font-size:11px">Approved</span>',pending:'<span style="background:#FFF3E0;color:#E65100;border:1px solid #FFCC80;border-radius:10px;padding:2px 8px;font-size:11px">Pending</span>',rejected:'<span style="background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;border-radius:10px;padding:2px 8px;font-size:11px">Rejected</span>'};
  var html='<table style="width:100%;border-collapse:collapse;font-size:12.5px;margin-top:10px"><thead><tr style="background:#f8f9fa"><th style="padding:7px 10px;text-align:left;font-weight:600;color:#555">Name</th><th style="padding:7px 10px;text-align:left;font-weight:600;color:#555">Phone</th><th style="padding:7px 10px;text-align:left;font-weight:600;color:#555">Status</th><th style="padding:7px 10px;text-align:left;font-weight:600;color:#555">Active</th></tr></thead><tbody>';
  list.slice(0,30).forEach(function(e){
    var d=e[1];
    var name=esc((d.firstName||'')+(d.firstName&&d.lastName?' ':'')+( d.lastName||''))||(esc(d.name||'—'));
    var st=d.approvalStatus||d.status||'';
    html+='<tr style="border-bottom:1px solid #f5f5f5"><td style="padding:7px 10px;font-weight:600">'+name+'</td><td style="padding:7px 10px;color:#555">'+esc(d.phone||d.mobileNumber||'—')+'</td><td style="padding:7px 10px">'+(statusMap[st]||esc(st||'—'))+'</td><td style="padding:7px 10px">'+(d.isActive||d.active?'<span style="color:#2E7D32">&#10003; Yes</span>':'<span style="color:#aaa">No</span>')+'</td></tr>';
  });
  html+='</tbody></table>';
  if(list.length>30) html+='<div style="padding:8px 0;font-size:12px;color:#aaa">Showing 30 of '+list.length+' drivers. <a href="SA-Drivers.aspx?cid='+CID+'" style="color:#1565C0">View all</a>.</div>';
  wrap.innerHTML=html;
}

function loadBillingSummary(){
  var wrap = document.getElementById('billing-summary-wrap');
  var link = document.getElementById('qa-billing-link');
  if(link) link.href = 'SA-Billing.aspx?cid='+CID;
  _fbGet('superBilling/'+CID+'/invoices').then(function(invoices){
    if(!invoices){ wrap.innerHTML='<div style="color:#aaa;font-size:13px;padding:4px 0">No invoices on record. <a href="SA-Billing.aspx?cid='+CID+'" style="color:#1565C0">Add one in Billing</a>.</div>'; return; }
    var list = Object.values(invoices).sort(function(a,b){ return (b.period||'').localeCompare(a.period||''); }).slice(0,5);
    var paid=0, unpaid=0, overdue=0, totalRev=0;
    Object.values(invoices).forEach(function(inv){
      if(inv.status==='paid'){ paid++; totalRev+=(+inv.amount||0); }
      else if(inv.status==='overdue') overdue++;
      else unpaid++;
    });
    var statsHtml='<div style="display:flex;gap:10px;flex-wrap:wrap;margin-bottom:14px">' +
      '<div style="background:#E8F5E9;border-radius:6px;padding:8px 14px;text-align:center"><div style="font-size:18px;font-weight:700;color:#2E7D32">'+paid+'</div><div style="font-size:11px;color:#555">Paid</div></div>' +
      (unpaid>0?'<div style="background:#E3F2FD;border-radius:6px;padding:8px 14px;text-align:center"><div style="font-size:18px;font-weight:700;color:#1565C0">'+unpaid+'</div><div style="font-size:11px;color:#555">Unpaid</div></div>':'')+
      (overdue>0?'<div style="background:#FFEBEE;border-radius:6px;padding:8px 14px;text-align:center"><div style="font-size:18px;font-weight:700;color:#C62828">'+overdue+'</div><div style="font-size:11px;color:#C62828">Overdue</div></div>':'')+
      '<div style="background:#F3E5F5;border-radius:6px;padding:8px 14px;text-align:center"><div style="font-size:18px;font-weight:700;color:#7B1FA2">$'+totalRev.toFixed(2)+'</div><div style="font-size:11px;color:#555">Total Revenue</div></div>' +
    '</div>';
    var rowsHtml='<table style="width:100%;border-collapse:collapse;font-size:12.5px">' +
      '<thead><tr style="background:#f8f9fa"><th style="padding:6px 10px;text-align:left;font-weight:600;color:#555">Period</th><th style="padding:6px 10px;text-align:left;font-weight:600;color:#555">Amount</th><th style="padding:6px 10px;text-align:left;font-weight:600;color:#555">Status</th><th style="padding:6px 10px;text-align:left;font-weight:600;color:#555">Paid Date</th></tr></thead><tbody>';
    list.forEach(function(inv){
      var badgeHtml = inv.status==='paid'
        ? '<span style="background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7;border-radius:10px;padding:2px 8px;font-size:11px">&#10003; Paid</span>'
        : inv.status==='overdue'
        ? '<span style="background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;border-radius:10px;padding:2px 8px;font-size:11px">&#9888; Overdue</span>'
        : '<span style="background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB;border-radius:10px;padding:2px 8px;font-size:11px">Unpaid</span>';
      rowsHtml+='<tr style="border-bottom:1px solid #f5f5f5"><td style="padding:7px 10px;font-weight:600">'+(inv.period||'—')+'</td><td style="padding:7px 10px">$'+Number(inv.amount||0).toFixed(2)+'</td><td style="padding:7px 10px">'+badgeHtml+'</td><td style="padding:7px 10px;color:#888">'+fmtDate(inv.paidDate)+'</td></tr>';
    });
    rowsHtml+='</tbody></table>';
    if(Object.keys(invoices).length>5) rowsHtml+='<div style="padding:8px 10px;font-size:12px;color:#aaa">Showing last 5 of '+Object.keys(invoices).length+' invoices. <a href="SA-Billing.aspx?cid='+CID+'" style="color:#1565C0">View all</a>.</div>';
    wrap.innerHTML = statsHtml + rowsHtml;
  }).catch(function(e){ wrap.innerHTML='<div style="color:#C62828;font-size:13px">Error loading billing: '+esc(String(e))+'</div>'; });
}

function loadAuditSummary(){
  var wrap = document.getElementById('audit-log-wrap');
  _fbGet('superAuditLog').then(function(all){
    all=all||{};
    var entries = Object.values(all)
      .filter(function(e){ return String(e.cid||'') === String(CID); })
      .sort(function(a,b){ return (b.ts||0)-(a.ts||0); })
      .slice(0,10);
    if(!entries.length){ wrap.innerHTML='<div style="color:#aaa;font-size:13px;padding:4px 0">No audit events recorded for this company yet.</div>'; return; }
    var html='';
    entries.forEach(function(entry){
      var dt = entry.ts ? new Date(entry.ts).toLocaleString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}) : '—';
      html+='<div style="display:flex;gap:10px;align-items:flex-start;padding:9px 0;border-bottom:1px solid #f5f5f5;font-size:12.5px">' +
        '<span style="font-size:16px;line-height:1.4">&#128203;</span>' +
        '<div style="flex:1">' +
          '<div style="font-weight:600;color:#263238">'+esc(entry.action||'event')+'</div>' +
          (entry.detail?'<div style="color:#555;margin-top:1px">'+esc(entry.detail)+'</div>':'')+
          '<div style="color:#aaa;font-size:11px;margin-top:2px">'+dt+' &mdash; by '+esc(entry.actor||'system')+'</div>' +
        '</div>' +
      '</div>';
    });
    wrap.innerHTML=html;
  }).catch(function(e){ wrap.innerHTML='<div style="color:#C62828;font-size:13px">Error loading audit log: '+esc(String(e))+'</div>'; });
}

function loadPanelUsers(){
  var wrap = document.getElementById('panel-users-wrap');
  wrap.innerHTML = '<div style="padding:16px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>';
  fetch('/api/admin/panel-users/'+encodeURIComponent(CID))
    .then(function(r){ return r.json(); })
    .then(function(users){
      if(!users.length){
        wrap.innerHTML='<div style="padding:16px 18px;font-size:13px;color:#aaa">No users have owner panel access yet.</div>';
        return;
      }
      var html='';
      users.forEach(function(u){
        html += '<div class="user-row">' +
          '<div>' +
            '<div style="font-weight:600;font-size:13px">'+(u.email?esc(u.email):'<span style="color:#aaa">Email unknown</span>')+'</div>' +
            '<div class="uid-mono">UID: '+esc(u.uid)+'</div>' +
          '</div>' +
          '<button onclick="revokeAccess(\''+esc(u.uid)+'\')" class="sa-btn sa-btn-d" style="font-size:11px">Revoke</button>' +
        '</div>';
      });
      wrap.innerHTML=html;
    })
    .catch(function(){ wrap.innerHTML='<div style="padding:16px 18px;font-size:13px;color:#C62828">Failed to load panel users.</div>'; });
}

function revokeAccess(uid){
  if(!confirm('Revoke owner panel access for UID: '+uid+'?')) return;
  var saEmail = (firebase.auth().currentUser||{}).email || 'sa-admin';
  fetch('/api/admin/revoke-access',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({cid:CID, uid:uid, _saEmail:saEmail})
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){ showNotice('Access revoked','ok'); loadPanelUsers(); }
    else { showNotice('Error: '+(d.error||'unknown'),'err'); }
  }).catch(function(){ showNotice('Network error','err'); });
}

function grantByUid(){
  var uid = (document.getElementById('grant-uid-inp').value||'').trim();
  if(!uid||uid.length<20){ showNotice('Enter a valid Firebase UID','err'); return; }
  var saEmail = (firebase.auth().currentUser||{}).email || 'sa-admin';
  fetch('/api/admin/grant-access-uid',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({uid:uid, companyId:CID, _saEmail:saEmail})
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.success){ document.getElementById('grant-uid-inp').value=''; showNotice('Access granted','ok'); loadPanelUsers(); }
    else { showNotice('Error: '+(d.error||'unknown'),'err'); }
  }).catch(function(){ showNotice('Network error','err'); });
}

function sendPasswordReset(){
  var email = (companyData.email || companyData.contactEmail || '').trim();
  if(!email){ showNotice('No login email on file for this company — edit the Contact Email field first','warn'); return; }
  var btn = document.getElementById('reset-pwd-btn');
  btn.disabled=true; btn.textContent='Sending…';
  fetch('/api/admin/reset-owner-password',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({email:email})
  }).then(function(r){ return r.json(); }).then(function(d){
    btn.disabled=false; btn.textContent='⊠ Send Reset Email';
    if(d.ok){ showNotice('Password reset email sent to '+email,'ok'); toastr.success('Reset email sent to '+email); }
    else { showNotice('Error: '+(d.error||'unknown'),'err'); }
  }).catch(function(){ btn.disabled=false; btn.textContent='⊠ Send Reset Email'; showNotice('Network error','err'); });
}

function openDelete(){
  document.getElementById('del-name').textContent = (companyData.name||CID) + ' (ID: ' + CID + ')';
  document.getElementById('del-confirm').value='';
  document.getElementById('del-err').textContent='';
  document.getElementById('del-btn').disabled=true;
  document.getElementById('modal-delete').style.display='flex';
}
function closeDelete(){ document.getElementById('modal-delete').style.display='none'; }
function confirmDelete(){
  var typed = (document.getElementById('del-confirm').value||'').trim();
  if(typed!=='DELETE'){ document.getElementById('del-err').textContent='Type DELETE exactly'; return; }
  var btn=document.getElementById('del-btn');
  btn.disabled=true; btn.textContent='Deleting…';
  fetch('/api/company/delete',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({cid:CID})
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){ window.location.href='SA-Clients.aspx'; }
    else { btn.disabled=false; btn.textContent='Delete'; document.getElementById('del-err').textContent='Error: '+(d.error||'unknown'); }
  }).catch(function(){ btn.disabled=false; btn.textContent='Delete'; document.getElementById('del-err').textContent='Network error'; });
}

/* ── Owner Panel Settings ────────────────────────── */
function loadOwnerSettings(){
  _fbGet('companySettings/'+CID).then(function(data){
    var s=data||{};
    var el=document.getElementById('owner-settings-body');
    if(!data){ el.textContent='No data yet — Owner Panel has not written to companySettings/'+CID; return; }
    var fields=[
      {label:'Company Name',val:s.name},
      {label:'Logo URL',val:s.logoUrl?'<img src="'+esc(s.logoUrl)+'" style="max-height:40px;vertical-align:middle;margin-right:6px" onerror="this.style.display=\'none\'"/>'+esc(s.logoUrl):null},
      {label:'Timezone',val:s.timezone},
      {label:'Currency',val:s.currency},
      {label:'Contact Email',val:s.email||s.contactEmail},
      {label:'Contact Phone',val:s.phone||s.contactPhone},
      {label:'Address',val:s.address},
      {label:'Last Updated',val:s.updatedAt?new Date(s.updatedAt).toLocaleString('en-NZ'):null}
    ].filter(function(f){ return f.val; });
    if(!fields.length){ el.textContent='Owner Panel connected — no profile fields set yet.'; return; }
    el.innerHTML='<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:10px">'
      +fields.map(function(f){
        return '<div style="background:#F9FBE7;border:1px solid #E6EE9C;border-radius:6px;padding:10px 12px">'
          +'<div style="font-size:11px;font-weight:700;color:#558B2F;text-transform:uppercase;letter-spacing:.4px">'+esc(f.label)+'</div>'
          +'<div style="font-size:13px;color:#263238;margin-top:4px;word-break:break-word">'+f.val+'</div>'
          +'</div>';
      }).join('')
      +'</div>';
  }).catch(function(e){ document.getElementById('owner-settings-body').textContent='Error: '+e.message; });
}

/* ── Live Bookings from Passenger App ───────────── */
function loadBookings(){
  _fbGet('allbookings/'+CID).then(function(data){
    data=data||{};
    var bl=document.getElementById('bookings-loading');
    var bw=document.getElementById('bookings-wrap');
    if(!Object.keys(data).length){ bl.textContent='No bookings yet — Passenger App writes to allbookings/'+CID; return; }
    // Normalise timestamp: new records have requestedAt (ISO string); historical have CreatedAt/createdAt (ms number)
    function _bTs(b){ return b.requestedAt ? new Date(b.requestedAt).getTime() : (b.CreatedAt||b.createdAt||0); }
    var items=Object.entries(data).map(function(e){ return Object.assign({_bid:e[0]},e[1]); })
      .sort(function(a,b){ return _bTs(b)-_bTs(a); });
    var statusColor={scheduled:'#00838F',pending:'#E65100',accepted:'#1565C0',inprogress:'#7B1FA2',completed:'#2E7D32',cancelled:'#C62828'};
    document.getElementById('bookings-tbody').innerHTML=items.map(function(b){
      var st=b.status||'pending';
      var col=statusColor[st]||'#555';
      var bTs=_bTs(b);
      // pickup/dropoff (web bookings) and pickupLocation/dropoffLocation (passenger app) are
      // both {address, lat, lng} objects — extract .address; fall back to flat string form too.
      var pickupStr  = b.pickupAddress  || (b.pickup  && (b.pickup.address  || b.pickup))  || (b.pickupLocation  && b.pickupLocation.address)  || '—';
      var dropoffStr = b.dropoffAddress || (b.dropoff && (b.dropoff.address || b.dropoff)) || (b.dropoffLocation && b.dropoffLocation.address) || b.destination || '—';
      // TM multi-passenger: show all passengers / voucher numbers in the name cell
      var tmPassList  = Array.isArray(b.tmPassengers) ? b.tmPassengers : [];
      var tmVouchList = Array.isArray(b.tmVoucherNumbers) ? b.tmVoucherNumbers : [];
      var allTmNames  = tmPassList.map(function(p){ return p.cardholderName||''; }).filter(Boolean);
      var allTmCards  = tmPassList.length ? tmPassList.map(function(p){ return p.cardNumber||''; }).filter(Boolean) : tmVouchList;
      var passengerDisplay = b.passengerName || b.customerName || (allTmNames.length ? allTmNames.join(' + ') : '—');
      var cardDisplay = allTmCards.length ? ' <span style="font-size:10px;color:#0277BD">[TM: '+allTmCards.join(', ')+']</span>' : '';
      return '<tr>'
        +'<td style="font-family:monospace;font-size:11px;color:#888">'+esc(b._bid.substr(-8))+'</td>'
        +'<td style="font-weight:600">'+esc(passengerDisplay)+cardDisplay+'<div style="font-size:11px;color:#aaa">'+esc(b.passengerPhone||b.phone||'')+'</div></td>'
        +'<td style="font-size:12px;max-width:120px">'+esc(pickupStr)+'</td>'
        +'<td style="font-size:12px;max-width:120px">'+esc(dropoffStr)+'</td>'
        +'<td><span style="color:'+col+';font-weight:700;font-size:12px">'+esc(st)+'</span></td>'
        +'<td style="font-size:12px;color:#555">'+esc(b.driverName||b.assignedDriver||'Unassigned')+'</td>'
        +'<td style="font-size:11px;color:#888;white-space:nowrap">'+(bTs?new Date(bTs).toLocaleString('en-NZ',{timeZone:'Pacific/Auckland',day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'}):'—')+'</td>'
        +'<td><button class="sa-btn sa-btn-n" style="font-size:10px" onclick="viewRideStatus(\''+esc(b._bid)+'\')">&#128204; Status</button></td>'
        +'</tr>';
    }).join('');
    bl.style.display='none';
    bw.style.display='block';
  }).catch(function(e){ document.getElementById('bookings-loading').textContent='Error: '+e.message; });
}

function viewRideStatus(bid){
  _fbGet('rideStatus/'+CID+'/'+bid).then(function(data){
    var s=data||{};
    if(!data){ alert('No rideStatus entry found for booking '+bid+'.\nPassenger App reads rideStatus/'+CID+'/'+bid); return; }
    var lines=Object.entries(s).map(function(e){ return e[0]+': '+JSON.stringify(e[1]); }).join('\n');
    alert('rideStatus/'+CID+'/'+bid+':\n\n'+lines);
  }).catch(function(e){ alert('Error: '+e.message); });
}

/* ── Driver App Registrations ───────────────────── */
function loadDriverRegistrations(){
  _fbGet('driverRegistrations/'+CID).then(function(data){
    data=data||{};
    var dl=document.getElementById('drvreg-loading');
    var dw=document.getElementById('drvreg-wrap');
    if(!Object.keys(data).length){ dl.textContent='No registrations yet — Driver App writes to driverRegistrations/'+CID; return; }
    var items=Object.entries(data).map(function(e){ return Object.assign({_rid:e[0]},e[1]); })
      .sort(function(a,b){ return (b.registeredAt||0)-(a.registeredAt||0); });
    document.getElementById('drvreg-tbody').innerHTML=items.map(function(d){
      var st=d.status||'pending';
      var stBadge=st==='approved'
        ?'<span style="color:#2E7D32;font-weight:700">Approved</span>'
        :st==='rejected'
          ?'<span style="color:#C62828;font-weight:700">Rejected</span>'
          :'<span style="color:#E65100;font-weight:700">Pending</span>';
      return '<tr>'
        +'<td style="font-weight:600">'+esc(d.name||d.displayName||'—')+'</td>'
        +'<td style="font-size:12px">'+esc(d.email||'—')+'</td>'
        +'<td style="font-size:12px">'+esc(d.phone||'—')+'</td>'
        +'<td style="font-size:11px;color:#888;white-space:nowrap">'+(d.registeredAt?new Date(d.registeredAt).toLocaleString('en-NZ',{day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'}):'—')+'</td>'
        +'<td>'+stBadge+'</td>'
        +'<td style="white-space:nowrap">'
          +(st==='pending'?'<button class="sa-btn sa-btn-s" style="font-size:10px;margin-right:3px" onclick="approveDrvReg(\''+esc(d._rid)+'\')">&#10003; Approve</button><button class="sa-btn sa-btn-d" style="font-size:10px" onclick="rejectDrvReg(\''+esc(d._rid)+'\')">&#10007; Reject</button>':'')
        +'</td>'
        +'</tr>';
    }).join('');
    dl.style.display='none';
    dw.style.display='block';
  }).catch(function(e){ document.getElementById('drvreg-loading').textContent='Error: '+e.message; });
}

function approveDrvReg(rid){
  var saEmail=(firebase.auth().currentUser||{}).email||'sa';
  db.ref('driverRegistrations/'+CID+'/'+rid).update({status:'approved',approvedBy:saEmail,approvedAt:Date.now()}).then(function(){
    showNotice('Driver registration approved.','ok'); loadDriverRegistrations();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}
function rejectDrvReg(rid){
  if(!confirm('Reject this driver registration?')) return;
  var saEmail=(firebase.auth().currentUser||{}).email||'sa';
  db.ref('driverRegistrations/'+CID+'/'+rid).update({status:'rejected',rejectedBy:saEmail,rejectedAt:Date.now()}).then(function(){
    showNotice('Driver registration rejected.','ok'); loadDriverRegistrations();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

// ── Per-Company Cash Toggle ───────────────────────────────────────────────────
var _companyCashEnabled = true;

function renderCompanyCashBtn(enabled){
  var btn = document.getElementById('co-cash-btn');
  if(!btn) return;
  _companyCashEnabled = !!enabled;
  btn.textContent = enabled ? '✔ ON' : '✖ OFF';
  btn.style.background = enabled ? '#2E7D32' : '#C62828';
  btn.style.color = '#fff';
}

function loadCompanyCash(){
  _fbGet('companySettings/'+CID+'/paymentMethods/cashEnabled').then(function(data){
    renderCompanyCashBtn(data !== false);
  }).catch(function(){ renderCompanyCashBtn(true); });
}

function toggleCompanyCash(){
  var newVal = !_companyCashEnabled;
  db.ref('companySettings/'+CID+'/paymentMethods/cashEnabled').set(newVal).then(function(){
    renderCompanyCashBtn(newVal);
    var msg = document.getElementById('co-cash-msg');
    if(msg) msg.textContent = 'Cash payments '+(newVal?'enabled':'disabled')+' for this company. Saved at '+new Date().toLocaleTimeString();
  }).catch(function(e){
    var msg = document.getElementById('co-cash-msg');
    if(msg) msg.textContent = 'Error: '+e.message;
  });
}

/* ── ACC Vendor ID ────────────────────────────────── */
function loadAccVendorId(){
  _fbGet('companySettings/'+CID+'/accVendorId').then(function(val){
    var inp = document.getElementById('acc-vendor-input');
    if(inp) inp.value = val || '';
  }).catch(function(){});
}

function saveAccVendorId(){
  var inp = document.getElementById('acc-vendor-input');
  var msg = document.getElementById('acc-vendor-msg');
  var val = (inp ? inp.value : '').trim().toUpperCase();
  if(!val){ if(msg) msg.innerHTML='<span style="color:#c00">Please enter a vendor ID before saving.</span>'; return; }
  db.ref('companySettings/'+CID+'/accVendorId').set(val).then(function(){
    var ts = new Date().toLocaleTimeString();
    var rand = Math.random().toString(36).slice(2,7);
    var saEmail = (firebase.auth().currentUser||{}).email || 'sa-admin';
    db.ref('superAuditLog/LOG'+Date.now()+'_'+rand).set({action:'acc_vendor_id_updated',actor:saEmail,cid:CID,cidName:(companyData&&companyData.name)||CID,detail:'ACC Vendor ID set to '+val,ts:Date.now()});
    if(msg) msg.innerHTML='<span style="color:#2e7d32">&#10003; Saved — <strong>'+esc(val)+'</strong> will appear on all ACC invoices for this company.</span>';
  }).catch(function(e){
    if(msg) msg.innerHTML='<span style="color:#c00">Error: '+esc(e.message)+'</span>';
  });
}

/* ── Stripe Config ───────────────────────────────── */
function renderStripeConnectStatus(data){
  var status = data.connectStatus || 'not_started';
  var badge = document.getElementById('stripe-connect-badge');
  var acctEl = document.getElementById('stripe-connect-account-id');
  var chargesEl = document.getElementById('stripe-connect-charges');
  var sentEl = document.getElementById('stripe-connect-link-sent');
  if(badge){
    badge.className = 'connect-badge connect-' + (status === 'complete' ? 'complete' : status === 'pending' ? 'pending' : 'not-started');
    badge.textContent = status === 'complete' ? 'Complete' : status === 'pending' ? 'Pending' : 'Not started';
  }
  if(acctEl) acctEl.textContent = data.stripeAccountId || '—';
  if(chargesEl) chargesEl.textContent = data.connectChargesEnabled ? 'Yes' : (status === 'complete' ? 'Yes' : 'No');
  if(sentEl) sentEl.textContent = data.connectLinkSentAt ? new Date(data.connectLinkSentAt).toLocaleString('en-NZ') : '—';
}

function loadStripeConfig(){
  fetch('/api/admin/stripe-config/'+encodeURIComponent(CID))
    .then(function(r){ return r.json(); })
    .then(function(data){
      if(!data || data.error){ return; }
      renderStripeConnectStatus(data);
      var pubEl = document.getElementById('stripe-pub-key');
      var secEl = document.getElementById('stripe-secret-key');
      var whEl  = document.getElementById('stripe-webhook-secret');
      var statusEl = document.getElementById('stripe-config-status');
      if(pubEl) pubEl.value = data.stripePublishableKey || '';
      if(secEl) secEl.value = data.stripeSecretKey || '';
      if(whEl)  whEl.value  = data.stripeWebhookSecret || '';
      if(statusEl){
        var hasPub = !!(pubEl && pubEl.value);
        var hasSec = !!(secEl && secEl.value);
        var hasWh  = !!(whEl && whEl.value);
        if(hasPub || hasSec || hasWh){
          statusEl.innerHTML = '<span style="color:#2E7D32">&#10003; Configured</span>'
            + (data.updatedAt ? ' — last saved '+new Date(data.updatedAt).toLocaleString('en-NZ') : '');
        } else {
          statusEl.textContent = 'No Stripe keys saved yet for this company.';
        }
      }
    }).catch(function(){});
}

function resendStripeConnectLink(){
  var msg = document.getElementById('stripe-connect-msg');
  var email = (companyData && companyData.email) || (document.getElementById('f-email')||{}).value || '';
  if(!email){
    if(msg) msg.innerHTML = '<span style="color:#c00">No owner email on file.</span>';
    return;
  }
  if(msg) msg.textContent = 'Sending…';
  var saEmail = (firebase.auth().currentUser||{}).email || 'sa-admin';
  fetch('/api/admin/stripe-connect/resend/'+encodeURIComponent(CID), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: email, companyName: (companyData&&companyData.name)||CID, _saEmail: saEmail })
  }).then(function(r){ return r.json(); }).then(function(d){
    if(!d.ok){
      if(msg) msg.innerHTML = '<span style="color:#c00">Error: '+esc(d.error||'Failed')+'</span>';
      return;
    }
    if(msg) msg.innerHTML = '<span style="color:#2e7d32">&#10003; Onboarding email sent to '+esc(email)+'</span>';
    loadStripeConfig();
  }).catch(function(e){
    if(msg) msg.innerHTML = '<span style="color:#c00">Error: '+esc(e.message||e)+'</span>';
  });
}

function saveStripeConfig(){
  var pub = (document.getElementById('stripe-pub-key').value || '').trim();
  var sec = (document.getElementById('stripe-secret-key').value || '').trim();
  var wh  = (document.getElementById('stripe-webhook-secret').value || '').trim();
  var msg = document.getElementById('stripe-config-msg');
  if(!pub && !sec && !wh){
    if(msg) msg.innerHTML = '<span style="color:#c00">Enter at least one Stripe key before saving.</span>';
    return;
  }
  if(pub && !pub.startsWith('pk_')){
    if(msg) msg.innerHTML = '<span style="color:#c00">Publishable key should start with pk_</span>';
    return;
  }
  if(sec && !sec.startsWith('sk_')){
    if(msg) msg.innerHTML = '<span style="color:#c00">Secret key should start with sk_</span>';
    return;
  }
  if(wh && !wh.startsWith('whsec_')){
    if(msg) msg.innerHTML = '<span style="color:#c00">Webhook secret should start with whsec_</span>';
    return;
  }
  if(msg) msg.innerHTML = '<span style="color:#888">Saving…</span>';
  var saEmail = (firebase.auth().currentUser||{}).email || 'sa-admin';
  fetch('/api/admin/stripe-config/'+encodeURIComponent(CID), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      stripePublishableKey: pub,
      stripeSecretKey: sec,
      stripeWebhookSecret: wh,
      _saEmail: saEmail
    })
  }).then(function(r){ return r.json(); }).then(function(d){
    if(!d.ok){
      if(msg) msg.innerHTML = '<span style="color:#c00">Error: '+esc(d.error||'Save failed')+'</span>';
      showNotice('Save failed: '+(d.error||'unknown'), 'err');
      return;
    }
    if(msg) msg.innerHTML = '<span style="color:#2e7d32">&#10003; Stripe configuration saved for '+esc(companyData.name||CID)+'.</span>';
    showNotice('Stripe keys saved', 'ok');
    loadStripeConfig();
    var rand = Math.random().toString(36).slice(2,7);
    db.ref('superAuditLog/LOG'+Date.now()+'_'+rand).set({
      action: 'stripe_config_updated',
      actor: saEmail,
      cid: CID,
      cidName: (companyData && companyData.name) || CID,
      detail: 'Stripe keys updated (publishable='+(pub?'yes':'no')+', secret='+(sec?'yes':'no')+', webhook='+(wh?'yes':'no')+')',
      ts: Date.now()
    });
  }).catch(function(e){
    if(msg) msg.innerHTML = '<span style="color:#c00">Error: '+esc(e.message||e)+'</span>';
    showNotice('Save failed: '+String(e.message||e), 'err');
  });
}

window._fbOnLogin = function(){
  loadCompany(); loadFeatureFlags(); loadOwnerSettings();
  loadBookings(); loadDriverRegistrations(); loadCompanyCash();
  loadAccVendorId(); loadStripeConfig();
};

/* ── Owner Group Card ─────────────────────────────── */
function loadOwnerGroupCard(){
  var sel=document.getElementById('og-select');
  var cur=document.getElementById('og-current');
  _fbGet('ownerGroups').then(function(groups){
    groups=groups||{};
    sel.innerHTML='<option value="">— No group / standalone —</option>'
      +Object.entries(groups).map(function(e){
        return '<option value="'+e[0]+'">'+escHtml(e[1].groupName||e[0])+'  ('+escHtml(e[1].ownerName||'')+')</option>';
      }).join('');
    var currentGroupId=companyData.ownerGroupId||'';
    sel.value=currentGroupId;
    if(currentGroupId&&groups[currentGroupId]){
      var g=groups[currentGroupId];
      cur.innerHTML='<span style="background:#F3E5F5;color:#4A148C;padding:3px 10px;border-radius:8px;font-weight:600;font-size:13px">&#128101; '+escHtml(g.groupName||currentGroupId)+'</span>'
        +' <span style="color:#888;font-size:12px">Owner: '+escHtml(g.ownerName||'')+'</span>';
    } else {
      cur.textContent='This company is not part of any owner group.';
    }
  });
}

function saveOwnerGroup(){
  var sel=document.getElementById('og-select');
  var msg=document.getElementById('og-msg');
  var newGroupId=sel.value;
  var oldGroupId=companyData.ownerGroupId||'';
  msg.style.color='#888'; msg.textContent='Saving…';
  var writes=[];
  if(oldGroupId&&oldGroupId!==newGroupId){
    writes.push(db.ref('ownerGroups/'+oldGroupId+'/companyIds/'+CID).remove());
  }
  if(newGroupId){
    writes.push(db.ref('superClients/'+CID+'/ownerGroupId').set(newGroupId));
    writes.push(db.ref('ownerGroups/'+newGroupId+'/companyIds/'+CID).set(true));
  } else {
    writes.push(db.ref('superClients/'+CID+'/ownerGroupId').remove());
  }
  Promise.all(writes).then(function(){
    companyData.ownerGroupId=newGroupId||null;
    msg.style.color='#2E7D32'; msg.textContent='Saved ✓';
    loadOwnerGroupCard();
    showNotice('Owner group updated.','ok');
  }).catch(function(e){ msg.style.color='#C62828'; msg.textContent='Error: '+e.message; });
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
