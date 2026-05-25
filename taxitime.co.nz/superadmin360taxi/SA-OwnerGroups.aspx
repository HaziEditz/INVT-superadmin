<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Owner Groups &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}.sa-btn-s:hover{background:#C8E6C9}
.sa-btn-w{background:#FFF9C4;color:#F57F17;border:1px solid #FFF176}.sa-btn-w:hover{background:#FFF176}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-grp{background:#4A148C;color:#fff}.sa-btn-grp:hover{background:#38006b}
.sa-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.sa-ff input:focus,.sa-ff select:focus,.sa-ff textarea:focus{outline:none;border-color:#4A148C}
.add-form{display:none;padding:18px;background:#F3E5F5;border-top:1px solid #CE93D8}
.add-form.open{display:block}
.add-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:12px;margin-bottom:14px}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:9999;align-items:center;justify-content:center;padding:20px}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:14px;box-shadow:0 20px 60px rgba(0,0,0,.3);padding:28px;width:100%;max-width:700px;max-height:90vh;overflow-y:auto}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.section-hdr{font-size:12px;font-weight:700;color:#4A148C;text-transform:uppercase;letter-spacing:.05em;margin:16px 0 8px}
.detail-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:8px;margin-bottom:8px}
.detail-item{background:#F8F9FA;border-radius:6px;padding:8px 10px}
.detail-item label{display:block;font-size:10px;color:#9E9E9E;text-transform:uppercase;font-weight:700;margin-bottom:2px}
.detail-item span{font-size:13px;color:#263238;font-weight:500;word-break:break-all}
.company-chip{display:inline-flex;align-items:center;gap:6px;background:#E3F2FD;border:1px solid #BBDEFB;border-radius:20px;padding:4px 10px;font-size:12px;font-weight:600;color:#1565C0;margin:3px}
.company-chip .rm{cursor:pointer;color:#C62828;font-weight:700;font-size:14px;line-height:1}
.driver-chip{display:inline-flex;align-items:center;gap:6px;background:#F3E5F5;border:1px solid #CE93D8;border-radius:20px;padding:4px 10px;font-size:12px;font-weight:600;color:#4A148C;margin:3px}
.driver-chip .rm{cursor:pointer;color:#C62828;font-weight:700;font-size:14px;line-height:1}
.grp-badge{background:#F3E5F5;color:#4A148C;font-size:10px;font-weight:700;padding:2px 7px;border-radius:8px;border:1px solid #CE93D8;white-space:nowrap}
.stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.stat-box{background:#F3E5F5;border-radius:8px;padding:12px;text-align:center}
.stat-box .sv{font-size:22px;font-weight:700;color:#4A148C}
.stat-box .sl{font-size:11px;color:#7B1FA2;margin-top:2px}
.billing-row{display:flex;justify-content:space-between;align-items:center;padding:6px 0;border-bottom:1px solid #f0f0f0;font-size:13px}
.billing-row:last-child{border-bottom:none;font-weight:700;padding-top:10px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Owner Groups &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-OwnerGroups.aspx" style="font-weight:700;color:#4A148C">&#9658; Owner Groups</a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#128101; Owner Groups</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">
  Link multiple companies under one owner. One login, separate company views. Shared driver pool across sibling companies. Combined billing overview.
</p>

<div id="sa-notice" style="display:none" class="sa-notice"></div>

<!-- ═══ Groups List Card ═══ -->
<div class="sa-card">
  <div class="sa-bar" style="background:#4A148C">
    <h3>&#128101; Registered Owner Groups</h3>
    <div style="display:flex;gap:6px;flex-wrap:wrap">
      <span id="grp-count" style="font-size:12px;opacity:.8;align-self:center"></span>
      <button class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px" onclick="toggleAddForm()">&#43; New Group</button>
    </div>
  </div>

  <!-- Add Group Form -->
  <div class="add-form" id="add-form">
    <div style="font-size:13px;font-weight:600;color:#4A148C;margin-bottom:12px">&#43; Create New Owner Group</div>
    <div class="add-grid">
      <div class="sa-ff"><label>Group / Business Name <span style="color:#C62828">*</span></label><input id="af-name" placeholder="e.g. Smith Holdings Ltd"/></div>
      <div class="sa-ff"><label>Owner Full Name <span style="color:#C62828">*</span></label><input id="af-owner" placeholder="e.g. John Smith"/></div>
      <div class="sa-ff"><label>Owner Email <span style="color:#C62828">*</span></label><input id="af-email" type="email" placeholder="john@example.co.nz"/></div>
      <div class="sa-ff"><label>Owner Phone</label><input id="af-phone" placeholder="+64 21 000 0000"/></div>
      <div class="sa-ff"><label>Primary City</label><input id="af-city" placeholder="e.g. Auckland"/></div>
      <div class="sa-ff"><label>Notes</label><input id="af-notes" placeholder="Optional internal notes"/></div>
    </div>
    <div style="font-size:12px;color:#7B1FA2;margin-bottom:10px">&#9432; After creating the group you can link companies and add shared drivers from the group detail view.</div>
    <div style="display:flex;gap:8px;align-items:center">
      <button class="sa-btn sa-btn-grp" onclick="createGroup()">&#10003; Create Group</button>
      <button class="sa-btn sa-btn-n" onclick="toggleAddForm()">Cancel</button>
      <span id="af-msg" style="font-size:12px;color:#C62828"></span>
    </div>
  </div>

  <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead><tr>
        <th>Group Name</th>
        <th>Owner</th>
        <th>Companies</th>
        <th>Shared Drivers</th>
        <th>Primary City</th>
        <th>Created</th>
        <th>Actions</th>
      </tr></thead>
      <tbody id="grp-tbody">
        <tr id="grp-empty"><td colspan="7" style="text-align:center;padding:30px;color:#aaa">Loading groups&#8230;</td></tr>
      </tbody>
    </table>
  </div>
</div>

<!-- ═══ Group Detail Modal ═══ -->
<div id="modal-group" class="modal-overlay">
  <div class="modal-box">
    <!-- Header -->
    <div style="display:flex;align-items:flex-start;gap:14px;margin-bottom:18px">
      <div style="width:48px;height:48px;border-radius:50%;background:#4A148C;color:#fff;display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0">&#128101;</div>
      <div style="flex:1">
        <div id="md-grp-name" style="font-size:18px;font-weight:700;color:#4A148C"></div>
        <div id="md-grp-owner" style="font-size:13px;color:#888;margin-top:2px"></div>
      </div>
      <button class="sa-btn sa-btn-n" onclick="closeGroupModal()" style="align-self:flex-start">&#10005;</button>
    </div>

    <!-- Stats row -->
    <div class="stat-row" id="md-stats"></div>

    <!-- Tabs -->
    <div style="display:flex;gap:0;border-bottom:2px solid #E0E0E0;margin-bottom:14px">
      <button class="grp-tab-btn active" id="tab-btn-info" onclick="showTab('info')" style="padding:8px 16px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:600;color:#4A148C;border-bottom:2px solid #4A148C;margin-bottom:-2px">&#8505; Info</button>
      <button class="grp-tab-btn" id="tab-btn-companies" onclick="showTab('companies')" style="padding:8px 16px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:600;color:#aaa;border-bottom:2px solid transparent;margin-bottom:-2px">&#127970; Companies</button>
      <button class="grp-tab-btn" id="tab-btn-drivers" onclick="showTab('drivers')" style="padding:8px 16px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:600;color:#aaa;border-bottom:2px solid transparent;margin-bottom:-2px">&#128101; Shared Drivers</button>
      <button class="grp-tab-btn" id="tab-btn-billing" onclick="showTab('billing')" style="padding:8px 16px;border:none;background:none;cursor:pointer;font-size:13px;font-weight:600;color:#aaa;border-bottom:2px solid transparent;margin-bottom:-2px">&#128181; Billing</button>
    </div>

    <!-- Tab: Info -->
    <div id="tab-info">
      <div class="section-hdr">Group Details</div>
      <div class="detail-grid" id="md-info-grid"></div>
      <div class="section-hdr" style="margin-top:14px">Edit Group Info</div>
      <div class="add-grid" style="grid-template-columns:repeat(auto-fill,minmax(180px,1fr))">
        <div class="sa-ff"><label>Group Name</label><input id="ed-name"/></div>
        <div class="sa-ff"><label>Owner Name</label><input id="ed-owner"/></div>
        <div class="sa-ff"><label>Owner Email</label><input id="ed-email" type="email"/></div>
        <div class="sa-ff"><label>Owner Phone</label><input id="ed-phone"/></div>
        <div class="sa-ff"><label>Primary City</label><input id="ed-city"/></div>
        <div class="sa-ff"><label>Notes</label><input id="ed-notes"/></div>
      </div>
      <div style="display:flex;gap:8px;align-items:center;margin-top:8px">
        <button class="sa-btn sa-btn-grp" onclick="saveGroupInfo()">&#10003; Save Changes</button>
        <button class="sa-btn sa-btn-d" onclick="deleteGroup()">&#128465; Delete Group</button>
        <span id="md-info-msg" style="font-size:12px"></span>
      </div>
    </div>

    <!-- Tab: Companies -->
    <div id="tab-companies" style="display:none">
      <div class="section-hdr">Linked Companies</div>
      <div id="md-company-chips" style="margin-bottom:12px;min-height:32px"></div>
      <div style="background:#F3E5F5;border-radius:6px;padding:12px;margin-bottom:12px">
        <div style="font-size:12px;font-weight:600;color:#4A148C;margin-bottom:8px">&#43; Link a Company to this Group</div>
        <div style="display:flex;gap:8px;align-items:flex-end">
          <div class="sa-ff" style="flex:1;margin:0">
            <label>Select Company</label>
            <select id="link-co-select"><option value="">— choose company —</option></select>
          </div>
          <button class="sa-btn sa-btn-grp" onclick="linkCompany()">Link</button>
        </div>
        <div id="md-co-msg" style="font-size:12px;color:#C62828;margin-top:6px"></div>
      </div>
      <div style="font-size:11.5px;color:#9E9E9E">&#9432; Linking a company writes <code>ownerGroupId</code> to that company's record. Removing it clears the field.</div>
    </div>

    <!-- Tab: Shared Drivers -->
    <div id="tab-drivers" style="display:none">
      <div class="section-hdr">Shared Drivers</div>
      <p style="font-size:12px;color:#7B1FA2;margin-bottom:10px">Shared drivers can receive jobs from any company in this group, not just their home company. Dispatch must check <code>driver.sharedWith</code> when building the available-driver pool.</p>
      <div id="md-driver-chips" style="margin-bottom:12px;min-height:32px"></div>
      <div style="background:#F3E5F5;border-radius:6px;padding:12px;margin-bottom:12px">
        <div style="font-size:12px;font-weight:600;color:#4A148C;margin-bottom:8px">&#43; Add Shared Driver</div>
        <div style="display:flex;gap:8px;align-items:flex-end">
          <div class="sa-ff" style="flex:1;margin:0">
            <label>Select Driver (from linked companies)</label>
            <select id="link-drv-select"><option value="">— choose driver —</option></select>
          </div>
          <button class="sa-btn sa-btn-grp" onclick="linkDriver()">Add</button>
        </div>
        <div id="md-drv-msg" style="font-size:12px;color:#C62828;margin-top:6px"></div>
      </div>
      <div style="font-size:11.5px;color:#9E9E9E">&#9432; This writes <code>sharedWith: [cid1, cid2, ...]</code> to the driver's Firebase record. Dispatch and Driver App devs read this to allow cross-company jobs.</div>
    </div>

    <!-- Tab: Billing -->
    <div id="tab-billing" style="display:none">
      <div class="section-hdr">Combined Billing Summary</div>
      <p style="font-size:12px;color:#7B1FA2;margin-bottom:10px">Totals are pulled from each linked company's billing records. This is a read-only overview — individual invoices are managed in SA-Billing per company.</p>
      <div id="md-billing-list"></div>
    </div>

    <div id="md-grp-msg" style="font-size:12px;color:#C62828;margin-top:10px;text-align:right"></div>
  </div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var SUPER_PATH = 'superClients';
var GROUPS_PATH = 'ownerGroups';
var SA_CID = null; // SA admins are role-based — no company ID

var allGroups = {};       // { groupId: groupData }
var allCompanies = {};    // { cid: companyData }
var allDriversMap = {};   // { uid: driverData }
var currentGroupId = null;
var addFormOpen = false;

/* ── Auth guard ───────────────────────────────────── */
firebase.auth().onAuthStateChanged(function(user){
  if (!user) { window.location.href = 'SA-Login.aspx'; return; }
  loadData();
});

/* ── Load ─────────────────────────────────────────── */
function loadData() {
  _fbGet(SUPER_PATH).then(function(data){
    allCompanies = data || {};
    loadGroups();
  });
  _fbGet('drivers').then(function(data){
    allDriversMap = {};
    data = data || {};
    Object.keys(data).forEach(function(k){ allDriversMap[k] = Object.assign({_uid: k}, data[k]); });
  });
}

function loadGroups() {
  _fbGet(GROUPS_PATH).then(function(data){
    allGroups = data || {};
    renderGroups();
  });
}

/* ── Notice ───────────────────────────────────────── */
function showNotice(msg, type){
  var n = document.getElementById('sa-notice');
  n.className = 'sa-notice ' + type;
  n.textContent = msg;
  n.style.display = 'block';
  setTimeout(function(){ n.style.display = 'none'; }, 5000);
}

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

/* ── Render groups table ──────────────────────────── */
function renderGroups() {
  var entries = Object.entries(allGroups);
  document.getElementById('grp-count').textContent = entries.length + ' group(s)';
  var tbody = document.getElementById('grp-tbody');
  if (!entries.length) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:30px;color:#aaa">No owner groups yet. Click <strong>+ New Group</strong> to create one.</td></tr>';
    return;
  }
  tbody.innerHTML = entries.map(function(e){
    var id = e[0], g = e[1];
    var cids = Object.keys(g.companyIds || {});
    var coNames = cids.map(function(c){ return (allCompanies[c] && allCompanies[c].name) ? allCompanies[c].name : c; }).join(', ');
    var sharedDrvCount = countSharedDrivers(id);
    return '<tr>'
      +'<td><div style="font-weight:700;color:#4A148C">'+esc(g.groupName||'—')+'</div>'
        +(g.primaryCity ? '<div style="font-size:11px;color:#aaa">'+esc(g.primaryCity)+'</div>' : '')+'</td>'
      +'<td><div style="font-weight:500">'+esc(g.ownerName||'—')+'</div><div style="font-size:11px;color:#aaa">'+esc(g.ownerEmail||'')+'</div></td>'
      +'<td><span class="grp-badge">'+cids.length+' co.</span> <span style="font-size:11px;color:#555">'+esc(coNames.slice(0,60)+(coNames.length>60?'…':''))+'</span></td>'
      +'<td style="text-align:center"><span class="grp-badge">'+sharedDrvCount+'</span></td>'
      +'<td>'+esc(g.primaryCity||'—')+'</td>'
      +'<td style="font-size:11px;color:#aaa">'+(g.createdAt ? new Date(g.createdAt).toLocaleDateString('en-NZ') : '—')+'</td>'
      +'<td><button class="sa-btn sa-btn-grp" style="font-size:11px;padding:4px 9px" onclick="openGroupModal(\''+esc(id)+'\')">&#128065; View</button></td>'
      +'</tr>';
  }).join('');
}

function countSharedDrivers(groupId) {
  return Object.values(allDriversMap).filter(function(d){
    return Array.isArray(d.sharedWith) && d.sharedWith.length > 0
      && Object.keys(allGroups[groupId] && allGroups[groupId].companyIds || {}).some(function(cid){ return d.sharedWith.indexOf(cid) > -1; });
  }).length;
}

/* ── Add form ─────────────────────────────────────── */
function toggleAddForm() {
  addFormOpen = !addFormOpen;
  document.getElementById('add-form').classList.toggle('open', addFormOpen);
  if (addFormOpen) document.getElementById('af-name').focus();
}

function createGroup() {
  var name = (document.getElementById('af-name').value || '').trim();
  var owner = (document.getElementById('af-owner').value || '').trim();
  var email = (document.getElementById('af-email').value || '').trim();
  var phone = (document.getElementById('af-phone').value || '').trim();
  var city = (document.getElementById('af-city').value || '').trim();
  var notes = (document.getElementById('af-notes').value || '').trim();
  var msg = document.getElementById('af-msg');
  if (!name || !owner || !email) { msg.textContent = 'Group name, owner name and email are required.'; return; }
  msg.textContent = 'Creating…';
  var newRef = db.ref(GROUPS_PATH).push();
  newRef.set({
    groupName: name,
    ownerName: owner,
    ownerEmail: email,
    ownerPhone: phone,
    primaryCity: city,
    notes: notes,
    companyIds: {},
    createdAt: Date.now()
  }).then(function(){
    msg.textContent = '';
    ['af-name','af-owner','af-email','af-phone','af-city','af-notes'].forEach(function(id){ document.getElementById(id).value=''; });
    toggleAddForm();
    showNotice('Owner group "'+name+'" created.', 'ok');
  }).catch(function(e){ msg.textContent = 'Error: '+e.message; });
}

/* ── Group Modal ──────────────────────────────────── */
function openGroupModal(groupId) {
  currentGroupId = groupId;
  var g = allGroups[groupId];
  if (!g) return;

  document.getElementById('md-grp-name').textContent = g.groupName || '—';
  document.getElementById('md-grp-owner').textContent = '&#128100; '+(g.ownerName||'')+'  '+(g.ownerEmail ? '&#9993; '+g.ownerEmail : '');

  var cids = Object.keys(g.companyIds || {});
  var sharedCount = countSharedDrivers(groupId);

  document.getElementById('md-stats').innerHTML = [
    {v: cids.length, l: 'Companies'},
    {v: sharedCount, l: 'Shared Drivers'},
    {v: cids.reduce(function(a,c){ return a + (allCompanies[c] ? 1 : 0); },0), l: 'Active Companies'},
    {v: g.primaryCity||'—', l: 'Primary City'}
  ].map(function(s){
    return '<div class="stat-box"><div class="sv">'+esc(String(s.v))+'</div><div class="sl">'+esc(s.l)+'</div></div>';
  }).join('');

  document.getElementById('md-info-grid').innerHTML = [
    ['Group Name', g.groupName], ['Owner Name', g.ownerName],
    ['Owner Email', g.ownerEmail], ['Owner Phone', g.ownerPhone||'—'],
    ['Primary City', g.primaryCity||'—'], ['Notes', g.notes||'—'],
    ['Created', g.createdAt ? new Date(g.createdAt).toLocaleDateString('en-NZ') : '—'],
    ['Group ID', groupId]
  ].map(function(r){
    return '<div class="detail-item"><label>'+esc(r[0])+'</label><span>'+esc(r[1]||'—')+'</span></div>';
  }).join('');

  document.getElementById('ed-name').value = g.groupName || '';
  document.getElementById('ed-owner').value = g.ownerName || '';
  document.getElementById('ed-email').value = g.ownerEmail || '';
  document.getElementById('ed-phone').value = g.ownerPhone || '';
  document.getElementById('ed-city').value = g.primaryCity || '';
  document.getElementById('ed-notes').value = g.notes || '';

  renderCompanyChips(groupId);
  renderDriverChips(groupId);
  populateLinkCompanySelect(groupId);
  populateLinkDriverSelect(groupId);
  renderBilling(groupId);

  document.getElementById('md-grp-msg').textContent = '';
  showTab('info');
  document.getElementById('modal-group').classList.add('open');
}

function closeGroupModal() {
  document.getElementById('modal-group').classList.remove('open');
  currentGroupId = null;
}

/* ── Tabs ─────────────────────────────────────────── */
function showTab(name) {
  ['info','companies','drivers','billing'].forEach(function(t){
    document.getElementById('tab-'+t).style.display = (t===name) ? '' : 'none';
    var btn = document.getElementById('tab-btn-'+t);
    if (btn) {
      btn.style.color = (t===name) ? '#4A148C' : '#aaa';
      btn.style.borderBottomColor = (t===name) ? '#4A148C' : 'transparent';
    }
  });
}

/* ── Company Chips ────────────────────────────────── */
function renderCompanyChips(groupId) {
  var g = allGroups[groupId];
  var cids = Object.keys((g && g.companyIds) || {});
  var el = document.getElementById('md-company-chips');
  if (!cids.length) { el.innerHTML = '<span style="font-size:12px;color:#aaa">No companies linked yet.</span>'; return; }
  el.innerHTML = cids.map(function(cid){
    var name = (allCompanies[cid] && allCompanies[cid].name) ? allCompanies[cid].name : cid;
    return '<span class="company-chip">'
      +'<span>&#127970; '+esc(name)+'</span>'
      +'<span class="rm" title="Unlink" onclick="unlinkCompany(\''+esc(cid)+'\')">&#215;</span>'
      +'</span>';
  }).join('');
}

function populateLinkCompanySelect(groupId) {
  var g = allGroups[groupId];
  var linked = Object.keys((g && g.companyIds) || {});
  var sel = document.getElementById('link-co-select');
  var unlinked = Object.entries(allCompanies).filter(function(e){ return linked.indexOf(e[0]) === -1; });
  sel.innerHTML = '<option value="">— choose company —</option>'
    + unlinked.map(function(e){ return '<option value="'+esc(e[0])+'">'+esc(e[1].name||e[0])+' ('+esc(e[0])+')</option>'; }).join('');
}

function linkCompany() {
  var cid = document.getElementById('link-co-select').value;
  var msg = document.getElementById('md-co-msg');
  if (!cid || !currentGroupId) { msg.textContent = 'Select a company first.'; return; }
  msg.textContent = 'Linking…';
  var writes = [
    db.ref(GROUPS_PATH+'/'+currentGroupId+'/companyIds/'+cid).set(true),
    db.ref(SUPER_PATH+'/'+cid+'/ownerGroupId').set(currentGroupId)
  ];
  Promise.all(writes).then(function(){
    if (!allGroups[currentGroupId].companyIds) allGroups[currentGroupId].companyIds = {};
    allGroups[currentGroupId].companyIds[cid] = true;
    renderCompanyChips(currentGroupId);
    populateLinkCompanySelect(currentGroupId);
    populateLinkDriverSelect(currentGroupId);
    msg.textContent = '';
    showNotice((allCompanies[cid]&&allCompanies[cid].name ? allCompanies[cid].name : cid)+' linked to group.','ok');
  }).catch(function(e){ msg.textContent = 'Error: '+e.message; });
}

function unlinkCompany(cid) {
  if (!confirm('Unlink this company from the group? Their ownerGroupId will be cleared.')) return;
  var writes = [
    db.ref(GROUPS_PATH+'/'+currentGroupId+'/companyIds/'+cid).remove(),
    db.ref(SUPER_PATH+'/'+cid+'/ownerGroupId').remove()
  ];
  Promise.all(writes).then(function(){
    if (allGroups[currentGroupId] && allGroups[currentGroupId].companyIds) delete allGroups[currentGroupId].companyIds[cid];
    renderCompanyChips(currentGroupId);
    populateLinkCompanySelect(currentGroupId);
    populateLinkDriverSelect(currentGroupId);
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

/* ── Driver Chips ─────────────────────────────────── */
function renderDriverChips(groupId) {
  var g = allGroups[groupId];
  var cids = Object.keys((g && g.companyIds) || {});
  var el = document.getElementById('md-driver-chips');
  var shared = Object.values(allDriversMap).filter(function(d){
    return Array.isArray(d.sharedWith) && cids.some(function(cid){ return d.sharedWith.indexOf(cid) > -1; });
  });
  if (!shared.length) { el.innerHTML = '<span style="font-size:12px;color:#aaa">No shared drivers yet.</span>'; return; }
  el.innerHTML = shared.map(function(d){
    var name = [d.firstName||d.first_name||'', d.lastName||d.last_name||''].join(' ').trim() || d._uid;
    var home = (allCompanies[d.companyId] && allCompanies[d.companyId].name) ? allCompanies[d.companyId].name : d.companyId;
    return '<span class="driver-chip">'
      +'<span>&#128100; '+esc(name)+' <span style="font-size:10px;opacity:.7">('+esc(home)+')</span></span>'
      +'<span class="rm" title="Remove sharing" onclick="unlinkDriver(\''+esc(d._uid)+'\')">&#215;</span>'
      +'</span>';
  }).join('');
}

function populateLinkDriverSelect(groupId) {
  var g = allGroups[groupId];
  var cids = Object.keys((g && g.companyIds) || {});
  var sel = document.getElementById('link-drv-select');
  var eligible = Object.values(allDriversMap).filter(function(d){
    return cids.indexOf(d.companyId) > -1;
  });
  var alreadyShared = Object.values(allDriversMap).filter(function(d){
    return Array.isArray(d.sharedWith) && cids.some(function(c){ return d.sharedWith.indexOf(c) > -1; });
  }).map(function(d){ return d._uid; });
  var notYet = eligible.filter(function(d){ return alreadyShared.indexOf(d._uid) === -1; });
  sel.innerHTML = '<option value="">— choose driver —</option>'
    + notYet.map(function(d){
      var name = [d.firstName||d.first_name||'', d.lastName||d.last_name||''].join(' ').trim() || d._uid;
      var co = (allCompanies[d.companyId] && allCompanies[d.companyId].name) ? allCompanies[d.companyId].name : d.companyId;
      return '<option value="'+esc(d._uid)+'">'+esc(name)+' — '+esc(co)+'</option>';
    }).join('');
}

function linkDriver() {
  var uid = document.getElementById('link-drv-select').value;
  var msg = document.getElementById('md-drv-msg');
  if (!uid || !currentGroupId) { msg.textContent = 'Select a driver first.'; return; }
  var g = allGroups[currentGroupId];
  var cids = Object.keys((g && g.companyIds) || {});
  var d = allDriversMap[uid];
  if (!d) { msg.textContent = 'Driver not found.'; return; }
  var homeCid = d.companyId;
  var siblingCids = cids.filter(function(c){ return c !== homeCid; });
  if (!siblingCids.length) { msg.textContent = 'No sibling companies to share with — link more companies first.'; return; }
  msg.textContent = 'Adding…';
  db.ref('drivers/'+uid+'/sharedWith').set(siblingCids).then(function(){
    if (allDriversMap[uid]) allDriversMap[uid].sharedWith = siblingCids;
    renderDriverChips(currentGroupId);
    populateLinkDriverSelect(currentGroupId);
    msg.textContent = '';
    showNotice('Driver added to shared pool.','ok');
  }).catch(function(e){ msg.textContent = 'Error: '+e.message; });
}

function unlinkDriver(uid) {
  if (!confirm('Remove this driver from the shared pool? They will only receive jobs from their home company.')) return;
  db.ref('drivers/'+uid+'/sharedWith').remove().then(function(){
    if (allDriversMap[uid]) allDriversMap[uid].sharedWith = null;
    renderDriverChips(currentGroupId);
    populateLinkDriverSelect(currentGroupId);
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

/* ── Billing Summary ──────────────────────────────── */
function renderBilling(groupId) {
  var g = allGroups[groupId];
  var cids = Object.keys((g && g.companyIds) || {});
  var el = document.getElementById('md-billing-list');
  if (!cids.length) { el.innerHTML = '<p style="color:#aaa;font-size:12px">No companies linked. Link companies to see combined billing.</p>'; return; }
  el.innerHTML = '<p style="font-size:12px;color:#7B1FA2;margin-bottom:10px">Loading billing data&#8230;</p>';
  var rows = [];
  var done = 0;
  var total = 0;
  cids.forEach(function(cid){
    _fbGet('billing/'+cid).then(function(data){
      data = data || {};
      var outstanding = 0;
      Object.values(data).forEach(function(inv){
        if (inv && inv.status === 'unpaid') outstanding += (inv.amount || 0);
      });
      var name = (allCompanies[cid] && allCompanies[cid].name) ? allCompanies[cid].name : cid;
      total += outstanding;
      rows.push({name: name, amount: outstanding, cid: cid});
      done++;
      if (done === cids.length) {
        rows.sort(function(a,b){ return b.amount - a.amount; });
        el.innerHTML = rows.map(function(r){
          return '<div class="billing-row">'
            +'<span>&#127970; '+esc(r.name)+'</span>'
            +'<span style="font-weight:600;color:'+(r.amount>0?'#C62828':'#2E7D32')+'">$'+r.amount.toFixed(2)+' outstanding</span>'
            +'</div>';
        }).join('')
        +'<div class="billing-row" style="margin-top:6px;border-top:2px solid #4A148C;padding-top:10px">'
          +'<span style="color:#4A148C">&#128181; Group Total Outstanding</span>'
          +'<span style="color:#4A148C;font-size:16px">$'+total.toFixed(2)+'</span>'
          +'</div>';
      }
    });
  });
}

/* ── Save / Delete group info ─────────────────────── */
function saveGroupInfo() {
  if (!currentGroupId) return;
  var msg = document.getElementById('md-info-msg');
  msg.style.color = '#555'; msg.textContent = 'Saving…';
  db.ref(GROUPS_PATH+'/'+currentGroupId).update({
    groupName: document.getElementById('ed-name').value.trim(),
    ownerName: document.getElementById('ed-owner').value.trim(),
    ownerEmail: document.getElementById('ed-email').value.trim(),
    ownerPhone: document.getElementById('ed-phone').value.trim(),
    primaryCity: document.getElementById('ed-city').value.trim(),
    notes: document.getElementById('ed-notes').value.trim()
  }).then(function(){
    msg.style.color = '#2E7D32'; msg.textContent = 'Saved ✓';
    document.getElementById('md-grp-name').textContent = document.getElementById('ed-name').value.trim();
  }).catch(function(e){ msg.style.color = '#C62828'; msg.textContent = 'Error: '+e.message; });
}

function deleteGroup() {
  if (!currentGroupId) return;
  var g = allGroups[currentGroupId];
  var name = (g && g.groupName) ? g.groupName : currentGroupId;
  if (!confirm('Delete owner group "'+name+'"?\n\nThis will remove the group record. Linked companies will have their ownerGroupId cleared. Shared drivers will keep their sharedWith values — remove them manually if needed.')) return;
  var cids = Object.keys((g && g.companyIds) || {});
  var writes = cids.map(function(cid){ return db.ref(SUPER_PATH+'/'+cid+'/ownerGroupId').remove(); });
  writes.push(db.ref(GROUPS_PATH+'/'+currentGroupId).remove());
  Promise.all(writes).then(function(){
    closeGroupModal();
    showNotice('Group "'+name+'" deleted.','ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

document.getElementById('modal-group').addEventListener('click', function(e){ if(e.target===this) closeGroupModal(); });
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
