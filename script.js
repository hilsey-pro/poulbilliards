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
function buyItem(itemName, price) {
  alert(`Purchased ${itemName} for Tsh ${price}`);
}

function searchPapers() {
  let input = document.getElementById("search").value.toLowerCase();
  let cards = document.querySelectorAll(".paper-card");

  cards.forEach(card => {
    let text = card.innerText.toLowerCase();
    card.style.display = text.includes(input) ? "block" : "none";
  });
}

function exportPDF() {
  alert("Export to PDF feature coming soon (needs backend library)");
}
