<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Driver Ops &amp; Payments &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="assets/js/jquery.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet"/>
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet"/>
<link href="assets/css/main.min.css" rel="stylesheet"/>
<link href="assets/css/Toast.css" rel="stylesheet"/>
<link href="assets/css/bootstrap.min.css" rel="stylesheet"/>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-database.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
<style>
.sa-wrap{padding:20px;max-width:1280px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:18px;overflow:hidden}
.sa-bar{background:#00695C;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:600}
.sa-btn-n{background:rgba(255,255,255,.18);color:#fff;border:1px solid rgba(255,255,255,.3)}
.sa-btn-p{background:#00695C;color:#fff}.sa-btn-p:hover{background:#004D40}
.sa-btn-g{background:#fff;border:1px solid #ddd;color:#555}
.filter-bar{display:flex;gap:10px;padding:12px 18px;background:#FAFAFA;border-bottom:1px solid #ECEFF1;flex-wrap:wrap;align-items:flex-end}
.filter-bar label{font-size:11px;font-weight:700;color:#666;text-transform:uppercase;letter-spacing:.04em;display:block;margin-bottom:3px}
.filter-bar select,.filter-bar input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:130px}
.hint{background:#E0F2F1;border:1px solid #B2DFDB;border-radius:8px;padding:12px 16px;margin-bottom:16px;font-size:13px;color:#00695C;line-height:1.5}
.stats{display:grid;grid-template-columns:repeat(auto-fill,minmax(130px,1fr));gap:10px;padding:14px 18px;border-bottom:1px solid #f0f0f0}
.stat{background:#fafafa;border:1px solid #eee;border-radius:8px;padding:10px 12px}
.stat .v{font-size:18px;font-weight:800;color:#00695C}.stat .v.owed{color:#E65100}.stat .l{font-size:10px;color:#9e9e9e;text-transform:uppercase;font-weight:700;margin-top:2px}
.tbl{width:100%;border-collapse:collapse;font-size:12px}
.tbl th{background:#E0F2F1;padding:9px 10px;text-align:left;font-weight:700;color:#00695C;border-bottom:2px solid #B2DFDB;white-space:nowrap}
.tbl td{padding:8px 10px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.tbl tr:hover td{background:#F1F8F7}
.money{font-weight:700;font-variant-numeric:tabular-nums}
.owed{color:#E65100}.pill{display:inline-block;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px}
.pill.open{background:#FFF3E0;color:#E65100}.pill.paid{background:#E8F5E9;color:#2E7D32}
.empty{text-align:center;padding:40px;color:#aaa}
.bank{font-family:monospace;font-size:11px;color:#546e7a}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Driver Ops &amp; Payments &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-DriverOpsSummary.aspx" style="font-weight:700;color:#00695C">&#9658; Driver Ops &amp; Payments</a></li>
      <li><a href="SA-MasterReport.aspx">Platform Overview</a></li>
      <li><a href="Home.aspx">More…</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">
  <h2 style="font-size:18px;font-weight:700;margin-bottom:4px">Driver Ops &amp; Payment Summary</h2>
  <p style="font-size:13px;color:#888;margin-bottom:14px">Company-scoped month-end view of what each company owes its drivers. Same rules as the owner panel.</p>

  <div class="hint">
    <b>Paid / unpaid:</b> Cash = held by driver (not owed). Card / EFTPOS / TM / Account / Hoist = company owes driver share until Mark Paid.
    Mark Paid locks that driver’s period. Bank details are reference-only for manual transfer.
  </div>

  <div class="sa-card">
    <div class="sa-bar">
      <h3 id="dos-title">Select a company</h3>
      <div style="display:flex;gap:8px">
        <button class="sa-btn sa-btn-n" onclick="dosLoad()">Refresh</button>
        <button class="sa-btn sa-btn-n" onclick="dosExportCsv()">CSV</button>
      </div>
    </div>
    <div class="filter-bar">
      <div>
        <label>Company *</label>
        <select id="dos-company" onchange="dosLoad()"><option value="">— Select company —</option></select>
      </div>
      <div>
        <label>Period</label>
        <select id="dos-mode" onchange="dosOnMode()">
          <option value="month" selected>Month</option>
          <option value="week">Week</option>
          <option value="day">Day</option>
        </select>
      </div>
      <div id="dos-month-wrap"><label>Month</label><input type="month" id="dos-month" onchange="dosLoad()"/></div>
      <div id="dos-day-wrap" style="display:none"><label>Date</label><input type="date" id="dos-day" onchange="dosLoad()"/></div>
      <div id="dos-week-wrap" style="display:none"><label>Week of</label><input type="date" id="dos-week" onchange="dosLoad()"/></div>
      <div>
        <label>Status</label>
        <select id="dos-status" onchange="dosRender()">
          <option value="">All</option>
          <option value="open">Unpaid</option>
          <option value="paid">Paid</option>
        </select>
      </div>
    </div>
    <div id="dos-stats" class="stats" style="display:none"></div>
    <div style="overflow-x:auto;max-height:620px">
      <table class="tbl">
        <thead><tr>
          <th>Driver</th><th>Hours</th><th>Jobs</th><th>Vehicles</th><th>Cash held</th><th>Company owes</th>
          <th>Card</th><th>EFTPOS</th><th>TM</th><th>Account</th><th>Hoist</th><th>Status</th><th>Bank</th><th></th>
        </tr></thead>
        <tbody id="dos-tb"><tr><td colspan="14" class="empty">Choose a company to load.</td></tr></tbody>
      </table>
    </div>
  </div>

  <div class="sa-card">
    <div class="sa-bar" style="background:#455A64"><h3>Dispatcher activity (jobs named in period)</h3></div>
    <p style="padding:10px 18px;margin:0;font-size:12px;color:#78909c">Dispatcher shift hours are not stored historically — counts only.</p>
    <div style="overflow-x:auto;max-height:260px">
      <table class="tbl">
        <thead><tr><th>Dispatcher</th><th>Jobs</th><th>Completed</th><th>Cancelled</th></tr></thead>
        <tbody id="dos-disp-tb"><tr><td colspan="4" class="empty">—</td></tr></tbody>
      </table>
    </div>
  </div>
</div>
</div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allCompanies = {};
var _dosRows = [], _dosDisp = [], _dosPeriod = null, _dosCs = {};

function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function money(n){ n=Math.round((parseFloat(n)||0)*100)/100; return '$'+n.toFixed(2); }
function classifyPm(pm){
  var s=String(pm||'').toLowerCase().replace(/[\s_-]/g,'');
  if(!s) return 'other';
  if(s.indexOf('cash')>=0) return 'cash';
  if(s.indexOf('mobility')>=0||s==='tm'||s.indexOf('totalmobility')>=0) return 'tm';
  if(s.indexOf('account')>=0||s==='acc'||s.indexOf('business')>=0||s.indexOf('corporate')>=0) return 'account';
  if(s.indexOf('eftpos')>=0) return 'eftpos';
  if(s.indexOf('card')>=0||s.indexOf('stripe')>=0||s.indexOf('visa')>=0||s.indexOf('master')>=0||s.indexOf('amex')>=0||s.indexOf('debit')>=0||s.indexOf('credit')>=0) return 'card';
  return 'other';
}
function owes(fare,pm,cs){
  var gross=Math.max(0,parseFloat(fare)||0), b=classifyPm(pm);
  if(gross<=0) return {bucket:b,gross:0,owed:0};
  if(b==='cash') return {bucket:b,gross:gross,owed:0};
  if(b==='card'||b==='eftpos'){
    var c=parseFloat(cs.companyPercent)||0, d=parseFloat(cs.driverPercent)||0;
    return {bucket:b,gross:gross,owed:Math.max(0,gross-(gross*c)/100-(gross*d)/100)};
  }
  return {bucket:b,gross:gross,owed:gross};
}
function outcome(st){
  var s=String(st||'').toLowerCase().replace(/[\s_-]/g,'');
  if(s.indexOf('complete')>=0||s==='closed'||s==='done') return 'completed';
  if(s.indexOf('cancel')>=0) return 'cancelled';
  if(s.indexOf('reject')>=0||s.indexOf('declin')>=0) return 'rejected';
  if(s.indexOf('noshow')>=0) return 'no_show';
  return 'other';
}
function parseTs(v){
  if(v==null||v==='') return 0;
  if(typeof v==='number') return v<1e12?v*1000:v;
  var n=Date.parse(String(v)); return isNaN(n)?0:n;
}
function jobTs(j){
  return parseTs(j.completedAt||j.CompletedAt||j.endTime||j.EndTime||j.finishTime||j.timestamp||j.Timestamp||j.createdAt||j.CreatedAt||j.jobDate||j.DateTime||j.dateTime);
}
function periodBounds(mode, refMs){
  var d=new Date(refMs), y=d.getFullYear(), m=d.getMonth(), day=d.getDate();
  function sod(yy,mm,dd){return new Date(yy,mm,dd,0,0,0,0).getTime();}
  function eod(yy,mm,dd){return new Date(yy,mm,dd,23,59,59,999).getTime();}
  if(mode==='day') return {mode:'day',fromMs:sod(y,m,day),toMs:eod(y,m,day),key:y+'-'+String(m+1).padStart(2,'0')+'-'+String(day).padStart(2,'0'),label:d.toLocaleDateString('en-NZ',{weekday:'short',day:'numeric',month:'short',year:'numeric'})};
  if(mode==='week'){
    var dow=(d.getDay()+6)%7, mon=new Date(y,m,day-dow), sun=new Date(mon.getFullYear(),mon.getMonth(),mon.getDate()+6);
    return {mode:'week',fromMs:sod(mon.getFullYear(),mon.getMonth(),mon.getDate()),toMs:eod(sun.getFullYear(),sun.getMonth(),sun.getDate()),
      key:'W'+mon.getFullYear()+'-'+String(mon.getMonth()+1).padStart(2,'0')+'-'+String(mon.getDate()).padStart(2,'0'),
      label:mon.toLocaleDateString('en-NZ',{day:'numeric',month:'short'})+' – '+sun.toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'})};
  }
  var last=new Date(y,m+1,0).getDate();
  return {mode:'month',fromMs:sod(y,m,1),toMs:eod(y,m,last),key:y+'-'+String(m+1).padStart(2,'0'),label:d.toLocaleDateString('en-NZ',{month:'long',year:'numeric'})};
}

window._fbOnLogin = function(){
  _fbGet('superClients').then(function(d){
    allCompanies=d||{};
    var o='<option value="">— Select company —</option>';
    Object.keys(allCompanies).sort(function(a,b){
      return String(allCompanies[a].name||a).localeCompare(String(allCompanies[b].name||b));
    }).forEach(function(cid){
      o+='<option value="'+esc(cid)+'">'+esc(allCompanies[cid].name||cid)+' ('+esc(cid)+')</option>';
    });
    document.getElementById('dos-company').innerHTML=o;
    var now=new Date();
    var ym=now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0');
    var yd=ym+'-'+String(now.getDate()).padStart(2,'0');
    document.getElementById('dos-month').value=ym;
    document.getElementById('dos-day').value=yd;
    document.getElementById('dos-week').value=yd;
  });
};

function dosOnMode(){
  var mode=document.getElementById('dos-mode').value;
  document.getElementById('dos-month-wrap').style.display=mode==='month'?'':'none';
  document.getElementById('dos-day-wrap').style.display=mode==='day'?'':'none';
  document.getElementById('dos-week-wrap').style.display=mode==='week'?'':'none';
  dosLoad();
}
function dosCurrentPeriod(){
  var mode=document.getElementById('dos-mode').value||'month';
  var ref=Date.now();
  if(mode==='month'){ var mv=document.getElementById('dos-month').value; if(mv){ var p=mv.split('-'); ref=new Date(+p[0],+p[1]-1,15).getTime(); } }
  else if(mode==='day'){ var dv=document.getElementById('dos-day').value; if(dv) ref=new Date(dv+'T12:00:00').getTime(); }
  else { var wv=document.getElementById('dos-week').value; if(wv) ref=new Date(wv+'T12:00:00').getTime(); }
  return periodBounds(mode, ref);
}

function dosLoad(){
  var cid=document.getElementById('dos-company').value;
  if(!cid){
    document.getElementById('dos-tb').innerHTML='<tr><td colspan="14" class="empty">Choose a company to load.</td></tr>';
    document.getElementById('dos-stats').style.display='none';
    document.getElementById('dos-title').textContent='Select a company';
    return;
  }
  _dosPeriod=dosCurrentPeriod();
  document.getElementById('dos-title').textContent=(allCompanies[cid]&&allCompanies[cid].name||cid)+' — '+_dosPeriod.label;
  document.getElementById('dos-tb').innerHTML='<tr><td colspan="14" class="empty">Loading…</td></tr>';

  Promise.all([
    _fbGet('companies/'+cid+'/cardSettings').catch(function(){return {};}),
    _fbGet('drivers').catch(function(){return null;}),
    _fbGet('drivers/'+cid).catch(function(){return null;}),
    _fbGet('joback',{limitToLast:800}).catch(function(){return null;}),
    _fbGet('completedJobs/'+cid).catch(function(){return null;}),
    _fbGet('closedJobs/'+cid).catch(function(){return null;}),
    _fbGet('allbookings/'+cid).catch(function(){return null;}),
    _fbGet('shiftLogs/'+cid).catch(function(){return null;}),
    _fbGet('driverSettlements/'+cid+'/'+_dosPeriod.key).catch(function(){return null;})
  ]).then(function(res){
    _dosCs=res[0]||{};
    var driversMeta={};
    function ingest(d){
      if(!d||typeof d!=='object') return;
      Object.keys(d).forEach(function(k){
        var v=d[k]; if(!v||typeof v!=='object') return;
        if(v.companyId && String(v.companyId)!==String(cid) && !String(k).startsWith(cid)) {
          // keep if nested under drivers/{cid} path — flat drivers may be multi-company
        }
        var id=String(v.id||v.driverId||v.dispatcherId||k);
        var name=[v.firstName||'',v.lastName||'',v.name||''].join(' ').trim()||id;
        var meta={name:name,bankName:v.bankName||'',accountName:v.accountName||'',accountNumber:v.accountNumber||'',pushKey:k};
        if(v.companyId && String(v.companyId)!==String(cid)) return;
        driversMeta[id]=meta;
        if(v.dispatcherId) driversMeta[String(v.dispatcherId)]=meta;
        driversMeta[k]=meta;
      });
    }
    ingest(res[1]); ingest(res[2]);

    var merged={};
    function addNested(data){
      if(!data||typeof data!=='object') return;
      Object.keys(data).forEach(function(bid){
        if(!merged[bid]) merged[bid]={};
        var drivers=data[bid];
        if(drivers&&typeof drivers==='object') Object.assign(merged[bid], drivers);
      });
    }
    function addFlat(data){
      if(!data||typeof data!=='object') return;
      Object.keys(data).forEach(function(bid){
        var job=data[bid]; if(!job||typeof job!=='object') return;
        var did=String(job.driverId||job.DriverId||job.driverid||'').trim();
        if(!did) return;
        if(!merged[bid]) merged[bid]={};
        if(!merged[bid][did]) merged[bid][did]={};
        Object.assign(merged[bid][did], job);
      });
    }
    addNested(res[3]); addFlat(res[4]); addFlat(res[5]);
    if(res[6]&&typeof res[6]==='object'){
      Object.keys(res[6]).forEach(function(bid){
        var job=res[6][bid]; if(!job||typeof job!=='object') return;
        if(!merged[bid]) merged[bid]={};
        var vals=Object.values(job);
        var isFlat=vals.length>0&&vals.every(function(v){return v===null||typeof v!=='object';});
        if(isFlat){
          var did=String(job.driverId||job.DriverId||'').trim();
          if(!did) return;
          if(!merged[bid][did]) merged[bid][did]={};
          Object.assign(merged[bid][did], job);
        } else {
          Object.keys(job).forEach(function(did){
            var j=job[did]; if(!j||typeof j!=='object') return;
            if(!did || did===bid) return;
            if(!merged[bid][did]) merged[bid][did]={};
            Object.assign(merged[bid][did], j);
          });
        }
      });
    }

    var allJobs=[];
    Object.keys(merged).forEach(function(bid){
      Object.keys(merged[bid]||{}).forEach(function(did){
        var j=merged[bid][did]; if(!j||typeof j!=='object') return;
        var copy=Object.assign({},j);
        copy.bookingId=copy.bookingId||bid;
        copy.driverId=String(copy.driverId||copy.DriverId||did||'').trim();
        if(!copy.driverId || copy.driverId===bid || copy.driverId===String(copy.bookingId||'')) return;
        var ts=jobTs(copy);
        if(ts>=_dosPeriod.fromMs && ts<=_dosPeriod.toMs) allJobs.push(copy);
      });
    });

    var shiftMins={};
    if(res[7]&&typeof res[7]==='object'){
      Object.keys(res[7]).forEach(function(driverId){
        var shifts=res[7][driverId]; if(!shifts||typeof shifts!=='object') return;
        var work=0, brk=0;
        Object.keys(shifts).forEach(function(sid){
          var s=shifts[sid]; if(!s||typeof s!=='object') return;
          var st=parseTs(s.startTime||s.loginTime||s.start);
          var en=parseTs(s.endTime||s.logoutTime||s.end||s.finishTime);
          if(!st||st>_dosPeriod.toMs) return;
          if(en && en<_dosPeriod.fromMs) return;
          var cs=Math.max(st,_dosPeriod.fromMs), ce=en?Math.min(en,_dosPeriod.toMs):Math.min(Date.now(),_dosPeriod.toMs);
          if(ce>cs) work+=Math.round((ce-cs)/60000);
          brk+=parseInt(s.breakMinutes||s.breakMin||0,10)||0;
        });
        shiftMins[driverId]={workMinutes:work,breakMinutes:brk};
      });
    }

    var settlements=res[8]||{};
    var byDriver={};
    allJobs.forEach(function(j){
      var did=String(j.driverId||''); if(!did) return;
      if(!byDriver[did]) byDriver[did]=[];
      byDriver[did].push(j);
    });
    Object.keys(shiftMins).forEach(function(did){ if(!byDriver[did]) byDriver[did]=[]; });

    var dispMap={};
    allJobs.forEach(function(j){
      var dn=String(j.DispatcherName||j.dispatcherName||j.dispatcher||j.bookedBy||'').trim();
      if(!dn) return;
      if(!dispMap[dn]) dispMap[dn]={name:dn,total:0,completed:0,cancelled:0};
      dispMap[dn].total++;
      var o=outcome(j.jobstatus||j.JobStatus||j.status||'');
      if(o==='completed') dispMap[dn].completed++;
      if(o==='cancelled') dispMap[dn].cancelled++;
    });
    _dosDisp=Object.keys(dispMap).map(function(k){return dispMap[k];}).sort(function(a,b){return b.total-a.total;});

    _dosRows=Object.keys(byDriver).map(function(did){
      var meta=driversMeta[did]||{};
      var sm=shiftMins[did]||{workMinutes:0,breakMinutes:0};
      var settle=settlements[did]||(meta.pushKey&&settlements[meta.pushKey])||null;
      var pay={cash:{gross:0,owed:0},card:{gross:0,owed:0},eftpos:{gross:0,owed:0},tm:{gross:0,owed:0},hoist:{gross:0,owed:0,uses:0},account:{gross:0,owed:0},other:{gross:0,owed:0}};
      var outcomes={completed:0,cancelled:0,rejected:0,no_show:0,other:0,total:0};
      var vehicles={};
      byDriver[did].forEach(function(job){
        var o=outcome(job.jobstatus||job.JobStatus||job.status||'');
        outcomes[o]=(outcomes[o]||0)+1; outcomes.total++;
        var veh=String(job.vehicleId||job.VehicleId||job.taxiNumber||'').trim();
        if(veh) vehicles[veh]=1;
        if(o!=='completed') return;
        var fare=parseFloat(job.TotalFare||job.totalFare||job.Fare||job.fare||0);
        var pm=job.PaymentType||job.paymentType||job.PaymentMethod||'';
        var main=owes(fare,pm,_dosCs);
        pay[main.bucket].gross+=main.gross; pay[main.bucket].owed+=main.owed;
        var hoistAmt=parseFloat(job.tmSubsidyHoist||job.hoistFare||job.HoistFare||0);
        var hoistUses=parseInt(job.hoistUses||job.HoistUses||0,10)||0;
        if(hoistAmt>0||hoistUses>0){ pay.hoist.gross+=hoistAmt; pay.hoist.owed+=hoistAmt; pay.hoist.uses=(pay.hoist.uses||0)+hoistUses; }
      });
      var owed=pay.card.owed+pay.eftpos.owed+pay.tm.owed+pay.hoist.owed+pay.account.owed+pay.other.owed;
      var locked=!!(settle&&(settle.locked||settle.status==='paid'));
      return {
        driverId:did, driverName:meta.name||did,
        workHours:Math.round((sm.workMinutes/60)*10)/10, breakMinutes:sm.breakMinutes||0,
        outcomes:outcomes, vehicles:Object.keys(vehicles).sort(), pay:pay,
        cashHeld:pay.cash.gross, owedTotal:locked?0:Math.round(owed*100)/100, owedBeforeLock:Math.round(owed*100)/100,
        status:locked?'paid':'open', locked:locked,
        bankName:meta.bankName, accountName:meta.accountName, accountNumber:meta.accountNumber
      };
    }).filter(function(r){ return r.outcomes.total>0||r.workHours>0||r.owedBeforeLock>0; });

    dosRender();
  }).catch(function(e){
    document.getElementById('dos-tb').innerHTML='<tr><td colspan="14" class="empty">Error: '+esc(e&&e.message||e)+'</td></tr>';
  });
}

function dosRender(){
  var sf=document.getElementById('dos-status').value;
  var rows=_dosRows.filter(function(r){ return !sf||r.status===sf; }).slice().sort(function(a,b){ return b.owedTotal-a.owedTotal; });
  var unpaid=0,cash=0,jobs=0,paidN=0;
  rows.forEach(function(r){ unpaid+=r.owedTotal; cash+=r.cashHeld; jobs+=r.outcomes.total; if(r.status==='paid') paidN++; });
  document.getElementById('dos-stats').style.display='grid';
  document.getElementById('dos-stats').innerHTML=
    '<div class="stat"><div class="v">'+rows.length+'</div><div class="l">Drivers</div></div>'+
    '<div class="stat"><div class="v owed">'+money(unpaid)+'</div><div class="l">Total unpaid</div></div>'+
    '<div class="stat"><div class="v">'+money(cash)+'</div><div class="l">Cash held</div></div>'+
    '<div class="stat"><div class="v">'+paidN+'</div><div class="l">Paid / locked</div></div>'+
    '<div class="stat"><div class="v">'+jobs+'</div><div class="l">Jobs</div></div>';

  if(!rows.length){
    document.getElementById('dos-tb').innerHTML='<tr><td colspan="14" class="empty">No driver activity in this period.</td></tr>';
  } else {
    document.getElementById('dos-tb').innerHTML=rows.map(function(r){
      var mark=r.locked
        ? '<button class="sa-btn sa-btn-g" disabled>Paid</button>'
        : '<button class="sa-btn sa-btn-p" onclick="dosMarkPaid(\''+esc(r.driverId)+'\')">Mark Paid</button>';
      return '<tr>'+
        '<td><b>'+esc(r.driverName)+'</b><div style="font-size:10px;color:#90a4ae">'+esc(r.driverId)+'</div></td>'+
        '<td>'+r.workHours+'h</td>'+
        '<td>'+r.outcomes.completed+'/'+r.outcomes.cancelled+'/'+r.outcomes.rejected+'/'+r.outcomes.no_show+'</td>'+
        '<td>'+esc(r.vehicles.join(', ')||'—')+'</td>'+
        '<td class="money">'+money(r.cashHeld)+'</td>'+
        '<td class="money owed">'+money(r.owedTotal)+(r.locked?' <span style="font-size:10px;color:#2E7D32">('+money(r.owedBeforeLock)+')</span>':'')+'</td>'+
        '<td class="money">'+money(r.pay.card.owed)+'</td>'+
        '<td class="money">'+money(r.pay.eftpos.owed)+'</td>'+
        '<td class="money">'+money(r.pay.tm.owed)+'</td>'+
        '<td class="money">'+money(r.pay.account.owed)+'</td>'+
        '<td class="money">'+money(r.pay.hoist.owed)+'</td>'+
        '<td><span class="pill '+r.status+'">'+(r.status==='paid'?'Paid':'Unpaid')+'</span></td>'+
        '<td class="bank">'+esc(r.accountNumber||'—')+'</td>'+
        '<td>'+mark+'</td></tr>';
    }).join('');
  }

  document.getElementById('dos-disp-tb').innerHTML=_dosDisp.length
    ? _dosDisp.map(function(d){ return '<tr><td>'+esc(d.name)+'</td><td><b>'+d.total+'</b></td><td>'+d.completed+'</td><td>'+d.cancelled+'</td></tr>'; }).join('')
    : '<tr><td colspan="4" class="empty">No dispatcher names on jobs.</td></tr>';
}

function dosMarkPaid(driverId){
  var cid=document.getElementById('dos-company').value;
  var r=_dosRows.find(function(x){return x.driverId===driverId;});
  if(!r||!cid||r.locked) return;
  if(!confirm('Mark '+r.driverName+' paid for '+_dosPeriod.label+'?\nAmount: '+money(r.owedBeforeLock)+'\nThis locks the period.')) return;
  var payload={
    status:'paid', locked:true, amountPaid:r.owedBeforeLock,
    periodKey:_dosPeriod.key, periodLabel:_dosPeriod.label,
    fromMs:_dosPeriod.fromMs, toMs:_dosPeriod.toMs,
    driverId:driverId, driverName:r.driverName,
    cashHeld:r.cashHeld, pay:r.pay,
    paidAt:Date.now(), paidBy:'superadmin'
  };
  _fbPost('driverSettlements/'+cid+'/'+_dosPeriod.key+'/'+driverId,'PUT',payload).then(function(){
    r.locked=true; r.status='paid'; r.owedTotal=0; dosRender();
  }).catch(function(e){ alert('Mark paid failed: '+(e&&e.message||e)); });
}

function dosExportCsv(){
  var sf=document.getElementById('dos-status').value;
  var rows=_dosRows.filter(function(r){ return !sf||r.status===sf; });
  var cid=document.getElementById('dos-company').value;
  var lines=[['Company','Driver','DriverId','Period','Hours','Jobs','CashHeld','Owed','Card','EFTPOS','TM','Account','Hoist','Status','AccountNumber'].join(',')];
  rows.forEach(function(r){
    function q(v){ v=String(v==null?'':v); return /[",\n]/.test(v)?'"'+v.replace(/"/g,'""')+'"':v; }
    lines.push([cid,r.driverName,r.driverId,_dosPeriod&&_dosPeriod.label,r.workHours,r.outcomes.total,
      r.cashHeld.toFixed(2),r.owedTotal.toFixed(2),r.pay.card.owed.toFixed(2),r.pay.eftpos.owed.toFixed(2),
      r.pay.tm.owed.toFixed(2),r.pay.account.owed.toFixed(2),r.pay.hoist.owed.toFixed(2),r.status,r.accountNumber||''].map(q).join(','));
  });
  var a=document.createElement('a');
  a.href=URL.createObjectURL(new Blob([lines.join('\n')],{type:'text/csv'}));
  a.download='driver-ops-'+cid+'-'+(_dosPeriod&&_dosPeriod.key||'x')+'.csv';
  a.click();
}
</script>
</body>
</html>
