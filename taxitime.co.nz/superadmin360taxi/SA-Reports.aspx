<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"><meta charset="utf-8"/><title>Revenue Reports &mdash; BookaWaka Admin</title>
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
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;white-space:nowrap;color:#0D47A1}
.sa-tbl td{padding:9px 11px;border-bottom:1px solid #f5f5f5;vertical-align:middle}
.sa-tbl tr:hover td{background:#FFFDE7}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:4px;border:none;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none;white-space:nowrap}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-s{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}
.sa-notice{padding:10px 16px;border-radius:6px;margin-bottom:14px;font-size:13px}
.sa-notice.ok{background:#E8F5E9;color:#1B5E20;border-left:4px solid #2E7D32}
.sa-notice.err{background:#FFEBEE;color:#B71C1C;border-left:4px solid #C62828}
.kpi-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;padding:18px}
.kpi-box{border-radius:8px;padding:16px 18px;border-left:4px solid #1565C0;background:#F8F9FA}
.kpi-val{font-size:26px;font-weight:700;color:#1565C0}
.kpi-lbl{font-size:12px;color:#aaa;margin-top:4px}
.badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.badge-paid{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.badge-unpaid{background:#E3F2FD;color:#1565C0;border:1px solid #BBDEFB}
.badge-overdue{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
</style>
<link href="assets/css/bw-theme.css" rel="stylesheet"/>
</head>
<body class="sidebar_main_open sidebar_main_swipe">
<header id="header_main"><div class="header_main_content"><nav class="uk-navbar">
  <a href="#" id="sidebar_main_toggle" class="sSwitch sSwitch_left"><span class="sSwitchIcon"></span></a>
  <div class="col-md-offset-2 col-md-4"><label style="color:#fff">Revenue Reports &mdash; BookaWaka Admin</label></div>
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
      <li><a href="SA-Packages.aspx">Subscription Packages</a></li>
      <li><a href="SA-Billing.aspx">Company Billing</a></li>
      <li><a href="SA-Payouts.aspx">Company Payouts</a></li>
      <li><a href="SA-Drivers.aspx">All Drivers</a></li>
      <li><a href="SA-AuditLog.aspx">Audit Log</a></li>
      <li><a href="SA-ShiftLogs.aspx">Shift Logs</a></li>
      <li><a href="SA-Email.aspx">Send Email</a></li>
      <li><a href="SA-EmailLog.aspx">Email Sent Log</a></li>
      <li><a href="SA-Reports.aspx" style="font-weight:700;color:#1565C0">&#9658; Revenue Reports</a></li>
      <li><a href="SA-MasterReport.aspx">&#128202; Platform Overview</a></li>
      <li><a href="SA-PlatformHealth.aspx">&#128994; Platform Health</a></li>
      <li><a href="SA-Registrations.aspx">Registrations</a></li>
      <li><a href="SA-Alerts.aspx">System Alerts</a></li>
      <li><a href="SA-Settings.aspx">Platform Settings</a></li>
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

<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:16px">
  <h2 style="font-size:18px;font-weight:700;color:#263238;margin:0">&#128202; Monthly Revenue Report</h2>
  <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
    <input id="report-month" type="month" style="padding:7px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px"/>
    <button onclick="loadReport()" class="sa-btn sa-btn-p">&#128202; Generate Report</button>
    <button onclick="exportCsv()" id="csv-btn" class="sa-btn sa-btn-s" style="display:none">&#8659; Export CSV</button>
    <button onclick="loadAnnual()" class="sa-btn sa-btn-n">&#128197; Annual Summary</button>
    <button onclick="loadOutstanding()" class="sa-btn" style="background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2">&#9888; Outstanding Balances</button>
  </div>
</div>

<div id="report-notice" style="display:none"></div>

<div id="report-kpis" class="sa-card" style="display:none">
  <div class="sa-bar"><h3>&#128202; Summary</h3><span id="report-period-label" style="font-size:13px;opacity:.8"></span></div>
  <div class="kpi-row">
    <div class="kpi-box"><div class="kpi-val" style="color:#2E7D32" id="kpi-collected">—</div><div class="kpi-lbl">Collected</div></div>
    <div class="kpi-box" style="border-left-color:#C62828"><div class="kpi-val" style="color:#C62828" id="kpi-outstanding">—</div><div class="kpi-lbl">Outstanding</div></div>
    <div class="kpi-box" style="border-left-color:#1565C0"><div class="kpi-val" style="color:#1565C0" id="kpi-invoiced">—</div><div class="kpi-lbl">Total Invoiced</div></div>
    <div class="kpi-box" style="border-left-color:#7B1FA2"><div class="kpi-val" style="color:#7B1FA2" id="kpi-co-count">—</div><div class="kpi-lbl">Companies with invoices</div></div>
    <div class="kpi-box" style="border-left-color:#E65100"><div class="kpi-val" style="color:#E65100" id="kpi-overdue-ct">—</div><div class="kpi-lbl">Overdue</div></div>
  </div>
</div>

<div id="trend-card" class="sa-card" style="display:none">
  <div class="sa-bar"><h3>&#128200; Revenue Trend — Last 12 Months</h3><span id="trend-label" style="font-size:12px;opacity:.8"></span></div>
  <div style="padding:20px 18px 8px">
    <div id="trend-chart" style="display:flex;align-items:flex-end;gap:4px;height:120px;margin-bottom:6px"></div>
    <div id="trend-legend" style="display:flex;gap:16px;font-size:11px;color:#888;flex-wrap:wrap;margin-top:8px">
      <span><span style="display:inline-block;width:10px;height:10px;background:#2E7D32;border-radius:2px;margin-right:4px"></span>Collected</span>
      <span><span style="display:inline-block;width:10px;height:10px;background:#BBDEFB;border-radius:2px;margin-right:4px"></span>Invoiced</span>
    </div>
  </div>
</div>

<div id="report-table-wrap" class="sa-card" style="display:none">
  <div class="sa-bar"><h3>&#128203; Per-Company Breakdown</h3></div>
  <div style="overflow-x:auto;padding:0 0 14px">
    <table class="sa-tbl" id="report-tbl">
      <thead>
        <tr>
          <th>Company</th>
          <th>ID</th>
          <th>Plan</th>
          <th>Invoices</th>
          <th>Invoiced</th>
          <th>Collected</th>
          <th>Outstanding</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody id="report-body"></tbody>
    </table>
  </div>
</div>

<div id="annual-card" class="sa-card" style="display:none">
  <div class="sa-bar"><h3>&#128197; Annual Revenue Summary</h3><span id="annual-label" style="font-size:12px;opacity:.8"></span></div>
  <div class="kpi-row">
    <div class="kpi-box"><div class="kpi-val" style="color:#2E7D32" id="ann-collected">—</div><div class="kpi-lbl">YTD Collected</div></div>
    <div class="kpi-box" style="border-left-color:#C62828"><div class="kpi-val" style="color:#C62828" id="ann-outstanding">—</div><div class="kpi-lbl">YTD Outstanding</div></div>
    <div class="kpi-box" style="border-left-color:#1565C0"><div class="kpi-val" style="color:#1565C0" id="ann-invoiced">—</div><div class="kpi-lbl">YTD Invoiced</div></div>
  </div>
  <div style="overflow-x:auto;padding:0 0 14px">
    <table class="sa-tbl" id="annual-tbl">
      <thead><tr><th>Month</th><th>Invoiced</th><th>Collected</th><th>Outstanding</th><th>Count</th></tr></thead>
      <tbody id="annual-body"></tbody>
    </table>
  </div>
</div>

<div id="outstanding-card" class="sa-card" style="display:none">
  <div class="sa-bar" style="background:#C62828"><h3>&#9888; Outstanding Balances — All Companies</h3><span id="outstanding-label" style="font-size:12px;opacity:.8"></span></div>
  <div style="overflow-x:auto;padding:0 0 14px">
    <table class="sa-tbl" id="outstanding-tbl">
      <thead><tr><th>Company</th><th>Overdue Invoices</th><th>Unpaid Invoices</th><th>Total Outstanding</th><th>Actions</th></tr></thead>
      <tbody id="outstanding-body"></tbody>
    </table>
  </div>
</div>

<div id="report-empty" style="display:none;text-align:center;padding:60px;color:#aaa;font-size:14px">
  Select a month above and click <strong>Generate Report</strong> to view revenue data.
</div>

</div></div></div>

<script src="assets/js/common.min.js"></script>
<script src="assets/js/altair_admin_common.min.js"></script>
<script src="assets/js/tm-helpers.js"></script>
<script>
var reportData = [];

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function fmtMoney(n){ return '$'+(+n||0).toFixed(2); }
function fmtMonth(m){
  if(!m) return '—';
  var parts=m.split('-');
  if(parts.length<2) return m;
  var months=['January','February','March','April','May','June','July','August','September','October','November','December'];
  return months[parseInt(parts[1],10)-1]+' '+parts[0];
}

function showNotice(msg, type){
  var el=document.getElementById('report-notice');
  el.className='sa-notice '+(type||'ok');
  el.textContent=msg;
  el.style.display='block';
  if(type!=='err') setTimeout(function(){ el.style.display='none'; },4000);
}

function loadReport(){
  var month=document.getElementById('report-month').value;
  if(!month){ showNotice('Please select a month','err'); return; }

  document.getElementById('report-kpis').style.display='none';
  document.getElementById('report-table-wrap').style.display='none';
  document.getElementById('report-empty').style.display='none';
  document.getElementById('csv-btn').style.display='none';
  document.getElementById('report-notice').style.display='none';

  Promise.all([
    _fbGet('superClients'),
    _fbGet('superBilling')
  ]).then(function(results){
    var clients=results[0]||{};
    var billing=results[1]||{};

    var rows=[];
    var totCollected=0, totOutstanding=0, totInvoiced=0, totOverdue=0;

    Object.entries(clients).forEach(function(entry){
      var cid=entry[0], c=entry[1];
      var invoices=(billing[cid]&&billing[cid].invoices)||{};
      var monthInvoices=Object.values(invoices).filter(function(inv){ return inv.period===month; });
      if(!monthInvoices.length) return;

      var collected=0, outstanding=0, invoiced=0, hasOverdue=false;
      var statuses=[];
      monthInvoices.forEach(function(inv){
        var amt=+(inv.amount||0);
        invoiced+=amt;
        if(inv.status==='paid'){ collected+=amt; }
        else { outstanding+=amt; if(inv.status==='overdue') hasOverdue=true; }
        statuses.push(inv.status);
      });

      totCollected+=collected;
      totOutstanding+=outstanding;
      totInvoiced+=invoiced;
      if(hasOverdue) totOverdue++;

      rows.push({cid:cid,name:c.name||cid,plan:c.packageName||c.plan||'—',invoiceCount:monthInvoices.length,invoiced:invoiced,collected:collected,outstanding:outstanding,hasOverdue:hasOverdue,statuses:statuses});
    });

    reportData=rows;

    document.getElementById('report-period-label').textContent=fmtMonth(month);
    document.getElementById('kpi-collected').textContent=fmtMoney(totCollected);
    document.getElementById('kpi-outstanding').textContent=fmtMoney(totOutstanding);
    document.getElementById('kpi-invoiced').textContent=fmtMoney(totInvoiced);
    document.getElementById('kpi-co-count').textContent=rows.length;
    document.getElementById('kpi-overdue-ct').textContent=totOverdue;

    if(!rows.length){
      document.getElementById('report-empty').textContent='No invoices found for '+fmtMonth(month)+'.';
      document.getElementById('report-empty').style.display='block';
      document.getElementById('report-kpis').style.display='block';
      return;
    }

    rows.sort(function(a,b){ return b.outstanding-a.outstanding||b.invoiced-a.invoiced; });

    var html='';
    rows.forEach(function(r){
      var statusBadge=r.hasOverdue
        ?'<span class="badge badge-overdue">&#9888; Overdue</span>'
        :r.outstanding>0?'<span class="badge badge-unpaid">Unpaid</span>'
        :'<span class="badge badge-paid">&#10003; Paid</span>';
      html+='<tr>'
        +'<td style="font-weight:600"><a href="SA-Billing.aspx?cid='+esc(r.cid)+'" style="color:#1565C0;text-decoration:none">'+esc(r.name)+'</a></td>'
        +'<td style="font-family:monospace;font-size:11px;color:#888">'+esc(r.cid)+'</td>'
        +'<td style="color:#555">'+esc(r.plan)+'</td>'
        +'<td style="text-align:center">'+r.invoiceCount+'</td>'
        +'<td style="font-weight:600">'+fmtMoney(r.invoiced)+'</td>'
        +'<td style="color:#2E7D32;font-weight:600">'+fmtMoney(r.collected)+'</td>'
        +'<td style="color:'+(r.outstanding>0?'#C62828':'#aaa')+';font-weight:600">'+fmtMoney(r.outstanding)+'</td>'
        +'<td>'+statusBadge+'</td>'
        +'</tr>';
    });
    document.getElementById('report-body').innerHTML=html;
    document.getElementById('report-kpis').style.display='block';
    document.getElementById('report-table-wrap').style.display='block';
    document.getElementById('csv-btn').style.display='inline-flex';
    loadTrend();
  }).catch(function(e){ showNotice('Error loading report: '+String(e.message||e),'err'); });
}

function loadTrend(){
  var now=new Date();
  var months=[];
  for(var i=11;i>=0;i--){
    var d=new Date(now.getFullYear(),now.getMonth()-i,1);
    months.push(d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0'));
  }
  _fbGet('superBilling').then(function(billing){
    billing=billing||{};
    var totals={};
    months.forEach(function(m){ totals[m]={invoiced:0,collected:0}; });
    Object.entries(billing).forEach(function(entry){
      var cid=entry[0];
      var invoices=(entry[1]&&entry[1].invoices)||{};
      Object.values(invoices).forEach(function(inv){
        if(totals[inv.period]){
          var amt=+(inv.amount||0);
          totals[inv.period].invoiced+=amt;
          if(inv.status==='paid') totals[inv.period].collected+=amt;
        }
      });
    });
    var maxVal=Math.max.apply(null,months.map(function(m){ return totals[m].invoiced; }))||1;
    var chartEl=document.getElementById('trend-chart');
    chartEl.innerHTML=months.map(function(m){
      var inv=totals[m].invoiced, col=totals[m].collected;
      var invH=Math.round((inv/maxVal)*110);
      var colH=Math.round((col/maxVal)*110);
      var parts=m.split('-');
      var lbl=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][parseInt(parts[1],10)-1]+' '+(parts[0].slice(2));
      return '<div style="display:flex;flex-direction:column;align-items:center;flex:1;min-width:28px">'
        +'<div style="display:flex;align-items:flex-end;gap:2px;width:100%">'
        +'<div style="flex:1;background:#BBDEFB;border-radius:3px 3px 0 0;height:'+invH+'px;min-height:1px;transition:height .3s" title="Invoiced: $'+inv.toFixed(2)+'"></div>'
        +'<div style="flex:1;background:#2E7D32;border-radius:3px 3px 0 0;height:'+colH+'px;min-height:'+(col>0?'2':'0')+'px;transition:height .3s" title="Collected: $'+col.toFixed(2)+'"></div>'
        +'</div>'
        +'<div style="font-size:9px;color:#aaa;margin-top:4px;white-space:nowrap">'+lbl+'</div>'
        +'</div>';
    }).join('');
    document.getElementById('trend-card').style.display='block';
    document.getElementById('trend-label').textContent='Last 12 months ('+months[0]+' to '+months[11]+')';
  }).catch(function(e){ console.warn('Trend chart error:',e); });
}

function loadAnnual(){
  var year=new Date().getFullYear();
  var months=['01','02','03','04','05','06','07','08','09','10','11','12'];
  var ytdMonths=months.map(function(m){ return year+'-'+m; });
  document.getElementById('annual-card').style.display='none';
  _fbGet('superBilling').then(function(billing){
    billing=billing||{};
    var totals={};
    ytdMonths.forEach(function(m){ totals[m]={invoiced:0,collected:0,outstanding:0,count:0}; });
    Object.entries(billing).forEach(function(entry){
      var cid=entry[0];
      var invoices=(entry[1]&&entry[1].invoices)||{};
      Object.values(invoices).forEach(function(inv){
        if(totals[inv.period]){
          var amt=+(inv.amount||0);
          totals[inv.period].invoiced+=amt;
          totals[inv.period].count++;
          if(inv.status==='paid') totals[inv.period].collected+=amt;
          else totals[inv.period].outstanding+=amt;
        }
      });
    });
    var totInv=0, totCol=0, totOut=0;
    var html=ytdMonths.map(function(m){
      var t=totals[m]; totInv+=t.invoiced; totCol+=t.collected; totOut+=t.outstanding;
      return '<tr>'
        +'<td style="font-weight:600">'+fmtMonth(m)+'</td>'
        +'<td>'+fmtMoney(t.invoiced)+'</td>'
        +'<td style="color:#2E7D32;font-weight:600">'+fmtMoney(t.collected)+'</td>'
        +'<td style="color:'+(t.outstanding>0?'#C62828':'#aaa')+';font-weight:600">'+fmtMoney(t.outstanding)+'</td>'
        +'<td style="color:#888">'+t.count+'</td>'
        +'</tr>';
    }).join('');
    document.getElementById('annual-body').innerHTML=html;
    document.getElementById('ann-invoiced').textContent=fmtMoney(totInv);
    document.getElementById('ann-collected').textContent=fmtMoney(totCol);
    document.getElementById('ann-outstanding').textContent=fmtMoney(totOut);
    document.getElementById('annual-label').textContent='Year '+year;
    document.getElementById('annual-card').style.display='block';
  }).catch(function(e){ showNotice('Annual summary error: '+e.message,'err'); });
}

function loadOutstanding(){
  document.getElementById('outstanding-card').style.display='none';
  Promise.all([
    _fbGet('superClients'),
    _fbGet('superBilling')
  ]).then(function(results){
    var clients=results[0]||{};
    var billing=results[1]||{};
    var rows=[];
    Object.entries(billing).forEach(function(entry){
      var cid=entry[0];
      var invoices=(entry[1]&&entry[1].invoices)||{};
      var overdueCt=0, unpaidCt=0, totalOut=0;
      Object.values(invoices).forEach(function(inv){
        if(inv.status==='overdue'){ overdueCt++; totalOut+=+(inv.amount||0); }
        else if(inv.status==='unpaid'){ unpaidCt++; totalOut+=+(inv.amount||0); }
      });
      if(totalOut>0){
        var c=clients[cid]||{};
        rows.push({cid:cid,name:c.name||cid,overdue:overdueCt,unpaid:unpaidCt,total:totalOut});
      }
    });
    rows.sort(function(a,b){ return b.total-a.total; });
    if(!rows.length){
      document.getElementById('outstanding-body').innerHTML='<tr><td colspan="5" style="text-align:center;padding:30px;color:#aaa">No outstanding balances. All companies are up to date.</td></tr>';
    } else {
      document.getElementById('outstanding-body').innerHTML=rows.map(function(r){
        return '<tr>'
          +'<td><a href="SA-Billing.aspx?cid='+esc(r.cid)+'" style="font-weight:600;color:#1565C0;text-decoration:none">'+esc(r.name)+'</a><div style="font-size:11px;font-family:monospace;color:#aaa">ID: '+esc(r.cid)+'</div></td>'
          +'<td style="color:#C62828;font-weight:700">'+r.overdue+'</td>'
          +'<td style="color:#E65100;font-weight:700">'+r.unpaid+'</td>'
          +'<td style="color:#C62828;font-weight:800;font-size:14px">'+fmtMoney(r.total)+'</td>'
          +'<td><a href="SA-Billing.aspx?cid='+esc(r.cid)+'" class="sa-btn sa-btn-p" style="font-size:11px;text-decoration:none">View Billing</a></td>'
          +'</tr>';
      }).join('');
    }
    document.getElementById('outstanding-label').textContent=rows.length+' compan'+(rows.length!==1?'ies':'y')+' with outstanding balance';
    document.getElementById('outstanding-card').style.display='block';
  }).catch(function(e){ showNotice('Outstanding balances error: '+e.message,'err'); });
}

function exportCsv(){
  var month=document.getElementById('report-month').value||'report';
  if(!reportData.length){ showNotice('Generate a report first','err'); return; }
  var lines=['Company,Company ID,Plan,Invoices,Invoiced,Collected,Outstanding,Status'];
  reportData.forEach(function(r){
    var status=r.hasOverdue?'Overdue':r.outstanding>0?'Unpaid':'Paid';
    lines.push([
      '"'+(r.name||'').replace(/"/g,'""')+'"',
      r.cid,
      '"'+(r.plan||'').replace(/"/g,'""')+'"',
      r.invoiceCount,
      r.invoiced.toFixed(2),
      r.collected.toFixed(2),
      r.outstanding.toFixed(2),
      status
    ].join(','));
  });
  var blob=new Blob([lines.join('\n')],{type:'text/csv'});
  var a=document.createElement('a');
  a.href=URL.createObjectURL(blob);
  a.download='revenue-report-'+month+'.csv';
  a.click();
}

window._fbOnLogin = function(){
  // Set default month to current
  var now=new Date();
  document.getElementById('report-month').value=now.getFullYear()+'-'+(String(now.getMonth()+1).padStart(2,'0'));
  document.getElementById('report-empty').style.display='block';
};
</script>
<script src="assets/js/bw-customize.js"></script>
</body>
</html>
