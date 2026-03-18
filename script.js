function searchPapers() {
    const input = document.getElementById('search').value.toLowerCase();
    const papers = document.querySelectorAll('.paper-card');

    papers.forEach(paper => {
        const title = paper.querySelector('h3').textContent.toLowerCase();
        if (title.includes(input)) {
            paper.style.display = 'block';
        } else {
            paper.style.display = 'none';
        }
    });
}

function exportPDF() {
    window.print();
}
