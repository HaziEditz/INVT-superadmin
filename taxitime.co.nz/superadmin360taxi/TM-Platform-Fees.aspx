<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>TM Platform Fees &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="assets/js/jquery.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet"/>
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet"/>
<link href="assets/css/main.min.css" rel="stylesheet"/>
<link href="assets/css/bootstrap.min.css" rel="stylesheet"/>
<link href="toast/toastr.min.css" rel="stylesheet"/>
<script src="toast/toastr.min.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<style>
.tm-wrap{padding:20px;max-width:1100px}
.tm-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.tm-bar{background:#5D4037;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between}
.tm-bar h3{margin:0;font-size:15px;font-weight:600}
.tm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;background:#5D4037;color:#fff}
.filt{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding:11px 18px;background:#fafafa;border-bottom:1px solid #f0f0f0}
.filt input,.filt select{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.sum-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:14px;padding:18px}
.sum-box{background:#f9f9f9;border-radius:6px;padding:14px 16px;border-left:4px solid #5D4037}
.sum-box .sv{font-size:22px;font-weight:700;color:#5D4037}.sum-box .sl{font-size:12px;color:#9e9e9e;margin-top:2px}
.tm-tbl{width:100%;border-collapse:collapse;font-size:13px}
.tm-tbl th{background:#f5f5f5;padding:9px 11px;text-align:left;font-weight:600;border-bottom:2px solid #e0e0e0}
.tm-tbl td{padding:8px 11px;border-bottom:1px solid #f0f0f0}
.notice{padding:12px 16px;background:#FFF8E1;border-left:4px solid #E65100;font-size:13px;color:#E65100;margin:0}
.ff{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;padding:18px;max-width:720px}
.ff label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
.ff input{width:100%;padding:9px 11px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">TM Platform Fees — BookaWaka Admin</label></div>
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
<aside id="sidebar_main"><div class="sidebar_main_header"><div class="sidebar_logo">
  <a href="Home.aspx" class="sSidebar_hide"><img src="assets/img/bw-logo.png" alt="" style="height:100px;width:100px;border-radius:50%"/></a>
</div></div>
<div class="menu_section"><ul>
  <li title="Dashboard"><a href="Home.aspx"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Home</span></a></li>
  <li class="current_section" title="Total Mobility"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8CC;</i></span><span class="menu_title">Total Mobility</span></a><ul>
    <li><a href="TM-Setup.aspx">TM Setup Hub</a></li>
    <li><a href="TM-Platform-Fees.aspx" style="font-weight:700;color:#5D4037">&#9658; Platform Fees</a></li>
    <li><a href="TM-Clean-Scan.aspx">Clean-trip Scan</a></li>
    <li><a href="TM-Settlement.aspx">Settlement</a></li>
    <li><a href="TM-Batches.aspx">Claim Batches</a></li>
    <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
  </ul></li>
</ul></div></aside>
<div id="page_content"><div id="page_content_inner">
<div class="tm-wrap">
  <div class="notice" id="fee-label">BookaWaka platform fees — not charged yet</div>
  <div class="tm-card" style="margin-top:16px">
    <div class="tm-bar"><h3>Platform defaults <code style="opacity:.8;font-size:11px;margin-left:8px">platformTmFees/defaults</code></h3>
      <button class="tm-btn" style="background:rgba(255,255,255,.2)" onclick="saveDefaults()">Save defaults</button></div>
    <div class="ff">
      <div><label>Council fee per trip ($)</label><input id="fee-council" type="number" min="0" step="0.01" value="0"/></div>
      <div><label>Company fee per trip ($)</label><input id="fee-company" type="number" min="0" step="0.01" value="0"/></div>
      <div><label>chargeEnabled</label>
        <input id="fee-charge" type="checkbox" disabled/> <span style="font-size:12px;color:#888">Hard off (locked)</span>
      </div>
    </div>
    <div id="fee-msg" style="padding:0 18px 16px;font-size:12px;color:#888"></div>
  </div>
  <div class="tm-card">
    <div class="tm-bar" style="background:#6D4C41"><h3>Would-be fees this month</h3>
      <button class="tm-btn" style="background:rgba(255,255,255,.2)" onclick="loadWouldBe()">Refresh</button></div>
    <div class="filt">
      <input id="wb-month" type="month" onchange="loadWouldBe()"/>
      <select id="wb-council" onchange="loadWouldBe()"><option value="">All councils</option></select>
    </div>
    <div id="wb-summary" class="sum-grid"></div>
    <div style="overflow-x:auto;padding:0 0 12px">
      <table class="tm-tbl"><thead><tr><th>By company</th><th>Trips</th><th>Council fees</th><th>Company fees</th></tr></thead>
        <tbody id="wb-co"></tbody></table>
      <table class="tm-tbl" style="margin-top:12px"><thead><tr><th>By council</th><th>Trips</th><th>Council fees</th><th>Company fees</th></tr></thead>
        <tbody id="wb-cn"></tbody></table>
    </div>
  </div>
  <p style="font-size:12px;color:#888">Per-company overrides: <code>companySettings/{cid}/tmConfig</code> fields <code>councilFeePerTrip</code> / <code>companyFeePerTrip</code> (SA Company page).</p>
</div>
</div></div>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/uikit_custom.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
window._fbOnLogin = function() {
  var m = new Date();
  var ym = m.getFullYear() + '-' + String(m.getMonth()+1).padStart(2,'0');
  document.getElementById('wb-month').value = ym;
  adminRead('tmConfig').then(function(d){
    var o = '<option value="">All councils</option>';
    Object.entries(d||{}).forEach(function(kv){
      o += '<option value="'+kv[0]+'">'+((kv[1]&&kv[1].name)||kv[0])+'</option>';
    });
    document.getElementById('wb-council').innerHTML = o;
  });
  loadDefaults();
  loadWouldBe();
};
function loadDefaults(){
  adminRead('platformTmFees/defaults').then(function(d){
    d = d || {};
    document.getElementById('fee-council').value = d.councilFeePerTrip != null ? d.councilFeePerTrip : 0;
    document.getElementById('fee-company').value = d.companyFeePerTrip != null ? d.companyFeePerTrip : 0;
    document.getElementById('fee-charge').checked = false;
  }).catch(function(){});
}
function saveDefaults(){
  var payload = {
    councilFeePerTrip: Math.max(0, Math.round((parseFloat(document.getElementById('fee-council').value)||0)*100)/100),
    companyFeePerTrip: Math.max(0, Math.round((parseFloat(document.getElementById('fee-company').value)||0)*100)/100),
    chargeEnabled: false,
    updatedAt: Date.now()
  };
  adminWrite('platformTmFees/defaults','PUT',payload).then(function(){
    document.getElementById('fee-msg').innerHTML = '<span style="color:#2e7d32">Saved — chargeEnabled remains false.</span>';
  }).catch(function(e){
    document.getElementById('fee-msg').textContent = 'Error: '+(e&&e.message||e);
  });
}
function money(n){ return '$'+(Number(n)||0).toFixed(2); }
function loadWouldBe(){
  var month = document.getElementById('wb-month').value || '';
  var council = document.getElementById('wb-council').value || '';
  adminRead('tmTripStatus').then(function(all){
    var tripCount=0, councilFees=0, companyFees=0;
    var byCo={}, byCn={};
    function stampMonth(ts){
      var n=Number(ts); if(!n) return '';
      var d=new Date(n<1e12?n*1000:n);
      return d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0');
    }
    Object.keys(all||{}).forEach(function(cid){
      var map=all[cid]||{};
      Object.keys(map).forEach(function(rk){
        var st=map[rk]; if(!st||st.platformFeeStampAt==null||st.platformFeeStampAt==='') return;
        if(month && stampMonth(st.platformFeeStampAt)!==month) return;
        if(council && String(st.councilId||'')!==council) return;
        var cFee=Number(st.platformFeeCouncil)||0;
        var coFee=Number(st.platformFeeCompany)||0;
        tripCount++; councilFees+=cFee; companyFees+=coFee;
        if(!byCo[cid]) byCo[cid]={trips:0,c:0,co:0};
        byCo[cid].trips++; byCo[cid].c+=cFee; byCo[cid].co+=coFee;
        var cn=String(st.councilId||'unknown');
        if(!byCn[cn]) byCn[cn]={trips:0,c:0,co:0};
        byCn[cn].trips++; byCn[cn].c+=cFee; byCn[cn].co+=coFee;
      });
    });
    document.getElementById('wb-summary').innerHTML =
      '<div class="sum-box"><div class="sv">'+tripCount+'</div><div class="sl">Stamped trips</div></div>'+
      '<div class="sum-box"><div class="sv">'+money(councilFees)+'</div><div class="sl">Would-be council fees</div></div>'+
      '<div class="sum-box"><div class="sv">'+money(companyFees)+'</div><div class="sl">Would-be company fees</div></div>';
    document.getElementById('wb-co').innerHTML = Object.keys(byCo).sort().map(function(cid){
      var r=byCo[cid]; return '<tr><td>'+cid+'</td><td>'+r.trips+'</td><td>'+money(r.c)+'</td><td>'+money(r.co)+'</td></tr>';
    }).join('') || '<tr><td colspan="4" style="text-align:center;color:#aaa;padding:20px">No stamped fees for this filter</td></tr>';
    document.getElementById('wb-cn').innerHTML = Object.keys(byCn).sort().map(function(cn){
      var r=byCn[cn]; return '<tr><td>'+cn+'</td><td>'+r.trips+'</td><td>'+money(r.c)+'</td><td>'+money(r.co)+'</td></tr>';
    }).join('') || '<tr><td colspan="4" style="text-align:center;color:#aaa;padding:20px">No stamped fees for this filter</td></tr>';
  }).catch(function(e){
    document.getElementById('wb-summary').innerHTML = '<div class="sum-box"><div class="sl">'+String(e&&e.message||e)+'</div></div>';
  });
}
</script>
</body></html>
