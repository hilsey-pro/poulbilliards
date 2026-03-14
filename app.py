from flask import Flask, render_template_string, request, jsonify

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY PRO | MASTER SYSTEM</title>
    <style>
        :root { --neon:#00d4ff; --bg:#02060e; --panel:#0a1324; --text:#e0e6ed; --money:#25d366; }
        body { background:var(--bg); color:var(--text); font-family:sans-serif; margin:0; display:flex; height:100vh; overflow:hidden; }
        .sidebar { width:240px; background:var(--panel); border-right:1px solid #1e2a44; padding:20px; display:flex; flex-direction:column; }
        .nav-item { padding:12px; margin:5px 0; border-radius:8px; cursor:pointer; color:#8899a6; transition:0.3s; font-size:14px; }
        .active { background:rgba(0,212,255,0.1); color:var(--neon); border-left:4px solid var(--neon); }
        .main { flex:1; padding:25px; overflow-y:auto; }
        .card { background:var(--panel); padding:20px; border-radius:12px; border:1px solid #1e2a44; margin-bottom:20px; }
        .engine-split { display:flex; gap:20px; height:60vh; }
        .chat-area { flex:1; background:#050a14; border:1px solid #1e2a44; border-radius:10px; display:flex; flex-direction:column; }
        #chatBox { flex:1; overflow-y:auto; padding:15px; display:flex; flex-direction:column; gap:10px; }
        .paper-view { flex:1; background:white; color:#111; padding:35px; border-radius:10px; overflow-y:auto; font-family:serif; line-height:1.6; box-shadow:0 0 15px rgba(0,0,0,0.5); }
        input { background:#02060e; border:1px solid #1e2a44; color:white; padding:10px; border-radius:5px; margin-bottom:10px; width:100%; box-sizing:border-box; }
        .btn { background:var(--neon); border:none; padding:10px 15px; font-weight:bold; cursor:pointer; border-radius:5px; color:#02060e; }
        table { width:100%; border-collapse:collapse; }
        th, td { text-align:left; padding:12px; border-bottom:1px solid #1e2a44; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2 style="color:var(--neon)">HILSEY PRO</h2>
        <div class="nav-item active" onclick="show('dash')">📊 Dashboard</div>
        <div class="nav-item" onclick="show('writing')">🧠 AI Engine</div>
        <div class="nav-item" onclick="show('lectures')">📚 Lecture Hub</div>
        <div class="nav-item" onclick="show('db')">📁 Student DB</div>
    </div>
    <div class="main">
        <div id="dash" class="page">
            <h1>Command Center</h1>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px;">
                <div class="card"><h3>Revenue Tracker</h3><p style="color:var(--money); font-size:22px;">$420.00</p></div>
                <div class="card"><h3>Video Call</h3><button class="btn" onclick="window.open('https://meet.google.com/new')">Start Google Meet</button></div>
            </div>
        </div>
        <div id="writing" class="page" style="display:none">
            <h1>AI Writing Engine</h1>
            <div class="engine-split">
                <div class="chat-area">
                    <div id="chatBox"><div style="color:var(--neon)">Ready for TIA Report generation (Simulation Mode)...</div></div>
                    <div style="display:flex; padding:10px; border-top:1px solid #1e2a44;">
                        <input id="userInput" style="margin-bottom:0;" placeholder="Describe the report...">
                        <button class="btn" style="margin-left:10px;" onclick="runSimAI()">DRAFT</button>
                    </div>
                </div>
                <div class="paper-view" id="paper">Preview...</div>
            </div>
            <button class="btn" style="background:var(--money); margin-top:10px;" onclick="share()">📲 SHARE TO WHATSAPP</button>
        </div>
        <div id="lectures" class="page" style="display:none">
            <h1>Lecture Hub</h1>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                <div class="card"><h4>Accounting 1</h4><button class="btn">View Notes</button></div>
                <div class="card"><h4>Business Law</h4><button class="btn">View Notes</button></div>
            </div>
        </div>
        <div id="db" class="page" style="display:none">
            <h1>Student Database</h1>
            <div class="card">
                <h3>Register Student</h3>
                <div style="display:flex; gap:10px;">
                    <input id="sName" placeholder="Full Name">
                    <input id="sID" placeholder="TIA ID">
                    <button class="btn" onclick="addStudent()">ADD</button>
                </div>
            </div>
            <div class="card">
                <table id="studentTable">
                    <tr><th>Name</th><th>ID</th><th>Status</th></tr>
                    <tr><td>William Hilsey</td><td>TIA-2026-MASTER</td><td style="color:var(--money)">Paid</td></tr>
                </table>
            </div>
        </div>
    </div>
    <script>
        function show(id) {
            document.querySelectorAll('.page').forEach(p => p.style.display = 'none');
            document.getElementById(id).style.display = 'block';
            document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
            event.currentTarget.classList.add('active');
        }
        function addStudent() {
            const name = document.getElementById('sName').value;
            const id = document.getElementById('sID').value;
            if(!name || !id) return alert("Enter details!");
            const table = document.getElementById('studentTable');
            table.innerHTML += `<tr><td>${name}</td><td>${id}</td><td>Pending</td></tr>`;
            document.getElementById('sName').value = '';
            document.getElementById('sID').value = '';
        }
        function runSimAI() {
            const input = document.getElementById('userInput');
            const paper = document.getElementById('paper');
            if(!input.value) return;
            paper.innerHTML = `<h2 style="text-align:center">TANZANIA INSTITUTE OF ACCOUNTANCY</h2><h4 style="text-align:center">OFFICIAL ACADEMIC DRAFT</h4><hr><p><b>Subject:</b> ${input.value}</p><p>This is a structured draft for your TIA assignment. You can edit this text or share it directly to your WhatsApp status for classmates to see.</p>`;
            input.value = '';
        }
        function share() {
            const content = document.getElementById('paper').innerText;
            window.open(`https://wa.me/?text=${encodeURIComponent(content)}`, '_blank');
        }
    </script>
</body>
</html>
"""

@app.route("/")
def home(): return render_template_string(HTML)

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000)
