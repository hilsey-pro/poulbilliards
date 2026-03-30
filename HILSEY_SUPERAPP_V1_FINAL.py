from flask import Flask, render_template_string

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY PRO | SUPER APP</title>
    <style>
        :root { --neon: #00d4ff; --bg: #03070f; --panel: #0a1324; }
        body { background: var(--bg); color: white; font-family: sans-serif; margin: 0; display: flex; height: 100vh; overflow: hidden; }
        .sidebar { width: 280px; background: var(--panel); border-right: 1px solid #1e2a44; overflow-y: auto; }
        .viewport { flex: 1; padding: 40px; overflow-y: auto; }
        .nav-btn { padding: 15px 25px; cursor: pointer; color: #888; border: none; background: none; width: 100%; text-align: left; transition: 0.3s; font-size: 0.85rem; }
        .nav-btn:hover { color: var(--neon); background: rgba(0,212,255,0.1); }
        .card { background: var(--panel); border: 1px solid #1e2a44; padding: 25px; border-radius: 15px; margin-bottom: 20px; }
        .hidden { display: none; }
        .step-hidden { display: none; }
        .action-btn { background: var(--neon); color: black; padding: 10px 20px; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 15px; }
        video { width: 100%; border-radius: 10px; background: #000; border: 2px solid var(--neon); }
        .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-top: 10px; }
        .item-box { background: #050a14; border: 1px solid #1e2a44; padding: 15px; text-align: center; border-radius: 10px; cursor: pointer; font-size: 0.8rem; }
        .item-box:hover { border-color: var(--neon); }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2 style="padding:20px; color:var(--neon); border-bottom:1px solid #1e2a44;">HILSEY PRO</h2>
        <button class="nav-btn" onclick="showMod('v-dash')">📊 1. Course Overview</button>
        <button class="nav-btn" onclick="showMod('v-lecture')">📹 2. Lecture Hub</button>
        <button class="nav-btn" onclick="showMod('v-tools')">📓 3. Digital Stationery</button>
        <button class="nav-btn" onclick="showMod('v-group')">👥 4. Group Collaboration</button>
        <button class="nav-btn" onclick="showMod('v-writing')">📄 5. Writing Engine</button>
        <button class="nav-btn" onclick="showMod('v-market')">🛒 6. Marketplace</button>
        <button class="nav-btn" onclick="showMod('v-money')">💰 7. Earnings Portal</button>
        <button class="nav-btn" onclick="showMod('v-library')">📚 8. Resources Library</button>
        <button class="nav-btn" onclick="showMod('v-prod')">⏱ 9. Productivity Tools</button>
        <button class="nav-btn" onclick="showMod('v-profile')">🏆 10. Profile Tracker</button>
        <button class="nav-btn" onclick="showMod('v-notif')">🔔 11. Notifications</button>
        <button class="nav-btn" onclick="showMod('v-admin')">👨‍💼 12. Admin Control</button>
    </div>

    <div class="viewport">
        <div id="v-lecture" class="mod hidden">
            <h1>Lecture Hub</h1>
            <div id="l-s1" class="card">
                <h3>Step 1: Join Session</h3>
                <div class="grid">
                    <div class="item-box" onclick="nextStep('l-s1', 'l-s2')">Live Video Class</div>
                    <div class="item-box">Audio Room</div>
                    <div class="item-box">Recordings</div>
                </div>
            </div>
            <div id="l-s2" class="card step-hidden">
                <h3>Step 2: Video Feed</h3>
                <video id="webcam" autoplay playsinline></video>
                <button class="action-btn" onclick="startVideo()">ENABLE CAMERA</button>
                <button class="action-btn" style="background:#ff4444; color:white;" onclick="stopVideo()">END CALL</button>
            </div>
        </div>

        <div id="v-writing" class="mod hidden">
            <h1>Writing & CV Engine</h1>
            <div id="w-s1" class="card">
                <h3>Step 1: Document Type</h3>
                <div class="grid">
                    <div class="item-box" onclick="nextStep('w-s1', 'w-s2')">Professional CV</div>
                    <div class="item-box" onclick="nextStep('w-s1', 'w-s2')">Research Proposal</div>
                </div>
            </div>
            <div id="w-s2" class="card step-hidden">
                <h3>Step 2: Template Selection</h3>
                <div class="grid">
                    <div class="item-box" onclick="nextStep('w-s2', 'w-s3')">Modern Neon</div>
                    <div class="item-box" onclick="nextStep('w-s2', 'w-s3')">Classic TIA</div>
                </div>
            </div>
            <div id="w-s3" class="card step-hidden">
                <h3>Step 3: Editor</h3>
                <textarea style="width:100%; height:150px; background:#050a14; color:white; border:1px solid #1e2a44;"></textarea>
                <button class="action-btn">GENERATE PDF</button>
            </div>
        </div>

        <div id="v-dash" class="mod">
            <h1>Dashboard</h1>
            <div class="card"><h3>Welcome to the 12-Module System</h3><p>Select a tool from the sidebar to begin the step-by-step process.</p></div>
        </div>

        <div id="v-market" class="mod hidden">
            <h1>Marketplace</h1>
            <div id="m-s1" class="card">
                <h3>Step 1: Category</h3>
                <div class="grid">
                    <div class="item-box" onclick="nextStep('m-s1', 'm-s2')">Stationery</div>
                    <div class="item-box" onclick="nextStep('m-s1', 'm-s2')">Printing</div>
                </div>
            </div>
            <div id="m-s2" class="card step-hidden">
                <h3>Step 2: Nearby Shops</h3>
                <div class="item-box">Main Gate Shop - 200m</div>
                <button class="action-btn">CONTINUE</button>
            </div>
        </div>

        <div id="v-money" class="mod hidden"><h1>Earnings</h1><div class="card">Step-by-step monetization active.</div></div>
        <div id="v-admin" class="mod hidden"><h1>Admin Panel</h1><div class="card">System Management Console.</div></div>
    </div>

    <script>
        function showMod(id) {
            document.querySelectorAll('.mod').forEach(m => m.classList.add('hidden'));
            document.getElementById(id).classList.remove('hidden');
        }
        function nextStep(curr, next) {
            document.getElementById(curr).classList.add('step-hidden');
            document.getElementById(next).classList.remove('step-hidden');
        }
        let stream;
        async function startVideo() {
            try { stream = await navigator.mediaDevices.getUserMedia({ video: true }); document.getElementById('webcam').srcObject = stream; } 
            catch (err) { alert("Camera Error"); }
        }
        function stopVideo() {
            if(stream) stream.getTracks().forEach(t => t.stop());
            nextStep('l-s2', 'l-s1');
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
