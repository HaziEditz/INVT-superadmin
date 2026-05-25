<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Dispatch Sessions &mdash; BookaWaka Admin</title>
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
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}.sa-btn-d:hover{background:#FFCDD2}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-notice.warn{background:#FFF8E1;color:#F57F17;border-left:4px solid #F9A825}
.kpi-row{display:flex;gap:0;flex-wrap:wrap;border-bottom:1px solid #f5f5f5}
.kpi-box{flex:1;min-width:120px;padding:16px 18px;border-left:3px solid #1565C0}
.kpi-box:first-child{border-left:none}
.kpi-val{font-size:24px;font-weight:800;color:#1565C0}
.kpi-lbl{font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.5px;margin-top:2px}
.pulse{display:inline-block;width:9px;height:9px;border-radius:50%;background:#2E7D32;margin-right:5px;animation:pulse 1.5s infinite}
@keyframes pulse{0%,100%{box-shadow:0 0 0 0 rgba(46,125,50,.6)}50%{box-shadow:0 0 0 5px rgba(46,125,50,0)}}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Dispatch Sessions &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Broadcast.aspx">Broadcast</a></li>
      <li><a href="SA-Sessions.aspx" style="font-weight:700;color:#1565C0">&#9658; Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx">Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:16px">
  <div>
    <h2 style="font-size:18px;font-weight:700;color:#263238;margin:0 0 3px">&#128187; Dispatch Session Visibility</h2>
    <p style="font-size:12px;color:#888;margin:0">Live view of which companies have active dispatch sessions. Refreshes every 30 seconds.</p>
  </div>
  <div style="display:flex;gap:8px;align-items:center">
    <button onclick="loadSessions()" class="sa-btn sa-btn-n">&#8635; Refresh</button>
    <button onclick="revokeAllSessions()" class="sa-btn sa-btn-d">&#128683; Revoke ALL Sessions</button>
  </div>
</div>
<div id="sess-notice" class="sa-notice"></div>

<!-- KPI row -->
<div class="sa-card">
  <div class="kpi-row">
    <div class="kpi-box"><div class="kpi-val" id="kpi-active">—</div><div class="kpi-lbl">Companies Online</div></div>
    <div class="kpi-box" style="border-left-color:#E65100"><div class="kpi-val" style="color:#E65100" id="kpi-dispatchers">—</div><div class="kpi-lbl">Active Dispatcher Sessions</div></div>
    <div class="kpi-box" style="border-left-color:#7B1FA2"><div class="kpi-val" style="color:#7B1FA2" id="kpi-stale">—</div><div class="kpi-lbl">Stale (&gt;1h since heartbeat)</div></div>
    <div class="kpi-box" style="border-left-color:#aaa"><div class="kpi-val" style="color:#aaa" id="kpi-total-co">—</div><div class="kpi-lbl">Total Companies Monitored</div></div>
  </div>
</div>

<!-- Active sessions table -->
<div class="sa-card">
  <div class="sa-bar"><h3><span class="pulse"></span>Active Dispatch Sessions</h3>
    <span id="last-refresh-label" style="font-size:12px;opacity:.75"></span>
  </div>
  <div id="sess-loading" style="padding:30px;text-align:center;color:#aaa;font-size:13px">Loading sessions&hellip;</div>
  <div style="overflow-x:auto">
    <table class="sa-tbl" id="sess-tbl" style="display:none">
      <thead><tr>
        <th>Company</th><th>Dispatcher(s)</th><th>Sessions</th>
        <th>Last Heartbeat</th><th>IP / User-Agent</th><th>Status</th><th>Actions</th>
      </tr></thead>
      <tbody id="sess-tbody"></tbody>
    </table>
  </div>
</div>

<!-- Session revocation history -->
<div class="sa-card">
  <div class="sa-bar" style="background:#263238"><h3>&#128203; Revocation History</h3></div>
  <div style="overflow-x:auto;padding:0 0 8px">
    <table class="sa-tbl" id="revoke-hist-tbl">
      <thead><tr><th>Time</th><th>Company</th><th>Revoked By</th><th>Reason</th></tr></thead>
      <tbody id="revoke-hist-body"><tr><td colspan="4" style="text-align:center;padding:20px;color:#aaa">Loading&hellip;</td></tr></tbody>
    </table>
  </div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allClients = {};
var STALE_THRESHOLD = 60 * 60 * 1000; // 1 hour

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtAge(ts){
  if(!ts) return '—';
  var d=Date.now()-ts;
  if(d<60000) return Math.round(d/1000)+'s ago';
  if(d<3600000) return Math.round(d/60000)+'m ago';
  if(d<86400000) return Math.round(d/3600000)+'h ago';
  return Math.round(d/86400000)+'d ago';
}
function fmtDt(ts){ if(!ts) return '—'; return new Date(ts).toLocaleString('en-NZ',{day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'}); }

function showNotice(msg,type){
  var el=document.getElementById('sess-notice');
  el.className='sa-notice '+(type||'ok');
  el.textContent=msg;
  el.style.display='block';
  if(type!=='err') setTimeout(function(){ el.style.display='none'; },4000);
}

function loadSessions(){
  document.getElementById('sess-loading').style.display='block';
  document.getElementById('sess-tbl').style.display='none';

  Promise.all([
    _fbGet('superClients'),
    _fbGet('activeDispatchers')
  ]).then(function(results){
    allClients = results[0]||{};
    var sessions = results[1]||{};

    var rows=[];
    var activeCo=0, totalDisp=0, staleCo=0;
    var now=Date.now();

    Object.entries(sessions).forEach(function(entry){
      var cid=entry[0];
      var coSessions=entry[1]||{};
      var c=allClients[cid]||{};
      var sessionList=Object.entries(coSessions).map(function(se){
        return Object.assign({_sid:se[0]},se[1]);
      });
      if(!sessionList.length) return;

      var latest=Math.max.apply(null,sessionList.map(function(s){ return s.heartbeat||s.lastSeen||0; }));
      var isStale=latest>0&&(now-latest)>STALE_THRESHOLD;
      var isActive=latest>0&&(now-latest)<STALE_THRESHOLD;

      if(isActive) activeCo++;
      else if(isStale) staleCo++;
      totalDisp+=sessionList.length;

      rows.push({cid:cid,name:c.name||cid,status:c.status||'active',sessions:sessionList,latestHb:latest,isStale:isStale,isActive:isActive});
    });

    rows.sort(function(a,b){ return (b.latestHb||0)-(a.latestHb||0); });

    document.getElementById('kpi-active').textContent=activeCo;
    document.getElementById('kpi-dispatchers').textContent=totalDisp;
    document.getElementById('kpi-stale').textContent=staleCo;
    document.getElementById('kpi-total-co').textContent=rows.length;
    document.getElementById('last-refresh-label').textContent='Last refresh: '+new Date().toLocaleTimeString('en-NZ');

    if(!rows.length){
      document.getElementById('sess-loading').textContent='No active dispatch sessions found. Sessions are written to activeDispatchers/{companyId} by the dispatch app.';
      document.getElementById('sess-loading').style.display='block';
      return;
    }

    document.getElementById('sess-tbody').innerHTML=rows.map(function(r){
      var statusDot=r.isActive
        ? '<span class="pulse"></span><span style="color:#2E7D32;font-weight:700">Online</span>'
        : r.isStale
          ? '<span style="color:#E65100;font-weight:700">&#9679; Stale</span>'
          : '<span style="color:#aaa">&#9679; Unknown</span>';
      var coStatus=r.status==='suspended'
        ? '<span style="background:#FFEBEE;color:#C62828;border-radius:10px;padding:1px 7px;font-size:11px;font-weight:700">Suspended</span>'
        : '';

      var dispatcherEmails=[...new Set(r.sessions.map(function(s){ return s.email||s.uid||'unknown'; }))].slice(0,3).join(', ');
      var ua=r.sessions[0]&&(r.sessions[0].ua||r.sessions[0].userAgent||'');
      var ip=r.sessions[0]&&r.sessions[0].ip||'';

      return '<tr>'
        +'<td><a href="SA-Company.aspx?cid='+esc(r.cid)+'" style="font-weight:700;color:#1565C0;text-decoration:none">'+esc(r.name)+'</a>'
          +'<div style="font-size:11px;font-family:monospace;color:#aaa">ID: '+esc(r.cid)+'</div>'
          +(coStatus?'<div style="margin-top:3px">'+coStatus+'</div>':'')
        +'</td>'
        +'<td style="font-size:12px;color:#555;max-width:180px;word-break:break-word">'+esc(dispatcherEmails)+(r.sessions.length>3?'<span style="color:#aaa"> +more</span>':'')+'</td>'
        +'<td style="font-weight:700;color:#1565C0">'+r.sessions.length+'</td>'
        +'<td style="font-size:12px;color:#555">'+fmtDt(r.latestHb)+'<div style="font-size:11px;color:#aaa">'+fmtAge(r.latestHb)+'</div></td>'
        +'<td style="font-size:11px;color:#888;max-width:160px;word-break:break-word">'+(ip?'IP: '+esc(ip)+'<br/>':'')+(ua?esc(ua).substr(0,60):'—')+'</td>'
        +'<td>'+statusDot+'</td>'
        +'<td style="white-space:nowrap">'
          +'<button class="sa-btn sa-btn-d" style="font-size:11px;margin-right:4px" onclick="revokeCompanySession(\''+esc(r.cid)+'\',\''+esc(r.name)+'\')">&#128683; Revoke</button>'
          +'<a href="SA-Company.aspx?cid='+esc(r.cid)+'" class="sa-btn sa-btn-n" style="font-size:11px">&#9998; Company</a>'
        +'</td>'
        +'</tr>';
    }).join('');

    document.getElementById('sess-loading').style.display='none';
    document.getElementById('sess-tbl').style.display='table';
    loadRevocationHistory();
  }).catch(function(e){
    document.getElementById('sess-loading').textContent='Error loading sessions: '+e.message;
  });
}

function revokeCompanySession(cid, name){
  if(!confirm('Revoke all dispatch sessions for '+name+'?\n\nThis writes a sessionRevoke signal to Firebase. The dispatch app must be listening on superClients/{cid}/sessionRevoke to enforce the logout.')) return;
  var saEmail=(firebase.auth().currentUser||{}).email||'sa';
  var now=Date.now();
  db.ref('superClients/'+cid).update({sessionRevoke:now}).then(function(){
    var ts=Date.now(), rand=Math.random().toString(36).substr(2,5).toUpperCase();
    db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:'session_revoked',actor:saEmail,cid:cid,cidName:name,detail:'Dispatch sessions revoked from SA-Sessions panel',ts:ts});
    showNotice('Revocation signal sent for '+name,'warn');
    loadSessions();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function revokeAllSessions(){
  if(!confirm('REVOKE ALL active dispatch sessions across ALL companies?\n\nThis will log out every dispatcher on the platform. Use only in an emergency.')) return;
  var saEmail=(firebase.auth().currentUser||{}).email||'sa';
  var now=Date.now();
  _fbGet('activeDispatchers').then(function(data){
    data=data||{};
    var cids=Object.keys(data);
    if(!cids.length){ showNotice('No sessions to revoke.','ok'); return; }
    var updates={};
    cids.forEach(function(cid){ updates['superClients/'+cid+'/sessionRevoke']=now; });
    return db.ref().update(updates);
  }).then(function(){
    var ts=Date.now(), rand=Math.random().toString(36).substr(2,5).toUpperCase();
    db.ref('superAuditLog/LOG'+ts+'_'+rand).set({action:'all_sessions_revoked',actor:saEmail,cid:'ALL',cidName:'ALL COMPANIES',detail:'Emergency: all dispatch sessions revoked by SA admin',ts:ts});
    showNotice('All sessions revoked across all companies.','warn');
    loadSessions();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function loadRevocationHistory(){
  _fbGet('superAuditLog').then(function(data){
    data=data||{};
    var items=Object.values(data).filter(function(e){ return e&&e.action==='session_revoked'; }).sort(function(a,b){ return (b.ts||0)-(a.ts||0); }).slice(0,15);
    var tbody=document.getElementById('revoke-hist-body');
    if(!items.length){
      tbody.innerHTML='<tr><td colspan="4" style="text-align:center;padding:20px;color:#aaa">No revocation events recorded yet.</td></tr>';
      return;
    }
    tbody.innerHTML=items.map(function(r){
      return '<tr>'
        +'<td style="white-space:nowrap;font-size:11px;color:#888">'+fmtDt(r.ts)+'</td>'
        +'<td style="font-weight:600"><a href="SA-Company.aspx?cid='+esc(r.cid)+'" style="color:#1565C0;text-decoration:none">'+esc(r.cidName||r.cid)+'</a></td>'
        +'<td style="font-size:12px;color:#555">'+esc(r.actor||'—')+'</td>'
        +'<td style="font-size:12px;color:#888">'+esc(r.detail||'—')+'</td>'
        +'</tr>';
    }).join('');
  }).catch(function(){});
}

var _autoRefresh = null;
window._fbOnLogin = function(){
  if (_autoRefresh) return;
  loadSessions();
  _autoRefresh = setInterval(function(){ loadSessions(); }, 30000);
};
window.addEventListener('beforeunload', function(){ if(_autoRefresh) clearInterval(_autoRefresh); });
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
