<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>System Alerts &mdash; BookaWaka Admin</title>
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
.sa-bar.amber{background:#E65100}
.sa-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none;white-space:nowrap}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-btn-d{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.kpi-chips{display:flex;gap:10px;flex-wrap:wrap;padding:14px 18px;border-bottom:1px solid #f5f5f5}
.kpi-chip{border-radius:8px;padding:10px 16px;min-width:90px;text-align:center}
.kpi-n{font-size:22px;font-weight:700}
.kpi-l{font-size:11px;color:#888;margin-top:2px}
.alert-row{padding:14px 18px;border-bottom:1px solid #f5f5f5;display:flex;align-items:flex-start;gap:14px;flex-wrap:wrap}
.alert-icon{font-size:22px;line-height:1;margin-top:2px;min-width:28px;text-align:center}
.alert-body{flex:1;min-width:200px}
.alert-title{font-weight:700;font-size:13px;color:#263238}
.alert-detail{font-size:12px;color:#888;margin-top:3px}
.alert-meta{font-size:11px;color:#aaa;margin-top:4px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">System Alerts &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Alerts.aspx" style="font-weight:700;color:#1565C0">&#9658; System Alerts</a></li>
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

<h2 style="font-size:18px;font-weight:700;color:#263238;margin:0 0 16px">&#128276; System Alerts</h2>
<div id="alert-notice" class="sa-notice"></div>

<!-- Trial Expiry Alerts -->
<div class="sa-card">
  <div class="sa-bar amber">
    <h3>&#128197; Trial Expiry Alerts Sent</h3>
    <button onclick="loadAlerts()" class="sa-btn sa-btn-n" style="font-size:12px;color:#fff;border-color:rgba(255,255,255,.3);background:rgba(255,255,255,.15)">&#8635; Refresh</button>
  </div>
  <div class="kpi-chips">
    <div class="kpi-chip" style="background:#FFF3E0"><div class="kpi-n" style="color:#E65100" id="kpi-trial-alerts">—</div><div class="kpi-l">Alerts Sent</div></div>
    <div class="kpi-chip" style="background:#FFEBEE"><div class="kpi-n" style="color:#C62828" id="kpi-trial-dismissed">—</div><div class="kpi-l">Dismissed</div></div>
    <div class="kpi-chip" style="background:#f5f5f5"><div class="kpi-n" style="color:#555" id="kpi-trial-total">—</div><div class="kpi-l">Total</div></div>
  </div>
  <div id="trial-alerts-wrap">
    <div style="padding:30px;text-align:center;color:#aaa;font-size:13px" id="trial-loading">Loading&hellip;</div>
  </div>
</div>

<!-- Custom system-wide alerts -->
<div class="sa-card">
  <div class="sa-bar">
    <h3>&#128276; Custom System Alerts</h3>
    <button onclick="toggleAddAlert()" class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px">&#43; Add Alert</button>
  </div>
  <!-- Add alert form -->
  <div id="add-alert-form" style="display:none;padding:16px 18px;background:#F0F7FF;border-bottom:1px solid #BBDEFB">
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px;margin-bottom:12px">
      <div>
        <label style="display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:4px">Title <span style="color:#C62828">*</span></label>
        <input id="alert-title" type="text" placeholder="e.g. Scheduled maintenance" style="width:100%;padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box"/>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:4px">Severity</label>
        <select id="alert-severity" style="width:100%;padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px">
          <option value="info">Info</option>
          <option value="warning">Warning</option>
          <option value="critical">Critical</option>
        </select>
      </div>
      <div>
        <label style="display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:4px">Audience</label>
        <select id="alert-audience" style="width:100%;padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px">
          <option value="internal">Internal only</option>
          <option value="all">All companies</option>
        </select>
      </div>
    </div>
    <div style="margin-bottom:12px">
      <label style="display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:4px">Message</label>
      <textarea id="alert-message" rows="2" placeholder="Describe the alert…" style="width:100%;padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;font-family:inherit;box-sizing:border-box;resize:vertical"></textarea>
    </div>
    <div style="display:flex;gap:8px;align-items:center">
      <button onclick="saveAlert()" class="sa-btn sa-btn-p">Save Alert</button>
      <button onclick="toggleAddAlert()" class="sa-btn sa-btn-n">Cancel</button>
      <span id="alert-msg" style="font-size:12px;color:#888"></span>
    </div>
  </div>
  <div id="custom-alerts-wrap">
    <div style="padding:30px;text-align:center;color:#aaa;font-size:13px" id="custom-loading">Loading&hellip;</div>
  </div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDt(ts){ if(!ts) return '—'; return new Date(ts).toLocaleString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}); }

function showNotice(msg, type){
  var el=document.getElementById('alert-notice');
  el.className='sa-notice '+(type||'ok');
  el.textContent=msg;
  el.style.display='block';
  if(type!=='err') setTimeout(function(){ el.style.display='none'; },4000);
}

function loadAlerts(){
  loadTrialAlerts();
  loadCustomAlerts();
}

function loadTrialAlerts(){
  var wrap=document.getElementById('trial-alerts-wrap');
  wrap.innerHTML='<div style="padding:30px;text-align:center;color:#aaa;font-size:13px" id="trial-loading">Loading&hellip;</div>';
  _fbGet('superAlerts/trialExpiry').then(function(raw){
    raw=raw||{};
    var data=(raw && typeof raw==='object' && !Array.isArray(raw)) ? raw : {};
    var items=Object.entries(data)
      .filter(function(e){ return e[1] && typeof e[1]==='object' && !Array.isArray(e[1]); })
      .map(function(e){ return Object.assign({_cid:e[0]},e[1]); });
    var sent=items.filter(function(i){ return i.sentAt; });
    var dismissed=items.filter(function(i){ return i.dismissed; });
    document.getElementById('kpi-trial-alerts').textContent=sent.length;
    document.getElementById('kpi-trial-dismissed').textContent=dismissed.length;
    document.getElementById('kpi-trial-total').textContent=items.length;
    var wrap=document.getElementById('trial-alerts-wrap');
    if(!items.length){ wrap.innerHTML='<div style="padding:20px 18px;color:#aaa;font-size:13px">No trial expiry alerts on record.</div>'; return; }
    var sev={info:'&#8505;',warning:'&#9888;',critical:'&#128680;'};
    var severityColor={info:'#1565C0',warning:'#E65100',critical:'#C62828'};
    items.sort(function(a,b){ return (b.sentAt||0)-(a.sentAt||0); });
    wrap.innerHTML='<div style="overflow-x:auto"><table class="sa-tbl"><thead><tr><th>Company</th><th>Sent At</th><th>Trial End</th><th>Status</th><th>Actions</th></tr></thead><tbody>'
      +items.map(function(i){
        var st=i.dismissed?'<span style="background:#f5f5f5;color:#aaa;border-radius:10px;padding:1px 7px;font-size:11px;border:1px solid #e0e0e0">Dismissed</span>'
          :i.sentAt?'<span style="background:#E3F2FD;color:#1565C0;border-radius:10px;padding:1px 7px;font-size:11px;border:1px solid #BBDEFB">Sent</span>'
          :'<span style="background:#FFF3E0;color:#E65100;border-radius:10px;padding:1px 7px;font-size:11px;border:1px solid #FFCC80">Queued</span>';
        return '<tr><td style="font-weight:600"><a href="SA-Company.aspx?cid='+esc(i._cid)+'" style="color:#1565C0;text-decoration:none">'+esc(i.companyName||i._cid)+'</a></td>'
          +'<td style="color:#555;font-size:11px">'+fmtDt(i.sentAt)+'</td>'
          +'<td style="color:#555;font-size:11px">'+fmtDt(i.trialEnd)+'</td>'
          +'<td>'+st+'</td>'
          +'<td><button class="sa-btn sa-btn-n" style="font-size:10px" onclick="dismissAlert(\''+esc(i._cid)+'\')">Dismiss</button>'
          +(!i.dismissed?'<button class="sa-btn sa-btn-d" style="font-size:10px;margin-left:3px" onclick="clearTrialAlert(\''+esc(i._cid)+'\')">&#128465;</button>':'')+'</td></tr>';
      }).join('')+'</tbody></table></div>';
  }).catch(function(e){ document.getElementById('trial-alerts-wrap').innerHTML='<div style="padding:20px 18px;color:#C62828;font-size:13px">Error: '+esc(e.message)+'</div>'; });
}

function dismissAlert(cid){
  db.ref('superAlerts/trialExpiry/'+cid).update({dismissed:true,dismissedAt:Date.now()}).then(function(){
    showNotice('Alert dismissed.','ok'); loadTrialAlerts();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}
function clearTrialAlert(cid){
  if(!confirm('Remove this alert record?')) return;
  db.ref('superAlerts/trialExpiry/'+cid).remove().then(function(){
    showNotice('Alert removed.','ok'); loadTrialAlerts();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function loadCustomAlerts(){
  var wrap=document.getElementById('custom-alerts-wrap');
  wrap.innerHTML='<div style="padding:30px;text-align:center;color:#aaa;font-size:13px">Loading&hellip;</div>';
  _fbGet('superAlerts/custom').then(function(raw){
    raw=raw||{};
    var data=(raw && typeof raw==='object' && !Array.isArray(raw)) ? raw : {};
    var items=Object.entries(data)
      .filter(function(e){ return e[1] && typeof e[1]==='object' && !Array.isArray(e[1]) && e[1].createdAt; })
      .map(function(e){ return Object.assign({_id:e[0]},e[1]); })
      .sort(function(a,b){ return (b.createdAt||0)-(a.createdAt||0); });
    var wrap=document.getElementById('custom-alerts-wrap');
    if(!items.length){ wrap.innerHTML='<div style="padding:20px 18px;color:#aaa;font-size:13px">No custom alerts. Click &ldquo;+ Add Alert&rdquo; to create one.</div>'; return; }
    var iconMap={info:'&#8505;',warning:'&#9888;&#65039;',critical:'&#128680;'};
    var colorMap={info:'#1565C0',warning:'#E65100',critical:'#C62828'};
    var bgMap={info:'#E3F2FD',warning:'#FFF3E0',critical:'#FFEBEE'};
    wrap.innerHTML=items.map(function(i){
      var icon=iconMap[i.severity||'info']||'&#8505;';
      var col=colorMap[i.severity||'info']||'#1565C0';
      var bg=bgMap[i.severity||'info']||'#E3F2FD';
      var resolvedBadge=i.resolved
        ?'<span style="background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7;border-radius:10px;padding:1px 7px;font-size:11px">&#10003; Resolved</span>'
        :'<span style="background:'+bg+';color:'+col+';border:1px solid '+col+'50;border-radius:10px;padding:1px 7px;font-size:11px">Active</span>';
      return '<div class="alert-row">'
        +'<div class="alert-icon" style="color:'+col+'">'+icon+'</div>'
        +'<div class="alert-body">'
        +'<div class="alert-title">'+esc(i.title||'Untitled')+'</div>'
        +(i.message?'<div class="alert-detail">'+esc(i.message)+'</div>':'')
        +'<div class="alert-meta">Created: '+fmtDt(i.createdAt)+'  &middot;  Audience: '+esc(i.audience||'internal')+'  &middot;  '+resolvedBadge+'</div>'
        +'</div>'
        +'<div style="display:flex;gap:6px;align-items:center;flex-shrink:0">'
        +(!i.resolved?'<button class="sa-btn sa-btn-s" style="font-size:10px" onclick="resolveAlert(\''+i._id+'\')">&#10003; Resolve</button>':'')
        +'<button class="sa-btn sa-btn-d" style="font-size:10px" onclick="deleteAlert(\''+i._id+'\')">&#128465;</button>'
        +'</div>'
        +'</div>';
    }).join('');
  }).catch(function(e){ document.getElementById('custom-alerts-wrap').innerHTML='<div style="padding:20px 18px;color:#C62828;font-size:13px">Error: '+esc(e.message)+'</div>'; });
}

function toggleAddAlert(){
  var f=document.getElementById('add-alert-form');
  f.style.display=f.style.display==='none'?'block':'none';
  document.getElementById('alert-msg').textContent='';
}

function saveAlert(){
  var title=(document.getElementById('alert-title').value||'').trim();
  if(!title){ document.getElementById('alert-msg').textContent='Title is required.'; return; }
  var severity=document.getElementById('alert-severity').value;
  var audience=document.getElementById('alert-audience').value;
  var message=(document.getElementById('alert-message').value||'').trim();
  db.ref('superAlerts/custom').push({
    title:title, severity:severity, audience:audience, message:message||null,
    createdAt:Date.now(), createdBy:(firebase.auth().currentUser||{}).email||'sa', resolved:false
  }).then(function(){
    document.getElementById('alert-title').value='';
    document.getElementById('alert-message').value='';
    document.getElementById('add-alert-form').style.display='none';
    showNotice('Alert saved.','ok');
    loadCustomAlerts();
  }).catch(function(e){ document.getElementById('alert-msg').textContent='Error: '+e.message; });
}

function resolveAlert(id){
  db.ref('superAlerts/custom/'+id).update({resolved:true,resolvedAt:Date.now()}).then(function(){
    showNotice('Alert resolved.','ok'); loadCustomAlerts();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

function deleteAlert(id){
  if(!confirm('Delete this alert?')) return;
  db.ref('superAlerts/custom/'+id).remove().then(function(){
    showNotice('Alert deleted.','ok'); loadCustomAlerts();
  }).catch(function(e){ showNotice('Error: '+e.message,'err'); });
}

window._fbOnLogin = function(){ loadAlerts(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
