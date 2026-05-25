<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Dashboard &mdash; BookaWaka Admin</title>
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
/* ── Dashboard Layout ──────────────────────────────── */
.db-wrap{padding:20px}
.db-greeting{font-size:20px;font-weight:700;color:#263238;margin-bottom:4px}
.db-sub{font-size:13px;color:#90A4AE;margin-bottom:20px}

/* ── KPI Cards ─────────────────────────────────────── */
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;margin-bottom:22px}
.kpi{background:#fff;border-radius:8px;box-shadow:0 1px 5px rgba(0,0,0,.1);padding:18px 20px;border-left:5px solid #1565C0;cursor:pointer;transition:.15s;text-decoration:none;display:block;color:inherit}
.kpi:hover{box-shadow:0 3px 12px rgba(0,0,0,.15);transform:translateY(-2px);text-decoration:none;color:inherit}
.kpi.orange{border-left-color:#1565C0}
.kpi.yellow{border-left-color:#F9A825}
.kpi.green{border-left-color:#2E7D32}
.kpi.red{border-left-color:#C62828}
.kpi.blue{border-left-color:#1565C0}
.kpi.teal{border-left-color:#00695C}
.kpi-val{font-size:32px;font-weight:700;line-height:1;color:#263238}
.kpi-lbl{font-size:12px;color:#90A4AE;margin-top:6px;font-weight:500}
.kpi-sub{font-size:11.5px;color:#BDBDBD;margin-top:3px}
.kpi-icon{float:right;font-size:36px;opacity:.12;margin-top:-4px}

/* ── Section Cards ──────────────────────────────────── */
.db-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:18px;overflow:hidden}
.db-card-hdr{padding:12px 18px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #f5f5f5}
.db-card-hdr h3{margin:0;font-size:14px;font-weight:700;color:#263238}
.db-card-hdr a{font-size:12px;color:#1565C0;text-decoration:none;font-weight:600}
.db-card-hdr a:hover{text-decoration:underline}
.db-card-body{padding:16px 18px}

/* ── Module Activity Row ────────────────────────────── */
.mod-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:14px;margin-bottom:18px}
.mod-panel{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.1);padding:18px;position:relative;overflow:hidden}
.mod-panel::before{content:'';position:absolute;top:0;left:0;right:0;height:4px}
.mod-panel.taxi::before{background:#1565C0}
.mod-panel.food::before{background:#F9A825}
.mod-panel.freight::before{background:#37474F}
.mod-title{font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#90A4AE;margin-bottom:10px}
.mod-big{font-size:28px;font-weight:700;color:#263238}
.mod-detail{font-size:12px;color:#aaa;margin-top:4px}
.mod-link{font-size:12px;color:#1565C0;text-decoration:none;font-weight:600;margin-top:8px;display:inline-block}
.mod-link:hover{text-decoration:underline}
.mod-badge{position:absolute;top:14px;right:14px;width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:18px;opacity:.15}
.mod-badge.taxi{background:#1565C0}
.mod-badge.food{background:#F9A825}
.mod-badge.freight{background:#37474F}

/* ── Attention section ──────────────────────────────── */
.attn-empty{text-align:center;padding:24px;color:#C8E6C9;font-size:13px}
.attn-row{display:flex;align-items:center;justify-content:space-between;padding:9px 0;border-bottom:1px solid #f9f9f9;font-size:13px;flex-wrap:wrap;gap:6px}
.attn-row:last-child{border-bottom:none}
.attn-lbl{font-weight:600;color:#263238}
.attn-meta{color:#aaa;font-size:12px}
.attn-btn{padding:4px 12px;border-radius:4px;font-size:12px;font-weight:600;border:none;cursor:pointer;text-decoration:none;display:inline-block}
.attn-btn-red{background:#FFEBEE;color:#C62828}
.attn-btn-amber{background:#FFF8E1;color:#F57F17}
.attn-btn-blue{background:#E3F2FD;color:#1565C0}

/* ── Companies table ────────────────────────────────── */
.co-tbl{width:100%;border-collapse:collapse;font-size:13px}
.co-tbl th{background:#E3F2FD;padding:8px 10px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;color:#0D47A1;white-space:nowrap;font-size:12px}
.co-tbl td{padding:7px 10px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.co-tbl tr:hover td{background:#FFFDE7}
.co-tbl a{color:#1565C0;text-decoration:none;font-weight:600}
.mod-chip{display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600;margin-right:2px}
.chip-on{background:#E8F5E9;color:#2E7D32}
.chip-off{background:#f5f5f5;color:#ccc}
.badge-active{background:#E8F5E9;color:#2E7D32;font-size:11px;padding:2px 8px;border-radius:10px;font-weight:700}
.badge-suspended{background:#FFEBEE;color:#C62828;font-size:11px;padding:2px 8px;border-radius:10px;font-weight:700}

/* ── Activity Feed ──────────────────────────────────── */
.feed-item{display:flex;align-items:flex-start;gap:12px;padding:10px 0;border-bottom:1px solid #f5f5f5;font-size:13px}
.feed-item:last-child{border-bottom:none}
.feed-dot{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;margin-top:1px}
.feed-dot.orange{background:#E3F2FD;color:#1565C0}
.feed-dot.green{background:#E8F5E9;color:#2E7D32}
.feed-dot.amber{background:#FFF8E1;color:#F57F17}
.feed-dot.red{background:#FFEBEE;color:#C62828}
.feed-dot.blue{background:#E3F2FD;color:#1565C0}
.feed-msg{flex:1;color:#263238;font-weight:500}
.feed-time{font-size:11.5px;color:#BDBDBD;margin-top:2px}

/* ── Two column layout ───────────────────────────────── */
.db-two-col{display:grid;grid-template-columns:1fr 1fr;gap:14px}
@media(max-width:900px){.db-two-col{grid-template-columns:1fr}}

/* ── Spinner ─────────────────────────────────────────── */
.spin{color:#aaa;font-size:13px;padding:20px;text-align:center}

/* ── Quick links ─────────────────────────────────────── */
.ql-row{display:flex;flex-wrap:wrap;gap:8px;padding:14px 18px}
.ql-btn{padding:7px 16px;border-radius:6px;font-size:13px;font-weight:600;text-decoration:none;display:inline-flex;align-items:center;gap:5px;border:1.5px solid #ddd;color:#37474F;background:#fff;transition:.12s}
.ql-btn:hover{border-color:#1565C0;color:#1565C0;text-decoration:none}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">

<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">BookaWaka Admin &mdash; Dashboard</label></div>
  <div class="uk-navbar-flip"><ul class="uk-navbar-nav user_actions">
    <li><a href="#" id="full_screen_toggle" class="user_action_icon uk-visible-large"><i class="material-icons md-24 md-light">&#xE5D0;</i></a></li>
    <li data-uk-dropdown="{mode:'click',pos:'bottom-right'}">
      <a href="#" class="user_action_image"><img class="md-user-image" src="assets/img/bw-logo.png" alt=""/></a>
      <div class="uk-dropdown uk-dropdown-small"><ul class="uk-nav js-uk-prevent">
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
    <li class="current_section" title="Dashboard"><a href="Home.aspx"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Home</span></a></li>
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
    </ul></li>
    <li class="current_section" title="Towing"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Towing</span></a><ul>
      <li><a href="SA-Towing.aspx">Towing Dashboard</a></li>
      <li><a href="SA-Towing.aspx#jobs">All Jobs</a></li>
      <li><a href="SA-Towing.aspx#config">Platform Config</a></li>
      <li><a href="/towing-portal" target="_blank">Owner Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Rental Cars"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE531;</i></span><span class="menu_title">Rental Cars</span></a><ul>
      <li><a href="SA-Rental.aspx">Rental Dashboard</a></li>
      <li><a href="SA-Rental.aspx#reservations">All Reservations</a></li>
      <li><a href="SA-Rental.aspx#config">Platform Config</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests <span id="sb-onboard-badge" style="background:#1565C0;color:#fff;font-size:10px;font-weight:700;padding:1px 6px;border-radius:8px;margin-left:4px;display:none"></span></a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-WatchList.aspx">&#9888; Passenger Watch-list</a></li>
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
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="db-wrap">

  <div class="db-greeting" id="db-greeting">Good morning &mdash; BookaWaka Admin</div>
  <div class="db-sub" id="db-date-str">Loading platform data&hellip;</div>

  <!-- ── KPI Row ───────────────────────────── -->
  <div class="kpi-row">
    <a class="kpi orange" href="SA-Clients.aspx">
      <span class="kpi-icon material-icons">business</span>
      <div class="kpi-val" id="kpi-companies">&#8230;</div>
      <div class="kpi-lbl">Total Companies</div>
      <div class="kpi-sub" id="kpi-companies-sub">&nbsp;</div>
    </a>
    <a class="kpi yellow" href="SA-Onboard.aspx">
      <span class="kpi-icon material-icons">assignment</span>
      <div class="kpi-val" id="kpi-pending">&#8230;</div>
      <div class="kpi-lbl">Pending Onboard Requests</div>
      <div class="kpi-sub" id="kpi-pending-sub">Awaiting review</div>
    </a>
    <a class="kpi red" href="SA-Billing.aspx">
      <span class="kpi-icon material-icons">receipt_long</span>
      <div class="kpi-val" id="kpi-overdue">&#8230;</div>
      <div class="kpi-lbl">Overdue Invoices</div>
      <div class="kpi-sub" id="kpi-overdue-sub">&nbsp;</div>
    </a>
    <a class="kpi green" href="SA-Payouts.aspx">
      <span class="kpi-icon material-icons">payments</span>
      <div class="kpi-val" id="kpi-payouts">&#8230;</div>
      <div class="kpi-lbl">Pending Payouts</div>
      <div class="kpi-sub" id="kpi-payouts-sub">&nbsp;</div>
    </a>
    <a class="kpi" style="border-left-color:#6A1B9A" href="SA-Drivers.aspx#transfers">
      <span class="kpi-icon material-icons">swap_horiz</span>
      <div class="kpi-val" id="kpi-transfers">&#8230;</div>
      <div class="kpi-lbl">Pending Transfers</div>
      <div class="kpi-sub">Awaiting approval</div>
    </a>
  </div>

  <!-- ── TM KPI Row ───────────────────────── -->
  <div style="font-size:11.5px;font-weight:700;color:#1B5E20;letter-spacing:.06em;text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;gap:8px">
    <span style="background:#E8F5E9;color:#1B5E20;padding:2px 8px;border-radius:10px">&#9851; Total Mobility</span>
    <span id="tm-month-label" style="color:#aaa;font-weight:400;font-size:11px"></span>
  </div>
  <div class="kpi-row" style="margin-bottom:22px">
    <a class="kpi" style="border-left-color:#00695C" href="TM-Trips.aspx">
      <span class="kpi-icon material-icons">directions_car</span>
      <div class="kpi-val" id="kpi-tm-trips">&#8230;</div>
      <div class="kpi-lbl">TM Trips This Month</div>
      <div class="kpi-sub" id="kpi-tm-trips-sub">&nbsp;</div>
    </a>
    <a class="kpi" style="border-left-color:#1565C0" href="TM-Batches.aspx">
      <span class="kpi-icon material-icons">pending_actions</span>
      <div class="kpi-val" id="kpi-tm-batches">&#8230;</div>
      <div class="kpi-lbl">Batches Awaiting Council</div>
      <div class="kpi-sub" id="kpi-tm-batches-sub">&nbsp;</div>
    </a>
    <a class="kpi" style="border-left-color:#2E7D32" href="TM-Reports.aspx">
      <span class="kpi-icon material-icons">account_balance</span>
      <div class="kpi-val" id="kpi-tm-claim">&#8230;</div>
      <div class="kpi-lbl">Council Claim This Month</div>
      <div class="kpi-sub" id="kpi-tm-claim-sub">&nbsp;</div>
    </a>
    <a class="kpi" style="border-left-color:#F9A825" href="TM-Flagged.aspx">
      <span class="kpi-icon material-icons">flag</span>
      <div class="kpi-val" id="kpi-tm-flagged">&#8230;</div>
      <div class="kpi-lbl">Trips Awaiting SA Review</div>
      <div class="kpi-sub">company_approved status</div>
    </a>
  </div>

  <style>
  @keyframes pulse-tw {
    0%,100%{box-shadow:0 1px 5px rgba(230,81,0,.15)}
    50%{box-shadow:0 0 18px rgba(230,81,0,.45);transform:translateY(-3px)}
  }
  </style>
  <!-- ── Towing KPI Row ───────────────────── -->
  <div style="font-size:11.5px;font-weight:700;color:#BF360C;letter-spacing:.06em;text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;gap:8px">
    <span style="background:#FFF3E0;color:#E65100;padding:2px 8px;border-radius:10px">&#128667; Towing</span>
  </div>
  <div class="kpi-row" style="margin-bottom:22px">
    <a class="kpi" style="border-left-color:#E65100;background:#FFF8F5" href="SA-Towing.aspx#unassigned" id="kpi-tw-unassigned-card">
      <div class="kpi-val" id="kpi-tw-unassigned">&#8230;</div>
      <div class="kpi-lbl">Unassigned Jobs</div>
      <div class="kpi-sub" id="kpi-tw-unassigned-sub">Need assignment</div>
    </a>
    <a class="kpi" style="border-left-color:#F57F17" href="SA-Towing.aspx#jobs">
      <div class="kpi-val" id="kpi-tw-active">&#8230;</div>
      <div class="kpi-lbl">Active Tow Jobs</div>
      <div class="kpi-sub">In progress</div>
    </a>
    <a class="kpi" style="border-left-color:#2E7D32" href="SA-Towing.aspx">
      <div class="kpi-val" id="kpi-tw-companies">&#8230;</div>
      <div class="kpi-lbl">Towing Companies</div>
      <div class="kpi-sub">On platform</div>
    </a>
    <a class="kpi" style="border-left-color:#1565C0" href="SA-Towing.aspx">
      <div class="kpi-val" id="kpi-tw-trucks">&#8230;</div>
      <div class="kpi-lbl">Trucks in Fleet</div>
      <div class="kpi-sub">Across all companies</div>
    </a>
  </div>

  <!-- ── Food Delivery KPI Row ────────────── -->
  <div style="font-size:11.5px;font-weight:700;color:#E65100;letter-spacing:.06em;text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;gap:8px">
    <span style="background:#FFF8E1;color:#F57F17;padding:2px 8px;border-radius:10px">&#127829; Food Delivery</span>
  </div>
  <div class="kpi-row" style="margin-bottom:22px">
    <a class="kpi" style="border-left-color:#F9A825" href="FD-Orders.aspx">
      <span class="kpi-icon material-icons">receipt</span>
      <div class="kpi-val" id="kpi-fd-orders">&#8230;</div>
      <div class="kpi-lbl">Orders Today</div>
      <div class="kpi-sub" id="kpi-fd-orders-sub">&nbsp;</div>
    </a>
    <a class="kpi" style="border-left-color:#F57F17" href="FD-Orders.aspx">
      <span class="kpi-icon material-icons">attach_money</span>
      <div class="kpi-val" id="kpi-fd-revenue">&#8230;</div>
      <div class="kpi-lbl">Revenue Today</div>
      <div class="kpi-sub">Food delivery</div>
    </a>
    <a class="kpi" style="border-left-color:#E65100" href="SA-Clients.aspx">
      <span class="kpi-icon material-icons">store</span>
      <div class="kpi-val" id="kpi-fd-companies">&#8230;</div>
      <div class="kpi-lbl">FD Companies</div>
      <div class="kpi-sub">Module active</div>
    </a>
  </div>

  <!-- ── Freight KPI Row ───────────────────── -->
  <div style="font-size:11.5px;font-weight:700;color:#37474F;letter-spacing:.06em;text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;gap:8px">
    <span style="background:#ECEFF1;color:#37474F;padding:2px 8px;border-radius:10px">&#128230; Freight</span>
  </div>
  <div class="kpi-row" style="margin-bottom:22px">
    <a class="kpi" style="border-left-color:#37474F" href="FR-Orders.aspx">
      <span class="kpi-icon material-icons">local_shipping</span>
      <div class="kpi-val" id="kpi-fr-orders">&#8230;</div>
      <div class="kpi-lbl">Orders Today</div>
      <div class="kpi-sub" id="kpi-fr-orders-sub">&nbsp;</div>
    </a>
    <a class="kpi" style="border-left-color:#546E7A" href="FR-Orders.aspx">
      <span class="kpi-icon material-icons">attach_money</span>
      <div class="kpi-val" id="kpi-fr-revenue">&#8230;</div>
      <div class="kpi-lbl">Revenue Today</div>
      <div class="kpi-sub">Freight</div>
    </a>
    <a class="kpi" style="border-left-color:#607D8B" href="SA-Clients.aspx">
      <span class="kpi-icon material-icons">business</span>
      <div class="kpi-val" id="kpi-fr-companies">&#8230;</div>
      <div class="kpi-lbl">Freight Companies</div>
      <div class="kpi-sub">Module active</div>
    </a>
  </div>

  <!-- ── Module Activity ───────────────────── -->
  <div class="mod-row">
    <div class="mod-panel taxi">
      <div class="mod-badge taxi material-icons">&#xE531;</div>
      <div class="mod-title">&#128665; Taxi &mdash; Today</div>
      <div class="mod-big" id="taxi-trips">&#8230;</div>
      <div class="mod-detail">Trips processed today</div>
      <a class="mod-link" href="TM-Trips.aspx">View all trips &#8594;</a>
    </div>
    <div class="mod-panel food">
      <div class="mod-badge food material-icons">&#xE56C;</div>
      <div class="mod-title">&#127829; Food Delivery &mdash; Today</div>
      <div class="mod-big" id="fd-orders">&#8230;</div>
      <div class="mod-detail" id="fd-revenue">Revenue loading&hellip;</div>
      <a class="mod-link" href="FD-Orders.aspx">View all orders &#8594;</a>
    </div>
    <div class="mod-panel freight">
      <div class="mod-badge freight material-icons">&#xE558;</div>
      <div class="mod-title">&#128230; Freight &mdash; Today</div>
      <div class="mod-big" id="fr-orders">&#8230;</div>
      <div class="mod-detail" id="fr-revenue">Revenue loading&hellip;</div>
      <a class="mod-link" href="FR-Orders.aspx">View all orders &#8594;</a>
    </div>
  </div>

  <!-- ── Bottom Two-column ─────────────────── -->
  <div class="db-two-col">

    <!-- Left: Attention + Companies -->
    <div>

      <!-- Needs Attention -->
      <div class="db-card" id="attn-card">
        <div class="db-card-hdr">
          <h3>&#9888; Needs Attention</h3>
          <span id="attn-count" style="font-size:12px;color:#aaa">Loading&hellip;</span>
        </div>
        <div class="db-card-body" id="attn-body" style="padding:0 18px">
          <div class="spin">Checking&hellip;</div>
        </div>
      </div>

      <!-- All Companies -->
      <div class="db-card">
        <div class="db-card-hdr">
          <h3>&#127970; All Companies</h3>
          <a href="SA-Clients.aspx">Manage &#8594;</a>
        </div>
        <div style="overflow-x:auto">
          <table class="co-tbl">
            <thead><tr>
              <th>Company</th>
              <th>Location</th>
              <th>Modules</th>
              <th>Status</th>
            </tr></thead>
            <tbody id="co-tbl-body"><tr><td colspan="4" class="spin">Loading&hellip;</td></tr></tbody>
          </table>
        </div>
        <div style="padding:10px 18px;border-top:1px solid #f5f5f5">
          <a href="SA-Clients.aspx" style="font-size:12px;color:#1565C0;font-weight:600;text-decoration:none">View all companies &#8594;</a>
        </div>
      </div>

    </div>

    <!-- Right: Activity Feed + Quick Links -->
    <div>

      <!-- Recent Activity Feed -->
      <div class="db-card">
        <div class="db-card-hdr">
          <h3>&#128337; Recent Activity</h3>
          <span id="feed-updated" style="font-size:12px;color:#aaa"></span>
        </div>
        <div class="db-card-body" style="padding:4px 18px" id="feed-body">
          <div class="spin">Loading&hellip;</div>
        </div>
      </div>

      <!-- Quick Links -->
      <div class="db-card">
        <div class="db-card-hdr"><h3>&#128279; Quick Links</h3></div>
        <div class="ql-row">
          <a href="SA-Clients.aspx" class="ql-btn">&#127970; All Companies</a>
          <a href="SA-Onboard.aspx" class="ql-btn">&#128640; Onboard Requests</a>
          <a href="SA-Billing.aspx" class="ql-btn">&#128203; Billing</a>
          <a href="SA-Payouts.aspx" class="ql-btn">&#128176; Payouts</a>
          <a href="TM-Trips.aspx" class="ql-btn">&#128665; TM Trips</a>
          <a href="FD-Orders.aspx" class="ql-btn">&#127829; FD Orders</a>
          <a href="FR-Orders.aspx" class="ql-btn">&#128230; Freight Orders</a>
          <a href="SA-Packages.aspx" class="ql-btn">&#128230; Packages</a>
          <a href="/join" target="_blank" class="ql-btn">&#128279; Join Form &#8599;</a>
          <a href="/company-portal" target="_blank" class="ql-btn">&#127970; Company Portal &#8599;</a>
        </div>
      </div>

    </div>
  </div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allCompanies = {};
var activityFeed = [];

// ── Greeting ────────────────────────────────────────
(function(){
  // Use Pacific/Auckland so greeting and date are always correct for NZ,
  // regardless of what timezone the server or browser is set to.
  var nzHr = parseInt(new Date().toLocaleString('en-NZ', {timeZone:'Pacific/Auckland', hour:'2-digit', hour12:false}), 10);
  var greet = nzHr < 12 ? 'Good morning' : nzHr < 17 ? 'Good afternoon' : 'Good evening';
  document.getElementById('db-greeting').textContent = greet + ' \u2014 BookaWaka Admin';
  var opts = {timeZone:'Pacific/Auckland', weekday:'long', year:'numeric', month:'long', day:'numeric'};
  document.getElementById('db-date-str').textContent = new Date().toLocaleDateString('en-NZ', opts) + ' \u2014 Platform Overview';
})();

// ── Helpers ──────────────────────────────────────────
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtMoney(v){ return '$'+(+v||0).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g,','); }
function fmtTime(ts){
  if(!ts) return '';
  var d=new Date(ts);
  var now=Date.now();
  var diff=Math.floor((now-ts)/1000);
  if(diff<60) return 'Just now';
  if(diff<3600) return Math.floor(diff/60)+'m ago';
  if(diff<86400) return Math.floor(diff/3600)+'h ago';
  return d.toLocaleDateString('en-NZ',{day:'numeric',month:'short'});
}
function todayStart(){ return _tzTodayStart(); }
function todayEnd(){   return _tzTodayEnd();   }

function pushFeed(ts, dotClass, icon, msg){
  activityFeed.push({ts:ts||0, dotClass:dotClass, icon:icon, msg:msg});
}
function renderFeed(){
  activityFeed.sort(function(a,b){return b.ts-a.ts;});
  var items = activityFeed.slice(0,20);
  if(!items.length){
    document.getElementById('feed-body').innerHTML='<div class="spin" style="color:#C8E6C9">No recent activity yet.</div>';
    return;
  }
  var html='';
  items.forEach(function(item){
    html+='<div class="feed-item">'+
      '<div class="feed-dot '+esc(item.dotClass)+'">'+item.icon+'</div>'+
      '<div><div class="feed-msg">'+esc(item.msg)+'</div>'+
        '<div class="feed-time">'+fmtTime(item.ts)+'</div>'+
      '</div></div>';
  });
  document.getElementById('feed-body').innerHTML=html;
  document.getElementById('feed-updated').textContent='Updated '+fmtTime(Date.now());
}

var AUDIT_ACTION_MAP={
  company_approved:{dot:'green',icon:'&#10003;',label:'Company approved'},
  company_rejected:{dot:'red',icon:'&#10007;',label:'Application rejected'},
  company_activated:{dot:'green',icon:'&#9733;',label:'Company activated'},
  company_deactivated:{dot:'red',icon:'&#8856;',label:'Company deactivated'},
  company_suspended:{dot:'red',icon:'&#128683;',label:'Company suspended'},
  company_reactivated:{dot:'green',icon:'&#8635;',label:'Company reactivated'},
  company_onboarded:{dot:'green',icon:'&#128640;',label:'Company direct-onboarded'},
  access_granted:{dot:'blue',icon:'&#128273;',label:'Panel access granted'},
  access_revoked:{dot:'red',icon:'&#128274;',label:'Panel access revoked'},
  module_toggled:{dot:'amber',icon:'&#9881;',label:'Module toggled'},
  driver_approved:{dot:'green',icon:'&#128663;',label:'Driver approved'},
  driver_rejected:{dot:'red',icon:'&#128663;',label:'Driver rejected'},
  trial_extended:{dot:'blue',icon:'&#128197;',label:'Trial extended'},
  invoice_created:{dot:'blue',icon:'&#128179;',label:'Invoice created'},
  payout_recorded:{dot:'green',icon:'&#128176;',label:'Payout recorded'}
};
function loadAuditFeed(){
  _fbGet('superAuditLog').then(function(entries){
    entries=entries||{};
    activityFeed=activityFeed.filter(function(f){return f._src!=='audit';});
    Object.values(entries).forEach(function(e){
      if(!e||!e.ts) return;
      var map=AUDIT_ACTION_MAP[e.action]||{dot:'grey',icon:'&#8226;',label:e.action||'action'};
      var company=e.cidName||e.cid||'';
      var actor=e.actor||'';
      var msg=map.label+(company?' \u2014 '+company:'')+(actor?' ('+actor+')':'');
      activityFeed.push({ts:e.ts,dotClass:map.dot,icon:map.icon,msg:msg,_src:'audit'});
    });
    renderFeed();
  }).catch(function(){ renderFeed(); });
}

// ── Main loader ──────────────────────────────────────
var _dashLoaded = false;
window._fbOnLogin = function(){
  if (_dashLoaded) return;
  _dashLoaded = true;
  loadDashboard();
};

function loadDashboard(){
  // 1. Companies
  _fbGet('superClients').then(function(data){
    allCompanies = data || {};
    renderCompanyTable();
    renderKpiCompanies();
    loadModuleActivity();
    loadAttentionData();
    loadTmStats();
    loadAuditFeed();
  }).catch(function(err){
    console.error('superClients read error:', err);
    allCompanies = {};
    renderCompanyTable();
    renderKpiCompanies();
    loadTmStats();
    loadAuditFeed();
  });

  // Trial expiry alert — fire-and-forget, silent
  fetch('/api/admin/trial-expiry-alerts', { method: 'POST' })
    .then(function(r){ return r.json(); })
    .then(function(d){ if(d.sent>0) console.log('[trial-alert] Sent '+d.sent+' expiry alert(s)'); })
    .catch(function(){});

  // 2. Onboard requests via Admin API + Firebase website submissions
  function loadOnboardData(){
    var apiPromise = fetch('/api/admin/registrations').then(function(r){return r.json();}).catch(function(){return [];});
    var fbPromise = _fbGet('onboardRequests').then(function(d){return d||{};}).catch(function(){return {};});
    Promise.all([apiPromise, fbPromise]).then(function(results){
      var data = Array.isArray(results[0]) ? results[0] : [];
      var fbReqs = results[1];

      // Count pending from admin API
      var apiPending = data.filter(function(r){return r.status==='pending';}).length;

      // Count pending from Firebase (website submissions) — deduplicate by email
      var apiEmails = {};
      data.forEach(function(r){ if(r.email) apiEmails[(r.email||'').toLowerCase()]=true; });
      var fbPending = 0;
      var weekAgo = Date.now() - 7*24*60*60*1000;
      var fbNewThisWeek = 0;
      Object.values(fbReqs).forEach(function(r){
        if(!r||!r.email) return;
        if(apiEmails[(r.email||'').toLowerCase()]) return;
        if(r.status==='pending'){
          fbPending++;
          var subTs = typeof r.submittedAt==='number' ? r.submittedAt : (r.submittedAt ? new Date(r.submittedAt).getTime() : 0);
          if(subTs>=weekAgo) fbNewThisWeek++;
          var coName = r.businessName||r.name||'New company';
          activityFeed.push({ts:subTs,dotClass:'amber',icon:'&#x1F310;',msg:coName+' submitted a website application'+(r.city?' from '+r.city:''),_src:'onboard'});
        }
      });

      var totalPending = apiPending + fbPending;
      document.getElementById('kpi-pending').textContent = totalPending;

      var newThisWeek = data.filter(function(r){ return r.status==='pending' && (r.submittedAt||0)>=weekAgo; }).length + fbNewThisWeek;
      var pendSub = document.getElementById('kpi-pending-sub');
      if(pendSub) pendSub.textContent = newThisWeek>0 ? newThisWeek+' new this week' : 'Awaiting review';

      var badge = document.getElementById('sb-onboard-badge');
      if(totalPending>0){badge.textContent=totalPending;badge.style.display='inline';}
      else{badge.style.display='none';}

      activityFeed = activityFeed.filter(function(f){return f._src!=='onboard';});
      data.slice(-5).forEach(function(r){
        var f={ts:r.submittedAt||0,dotClass:'amber',icon:'&#x1F680;',msg:(r.company||'New company')+' submitted an application'+(r.area?' from '+r.area:''),_src:'onboard'};
        if(r.status==='trial'||r.status==='active'){f={ts:r.approvedAt||r.submittedAt||0,dotClass:'green',icon:'&#x2713;',msg:(r.company||'Company')+' approved'+(r.companyId?' (ID: '+r.companyId+')':''),_src:'onboard'};}
        else if(r.status==='rejected'){f={ts:r.submittedAt||0,dotClass:'red',icon:'&#x2717;',msg:(r.company||'Company')+' application rejected',_src:'onboard'};}
        activityFeed.push(f);
      });
      renderFeed();
    }).catch(function(){ document.getElementById('kpi-pending').textContent = '?'; });
  }
  loadOnboardData();
  setInterval(loadOnboardData, 30000);

  // 7. Towing stats
  function loadTowingStats(){
    Promise.all([
      _fbGet('towingJobs/unassigned').then(function(v){ return v||{}; }).catch(function(){ return {}; }),
      _fbGet('towingJobs').then(function(v){ return v||{}; }).catch(function(){ return {}; }),
      _fbGet('towingPortalAccess').then(function(v){ return v||{}; }).catch(function(){ return {}; }),
      _fbGet('towingFleet').then(function(v){ return v||{}; }).catch(function(){ return {}; })
    ]).then(function(results){
      var unassigned = Object.keys(results[0]).length;
      var jobsByCompany = results[1];
      var companies = Object.keys(results[2]).length;
      var fleet = results[3];
      var active = 0;
      Object.values(jobsByCompany).forEach(function(cJobs){
        if(!cJobs || typeof cJobs !== 'object') return;
        Object.values(cJobs).forEach(function(j){
          if(j && ['pending','assigned','enroute','arrived','loading','dropoff'].indexOf(j.status||'')>-1) active++;
        });
      });
      var totalTrucks = 0;
      Object.values(fleet).forEach(function(cFleet){ totalTrucks += Object.keys(cFleet||{}).length; });
      var el;
      el = document.getElementById('kpi-tw-unassigned'); if(el) el.textContent = unassigned;
      el = document.getElementById('kpi-tw-active'); if(el) el.textContent = active;
      el = document.getElementById('kpi-tw-companies'); if(el) el.textContent = companies;
      el = document.getElementById('kpi-tw-trucks'); if(el) el.textContent = totalTrucks;
      if(unassigned > 0){
        var card = document.getElementById('kpi-tw-unassigned-card');
        if(card) card.style.animation = 'pulse-tw 1.6s ease-in-out infinite';
        var sub = document.getElementById('kpi-tw-unassigned-sub');
        if(sub) sub.textContent = unassigned + ' waiting for dispatch';
      }
    }).catch(function(){
      ['kpi-tw-unassigned','kpi-tw-active','kpi-tw-companies','kpi-tw-trucks'].forEach(function(id){
        var e = document.getElementById(id); if(e) e.textContent = '?';
      });
    });
  }
  loadTowingStats();
  setInterval(loadTowingStats, 60000);

  // 3. Pending driver transfer requests
  function loadTransfersData(){
    _fbGet('driverTransferRequests').then(function(all){
      all = all || {};
      var pending = Object.values(all).filter(function(r){ return r.status === 'pending'; }).length;
      var el = document.getElementById('kpi-transfers');
      if (el) el.textContent = pending;
      var kpiEl = el && el.closest ? el.closest('a.kpi') : null;
      if (kpiEl) {
        kpiEl.style.borderLeftColor = pending > 0 ? '#6A1B9A' : '#9E9E9E';
      }
    }).catch(function(){ var el=document.getElementById('kpi-transfers'); if(el) el.textContent='?'; });
  }
  loadTransfersData();
  setInterval(loadTransfersData, 60000);
}

function renderKpiCompanies(){
  var total = Object.keys(allCompanies).length;
  var active = Object.values(allCompanies).filter(function(c){return c.status!=='suspended';}).length;
  var now = Date.now();
  var monthStartMs = _tzMonthStart();
  var newThisMonth = Object.values(allCompanies).filter(function(c){
    var ts = c.createdAt || c.joinedAt || 0;
    return ts >= monthStartMs;
  }).length;
  document.getElementById('kpi-companies').textContent = total;
  var sub = active+' active'+(total-active>0?' / '+(total-active)+' suspended':'');
  if(newThisMonth>0) sub += ' \u2022 +'+newThisMonth+' this month';
  document.getElementById('kpi-companies-sub').textContent = sub;
}

function renderCompanyTable(){
  var rows='';
  var list = Object.entries(allCompanies);
  if(!list.length){
    document.getElementById('co-tbl-body').innerHTML='<tr><td colspan="4" style="text-align:center;padding:20px;color:#aaa">No companies registered yet. <a href="SA-Clients.aspx">Add one</a>.</td></tr>';
    return;
  }
  list.forEach(function(e){
    var cid=e[0], c=e[1];
    var mods='';
    if(c.modules){
      mods+='<span class="mod-chip '+(c.modules.taxi?'chip-on':'chip-off')+'">Taxi</span>';
      mods+='<span class="mod-chip '+(c.modules.foodDelivery?'chip-on':'chip-off')+'">FD</span>';
      mods+='<span class="mod-chip '+(c.modules.freight?'chip-on':'chip-off')+'">FR</span>';
    }
    var statusBadge = c.status==='suspended'
      ? '<span class="badge-suspended">Suspended</span>'
      : '<span class="badge-active">Active</span>';
    rows+='<tr>'+
      '<td><a href="SA-Clients.aspx">'+esc(c.name||cid)+'</a><div style="font-size:11px;color:#aaa">ID: '+esc(cid)+'</div></td>'+
      '<td>'+esc(c.city||'')+(c.city&&c.country?', ':'')+esc(c.country||'')+'</td>'+
      '<td>'+mods+'</td>'+
      '<td>'+statusBadge+'</td>'+
    '</tr>';
  });
  document.getElementById('co-tbl-body').innerHTML=rows;
}

function loadModuleActivity(){
  var cids = Object.keys(allCompanies);
  var tStart = todayStart(), tEnd = todayEnd();

  // Taxi trips today — read from completedJobs/{cid}
  var taxiCids = cids.filter(function(cid){ return allCompanies[cid].modules && allCompanies[cid].modules.taxi; });
  if(!taxiCids.length && cids.length){
    // fallback: treat all companies as taxi capable
    taxiCids = cids;
  }
  var taxiCount=0, taxiRev=0, taxiDone=0;
  var todayStr = _tzDateStr(); // YYYY-MM-DD in Pacific/Auckland
  function finishTaxi(){
    document.getElementById('taxi-trips').textContent = taxiCount;
    if(taxiCount>0) pushFeed(Date.now(),'orange','&#x1F695;',taxiCount+' taxi trip'+(taxiCount!==1?'s':'')+' today'+( taxiRev>0 ? ' ('+fmtMoney(taxiRev)+')' : ''));
    renderFeed();
  }
  if(!taxiCids.length){
    document.getElementById('taxi-trips').textContent='0';
  } else {
    taxiCids.forEach(function(cid){
      // Load BOTH paths: completedJobs (hail trips) + allbookings (dispatched trips)
      // Driver app confirmed: hail → completedJobs, dispatched → allbookings
      Promise.all([
        _fbGet('completedJobs/'+cid).catch(function(){ return {}; }),
        _fbGet('allbookings/'+cid).catch(function(){ return {}; })
      ]).then(function(res){
        var hailJobs       = res[0] || {};
        var dispatchedJobs = res[1] || {};

        // Hail trips — completedJobs always wrote lowercase fields
        Object.values(hailJobs).forEach(function(j){
          var ts = j.completedAt_ISO || j.CompletedAt_ISO || j.completedAt || '';
          if(ts && _tzToDate(ts)===todayStr){
            taxiCount++;
            taxiRev+=(+(j.fare||j.FinalFare||0));
          }
        });

        // Dispatched trips — only count status=completed, exclude TM (counted separately)
        // Historical allbookings: Status:"Completed", CompletedAt_ISO, FinalFare (all PascalCase)
        // New records: status:"completed", completedAt_ISO, fare (all lowercase)
        Object.values(dispatchedJobs).forEach(function(j){
          var jSt = (j.status || j.Status || '').toLowerCase();
          if(jSt !== 'completed' && jSt !== 'done') return;
          if(j.paymentType === 'total_mobility') return;
          var ts = j.completedAt_ISO || j.CompletedAt_ISO || j.completedAt || '';
          if(ts && _tzToDate(ts)===todayStr){
            taxiCount++;
            taxiRev+=(+(j.fare||j.FinalFare||0));
          }
        });

        taxiDone++;
        if(taxiDone===taxiCids.length) finishTaxi();
      });
    });
  }

  // Food Delivery today — all FD companies
  var fdCids = cids.filter(function(cid){return allCompanies[cid].modules && allCompanies[cid].modules.foodDelivery;});
  var fdOrders=0, fdRev=0, fdDone=0;
  var el;
  el=document.getElementById('kpi-fd-companies'); if(el) el.textContent=fdCids.length;
  if(!fdCids.length){
    document.getElementById('fd-orders').textContent='0';
    document.getElementById('fd-revenue').textContent='No FD companies active';
    el=document.getElementById('kpi-fd-orders'); if(el) el.textContent='0';
    el=document.getElementById('kpi-fd-revenue'); if(el) el.textContent='$0';
    el=document.getElementById('kpi-fd-orders-sub'); if(el) el.textContent='No companies active';
  } else {
    fdCids.forEach(function(cid){
      _fbGet('foodOrders/'+cid).then(function(allOrders){
        var orders={}; Object.entries(allOrders||{}).forEach(function(e){ var t=e[1].createdAt||0; if(t>=tStart&&t<=tEnd) orders[e[0]]=e[1]; });
        fdOrders+=Object.keys(orders).length;
        fdRev+=Object.values(orders).reduce(function(s,o){return s+(o.totalAmount||o.total||o.amount||0);},0);
        fdDone++;
        if(fdDone===fdCids.length){
          document.getElementById('fd-orders').textContent=fdOrders;
          document.getElementById('fd-revenue').textContent=fmtMoney(fdRev)+' revenue today';
          el=document.getElementById('kpi-fd-orders'); if(el) el.textContent=fdOrders;
          el=document.getElementById('kpi-fd-revenue'); if(el) el.textContent=fmtMoney(fdRev);
          el=document.getElementById('kpi-fd-orders-sub'); if(el) el.textContent=fmtMoney(fdRev)+' today';
          if(fdOrders>0) pushFeed(Date.now(),'amber','&#x1F355;',fdOrders+' food delivery order'+(fdOrders!==1?'s':'')+' today ('+fmtMoney(fdRev)+')');
          renderFeed();
        }
      }).catch(function(){fdDone++; if(fdDone===fdCids.length){ el=document.getElementById('kpi-fd-orders'); if(el) el.textContent=fdOrders; }});
    });
  }

  // Freight today — all Freight companies
  var frCids = cids.filter(function(cid){return allCompanies[cid].modules && allCompanies[cid].modules.freight;});
  var frOrders=0, frRev=0, frDone=0;
  el=document.getElementById('kpi-fr-companies'); if(el) el.textContent=frCids.length;
  if(!frCids.length){
    document.getElementById('fr-orders').textContent='0';
    document.getElementById('fr-revenue').textContent='No Freight companies active';
    el=document.getElementById('kpi-fr-orders'); if(el) el.textContent='0';
    el=document.getElementById('kpi-fr-revenue'); if(el) el.textContent='$0';
    el=document.getElementById('kpi-fr-orders-sub'); if(el) el.textContent='No companies active';
  } else {
    frCids.forEach(function(cid){
      _fbGet('freightOrders/'+cid).then(function(allOrders){
        var orders={}; Object.entries(allOrders||{}).forEach(function(e){ var t=e[1].createdAt||0; if(t>=tStart&&t<=tEnd) orders[e[0]]=e[1]; });
        frOrders+=Object.keys(orders).length;
        frRev+=Object.values(orders).reduce(function(s,o){return s+(o.totalAmount||o.total||o.amount||0);},0);
        frDone++;
        if(frDone===frCids.length){
          document.getElementById('fr-orders').textContent=frOrders;
          document.getElementById('fr-revenue').textContent=fmtMoney(frRev)+' revenue today';
          el=document.getElementById('kpi-fr-orders'); if(el) el.textContent=frOrders;
          el=document.getElementById('kpi-fr-revenue'); if(el) el.textContent=fmtMoney(frRev);
          el=document.getElementById('kpi-fr-orders-sub'); if(el) el.textContent=fmtMoney(frRev)+' today';
          if(frOrders>0) pushFeed(Date.now(),'blue','&#x1F4E6;',frOrders+' freight order'+(frOrders!==1?'s':'')+' today ('+fmtMoney(frRev)+')');
          renderFeed();
        }
      }).catch(function(){frDone++; if(frDone===frCids.length){ el=document.getElementById('kpi-fr-orders'); if(el) el.textContent=frOrders; }});
    });
  }
}

function loadAttentionData(){
  var cids = Object.keys(allCompanies);
  var attnItems = [];
  var billingDone=0, payoutDone=0;
  var today=Date.now();

  // No-plan companies + trial expiry (sync check — data already loaded)
  cids.forEach(function(cid){
    var c = allCompanies[cid];
    if(!c) return;
    if(!c.packageId){
      attnItems.push({type:'noplan',cid:cid,name:c.name||cid,detail:'No subscription plan assigned',amount:null,link:'SA-Billing.aspx?cid='+cid,btnClass:'attn-btn-blue',btnText:'Assign Plan'});
    }
    if(c.status === 'trial' && c.trialEnd){
      var teMs = typeof c.trialEnd === 'number' ? c.trialEnd : new Date(c.trialEnd).getTime();
      if(!isNaN(teMs)){
        var daysLeft = Math.ceil((teMs - today) / 86400000);
        if(daysLeft < 0){
          attnItems.push({type:'trial-expired',cid:cid,name:c.name||cid,detail:'Trial expired '+Math.abs(daysLeft)+' day'+(Math.abs(daysLeft)!==1?'s':'')+' ago — action needed',amount:null,link:'SA-Onboard.aspx',btnClass:'attn-btn-red',btnText:'Onboarding'});
        } else if(daysLeft <= 3){
          attnItems.push({type:'trial-expiring',cid:cid,name:c.name||cid,detail:'Trial expires in '+daysLeft+' day'+(daysLeft!==1?'s':'')+' ('+new Date(teMs).toLocaleDateString('en-NZ',{day:'numeric',month:'short'})+')',amount:null,link:'SA-Onboard.aspx',btnClass:'attn-btn-amber',btnText:'Onboarding'});
        }
      }
    }
  });

  // Overdue invoices
  if(!cids.length){
    renderAttn([]);
    return;
  }
  cids.forEach(function(cid){
    _fbGet('superBilling/'+cid+'/invoices').then(function(invs){
      invs=invs||{};
      Object.entries(invs).forEach(function(e){
        var inv=e[1];
        if(inv.status==='unpaid' && inv.dueDate && new Date(inv.dueDate).getTime()<today){
          attnItems.push({type:'invoice',cid:cid,name:allCompanies[cid]&&allCompanies[cid].name||cid,detail:'Invoice overdue since '+inv.dueDate,amount:inv.amount,link:'SA-Billing.aspx?cid='+cid,btnClass:'attn-btn-red',btnText:'Billing'});
        }
      });
      billingDone++;
      if(billingDone===cids.length) loadPayoutAttn();
    }).catch(function(){billingDone++; if(billingDone===cids.length) loadPayoutAttn();});
  });

  function loadPayoutAttn(){
    cids.forEach(function(cid){
      _fbGet('superPayouts/'+cid).then(function(payouts){
        payouts=payouts||{};
        var pending=Object.values(payouts).filter(function(p){return p.status==='pending';});
        if(pending.length){
          var total=pending.reduce(function(s,p){return s+(p.amount||0);},0);
          attnItems.push({type:'payout',cid:cid,name:allCompanies[cid]&&allCompanies[cid].name||cid,detail:pending.length+' pending payout'+(pending.length!==1?'s':''),amount:total,link:'SA-Payouts.aspx?cid='+cid,btnClass:'attn-btn-amber',btnText:'Payouts'});
        }
        payoutDone++;
        if(payoutDone===cids.length){ renderAttn(attnItems); loadPlanCompliance(attnItems); }
      }).catch(function(){payoutDone++; if(payoutDone===cids.length){ renderAttn(attnItems); loadPlanCompliance(attnItems); }});
    });
  }
}

function loadPlanCompliance(existingItems){
  _fbGet('superPackages').then(function(pkgs){
    pkgs=pkgs||{};
    var added=0;
    var newItems=existingItems.slice();
    Object.entries(allCompanies).forEach(function(entry){
      var cid=entry[0], c=entry[1];
      if(c.status==='suspended'||c.status==='rejected') return;
      var pkgId=c.packageId;
      if(!pkgId) return;
      var pkg=pkgs[pkgId];
      if(!pkg||!pkg.maxDrivers) return;
      var driverCount=+(c.driverCount||c.activeDrivers||0);
      if(driverCount>0 && driverCount > +pkg.maxDrivers){
        newItems.push({type:'plan-exceed',cid:cid,name:c.name||cid,detail:'Drivers ('+driverCount+') exceed plan limit of '+pkg.maxDrivers+' ('+esc(pkg.name||pkgId)+')',amount:null,link:'SA-Company.aspx?cid='+cid,btnClass:'attn-btn-amber',btnText:'View Company'});
        added++;
      }
    });
    if(added>0) renderAttn(newItems);
  }).catch(function(){});
}

function renderAttn(items){
  var overdueCount     = items.filter(function(i){return i.type==='invoice';}).length;
  var payoutCount      = items.filter(function(i){return i.type==='payout';}).length;
  var noplanCount      = items.filter(function(i){return i.type==='noplan';}).length;
  var trialExpiredCount  = items.filter(function(i){return i.type==='trial-expired';}).length;
  var trialExpiringCount = items.filter(function(i){return i.type==='trial-expiring';}).length;
  var planExceedCount    = items.filter(function(i){return i.type==='plan-exceed';}).length;
  document.getElementById('kpi-overdue').textContent = overdueCount;
  document.getElementById('kpi-overdue-sub').textContent = overdueCount>0 ? overdueCount+' compan'+(overdueCount!==1?'ies':'y')+' overdue' : 'All invoices current';
  document.getElementById('kpi-payouts').textContent = payoutCount;
  var totalPayout = items.filter(function(i){return i.type==='payout';}).reduce(function(s,i){return s+(i.amount||0);},0);
  document.getElementById('kpi-payouts-sub').textContent = payoutCount>0 ? fmtMoney(totalPayout)+' outstanding' : 'All paid out';
  var totalAttn = items.length;
  var extraNotes = [];
  if(noplanCount) extraNotes.push(noplanCount+' unassigned plan'+(noplanCount!==1?'s':''));
  if(trialExpiredCount) extraNotes.push(trialExpiredCount+' expired trial'+(trialExpiredCount!==1?'s':''));
  if(trialExpiringCount) extraNotes.push(trialExpiringCount+' trial'+(trialExpiringCount!==1?'s':'')+' expiring soon');
  if(planExceedCount) extraNotes.push(planExceedCount+' plan limit exceeded');
  document.getElementById('attn-count').textContent = totalAttn>0 ? totalAttn+' item'+(totalAttn!==1?'s':'')+' need attention'+(extraNotes.length?' ('+extraNotes.join(', ')+')':'') : '';

  if(!items.length){
    document.getElementById('attn-body').innerHTML='<div class="attn-empty">&#10003; Everything looks good &mdash; no overdue invoices or pending payouts.</div>';
    return;
  }
  var html='';
  items.forEach(function(item){
    var amtStr = item.amount ? ' &mdash; '+fmtMoney(item.amount) : '';
    html+='<div class="attn-row">'+
      '<div><div class="attn-lbl">'+esc(item.name)+'</div><div class="attn-meta">'+esc(item.detail)+amtStr+'</div></div>'+
      '<a href="'+esc(item.link)+'" class="attn-btn '+esc(item.btnClass)+'">'+esc(item.btnText)+' &#8594;</a>'+
    '</div>';
  });
  document.getElementById('attn-body').innerHTML=html;
}

function loadTmStats(){
  var curMonth = _tzCurMonth(); // YYYY-MM in Pacific/Auckland
  document.getElementById('tm-month-label').textContent = new Date().toLocaleString('en-NZ', {timeZone:'Pacific/Auckland', month:'long', year:'numeric'});

  var allCids = Object.keys(allCompanies);

  // Load council configs + cards to calculate correct subsidy %
  Promise.all([
    _fbGet('tmConfig').then(function(v){ return v||{}; }).catch(function(){ return {}; }),
    _fbGet('tmCards').then(function(v){ return v||{}; }).catch(function(){ return {}; }),
    _fbGet('tmTripStatus').then(function(v){ return v||{}; }).catch(function(){ return {}; }),
    _fbGet('tmBatches').then(function(v){ return v||{}; }).catch(function(){ return {}; })
  ]).then(function(res){
    var councils   = res[0];
    var cards      = res[1];
    var allStatus  = res[2];
    var allBatches = res[3];

    // Helper: calculate TM subsidy from council config
    function calcSub(fare, councilId){
      var c = councils[councilId] || {};
      var pct = parseFloat(c.subsidyPercent || 75);
      var cap = parseFloat(c.capAmount || 99999);
      return Math.min(fare * pct / 100, cap);
    }

    // company_approved count (trips awaiting SA review)
    var flaggedCount = 0;
    Object.values(allStatus).forEach(function(cidMap){
      Object.values(cidMap||{}).forEach(function(st){
        if(st && st.status==='company_approved') flaggedCount++;
      });
    });
    document.getElementById('kpi-tm-flagged').textContent = flaggedCount;

    // Count all TM trips this month directly from completedJobs
    if(!allCids.length){
      ['kpi-tm-trips','kpi-tm-claim'].forEach(function(id){ document.getElementById(id).textContent='0'; });
      document.getElementById('kpi-tm-trips-sub').textContent = 'No companies yet';
      document.getElementById('kpi-tm-claim-sub').textContent = '0 trips';
    } else {
      var done=0, tmTrips=0, tmClaim=0;
      allCids.forEach(function(cid){
        // TM trips come from BOTH completedJobs (hail) and allbookings (dispatched)
        Promise.all([
          _fbGet('completedJobs/'+cid).catch(function(){ return {}; }),
          _fbGet('allbookings/'+cid).catch(function(){ return {}; }),
          _fbGet('trips/'+cid).catch(function(){ return {}; })  // TM voucher numbers live here
        ]).then(function(res){
          var hailJobs       = res[0] || {};
          var dispatchedJobs = res[1] || {};
          var tripsData      = res[2] || {};  // for cardNumber lookup via bookingId

          // Merge both job sources; dispatched only if status=completed
          var allJobs = Object.assign({}, hailJobs);
          // Historical allbookings records: Status:"Completed" (capital S+C); new records: status:"completed"
          Object.entries(dispatchedJobs).forEach(function(e){
            var st = (e[1].status || e[1].Status || '').toLowerCase();
            if(st === 'completed' || st === 'done') allJobs[e[0]] = e[1];
          });

          Object.values(allJobs).forEach(function(j){
            if(j.paymentType !== 'total_mobility') return;
            // Historical allbookings used CompletedAt_ISO and FinalFare (PascalCase)
            var dateStr = _tzToMonth(j.startedAt_ISO||j.completedAt_ISO||j.CompletedAt_ISO||j.completedAt||'');
            if(dateStr !== curMonth) return;
            // estimatedFare is the passenger app's authoritative total fare for the whole trip
            var fare = parseFloat(j.estimatedFare||j.fare||j.FinalFare||j.meterFare||0);
            // cardNumber may be in completedJobs directly, or in trips/{cid}/{bookingId}
            var cardNum = j.tmVoucherNo||j.cardNumber||'';
            if(!cardNum && j.bookingId && tripsData[j.bookingId]) {
              cardNum = tripsData[j.bookingId].cardNumber || '';
            }
            var card = cards[cardNum]||{};
            var councilId = j.councilId||card.councilId||'';
            // Multi-passenger TM: split fare per card, apply cap per card, sum
            // Per NZ TM rules confirmed by passenger app dev — single-cap under-claims on group rides
            var tmPaxList = Array.isArray(j.tmPassengers) ? j.tmPassengers : [];
            var sub;
            if (tmPaxList.length > 1) {
              var farePerCard = fare / tmPaxList.length;
              sub = tmPaxList.reduce(function(total, pax) {
                var paxCard = cards[pax.cardNumber||''] || {};
                var paxCouncil = pax.councilId || paxCard.councilId || councilId;
                return total + calcSub(farePerCard, paxCouncil);
              }, 0);
            } else {
              var storedSub = parseFloat(j.tmCouncilAmount||j.tmSubsidy||j.tmSubsidyFare||0);
              sub = (storedSub > 0 && storedSub < fare) ? storedSub : calcSub(fare, councilId);
            }
            // Hoist fee is council-covered (confirmed by passenger app dev)
            // tmHoistFeeTotal is a new field; for historical records reconstruct from tmHoistCount × $5.00/lift
            var hoistFee = parseFloat(j.tmHoistFeeTotal || j.hoistTotal || j.hoistFee || 0);
            if (!hoistFee && j.tmHoistCount) hoistFee = +(j.tmHoistCount) * 5;
            tmTrips++;
            tmClaim += sub + hoistFee;
          });
          done++;
          if(done===allCids.length){
            document.getElementById('kpi-tm-trips').textContent = tmTrips;
            document.getElementById('kpi-tm-trips-sub').textContent = tmTrips>0 ? fmtMoney(tmClaim)+' council claim' : 'No TM trips yet';
            document.getElementById('kpi-tm-claim').textContent = fmtMoney(tmClaim);
            document.getElementById('kpi-tm-claim-sub').textContent = tmTrips+' trip'+(tmTrips!==1?'s':'');
          }
        }).catch(function(){
          done++;
          if(done===allCids.length){
            document.getElementById('kpi-tm-trips').textContent = tmTrips;
            document.getElementById('kpi-tm-claim').textContent = fmtMoney(tmClaim);
          }
        });
      });
    }

    // Submitted batches awaiting council payment
    var submitted=0, submittedValue=0;
    Object.values(allBatches).forEach(function(councilData){
      Object.values(councilData||{}).forEach(function(cidData){
        Object.values(cidData||{}).forEach(function(batch){
          if(batch && batch.status==='submitted'){ submitted++; submittedValue+=parseFloat(batch.totalSubsidy||0); }
        });
      });
    });
    document.getElementById('kpi-tm-batches').textContent = submitted;
    document.getElementById('kpi-tm-batches-sub').textContent = submitted>0 ? fmtMoney(submittedValue)+' awaiting payment' : 'All clear';

  }).catch(function(){
    ['kpi-tm-trips','kpi-tm-claim','kpi-tm-flagged','kpi-tm-batches'].forEach(function(id){
      var el = document.getElementById(id); if(el) el.textContent='?';
    });
  });
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
