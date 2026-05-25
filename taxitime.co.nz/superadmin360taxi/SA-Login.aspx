<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>Admin Login &mdash; BookaWaka Admin</title>
<link rel="icon" href="assets/img/bw-logo.png"/>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.24.0/firebase-auth.js"></script>
<script>
firebase.initializeApp({apiKey:"AIzaSyBhcA7J8ZefAwlzhuYUNDIf_W3Yzy_16gA",authDomain:"taxilatest.firebaseapp.com",databaseURL:"https://taxilatest.firebaseio.com",projectId:"taxilatest",storageBucket:"taxilatest.appspot.com"});
</script>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{min-height:100vh;background:#0F172A;display:flex;align-items:center;justify-content:center;font-family:'Inter',system-ui,sans-serif;background-image:radial-gradient(ellipse at 20% 50%,rgba(37,99,235,.15) 0%,transparent 60%),radial-gradient(ellipse at 80% 20%,rgba(37,99,235,.08) 0%,transparent 50%)}
.box{background:#fff;border-radius:16px;padding:44px 40px;width:100%;max-width:420px;box-shadow:0 20px 60px rgba(0,0,0,.4)}
.logo{text-align:center;margin-bottom:32px}
.logo img{width:64px;height:64px;border-radius:14px;object-fit:cover;box-shadow:0 4px 12px rgba(0,0,0,.15)}
.logo h1{font-size:22px;font-weight:800;color:#0F172A;margin-top:14px;letter-spacing:-.02em}
.logo p{font-size:13px;color:#64748B;margin-top:5px;font-weight:500}
.divider{height:1px;background:#F1F5F9;margin-bottom:24px}
.field{margin-bottom:16px}
.field label{display:block;font-size:12px;font-weight:600;color:#374151;margin-bottom:6px;text-transform:uppercase;letter-spacing:.05em}
.field input{width:100%;padding:11px 14px;border:1.5px solid #E2E8F0;border-radius:10px;font-size:14px;font-family:'Inter',system-ui,sans-serif;transition:.15s;color:#0F172A;background:#F8FAFC}
.field input:focus{outline:none;border-color:#2563EB;background:#fff;box-shadow:0 0 0 3px rgba(37,99,235,.1)}
.btn{width:100%;padding:13px;background:#2563EB;color:#fff;border:none;border-radius:10px;font-size:15px;font-weight:700;cursor:pointer;margin-top:6px;transition:.15s;font-family:'Inter',system-ui,sans-serif;letter-spacing:-.01em}
.btn:hover{background:#1D4ED8;box-shadow:0 4px 12px rgba(37,99,235,.35)}
.btn:disabled{background:#94A3B8;cursor:not-allowed;box-shadow:none}
.err{background:#FEF2F2;border:1px solid #FECACA;border-left:4px solid #DC2626;padding:10px 14px;border-radius:8px;font-size:13px;color:#991B1B;margin-bottom:16px;display:none}
.note{font-size:12px;color:#94A3B8;text-align:center;margin-top:22px;line-height:1.7}
</style>
</head>
<body>
<div class="box">
  <div class="logo">
    <img src="assets/img/bw-logo.png" alt="BookaWaka"/>
    <h1>BookaWaka</h1>
    <p>Sign in to manage your platform</p>
  </div>
  <div class="divider"></div>
  <div class="err" id="err"></div>
  <div class="field">
    <label>Email address</label>
    <input type="email" id="email" placeholder="admin@bookawaka.co.nz" autocomplete="email"/>
  </div>
  <div class="field">
    <label>Password</label>
    <input type="password" id="pwd" placeholder="&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;" autocomplete="current-password"/>
  </div>
  <button class="btn" id="btn" onclick="doLogin()">Sign In</button>
  <p class="note">Access is restricted to authorised BookaWaka administrators.<br>Contact your system administrator if you need access.</p>
</div>
<script>
// If already signed in, go straight to Home
firebase.auth().onAuthStateChanged(function(user){
  if(user) window.location.href = 'Home.aspx';
});

document.getElementById('pwd').addEventListener('keydown', function(e){
  if(e.key==='Enter') doLogin();
});
document.getElementById('email').addEventListener('keydown', function(e){
  if(e.key==='Enter') document.getElementById('pwd').focus();
});

function doLogin(){
  var email = document.getElementById('email').value.trim();
  var pwd = document.getElementById('pwd').value;
  var btn = document.getElementById('btn');
  var err = document.getElementById('err');
  err.style.display = 'none';
  if(!email || !pwd){ showErr('Please enter your email and password.'); return; }
  btn.disabled = true; btn.textContent = 'Signing in\u2026';
  firebase.auth().signInWithEmailAndPassword(email, pwd)
    .then(function(){
      window.location.href = 'Home.aspx';
    })
    .catch(function(e){
      btn.disabled = false; btn.textContent = 'Sign In';
      var msg = 'Sign-in failed. Check your email and password.';
      if(e.code==='auth/user-not-found') msg = 'No admin account found for that email.';
      else if(e.code==='auth/wrong-password') msg = 'Incorrect password. Please try again.';
      else if(e.code==='auth/too-many-requests') msg = 'Too many failed attempts. Try again later.';
      else if(e.code==='auth/invalid-email') msg = 'Please enter a valid email address.';
      showErr(msg);
    });
}
function showErr(m){ var e=document.getElementById('err'); e.textContent=m; e.style.display='block'; }
</script>
</body>
</html>
