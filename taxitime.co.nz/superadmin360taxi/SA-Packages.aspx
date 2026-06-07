<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Subscription Packages &mdash; BookaWaka Admin</title>
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
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-tbl tr:last-child td{border-bottom:none}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1;color:#fff}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}.sa-btn-s:hover{background:#C8E6C9}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-y{background:#FFF9C4;color:#F57F17;border:1px solid #FFF176}
.sa-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.sa-ff input:focus,.sa-ff select:focus,.sa-ff textarea:focus{outline:none;border-color:#1565C0}
.add-form{display:none;padding:18px;background:#F0F7FF;border-top:1px solid #BBDEFB}
.add-form.open{display:block}
.add-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:12px;margin-bottom:14px}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
/* Package cards */
.pkg-cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;padding:18px}
.pkg-card{border-radius:8px;border:2px solid #BBDEFB;overflow:hidden;position:relative}
.pkg-card.inactive{opacity:.55;border-color:#e0e0e0}
.pkg-card.join-visible{border-color:#2E7D32;border-width:2px}
.pkg-head{background:#1565C0;color:#fff;padding:14px 16px}
.pkg-head.flat-annual{background:#6A1B9A}
.pkg-head.flat-monthly{background:#0277BD}
.pkg-head h3{margin:0;font-size:16px;font-weight:700}
.pkg-price-main{font-size:28px;font-weight:800;margin:4px 0 0;line-height:1}
.pkg-price-main span{font-size:13px;font-weight:400;opacity:.85}
.pkg-price-sub{font-size:11.5px;opacity:.75;margin-top:3px}
.pkg-body{padding:14px 16px}
.pkg-desc{font-size:12.5px;color:#757575;margin-bottom:10px}
.pkg-mods{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:12px}
.mod-tag{display:inline-flex;align-items:center;gap:3px;font-size:11px;font-weight:600;padding:3px 9px;border-radius:12px}
.mod-taxi{background:#E3F2FD;color:#1565C0}
.mod-food{background:#E8F5E9;color:#1B5E20}
.mod-freight{background:#F3E5F5;color:#6A1B9A}
.mod-off{background:#f5f5f5;color:#ccc}
.pkg-actions{display:flex;gap:6px;flex-wrap:wrap}
.badge-active{background:#E8F5E9;color:#2E7D32;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7;position:absolute;top:10px;right:10px}
.badge-inactive{background:#f5f5f5;color:#aaa;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #e0e0e0;position:absolute;top:10px;right:10px}
.badge-join{background:#E8F5E9;color:#2E7D32;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7}
.edit-panel{display:none;background:#F0F7FF;border-top:1px solid #BBDEFB;padding:14px 16px}
.edit-panel.open{display:block}
.edit-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px}
/* Volume tier table */
.tier-tbl{width:100%;border-collapse:collapse;font-size:12px;margin-bottom:8px}
.tier-tbl th{background:#BBDEFB;padding:5px 8px;text-align:left;font-weight:600;color:#0D47A1}
.tier-tbl td{padding:5px 8px;border-bottom:1px solid #e0e0e0;vertical-align:middle}
.tier-tbl input{padding:4px 6px;border:1px solid #ddd;border-radius:3px;font-size:12px;width:80px}
.tier-tbl input:focus{outline:none;border-color:#1565C0}
/* Company pricing */
.co-override-row{background:#FFFDE7}
.badge-custom{background:#FFF9C4;color:#E65100;font-size:10px;font-weight:700;padding:2px 7px;border-radius:10px;border:1px solid #FFE082;white-space:nowrap}
.badge-default{background:#E3F2FD;color:#1565C0;font-size:10px;font-weight:700;padding:2px 7px;border-radius:10px;border:1px solid #BBDEFB;white-space:nowrap}
.inline-edit-row{display:none}
.inline-edit-row td{background:#F0F7FF!important;padding:10px 11px!important}
.inline-edit-row.open{display:table-row}
.ie-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:8px;margin-bottom:10px}
.ie-grid .sa-ff input,.ie-grid .sa-ff select{font-size:12px;padding:6px 8px}
.est-pill{display:inline-block;background:#E8F5E9;color:#1B5E20;font-weight:700;padding:3px 10px;border-radius:12px;font-size:12px}
.est-pill.custom{background:#FFF9C4;color:#E65100}
.billing-type-badge{display:inline-block;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px;margin-bottom:6px}
.bt-per-car{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.bt-flat-monthly{background:#E8F5E9;color:#1B5E20;border:1px solid #A5D6A7}
.bt-flat-annual{background:#F3E5F5;color:#6A1B9A;border:1px solid #CE93D8}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Subscription Packages &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Packages.aspx" style="font-weight:700;color:#1565C0">&#9658; Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
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
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
      <li><a href="SA-Broadcast.aspx">Broadcast</a></li>
      <li><a href="SA-Sessions.aspx">Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx">Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
      <li><a href="/join" target="_blank">Join Page &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:4px">&#128230; Subscription Packages</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">
  Create package tiers with flexible pricing: <strong>per taxi/month</strong> (with optional volume discounts),
  <strong>flat monthly</strong>, or <strong>flat annual</strong>. Toggle <em>Show on Join Page</em> to control which packages
  appear when operators sign up at <a href="/join" target="_blank">/join</a>. Changes are live instantly.
</p>

<div id="sa-notice" style="display:none" class="sa-notice"></div>

<!-- ════ PACKAGE TIERS ════ -->
<div class="sa-card">
  <div class="sa-bar">
    <h3>&#128230; Package Tiers</h3>
    <button class="sa-btn sa-btn-p" onclick="toggleAddForm()">&#43; New Package</button>
  </div>

  <!-- Add Form -->
  <div id="add-form" class="add-form">
    <div style="font-size:13px;font-weight:600;color:#1565C0;margin-bottom:12px">&#43; Create New Package</div>
    <div class="add-grid">
      <div class="sa-ff"><label>Package Name <span style="color:#C62828">*</span></label><input id="f-name" placeholder="e.g. Growth"/></div>
      <div class="sa-ff">
        <label>Billing Type <span style="color:#C62828">*</span></label>
        <select id="f-btype" onchange="toggleBillingFields('f')">
          <option value="per_car_monthly">Per taxi / month</option>
          <option value="flat_monthly">Flat monthly fee</option>
          <option value="flat_annual">Flat annual fee</option>
        </select>
      </div>
      <div class="sa-ff" id="f-ppc-wrap"><label>Price per Taxi / Month (NZD) <span style="color:#C62828">*</span></label><input id="f-ppc" type="number" min="0" step="0.50" placeholder="e.g. 15.00"/></div>
      <div class="sa-ff" id="f-flat-wrap" style="display:none"><label>Flat Price (NZD) <span style="color:#C62828">*</span></label><input id="f-flat" type="number" min="0" step="1" placeholder="e.g. 500.00"/></div>
      <div class="sa-ff" id="f-min-wrap"><label>Minimum Monthly (NZD) <span style="color:#aaa">optional</span></label><input id="f-minmonth" type="number" min="0" step="1" placeholder="e.g. 50"/></div>
      <div class="sa-ff"><label>Free Trial Period</label>
        <select id="f-trial">
          <option value="">No trial</option>
          <option value="7">7 days</option>
          <option value="14">14 days</option>
          <option value="30">30 days</option>
          <option value="60">60 days</option>
          <option value="90">90 days</option>
        </select>
      </div>
      <div class="sa-ff"><label>Valid From <span style="color:#C62828">*</span></label><input id="f-from" type="date"/></div>
      <div class="sa-ff"><label>End Date <span style="color:#aaa">optional</span></label><input id="f-end" type="date"/></div>
    </div>

    <!-- Volume Tiers (per_car_monthly only) -->
    <div id="f-tiers-wrap" style="margin-bottom:14px">
      <div style="font-size:12px;color:#555;font-weight:600;margin-bottom:6px">
        &#128200; Volume Discount Tiers <span style="font-weight:400;color:#aaa">(optional — bigger fleet = cheaper rate)</span>
        <button type="button" class="sa-btn sa-btn-n" style="font-size:11px;margin-left:8px" onclick="addTierRow('f-tiers-body')">&#43; Add Tier</button>
      </div>
      <table class="tier-tbl" id="f-tiers-table" style="display:none">
        <thead><tr><th>Min Cars</th><th>Max Cars (0 = unlimited)</th><th>Price / Car / Month</th><th></th></tr></thead>
        <tbody id="f-tiers-body"></tbody>
      </table>
      <div style="font-size:11px;color:#aaa;margin-top:4px">e.g. 1–5 cars: $15/car &bull; 6–20 cars: $12/car &bull; 21+ cars: $10/car</div>
    </div>

    <div class="sa-ff" style="margin-bottom:12px"><label>Description (shown to operators)</label><textarea id="f-desc" rows="2" placeholder="Brief description of what's included…"></textarea></div>

    <!-- Modules + Join visibility -->
    <div style="display:flex;align-items:flex-start;gap:28px;flex-wrap:wrap;margin-bottom:14px">
      <div>
        <div style="font-size:12px;color:#757575;font-weight:500;margin-bottom:6px">Included Modules</div>
        <label style="display:inline-flex;align-items:center;gap:6px;margin-right:16px;font-size:13px;cursor:pointer"><input type="checkbox" id="f-m-taxi" checked/> Taxi / Rides</label>
        <label style="display:inline-flex;align-items:center;gap:6px;margin-right:16px;font-size:13px;cursor:pointer"><input type="checkbox" id="f-m-food"/> Food Delivery</label>
        <label style="display:inline-flex;align-items:center;gap:6px;font-size:13px;cursor:pointer"><input type="checkbox" id="f-m-freight"/> Freight</label>
      </div>
      <div>
        <div style="font-size:12px;color:#757575;font-weight:500;margin-bottom:6px">Join Page Visibility</div>
        <label style="display:inline-flex;align-items:center;gap:6px;font-size:13px;cursor:pointer">
          <input type="checkbox" id="f-showjoin" checked/>
          Show on <strong>/join</strong> registration page
        </label>
      </div>
    </div>

    <div style="display:flex;gap:8px;align-items:center">
      <button class="sa-btn sa-btn-p" onclick="savePackage()">&#128190; Save Package</button>
      <button class="sa-btn sa-btn-n" onclick="toggleAddForm()">Cancel</button>
      <span id="add-msg" style="font-size:12.5px;color:#888"></span>
    </div>
  </div>

  <div id="pkg-cards" class="pkg-cards">
    <div style="text-align:center;color:#aaa;padding:30px;grid-column:1/-1">Loading packages&hellip;</div>
  </div>
</div>

<!-- ════ COMPANY PRICING OVERRIDES ════ -->
<div class="sa-card">
  <div class="sa-bar" style="background:#2E7D32">
    <h3>&#128188; Company Pricing &amp; Fleet</h3>
    <div style="font-size:12px;opacity:.8">Set a custom rate or fleet size per company — overrides the package default.</div>
  </div>
  <div style="padding:10px 18px;background:#F1F8E9;border-bottom:1px solid #DCEDC8;font-size:12.5px;color:#33691E">
    <strong>How it works:</strong> Each company is assigned a package tier. You can override the per-car rate individually
    — great for big-fleet discounts or negotiated deals. Set contracted fleet size to lock billing regardless of daily driver count.
  </div>
  <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead>
        <tr>
          <th>Company</th><th>Package</th><th>Fleet <small style="font-weight:400;color:#90A4AE">(contracted)</small></th>
          <th>Rate / Car</th><th>Monthly Estimate</th><th>Notes</th><th>Actions</th>
        </tr>
      </thead>
      <tbody id="co-pricing-tbody">
        <tr><td colspan="7" style="text-align:center;padding:30px;color:#aaa">Loading&hellip;</td></tr>
      </tbody>
    </table>
  </div>
  <div id="co-pricing-empty" style="display:none;text-align:center;padding:30px;color:#aaa;font-style:italic">No companies found.</div>
</div>

<!-- Summary -->
<div id="billing-summary" class="sa-card" style="display:none;padding:16px 18px;background:#F0F7FF;border-left:4px solid #1565C0">
  <div style="font-size:13px;font-weight:600;color:#1565C0;margin-bottom:6px">&#128200; Monthly Billing Summary</div>
  <div style="display:flex;gap:24px;flex-wrap:wrap;font-size:13px">
    <div><span style="color:#888">Active Companies:</span> <strong id="sum-cos">—</strong></div>
    <div><span style="color:#888">Total Contracted Cars:</span> <strong id="sum-cars">—</strong></div>
    <div><span style="color:#888">Total Monthly Revenue:</span> <strong id="sum-rev" style="color:#1565C0">—</strong></div>
    <div><span style="color:#888">Custom-priced Companies:</span> <strong id="sum-custom" style="color:#E65100">—</strong></div>
  </div>
</div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var PKG_PATH = 'superPackages';
var BILLING_PATH = 'companyBilling';
var allPackages = {};
var allCompanies = {};
var allBilling = {};
var allCompanySettings = {};

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function showNotice(msg,type){
  var el=document.getElementById('sa-notice');
  el.className='sa-notice '+type; el.textContent=msg; el.style.display='block';
  setTimeout(function(){ el.style.display='none'; },5000);
}
function toggleAddForm(){
  document.getElementById('add-form').classList.toggle('open');
  document.getElementById('add-msg').textContent='';
}

// ── Billing type helpers ──────────────────────────────────────────
function toggleBillingFields(prefix){
  var bt=document.getElementById(prefix+'-btype').value;
  var isPerCar = bt==='per_car_monthly';
  var isFlat = !isPerCar;
  document.getElementById(prefix+'-ppc-wrap').style.display = isPerCar ? '' : 'none';
  document.getElementById(prefix+'-flat-wrap').style.display = isFlat ? '' : 'none';
  var minWrap = document.getElementById(prefix+'-min-wrap');
  if(minWrap) minWrap.style.display = isPerCar ? '' : 'none';
  var tiersWrap = document.getElementById(prefix+'-tiers-wrap');
  if(tiersWrap) tiersWrap.style.display = isPerCar ? '' : 'none';
}

function billingTypeLabel(bt){
  if(bt==='flat_monthly') return '<span class="billing-type-badge bt-flat-monthly">Flat Monthly</span>';
  if(bt==='flat_annual')  return '<span class="billing-type-badge bt-flat-annual">Flat Annual</span>';
  return '<span class="billing-type-badge bt-per-car">Per Taxi / Month</span>';
}

function priceDisplay(p){
  var bt = p.billingType || 'per_car_monthly';
  if(bt==='flat_annual')  return { main: '$'+(+(p.flatPrice||0)).toFixed(2), sub: '/year (flat)' };
  if(bt==='flat_monthly') return { main: '$'+(+(p.flatPrice||0)).toFixed(2), sub: '/month (flat)' };
  // per_car_monthly — show base rate; tiers shown separately
  return { main: '$'+(+(p.pricePerCar||p.monthlyPrice||0)).toFixed(2), sub: '/taxi/month' };
}

function modTag(key,on){
  var labels={taxi:'&#128663; Taxi',food:'&#127829; Food',freight:'&#128230; Freight'};
  var cls={taxi:'mod-taxi',food:'mod-food',freight:'mod-freight'};
  return '<span class="mod-tag '+(on?cls[key]:'mod-off')+'">'+labels[key]+'</span>';
}

// ── Volume Tier rows ─────────────────────────────────────────────
var tierCounter=0;
function addTierRow(tbodyId){
  var tbody=document.getElementById(tbodyId);
  var table=tbody.parentElement;
  table.style.display='';
  var rid='tier-'+(++tierCounter);
  var tr=document.createElement('tr');
  tr.id=rid;
  tr.innerHTML='<td><input type="number" min="1" step="1" placeholder="1" style="width:70px"/></td>'
    +'<td><input type="number" min="0" step="1" placeholder="0" style="width:70px"/></td>'
    +'<td><input type="number" min="0" step="0.50" placeholder="0.00" style="width:80px"/></td>'
    +'<td><button type="button" class="sa-btn sa-btn-d" style="font-size:10px;padding:3px 7px" onclick="removeTierRow(\''+rid+'\',\''+tbodyId+'\')">&#10005;</button></td>';
  tbody.appendChild(tr);
}
function removeTierRow(rid,tbodyId){
  var tr=document.getElementById(rid);
  if(tr) tr.parentNode.removeChild(tr);
  var tbody=document.getElementById(tbodyId);
  if(!tbody.rows.length) tbody.parentElement.style.display='none';
}
function getTiersFromBody(tbodyId){
  var tbody=document.getElementById(tbodyId);
  if(!tbody) return null;
  var rows=Array.from(tbody.rows);
  if(!rows.length) return null;
  var tiers=rows.map(function(tr){
    var inputs=tr.querySelectorAll('input');
    return { min:+(inputs[0].value||1), max:+(inputs[1].value||0), price:+(inputs[2].value||0) };
  });
  return tiers.length ? tiers : null;
}
function renderTierRows(tbodyId, tiers){
  if(!tiers||!tiers.length) return;
  var tbody=document.getElementById(tbodyId);
  var table=tbody.parentElement;
  table.style.display='';
  tiers.forEach(function(t){
    var rid='tier-'+(++tierCounter);
    var tr=document.createElement('tr');
    tr.id=rid;
    tr.innerHTML='<td><input type="number" min="1" step="1" value="'+esc(String(t.min||1))+'" style="width:70px"/></td>'
      +'<td><input type="number" min="0" step="1" value="'+esc(String(t.max||0))+'" style="width:70px"/></td>'
      +'<td><input type="number" min="0" step="0.50" value="'+esc(String(t.price||0))+'" style="width:80px"/></td>'
      +'<td><button type="button" class="sa-btn sa-btn-d" style="font-size:10px;padding:3px 7px" onclick="removeTierRow(\''+rid+'\',\''+tbodyId+'\')">&#10005;</button></td>';
    tbody.appendChild(tr);
  });
}
function tierSummaryHtml(tiers){
  if(!tiers||!tiers.length) return '';
  var rows=tiers.map(function(t){
    var range = t.max===0 ? t.min+'+ cars' : t.min+'\u2013'+t.max+' cars';
    return '<span style="font-size:11px;background:#E3F2FD;color:#1565C0;border-radius:4px;padding:2px 7px;border:1px solid #BBDEFB;white-space:nowrap">'
      +range+' = $'+parseFloat(t.price).toFixed(2)+'/car</span>';
  });
  return '<div style="display:flex;gap:5px;flex-wrap:wrap;margin-top:5px">'+rows.join('')+'</div>';
}

// ── Render Package Cards ─────────────────────────────────────────
function renderPackages(data){
  var el=document.getElementById('pkg-cards');
  if(!data||!Object.keys(data).length){
    el.innerHTML='<div style="text-align:center;color:#aaa;padding:30px;grid-column:1/-1">No packages yet. Click "+ New Package" to create your first tier.</div>';
    return;
  }
  var html='';
  Object.keys(data).sort(function(a,b){ return (data[a].sortOrder||99)-(data[b].sortOrder||99); }).forEach(function(id){
    var p=data[id];
    var active=p.active!==false;
    var showJoin=p.showOnJoin!==false; // default true
    var bt=p.billingType||'per_car_monthly';
    var pd=priceDisplay(p);
    var tiers=Array.isArray(p.volumeTiers)?p.volumeTiers:(p.volumeTiers?Object.values(p.volumeTiers):null);
    var headCls='pkg-head'+(bt==='flat_annual'?' flat-annual':bt==='flat_monthly'?' flat-monthly':'');
    var ebodyId='etiers-'+id;

    html+='<div class="pkg-card'+(active?'':' inactive')+(showJoin?' join-visible':'')+'" id="pkg-'+id+'">'
      +'<span class="'+(active?'badge-active':'badge-inactive')+'">'+(active?'Active':'Inactive')+'</span>'
      +'<div class="'+headCls+'">'
        +'<h3>'+esc(p.name||id)+'</h3>'
        +'<div class="pkg-price-main">'+pd.main+'<span> '+esc(pd.sub)+'</span></div>'
        +(p.minimumMonthly ? '<div class="pkg-price-sub">Min. $'+parseFloat(p.minimumMonthly).toFixed(0)+'/month</div>' : '')
      +'</div>'
      +'<div class="pkg-body">'
        +billingTypeLabel(bt)
        +(showJoin ? '<span class="badge-join" style="margin-left:4px">&#127758; Visible on join page</span>' : '<span style="font-size:10px;color:#aaa;margin-left:4px">Hidden from join page</span>')
        +'<div style="margin:6px 0">'
        +'<div class="pkg-desc">'+esc(p.description||'')+'</div>'
        +(tiers&&tiers.length ? tierSummaryHtml(tiers) : '')
        +'</div>'
        +'<div class="pkg-mods">'
          +modTag('taxi',p.modules&&p.modules.taxi)
          +modTag('food',p.modules&&p.modules.food)
          +modTag('freight',p.modules&&p.modules.freight)
          +(p.trialDays ? '<span class="mod-tag" style="background:#FFF3E0;color:#E65100">&#9201; '+p.trialDays+'-day trial</span>' : '')
        +'</div>'
        +(p.dateFrom ? '<div style="font-size:11.5px;color:#555;margin-bottom:8px"><strong>From:</strong> '+esc(p.dateFrom)+(p.dateEnd?' &rarr; '+esc(p.dateEnd):'')+'</div>' : '')
        +'<div class="pkg-actions">'
          +'<button class="sa-btn sa-btn-n" style="font-size:11px" onclick="togglePkgEdit(\''+id+'\')">&#9998; Edit</button>'
          +'<button class="sa-btn '+(active?'sa-btn-d':'sa-btn-s')+'" style="font-size:11px" onclick="togglePkgActive(\''+id+'\','+(active?'false':'true')+')">'+(active?'Deactivate':'Activate')+'</button>'
          +'<button class="sa-btn sa-btn-d" style="font-size:11px" onclick="deletePackage(\''+id+'\')" title="Delete package">&#128465;</button>'
        +'</div>'

        // Edit panel
        +'<div class="edit-panel" id="edit-'+id+'">'
          +'<div class="edit-grid">'
            +'<div class="sa-ff"><label>Name</label><input id="e-name-'+id+'" value="'+esc(p.name||'')+'"/></div>'
            +'<div class="sa-ff"><label>Billing Type</label>'
              +'<select id="e-btype-'+id+'" onchange="toggleEditBillingFields(\''+id+'\')">'
                +'<option value="per_car_monthly"'+(bt==='per_car_monthly'?' selected':'')+'>Per taxi / month</option>'
                +'<option value="flat_monthly"'+(bt==='flat_monthly'?' selected':'')+'>Flat monthly fee</option>'
                +'<option value="flat_annual"'+(bt==='flat_annual'?' selected':'')+'>Flat annual fee</option>'
              +'</select>'
            +'</div>'
            +'<div class="sa-ff" id="e-ppc-wrap-'+id+'" style="'+(bt!=='per_car_monthly'?'display:none':'')+'">'
              +'<label>Price / Taxi / Month ($)</label><input id="e-ppc-'+id+'" type="number" step="0.50" value="'+(+(p.pricePerCar||p.monthlyPrice||0))+'"/>'
            +'</div>'
            +'<div class="sa-ff" id="e-flat-wrap-'+id+'" style="'+(bt==='per_car_monthly'?'display:none':'')+'">'
              +'<label>Flat Price ($)</label><input id="e-flat-'+id+'" type="number" step="1" value="'+(+(p.flatPrice||0))+'"/>'
            +'</div>'
            +'<div class="sa-ff" id="e-min-wrap-'+id+'" style="'+(bt!=='per_car_monthly'?'display:none':'')+'">'
              +'<label>Min. Monthly ($)</label><input id="e-min-'+id+'" type="number" value="'+(p.minimumMonthly||'')+'"/>'
            +'</div>'
            +'<div class="sa-ff"><label>Free Trial</label>'
              +'<select id="e-trial-'+id+'">'
                +'<option value="">No trial</option>'
                +[7,14,30,60,90].map(function(d){return '<option value="'+d+'"'+(p.trialDays==d?' selected':'')+'>'+d+' days</option>';}).join('')
              +'</select>'
            +'</div>'
            +'<div class="sa-ff"><label>Valid From</label><input id="e-from-'+id+'" type="date" value="'+(p.dateFrom||'')+'"/></div>'
            +'<div class="sa-ff"><label>End Date</label><input id="e-end-'+id+'" type="date" value="'+(p.dateEnd||'')+'"/></div>'
          +'</div>'

          // Volume tiers (per_car only)
          +'<div id="e-tiers-wrap-'+id+'" style="margin-bottom:10px;'+(bt!=='per_car_monthly'?'display:none':'')+'">'
            +'<div style="font-size:12px;color:#555;font-weight:600;margin-bottom:5px">'
              +'&#128200; Volume Discount Tiers'
              +' <button type="button" class="sa-btn sa-btn-n" style="font-size:11px;margin-left:6px" onclick="addTierRow(\''+ebodyId+'\')">&#43; Add Tier</button>'
            +'</div>'
            +'<table class="tier-tbl" id="etiers-tbl-'+id+'" style="'+(tiers&&tiers.length?'':'display:none')+'">'
              +'<thead><tr><th>Min Cars</th><th>Max Cars (0=unlimited)</th><th>Price/Car/Month</th><th></th></tr></thead>'
              +'<tbody id="'+ebodyId+'"></tbody>'
            +'</table>'
          +'</div>'

          +'<div class="sa-ff" style="margin-bottom:10px"><label>Description</label><textarea id="e-desc-'+id+'" rows="2">'+esc(p.description||'')+'</textarea></div>'
          +'<div style="margin-bottom:10px;display:flex;gap:24px;flex-wrap:wrap">'
            +'<div><div style="font-size:12px;color:#757575;font-weight:500;margin-bottom:5px">Modules</div>'
              +'<label style="display:inline-flex;align-items:center;gap:5px;margin-right:10px;font-size:12px"><input type="checkbox" id="e-taxi-'+id+'" '+(p.modules&&p.modules.taxi?'checked':'')+'/> Taxi</label>'
              +'<label style="display:inline-flex;align-items:center;gap:5px;margin-right:10px;font-size:12px"><input type="checkbox" id="e-food-'+id+'" '+(p.modules&&p.modules.food?'checked':'')+'/> Food</label>'
              +'<label style="display:inline-flex;align-items:center;gap:5px;font-size:12px"><input type="checkbox" id="e-freight-'+id+'" '+(p.modules&&p.modules.freight?'checked':'')+'/> Freight</label>'
            +'</div>'
            +'<div><div style="font-size:12px;color:#757575;font-weight:500;margin-bottom:5px">Join Page</div>'
              +'<label style="display:inline-flex;align-items:center;gap:5px;font-size:12px"><input type="checkbox" id="e-showjoin-'+id+'" '+(showJoin?'checked':'')+'/> Show on /join page</label>'
            +'</div>'
          +'</div>'
          +'<div style="display:flex;gap:6px">'
            +'<button class="sa-btn sa-btn-p" style="font-size:11px" onclick="savePkgEdit(\''+id+'\')">&#128190; Save</button>'
            +'<button class="sa-btn sa-btn-n" style="font-size:11px" onclick="togglePkgEdit(\''+id+'\')">Cancel</button>'
          +'</div>'
        +'</div>'
      +'</div>'
    +'</div>';
  });
  el.innerHTML=html;

  // Populate edit tier tables from existing data
  Object.keys(data).forEach(function(id){
    var p=data[id];
    var tiers=Array.isArray(p.volumeTiers)?p.volumeTiers:(p.volumeTiers?Object.values(p.volumeTiers):null);
    if(tiers&&tiers.length) renderTierRows('etiers-'+id, tiers);
  });
}

function togglePkgEdit(id){
  document.getElementById('edit-'+id).classList.toggle('open');
}
function toggleEditBillingFields(id){
  var bt=document.getElementById('e-btype-'+id).value;
  var isPerCar=bt==='per_car_monthly';
  document.getElementById('e-ppc-wrap-'+id).style.display=isPerCar?'':'none';
  document.getElementById('e-flat-wrap-'+id).style.display=isPerCar?'none':'';
  var mw=document.getElementById('e-min-wrap-'+id); if(mw) mw.style.display=isPerCar?'':'none';
  var tw=document.getElementById('e-tiers-wrap-'+id); if(tw) tw.style.display=isPerCar?'':'none';
}
function togglePkgActive(id,val){
  var active=val==='true'||val===true;
  db.ref(PKG_PATH+'/'+id+'/active').set(active).then(function(){
    showNotice('Package '+(active?'activated':'deactivated')+'.','ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}
function deletePackage(id){
  var p=allPackages[id];
  if(!confirm('Delete package "'+(p&&p.name||id)+'"? This cannot be undone.')) return;
  db.ref(PKG_PATH+'/'+id).remove().then(function(){
    showNotice('Package deleted.','ok');
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function savePkgEdit(id){
  var bt=document.getElementById('e-btype-'+id).value;
  var isPerCar=bt==='per_car_monthly';
  var trialVal=document.getElementById('e-trial-'+id).value;
  var tiers=isPerCar ? getTiersFromBody('etiers-'+id) : null;
  var upd={
    name:document.getElementById('e-name-'+id).value.trim(),
    billingType:bt,
    pricePerCar:isPerCar ? +(document.getElementById('e-ppc-'+id).value||0) : null,
    flatPrice:!isPerCar ? +(document.getElementById('e-flat-'+id).value||0) : null,
    minimumMonthly:isPerCar ? (+(document.getElementById('e-min-'+id).value||0)||null) : null,
    volumeTiers:tiers||null,
    description:document.getElementById('e-desc-'+id).value.trim(),
    dateFrom:document.getElementById('e-from-'+id).value||null,
    dateEnd:document.getElementById('e-end-'+id).value||null,
    trialDays:trialVal ? +trialVal : null,
    showOnJoin:document.getElementById('e-showjoin-'+id).checked,
    modules:{
      taxi:document.getElementById('e-taxi-'+id).checked,
      food:document.getElementById('e-food-'+id).checked,
      freight:document.getElementById('e-freight-'+id).checked
    }
  };
  db.ref(PKG_PATH+'/'+id).update(upd).then(function(){
    showNotice('Package updated.','ok');
    togglePkgEdit(id);
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function savePackage(){
  var name=(document.getElementById('f-name').value||'').trim();
  var bt=document.getElementById('f-btype').value;
  var isPerCar=bt==='per_car_monthly';
  var dateFrom=(document.getElementById('f-from').value||'').trim();
  if(!name){ showNotice('Please enter a Package Name.','err'); return; }
  if(!dateFrom){ showNotice('Please set a Valid From date.','err'); return; }
  if(isPerCar && (document.getElementById('f-ppc').value||'')===''){
    showNotice('Please enter a Price per Taxi / Month.','err'); return;
  }
  if(!isPerCar && (document.getElementById('f-flat').value||'')===''){
    showNotice('Please enter a Flat Price.','err'); return;
  }
  var trialVal=document.getElementById('f-trial').value;
  var tiers=isPerCar ? getTiersFromBody('f-tiers-body') : null;
  var id='pkg_'+name.toLowerCase().replace(/[^a-z0-9]/g,'_')+'_'+Date.now();
  db.ref(PKG_PATH+'/'+id).set({
    name:name,
    billingType:bt,
    pricePerCar:isPerCar ? +(document.getElementById('f-ppc').value||0) : null,
    flatPrice:!isPerCar ? +(document.getElementById('f-flat').value||0) : null,
    minimumMonthly:isPerCar ? (+(document.getElementById('f-minmonth').value||0)||null) : null,
    volumeTiers:tiers||null,
    description:document.getElementById('f-desc').value.trim(),
    dateFrom:dateFrom,
    dateEnd:document.getElementById('f-end').value||null,
    trialDays:trialVal ? +trialVal : null,
    active:true,
    showOnJoin:document.getElementById('f-showjoin').checked,
    sortOrder:Date.now(),
    createdAt:new Date().toISOString(),
    modules:{
      taxi:document.getElementById('f-m-taxi').checked,
      food:document.getElementById('f-m-food').checked,
      freight:document.getElementById('f-m-freight').checked
    }
  }).then(function(){
    showNotice('Package "'+name+'" created.','ok');
    toggleAddForm();
    ['f-name','f-ppc','f-flat','f-minmonth','f-desc','f-from','f-end'].forEach(function(x){ document.getElementById(x).value=''; });
    document.getElementById('f-trial').value='';
    document.getElementById('f-m-taxi').checked=true;
    document.getElementById('f-m-food').checked=false;
    document.getElementById('f-m-freight').checked=false;
    document.getElementById('f-showjoin').checked=true;
    // clear tiers
    var tbody=document.getElementById('f-tiers-body');
    tbody.innerHTML='';
    tbody.parentElement.style.display='none';
  }).catch(function(e){ document.getElementById('add-msg').textContent='Error: '+e.message; });
}

/* ── Company Pricing Table ─────────────────────────────────────── */
function getEffectiveRate(pkgId, fleetSize){
  var pkg=allPackages[pkgId]||{};
  var bt=pkg.billingType||'per_car_monthly';
  if(bt!=='per_car_monthly') return null;
  var tiers=Array.isArray(pkg.volumeTiers)?pkg.volumeTiers:(pkg.volumeTiers?Object.values(pkg.volumeTiers):null);
  if(tiers&&tiers.length&&fleetSize>0){
    for(var i=0;i<tiers.length;i++){
      var t=tiers[i];
      if(fleetSize>=t.min&&(t.max===0||fleetSize<=t.max)) return +(t.price||0);
    }
  }
  return +(pkg.pricePerCar||pkg.monthlyPrice||0);
}
function getMonthlyFee(pkgId, fleet, override){
  var pkg=allPackages[pkgId]||{};
  var bt=pkg.billingType||'per_car_monthly';
  if(bt==='flat_annual') return +(pkg.flatPrice||0)/12;
  if(bt==='flat_monthly') return +(pkg.flatPrice||0);
  // per_car_monthly
  var rate = override!==null ? override : getEffectiveRate(pkgId,fleet);
  var monthly = fleet>0 ? rate*fleet : 0;
  var minM=+(pkg.minimumMonthly||0);
  return Math.max(monthly,minM);
}
function getPkgName(pkgId){
  return pkgId ? (allPackages[pkgId]&&allPackages[pkgId].name||pkgId) : '—';
}

function resolveCompanyPackage(cid, co){
  var cs=allCompanySettings[cid]||{};
  var csBilling=cs.billing||{};
  var b=allBilling[cid]||{};
  var planName=typeof cs.plan==='string'?cs.plan:(cs.plan&&cs.plan.name)||'';
  var pkgId=csBilling.packageId||b.packageId||co.packageId||'';
  if(!pkgId&&planName){
    Object.keys(allPackages).forEach(function(pid){
      if(allPackages[pid].name===planName) pkgId=pid;
    });
  }
  return { pkgId:pkgId, planName:planName, csBilling:csBilling };
}

function companyHasAssignedPackage(resolved){
  return !!(resolved.pkgId||resolved.planName);
}

function renderCompanyPricing(){
  var tbody=document.getElementById('co-pricing-tbody');
  var companyIdSet={};
  Object.keys(allCompanies).forEach(function(cid){ companyIdSet[cid]=true; });
  Object.keys(allCompanySettings).forEach(function(cid){
    var co=allCompanies[cid]||{};
    if(companyHasAssignedPackage(resolveCompanyPackage(cid, co))) companyIdSet[cid]=true;
  });
  var companies=Object.keys(companyIdSet).map(function(cid){
    return [cid, allCompanies[cid]||{ name: cid }];
  }).sort(function(a,b){
    return (a[1].name||a[0]).localeCompare(b[1].name||b[0]);
  });
  if(!companies.length){
    tbody.innerHTML='';
    document.getElementById('co-pricing-empty').style.display='block';
    return;
  }
  var totalCars=0, totalRev=0, customCount=0, activeCount=0;
  var rows=companies.map(function(entry){
    var cid=entry[0], co=entry[1];
    var resolved=resolveCompanyPackage(cid, co);
    var pkgId=resolved.pkgId;
    var b=allBilling[cid]||{};
    var csBilling=resolved.csBilling;
    var fleet=+(b.contractedFleet||co.fleetSize||0);
    var override=b.pricePerCarOverride!==undefined&&b.pricePerCarOverride!==null&&b.pricePerCarOverride!==''?+b.pricePerCarOverride:null;
    var monthly=getMonthlyFee(pkgId,fleet,override);
    if(monthly<=0&&csBilling.monthlyRate){
      monthly=fleet>0?+(csBilling.monthlyRate)*fleet:+(csBilling.monthlyRate);
    }
    var hasOverride=override!==null;
    var notes=b.notes||co.notes||'';
    var hasPackage=companyHasAssignedPackage(resolved);
    if(hasPackage){
      activeCount++;
      totalRev+=monthly;
      if(fleet>0) totalCars+=fleet;
    }
    if(hasOverride) customCount++;
    var pkg=allPackages[pkgId]||{};
    var bt=pkg.billingType||'per_car_monthly';
    var rateStr=override!==null?'$'+override.toFixed(2):'$'+(getEffectiveRate(pkgId,fleet)||0).toFixed(2);
    var rateDisplay=bt!=='per_car_monthly'?'<span style="color:#aaa;font-size:11px">Flat</span>'
      :(hasOverride
        ?'<span class="badge-custom">Custom '+rateStr+'/car</span>'
        :(rateStr>0?'<span class="badge-default">'+rateStr+'/car</span>':'<span style="color:#aaa">—</span>'));
    var estDisplay=monthly>0?'<span class="est-pill'+(hasOverride?' custom':'')+'">$'+monthly.toFixed(2)+'/mo</span>':'<span style="color:#aaa">—</span>';
    var pkgOpts='<option value="">— No package —</option>';
    Object.keys(allPackages).sort(function(a,b){ return (allPackages[a].sortOrder||99)-(allPackages[b].sortOrder||99); }).forEach(function(pid){
      var pp=allPackages[pid];
      var label=pp.name+(pp.billingType==='flat_annual'?' ('+pp.flatPrice+'/yr)':pp.billingType==='flat_monthly'?' ('+pp.flatPrice+'/mo)':' ($'+(+(pp.pricePerCar||0)).toFixed(2)+'/car)');
      pkgOpts+='<option value="'+esc(pid)+'"'+(pid===pkgId?' selected':'')+'>'+esc(label)+'</option>';
    });
    return '<tr id="corow-'+esc(cid)+'">'
      +'<td><div style="font-weight:600;color:#1565C0">'+esc(co.name||cid)+'</div><div style="font-size:10.5px;font-family:monospace;color:#aaa">'+esc(cid)+'</div></td>'
      +'<td style="font-size:12px">'+esc(getPkgName(pkgId))+'</td>'
      +'<td><span style="font-weight:700;font-size:14px;color:#333">'+esc(String(fleet||'—'))+'</span>'+
        (fleet>0?' <span style="font-size:11px;color:#aaa">vehicles</span>':'')+'</td>'
      +'<td>'+rateDisplay+'</td><td>'+estDisplay+'</td>'
      +'<td style="font-size:12px;color:#777;max-width:160px">'+esc(notes)+'</td>'
      +'<td><button class="sa-btn sa-btn-n" style="font-size:11px" onclick="toggleCoEdit(\''+esc(cid)+'\')">&#9998; Edit</button></td>'
      +'</tr>'
      +'<tr id="corow-edit-'+esc(cid)+'" class="inline-edit-row">'
        +'<td colspan="7"><div style="font-size:12px;font-weight:600;color:#1565C0;margin-bottom:8px">&#9998; '+esc(co.name||cid)+'</div>'
          +'<div class="ie-grid">'
            +'<div class="sa-ff"><label>Package Tier</label><select id="ie-pkg-'+esc(cid)+'">'+pkgOpts+'</select></div>'
            +'<div class="sa-ff"><label>Contracted Fleet Size</label><input id="ie-fleet-'+esc(cid)+'" type="number" min="0" step="1" value="'+esc(String(fleet||''))+'" placeholder="e.g. 12"/></div>'
            +'<div class="sa-ff"><label>Custom Rate / Car <small style="color:#aaa">(blank = use package + volume tiers)</small></label><input id="ie-rate-'+esc(cid)+'" type="number" min="0" step="0.50" value="'+esc(override!==null?String(override):'')+'" placeholder="Blank for package default"/></div>'
            +'<div class="sa-ff"><label>Notes</label><input id="ie-notes-'+esc(cid)+'" value="'+esc(notes)+'" placeholder="e.g. Negotiated deal"/></div>'
          +'</div>'
          +'<div style="display:flex;gap:6px;align-items:center">'
            +'<button class="sa-btn sa-btn-p" style="font-size:11px" onclick="saveCoEdit(\''+esc(cid)+'\')">Save</button>'
            +'<button class="sa-btn sa-btn-d" style="font-size:11px" onclick="clearCoOverride(\''+esc(cid)+'\')">Clear Override</button>'
            +'<button class="sa-btn sa-btn-n" style="font-size:11px" onclick="toggleCoEdit(\''+esc(cid)+'\')">Cancel</button>'
            +'<span id="ie-msg-'+esc(cid)+'" style="font-size:12px;color:#888"></span>'
          +'</div>'
          +'<div style="font-size:11.5px;color:#90A4AE;margin-top:6px">&#9432; Volume tiers from the assigned package apply automatically based on fleet size.</div>'
        +'</td>'
      +'</tr>';
  }).join('');
  tbody.innerHTML=rows;
  document.getElementById('billing-summary').style.display='block';
  document.getElementById('sum-cos').textContent=activeCount;
  document.getElementById('sum-cars').textContent=totalCars;
  document.getElementById('sum-rev').textContent='$'+totalRev.toFixed(2);
  document.getElementById('sum-custom').textContent=customCount;
}

function toggleCoEdit(cid){
  document.getElementById('corow-edit-'+cid).classList.toggle('open');
}
function saveCoEdit(cid){
  var pkgId=document.getElementById('ie-pkg-'+cid).value;
  var fleetVal=document.getElementById('ie-fleet-'+cid).value.trim();
  var rateVal=document.getElementById('ie-rate-'+cid).value.trim();
  var notes=document.getElementById('ie-notes-'+cid).value.trim();
  var msg=document.getElementById('ie-msg-'+cid);
  var pkg=pkgId&&allPackages[pkgId]?allPackages[pkgId]:null;
  var pkgName=pkg?pkg.name:'';
  var fleet=fleetVal!==''?+fleetVal:0;
  var override=rateVal!==''?+rateVal:null;
  var monthlyRate=override!==null?override:getEffectiveRate(pkgId,fleet);
  var monthlyFee=getMonthlyFee(pkgId,fleet,override);
  msg.textContent='Saving\u2026';
  updateCompanyPlan(cid,{
    packageId:pkgId||null,
    packageName:pkgName,
    packageMeta:pkg,
    monthlyRate:monthlyRate,
    monthlyFee:monthlyFee||null,
    contractedFleet:fleet,
    pricePerCarOverride:override,
    notes:notes||null,
    clearTrial:!!(pkg&&!pkg.trialDays&&pkgId!=='pkg_trial')
  }).then(function(){
    var patch={ packageId:pkgId||null, contractedFleet:fleet, pricePerCarOverride:override, notes:notes||null, updatedAt:new Date().toISOString() };
    allBilling[cid]=Object.assign(allBilling[cid]||{},patch);
    toggleCoEdit(cid); renderCompanyPricing();
    showNotice('Pricing updated for '+((allCompanies[cid]&&allCompanies[cid].name)||cid)+'.','ok');
  }).catch(function(e){ msg.style.color='#C62828'; msg.textContent='Error: '+e.message; });
}
function clearCoOverride(cid){
  var msg=document.getElementById('ie-msg-'+cid);
  msg.textContent='Clearing\u2026';
  var co=allCompanies[cid]||{};
  var b=allBilling[cid]||{};
  var resolved=resolveCompanyPackage(cid,co);
  var pkgId=resolved.pkgId||document.getElementById('ie-pkg-'+cid).value;
  var pkg=pkgId&&allPackages[pkgId]?allPackages[pkgId]:null;
  var fleet=+(b.contractedFleet||co.fleetSize||0);
  var monthlyRate=getEffectiveRate(pkgId,fleet);
  var monthlyFee=getMonthlyFee(pkgId,fleet,null);
  updateCompanyPlan(cid,{
    packageId:pkgId||null,
    packageName:getPkgName(pkgId),
    packageMeta:pkg,
    monthlyRate:monthlyRate,
    monthlyFee:monthlyFee||null,
    contractedFleet:fleet,
    pricePerCarOverride:null,
    clearTrial:!!(pkg&&!pkg.trialDays&&pkgId!=='pkg_trial')
  }).then(function(){
    if(allBilling[cid]) allBilling[cid].pricePerCarOverride=null;
    toggleCoEdit(cid); renderCompanyPricing();
    showNotice('Custom rate removed — package volume tiers now apply.','ok');
  }).catch(function(e){ msg.style.color='#C62828'; msg.textContent='Error: '+e.message; });
}

/* ── Seed defaults if empty ──────────────────────────────────────── */
function seedDefaults(){
  _fbGet(PKG_PATH).then(function(data){
    if(data) return;
    var defaults=[
      {id:'pkg_trial',name:'Free Trial',billingType:'per_car_monthly',pricePerCar:0,minimumMonthly:null,description:'30-day free trial. All modules included. No charge until trial ends.',sortOrder:0,active:true,showOnJoin:true,trialDays:30,dateFrom:new Date().toISOString().slice(0,10),createdAt:new Date().toISOString(),modules:{taxi:true,food:true,freight:true}},
      {id:'pkg_basic',name:'Basic',billingType:'per_car_monthly',pricePerCar:10,minimumMonthly:50,description:'Taxi dispatch only. Perfect for small fleets just getting started.',sortOrder:1,active:true,showOnJoin:true,dateFrom:new Date().toISOString().slice(0,10),createdAt:new Date().toISOString(),modules:{taxi:true,food:false,freight:false}},
      {id:'pkg_standard',name:'Standard',billingType:'per_car_monthly',pricePerCar:15,minimumMonthly:99,description:'Taxi + Food Delivery. Grow your revenue with restaurant orders.',sortOrder:2,active:true,showOnJoin:true,dateFrom:new Date().toISOString().slice(0,10),createdAt:new Date().toISOString(),volumeTiers:[{min:1,max:5,price:15},{min:6,max:20,price:12},{min:21,max:0,price:10}],modules:{taxi:true,food:true,freight:false}},
      {id:'pkg_pro',name:'Pro — All Modules',billingType:'per_car_monthly',pricePerCar:20,minimumMonthly:149,description:'All modules: Taxi, Food Delivery & Freight. Best value for large fleets.',sortOrder:3,active:true,showOnJoin:true,dateFrom:new Date().toISOString().slice(0,10),createdAt:new Date().toISOString(),volumeTiers:[{min:1,max:5,price:20},{min:6,max:20,price:16},{min:21,max:0,price:13}],modules:{taxi:true,food:true,freight:true}},
      {id:'pkg_annual',name:'Annual Plan',billingType:'flat_annual',flatPrice:500,description:'One flat yearly fee. Includes all modules. Great for predictable budgeting.',sortOrder:4,active:true,showOnJoin:true,dateFrom:new Date().toISOString().slice(0,10),createdAt:new Date().toISOString(),modules:{taxi:true,food:true,freight:true}}
    ];
    var batch={};
    defaults.forEach(function(d){ var id=d.id; delete d.id; batch[id]=d; });
    return db.ref(PKG_PATH).set(batch);
  });
}

/* ── Load ────────────────────────────────────────────────────────── */
window._fbOnLogin = function(){
  seedDefaults();
  Promise.all([
    _fbGet(PKG_PATH),
    _fbGet('superClients'),
    _fbGet(BILLING_PATH),
    _fbGet('companySettings')
  ]).then(function(results){
    allPackages=results[0]||{};
    allCompanies=results[1]||{};
    allBilling=results[2]||{};
    allCompanySettings=results[3]||{};
    renderPackages(allPackages);
    renderCompanyPricing();
  });
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
