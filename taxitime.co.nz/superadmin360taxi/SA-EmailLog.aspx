<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Email Sent Log &mdash; BookaWaka Admin</title>
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
.sa-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none;white-space:nowrap}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.badge-sent{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-failed{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.badge-pending{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Email Sent Log &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-EmailLog.aspx" style="font-weight:700;color:#1565C0">&#9658; Email Sent Log</a></li>
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

<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:16px">
  <h2 style="font-size:18px;font-weight:700;color:#263238;margin:0">&#9993; Email Sent Log</h2>
  <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
    <input id="log-search" type="text" placeholder="Search by email, company or subject&hellip;" oninput="renderLog()" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:240px"/>
    <select id="log-status-filter" onchange="renderLog()" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px">
      <option value="">All statuses</option>
      <option value="sent">Sent</option>
      <option value="failed">Failed</option>
    </select>
    <button onclick="loadLog()" class="sa-btn sa-btn-n" style="font-size:12px">&#8635; Refresh</button>
  </div>
</div>

<div class="sa-card">
  <div class="sa-bar"><h3>&#9993; Sent Emails</h3><span id="log-count-label" style="font-size:12px;opacity:.8"></span></div>
  <div id="log-loading" style="padding:30px;text-align:center;color:#aaa;font-size:13px">Loading&hellip;</div>
  <div style="overflow-x:auto">
    <table class="sa-tbl" id="log-tbl" style="display:none">
      <thead>
        <tr>
          <th>Date &amp; Time</th>
          <th>To</th>
          <th>Company</th>
          <th>Subject</th>
          <th>Status</th>
          <th>Resend ID</th>
        </tr>
      </thead>
      <tbody id="log-body"></tbody>
    </table>
  </div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allLogEntries = [];

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDt(ts){
  if(!ts) return '—';
  return new Date(ts).toLocaleString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'});
}

function loadLog(){
  var loading=document.getElementById('log-loading');
  loading.textContent='Loading…';
  loading.style.display='block';
  document.getElementById('log-tbl').style.display='none';

  _fbGet('emailLog').then(function(data){
    data=data||{};
    allLogEntries=Object.values(data).sort(function(a,b){ return (b.sentAt||0)-(a.sentAt||0); });
    loading.style.display='none';
    renderLog();
  }).catch(function(e){
    loading.textContent='Error loading email log: '+String(e.message||e);
    loading.style.color='#C62828';
  });
}

function renderLog(){
  var search=(document.getElementById('log-search').value||'').toLowerCase();
  var statusFilter=document.getElementById('log-status-filter').value;

  var filtered=allLogEntries.filter(function(e){
    if(statusFilter && e.status!==statusFilter) return false;
    if(search){
      var hay=((e.toEmail||'')+(e.companyName||'')+(e.subject||'')).toLowerCase();
      if(hay.indexOf(search)<0) return false;
    }
    return true;
  });

  document.getElementById('log-count-label').textContent=filtered.length+' email'+(filtered.length!==1?'s':'')+(allLogEntries.length!==filtered.length?' (filtered from '+allLogEntries.length+')':'');

  if(!filtered.length){
    document.getElementById('log-tbl').style.display='none';
    var loading=document.getElementById('log-loading');
    loading.textContent=allLogEntries.length?'No emails match your search.':'No emails logged yet.';
    loading.style.display='block';
    loading.style.color='#aaa';
    return;
  }

  var html='';
  filtered.forEach(function(e){
    var badge=e.status==='sent'?'<span class="badge badge-sent">&#10003; Sent</span>'
      :e.status==='failed'?'<span class="badge badge-failed">&#10007; Failed</span>'
      :'<span class="badge badge-pending">Pending</span>';
    var errDetail=e.status==='failed'&&e.error?'<div style="font-size:11px;color:#C62828;margin-top:2px">'+esc(e.error)+'</div>':'';
    html+='<tr>'
      +'<td style="white-space:nowrap;color:#555">'+fmtDt(e.sentAt)+'</td>'
      +'<td><a href="mailto:'+esc(e.toEmail||'')+'" style="color:#1565C0;text-decoration:none">'+esc(e.toEmail||'—')+'</a></td>'
      +'<td style="font-weight:600">'+esc(e.companyName||'—')+(e.companyId?'<div style="font-size:11px;color:#aaa;font-family:monospace">'+esc(e.companyId)+'</div>':'')+'</td>'
      +'<td style="max-width:200px">'+esc(e.subject||'—')+'</td>'
      +'<td>'+badge+errDetail+'</td>'
      +'<td style="font-family:monospace;font-size:11px;color:#aaa">'+esc(e.resendId||'—')+'</td>'
      +'</tr>';
  });
  document.getElementById('log-body').innerHTML=html;
  document.getElementById('log-tbl').style.display='table';
  document.getElementById('log-loading').style.display='none';
}

window._fbOnLogin = function(){ loadLog(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
