import os
import json
from datetime import datetime
from flask import Flask, render_template, request, jsonify, session, redirect, url_for

app = Flask(__name__)
app.secret_key = "hilsey_pro_secure_key_2026"

import google.generativeai as genai
genai.configure(api_key="AIzaSyA5RkM41g8DQP1FLs6cyb7S8Q7fVMTX4Ko")
model = genai.GenerativeModel('gemini-pro')

DB_FILE = "database.json"

def get_db_data():
    if os.path.exists(DB_FILE):
        with open(DB_FILE, 'r') as f:
            return json.load(f)
    return {"users": {}, "projects": []}

def save_db_data(data):
    with open(DB_FILE, 'w') as f:
        json.dump(data, f)

# --- ROUTES ---

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if username.lower() == "admin" and password == "9999":
            session['user'], session['role'] = "Lecturer", "admin"
            return redirect(url_for('dashboard'))
        elif password == "1234": 
            session['user'], session['role'] = username, "student"
            return redirect(url_for('dashboard'))
        return "<h1>Access Denied</h1>"
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/')
def index():
    if 'user' not in session: return redirect(url_for('login'))
    template_type = request.args.get('template', 'blank')
    return render_template('index.html', user=session['user'], template=template_type)

@app.route('/dashboard')
def dashboard():
    if 'user' not in session: return redirect(url_for('login'))
    data = get_db_data()
    user_data = data.get("users", {})
    user_docs = user_data.get(session['user'], [])
    stats = {
        "total_files": len(user_docs),
        "total_words": sum(d.get('words', 0) for d in user_docs)
    }
    return render_template('dashboard.html', user=session['user'], role=session.get('role'), stats=stats)

@app.route('/templates')
def templates_list():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('templates.html')

@app.route('/workspace')
def workspace():
    if 'user' not in session: return redirect(url_for('login'))
    data = get_db_data()
    return render_template('workspace.html', projects=data.get("projects", []))

# --- API HELPERS ---

@app.route('/save', methods=['POST'])
def save_draft():
    req_data = request.json
    db_data = get_db_data()
    username = session['user']
    if "users" not in db_data: db_data["users"] = {}
    if username not in db_data["users"]: db_data["users"][username] = []
    
    db_data["users"][username].append({
        "title": req_data.get('title') or "Untitled",
        "date": datetime.now().strftime("%b %d, %Y"),
        "content": req_data.get('content'),
        "words": len(req_data.get('content', '').split())
    })
    save_db_data(db_data)
    return jsonify({"success": True})

@app.route('/ai-assist', methods=['POST'])
def ai_assist():
    try:
        req_data = request.json
        mode, content = req_data.get("mode"), req_data.get("content")
        prompts = {
            "polish": f"Improve academic tone: {content}",
            "summarize": f"Summarize: {content}",
            "suggest": f"Suggest 3 research references for: {content}"
        }
        response = model.generate_content(prompts.get(mode, "Help: " + content))
        return jsonify({"success": True, "result": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
