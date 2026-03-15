import os
from flask import Flask, render_template, request, jsonify
import google.generativeai as genai

app = Flask(__name__)

# 🔑 Your Gemini Key
genai.configure(api_key="AIzaSyA5RkM41g8DQP1FLs6cyb7S8Q7fVMTX4Ko")
model = genai.GenerativeModel('gemini-pro')

# --- ROUTES ---

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/hub')
def discussion_hub():
    # This is the new Video/Audio call room
    return render_template('hub.html')

@app.route('/database')
def student_data():
    # This is where students see their saved work
    return render_template('database.html')

@app.route('/generate', methods=['POST'])
def generate():
    try:
        data = request.json
        prompt = f"Professional help with: {data.get('message', '')}"
        response = model.generate_content(prompt)
        return jsonify({"success": True, "content": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
