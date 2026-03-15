import os
from flask import Flask, render_template, request, jsonify, session, redirect, url_for
import google.generativeai as genai

app = Flask(__name__)

# 🔐 Security Key for Login Sessions
app.secret_key = "hilsey_pro_secure_key_2026"

# 🔑 Google AI Configuration
genai.configure(api_key="AIzaSyA5RkM41g8DQP1FLs6cyb7S8Q7fVMTX4Ko")
model = genai.GenerativeModel('gemini-pro')

# --- AUTHENTICATION CHECK ---
# This helper ensures students are logged in before seeing pages
def is_logged_in():
    return 'user' in session

# --- ROUTES ---

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        # Simple Access Pin Check (You can change "1234" to any pin you like)
        if password == "1234": 
            session['user'] = username
            return redirect(url_for('index'))
        else:
            return "<h1>Invalid Pin!</h1><p>Please go back and try again.</p>"
            
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect(url_for('login'))

@app.route('/')
def index():
    if not is_logged_in():
        return redirect(url_for('login'))
    return render_template('index.html', user=session['user'])

@app.route('/hub')
def discussion_hub():
    if not is_logged_in():
        return redirect(url_for('login'))
    return render_template('hub.html')

@app.route('/database')
def student_data():
    if not is_logged_in():
        return redirect(url_for('login'))
    return render_template('database.html')

@app.route('/generate', methods=['POST'])
def generate():
    if not is_logged_in():
        return jsonify({"success": False, "error": "Not logged in"})
    try:
        data = request.json
        user_input = data.get("message", "")
        prompt = f"Professional help with: {user_input}"
        response = model.generate_content(prompt)
        return jsonify({"success": True, "content": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# --- LECTURER PORTAL (Secret Route) ---
@app.route('/lecturer-portal')
def lecturer():
    # Only allow access if the lecturer is logged in (optional)
    return """
    <div style="font-family:sans-serif; padding:40px; background:#0f172a; color:white; min-height:100vh;">
        <h1 style="color:#818cf8;">👨‍🏫 Lecturer Dashboard</h1>
        <hr style="border-color:#334155;">
        <div style="background:#1e293b; padding:20px; border-radius:10px; margin-top:20px; border: 1px solid #4f46e5;">
            <h3 style="margin-top:0;">Live Discussion Status</h3>
            <p>🟢 Status: <strong>Active</strong></p>
            <p>📍 Room: <strong>HilseyPro_Academic_Room_2024</strong></p>
            <p>👥 Active Students: Connected</p>
            <button onclick="location.href='/hub'" style="background:#4f46e5; color:white; border:none; padding:12px 24px; border-radius:5px; cursor:pointer; font-weight:bold;">
                Join Room to Listen
            </button>
        </div>
        <div style="margin-top:30px; font-size:0.8em; color:#64748b;">
            <p>Note: This is a private portal for administrative use.</p>
            <a href="/logout" style="color:#ef4444;">Click here to Logout</a>
        </div>
    </div>
    """

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
