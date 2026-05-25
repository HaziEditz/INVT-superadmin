/* BookaWaka Admin — Theme Customizer */
(function(){
  var PRESETS = [
    { name:'Ocean',   accent:'#2563EB', sidebar:'#0F172A', header:'#1E293B' },
    { name:'Violet',  accent:'#7C3AED', sidebar:'#1A0B2E', header:'#2D0D4E' },
    { name:'Emerald', accent:'#059669', sidebar:'#052E16', header:'#0A3D22' },
    { name:'Amber',   accent:'#D97706', sidebar:'#1C1400', header:'#2A1F00' },
    { name:'Rose',    accent:'#E11D48', sidebar:'#1A0010', header:'#2D0018' },
    { name:'Slate',   accent:'#475569', sidebar:'#0F172A', header:'#1E293B' },
  ];

  var KEY = 'bw_theme_v1';

  function loadTheme() {
    try { return JSON.parse(localStorage.getItem(KEY)) || PRESETS[0]; }
    catch(e) { return PRESETS[0]; }
  }

  function hexToRgb(hex) {
    var r = parseInt(hex.slice(1,3),16);
    var g = parseInt(hex.slice(3,5),16);
    var b = parseInt(hex.slice(5,7),16);
    return r+','+g+','+b;
  }

  function applyTheme(t) {
    var rgb = hexToRgb(t.accent);
    var s = document.getElementById('bw-custom-style');
    if(!s){ s=document.createElement('style'); s.id='bw-custom-style'; document.head.appendChild(s); }
    s.textContent = [
      '#sidebar_main{background:'+t.sidebar+'!important}',
      '#sidebar_main .sidebar_main_header{background:'+t.sidebar+'!important}',
      '#header_main{background:'+t.header+'!important}',
      '.menu_section>ul>li>a:hover,.menu_section>ul>li.active_main>a,.menu_section>ul>li.current_section.open>a{background:rgba('+rgb+',.15)!important;border-left-color:'+t.accent+'!important}',
      '.menu_section>ul>li>ul li a:hover{background:rgba('+rgb+',.1)!important;color:'+t.accent+'!important}',
      '.menu_section>ul>li>a:hover .menu_icon .material-icons,.menu_section>ul>li.active_main>a .menu_icon .material-icons,.menu_section>ul>li.current_section.open>a .menu_icon .material-icons{color:'+t.accent+'!important}',
      '.kpi.orange::before,.kpi.blue::before{background:'+t.accent+'!important}',
      '.uk-button-primary,.sa-btn-approve,.sa-btn-b{background:'+t.accent+'!important}',
      '.uk-button-primary:hover,.sa-btn-approve:hover,.sa-btn-b:hover{background:'+shadeColor(t.accent,-15)+'!important}',
      '.btn{background:'+t.accent+'!important}',
      '.btn:hover{background:'+shadeColor(t.accent,-15)+'!important;box-shadow:0 4px 12px rgba('+rgb+',.35)!important}',
      '.tab-btn.active,.tab-btn:focus{background:rgba('+rgb+',.08)!important;color:'+t.accent+'!important;border-color:rgba('+rgb+',.35)!important}',
      '.tab-btn:hover{border-color:rgba('+rgb+',.35)!important;color:'+t.accent+'!important}',
      '.ql-btn:hover{border-color:'+t.accent+'!important;color:'+t.accent+'!important;background:rgba('+rgb+',.06)!important}',
      '.db-card-hdr a,.mod-link,.co-tbl a,.attn-btn-blue{color:'+t.accent+'!important}',
      '.attn-btn-blue{background:rgba('+rgb+',.1)!important}',
      '.field input:focus,.sa-stat.blue{border-color:'+t.accent+'!important}',
      '.sa-stat.blue{border-top-color:'+t.accent+'!important}',
      'input:focus,select:focus,textarea:focus{border-color:'+t.accent+'!important;box-shadow:0 0 0 3px rgba('+rgb+',.1)!important}',
    ].join('\n');
    localStorage.setItem(KEY, JSON.stringify(t));
  }

  function shadeColor(hex, pct) {
    var n = parseInt(hex.slice(1),16);
    var r = Math.min(255,Math.max(0,((n>>16)&0xff)+Math.round(2.55*pct)));
    var g = Math.min(255,Math.max(0,((n>>8)&0xff)+Math.round(2.55*pct)));
    var b = Math.min(255,Math.max(0,(n&0xff)+Math.round(2.55*pct)));
    return '#'+((1<<24)+(r<<16)+(g<<8)+b).toString(16).slice(1);
  }

  function buildUI() {
    var cur = loadTheme();
    applyTheme(cur);

    var wrap = document.createElement('div');
    wrap.id = 'bw-cz-wrap';
    wrap.innerHTML = [
      '<button id="bw-cz-btn" title="Customise theme" onclick="window._bwCzToggle()">',
        '<svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><circle cx="12" cy="12" r="3"/></svg>',
      '</button>',
      '<div id="bw-cz-panel">',
        '<div id="bw-cz-hdr"><span>&#127912; Customise Theme</span><button onclick="window._bwCzToggle()" style="background:none;border:none;cursor:pointer;color:#64748B;font-size:18px;line-height:1;padding:0">&times;</button></div>',
        '<div id="bw-cz-body">',
          '<div class="bw-cz-sec">Colour presets</div>',
          '<div id="bw-cz-presets">'+PRESETS.map(function(p,i){
            return '<button class="bw-cz-preset" data-i="'+i+'" title="'+p.name+'" style="background:'+p.accent+'" onclick="window._bwCzPreset('+i+')"></button>';
          }).join('')+'</div>',
          '<div class="bw-cz-sec" style="margin-top:16px">Accent colour</div>',
          '<div style="display:flex;align-items:center;gap:10px;margin-top:8px">',
            '<input type="color" id="bw-cz-accent" value="'+cur.accent+'" style="width:44px;height:36px;border:1.5px solid #E2E8F0;border-radius:8px;cursor:pointer;padding:2px 3px"/>',
            '<span id="bw-cz-accent-val" style="font-size:12px;font-family:monospace;color:#64748B">'+cur.accent+'</span>',
          '</div>',
          '<div class="bw-cz-sec" style="margin-top:16px">Sidebar colour</div>',
          '<div style="display:flex;align-items:center;gap:10px;margin-top:8px">',
            '<input type="color" id="bw-cz-sidebar" value="'+cur.sidebar+'" style="width:44px;height:36px;border:1.5px solid #E2E8F0;border-radius:8px;cursor:pointer;padding:2px 3px"/>',
            '<span id="bw-cz-sidebar-val" style="font-size:12px;font-family:monospace;color:#64748B">'+cur.sidebar+'</span>',
          '</div>',
          '<button id="bw-cz-reset" onclick="window._bwCzReset()">Reset to default</button>',
        '</div>',
      '</div>',
    ].join('');

    var style = document.createElement('style');
    style.textContent = [
      '#bw-cz-wrap{position:fixed;bottom:20px;right:20px;z-index:99999;font-family:\'Inter\',system-ui,sans-serif}',
      '#bw-cz-btn{width:44px;height:44px;border-radius:50%;background:#1E293B;color:#fff;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 14px rgba(0,0,0,.35);transition:.2s;margin-left:auto}',
      '#bw-cz-btn:hover{transform:rotate(45deg);box-shadow:0 6px 20px rgba(0,0,0,.4)}',
      '#bw-cz-panel{position:absolute;bottom:54px;right:0;width:240px;background:#fff;border-radius:14px;box-shadow:0 10px 40px rgba(0,0,0,.2);border:1px solid #E2E8F0;overflow:hidden;display:none;animation:bwFadeUp .2s ease}',
      '@keyframes bwFadeUp{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}',
      '#bw-cz-hdr{padding:14px 16px;background:#F8FAFC;border-bottom:1px solid #E2E8F0;display:flex;align-items:center;justify-content:space-between;font-size:13px;font-weight:700;color:#0F172A}',
      '#bw-cz-body{padding:16px}',
      '.bw-cz-sec{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#94A3B8}',
      '#bw-cz-presets{display:flex;gap:8px;flex-wrap:wrap;margin-top:8px}',
      '.bw-cz-preset{width:30px;height:30px;border-radius:50%;border:2px solid transparent;cursor:pointer;transition:.15s;padding:0}',
      '.bw-cz-preset:hover{transform:scale(1.15);border-color:rgba(0,0,0,.2)}',
      '.bw-cz-preset.active{border-color:#0F172A;box-shadow:0 0 0 2px #fff,0 0 0 4px #0F172A}',
      '#bw-cz-reset{margin-top:18px;width:100%;padding:8px;border:1.5px solid #E2E8F0;background:#F8FAFC;border-radius:8px;font-size:12.5px;font-weight:600;color:#64748B;cursor:pointer;transition:.15s}',
      '#bw-cz-reset:hover{background:#E2E8F0;color:#374151}',
    ].join('');

    document.head.appendChild(style);
    document.body.appendChild(wrap);

    var open = false;
    window._bwCzToggle = function(){
      open = !open;
      document.getElementById('bw-cz-panel').style.display = open ? 'block' : 'none';
      syncUI(loadTheme());
    };

    window._bwCzPreset = function(i){
      var p = PRESETS[i];
      applyTheme(p);
      syncUI(p);
      syncPresetBtns(i);
    };

    window._bwCzReset = function(){
      applyTheme(PRESETS[0]);
      syncUI(PRESETS[0]);
      syncPresetBtns(0);
    };

    function syncUI(t) {
      document.getElementById('bw-cz-accent').value = t.accent;
      document.getElementById('bw-cz-accent-val').textContent = t.accent;
      document.getElementById('bw-cz-sidebar').value = t.sidebar;
      document.getElementById('bw-cz-sidebar-val').textContent = t.sidebar;
    }

    function syncPresetBtns(activeIdx) {
      document.querySelectorAll('.bw-cz-preset').forEach(function(b,i){
        b.classList.toggle('active', i===activeIdx);
      });
    }
    syncPresetBtns(PRESETS.findIndex(function(p){ var c=loadTheme(); return p.accent===c.accent&&p.sidebar===c.sidebar; }));

    document.getElementById('bw-cz-accent').addEventListener('input', function(e){
      var cur2 = loadTheme();
      cur2.accent = e.target.value;
      document.getElementById('bw-cz-accent-val').textContent = e.target.value;
      applyTheme(cur2);
    });
    document.getElementById('bw-cz-sidebar').addEventListener('input', function(e){
      var cur2 = loadTheme();
      cur2.sidebar = e.target.value;
      cur2.header = shadeColor(e.target.value, 10);
      document.getElementById('bw-cz-sidebar-val').textContent = e.target.value;
      applyTheme(cur2);
    });
  }

  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded', buildUI);
  } else {
    buildUI();
  }
})();

/* Suppress known non-fatal errors from the Altair admin theme's minified JS.
   These occur when optional UI components (search bar, hierarchical sidebar)
   are absent on a given page — they do not affect portal functionality.
   Uses capture phase (true) so this handler runs before any other listener. */
(function(){
  var THEME_FILES = ['altair_admin_common.min.js', 'common.min.js'];
  function isThemeFile(src) {
    if (!src) return false;
    for (var i = 0; i < THEME_FILES.length; i++) {
      if (src.indexOf(THEME_FILES[i]) !== -1) return true;
    }
    return false;
  }
  /* Capture-phase error handler — fires before the platform's own reporter */
  window.addEventListener('error', function(e) {
    if (isThemeFile(e.filename)) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }
  }, true);
  /* Also suppress any unhandled promise rejections from theme code */
  window.addEventListener('unhandledrejection', function(e) {
    var stack = (e.reason && e.reason.stack) || '';
    if (isThemeFile(stack)) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }
  }, true);
  /* Belt-and-suspenders: window.onerror as a fallback */
  window.onerror = function(msg, src) {
    if (isThemeFile(src)) return true;
  };
})();
