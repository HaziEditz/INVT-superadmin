(function(){
  var params = new URLSearchParams(window.location.search);
  var urlCid = params.get('cid') || '';

  // Inject URL cid into COMPANY_ID as early as possible
  if(urlCid && typeof COMPANY_ID !== 'undefined') {
    COMPANY_ID = urlCid;
  }

  document.addEventListener('DOMContentLoaded', function(){
    var wrap = document.querySelector('.fd-wrap');
    if(!wrap) return;

    // Detect which module context we're in from the page URL
    var page = (window.location.pathname || '').toUpperCase();
    var moduleKey = page.indexOf('/FD-') !== -1 ? 'foodDelivery'
                  : page.indexOf('/FR-') !== -1 ? 'freight'
                  : null;

    // Company picker bar
    var bar = document.createElement('div');
    bar.id = 'co-selector-bar';
    bar.style.cssText = [
      'background:#E3F2FD',
      'border:1px solid #BBDEFB',
      'border-radius:8px',
      'padding:12px 18px',
      'margin-bottom:18px',
      'display:flex',
      'align-items:center',
      'gap:12px',
      'flex-wrap:wrap',
      'font-size:13px'
    ].join(';');
    // Context-aware label: operators are the delivery/freight network owners
    // (drivers + dispatch) — restaurants and freight clients sit underneath them.
    var roleLabel = moduleKey === 'foodDelivery' ? 'Delivery Operator'
                  : moduleKey === 'freight'      ? 'Freight Operator'
                  : 'Company';
    var roleHint = moduleKey === 'foodDelivery'
      ? 'The operator whose drivers will deliver this restaurant\u2019s orders.'
      : moduleKey === 'freight'
      ? 'The operator whose drivers will fulfil these freight jobs.'
      : '';
    bar.innerHTML =
      '<span style="font-weight:700;color:#0D47A1;white-space:nowrap">&#128666; ' + roleLabel + ':</span>' +
      '<select id="co-sel" style="padding:7px 12px;border:1px solid #BBDEFB;border-radius:4px;font-size:13px;min-width:220px;background:#fff;flex:1;max-width:420px">' +
        '<option value="">Loading operators\u2026</option>' +
      '</select>' +
      '<span id="co-sel-info" style="font-size:12px;color:#1565C0"></span>' +
      (roleHint ? '<div style="flex-basis:100%;font-size:11.5px;color:#1565C0;opacity:0.85;margin-top:2px">' + roleHint + '</div>' : '');
    wrap.insertBefore(bar, wrap.firstChild);

    // "Please select" prompt shown when no company is chosen
    var prompt = document.createElement('div');
    prompt.id = 'co-sel-prompt';
    prompt.style.cssText = [
      'display:none',
      'background:#FFF9C4',
      'border:1px solid #FFF176',
      'border-radius:8px',
      'padding:20px',
      'text-align:center',
      'color:#E65100',
      'font-size:14px',
      'font-weight:600',
      'margin-bottom:18px'
    ].join(';');
    prompt.innerHTML = '&#9757; Select a ' + roleLabel.toLowerCase() + ' from the dropdown above to view data.';
    wrap.insertBefore(prompt, bar.nextSibling);

    // Use the server-side /api/fb proxy (admin-credentialed) instead of a
     // direct client-side firebase read — Firebase rules deny browser reads of
     // `superClients` for SA admins, so the previous call was returning
     // PERMISSION_DENIED and the dropdown showed "Error loading companies".
    fetch('/api/fb?path=' + encodeURIComponent('superClients')).then(function(r){
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    }).then(function(data){
      data = data || {};
      var sel = document.getElementById('co-sel');
      sel.innerHTML = '';

      // Blank/prompt option
      var blankOpt = document.createElement('option');
      blankOpt.value = '';
      blankOpt.textContent = '\u2014 Select a ' + roleLabel.toLowerCase() + ' \u2014';
      sel.appendChild(blankOpt);

      // Filter: only show companies that have THIS module enabled. Stops the
      // FD picker from listing taxi-only operators and vice versa.
      var list = Object.entries(data).filter(function(entry){
        if (!moduleKey) return true; // unknown page — show all
        var m = entry[1] && entry[1].modules;
        return !!(m && m[moduleKey]);
      }).sort(function(a, b){
        return (a[1].name || a[0]).localeCompare(b[1].name || b[0]);
      });

      if (list.length === 0) {
        var noneOpt = document.createElement('option');
        noneOpt.value = '';
        noneOpt.textContent = '\u2014 No operators have ' + (moduleKey === 'foodDelivery' ? 'Food Delivery' : 'Freight') + ' enabled \u2014';
        noneOpt.disabled = true;
        sel.appendChild(noneOpt);
      }

      list.forEach(function(entry){
        var id = entry[0], c = entry[1];
        var opt = document.createElement('option');
        opt.value = id;

        // Build label: name + cid (to disambiguate duplicates) + module tags
        var label = (c.name || ('Company ' + id)) + ' \u2014 ' + id;
        var tags = [];
        if(c.modules){
          if(c.modules.foodDelivery) tags.push('FD');
          if(c.modules.freight)      tags.push('FR');
          if(c.modules.totalMobility)tags.push('TM');
        }
        opt.textContent = label + (tags.length ? '  [' + tags.join(', ') + ']' : '');

        // Highlight suspended companies
        if(c.status === 'suspended') opt.textContent += '  \u26A0 Suspended';

        if(id === urlCid) opt.selected = true;
        sel.appendChild(opt);
      });

      // Info badge below select
      function showInfo(cid){
        var info = document.getElementById('co-sel-info');
        var c = data[cid] || {};
        var parts = [];
        if(c.city) parts.push(c.city);
        if(c.country) parts.push(c.country);
        info.textContent = parts.join(', ');
        if(c.status === 'suspended'){
          info.innerHTML +=
            ' <span style="background:#FFEBEE;color:#C62828;font-size:10px;font-weight:700;padding:2px 7px;border-radius:8px;border:1px solid #FFCDD2">&#9888; Suspended</span>';
        }
      }

      if(urlCid && data[urlCid]){
        showInfo(urlCid);
        document.getElementById('co-sel-prompt').style.display = 'none';
      } else if(!urlCid){
        // No company selected — show prompt, dim main content
        document.getElementById('co-sel-prompt').style.display = 'block';
        var contentEls = wrap.querySelectorAll(
          '.fd-card, .fd-stats, .fd-controls, .fr-info-note, table, canvas, .sa-card, h2 + p, p + div'
        );
        contentEls.forEach(function(el){
          el.style.opacity = '0.25';
          el.style.pointerEvents = 'none';
          el.style.userSelect = 'none';
        });
      }

      sel.addEventListener('change', function(){
        var newCid = sel.value;
        if(!newCid) return;
        var url = new URL(window.location.href);
        url.searchParams.set('cid', newCid);
        window.location.href = url.toString();
      });

    }).catch(function(err){
      var sel = document.getElementById('co-sel');
      if(sel) sel.innerHTML = '<option value="">Error loading operators</option>';
      console.error('[co-selector] Failed to load companies:', err);
    });
  });
})();
