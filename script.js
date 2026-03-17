<!DOCTYPE html>
<html>
<head>
  <title>Hilsey Hub - Gateway</title>
  <style>
    body {
      font-family: Arial;
      background: #0f172a;
      color: white;
      text-align: center;
      margin: 0;
      padding: 0;
    }

    .login-box {
      margin-top: 100px;
      background: #1e293b;
      display: inline-block;
      padding: 30px;
      border-radius: 10px;
    }

    input {
      display: block;
      margin: 15px auto;
      padding: 10px;
      width: 250px;
      border-radius: 5px;
      border: none;
    }

    button {
      padding: 10px 20px;
      margin: 10px;
      background: #22c55e;
      border: none;
      cursor: pointer;
      color: white;
      border-radius: 5px;
    }

    #error {
      color: #ff5555;
      margin-top: 10px;
    }

    h1 {
      margin-bottom: 20px;
    }
  </style>
</head>
<body>

<div class="login-box">
  <h1>Hilsey Secure Gateway</h1>

  <input type="text" id="reg" placeholder="Registration Number (DSM/...)">
  <input type="password" id="pass" placeholder="Password">

  <button onclick="login()">Enter</button>

  <p id="error"></p>
</div>

<script>
function login() {
  let reg = document.getElementById("reg").value;
  let pass = document.getElementById("pass").value;

  // Temporary master password for you
  if (reg === "DSM/BAC25" && pass === "hilsey123") {
    window.location.href = "dashboard.html";
  } else {
    document.getElementById("error").innerText = "Invalid login";
  }
}
</script>

</body>
</html>
