from flask import Flask, render_template_string

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY PRO | FULL MULTI-STEP SYSTEM</title>
    <style>
        :root { --neon: #00d4ff; --bg: #03070f; --panel: #0a1324; }
        body { background: var(--bg); color: white; font-family: 'Inter', sans-serif; margin: 0; display: flex; height: 100vh; overflow: hidden; }
        .sidebar { width: 280px; background: var(--panel); border-right: 1px solid #1e2a44; overflow-y: auto; }
        .viewport { flex: 1; padding: 40px; overflow-y: auto; }
        .nav-btn { padding: 15px 25px; cursor: pointer; color: #888; border: none; background: none; width: 100%; text-align: left; transition: 0.3s; }
        .nav-btn:hover, .active-nav { color: var(--neon); background: rgba(0,212,255,0.1); }
        .card { background: var(--panel); border: 1px solid #1e2a44; padding: 25px; border-radius: 15px; margin-bottom: 20px; }
        .hidden { display: none; }
        .action-btn { background: var(--neon); color: black; padding: 12px 20px; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 10px; }
        video { width: 100%; border-radius: 10px; background: #000; border: 2px solid var(--neon); }
        .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-top: 15px; }
        .item { background: #050a14; border: 1px solid #1e2a44; padding: 15px; text-align: center; border-radius: 10px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2 style="padding:25px; color:var(--neon)">HILSEY PRO</h2>
        <button class="nav-btn" onclick="showMod('v-lecture')">📹 2. Lecture Hub</button>
        <button class="nav-btn" onclick="showMod('v-market')">🛒 6. Marketplace</button>
        <button class="nav-btn" onclick="showMod('v-money')">💰 7. Earnings Portal</button>
        <button class="nav-btn" onclick="showMod('v-writing')">📄 5. Writing Engine</button>
    </div>

    <div class="viewport">
        <div id="v-lecture" class="mod">
            <h1>Lecture Hub</h1>
            <div id="l-step-1" class="card">
                <h3>Step 1: Join Session</h3>
                <p>Verify your student ID to enter the video lecture room.</p>
                <button class="action-btn" onclick="startVideo()">START LIVE VIDEO CALL</button>
            </div>
            <div id="l-step-2" class="card hidden">
                <h3>Step 2: Live Feed</h3>
                <video id="webcam" autoplay playsinline></video>
                <button class="action-btn" style="background:#ff4444; color:white;" onclick="stopVideo()">END CALL</button>
            </div>
        </div>

        <div id="v-market" class="mod hidden">
            <h1>Stationery Marketplace</h1>
            <div id="m-step-1" class="card">
                <h3>Step 1: Select Category</h3>
                <div class="grid">
                    <div class="item" onclick="nextStep('m-step-1', 'm-step-2')">📓 Notebooks</div>
                    <div class="item" onclick="nextStep('m-step-1', 'm-step-2')">🖊 Pens</div>
                    <div class="item" onclick="nextStep('m-step-1', 'm-step-2')">📐 Math Sets</div>
                </div>
            </div>
            <div id="m-step-2" class="card hidden">
                <h3>Step 2: Choose Item</h3>
                <div class="grid">
                    <div class="item">Hardcover TSh 5,000</div>
                    <div class="item">Spiral TSh 3,500</div>
                </div>
                <button class="action-btn" onclick="nextStep('m-step-2', 'm-step-3')">CONTINUE TO CHECKOUT</button>
            </div>
            <div id="m-step-3" class="card hidden">
                <h3>Step 3: Final Payment</h3>
                <p>Location: Near TIA Main Gate</p>
                <button class="action-btn">CONFIRM ORDER</button>
            </div>
        </div>
        
        <div id="v-money" class="mod hidden"><h1>Earnings</h1><div class="card">Coming Soon...</div></div>
        <div id="v-writing" class="mod hidden"><h1>Writing Engine</h1><div class="card">Coming Soon...</div></div>
    </div>

    <script>
        function showMod(id) {
            document.querySelectorAll('.mod').forEach(m => m.classList.add('hidden'));
            document.getElementById(id).classList.remove('hidden');
        }
        function nextStep(curr, next) {
            document.getElementById(curr).classList.add('hidden');
            document.getElementById(next).classList.remove('hidden');
        }

        // VIDEO CALL LOGIC
        let stream;
        async function startVideo() {
            try {
                stream = await navigator.mediaDevices.getUserMedia({ video: true });
                document.getElementById('webcam').srcObject = stream;
                nextStep('l-step-1', 'l-step-2');
            } catch (err) {
                alert("Camera access denied or not found.");
            }
        }
        function stopVideo() {
            stream.getTracks().forEach(track => track.stop());
            nextStep('l-step-2', 'l-step-1');
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
