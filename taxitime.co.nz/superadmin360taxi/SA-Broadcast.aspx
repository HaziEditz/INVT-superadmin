<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Broadcast &mdash; BookaWaka Admin</title>
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
.sa-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none;white-space:nowrap}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-ff label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:6px;font-size:13px;box-sizing:border-box;font-family:inherit}
.sa-ff input:focus,.sa-ff select:focus,.sa-ff textarea:focus{outline:none;border-color:#1565C0}
.badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Broadcast &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Registrations.aspx">Registrations</a></li>
      <li><a href="SA-Alerts.aspx">System Alerts</a></li>
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
      <li><a href="SA-Broadcast.aspx" style="font-weight:700;color:#1565C0">&#9658; Broadcast</a></li>
      <li><a href="SA-Sessions.aspx">Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx">Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;color:#263238;margin:0 0 16px">&#128227; Broadcast Messages</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">Send a system-wide message to all company portals. Messages are stored in Firebase and visible inside each company's portal until dismissed or expired.</p>
<div id="bc-notice" class="sa-notice"></div>

<!-- Compose -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#128221; Compose Broadcast</h3></div>
  <div style="padding:18px">
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:14px;margin-bottom:14px">
      <div class="sa-ff">
        <label>Title <span style="color:#C62828">*</span></label>
        <input id="bc-title" type="text" placeholder="e.g. Scheduled maintenance tonight"/>
      </div>
      <div class="sa-ff">
        <label>Type</label>
        <select id="bc-type">
          <option value="info">Info</option>
          <option value="announcement">Announcement</option>
          <option value="maintenance">Maintenance</option>
          <option value="urgent">Urgent</option>
        </select>
      </div>
      <div class="sa-ff">
        <label>Audience</label>
        <select id="bc-audience">
          <option value="all">All companies</option>
          <option value="active">Active only</option>
          <option value="trial">Trial companies only</option>
        </select>
      </div>
      <div class="sa-ff">
        <label>Expires (optional)</label>
        <input id="bc-expires" type="date"/>
      </div>
    </div>
    <div class="sa-ff" style="margin-bottom:16px">
      <label>Message Body <span style="color:#C62828">*</span></label>
      <textarea id="bc-body" rows="3" placeholder="Write the message that all companies will see in their portal&hellip;"></textarea>
    </div>
    <div style="display:flex;gap:8px;align-items:center">
      <button onclick="sendBroadcast()" class="sa-btn sa-btn-p">&#128227; Broadcast Now</button>
      <button onclick="clearForm()" class="sa-btn sa-btn-n">Clear</button>
      <span id="bc-msg" style="font-size:12px;color:#888"></span>
    </div>
  </div>
</div>

<!-- History -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#128203; Broadcast History</h3>
    <button onclick="loadHistory()" class="sa-btn sa-btn-n" style="font-size:12px;background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3)">&#8635; Refresh</button>
  </div>
  <div id="bc-history-loading" style="padding:30px;text-align:center;color:#aaa;font-size:13px">Loading&hellip;</div>
  <div style="overflow-x:auto">
    <table class="sa-tbl" id="bc-history-tbl" style="display:none">
      <thead><tr><th>Sent</th><th>Title</th><th>Type</th><th>Audience</th><th>Expires</th><th>Sent By</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody id="bc-history-body"></tbody>
    </table>
  </div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var BROADCAST_PATH = 'superBroadcast';

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDt(ts){ if(!ts) return '—'; return new Date(ts).toLocaleString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}); }

function showNotice(msg, type){
  var el=document.getElementById('bc-notice');
  el.className='sa-notice '+(type||'ok');
  el.textContent=msg;
  el.style.display='block';
  if(type!=='err') setTimeout(function(){ el.style.display='none'; },4000);
}

var typeConfig={
  info:{icon:'&#8505;',color:'#1565C0',bg:'#E3F2FD'},
  announcement:{icon:'&#128227;',color:'#7B1FA2',bg:'#F3E5F5'},
  maintenance:{icon:'&#9881;',color:'#E65100',bg:'#FFF3E0'},
  urgent:{icon:'&#128680;',color:'#C62828',bg:'#FFEBEE'}
};

function sendBroadcast(){
  var title=(document.getElementById('bc-title').value||'').trim();
  var body=(document.getElementById('bc-body').value||'').trim();
  if(!title||!body){ document.getElementById('bc-msg').textContent='Title and message are required.'; return; }
  var type=document.getElementById('bc-type').value;
  var audience=document.getElementById('bc-audience').value;
  var expires=document.getElementById('bc-expires').value;
  var saEmail=(firebase.auth().currentUser||{}).email||'sa';
  db.ref(BROADCAST_PATH).push({
    title:title, body:body, type:type, audience:audience,
    expires:expires||null,
    sentAt:Date.now(), sentBy:saEmail,
    active:true
  }).then(function(){
    showNotice('Broadcast sent to all company portals.','ok');
    clearForm();
    loadHistory();
  }).catch(function(e){ document.getElementById('bc-msg').textContent='Error: '+e.message; });
}

function clearForm(){
  ['bc-title','bc-body','bc-expires'].forEach(function(id){ document.getElementById(id).value=''; });
  document.getElementById('bc-type').value='info';
  document.getElementById('bc-audience').value='all';
  document.getElementById('bc-msg').textContent='';
}

function loadHistory(){
  document.getElementById('bc-history-loading').style.display='block';
  document.getElementById('bc-history-tbl').style.display='none';
  _fbGet(BROADCAST_PATH).then(function(data){
    data=data||{};
    var items=Object.entries(data).map(function(e){ return Object.assign({_id:e[0]},e[1]); })
      .sort(function(a,b){ return (b.sentAt||0)-(a.sentAt||0); });
    document.getElementById('bc-history-loading').style.display='none';
    if(!items.length){
      document.getElementById('bc-history-loading').textContent='No broadcasts sent yet.';
      document.getElementById('bc-history-loading').style.display='block';
      return;
    }
    var tc=typeConfig;
    document.getElementById('bc-history-body').innerHTML=items.map(function(m){
      var cfg=tc[m.type]||tc.info;
      var typeBadge='<span style="background:'+cfg.bg+';color:'+cfg.color+';border-radius:10px;padding:1px 7px;font-size:11px;font-weight:700">'+cfg.icon+' '+esc(m.type)+'</span>';
      var stBadge=m.active
        ?'<span style="background:#E8F5E9;color:#2E7D32;border-radius:10px;padding:1px 7px;font-size:11px;font-weight:700">Active</span>'
        :'<span style="background:#f5f5f5;color:#aaa;border-radius:10px;padding:1px 7px;font-size:11px">Archived</span>';
      return '<tr>'
        +'<td style="white-space:nowrap;color:#888;font-size:11px">'+fmtDt(m.sentAt)+'</td>'
        +'<td style="font-weight:700;max-width:200px"><div>'+esc(m.title)+'</div><div style="font-size:11px;color:#aaa;font-weight:400;margin-top:2px">'+esc(m.body).substr(0,60)+(m.body&&m.body.length>60?'&hellip;':'')+'</div></td>'
        +'<td>'+typeBadge+'</td>'
        +'<td style="font-size:12px;color:#555">'+esc(m.audience||'all')+'</td>'
        +'<td style="font-size:11px;color:#888">'+esc(m.expires||'—')+'</td>'
        +'<td style="font-size:11px;color:#888">'+esc(m.sentBy||'—')+'</td>'
        +'<td>'+stBadge+'</td>'
        +'<td style="white-space:nowrap">'
        +(m.active?'<button class="sa-btn sa-btn-n" style="font-size:10px;margin-right:3px" onclick="archiveBc(\''+esc(m._id)+'\')">Archive</button>':'')
        +'<button class="sa-btn sa-btn-d" style="font-size:10px" onclick="deleteBc(\''+esc(m._id)+'\')">&#128465;</button>'
        +'</td>'
        +'</tr>';
    }).join('');
    document.getElementById('bc-history-tbl').style.display='table';
  }).catch(function(e){ document.getElementById('bc-history-loading').textContent='Error: '+e.message; });
}

function archiveBc(id){
  db.ref(BROADCAST_PATH+'/'+id).update({active:false,archivedAt:Date.now()}).then(function(){
    showNotice('Broadcast archived.','ok'); loadHistory();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}
function deleteBc(id){
  if(!confirm('Delete this broadcast?')) return;
  db.ref(BROADCAST_PATH+'/'+id).remove().then(function(){
    showNotice('Broadcast deleted.','ok'); loadHistory();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

window._fbOnLogin = function(){ loadHistory(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
