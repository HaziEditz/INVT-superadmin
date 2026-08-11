<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Clean-trip Scan &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="assets/js/jquery.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet"/>
<link href="assets/css/main.min.css" rel="stylesheet"/>
<link href="assets/css/bootstrap.min.css" rel="stylesheet"/>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyDIVSI_GRYG0hCPvc9h80QXZMxwZoejctQ",authDomain:"bookawaka2026-564e1.firebaseapp.com",databaseURL:"https://bookawaka2026-564e1-default-rtdb.firebaseio.com",projectId:"bookawaka2026-564e1",storageBucket:"bookawaka2026-564e1.firebasestorage.app"});
</script>
<style>
.tm-wrap{padding:20px;max-width:900px}
.tm-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.tm-bar{background:#1565C0;color:#fff;padding:13px 18px}
.tm-bar h3{margin:0;font-size:15px;font-weight:600}
.tm-btn{padding:8px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:600;background:#1565C0;color:#fff;margin-right:8px}
.tm-btn.sec{background:#eee;color:#333}
.notice{padding:12px 16px;background:#E3F2FD;border-left:4px solid #1565C0;font-size:13px;color:#0D47A1;margin:0}
.filt{padding:16px 18px;display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end}
.filt label{display:block;font-size:11px;color:#666;margin-bottom:3px}
.filt input,.filt select{padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:180px}
#scan-out{padding:16px 18px;font-size:14px;line-height:1.55;color:#333;background:#FAFAFA;min-height:80px}
.scan-summary{margin:0}
.scan-summary .mode{font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.04em;color:#1565C0;margin:0 0 10px}
.scan-summary .mode.live{color:#2E7D32}
.scan-summary .headline{font-size:15px;font-weight:600;margin:0 0 12px;color:#0D47A1}
.scan-summary table{width:100%;max-width:480px;border-collapse:collapse;font-size:13px}
.scan-summary td{padding:7px 0;border-bottom:1px solid #eee}
.scan-summary td:last-child{text-align:right;font-weight:700;font-variant-numeric:tabular-nums}
.scan-summary .note{margin:12px 0 0;font-size:12px;color:#666}
.scan-summary .err{color:#C62828;font-weight:600}
.scan-busy,.scan-error{font-size:13px;color:#555}
.scan-error{color:#C62828;white-space:pre-wrap}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">TM Clean-trip Scan — BookaWaka Admin</label></div>
</nav></div></header>
<aside id="sidebar_main"><div class="menu_section"><ul>
  <li><a href="Home.aspx"><span class="menu_title">Home</span></a></li>
  <li class="current_section"><a href="#"><span class="menu_title">Total Mobility</span></a><ul>
    <li><a href="TM-Setup.aspx">TM Setup Hub</a></li>
    <li><a href="TM-Platform-Fees.aspx">Platform Fees</a></li>
    <li><a href="TM-Clean-Scan.aspx" style="font-weight:700;color:#1565C0">&#9658; Clean-trip Scan</a></li>
    <li><a href="TM-Settlement.aspx">Settlement</a></li>
    <li><a href="TM-Batches.aspx">Claim Batches</a></li>
  </ul></li>
</ul></div></aside>
<div id="page_content"><div id="page_content_inner">
<div class="tm-wrap">
  <div class="notice">Walks currently submitted trips (no date window by design), runs anomaly scan, auto-approves <strong>submitted + clean + never-flagged + never-edited</strong> into claim batches. Runs <strong>automatically every hour</strong>; buttons below are for dry-run / manual override. Council Trips UI is unchanged.</div>
  <div class="tm-card" style="margin-top:16px">
    <div class="tm-bar"><h3>Automatic schedule</h3></div>
    <div id="scan-last" style="padding:14px 18px;font-size:13px;color:#555">Loading last scheduled run…</div>
  </div>
  <div class="tm-card" style="margin-top:16px">
    <div class="tm-bar"><h3>Manual override</h3></div>
    <div class="filt">
      <div><label>Council (optional)</label><select id="scan-council"><option value="">All councils</option></select></div>
      <div><label>Company (optional)</label><select id="scan-company"><option value="">All companies</option></select></div>
      <div>
        <button class="tm-btn sec" onclick="runScan(true)">Dry run</button>
        <button class="tm-btn" onclick="runScan(false)">Run scan</button>
      </div>
    </div>
    <div id="scan-out">Ready.</div>
  </div>
</div>
</div></div>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
window._fbOnLogin = function() {
  Promise.all([adminRead('tmConfig'), adminRead('superClients')]).then(function(res) {
    var councils = res[0] || {};
    var companies = res[1] || {};
    var cOpts = '<option value="">All councils</option>';
    Object.keys(councils).sort().forEach(function(id) {
      cOpts += '<option value="'+id+'">'+(councils[id].name||id)+'</option>';
    });
    document.getElementById('scan-council').innerHTML = cOpts;
    var coOpts = '<option value="">All companies</option>';
    Object.keys(companies).sort(function(a,b){
      return String(companies[a].name||a).localeCompare(String(companies[b].name||b));
    }).forEach(function(id) {
      coOpts += '<option value="'+id+'">'+(companies[id].name||id)+'</option>';
    });
    document.getElementById('scan-company').innerHTML = coOpts;
  });
  loadLastRun();
};
function loadLastRun(){
  var el=document.getElementById('scan-last');
  if(!el) return;
  fetch('/api/sa/tm-clean-scan/last-run').then(function(r){ return r.json(); }).then(function(j){
    var lr=j&&j.lastRun;
    var intervalMin=Math.round((j&&j.intervalMs?j.intervalMs:3600000)/60000);
    if(!lr||!lr.at){
      el.innerHTML='No automatic run logged yet. Schedule: every <strong>'+intervalMin+' minutes</strong> (first run a few minutes after server start).';
      return;
    }
    var when=new Date(Number(lr.at));
    var whenStr=isNaN(when.getTime())?String(lr.at):when.toLocaleString();
    var other=Math.max(0, n(lr.scanned)-n(lr.approved)-n(lr.flagged));
    el.innerHTML=
      '<div style="margin-bottom:6px"><strong>Last run:</strong> '+whenStr+
      ' <span style="color:#888">('+(lr.source||'unknown')+(lr.who?' · '+lr.who:'')+')</span></div>'+
      '<div>'+n(lr.scanned)+' checked · '+n(lr.approved)+' auto-approved · '+
      n(lr.flagged)+' flagged · '+other+' skipped'+(n(lr.errors)?' · <span style="color:#C62828">'+n(lr.errors)+' errors</span>':'')+
      '</div>'+
      '<div style="margin-top:6px;color:#888;font-size:12px">Automatic schedule: every '+intervalMin+' minutes. Manual Dry run / Run scan below still work as override.</div>';
  }).catch(function(){
    el.textContent='Could not load last-run status.';
  });
}
function saApi(method, path, body){
  var user = firebase.auth().currentUser;
  if(!user) return Promise.reject(new Error('Not signed in'));
  return user.getIdToken(true).then(function(idToken){
    var opts={method:method, headers:{'Content-Type':'application/json','Authorization':'Bearer '+idToken}};
    if(body) opts.body=JSON.stringify(body);
    return fetch(path, opts).then(function(r){
      return r.json().then(function(j){
        if(!r.ok){ var e=new Error(j.error||('HTTP '+r.status)); e.body=j; throw e; }
        return j;
      });
    });
  });
}
function n(v){ var x=Number(v); return Number.isFinite(x)?x:0; }
function formatScanSummary(j){
  var scanned=n(j.scanned);
  var approved=n(j.approved);
  var flagged=n(j.flagged);
  var errors=n(j.errors);
  var other=Math.max(0, scanned - approved - flagged);
  var dry=!!j.dryRun;
  var approveLabel=dry?'Would auto-approve':'Auto-approved';
  var headline=scanned+' trip'+(scanned===1?'':'s')+' checked — '+
    approved+' '+(dry?'would be approved automatically':'approved automatically')+', '+
    flagged+' need human review (flagged), '+
    other+' skipped for other reasons';
  if(errors) headline+=', '+errors+' error'+(errors===1?'':'s');
  var html='<div class="scan-summary">'+
    '<div class="mode '+(dry?'':'live')+'">'+(dry?'Dry run (no changes written)':'Live run')+'</div>'+
    '<p class="headline">'+headline+'</p>'+
    '<table>'+
      '<tr><td>Trips checked</td><td>'+scanned+'</td></tr>'+
      '<tr><td>'+approveLabel+'</td><td>'+approved+'</td></tr>'+
      '<tr><td>Need human review (flagged)</td><td>'+flagged+'</td></tr>'+
      '<tr><td>Skipped for other reasons</td><td>'+other+'</td></tr>'+
      (errors?'<tr><td class="err">Errors</td><td class="err">'+errors+'</td></tr>':'')+
    '</table>'+
    '<p class="note">'+(j.note||'Clean never-flagged never-edited submitted trips go to approved + claim batch. Council Trips UI is unchanged.')+'</p>'+
  '</div>';
  return html;
}
function runScan(dryRun){
  var out=document.getElementById('scan-out');
  out.innerHTML='<div class="scan-busy">Running'+(dryRun?' dry-run':'')+'…</div>';
  saApi('POST','/api/sa/tm-clean-scan',{
    dryRun: !!dryRun,
    councilId: document.getElementById('scan-council').value.trim()||undefined,
    companyId: document.getElementById('scan-company').value.trim()||undefined
  }).then(function(j){
    out.innerHTML=formatScanSummary(j||{});
    if(!dryRun) loadLastRun();
  }).catch(function(e){
    var detail=(e&&e.body&&e.body.error)||'';
    out.innerHTML='<div class="scan-error">Error: '+(e&&e.message||e)+(detail&&detail!==(e&&e.message)?' — '+detail:'')+'</div>';
  });
}
</script>
</body></html>
