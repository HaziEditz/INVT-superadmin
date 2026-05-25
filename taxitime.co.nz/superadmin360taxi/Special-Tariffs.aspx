<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Special Tariffs &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png" />
<script src="assets/js/jquery.min.js" type="text/javascript"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet" />
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet" />
<link href="assets/css/main.min.css" rel="stylesheet" />
<link href="assets/css/Toast.css" rel="stylesheet" />
<link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
<link href="toast/toastr.min.css" rel="stylesheet" />
<script src="toast/toastr.min.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
var config = {
  apiKey: "AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",
  authDomain: "taxilatest.firebaseapp.com",
  databaseURL: "https://taxilatest.firebaseio.com",
  projectId: "taxilatest",
  storageBucket: "taxilatest.appspot.com"
};
firebase.initializeApp(config);
</script>
<style>
.sp-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,.1);
  padding: 20px 22px;
  margin-bottom: 20px;
}
.sp-toggle-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.sp-toggle {
  position: relative;
  display: inline-block;
  width: 52px;
  height: 28px;
}
.sp-toggle input { opacity: 0; width: 0; height: 0; }
.sp-slider {
  position: absolute;
  inset: 0;
  background: #ccc;
  border-radius: 28px;
  transition: .3s;
  cursor: pointer;
}
.sp-slider:before {
  position: absolute;
  content: "";
  height: 20px;
  width: 20px;
  left: 4px;
  bottom: 4px;
  background: #fff;
  border-radius: 50%;
  transition: .3s;
}
.sp-toggle input:checked + .sp-slider { background: #43A047; }
.sp-toggle input:checked + .sp-slider:before { transform: translateX(24px); }
.sp-rate-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 10px;
}
.sp-rate-table th {
  font-size: 11px;
  font-weight: 700;
  color: #757575;
  text-transform: uppercase;
  padding: 8px 10px;
  background: #F5F5F5;
  text-align: left;
}
.sp-rate-table td {
  padding: 7px 10px;
  border-bottom: 1px solid #f0f0f0;
  vertical-align: middle;
}
.sp-rate-table input[type=number] {
  width: 90px;
  padding: 5px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 13px;
}
.sp-add-row {
  display: flex;
  gap: 10px;
  align-items: flex-end;
  margin-top: 12px;
  padding: 12px;
  background: #F5F5F5;
  border-radius: 6px;
}
.sp-add-row .sp-field { flex: 1; }
.sp-add-row .sp-field label {
  display: block;
  font-size: 11px;
  font-weight: 700;
  color: #616161;
  text-transform: uppercase;
  letter-spacing: .5px;
  margin-bottom: 5px;
}
.sp-add-row .sp-field input {
  width: 100%;
  padding: 7px 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 13px;
  box-sizing: border-box;
}
.sp-price-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}
.sp-price-row label {
  font-size: 13px;
  font-weight: 600;
  color: #424242;
  min-width: 140px;
}
.sp-price-input {
  display: flex;
  align-items: center;
  gap: 6px;
}
.sp-price-input input {
  width: 100px;
  padding: 7px 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 600;
}
.sp-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 7px 14px;
  border-radius: 4px;
  border: 1px solid #ddd;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  background: #fff;
}
.sp-btn-primary { background: #1976D2; color: #fff; border-color: #1976D2; }
.sp-btn-primary:hover { background: #1565C0; }
.sp-btn-danger { background: #FFEBEE; color: #C62828; border-color: #FFCDD2; }
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main">
  <div class="header_main_content">
    <nav class="uk-navbar">
      <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
      <div class="col-md-offset-2 col-md-4">
        <label style="color:#fff">Special Tariffs &mdash; BookaWaka Admin</label>
      </div>
      <div class="uk-navbar-flip">
        <ul class="uk-navbar-nav user_actions">
          <li data-uk-dropdown="{mode:'click',pos:'bottom-right'}">
            <a href="#" class="user_action_image"><img class="md-user-image" src="assets/img/bw-logo.png" alt=""/></a>
            <div class="uk-dropdown uk-dropdown-small">
              <ul class="uk-nav js-uk-prevent">
                <li><a href="Home.aspx">Dashboard</a></li>
                <li><a onclick="(function(){ window.location.href='SA-Login.aspx'; })()">Logout</a></li>
              </ul>
            </div>
          </li>
        </ul>
      </div>
    </nav>
  </div>
</header>
<aside id="sidebar_main">
  <div class="sidebar_main_header">
    <div class="sidebar_logo">
      <a href="Home.aspx" class="sSidebar_hide"><img src="assets/img/bw-logo.png" alt="" style="height:100px;width:100px;border-radius:50%"/></a>
      <a href="Home.aspx" class="sSidebar_show"><img src="assets/img/bw-logo.png" alt="" style="height:50px;width:50px;border-radius:50%"/></a>
    </div>
  </div>
  <div class="menu_section">
    <ul>
      <li title="Dashboard"><a href="Home.aspx"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Home</span></a></li>
      <li class="current_section" title="Master Entries"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Master Entries</span></a>
        <ul>
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
        </ul>
      </li>
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
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content">
  <div id="page_content_inner">

<div style="padding: 20px; max-width: 900px;">

  <div style="margin-bottom: 24px;">
    <h2 style="margin: 0 0 4px; font-size: 20px; font-weight: 700; color: #212121;">
      Special Tariffs
    </h2>
    <p style="margin: 0; font-size: 13px; color: #9e9e9e;">
      Set flat-rate fares by distance for the passenger app, and adjust base prices for food delivery and freight.
    </p>
  </div>

  <!-- Section 1: Passenger App Flat Rates -->
  <div class="sp-section">
    <div class="sp-toggle-row">
      <div>
        <div style="font-size: 14px; font-weight: 700; color: #212121;">
          Passenger App &mdash; Flat Rate by Distance
        </div>
        <div style="font-size: 12px; color: #9e9e9e; margin-top: 2px;">
          When ON, the passenger app uses these fixed prices. If the exact km is not in the list, normal tariff applies.
        </div>
      </div>
      <label class="sp-toggle" title="Enable/disable passenger special tariff">
        <input type="checkbox" id="sp-pax-enabled" onchange="spUpdateStatus()"/>
        <span class="sp-slider"></span>
      </label>
    </div>
    <div id="sp-pax-status" style="font-size: 12px; font-weight: 700; margin-bottom: 14px; color: #9E9E9E;">
      &#x25CF; OFF &mdash; passenger app uses normal tariff
    </div>

    <table class="sp-rate-table">
      <thead>
        <tr>
          <th>Distance (km)</th>
          <th>Flat Price ($)</th>
          <th style="width: 50px;"></th>
        </tr>
      </thead>
      <tbody id="sp-pax-tbody">
        <tr><td colspan="3" style="text-align: center; color: #9e9e9e; padding: 20px;">Loading&hellip;</td></tr>
      </tbody>
    </table>

    <!-- Add new row -->
    <div class="sp-add-row">
      <div class="sp-field">
        <label>Distance (km)</label>
        <input type="number" id="sp-new-km" min="0.1" step="0.1" placeholder="e.g. 1"/>
      </div>
      <div class="sp-field">
        <label>Flat Price ($)</label>
        <input type="number" id="sp-new-price" min="0" step="0.50" placeholder="e.g. 5.00"/>
      </div>
      <button class="sp-btn sp-btn-primary" onclick="spAddRow()" style="white-space: nowrap;">
        + Add
      </button>
    </div>

    <div id="sp-pax-msg" style="display: none; margin-top: 10px; font-size: 12px; padding: 8px 12px; border-radius: 4px;"></div>
    <div style="margin-top: 14px; display: flex; justify-content: flex-end;">
      <button class="sp-btn sp-btn-primary" onclick="spSavePassenger()">
        Save Passenger Rates
      </button>
    </div>
  </div>

  <!-- Section 2: Food Delivery -->
  <div class="sp-section">
    <div style="font-size: 14px; font-weight: 700; color: #212121; margin-bottom: 4px;">
      &#127829; Food Delivery &mdash; Pricing
    </div>
    <div style="font-size: 12px; color: #9e9e9e; margin-bottom: 16px;">
      Base fee + distance rate shown to customer before they confirm a delivery booking. Set free km to 0 to charge per km from the start.
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px">
      <div>
        <label style="font-size:12px;font-weight:600;color:#555;display:block;margin-bottom:4px">Base Delivery Fee ($)</label>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fd-base', -0.5)" style="padding:5px 10px;font-size:16px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fd-base" min="0" step="0.50" value="0.00"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fd-base', 0.5)" style="padding:5px 10px;font-size:16px;font-weight:700">+</button>
        </div>
        <div style="font-size:11px;color:#9e9e9e;margin-top:3px">Flat fee charged on every delivery</div>
      </div>
      <div>
        <label style="font-size:12px;font-weight:600;color:#555;display:block;margin-bottom:4px">Free Distance Included (km)</label>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fd-freekm', -0.5)" style="padding:5px 10px;font-size:16px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fd-freekm" min="0" step="0.5" value="0"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fd-freekm', 0.5)" style="padding:5px 10px;font-size:16px;font-weight:700">+</button>
        </div>
        <div style="font-size:11px;color:#9e9e9e;margin-top:3px">First X km included in base fee. Set 0 to charge from pickup.</div>
      </div>
      <div>
        <label style="font-size:12px;font-weight:600;color:#555;display:block;margin-bottom:4px">Per km Rate ($/km)</label>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fd-perkm', -0.10)" style="padding:5px 10px;font-size:16px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fd-perkm" min="0" step="0.10" value="0.00"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fd-perkm', 0.10)" style="padding:5px 10px;font-size:16px;font-weight:700">+</button>
        </div>
        <div style="font-size:11px;color:#9e9e9e;margin-top:3px">Charged per km beyond the free distance</div>
      </div>
      <div>
        <label style="font-size:12px;font-weight:600;color:#555;display:block;margin-bottom:4px">Small Order Surcharge ($)</label>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fd-smallfee', -0.50)" style="padding:5px 10px;font-size:16px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fd-smallfee" min="0" step="0.50" value="0.00"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fd-smallfee', 0.50)" style="padding:5px 10px;font-size:16px;font-weight:700">+</button>
        </div>
        <div style="font-size:11px;color:#9e9e9e;margin-top:3px">Extra fee added if order is below minimum value. Set 0 to disable.</div>
      </div>
      <div>
        <label style="font-size:12px;font-weight:600;color:#555;display:block;margin-bottom:4px">Min Order Value for Surcharge ($)</label>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fd-smallmin', -1)" style="padding:5px 10px;font-size:16px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fd-smallmin" min="0" step="1" value="0.00"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fd-smallmin', 1)" style="padding:5px 10px;font-size:16px;font-weight:700">+</button>
        </div>
        <div style="font-size:11px;color:#9e9e9e;margin-top:3px">Orders below this value attract the surcharge above</div>
      </div>
    </div>

    <div style="background:#E3F2FD;border-radius:6px;padding:10px 14px;font-size:12px;color:#1565C0;margin-bottom:12px">
      <strong>Example:</strong> Base $4.00 + 3km free + $1.50/km &rarr; a 7km delivery = $4.00 + (7&minus;3) &times; $1.50 = <strong>$10.00</strong>
    </div>

    <div id="sp-fd-msg" style="display: none; font-size: 12px; padding: 8px 12px; border-radius: 4px; margin-bottom: 8px;"></div>
    <div style="display: flex; justify-content: flex-end;">
      <button class="sp-btn sp-btn-primary" onclick="spSaveDelivery()">&#10003; Save Food Delivery Pricing</button>
    </div>
  </div>

  <!-- Section 3: Freight / Courier -->
  <div class="sp-section">
    <div style="font-size: 14px; font-weight: 700; color: #212121; margin-bottom: 4px;">
      &#128230; Freight / Courier &mdash; Pricing by Weight
    </div>
    <div style="font-size: 12px; color: #9e9e9e; margin-bottom: 16px;">
      Three weight tiers — each with its own base fee and per-km rate. Customer selects parcel weight when booking; the matching tier is applied automatically.
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:0;margin-bottom:14px">
      <!-- Headers -->
      <div style="background:#37474F;color:#fff;padding:8px 12px;font-size:12px;font-weight:700;border-radius:6px 0 0 0">&#128230; Light (0–5 kg)</div>
      <div style="background:#37474F;color:#fff;padding:8px 12px;font-size:12px;font-weight:700;border-top:1px solid #546E7A">&#128218; Medium (5–20 kg)</div>
      <div style="background:#37474F;color:#fff;padding:8px 12px;font-size:12px;font-weight:700;border-radius:0 6px 0 0;border-top:1px solid #546E7A">&#129529; Heavy (20 kg+)</div>

      <!-- Base fees -->
      <div style="padding:12px;border:1px solid #e0e0e0;border-top:none;border-right:none">
        <div style="font-size:11px;font-weight:600;color:#555;margin-bottom:6px">Base Fee ($)</div>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fr-light-base',-0.5)" style="padding:4px 8px;font-size:14px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fr-light-base" min="0" step="0.5" value="0.00" style="width:70px"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fr-light-base',0.5)" style="padding:4px 8px;font-size:14px;font-weight:700">+</button>
        </div>
      </div>
      <div style="padding:12px;border:1px solid #e0e0e0;border-top:none;border-right:none">
        <div style="font-size:11px;font-weight:600;color:#555;margin-bottom:6px">Base Fee ($)</div>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fr-med-base',-0.5)" style="padding:4px 8px;font-size:14px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fr-med-base" min="0" step="0.5" value="0.00" style="width:70px"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fr-med-base',0.5)" style="padding:4px 8px;font-size:14px;font-weight:700">+</button>
        </div>
      </div>
      <div style="padding:12px;border:1px solid #e0e0e0;border-top:none">
        <div style="font-size:11px;font-weight:600;color:#555;margin-bottom:6px">Base Fee ($)</div>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fr-heavy-base',-0.5)" style="padding:4px 8px;font-size:14px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fr-heavy-base" min="0" step="0.5" value="0.00" style="width:70px"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fr-heavy-base',0.5)" style="padding:4px 8px;font-size:14px;font-weight:700">+</button>
        </div>
      </div>

      <!-- Per km -->
      <div style="padding:12px;border:1px solid #e0e0e0;border-top:none;border-right:none;border-radius:0 0 0 6px">
        <div style="font-size:11px;font-weight:600;color:#555;margin-bottom:6px">Per km ($/km)</div>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fr-light-km',-0.1)" style="padding:4px 8px;font-size:14px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fr-light-km" min="0" step="0.1" value="0.00" style="width:70px"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fr-light-km',0.1)" style="padding:4px 8px;font-size:14px;font-weight:700">+</button>
        </div>
      </div>
      <div style="padding:12px;border:1px solid #e0e0e0;border-top:none;border-right:none">
        <div style="font-size:11px;font-weight:600;color:#555;margin-bottom:6px">Per km ($/km)</div>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fr-med-km',-0.1)" style="padding:4px 8px;font-size:14px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fr-med-km" min="0" step="0.1" value="0.00" style="width:70px"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fr-med-km',0.1)" style="padding:4px 8px;font-size:14px;font-weight:700">+</button>
        </div>
      </div>
      <div style="padding:12px;border:1px solid #e0e0e0;border-top:none;border-radius:0 0 6px 0">
        <div style="font-size:11px;font-weight:600;color:#555;margin-bottom:6px">Per km ($/km)</div>
        <div class="sp-price-input">
          <button class="sp-btn" onclick="spAdjustField('sp-fr-heavy-km',-0.1)" style="padding:4px 8px;font-size:14px;font-weight:700">&minus;</button>
          <input type="number" id="sp-fr-heavy-km" min="0" step="0.1" value="0.00" style="width:70px"/>
          <button class="sp-btn" onclick="spAdjustField('sp-fr-heavy-km',0.1)" style="padding:4px 8px;font-size:14px;font-weight:700">+</button>
        </div>
      </div>
    </div>

    <div style="background:#FFF3E0;border-radius:6px;padding:10px 14px;font-size:12px;color:#E65100;margin-bottom:12px">
      <strong>Example:</strong> Medium parcel, base $8.00 + $2.50/km &rarr; 6km delivery = $8.00 + 6 &times; $2.50 = <strong>$23.00</strong>
    </div>

    <div id="sp-fr-msg" style="display: none; font-size: 12px; padding: 8px 12px; border-radius: 4px; margin-bottom: 8px;"></div>
    <div style="display: flex; justify-content: flex-end;">
      <button class="sp-btn sp-btn-primary" onclick="spSaveFreight()">&#10003; Save Freight Pricing</button>
    </div>
  </div>

</div>

  </div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var _spPaxRates = {};

window._fbOnLogin = function() {
  loadSpecialTariffs();
};

function loadSpecialTariffs() {
  adminRead('specialTariffs/' + COMPANY_ID).then(function(data) {
    data = data || {};

    var pax = data.passenger || {};
    document.getElementById('sp-pax-enabled').checked = !!pax.enabled;
    spUpdateStatus();
    _spPaxRates = pax.rates || {};
    renderSpPaxTable();

    var fd = data.foodDelivery || {};
    document.getElementById('sp-fd-base').value     = (fd.basePrice    || 0).toFixed(2);
    document.getElementById('sp-fd-freekm').value   = (fd.freeKm       || 0).toFixed(1);
    document.getElementById('sp-fd-perkm').value    = (fd.perKm        || 0).toFixed(2);
    document.getElementById('sp-fd-smallfee').value = (fd.smallOrderFee|| 0).toFixed(2);
    document.getElementById('sp-fd-smallmin').value = (fd.smallOrderMin || 0).toFixed(2);

    var fr = data.freight || {};
    var fl = fr.light  || {};
    var fm = fr.medium || {};
    var fh = fr.heavy  || {};
    document.getElementById('sp-fr-light-base').value = (fl.base  || 0).toFixed(2);
    document.getElementById('sp-fr-light-km').value   = (fl.perKm || 0).toFixed(2);
    document.getElementById('sp-fr-med-base').value   = (fm.base  || 0).toFixed(2);
    document.getElementById('sp-fr-med-km').value     = (fm.perKm || 0).toFixed(2);
    document.getElementById('sp-fr-heavy-base').value = (fh.base  || 0).toFixed(2);
    document.getElementById('sp-fr-heavy-km').value   = (fh.perKm || 0).toFixed(2);

  }).catch(function() {
    _spPaxRates = {};
    renderSpPaxTable();
  });
}

function spUpdateStatus() {
  var on = document.getElementById('sp-pax-enabled').checked;
  var el = document.getElementById('sp-pax-status');
  if (on) {
    el.style.color = '#43A047';
    el.textContent = '\u25CF ON \u2014 passenger app will use these flat rates';
  } else {
    el.style.color = '#9E9E9E';
    el.textContent = '\u25CF OFF \u2014 passenger app uses normal tariff';
  }
}

function renderSpPaxTable() {
  var tbody = document.getElementById('sp-pax-tbody');
  var keys = Object.keys(_spPaxRates).map(Number).sort(function(a, b) { return a - b; });
  if (!keys.length) {
    tbody.innerHTML = '<tr><td colspan="3" style="text-align:center;color:#9e9e9e;padding:20px">No rates added yet \u2014 use the form below to add entries.</td></tr>';
    return;
  }
  tbody.innerHTML = keys.map(function(km) {
    var price = _spPaxRates[String(km)];
    return '<tr>' +
      '<td style="font-weight:600">' + km + ' km</td>' +
      '<td style="color:#1B5E20;font-weight:700">$' + parseFloat(price).toFixed(2) + '</td>' +
      '<td>' +
        '<button class="sp-btn sp-btn-danger" onclick="spRemoveRow(' + km + ')" style="padding:3px 8px">' +
          '<span style="font-size:13px">\u2715</span>' +
        '</button>' +
      '</td>' +
    '</tr>';
  }).join('');
}

function spAddRow() {
  var km    = parseFloat(document.getElementById('sp-new-km').value);
  var price = parseFloat(document.getElementById('sp-new-price').value);
  if (isNaN(km) || km <= 0)     { spMsg('pax', 'Enter a valid distance.', false); return; }
  if (isNaN(price) || price < 0) { spMsg('pax', 'Enter a valid price.', false); return; }
  _spPaxRates[String(km)] = price;
  document.getElementById('sp-new-km').value    = '';
  document.getElementById('sp-new-price').value = '';
  renderSpPaxTable();
}

function spRemoveRow(km) {
  delete _spPaxRates[String(km)];
  renderSpPaxTable();
}

function spSavePassenger() {
  var enabled = document.getElementById('sp-pax-enabled').checked;
  var payload = { enabled: enabled, rates: _spPaxRates, updatedAt: Date.now() };
  adminWrite('specialTariffs/' + COMPANY_ID + '/passenger', 'PUT', payload).then(function() {
    spMsg('pax', 'Passenger rates saved.', true);
  }).catch(function(e) { spMsg('pax', 'Save failed: ' + e.message, false); });
}

function spSaveDelivery() {
  var payload = {
    basePrice:  parseFloat(document.getElementById('sp-fd-base').value)     || 0,
    freeKm:     parseFloat(document.getElementById('sp-fd-freekm').value)   || 0,
    perKm:      parseFloat(document.getElementById('sp-fd-perkm').value)    || 0,
    smallOrderFee: parseFloat(document.getElementById('sp-fd-smallfee').value) || 0,
    smallOrderMin: parseFloat(document.getElementById('sp-fd-smallmin').value) || 0,
    updatedAt: Date.now()
  };
  adminWrite('specialTariffs/' + COMPANY_ID + '/foodDelivery', 'PUT', payload).then(function() {
    spMsg('fd', 'Food delivery pricing saved.', true);
  }).catch(function(e) { spMsg('fd', 'Save failed: ' + e.message, false); });
}

function spSaveFreight() {
  var payload = {
    light:  { base: parseFloat(document.getElementById('sp-fr-light-base').value) || 0, perKm: parseFloat(document.getElementById('sp-fr-light-km').value) || 0 },
    medium: { base: parseFloat(document.getElementById('sp-fr-med-base').value)   || 0, perKm: parseFloat(document.getElementById('sp-fr-med-km').value)   || 0 },
    heavy:  { base: parseFloat(document.getElementById('sp-fr-heavy-base').value) || 0, perKm: parseFloat(document.getElementById('sp-fr-heavy-km').value) || 0 },
    updatedAt: Date.now()
  };
  adminWrite('specialTariffs/' + COMPANY_ID + '/freight', 'PUT', payload).then(function() {
    spMsg('fr', 'Freight pricing saved.', true);
  }).catch(function(e) { spMsg('fr', 'Save failed: ' + e.message, false); });
}

function spAdjustField(id, delta) {
  var el = document.getElementById(id);
  if (!el) return;
  var step = parseFloat(el.getAttribute('step')) || 0.5;
  var val = Math.max(0, (parseFloat(el.value) || 0) + delta);
  el.value = val.toFixed(step < 1 ? 2 : 0);
}

function spMsg(type, msg, ok) {
  var el = document.getElementById('sp-' + type + '-msg');
  if (!el) return;
  el.style.display      = 'block';
  el.style.background   = ok ? '#E8F5E9' : '#FFEBEE';
  el.style.color        = ok ? '#1B5E20' : '#C62828';
  el.style.borderLeft   = '4px solid ' + (ok ? '#4CAF50' : '#F44336');
  el.textContent        = msg;
  setTimeout(function() { el.style.display = 'none'; }, 3500);
}
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
