<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Platform Settings &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.sa-ff label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:5px}
.sa-ff input,.sa-ff select,.sa-ff textarea{width:100%;padding:8px 11px;border:1.5px solid #ddd;border-radius:6px;font-size:13px;box-sizing:border-box;font-family:inherit}
.sa-ff input:focus,.sa-ff select:focus,.sa-ff textarea:focus{outline:none;border-color:#1565C0}
.set-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;padding:18px}
.set-section{border-bottom:1px solid #f5f5f5}
.set-section:last-child{border-bottom:none}
.set-section-hdr{padding:14px 18px;font-size:13px;font-weight:700;color:#1565C0;background:#F0F7FF;display:flex;align-items:center;gap:6px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Platform Settings &mdash; BookaWaka Admin</label></div>
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
    <li class="current_section" title="Towing"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Towing</span></a><ul>
      <li><a href="SA-Towing.aspx">Towing Dashboard</a></li>
      <li><a href="SA-Towing.aspx#jobs">All Jobs</a></li>
      <li><a href="SA-Towing.aspx#config">Platform Config</a></li>
      <li><a href="/towing-portal" target="_blank">Owner Portal &#8599;</a></li>
    </ul></li>
    <li class="current_section" title="Rental Cars"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE531;</i></span><span class="menu_title">Rental Cars</span></a><ul>
      <li><a href="SA-Rental.aspx">Rental Dashboard</a></li>
      <li><a href="SA-Rental.aspx#reservations">All Reservations</a></li>
      <li><a href="SA-Rental.aspx#config">Platform Config</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-Onboard.aspx">Onboarding Requests</a></li>
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-Email.aspx">Send Email</a></li>
      <li><a href="SA-EmailLog.aspx">Email Sent Log</a></li>
      <li><a href="SA-Reports.aspx">Revenue Reports</a></li>
      <li><a href="SA-MasterReport.aspx">&#128202; Platform Overview</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="SA-Registrations.aspx">Registrations</a></li>
      <li><a href="SA-Alerts.aspx">System Alerts</a></li>
      <li><a href="SA-Settings.aspx" style="font-weight:700;color:#1565C0">&#9658; Platform Settings</a></li>
      <li><a href="SA-Broadcast.aspx">Broadcast</a></li>
      <li><a href="SA-Sessions.aspx">Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx">Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
      <li><a href="/company-portal" target="_blank">Company Portal &#8599;</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;color:#263238;margin:0 0 16px">&#9881; Platform Settings</h2>
<div id="set-notice" class="sa-notice"></div>

<div class="sa-card">
  <div class="sa-bar"><h3>&#9881; Global Platform Configuration</h3>
    <button onclick="saveSettings()" class="sa-btn sa-btn-p">&#10003; Save All Settings</button>
  </div>

  <!-- Branding -->
  <div class="set-section">
    <div class="set-section-hdr">&#127981; Platform Branding</div>
    <div class="set-grid">
      <div class="sa-ff"><label>Platform Name</label><input id="s-platform-name" type="text" placeholder="e.g. BookaWaka"/></div>
      <div class="sa-ff"><label>Support Email</label><input id="s-support-email" type="email" placeholder="e.g. support@bookawaka.co.nz"/></div>
      <div class="sa-ff"><label>Platform Website</label><input id="s-website" type="url" placeholder="e.g. https://bookawaka.co.nz"/></div>
      <div class="sa-ff"><label>Admin Alert Email</label><input id="s-alert-email" type="email" placeholder="e.g. admin@bookawaka.co.nz"/></div>
    </div>
  </div>

  <!-- Billing -->
  <div class="set-section">
    <div class="set-section-hdr">&#128179; Billing Defaults</div>
    <div class="set-grid">
      <div class="sa-ff"><label>Default Trial Period (days)</label><input id="s-trial-days" type="number" min="0" placeholder="e.g. 10"/></div>
      <div class="sa-ff"><label>Invoice Due After (days)</label><input id="s-invoice-due" type="number" min="0" placeholder="e.g. 14"/></div>
      <div class="sa-ff"><label>Default Currency</label>
        <select id="s-currency">
          <option value="NZD">NZD — New Zealand Dollar</option>
          <option value="AUD">AUD — Australian Dollar</option>
          <option value="USD">USD — US Dollar</option>
          <option value="GBP">GBP — British Pound</option>
        </select>
      </div>
      <div class="sa-ff"><label>Billing Cycle</label>
        <select id="s-billing-cycle">
          <option value="monthly">Monthly</option>
          <option value="weekly">Weekly</option>
          <option value="quarterly">Quarterly</option>
        </select>
      </div>
    </div>
  </div>

  <!-- Commission -->
  <div class="set-section">
    <div class="set-section-hdr">&#128200; Commission / Payout Rates</div>
    <div class="set-grid">
      <div class="sa-ff"><label>Taxi Commission Rate (%)</label><input id="s-taxi-comm" type="number" min="0" max="100" step="0.1" placeholder="e.g. 15"/></div>
      <div class="sa-ff"><label>Food Delivery Commission Rate (%)</label><input id="s-food-comm" type="number" min="0" max="100" step="0.1" placeholder="e.g. 20"/></div>
      <div class="sa-ff"><label>Freight Commission Rate (%)</label><input id="s-freight-comm" type="number" min="0" max="100" step="0.1" placeholder="e.g. 12"/></div>
      <div class="sa-ff"><label>Payout Schedule Default</label>
        <select id="s-payout-sched">
          <option value="weekly">Weekly</option>
          <option value="monthly">Monthly</option>
        </select>
      </div>
    </div>
  </div>

  <!-- Notifications -->
  <div class="set-section">
    <div class="set-section-hdr">&#128276; Notification Settings</div>
    <div class="set-grid">
      <div class="sa-ff"><label>Trial Expiry Alert (days before)</label><input id="s-trial-alert-days" type="number" min="1" max="30" placeholder="e.g. 3"/></div>
      <div class="sa-ff"><label>Overdue Invoice Grace Period (days)</label><input id="s-overdue-grace" type="number" min="0" placeholder="e.g. 15"/></div>
      <div class="sa-ff" style="grid-column:span 2">
        <label>Invoice Email Footer Note</label>
        <textarea id="s-invoice-footer" rows="2" placeholder="Optional note appended to all invoice emails"></textarea>
      </div>
    </div>
  </div>

  <div style="padding:0 18px 18px;display:flex;gap:8px;align-items:center">
    <button onclick="saveSettings()" class="sa-btn sa-btn-p">&#10003; Save All Settings</button>
    <button onclick="loadSettings()" class="sa-btn sa-btn-n">&#8635; Reset</button>
    <span id="save-msg" style="font-size:12px;color:#888"></span>
  </div>
</div>

<!-- App & Service Configuration -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#128241; App &amp; Service Configuration</h3>
    <button onclick="saveAppConfig()" class="sa-btn sa-btn-p">&#10003; Save App Config</button>
  </div>
  <div id="appcfg-notice" class="sa-notice"></div>

  <!-- Server -->
  <div class="set-section">
    <div class="set-section-hdr">&#127760; BookaWaka Server</div>
    <div class="set-grid">
      <div class="sa-ff" style="grid-column:span 2">
        <label>Server URL <span style="font-size:11px;color:#888;font-weight:400">(read-only — this is what all apps must connect to)</span></label>
        <input type="url" value="https://bookawaka.replit.app" readonly style="background:#f5f5f5;color:#1565C0;font-weight:600;cursor:default"/>
      </div>
      <div class="sa-ff">
        <label>Passenger Link Password <span style="font-size:11px;color:#888;font-weight:400">(BookaWaka only)</span></label>
        <input id="ac-pass-link" type="text" placeholder="e.g. BW@PassLink2026"/>
      </div>
    </div>
  </div>

  <!-- Payment Methods -->
  <div class="set-section">
    <div class="set-section-hdr">&#128179; Payment Methods — Master Switch</div>
    <div style="padding:14px 18px">
      <p style="font-size:12px;color:#888;margin:0 0 14px">This is the <strong>platform-wide override</strong>. When OFF, cash is hidden for ALL companies on the passenger app — regardless of individual company settings.</p>
      <div style="display:flex;align-items:center;gap:16px;flex-wrap:wrap">
        <div>
          <div style="font-size:13px;font-weight:600;color:#374151;margin-bottom:4px">Cash Payments</div>
          <div style="font-size:11px;color:#888">Controls cash option on passenger booking screen</div>
        </div>
        <button id="ac-cash-btn" onclick="togglePlatformCash()" style="min-width:90px;padding:8px 18px;border-radius:20px;border:none;cursor:pointer;font-size:13px;font-weight:700;transition:background .2s">Loading…</button>
      </div>
    </div>
  </div>

  <!-- App Versions -->
  <div class="set-section">
    <div class="set-section-hdr">&#128196; Minimum App Version Requirements</div>
    <p style="padding:8px 18px 0;font-size:12px;color:#888;margin:0">Apps below the minimum version will be shown an update prompt on next launch.</p>
    <div class="set-grid">
      <div class="sa-ff">
        <label>Driver App Min Version</label>
        <input id="ac-drv-ver" type="number" min="1" placeholder="e.g. 3"/>
      </div>
      <div class="sa-ff">
        <label>Passenger App Min Version</label>
        <input id="ac-pax-ver" type="number" min="1" placeholder="e.g. 14"/>
      </div>
      <div class="sa-ff">
        <label>Dispatch App Min Version</label>
        <input id="ac-dsp-ver" type="number" min="1" placeholder="e.g. 1"/>
      </div>
    </div>
  </div>

  <div style="padding:0 18px 18px;display:flex;gap:8px;align-items:center">
    <button onclick="saveAppConfig()" class="sa-btn sa-btn-p">&#10003; Save App Config</button>
    <button onclick="loadAppConfig()" class="sa-btn sa-btn-n">&#8635; Reset</button>
    <span id="ac-save-msg" style="font-size:12px;color:#888"></span>
  </div>
</div>

<!-- Settings history / audit -->
<div class="sa-card">
  <div class="sa-bar"><h3>&#128203; Settings History</h3></div>
  <div id="settings-history" style="padding:16px 18px;font-size:13px;color:#aaa">Loading&hellip;</div>
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var SETTINGS_PATH = 'superSettings';

function showNotice(msg, type){
  var el=document.getElementById('set-notice');
  el.className='sa-notice '+(type||'ok');
  el.textContent=msg;
  el.style.display='block';
  if(type!=='err') setTimeout(function(){ el.style.display='none'; },4000);
}

var fieldMap={
  'platform-name':'platformName','support-email':'supportEmail','website':'website','alert-email':'alertEmail',
  'trial-days':'trialDays','invoice-due':'invoiceDueDays','currency':'currency','billing-cycle':'billingCycle',
  'taxi-comm':'taxiCommission','food-comm':'foodCommission','freight-comm':'freightCommission','payout-sched':'payoutSchedule',
  'trial-alert-days':'trialAlertDays','overdue-grace':'overdueGraceDays','invoice-footer':'invoiceEmailFooter'
};

function loadSettings(){
  _fbGet(SETTINGS_PATH+'/config').then(function(s){
    s=s||{};
    Object.entries(fieldMap).forEach(function(e){
      var el=document.getElementById('s-'+e[0]);
      if(el && s[e[1]]!==undefined) el.value=s[e[1]];
    });
  }).catch(function(e){ showNotice('Load error: '+e.message,'err'); });
  loadHistory();
}

function saveSettings(){
  var data={};
  Object.entries(fieldMap).forEach(function(e){
    var el=document.getElementById('s-'+e[0]);
    if(el) data[e[1]]=(el.type==='number'&&el.value!=='')?+el.value:(el.value||null);
  });
  data.updatedAt=new Date().toISOString();
  data.updatedBy=(firebase.auth().currentUser||{}).email||'sa';
  db.ref(SETTINGS_PATH+'/config').update(data).then(function(){
    db.ref(SETTINGS_PATH+'/history').push({savedAt:Date.now(),savedBy:data.updatedBy,snapshot:data});
    showNotice('Settings saved.','ok');
    document.getElementById('save-msg').textContent='Saved at '+new Date().toLocaleTimeString();
    loadHistory();
  }).catch(function(e){ showNotice('Save error: '+e.message,'err'); });
}

function loadHistory(){
  _fbGet(SETTINGS_PATH+'/history').then(function(data){
    data=data||{};
    var items=Object.values(data).sort(function(a,b){return (b.savedAt||0)-(a.savedAt||0);}).slice(0,5);
    var el=document.getElementById('settings-history');
    if(!items.length){ el.textContent='No settings history yet.'; return; }
    el.innerHTML=items.map(function(h){
      return '<div style="padding:8px 0;border-bottom:1px solid #f5f5f5;font-size:12.5px">'
        +'<span style="font-weight:600;color:#263238">'+new Date(h.savedAt).toLocaleString('en-NZ')+'</span>'
        +' &mdash; saved by <span style="color:#1565C0">'+h.savedBy+'</span>'
        +'</div>';
    }).join('');
  }).catch(function(){});
}

// ── Platform Cash Toggle ─────────────────────────────────────────────────────
var _platformCashEnabled = true;

function renderCashBtn(enabled){
  var btn = document.getElementById('ac-cash-btn');
  if(!btn) return;
  _platformCashEnabled = !!enabled;
  btn.textContent = enabled ? '✔ ON' : '✖ OFF';
  btn.style.background = enabled ? '#2E7D32' : '#C62828';
  btn.style.color = '#fff';
}

function togglePlatformCash(){
  var newVal = !_platformCashEnabled;
  db.ref('bwConfig/paymentMethods/cashEnabled').set(newVal).then(function(){
    renderCashBtn(newVal);
    showAppNotice('Cash payments '+(newVal?'ENABLED':'DISABLED')+' platform-wide.', newVal?'ok':'err');
  }).catch(function(e){ showAppNotice('Error: '+e.message,'err'); });
}

// ── App & Service Config ──────────────────────────────────────────────────────
var BW_CONFIG_PATH = 'bwConfig/appSettings';

function showAppNotice(msg, type){
  var el=document.getElementById('appcfg-notice');
  el.className='sa-notice '+(type||'ok');
  el.textContent=msg;
  el.style.display='block';
  if(type!=='err') setTimeout(function(){ el.style.display='none'; },4000);
}

function loadAppConfig(){
  _fbGet('bwConfig/paymentMethods/cashEnabled').then(function(data){
    renderCashBtn(data !== false);
  }).catch(function(){ renderCashBtn(true); });
  _fbGet(BW_CONFIG_PATH).then(function(s){
    s=s||{};
    if(s.passengerLinkPassword) document.getElementById('ac-pass-link').value=s.passengerLinkPassword;
    if(s.driverAppMinVersion)   document.getElementById('ac-drv-ver').value=s.driverAppMinVersion;
    if(s.passengerAppMinVersion) document.getElementById('ac-pax-ver').value=s.passengerAppMinVersion;
    if(s.dispatchAppMinVersion) document.getElementById('ac-dsp-ver').value=s.dispatchAppMinVersion;
  }).catch(function(e){ showAppNotice('Load error: '+e.message,'err'); });
}

function saveAppConfig(){
  var data={
    serverUrl: 'https://bookawaka.replit.app',
    passengerLinkPassword: document.getElementById('ac-pass-link').value||null,
    driverAppMinVersion:   parseInt(document.getElementById('ac-drv-ver').value)||null,
    passengerAppMinVersion:parseInt(document.getElementById('ac-pax-ver').value)||null,
    dispatchAppMinVersion: parseInt(document.getElementById('ac-dsp-ver').value)||null,
    updatedAt: new Date().toISOString(),
    updatedBy: (firebase.auth().currentUser||{}).email||'sa'
  };
  db.ref(BW_CONFIG_PATH).update(data).then(function(){
    showAppNotice('App config saved.','ok');
    document.getElementById('ac-save-msg').textContent='Saved at '+new Date().toLocaleTimeString();
  }).catch(function(e){ showAppNotice('Save error: '+e.message,'err'); });
}

window._fbOnLogin = function(){ loadSettings(); loadAppConfig(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
