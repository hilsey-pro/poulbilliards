function login() {
    const r = document.getElementById('reg').value.toUpperCase();
    const p = document.getElementById('pass').value.toUpperCase();
    if (p === "DEVELOPER2021" || p === "DEVELOPER2022") {
        localStorage.setItem('role', 'staff');
        window.location.href = "lecture.html";
    }
    else if (r === p && r !== "") {
        localStorage.setItem('role', 'student');
        localStorage.setItem('userReg', r);
        window.location.href = "dashboard.html";
    }
    else {
        alert("Invalid Credentials!");
    }
}

function searchPapers() {
    let input = document.getElementById('search').value.toLowerCase();
    let cards = document.getElementsByClassName('paper-card');

    for (let i = 0; i < cards.length; i++) {
        let title = cards[i].getElementsByTagName('h3')[0].innerText.toLowerCase();
        if (title.includes(input)) {
            cards[i].style.display = "";
        } else {
            cards[i].style.display = "none";
        }
    }
}

function exportPDF() {
    let content = document.getElementById('editor').value;
    if (content.trim() === "") {
        alert("Editor is empty!");
        return;
    }
    alert("Exporting assignment to PDF... (Simulation)");
    // In a real app, we might use jsPDF here.
}
