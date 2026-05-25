<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Rental Cars &mdash; BookaWaka Admin</title>
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
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-g{background:#2E7D32;color:#fff}.sa-btn-g:hover{background:#1B5E20}
.sa-btn-r{background:#C62828;color:#fff}.sa-btn-r:hover{background:#B71C1C}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32;display:block}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828;display:block}
.sa-ff label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:6px;font-size:13px;box-sizing:border-box;font-family:inherit}
.sa-ff input:focus,.sa-ff select:focus{outline:none;border-color:#1565C0}
.set-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;padding:18px}
.set-section{border-bottom:1px solid #f5f5f5}
.set-section:last-child{border-bottom:none}
.set-section-hdr{padding:14px 18px;font-size:13px;font-weight:700;color:#1565C0;background:#F0F7FF;display:flex;align-items:center;gap:6px}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#F5F5F5;padding:10px 14px;text-align:left;font-weight:700;color:#374151;border-bottom:2px solid #e0e0e0;white-space:nowrap}
.sa-tbl td{padding:10px 14px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.sa-tbl tr:hover td{background:#FAFAFA}
.status-badge{display:inline-block;padding:3px 9px;border-radius:10px;font-size:11px;font-weight:700;text-transform:uppercase}
.s-pending{background:#FFF8E1;color:#F57F17}
.s-confirmed{background:#E3F2FD;color:#1565C0}
.s-active{background:#E8F5E9;color:#2E7D32}
.s-completed{background:#F3E5F5;color:#6A1B9A}
.s-cancelled{background:#FFEBEE;color:#C62828}
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:14px;padding:18px}
.kpi-box{background:#F8F9FF;border-radius:8px;padding:16px 18px;border-left:4px solid #1565C0;text-align:center}
.kpi-box.green{border-left-color:#2E7D32}
.kpi-box.orange{border-left-color:#E65100}
.kpi-box.purple{border-left-color:#6A1B9A}
.kpi-box.teal{border-left-color:#00695C}
.kpi-val{font-size:28px;font-weight:800;color:#263238;line-height:1}
.kpi-lbl{font-size:11px;color:#90A4AE;margin-top:5px;font-weight:600;text-transform:uppercase}
.toggle-row{display:flex;align-items:center;gap:14px;padding:14px 18px;flex-wrap:wrap}
.toggle-label{font-size:13px;font-weight:600;color:#374151;flex:1;min-width:200px}
.toggle-label small{display:block;font-size:11px;font-weight:400;color:#9e9e9e;margin-top:2px}
.toggle-btn{min-width:80px;padding:7px 16px;border-radius:20px;border:none;cursor:pointer;font-size:13px;font-weight:700;transition:background .2s}
.co-card{display:flex;align-items:center;gap:14px;padding:14px 18px;border-bottom:1px solid #f5f5f5}
.co-card:last-child{border-bottom:none}
.co-avatar{width:40px;height:40px;border-radius:50%;background:#1565C0;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:14px;flex-shrink:0}
.co-info{flex:1}
.co-name{font-weight:700;font-size:13px;color:#263238}
.co-sub{font-size:11px;color:#9e9e9e;margin-top:2px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">&#128663; Rental Cars &mdash; BookaWaka Admin</label></div>
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
    <li class="current_section" title="Rental Cars"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE531;</i></span><span class="menu_title">Rental Cars</span></a><ul>
      <li><a href="SA-Rental.aspx" style="font-weight:700;color:#1565C0">&#9658; Rental Dashboard</a></li>
      <li><a href="SA-Rental.aspx#reservations">All Reservations</a></li>
      <li><a href="SA-Rental.aspx#config">Platform Config</a></li>
      <li><a href="/rental-portal" target="_blank">Owner Portal &#8599;</a></li>
      <li><a href="SA-Rental.aspx#taxi-requests">Taxi Requests</a></li>
      <li><a href="SA-Rental.aspx#promo-codes">Promo Codes</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Restaurants.aspx">Restaurants</a></li>
      <li><a href="FD-Orders.aspx">All Orders</a></li>
    </ul></li>
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Orders.aspx">All Orders</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;color:#263238;margin:0 0 16px">&#128663; Rental Cars Platform</h2>

<!-- KPI Row -->
<div class="sa-card">
  <div class="sa-bar" style="background:#00695C"><h3>&#128202; Rental Overview</h3>
    <button onclick="loadAll()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px">&#8635; Refresh</button>
  </div>
  <div class="kpi-row">
    <div class="kpi-box green">
      <div class="kpi-val" id="kpi-companies">—</div>
      <div class="kpi-lbl">Rental Companies</div>
    </div>
    <div class="kpi-box">
      <div class="kpi-val" id="kpi-vehicles">—</div>
      <div class="kpi-lbl">Total Vehicles</div>
    </div>
    <div class="kpi-box orange">
      <div class="kpi-val" id="kpi-active">—</div>
      <div class="kpi-lbl">Active Rentals</div>
    </div>
    <div class="kpi-box purple">
      <div class="kpi-val" id="kpi-reservations">—</div>
      <div class="kpi-lbl">Total Reservations</div>
    </div>
    <div class="kpi-box teal">
      <div class="kpi-val" id="kpi-revenue">—</div>
      <div class="kpi-lbl">Platform Commission</div>
    </div>
  </div>
</div>

<!-- Analytics Charts -->
<div class="sa-card">
  <div class="sa-bar" style="background:#00695C"><h3>&#128202; Analytics</h3>
    <button onclick="renderCharts()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px">&#8635; Refresh Charts</button>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:18px;padding:20px">
    <div>
      <div style="font-size:12px;font-weight:700;color:#374151;margin-bottom:10px">&#128200; Reservations — Last 30 Days</div>
      <canvas id="chart-trend" height="200"></canvas>
    </div>
    <div>
      <div style="font-size:12px;font-weight:700;color:#374151;margin-bottom:10px">&#127939; Status Breakdown</div>
      <canvas id="chart-status" height="200"></canvas>
    </div>
    <div>
      <div style="font-size:12px;font-weight:700;color:#374151;margin-bottom:10px">&#127970; Revenue by Company</div>
      <canvas id="chart-company" height="200"></canvas>
    </div>
  </div>
</div>

<!-- Platform Config -->
<div class="sa-card" id="config">
  <div class="sa-bar" style="background:#4527A0"><h3>&#9881; Platform Rental Configuration</h3>
    <button onclick="saveRentalConfig()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px">&#10003; Save Config</button>
  </div>

  <!-- Master switch -->
  <div class="set-section">
    <div class="set-section-hdr">&#128663; Rental Module — Master Switch</div>
    <div class="toggle-row">
      <div class="toggle-label">Rental Cars Platform-Wide
        <small>When OFF, rental module is hidden from all passenger apps and websites</small>
      </div>
      <button id="rc-master-btn" onclick="toggleMaster()" class="toggle-btn">Loading…</button>
    </div>
  </div>

  <!-- Commission -->
  <div class="set-section">
    <div class="set-section-hdr">&#128179; Default Commission & Deposit</div>
    <div class="set-grid">
      <div class="sa-ff">
        <label>Default Commission % <span style="font-size:11px;color:#888;font-weight:400">(BookaWaka takes this % of each rental)</span></label>
        <input id="rc-commission" type="number" min="0" max="50" step="0.5" placeholder="e.g. 12"/>
      </div>
      <div class="sa-ff">
        <label>Deposit Policy <span style="font-size:11px;color:#888;font-weight:400">(platform default)</span></label>
        <select id="rc-deposit-policy">
          <option value="held">Hold &amp; release on return (recommended)</option>
          <option value="upfront">Charge upfront, refund on return</option>
        </select>
      </div>
      <div class="sa-ff">
        <label>Long Rental Threshold (days) <span style="font-size:11px;color:#888;font-weight:400">(use upfront capture for rentals longer than this)</span></label>
        <input id="rc-long-rental-days" type="number" min="1" placeholder="e.g. 7"/>
      </div>
    </div>
  </div>

  <!-- Ride to Rental -->
  <div class="set-section">
    <div class="set-section-hdr">&#128664; Ride-to-Rental Cross-Sell</div>
    <p style="padding:8px 18px 0;font-size:12px;color:#888;margin:0">After a customer confirms a rental booking, offer them a discounted taxi ride to pick up their car — or back home when they return it. Uses BookaWaka's existing taxi network.</p>
    <div class="toggle-row">
      <div class="toggle-label">Offer Ride-to-Rental
        <small>Show taxi booking prompt after rental confirmation</small>
      </div>
      <button id="rc-r2r-btn" onclick="toggleR2R()" class="toggle-btn">Loading…</button>
    </div>
    <div class="set-grid">
      <div class="sa-ff">
        <label>Discount % on taxi ride <span style="font-size:11px;color:#888;font-weight:400">(shown to customer after booking)</span></label>
        <input id="rc-r2r-discount" type="number" min="0" max="100" step="5" placeholder="e.g. 20"/>
      </div>
      <div class="sa-ff" style="grid-column:span 2">
        <label>Offer Message <span style="font-size:11px;color:#888;font-weight:400">(shown to customer on confirmation screen)</span></label>
        <input id="rc-r2r-msg" type="text" placeholder="e.g. Need a ride to pick up your rental? Book now and get 20% off!"/>
      </div>
    </div>
  </div>

  <div style="padding:0 18px 18px;display:flex;gap:8px;align-items:center">
    <button onclick="saveRentalConfig()" class="sa-btn sa-btn-p">&#10003; Save Config</button>
    <span id="rc-save-msg" style="font-size:12px;color:#888"></span>
  </div>
</div>

<!-- Rental Companies -->
<div class="sa-card">
  <div class="sa-bar" style="background:#E65100"><h3>&#127970; Rental Companies</h3>
    <span style="font-size:11px;opacity:.7">Companies with rentalEnabled = true in companySettings</span>
  </div>
  <div id="rental-companies-body" style="padding:16px 18px;font-size:13px;color:#aaa">Loading&hellip;</div>
</div>

<!-- Per-Company Commission Override + Portal Access -->
<div class="sa-card" id="co-commission-card" style="display:none">
  <div class="sa-bar" style="background:#37474F"><h3 id="co-commission-title">&#128179; Company Settings</h3></div>
  <div style="padding:16px 18px">

    <!-- Commission & Ride-to-Rental -->
    <p style="font-size:12.5px;font-weight:700;color:#263238;margin-bottom:8px">Commission &amp; Ride-to-Rental Override</p>
    <p style="font-size:12px;color:#888;margin:0 0 12px">Override the platform default for this company. Leave blank to use platform default.</p>
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px;align-items:end;margin-bottom:20px">
      <div class="sa-ff">
        <label>Commission % Override</label>
        <input id="co-comm-val" type="number" min="0" max="50" step="0.5" placeholder="Platform default"/>
      </div>
      <div class="sa-ff">
        <label>Ride-to-Rental for this company</label>
        <select id="co-r2r-override">
          <option value="">Use platform default</option>
          <option value="true">ON — offer the taxi ride</option>
          <option value="false">OFF — don't show</option>
        </select>
      </div>
      <div>
        <button onclick="saveCoCommission()" class="sa-btn sa-btn-p">&#10003; Save Override</button>
        <span id="co-comm-msg" style="font-size:12px;color:#888;display:block;margin-top:6px"></span>
      </div>
    </div>

    <!-- Portal Access Setup -->
    <div style="border-top:1px solid #f0f0f0;padding-top:16px">
      <p style="font-size:12.5px;font-weight:700;color:#263238;margin-bottom:6px">&#128663; Rental Owner Portal Access</p>
      <p style="font-size:12px;color:#888;margin:0 0 12px">Set up login credentials so this rental company can access their Owner Portal at <a href="/rental-portal" target="_blank" style="color:#1565C0">/rental-portal &#8599;</a></p>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr auto;gap:12px;align-items:end">
        <div class="sa-ff">
          <label>Company Name (for portal)</label>
          <input id="co-portal-name" type="text" placeholder="e.g. City Rentals Ltd"/>
        </div>
        <div class="sa-ff">
          <label>Login Email</label>
          <input id="co-portal-email" type="email" placeholder="owner@rentalcompany.com"/>
        </div>
        <div class="sa-ff">
          <label>Password (min 6 chars)</label>
          <input id="co-portal-pwd" type="password" placeholder="Set a strong password"/>
        </div>
        <div>
          <button onclick="setupPortalAccess()" class="sa-btn" style="background:#00695C;color:#fff">&#128663; Setup Portal</button>
          <span id="co-portal-msg" style="font-size:12px;color:#888;display:block;margin-top:6px"></span>
        </div>
      </div>
    </div>

  </div>
</div>

<!-- Revenue & Commission -->
<div class="sa-card" id="revenue">
  <div class="sa-bar" style="background:#2E7D32"><h3>&#128200; Revenue &amp; Commission</h3>
    <div style="display:flex;gap:8px;align-items:center">
      <select id="rev-period" onchange="loadRentalRevenue()" style="font-size:12px;padding:5px 8px;border-radius:4px;border:1px solid rgba(255,255,255,.3);background:rgba(255,255,255,.1);color:#fff">
        <option value="all">All Time</option>
        <option value="month" selected>This Month</option>
      </select>
      <a href="/rent" target="_blank" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px">&#128663; Booking Page &#8599;</a>
    </div>
  </div>
  <div id="rev-loading" style="padding:20px 18px;color:#aaa;font-size:13px">Loading revenue data&hellip;</div>
  <div id="rev-wrap" style="display:none">
    <div style="overflow-x:auto">
      <table class="sa-tbl" id="rev-tbl">
        <thead><tr>
          <th>Company</th>
          <th>Reservations</th>
          <th>Active</th>
          <th>Total Revenue</th>
          <th>This Month</th>
          <th>Commission Rate</th>
          <th>Commission Earned</th>
        </tr></thead>
        <tbody id="rev-tbody"></tbody>
        <tfoot id="rev-tfoot" style="font-weight:700;background:#F1F8E9"></tfoot>
      </table>
    </div>
  </div>
  <div id="rev-empty" style="display:none;padding:20px 18px;color:#aaa;font-size:13px;font-style:italic">No revenue data yet.</div>
</div>

<!-- All Reservations -->
<div class="sa-card" id="reservations">
  <div class="sa-bar" style="background:#1565C0"><h3>&#128203; All Rental Reservations</h3>
    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
      <select id="res-filter-status" onchange="filterReservations()" style="font-size:12px;padding:5px 8px;border-radius:4px;border:1px solid rgba(255,255,255,.3);background:rgba(255,255,255,.1);color:#fff">
        <option value="">All Statuses</option>
        <option value="pending">Pending</option>
        <option value="confirmed">Confirmed</option>
        <option value="active">Active</option>
        <option value="completed">Completed</option>
        <option value="cancelled">Cancelled</option>
      </select>
      <select id="res-filter-company" onchange="filterReservations()" style="font-size:12px;padding:5px 8px;border-radius:4px;border:1px solid rgba(255,255,255,.3);background:rgba(255,255,255,.1);color:#fff">
        <option value="">All Companies</option>
      </select>
    </div>
  </div>
  <div id="res-loading" style="padding:20px 18px;color:#aaa;font-size:13px">Loading reservations&hellip;</div>
  <div style="overflow-x:auto;display:none" id="res-wrap">
    <table class="sa-tbl" id="res-tbl">
      <thead><tr>
        <th>Job ID</th>
        <th>Company</th>
        <th>Customer</th>
        <th>Vehicle</th>
        <th>Pickup</th>
        <th>Return</th>
        <th>Days</th>
        <th>Total</th>
        <th>Deposit</th>
        <th>Insurance</th>
        <th>Commission</th>
        <th>Status</th>
        <th>Ride-to-Rental</th>
        <th>Actions</th>
      </tr></thead>
      <tbody id="res-tbody"></tbody>
    </table>
  </div>
  <div id="res-empty" style="padding:20px 18px;color:#aaa;font-size:13px;display:none">No reservations found.</div>
</div>

<!-- Taxi Ride Requests -->
<div class="sa-card" id="taxi-requests">
  <div class="sa-bar" style="background:#00695C">
    <h3>&#128664; Taxi Ride Requests</h3>
    <span style="font-size:11px;opacity:.7">Customers who used the Ride-to-Rental cross-sell at /ride</span>
  </div>
  <div id="taxi-req-loading" style="padding:20px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>
  <div style="overflow-x:auto;display:none" id="taxi-req-wrap">
    <table class="sa-tbl">
      <thead><tr>
        <th>Reference</th><th>Customer</th><th>Phone</th><th>Pickup Address</th>
        <th>Destination</th><th>Scheduled</th><th>Promo Code</th><th>Discount</th><th>Status</th><th>Requested</th>
      </tr></thead>
      <tbody id="taxi-req-tbody"></tbody>
    </table>
  </div>
  <div id="taxi-req-empty" style="padding:20px 18px;color:#aaa;font-size:13px;display:none">No taxi ride requests yet. They appear here when customers use their rental promo code at <strong>/ride</strong>.</div>
</div>

<!-- Promo Codes -->
<div class="sa-card" id="promo-codes">
  <div class="sa-bar" style="background:#4527A0">
    <h3>&#127881; Ride-to-Rental Promo Codes</h3>
    <select id="promo-filter" onchange="filterPromos()" style="font-size:12px;padding:5px 8px;border-radius:4px;border:1px solid rgba(255,255,255,.3);background:rgba(255,255,255,.1);color:#fff">
      <option value="">All Codes</option>
      <option value="valid">Valid (unused)</option>
      <option value="used">Used</option>
      <option value="expired">Expired</option>
    </select>
  </div>
  <div id="promo-loading" style="padding:20px 18px;color:#aaa;font-size:13px">Loading&hellip;</div>
  <div style="overflow-x:auto;display:none" id="promo-wrap">
    <table class="sa-tbl">
      <thead><tr>
        <th>Code</th><th>Customer Email</th><th>Discount</th><th>Rental Booking</th><th>Status</th><th>Created</th><th>Expires</th>
      </tr></thead>
      <tbody id="promo-tbody"></tbody>
    </table>
  </div>
  <div id="promo-empty" style="padding:20px 18px;color:#aaa;font-size:13px;display:none">No promo codes issued yet.</div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var db = firebase.database();
var _masterEnabled = true;
var _r2rEnabled    = true;
var _selectedCo    = null;
var _allReservations = [];
var _rentalCos = {};

// ── Load on login ─────────────────────────────────────────────────────────────
window._fbOnLogin = function(){
  loadRentalConfig();
  loadRentalCompanies();
  loadAllReservations();
  loadRentalRevenue();
};

function loadAll(){ loadRentalConfig(); loadRentalCompanies(); loadAllReservations(); loadRentalRevenue(); loadTaxiRequests(); loadPromoCodes(); }

// ── Revenue & Commission ──────────────────────────────────────────────────────
function loadRentalRevenue(){
  document.getElementById('rev-loading').style.display='block';
  document.getElementById('rev-wrap').style.display='none';
  document.getElementById('rev-empty').style.display='none';
  fetch('/api/admin/rental-revenue').then(function(r){ return r.json(); }).then(function(d){
    document.getElementById('rev-loading').style.display='none';
    if(!d.ok || !d.data || !Object.keys(d.data).length){
      document.getElementById('rev-empty').style.display='block'; return;
    }
    var period = document.getElementById('rev-period').value;
    var rows = '', totRev=0, totComm=0, totCount=0;
    Object.keys(d.data).forEach(function(cid){
      var row = d.data[cid];
      var rev = period==='month' ? row.thisMonth : row.total;
      var comm = rev * row.commissionRate / 100;
      totRev += rev; totComm += comm; totCount += row.count;
      var coName = (_rentalCos[cid] && _rentalCos[cid].name) || cid;
      rows += '<tr>'
        +'<td style="font-weight:600">'+coName+'<br><span style="font-size:10px;color:#aaa">'+cid+'</span></td>'
        +'<td>'+row.count+'</td>'
        +'<td>'+(row.active>0?'<span style="color:#2E7D32;font-weight:700">'+row.active+' active</span>':'<span style="color:#aaa">0</span>')+'</td>'
        +'<td style="font-weight:600">$'+row.total.toFixed(2)+'</td>'
        +'<td>$'+row.thisMonth.toFixed(2)+'</td>'
        +'<td><span style="background:#E8F5E9;color:#2E7D32;padding:2px 8px;border-radius:10px;font-size:12px;font-weight:700">'+row.commissionRate+'%</span></td>'
        +'<td style="font-weight:700;color:#2E7D32">$'+comm.toFixed(2)+'</td>'
        +'</tr>';
    });
    document.getElementById('rev-tbody').innerHTML = rows;
    document.getElementById('rev-tfoot').innerHTML = '<tr>'
      +'<td colspan="2" style="padding:10px 14px">TOTAL ('+totCount+' reservations)</td>'
      +'<td></td>'
      +'<td style="padding:10px 14px">$'+totRev.toFixed(2)+'</td>'
      +'<td></td><td></td>'
      +'<td style="padding:10px 14px;color:#2E7D32">$'+totComm.toFixed(2)+'</td>'
      +'</tr>';
    document.getElementById('kpi-revenue').textContent = '$'+totComm.toFixed(2);
    document.getElementById('rev-wrap').style.display='block';
  }).catch(function(e){
    document.getElementById('rev-loading').style.display='none';
    document.getElementById('rev-empty').style.display='block';
    document.getElementById('rev-empty').textContent = 'Error: '+e.message;
  });
}

// ── Platform Config ───────────────────────────────────────────────────────────
function loadRentalConfig(){
  _fbGet('bwConfig/rental').then(function(c){
    c = c || {};
    renderMasterBtn(c.enabled !== false);
    renderR2RBtn(c.rideToRental && c.rideToRental.enabled !== false);
    if(c.defaultCommission !== undefined) document.getElementById('rc-commission').value = c.defaultCommission;
    if(c.depositPolicy) document.getElementById('rc-deposit-policy').value = c.depositPolicy;
    if(c.longRentalDays) document.getElementById('rc-long-rental-days').value = c.longRentalDays;
    if(c.rideToRental){
      if(c.rideToRental.discountPercent !== undefined) document.getElementById('rc-r2r-discount').value = c.rideToRental.discountPercent;
      if(c.rideToRental.message) document.getElementById('rc-r2r-msg').value = c.rideToRental.message;
    }
  });
}

function renderMasterBtn(on){
  _masterEnabled = !!on;
  var btn = document.getElementById('rc-master-btn');
  btn.textContent = on ? '✔ ON' : '✖ OFF';
  btn.style.background = on ? '#2E7D32' : '#C62828';
  btn.style.color = '#fff';
}

function renderR2RBtn(on){
  _r2rEnabled = !!on;
  var btn = document.getElementById('rc-r2r-btn');
  btn.textContent = on ? '✔ ON' : '✖ OFF';
  btn.style.background = on ? '#2E7D32' : '#C62828';
  btn.style.color = '#fff';
}

function toggleMaster(){ renderMasterBtn(!_masterEnabled); }
function toggleR2R(){ renderR2RBtn(!_r2rEnabled); }

function saveRentalConfig(){
  var payload = {
    enabled:          _masterEnabled,
    defaultCommission: parseFloat(document.getElementById('rc-commission').value) || 12,
    depositPolicy:    document.getElementById('rc-deposit-policy').value,
    longRentalDays:   parseInt(document.getElementById('rc-long-rental-days').value) || 7,
    rideToRental: {
      enabled:         _r2rEnabled,
      discountPercent: parseFloat(document.getElementById('rc-r2r-discount').value) || 20,
      message:         document.getElementById('rc-r2r-msg').value || 'Need a ride to your rental? Book now and save!'
    },
    updatedAt: Date.now()
  };
  db.ref('bwConfig/rental').set(payload).then(function(){
    var msg = document.getElementById('rc-save-msg');
    msg.textContent = '✔ Saved at ' + new Date().toLocaleTimeString();
    msg.style.color = '#2E7D32';
    setTimeout(function(){ msg.textContent=''; }, 4000);
  }).catch(function(e){
    var msg = document.getElementById('rc-save-msg');
    msg.textContent = 'Error: ' + e.message;
    msg.style.color = '#C62828';
  });
}

// ── Rental Companies ──────────────────────────────────────────────────────────
function loadRentalCompanies(){
  _fbGet('companySettings').then(function(all){
    all = all || {};
    var body = document.getElementById('rental-companies-body');
    var cos = [];
    Object.keys(all).forEach(function(cid){
      if(all[cid] && all[cid].features && all[cid].features.rentalEnabled){
        cos.push({cid: cid, data: all[cid]});
      }
    });
    _rentalCos = {};
    cos.forEach(function(c){ _rentalCos[c.cid] = c; });
    document.getElementById('kpi-companies').textContent = cos.length;
    if(!cos.length){
      body.innerHTML = '<div style="padding:16px;color:#aaa;font-size:13px">No rental companies enabled yet. Enable <strong>Rental Cars</strong> in a company\'s feature flags (SA-Company.aspx) to get started.</div>';
      return;
    }
    body.innerHTML = '';
    // Load vehicle counts
    var pending = cos.length;
    var totalVehicles = 0;
    var companyFilter = document.getElementById('res-filter-company');
    companyFilter.innerHTML = '<option value="">All Companies</option>';
    cos.forEach(function(c){
      Promise.all([
        _fbGet('superClients/'+c.cid),
        _fbGet('rentalFleet/'+c.cid),
        _fbGet('rentalConfig/'+c.cid)
      ]).then(function(res){
        var name = (res[0] && res[0].name) || c.cid;
        var fleet = res[1] || {};
        var vCount = Object.keys(fleet).length;
        totalVehicles += vCount;
        var cfg = res[2] || {};
        companyFilter.innerHTML += '<option value="'+c.cid+'">'+name+'</option>';
        body.innerHTML += buildCoCard(c.cid, name, vCount, cfg);
        pending--;
        if(!pending){ document.getElementById('kpi-vehicles').textContent = totalVehicles; }
      });
    });
  });
}

function buildCoCard(cid, name, vCount, cfg){
  var initials = name.split(' ').map(function(w){ return w[0]||''; }).join('').substring(0,2).toUpperCase();
  var comm = cfg.commission !== undefined ? cfg.commission+'%' : 'Platform default';
  var r2r  = cfg.rideToRental === true ? '✔ ON' : cfg.rideToRental === false ? '✖ OFF' : 'Platform default';
  return '<div class="co-card">'
    +'<div class="co-avatar">'+initials+'</div>'
    +'<div class="co-info">'
      +'<div class="co-name">'+name+' <span style="font-size:11px;color:#9e9e9e;font-weight:400">'+cid+'</span></div>'
      +'<div class="co-sub">'+vCount+' vehicle'+(vCount!==1?'s':'')+' &nbsp;|&nbsp; Commission: '+comm+' &nbsp;|&nbsp; Ride-to-Rental: '+r2r+'</div>'
    +'</div>'
    +'<div style="display:flex;gap:8px">'
      +'<button onclick="selectCo(\''+cid+'\',\''+name+'\')" class="sa-btn sa-btn-n" style="font-size:12px">&#9881; Override</button>'
      +'<a href="SA-Company.aspx?cid='+cid+'" class="sa-btn sa-btn-p" style="font-size:12px">View Company &#8599;</a>'
    +'</div>'
    +'</div>';
}

var _selectedCoId = null;
function selectCo(cid, name){
  _selectedCoId = cid;
  document.getElementById('co-commission-card').style.display='block';
  document.getElementById('co-commission-title').textContent = '&#128179; Commission Override — '+name;
  _fbGet('rentalConfig/'+cid).then(function(c){
    c = c || {};
    document.getElementById('co-comm-val').value = c.commission !== undefined ? c.commission : '';
    document.getElementById('co-r2r-override').value = c.rideToRental !== undefined ? String(c.rideToRental) : '';
  });
  document.getElementById('co-commission-card').scrollIntoView({behavior:'smooth'});
}

function saveCoCommission(){
  if(!_selectedCoId) return;
  var commVal = document.getElementById('co-comm-val').value;
  var r2rVal  = document.getElementById('co-r2r-override').value;
  var updates = { updatedAt: Date.now() };
  if(commVal !== '') updates.commission = parseFloat(commVal);
  if(r2rVal !== '') updates.rideToRental = (r2rVal === 'true');
  db.ref('rentalConfig/'+_selectedCoId).update(updates).then(function(){
    var msg = document.getElementById('co-comm-msg');
    msg.textContent = '✔ Saved'; msg.style.color = '#2E7D32';
    setTimeout(function(){ msg.textContent=''; loadRentalCompanies(); }, 2000);
  }).catch(function(e){
    document.getElementById('co-comm-msg').textContent = 'Error: '+e.message;
  });
}

function setupPortalAccess(){
  if(!_selectedCoId) return;
  var name  = document.getElementById('co-portal-name').value.trim();
  var email = document.getElementById('co-portal-email').value.trim();
  var pwd   = document.getElementById('co-portal-pwd').value;
  var msg   = document.getElementById('co-portal-msg');
  if(!name || !email || !pwd){ msg.textContent='Please fill all fields'; msg.style.color='#C62828'; return; }
  if(pwd.length < 6){ msg.textContent='Password must be at least 6 characters'; msg.style.color='#C62828'; return; }
  msg.textContent = 'Setting up…'; msg.style.color = '#888';
  fetch('/api/set-rental-password', {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ companyId: _selectedCoId, name: name, email: email, password: pwd })
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){
      msg.textContent = '✔ Portal access set up. They can now log in at /rental-portal';
      msg.style.color = '#2E7D32';
      document.getElementById('co-portal-pwd').value = '';
    } else {
      msg.textContent = 'Error: ' + (d.error || 'Unknown error');
      msg.style.color = '#C62828';
    }
  }).catch(function(e){
    msg.textContent = 'Error: ' + e.message;
    msg.style.color = '#C62828';
  });
}

// ── All Reservations ──────────────────────────────────────────────────────────
function loadAllReservations(){
  _fbGet('rentalReservations').then(function(all){
    all = all || {};
    _allReservations = [];
    var active = 0, total = 0, revenue = 0;
    Object.keys(all).forEach(function(cid){
      var cos = all[cid] || {};
      Object.keys(cos).forEach(function(rid){
        var r = cos[rid]; r._cid = cid; r._rid = rid;
        _allReservations.push(r);
        total++;
        if(r.status === 'active') active++;
        if(r.pricing && r.pricing.platform) revenue += (r.pricing.platform || 0);
      });
    });
    document.getElementById('kpi-active').textContent = active;
    document.getElementById('kpi-reservations').textContent = total;
    document.getElementById('kpi-revenue').textContent = '$'+revenue.toFixed(2);
    filterReservations();
    renderCharts();
  }).catch(function(){
    document.getElementById('res-loading').textContent = 'No reservations yet.';
  });
}

var _rentCharts = {};
function renderCharts(){
  if(typeof Chart === 'undefined') return;

  // 1. Reservations trend — last 30 days
  var now = Date.now();
  var days = {};
  for(var i=29;i>=0;i--){
    var d = new Date(now - i*864e5);
    var key = d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')+'-'+String(d.getDate()).padStart(2,'0');
    days[key] = 0;
  }
  _allReservations.forEach(function(r){
    var ts = r.createdAt || r.pickupDate || 0;
    if(!ts) return;
    var d = new Date(ts);
    var key = d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')+'-'+String(d.getDate()).padStart(2,'0');
    if(Object.prototype.hasOwnProperty.call(days,key)) days[key]++;
  });
  var trendLabels = Object.keys(days).map(function(k){ var d=new Date(k+'T12:00:00'); return (d.getMonth()+1)+'/'+(d.getDate()); });
  var trendData   = Object.values(days);
  if(_rentCharts.trend) _rentCharts.trend.destroy();
  var ctx1 = document.getElementById('chart-trend');
  if(ctx1) _rentCharts.trend = new Chart(ctx1,{
    type:'line',
    data:{labels:trendLabels,datasets:[{label:'Reservations',data:trendData,borderColor:'#00695C',backgroundColor:'rgba(0,105,92,.1)',tension:.35,pointRadius:2,fill:true}]},
    options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{stepSize:1,precision:0}},x:{ticks:{maxTicksLimit:10,font:{size:10}}}}}
  });

  // 2. Status breakdown doughnut
  var statusCount = {pending:0,confirmed:0,active:0,completed:0,cancelled:0};
  _allReservations.forEach(function(r){ var s=r.status||'pending'; if(Object.prototype.hasOwnProperty.call(statusCount,s)) statusCount[s]++; });
  if(_rentCharts.status) _rentCharts.status.destroy();
  var ctx2 = document.getElementById('chart-status');
  if(ctx2) _rentCharts.status = new Chart(ctx2,{
    type:'doughnut',
    data:{
      labels:['Pending','Confirmed','Active','Completed','Cancelled'],
      datasets:[{data:[statusCount.pending,statusCount.confirmed,statusCount.active,statusCount.completed,statusCount.cancelled],
        backgroundColor:['#F9A825','#1565C0','#2E7D32','#6A1B9A','#C62828'],borderWidth:2,borderColor:'#fff'}]
    },
    options:{responsive:true,plugins:{legend:{position:'bottom',labels:{font:{size:11},boxWidth:12}}}}
  });

  // 3. Revenue by company bar
  var coRevMap = {};
  _allReservations.forEach(function(r){
    var rev = (r.pricing && r.pricing.subtotal) ? parseFloat(r.pricing.subtotal) : (r.pricing && r.pricing.total ? parseFloat(r.pricing.total) : 0);
    if(!coRevMap[r._cid]) coRevMap[r._cid] = 0;
    coRevMap[r._cid] += rev;
  });
  var coLabels = Object.keys(coRevMap).map(function(cid){ return (_rentalCos[cid] && _rentalCos[cid].name) || cid; });
  var coData   = Object.values(coRevMap).map(function(v){ return Math.round(v*100)/100; });
  if(_rentCharts.company) _rentCharts.company.destroy();
  var ctx3 = document.getElementById('chart-company');
  if(ctx3 && coLabels.length){
    _rentCharts.company = new Chart(ctx3,{
      type:'bar',
      data:{labels:coLabels,datasets:[{label:'Revenue ($)',data:coData,backgroundColor:'#00695C',borderRadius:4}]},
      options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{font:{size:10}}},x:{ticks:{font:{size:11}}}}}
    });
  } else if(ctx3){
    ctx3.parentElement.innerHTML='<div style="text-align:center;color:#aaa;padding:20px;font-size:13px">No reservation data yet.</div>';
  }
}

function filterReservations(){
  var statusF  = document.getElementById('res-filter-status').value;
  var companyF = document.getElementById('res-filter-company').value;
  var filtered = _allReservations.filter(function(r){
    if(statusF  && r.status !== statusF)   return false;
    if(companyF && r._cid  !== companyF)   return false;
    return true;
  });
  renderReservations(filtered);
}

function renderReservations(list){
  document.getElementById('res-loading').style.display = 'none';
  if(!list.length){
    document.getElementById('res-wrap').style.display = 'none';
    document.getElementById('res-empty').style.display = 'block';
    return;
  }
  document.getElementById('res-empty').style.display = 'none';
  document.getElementById('res-wrap').style.display = 'block';
  var tbody = document.getElementById('res-tbody');
  tbody.innerHTML = list.map(function(r){
    var pickup  = r.pickupDate  ? new Date(r.pickupDate).toLocaleDateString()  : '—';
    var ret     = r.returnDate  ? new Date(r.returnDate).toLocaleDateString()  : '—';
    var subtotal = r.pricing && r.pricing.subtotal ? r.pricing.subtotal : (r.pricing && r.pricing.total ? r.pricing.total : 0);
    var total   = subtotal ? '$'+parseFloat(subtotal).toFixed(2) : '—';
    var deposit = r.deposit && r.deposit.amount  ? '$'+parseFloat(r.deposit.amount).toFixed(2)  : '—';
    var depStat = r.deposit ? r.deposit.status : '';
    var ins     = r.insuranceTier || '—';
    var r2r     = r.rideToRentalBooked ? '<span style="color:#2E7D32;font-weight:700">✔ Booked</span>' : (r.promoCode ? '<span style="color:#1565C0;font-size:11px;font-weight:600">'+r.promoCode+'</span>' : '<span style="color:#9e9e9e">—</span>');
    var sBadge  = statusBadge(r.status);
    // Commission calculation
    var commRate = r.pricing && r.pricing.commissionRate ? parseFloat(r.pricing.commissionRate) : 12;
    var commAmt  = r.pricing && r.pricing.commission ? parseFloat(r.pricing.commission) : (subtotal * commRate / 100);
    var commHtml = commAmt > 0 ? '<span style="color:#2E7D32;font-weight:700">$'+commAmt.toFixed(2)+'</span><br><span style="font-size:10px;color:#888">('+commRate+'%)</span>' : '—';
    // Cancel button (only for cancellable statuses)
    var cancelBtn = '';
    if(r.status === 'confirmed' || r.status === 'pending'){
      cancelBtn = '<button onclick="cancelReservation(\''+r._cid+'\',\''+r._rid+'\')" style="background:#C62828;color:#fff;border:none;padding:4px 10px;border-radius:4px;font-size:11px;cursor:pointer;font-weight:600">✕ Cancel</button>';
    }
    return '<tr>'
      +'<td style="font-weight:700;font-family:monospace;color:#1565C0">'+(r.jobId||r._rid)+'</td>'
      +'<td>'+(r._cid||'—')+'</td>'
      +'<td>'+(r.customerId||'—')+'</td>'
      +'<td>'+(r.vehicleId||'—')+'</td>'
      +'<td>'+pickup+'</td>'
      +'<td>'+ret+'</td>'
      +'<td style="text-align:center">'+(r.billingDays||'—')+'</td>'
      +'<td style="font-weight:700">'+total+'</td>'
      +'<td>'+deposit+(depStat?' <span style="font-size:10px;color:#888">('+depStat+')</span>':'')+'</td>'
      +'<td style="text-transform:capitalize">'+ins+'</td>'
      +'<td>'+commHtml+'</td>'
      +'<td>'+sBadge+'</td>'
      +'<td>'+r2r+'</td>'
      +'<td>'+(cancelBtn||'—')+'</td>'
      +'</tr>';
  }).join('');
}

function cancelReservation(cid, rid){
  if(!confirm('Cancel this reservation and issue a Stripe refund?\n\nThis action cannot be undone.')) return;
  fetch('/api/admin/rental-cancel',{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({cid:cid, reservationId:rid})
  }).then(function(r){ return r.json(); }).then(function(d){
    if(d.ok){
      alert('Reservation cancelled.\n'+d.notes);
      loadAllReservations();
    } else {
      alert('Error: '+(d.error||'Unknown error'));
    }
  }).catch(function(e){ alert('Request failed: '+e.message); });
}

function statusBadge(s){
  var map = {pending:'s-pending',confirmed:'s-confirmed',active:'s-active',completed:'s-completed',cancelled:'s-cancelled'};
  return '<span class="status-badge '+(map[s]||'')+'>'+(s||'unknown')+'</span>';
}

// ── Taxi Ride Requests ────────────────────────────────────────────────────────
function loadTaxiRequests(){
  document.getElementById('taxi-req-loading').style.display='block';
  document.getElementById('taxi-req-wrap').style.display='none';
  document.getElementById('taxi-req-empty').style.display='none';
  _fbGet('rentalTaxiRequests').then(function(all){
    all = all || {};
    var list = Object.values(all).sort(function(a,b){ return (b.createdAt||0)-(a.createdAt||0); });
    document.getElementById('taxi-req-loading').style.display='none';
    if(!list.length){ document.getElementById('taxi-req-empty').style.display='block'; return; }
    document.getElementById('taxi-req-wrap').style.display='block';
    var sColors = {pending:'#F57F17',confirmed:'#2E7D32',completed:'#00695C',cancelled:'#C62828'};
    document.getElementById('taxi-req-tbody').innerHTML = list.map(function(r){
      var scheduled = r.scheduledAt ? new Date(r.scheduledAt).toLocaleString('en-NZ',{dateStyle:'short',timeStyle:'short'}) : '—';
      var created = r.createdAt ? new Date(r.createdAt).toLocaleString('en-NZ',{dateStyle:'short',timeStyle:'short'}) : '—';
      var sc = sColors[r.status||'pending'] || '#888';
      var promo = r.promoCode ? '<span style="font-family:monospace;color:#1B5E20;font-weight:700">'+r.promoCode+'</span>' : '<span style="color:#aaa">—</span>';
      var disc = r.discountPercent ? '<span style="color:#2E7D32;font-weight:700">'+r.discountPercent+'% off</span>' : '—';
      return '<tr>'
        +'<td style="font-family:monospace;font-weight:700;font-size:12px;color:#1565C0">'+(r.requestId||'—')+'</td>'
        +'<td style="font-weight:600">'+(r.customerName||'—')+'</td>'
        +'<td>'+(r.customerPhone||'—')+'</td>'
        +'<td style="font-size:12px;max-width:150px">'+(r.pickup||'—')+'</td>'
        +'<td style="font-size:12px;max-width:150px">'+(r.destination||'—')+'</td>'
        +'<td style="font-size:12px">'+scheduled+'</td>'
        +'<td>'+promo+'</td>'
        +'<td>'+disc+'</td>'
        +'<td><span style="background:'+sc+';color:#fff;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700;text-transform:capitalize">'+(r.status||'pending')+'</span></td>'
        +'<td style="font-size:11px;color:#888">'+created+'</td>'
        +'</tr>';
    }).join('');
  }).catch(function(){ document.getElementById('taxi-req-loading').textContent='Error loading requests.'; });
}

// ── Promo Codes ───────────────────────────────────────────────────────────────
var _allPromos = [];
function loadPromoCodes(){
  document.getElementById('promo-loading').style.display='block';
  document.getElementById('promo-wrap').style.display='none';
  document.getElementById('promo-empty').style.display='none';
  _fbGet('rentalPromos').then(function(all){
    all = all || {};
    _allPromos = Object.values(all).sort(function(a,b){ return (b.createdAt||0)-(a.createdAt||0); });
    document.getElementById('promo-loading').style.display='none';
    filterPromos();
  }).catch(function(){ document.getElementById('promo-loading').textContent='Error loading promo codes.'; });
}

function filterPromos(){
  var f = (document.getElementById('promo-filter')||{}).value || '';
  var now = Date.now();
  var filtered = _allPromos.filter(function(p){
    if(f==='valid')   return !p.used && (!p.expiresAt || p.expiresAt > now);
    if(f==='used')    return !!p.used;
    if(f==='expired') return !p.used && p.expiresAt && p.expiresAt <= now;
    return true;
  });
  if(!filtered.length){
    document.getElementById('promo-wrap').style.display='none';
    document.getElementById('promo-empty').style.display='block'; return;
  }
  document.getElementById('promo-empty').style.display='none';
  document.getElementById('promo-wrap').style.display='block';
  document.getElementById('promo-tbody').innerHTML = filtered.map(function(p){
    var now2 = Date.now();
    var expired = p.expiresAt && now2 > p.expiresAt;
    var status = p.used
      ? '<span style="background:#2E7D32;color:#fff;padding:2px 9px;border-radius:10px;font-size:11px">Used</span>'
      : expired
        ? '<span style="background:#9e9e9e;color:#fff;padding:2px 9px;border-radius:10px;font-size:11px">Expired</span>'
        : '<span style="background:#1565C0;color:#fff;padding:2px 9px;border-radius:10px;font-size:11px">Valid</span>';
    var created = p.createdAt ? new Date(p.createdAt).toLocaleDateString('en-NZ') : '—';
    var expires = p.expiresAt ? new Date(p.expiresAt).toLocaleDateString('en-NZ') : '—';
    return '<tr>'
      +'<td style="font-family:monospace;font-size:14px;font-weight:900;color:#1B5E20;letter-spacing:2px">'+(p.code||'—')+'</td>'
      +'<td style="font-size:12px">'+(p.customerEmail||'—')+'</td>'
      +'<td style="font-weight:700;color:#2E7D32">'+(p.discountPercent||0)+'%</td>'
      +'<td style="font-family:monospace;font-size:12px;color:#1565C0">'+(p.rentalJobId||'—')+'</td>'
      +'<td>'+status+'</td>'
      +'<td style="font-size:12px;color:#888">'+created+'</td>'
      +'<td style="font-size:12px;color:#888">'+expires+'</td>'
      +'</tr>';
  }).join('');
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
