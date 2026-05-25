<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Business Accounts &mdash; BookaWaka Admin</title>
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
<script>firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});</script>
<style>
.sa-wrap{padding:20px}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#E65100;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-bar.dark{background:#BF360C}
.sa-bar.blue{background:#1565C0}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none}
.sa-btn-p{background:#E65100;color:#fff}.sa-btn-p:hover{background:#BF360C}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}.sa-btn-n:hover{background:#eee}
.sa-btn-b{background:#1565C0;color:#fff}.sa-btn-b:hover{background:#0D47A1}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px;display:none}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32;display:block}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828;display:block}
.sa-notice.warn{background:#FFF8E1;color:#E65100;border-left:4px solid #FF8F00;display:block}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#FFF3E0;padding:10px 14px;text-align:left;font-weight:700;color:#BF360C;border-bottom:2px solid #FFCCBC;white-space:nowrap}
.sa-tbl td{padding:9px 14px;border-bottom:1px solid #f0f0f0;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFF8F5}
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;padding:18px}
.kpi-box{background:#FFF8F5;border-radius:8px;padding:16px 18px;border-left:4px solid #E65100;text-align:center}
.kpi-box.blue{border-left-color:#1565C0;background:#F0F7FF}
.kpi-box.green{border-left-color:#2E7D32;background:#F1F8E9}
.kpi-box.grey{border-left-color:#546E7A;background:#ECEFF1}
.kpi-val{font-size:28px;font-weight:800;color:#E65100;line-height:1}
.kpi-box.blue .kpi-val{color:#1565C0}
.kpi-box.green .kpi-val{color:#2E7D32}
.kpi-box.grey .kpi-val{color:#546E7A}
.kpi-lbl{font-size:11px;color:#90A4AE;margin-top:5px;font-weight:600;text-transform:uppercase}
.filter-row{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:12px 18px;border-bottom:1px solid #f5f5f5}
.filter-row select,.filter-row input{padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:12.5px}
.badge{display:inline-block;padding:2px 9px;border-radius:10px;font-size:11px;font-weight:700}
.badge-active{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-inactive{background:#ECEFF1;color:#546E7A;border:1px solid #CFD8DC}
.cid-badge{font-family:monospace;background:#FFF3E0;color:#E65100;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700}
.acct-badge{font-family:monospace;background:#E3F2FD;color:#1565C0;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700}
.sa-empty{padding:40px;text-align:center;color:#bbb;font-size:13px}
.detail-panel{background:#F9FAFB;border-top:1px solid #f0f0f0;padding:14px 18px;font-size:12.5px}
.detail-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:8px}
.detail-item label{display:block;font-size:11px;color:#9e9e9e;font-weight:600;text-transform:uppercase;margin-bottom:2px}
.detail-item span{font-size:13px;color:#263238;font-weight:500}
.expand-btn{background:none;border:none;cursor:pointer;color:#E65100;font-size:12px;font-weight:600;padding:2px 6px}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">&#127970; Business Accounts &mdash; BookaWaka Admin</label></div>
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
    <li class="current_section" title="Total Mobility"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE8CC;</i></span><span class="menu_title">Total Mobility</span></a><ul>
      <li><a href="TM-Council-Config.aspx">Council Config</a></li>
      <li><a href="TM-Cards.aspx">Passenger Cards</a></li>
      <li><a href="TM-Trips.aspx">All Trips</a></li>
      <li><a href="TM-Flagged.aspx">Flagged Trips</a></li>
      <li><a href="TM-Batches.aspx">Claim Batches</a></li>
      <li><a href="TM-Reports.aspx">Monthly Reports</a></li>
      <li><a href="TM-Settings.aspx">TM Settings</a></li>
    </ul></li>
    <li class="current_section" title="Food Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE56C;</i></span><span class="menu_title">Food Delivery</span></a><ul>
      <li><a href="FD-Restaurants.aspx">Restaurants</a></li>
      <li><a href="FD-Orders.aspx">All Orders</a></li>
      <li><a href="FD-Payouts.aspx">Payouts</a></li>
      <li><a href="FD-Reports.aspx">Reports</a></li>
      <li><a href="FD-Commission.aspx">Commission Rates</a></li>
    </ul></li>
    <li class="current_section" title="Freight Delivery"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE558;</i></span><span class="menu_title">Freight Delivery</span></a><ul>
      <li><a href="FR-Orders.aspx">All Orders</a></li>
      <li><a href="FR-Payouts.aspx">Payouts</a></li>
      <li><a href="FR-Reports.aspx">Reports</a></li>
      <li><a href="FR-Commission.aspx">Commission Rates</a></li>
    </ul></li>
    <li class="current_section" title="Taxi Companies"><a href="#"><span class="menu_icon"><i class="material-icons">&#xE7EF;</i></span><span class="menu_title">Taxi Companies</span></a><ul>
      <li><a href="SA-Clients.aspx">All Companies</a></li>
      <li><a href="SA-OwnerGroups.aspx">Owner Groups</a></li>
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
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
      <li><a href="SA-Broadcast.aspx">Broadcast</a></li>
      <li><a href="SA-Sessions.aspx">Dispatch Sessions</a></li>
      <li><a href="SA-BusinessAccounts.aspx" style="font-weight:700;color:#E65100">&#9658; Business Accounts</a></li>
      <li><a href="SA-ACCClients.aspx">ACC Clients</a></li>
    </ul></li>
  </ul></div>
</aside>
<div id="page_content"><div id="page_content_inner">
<div class="sa-wrap">

<h2 style="font-size:18px;font-weight:700;margin-bottom:6px">&#127970; Business Accounts — Platform Overview</h2>
<p style="font-size:13px;color:#888;margin-bottom:18px">
  Read-only view of all corporate business accounts across every company. Accounts are created and managed by each company's owner panel.
</p>

<div id="sa-notice" style="display:none" class="sa-notice"></div>

<!-- KPIs -->
<div class="sa-card">
  <div class="kpi-row">
    <div class="kpi-box"><div class="kpi-val" id="kpi-total">—</div><div class="kpi-lbl">Total Accounts</div></div>
    <div class="kpi-box green"><div class="kpi-val" id="kpi-active">—</div><div class="kpi-lbl">Active</div></div>
    <div class="kpi-box grey"><div class="kpi-val" id="kpi-inactive">—</div><div class="kpi-lbl">Inactive</div></div>
    <div class="kpi-box blue"><div class="kpi-val" id="kpi-companies">—</div><div class="kpi-lbl">Companies Using</div></div>
  </div>
</div>

<!-- Table -->
<div class="sa-card">
  <div class="sa-bar">
    <h3>&#127970; All Business Accounts</h3>
    <div style="display:flex;gap:6px;align-items:center;flex-wrap:wrap">
      <button class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px" onclick="exportCsv()">&#8659; Export CSV</button>
      <button class="sa-btn" style="background:rgba(255,255,255,.15);color:#fff;border:1px solid rgba(255,255,255,.3);font-size:12px" onclick="loadData()">&#8635; Refresh</button>
    </div>
  </div>

  <div class="filter-row">
    <input id="f-search" type="text" placeholder="Search name, account ID, email…" style="min-width:220px" oninput="applyFilter()"/>
    <select id="f-company" onchange="applyFilter()"><option value="">All Companies</option></select>
    <select id="f-status" onchange="applyFilter()">
      <option value="">All Statuses</option>
      <option value="active">Active</option>
      <option value="inactive">Inactive</option>
    </select>
    <span id="f-count" style="margin-left:auto;font-size:12px;color:#9e9e9e"></span>
  </div>

  <div id="tbl-wrap" style="overflow-x:auto">
    <div class="sa-empty" id="tbl-loading">Loading business accounts…</div>
    <table class="sa-tbl" id="main-tbl" style="display:none">
      <thead>
        <tr>
          <th>Account ID</th>
          <th>Account Name</th>
          <th>Company</th>
          <th>Contact</th>
          <th>Email</th>
          <th>Phone</th>
          <th>Payment Terms</th>
          <th>Status</th>
          <th>Created</th>
          <th></th>
        </tr>
      </thead>
      <tbody id="tbl-body"></tbody>
    </table>
    <div class="sa-empty" id="tbl-empty" style="display:none">No business accounts found matching your filters.</div>
  </div>
</div>

</div>
</div></div>

<script src="assets/js/tm-helpers.js"></script>
<script>
var db = firebase.database();
var allRows = [];
var allCompanies = {};

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function showNotice(msg, type){
  var el = document.getElementById('sa-notice');
  el.className = 'sa-notice ' + type;
  el.textContent = msg;
  el.style.display = 'block';
  if(type !== 'err') setTimeout(function(){ el.style.display = 'none'; }, 4000);
}

function loadData(){
  document.getElementById('tbl-loading').style.display = 'block';
  document.getElementById('main-tbl').style.display = 'none';
  document.getElementById('tbl-empty').style.display = 'none';

  _fbGet('superClients').then(function(clients){
    allCompanies = clients || {};

    // Populate company filter
    var sel = document.getElementById('f-company');
    var prev = sel.value;
    sel.innerHTML = '<option value="">All Companies</option>';
    Object.entries(allCompanies).sort(function(a,b){ return (a[1].name||'').localeCompare(b[1].name||''); }).forEach(function(e){
      sel.innerHTML += '<option value="'+esc(e[0])+'">'+esc(e[1].name||e[0])+'</option>';
    });
    sel.value = prev;

    // Load business accounts from all companies
    var cids = Object.keys(allCompanies);
    if(!cids.length){
      document.getElementById('tbl-loading').style.display = 'none';
      document.getElementById('tbl-empty').style.display = 'block';
      return;
    }

    allRows = [];
    var done = 0;
    cids.forEach(function(cid){
      _fbGet('businessAccounts/'+cid).then(function(data){
        data = data || {};
        Object.entries(data).forEach(function(e){
          var acct = e[1] || {};
          allRows.push({
            accountId: e[0],
            cid: cid,
            companyName: (allCompanies[cid] && allCompanies[cid].name) || cid,
            name: acct.name || acct.accountName || '',
            contact: acct.contact || acct.contactName || '',
            email: acct.email || acct.billingEmail || '',
            phone: acct.phone || '',
            terms: acct.paymentTerms || acct.terms || '',
            status: acct.status || 'active',
            createdAt: acct.createdAt || acct.created || ''
          });
        });
      }).catch(function(){}).finally(function(){
        done++;
        if(done === cids.length){
          document.getElementById('tbl-loading').style.display = 'none';
          updateKpis();
          applyFilter();
        }
      });
    });
  }).catch(function(e){
    document.getElementById('tbl-loading').textContent = 'Error loading data: ' + e.message;
  });
}

function updateKpis(){
  var active = allRows.filter(function(r){ return r.status === 'active'; }).length;
  var inactive = allRows.length - active;
  var cos = new Set(allRows.map(function(r){ return r.cid; })).size;
  document.getElementById('kpi-total').textContent = allRows.length;
  document.getElementById('kpi-active').textContent = active;
  document.getElementById('kpi-inactive').textContent = inactive;
  document.getElementById('kpi-companies').textContent = cos;
}

function applyFilter(){
  var search = (document.getElementById('f-search').value || '').toLowerCase();
  var cid = document.getElementById('f-company').value;
  var status = document.getElementById('f-status').value;

  var filtered = allRows.filter(function(r){
    if(cid && r.cid !== cid) return false;
    if(status && r.status !== status) return false;
    if(search){
      var hay = (r.accountId+' '+r.name+' '+r.email+' '+r.contact+' '+r.phone).toLowerCase();
      if(hay.indexOf(search) === -1) return false;
    }
    return true;
  });

  document.getElementById('f-count').textContent = filtered.length + ' account' + (filtered.length !== 1 ? 's' : '');

  var tbody = document.getElementById('tbl-body');
  if(!filtered.length){
    document.getElementById('main-tbl').style.display = 'none';
    document.getElementById('tbl-empty').style.display = 'block';
    return;
  }
  document.getElementById('tbl-empty').style.display = 'none';
  document.getElementById('main-tbl').style.display = 'table';

  tbody.innerHTML = filtered.map(function(r){
    var statusBadge = r.status === 'active'
      ? '<span class="badge badge-active">Active</span>'
      : '<span class="badge badge-inactive">Inactive</span>';
    var created = r.createdAt ? new Date(r.createdAt).toLocaleDateString('en-NZ') : '—';
    return '<tr>'
      +'<td><span class="acct-badge">'+esc(r.accountId)+'</span></td>'
      +'<td style="font-weight:600">'+esc(r.name||'—')+'</td>'
      +'<td><span class="cid-badge">'+esc(r.cid)+'</span> '+esc(r.companyName)+'</td>'
      +'<td>'+esc(r.contact||'—')+'</td>'
      +'<td>'+(r.email ? '<a href="mailto:'+esc(r.email)+'" style="color:#1565C0">'+esc(r.email)+'</a>' : '—')+'</td>'
      +'<td>'+esc(r.phone||'—')+'</td>'
      +'<td>'+esc(r.terms||'—')+'</td>'
      +'<td>'+statusBadge+'</td>'
      +'<td style="color:#9e9e9e;font-size:12px">'+created+'</td>'
      +'<td><a href="SA-Company.aspx?cid='+esc(r.cid)+'" class="sa-btn sa-btn-n" style="font-size:11px;padding:4px 8px">View Company</a></td>'
      +'</tr>';
  }).join('');
}

function exportCsv(){
  var headers = ['Account ID','Account Name','Company ID','Company Name','Contact','Email','Phone','Payment Terms','Status','Created'];
  var rows = allRows.map(function(r){
    return [r.accountId, r.name, r.cid, r.companyName, r.contact, r.email, r.phone, r.terms, r.status, r.createdAt].map(function(v){
      return '"'+(String(v||'').replace(/"/g,'""'))+'"';
    }).join(',');
  });
  var csv = headers.join(',') + '\n' + rows.join('\n');
  var a = document.createElement('a');
  a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
  a.download = 'business-accounts-' + new Date().toISOString().slice(0,10) + '.csv';
  a.click();
}

window._fbOnLogin = function(){ loadData(); };
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
