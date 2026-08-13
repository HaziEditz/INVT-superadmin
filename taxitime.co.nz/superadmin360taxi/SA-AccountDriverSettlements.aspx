<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Account / ACC Driver Pay &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#00695C;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:600}
.sa-btn-n{background:rgba(255,255,255,.18);color:#fff;border:1px solid rgba(255,255,255,.3)}
.sa-btn-p{background:#00695C;color:#fff}.sa-btn-p:hover{background:#004D40}
.sa-btn-g{background:#fff;border:1px solid #ddd;color:#555}
.filter-bar{display:flex;gap:10px;padding:12px 18px;background:#FAFAFA;border-bottom:1px solid #ECEFF1;flex-wrap:wrap;align-items:flex-end}
.filter-bar label{font-size:11px;font-weight:700;color:#666;text-transform:uppercase;letter-spacing:.04em;display:block;margin-bottom:3px}
.filter-bar select,.filter-bar input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;min-width:130px}
.hint{background:#E0F2F1;border:1px solid #B2DFDB;border-radius:8px;padding:12px 16px;margin-bottom:16px;font-size:13px;color:#00695C;line-height:1.55}
.hint b{color:#004D40}
.stats{display:grid;grid-template-columns:repeat(auto-fill,minmax(130px,1fr));gap:10px;padding:14px 18px;border-bottom:1px solid #f0f0f0}
.stat{background:#fafafa;border:1px solid #eee;border-radius:8px;padding:10px 12px}
.stat .v{font-size:18px;font-weight:800;color:#00695C}.stat .v.owed{color:#E65100}.stat .v.paid{color:#2E7D32}
.stat .l{font-size:10px;color:#9e9e9e;text-transform:uppercase;font-weight:700;margin-top:2px}
.tbl-wrap{overflow-x:auto;max-height:640px;overflow-y:auto}
.tbl{width:100%;border-collapse:collapse;font-size:12px;min-width:1000px}
.tbl th{background:#E0F2F1;padding:9px 10px;text-align:left;font-weight:700;color:#00695C;border-bottom:2px solid #B2DFDB;white-space:nowrap}
.tbl td{padding:8px 10px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.tbl tr:hover td{background:#F1F8F7}
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
.sa-modal-h{padding:14px 18px;background:linear-gradient(135deg,#00695C,#00897B);color:#fff;display:flex;justify-content:space-between;align-items:center}
.sa-modal-h h3{margin:0;font-size:15px}
.sa-modal-b{padding:16px 18px;max-height:72vh;overflow-y:auto}
.sa-kv{display:grid;grid-template-columns:repeat(2,1fr);gap:8px 16px;margin-bottom:8px}
.sa-kv .k{font-size:10px;font-weight:700;color:#9e9e9e;text-transform:uppercase;letter-spacing:.3px}
.sa-kv .val{font-size:13px;font-weight:600;color:#212121}
.sa-note{font-size:11px;color:#78909c;margin-top:10px;line-height:1.5}
</style>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Account / ACC Driver Pay &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-AccountDriverSettlements.aspx" style="font-weight:700;color:#00695C">&#9658; Account / ACC Driver Pay</a></li>
      <li><a href="SA-MasterReport.aspx">Platform Overview</a></li>
      <li><a href="Home.aspx">More&hellip;</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">
  <h2 style="font-size:18px;font-weight:700;margin-bottom:4px">Account / ACC Driver Pay</h2>
  <p style="font-size:13px;color:#888;margin-bottom:14px">Company-own Account/ACC unpaid tracking. Separate from BookaWaka Card/TM Mark Paid.</p>

  <div class="hint">
    <b>Company ledger (Track B):</b> Account, ACC, Business Account, and corporate jobs &mdash; what the company owes drivers.
    Mark Paid locks <code>accountDriverSettlements/{cid}/{period}/{driver}</code>.
    This does <b>not</b> touch <code>driverSettlements</code> (Card/TM/Hoist BookaWaka settlement).
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
      <div id="ads-month-wrap"><label>Month</label><input type="month" id="ads-month" onchange="adsLoad()"/></div>
      <div id="ads-day-wrap" style="display:none"><label>Date</label><input type="date" id="ads-day" onchange="adsLoad()"/></div>
      <div id="ads-week-wrap" style="display:none"><label>Week of</label><input type="date" id="ads-week" onchange="adsLoad()"/></div>
      <div id="ads-range-wrap" style="display:none;gap:10px">
        <div style="display:inline-block"><label>From</label><input type="date" id="ads-range-from" onchange="adsLoad()"/></div>
        <div style="display:inline-block;margin-left:10px"><label>To</label><input type="date" id="ads-range-to" onchange="adsLoad()"/></div>
      </div>
      <div>
        <label>Driver</label>
        <select id="ads-driver" onchange="adsRender()"><option value="">All drivers</option></select>
      </div>
      <div>
        <label>Status</label>
        <select id="ads-status" onchange="adsRender()">
          <option value="">All</option>
          <option value="open">Unpaid</option>
          <option value="paid">Paid</option>
        </select>
      </div>
    </div>
    <div id="ads-stats" class="stats" style="display:none"></div>
    <div class="tbl-wrap">
      <table class="tbl">
        <thead><tr>
          <th>Driver</th><th>Completed</th><th>Account / ACC total</th>
          <th>Canc / Rej / NS</th><th>Vehicles</th><th>Account refs</th>
          <th>Status</th><th>Bank</th><th></th>
        </tr></thead>
        <tbody id="ads-tb"><tr><td colspan="9" class="empty">Choose a company to load.</td></tr></tbody>
      </table>
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
function adsClassifyPaymentMethod(pm){
  var s=String(pm||'').toLowerCase().replace(/[\s_-]/g,'');
  if(!s||s==='\u2014'||s==='-') return 'other';
  if(s.indexOf('cash')>=0) return 'cash';
  if(s.indexOf('mobility')>=0||s==='tm'||s.indexOf('totalmobility')>=0) return 'tm';
  if(s.indexOf('account')>=0||s==='acc'||s.indexOf('business')>=0||s.indexOf('corporate')>=0) return 'account';
  if(s.indexOf('eftpos')>=0) return 'eftpos';
  if(s.indexOf('card')>=0||s.indexOf('stripe')>=0||s.indexOf('visa')>=0||s.indexOf('master')>=0||s.indexOf('amex')>=0||
     s.indexOf('debit')>=0||s.indexOf('credit')>=0||s.indexOf('tap')>=0||s.indexOf('nfc')>=0||s.indexOf('taptopay')>=0) return 'card';
  return 'other';
}
function adsIsAccountPayment(pm){ return adsClassifyPaymentMethod(pm)==='account'; }
function adsNormalizeJobOutcome(status){
  var s=String(status||'').toLowerCase().replace(/[\s_-]/g,'');
  if(!s) return 'other';
  if(s.indexOf('complete')>=0||s==='closed'||s==='done'||s==='finished') return 'completed';
  if(s.indexOf('cancel')>=0) return 'cancelled';
  if(s.indexOf('reject')>=0||s.indexOf('declin')>=0) return 'rejected';
  if(s.indexOf('noshow')>=0||s==='ns') return 'no_show';
  return 'other';
}
function adsJobFare(job){
  var full=parseFloat(job.TotalFare||job.totalFare||job.Fare||job.fare||job.RideCost||job.EstimatedFare||0)||0;
  var isTm=job.isTotalMobility===true||job.tmUsed===true||
    job.tmPaymentType==='total_mobility'||job.paymentCategory==='total_mobility'||
    (job.tmSubsidyFare!=null&&job.tmSubsidyFare!=='')||
    (job.tmSubsidy!=null&&job.tmSubsidy!=='')||
    (job.tmCouncilPays!=null&&job.tmCouncilPays!=='')||
    (job.councilPays!=null&&job.councilPays!=='')||
    !!(job.tmCardNumber||job.tmVoucherNo);
  if(!isTm) return full;
  var pax=parseFloat(job.tmPassengerPays||job.passengerPays||job.patientPays||0)||0;
  if(pax>0) return Math.round(pax*100)/100;
  var hoist=parseFloat(job.tmSubsidyHoist||job.hoistFare||job.HoistFare||job.hoistAmount||0)||0;
  var sub=0;
  if(job.tmSubsidyFare!=null&&job.tmSubsidyFare!=='') sub=parseFloat(job.tmSubsidyFare)||0;
  else {
    var combined=parseFloat(job.tmSubsidy||job.tmCouncilPays||job.councilPays||0)||0;
    sub=hoist>0?Math.max(0,combined-hoist):combined;
  }
  return Math.max(0, Math.round((full-hoist-sub)*100)/100);
}
function adsJobPaymentMethod(job){
  return job.PaymentType||job.paymentType||job.PaymentMethod||job.paymentMethod||'';
}
function adsFormatPayWithCount(owedOrGross, count){
  var n=Math.round((parseFloat(owedOrGross)||0)*100)/100;
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
      if(toMs<fromMs){ fromMs=sod(toParts[0],toParts[1]-1,toParts[2]); toMs=eod(fromParts[0],fromParts[1]-1,fromParts[2]); }
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

function adsIsCompanyKey(k, companyId){
  var s=String(k||'');
  if(!s) return false;
  if(companyId!=null && String(companyId)!=='' && s===String(companyId)) return true;
  return /^\d+$/.test(s);
}
function adsIsLegacyDriverId(id){ return /^D\d+/i.test(String(id||'').trim()); }
function adsPreferCanonId(v, fallbackKey, existingCanon){
  if(!v||typeof v!=='object') return String(fallbackKey||'');
  var candidates=[v.dispatcherId, v.id, v.driverId, v.DriverId, fallbackKey];
  for(var i=0;i<candidates.length;i++){
    var c=candidates[i];
    if(c!=null && String(c).trim()!=='' && adsIsLegacyDriverId(c)) return String(c).trim();
  }
  if(existingCanon){
    var aliases=[v.uid, v.Uid, fallbackKey, v.fleetKey].filter(Boolean).map(String);
    for(var a=0;a<aliases.length;a++){
      var prev=existingCanon[aliases[a]];
      if(prev && adsIsLegacyDriverId(prev)) return prev;
    }
  }
  for(var j=0;j<candidates.length;j++){
    var c2=candidates[j];
    if(c2!=null && String(c2).trim()!=='') return String(c2).trim();
  }
  return String(fallbackKey||'');
}
function adsLooksLikeDriverBucket(v){
  if(!v||typeof v!=='object'||Array.isArray(v)) return false;
  var vals=Object.values(v);
  if(!vals.length) return false;
  return vals.some(function(child){
    return child&&typeof child==='object'&&!Array.isArray(child)&&
      !!(child.name||child.email||child.firstName||child.driverId||child.dispatcherId||child.uid);
  });
}
function adsBuildDriverCanon(driversRoot, driversCid, companyId){
  var canon={}, names={}, valid={};
  function setCanon(alias, canonId, name){
    if(alias==null||alias==='') return;
    var a=String(alias);
    if(adsIsCompanyKey(a, companyId)) return;
    var c=String(canonId);
    if(!c||adsIsCompanyKey(c, companyId)) return;
    if(canon[a] && adsIsLegacyDriverId(canon[a]) && !adsIsLegacyDriverId(c)) return;
    canon[a]=c;
    if(name){ names[a]=name; names[c]=name; }
    valid[c]=true;
  }
  function ingest(key, d, fromCompanyScoped){
    if(!d||typeof d!=='object') return;
    if(adsIsCompanyKey(key, companyId) && adsLooksLikeDriverBucket(d)){
      Object.keys(d).forEach(function(childKey){ ingest(childKey, d[childKey], true); });
      return;
    }
    if(!fromCompanyScoped && d.companyId!=null && companyId && String(d.companyId)!==String(companyId)) return;
    if(/^\d+$/.test(String(key)) && !d.name && !d.email && !d.firstName) return;
    var name=[d.firstName||d.first_name||'', d.lastName||d.last_name||d.surname||'', d.name||''].join(' ').trim() || d.email || d.dispatcherId || '';
    if(!name && !d.id && !d.driverId && !d.dispatcherId && !d.uid) return;
    var canonId=adsPreferCanonId(d, key, canon);
    if(!canonId || adsIsCompanyKey(canonId, companyId)) return;
    setCanon(key, canonId, name||canonId);
    setCanon(d.uid, canonId, name||canonId);
    setCanon(d.Uid, canonId, name||canonId);
    setCanon(d.id, canonId, name||canonId);
    setCanon(d.driverId, canonId, name||canonId);
    setCanon(d.DriverId, canonId, name||canonId);
    setCanon(d.dispatcherId, canonId, name||canonId);
    setCanon(canonId, canonId, name||canonId);
  }
  if(driversCid && typeof driversCid==='object') Object.keys(driversCid).forEach(function(k){ ingest(k, driversCid[k], true); });
  if(driversRoot && typeof driversRoot==='object') Object.keys(driversRoot).forEach(function(k){ ingest(k, driversRoot[k], false); });
  return {canon:canon, names:names, valid:valid};
}
function adsResolveDriverId(rawId, canonMap, companyId){
  if(rawId==null||rawId===''||rawId==='0') return null;
  var id=String(rawId);
  if(adsIsCompanyKey(id, companyId)) return null;
  if(canonMap && canonMap[id]) return canonMap[id];
  return id;
}
function adsBuildDriverRow(opts){
  opts=opts||{};
  var jobs=opts.jobs||[], settlement=opts.settlement||null;
  var ledgerJobs=[], gross=0, completedCount=0, cancelled=0, rejected=0, noShow=0;
  var vehicles={}, accountRefs={};
  jobs.forEach(function(job){
    if(!adsIsAccountPayment(adsJobPaymentMethod(job))) return;
    ledgerJobs.push(job);
    var outcome=adsNormalizeJobOutcome(job.jobstatus||job.JobStatus||job.status||job.Status||'');
    if(outcome==='cancelled') cancelled+=1;
    else if(outcome==='rejected') rejected+=1;
    else if(outcome==='no_show') noShow+=1;
    var veh=String(job.vehicleId||job.VehicleId||job.taxiNumber||job.TaxiNumber||job.carNumber||'').trim();
    if(veh) vehicles[veh]=(vehicles[veh]||0)+1;
    var ref=String(job.accountNumber||job.AccountNumber||job.accountCode||job.AccountCode||
      job.accountId||job.AccountId||job.accClientId||'').trim();
    if(ref) accountRefs[ref]=(accountRefs[ref]||0)+1;
    if(outcome!=='completed') return;
    completedCount+=1;
    gross+=adsJobFare(job);
  });
  gross=Math.round(gross*100)/100;
  var locked=!!(settlement&&(settlement.locked||settlement.status==='paid'));
  return {
    driverId:String(opts.driverId||''), driverName:String(opts.driverName||opts.driverId||'Driver'),
    jobs:ledgerJobs, jobCount:ledgerJobs.length, completedCount:completedCount,
    cancelled:cancelled, rejected:rejected, noShow:noShow, gross:gross,
    owedTotal:locked?0:gross, owedBeforeLock:gross,
    status:locked?'paid':'open', locked:locked, settlement:settlement,
    vehicles:Object.keys(vehicles).sort(), accountRefs:Object.keys(accountRefs).sort(),
    bankName:opts.bankName||'', accountName:opts.accountName||'', accountNumber:opts.accountNumber||''
  };
}
function adsIngestDriversMeta(dataRoot, dataCid, cid){
  var meta={};
  function ingest(d, scoped){
    if(!d||typeof d!=='object') return;
    Object.keys(d).forEach(function(k){
      var v=d[k];
      if(!v||typeof v!=='object') return;
      if(/^\d+$/.test(k) && !v.name && !v.email && !v.firstName) return;
      if(!scoped && v.companyId!=null && String(v.companyId)!==String(cid)) return;
      var id=String(v.id||v.driverId||v.dispatcherId||k);
      var name=[v.firstName||'',v.lastName||'',v.name||''].join(' ').trim()||v.dispatcherId||id;
      var m={name:name, bankName:v.bankName||'', accountName:v.accountName||'', accountNumber:v.accountNumber||'', pushKey:k};
      meta[id]=m;
      if(v.dispatcherId) meta[String(v.dispatcherId)]=m;
      if(v.uid) meta[String(v.uid)]=m;
      meta[k]=m;
    });
  }
  ingest(dataCid, true); ingest(dataRoot, false);
  return meta;
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
    var now=new Date();
    var ym=now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0');
    var yd=ym+'-'+String(now.getDate()).padStart(2,'0');
    document.getElementById('ads-month').value=ym;
    document.getElementById('ads-day').value=yd;
    document.getElementById('ads-week').value=yd;
    document.getElementById('ads-range-from').value=yd;
    document.getElementById('ads-range-to').value=yd;
  });
};

function adsOnMode(){
  var mode=document.getElementById('ads-mode').value;
  document.getElementById('ads-month-wrap').style.display=mode==='month'?'':'none';
  document.getElementById('ads-day-wrap').style.display=mode==='day'?'':'none';
  document.getElementById('ads-week-wrap').style.display=mode==='week'?'':'none';
  document.getElementById('ads-range-wrap').style.display=mode==='range'?'flex':'none';
  adsLoad();
}
function adsCurrentPeriod(){
  var mode=document.getElementById('ads-mode').value||'month';
  var ref=Date.now();
  if(mode==='month'){ var mv=document.getElementById('ads-month').value; if(mv){ var p=mv.split('-'); ref=new Date(+p[0],+p[1]-1,15).getTime(); } }
  else if(mode==='day'){ var dv=document.getElementById('ads-day').value; if(dv) ref=new Date(dv+'T12:00:00').getTime(); }
  else if(mode==='week'){ var wv=document.getElementById('ads-week').value; if(wv) ref=new Date(wv+'T12:00:00').getTime(); }
  if(mode==='range'){
    var rf=document.getElementById('ads-range-from').value;
    var rt=document.getElementById('ads-range-to').value;
    return adsPeriodBounds('range', ref, rf, rt);
  }
  return adsPeriodBounds(mode, ref);
}

function adsLoad(){
  var cid=document.getElementById('ads-company').value;
  if(!cid){
    document.getElementById('ads-tb').innerHTML='<tr><td colspan="9" class="empty">Choose a company to load.</td></tr>';
    document.getElementById('ads-stats').style.display='none';
    document.getElementById('ads-title').textContent='Select a company';
    return;
  }
  _adsPeriod=adsCurrentPeriod();
  document.getElementById('ads-title').textContent=(allCompanies[cid]&&allCompanies[cid].name||cid)+' \u2014 '+_adsPeriod.label;
  document.getElementById('ads-tb').innerHTML='<tr><td colspan="9" class="empty">Loading\u2026</td></tr>';

  Promise.all([
    _fbGet('drivers').catch(function(){return null;}),
    _fbGet('drivers/'+cid).catch(function(){return null;}),
    _fbGet('joback',{limitToLast:800}).catch(function(){return null;}),
    _fbGet('completedJobs/'+cid).catch(function(){return null;}),
    _fbGet('closedJobs/'+cid).catch(function(){return null;}),
    _fbGet('allbookings/'+cid).catch(function(){return null;}),
    _fbGet('accountDriverSettlements/'+cid+'/'+_adsPeriod.key).catch(function(){return null;})
  ]).then(function(res){
    var driversRoot=res[0], driversCid=res[1], settlements=res[6]||{};
    var built=adsBuildDriverCanon(driversRoot, driversCid, cid);
    var canon=built.canon||{}, names=built.names||{};
    _adsDriversMeta=adsIngestDriversMeta(driversRoot, driversCid, cid);

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
    addNested(res[2]); addFlat(res[3]); addFlat(res[4]);
    if(res[5]&&typeof res[5]==='object'){
      Object.keys(res[5]).forEach(function(bid){
        var job=res[5][bid]; if(!job||typeof job!=='object') return;
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
            if(!did||did===bid) return;
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
        var copy=Object.assign({}, j);
        copy.bookingId=copy.bookingId||bid;
        var rawDid=String(copy.driverId||copy.DriverId||did||'').trim();
        if(!rawDid||rawDid===bid||rawDid===String(copy.bookingId||'')) return;
        var canonDid=adsResolveDriverId(rawDid, canon, cid);
        if(!canonDid) return;
        copy.driverId=canonDid;
        var ts=adsJobTs(copy);
        if(!ts||ts<_adsPeriod.fromMs||ts>_adsPeriod.toMs) return;
        if(!adsIsAccountPayment(adsJobPaymentMethod(copy))) return;
        allJobs.push(copy);
      });
    });

    var byDriver={};
    allJobs.forEach(function(j){
      var did=String(j.driverId||''); if(!did) return;
      if(!byDriver[did]) byDriver[did]=[];
      byDriver[did].push(j);
    });

    _adsRows=Object.keys(byDriver).map(function(did){
      var meta=_adsDriversMeta[did]||{};
      var settle=settlements[did]||(meta.pushKey&&settlements[meta.pushKey])||null;
      return adsBuildDriverRow({
        driverId:did, driverName:meta.name||names[did]||did,
        jobs:byDriver[did], settlement:settle,
        bankName:meta.bankName, accountName:meta.accountName, accountNumber:meta.accountNumber
      });
    }).filter(function(r){
      if(!(r.jobCount>0 || r.owedBeforeLock>0 || r.completedCount>0)) return false;
      var meta=_adsDriversMeta[r.driverId];
      var looksLikeBooking=/^869\d{6,}$/.test(r.driverId) || (/^\d{10,}$/.test(r.driverId) && !meta);
      if(looksLikeBooking && !meta && r.completedCount===0 && r.owedBeforeLock===0) return false;
      return true;
    });

    var sel=document.getElementById('ads-driver');
    var prev=sel.value;
    sel.innerHTML='<option value="">All drivers</option>'+_adsRows.slice().sort(function(a,b){
      return a.driverName.localeCompare(b.driverName);
    }).map(function(r){
      return '<option value="'+esc(r.driverId)+'">'+esc(r.driverName)+'</option>';
    }).join('');
    if(prev) sel.value=prev;

    adsRender();
  }).catch(function(e){
    document.getElementById('ads-tb').innerHTML='<tr><td colspan="9" class="empty">Error: '+esc(e&&e.message||e)+'</td></tr>';
  });
}

function adsFiltered(){
  var df=document.getElementById('ads-driver').value;
  var sf=document.getElementById('ads-status').value;
  return _adsRows.filter(function(r){
    if(df && r.driverId!==df) return false;
    if(sf && r.status!==sf) return false;
    return true;
  }).slice().sort(function(a,b){ return b.owedBeforeLock-a.owedBeforeLock; });
}

function adsRender(){
  var rows=adsFiltered();
  var unpaid=0, paidN=0, completed=0;
  rows.forEach(function(r){ unpaid+=r.owedTotal; completed+=r.completedCount||0; if(r.status==='paid') paidN++; });
  document.getElementById('ads-stats').style.display='grid';
  document.getElementById('ads-stats').innerHTML=
    '<div class="stat"><div class="v">'+rows.length+'</div><div class="l">Drivers</div></div>'+
    '<div class="stat"><div class="v owed">'+money(unpaid)+'</div><div class="l">Total unpaid</div></div>'+
    '<div class="stat"><div class="v paid">'+paidN+'</div><div class="l">Paid / locked</div></div>'+
    '<div class="stat"><div class="v">'+completed+'</div><div class="l">Completed jobs</div></div>';

  if(!rows.length){
    document.getElementById('ads-tb').innerHTML='<tr><td colspan="9" class="empty">No Account / ACC activity in this period.</td></tr>';
    return;
  }
  document.getElementById('ads-tb').innerHTML=rows.map(function(r){
    var mark=r.locked
      ? '<button class="sa-btn sa-btn-g" disabled>Paid</button>'
      : '<button class="sa-btn sa-btn-p" onclick="adsMarkPaid(\''+esc(r.driverId)+'\')">Mark Paid</button>';
    var bank=r.accountNumber
      ? '<span class="bank" title="'+esc((r.bankName||'')+' / '+(r.accountName||''))+'">'+esc(r.accountNumber)+'</span>'
      : '<span class="ads-zero">\u2014</span>';
    return '<tr>'+
      '<td><b>'+esc(r.driverName)+'</b><div class="ads-sub">'+esc(r.driverId)+'</div></td>'+
      '<td>'+r.completedCount+'</td>'+
      '<td class="money owed">'+adsFormatPayWithCount(r.locked?r.owedBeforeLock:r.owedTotal, r.completedCount)+
        (r.locked?' <span class="ads-sub" style="color:#2E7D32">(locked)</span>':'')+'</td>'+
      '<td>Canc '+r.cancelled+' \u00b7 Rej '+r.rejected+' \u00b7 NS '+r.noShow+'</td>'+
      '<td>'+esc(r.vehicles.join(', ')||'\u2014')+'</td>'+
      '<td>'+esc(r.accountRefs.join(', ')||'\u2014')+'</td>'+
      '<td><span class="pill '+r.status+'">'+(r.status==='paid'?'Paid':'Unpaid')+'</span></td>'+
      '<td>'+bank+'</td>'+
      '<td style="white-space:nowrap"><button class="sa-btn sa-btn-g" onclick="adsOpenDetail(\''+esc(r.driverId)+'\')">Detail</button> '+mark+'</td>'+
    '</tr>';
  }).join('');
}

function adsOpenDetail(driverId){
  var r=_adsRows.find(function(x){return x.driverId===driverId;});
  if(!r) return;
  document.getElementById('ads-detail-title').textContent=r.driverName+' \u2014 '+(_adsPeriod&&_adsPeriod.label||'');
  var html='<div class="sa-kv">'+
    '<div><div class="k">Account / ACC owed</div><div class="val" style="color:#E65100">'+money(r.owedTotal)+'</div></div>'+
    '<div><div class="k">Status</div><div class="val">'+(r.locked?'Paid &amp; locked':'Open / unpaid')+'</div></div>'+
    '<div><div class="k">Completed</div><div class="val">'+r.completedCount+'</div></div>'+
    '<div><div class="k">Canc / Rej / NS</div><div class="val">'+r.cancelled+' / '+r.rejected+' / '+r.noShow+'</div></div>'+
    '<div><div class="k">Vehicles</div><div class="val">'+esc(r.vehicles.join(', ')||'\u2014')+'</div></div>'+
    '<div><div class="k">Account refs</div><div class="val">'+esc(r.accountRefs.join(', ')||'\u2014')+'</div></div>'+
    '<div style="grid-column:1/-1"><div class="k">Bank</div><div class="val bank">'+esc([r.bankName,r.accountName,r.accountNumber].filter(Boolean).join(' \u00b7 ')||'Not on file')+'</div></div>'+
  '</div>';
  html+='<table class="tbl" style="min-width:0"><thead><tr><th>When</th><th>Booking</th><th>Pay</th><th>Fare</th><th>Status</th><th>Account ref</th></tr></thead><tbody>';
  var list=(r.jobs||[]).slice().sort(function(a,b){return adsJobTs(b)-adsJobTs(a);}).slice(0,80);
  list.forEach(function(j){
    var fare=adsJobFare(j);
    var pm=adsJobPaymentMethod(j);
    var ts=adsJobTs(j);
    var ref=String(j.accountNumber||j.AccountNumber||j.accountCode||j.AccountCode||j.accountId||j.AccountId||j.accClientId||'').trim();
    html+='<tr><td>'+(ts?new Date(ts).toLocaleString('en-NZ'):'\u2014')+'</td>'+
      '<td>'+esc(j.bookingId||'')+'</td><td>'+esc(pm||'\u2014')+'</td>'+
      '<td class="money">'+money(fare)+'</td>'+
      '<td>'+esc(j.jobstatus||j.status||'')+'</td><td>'+esc(ref||'\u2014')+'</td></tr>';
  });
  html+='</tbody></table>';
  if((r.jobs||[]).length>80) html+='<div class="sa-note">Showing latest 80 of '+r.jobs.length+' Account/ACC jobs.</div>';
  document.getElementById('ads-detail-body').innerHTML=html;
  document.getElementById('ads-detail-ov').classList.add('show');
}
function adsCloseDetail(){ document.getElementById('ads-detail-ov').classList.remove('show'); }

function adsMarkPaid(driverId){
  var cid=document.getElementById('ads-company').value;
  var r=_adsRows.find(function(x){return x.driverId===driverId;});
  if(!r||!cid||r.locked) return;
  if(!confirm('Mark '+r.driverName+' paid for Account/ACC '+_adsPeriod.label+'?\nAmount: '+money(r.owedBeforeLock)+'\nLocks accountDriverSettlements (not Card/TM).')) return;
  var payload={
    status:'paid', locked:true, amountPaid:r.owedBeforeLock,
    periodKey:_adsPeriod.key, periodLabel:_adsPeriod.label,
    fromMs:_adsPeriod.fromMs, toMs:_adsPeriod.toMs,
    driverId:driverId, driverName:r.driverName,
    gross:r.gross, completedCount:r.completedCount,
    ledgerKind:'account',
    paidAt:Date.now(), paidBy:'superadmin'
  };
  _fbPost('accountDriverSettlements/'+cid+'/'+_adsPeriod.key+'/'+driverId,'PUT',payload).then(function(){
    r.settlement=payload; r.locked=true; r.status='paid'; r.owedTotal=0;
    adsRender();
  }).catch(function(e){ alert('Mark paid failed: '+(e&&e.message||e)); });
}

function adsExportCsv(){
  var rows=adsFiltered();
  var cid=document.getElementById('ads-company').value;
  var headers=['Company','Driver','DriverId','Period','Completed','AccountGross','Canc','Rej','NoShow','Vehicles','AccountRefs','OwedTotal','Status','BankName','AccountName','AccountNumber'];
  var lines=[headers.join(',')];
  rows.forEach(function(r){
    function q(v){ v=String(v==null?'':v); return /[",\n]/.test(v)?'"'+v.replace(/"/g,'""')+'"':v; }
    lines.push([
      cid, r.driverName, r.driverId, _adsPeriod&&_adsPeriod.label,
      r.completedCount, r.owedBeforeLock.toFixed(2),
      r.cancelled, r.rejected, r.noShow,
      r.vehicles.join(' '), r.accountRefs.join(' '),
      r.owedTotal.toFixed(2), r.status, r.bankName, r.accountName, r.accountNumber
    ].map(q).join(','));
  });
  var a=document.createElement('a');
  a.href=URL.createObjectURL(new Blob([lines.join('\n')],{type:'text/csv'}));
  a.download='account-driver-pay-'+cid+'-'+(_adsPeriod&&_adsPeriod.key||'x')+'.csv';
  a.click();
}
</script>
</body>
</html>
