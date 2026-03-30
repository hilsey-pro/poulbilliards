from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return "<h1>HILSEY SERVER IS LIVE</h1><p>If you see this on your phone, the connection is working!</p>"

@app.route('/api/ai/copilot', methods=['POST'])
def ai_logic():
    data = request.json
    topic = data.get('topic', 'General')
    return jsonify({"content": f"AI CONTENT FOR: {topic}\n\nThis is a sample generated report for TIA students."})

@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    return jsonify({"message": "Order Received!"})

if __name__ == '__main__':
    # We hard-code the host here so you don't have to type it later
    app.run(host='0.0.0.0', port=5000)
