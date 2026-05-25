<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Food Delivery &mdash; Restaurants &mdash; BookaWaka Admin</title>
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
firebase.initializeApp({
  apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",
  authDomain:"taxilatest.firebaseapp.com",
  databaseURL:"https://taxilatest.firebaseio.com",
  projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"
});
</script>
<style>
.fd-wrap{padding:20px}
.fd-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.fd-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between}
.fd-bar h3{margin:0;font-size:15px;font-weight:600}
.fd-tbl{width:100%;border-collapse:collapse;font-size:13px}
.fd-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.fd-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.fd-tbl tr:hover td{background:#FFFDE7}
.bx{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:600}
.bx-g{background:#E8F5E9;color:#2E7D32}.bx-r{background:#FFEBEE;color:#C62828}
.bx-o{background:#E3F2FD;color:#1565C0}.bx-b{background:#E3F2FD;color:#1565C0}
.fd-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 13px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500}
.fd-btn-p{background:#1565C0;color:#fff}.fd-btn-p:hover{background:#0D47A1}
.fd-btn-e{background:#E3F2FD;color:#1565C0}.fd-btn-d{background:#FFEBEE;color:#C62828}
.fd-btn-wh{background:rgba(255,255,255,.15);color:#fff}
.fd-ov{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:999;align-items:center;justify-content:center}
.fd-ov.open{display:flex}
.fd-modal{background:#fff;border-radius:8px;width:720px;max-width:96vw;max-height:92vh;overflow-y:auto;box-shadow:0 8px 32px rgba(0,0,0,.25)}
.fd-mh{background:#1565C0;color:#fff;padding:14px 18px;display:flex;align-items:center;justify-content:space-between;border-radius:8px 8px 0 0}
.fd-mh h3{margin:0;font-size:15px}
.fd-mb{padding:18px}.fd-mf{padding:12px 18px;border-top:1px solid #eee;display:flex;gap:8px;justify-content:flex-end}
.fd-fg{display:grid;grid-template-columns:1fr 1fr;gap:12px 18px}
.fd-ff label{display:block;font-size:12px;color:#757575;margin-bottom:3px;font-weight:500}
.fd-ff input,.fd-ff select,.fd-ff textarea{width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;box-sizing:border-box}
.fd-ff input:focus,.fd-ff select:focus{outline:none;border-color:#1565C0}
.fd-msg{margin-top:8px;font-size:13px}.fd-msg.ok{color:#2E7D32}.fd-msg.err{color:#C62828}
.fd-sec-lbl{grid-column:1/-1;border-top:1px solid #eee;margin-top:6px;padding-top:14px;font-size:12px;font-weight:700;color:#1565C0}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Food Delivery &mdash; Restaurants &mdash; BookaWaka Admin</label></div>
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
      <li><a href="FD-Restaurants.aspx" style="font-weight:700;color:#1565C0">&#9658; Restaurants</a></li>
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
      <li><a href="FR-Commission.aspx">Commission Rates</a></li>
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
<div class="fd-card">
  <div class="fd-bar">
    <h3>&#127829; Restaurants <small id="fd-count" style="opacity:.75;font-size:12px"></small></h3>
    <div style="display:flex;gap:8px">
      <button class="fd-btn fd-btn-p" onclick="openFD()">+ Add Restaurant</button>
      <button class="fd-btn fd-btn-wh" onclick="refreshFD()">&#8635;</button>
    </div>
  </div>
  <div style="overflow-x:auto">
    <table class="fd-tbl">
      <thead><tr>
        <th>Restaurant</th><th>Email</th><th>Delivery Radius</th><th>Delivery Fee</th>
        <th>Food Comm %</th><th>Delivery Comm %</th><th>Payout</th><th>Status</th><th>Actions</th>
      </tr></thead>
      <tbody id="fd-tb"><tr><td colspan="9" style="text-align:center;padding:40px;color:#9e9e9e">Loading&#8230;</td></tr></tbody>
    </table>
  </div>
</div></div>

<!-- Modal -->
<div class="fd-ov" id="fd-ov">
<div class="fd-modal">
  <div class="fd-mh"><h3 id="fd-mtitle">Add Restaurant</h3>
    <button onclick="closeFD()" style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px">&#x2715;</button></div>
  <div class="fd-mb"><div class="fd-fg">
    <div class="fd-ff" style="grid-column:1/-1"><label>Restaurant Name *</label><input id="fd-name" placeholder="e.g. Burger Palace"/></div>
    <div class="fd-ff"><label>Owner / Contact Name</label><input id="fd-contact" placeholder="John Smith"/></div>
    <div class="fd-ff"><label>Email *</label><input id="fd-email" type="email" placeholder="owner@restaurant.com"/></div>
    <div class="fd-ff"><label>Phone</label><input id="fd-phone" placeholder="+64 21 000 0000"/></div>
    <div class="fd-ff"><label>Address</label><input id="fd-addr" placeholder="123 Main St, City"/></div>
    <div class="fd-ff"><label>Cuisine Type</label><input id="fd-cuisine" placeholder="e.g. Italian, Burgers, Indian"/></div>
    <div class="fd-ff" style="grid-column:1/-1"><label>Description (shown to customers)</label><textarea id="fd-desc" rows="2" placeholder="Short description of the restaurant" style="width:100%;padding:7px 9px;border:1px solid #ddd;border-radius:4px;font-size:13px;font-family:inherit;box-sizing:border-box"></textarea></div>
    <div class="fd-ff" style="grid-column:1/-1"><label>Cover Image (optional, &lt;2MB — auto-compressed)</label>
      <div style="display:flex;gap:12px;align-items:center"><img id="fd-cover-preview" style="width:140px;height:80px;object-fit:cover;border-radius:4px;border:1px solid #eee;background:#fafafa" alt=""/>
      <input id="fd-cover-file" type="file" accept="image/*" style="font-size:12.5px"/></div>
    </div>
    <div class="fd-ff"><label>Delivery Radius (km)</label><input id="fd-radius" type="number" step="0.5" min="0.5" placeholder="5"/></div>
    <div class="fd-ff"><label>Default Delivery Fee ($)</label><input id="fd-dfee" type="number" step="0.50" min="0" placeholder="8.00"/></div>
    <div class="fd-ff"><label>Minimum Order ($)</label><input id="fd-minord" type="number" step="0.50" min="0" placeholder="15.00"/></div>
    <div class="fd-ff"><label>Avg Prep Time (minutes)</label><input id="fd-prep" type="number" min="5" placeholder="25"/></div>
    <div class="fd-ff"><label>Payout Schedule</label>
      <select id="fd-payout"><option value="weekly">Weekly</option><option value="monthly">Monthly</option><option value="daily">Daily</option></select></div>
    <div class="fd-sec-lbl">&#128181; Commission Rates</div>
    <div class="fd-ff"><label>Food Commission % *</label><input id="fd-fcomm" type="number" step="0.5" min="0" max="50" placeholder="15"/></div>
    <div class="fd-ff"><label>Delivery Commission % *</label><input id="fd-dcomm" type="number" step="0.5" min="0" max="50" placeholder="10"/></div>
    <div class="fd-ff"><label>Status</label>
      <select id="fd-act"><option value="true">Active</option><option value="false">Inactive</option></select></div>
    <div class="fd-ff"><label>Notes</label><input id="fd-notes" placeholder="Optional notes"/></div>
    <div class="fd-sec-lbl">&#128273; Restaurant Portal Access</div>
    <div class="fd-ff"><label>Portal Email (auto-filled from Email above)</label><input id="fd-portal-email" type="email" readonly style="background:#f5f5f5;color:#777"/></div>
    <div class="fd-ff"><label>Set / Reset Portal Password</label><input id="fd-pw" type="password" placeholder="Leave blank to keep existing"/></div>
    <div class="fd-ff"><label>Confirm Password</label><input id="fd-pw2" type="password" placeholder="Re-enter new password"/></div>
    <div class="fd-ff" style="grid-column:1/-1"><p style="font-size:11.5px;color:#888">Set a password so the restaurant owner can log in at <strong>/restaurant-portal</strong> to manage their menu, view orders and see settlement statements.</p></div>
  </div>
  <div id="fd-msg" class="fd-msg"></div></div>
  <div class="fd-mf">
    <button class="fd-btn" style="background:#eee;color:#333" onclick="closeFD()">Cancel</button>
    <button class="fd-btn fd-btn-p" onclick="saveFD()">Save Restaurant</button>
  </div>
</div></div>

</div></div>
<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script src="assets/js/fd-multi-company.js"></script>
<script>
var fdData = {};
var fdEditId = null;
var fdCoverData = '';

document.addEventListener('DOMContentLoaded', function(){
  var fi = document.getElementById('fd-cover-file');
  if (!fi) return;
  fi.addEventListener('change', function(){
    if (!fi.files || !fi.files[0]) return;
    var f = fi.files[0];
    if (f.size > 2*1024*1024) { alert('Image too large — must be under 2MB.'); fi.value=''; return; }
    var reader = new FileReader();
    reader.onload = function(ev){
      var img = new Image();
      img.onload = function(){
        var max = 1000;
        var w = img.width, h = img.height;
        if (w > h && w > max) { h = Math.round(h*max/w); w = max; }
        else if (h >= w && h > max) { w = Math.round(w*max/h); h = max; }
        var canvas = document.createElement('canvas');
        canvas.width = w; canvas.height = h;
        canvas.getContext('2d').drawImage(img, 0, 0, w, h);
        var b64 = canvas.toDataURL('image/jpeg', 0.75);
        if (b64.length > 400000) { alert('Image still too large after compression. Try a smaller photo.'); return; }
        fdCoverData = b64;
        document.getElementById('fd-cover-preview').src = b64;
      };
      img.src = ev.target.result;
    };
    reader.readAsDataURL(f);
  });
});

window._fbOnLogin = function() { loadFD(); };

function loadFD() {
  adminRead('foodClients/' + COMPANY_ID).then(function(d) {
    fdData = d || {};
    renderFD();
  }).catch(function() { renderFD(); });
}

function renderFD() {
  var keys = Object.keys(fdData);
  document.getElementById('fd-count').textContent = '(' + keys.length + ')';
  var tb = document.getElementById('fd-tb');
  if (!keys.length) {
    tb.innerHTML = '<tr><td colspan="9" style="text-align:center;padding:40px;color:#9e9e9e">No restaurants yet. Click + Add Restaurant to get started.</td></tr>';
    return;
  }
  tb.innerHTML = keys.sort(function(a,b){ return (fdData[a].name||'').localeCompare(fdData[b].name||''); }).map(function(id) {
    var r = fdData[id];
    var active = r.active !== false;
    return '<tr>' +
      '<td><strong>' + esc(r.name||'—') + '</strong><br><small style="color:#888">' + esc(r.address||'') + '</small></td>' +
      '<td>' + esc(r.email||'—') + '</td>' +
      '<td>' + (r.deliveryRadius||'—') + ' km</td>' +
      '<td>$' + parseFloat(r.deliveryFee||0).toFixed(2) + '</td>' +
      '<td style="font-weight:700;color:#1565C0">' + (r.foodCommissionPct||0) + '%</td>' +
      '<td style="font-weight:700;color:#1565C0">' + (r.deliveryCommissionPct||0) + '%</td>' +
      '<td><span class="bx bx-b">' + esc(r.payoutSchedule||'weekly') + '</span></td>' +
      '<td><span class="bx ' + (active?'bx-g':'bx-r') + '">' + (active?'Active':'Inactive') + '</span></td>' +
      '<td style="white-space:nowrap">' +
        '<button class="fd-btn fd-btn-e" onclick="editFD(\'' + id + '\')" style="margin-right:6px">Edit</button>' +
        '<button class="fd-btn fd-btn-d" onclick="delFD(\'' + id + '\')">Delete</button>' +
      '</td></tr>';
  }).join('');
}

function openFD() {
  fdEditId = null;
  fdCoverData = '';
  document.getElementById('fd-mtitle').textContent = 'Add Restaurant';
  ['fd-name','fd-contact','fd-email','fd-phone','fd-addr','fd-cuisine','fd-desc','fd-radius','fd-dfee','fd-minord','fd-prep','fd-fcomm','fd-dcomm','fd-notes','fd-portal-email','fd-pw','fd-pw2'].forEach(function(id) {
    document.getElementById(id).value = '';
  });
  document.getElementById('fd-payout').value = 'weekly';
  document.getElementById('fd-act').value = 'true';
  document.getElementById('fd-cover-preview').src = '';
  document.getElementById('fd-cover-file').value = '';
  document.getElementById('fd-msg').textContent = '';
  document.getElementById('fd-ov').classList.add('open');
  document.getElementById('fd-email').addEventListener('input', syncPortalEmail);
}

function syncPortalEmail() {
  document.getElementById('fd-portal-email').value = document.getElementById('fd-email').value;
}

function editFD(id) {
  var r = fdData[id] || {};
  fdEditId = id;
  fdCoverData = r.coverImage || '';
  document.getElementById('fd-mtitle').textContent = 'Edit Restaurant';
  document.getElementById('fd-name').value = r.name||'';
  document.getElementById('fd-contact').value = r.contactName||'';
  document.getElementById('fd-email').value = r.email||'';
  document.getElementById('fd-phone').value = r.phone||'';
  document.getElementById('fd-addr').value = r.address||'';
  document.getElementById('fd-cuisine').value = r.cuisine||'';
  document.getElementById('fd-desc').value = r.description||'';
  document.getElementById('fd-cover-preview').src = r.coverImage || '';
  document.getElementById('fd-cover-file').value = '';
  document.getElementById('fd-radius').value = r.deliveryRadius||'';
  document.getElementById('fd-dfee').value = r.deliveryFee||'';
  document.getElementById('fd-minord').value = r.minOrder||'';
  document.getElementById('fd-prep').value = r.prepTime||'';
  document.getElementById('fd-fcomm').value = r.foodCommissionPct||'';
  document.getElementById('fd-dcomm').value = r.deliveryCommissionPct||'';
  document.getElementById('fd-payout').value = r.payoutSchedule||'weekly';
  document.getElementById('fd-act').value = r.active === false ? 'false' : 'true';
  document.getElementById('fd-notes').value = r.notes||'';
  document.getElementById('fd-portal-email').value = r.email||'';
  document.getElementById('fd-pw').value = '';
  document.getElementById('fd-pw2').value = '';
  document.getElementById('fd-msg').textContent = '';
  document.getElementById('fd-ov').classList.add('open');
  document.getElementById('fd-email').addEventListener('input', syncPortalEmail);
}

function closeFD() { document.getElementById('fd-ov').classList.remove('open'); }

function saveFD() {
  var name  = document.getElementById('fd-name').value.trim();
  var email = document.getElementById('fd-email').value.trim().toLowerCase();
  var fcomm = parseFloat(document.getElementById('fd-fcomm').value);
  var dcomm = parseFloat(document.getElementById('fd-dcomm').value);
  var pw    = document.getElementById('fd-pw').value;
  var pw2   = document.getElementById('fd-pw2').value;
  if (!name)              { fdMsg('Restaurant name is required.', false); return; }
  if (!email)             { fdMsg('Email is required.', false); return; }
  if (isNaN(fcomm)||fcomm<0) { fdMsg('Enter a valid food commission %.', false); return; }
  if (isNaN(dcomm)||dcomm<0) { fdMsg('Enter a valid delivery commission %.', false); return; }
  if (pw && pw !== pw2)   { fdMsg('Passwords do not match.', false); return; }
  // Hard guard: refuse to save if no company context — would orphan the record at foodClients/null/{key}.
  if (!COMPANY_ID || COMPANY_ID === 'null' || COMPANY_ID === 'undefined') {
    fdMsg('No company selected. Use "View as company" first, or open this page via the company picker, then try again.', false);
    return;
  }

  var key = fdEditId || name.toLowerCase().replace(/[^a-z0-9]+/g,'_').replace(/^_|_$/g,'') + '_' + Date.now().toString(36);
  var data = {
    name: name,
    contactName: document.getElementById('fd-contact').value.trim(),
    email: email,
    phone: document.getElementById('fd-phone').value.trim(),
    address: document.getElementById('fd-addr').value.trim(),
    cuisine: document.getElementById('fd-cuisine').value.trim(),
    description: document.getElementById('fd-desc').value.trim(),
    deliveryRadius: parseFloat(document.getElementById('fd-radius').value)||5,
    deliveryFee: parseFloat(document.getElementById('fd-dfee').value)||0,
    minOrder: parseFloat(document.getElementById('fd-minord').value)||0,
    prepTime: parseInt(document.getElementById('fd-prep').value)||25,
    foodCommissionPct: fcomm,
    deliveryCommissionPct: dcomm,
    payoutSchedule: document.getElementById('fd-payout').value,
    active: document.getElementById('fd-act').value === 'true',
    notes: document.getElementById('fd-notes').value.trim(),
    updatedAt: Date.now()
  };
  if (fdCoverData) data.coverImage = fdCoverData;
  if (!fdEditId) data.createdAt = Date.now();

  adminWrite('foodClients/' + COMPANY_ID + '/' + key, 'PUT', data).then(function() {
    fdData[key] = data;
    // Mirror to fdRestaurants/{cid}/{rid} (passenger app + website read contract).
    // Strip portal-only fields; menu/hours are merged in by owner-panel writes.
    var pub = Object.assign({}, data); delete pub.notes;
    pub.rid = key; pub.cid = COMPANY_ID; pub.mirroredAt = Date.now();
    adminWrite('fdRestaurants/' + COMPANY_ID + '/' + key, 'PATCH', pub).catch(function(){ /* best-effort */ });
    if (pw) {
      return fetch('/api/set-restaurant-password', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({restaurantId: key, email: email, password: pw, companyId: COMPANY_ID})
      }).then(function(r){return r.json();}).then(function(res){
        if (res.error) { fdMsg('Saved but portal password failed: ' + res.error, false); }
        else { fdMsg('Restaurant saved + portal access set!', true); setTimeout(function(){ renderFD(); closeFD(); }, 1800); }
      });
    }
    fdMsg('Restaurant saved!', true);
    setTimeout(function(){ renderFD(); closeFD(); }, 1200);
  }).catch(function(e){ fdMsg('Save failed: ' + e.message, false); });
}

function delFD(id) {
  var nm = (fdData[id]||{}).name || id;
  if (!confirm('Delete restaurant "' + nm + '"? This will not remove their orders.')) return;
  adminWrite('foodClients/' + COMPANY_ID + '/' + id, 'DELETE', null).then(function(){
    delete fdData[id]; renderFD();
    // Mirror delete to fdRestaurants — best-effort
    adminWrite('fdRestaurants/' + COMPANY_ID + '/' + id, 'DELETE', null).catch(function(){});
  }).catch(function(e){ alert('Delete failed: ' + e.message); });
}

function refreshFD() { loadFD(); }
function fdMsg(m, ok) { var el = document.getElementById('fd-msg'); el.textContent = m; el.className = 'fd-msg ' + (ok?'ok':'err'); }
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
</script>
<script src="assets/js/bw-customize.js"></script>
</body></html>
