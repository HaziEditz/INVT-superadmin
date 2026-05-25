<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Freight Delivery &mdash; Commission Rates &mdash; BookaWaka Admin</title>
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
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<style>
.fd-wrap{padding:20px}
.fd-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.fd-bar{background:#37474F;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.fd-bar h3{margin:0;font-size:15px;font-weight:600}
.fd-form-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;padding:20px}
.fd-form-label{font-size:12.5px;font-weight:600;color:#555;display:block;margin-bottom:5px}
.fd-form-input{width:100%;padding:9px 12px;border:1px solid #ddd;border-radius:4px;font-size:14px;box-sizing:border-box}
.fd-form-input:focus{outline:none;border-color:#37474F;box-shadow:0 0 0 3px rgba(55,71,79,.1)}
.fd-btn{padding:9px 22px;background:#37474F;color:#fff;border:none;border-radius:4px;font-size:13px;font-weight:600;cursor:pointer}
.fd-btn:hover{background:#263238}
.fd-tbl{width:100%;border-collapse:collapse;font-size:12.5px}
.fd-tbl th{background:#ECEFF1;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #B0BEC5;white-space:nowrap;color:#37474F}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tr:hover td{background:#F5F5F5}
.info-box{background:#ECEFF1;border-left:4px solid #546E7A;padding:12px 16px;border-radius:6px;font-size:13px;color:#546E7A;margin-bottom:18px}
.rate-highlight{font-size:32px;font-weight:700;color:#37474F}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Freight Delivery &mdash; Commission Rates &mdash; BookaWaka Admin</label></div>
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
<aside id="sidebar_main">
  <div class="sidebar_main_header"><div class="sidebar_logo">
    <a href="Home.aspx" class="sSidebar_hide"><img src="assets/img/bw-logo.png" alt="" style="height:100px;width:100px;border-radius:50%"/></a>
    <a href="Home.aspx" class="sSidebar_show"><img src="assets/img/bw-logo.png" alt="" style="height:50px;width:50px;border-radius:50%"/></a>
  </div></div>
  <div class="menu_section"><ul>
    <li title="Dashboard"><a href="Home.aspx"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Home</span></a></li>
    <li class="current_section" title="Master Entries"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE871;</i></span><span class="menu_title">Master Entries</span></a><ul>
      <li><a href="Define%20Portal%20Contents.aspx">Define Portal Contents</a></li>
      <li><a href="Define%20Registration%20Packages.aspx">Registration Packages</a></li>
      <li><a href="AdminCountriesEntry.aspx">Define Service Countries</a></li>
      <li><a href="Define%20Traveling%20Entities.aspx">Define Traveling Entities</a></li>
      <li><a href="Define%20Currency.aspx">Define Currency</a></li>
      <li><a href="Define%20Payment%20Types.aspx">Define Payment Types</a></li>
      <li><a href="Define%20Vehicle.aspx">Define Vehicles</a></li>
      <li><a href="Define%20Time%20Zone.aspx">Define Time Zones</a></li>
      <li><a href="Define%20Traveling%20Conditions.aspx">Define Traveling Conditions</a></li>
      <li><a href="Define%20Duty%20Time.aspx">Define Duty Times</a></li>
      <li><a href="Define%20Distance%20Units.aspx">Define Distance Units</a></li>
    </ul></li>
    <li class="current_section" title="Total Mobility"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8CC;</i></span><span class="menu_title">Total Mobility</span></a><ul>
      <li><a href="TM-Council-Config.aspx">Council Config</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
      <li><a href="TM-Settings.aspx">TM Settings</a></li>
      <li><a href="/council-portal" target="_blank">Council Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Pricing"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8A1;</i></span><span class="menu_title">Pricing</span></a><ul>
      <li><a href="Special-Tariffs.aspx">Special Tariffs</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Restaurants.aspx">Restaurants</a></li>
      <li><a href="FD-Orders.aspx">All Orders</a></li>
      <li><a href="FD-Payouts.aspx">Payouts</a></li>
      <li><a href="FD-Reports.aspx">Reports</a></li>
      <li><a href="FD-Commission.aspx">Commission Rates</a></li>
      <li><a href="/restaurant-portal" target="_blank">Restaurant Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Orders.aspx">All Orders</a></li>
      <li><a href="FR-Payouts.aspx">Payouts</a></li>
      <li><a href="FR-Reports.aspx">Reports</a></li>
      <li><a href="FR-Commission.aspx" style="font-weight:700;color:#37474F">&#9658; Commission Rates</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="fd-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px;color:#37474F">&#9881; Freight Delivery &mdash; Commission Rates</h2>
<p style="font-size:13px;color:#888;margin-bottom:14px">Set the default commission percentage BookaWaka takes from each freight delivery. You can also override per company.</p>

<div class="info-box">&#9432; Commission is deducted from the delivery fee. Example: $20 delivery fee at 15% commission = $3.00 to BookaWaka, $17.00 to the company.</div>

<div class="fd-card">
  <div class="fd-bar"><h3>&#127758; Global Default Commission</h3></div>
  <div style="padding:20px;display:flex;align-items:center;gap:30px;flex-wrap:wrap">
    <div>
      <div class="fd-form-label">Commission % (platform default)</div>
      <div style="display:flex;align-items:center;gap:10px">
        <input id="def-pct" type="number" min="0" max="100" step="0.5" class="fd-form-input" style="max-width:120px;font-size:22px;font-weight:700;text-align:center" placeholder="10"/>
        <span style="font-size:20px;color:#555">%</span>
      </div>
    </div>
    <div>
      <div class="fd-form-label">Min. Delivery Fee ($)</div>
      <input id="def-minfee" type="number" min="0" step="0.50" class="fd-form-input" style="max-width:120px" placeholder="5.00"/>
    </div>
    <div>
      <div class="fd-form-label">Base Distance Rate ($/km)</div>
      <input id="def-rate" type="number" min="0" step="0.10" class="fd-form-input" style="max-width:120px" placeholder="2.50"/>
    </div>
    <div style="margin-top:22px">
      <button class="fd-btn" onclick="saveDefaults()">&#10003; Save Defaults</button>
    </div>
  </div>
  <div style="padding:0 20px 16px;font-size:13px;color:#888" id="def-saved-note"></div>
</div>

<div class="fd-card">
  <div class="fd-bar"><h3>&#127970; Per-Company Overrides</h3>
    <button onclick="addOverride()" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);padding:5px 14px;border-radius:4px;font-size:12px;cursor:pointer">&#43; Add Override</button>
  </div>
  <div id="override-add" style="display:none;padding:16px;background:#f9f9f9;border-bottom:1px solid #eee">
    <div style="display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap">
      <div>
        <label class="fd-form-label">Company ID</label>
        <input id="ov-cid" type="text" class="fd-form-input" style="max-width:130px" placeholder="Company ID"/>
      </div>
      <div>
        <label class="fd-form-label">Commission %</label>
        <input id="ov-pct" type="number" min="0" max="100" step="0.5" class="fd-form-input" style="max-width:100px" placeholder="10"/>
      </div>
      <div>
        <label class="fd-form-label">Min. Fee ($)</label>
        <input id="ov-minfee" type="number" min="0" step="0.50" class="fd-form-input" style="max-width:100px" placeholder="5.00"/>
      </div>
      <div>
        <label class="fd-form-label">Note</label>
        <input id="ov-note" type="text" class="fd-form-input" style="max-width:160px" placeholder="e.g. Partner discount"/>
      </div>
      <button class="fd-btn" onclick="saveOverride()">Save Override</button>
      <button onclick="document.getElementById('override-add').style.display='none'" style="padding:9px 14px;border:1px solid #ddd;border-radius:4px;background:#fff;font-size:13px;cursor:pointer">Cancel</button>
    </div>
  </div>
  <table class="fd-tbl">
    <thead>
      <tr>
        <th>Company ID</th>
        <th>Company Name</th>
        <th>Commission %</th>
        <th>Min. Fee</th>
        <th>Note</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody id="overrides-body">
      <tr><td colspan="6" style="text-align:center;padding:20px;color:#aaa">Loading&hellip;</td></tr>
    </tbody>
  </table>
</div>

<!-- ── Driver Pay Per Company ───────────────────────────────────────────── -->
<div class="fd-card" style="margin-top:20px">
  <div class="fd-bar" style="background:#283593">
    <h3>&#128184; Driver Pay Settings (per Freight Company)</h3>
    <button onclick="loadDriverPayConfigs()" style="background:rgba(255,255,255,.15);color:#fff;border:none;cursor:pointer;padding:5px 10px;border-radius:4px;font-size:12px">&#8635; Refresh</button>
  </div>
  <div class="info-box" style="margin:14px 16px 4px;background:#E8EAF6;border-color:#283593;color:#283593">
    &#9432; Set how much each driver earns per delivery — flat dollar amount or percentage of order value.
    <strong>Instant</strong> = paid immediately when delivery is confirmed.
    <strong>Weekly/Monthly</strong> = accumulated and paid as a batch. Drivers need a Stripe account connected to receive payouts.
    <a href="FR-DriverPayouts.aspx" style="margin-left:8px;font-weight:700;color:#283593">&#128196; View Driver Payouts &rarr;</a>
  </div>
  <div style="overflow-x:auto">
    <table class="fd-tbl">
      <thead><tr>
        <th>Company</th>
        <th>Pay Model</th>
        <th>Amount</th>
        <th>Schedule</th>
        <th>Current Setting</th>
        <th>Save</th>
      </tr></thead>
      <tbody id="dp-tb"><tr><td colspan="6" style="text-align:center;padding:20px;color:#aaa">Loading&hellip;</td></tr></tbody>
    </table>
  </div>
</div>

</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script src="assets/js/fd-multi-company.js"></script>
<script>
var companies={};
var defaults={pct:10,minfee:5,rate:2.5};

function loadData(){
  _fbGet('freightConfig/defaults').then(function(d){
    d=d||{};
    defaults=d;
    document.getElementById('def-pct').value=d.commissionPct!==undefined?d.commissionPct:10;
    document.getElementById('def-minfee').value=d.minFee!==undefined?d.minFee:5;
    document.getElementById('def-rate').value=d.distanceRate!==undefined?d.distanceRate:2.5;
  });
  _fbGet('superClients').then(function(data){
    companies=data||{};
    loadOverrides();
  });
}

function loadOverrides(){
  _fbGet('freightConfig/overrides').then(function(data){
    data=data||{};
    var tbody=document.getElementById('overrides-body');
    var keys=Object.keys(data);
    if(!keys.length){
      tbody.innerHTML='<tr><td colspan="6" style="text-align:center;padding:20px;color:#aaa">No per-company overrides set. Global defaults apply to all companies.</td></tr>';
      return;
    }
    var rows='';
    keys.forEach(function(cid){
      var ov=data[cid];
      var cname=(companies[cid]&&companies[cid].name)?companies[cid].name:'—';
      rows+='<tr>' +
        '<td style="font-family:monospace;font-size:12px">'+cid+'</td>' +
        '<td>'+cname+'</td>' +
        '<td style="font-weight:700;color:#37474F">'+ov.commissionPct+'%</td>' +
        '<td>$'+parseFloat(ov.minFee||5).toFixed(2)+'</td>' +
        '<td style="color:#888;font-size:12px">'+(ov.note||'—')+'</td>' +
        '<td><button onclick="deleteOverride(\''+cid+'\')" style="padding:3px 10px;border:1px solid #FFCDD2;border-radius:4px;background:#FFEBEE;color:#C62828;font-size:12px;cursor:pointer">Remove</button></td>' +
      '</tr>';
    });
    tbody.innerHTML=rows;
  });
}

function saveDefaults(){
  var pct=parseFloat(document.getElementById('def-pct').value)||10;
  var minfee=parseFloat(document.getElementById('def-minfee').value)||5;
  var rate=parseFloat(document.getElementById('def-rate').value)||2.5;
  db.ref('freightConfig/defaults').set({commissionPct:pct,minFee:minfee,distanceRate:rate,updatedAt:Date.now()}).then(function(){
    var note=document.getElementById('def-saved-note');
    note.style.color='#2E7D32';
    note.textContent='&#10003; Defaults saved at '+new Date().toLocaleTimeString('en-NZ');
    setTimeout(function(){ note.textContent=''; },4000);
  });
}

function addOverride(){
  document.getElementById('override-add').style.display='block';
}

function saveOverride(){
  var cid=(document.getElementById('ov-cid').value||'').trim();
  var pct=parseFloat(document.getElementById('ov-pct').value)||10;
  var minfee=parseFloat(document.getElementById('ov-minfee').value)||5;
  var note=(document.getElementById('ov-note').value||'').trim();
  if(!cid){ toastr.warning('Please enter a company ID'); return; }
  db.ref('freightConfig/overrides/'+cid).set({commissionPct:pct,minFee:minfee,note:note,updatedAt:Date.now()}).then(function(){
    document.getElementById('override-add').style.display='none';
    document.getElementById('ov-cid').value='';
    document.getElementById('ov-pct').value='';
    document.getElementById('ov-minfee').value='';
    document.getElementById('ov-note').value='';
    loadOverrides();
    toastr.success('Override saved');
  });
}

function deleteOverride(cid){
  if(!confirm('Remove override for company '+cid+'? Global defaults will apply.')) return;
  db.ref('freightConfig/overrides/'+cid).remove().then(function(){
    loadOverrides();
    toastr.info('Override removed');
  });
}

window._fbOnLogin = function(){
  var urlCid=(new URLSearchParams(window.location.search)).get('cid');
  if(urlCid) COMPANY_ID=urlCid;
  loadData();
  loadDriverPayConfigs();
};
</script>

<script>
// ── Driver Pay Config per Freight Company ─────────────────────────────────────
var freightCompanies = {};
var driverPayConfigs = {};

function loadDriverPayConfigs() {
  _fbGet('freightAccess').then(function(data){
    freightCompanies = data || {};
    var cids = Object.keys(freightCompanies);
    if (!cids.length) { renderDriverPayTable(); return; }
    var done = 0;
    cids.forEach(function(cid){
      _fbGet('freightConfig/driverPay/'+cid).then(function(cfg){
        driverPayConfigs[cid] = cfg || {};
        done++;
        if (done === cids.length) renderDriverPayTable();
      });
    });
  });
}

function renderDriverPayTable() {
  var keys = Object.keys(freightCompanies);
  var tb = document.getElementById('dp-tb');
  if (!keys.length) { tb.innerHTML='<tr><td colspan="5" style="text-align:center;padding:20px;color:#aaa">No freight companies found.</td></tr>'; return; }
  keys.sort(function(a,b){ return (freightCompanies[a].name||'').localeCompare(freightCompanies[b].name||''); });
  tb.innerHTML = keys.map(function(cid){
    var c = freightCompanies[cid];
    var dp = driverPayConfigs[cid] || {};
    var model = dp.model || 'flat';
    var amount = parseFloat(dp.amount||0);
    var schedule = dp.schedule || 'weekly';
    var schedCol = schedule==='instant'?'#C62828':schedule==='weekly'?'#1565C0':'#5D4037';
    var dpDisplay = model==='flat' ? '$'+amount.toFixed(2)+' flat/delivery' : amount+'% of order';
    return '<tr>' +
      '<td><strong>'+esc(c.name||cid)+'</strong><br><small style="color:#999;font-size:11px">'+cid+'</small></td>' +
      '<td>' +
        '<select id="dpm-'+cid+'" style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px">' +
          '<option value="flat"'+(model==='flat'?' selected':'')+'>Flat $ per delivery</option>' +
          '<option value="percent"'+(model==='percent'?' selected':'')+'>% of order value</option>' +
        '</select>' +
      '</td>' +
      '<td>' +
        '<input type="number" id="dpa-'+cid+'" value="'+amount+'" min="0" step="0.01" style="width:90px;padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px"/>' +
      '</td>' +
      '<td>' +
        '<select id="dps-'+cid+'" style="padding:5px 8px;border:1px solid #ddd;border-radius:4px;font-size:12.5px">' +
          '<option value="instant"'+(schedule==='instant'?' selected':'')+'>&#9889; Instant</option>' +
          '<option value="weekly"'+(schedule==='weekly'?' selected':'')+'>&#128197; Weekly</option>' +
          '<option value="monthly"'+(schedule==='monthly'?' selected':'')+'>&#128197; Monthly</option>' +
        '</select>' +
      '</td>' +
      '<td style="font-size:12px"><span style="font-weight:700;color:'+schedCol+'">' + dpDisplay + '</span> / <span style="color:#888">' + schedule + '</span></td>' +
      '<td>' +
        '<button onclick="saveDriverPay(\''+cid+'\')" style="padding:5px 12px;background:#283593;color:#fff;border:none;border-radius:4px;font-size:12px;cursor:pointer">Save</button>' +
      '</td>' +
    '</tr>';
  }).join('');
}

function saveDriverPay(cid) {
  var model = document.getElementById('dpm-'+cid).value;
  var amount = parseFloat(document.getElementById('dpa-'+cid).value)||0;
  var schedule = document.getElementById('dps-'+cid).value;
  fetch('/api/sa-freight-driver-pay', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ companyId: cid, model: model, amount: amount, schedule: schedule })
  }).then(function(r){ return r.json(); }).then(function(d){
    if (d.error) { toastr.error(d.error); return; }
    driverPayConfigs[cid] = { model: model, amount: amount, schedule: schedule };
    renderDriverPayTable();
    toastr.success('Driver pay saved for '+(freightCompanies[cid].name||cid));
  }).catch(function(){ toastr.error('Save failed'); });
}

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
