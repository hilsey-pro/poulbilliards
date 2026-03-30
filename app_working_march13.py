from flask import Flask, render_template_string

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY PRO | COMMAND CENTER</title>
    <style>
        :root { --neon: #00d4ff; --bg: #03070f; --panel: #0a1324; }
        body { background: var(--bg); color: white; font-family: 'Inter', sans-serif; margin: 0; display: flex; height: 100vh; overflow: hidden; }
        
        /* Layout */
        .sidebar { width: 280px; background: var(--panel); border-right: 1px solid #1e2a44; }
        .viewport { flex: 1; padding: 30px; overflow-y: auto; display: flex; flex-direction: column; }
        
        /* Navigation */
        .nav-btn { padding: 15px 25px; cursor: pointer; color: #888; border: none; background: none; width: 100%; text-align: left; transition: 0.3s; }
        .nav-btn:hover { color: var(--neon); background: rgba(0,212,255,0.1); }
        
        /* Modules */
        .card { background: var(--panel); border: 1px solid #1e2a44; padding: 25px; border-radius: 15px; margin-bottom: 20px; }
        .hidden { display: none; }
        
        /* AI Engine Specifics */
        .engine-container { display: flex; gap: 20px; height: 75vh; }
        .ai-chat { flex: 1; background: #050a14; border: 1px solid #1e2a44; border-radius: 12px; display: flex; flex-direction: column; }
        .doc-preview { flex: 1.2; background: white; color: #333; border-radius: 12px; padding: 40px; overflow-y: auto; font-family: 'Times New Roman', serif; line-height: 1.6; }
        .input-area { padding: 15px; border-top: 1px solid #1e2a44; display: flex; gap: 10px; }
        input[type="text"] { flex: 1; padding: 12px; background: #03070f; border: 1px solid #1e2a44; color: white; border-radius: 5px; }
        .action-btn { background: var(--neon); color: black; padding: 10px 20px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; }
        
        /* Dashboard Widgets */
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .status-pill { background: #25d366; color: black; padding: 2px 10px; border-radius: 10px; font-size: 0.7rem; font-weight: bold; float: right; }
        video { width: 100%; border-radius: 10px; border: 2px solid var(--neon); background: #000; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2 style="padding:25px; color:var(--neon);">HILSEY PRO</h2>
        <button class="nav-btn" onclick="showMod('v-dash')">📊 1. Command Center</button>
        <button class="nav-btn" onclick="showMod('v-writing')">📄 5. AI Writing Engine</button>
        <button class="nav-btn" onclick="showMod('v-lecture')">📹 2. Lecture Hub</button>
        <button class="nav-btn" onclick="window.open('https://wa.me/?text=Check%20out%20Hilsey%20Pro!')">🟢 WhatsApp Share</button>
        <button class="nav-btn" onclick="window.print()" style="margin-top:20px; color:#aaa;">🖨️ Export to PDF</button>
    </div>

    <div class="viewport">
        <div id="v-dash" class="mod">
            <h1>Command Center</h1>
            <div class="grid-2">
                <div class="card">
                    <h3>System Time <span class="status-pill">SECURE</span></h3>
                    <div id="liveClock" style="font-size: 2.5rem; color: var(--neon); font-family: monospace;">00:00:00</div>
                    <div id="liveDate" style="color: #56657a; margin-top: 5px;">Friday, March 13, 2026</div>
                </div>
                <div class="card">
                    <h3>Focus Tasks</h3>
                    <label style="display:block; margin-bottom:10px;"><input type="checkbox"> Finalize TIA Project</label>
                    <label style="display:block; margin-bottom:10px;"><input type="checkbox"> Test AI Writing Engine</label>
                    <label style="display:block;"><input type="checkbox" checked> Deploy Dashboard V1</label>
                </div>
            </div>
            <div class="card">
                <h3>Developer Note</h3>
                <p>Welcome, William. All modules are running on a synchronized server. Use the sidebar to navigate between AI tools and Video services.</p>
            </div>
        </div>

        <div id="v-writing" class="mod hidden">
            <h1>AI Writing Engine</h1>
            <div class="engine-container">
                <div class="ai-chat">
                    <div id="chatHistory" style="padding:15px; flex:1; overflow-y:auto; font-size:0.9rem;">
                        <div style="color:var(--neon)">AI: William, I am ready. Type "Generate CV" or "Cover Letter".</div>
                    </div>
                    <div class="input-area">
                        <input type="text" id="aiInput" placeholder="Ask Meta-Style AI...">
                        <button class="action-btn" onclick="runAI()">SEND</button>
                    </div>
                </div>
                <div class="doc-preview" id="paper">
                    <div style="text-align:center; color:#ccc; margin-top:150px;">Previewing Document...</div>
                </div>
            </div>
        </div>

        <div id="v-lecture" class="mod hidden">
            <h1>Lecture Hub</h1>
            <div class="card">
                <video id="webcam" autoplay playsinline></video>
                <button class="action-btn" style="margin-top:15px;" onclick="startVideo()">ENABLE CAMERA</button>
            </div>
        </div>
    </div>

    <script>
        function showMod(id) {
            document.querySelectorAll('.mod').forEach(m => m.classList.add('hidden'));
            document.getElementById(id).classList.remove('hidden');
        }

        // Clock Logic
        function updateClock() {
            const now = new Date();
            document.getElementById('liveClock').innerText = now.toLocaleTimeString();
        }
        setInterval(updateClock, 1000);
        updateClock();

        // AI Writing Logic (The Vivid Answers)
        function runAI() {
            const val = document.getElementById('aiInput').value.toLowerCase();
            const paper = document.getElementById('paper');
            const chat = document.getElementById('chatHistory');
            
            chat.innerHTML += `<div style="text-align:right; margin:10px 0; color:#888;">${val}</div>`;

            if(val.includes("cv")) {
                paper.innerHTML = `<h1 style="text-align:center">WILLIAM HILSEY</h1><p style="text-align:center">Software Engineer | TIA Student</p><hr><h3>SUMMARY</h3><p>Highly skilled developer specializing in Python and AI automation. Created the Hilsey Pro ecosystem.</p><h3>SKILLS</h3><ul><li>Full-stack Development</li><li>AI Prompt Engineering</li><li>UI/UX Design</li></ul>`;
                chat.innerHTML += `<div style="color:var(--neon)">AI: CV Layout Generated.</div>`;
            } else if(val.includes("letter")) {
                paper.innerHTML = `<h3>COVER LETTER</h3><p>Dear Hiring Manager,</p><p>I am applying for the Developer position at your firm. With my background in building Super Apps at TIA...</p><p>Sincerely,<br>William Hilsey</p>`;
                chat.innerHTML += `<div style="color:var(--neon)">AI: Cover Letter Drafted.</div>`;
            } else {
                paper.innerHTML = `<h3>AI Response</h3><p>I am processing a vivid response for your query: "${val}". Please wait while I format the technical details...</p>`;
            }
            document.getElementById('aiInput').value = "";
            chat.scrollTop = chat.scrollHeight;
        }

        // Camera Logic
        async function startVideo() {
            const s = await navigator.mediaDevices.getUserMedia({video:true});
            document.getElementById('webcam').srcObject = s;
        }
    </script>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
