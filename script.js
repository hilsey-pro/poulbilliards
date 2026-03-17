function login() {
  let reg = document.getElementById("reg").value;
  let pass = document.getElementById("pass").value;

  if (reg === "DSM/123" && pass === "1234") {
    window.location.href = "dashboard.html";
  } else {
    document.getElementById("error").innerText = "Invalid login";
  }
}

function goTo(section) {
  alert(section + " page coming next");
}
