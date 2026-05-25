<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Registrations &mdash; BookaWaka Admin</title>
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
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}.sa-btn-s:hover{background:#C8E6C9}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00}
.badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.tab-row{display:flex;gap:2px;padding:0 18px;border-bottom:1px solid #e0e0e0;background:#fafafa}
.tab-btn{padding:10px 16px;border:none;background:none;font-size:13px;font-weight:500;color:#888;cursor:pointer;border-bottom:3px solid transparent;margin-bottom:-1px}
.tab-btn.active{color:#1565C0;border-bottom-color:#1565C0;font-weight:700}
.tab-pane{display:none;padding:16px 18px}
.tab-pane.active{display:block}
.kpi-chips{display:flex;gap:10px;flex-wrap:wrap;padding:14px 18px;border-bottom:1px solid #f5f5f5}
.kpi-chip{border-radius:8px;padding:10px 16px;min-width:90px;text-align:center}
.kpi-n{font-size:22px;font-weight:700}
.kpi-l{font-size:11px;color:#888;margin-top:2px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Registrations &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-EmailLog.aspx">Email Sent Log</a></li>
      <li><a href="SA-Reports.aspx">Revenue Reports</a></li>
      <li><a href="SA-MasterReport.aspx">&#128202; Platform Overview</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="SA-Registrations.aspx" style="font-weight:700;color:#1565C0">&#9658; Registrations</a></li>
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

<h2 style="font-size:18px;font-weight:700;color:#263238;margin:0 0 16px">&#128101; Registrations</h2>
<div id="reg-notice" class="sa-notice"></div>

<div class="sa-card">
  <div class="sa-bar">
    <h3>&#128101; All Registrations</h3>
    <button onclick="loadAll()" class="sa-btn sa-btn-n" style="font-size:12px;color:#fff;border-color:rgba(255,255,255,.3);background:rgba(255,255,255,.15)">&#8635; Refresh</button>
  </div>
  <div class="kpi-chips">
    <div class="kpi-chip" style="background:#FFF3E0"><div class="kpi-n" style="color:#E65100" id="kpi-pending">—</div><div class="kpi-l">Pending</div></div>
    <div class="kpi-chip" style="background:#E8F5E9"><div class="kpi-n" style="color:#2E7D32" id="kpi-approved">—</div><div class="kpi-l">Approved</div></div>
    <div class="kpi-chip" style="background:#FFEBEE"><div class="kpi-n" style="color:#C62828" id="kpi-rejected">—</div><div class="kpi-l">Rejected</div></div>
    <div class="kpi-chip" style="background:#f5f5f5"><div class="kpi-n" style="color:#555" id="kpi-total">—</div><div class="kpi-l">Total</div></div>
  </div>
  <div class="tab-row">
    <button class="tab-btn active" id="tab-btn-pending" onclick="switchTab('pending')">Pending <span id="badge-pending" style="background:#E65100;color:#fff;border-radius:10px;padding:1px 7px;font-size:10px;margin-left:4px"></span></button>
    <button class="tab-btn" id="tab-btn-all" onclick="switchTab('all')">All Registrations</button>
  </div>

  <div class="tab-pane active" id="tab-pending" style="padding:0">
    <div id="pending-loading" style="padding:30px;text-align:center;color:#aaa;font-size:13px">Loading&hellip;</div>
    <div style="overflow-x:auto"><table class="sa-tbl" id="pending-tbl" style="display:none">
      <thead><tr><th>Date</th><th>Type</th><th>Name</th><th>Email</th><th>Phone</th><th>Company</th><th>Actions</th></tr></thead>
      <tbody id="pending-body"></tbody>
    </table></div>
  </div>

  <div class="tab-pane" id="tab-all" style="padding:0">
    <div style="padding:12px 18px;border-bottom:1px solid #f5f5f5;display:flex;gap:8px;align-items:center;flex-wrap:wrap">
      <input id="reg-search" type="text" placeholder="Search name, email, company&hellip;" oninput="renderAll()" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px;width:240px"/>
      <select id="reg-type-filter" onchange="renderAll()" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px">
        <option value="">All types</option>
        <option value="passenger">Passenger</option>
        <option value="driver">Driver</option>
        <option value="company">Company</option>
      </select>
      <select id="reg-status-filter" onchange="renderAll()" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px">
        <option value="">All statuses</option>
        <option value="pending">Pending</option>
        <option value="approved">Approved</option>
        <option value="rejected">Rejected</option>
      </select>
    </div>
    <div id="all-loading" style="padding:30px;text-align:center;color:#aaa;font-size:13px">Loading&hellip;</div>
    <div style="overflow-x:auto"><table class="sa-tbl" id="all-tbl" style="display:none">
      <thead><tr><th>Date</th><th>Type</th><th>Name</th><th>Email</th><th>Phone</th><th>Company</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody id="all-body"></tbody>
    </table></div>
  </div>
</div>

<!-- Reject reason modal -->
<div id="modal-reject" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9999;align-items:center;justify-content:center;padding:20px">
  <div style="background:#fff;border-radius:10px;padding:28px;max-width:420px;width:100%;box-shadow:0 8px 30px rgba(0,0,0,.25)">
    <h3 style="font-size:16px;font-weight:700;color:#C62828;margin-bottom:12px">&#10007; Reject Registration</h3>
    <div id="reject-name" style="font-weight:700;font-size:13px;padding:8px 12px;background:#FFEBEE;border:1px solid #FFCDD2;border-radius:6px;margin-bottom:14px"></div>
    <div style="margin-bottom:16px">
      <label style="display:block;font-size:12px;font-weight:700;color:#374151;margin-bottom:5px">Reason <span style="color:#aaa;font-weight:400">(optional)</span></label>
      <textarea id="reject-reason" rows="3" placeholder="e.g. Incomplete information, duplicate account&hellip;" style="width:100%;padding:10px 12px;border:1.5px solid #FFCDD2;border-radius:8px;font-size:13px;font-family:inherit;box-sizing:border-box;resize:vertical"></textarea>
    </div>
    <div id="reject-msg" style="font-size:12px;color:#C62828;margin-bottom:8px"></div>
    <div style="display:flex;gap:8px;justify-content:flex-end">
      <button onclick="closeRejectModal()" class="sa-btn sa-btn-n">Cancel</button>
      <button id="reject-btn" onclick="confirmReject()" class="sa-btn sa-btn-d" style="font-weight:700">&#10007; Reject</button>
    </div>
  </div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allRegs = [];
var _rejectUid = null;

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDt(ts){ if(!ts) return '—'; return new Date(ts).toLocaleString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}); }

function showNotice(msg, type){
  var el=document.getElementById('reg-notice');
  el.className='sa-notice '+(type||'ok');
  el.textContent=msg;
  el.style.display='block';
  if(type!=='err') setTimeout(function(){ el.style.display='none'; },4000);
}

function switchTab(tab){
  ['pending','all'].forEach(function(t){
    document.getElementById('tab-'+t).className='tab-pane'+(t===tab?' active':'');
    document.getElementById('tab-btn-'+t).className='tab-btn'+(t===tab?' active':'');
  });
}

function loadAll(){
  document.getElementById('pending-loading').style.display='block';
  document.getElementById('all-loading').style.display='block';
  document.getElementById('pending-tbl').style.display='none';
  document.getElementById('all-tbl').style.display='none';
  _fbGet('registrations').then(function(data){
    data=data||{};
    allRegs=Object.entries(data).map(function(e){ return Object.assign({_uid:e[0]},e[1]); })
      .sort(function(a,b){ return (b.createdAt||b.submittedAt||0)-(a.createdAt||a.submittedAt||0); });
    updateKpis();
    renderPending();
    renderAll();
  }).catch(function(e){
    document.getElementById('pending-loading').textContent='Error: '+String(e.message||e);
    document.getElementById('all-loading').textContent='Error: '+String(e.message||e);
  });
}

function updateKpis(){
  var pending=allRegs.filter(function(r){ return r.status==='pending'||!r.status; });
  var approved=allRegs.filter(function(r){ return r.status==='approved'; });
  var rejected=allRegs.filter(function(r){ return r.status==='rejected'; });
  document.getElementById('kpi-pending').textContent=pending.length;
  document.getElementById('kpi-approved').textContent=approved.length;
  document.getElementById('kpi-rejected').textContent=rejected.length;
  document.getElementById('kpi-total').textContent=allRegs.length;
  document.getElementById('badge-pending').textContent=pending.length||'';
  document.getElementById('badge-pending').style.display=pending.length?'inline-block':'none';
}

function renderPending(){
  var loading=document.getElementById('pending-loading');
  var tbl=document.getElementById('pending-tbl');
  var pending=allRegs.filter(function(r){ return r.status==='pending'||!r.status; });
  if(!pending.length){
    loading.textContent='No pending registrations.'; loading.style.display='block'; tbl.style.display='none'; return;
  }
  loading.style.display='none'; tbl.style.display='table';
  document.getElementById('pending-body').innerHTML=pending.map(function(r){ return regRow(r,false); }).join('');
}

function renderAll(){
  var loading=document.getElementById('all-loading');
  var tbl=document.getElementById('all-tbl');
  var search=(document.getElementById('reg-search').value||'').toLowerCase();
  var typeF=document.getElementById('reg-type-filter').value;
  var statusF=document.getElementById('reg-status-filter').value;
  var list=allRegs.filter(function(r){
    if(typeF && (r.type||r.userType||'').toLowerCase()!==typeF) return false;
    var st=r.status||'pending';
    if(statusF && st!==statusF) return false;
    if(search){
      var hay=((r.name||'')+(r.firstName||'')+(r.lastName||'')+(r.email||'')+(r.phone||'')+(r.companyName||r.company||'')).toLowerCase();
      if(hay.indexOf(search)<0) return false;
    }
    return true;
  });
  if(!list.length){
    loading.textContent='No registrations match your filter.'; loading.style.display='block'; tbl.style.display='none'; return;
  }
  loading.style.display='none'; tbl.style.display='table';
  document.getElementById('all-body').innerHTML=list.map(function(r){ return regRow(r,true); }).join('');
}

function regRow(r, showStatus){
  var name=esc((r.name||(r.firstName||'')+(r.firstName&&r.lastName?' ':'')+( r.lastName||''))||'—');
  var type=r.type||r.userType||'—';
  var typeBadge=type==='driver'
    ?'<span style="background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB;border-radius:10px;padding:1px 7px;font-size:11px">Driver</span>'
    :type==='passenger'||type==='user'
    ?'<span style="background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7;border-radius:10px;padding:1px 7px;font-size:11px">Passenger</span>'
    :'<span style="background:#f5f5f5;color:#555;border:1px solid #e0e0e0;border-radius:10px;padding:1px 7px;font-size:11px">'+esc(type)+'</span>';
  var st=r.status||'pending';
  var stBadge=st==='approved'?'<span style="background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7;border-radius:10px;padding:1px 7px;font-size:11px">&#10003; Approved</span>'
    :st==='rejected'?'<span style="background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;border-radius:10px;padding:1px 7px;font-size:11px">&#10007; Rejected</span>'
    :'<span style="background:#FFF3E0;color:#E65100;border:1px solid #FFCC80;border-radius:10px;padding:1px 7px;font-size:11px">Pending</span>';
  var actions=st!=='approved'?'<button class="sa-btn sa-btn-s" style="font-size:10px;margin-right:3px" onclick="approveReg(\''+esc(r._uid)+'\')">&#10003; Approve</button>':'';
  actions+=st!=='rejected'?'<button class="sa-btn sa-btn-d" style="font-size:10px" onclick="openRejectModal(\''+esc(r._uid)+'\',\''+name+'\')">&#10007; Reject</button>':'';
  var ts=r.createdAt||r.submittedAt||r.timestamp||0;
  return '<tr>'
    +'<td style="white-space:nowrap;color:#888;font-size:11px">'+fmtDt(ts)+'</td>'
    +'<td>'+typeBadge+'</td>'
    +'<td style="font-weight:600">'+name+'</td>'
    +'<td style="color:#555;font-size:11px">'+esc(r.email||'—')+'</td>'
    +'<td style="color:#555;font-size:11px">'+esc(r.phone||r.mobileNumber||'—')+'</td>'
    +'<td style="color:#555;font-size:11px">'+esc(r.companyName||r.company||r.companyId||'—')+'</td>'
    +(showStatus?'<td>'+stBadge+'</td>':'')
    +'<td style="white-space:nowrap">'+actions+'</td>'
    +'</tr>';
}

function approveReg(uid){
  if(!confirm('Approve this registration?')) return;
  db.ref('registrations/'+uid).update({status:'approved',approvedAt:Date.now()}).then(function(){
    showNotice('Registration approved.','ok');
    loadAll();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function openRejectModal(uid, name){
  _rejectUid=uid;
  document.getElementById('reject-name').textContent=name;
  document.getElementById('reject-reason').value='';
  document.getElementById('reject-msg').textContent='';
  document.getElementById('reject-btn').disabled=false;
  document.getElementById('modal-reject').style.display='flex';
}
function closeRejectModal(){ document.getElementById('modal-reject').style.display='none'; _rejectUid=null; }
function confirmReject(){
  if(!_rejectUid) return;
  var reason=document.getElementById('reject-reason').value.trim();
  var btn=document.getElementById('reject-btn');
  btn.disabled=true;
  db.ref('registrations/'+_rejectUid).update({status:'rejected',rejectedAt:Date.now(),rejectReason:reason||null}).then(function(){
    closeRejectModal();
    showNotice('Registration rejected.','ok');
    loadAll();
  }).catch(function(e){ document.getElementById('reject-msg').textContent='Error: '+(e.message||e); btn.disabled=false; });
}

window._fbOnLogin = function(){ loadAll(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
