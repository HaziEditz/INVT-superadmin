<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8"/>
<title>Passenger Wallet &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="assets/js/jquery.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
<link href="bower_components/uikit/css/uikit.almost-flat.min.css" rel="stylesheet"/>
<link href="assets/css/main.min.css" rel="stylesheet"/>
<link href="assets/css/Toast.css" rel="stylesheet"/>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<style>
body{margin:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#F5F7FA;color:#212121}
.sa-wrap{padding:20px;max-width:1280px;margin:0 auto}
.sa-card{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.12);margin-bottom:20px;overflow:hidden}
.sa-bar{background:#1565C0;color:#fff;padding:13px 18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.sa-bar h3{margin:0;font-size:15px;font-weight:600}
.sa-body{padding:18px}
.sa-grid{display:grid;gap:14px;grid-template-columns:repeat(auto-fit,minmax(220px,1fr))}
.sa-row{display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end;margin-bottom:14px}
.sa-row > div{flex:1;min-width:160px}
label{display:block;font-size:12px;font-weight:600;color:#555;margin-bottom:4px;text-transform:uppercase;letter-spacing:.3px}
input,select,textarea{width:100%;padding:8px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;font-family:inherit;background:#fff;box-sizing:border-box}
input:focus,select:focus,textarea:focus{outline:none;border-color:#1565C0;box-shadow:0 0 0 2px rgba(21,101,192,.15)}
.sa-btn{display:inline-flex;align-items:center;gap:4px;padding:8px 14px;border-radius:4px;border:none;cursor:pointer;font-size:13px;font-weight:500;text-decoration:none;font-family:inherit}
.sa-btn-p{background:#1565C0;color:#fff}.sa-btn-p:hover{background:#0D47A1}
.sa-btn-s{background:#2E7D32;color:#fff}.sa-btn-s:hover{background:#1B5E20}
.sa-btn-w{background:#F57F17;color:#fff}.sa-btn-w:hover{background:#E65100}
.sa-btn-n{background:#f5f5f5;color:#555;border:1px solid #e0e0e0}.sa-btn-n:hover{background:#eee}
.sa-btn[disabled]{opacity:.5;cursor:not-allowed}
.sa-tbl{width:100%;border-collapse:collapse;font-size:13px;margin-top:8px}
.sa-tbl th{background:#E3F2FD;padding:9px 11px;text-align:left;font-weight:700;border-bottom:2px solid #BBDEFB;color:#0D47A1;font-size:12px;text-transform:uppercase;letter-spacing:.3px}
.sa-tbl td{padding:8px 11px;border-bottom:1px solid #f5f5f5}
.sa-tbl tr:hover td{background:#FFFDE7}
.kv{display:grid;grid-template-columns:160px 1fr;gap:6px 14px;font-size:13px}
.kv .k{color:#666;font-weight:600}
.kv .v{font-family:'SF Mono',Menlo,Consolas,monospace;word-break:break-all}
.bal{font-size:32px;font-weight:700;color:#1B5E20;font-family:'SF Mono',Menlo,Consolas,monospace}
.bal.neg{color:#C62828}
.muted{color:#888;font-size:12px}
.tag{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700}
.tag-credit{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.tag-debit{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.tag-warn{background:#FFF8E1;color:#F57F17;border:1px solid #FFE082}
.banner{padding:10px 14px;border-radius:4px;margin-bottom:14px;font-size:13px;display:none}
.banner.err{background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2}
.banner.ok{background:#E8F5E9;color:#2E7D32;border:1px solid #A5D6A7}
.banner.show{display:block}
.topnav{background:#0D47A1;color:#fff;padding:10px 20px;display:flex;align-items:center;justify-content:space-between}
.topnav a{color:#fff;text-decoration:none;margin-right:14px;font-size:13px;font-weight:500;opacity:.85}
.topnav a:hover{opacity:1}
.topnav .me{font-size:12px;opacity:.85}
.spinner{display:inline-block;width:14px;height:14px;border:2px solid #ccc;border-top-color:#1565C0;border-radius:50%;animation:spin .8s linear infinite;vertical-align:middle;margin-right:6px}
@keyframes spin{to{transform:rotate(360deg)}}
.integrity{padding:10px;border-radius:4px;font-size:12px;margin-top:10px;font-family:'SF Mono',Menlo,Consolas,monospace}
.integrity.ok{background:#E8F5E9;color:#1B5E20}
.integrity.fail{background:#FFEBEE;color:#C62828}
</style>
</head>
<body>

<div class="topnav">
  <div>
    <a href="SA-Dashboard.aspx">&larr; SA Dashboard</a>
    <a href="SA-Clients.aspx">Operators</a>
    <a href="SA-Drivers.aspx">Drivers</a>
    <strong style="margin-left:6px">Passenger Wallet</strong>
  </div>
  <div class="me"><span id="meEmail">…</span> &middot; <a href="javascript:firebase.auth().signOut()">Logout</a></div>
</div>

<div class="sa-wrap">

  <div id="banner" class="banner"></div>

  <!-- ── LOOKUP PANEL ───────────────────────────────────────────────────── -->
  <div class="sa-card">
    <div class="sa-bar"><h3>🔍 Wallet Lookup</h3></div>
    <div class="sa-body">
      <div class="sa-row">
        <div>
          <label>Identifier type</label>
          <select id="lkType">
            <option value="email">Email</option>
            <option value="phone">Phone</option>
            <option value="uid">Firebase UID</option>
            <option value="key">Passenger key</option>
          </select>
        </div>
        <div style="flex:2">
          <label>Identifier value</label>
          <input id="lkValue" placeholder="e.g. customer@example.com"/>
        </div>
        <div style="flex:0">
          <button class="sa-btn sa-btn-p" id="lkGo">Look up</button>
        </div>
      </div>

      <div id="lkResult" style="display:none">
        <div class="sa-grid" style="margin-top:10px">
          <div>
            <div class="muted">Current balance</div>
            <div class="bal" id="lkBalance">—</div>
            <div class="muted" id="lkBalanceMeta"></div>
          </div>
          <div>
            <div class="kv">
              <div class="k">Passenger key</div><div class="v" id="lkKey">—</div>
              <div class="k">Firebase UID</div><div class="v" id="lkUid">—</div>
              <div class="k">Email</div><div class="v" id="lkEmail">—</div>
              <div class="k">Phone</div><div class="v" id="lkPhone">—</div>
              <div class="k">Created</div><div class="v" id="lkCreated">—</div>
            </div>
          </div>
        </div>

        <h4 style="margin:18px 0 6px;font-size:13px;color:#555">Recent ledger (last 50)</h4>
        <table class="sa-tbl">
          <thead><tr><th>When</th><th>Type</th><th>Reason</th><th style="text-align:right">Amount</th><th style="text-align:right">Balance after</th><th>Notes</th></tr></thead>
          <tbody id="lkLedger"><tr><td colspan="6" class="muted">Loading…</td></tr></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ── ADJUST PANEL ───────────────────────────────────────────────────── -->
  <div class="sa-card">
    <div class="sa-bar"><h3>✏️ Manual Adjustment</h3></div>
    <div class="sa-body">
      <div class="sa-row">
        <div>
          <label>Identifier type</label>
          <select id="adjType">
            <option value="email">Email</option>
            <option value="phone">Phone</option>
            <option value="uid">Firebase UID</option>
            <option value="key">Passenger key</option>
          </select>
        </div>
        <div style="flex:2">
          <label>Identifier value</label>
          <input id="adjValue" placeholder="passenger identifier"/>
        </div>
        <div>
          <label>Amount (NZD, negative for clawback)</label>
          <input id="adjAmount" type="number" step="0.01" placeholder="10.00"/>
        </div>
      </div>
      <div class="sa-row">
        <div>
          <label>Reason</label>
          <select id="adjReason">
            <option value="refund_correction">Refund correction</option>
            <option value="goodwill_credit">Goodwill credit</option>
            <option value="dispute_resolution">Dispute resolution</option>
            <option value="fraud_clawback">Fraud clawback</option>
            <option value="other">Other</option>
          </select>
        </div>
        <div style="flex:3">
          <label>Note (audit log)</label>
          <input id="adjNote" placeholder="e.g. Stripe dispute #ch_xxx — refunding fare $10 to wallet"/>
        </div>
        <div style="flex:0">
          <button class="sa-btn sa-btn-w" id="adjGo">Apply adjustment</button>
        </div>
      </div>
      <div class="muted">Adjustments are immutable. Both the wallet ledger and walletAdminAudit are written atomically — your name + timestamp + before/after balance are stamped permanently.</div>
    </div>
  </div>

  <!-- ── RECONCILIATION PANEL ───────────────────────────────────────────── -->
  <div class="sa-card">
    <div class="sa-bar">
      <h3>📊 Reconciliation Report</h3>
      <button class="sa-btn sa-btn-n" id="recCsv">Export CSV</button>
    </div>
    <div class="sa-body">
      <div class="sa-row">
        <div>
          <label>From (UTC)</label>
          <input id="recFrom" type="datetime-local"/>
        </div>
        <div>
          <label>To (UTC)</label>
          <input id="recTo" type="datetime-local"/>
        </div>
        <div style="flex:0">
          <button class="sa-btn sa-btn-p" id="recGo">Run report</button>
        </div>
      </div>

      <div id="recOut" style="display:none">
        <div class="sa-grid" style="margin-top:10px">
          <div><div class="muted">Currency</div><div class="bal" id="recCurrency" style="font-size:18px;color:#212121">—</div></div>
          <div><div class="muted">Passengers</div><div class="bal" id="recCount" style="font-size:18px;color:#212121">—</div></div>
          <div><div class="muted">Opening balance</div><div class="bal" id="recOpen" style="font-size:18px">—</div></div>
          <div><div class="muted">Closing balance</div><div class="bal" id="recClose" style="font-size:18px">—</div></div>
          <div><div class="muted">Total credits</div><div class="bal" id="recCredits" style="font-size:18px">—</div></div>
          <div><div class="muted">Total debits</div><div class="bal" id="recDebits" style="font-size:18px;color:#C62828">—</div></div>
        </div>

        <div id="recIntegrity" class="integrity">—</div>

        <h4 style="margin:18px 0 6px;font-size:13px;color:#555">By reason</h4>
        <table class="sa-tbl">
          <thead><tr><th>Reason</th><th style="text-align:right">Count</th><th style="text-align:right">Credits</th><th style="text-align:right">Debits</th><th style="text-align:right">Net</th></tr></thead>
          <tbody id="recByReason"></tbody>
        </table>

        <div id="recByAdjustWrap" style="display:none">
          <h4 style="margin:18px 0 6px;font-size:13px;color:#555">Admin adjustments — by sub-reason</h4>
          <table class="sa-tbl">
            <thead><tr><th>Adjust reason</th><th style="text-align:right">Count</th><th style="text-align:right">Credits</th><th style="text-align:right">Debits</th><th style="text-align:right">Net</th></tr></thead>
            <tbody id="recByAdjustReason"></tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

</div>

<script>
function $(s){return document.querySelector(s);}
function showBanner(kind, msg){var b=$('#banner'); b.className='banner '+kind+' show'; b.textContent=msg; setTimeout(function(){b.classList.remove('show')}, 6000);}
function fmtMoney(dollars){if(dollars==null||isNaN(dollars))return '—'; return (dollars<0?'-$':'$')+Math.abs(dollars).toFixed(2);}
function fmtCents(c){return fmtMoney(c==null?null:c/100);}
function fmtTs(t){if(!t) return '—'; var d=new Date(t); return d.toLocaleString();}
function esc(s){return String(s==null?'':s).replace(/[&<>"']/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c];});}

// Auth: send a fresh Firebase ID token on every call. Server verifies the
// token and checks super-admin membership — never trust caller-supplied UIDs.
function api(method, path, body){
  var url='/api/sa-wallet/'+path;
  var user = firebase.auth().currentUser;
  if(!user){ return Promise.reject(new Error('Not signed in')); }
  return user.getIdToken().then(function(idToken){
    var opts={method:method, headers:{'Content-Type':'application/json', 'Authorization':'Bearer '+idToken}};
    if(body){ opts.body = JSON.stringify(body); }
    return fetch(url, opts).then(function(r){
      return r.text().then(function(t){
        var j; try{j=JSON.parse(t);}catch(e){j={raw:t};}
        if(!r.ok){ var err=new Error(j.error||('HTTP '+r.status)); err.status=r.status; err.body=j; throw err; }
        return j;
      });
    });
  });
}

// ── LOOKUP ────────────────────────────────────────────────────────────────
document.getElementById('lkGo').addEventListener('click', function(){
  var type=$('#lkType').value, val=$('#lkValue').value.trim();
  if(!val){ showBanner('err','Enter an identifier'); return; }
  this.disabled=true;
  api('GET','lookup?'+encodeURIComponent(type)+'='+encodeURIComponent(val))
    .then(function(r){
      $('#lkResult').style.display='block';
      var cents = r.balanceCents != null ? r.balanceCents : (r.balance!=null?Math.round(r.balance*100):0);
      var bal=$('#lkBalance'); bal.textContent=fmtCents(cents); bal.classList.toggle('neg', cents<0);
      $('#lkBalanceMeta').textContent=(r.currency||'NZD')+' · key '+(r.key||'—');
      $('#lkKey').textContent=r.key||'—';
      $('#lkUid').textContent=r.uid||'(none yet)';
      $('#lkEmail').textContent=r.email||'—';
      $('#lkPhone').textContent=r.phone||'—';
      $('#lkCreated').textContent=fmtTs(r.createdAt);
      // Pull ledger
      return api('GET','ledger/'+encodeURIComponent(val)+'?type='+encodeURIComponent(type));
    })
    .then(function(r){
      var entries=r.entries||r.ledger||[];
      entries.sort(function(a,b){return (b.createdAt||0)-(a.createdAt||0);});
      var tb=$('#lkLedger'); tb.innerHTML='';
      if(!entries.length){ tb.innerHTML='<tr><td colspan="6" class="muted">No ledger entries</td></tr>'; return; }
      entries.slice(0,50).forEach(function(e){
        var amt=e.amountCents!=null?e.amountCents:(e.amount?Math.round(e.amount*100):0);
        var tag = amt>=0 ? '<span class="tag tag-credit">+'+fmtCents(amt)+'</span>' : '<span class="tag tag-debit">'+fmtCents(amt)+'</span>';
        var rawNote = e.note || e.adjustReason || e.adjustedBy || '';
        var noteHtml = esc(rawNote);
        if(e.auditTxId) noteHtml += ' <span class="muted">[audit:'+esc(String(e.auditTxId).slice(0,8))+']</span>';
        tb.insertAdjacentHTML('beforeend',
          '<tr><td>'+esc(fmtTs(e.createdAt))+'</td><td>'+esc(e.type||'—')+'</td><td>'+esc(e.reason||'—')+'</td>'+
          '<td style="text-align:right">'+tag+'</td>'+
          '<td style="text-align:right">'+esc(fmtCents(e.balanceAfterCents))+'</td>'+
          '<td>'+noteHtml+'</td></tr>');
      });
    })
    .catch(function(err){
      $('#lkResult').style.display='none';
      showBanner('err', err.status===404 ? 'Passenger not found' : ('Lookup failed: '+err.message));
    })
    .finally(function(){ document.getElementById('lkGo').disabled=false; });
});

// ── ADJUST ────────────────────────────────────────────────────────────────
document.getElementById('adjGo').addEventListener('click', function(){
  var type=$('#adjType').value;
  var val=$('#adjValue').value.trim();
  var amt=parseFloat($('#adjAmount').value);
  var reason=$('#adjReason').value;
  var note=$('#adjNote').value.trim();
  if(!val){ showBanner('err','Enter an identifier'); return; }
  if(isNaN(amt) || amt===0){ showBanner('err','Amount must be a non-zero number'); return; }
  if(!note){ showBanner('err','Note is required for audit trail'); return; }
  if(!confirm('Adjust wallet for '+type+'="'+val+'" by '+fmtMoney(amt)+'?\nReason: '+reason+'\nThis is permanent and audited.')) return;
  this.disabled=true;
  var meEmail = (firebase.auth().currentUser && firebase.auth().currentUser.email) || 'sa-admin';
  api('POST','adjust',{
    identifier: val,
    identifierType: type,
    amount: amt,
    reason: reason,
    adjustedBy: meEmail,
    note: note
  })
    .then(function(r){
      showBanner('ok','Adjustment applied. New balance: '+fmtCents(r.balanceAfterCents!=null?r.balanceAfterCents:r.afterBalanceCents)+'  (txId: '+(r.txId||r.entryId||'?')+')');
      $('#adjValue').value=''; $('#adjAmount').value=''; $('#adjNote').value='';
      // Auto-refresh lookup if the same identifier was loaded
      if($('#lkValue').value.trim()===val && $('#lkType').value===type) document.getElementById('lkGo').click();
    })
    .catch(function(err){
      showBanner('err','Adjustment failed: '+err.message);
    })
    .finally(function(){ document.getElementById('adjGo').disabled=false; });
});

// ── RECONCILIATION ────────────────────────────────────────────────────────
function runReconciliation(){
  var qs=[];
  var f=$('#recFrom').value, t=$('#recTo').value;
  if(f) qs.push('from='+encodeURIComponent(new Date(f).toISOString()));
  if(t) qs.push('to='+encodeURIComponent(new Date(t).toISOString()));
  document.getElementById('recGo').disabled=true;
  api('GET','reconciliation'+(qs.length?'?'+qs.join('&'):''))
    .then(function(r){
      $('#recOut').style.display='block';
      $('#recCurrency').textContent=r.currency||'NZD';
      $('#recCount').textContent=r.passengerCount||0;
      $('#recOpen').textContent=fmtCents(r.openingBalanceCents);
      $('#recClose').textContent=fmtCents(r.closingBalanceCents);
      $('#recCredits').textContent='+'+fmtCents(r.totalCreditsCents);
      $('#recDebits').textContent='-'+fmtCents(r.totalDebitsCents);
      // Integrity check per contract:
      //   closingBalanceCents - openingBalanceCents === totalCreditsCents - totalDebitsCents
      var lhs = (r.closingBalanceCents||0) - (r.openingBalanceCents||0);
      var rhs = (r.totalCreditsCents||0) - (r.totalDebitsCents||0);
      var integ=$('#recIntegrity');
      if(lhs === rhs){
        integ.className='integrity ok';
        integ.textContent='✅ Integrity check OK  ·  closing − opening = '+lhs+'¢  =  credits − debits = '+rhs+'¢';
      } else {
        integ.className='integrity fail';
        integ.textContent='⚠️ Integrity mismatch  ·  closing − opening = '+lhs+'¢  ≠  credits − debits = '+rhs+'¢  (Δ='+(lhs-rhs)+'¢). Investigate ledger before trusting this report.';
      }
      // byReason table (top-level ledger reason field)
      var tb=$('#recByReason'); tb.innerHTML='';
      var keys=Object.keys(r.byReason||{}).sort();
      if(!keys.length){ tb.innerHTML='<tr><td colspan="5" class="muted">No activity in this window</td></tr>'; }
      keys.forEach(function(k){
        var row=r.byReason[k];
        tb.insertAdjacentHTML('beforeend',
          '<tr><td>'+esc(k)+'</td>'+
          '<td style="text-align:right">'+(row.count||0)+'</td>'+
          '<td style="text-align:right;color:#2E7D32">+'+fmtCents(row.creditsCents)+'</td>'+
          '<td style="text-align:right;color:#C62828">-'+fmtCents(row.debitsCents)+'</td>'+
          '<td style="text-align:right">'+fmtCents(row.totalCents)+'</td></tr>');
      });
      // byAdjustReason sub-block — only rendered when present (admin /adjust splits)
      var tba=$('#recByAdjustReason'); tba.innerHTML='';
      var akeys=Object.keys(r.byAdjustReason||{}).sort();
      if(akeys.length){
        $('#recByAdjustWrap').style.display='block';
        akeys.forEach(function(k){
          var row=r.byAdjustReason[k];
          tba.insertAdjacentHTML('beforeend',
            '<tr><td>'+esc(k)+'</td>'+
            '<td style="text-align:right">'+(row.count||0)+'</td>'+
            '<td style="text-align:right;color:#2E7D32">+'+fmtCents(row.creditsCents)+'</td>'+
            '<td style="text-align:right;color:#C62828">-'+fmtCents(row.debitsCents)+'</td>'+
            '<td style="text-align:right">'+fmtCents(row.totalCents)+'</td></tr>');
        });
      } else {
        $('#recByAdjustWrap').style.display='none';
      }
      // Stash for CSV export
      window.__recLast = r;
    })
    .catch(function(err){ showBanner('err','Reconciliation failed: '+err.message); })
    .finally(function(){ document.getElementById('recGo').disabled=false; });
}
document.getElementById('recGo').addEventListener('click', runReconciliation);

document.getElementById('recCsv').addEventListener('click', function(){
  var r=window.__recLast;
  if(!r){ showBanner('err','Run a report first'); return; }
  var lines=['Wallet Reconciliation Report'];
  lines.push('From,'+(r.from||''));
  lines.push('To,'+(r.to||''));
  lines.push('Currency,'+r.currency);
  lines.push('Passengers,'+r.passengerCount);
  lines.push('Opening (cents),'+r.openingBalanceCents);
  lines.push('Closing (cents),'+r.closingBalanceCents);
  lines.push('Total credits (cents),'+r.totalCreditsCents);
  lines.push('Total debits (cents),'+r.totalDebitsCents);
  lines.push('');
  lines.push('Reason,Count,Credits (cents),Debits (cents),Net (cents)');
  Object.keys(r.byReason||{}).sort().forEach(function(k){
    var x=r.byReason[k];
    lines.push([k, x.count||0, x.creditsCents||0, x.debitsCents||0, x.totalCents||0].join(','));
  });
  if(r.byAdjustReason && Object.keys(r.byAdjustReason).length){
    lines.push('');
    lines.push('Admin adjustments by sub-reason,Count,Credits (cents),Debits (cents),Net (cents)');
    Object.keys(r.byAdjustReason).sort().forEach(function(k){
      var x=r.byAdjustReason[k];
      lines.push([k, x.count||0, x.creditsCents||0, x.debitsCents||0, x.totalCents||0].join(','));
    });
  }
  var blob=new Blob([lines.join('\n')], {type:'text/csv'});
  var url=URL.createObjectURL(blob);
  var a=document.createElement('a'); a.href=url; a.download='wallet-reconciliation-'+Date.now()+'.csv'; a.click();
  URL.revokeObjectURL(url);
});

// ── Auth gate ─────────────────────────────────────────────────────────────
firebase.auth().onAuthStateChanged(function(user){
  if(!user){ window.location.href='SA-Login.aspx'; return; }
  document.getElementById('meEmail').textContent = user.email || user.uid;
  // Default report range: this month, UTC
  var now=new Date();
  var from=new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1, 0, 0, 0));
  var to=new Date();
  function toLocalInput(d){ var iso=new Date(d.getTime()-d.getTimezoneOffset()*60000).toISOString(); return iso.slice(0,16); }
  $('#recFrom').value = toLocalInput(from);
  $('#recTo').value = toLocalInput(to);
});
</script>
</body>
</html>
