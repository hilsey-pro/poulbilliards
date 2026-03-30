rom flask import Flask, render_template_string, request, jsonify
from openai import OpenAI
import os

app = Flask(__name__)

# =========================================================
# 🔑 PASTE YOUR OPENAI API KEY BETWEEN THE QUOTES BELOW:
# =========================================================
client = OpenAI(api_key="YOUR_API_KEY_HERE")
# =========================================================

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY PRO | NEURAL ENGINE</title>
    <style>
        :root { --neon:#00d4ff; --bg:#03070f; --panel:#0a1324; --text:#e0e6ed; }
        body{ background:var(--bg); color:var(--text); font-family:'Segoe UI', sans-serif; margin:0; display:flex; height:100vh; overflow:hidden; }
        .sidebar{ width:280px; background:var(--panel); border-right:1px solid #1e2a44; display:flex; flex-direction:column; }
        .nav-btn{ padding:18px 25px; cursor:pointer; color:#888; border:none; background:none; text-align:left; font-size: 14px; }
        .nav-btn:hover, .active{ color:var(--neon); background: rgba(0,212,255,0.05); border-left: 3px solid var(--neon); }
        .viewport{ flex:1; padding:35px; overflow-y:auto; }
        .engine-container{ display:flex; gap:25px; height:75vh; }
        .ai-chat{ flex:1; background:#050a14; border:1px solid #1e2a44; display:flex; flex-direction:column; border-radius: 12px; overflow: hidden; }
        .doc-preview{ flex:1.5; background:white; color:#1a1a1a; padding:50px; overflow:auto; border-radius: 8px; font-family: 'Times New Roman', serif; line-height: 1.6; }
        #chatHistory { flex:1; overflow-y:auto; padding:20px; display: flex; flex-direction: column; }
        .chat-bubble{ margin-bottom:12px; padding:15px; border-radius:12px; max-width:85%; font-size: 14px; }
        .ai-msg{ background:#0a2a40; color:#00d4ff; align-self: flex-start; }
        .user-msg{ background:#1e2a44; margin-left:auto; text-align:right; }
        .input-area { display:flex; border-top:1px solid #1e2a44; background: #0a1324; padding: 10px; }
        input{ flex:1; background:#03070f; color:white; border:1px solid #1e2a44; padding:12px; border-radius: 6px; }
        button{ background:#00d4ff; border:none; padding:12px 20px; font-weight:bold; cursor:pointer; border-radius: 6px; margin-left: 10px; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2 style="padding:25px;color:#00d4ff;">HILSEY PRO</h2>
    <button class="nav-btn active" onclick="showMod('v-dash')">📊 Command Center</button>
    <button class="nav-btn" onclick="showMod('v-writing')">🧠 AI Writing Engine</button>
    <button class="nav-btn" onclick="showMod('v-db')">🗂️ TIA Student DB</button>
    <div style="flex:1"></div>
    <button class="nav-btn" onclick="shareToWhatsApp()" style="color: #25d366;">📲 Share to Status</button>
</div>

<div class="viewport">
    <div id="v-dash" class="mod">
        <h1>Command Center</h1>
        <div style="background:var(--panel); padding:20px; border-radius:12px; border:1px solid #1e2a44;">
            <h2 id="clock" style="font-size: 3rem; margin: 0;"></h2>
            <p>Admin: William Hilsey | Status: Online</p>
        </div>
    </div>

    <div id="v-writing" class="mod" style="display:none">
        <h1>Neural Writing Engine</h1>
        <div class="engine-container">
            <div class="ai-chat">
                <div id="chatHistory">
                    <div class="chat-bubble ai-msg">AI: Ready. Ask me a question or for a research paper.</div>
                </div>
                <div class="input-area">
                    <input id="aiInput" placeholder="Enter prompt...">
                    <button onclick="processAI()">GENERATE</button>
                </div>
            </div>
            <div id="paper" class="doc-preview">Awaiting AI synthesis...</div>
        </div>
    </div>

    <div id="v-db" class="mod" style="display:none">
        <h1>TIA Database</h1>
        <p>Connected to Registrar Servers...</p>
    </div>
</div>

<script>
    function showMod(id){
        document.querySelectorAll('.mod').forEach(m=>m.style.display="none")
        document.getElementById(id).style.display="block"
    }

    async function processAI(){
        const inputField = document.getElementById("aiInput")
        const prompt = inputField.value
        if(!prompt) return;

        const chat = document.getElementById("chatHistory")
        const paper = document.getElementById("paper")

        chat.innerHTML += `<div class="chat-bubble user-msg">${prompt}</div>`
        inputField.value = ""
        
        const loadingId = "loading-" + Date.now()
        chat.innerHTML += `<div id="${loadingId}" class="chat-bubble ai-msg">AI: Thinking...</div>`
        chat.scrollTop = chat.scrollHeight

        try {
            const response = await fetch("/ai", {
                method: "POST",
                headers: {"Content-Type":"application/json"},
                body: JSON.stringify({prompt: prompt})
            })
            const data = await response.json()
            document.getElementById(loadingId).remove()

            chat.innerHTML += `<div class="chat-bubble ai-msg">AI: ${data.reply}</div>`
            paper.innerHTML = `<h2>Academic Report</h2><hr><p style="white-space: pre-wrap;">${data.reply}</p>`
        } catch (e) {
            document.getElementById(loadingId).innerText = "AI: Error connecting to server."
        }
        chat.scrollTop = chat.scrollHeight
    }

    function shareToWhatsApp(){
        const content = document.getElementById('paper').innerText
        window.open("https://wa.me/?text=" + encodeURIComponent(content.substring(0,800)))
    }

    setInterval(() => { document.getElementById('clock').innerText = new Date().toLocaleTimeString(); }, 1000)
</script>
</body>
</html>
"""

@app.route("/")
def home():
    return render_template_string(HTML)

@app.route("/ai", methods=["POST"])
def ai():
    try:
        data = request.json
        prompt = data.get("prompt")
        
        print(f"DEBUG: Processing prompt: {prompt}")

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are Hilsey Pro, a scholar AI for William Hilsey at TIA. Provide professional, detailed academic answers."},
                {"role": "user", "content": prompt}
            ]
        )
        reply = response.choices[0].message.content
        return jsonify({"reply": reply})

    except Exception as e:
        print(f"!!! AI ENGINE ERROR: {str(e)} !!!")
        return jsonify({"reply": f"Internal Error: {str(e)}"}), 500

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000)
