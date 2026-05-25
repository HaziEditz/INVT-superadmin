<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Send Email &mdash; BookaWaka Admin</title>
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
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-n:hover{background:#eee}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.ff label{display:block;font-size:12px;color:#666;font-weight:600;margin-bottom:4px;text-transform:uppercase;letter-spacing:.04em}
.ff input,.ff select,.ff textarea{width:100%;padding:9px 11px;border:1px solid #ddd;border-radius:5px;font-size:13.5px;box-sizing:border-box;font-family:inherit;transition:border-color .15s}
.ff input:focus,.ff select:focus,.ff textarea:focus{outline:none;border-color:#1565C0;box-shadow:0 0 0 3px rgba(21,101,192,.08)}
.ff textarea{resize:vertical;line-height:1.6}
.compose-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px}
.compose-grid.full{grid-template-columns:1fr}
/* Templates */
.template-strip{display:flex;gap:8px;flex-wrap:wrap;padding:14px 18px;background:#F8FBFF;border-bottom:1px solid #e8f0fe}
.tpl-btn{padding:6px 13px;border-radius:20px;border:1.5px solid #BBDEFB;background:#fff;color:#1565C0;font-size:12px;font-weight:600;cursor:pointer;transition:all .15s}
.tpl-btn:hover,.tpl-btn.active{background:#1565C0;color:#fff;border-color:#1565C0}
.tpl-label{font-size:12px;color:#888;font-weight:600;align-self:center;white-space:nowrap}
/* Company info bar */
.co-info{display:flex;gap:16px;align-items:center;padding:10px 14px;background:#F3F8FF;border:1px solid #BBDEFB;border-radius:6px;margin-bottom:14px;flex-wrap:wrap}
.co-info-item{font-size:12.5px;color:#555}
.co-info-item strong{color:#1565C0}
/* Log table */
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;color:#0D47A1;font-size:12px}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:last-child td{border-bottom:none}
.sa-tbl tr:hover td{background:#FAFEFF}
.badge-sent{background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #A5D6A7}
.badge-failed{background:#FFEBEE;color:#C62828;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;border:1px solid #FFCDD2}
/* Char counter */
.char-count{font-size:11px;color:#aaa;text-align:right;margin-top:3px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Send Email &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Email.aspx" style="font-weight:700;color:#1565C0">&#9658; Send Email</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#9993; Send Email to Company</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">Compose and send an email directly to any registered company. Use templates for common messages like invoices, payment reminders, and notices.</p>

<div id="sa-notice" style="display:none" class="sa-notice"></div>

<!-- Compose card -->
<div class="sa-card">
  <div class="sa-bar">
    <h3>&#9998; Compose Email</h3>
    <span id="send-status" style="font-size:12px;opacity:.85"></span>
  </div>

  <!-- Quick templates -->
  <div class="template-strip">
    <span class="tpl-label">Quick Template:</span>
    <button class="tpl-btn" onclick="applyTemplate('invoice')">&#128190; Monthly Invoice</button>
    <button class="tpl-btn" onclick="applyTemplate('payment_reminder')">&#9888; Payment Reminder</button>
    <button class="tpl-btn" onclick="applyTemplate('overdue')">&#128680; Overdue Notice</button>
    <button class="tpl-btn" onclick="applyTemplate('welcome')">&#127881; Welcome</button>
    <button class="tpl-btn" onclick="applyTemplate('subscription')">&#128260; Subscription Update</button>
    <button class="tpl-btn" onclick="applyTemplate('general')">&#128221; General Notice</button>
    <button class="tpl-btn sa-btn-n" style="border-radius:20px" onclick="clearAll()">&#10006; Clear</button>
  </div>

  <div style="padding:20px">

    <!-- Company selector -->
    <div class="compose-grid" style="margin-bottom:14px">
      <div class="ff">
        <label>Company <span style="color:#C62828">*</span></label>
        <select id="co-select" onchange="onCompanyChange()">
          <option value="">— Select a company —</option>
        </select>
      </div>
      <div class="ff">
        <label>To (Email Address) <span style="color:#C62828">*</span></label>
        <input id="to-email" type="email" placeholder="Loaded from company record&#8230;" />
      </div>
    </div>

    <!-- Company info strip -->
    <div id="co-info" class="co-info" style="display:none">
      <div class="co-info-item">&#127970; Company: <strong id="ci-name">—</strong></div>
      <div class="co-info-item">&#128100; Contact: <strong id="ci-contact">—</strong></div>
      <div class="co-info-item">&#127757; <strong id="ci-city">—</strong></div>
      <div class="co-info-item" id="ci-fleet-wrap" style="display:none">&#128665; Fleet: <strong id="ci-fleet">—</strong> vehicles</div>
    </div>

    <!-- CC + Subject -->
    <div class="compose-grid" style="margin-bottom:14px">
      <div class="ff">
        <label>CC <span style="color:#aaa;font-weight:400;text-transform:none">optional — comma separated</span></label>
        <input id="cc-email" type="text" placeholder="accounts@youroffice.co.nz, &#8230;"/>
      </div>
      <div class="ff">
        <label>Subject <span style="color:#C62828">*</span></label>
        <input id="email-subject" type="text" placeholder="e.g. Invoice #BW-2026-0042 — April"/>
      </div>
    </div>

    <!-- Body -->
    <div class="ff compose-grid full" style="margin-bottom:6px">
      <label>Message Body <span style="color:#C62828">*</span></label>
      <textarea id="email-body" rows="14" placeholder="Type your message here&#8230; or pick a quick template above." oninput="updateCharCount()"></textarea>
    </div>
    <div class="char-count" id="char-count">0 characters</div>

    <!-- Ref / Invoice number -->
    <div class="compose-grid" style="margin-top:14px">
      <div class="ff">
        <label>Reference / Invoice # <span style="color:#aaa;font-weight:400;text-transform:none">optional</span></label>
        <input id="ref-no" type="text" placeholder="e.g. BW-INV-2026-0042"/>
      </div>
      <div class="ff">
        <label>Amount (if applicable) <span style="color:#aaa;font-weight:400;text-transform:none">for display only</span></label>
        <input id="ref-amount" type="text" placeholder="e.g. $1,240.00"/>
      </div>
    </div>

    <!-- Send bar -->
    <div style="display:flex;gap:10px;margin-top:20px;align-items:center;flex-wrap:wrap;border-top:1px solid #f0f0f0;padding-top:16px">
      <button class="sa-btn sa-btn-p" style="font-size:14px;padding:10px 24px" onclick="sendEmail()">
        &#9993; Send Email
      </button>
      <button class="sa-btn sa-btn-n" onclick="clearAll()">Clear</button>
      <span id="send-msg" style="font-size:13px;color:#C62828;margin-left:4px"></span>
    </div>

  </div>
</div>

<!-- Sent log -->
<div class="sa-card">
  <div class="sa-bar" style="background:#37474F">
    <h3>&#128202; Sent Email Log</h3>
    <div style="display:flex;gap:8px;align-items:center">
      <select id="log-filter-co" onchange="renderLog()" style="padding:5px 10px;border-radius:4px;border:none;font-size:12px;min-width:160px">
        <option value="">All Companies</option>
      </select>
      <button class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;font-size:12px" onclick="loadLog()">&#8635; Refresh</button>
    </div>
  </div>
  <div style="overflow-x:auto">
    <table class="sa-tbl">
      <thead><tr>
        <th>Date / Time</th><th>Company</th><th>To</th><th>Subject</th><th>Ref #</th><th>Sent by</th><th>Status</th>
      </tr></thead>
      <tbody id="log-tbody">
        <tr><td colspan="7" style="text-align:center;padding:24px;color:#aaa">Loading&#8230;</td></tr>
      </tbody>
    </table>
  </div>
  <div id="log-empty" style="display:none;text-align:center;padding:28px;color:#aaa;font-style:italic">No emails sent yet.</div>
</div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
/* db is provided by tm-helpers.js shim — do not redeclare */
var allCompanies = {};
var emailLog = {};

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function showNotice(msg, type) {
  var el = document.getElementById('sa-notice');
  el.className = 'sa-notice ' + (type||'ok');
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(function(){ el.style.display='none'; }, 5000);
}

function fmtDate(ts) {
  if (!ts) return '—';
  return new Date(ts).toLocaleString('en-NZ', {day:'2-digit',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'});
}

/* ── Templates ── */
var TEMPLATES = {
  invoice: {
    subject: 'Invoice #{REF} — BookaWaka Platform — {MONTH}',
    body: 'Dear {CONTACT},\n\nPlease find attached your invoice for the BookaWaka platform subscription for the period ending {MONTH}.\n\nInvoice Reference: {REF}\nAmount Due: {AMOUNT}\nDue Date: [DUE DATE]\n\nPayment can be made via bank transfer to:\n  Account Name: BookaWaka Ltd\n  Bank: [BANK DETAILS]\n\nIf you have any questions about this invoice, please don\'t hesitate to reply to this email.\n\nThank you for your continued partnership with BookaWaka.\n\nKind regards,\nBookaWaka Finance Team'
  },
  payment_reminder: {
    subject: 'Payment Reminder — Invoice {REF} — BookaWaka',
    body: 'Dear {CONTACT},\n\nThis is a friendly reminder that payment for Invoice {REF} ({AMOUNT}) is due shortly.\n\nPlease ensure payment is made by the due date to avoid any interruption to your service.\n\nIf you have already made payment, please disregard this message.\n\nShould you have any queries or need to discuss payment arrangements, please reply to this email.\n\nKind regards,\nBookaWaka Finance Team'
  },
  overdue: {
    subject: 'OVERDUE: Invoice {REF} — Action Required — BookaWaka',
    body: 'Dear {CONTACT},\n\nOur records show that Invoice {REF} ({AMOUNT}) is now overdue.\n\nWe ask that you arrange payment as soon as possible to ensure continuity of your BookaWaka services. Failure to settle this balance within 7 days may result in temporary suspension of platform access.\n\nIf you are experiencing difficulty making payment, please contact us immediately so we can discuss a suitable arrangement.\n\nKind regards,\nBookaWaka Accounts Team'
  },
  welcome: {
    subject: 'Welcome to BookaWaka — {COMPANY}',
    body: 'Dear {CONTACT},\n\nWelcome to the BookaWaka platform! We\'re thrilled to have {COMPANY} on board.\n\nHere\'s what you can expect:\n\n• Real-time dispatch and trip management\n• Driver and fleet management tools\n• Automated fare calculations and reporting\n• Total Mobility subsidy processing (if applicable)\n• Dedicated support from the BookaWaka team\n\nYour company admin portal is available at: https://admin.bookawaka.co.nz\nYour dispatch portal is available at: https://dispatch.bookawaka.co.nz\n\nIf you have any questions getting started, please don\'t hesitate to reach out.\n\nWelcome aboard!\n\nKind regards,\nThe BookaWaka Team'
  },
  subscription: {
    subject: 'Subscription Update — BookaWaka Platform — {COMPANY}',
    body: 'Dear {CONTACT},\n\nWe are writing to inform you of an update to your BookaWaka platform subscription.\n\nYour current plan: [PLAN NAME]\nEffective date: [DATE]\nNew amount: {AMOUNT}/month\n\nThis change reflects [REASON FOR CHANGE].\n\nIf you have any questions about this update or wish to discuss your plan, please reply to this email or contact your account manager.\n\nThank you for your continued support.\n\nKind regards,\nBookaWaka Team'
  },
  general: {
    subject: 'Message from BookaWaka — {COMPANY}',
    body: 'Dear {CONTACT},\n\nWe are reaching out regarding your account with BookaWaka.\n\n[YOUR MESSAGE HERE]\n\nIf you have any questions, please don\'t hesitate to contact us.\n\nKind regards,\nBookaWaka Admin Team'
  }
};

function applyTemplate(key) {
  document.querySelectorAll('.tpl-btn').forEach(function(b){ b.classList.remove('active'); });
  event.target.classList.add('active');
  var co = allCompanies[document.getElementById('co-select').value] || {};
  var tpl = TEMPLATES[key];
  if (!tpl) return;
  var contact = co.contactName || co.ownerName || co.name || '[Contact Name]';
  var company = co.name || '[Company Name]';
  var month = new Date().toLocaleDateString('en-NZ', {month:'long', year:'numeric'});
  var ref = document.getElementById('ref-no').value || 'BW-' + new Date().getFullYear() + '-XXXX';
  var amount = document.getElementById('ref-amount').value || '[AMOUNT]';
  function fill(s) {
    return s.replace(/{CONTACT}/g, contact).replace(/{COMPANY}/g, company)
            .replace(/{MONTH}/g, month).replace(/{REF}/g, ref).replace(/{AMOUNT}/g, amount);
  }
  document.getElementById('email-subject').value = fill(tpl.subject);
  document.getElementById('email-body').value = fill(tpl.body);
  updateCharCount();
}

function updateCharCount() {
  var l = (document.getElementById('email-body').value || '').length;
  document.getElementById('char-count').textContent = l.toLocaleString() + ' character' + (l===1?'':'s');
}

function clearAll() {
  document.getElementById('email-subject').value = '';
  document.getElementById('email-body').value = '';
  document.getElementById('cc-email').value = '';
  document.getElementById('ref-no').value = '';
  document.getElementById('ref-amount').value = '';
  document.getElementById('send-msg').textContent = '';
  document.querySelectorAll('.tpl-btn').forEach(function(b){ b.classList.remove('active'); });
  updateCharCount();
}

/* ── Company selector ── */
function onCompanyChange() {
  var cid = document.getElementById('co-select').value;
  var co = allCompanies[cid];
  if (!co) {
    document.getElementById('co-info').style.display = 'none';
    document.getElementById('to-email').value = '';
    return;
  }
  var email = co.email || co.contactEmail || co.billingEmail || co.ownerEmail || '';
  document.getElementById('to-email').value = email;
  document.getElementById('ci-name').textContent = co.name || cid;
  document.getElementById('ci-contact').textContent = co.contactName || co.ownerName || '—';
  document.getElementById('ci-city').textContent = [co.city, co.country].filter(Boolean).join(', ') || '—';
  var fleet = co.fleetSize || co.numberOfVehicles || co.vehicles;
  if (fleet) {
    document.getElementById('ci-fleet').textContent = fleet;
    document.getElementById('ci-fleet-wrap').style.display = '';
  } else {
    document.getElementById('ci-fleet-wrap').style.display = 'none';
  }
  document.getElementById('co-info').style.display = 'flex';
}

/* ── Send email ── */
function sendEmail() {
  var cid = document.getElementById('co-select').value;
  var toEmail = document.getElementById('to-email').value.trim();
  var ccRaw = document.getElementById('cc-email').value.trim();
  var subject = document.getElementById('email-subject').value.trim();
  var body = document.getElementById('email-body').value.trim();
  var ref = document.getElementById('ref-no').value.trim();
  var amount = document.getElementById('ref-amount').value.trim();
  var msg = document.getElementById('send-msg');

  if (!toEmail) { msg.textContent = 'Please enter or load a recipient email.'; return; }
  if (!subject) { msg.textContent = 'Please enter a subject.'; return; }
  if (!body) { msg.textContent = 'Please enter a message.'; return; }

  var co = allCompanies[cid] || {};
  var coName = co.name || cid || 'Unknown Company';
  var ccList = ccRaw ? ccRaw.split(',').map(function(e){ return e.trim(); }).filter(Boolean) : [];

  msg.style.color = '#1565C0';
  msg.textContent = 'Sending&#8230;';
  document.querySelector('button[onclick="sendEmail()"]').disabled = true;

  fetch('/api/send-company-email', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      companyId: cid,
      companyName: coName,
      toEmail: toEmail,
      cc: ccList,
      subject: subject,
      body: body,
      refNo: ref || null,
      amount: amount || null
    })
  }).then(function(r){ return r.json(); }).then(function(json) {
    document.querySelector('button[onclick="sendEmail()"]').disabled = false;
    if (json.ok) {
      msg.style.color = '#2E7D32';
      msg.textContent = 'Email sent successfully to ' + toEmail;
      showNotice('Email sent to ' + coName + ' (' + toEmail + ')','ok');
      loadLog();
    } else {
      msg.style.color = '#C62828';
      msg.textContent = 'Send failed: ' + (json.error || 'Unknown error');
    }
  }).catch(function(err) {
    document.querySelector('button[onclick="sendEmail()"]').disabled = false;
    msg.style.color = '#C62828';
    msg.textContent = 'Network error: ' + String(err);
  });
}

/* ── Load log ── */
function loadLog() {
  _fbGet('emailLog').then(function(data) {
    emailLog = data || {};
    renderLog();
  });
}

function renderLog() {
  var filterCo = document.getElementById('log-filter-co').value;
  var tbody = document.getElementById('log-tbody');
  var empty = document.getElementById('log-empty');
  var entries = Object.entries(emailLog).map(function(e){ return Object.assign({ _id: e[0] }, e[1]); });
  if (filterCo) entries = entries.filter(function(e){ return e.companyId === filterCo; });
  entries.sort(function(a,b){ return (b.sentAt||0)-(a.sentAt||0); });

  if (!entries.length) {
    tbody.innerHTML = '';
    empty.style.display = 'block';
    return;
  }
  empty.style.display = 'none';
  tbody.innerHTML = entries.map(function(e) {
    var coName = (allCompanies[e.companyId] && allCompanies[e.companyId].name) || e.companyName || e.companyId || '—';
    var statusBadge = e.status === 'sent'
      ? '<span class="badge-sent">&#10003; Sent</span>'
      : '<span class="badge-failed">&#10007; Failed</span>';
    return '<tr>'+
      '<td style="font-size:12px;color:#888;white-space:nowrap">'+fmtDate(e.sentAt)+'</td>'+
      '<td style="font-weight:600;font-size:13px">'+esc(coName)+'</td>'+
      '<td style="font-size:12px">'+esc(e.toEmail||'—')+'</td>'+
      '<td style="font-size:12px;max-width:240px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="'+esc(e.subject||'')+'">'+esc(e.subject||'—')+'</td>'+
      '<td style="font-family:monospace;font-size:11px;color:#888">'+esc(e.refNo||'—')+'</td>'+
      '<td style="font-size:12px;color:#888">'+esc(e.sentBy||'admin')+'</td>'+
      '<td>'+statusBadge+(e.error?'<div style="font-size:10.5px;color:#C62828;margin-top:2px">'+esc(e.error)+'</div>':'')+'</td>'+
    '</tr>';
  }).join('');
}

/* ── Init ── */
var _dataLoaded = false;
function loadData() {
  if (_dataLoaded) return;
  _dataLoaded = true;
  _fbGet('superClients').then(function(data) {
    allCompanies = data || {};
    var keys = Object.keys(allCompanies);
    if (!keys.length) {
      showNotice('No companies found in database.', 'err');
      return;
    }
    var sel = document.getElementById('co-select');
    var logSel = document.getElementById('log-filter-co');
    keys.sort(function(a,b){
      return (allCompanies[a].name||a).localeCompare(allCompanies[b].name||b);
    }).forEach(function(cid) {
      var name = allCompanies[cid].name || cid;
      var o1 = document.createElement('option'); o1.value=cid; o1.textContent=name; sel.appendChild(o1);
      var o2 = document.createElement('option'); o2.value=cid; o2.textContent=name; logSel.appendChild(o2);
    });
    // Pre-select company from URL ?cid=
    var params = new URLSearchParams(window.location.search);
    var preselect = params.get('cid');
    if (preselect && allCompanies[preselect]) {
      sel.value = preselect;
      onCompanyChange();
    }
    loadLog();
  }).catch(function(err) {
    showNotice('Failed to load companies: ' + String(err), 'err');
    console.error('loadData error:', err);
  });
}

window._fbOnLogin = function(){ loadData(); };
/* Fallback: also fire on DOMContentLoaded in case _fbOnLogin never triggers */
document.addEventListener('DOMContentLoaded', function() {
  setTimeout(function() { if (!_dataLoaded) loadData(); }, 2000);
});
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
