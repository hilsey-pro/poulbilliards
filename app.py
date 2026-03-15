import os
import json
from datetime import datetime
from flask import Flask, render_template, request, jsonify, session, redirect, url_for

app = Flask(__name__)
app.secret_key = "hilsey_pro_secure_key_2026"

# 🔑 Google AI Configuration
import google.generativeai as genai
genai.configure(api_key="AIzaSyA5RkM41g8DQP1FLs6cyb7S8Q7fVMTX4Ko")
model = genai.GenerativeModel('gemini-pro')

DB_FILE = "database.json"

def get_db_data():
    if os.path.exists(DB_FILE):
        with open(DB_FILE, 'r') as f:
            try:
                data = json.load(f)
                # Ensure the structure exists
                if "users" not in data: data = {"users": data, "projects": [], "messages": []}
                if "projects" not in data: data["projects"] = []
                if "messages" not in data: data["messages"] = []
                return data
            except:
                return {"users": {}, "projects": [], "messages": []}
    return {"users": {}, "projects": [], "messages": []}

def save_db_data(data):
    with open(DB_FILE, 'w') as f:
        json.dump(data, f)

# --- AUTH ROUTES ---

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

# --- MAIN PAGE ROUTES ---

@app.route('/')
def index():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('index.html', user=session['user'])

@app.route('/dashboard')
def dashboard():
    if 'user' not in session: return redirect(url_for('login'))
    data = get_db_data()
    user_docs = data["users"].get(session['user'], [])
    stats = {
        "total_files": len(user_docs),
        "total_words": sum(d.get('words', 0) for d in user_docs)
    }
    return render_template('dashboard.html', user=session['user'], role=session.get('role'), stats=stats)

@app.route('/templates')
def templates_list():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('templates.html')

@app.route('/database')
def student_data():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('database.html')

@app.route('/hub')
def discussion_hub():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('hub.html', user=session['user'])

@app.route('/workspace')
def workspace():
    if 'user' not in session: return redirect(url_for('login'))
    data = get_db_data()
    return render_template('workspace.html', projects=data.get("projects", []))

# --- API & AI ENGINE ---

@app.route('/save', methods=['POST'])
def save_draft():
    if 'user' not in session: return jsonify({"success": False})
    req_data = request.json
    db_data = get_db_data()
    username = session['user']
    
    if username not in db_data["users"]: db_data["users"][username] = []
    
    db_data["users"][username].append({
        "title": req_data.get('title') or "Untitled Draft",
        "date": datetime.now().strftime("%b %d, %Y"),
        "content": req_data.get('content'),
        "words": len(str(req_data.get('content', '')).split())
    })
    save_db_data(db_data)
    return jsonify({"success": True})

@app.route('/get-docs')
def get_docs():
    if 'user' not in session: return jsonify([])
    data = get_db_data()
    if session.get('role') == "admin":
        return jsonify([dict(d, student=u) for u, docs in data["users"].items() for d in docs])
    return jsonify(data["users"].get(session['user'], []))

@app.route('/ai-assist', methods=['POST'])
def ai_assist():
    try:
        req_data = request.json
        mode, content = req_data.get("mode"), req_data.get("content")
        prompts = {
            "polish": f"Improve academic tone and grammar of this text: {content}",
            "summarize": f"Summarize this text: {content}",
            "suggest": f"Suggest 3 research references for: {content}"
        }
        response = model.generate_content(prompts.get(mode, "Help with: " + content))
        return jsonify({"success": True, "result": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# --- GROUP & HUB LOGIC ---

@app.route('/add-task', methods=['POST'])
def add_task():
    data = get_db_data()
    new_task = request.json.get('task')
    data["projects"].append({
        "task": new_task, 
        "user": session['user'], 
        "status": "Pending",
        "date": datetime.now().strftime("%H:%M")
    })
    save_db_data(data)
    return jsonify({"success": True})

@app.route('/get-messages')
def get_messages():
    data = get_db_data()
    return jsonify(data.get("messages", []))

@app.route('/send-message', methods=['POST'])
def send_message():
    data = get_db_data()
    msg = {
        "user": session.get('user', 'User'),
        "text": request.json.get('text'),
        "time": datetime.now().strftime("%H:%M")
    }
    data["messages"].append(msg)
    save_db_data(data)
    return jsonify({"success": True})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
