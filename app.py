import os
from flask import Flask, render_template, request, jsonify
import google.generativeai as genai

app = Flask(__name__)

# 🔑 Here is the fix! Notice the quotation marks (" ") around your key.
genai.configure(api_key="AIzaSyA5RkM41g8DQP1FLs6cyb7S8Q7fVMTX4Ko")
model = genai.GenerativeModel('gemini-pro')

@app.route('/')
def index():
    # This loads your new PDF Notepad layout
    return render_template('index.html')

@app.route('/generate', methods=['POST'])
def generate():
    try:
        data = request.json
        doc_type = data.get("type", "Document")
        user_input = data.get("message", "")

        # This tells the AI what to do
        prompt = f"You are Hilsey Pro. Create a professional {doc_type} based on: {user_input}"
        response = model.generate_content(prompt)
        
        return jsonify({"success": True, "content": response.text})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
