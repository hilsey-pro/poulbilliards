import os
from flask import Flask, render_template, request, jsonify
import google.generativeai as genai

app = Flask(__name__)

# 🔑 Google AI Configuration
# Make sure your API key is correct and inside the quotes
genai.configure(api_key="AIzaSyA5RkM41g8DQP1FLs6cyb7S8Q7fVMTX4Ko")
model = genai.GenerativeModel('gemini-pro')

# --- ROUTES ---

@app.route('/')
def index():
    # This is the main Assignment Pad / Notepad
    return render_template('index.html')

@app.route('/hub')
def discussion_hub():
    # This is the Video/Audio call room for students
    return render_template('hub.html')

@app.route('/database')
def student_data():
    # This is the Student Cloud Storage page
    return render_template('database.html')

@app.route('/generate', methods=['POST'])
def generate():
    """This handles the AI writing help"""
    try:
        data = request.json
        user_input = data.get("message", "")
        
        # Telling the AI to be a professional academic assistant
        prompt = f"Professional help with: {user_input}"
        response = model.generate_content(prompt)
        
        return jsonify({"success": True, "content": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# --- NEW: LECTURER PORTAL (Secret Route) ---
@app.route('/lecturer-portal')
def lecturer():
    # This is the secret dashboard for the teacher to monitor the Hub
    return """
    <div style="font-family:sans-serif; padding:40px; background:#0f172a; color:white; min-height:100vh;">
        <h1 style="color:#818cf8;">👨‍🏫 Lecturer Dashboard</h1>
        <hr style="border-color:#334155;">
        <div style="background:#1e293b; padding:20px; border-radius:10px; margin-top:20px; border: 1px solid #4f46e5;">
            <h3 style="margin-top:0;">Live Discussion Status</h3>
            <p>🟢 Status: <strong>Active</strong></p>
            <p>📍 Room: <strong>HilseyPro_Academic_Room_2024</strong></p>
            <p>👥 Active Students: 4</p>
            <button onclick="location.href='/hub'" style="background:#4f46e5; color:white; border:none; padding:12px 24px; border-radius:5px; cursor:pointer; font-weight:bold;">
                Join Room to Listen
            </button>
        </div>
        <div style="margin-top:30px; font-size:0.8em; color:#64748b;">
            <p>Note: This is a private portal. Do not share this URL with students.</p>
        </div>
    </div>
    """

# --- START THE SERVER ---
if __name__ == "__main__":
    # Render uses the PORT environment variable
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
