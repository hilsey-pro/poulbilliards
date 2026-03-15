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

# --- DATA STORAGE (Simple File-based for now) ---
DB_FILE = "database.json"

def save_to_db(username, content):
    data = {}
    if os.path.exists(DB_FILE):
        with open(DB_FILE, 'r') as f:
            data = json.load(f)
    
    if username not in data:
        data[username] = []
    
    # Add new entry
    data[username].append({
        "filename": f"Draft_{datetime.now().strftime('%Y%m%d_%H%M')}.txt",
        "date": datetime.now().strftime("%b %d, %Y"),
        "content": content
    })
    
    with open(DB_FILE, 'w') as f:
        json.dump(data, f)

# --- ROUTES ---

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if password == "1234": 
            session['user'] = username
            return redirect(url_for('index'))
        return "<h1>Invalid Pin!</h1>"
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect(url_for('login'))

@app.route('/')
def index():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('index.html', user=session['user'])

@app.route('/hub')
def discussion_hub():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('hub.html')

@app.route('/database')
def student_data():
    if 'user' not in session: return redirect(url_for('login'))
    return render_template('database.html')

@app.route('/save', methods=['POST'])
def save_draft():
    if 'user' not in session: return jsonify({"success": False})
    content = request.json.get('content')
    save_to_db(session['user'], content)
    return jsonify({"success": True})

@app.route('/get-docs')
def get_docs():
    if 'user' not in session: return jsonify([])
    if not os.path.exists(DB_FILE): return jsonify([])
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return jsonify(data.get(session['user'], []))

@app.route('/generate', methods=['POST'])
def generate():
    try:
        data = request.json
        response = model.generate_content(f"Professional help with: {data.get('message', '')}")
        return jsonify({"success": True, "content": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

@app.route('/lecturer-portal')
def lecturer():
    return render_template('lecturer.html') # We will create this next!

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
