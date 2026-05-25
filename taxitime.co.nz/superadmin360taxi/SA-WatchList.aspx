<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Passenger Watch-list &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#C62828;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.sa-tbl th{background:#FFEBEE;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #FFCDD2;white-space:nowrap;color:#B71C1C}
.sa-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none;white-space:nowrap}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.badge-flag{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.badge-warn{background:#FFF8E1;color:#F57F17;border:1px solid #FFE082}
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;margin-bottom:16px}
.kpi{background:#fff;border-radius:8px;box-shadow:0 1px 5px rgba(0,0,0,.1);padding:18px 20px;border-left:5px solid #C62828}
.kpi-val{font-size:30px;font-weight:700;color:#263238}
.kpi-lbl{font-size:12px;color:#90A4AE;margin-top:4px;font-weight:500}
.filt{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
.filt label{font-size:12px;color:#555;font-weight:600}
.filt input,.filt select{padding:6px 9px;border:1px solid #ddd;border-radius:4px;font-size:12.5px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Passenger Watch-list &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-Alerts.aspx">System Alerts</a></li>
      <li><a href="SA-WatchList.aspx" style="font-weight:700;color:#C62828">&#9658; &#9888; Passenger Watch-list</a></li>
      <li><a href="SA-EmailLog.aspx">Email Sent Log</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:16px">
  <h2 style="font-size:18px;font-weight:700;color:#263238;margin:0">&#9888; Passenger Watch-list</h2>
  <div class="filt">
    <label>Window</label>
    <select id="f-days" onchange="loadWatch()">
      <option value="30">30 days</option>
      <option value="90" selected>90 days</option>
      <option value="180">180 days</option>
      <option value="365">365 days</option>
    </select>
    <label>Min low ratings</label>
    <select id="f-min" onchange="loadWatch()">
      <option value="2" selected>2+</option>
      <option value="3">3+</option>
      <option value="5">5+</option>
    </select>
    <label>Star threshold &le;</label>
    <select id="f-star" onchange="loadWatch()">
      <option value="1">1</option>
      <option value="2" selected>2</option>
      <option value="3">3</option>
    </select>
    <input id="f-search" type="text" placeholder="Search phone or company&hellip;" oninput="renderWatch()" style="width:220px"/>
    <button onclick="loadWatch()" class="sa-btn sa-btn-n">&#8635; Refresh</button>
  </div>
</div>

<div class="kpi-row">
  <div class="kpi"><div class="kpi-val" id="kpi-total">0</div><div class="kpi-lbl">Flagged passengers</div></div>
  <div class="kpi"><div class="kpi-val" id="kpi-companies">0</div><div class="kpi-lbl">Companies affected</div></div>
  <div class="kpi"><div class="kpi-val" id="kpi-low">0</div><div class="kpi-lbl">Low ratings in window</div></div>
</div>

<div class="sa-card">
  <div class="sa-bar"><h3>&#9888; Flagged Passengers (cross-company)</h3><span id="watch-count-label" style="font-size:12px;opacity:.85"></span></div>
  <div id="watch-loading" style="padding:30px;text-align:center;color:#aaa;font-size:13px">Loading&hellip;</div>
  <div style="overflow-x:auto">
    <table class="sa-tbl" id="watch-tbl" style="display:none">
      <thead>
        <tr>
          <th>Phone</th>
          <th>Company</th>
          <th>Low ratings (window)</th>
          <th>Total ratings</th>
          <th>Avg rating</th>
          <th>Last low</th>
          <th>Last reason</th>
        </tr>
      </thead>
      <tbody id="watch-body"></tbody>
    </table>
  </div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script>
var allItems = [];

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtDt(ts){
  if(!ts) return '—';
  return new Date(ts).toLocaleString('en-NZ',{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'});
}
function fmtPhone(p){
  p = String(p||'');
  if(p.length===10 && p.charAt(0)==='0') return p.slice(0,3)+' '+p.slice(3,6)+' '+p.slice(6);
  if(p.length>=11) return '+'+p.slice(0, p.length-9)+' '+p.slice(-9, -6)+' '+p.slice(-6, -3)+' '+p.slice(-3);
  return p;
}

function loadWatch(){
  var days = document.getElementById('f-days').value;
  var min  = document.getElementById('f-min').value;
  var star = document.getElementById('f-star').value;
  var loading=document.getElementById('watch-loading');
  loading.textContent='Loading…'; loading.style.display='block'; loading.style.color='#aaa';
  document.getElementById('watch-tbl').style.display='none';

  fetch('/api/admin/passenger-watchlist?days='+days+'&minLow='+min+'&lowStarMax='+star)
    .then(function(r){ return r.json(); })
    .then(function(d){
      if(d && d.error) throw new Error(d.error);
      allItems = (d && d.items) || [];
      renderWatch();
    }).catch(function(e){
      loading.textContent='Error loading watch-list: '+String(e.message||e);
      loading.style.color='#C62828';
    });
}

function renderWatch(){
  var search=(document.getElementById('f-search').value||'').toLowerCase();
  var filtered = allItems.filter(function(it){
    if(!search) return true;
    return ((it.phone||'')+' '+(it.companyName||'')+' '+(it.companyId||'')).toLowerCase().indexOf(search) >= 0;
  });

  var totalLow = 0, companies = {};
  filtered.forEach(function(it){ totalLow += (it.lowRatingsInWindow||0); companies[it.companyId]=true; });
  document.getElementById('kpi-total').textContent = filtered.length;
  document.getElementById('kpi-companies').textContent = Object.keys(companies).length;
  document.getElementById('kpi-low').textContent = totalLow;
  document.getElementById('watch-count-label').textContent = filtered.length+' passenger'+(filtered.length!==1?'s':'')+(allItems.length!==filtered.length?' (filtered from '+allItems.length+')':'');

  var loading=document.getElementById('watch-loading');
  if(!filtered.length){
    document.getElementById('watch-tbl').style.display='none';
    loading.textContent = allItems.length ? 'No passengers match your search.' : 'No flagged passengers in this window. Nothing to action.';
    loading.style.display='block'; loading.style.color='#aaa';
    return;
  }

  var html='';
  filtered.forEach(function(it){
    var sevBadge = it.lowRatingsInWindow >= 5 ? '<span class="badge badge-flag">'+it.lowRatingsInWindow+' low</span>'
                  : '<span class="badge badge-warn">'+it.lowRatingsInWindow+' low</span>';
    html += '<tr>'
      + '<td style="font-family:monospace;font-weight:600">'+esc(fmtPhone(it.phone))+'</td>'
      + '<td>'+esc(it.companyName||'—')+'<div style="font-size:11px;color:#aaa;font-family:monospace">'+esc(it.companyId)+'</div></td>'
      + '<td>'+sevBadge+'</td>'
      + '<td>'+(it.totalRatings||0)+'</td>'
      + '<td style="font-weight:600">'+(it.avgRating||0).toFixed(1)+' &#9733;</td>'
      + '<td style="white-space:nowrap;color:#555">'+fmtDt(it.lastLowAt)+'</td>'
      + '<td style="max-width:280px;color:#555">'+esc(it.lastLowReason||'—')+'</td>'
      + '</tr>';
  });
  document.getElementById('watch-body').innerHTML=html;
  document.getElementById('watch-tbl').style.display='table';
  loading.style.display='none';
}

window._fbOnLogin = function(){ loadWatch(); };
// Fallback if bw-customize doesn't trigger _fbOnLogin
setTimeout(function(){ if(!allItems.length) loadWatch(); }, 1500);
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
