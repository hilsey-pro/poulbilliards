import os
from flask import Flask, render_template, request, jsonify
import google.generativeai as genai

app = Flask(__name__)

# I have inserted your key below!
genai.configure(api_key="DOAQ5Q5SR6S62Q3ACWPZE7Z6NTH3ZMLF")

SYSTEM_PROMPT = """
You are Hilsey Pro AI, a premium business and academic assistant.
Your goal is to help users generate:
1. Professional CVs (Modern, Tech, Creative, Executive, etc.)
2. Detailed Business Proposals
3. Field Reports and Cover Letters
Always provide structured, high-quality templates.
"""

model = genai.GenerativeModel('gemini-pro')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    try:
        user_data = request.json.get("message")
        full_query = f"{SYSTEM_PROMPT}\n\nUser: {user_data}"
        response = model.generate_content(full_query)
        return jsonify({"response": response.text})
    except Exception as e:
        return jsonify({"response": f"Error: {str(e)}"})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
