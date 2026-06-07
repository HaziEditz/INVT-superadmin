<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Onboarding Requests &mdash; BookaWaka Admin</title>
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
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;margin-bottom:20px}
.sa-stat{background:#fff;border-radius:6px;padding:14px 18px;box-shadow:0 1px 4px rgba(0,0,0,.1);border-left:4px solid #1565C0;cursor:pointer;transition:.15s}
.sa-stat:hover{box-shadow:0 2px 8px rgba(0,0,0,.15);transform:translateY(-1px)}
.sa-stat.active{box-shadow:0 2px 8px rgba(0,0,0,.2);transform:translateY(-1px)}
.sa-stat.yellow{border-left-color:#F57F17}
.sa-stat.green{border-left-color:#2E7D32}
.sa-stat.red{border-left-color:#C62828}
.sa-stat.grey{border-left-color:#757575}
.sa-stat-v{font-size:28px;font-weight:700;color:#1565C0;line-height:1.1}
.sa-stat.yellow .sa-stat-v{color:#F57F17}
.sa-stat.green .sa-stat-v{color:#2E7D32}
.sa-stat.red .sa-stat-v{color:#C62828}
.sa-stat.grey .sa-stat-v{color:#757575}
.sa-stat-l{font-size:11.5px;color:#888;margin-top:4px}
.tab-btns{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:16px}
.tab-btn{padding:7px 18px;border:1px solid #ddd;border-radius:20px;background:#fff;font-size:13px;cursor:pointer;font-weight:500;transition:.15s}
.tab-btn:hover{border-color:#1565C0;color:#1565C0}
.tab-btn.active{background:#1565C0;color:#fff;border-color:#1565C0;font-weight:700}
.req-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.1);margin-bottom:14px;overflow:hidden;border-left:4px solid #ddd;transition:.15s}
.req-card.pending{border-left-color:#F57F17}
.req-card.approved{border-left-color:#2E7D32}
.req-card.rejected{border-left-color:#C62828}
.req-card-hdr{padding:14px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;cursor:pointer;background:#fafafa;border-bottom:1px solid #f0f0f0}
.req-card-hdr:hover{background:#f5f5f5}
.req-card-body{padding:18px;display:none}
.req-card-body.open{display:block}
.req-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px;margin-bottom:14px}
.req-field{font-size:13px}
.req-field label{display:block;font-size:11px;font-weight:700;color:#aaa;text-transform:uppercase;letter-spacing:.5px;margin-bottom:2px}
.req-field span{color:#263238;font-weight:500;overflow-wrap:break-word;word-break:break-word}
.req-actions{display:flex;gap:8px;flex-wrap:wrap;padding-top:14px;border-top:1px solid #f0f0f0;margin-top:4px}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 16px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:600}
.sa-btn-approve{background:#2E7D32;color:#fff}.sa-btn-approve:hover{background:#1B5E20}
.sa-btn-reject{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-reject:hover{background:#FFCDD2}
.sa-btn-view{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}.sa-btn-view:hover{background:#BBDEFB}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.mod-chip{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600;margin-right:4px}
.mod-on{background:#E8F5E9;color:#2E7D32}
.bx{display:inline-block;padding:2px 10px;border-radius:10px;font-size:11.5px;font-weight:600}
.bx-pending{background:#FFF8E1;color:#F57F17;border:1px solid #FFE082}
.bx-approved{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.bx-rejected{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.share-box{background:#E3F2FD;border:1px solid #BBDEFB;border-radius:6px;padding:12px 16px;font-size:13px;color:#1565C0;display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:16px}
.share-box input{flex:1;min-width:200px;padding:7px 10px;border:1px solid #BBDEFB;border-radius:4px;font-size:13px;background:#fff;color:#1565C0;font-family:monospace}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center}
.modal-overlay.open{display:flex}
.modal-box{background:#fff;border-radius:10px;padding:28px;max-width:480px;width:95%;box-shadow:0 8px 30px rgba(0,0,0,.2)}
.modal-box h3{font-size:16px;font-weight:700;margin-bottom:16px;color:#263238}
.modal-field{margin-bottom:14px}
.modal-field label{display:block;font-size:12.5px;font-weight:600;color:#555;margin-bottom:5px}
.modal-field input,.modal-field textarea,.modal-field select{width:100%;padding:9px 12px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;font-family:inherit}
.modal-field input:focus,.modal-field textarea:focus,.modal-field select:focus{outline:none;border-color:#1565C0}
.modal-actions{display:flex;gap:8px;justify-content:flex-end;margin-top:18px}
.modal-info{background:#E3F2FD;border-left:4px solid #1565C0;padding:10px 14px;border-radius:4px;font-size:13px;color:#0D47A1;margin-bottom:14px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Onboarding Requests &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Onboard.aspx" style="font-weight:700;color:#1565C0">&#9658; Onboarding Requests <span id="sb-pending-badge" style="background:#1565C0;color:#fff;font-size:10px;font-weight:700;padding:1px 6px;border-radius:8px;margin-left:4px;display:none"></span></a></li>
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

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px;color:#1565C0">&#128640; Company Onboarding Requests</h2>
<p style="font-size:13px;color:#888;margin-bottom:16px">Review applications from taxi companies that want to join the BookaWaka platform. Approve to auto-create their company record, or reject with a note.</p>

<div class="share-box">
  <span>&#128279; Share your application link with prospective companies:</span>
  <input type="text" id="join-link" readonly onclick="this.select()"/>
  <button onclick="copyLink()" style="padding:7px 14px;border:1px solid #BBDEFB;border-radius:4px;background:#fff;color:#1565C0;font-size:12px;font-weight:600;cursor:pointer">Copy</button>
  <a id="join-link-open" href="#" target="_blank" style="padding:7px 14px;border:1px solid #BBDEFB;border-radius:4px;background:#fff;color:#1565C0;font-size:12px;font-weight:600;text-decoration:none">Open &#8599;</a>
</div>

<div class="sa-card" style="margin-bottom:20px">
  <div class="sa-bar" style="background:#2E7D32">
    <h3>&#10133; Direct Company Onboarding</h3>
    <button onclick="openDirectOnboard()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3)">&#43; Create Company Now</button>
  </div>
  <div style="padding:12px 18px;font-size:13px;color:#555">
    Onboard a company directly without a registration request. A unique Company ID is auto-assigned, a Firebase login is created automatically, and the company can log in immediately.
  </div>
</div>

<div class="sa-stats">
  <div class="sa-stat yellow" onclick="setTab('pending')"><div class="sa-stat-v" id="cnt-pending">0</div><div class="sa-stat-l">Pending Review</div></div>
  <div class="sa-stat green" onclick="setTab('approved')"><div class="sa-stat-v" id="cnt-approved">0</div><div class="sa-stat-l">Trial &amp; Active</div></div>
  <div class="sa-stat red" onclick="setTab('rejected')"><div class="sa-stat-v" id="cnt-rejected">0</div><div class="sa-stat-l">Rejected</div></div>
  <div class="sa-stat grey" onclick="setTab('all')"><div class="sa-stat-v" id="cnt-all">0</div><div class="sa-stat-l">Total Applications</div></div>
</div>

<div class="tab-btns">
  <button class="tab-btn active" id="tab-pending" onclick="setTab('pending')">&#9202; Pending</button>
  <button class="tab-btn" id="tab-approved" onclick="setTab('approved')">&#10003; Approved</button>
  <button class="tab-btn" id="tab-rejected" onclick="setTab('rejected')">&#10007; Rejected</button>
  <button class="tab-btn" id="tab-all" onclick="setTab('all')">All</button>
  <button onclick="bulkApproveAllPending()" class="sa-btn sa-btn-approve" style="font-size:12px;margin-left:auto">&#10003;&#10003; Approve All Pending</button>
</div>
<div class="tab-btns" style="margin-top:-8px;margin-bottom:12px">
  <button class="tab-btn active" id="type-all" onclick="setType('all')">All Service Types</button>
  <button class="tab-btn" id="type-taxi" onclick="setType('taxi')">&#128665; Taxi</button>
  <button class="tab-btn" id="type-towing" onclick="setType('towing')" style="border-color:#E65100;color:#E65100">&#128667; Towing</button>
</div>

<div id="requests-wrap">
  <div style="text-align:center;padding:40px;color:#aaa">Loading requests&hellip;</div>
</div>

</div>
</div></div>

<div class="modal-overlay" id="modal-approve">
  <div class="modal-box">
    <h3>&#10003; Approve Application</h3>
    <div class="modal-info" id="approve-summary"></div>
    <div style="font-size:12.5px;color:#555;background:#F1F8E9;border-left:4px solid #2E7D32;padding:10px 14px;border-radius:4px;margin-bottom:14px">
      Approving will start a <strong>10-day free trial</strong> automatically. A unique Company ID will be assigned by the system.
    </div>
    <div class="modal-field">
      <label>Subscription Package (optional)</label>
      <select id="approve-pkg">
        <option value="">-- No package assigned yet --</option>
      </select>
    </div>
    <div class="modal-field">
      <label>Owner's Firebase UID <span style="font-weight:400;color:#888">(optional — paste from Firebase Console if auto-lookup fails)</span></label>
      <input type="text" id="approve-uid" placeholder="e.g. abc123XYZdef — leave blank to auto-detect" style="font-family:monospace;font-size:13px"/>
      <div style="font-size:11px;color:#aaa;margin-top:3px">Firebase Console → Authentication → Users → find the email → copy UID</div>
    </div>
    <div class="modal-field">
      <label>Internal Note (optional)</label>
      <textarea id="approve-note" rows="2" placeholder="e.g. Referred by Auckland council, first 3 months free"></textarea>
    </div>
    <div style="margin-top:10px;padding-top:10px;border-top:1px solid #f0f0f0;font-size:12.5px;color:#1565C0">
      <a id="approve-preview-link" href="#" target="_blank" style="color:#1565C0;text-decoration:none">&#128233; Preview welcome email &rarr;</a>
      <span style="color:#aaa;font-size:11px;margin-left:6px">(opens in new tab — temp password shown as placeholder)</span>
    </div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-approve')" class="sa-btn sa-btn-n">Cancel</button>
      <button onclick="confirmApprove()" class="sa-btn sa-btn-approve">&#10003; Confirm &amp; Start Trial</button>
    </div>
  </div>
</div>

<div class="modal-overlay" id="modal-reject">
  <div class="modal-box">
    <h3>&#10007; Reject Application</h3>
    <div class="modal-info" id="reject-summary"></div>
    <div class="modal-field">
      <label>Rejection Reason <span style="color:#1565C0">*</span></label>
      <select id="reject-reason">
        <option value="">-- Select reason --</option>
        <option value="Service area not covered">Service area not covered</option>
        <option value="Duplicate application">Duplicate application</option>
        <option value="Does not meet requirements">Does not meet requirements</option>
        <option value="Application incomplete">Application incomplete</option>
        <option value="Currently not onboarding">Currently not onboarding new companies</option>
        <option value="Other">Other (specify below)</option>
      </select>
    </div>
    <div class="modal-field">
      <label>Additional Note</label>
      <textarea id="reject-note" rows="3" placeholder="Optional — any additional context for internal records"></textarea>
    </div>
    <div class="modal-field" style="margin-top:4px">
      <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13px;font-weight:500">
        <input type="checkbox" id="reject-send-email" checked style="width:15px;height:15px;accent-color:#1565C0"/>
        Notify applicant by email with rejection reason
      </label>
    </div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-reject')" class="sa-btn sa-btn-n">Cancel</button>
      <button onclick="confirmReject()" style="background:#C62828;color:#fff;padding:7px 16px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:600">&#10007; Confirm Rejection</button>
    </div>
  </div>
</div>

<div class="modal-overlay" id="modal-grant-uid">
  <div class="modal-box" style="max-width:520px">
    <h3>&#128273; Grant Owner Panel Access</h3>
    <div class="modal-info" id="grant-uid-summary"></div>
    <div style="background:#E3F2FD;border-left:4px solid #1565C0;padding:10px 14px;border-radius:4px;font-size:12.5px;color:#333;margin-bottom:14px">
      The owner already has a Firebase account. To grant them owner panel access, paste their Firebase UID below.<br><br>
      <strong>How to find the UID:</strong> Go to <strong>Firebase Console → Authentication → Users</strong>, search for the owner's email, and copy the UID (28-character code in the User UID column).
    </div>
    <div class="modal-field">
      <label>Firebase UID <span style="color:#C62828">*</span></label>
      <input type="text" id="grant-uid-input" placeholder="e.g. dBJKSLmLY8RZ8C523xAsCfgZcgA2" style="font-family:monospace;font-size:13px" oninput="validateGrantUid()"/>
      <div id="grant-uid-hint" style="font-size:11.5px;color:#aaa;margin-top:3px">UIDs are 28 characters — letters and numbers only.</div>
    </div>
    <div style="background:#E3F2FD;border-left:4px solid #1565C0;padding:10px 14px;border-radius:4px;font-size:12px;color:#1565C0;margin-bottom:14px;line-height:1.7">
      <strong>&#128161; What to tell the owner panel developer:</strong><br>
      <span id="grant-uid-devmsg"></span>
    </div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-grant-uid')" class="sa-btn sa-btn-n">Cancel</button>
      <button onclick="copySetupGuide()" class="sa-btn" style="background:#1565C0;color:#fff">&#128203; Copy Setup Guide</button>
      <button id="grant-uid-btn" onclick="confirmGrantUid()" class="sa-btn sa-btn-approve" disabled>&#10003; Grant Access</button>
    </div>
  </div>
</div>

<div class="modal-overlay" id="modal-direct">
  <div class="modal-box" style="max-width:560px">
    <h3>&#128640; Direct Company Onboarding</h3>
    <div style="background:#E8F5E9;border-left:4px solid #2E7D32;padding:10px 14px;border-radius:4px;font-size:12.5px;color:#1B5E20;margin-bottom:16px">
      A unique Company ID is auto-generated, a Firebase login is created automatically, and the company gets immediate owner panel access.
    </div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
      <div class="modal-field" style="grid-column:span 2">
        <label>Company Name <span style="color:#C62828">*</span></label>
        <input type="text" id="do-name" placeholder="e.g. CityTaxi Auckland"/>
      </div>
      <div class="modal-field">
        <label>Admin / Login Email <span style="color:#C62828">*</span></label>
        <input type="email" id="do-email" placeholder="owner@company.com"/>
      </div>
      <div class="modal-field">
        <label>Contact Phone</label>
        <input type="text" id="do-phone" placeholder="+64 21 000 000"/>
      </div>
      <div class="modal-field">
        <label>City / Area</label>
        <input type="text" id="do-city" placeholder="e.g. Auckland"/>
      </div>
      <div class="modal-field">
        <label>Country</label>
        <input type="text" id="do-country" value="New Zealand"/>
      </div>
      <div class="modal-field">
        <label>Contact Name</label>
        <input type="text" id="do-contact" placeholder="e.g. John Smith"/>
      </div>
      <div class="modal-field">
        <label>Plan (optional)</label>
        <input type="text" id="do-plan" placeholder="e.g. Professional"/>
      </div>
      <div class="modal-field" style="grid-column:span 2">
        <label>Internal Notes</label>
        <textarea id="do-notes" rows="2" placeholder="e.g. Referred by council, 3-month trial agreed"></textarea>
      </div>
    </div>
    <div id="do-msg" style="font-size:12.5px;margin-top:8px;padding:8px 12px;border-radius:4px;display:none"></div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-direct')" class="sa-btn sa-btn-n">Cancel</button>
      <button onclick="submitDirectOnboard()" id="do-submit" class="sa-btn" style="background:#2E7D32;color:#fff">&#128640; Create &amp; Onboard</button>
    </div>
  </div>
</div>

<div class="modal-overlay" id="modal-credentials">
  <div class="modal-box" style="max-width:460px">
    <h3>&#127881; Company Onboarded!</h3>
    <div style="background:#E8F5E9;border-left:4px solid #2E7D32;padding:10px 14px;border-radius:4px;font-size:13px;color:#1B5E20;margin-bottom:16px">
      The company is now live. A welcome email with login details has been automatically sent to the owner. You can also copy and share the credentials below as a backup.
    </div>
    <div style="display:flex;flex-direction:column;gap:10px;margin-bottom:18px">
      <div style="background:#F8F9FA;border:1px solid #E3F2FD;border-radius:6px;padding:13px 16px">
        <div style="font-size:11px;color:#aaa;text-transform:uppercase;font-weight:700;letter-spacing:.5px;margin-bottom:5px">Company ID</div>
        <div id="cred-cid" style="font-size:22px;font-weight:700;color:#1565C0;font-family:monospace"></div>
      </div>
      <div style="background:#F8F9FA;border:1px solid #E0E0E0;border-radius:6px;padding:13px 16px">
        <div style="font-size:11px;color:#aaa;text-transform:uppercase;font-weight:700;letter-spacing:.5px;margin-bottom:5px">Login Email</div>
        <div id="cred-email" style="font-size:14px;font-weight:600;color:#263238;overflow-wrap:break-word;word-break:break-word"></div>
      </div>
      <div id="cred-pwd-row" style="background:#FFF8E1;border:1px solid #FFE082;border-radius:6px;padding:13px 16px">
        <div style="font-size:11px;color:#E65100;text-transform:uppercase;font-weight:700;letter-spacing:.5px;margin-bottom:5px">&#9888; Temporary Password</div>
        <div id="cred-pwd" style="font-size:18px;font-weight:700;color:#E65100;font-family:monospace;letter-spacing:1px"></div>
        <div style="font-size:11px;color:#888;margin-top:5px">The owner should change this after first login.</div>
      </div>
    </div>
    <button onclick="copyAllCredentials()" class="sa-btn" style="background:#1565C0;color:#fff;width:100%;justify-content:center;margin-bottom:10px;font-size:13px">&#128203; Copy All Login Details</button>
    <div class="modal-actions" style="justify-content:center">
      <button onclick="closeModal('modal-credentials')" class="sa-btn sa-btn-n">Done</button>
    </div>
  </div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allRequests = {};   // keyed by registration id
var allPackages = {};
var fbAccessMap = {};  // Firebase adminAccess snapshot: {companyId: {uid: true, ...}}
var curTab = 'pending';
var activeReqId = null;
var pollTimer = null;
var activeExtendId = null, activeExtendCid = null;

var LIVE_STATUSES = ['trial','active','grace','deactivated'];

function escHtml(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function _getSaEmail(){ try{ return (firebase.auth().currentUser||{}).email||'sa-admin'; }catch(e){ return 'sa-admin'; } }
function fmtDate(ts){ return ts?new Date(ts).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}):'—'; }
function fmtDateShort(ts){ return ts?new Date(ts).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'}):'—'; }

var curType='all';

function setTab(tab){
  curTab=tab;
  ['pending','approved','rejected','all'].forEach(function(t){
    document.getElementById('tab-'+t).classList.remove('active');
  });
  document.getElementById('tab-'+tab).classList.add('active');
  renderRequests();
}

function setType(type){
  curType=type;
  ['all','taxi','towing'].forEach(function(t){
    var btn=document.getElementById('type-'+t);
    if(btn){ btn.classList.remove('active'); btn.style.background=''; btn.style.color=''; btn.style.borderColor=''; }
  });
  var active=document.getElementById('type-'+type);
  if(active){
    if(type==='towing'){ active.style.background='#E65100'; active.style.color='#fff'; active.style.borderColor='#E65100'; }
    else { active.classList.add('active'); }
  }
  renderRequests();
}

function statusBadge(status){
  var map={
    pending:'<span class="bx bx-pending">Pending</span>',
    trial:'<span class="bx" style="background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB">Trial</span>',
    active:'<span class="bx bx-approved">Active</span>',
    grace:'<span class="bx" style="background:#FFF3E0;color:#E65100;border:1px solid #FFCC80">Grace Period</span>',
    deactivated:'<span class="bx" style="background:#F5F5F5;color:#757575;border:1px solid #E0E0E0">Deactivated</span>',
    rejected:'<span class="bx bx-rejected">Rejected</span>'
  };
  return map[status]||'<span class="bx">'+escHtml(status)+'</span>';
}

function cardClass(status){
  if(status==='pending') return 'pending';
  if(status==='trial'||status==='active') return 'approved';
  if(status==='grace') return 'pending';
  if(status==='deactivated'||status==='rejected') return 'rejected';
  return '';
}

function accessBadge(r){
  if(!r.companyId || LIVE_STATUSES.indexOf(r.status)===-1 || r.status==='deactivated') return '';
  var cid=String(r.companyId);
  var entry=fbAccessMap[cid]||null;
  var uids=entry?Object.keys(entry).filter(function(k){return entry[k]===true;}):[];
  if(uids.length>0){
    return '<span style="display:inline-flex;align-items:center;gap:4px;background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7;border-radius:12px;padding:2px 10px;font-size:11.5px;font-weight:600;margin-left:6px">&#128275; Panel Access Granted</span>';
  } else {
    return '<span style="display:inline-flex;align-items:center;gap:4px;background:#FFF3E0;color:#E65100;border:1px solid #FFCC80;border-radius:12px;padding:2px 10px;font-size:11.5px;font-weight:600;margin-left:6px" title="Owner cannot log in — click Grant Panel Access">&#9888; No Panel Access</span>';
  }
}

function renderRequests(){
  var filtered = Object.values(allRequests).filter(function(r){
    // Service type filter
    var svcType = r.serviceType || 'taxi';
    if(curType !== 'all' && svcType !== curType) return false;
    // Status filter
    if(curTab==='all') return true;
    if(curTab==='approved') return LIVE_STATUSES.indexOf(r.status)!==-1;
    return r.status===curTab;
  }).sort(function(a,b){ return (b.submittedAt||0)-(a.submittedAt||0); });

  var wrap = document.getElementById('requests-wrap');
  if(!filtered.length){
    var msgs={
      pending:'No pending applications. New requests will appear here automatically.',
      approved:'No approved companies yet.',
      rejected:'No rejected applications.',
      all:'No applications received yet. Share the link above to invite companies.'
    };
    wrap.innerHTML='<div style="text-align:center;padding:40px;color:#aaa">'+msgs[curTab]+'</div>';
    return;
  }

  var html='';
  filtered.forEach(function(r){
    var id=r.id;
    var trialInfo='';
    if(r.status==='trial'&&r.trialEnd){
      trialInfo='<div style="margin-top:6px;font-size:12px;color:#1565C0">&#9202; Trial ends '+fmtDateShort(r.trialEnd)+'</div>';
    } else if(r.status==='grace'&&r.graceEnd){
      trialInfo='<div style="margin-top:6px;font-size:12px;color:#E65100">&#9888; Grace period ends '+fmtDateShort(r.graceEnd)+'</div>';
    } else if(r.status==='active'&&r.companyId){
      trialInfo='<div style="margin-top:6px;font-size:12px;color:#2E7D32">&#10003; Active &mdash; Company ID <strong>'+escHtml(String(r.companyId))+'</strong></div>';
    } else if(r.status==='rejected'){
      trialInfo='<div style="margin-top:6px;font-size:12px;color:#C62828">&#10007; Rejected</div>';
    } else if(r.companyId){
      trialInfo='<div style="margin-top:6px;font-size:12px;color:#555">Company ID: <strong>'+escHtml(String(r.companyId))+'</strong></div>';
    }
    var isTowing = (r.serviceType||'taxi') === 'towing';
    var cardBorderStyle = isTowing ? 'style="border-left-color:#E65100"' : '';
    html+='<div class="req-card '+escHtml(cardClass(r.status))+'" id="rc-'+escHtml(id)+'" '+cardBorderStyle+'>';
    var srcBadge = r._source==='firebase' ? '<span style="display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB;margin-left:6px">&#127760; Website</span>' : '';
    var towingBadge = isTowing ? '<span style="display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#FFF3E0;color:#E65100;border:1px solid #FFCC80;margin-left:6px">&#128667; Towing Operator</span>' : '';
    html+='<div class="req-card-hdr" onclick="toggleCard(\''+escHtml(id)+'\')">'+
      '<div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap">'+
        '<div>'+
          '<div style="font-weight:700;font-size:14px">'+escHtml(r.company||'Unnamed Company')+srcBadge+towingBadge+'</div>'+
          '<div style="font-size:12px;color:#888">'+escHtml(r.area||'')+(r.area&&r.country?', ':'')+escHtml(r.country||'')+'&nbsp;&nbsp;&bull;&nbsp;&nbsp;'+escHtml(r.name||'')+'&nbsp;&nbsp;&bull;&nbsp;&nbsp;'+escHtml(r.email||'')+'</div>'+
          trialInfo+
        '</div>'+
      '</div>'+
      '<div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">'+statusBadge(r.status)+(isTowing?'':accessBadge(r))+'<span style="font-size:11.5px;color:#aaa">'+fmtDate(r.submittedAt)+'</span><span style="color:#aaa;font-size:18px">&#8964;</span></div>'+
    '</div>';
    html+='<div class="req-card-body" id="rcb-'+escHtml(id)+'">';
    html+='<div class="req-grid">';
    html+='<div class="req-field"><label>Company Name</label><span>'+escHtml(r.company||'—')+'</span></div>';
    html+='<div class="req-field"><label>Area / City</label><span>'+escHtml(r.area||'—')+'</span></div>';
    html+='<div class="req-field"><label>Country</label><span>'+escHtml(r.country||'—')+'</span></div>';
    html+='<div class="req-field"><label>Business Number</label><span>'+escHtml(r.businessNumber||'—')+'</span></div>';
    if(isTowing){
      html+='<div class="req-field"><label>Tow Trucks</label><span>'+escHtml(r.towingFleetSize||r.fleetSize||'—')+'</span></div>';
      if(r.truckTypes) html+='<div class="req-field"><label>Truck Types</label><span>'+escHtml(r.truckTypes)+'</span></div>';
      if(r.operatingHours) html+='<div class="req-field"><label>Operating Hours</label><span>'+escHtml(r.operatingHours)+'</span></div>';
      if(r.afterHours!==undefined) html+='<div class="req-field"><label>After-Hours</label><span>'+(r.afterHours?'&#10003; Yes':'&#10007; No')+'</span></div>';
    } else {
      html+='<div class="req-field"><label>Fleet Size</label><span>'+escHtml(r.fleetSize||'—')+'</span></div>';
    }
    html+='<div class="req-field"><label>Contact Name</label><span>'+escHtml(r.name||'—')+'</span></div>';
    html+='<div class="req-field"><label>Email</label><span><a href="mailto:'+escHtml(r.email||'')+'" style="color:#1565C0">'+escHtml(r.email||'—')+'</a></span></div>';
    html+='<div class="req-field"><label>Phone</label><span>'+escHtml(r.phone||'—')+'</span></div>';
    if(r.message) html+='<div class="req-field" style="grid-column:1/-1"><label>Message</label><span>'+escHtml(r.message)+'</span></div>';
    if(!isTowing){
      if(r.companyId) html+='<div class="req-field"><label>Company ID</label><span style="font-weight:700;font-size:15px;color:#1565C0">'+escHtml(String(r.companyId))+'</span></div>';
      if(r.trialStart) html+='<div class="req-field"><label>Trial Start</label><span>'+fmtDateShort(r.trialStart)+'</span></div>';
      if(r.trialEnd) html+='<div class="req-field"><label>Trial End</label><span>'+fmtDateShort(r.trialEnd)+'</span></div>';
    }
    html+='<div class="req-field"><label>Reference</label><span style="font-family:monospace;font-size:12px">'+escHtml(id)+'</span></div>';
    html+='</div>';
    html+='<div class="req-actions">';
    if(isTowing){
      // Towing operators — different flow: no trial, SA sets up portal access in SA-Towing
      if(r.status==='pending'){
        html+='<a href="SA-Towing.aspx" class="sa-btn sa-btn-p" style="background:#E65100;border-color:#E65100">&#128667; Set Up Towing Portal</a>';
        html+='<button onclick="openReject(\''+escHtml(id)+'\')" class="sa-btn sa-btn-reject">&#10007; Reject</button>';
      } else if(r.status==='rejected'){
        html+='<a href="SA-Towing.aspx" class="sa-btn sa-btn-view">&#128667; Review in Towing Module</a>';
      } else {
        html+='<a href="SA-Towing.aspx" class="sa-btn sa-btn-view">&#128667; Manage in Towing Module</a>';
      }
    } else if(r.status==='pending'){
      html+='<button onclick="openApprove(\''+escHtml(id)+'\')" class="sa-btn sa-btn-approve">&#10003; Approve &amp; Start Trial</button>';
      html+='<button onclick="openReject(\''+escHtml(id)+'\')" class="sa-btn sa-btn-reject">&#10007; Reject</button>';
    } else if(r.status==='trial'||r.status==='grace'){
      html+='<button onclick="activateCompany(\''+escHtml(id)+'\')" class="sa-btn sa-btn-approve">&#9733; Mark as Paid / Active</button>';
      if(r.companyId) html+='<button onclick="window.location.href=\'SA-Billing.aspx?cid='+escHtml(String(r.companyId))+'\'" class="sa-btn sa-btn-view">&#128203; Billing</button>';
      html+='<button onclick="openExtendTrial(\''+escHtml(id)+'\',\''+escHtml(String(r.companyId||''))+'\',\''+escHtml(String(r.trialEnd||''))+'\')" class="sa-btn" style="background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB">&#128197; Extend Trial</button>';
      html+='<button onclick="grantAccess(\''+escHtml(id)+'\')" class="sa-btn" style="background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7">&#128273; Grant Panel Access</button>';
      html+='<button onclick="openDeactivate(\''+escHtml(id)+'\')" class="sa-btn sa-btn-reject">&#10007; Deactivate</button>';
    } else if(r.status==='active'){
      if(r.companyId) html+='<button onclick="window.location.href=\'SA-Billing.aspx?cid='+escHtml(String(r.companyId))+'\'" class="sa-btn sa-btn-view">&#128203; Billing</button>';
      if(r.companyId) html+='<button onclick="window.location.href=\'SA-Clients.aspx\'" class="sa-btn sa-btn-view">&#127970; All Companies</button>';
      html+='<button onclick="grantAccess(\''+escHtml(id)+'\')" class="sa-btn" style="background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7">&#128273; Grant Panel Access</button>';
      html+='<button onclick="openDeactivate(\''+escHtml(id)+'\')" class="sa-btn sa-btn-reject">&#10007; Deactivate</button>';
    } else if(r.status==='deactivated'){
      html+='<button onclick="activateCompany(\''+escHtml(id)+'\')" class="sa-btn sa-btn-approve">&#9654; Re-activate</button>';
    }
    html+='</div></div></div>';
  });
  wrap.innerHTML=html;
}

function toggleCard(id){
  var body=document.getElementById('rcb-'+id);
  if(body) body.classList.toggle('open');
}

function openApprove(id){
  activeReqId=id;
  var r=allRequests[id]||{};
  document.getElementById('approve-summary').innerHTML='<strong>'+escHtml(r.company||'Company')+'</strong><br>'+escHtml(r.name||'')+' &mdash; '+escHtml(r.email||'')+'<br>'+escHtml(r.area||'')+(r.area&&r.country?', ':'')+escHtml(r.country||'');
  document.getElementById('approve-note').value='';

  // Auto-lookup Firebase UID by email
  var uidInput = document.getElementById('approve-uid');
  var uidHint = uidInput ? uidInput.nextElementSibling : null;
  uidInput.value = '';
  if(uidHint) uidHint.textContent = 'Looking up Firebase UID\u2026';
  if(r.email){
    fetch('/api/admin/lookup-uid?email='+encodeURIComponent(r.email))
      .then(function(res){return res.json();})
      .then(function(data){
        if(data.uid){
          uidInput.value = data.uid;
          if(uidHint) uidHint.textContent = '\u2713 Auto-detected ('+data.uid.length+' chars) — edit if incorrect';
          if(uidHint) uidHint.style.color='#2E7D32';
        } else {
          if(uidHint) uidHint.textContent = 'No Firebase account yet — will be auto-created on approval, or paste UID manually.';
          if(uidHint) uidHint.style.color='#888';
        }
      })
      .catch(function(){
        if(uidHint) uidHint.textContent = 'Lookup failed — paste UID manually if needed.';
        if(uidHint) uidHint.style.color='#E65100';
      });
  } else {
    if(uidHint){ uidHint.textContent='No email on record — paste UID manually.'; uidHint.style.color='#888'; }
  }

  var previewLink = document.getElementById('approve-preview-link');
  if(previewLink && r.email){
    var qs = '?name='+encodeURIComponent(r.company||'Company')+'&email='+encodeURIComponent(r.email)+'&cid=AUTO';
    previewLink.href = '/api/admin/welcome-email-preview'+qs;
    previewLink.style.display = '';
  } else if(previewLink){
    previewLink.style.display = 'none';
  }
  document.getElementById('modal-approve').classList.add('open');
}

function openReject(id){
  activeReqId=id;
  var r=allRequests[id]||{};
  document.getElementById('reject-summary').innerHTML='<strong>'+escHtml(r.company||'Company')+'</strong><br>'+escHtml(r.name||'')+' &mdash; '+escHtml(r.email||'');
  document.getElementById('reject-reason').value='';
  document.getElementById('reject-note').value='';
  document.getElementById('modal-reject').classList.add('open');
}

function openDeactivate(id){
  if(!confirm('Deactivate this company? They will immediately lose access to the owner panel.')) return;
  var r=allRequests[id]||{};
  var saEmail = _getSaEmail();
  fetch('/api/admin/registrations/'+encodeURIComponent(id)+'/deactivate',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({companyId: r.companyId ? String(r.companyId) : null, _saEmail: saEmail})
  }).then(function(r){return r.json();}).then(function(data){
    if(data.error){ toastr.error('Error: '+data.error); return; }
    toastr.warning('Company deactivated — owner panel access revoked');
    loadRegistrations();
  }).catch(function(){ toastr.error('Network error'); });
}

function closeModal(id){ document.getElementById(id).classList.remove('open'); }

function confirmApprove(){
  var pkg=document.getElementById('approve-pkg').value;
  var manualUid=(document.getElementById('approve-uid').value||'').trim();
  var note=(document.getElementById('approve-note').value||'').trim();
  if(!activeReqId) return;
  var r=allRequests[activeReqId]||{};
  var btn=document.querySelector('#modal-approve .sa-btn-approve');
  btn.disabled=true; btn.textContent='Approving…';
  var saEmail = _getSaEmail();

  // Firebase website registrations — use direct onboard (no admin API record exists)
  if(r._source==='firebase'){
    fetch('/api/admin/direct-onboard',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body:JSON.stringify({
        name:r.company||'', email:r.email||'', city:r.area||'', country:r.country||'',
        contactName:r.name||'', phone:r.phone||'', plan:pkg||'', notes:note||'',
        _saEmail:saEmail
      })
    }).then(function(res){return res.json();}).then(function(data){
      btn.disabled=false; btn.textContent='✓ Confirm & Start Trial';
      if(data.error){ toastr.error('Approval failed: '+data.error); return; }
      db.ref('onboardRequests/'+activeReqId).update({status:'trial', approvedAt:Date.now(), companyId:data.cid})
        .catch(function(e){ console.warn('[onboard] Firebase status sync failed for '+activeReqId+':', e.message); });
      closeModal('modal-approve');
      setTab('trial');
      if(data.needsManualAccess){
        toastr.warning((r.company||'Company')+' approved (ID: '+data.cid+') — grant portal access by entering the owner\'s Firebase UID below.', null, {timeOut:8000});
        loadRegistrations();
        setTimeout(function(){ promptManualUid(activeReqId); }, 600);
      } else {
        toastr.success((r.company||'Company')+' approved — 10-day trial started (ID: '+data.cid+')');
        if(data.autoCreated&&data.tempPassword){
          showCredentials({cid:data.cid, email:r.email||'', tempPassword:data.tempPassword, autoCreated:true});
        }
        loadRegistrations();
      }
    }).catch(function(){ btn.disabled=false; btn.textContent='✓ Confirm & Start Trial'; toastr.error('Network error'); });
    return;
  }

  // Standard admin API path for existing admin API registrations
  var knownUid = r.uid || manualUid || '';
  fetch('/api/admin/registrations/'+encodeURIComponent(activeReqId)+'/approve',{
    method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({email: r.email||'', uid: knownUid, _saEmail: saEmail})
  }).then(function(res){return res.json();}).then(function(data){
    btn.disabled=false; btn.textContent='✓ Confirm & Start Trial';
    if(data.error){ toastr.error('Approval failed: '+data.error); return; }
    var reg = data.registration || data;
    var cid = reg.companyId ? String(reg.companyId) : null;
    closeModal('modal-approve');
    toastr.success((r.company||'Company')+' approved — 10-day trial started'+(cid?' (ID: '+cid+')':''));
    if(data.autoCreated && data.tempPassword){
      showCredentials({cid: cid, email: r.email||'', tempPassword: data.tempPassword, autoCreated: true});
    } else if(data.accessGranted){
      toastr.success('Owner panel access granted to '+escHtml(r.email||''));
    } else if(data.uidWarning){
      toastr.warning('Login account not yet set up for '+escHtml(r.email||'')+' — use "Grant Panel Access" once they sign up.');
    }
    if(cid){
      var now=Date.now();
      var companyData={
        name:r.company||'',area:r.area||'',country:r.country||'',
        contactName:r.name||'',email:r.email||'',phone:r.phone||'',
        status:'trial',createdAt:now,onboardedFrom:activeReqId,note:note,
        trialEnd:reg.trialEnd||null
      };
      db.ref('superClients/'+cid).set(companyData).then(function(){
        if(!pkg) return;
        var pkgData=allPackages[pkg]||{};
        return updateCompanyPlan(cid,{
          packageId:pkg,
          packageName:pkgData.name||pkg,
          packageMeta:pkgData,
          status:'trial',
          billingStartDate:new Date(now).toISOString().slice(0,10),
          trialEnd:reg.trialEnd||null,
          clearTrial:false
        });
      });
    }
    loadRegistrations();
  }).catch(function(){ btn.disabled=false; btn.textContent='✓ Confirm & Start Trial'; toastr.error('Network error'); });
}

/* ── Direct Onboard ── */
function openDirectOnboard(){
  ['do-name','do-email','do-phone','do-city','do-contact','do-plan','do-notes'].forEach(function(id){ document.getElementById(id).value=''; });
  document.getElementById('do-country').value='New Zealand';
  var msg=document.getElementById('do-msg'); msg.style.display='none'; msg.textContent='';
  var btn=document.getElementById('do-submit'); btn.disabled=false; btn.textContent='\uD83D\uDE80 Create & Onboard';
  document.getElementById('modal-direct').classList.add('open');
}

function submitDirectOnboard(){
  var name=(document.getElementById('do-name').value||'').trim();
  var email=(document.getElementById('do-email').value||'').trim();
  var city=(document.getElementById('do-city').value||'').trim();
  var country=(document.getElementById('do-country').value||'').trim();
  var contactName=(document.getElementById('do-contact').value||'').trim();
  var phone=(document.getElementById('do-phone').value||'').trim();
  var plan=(document.getElementById('do-plan').value||'').trim();
  var notes=(document.getElementById('do-notes').value||'').trim();
  if(!name||!email){ showDirectMsg('Company name and email are required','err'); return; }
  if(!/.+@.+\..+/.test(email)){ showDirectMsg('Enter a valid email address','err'); return; }
  var btn=document.getElementById('do-submit');
  btn.disabled=true; btn.textContent='Creating\u2026';
  var saEmail = _getSaEmail();
  fetch('/api/admin/direct-onboard',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({name:name,email:email,city:city,country:country,contactName:contactName,phone:phone,plan:plan,notes:notes,_saEmail:saEmail})
  }).then(function(r){return r.json();}).then(function(data){
    btn.disabled=false; btn.textContent='\uD83D\uDE80 Create & Onboard';
    if(data.error){ showDirectMsg('Error: '+data.error,'err'); return; }
    closeModal('modal-direct');
    showCredentials({cid:data.cid,email:data.email,tempPassword:data.tempPassword,autoCreated:data.autoCreated});
    toastr.success((data.name||'Company')+' onboarded — Company ID: '+data.cid);
  }).catch(function(){ btn.disabled=false; btn.textContent='\uD83D\uDE80 Create & Onboard'; showDirectMsg('Network error — try again','err'); });
}

function showDirectMsg(msg,type){
  var el=document.getElementById('do-msg');
  el.style.background=type==='err'?'#FFEBEE':'#E8F5E9';
  el.style.color=type==='err'?'#C62828':'#1B5E20';
  el.textContent=msg; el.style.display='block';
}

function showCredentials(creds){
  document.getElementById('cred-cid').textContent=creds.cid||'—';
  document.getElementById('cred-email').textContent=creds.email||'—';
  var pwdRow=document.getElementById('cred-pwd-row');
  if(creds.tempPassword&&creds.autoCreated){
    document.getElementById('cred-pwd').textContent=creds.tempPassword;
    pwdRow.style.display='block';
  } else {
    pwdRow.style.display='none';
  }
  document.getElementById('modal-credentials').classList.add('open');
}

function copyAllCredentials(){
  var cid=document.getElementById('cred-cid').textContent;
  var email=document.getElementById('cred-email').textContent;
  var pwd=document.getElementById('cred-pwd').textContent;
  var text='BookaWaka Owner Panel Login Details\n\nCompany ID: '+cid+'\nLogin Email: '+email+(pwd?'\nTemporary Password: '+pwd:'')+'\n\nPlease log in and change your password after first sign-in.';
  navigator.clipboard.writeText(text).then(function(){
    toastr.success('Login details copied to clipboard');
  }).catch(function(){
    var ta=document.createElement('textarea'); ta.value=text;
    document.body.appendChild(ta); ta.select(); document.execCommand('copy'); document.body.removeChild(ta);
    toastr.success('Copied!');
  });
}

function confirmReject(){
  var reason=document.getElementById('reject-reason').value;
  var note=(document.getElementById('reject-note').value||'').trim();
  if(!reason){ toastr.warning('Please select a rejection reason'); return; }
  if(!activeReqId) return;
  var reviewNote=reason+(note?' — '+note:'');
  var saEmail = _getSaEmail();
  var r2 = allRequests[activeReqId] || {};
  var sendEmail = document.getElementById('reject-send-email').checked;

  function afterReject(){
    closeModal('modal-reject');
    toastr.info('Application rejected');
    loadRegistrations();
    if(sendEmail && r2.email){
      var emailBody = 'Dear '+(r2.name||r2.company||'Applicant')+',\n\nThank you for your interest in joining BookaWaka.\n\nAfter reviewing your application, we are unfortunately unable to proceed at this time.\n\nReason: '+reviewNote+'\n\nIf you believe this decision is in error or would like to discuss your application, please contact us at support@bookawaka.co.nz.\n\nKind regards,\nBookaWaka Team';
      fetch('/api/send-company-email',{
        method:'POST', headers:{'Content-Type':'application/json'},
        body:JSON.stringify({toEmail:r2.email, companyName:r2.company||r2.name||r2.email, subject:'Your BookaWaka application — update', body:emailBody})
      }).then(function(er){ return er.json(); }).then(function(ed){
        if(ed.ok) toastr.success('Rejection email sent to '+r2.email);
        else toastr.warning('Rejection recorded, but email failed: '+(ed.error||'unknown'));
      }).catch(function(){ toastr.warning('Rejection recorded but email could not be sent'); });
    }
  }

  // Firebase website registrations — update status directly in Firebase
  if(r2._source==='firebase'){
    db.ref('onboardRequests/'+activeReqId).update({status:'rejected', rejectedAt:Date.now(), rejectionNote:reviewNote})
      .then(afterReject)
      .catch(function(){ toastr.error('Firebase error — could not save rejection'); });
    return;
  }

  // Standard admin API path
  fetch('/api/admin/registrations/'+encodeURIComponent(activeReqId)+'/reject',{
    method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({reason:reviewNote, _saEmail:saEmail})
  }).then(function(r){return r.json();}).then(function(data){
    if(data.error){ toastr.error('Error: '+data.error); return; }
    afterReject();
  }).catch(function(){ toastr.error('Network error'); });
}

function grantAccess(id){
  var r=allRequests[id]||{};
  if(!r.companyId){ toastr.warning('No Company ID — cannot grant access'); return; }
  var saEmail = _getSaEmail();
  // If UID already stored, grant directly
  if(r.uid){
    fetch('/api/admin/grant-access-uid',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body:JSON.stringify({uid: r.uid, companyId: String(r.companyId), _saEmail: saEmail})
    }).then(function(res){return res.json();}).then(function(data){
      if(data.success){ toastr.success('Owner panel access granted to '+escHtml(r.email||r.company||'')); loadRegistrations(); }
      else { toastr.error('Failed: '+(data.error||'unknown error')); }
    }).catch(function(){ toastr.error('Network error'); });
    return;
  }
  // No UID stored — go straight to manual entry (server-side lookup not available without Admin SDK)
  promptManualUid(id);
}

var _grantUidReqId = null;

function promptManualUid(id){
  var r=allRequests[id]||{};
  _grantUidReqId = id;
  document.getElementById('grant-uid-input').value='';
  document.getElementById('grant-uid-btn').disabled=true;
  document.getElementById('grant-uid-hint').style.color='#aaa';
  document.getElementById('grant-uid-summary').textContent=(r.company||'')+(r.email?' — '+r.email:'')+(r.companyId?' (Company ID: '+r.companyId+')':'');
  document.getElementById('grant-uid-devmsg').innerHTML=buildSetupMsg(r);
  document.getElementById('modal-grant-uid').classList.add('open');
}

function buildSetupMsg(r){
  var cid=r.companyId||'?';
  return 'Your company has been approved on BookaWaka.<br>'+
    'To enable login for your owner panel, your app must check this Firebase path after sign-in:<br>'+
    '<code style="background:#fff;padding:2px 6px;border-radius:3px;font-family:monospace">adminAccess/'+escHtml(String(cid))+'/{userUID}</code><br>'+
    'If the value is <code style="background:#fff;padding:2px 6px;border-radius:3px;font-family:monospace">true</code>, the user is authorised. '+
    'Firebase DB URL: <code style="background:#fff;padding:2px 6px;border-radius:3px;font-family:monospace">https://taxilatest.firebaseio.com</code>';
}

function buildSetupMsgPlain(r){
  var cid=r.companyId||'?';
  return 'Your company has been approved on BookaWaka (Company ID: '+cid+').\n\n'+
    'To enable login for your owner panel, check this Firebase Realtime Database path after the user signs in:\n\n'+
    '  adminAccess/'+cid+'/{userUID}\n\n'+
    'If the value is true, the user is authorised to access the panel.\n'+
    'If it is null/false, deny access.\n\n'+
    'Firebase config:\n'+
    '  Project: taxilatest\n'+
    '  DB URL: https://taxilatest.firebaseio.com\n'+
    '  API key: AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA\n'+
    '  Auth domain: taxilatest.firebaseapp.com\n\n'+
    'Example check (Firebase JS SDK v7/v8):\n'+
    "  firebase.database().ref('adminAccess/"+cid+"/' + user.uid).once('value').then(function(snap){\n"+
    '    if(snap.val()===true){ /* allow in */ }\n'+
    '    else{ firebase.auth().signOut(); /* deny */ }\n'+
    '  });';
}

function validateGrantUid(){
  var uid=document.getElementById('grant-uid-input').value.trim();
  var hint=document.getElementById('grant-uid-hint');
  var btn=document.getElementById('grant-uid-btn');
  if(!uid){ hint.textContent='UIDs are 28 characters — letters and numbers only.'; hint.style.color='#aaa'; btn.disabled=true; return; }
  if(uid.length<20){ hint.textContent='Too short — Firebase UIDs are usually 28 characters.'; hint.style.color='#E65100'; btn.disabled=true; return; }
  hint.textContent='Looks good (\u2713 '+uid.length+' characters)'; hint.style.color='#2E7D32'; btn.disabled=false;
}

function confirmGrantUid(){
  if(!_grantUidReqId) return;
  var r=allRequests[_grantUidReqId]||{};
  var uid=document.getElementById('grant-uid-input').value.trim();
  if(!uid||!r.companyId){ toastr.error('UID and Company ID are required'); return; }
  var btn=document.getElementById('grant-uid-btn');
  btn.disabled=true; btn.textContent='Granting\u2026';
  var saEmail2 = _getSaEmail();
  fetch('/api/admin/grant-access-uid',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({uid:uid, companyId:String(r.companyId), _saEmail:saEmail2})
  }).then(function(res){return res.json();}).then(function(data){
    btn.disabled=false; btn.textContent='\u2713 Grant Access';
    if(data.success){
      // For firebase-source records, save the UID back so it persists after reload
      if(r._source==='firebase' && _grantUidReqId){
        db.ref('onboardRequests/'+_grantUidReqId).update({uid:uid})
          .catch(function(e){ console.warn('[grant-uid] Could not save UID to Firebase record:', e.message); });
      }
      closeModal('modal-grant-uid');
      toastr.success('&#128275; Access granted — '+escHtml(r.company||r.email||uid)+' can now log into the owner panel');
      loadRegistrations();
    } else { toastr.error('Failed: '+(data.error||'unknown error')); }
  }).catch(function(){ btn.disabled=false; btn.textContent='\u2713 Grant Access'; toastr.error('Network error'); });
}

function copySetupGuide(){
  var r=_grantUidReqId?allRequests[_grantUidReqId]||{}:{};
  var text=buildSetupMsgPlain(r);
  navigator.clipboard.writeText(text).then(function(){
    toastr.success('Setup guide copied to clipboard — paste it into an email or message to the owner panel developer');
  }).catch(function(){
    var ta=document.createElement('textarea');
    ta.value=text; document.body.appendChild(ta); ta.select();
    document.execCommand('copy'); document.body.removeChild(ta);
    toastr.success('Setup guide copied!');
  });
}

function activateCompany(id){
  if(!confirm('Mark this company as fully paid/active?')) return;
  var r=allRequests[id]||{};
  var saEmail = _getSaEmail();
  fetch('/api/admin/registrations/'+encodeURIComponent(id)+'/activate',{
    method:'POST', headers:{'Content-Type':'application/json'},
    body:JSON.stringify({email: r.email||'', companyId: r.companyId ? String(r.companyId) : null, uid: r.uid||'', _saEmail: saEmail})
  }).then(function(res){return res.json();}).then(function(data){
    if(data.error){ toastr.error('Error: '+data.error); return; }
    toastr.success('Company activated — owner panel access confirmed');
    if(r.companyId) db.ref('superClients/'+r.companyId+'/status').set('active');
    loadRegistrations();
  }).catch(function(){ toastr.error('Network error'); });
}

function updateCounts(){
  var vals=Object.values(allRequests);
  var pending=vals.filter(function(r){return r.status==='pending';}).length;
  var liveCount=vals.filter(function(r){return r.status==='trial'||r.status==='active';}).length;
  var rejected=vals.filter(function(r){return r.status==='rejected';}).length;
  var total=vals.length;
  document.getElementById('cnt-pending').textContent=pending;
  document.getElementById('cnt-approved').textContent=liveCount;
  document.getElementById('cnt-rejected').textContent=rejected;
  document.getElementById('cnt-all').textContent=total;
  var badge=document.getElementById('sb-pending-badge');
  if(pending>0){ badge.textContent=pending; badge.style.display='inline'; }
  else{ badge.style.display='none'; }
}

function copyLink(){
  var inp=document.getElementById('join-link');
  inp.select();
  document.execCommand('copy');
  toastr.success('Link copied to clipboard');
}

function loadPackages(){
  _fbGet('superPackages').then(function(data){
    allPackages=data||{};
    var sel=document.getElementById('approve-pkg');
    sel.innerHTML='<option value="">-- No package assigned yet --</option>';
    Object.entries(allPackages).forEach(function(e){
      var p=e[1];
      if(p.active!==false){
        var opt=document.createElement('option');
        var price = p.monthlyPrice || p.price || p.monthly || p.amount || 0;
        opt.value=e[0]; opt.textContent=p.name+(price?' ($'+price+'/mo)':'');
        sel.appendChild(opt);
      }
    });
  });
}

/* ── Bulk Approve All Pending ─────────────────────── */
function bulkApproveAllPending(){
  var all=Object.entries(allRequests).filter(function(e){
    var s=e[1].status;
    return s==='pending'||s==='new'||s==='grace';
  });
  var apiPending=all.filter(function(e){ return e[1]._source!=='firebase'; });
  var fbPending=all.filter(function(e){ return e[1]._source==='firebase'; });
  if(!all.length){ toastr.warning('No pending applications to approve.'); return; }
  var msg='Approve '+apiPending.length+' pending application'+(apiPending.length!==1?'s':'')+' with default settings?';
  if(fbPending.length) msg+='\n\nNote: '+fbPending.length+' website registration'+(fbPending.length!==1?'s':'')+' must be approved individually (they require direct onboarding).';
  if(!confirm(msg)) return;
  if(!apiPending.length){ toastr.info('No admin API registrations to bulk approve. Approve website registrations individually.'); return; }
  var done=0, failed=0;
  var saEmail=_getSaEmail();
  function next(i){
    if(i>=apiPending.length){
      toastr.success('Bulk approved: '+done+(failed?' | Failed: '+failed:'')+(fbPending.length?' | '+fbPending.length+' website registration'+(fbPending.length!==1?'s':'')+' need individual approval':''));
      loadRegistrations();
      return;
    }
    var id=apiPending[i][0];
    fetch('/api/admin/registrations/'+id+'/approve',{
      method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({package:'',note:'Bulk approved by SA admin',_saEmail:saEmail})
    }).then(function(r){return r.json();}).then(function(d){
      if(d.error||d.ok===false) failed++; else done++;
      next(i+1);
    }).catch(function(){ failed++; next(i+1); });
  }
  next(0);
}

function loadRegistrations(){
  Promise.all([
    fetch('/api/admin/registrations').then(function(r){ return r.json(); }),
    _fbGet('adminAccess').then(function(v){ return v||{}; }).catch(function(){ return {}; })
  ]).then(function(results){
    var data=results[0], access=results[1];
    fbAccessMap = access;
    allRequests={};
    if(Array.isArray(data)){
      data.forEach(function(reg){ allRequests[reg.id]=reg; });
    }
    updateCounts();
    renderRequests();
  }).catch(function(e){
    console.error('loadRegistrations error:', e);
    document.getElementById('requests-wrap').innerHTML='<div style="text-align:center;padding:40px;color:#C62828">Network error loading registrations.</div>';
  });
}

window._fbOnLogin = function(){
  if (pollTimer) return;
  var joinUrl=window.location.protocol+'//'+window.location.host+'/join';
  document.getElementById('join-link').value=joinUrl;
  document.getElementById('join-link-open').href=joinUrl;
  loadPackages();
  loadRegistrations();
  pollTimer=setInterval(loadRegistrations, 30000);
};

/* ── Extend Trial ─────────────────────────────────── */
function writeOnboardAudit(action, cid, cidName, detail){
  var saEmail=_getSaEmail();
  var ts=Date.now();
  var rand=Math.random().toString(36).slice(2,7).toUpperCase();
  db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:action,actor:saEmail,cid:String(cid||''),cidName:cidName||'',detail:detail||'',ts:ts});
}
function openExtendTrial(id, cid, currentTrialEnd){
  activeExtendId=id; activeExtendCid=cid;
  var r=allRequests[id]||{};
  document.getElementById('ext-company').textContent=(r.company||cid||'Company')+' (ID: '+(cid||'—')+')';
  var cur=currentTrialEnd||(r.trialEnd||'');
  var curMs = typeof cur==='number'?cur:(cur?new Date(cur).getTime():0);
  document.getElementById('ext-current').textContent=curMs?new Date(curMs).toLocaleDateString('en-NZ',{day:'numeric',month:'long',year:'numeric'}):'Not set';
  var minDate=new Date(Date.now()+86400000).toISOString().slice(0,10);
  document.getElementById('ext-new-date').min=minDate;
  document.getElementById('ext-new-date').value=curMs>Date.now()?new Date(curMs+14*86400000).toISOString().slice(0,10):new Date(Date.now()+14*86400000).toISOString().slice(0,10);
  document.getElementById('modal-extend').classList.add('open');
}
function confirmExtendTrial(){
  var newDate=document.getElementById('ext-new-date').value;
  if(!newDate){ toastr.warning('Please select a new trial end date.'); return; }
  if(!activeExtendCid){ toastr.error('No company ID — cannot extend trial.'); return; }
  var newTs=new Date(newDate).getTime();
  var r=allRequests[activeExtendId]||{};
  var btn=document.getElementById('ext-confirm-btn');
  btn.disabled=true; btn.textContent='Saving…';
  _fbGet('superClients/'+activeExtendCid).then(function(){
    return updateCompanyPlan(activeExtendCid,{
      status:'trial',
      trialEnd:newTs,
      clearTrial:false
    });
  }).then(function(){
    writeOnboardAudit('trial_extended', activeExtendCid, r.company||activeExtendCid, 'Trial extended to '+new Date(newDate).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'}));
    if(allRequests[activeExtendId]) allRequests[activeExtendId].trialEnd=newDate;
    closeModal('modal-extend');
    toastr.success('Trial extended to '+new Date(newDate).toLocaleDateString('en-NZ',{day:'numeric',month:'long',year:'numeric'}));
    loadRegistrations();
  }).catch(function(e){ toastr.error('Error: '+e.message); })
    .finally(function(){ btn.disabled=false; btn.textContent='Extend Trial'; });
}
</script>
<div class="modal-overlay" id="modal-extend">
  <div class="modal-box">
    <h3>&#128197; Extend Trial Period</h3>
    <div class="modal-info"><strong id="ext-company"></strong><br>Current trial end: <span id="ext-current" style="font-weight:700"></span></div>
    <div class="modal-field">
      <label>New Trial End Date <span style="color:#C62828">*</span></label>
      <input type="date" id="ext-new-date"/>
    </div>
    <div style="font-size:12px;color:#888;margin-bottom:14px">The company will remain on trial status until this new date. This action is logged in the audit trail.</div>
    <div class="modal-actions">
      <button onclick="closeModal('modal-extend')" class="sa-btn sa-btn-n">Cancel</button>
      <button id="ext-confirm-btn" onclick="confirmExtendTrial()" class="sa-btn sa-btn-approve">Extend Trial</button>
    </div>
  </div>
</div>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
