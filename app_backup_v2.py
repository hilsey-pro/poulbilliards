from flask import Flask, render_template_string

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY PRO | AI ELITE</title>
    <style>
        :root { --neon: #00d4ff; --bg: #03070f; --panel: #0a1324; }
        body { background: var(--bg); color: white; font-family: sans-serif; margin: 0; display: flex; height: 100vh; overflow: hidden; }
        .sidebar { width: 260px; background: var(--panel); border-right: 1px solid #1e2a44; }
        .viewport { flex: 1; padding: 30px; overflow-y: auto; }
        .nav-btn { padding: 15px 25px; cursor: pointer; color: #888; border: none; background: none; width: 100%; text-align: left; }
        .nav-btn:hover { color: var(--neon); background: rgba(0,212,255,0.1); }
        .card { background: var(--panel); border: 1px solid #1e2a44; padding: 25px; border-radius: 15px; margin-bottom: 20px; }
        .hidden { display: none; }
        .engine-container { display: flex; gap: 20px; height: 80vh; }
        .ai-chat { flex: 1; background: #050a14; border: 1px solid #1e2a44; border-radius: 12px; display: flex; flex-direction: column; }
        .doc-preview { flex: 1.2; background: white; color: #333; border-radius: 12px; padding: 50px; overflow-y: auto; font-family: 'Times New Roman', serif; line-height: 1.6; }
        .input-area { padding: 15px; border-top: 1px solid #1e2a44; display: flex; gap: 10px; }
        input { flex: 1; padding: 12px; background: #03070f; border: 1px solid #1e2a44; color: white; border-radius: 5px; }
        .action-btn { background: var(--neon); color: black; padding: 10px 20px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; }
        video { width: 100%; border-radius: 10px; border: 2px solid var(--neon); }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2 style="padding:25px; color:var(--neon);">HILSEY PRO</h2>
        <button class="nav-btn" onclick="showMod('v-dash')">📊 Dashboard</button>
        <button class="nav-btn" onclick="showMod('v-writing')">📄 AI Writing Engine</button>
        <button class="nav-btn" onclick="showMod('v-lecture')">📹 Lecture Hub</button>
        <button class="nav-btn" onclick="window.print()">🖨️ Download PDF</button>
    </div>
    <div class="viewport">
        <div id="v-writing" class="mod">
            <h1>AI Writing Engine</h1>
            <div class="engine-container">
                <div class="ai-chat">
                    <div style="padding:15px; flex:1; overflow-y:auto;" id="chatHistory">
                        <div style="color:var(--neon)">AI: William, tell me what to write. (Try: "Write Cover Letter", "Generate CV", or "Project Report")</div>
                    </div>
                    <div class="input-area">
                        <input type="text" id="aiInput" placeholder="Ask Meta-Style AI...">
                        <button class="action-btn" onclick="runAI()">SEND</button>
                    </div>
                </div>
                <div class="doc-preview" id="paper">
                    <div style="text-align:center; color:#ccc; margin-top:150px;">Ready for your command...</div>
                </div>
            </div>
        </div>
        <div id="v-lecture" class="mod hidden">
            <h1>Lecture Hub</h1>
            <div class="card"><video id="webcam" autoplay playsinline></video><button class="action-btn" onclick="startVideo()">START VIDEO</button></div>
        </div>
        <div id="v-dash" class="mod hidden">
            <h1>Dashboard</h1>
            <div class="card"><h3>Systems Active.</h3><p>AI Engine V2.0 Loaded.</p></div>
        </div>
    </div>
    <script>
        function showMod(id) {
            document.querySelectorAll('.mod').forEach(m => m.classList.add('hidden'));
            document.getElementById(id).classList.remove('hidden');
        }

        function runAI() {
            const val = document.getElementById('aiInput').value.toLowerCase();
            const paper = document.getElementById('paper');
            const chat = document.getElementById('chatHistory');
            
            chat.innerHTML += `<div style="margin:10px 0; text-align:right;">${val}</div>`;

            if(val.includes("cv")) {
                paper.innerHTML = "<h1>WILLIAM HILSEY</h1><p style='text-align:center'>Software Engineer | TIA Student</p><hr><h3>SUMMARY</h3><p>Expert in Super App development and AI integration. Passionate about building educational tools for Tanzania.</p><h3>SKILLS</h3><ul><li>Python</li><li>Flask</li><li>UI/UX</li></ul>";
            } 
            else if(val.includes("letter")) {
                paper.innerHTML = "<h3>COVER LETTER</h3><br><p>To Whom It May Concern,</p><p>I am writing to express my strong interest in the Software Developer position. With a solid foundation in Python and a proven track record of building complex, multi-module applications like Hilsey Pro, I am confident in my ability to contribute to your team.</p><p>My experience at TIA has equipped me with both technical skills and the discipline required for high-stakes projects. I look forward to discussing how my background in AI automation can benefit your organization.</p><br><p>Sincerely,<br>William Hilsey</p>";
            }
            else if(val.includes("report")) {
                paper.innerHTML = "<h2 style='text-align:center'>PROJECT REPORT: AI ECOSYSTEM</h2><br><h4>1. INTRODUCTION</h4><p>This report details the architectural design of the Hilsey Pro Super App. The primary objective was to create a unified platform for students at TIA.</p><h4>2. METHODOLOGY</h4><p>Using the Flask framework, we integrated multiple modules including real-time video communication and an AI-driven writing engine. The UI follows modern dark-mode standards to ensure user focus and productivity.</p><h4>3. CONCLUSION</h4><p>The project successfully demonstrates the power of integrated web systems in modern education.</p>";
            }
            else {
                paper.innerHTML = "<h3>AI Search Result</h3><p>I have analyzed your request. Based on current data, the best approach for " + val + " is to utilize professional formatting and clear technical language. (More content would appear here based on your specific prompt).</p>";
            }
            chat.innerHTML += `<div style="color:var(--neon); margin-bottom:10px;">AI: Document generated with professional formatting.</div>`;
            document.getElementById('aiInput').value = "";
            chat.scrollTop = chat.scrollHeight;
        }

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
