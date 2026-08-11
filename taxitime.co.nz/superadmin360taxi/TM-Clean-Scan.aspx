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
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
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
.filt input,.filt select{padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
#scan-out{padding:16px 18px;font-family:monospace;font-size:12px;white-space:pre-wrap;background:#FAFAFA;min-height:80px}
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
  <div class="notice">Walks all companies/trips, runs anomaly scan, auto-approves <strong>submitted + clean + never-flagged</strong> into claim batches (addendum-aware). Council Trips UI is unchanged.</div>
  <div class="tm-card" style="margin-top:16px">
    <div class="tm-bar"><h3>Run SA clean-trip scan</h3></div>
    <div class="filt">
      <div><label>Council ID (optional)</label><input id="scan-council" placeholder="cncl_…"/></div>
      <div><label>Company ID (optional)</label><input id="scan-company" placeholder="860869"/></div>
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
function saApi(method, path, body){
  var user = firebase.auth().currentUser;
  if(!user) return Promise.reject(new Error('Not signed in'));
  return user.getIdToken().then(function(idToken){
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
function runScan(dryRun){
  var out=document.getElementById('scan-out');
  out.textContent='Running'+(dryRun?' dry-run':'')+'…';
  saApi('POST','/api/sa/tm-clean-scan',{
    dryRun: !!dryRun,
    councilId: document.getElementById('scan-council').value.trim()||undefined,
    companyId: document.getElementById('scan-company').value.trim()||undefined
  }).then(function(j){
    out.textContent=JSON.stringify(j,null,2);
  }).catch(function(e){
    out.textContent='Error: '+(e&&e.message||e)+'\n'+JSON.stringify(e&&e.body||{},null,2);
  });
}
</script>
</body></html>
