<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Driver Ops &amp; Payments &mdash; BookaWaka Admin</title>
<meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate"/>
<meta http-equiv="Pragma" content="no-cache"/>
<meta name="dos-build" content="track-c-v3-tm-subsidy"/>
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
.sa-wrap{padding:20px;max-width:1800px}
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
.stat .v{font-size:18px;font-weight:800;color:#00695C}.stat .v.owed{color:#E65100}.stat .l{font-size:10px;color:#9e9e9e;text-transform:uppercase;font-weight:700;margin-top:2px}
.tbl-wrap{overflow-x:auto;max-height:640px;overflow-y:auto}
.tbl{width:100%;border-collapse:collapse;font-size:12px;min-width:1280px}
.tbl th{background:#E0F2F1;padding:8px 8px;text-align:left;font-weight:700;color:#00695C;border-bottom:2px solid #B2DFDB;white-space:nowrap}
.tbl thead tr.grp th{background:#00695C;color:#fff;border-bottom:1px solid #004D40;text-align:center;font-size:10px;letter-spacing:.04em;text-transform:uppercase;padding:6px 8px}
.tbl thead tr.grp th.g-src{background:#455A64}
.tbl thead tr.grp th.g-pay{background:#37474F}
.tbl thead tr.grp th.g-owed{background:#E65100}
.tbl thead tr.sub th{background:#F1F8F7;font-size:10px;color:#546e7a;border-bottom:2px solid #B2DFDB;text-align:center;padding:6px 6px}
.tbl td{padding:8px 8px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.tbl td.num,.tbl th.num{text-align:center;font-variant-numeric:tabular-nums}
.tbl td.money,.tbl th.money-h{text-align:right;font-variant-numeric:tabular-nums}
.tbl td.col-owed{background:#FFF8F3}
.tbl tr:hover td{background:#F1F8F7}
.tbl tr:hover td.col-owed{background:#FFECB3}
.tbl td.sticky-driver,.tbl th.sticky-driver{position:sticky;left:0;z-index:1;background:#fff;box-shadow:2px 0 0 #ECEFF1}
.tbl thead th.sticky-driver{z-index:3;background:#E0F2F1}
.tbl thead tr.grp th.sticky-driver{background:#00695C;z-index:4}
.money{font-weight:700;font-variant-numeric:tabular-nums}
.owed{color:#E65100}.pill{display:inline-block;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px}
.pill.open{background:#FFF3E0;color:#E65100}.pill.paid{background:#E8F5E9;color:#2E7D32}.pill.partial{background:#E3F2FD;color:#1565C0}
.build-stamp{display:inline-block;margin-left:8px;font-size:10px;font-weight:700;color:#00695C;background:#E0F2F1;border:1px solid #B2DFDB;border-radius:4px;padding:2px 6px;vertical-align:middle}
.empty{text-align:center;padding:40px;color:#aaa}
.bank{font-family:monospace;font-size:11px;color:#546e7a}
.dos-sub{font-size:10px;color:#90a4ae;margin-top:2px}
.dos-zero{color:#bdbdbd}
.sa-ov{display:none;position:fixed;inset:0;background:rgba(15,23,42,.45);z-index:10000;align-items:flex-start;justify-content:center;overflow-y:auto;padding:28px 16px}
.sa-ov.show{display:flex}
.sa-modal{background:#fff;border-radius:12px;width:780px;max-width:100%;box-shadow:0 20px 60px rgba(0,0,0,.22);margin:auto;overflow:hidden}
.sa-modal-h{padding:14px 18px;background:linear-gradient(135deg,#00695C,#00897B);color:#fff;display:flex;justify-content:space-between;align-items:center}
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
      <li><a href="SA-AccountDriverSettlements.aspx">Account / ACC Driver Pay</a></li>
      <li><a href="SA-MasterReport.aspx">Platform Overview</a></li>
      <li><a href="Home.aspx">More&hellip;</a></li>
    </ul></li>
  </ul></div>
</aside>

<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">
  <h2 style="font-size:18px;font-weight:700;margin-bottom:4px">Driver Ops &amp; Payment Summary <span class="build-stamp" id="dos-build-stamp">Track C · TM subsidy owed</span></h2>
  <p style="font-size:13px;color:#888;margin-bottom:14px">Company-scoped view of what each company owes its drivers. Same rules as the owner panel.</p>

  <div class="hint">
    <b>Paid / unpaid (BookaWaka):</b> Card and TM/Hoist are <b>independent</b> Mark Paid streams — lock Card for a period without locking TM (and vice versa).
    <b>Tracked, not BW-owed:</b> Cash · EFTPOS (Verifone) · Account/ACC (company settles with own clients — see Account / ACC Settlements) — shown as total × count.
    Bank details are reference-only for manual transfer.<br/>
    <b>Jobs legend:</b> Done = completed &middot; Canc = cancelled &middot; Rej = rejected &middot; <b>NS = No Show</b> &middot; Tot = total.<br/>
    <b>Sources:</b> Disp = dispatch console &middot; App = passenger app &middot; Web = website &middot; Food = food delivery &middot; Frt = freight &middot; Hail = driver app / street hail / queue &middot; Other = recognised but unmapped &middot; Unk = missing source field.
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
        <select id="dos-company" required onchange="dosLoad()"><option value="">&mdash; Select company &mdash;</option></select>
      </div>
      <div>
        <label>Period</label>
        <select id="dos-mode" onchange="dosOnMode()">
          <option value="month" selected>Month</option>
          <option value="week">Week</option>
          <option value="day">Day</option>
          <option value="range">Custom range</option>
        </select>
      </div>
      <div id="dos-month-wrap"><label>Month</label><input type="month" id="dos-month" onchange="dosLoad()"/></div>
      <div id="dos-day-wrap" style="display:none"><label>Date</label><input type="date" id="dos-day" onchange="dosLoad()"/></div>
      <div id="dos-week-wrap" style="display:none"><label>Week of</label><input type="date" id="dos-week" onchange="dosLoad()"/></div>
      <div id="dos-range-wrap" style="display:none;gap:10px">
        <div style="display:inline-block"><label>From</label><input type="date" id="dos-range-from" onchange="dosLoad()"/></div>
        <div style="display:inline-block;margin-left:10px"><label>To</label><input type="date" id="dos-range-to" onchange="dosLoad()"/></div>
      </div>
      <div>
        <label>Status</label>
        <select id="dos-status" onchange="dosRender()">
          <option value="">All</option>
          <option value="card_open">Card unpaid</option>
          <option value="tm_open">TM unpaid</option>
          <option value="open">Any unpaid</option>
          <option value="partial">Partial</option>
          <option value="paid">Fully paid</option>
        </select>
      </div>
    </div>
    <div id="dos-stats" class="stats" style="display:none"></div>
    <div class="tbl-wrap">
      <table class="tbl">
        <thead>
          <tr class="grp">
            <th class="sticky-driver" rowspan="2">Driver</th>
            <th rowspan="2">Hours</th>
            <th rowspan="2">Jobs</th>
            <th class="g-src" colspan="8">Sources</th>
            <th rowspan="2">Vehicles</th>
            <th class="g-pay" colspan="6">Payments</th>
            <th class="g-owed" colspan="3">Unpaid</th>
            <th rowspan="2">Status</th>
            <th rowspan="2">Bank</th>
            <th rowspan="2">Actions</th>
          </tr>
          <tr class="sub">
            <th class="num" title="Dispatch console">Disp</th>
            <th class="num" title="Passenger app">App</th>
            <th class="num" title="Website">Web</th>
            <th class="num" title="Food delivery">Food</th>
            <th class="num" title="Freight">Frt</th>
            <th class="num" title="Driver app / hail / queue">Hail</th>
            <th class="num" title="Recognised but unmapped">Oth</th>
            <th class="num" title="Missing source">Unk</th>
            <th class="money-h">Cash</th>
            <th class="money-h">Card</th>
            <th class="money-h">EFTPOS</th>
            <th class="money-h">TM</th>
            <th class="money-h">Account</th>
            <th class="money-h">Hoist</th>
            <th class="money-h">Card</th>
            <th class="money-h">TM</th>
            <th class="money-h">Total</th>
          </tr>
        </thead>
        <tbody id="dos-tb"><tr><td colspan="24" class="empty">Choose a company to load.</td></tr></tbody>
      </table>
    </div>
  </div>

  <div class="sa-card">
    <div class="sa-bar" style="background:#455A64"><h3>Dispatcher activity (jobs named in period)</h3></div>
    <p style="padding:10px 18px;margin:0;font-size:12px;color:#78909c">Dispatcher shift hours are not stored historically &mdash; counts only.</p>
    <div style="overflow-x:auto;max-height:260px">
      <table class="tbl">
        <thead><tr><th>Dispatcher</th><th>Jobs</th><th>Completed</th><th>Cancelled</th></tr></thead>
        <tbody id="dos-disp-tb"><tr><td colspan="4" class="empty">&mdash;</td></tr></tbody>
      </table>
    </div>
  </div>
</div>
</div></div>

<div class="sa-ov" id="dos-detail-ov" onclick="if(event.target===this)dosCloseDetail()">
  <div class="sa-modal">
    <div class="sa-modal-h">
      <h3 id="dos-detail-title">Driver detail</h3>
      <button class="sa-btn sa-btn-n" onclick="dosCloseDetail()">Close</button>
    </div>
    <div class="sa-modal-b" id="dos-detail-body"></div>
  </div>
</div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
/* ============================================================================
 * State
 * ========================================================================== */
var allCompanies = {};
var _dosRows = [], _dosDisp = [], _dosPeriod = null, _dosCs = {};

/* ============================================================================
 * Small utils
 * ========================================================================== */
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function money(n){ n=Math.round((parseFloat(n)||0)*100)/100; return '$'+n.toFixed(2); }

/* ============================================================================
 * Shift Reports logic — ported from INVT-admin/lib/shiftReportFlatten.js.
 * workedMinutes preferred over wall-clock, progressive End-Shift snapshots
 * collapsed to max-not-sum, driver identity resolved to canonical D00x ids.
 * This is what fixes the "0.0h" bug — the old wall-clock clip is gone.
 * ========================================================================== */
var DOS_MAX_SESSION_MIN = 18 * 60; // stale/ghost session cap

function dosParseTs(v){
  if(v==null||v==='') return 0;
  if(typeof v==='number'){
    if(!isFinite(v)||v<=0) return 0;
    return v>1e12?v:(v>1e10?v:v*1000);
  }
  var n=Number(v);
  if(!isNaN(n)&&n>0) return n>1e12?n:(n>1e10?n:n*1000);
  var t=Date.parse(String(v));
  return isNaN(t)?0:t;
}
function dosLooksLikeSession(s){
  if(!s||typeof s!=='object'||Array.isArray(s)) return false;
  return !!(s.startTime||s.shiftStartAt||s.sessionStartedAt||s.startTs||s.loginTime||
    s.endTime||s.shiftEndAt||s.endTs||s.logoutTime||s.finishTime||
    s.workedMinutes!=null||s.totalMinutes!=null||s.status||s.isActive!=null);
}
function dosLooksLikeDriverBucket(v){
  if(!v||typeof v!=='object'||Array.isArray(v)) return false;
  var vals=Object.values(v);
  if(!vals.length) return false;
  return vals.some(dosLooksLikeSession);
}
function dosLooksLikeCompanyBucket(v){
  if(!v||typeof v!=='object'||Array.isArray(v)) return false;
  var vals=Object.values(v);
  if(!vals.length) return false;
  var driverish=0, sessionish=0;
  vals.forEach(function(child){
    if(!child||typeof child!=='object') return;
    if(dosLooksLikeSession(child)) sessionish++;
    else if(dosLooksLikeDriverBucket(child)) driverish++;
  });
  return driverish>0 && sessionish===0;
}
function dosIsCompanyKey(k, companyId){
  var s=String(k||'');
  if(!s) return false;
  if(companyId!=null && String(companyId)!=='' && s===String(companyId)) return true;
  return /^\d+$/.test(s); // pure numeric keys are company ids in this schema (D001 is not pure numeric)
}
function dosIsLegacyDriverId(id){ return /^D\d+/i.test(String(id||'').trim()); }

function dosPreferCanonId(v, fallbackKey, existingCanon){
  if(!v||typeof v!=='object') return String(fallbackKey||'');
  var candidates=[v.dispatcherId, v.id, v.driverId, v.DriverId, fallbackKey];
  for(var i=0;i<candidates.length;i++){
    var c=candidates[i];
    if(c!=null && String(c).trim()!=='' && dosIsLegacyDriverId(c)) return String(c).trim();
  }
  if(existingCanon){
    var aliases=[v.uid, v.Uid, fallbackKey, v.fleetKey].filter(Boolean).map(String);
    for(var a=0;a<aliases.length;a++){
      var prev=existingCanon[aliases[a]];
      if(prev && dosIsLegacyDriverId(prev)) return prev;
    }
  }
  for(var j=0;j<candidates.length;j++){
    var c2=candidates[j];
    if(c2!=null && String(c2).trim()!=='') return String(c2).trim();
  }
  return String(fallbackKey||'');
}

/** Build alias→canonical-driver-id map (D00x preferred) + display names. */
function dosBuildDriverCanon(driversRoot, driversCid, companyId){
  var canon={}, names={}, valid={};
  function setCanon(alias, canonId, name){
    if(alias==null||alias==='') return;
    var a=String(alias);
    if(dosIsCompanyKey(a, companyId)) return;
    var c=String(canonId);
    if(!c||dosIsCompanyKey(c, companyId)) return;
    if(canon[a] && dosIsLegacyDriverId(canon[a]) && !dosIsLegacyDriverId(c)) return; // never demote D00x to a uid
    canon[a]=c;
    if(name){ names[a]=name; names[c]=name; }
    valid[c]=true;
  }
  function ingest(key, d, fromCompanyScoped){
    if(!d||typeof d!=='object') return;
    if(dosIsCompanyKey(key, companyId) && dosLooksLikeCompanyBucket(d)){
      Object.keys(d).forEach(function(childKey){ ingest(childKey, d[childKey], true); });
      return;
    }
    if(!fromCompanyScoped && d.companyId!=null && companyId && String(d.companyId)!==String(companyId)) return;
    if(/^\d+$/.test(String(key)) && !d.name && !d.email && !d.firstName) return;
    var name=[d.firstName||d.first_name||'', d.lastName||d.last_name||d.surname||'', d.name||''].join(' ').trim() || d.email || d.dispatcherId || '';
    if(!name && !d.id && !d.driverId && !d.dispatcherId && !d.uid) return;
    var canonId=dosPreferCanonId(d, key, canon);
    if(!canonId || dosIsCompanyKey(canonId, companyId)) return;
    setCanon(key, canonId, name||canonId);
    setCanon(d.uid, canonId, name||canonId);
    setCanon(d.Uid, canonId, name||canonId);
    setCanon(d.id, canonId, name||canonId);
    setCanon(d.driverId, canonId, name||canonId);
    setCanon(d.DriverId, canonId, name||canonId);
    setCanon(d.dispatcherId, canonId, name||canonId);
    setCanon(canonId, canonId, name||canonId);
  }
  if(driversCid && typeof driversCid==='object'){
    Object.keys(driversCid).forEach(function(k){ ingest(k, driversCid[k], true); });
  }
  if(driversRoot && typeof driversRoot==='object'){
    Object.keys(driversRoot).forEach(function(k){ ingest(k, driversRoot[k], false); });
  }
  return {canon:canon, names:names, valid:valid};
}

function dosResolveDriverId(rawId, canonMap, companyId){
  if(rawId==null||rawId===''||rawId==='0') return null;
  var id=String(rawId);
  if(dosIsCompanyKey(id, companyId)) return null;
  if(canonMap && canonMap[id]) return canonMap[id];
  return id;
}

/** Prefer app-authored workedMinutes; workedMinutes:0 is meaningful — never fall back to wall clock for it. */
function dosSessionDurationMin(s, startTs, endTs){
  if(s && s.workedMinutes!=null && s.workedMinutes!==''){
    var wm=parseFloat(s.workedMinutes);
    return isFinite(wm)&&wm>0?Math.round(wm):0;
  }
  if(s && s.totalMinutes!=null && s.totalMinutes!==''){
    var tm=parseFloat(s.totalMinutes);
    return isFinite(tm)&&tm>0?Math.round(tm):0;
  }
  if(startTs && endTs && endTs>startTs){
    var wall=Math.round((endTs-startTs)/60000);
    if(wall>=DOS_MAX_SESSION_MIN) return 0; // stale/ghost close stamped at the cap
    return wall;
  }
  return 0;
}
function dosExtractBreakMin(s){
  if(!s||typeof s!=='object') return 0;
  var breakMin=0;
  if(s.breaks && typeof s.breaks==='object'){
    Object.values(s.breaks).forEach(function(b){
      if(!b) return;
      var bm=parseFloat(b.breakMinutes||0);
      if(bm>0){ breakMin+=bm; return; }
      var bs=dosParseTs(b.breakStart||b.start||b.startTime);
      var be=dosParseTs(b.breakEnd||b.end||b.endTime);
      if(bs&&be&&be>bs) breakMin+=Math.round((be-bs)/60000);
    });
  }
  breakMin += parseFloat(s.breakMinutes||s.breakMin||0)||0;
  return Math.max(0, Math.round(breakMin));
}

/** Progressive End-Shift snapshots share a window & cumulative workedMinutes — take max, never sum. */
function dosCollapseProgressiveSessions(sessions){
  var groups={};
  (sessions||[]).forEach(function(s){
    if(!s||typeof s!=='object') return;
    var windowTs=Number(s._windowTs||s.windowTs||s.shiftStartAt||0) || Number(s._startTs||s.startTs||0) || 0;
    var sessionTs=Number(s._sessionTs||s.sessionTs||s.sessionStartedAt||0) || 0;
    var hasSession=!!(sessionTs||s._hasSessionStart);
    var end=Number(s._endTs||s.endTs||0)||0;
    var minutes=s._sessionMin!=null?Number(s._sessionMin):(s.durationMin!=null?Number(s.durationMin):0);
    if(!isFinite(minutes)||minutes<0) minutes=0;
    var key=String(s.driverId||s._driverId||'')+'|'+String(windowTs||'none')+'|'+(hasSession?String(sessionTs):'legacy');
    if(!groups[key]){
      groups[key]={windowTs:windowTs, sessionTs:sessionTs, hasSessionStart:hasSession, endTs:end,
        minutes:Math.round(minutes), breakMin:Number(s._breakMin||s.breakMin||0)||0, driverId:s.driverId};
    } else {
      var g=groups[key];
      if(end>g.endTs) g.endTs=end;
      if(Math.round(minutes)>g.minutes) g.minutes=Math.round(minutes);
      var br=Number(s._breakMin||s.breakMin||0)||0;
      if(br>g.breakMin) g.breakMin=br;
      if(hasSession && sessionTs && (!g.sessionTs||sessionTs<g.sessionTs)) g.sessionTs=sessionTs;
    }
  });
  return Object.keys(groups).map(function(k){
    var g=groups[k];
    var startTs=g.hasSessionStart&&g.sessionTs?g.sessionTs:g.windowTs;
    return {startTs:startTs, endTs:g.endTs, durationMin:g.minutes, _startTs:startTs, _endTs:g.endTs,
      _sessionMin:g.minutes, _breakMin:g.breakMin, _windowTs:g.windowTs, _sessionTs:g.sessionTs,
      _hasSessionStart:g.hasSessionStart, driverId:g.driverId};
  });
}
function dosSumCollapsedWorkMin(sessions){
  return dosCollapseProgressiveSessions(sessions).reduce(function(a,s){ return a+(s._sessionMin||s.durationMin||0); },0);
}

/** Flatten shiftLogs / attendance / driverSessions nodes into per-driver session rows. */
function dosFlattenShiftLogNodes(logsArr, opts){
  opts=opts||{};
  var companyId=opts.companyId!=null?String(opts.companyId):'';
  var canonMap=opts.canonMap||{};
  var validIds=opts.validIds||null;
  var lastShiftData=opts.lastShiftData||null;
  var byDriver={};
  function ensure(id){ if(!byDriver[id]) byDriver[id]={sessions:[],totalMinutes:0}; return byDriver[id]; }
  function addSession(rawDriverKey, vehicleId, windowTs, endTs, sessionObj, sessionTs){
    var driverKey=dosResolveDriverId(rawDriverKey, canonMap, companyId);
    if(!driverKey) return;
    if(validIds && !validIds[driverKey]) return;
    var hasSessionStart=!!(sessionTs&&sessionTs>0);
    var startTs=hasSessionStart?sessionTs:(windowTs||0);
    var dur=dosSessionDurationMin(sessionObj||{}, startTs, endTs);
    var brk=dosExtractBreakMin(sessionObj||{});
    var loggedAt=0;
    if(sessionObj){
      var la=sessionObj.loggedAt||sessionObj.LoggedAt;
      if(la!=null&&la!==''){
        if(typeof la==='number') loggedAt=la>1e12?la:(la>1e10?la:la*1000);
        else { var parsed=Date.parse(String(la)); loggedAt=isNaN(parsed)?0:parsed; }
      }
    }
    ensure(driverKey).sessions.push({
      startTs:startTs||0, endTs:endTs||0, loggedAt:loggedAt||0, durationMin:dur, breakMin:brk,
      vehicleId:vehicleId||'\u2014', sourceKey:String(rawDriverKey), activityTs:endTs||loggedAt||startTs||0,
      windowTs:windowTs||0, sessionTs:hasSessionStart?sessionTs:0, hasSessionStart:hasSessionStart
    });
  }
  function ingestDriverSessions(driverKey, sessions){
    if(!sessions||typeof sessions!=='object') return;
    Object.keys(sessions).forEach(function(sk){
      var s=sessions[sk];
      if(!dosLooksLikeSession(s)) return;
      var windowTs=dosParseTs(s.shiftStartAt||s.startTime||s.start||s.StartTime||s.startTs);
      var sessionTs=dosParseTs(s.sessionStartedAt);
      var end=dosParseTs(s.endTime||s.logoutTime||s.end||s.EndTime||s.logout||s.finishTime||s.shiftEndAt||s.endTs);
      var vid=s.vehicleId||s.VehicleId||s.vehicle||'\u2014';
      addSession(driverKey, vid, windowTs, end, s, sessionTs);
    });
  }
  function ingestNode(logData){
    if(!logData||typeof logData!=='object') return;
    Object.keys(logData).forEach(function(k1){
      var v1=logData[k1];
      if(!v1||typeof v1!=='object') return;
      if(dosIsCompanyKey(k1, companyId)||dosLooksLikeCompanyBucket(v1)){
        Object.keys(v1).forEach(function(driverKey){ ingestDriverSessions(driverKey, v1[driverKey]); });
        return;
      }
      if(dosLooksLikeDriverBucket(v1)){ ingestDriverSessions(k1, v1); return; }
      if(dosLooksLikeSession(v1)){
        var did=v1.driverId||v1.DriverId||v1.driver||k1;
        var windowTs=dosParseTs(v1.shiftStartAt||v1.startTime||v1.start||v1.StartTime||v1.startTs);
        var sessionTs=dosParseTs(v1.sessionStartedAt);
        var end=dosParseTs(v1.endTime||v1.logoutTime||v1.end||v1.EndTime||v1.finishTime||v1.shiftEndAt||v1.endTs);
        var vid=v1.vehicleId||v1.VehicleId||'\u2014';
        addSession(did, vid, windowTs, end, v1, sessionTs);
      }
    });
  }
  (logsArr||[]).forEach(ingestNode);
  if(lastShiftData && typeof lastShiftData==='object'){
    Object.keys(lastShiftData).forEach(function(id){
      if(dosIsCompanyKey(id, companyId)||id==='0') return;
      var resolved=dosResolveDriverId(id, canonMap, companyId);
      if(!resolved) return;
      if(validIds && !validIds[resolved]) return;
      if(byDriver[resolved] && byDriver[resolved].sessions.length) return;
      var endTs=dosParseTs(lastShiftData[id]);
      if(!endTs) return;
      addSession(resolved, '\u2014', 0, endTs, {}, 0);
    });
  }
  Object.keys(byDriver).forEach(function(id){
    var d=byDriver[id];
    d.totalMinutes=dosSumCollapsedWorkMin((d.sessions||[]).map(function(s){
      return {driverId:id,_windowTs:s.windowTs,_sessionTs:s.sessionTs,_hasSessionStart:s.hasSessionStart,
        _startTs:s.startTs,_endTs:s.endTs,_sessionMin:s.durationMin,_breakMin:s.breakMin};
    }));
  });
  return byDriver;
}

/** Driver Ops hours — same flatten + workedMinutes + progressive collapse as Shift Reports. */
function dosAggregateDriverShiftMinutes(opts){
  opts=opts||{};
  var companyId=opts.companyId!=null?String(opts.companyId):'';
  var fromMs=Number(opts.fromMs)||0;
  var toMs=Number(opts.toMs)||Number.MAX_SAFE_INTEGER;
  var built=dosBuildDriverCanon(opts.driversRoot, opts.driversCid, companyId);
  var logsArr=[];
  if(opts.shiftLogs) logsArr.push(opts.shiftLogs);
  if(opts.attendance) logsArr.push(opts.attendance);
  if(opts.driverSessions) logsArr.push(opts.driverSessions);
  var byDriver=dosFlattenShiftLogNodes(logsArr, {
    companyId:companyId, canonMap:built.canon,
    validIds:Object.keys(built.valid||{}).length?built.valid:null,
    names:built.names, lastShiftData:opts.lastShiftData||null
  });
  var out={};
  Object.keys(byDriver).forEach(function(did){
    var sessions=byDriver[did].sessions||[];
    var filtered=sessions.filter(function(s){
      var st=Number(s.startTs)||0, en=Number(s.endTs)||0;
      var act=Number(s.activityTs)||en||st||0;
      if(st&&en) return st<=toMs && en>=fromMs;
      if(!act) return false;
      return act>=fromMs && act<=toMs;
    });
    var mapped=filtered.map(function(s){
      return {driverId:did,_windowTs:s.windowTs,_sessionTs:s.sessionTs,_hasSessionStart:s.hasSessionStart,
        _startTs:s.startTs,_endTs:s.endTs,_sessionMin:s.durationMin,_breakMin:s.breakMin,
        durationMin:s.durationMin, breakMin:s.breakMin};
    });
    var collapsed=dosCollapseProgressiveSessions(mapped);
    var work=0, brk=0;
    collapsed.forEach(function(s){ work+=Number(s._sessionMin||s.durationMin||0)||0; brk+=Number(s._breakMin||s.breakMin||0)||0; });
    out[did]={workMinutes:Math.round(work), breakMinutes:Math.round(brk)};
  });
  return {byDriver:out, canon:built.canon, names:built.names, valid:built.valid};
}
function dosFmtDur(minutes){
  if(minutes==null||minutes===''||!isFinite(Number(minutes))||Number(minutes)<=0) return '\u2014';
  var total=Math.round(Number(minutes));
  var h=Math.floor(total/60), m=total%60;
  return h+'h '+(m<10?'0':'')+m+'m';
}

/* ============================================================================
 * Pay / job / source classification — ported from
 * INVT-admin/lib/driverOpsSummary.js.
 * ========================================================================== */
function dosClassifyPaymentMethod(pm){
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
/** Detect Total Mobility jobs even when PaymentType is Cash/other. */
function dosIsTmJob(job){
  if(!job||typeof job!=='object') return false;
  if(job.isTotalMobility===true||job.tmUsed===true) return true;
  if(job.tmPaymentType==='total_mobility'||job.paymentCategory==='total_mobility') return true;
  var pm=job.PaymentType||job.paymentType||job.PaymentMethod||job.paymentMethod||'';
  if(dosClassifyPaymentMethod(pm)==='tm') return true;
  if(job.tmSubsidyFare!=null&&job.tmSubsidyFare!=='') return true;
  if(job.tmSubsidy!=null&&job.tmSubsidy!=='') return true;
  if(job.tmCouncilPays!=null&&job.tmCouncilPays!=='') return true;
  if(job.councilPays!=null&&job.councilPays!=='') return true;
  if(job.tmCardNumber||job.tmVoucherNo) return true;
  return false;
}
function dosCompanyOwesDriver(fareNum, paymentMethod, cardSettings){
  cardSettings=cardSettings||{};
  var gross=Math.max(0, parseFloat(fareNum)||0);
  var bucket=dosClassifyPaymentMethod(paymentMethod);
  if(gross<=0) return {bucket:bucket, gross:0, owed:0, commission:0};
  // Cash / EFTPOS / Account(ACC): visible gross×count only — not BookaWaka Mark Paid.
  if(bucket==='cash'||bucket==='eftpos'||bucket==='account') return {bucket:bucket, gross:gross, owed:0, commission:0};
  if(bucket==='card'){
    var compPct=parseFloat(cardSettings.companyPercent)||0;
    var drvPct=parseFloat(cardSettings.driverPercent)||0;
    var commission=(gross*compPct)/100+(gross*drvPct)/100;
    var owed=Math.max(0, gross-commission);
    return {bucket:bucket, gross:gross, owed:owed, commission:commission};
  }
  // TM PaymentType alone still returns full fare — dosJobPaymentLines settles subsidy (+ hoist).
  return {bucket:bucket, gross:gross, owed:gross, commission:0};
}
/** Meter TM subsidy + display %. Prefer tmSubsidyFare; else combined−hoist; else fare−hoist−pax. */
function dosTmSubsidyParts(job){
  var fare=parseFloat(job.TotalFare||job.totalFare||job.tmTotalFare||job.Fare||job.fare||job.RideCost||job.EstimatedFare||0)||0;
  var hoistAmt=parseFloat(job.tmSubsidyHoist||job.hoistFare||job.HoistFare||job.hoistAmount||0)||0;
  var subsidy=0;
  if(job.tmSubsidyFare!=null&&job.tmSubsidyFare!==''){
    subsidy=parseFloat(job.tmSubsidyFare)||0;
  } else {
    var combined=parseFloat(job.tmSubsidy||job.tmCouncilPays||job.councilPays||0)||0;
    if(combined>0){
      subsidy=hoistAmt>0?Math.max(0, combined-hoistAmt):combined;
    } else {
      var hasPax=(job.tmPassengerPays!=null&&job.tmPassengerPays!=='')||
        (job.passengerPays!=null&&job.passengerPays!=='')||
        (job.patientPays!=null&&job.patientPays!=='');
      if(hasPax){
        var pax0=parseFloat(job.tmPassengerPays||job.passengerPays||job.patientPays||0)||0;
        subsidy=Math.max(0, fare-hoistAmt-pax0);
      }
    }
  }
  subsidy=Math.round(Math.max(0, subsidy)*100)/100;
  var pax=parseFloat(job.tmPassengerPays||job.passengerPays||job.patientPays||0)||0;
  var meterBase=Math.max(0, fare-hoistAmt);
  var councilPct=parseFloat(job.tmSubsidyPercent||job.subsidyPercent||job.councilPercent||job.tmPercent||'');
  if(!isFinite(councilPct)||councilPct<=0) councilPct=null;
  var passengerPct=parseFloat(job.tmPassengerPercent||job.passengerPercent||'');
  if(!isFinite(passengerPct)||passengerPct<=0) passengerPct=null;
  if(councilPct==null&&meterBase>0.009&&subsidy>0) councilPct=Math.round((subsidy/meterBase)*1000)/10;
  if(passengerPct==null&&meterBase>0.009&&pax>0) passengerPct=Math.round((pax/meterBase)*1000)/10;
  else if(passengerPct==null&&councilPct!=null) passengerPct=Math.round((100-councilPct)*10)/10;
  return {
    fare:Math.round(fare*100)/100,
    subsidy:subsidy,
    hoistAmt:Math.round(Math.max(0, hoistAmt)*100)/100,
    passengerPays:Math.round(Math.max(0, pax)*100)/100,
    meterBase:Math.round(meterBase*100)/100,
    councilPct:councilPct,
    passengerPct:passengerPct
  };
}
/**
 * Split a job into pay lines.
 * TM: cash/EFTPOS/Account remainder stays $0-owed; subsidy still enters tm.owed.
 * PaymentType===TM never owes full fare — subsidy only. Hoist is separate.
 */
function dosJobPaymentLines(job, cardSettings){
  cardSettings=cardSettings||{};
  var fare=parseFloat(job.TotalFare||job.totalFare||job.Fare||job.fare||job.RideCost||job.EstimatedFare||0);
  var pm=job.PaymentType||job.paymentType||job.PaymentMethod||job.paymentMethod||'';
  var hoistAmt=parseFloat(job.tmSubsidyHoist||job.hoistFare||job.HoistFare||job.hoistAmount||0);
  var hoistUses=parseInt(job.hoistUses||job.HoistUses||job.hoistCount||job.tmHoistCount||0,10)||0;
  var lines=[];
  var main=dosCompanyOwesDriver(fare, pm, cardSettings);
  if(dosIsTmJob(job)){
    if(main.bucket==='cash'||main.bucket==='eftpos'||main.bucket==='account'){
      lines.push({kind:'main', bucket:main.bucket, gross:main.gross, owed:0, commission:0});
    }
    var parts=dosTmSubsidyParts(job);
    if(parts.subsidy>0){
      lines.push({kind:'tm_subsidy', bucket:'tm', gross:parts.subsidy, owed:parts.subsidy, commission:0});
    }
  } else {
    lines.push({kind:'main', bucket:main.bucket, gross:main.gross, owed:main.owed, commission:main.commission});
  }
  if(hoistAmt>0||hoistUses>0){
    var hGross=hoistAmt>0?hoistAmt:0;
    lines.push({kind:'hoist', bucket:'hoist', gross:hGross, owed:hGross, commission:0, uses:hoistUses});
  }
  return lines;
}
function dosNormalizeJobOutcome(status){
  var s=String(status||'').toLowerCase().replace(/[\s_-]/g,'');
  if(!s) return 'other';
  if(s.indexOf('complete')>=0||s==='closed'||s==='done'||s==='finished') return 'completed';
  if(s.indexOf('cancel')>=0) return 'cancelled';
  if(s.indexOf('reject')>=0||s.indexOf('declin')>=0) return 'rejected';
  if(s.indexOf('noshow')>=0||s==='ns') return 'no_show';
  return 'other';
}
function dosNormalizeJobSource(job){
  var raw=String(job.source||job.bookingSource||job.BookingSource||job.Source||job.via||job.Via||'').toLowerCase();
  var svc=String(job.serviceType||job.ServiceType||job.bookingType||job.Bookingtype||'').toLowerCase();
  if(svc.indexOf('food')>=0||raw.indexOf('food')>=0) return 'food';
  if(svc.indexOf('freight')>=0||raw.indexOf('freight')>=0||raw.indexOf('parcel')>=0) return 'freight';
  if(raw.indexOf('hail')>=0||raw.indexOf('driverapp')>=0||raw.indexOf('driver_app')>=0||raw.indexOf('driver-app')>=0||
     raw.indexOf('driver created')>=0||raw.indexOf('street')>=0||raw==='queue'||raw.indexOf('driverqueue')>=0) return 'hail';
  if(raw.indexOf('dispatch')>=0||raw.indexOf('console')>=0) return 'dispatch';
  if(raw.indexOf('web')>=0||raw.indexOf('website')>=0) return 'website';
  if(raw.indexOf('passenger')>=0||raw.indexOf('rider')>=0||raw.indexOf('pax')>=0) return 'passenger_app';
  if(raw.indexOf('app')>=0) return 'passenger_app';
  return raw?'other':'unknown';
}
/** "$12.50 ×3" — count always shown when > 0. */
function dosFormatPayWithCount(owedOrGross, count){
  var n=Math.round((parseFloat(owedOrGross)||0)*100)/100;
  var c=parseInt(count,10)||0;
  var m='$'+n.toFixed(2);
  return c>0?(m+' \u00d7'+c):m;
}
/** NZ-friendly period bounds. Supports month / week / day / custom range. */
function dosPeriodBounds(mode, refMs, rangeFromYmd, rangeToYmd){
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
      if(toMs<fromMs){
        var tmp=fromMs;
        fromMs=sod(toParts[0],toParts[1]-1,toParts[2]);
        toMs=eod(fromParts[0],fromParts[1]-1,fromParts[2]);
      }
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
function dosEmptyPayTotals(){
  return {cash:{gross:0,owed:0,count:0}, card:{gross:0,owed:0,count:0}, eftpos:{gross:0,owed:0,count:0},
    tm:{gross:0,owed:0,count:0}, hoist:{gross:0,owed:0,count:0,uses:0}, account:{gross:0,owed:0,count:0}, other:{gross:0,owed:0,count:0}};
}
function dosEmptyOutcomeTotals(){ return {completed:0,cancelled:0,rejected:0,no_show:0,other:0,total:0}; }
function dosEmptySourceTotals(){ return {dispatch:0,passenger_app:0,website:0,food:0,freight:0,hail:0,other:0,unknown:0}; }
function dosEmptyTmDetail(){ return {trips:0,fare:0,subsidy:0,hoist:0,hoistUses:0,passengerPays:0,owed:0,paid:0,councilPct:null,passengerPct:null}; }
function dosJobTs(j){
  return dosParseTs(j.completedAt||j.CompletedAt||j.endTime||j.EndTime||j.finishTime||
    j.timestamp||j.Timestamp||j.createdAt||j.CreatedAt||j.jobDate||j.JobDate||j.dateTime||j.DateTime);
}

/** Build one driver summary row from jobs + shift minutes + Card/TM settlements (Track C). */
function dosIsSettlementLocked(s){ return !!(s&&(s.locked||s.status==='paid')); }
function dosResolveStreamLocks(opts){
  opts=opts||{};
  var legacyLocked=dosIsSettlementLocked(opts.legacySettlement||opts.settlement);
  return {
    cardLocked: legacyLocked || dosIsSettlementLocked(opts.cardSettlement),
    tmLocked: legacyLocked || dosIsSettlementLocked(opts.tmSettlement),
    legacyLocked: legacyLocked
  };
}
function dosBuildDriverSummaryRow(opts){
  opts=opts||{};
  var jobs=opts.jobs||[], cardSettings=opts.cardSettings||{};
  var settlement=opts.settlement||null;
  var cardSettlement=opts.cardSettlement||null;
  var tmSettlement=opts.tmSettlement||null;
  var pay=dosEmptyPayTotals();
  var outcomes=dosEmptyOutcomeTotals();
  var sources=dosEmptySourceTotals();
  var tmDetail=dosEmptyTmDetail();
  var vehicles={};
  var pctSamples=[];
  var paxPctSamples=[];
  jobs.forEach(function(job){
    var outcome=dosNormalizeJobOutcome(job.jobstatus||job.JobStatus||job.status||job.Status||'');
    outcomes[outcome]=(outcomes[outcome]||0)+1; outcomes.total++;
    var src=dosNormalizeJobSource(job);
    sources[src]=(sources[src]||0)+1;
    var veh=String(job.vehicleId||job.VehicleId||job.taxiNumber||job.TaxiNumber||job.carNumber||'').trim();
    if(veh) vehicles[veh]=(vehicles[veh]||0)+1;
    if(outcome!=='completed') return;
    var tmJob=dosIsTmJob(job);
    if(tmJob){
      tmDetail.trips+=1;
      var parts=dosTmSubsidyParts(job);
      tmDetail.fare+=parts.fare; tmDetail.subsidy+=parts.subsidy; tmDetail.hoist+=parts.hoistAmt; tmDetail.passengerPays+=parts.passengerPays;
      var uses=parseInt(job.hoistUses||job.HoistUses||job.hoistCount||job.tmHoistCount||0,10)||0;
      tmDetail.hoistUses+=uses;
      if(parts.councilPct!=null) pctSamples.push(parts.councilPct);
      if(parts.passengerPct!=null) paxPctSamples.push(parts.passengerPct);
    }
    dosJobPaymentLines(job, cardSettings).forEach(function(line){
      var b=line.bucket;
      if(!pay[b]) pay[b]={gross:0,owed:0,count:0};
      pay[b].gross+=line.gross; pay[b].owed+=line.owed; pay[b].count+=1;
      if(b==='hoist' && line.uses) pay.hoist.uses=(pay.hoist.uses||0)+line.uses;
    });
  });
  if(pctSamples.length){ tmDetail.councilPct=Math.round((pctSamples.reduce(function(a,b){return a+b;},0)/pctSamples.length)*10)/10; }
  if(paxPctSamples.length){ tmDetail.passengerPct=Math.round((paxPctSamples.reduce(function(a,b){return a+b;},0)/paxPctSamples.length)*10)/10; }
  else if(tmDetail.councilPct!=null){ tmDetail.passengerPct=Math.round((100-tmDetail.councilPct)*10)/10; }
  tmDetail.owed=Math.round((pay.tm.owed+pay.hoist.owed)*100)/100;
  tmDetail.fare=Math.round(tmDetail.fare*100)/100;
  tmDetail.subsidy=Math.round(tmDetail.subsidy*100)/100;
  tmDetail.hoist=Math.round(tmDetail.hoist*100)/100;
  tmDetail.passengerPays=Math.round(tmDetail.passengerPays*100)/100;
  var cardOwedBeforeLock=Math.round((pay.card.owed+pay.other.owed)*100)/100;
  var tmOwedBeforeLock=Math.round((pay.tm.owed+pay.hoist.owed)*100)/100;
  var owedBeforeLock=Math.round((cardOwedBeforeLock+tmOwedBeforeLock)*100)/100;
  var locks=dosResolveStreamLocks({cardSettlement:cardSettlement,tmSettlement:tmSettlement,legacySettlement:settlement});
  var cardLocked=locks.cardLocked, tmLocked=locks.tmLocked;
  var locked=cardLocked&&tmLocked;
  var status='open';
  if(locked) status='paid';
  else if(cardLocked||tmLocked) status='partial';
  if(tmLocked){ tmDetail.paid=tmDetail.owed; tmDetail.owed=0; }
  var cardOwed=cardLocked?0:cardOwedBeforeLock;
  var tmOwed=tmLocked?0:tmOwedBeforeLock;
  return {
    driverId:String(opts.driverId||''), driverName:String(opts.driverName||opts.driverId||'Driver'),
    workMinutes:Math.max(0, opts.workMinutes|0), breakMinutes:Math.max(0, opts.breakMinutes|0),
    outcomes:outcomes, sources:sources, tmDetail:tmDetail, vehicles:Object.keys(vehicles).sort(),
    pay:pay, cashHeld:pay.cash.gross,
    cardOwed:cardOwed, tmOwed:tmOwed,
    cardOwedBeforeLock:cardOwedBeforeLock, tmOwedBeforeLock:tmOwedBeforeLock,
    owedTotal:Math.round((cardOwed+tmOwed)*100)/100, owedBeforeLock:owedBeforeLock,
    status:status, locked:locked, cardLocked:cardLocked, tmLocked:tmLocked,
    cardSettlement:cardSettlement, tmSettlement:tmSettlement, settlement:settlement,
    bankName:(opts.bankName||''), accountName:(opts.accountName||''), accountNumber:(opts.accountNumber||''),
    jobs:jobs
  };
}

/* ============================================================================
 * Page wiring
 * ========================================================================== */
window._fbOnLogin = function(){
  _fbGet('superClients').then(function(d){
    allCompanies=d||{};
    var o='<option value="">\u2014 Select company \u2014</option>';
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
    document.getElementById('dos-range-from').value=yd;
    document.getElementById('dos-range-to').value=yd;
  });
};

function dosOnMode(){
  var mode=document.getElementById('dos-mode').value;
  document.getElementById('dos-month-wrap').style.display=mode==='month'?'':'none';
  document.getElementById('dos-day-wrap').style.display=mode==='day'?'':'none';
  document.getElementById('dos-week-wrap').style.display=mode==='week'?'':'none';
  document.getElementById('dos-range-wrap').style.display=mode==='range'?'flex':'none';
  dosLoad();
}
function dosCurrentPeriod(){
  var mode=document.getElementById('dos-mode').value||'month';
  var ref=Date.now();
  if(mode==='month'){ var mv=document.getElementById('dos-month').value; if(mv){ var p=mv.split('-'); ref=new Date(+p[0],+p[1]-1,15).getTime(); } }
  else if(mode==='day'){ var dv=document.getElementById('dos-day').value; if(dv) ref=new Date(dv+'T12:00:00').getTime(); }
  else if(mode==='week'){ var wv=document.getElementById('dos-week').value; if(wv) ref=new Date(wv+'T12:00:00').getTime(); }
  if(mode==='range'){
    var rf=document.getElementById('dos-range-from').value;
    var rt=document.getElementById('dos-range-to').value;
    return dosPeriodBounds('range', ref, rf, rt);
  }
  return dosPeriodBounds(mode, ref);
}

/** Driver metadata (name / bank details) keyed by every id alias we can find. */
function dosIngestDriversMeta(dataRoot, dataCid, cid){
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
  ingest(dataCid, true);
  ingest(dataRoot, false);
  return meta;
}

function dosLoad(){
  var cid=document.getElementById('dos-company').value;
  if(!cid){
    document.getElementById('dos-tb').innerHTML='<tr><td colspan="24" class="empty">Choose a company to load.</td></tr>';
    document.getElementById('dos-stats').style.display='none';
    document.getElementById('dos-title').textContent='Select a company';
    return;
  }
  _dosPeriod=dosCurrentPeriod();
  document.getElementById('dos-title').textContent=(allCompanies[cid]&&allCompanies[cid].name||cid)+' \u2014 '+_dosPeriod.label;
  document.getElementById('dos-tb').innerHTML='<tr><td colspan="24" class="empty">Loading\u2026</td></tr>';

  Promise.all([
    _fbGet('companies/'+cid+'/cardSettings').catch(function(){return {};}),
    _fbGet('drivers').catch(function(){return null;}),
    _fbGet('drivers/'+cid).catch(function(){return null;}),
    _fbGet('joback',{limitToLast:800}).catch(function(){return null;}),
    _fbGet('completedJobs/'+cid).catch(function(){return null;}),
    _fbGet('closedJobs/'+cid).catch(function(){return null;}),
    _fbGet('allbookings/'+cid).catch(function(){return null;}),
    _fbGet('shiftLogs/'+cid).catch(function(){return null;}),
    _fbGet('attendance/'+cid).catch(function(){return null;}),
    _fbGet('driverSessions/'+cid).catch(function(){return null;}),
    _fbGet('driverSettlements/'+cid+'/'+_dosPeriod.key).catch(function(){return null;}),
    _fbGet('cardDriverSettlements/'+cid+'/'+_dosPeriod.key).catch(function(){return null;}),
    _fbGet('tmDriverSettlements/'+cid+'/'+_dosPeriod.key).catch(function(){return null;})
  ]).then(function(res){
    _dosCs=res[0]||{};
    var driversRoot=res[1], driversCid=res[2];
    var legacySettlements=res[10]||{};
    var cardSettlements=res[11]||{};
    var tmSettlements=res[12]||{};

    var shiftAgg=dosAggregateDriverShiftMinutes({
      companyId:cid, fromMs:_dosPeriod.fromMs, toMs:_dosPeriod.toMs,
      driversRoot:driversRoot, driversCid:driversCid,
      shiftLogs:res[7], attendance:res[8], driverSessions:res[9]
    });
    var canon=shiftAgg.canon, names=shiftAgg.names;
    var driversMeta=dosIngestDriversMeta(driversRoot, driversCid, cid);

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
            if(!did||did===bid) return;
            if(!merged[bid][did]) merged[bid][did]={};
            Object.assign(merged[bid][did], j);
          });
        }
      });
    }

    // Resolve every job's driverId to the same canonical id used for shift hours —
    // this is the identity fix that lines jobs up with the correct driver row.
    var allJobs=[];
    Object.keys(merged).forEach(function(bid){
      Object.keys(merged[bid]||{}).forEach(function(did){
        var j=merged[bid][did]; if(!j||typeof j!=='object') return;
        var copy=Object.assign({}, j);
        copy.bookingId=copy.bookingId||bid;
        var rawDid=String(copy.driverId||copy.DriverId||did||'').trim();
        if(!rawDid||rawDid===bid||rawDid===String(copy.bookingId||'')) return;
        var canonDid=dosResolveDriverId(rawDid, canon, cid);
        if(!canonDid) return; // rejected company/phantom ids (e.g. "0") — do not fall back
        copy.driverId=canonDid;
        var ts=dosJobTs(copy);
        if(ts>=_dosPeriod.fromMs && ts<=_dosPeriod.toMs) allJobs.push(copy);
      });
    });

    var byDriver={};
    allJobs.forEach(function(j){
      var did=String(j.driverId||''); if(!did) return;
      if(!byDriver[did]) byDriver[did]=[];
      byDriver[did].push(j);
    });
    Object.keys(shiftAgg.byDriver).forEach(function(did){ if(!byDriver[did]) byDriver[did]=[]; });

    var dispMap={};
    allJobs.forEach(function(j){
      var dn=String(j.DispatcherName||j.dispatcherName||j.dispatcher||j.bookedBy||'').trim();
      if(!dn||dn==='\u2014'||dn==='-') return;
      if(!dispMap[dn]) dispMap[dn]={name:dn,total:0,completed:0,cancelled:0};
      dispMap[dn].total++;
      var o=dosNormalizeJobOutcome(j.jobstatus||j.JobStatus||j.status||'');
      if(o==='completed') dispMap[dn].completed++;
      if(o==='cancelled') dispMap[dn].cancelled++;
    });
    _dosDisp=Object.keys(dispMap).map(function(k){return dispMap[k];}).sort(function(a,b){return b.total-a.total;});

    function pickSettle(map, did, meta){
      return (map&&map[did])||(meta&&meta.pushKey&&map&&map[meta.pushKey])||null;
    }
    _dosRows=Object.keys(byDriver).map(function(did){
      var meta=driversMeta[did]||{};
      var sm=shiftAgg.byDriver[did]||{workMinutes:0,breakMinutes:0};
      return dosBuildDriverSummaryRow({
        driverId:did, driverName:meta.name||names[did]||did,
        jobs:byDriver[did], workMinutes:sm.workMinutes, breakMinutes:sm.breakMinutes,
        cardSettings:_dosCs,
        settlement:pickSettle(legacySettlements, did, meta),
        cardSettlement:pickSettle(cardSettlements, did, meta),
        tmSettlement:pickSettle(tmSettlements, did, meta),
        bankName:meta.bankName, accountName:meta.accountName, accountNumber:meta.accountNumber
      });
    }).filter(function(r){
      if(!(r.outcomes.total>0 || r.workMinutes>0 || r.owedBeforeLock>0)) return false;
      var meta=driversMeta[r.driverId];
      var looksLikeBooking=/^869\d{6,}$/.test(r.driverId) || (/^\d{10,}$/.test(r.driverId) && !meta);
      if(looksLikeBooking && !meta && r.workMinutes===0 && r.owedBeforeLock===0 && r.outcomes.completed===0) return false;
      return true;
    });

    dosRender();
  }).catch(function(e){
    document.getElementById('dos-tb').innerHTML='<tr><td colspan="24" class="empty">Error: '+esc(e&&e.message||e)+'</td></tr>';
  });
}

function dosStatusLabel(r){
  if(r.status==='paid') return 'Paid';
  if(r.status==='partial') return 'Partial';
  return 'Unpaid';
}
function dosMatchesStatusFilter(r, sf){
  if(!sf) return true;
  if(sf==='card_open') return !r.cardLocked && r.cardOwedBeforeLock>0;
  if(sf==='tm_open') return !r.tmLocked && r.tmOwedBeforeLock>0;
  if(sf==='open') return r.owedTotal>0;
  if(sf==='partial') return r.status==='partial';
  if(sf==='paid') return r.status==='paid';
  return r.status===sf;
}
function dosRender(){
  var sf=document.getElementById('dos-status').value;
  var rows=_dosRows.filter(function(r){ return dosMatchesStatusFilter(r, sf); }).slice().sort(function(a,b){ return b.owedTotal-a.owedTotal; });
  var unpaid=0,cardUnpaid=0,tmUnpaid=0,cash=0,jobs=0,paidN=0,workMin=0;
  rows.forEach(function(r){
    unpaid+=r.owedTotal; cardUnpaid+=r.cardOwed; tmUnpaid+=r.tmOwed;
    cash+=r.cashHeld; jobs+=r.outcomes.total; workMin+=r.workMinutes||0;
    if(r.status==='paid') paidN++;
  });
  document.getElementById('dos-stats').style.display='grid';
  document.getElementById('dos-stats').innerHTML=
    '<div class="stat"><div class="v">'+rows.length+'</div><div class="l">Drivers</div></div>'+
    '<div class="stat"><div class="v owed">'+money(cardUnpaid)+'</div><div class="l">Card unpaid</div></div>'+
    '<div class="stat"><div class="v owed">'+money(tmUnpaid)+'</div><div class="l">TM unpaid</div></div>'+
    '<div class="stat"><div class="v owed">'+money(unpaid)+'</div><div class="l">Total unpaid</div></div>'+
    '<div class="stat"><div class="v">'+money(cash)+'</div><div class="l">Cash held</div></div>'+
    '<div class="stat"><div class="v">'+paidN+'</div><div class="l">Fully paid</div></div>'+
    '<div class="stat"><div class="v">'+jobs+'</div><div class="l">Jobs</div></div>'+
    '<div class="stat"><div class="v">'+dosFmtDur(workMin)+'</div><div class="l">Hours worked</div></div>';

  if(!rows.length){
    document.getElementById('dos-tb').innerHTML='<tr><td colspan="24" class="empty">No driver activity in this period.</td></tr>';
  } else {
    document.getElementById('dos-tb').innerHTML=rows.map(function(r){
      var markCard=r.cardLocked || !(r.cardOwedBeforeLock>0)
        ? '<button class="sa-btn sa-btn-g" disabled title="'+(r.cardLocked?'Card stream locked':'No card owed')+'">'+(r.cardLocked?'Card paid':'No card')+'</button>'
        : '<button class="sa-btn sa-btn-p" onclick="dosMarkCardPaid(\''+esc(r.driverId)+'\')">Mark Card</button>';
      var markTm=r.tmLocked || !(r.tmOwedBeforeLock>0)
        ? '<button class="sa-btn sa-btn-g" disabled title="'+(r.tmLocked?'TM stream locked':'No TM owed')+'">'+(r.tmLocked?'TM paid':'No TM')+'</button>'
        : '<button class="sa-btn sa-btn-p" onclick="dosMarkTmPaid(\''+esc(r.driverId)+'\')">Mark TM</button>';
      var bank=r.accountNumber
        ? '<span class="bank" title="'+esc((r.bankName||'')+' / '+(r.accountName||''))+'">'+esc(r.accountNumber)+'</span>'
        : '<span class="dos-zero">\u2014</span>';
      var t=r.tmDetail;
      var tmMain=t.trips?dosFormatPayWithCount(r.tmLocked?t.paid:t.owed, t.trips):'$0.00';
      var tmPctBits=[];
      if(t.councilPct!=null) tmPctBits.push('Council '+t.councilPct+'%');
      if(t.passengerPct!=null) tmPctBits.push('Pax '+t.passengerPct+'%');
      var tmSub=t.trips?('Sub '+money(t.subsidy)+' \u00b7 Hoist '+money(t.hoist)+(tmPctBits.length?' \u00b7 '+tmPctBits.join(' / '):'')+(t.passengerPays?' \u00b7 Pax '+money(t.passengerPays):'')):'';
      function lockedNote(before){ return ' <span class="dos-sub" style="color:#2E7D32">('+money(before)+' locked)</span>'; }
      return '<tr>'+
        '<td class="sticky-driver"><b>'+esc(r.driverName)+'</b><div class="dos-sub">'+esc(r.driverId)+'</div></td>'+
        '<td>'+dosFmtDur(r.workMinutes)+'<div class="dos-sub">'+dosFmtDur(r.breakMinutes)+' brk</div></td>'+
        '<td>Done '+r.outcomes.completed+' \u00b7 Canc '+r.outcomes.cancelled+' \u00b7 Rej '+r.outcomes.rejected+' \u00b7 NS '+r.outcomes.no_show+'<div class="dos-sub">Tot '+r.outcomes.total+'</div></td>'+
        '<td class="num">'+(r.sources.dispatch||0)+'</td>'+
        '<td class="num">'+(r.sources.passenger_app||0)+'</td>'+
        '<td class="num">'+(r.sources.website||0)+'</td>'+
        '<td class="num">'+(r.sources.food||0)+'</td>'+
        '<td class="num">'+(r.sources.freight||0)+'</td>'+
        '<td class="num">'+(r.sources.hail||0)+'</td>'+
        '<td class="num">'+(r.sources.other||0)+'</td>'+
        '<td class="num">'+(r.sources.unknown||0)+'</td>'+
        '<td>'+esc(r.vehicles.join(', ')||'\u2014')+'</td>'+
        '<td class="money">'+dosFormatPayWithCount(r.cashHeld, r.pay.cash.count)+'</td>'+
        '<td class="money">'+dosFormatPayWithCount(r.cardLocked?0:r.pay.card.owed, r.pay.card.count)+'</td>'+
        '<td class="money">'+dosFormatPayWithCount(r.pay.eftpos.gross, r.pay.eftpos.count)+'</td>'+
        '<td class="money">'+tmMain+(tmSub?'<div class="dos-sub">'+tmSub+'</div>':'')+'</td>'+
        '<td class="money">'+dosFormatPayWithCount(r.pay.account.gross, r.pay.account.count)+'</td>'+
        '<td class="money">'+dosFormatPayWithCount(r.tmLocked?0:r.pay.hoist.owed, r.pay.hoist.count)+'</td>'+
        '<td class="money owed col-owed">'+money(r.cardOwed)+(r.cardLocked?lockedNote(r.cardOwedBeforeLock):'')+'</td>'+
        '<td class="money owed col-owed">'+money(r.tmOwed)+(r.tmLocked?lockedNote(r.tmOwedBeforeLock):'')+'</td>'+
        '<td class="money owed col-owed">'+money(r.owedTotal)+'</td>'+
        '<td><span class="pill '+r.status+'">'+dosStatusLabel(r)+'</span></td>'+
        '<td>'+bank+'</td>'+
        '<td style="white-space:nowrap"><button class="sa-btn sa-btn-g" onclick="dosOpenDetail(\''+esc(r.driverId)+'\')">Detail</button> '+markCard+' '+markTm+'</td>'+
      '</tr>';
    }).join('');
  }

  document.getElementById('dos-disp-tb').innerHTML=_dosDisp.length
    ? _dosDisp.map(function(d){ return '<tr><td>'+esc(d.name)+'</td><td><b>'+d.total+'</b></td><td>'+d.completed+'</td><td>'+d.cancelled+'</td></tr>'; }).join('')
    : '<tr><td colspan="4" class="empty">No dispatcher names on jobs.</td></tr>';
}

function dosOpenDetail(driverId){
  var r=_dosRows.find(function(x){return x.driverId===driverId;});
  if(!r) return;
  document.getElementById('dos-detail-title').textContent=r.driverName+' \u2014 '+(_dosPeriod&&_dosPeriod.label||'');
  var t=r.tmDetail;
  var srcBits=Object.keys(r.sources).filter(function(k){return r.sources[k];}).map(function(k){return k.replace(/_/g,' ')+': '+r.sources[k];}).join(' \u00b7 ');
  var html='<div class="sa-kv">'+
    '<div><div class="k">Hours / breaks</div><div class="val">'+dosFmtDur(r.workMinutes)+' / '+dosFmtDur(r.breakMinutes)+'</div></div>'+
    '<div><div class="k">Company owes</div><div class="val" style="color:#E65100">'+money(r.owedTotal)+'</div></div>'+
    '<div><div class="k">Card / TM owed</div><div class="val">'+money(r.cardOwed)+' / '+money(r.tmOwed)+'</div></div>'+
    '<div><div class="k">Cash held</div><div class="val">'+money(r.cashHeld)+'</div></div>'+
    '<div><div class="k">Status</div><div class="val">'+dosStatusLabel(r)+(r.cardLocked?' · Card locked':'')+(r.tmLocked?' · TM locked':'')+'</div></div>'+
    '<div><div class="k">Jobs</div><div class="val">Done '+r.outcomes.completed+' \u00b7 Canc '+r.outcomes.cancelled+' \u00b7 Rej '+r.outcomes.rejected+' \u00b7 NS '+r.outcomes.no_show+' \u00b7 Tot '+r.outcomes.total+'</div></div>'+
    '<div><div class="k">Vehicles</div><div class="val">'+esc(r.vehicles.join(', ')||'\u2014')+'</div></div>'+
    '<div style="grid-column:1 / -1"><div class="k">Sources</div><div class="val">'+esc(srcBits||'\u2014')+'</div></div>'+
    '<div style="grid-column:1 / -1"><div class="k">Bank</div><div class="val bank">'+esc([r.bankName,r.accountName,r.accountNumber].filter(Boolean).join(' \u00b7 ')||'Not on file')+'</div></div>'+
  '</div>';
  html+='<div class="sa-kv" style="border-top:1px solid #eee;padding-top:10px;margin-top:4px">'+
    '<div><div class="k">TM trips</div><div class="val">'+t.trips+'</div></div>'+
    '<div><div class="k">TM fare</div><div class="val">'+money(t.fare)+'</div></div>'+
    '<div><div class="k">TM subsidy</div><div class="val">'+money(t.subsidy)+(t.councilPct!=null?' ('+t.councilPct+'%)':'')+'</div></div>'+
    '<div><div class="k">TM hoist</div><div class="val">'+money(t.hoist)+(t.hoistUses?' \u00d7'+t.hoistUses:'')+'</div></div>'+
    '<div><div class="k">Pax pays</div><div class="val">'+money(t.passengerPays||0)+(t.passengerPct!=null?' ('+t.passengerPct+'%)':'')+'</div></div>'+
    '<div><div class="k">TM owed</div><div class="val" style="color:#E65100">'+money(t.owed)+'</div></div>'+
    '<div><div class="k">TM paid</div><div class="val" style="color:#2E7D32">'+money(t.paid)+'</div></div>'+
  '</div>';
  html+='<table class="tbl" style="min-width:0"><thead><tr><th>When</th><th>Booking</th><th>Pay</th><th>Fare</th><th>Owed</th><th>Status</th><th>Source</th></tr></thead><tbody>';
  var list=(r.jobs||[]).slice().sort(function(a,b){return dosJobTs(b)-dosJobTs(a);}).slice(0,80);
  list.forEach(function(j){
    var fare=parseFloat(j.TotalFare||j.totalFare||j.Fare||j.fare||0);
    var pm=j.PaymentType||j.paymentType||j.PaymentMethod||'';
    var lines=dosJobPaymentLines(j, _dosCs);
    var lineOwed=lines.reduce(function(a,l){return a+(l.owed||0);},0);
    var ts=dosJobTs(j);
    var isCompleted=dosNormalizeJobOutcome(j.jobstatus||j.status)==='completed';
    html+='<tr><td>'+(ts?new Date(ts).toLocaleString('en-NZ'):'\u2014')+'</td>'+
      '<td>'+esc(j.bookingId||'')+'</td><td>'+esc(pm||'\u2014')+'</td>'+
      '<td class="money">'+money(fare)+'</td><td class="money">'+(isCompleted?money(lineOwed):'\u2014')+'</td>'+
      '<td>'+esc(j.jobstatus||j.status||'')+'</td><td>'+esc(dosNormalizeJobSource(j))+'</td></tr>';
  });
  html+='</tbody></table>';
  if((r.jobs||[]).length>80) html+='<div class="sa-note">Showing latest 80 of '+r.jobs.length+' jobs.</div>';
  document.getElementById('dos-detail-body').innerHTML=html;
  document.getElementById('dos-detail-ov').classList.add('show');
}
function dosCloseDetail(){ document.getElementById('dos-detail-ov').classList.remove('show'); }

function dosMarkStreamPaid(driverId, kind){
  var cid=document.getElementById('dos-company').value;
  var r=_dosRows.find(function(x){return x.driverId===driverId;});
  if(!r||!cid) return;
  var isCard=kind==='card';
  if(isCard){ if(r.cardLocked||!(r.cardOwedBeforeLock>0)) return; }
  else { if(r.tmLocked||!(r.tmOwedBeforeLock>0)) return; }
  var amt=isCard?r.cardOwedBeforeLock:r.tmOwedBeforeLock;
  var label=isCard?'Card':'TM/Hoist';
  if(!confirm('Mark '+r.driverName+' '+label+' paid for '+_dosPeriod.label+'?\nAmount: '+money(amt)+'\nLocks '+label+' only (independent of the other stream).')) return;
  var root=isCard?'cardDriverSettlements':'tmDriverSettlements';
  var payload={
    status:'paid', locked:true, amountPaid:amt, kind:isCard?'card':'tm',
    periodKey:_dosPeriod.key, periodLabel:_dosPeriod.label,
    fromMs:_dosPeriod.fromMs, toMs:_dosPeriod.toMs,
    driverId:driverId, driverName:r.driverName,
    pay:r.pay, tmDetail:r.tmDetail, sources:r.sources,
    paidAt:Date.now(), paidBy:'superadmin'
  };
  _fbPost(root+'/'+cid+'/'+_dosPeriod.key+'/'+driverId,'PUT',payload).then(function(){
    if(isCard){
      r.cardSettlement=payload; r.cardLocked=true; r.cardOwed=0;
    } else {
      r.tmSettlement=payload; r.tmLocked=true; r.tmOwed=0;
      r.tmDetail.paid=r.tmDetail.owed; r.tmDetail.owed=0;
    }
    r.owedTotal=Math.round(((r.cardOwed||0)+(r.tmOwed||0))*100)/100;
    r.locked=!!(r.cardLocked&&r.tmLocked);
    r.status=r.locked?'paid':((r.cardLocked||r.tmLocked)?'partial':'open');
    dosRender();
  }).catch(function(e){ alert('Mark paid failed: '+(e&&e.message||e)); });
}
function dosMarkCardPaid(driverId){ dosMarkStreamPaid(driverId, 'card'); }
function dosMarkTmPaid(driverId){ dosMarkStreamPaid(driverId, 'tm'); }

function dosExportCsv(){
  var sf=document.getElementById('dos-status').value;
  var rows=_dosRows.filter(function(r){ return dosMatchesStatusFilter(r, sf); });
  var cid=document.getElementById('dos-company').value;
  var headers=['Company','Driver','DriverId','Period','Hours','BreakMin',
    'Done','Cancelled','Rejected','NoShow','JobsTotal',
    'Disp','App','Web','Food','Frt','Hail','Other','Unknown','Vehicles',
    'CashHeld','CashCount','CardOwed','CardCount','EftposGross','EftposCount',
    'TmTrips','TmFare','TmSubsidy','TmHoist','TmHoistUses','TmPassengerPays','TmOwed','TmPaid',
    'AccountGross','AccountCount','HoistOwed','HoistCount',
    'CardStreamOwed','TmStreamOwed','OwedTotal','CardStatus','TmStatus','Status','BankName','AccountName','AccountNumber'];
  var lines=[headers.join(',')];
  rows.forEach(function(r){
    function q(v){ v=String(v==null?'':v); return /[",\n]/.test(v)?'"'+v.replace(/"/g,'""')+'"':v; }
    lines.push([
      cid, r.driverName, r.driverId, _dosPeriod&&_dosPeriod.label,
      (r.workMinutes/60).toFixed(1), r.breakMinutes,
      r.outcomes.completed, r.outcomes.cancelled, r.outcomes.rejected, r.outcomes.no_show, r.outcomes.total,
      r.sources.dispatch||0, r.sources.passenger_app||0, r.sources.website||0, r.sources.food||0, r.sources.freight||0, r.sources.hail||0,
      r.sources.other||0, r.sources.unknown||0,
      r.vehicles.join(' '),
      r.cashHeld.toFixed(2), r.pay.cash.count, r.pay.card.owed.toFixed(2), r.pay.card.count,
      r.pay.eftpos.gross.toFixed(2), r.pay.eftpos.count,
      r.tmDetail.trips, r.tmDetail.fare.toFixed(2), r.tmDetail.subsidy.toFixed(2), r.tmDetail.hoist.toFixed(2),
      r.tmDetail.hoistUses, r.tmDetail.passengerPays.toFixed(2), r.tmDetail.owed.toFixed(2), r.tmDetail.paid.toFixed(2),
      r.pay.account.gross.toFixed(2), r.pay.account.count, r.pay.hoist.owed.toFixed(2), r.pay.hoist.count,
      r.cardOwed.toFixed(2), r.tmOwed.toFixed(2), r.owedTotal.toFixed(2),
      r.cardLocked?'paid':'open', r.tmLocked?'paid':'open', r.status, r.bankName, r.accountName, r.accountNumber
    ].map(q).join(','));
  });
  var a=document.createElement('a');
  a.href=URL.createObjectURL(new Blob([lines.join('\n')],{type:'text/csv'}));
  a.download='driver-ops-'+cid+'-'+(_dosPeriod&&_dosPeriod.key||'x')+'.csv';
  a.click();
}
</script>
</body>
</html>
