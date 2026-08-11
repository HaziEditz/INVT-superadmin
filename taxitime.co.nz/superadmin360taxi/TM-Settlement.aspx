<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Settlement &mdash; BookaWaka Admin</title>
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
.tm-wrap{padding:20px;max-width:960px}
.tm-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.tm-bar{background:#37474F;color:#fff;padding:13px 18px}
.tm-bar h3{margin:0;font-size:15px;font-weight:600}
.tm-btn{padding:8px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:600;background:#37474F;color:#fff;margin:4px 8px 4px 0}
.notice{padding:12px 16px;background:#FFF8E1;border-left:4px solid #E65100;font-size:13px;color:#E65100;margin:0}
.filt{padding:16px 18px;display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end}
.filt label{display:block;font-size:11px;color:#666;margin-bottom:3px}
.filt input{padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
#set-out{padding:16px 18px;font-family:monospace;font-size:12px;white-space:pre-wrap;background:#FAFAFA;min-height:100px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">TM Settlement — BookaWaka Admin</label></div>
</nav></div></header>
<aside id="sidebar_main"><div class="menu_section"><ul>
  <li><a href="Home.aspx"><span class="menu_title">Home</span></a></li>
  <li class="current_section"><a href="#"><span class="menu_title">Total Mobility</span></a><ul>
    <li><a href="TM-Setup.aspx">TM Setup Hub</a></li>
    <li><a href="TM-Platform-Fees.aspx">Platform Fees</a></li>
    <li><a href="TM-Clean-Scan.aspx">Clean-trip Scan</a></li>
    <li><a href="TM-Settlement.aspx" style="font-weight:700;color:#37474F">&#9658; Settlement</a></li>
    <li><a href="TM-Batches.aspx">Claim Batches</a></li>
  </ul></li>
</ul></div></aside>
<div id="page_content"><div id="page_content_inner">
<div class="tm-wrap">
  <div class="notice" id="set-label">BookaWaka settlement — platform fees not charged yet. chargeEnabled stays false; execute-payouts is blocked.</div>
  <div class="tm-card" style="margin-top:16px">
    <div class="tm-bar"><h3>Council invoice / paid tracking / payout plans</h3></div>
    <div class="filt">
      <div><label>Council ID</label><input id="set-council" placeholder="cncl_…"/></div>
      <div><label>Month</label><input id="set-ym" type="month"/></div>
      <div><label>Pay ref (council paid)</label><input id="set-ref" placeholder="optional"/></div>
    </div>
    <div style="padding:0 18px 16px">
      <button class="tm-btn" onclick="buildInvoice()">Build draft invoice</button>
      <button class="tm-btn" onclick="markPaid()">Mark council paid BookaWaka</button>
      <button class="tm-btn" onclick="planPayouts()">Plan company payouts</button>
      <button class="tm-btn" style="background:#C62828" onclick="executePayouts()">Execute payouts (blocked)</button>
    </div>
    <div id="set-out">Ready.</div>
  </div>
</div>
</div></div>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
(function(){
  var m=new Date();
  document.getElementById('set-ym').value=m.getFullYear()+'-'+String(m.getMonth()+1).padStart(2,'0');
})();
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
function show(j){ document.getElementById('set-out').textContent=JSON.stringify(j,null,2); }
function err(e){ document.getElementById('set-out').textContent='Error: '+(e&&e.message||e)+'\n'+JSON.stringify(e&&e.body||{},null,2); }
function buildInvoice(){
  saApi('POST','/api/sa/tm-settlement/invoice',{
    councilId: document.getElementById('set-council').value.trim(),
    ym: document.getElementById('set-ym').value.trim()
  }).then(show).catch(err);
}
function markPaid(){
  saApi('POST','/api/sa/tm-settlement/council-paid',{
    councilId: document.getElementById('set-council').value.trim(),
    ym: document.getElementById('set-ym').value.trim(),
    payRef: document.getElementById('set-ref').value.trim()||undefined
  }).then(show).catch(err);
}
function planPayouts(){
  saApi('POST','/api/sa/tm-settlement/plan-payouts',{
    councilId: document.getElementById('set-council').value.trim(),
    ym: document.getElementById('set-ym').value.trim()
  }).then(show).catch(err);
}
function executePayouts(){
  saApi('POST','/api/sa/tm-settlement/execute-payouts',{}).then(show).catch(err);
}
</script>
</body></html>
