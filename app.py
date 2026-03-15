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

def save_to_db(username, content):
    data = get_db_data()
    if username not in data:
        data[username] = []
    
    # Calculate word count for stats
    word_count = len(content.split())
    
    data[username].append({
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
            session['user'] = "Lecturer"
            session['role'] = "admin"
            return redirect(url_for('dashboard'))
        elif password == "1234": 
            session['user'] = username
            session['role'] = "student"
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
    stats = {"total_files": 0, "total_words": 0, "recent_activity": []}
    
    if session.get('role') == 'admin':
        # Admin sees global stats
        for user in data:
            stats["total_files"] += len(data[user])
            for doc in data[user]:
                stats["total_words"] += doc.get('words', 0)
    else:
        # Student sees only their stats
        user_docs = data.get(session['user'], [])
        stats["total_files"] = len(user_docs)
        for doc in user_docs:
            stats["total_words"] += doc.get('words', 0)
            
    return render_template('dashboard.html', user=session['user'], role=session.get('role'), stats=stats)

@app.route('/save', methods=['POST'])
def save_draft():
    if 'user' not in session: return jsonify({"success": False})
    content = request.json.get('content')
    save_to_db(session['user'], content)
    return jsonify({"success": True})

@app.route('/get-docs')
def get_docs():
    if 'user' not in session: return jsonify([])
    data = get_db_data()
    if session.get('role') == "admin":
        all_docs = []
        for user, docs in data.items():
            for d in docs:
                d['student'] = user
                all_docs.append(d)
        return jsonify(all_docs)
    return jsonify(data.get(session['user'], []))

@app.route('/generate', methods=['POST'])
def generate():
    try:
        data = request.json
        response = model.generate_content(f"Academic help: {data.get('message', '')}")
        return jsonify({"success": True, "content": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
