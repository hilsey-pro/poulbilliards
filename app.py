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
            return json.load(f)
    return {}

def save_to_db(username, content, title):
    data = get_db_data()
    if username not in data:
        data[username] = []
    
    word_count = len(content.split())
    data[username].append({
        "title": title or "Untitled Draft",
        "filename": f"Draft_{datetime.now().strftime('%Y%m%d_%H%M')}.txt",
        "date": datetime.now().strftime("%b %d, %Y"),
        "content": content,
        "words": word_count
    })
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
    return render_template('index.html', user=session['user'])

@app.route('/dashboard')
def dashboard():
    if 'user' not in session: return redirect(url_for('login'))
    data = get_db_data()
    stats = {"total_files": 0, "total_words": 0}
    if session.get('role') == 'admin':
        for u in data:
            stats["total_files"] += len(data[u])
            stats["total_words"] += sum(d.get('words', 0) for d in data[u])
    else:
        user_docs = data.get(session['user'], [])
        stats["total_files"] = len(user_docs)
        stats["total_words"] = sum(d.get('words', 0) for d in user_docs)
    return render_template('dashboard.html', user=session['user'], role=session.get('role'), stats=stats)

@app.route('/save', methods=['POST'])
def save_draft():
    if 'user' not in session: return jsonify({"success": False})
    data = request.json
    save_to_db(session['user'], data.get('content'), data.get('title'))
    return jsonify({"success": True})

@app.route('/get-docs')
def get_docs():
    if 'user' not in session: return jsonify([])
    data = get_db_data()
    if session.get('role') == "admin":
        return jsonify([dict(d, student=u) for u, docs in data.items() for d in docs])
    return jsonify(data.get(session['user'], []))

@app.route('/ai-assist', methods=['POST'])
def ai_assist():
    """Context-aware AI Study Assistant"""
    try:
        data = request.json
        mode = data.get("mode") # 'polish', 'summarize', or 'suggest'
        content = data.get("content")
        
        prompts = {
            "polish": f"Improve the academic tone and grammar of this text while keeping its meaning: {content}",
            "summarize": f"Provide a brief academic summary of this draft: {content}",
            "suggest": f"Suggest 3 research references or topics to expand on based on this text: {content}"
        }
        
        response = model.generate_content(prompts.get(mode, "Help with: " + content))
        return jsonify({"success": True, "result": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
