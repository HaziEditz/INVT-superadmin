<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Account / ACC Settlements &mdash; BookaWaka Admin</title>
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
firebase.initializeApp({apiKey:"AIzaSyDIVSI_GRYG0hCPvc9h80QXZMxwZoejctQ",authDomain:"bookawaka2026-564e1.firebaseapp.com",databaseURL:"https://bookawaka2026-564e1-default-rtdb.firebaseio.com",projectId:"bookawaka2026-564e1",storageBucket:"bookawaka2026-564e1.firebasestorage.app"});
</script>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
<style>
.sa-wrap{padding:20px;max-width:1400px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:18px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:600}
.sa-btn-n{background:rgba(255,255,255,.18);color:#fff;border:1px solid rgba(255,255,255,.3)}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-g{background:#fff;border:1px solid #ddd;color:#555}
.filter-bar{display:flex;gap:10px;padding:12px 18px;background:#FAFAFA;border-bottom:1px solid #ECEFF1;flex-wrap:wrap;align-items:flex-end}
.filter-bar label{font-size:11px;font-weight:700;color:#666;text-transform:uppercase;letter-spacing:.04em;display:block;margin-bottom:3px}
.filter-bar select,.filter-bar input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:130px}
.hint{background:#E3F2FD;border:1px solid #90CAF9;border-radius:8px;padding:12px 16px;margin-bottom:16px;font-size:13px;color:#1565C0;line-height:1.55}
.hint b{color:#0D47A1}
.stats{display:grid;grid-template-columns:repeat(auto-fill,minmax(130px,1fr));gap:10px;padding:14px 18px;border-bottom:1px solid #f0f0f0}
.stat{background:#fafafa;border:1px solid #eee;border-radius:8px;padding:10px 12px}
.stat .v{font-size:18px;font-weight:800;color:#1565C0}.stat .v.owed{color:#E65100}.stat .l{font-size:10px;color:#9e9e9e;text-transform:uppercase;font-weight:700;margin-top:2px}
.tbl-wrap{overflow-x:auto;max-height:640px;overflow-y:auto}
.tbl{width:100%;border-collapse:collapse;font-size:12px;min-width:980px}
.tbl th{background:#E3F2FD;padding:9px 10px;text-align:left;font-weight:700;color:#1565C0;border-bottom:2px solid #90CAF9;white-space:nowrap}
.tbl td{padding:8px 10px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.tbl tr:hover td{background:#F5F9FF}
.money{font-weight:700;font-variant-numeric:tabular-nums}
.owed{color:#E65100}.pill{display:inline-block;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px}
.pill.open{background:#FFF3E0;color:#E65100}.pill.paid{background:#E8F5E9;color:#2E7D32}
.empty{text-align:center;padding:40px;color:#aaa}
.bank{font-family:monospace;font-size:11px;color:#546e7a}
.ads-sub{font-size:10px;color:#90a4ae;margin-top:2px}
.ads-zero{color:#bdbdbd}
.sa-ov{display:none;position:fixed;inset:0;background:rgba(15,23,42,.45);z-index:10000;align-items:flex-start;justify-content:center;overflow-y:auto;padding:28px 16px}
.sa-ov.show{display:flex}
.sa-modal{background:#fff;border-radius:12px;width:780px;max-width:100%;box-shadow:0 20px 60px rgba(0,0,0,.22);margin:auto;overflow:hidden}
.sa-modal-h{padding:14px 18px;background:linear-gradient(135deg,#1565C0,#1E88E5);color:#fff;display:flex;justify-content:space-between;align-items:center}
.sa-modal-h h3{margin:0;font-size:15px}
.sa-modal-b{padding:16px 18px;max-height:72vh;overflow-y:auto}
.sa-kv{display:grid;grid-template-columns:repeat(3,1fr);gap:8px 16px;margin-bottom:8px}
.sa-kv .k{font-size:10px;font-weight:700;color:#9e9e9e;text-transform:uppercase;letter-spacing:.3px}
.sa-kv .val{font-size:13px;font-weight:600;color:#212121}
.sa-note{font-size:11px;color:#78909c;margin-top:10px;line-height:1.5}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Account / ACC Settlements &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-DriverOpsSummary.aspx">Driver Ops &amp; Payments</a></li>
      <li><a href="SA-AccountDriverSettlements.aspx" style="font-weight:700;color:#1565C0">&#9658; Account / ACC Settlements</a></li>
      <li><a href="SA-MasterReport.aspx">Platform Overview</a></li>
      <li><a href="Home.aspx">More&hellip;</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">
  <h2 style="font-size:18px;font-weight:700;margin-bottom:4px">Account / ACC Driver Settlements</h2>
  <p style="font-size:13px;color:#888;margin-bottom:14px">Company-scoped unpaid tracker for Account and ACC jobs. Isolated from BookaWaka Card/TM/Hoist Mark Paid.</p>

  <div class="hint">
    <b>Ledger:</b> <code>accountDriverSettlements/{companyId}/{periodKey}/{driverId}</code> — separate from <code>driverSettlements</code>.
    Mark Paid locks the Account/ACC period for that driver (full fare owed). Does not change Driver Ops BookaWaka owed math.
  </div>

  <div class="sa-card">
    <div class="sa-bar">
      <h3 id="ads-title">Select a company</h3>
      <div style="display:flex;gap:8px">
        <button class="sa-btn sa-btn-n" onclick="adsLoad()">Refresh</button>
        <button class="sa-btn sa-btn-n" onclick="adsExportCsv()">CSV</button>
      </div>
    </div>
    <div class="filter-bar">
      <div>
        <label>Company *</label>
        <select id="ads-company" required onchange="adsLoad()"><option value="">&mdash; Select company &mdash;</option></select>
      </div>
      <div>
        <label>Period</label>
        <select id="ads-mode" onchange="adsOnMode()">
          <option value="month" selected>Month</option>
          <option value="week">Week</option>
          <option value="day">Day</option>
          <option value="range">Custom range</option>
        </select>
      </div>
      <div id="ads-month-wrap">
        <label>Month</label>
        <input type="month" id="ads-month" onchange="adsLoad()"/>
      </div>
      <div id="ads-day-wrap" style="display:none">
        <label>Date</label>
        <input type="date" id="ads-day" onchange="adsLoad()"/>
      </div>
      <div id="ads-week-wrap" style="display:none">
        <label>Week of</label>
        <input type="date" id="ads-week" onchange="adsLoad()"/>
      </div>
      <div id="ads-range-wrap" style="display:none">
        <label>From</label>
        <input type="date" id="ads-range-from" onchange="adsLoad()"/>
      </div>
      <div id="ads-range-to-wrap" style="display:none">
        <label>To</label>
        <input type="date" id="ads-range-to" onchange="adsLoad()"/>
      </div>
      <div>
        <label>Status</label>
        <select id="ads-status" onchange="adsRender()">
          <option value="">All</option>
          <option value="open">Unpaid only</option>
          <option value="paid">Paid / locked</option>
        </select>
      </div>
    </div>
    <div id="ads-empty" class="empty">Select a company to load Account / ACC settlements.</div>
    <div id="ads-main" style="display:none">
      <div class="stats" id="ads-stats"></div>
      <div class="tbl-wrap">
        <table class="tbl">
          <thead>
            <tr>
              <th>Driver</th>
              <th>Completed</th>
              <th>Outcomes</th>
              <th>Account refs</th>
              <th>Vehicles</th>
              <th>Company owes</th>
              <th>Status</th>
              <th>Bank</th>
              <th></th>
            </tr>
          </thead>
          <tbody id="ads-tbody"></tbody>
        </table>
      </div>
    </div>
  </div>
</div>
</div></div>

<div class="sa-ov" id="ads-detail-ov" onclick="if(event.target===this)adsCloseDetail()">
  <div class="sa-modal">
    <div class="sa-modal-h">
      <h3 id="ads-detail-title">Driver detail</h3>
      <button class="sa-btn sa-btn-n" onclick="adsCloseDetail()">Close</button>
    </div>
    <div class="sa-modal-b" id="ads-detail-body"></div>
  </div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var allCompanies = {};
var _adsRows = [], _adsPeriod = null, _adsDriversMeta = {};

function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function money(n){ n=Math.round((parseFloat(n)||0)*100)/100; return '$'+n.toFixed(2); }
function adsParseTs(v){
  if(v==null||v==='') return 0;
  if(typeof v==='number'){ if(!isFinite(v)||v<=0) return 0; return v>1e12?v:(v>1e10?v:v*1000); }
  var n=Number(v); if(!isNaN(n)&&n>0) return n>1e12?n:(n>1e10?n:n*1000);
  var t=Date.parse(String(v)); return isNaN(t)?0:t;
}
function adsJobTs(j){
  return adsParseTs(j.completedAt||j.CompletedAt||j.endTime||j.EndTime||j.finishTime||
    j.timestamp||j.Timestamp||j.createdAt||j.CreatedAt||j.jobDate||j.JobDate||j.dateTime||j.DateTime);
}
function adsIsCompanyKey(k, companyId){
  var s=String(k||''); if(!s) return false;
  if(companyId!=null && String(companyId)!=='' && s===String(companyId)) return true;
  return /^\d+$/.test(s);
}
function adsIsLegacyDriverId(id){ return /^D\d+/i.test(String(id||'').trim()); }
function adsClassifyPm(pm){
  var s=String(pm||'').toLowerCase().replace(/[\s_-]/g,'');
  if(!s) return 'other';
  if(s.indexOf('account')>=0||s==='acc'||s.indexOf('business')>=0||s.indexOf('corporate')>=0) return 'account';
  return 'other';
}
function adsIsAccountPm(pm){ return adsClassifyPm(pm)==='account'; }
function adsNormalizeOutcome(status){
  var s=String(status||'').toLowerCase().replace(/[\s_-]/g,'');
  if(!s) return 'other';
  if(s.indexOf('complete')>=0||s==='closed'||s==='done'||s==='finished') return 'completed';
  if(s.indexOf('cancel')>=0) return 'cancelled';
  if(s.indexOf('reject')>=0||s.indexOf('declin')>=0) return 'rejected';
  if(s.indexOf('noshow')>=0||s==='ns') return 'no_show';
  return 'other';
}
function adsFormatPay(amt, count){
  var n=Math.round((parseFloat(amt)||0)*100)/100;
  var c=parseInt(count,10)||0;
  var m='$'+n.toFixed(2);
  return c>0?(m+' \u00d7'+c):m;
}
function adsPeriodBounds(mode, refMs, rangeFromYmd, rangeToYmd){
  refMs = refMs || Date.now();
  var d=new Date(refMs), y=d.getFullYear(), m=d.getMonth(), day=d.getDate();
  function sod(yy,mm,dd){ return new Date(yy,mm,dd,0,0,0,0).getTime(); }
  function eod(yy,mm,dd){ return new Date(yy,mm,dd,23,59,59,999).getTime(); }
  if(mode==='range'){
    var fromParts=String(rangeFromYmd||'').split('-').map(Number);
    var toParts=String(rangeToYmd||rangeFromYmd||'').split('-').map(Number);
    if(fromParts.length===3 && fromParts[0] && toParts.length===3 && toParts[0]){
      var fromMs=sod(fromParts[0],fromParts[1]-1,fromParts[2]);
      var toMs=eod(toParts[0],toParts[1]-1,toParts[2]);
      if(toMs<fromMs){ var tmp=fromMs; fromMs=sod(toParts[0],toParts[1]-1,toParts[2]); toMs=eod(fromParts[0],fromParts[1]-1,fromParts[2]); }
      var fromLabel=new Date(fromMs).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'});
      var toLabel=new Date(toMs).toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'});
      return {mode:'range', fromMs:fromMs, toMs:toMs, key:'R'+rangeFromYmd+'_'+(rangeToYmd||rangeFromYmd),
        label: fromLabel===toLabel?fromLabel:(fromLabel+' \u2013 '+toLabel)};
    }
  }
  if(mode==='day'){
    return {mode:'day', fromMs:sod(y,m,day), toMs:eod(y,m,day),
      key:y+'-'+String(m+1).padStart(2,'0')+'-'+String(day).padStart(2,'0'),
      label:d.toLocaleDateString('en-NZ',{weekday:'short',day:'numeric',month:'short',year:'numeric'})};
  }
  if(mode==='week'){
    var dow=(d.getDay()+6)%7;
    var mon=new Date(y,m,day-dow);
    var sun=new Date(mon.getFullYear(),mon.getMonth(),mon.getDate()+6);
    return {mode:'week', fromMs:sod(mon.getFullYear(),mon.getMonth(),mon.getDate()), toMs:eod(sun.getFullYear(),sun.getMonth(),sun.getDate()),
      key:'W'+mon.getFullYear()+'-'+String(mon.getMonth()+1).padStart(2,'0')+'-'+String(mon.getDate()).padStart(2,'0'),
      label:mon.toLocaleDateString('en-NZ',{day:'numeric',month:'short'})+' \u2013 '+sun.toLocaleDateString('en-NZ',{day:'numeric',month:'short',year:'numeric'})};
  }
  var last=new Date(y,m+1,0).getDate();
  return {mode:'month', fromMs:sod(y,m,1), toMs:eod(y,m,last), key:y+'-'+String(m+1).padStart(2,'0'),
    label:d.toLocaleDateString('en-NZ',{month:'long',year:'numeric'})};
}
function adsBuildRow(opts){
  var jobs=opts.jobs||[], settlement=opts.settlement||null;
  var ledgerJobs=[], gross=0, completedCount=0, cancelled=0, rejected=0, noShow=0, otherOut=0;
  var vehicles={}, accountRefs={};
  jobs.forEach(function(job){
    var pm=job.PaymentType||job.paymentType||job.PaymentMethod||job.paymentMethod||'';
    if(!adsIsAccountPm(pm)) return;
    ledgerJobs.push(job);
    var outcome=adsNormalizeOutcome(job.jobstatus||job.JobStatus||job.status||job.Status||'');
    if(outcome==='cancelled') cancelled++;
    else if(outcome==='rejected') rejected++;
    else if(outcome==='no_show') noShow++;
    else if(outcome!=='completed') otherOut++;
    var veh=String(job.vehicleId||job.VehicleId||job.taxiNumber||job.TaxiNumber||job.carNumber||'').trim();
    if(veh) vehicles[veh]=(vehicles[veh]||0)+1;
    var ref=String(job.accountNumber||job.AccountNumber||job.accountCode||job.AccountCode||job.accountId||job.AccountId||job.accClientId||'').trim();
    if(ref) accountRefs[ref]=(accountRefs[ref]||0)+1;
    if(outcome!=='completed') return;
    completedCount++;
    gross += parseFloat(job.TotalFare||job.totalFare||job.Fare||job.fare||job.RideCost||job.EstimatedFare||0)||0;
  });
  gross=Math.round(gross*100)/100;
  var locked=!!(settlement&&(settlement.locked||settlement.status==='paid'));
  return {
    driverId:String(opts.driverId||''), driverName:String(opts.driverName||opts.driverId||'Driver'),
    jobs:ledgerJobs, jobCount:ledgerJobs.length, completedCount:completedCount,
    cancelled:cancelled, rejected:rejected, noShow:noShow, otherOutcomes:otherOut,
    gross:gross, owedTotal:locked?0:gross, owedBeforeLock:gross,
    status:locked?'paid':'open', locked:locked, settlement:settlement,
    vehicles:Object.keys(vehicles).sort(), accountRefs:Object.keys(accountRefs).sort(),
    bankName:opts.bankName||'', accountName:opts.accountName||'', accountNumber:opts.accountNumber||''
  };
}
function adsResolveDriverId(rawId, canonMap, companyId){
  if(rawId==null||rawId===''||rawId==='0') return null;
  var id=String(rawId);
  if(adsIsCompanyKey(id, companyId)) return null;
  if(canonMap && canonMap[id]) return canonMap[id];
  return id;
}
function adsBuildCanon(driversRoot, driversCid, companyId){
  var canon={}, names={};
  function setCanon(alias, canonId, name){
    if(alias==null||alias==='') return;
    var a=String(alias); if(adsIsCompanyKey(a, companyId)) return;
    var c=String(canonId); if(!c||adsIsCompanyKey(c, companyId)) return;
    if(canon[a] && adsIsLegacyDriverId(canon[a]) && !adsIsLegacyDriverId(c)) return;
    canon[a]=c; if(name){ names[a]=name; names[c]=name; }
  }
  function ingest(key, d, fromCompanyScoped){
    if(!d||typeof d!=='object') return;
    if(adsIsCompanyKey(key, companyId) && !d.name && !d.email){
      Object.keys(d).forEach(function(childKey){ ingest(childKey, d[childKey], true); });
      return;
    }
    if(!fromCompanyScoped && d.companyId!=null && companyId && String(d.companyId)!==String(companyId)) return;
    if(/^\d+$/.test(String(key)) && !d.name && !d.email && !d.firstName) return;
    var name=[d.firstName||'', d.lastName||'', d.name||''].join(' ').trim() || d.email || d.dispatcherId || '';
    var candidates=[d.dispatcherId, d.id, d.driverId, d.DriverId, key];
    var canonId='';
    for(var i=0;i<candidates.length;i++){
      var c=candidates[i];
      if(c!=null && String(c).trim()!=='' && adsIsLegacyDriverId(c)){ canonId=String(c).trim(); break; }
    }
    if(!canonId){
      for(var j=0;j<candidates.length;j++){
        var c2=candidates[j];
        if(c2!=null && String(c2).trim()!==''){ canonId=String(c2).trim(); break; }
      }
    }
    if(!canonId || adsIsCompanyKey(canonId, companyId)) return;
    setCanon(key, canonId, name||canonId);
    setCanon(d.uid, canonId, name||canonId);
    setCanon(d.id, canonId, name||canonId);
    setCanon(d.driverId, canonId, name||canonId);
    setCanon(d.dispatcherId, canonId, name||canonId);
    setCanon(canonId, canonId, name||canonId);
  }
  if(driversCid&&typeof driversCid==='object') Object.keys(driversCid).forEach(function(k){ ingest(k, driversCid[k], true); });
  if(driversRoot&&typeof driversRoot==='object') Object.keys(driversRoot).forEach(function(k){ ingest(k, driversRoot[k], false); });
  return {canon:canon, names:names};
}
function adsMergeJobSources(results){
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
      var job=data[bid];
      if(!job||typeof job!=='object') return;
      var did=String(job.driverId||job.DriverId||job.driverid||'').trim();
      if(!did) return;
      if(!merged[bid]) merged[bid]={};
      if(!merged[bid][did]) merged[bid][did]={};
      Object.assign(merged[bid][did], job);
    });
  }
  addNested(results[0]);
  addFlat(results[1]); addFlat(results[2]);
  if(results[3]&&typeof results[3]==='object'){
    Object.keys(results[3]).forEach(function(bid){
      var job=results[3][bid];
      if(!job||typeof job!=='object') return;
      if(!merged[bid]) merged[bid]={};
      var vals=Object.values(job);
      var isFlat=vals.length>0&&vals.every(function(v){return v===null||typeof v!=='object';});
      if(isFlat){
        var did=String(job.driverId||job.DriverId||job.driverid||'').trim();
        if(!did) return;
        if(!merged[bid][did]) merged[bid][did]={};
        Object.assign(merged[bid][did], job);
      } else {
        Object.keys(job).forEach(function(did){
          var j=job[did];
          if(!j||typeof j!=='object') return;
          if(!merged[bid][did]) merged[bid][did]={};
          Object.assign(merged[bid][did], j);
        });
      }
    });
  }
  return merged;
}
function adsOnMode(){
  var mode=document.getElementById('ads-mode').value;
  document.getElementById('ads-month-wrap').style.display=mode==='month'?'':'none';
  document.getElementById('ads-day-wrap').style.display=mode==='day'?'':'none';
  document.getElementById('ads-week-wrap').style.display=mode==='week'?'':'none';
  document.getElementById('ads-range-wrap').style.display=mode==='range'?'':'none';
  document.getElementById('ads-range-to-wrap').style.display=mode==='range'?'':'none';
  adsLoad();
}
function adsInitDates(){
  var now=new Date();
  var ym=now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0');
  var yd=ym+'-'+String(now.getDate()).padStart(2,'0');
  var mEl=document.getElementById('ads-month'); if(mEl&&!mEl.value) mEl.value=ym;
  var dEl=document.getElementById('ads-day'); if(dEl&&!dEl.value) dEl.value=yd;
  var wEl=document.getElementById('ads-week'); if(wEl&&!wEl.value) wEl.value=yd;
  var rf=document.getElementById('ads-range-from'); if(rf&&!rf.value) rf.value=yd;
  var rt=document.getElementById('ads-range-to'); if(rt&&!rt.value) rt.value=yd;
}
function adsCurrentPeriod(){
  var mode=document.getElementById('ads-mode').value||'month';
  var ref=Date.now();
  if(mode==='range'){
    return adsPeriodBounds('range', ref, document.getElementById('ads-range-from').value, document.getElementById('ads-range-to').value);
  }
  if(mode==='month'){
    var mv=document.getElementById('ads-month').value;
    if(mv){ var mp=mv.split('-'); ref=new Date(parseInt(mp[0],10),parseInt(mp[1],10)-1,15).getTime(); }
    return adsPeriodBounds('month', ref);
  }
  if(mode==='day'){
    var dv=document.getElementById('ads-day').value;
    if(dv) ref=new Date(dv+'T12:00:00').getTime();
    return adsPeriodBounds('day', ref);
  }
  var wv=document.getElementById('ads-week').value;
  if(wv) ref=new Date(wv+'T12:00:00').getTime();
  return adsPeriodBounds('week', ref);
}

window._fbOnLogin = function(){
  _fbGet('superClients').then(function(d){
    allCompanies=d||{};
    var o='<option value="">\u2014 Select company \u2014</option>';
    Object.keys(allCompanies).sort(function(a,b){
      return String(allCompanies[a].name||a).localeCompare(String(allCompanies[b].name||b));
    }).forEach(function(cid){
      o+='<option value="'+esc(cid)+'">'+esc(allCompanies[cid].name||cid)+' ('+esc(cid)+')</option>';
    });
    document.getElementById('ads-company').innerHTML=o;
    adsInitDates();
  });
};

function adsLoad(){
  adsInitDates();
  var cid=document.getElementById('ads-company').value;
  if(!cid){
    document.getElementById('ads-empty').style.display='';
    document.getElementById('ads-empty').textContent='Select a company to load Account / ACC settlements.';
    document.getElementById('ads-main').style.display='none';
    document.getElementById('ads-title').textContent='Select a company';
    return;
  }
  _adsPeriod=adsCurrentPeriod();
  document.getElementById('ads-title').textContent=(allCompanies[cid]&&allCompanies[cid].name||cid)+' \u2014 '+_adsPeriod.label;
  document.getElementById('ads-empty').style.display='none';
  document.getElementById('ads-main').style.display='none';
  Promise.all([
    _fbGet('drivers').catch(function(){return null;}),
    _fbGet('drivers/'+cid).catch(function(){return null;}),
    _fbGet('joback',{limitToLast:800}).catch(function(){return null;}),
    _fbGet('completedJobs/'+cid).catch(function(){return null;}),
    _fbGet('closedJobs/'+cid).catch(function(){return null;}),
    _fbGet('allbookings/'+cid).catch(function(){return null;}),
    _fbGet('accountDriverSettlements/'+cid+'/'+_adsPeriod.key).catch(function(){return null;})
  ]).then(function(res){
    var built=adsBuildCanon(res[0], res[1], cid);
    var canon=built.canon||{}, names=built.names||{};
    var settlements=res[6]||{};
    _adsDriversMeta={};
    function ingestDrivers(d){
      if(!d||typeof d!=='object') return;
      Object.keys(d).forEach(function(k){
        var v=d[k];
        if(!v||typeof v!=='object') return;
        if(/^\d+$/.test(k) && !v.name && !v.email) return;
        var id=String(v.id||v.driverId||v.dispatcherId||k);
        var name=[v.firstName||'',v.lastName||'',v.name||''].join(' ').trim()||v.dispatcherId||id;
        var meta={name:name,bankName:v.bankName||'',accountName:v.accountName||'',accountNumber:v.accountNumber||'',pushKey:k};
        _adsDriversMeta[id]=meta;
        if(v.dispatcherId) _adsDriversMeta[String(v.dispatcherId)]=meta;
        if(v.id) _adsDriversMeta[String(v.id)]=meta;
        if(v.uid) _adsDriversMeta[String(v.uid)]=meta;
        _adsDriversMeta[k]=meta;
      });
    }
    ingestDrivers(res[0]); ingestDrivers(res[1]);
    var merged=adsMergeJobSources([res[2],res[3],res[4],res[5]]);
    var byDriver={};
    Object.keys(merged).forEach(function(bid){
      Object.keys(merged[bid]||{}).forEach(function(did){
        var j=merged[bid][did];
        if(!j||typeof j!=='object') return;
        var copy=Object.assign({},j);
        copy.bookingId=copy.bookingId||copy.BookingId||bid;
        var rawDid=String(copy.driverId||copy.DriverId||copy.driverid||did||'').trim();
        if(!rawDid||rawDid===bid||rawDid===String(copy.bookingId||'')) return;
        var canonDid=adsResolveDriverId(rawDid, canon, cid);
        if(!canonDid) return;
        copy.driverId=canonDid;
        var ts=adsJobTs(copy);
        if(!ts||ts<_adsPeriod.fromMs||ts>_adsPeriod.toMs) return;
        var pm=copy.PaymentType||copy.paymentType||copy.PaymentMethod||copy.paymentMethod||'';
        if(!adsIsAccountPm(pm)) return;
        if(!byDriver[canonDid]) byDriver[canonDid]=[];
        byDriver[canonDid].push(copy);
      });
    });
    _adsRows=Object.keys(byDriver).map(function(did){
      var meta=_adsDriversMeta[did]||{};
      var settle=settlements[did]||null;
      if(!settle && meta.pushKey) settle=settlements[meta.pushKey]||null;
      return adsBuildRow({
        driverId:did, driverName:meta.name||names[did]||did, jobs:byDriver[did], settlement:settle,
        bankName:meta.bankName, accountName:meta.accountName, accountNumber:meta.accountNumber
      });
    }).filter(function(r){ return r.jobCount>0; });
    if(!_adsRows.length){
      document.getElementById('ads-empty').style.display='';
      document.getElementById('ads-empty').textContent='No Account / ACC driver jobs in this period.';
      return;
    }
    document.getElementById('ads-main').style.display='';
    adsRender();
  }).catch(function(e){
    document.getElementById('ads-empty').style.display='';
    document.getElementById('ads-empty').textContent='Failed to load: '+(e&&e.message||e);
  });
}

function adsRender(){
  var sf=document.getElementById('ads-status').value;
  var rows=_adsRows.filter(function(r){ return !sf || r.status===sf; }).slice().sort(function(a,b){ return b.owedTotal-a.owedTotal; });
  var unpaid=0, paidN=0, jobs=0;
  rows.forEach(function(r){ unpaid+=r.owedTotal; jobs+=r.completedCount; if(r.status==='paid') paidN++; });
  document.getElementById('ads-stats').innerHTML=
    '<div class="stat"><div class="v">'+rows.length+'</div><div class="l">Drivers</div></div>'+
    '<div class="stat"><div class="v owed">'+money(unpaid)+'</div><div class="l">Total unpaid</div></div>'+
    '<div class="stat"><div class="v">'+paidN+'</div><div class="l">Paid / locked</div></div>'+
    '<div class="stat"><div class="v">'+jobs+'</div><div class="l">Completed Acc jobs</div></div>';
  document.getElementById('ads-tbody').innerHTML=rows.map(function(r){
    var bank=r.accountNumber
      ? '<span class="bank" title="'+esc((r.bankName||'')+' / '+(r.accountName||''))+'">'+esc(r.accountNumber)+'</span>'
      : '<span class="ads-zero">\u2014</span>';
    var markBtn=r.locked
      ? '<button class="sa-btn sa-btn-g" disabled>Paid</button>'
      : '<button class="sa-btn sa-btn-p" onclick="adsMarkPaid(\''+esc(r.driverId)+'\')">Mark Paid</button>';
    return '<tr>'+
      '<td><b>'+esc(r.driverName)+'</b><div class="ads-sub">'+esc(r.driverId)+'</div></td>'+
      '<td class="money">'+adsFormatPay(r.owedBeforeLock, r.completedCount)+'</td>'+
      '<td>Done '+r.completedCount+' · Canc '+r.cancelled+' · Rej '+r.rejected+' · NS '+r.noShow+'<div class="ads-sub">Tot '+r.jobCount+'</div></td>'+
      '<td>'+esc(r.accountRefs.join(', ')||'\u2014')+'</td>'+
      '<td>'+esc(r.vehicles.join(', ')||'\u2014')+'</td>'+
      '<td class="money '+(r.owedTotal?'owed':'')+'">'+money(r.owedTotal)+
        (r.locked?' <span class="ads-sub" style="color:#2E7D32">('+money(r.owedBeforeLock)+' locked)</span>':'')+'</td>'+
      '<td><span class="pill '+r.status+'">'+(r.status==='paid'?'Paid':'Unpaid')+'</span></td>'+
      '<td>'+bank+'</td>'+
      '<td style="white-space:nowrap"><button class="sa-btn sa-btn-g" onclick="adsOpenDetail(\''+esc(r.driverId)+'\')">Detail</button> '+markBtn+'</td>'+
    '</tr>';
  }).join('');
}

function adsOpenDetail(driverId){
  var r=_adsRows.find(function(x){return x.driverId===driverId;});
  if(!r) return;
  document.getElementById('ads-detail-title').textContent=r.driverName+' \u2014 '+(_adsPeriod&&_adsPeriod.label||'');
  var html='<div class="sa-kv">'+
    '<div><div class="k">Company owes</div><div class="val" style="color:#E65100">'+money(r.owedTotal)+'</div></div>'+
    '<div><div class="k">Status</div><div class="val">'+(r.locked?'Paid & locked':'Open / unpaid')+'</div></div>'+
    '<div><div class="k">Completed</div><div class="val">'+r.completedCount+' / '+r.jobCount+'</div></div>'+
    '<div><div class="k">Account refs</div><div class="val">'+esc(r.accountRefs.join(', ')||'\u2014')+'</div></div>'+
    '<div><div class="k">Vehicles</div><div class="val">'+esc(r.vehicles.join(', ')||'\u2014')+'</div></div>'+
    '<div><div class="k">Bank</div><div class="val bank">'+esc([r.bankName,r.accountName,r.accountNumber].filter(Boolean).join(' · ')||'Not on file')+'</div></div>'+
  '</div>';
  html+='<table class="tbl" style="min-width:0"><thead><tr><th>When</th><th>Booking</th><th>Pay</th><th>Account</th><th>Fare</th><th>Status</th></tr></thead><tbody>';
  (r.jobs||[]).slice().sort(function(a,b){return adsJobTs(b)-adsJobTs(a);}).slice(0,80).forEach(function(j){
    var fare=parseFloat(j.TotalFare||j.totalFare||j.Fare||j.fare||0);
    var pm=j.PaymentType||j.paymentType||j.PaymentMethod||'';
    var ref=j.accountNumber||j.AccountNumber||j.accountCode||j.AccountCode||'';
    var ts=adsJobTs(j);
    html+='<tr><td>'+(ts?new Date(ts).toLocaleString('en-NZ'):'\u2014')+'</td>'+
      '<td>'+esc(j.bookingId||'')+'</td><td>'+esc(pm||'\u2014')+'</td><td>'+esc(ref||'\u2014')+'</td>'+
      '<td class="money">'+money(fare)+'</td><td>'+esc(j.jobstatus||j.status||'')+'</td></tr>';
  });
  html+='</tbody></table>';
  if((r.jobs||[]).length>80) html+='<div class="sa-note">Showing latest 80 of '+r.jobs.length+' jobs.</div>';
  document.getElementById('ads-detail-body').innerHTML=html;
  document.getElementById('ads-detail-ov').classList.add('show');
}
function adsCloseDetail(){ document.getElementById('ads-detail-ov').classList.remove('show'); }

function adsMarkPaid(driverId){
  var cid=document.getElementById('ads-company').value;
  var r=_adsRows.find(function(x){return x.driverId===driverId;});
  if(!r||!cid||r.locked) return;
  if(!confirm('Mark '+r.driverName+' Account/ACC paid for '+_adsPeriod.label+'?\nAmount: '+money(r.owedBeforeLock)+'\nLocks accountDriverSettlements (not driverSettlements).')) return;
  var payload={
    status:'paid', locked:true, amountPaid:r.owedBeforeLock, kind:'account',
    periodKey:_adsPeriod.key, periodLabel:_adsPeriod.label,
    fromMs:_adsPeriod.fromMs, toMs:_adsPeriod.toMs,
    driverId:driverId, driverName:r.driverName,
    completedCount:r.completedCount, gross:r.gross, accountRefs:r.accountRefs,
    paidAt:Date.now(), paidBy:'superadmin'
  };
  _fbPost('accountDriverSettlements/'+cid+'/'+_adsPeriod.key+'/'+driverId,'PUT',payload).then(function(){
    r.settlement=payload; r.locked=true; r.status='paid'; r.owedTotal=0;
    adsRender();
  }).catch(function(e){ alert('Mark paid failed: '+(e&&e.message||e)); });
}

function adsExportCsv(){
  var cid=document.getElementById('ads-company').value;
  var sf=document.getElementById('ads-status').value;
  var rows=_adsRows.filter(function(r){ return !sf || r.status===sf; });
  var headers=['Driver','DriverId','Period','Completed','Cancelled','Rejected','NoShow','JobTotal','Gross','Owed','Status','AccountRefs','Vehicles','BankName','AccountName','AccountNumber'];
  var lines=[headers.join(',')];
  rows.forEach(function(r){
    function q(v){ v=String(v==null?'':v); if(/[",\n]/.test(v)) return '"'+v.replace(/"/g,'""')+'"'; return v; }
    lines.push([
      r.driverName,r.driverId,_adsPeriod&&_adsPeriod.label,r.completedCount,r.cancelled,r.rejected,r.noShow,r.jobCount,
      r.owedBeforeLock.toFixed(2),r.owedTotal.toFixed(2),r.status,r.accountRefs.join(' '),r.vehicles.join(' '),
      r.bankName,r.accountName,r.accountNumber
    ].map(q).join(','));
  });
  var a=document.createElement('a');
  a.href=URL.createObjectURL(new Blob([lines.join('\n')],{type:'text/csv'}));
  a.download='account-settlements-'+cid+'-'+(_adsPeriod&&_adsPeriod.key||'x')+'.csv';
  a.click();
}
</script>
</body>
</html>
