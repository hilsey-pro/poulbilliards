            </div>
            <pre id="output" class="text-slate-300 font-mono text-xs whitespace-pre-wrap"></pre>
        </div>
    </div>

    <div id="payM" class="hidden fixed inset-0 bg-black/95 flex items-center justify-center p-4">
        <div class="bg-white text-black p-8 rounded-3xl max-w-sm w-full text-center border-4 border-yellow-500">
            <h2 id="payTarget" class="text-xl font-black mb-4 uppercase">Stationary Print</h2>
            <p class="text-xs mb-6">Payment: <b>500 TZS</b> to Lipa Namba <b>556677</b></p>
            <button onclick="finishDown()" class="w-full bg-green-600 text-white py-4 rounded-2xl font-black uppercase">CONFIRM & SEND</button>
            <button onclick="hidePay()" class="mt-4 text-gray-400 text-[10px] uppercase font-bold underline">Cancel</button>
        </div>
    </div>

    <script>
        let currentContent = "";
        let selectedStationery = "";

        async function getAI(t) {
            const topic = document.getElementById('topic').value || "General";
            const res = await fetch('http://127.0.0.1:5000/api/ai/copilot', {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({type:t, topic})});
            const data = await res.json();
            currentContent = data.content;
            document.getElementById('resultBox').classList.remove('hidden');
            document.getElementById('output').innerText = currentContent;
        }

        async function findStudent() {
            const reg = document.getElementById('regNo').value;
            const res = await fetch(`http://127.0.0.1:5000/api/students/search?reg=${reg}`);
            const data = await res.json();
            if(data.name) {
                document.getElementById('studentResult').classList.remove('hidden');
                document.getElementById('sName').innerText = data.name;
                document.getElementById('sBalance').innerText = "Fees Owed: " + data.balance;
            }
        }

        function showPay(loc) { 
            selectedStationery = loc;
            document.getElementById('payTarget').innerText = loc === 'Download' ? "Unlock Download" : "Send to: " + loc;
            document.getElementById('payM').classList.remove('hidden'); 
        }
        function hidePay() { document.getElementById('payM').classList.add('hidden'); }

        async function finishDown() {
            const res = await fetch('http://127.0.0.1:5000/api/download/pdf', {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({content:currentContent, stationery: selectedStationery})});
            const blob = await res.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a'); a.href = url; a.download = "Hilsey_Request.pdf"; a.click();
            alert(selectedStationery === 'Download' ? "Downloaded!" : "File sent to " + selectedStationery + ". Go pick it up!");
            hidePay();
        }

        async function load() {
            const res = await fetch('http://127.0.0.1:5000/api/assignments');
            const data = await res.json();
            document.getElementById('notices').innerHTML = `<h2 class="font-bold text-yellow-500 mb-4 uppercase">Assignments</h2>` + 
                data.map(n => `<div class='bg-slate-900 p-2 mb-2 rounded border-l-2 border-yellow-500'><b>[${n.type}] ${n.course}</b><br>${n.title}</div>`).join('');
        }
        load();
    </script>
</body>
</html>
EOF

cp index.html /mnt/c/Users/Public/index.html
python3 app.py
sqlite3 tia_system.db "SELECT * FROM assignment;"
sudo apt update && sudo apt install sqlite3 -y
sqlite3 tia_system.db "SELECT * FROM assignment;"
cat << 'EOF' > app.py
from flask import Flask, jsonify, request, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from reportlab.pdfgen import canvas
import io
from datetime import datetime

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///tia_system.db'
db = SQLAlchemy(app)

# Database Tables
class Assignment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    course = db.Column(db.String(100))
    title = db.Column(db.String(200))
    type = db.Column(db.String(20))

class PrintJob(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    student_reg = db.Column(db.String(50))
    doc_type = db.Column(db.String(50))
    content = db.Column(db.Text)
    status = db.Column(db.String(20), default="Pending") # Pending, Printed
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

@app.route('/api/assignments', methods=['GET', 'POST'])
def manage_tasks():
    if request.method == 'POST':
        data = request.json
        new_task = Assignment(course=data['course'], title=data['title'], type=data.get('type', 'Individual'))
        db.session.add(new_task)
        db.session.commit()
        return jsonify({"message": "Posted!"})
    return jsonify([{"course": t.course, "title": t.title, "type": t.type} for t in Assignment.query.all()])

@app.route('/api/print/send', methods=['POST'])
def send_to_print():
    data = request.json
    job = PrintJob(student_reg=data['reg'], doc_type=data['type'], content=data['content'])
    db.session.add(job)
    db.session.commit()
    return jsonify({"message": "Sent to Stationary!"})

@app.route('/api/print/queue', methods=['GET'])
def get_queue():
    jobs = PrintJob.query.order_by(PrintJob.timestamp.desc()).all()
    return jsonify([{
        "id": j.id, "reg": j.student_reg, "type": j.doc_type, 
        "status": j.status, "time": j.timestamp.strftime('%H:%M')
    } for j in jobs])

@app.route('/api/ai/copilot', methods=['POST'])
def ai():
    data = request.json
    t = data.get('type')
    topic = data.get('topic', 'General')
    content = f"TIA OFFICIAL {t.upper()}\nTopic: {topic}\n\nThis document is ready for submission.\nHilsey AI System 2026."
    return jsonify({"content": content})

@app.route('/api/students/search', methods=['GET'])
def search_student():
    reg = request.args.get('reg', '').upper()
    if "TIA" in reg:
        return jsonify({"name": f"Student {reg}", "balance": "5,500 TZS", "gpa": "3.2"})
    return jsonify({"error": "Not Found"}), 404

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
EOF

cat << 'EOF' > staff.html
<!DOCTYPE html>
<html>
<head>
    <title>STAFF | Hilsey Stationary</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-10 font-sans">
    <div class="max-w-4xl mx-auto bg-white shadow-2xl rounded-3xl overflow-hidden">
        <div class="bg-red-600 p-6 text-white flex justify-between items-center">
            <h1 class="text-2xl font-black italic">HILSEY STAFF TERMINAL</h1>
            <span class="bg-white text-red-600 px-3 py-1 rounded-full text-xs font-bold animate-pulse">LIVE ORDERS</span>
        </div>
        
        <div class="p-8">
            <table class="w-full text-left">
                <thead>
                    <tr class="text-gray-400 text-xs uppercase border-b">
                        <th class="pb-4">Time</th>
                        <th class="pb-4">Student Reg</th>
                        <th class="pb-4">Doc Type</th>
                        <th class="pb-4">Status</th>
                        <th class="pb-4 text-right">Action</th>
                    </tr>
                </thead>
                <tbody id="queueBody">
                    </tbody>
            </table>
        </div>
    </div>

    <script>
        async function loadQueue() {
            const res = await fetch('http://127.0.0.1:5000/api/print/queue');
            const data = await res.json();
            const body = document.getElementById('queueBody');
            body.innerHTML = data.map(j => `
                <tr class="border-b hover:bg-gray-50">
                    <td class="py-4 text-sm">${j.time}</td>
                    <td class="py-4 font-bold text-blue-600">${j.reg}</td>
                    <td class="py-4 text-sm text-gray-600">${j.type}</td>
                    <td class="py-4 text-xs font-bold ${j.status=='Pending'?'text-orange-500':'text-green-500'}">${j.status}</td>
                    <td class="py-4 text-right">
                        <button class="bg-black text-white px-4 py-1 rounded text-xs font-bold hover:bg-blue-600">OPEN & PRINT</button>
                    </td>
                </tr>
            `).join('');
        }
        setInterval(loadQueue, 3000); // Auto-refresh every 3 seconds
        loadQueue();
    </script>
</body>
</html>
EOF

cp index.html /mnt/c/Users/Public/index.html && cp staff.html /mnt/c/Users/Public/staff.html
python3 app.py
cat << 'EOF' > app.py
from flask import Flask, jsonify, request, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///hilsey_pro.db'
db = SQLAlchemy(app)

class Order(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reg = db.Column(db.String(50))
    trans_id = db.Column(db.String(100))
    doc_type = db.Column(db.String(50))
    status = db.Column(db.String(20), default="Verifying Payment") # New statuses
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    data = request.json
    new_order = Order(reg=data['reg'], trans_id=data['trans_id'], doc_type=data['type'])
    db.session.add(new_order)
    db.session.commit()
    return jsonify({"message": "Order Received!", "order_id": new_order.id})

@app.route('/api/order/status/<int:oid>', methods=['GET'])
def check_status(oid):
    order = Order.query.get(oid)
    return jsonify({"status": order.status}) if order else ({"error": "NA"}, 404)

@app.route('/api/staff/orders', methods=['GET'])
def get_staff_orders():
    orders = Order.query.order_by(Order.timestamp.desc()).all()
    return jsonify([{"id": o.id, "reg": o.reg, "type": o.doc_type, "status": o.status, "tx": o.trans_id} for o in orders])

@app.route('/api/staff/update', methods=['POST'])
def update_order():
    data = request.json
    order = Order.query.get(data['id'])
    order.status = data['status']
    db.session.commit()
    return jsonify({"message": "Updated"})

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
EOF

python3 app.py
cat << 'EOF' > app.py
from flask import Flask, jsonify, request, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from reportlab.pdfgen import canvas
from datetime import datetime
import io

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///hilsey_final.db'
db = SQLAlchemy(app)

class Order(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reg = db.Column(db.String(50))
    trans_id = db.Column(db.String(100))
    doc_type = db.Column(db.String(50))
    content = db.Column(db.Text)
    status = db.Column(db.String(20), default="Verifying...")
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    data = request.json
    new_order = Order(
        reg=data.get('reg', 'TIA/GUEST'), 
        trans_id=data.get('trans_id', 'N/A'), 
        doc_type=data.get('type', 'General'),
        content=data.get('content', '')
    )
    db.session.add(new_order)
    db.session.commit()
    return jsonify({"message": "Sent to Staff!", "order_id": new_order.id})

@app.route('/api/download/pdf/<int:oid>', methods=['GET'])
def download_pdf(oid):
    order = Order.query.get(oid)
    if not order: return "Not Found", 404
    
    buffer = io.BytesIO()
    p = canvas.Canvas(buffer)
    # Header
    p.setFont("Helvetica-Bold", 16)
    p.drawString(100, 800, "HILSEY STATIONARY - TIA PORTAL")
    p.setFont("Helvetica", 10)
    p.drawString(100, 785, f"Date: {order.timestamp.strftime('%Y-%m-%d %H:%M')}")
    p.line(100, 780, 500, 780)
    
    # Student Info
    p.setFont("Helvetica-Bold", 12)
    p.drawString(100, 750, f"STUDENT REG: {order.reg}")
    p.drawString(100, 735, f"DOC TYPE: {order.doc_type}")
    
    # Content
    p.setFont("Helvetica", 11)
    y = 700
    for line in order.content.split('\n'):
        p.drawString(100, y, line)
        y -= 20
    
    # Footer Watermark
    p.setFont("Helvetica-Oblique", 8)
    p.drawString(100, 50, "Verified by Hilsey AI - Professional TIA Submission")
    
    p.showPage()
    p.save()
    buffer.seek(0)
    return send_file(buffer, as_attachment=True, download_name=f"{order.reg}_document.pdf")

@app.route('/api/staff/orders', methods=['GET'])
def get_staff_orders():
    orders = Order.query.order_by(Order.timestamp.desc()).all()
    return jsonify([{"id": o.id, "reg": o.reg, "type": o.doc_type, "status": o.status, "tx": o.trans_id} for o in orders])

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
EOF

python3 app.py
cat << 'EOF' > index.html
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY TIA PORTAL</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-900 text-white p-6 font-sans">
    <div class="max-w-4xl mx-auto">
        <h1 class="text-3xl font-black text-blue-400 mb-6">HILSEY STATIONARY PRO</h1>

        <div class="bg-slate-800 p-6 rounded-2xl mb-6 border-l-4 border-blue-500">
            <h2 class="font-bold mb-4 uppercase text-sm">1. Generate Content</h2>
            <input id="topic" type="text" placeholder="Topic/Subject..." class="w-full bg-slate-900 p-3 rounded mb-4 border border-slate-700">
            <div class="flex gap-2">
                <button onclick="getAI('proposal')" class="bg-blue-600 flex-1 py-2 rounded font-bold text-xs uppercase">Proposal</button>
                <button onclick="getAI('field')" class="bg-green-600 flex-1 py-2 rounded font-bold text-xs uppercase">Field Report</button>
            </div>
        </div>

        <div class="bg-slate-800 p-6 rounded-2xl mb-6 border-l-4 border-purple-500">
            <h2 class="font-bold mb-4 uppercase text-sm">2. Student/Group Details</h2>
            <input id="leaderReg" type="text" placeholder="Leader Reg No (TIA/...)" class="w-full bg-slate-900 p-3 rounded mb-2 border border-slate-700">
            <textarea id="groupMembers" placeholder="Add other member names (optional)..." class="w-full bg-slate-900 p-3 rounded h-20 border border-slate-700 text-xs"></textarea>
        </div>

        <div id="resultBox" class="hidden bg-black p-6 rounded-2xl border border-blue-900 shadow-2xl">
            <h3 class="text-blue-500 font-bold uppercase text-[10px] mb-4">Preview & Print</h3>
            <pre id="output" class="text-slate-300 font-mono text-xs whitespace-pre-wrap mb-6 bg-slate-900 p-4 rounded"></pre>
            
            <div class="bg-yellow-500/10 p-4 rounded-xl border border-yellow-500/50 mb-4 text-center">
                <p class="text-yellow-500 font-bold text-sm">LIPA 500/= TO: 556677 (Hilsey)</p>
                <input id="txId" type="text" placeholder="Enter Transaction ID" class="mt-2 w-full max-w-xs bg-black p-2 rounded border border-yellow-500 text-center uppercase font-bold">
            </div>
            
            <button onclick="sendOrder()" class="w-full bg-blue-600 py-4 rounded-xl font-black uppercase tracking-widest hover:bg-blue-500">SEND TO STATIONARY</button>
        </div>
    </div>

    <script>
        let currentContent = "";

        async function getAI(t) {
            const topic = document.getElementById('topic').value;
            const res = await fetch('http://127.0.0.1:5000/api/ai/copilot', {
                method:'POST', headers:{'Content-Type':'application/json'},
                body:JSON.stringify({type:t, topic})
            });
            const data = await res.json();
            currentContent = data.content;
            document.getElementById('resultBox').classList.remove('hidden');
            document.getElementById('output').innerText = currentContent;
        }

        async function sendOrder() {
            const reg = document.getElementById('leaderReg').value;
            const members = document.getElementById('groupMembers').value;
            const tx = document.getElementById('txId').value;
            
            if(!reg || !tx) return alert("Please enter Reg No and Transaction ID");

            // Combine group names into the content
            const finalContent = `GROUP MEMBERS:\n1. ${reg}\n${members}\n\n---\n${currentContent}`;

            await fetch('http://127.0.0.1:5000/api/order/submit', {
                method:'POST', headers:{'Content-Type':'application/json'},
                body:JSON.stringify({reg, trans_id: tx, type: "Group Submission", content: finalContent})
            });
            
            alert("Sent! Your group document is waiting at the stationary.");
        }
    </script>
</body>
</html>
EOF

cp index.html /mnt/c/Users/Public/index.html
python3 app.py
cat << 'EOF' > app.py
from flask import Flask, jsonify, request, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from reportlab.pdfgen import canvas
from datetime import datetime
import io

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///hilsey_final.db'
db = SQLAlchemy(app)

class Order(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reg = db.Column(db.String(50))
    trans_id = db.Column(db.String(100))
    doc_type = db.Column(db.String(50))
    content = db.Column(db.Text)
    status = db.Column(db.String(20), default="Verifying...")
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    data = request.json
    new_order = Order(
        reg=data.get('reg', 'TIA/GUEST'), 
        trans_id=data.get('trans_id', 'N/A'), 
        doc_type=data.get('type', 'General'),
        content=data.get('content', '')
    )
    db.session.add(new_order)
    db.session.commit()
    return jsonify({"message": "Sent to Staff!", "order_id": new_order.id})

@app.route('/api/download/pdf/<int:oid>', methods=['GET'])
def download_pdf(oid):
    order = Order.query.get(oid)
    if not order: return "Not Found", 404
    
    buffer = io.BytesIO()
    p = canvas.Canvas(buffer)
    # Header
    p.setFont("Helvetica-Bold", 16)
    p.drawString(100, 800, "HILSEY STATIONARY - TIA PORTAL")
    p.setFont("Helvetica", 10)
    p.drawString(100, 785, f"Date: {order.timestamp.strftime('%Y-%m-%d %H:%M')}")
    p.line(100, 780, 500, 780)
    
    # Student Info
    p.setFont("Helvetica-Bold", 12)
    p.drawString(100, 750, f"STUDENT REG: {order.reg}")
    p.drawString(100, 735, f"DOC TYPE: {order.doc_type}")
    
    # Content
    p.setFont("Helvetica", 11)
    y = 700
    for line in order.content.split('\n'):
        p.drawString(100, y, line)
        y -= 20
    
    # Footer Watermark
    p.setFont("Helvetica-Oblique", 8)
    p.drawString(100, 50, "Verified by Hilsey AI - Professional TIA Submission")
    
    p.showPage()
    p.save()
    buffer.seek(0)
    return send_file(buffer, as_attachment=True, download_name=f"{order.reg}_document.pdf")

@app.route('/api/staff/orders', methods=['GET'])
def get_staff_orders():
    orders = Order.query.order_by(Order.timestamp.desc()).all()
    return jsonify([{"id": o.id, "reg": o.reg, "type": o.doc_type, "status": o.status, "tx": o.trans_id} for o in orders])

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
EOF

cp index.html /mnt/c/Users/Public/index.html
python3 app.py
cat << 'EOF' > app.py
from flask import Flask, jsonify, request, render_template_string
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///hilsey_final.db'
db = SQLAlchemy(app)

# --- DATABASE MODELS ---
class Order(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reg = db.Column(db.String(50))
    trans_id = db.Column(db.String(100))
    doc_type = db.Column(db.String(50))
    status = db.Column(db.String(20), default="Verifying...")
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

# --- API ROUTES ---
@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    data = request.json
    new_order = Order(
        reg=data.get('reg', 'TIA/GUEST'), 
        trans_id=data.get('trans_id', 'N/A'), 
        doc_type=data.get('type', 'General')
    )
    db.session.add(new_order)
    db.session.commit()
    return jsonify({"message": "Order Received!", "order_id": new_order.id})

@app.route('/api/staff/orders', methods=['GET'])
def get_staff_orders():
    orders = Order.query.order_by(Order.timestamp.desc()).all()
    return jsonify([
        {"id": o.id, "reg": o.reg, "type": o.doc_type, "status": o.status, "tx": o.trans_id} 
        for o in orders
    ])

@app.route('/api/staff/update', methods=['POST'])
def update_order():
    data = request.json
    order = Order.query.get(data['id'])
    if order:
        order.status = data['status']
        db.session.commit()
    return jsonify({"message": "Updated"})

# --- START THE SYSTEM ---
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    print("\n--- HILSEY STATIONARY SYSTEM LIVE ---")
    print("Running on http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000)
EOF

cp index.html /mnt/c/Users/Public/index.html
python3 app.py
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>HILSEY TIA PORTAL | PRO</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .glass { background: rgba(30, 41, 59, 0.7); backdrop-filter: blur(10px); }
        .btn-glow:hover { box-shadow: 0 0 15px rgba(59, 130, 246, 0.5); }
    </style>
</head>
<body class="bg-slate-900 text-slate-100 min-h-screen font-sans">
    <div class="max-w-5xl mx-auto p-4 md:p-10">
        
        <header class="flex justify-between items-center mb-10 border-b border-slate-800 pb-6">
            <div>
                <h1 class="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-emerald-400 uppercase tracking-tighter">Hilsey Stationary</h1>
                <p class="text-slate-500 text-xs font-bold tracking-widest uppercase mt-1">TIA Academic Logistics Hub</p>
            </div>
            <div class="hidden md:block text-right">
                <div class="text-[10px] text-slate-500 uppercase">System Status</div>
                <div class="flex items-center gap-2 text-emerald-400 font-mono text-sm">
                    <span class="w-2 h-2 bg-emerald-500 rounded-full animate-ping"></span> ONLINE
                </div>
            </div>
        </header>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <div class="lg:col-span-1 space-y-6">
                <section class="glass p-6 rounded-3xl border border-slate-800 shadow-xl">
                    <h2 class="text-blue-400 font-bold mb-4 uppercase text-xs flex items-center gap-2">
                        <span class="w-4 h-1 bg-blue-500"></span> 1. Document Context
                    </h2>
                    <input id="topic" type="text" placeholder="What is the topic?" class="w-full bg-slate-950 p-4 rounded-2xl mb-4 border border-slate-800 focus:border-blue-500 outline-none transition-all">
                    <div class="grid grid-cols-2 gap-3">
                        <button onclick="getAI('proposal')" class="bg-slate-800 hover:bg-blue-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Research Proposal</button>
                        <button onclick="getAI('field')" class="bg-slate-800 hover:bg-emerald-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Field Report</button>
                        <button onclick="getAI('cv')" class="bg-slate-800 hover:bg-purple-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Professional CV</button>
                        <button onclick="getAI('job')" class="bg-slate-800 hover:bg-orange-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Job Letter</button>
                    </div>
                </section>

                <section class="glass p-6 rounded-3xl border border-slate-800">
                    <h2 class="text-purple-400 font-bold mb-4 uppercase text-xs flex items-center gap-2">
                        <span class="w-4 h-1 bg-purple-500"></span> 2. Student Details
                    </h2>
                    <input id="leaderReg" type="text" placeholder="Leader Reg No (TIA/00...)" class="w-full bg-slate-950 p-3 rounded-xl mb-3 border border-slate-800 focus:border-purple-500 outline-none text-sm">
                    <textarea id="groupMembers" placeholder="Add extra members (optional)" class="w-full bg-slate-950 p-3 rounded-xl h-24 border border-slate-800 focus:border-purple-500 outline-none text-[11px]"></textarea>
                </section>
            </div>

            <div class="lg:col-span-2">
                <div id="resultBox" class="hidden glass rounded-3xl border border-blue-900/50 overflow-hidden shadow-2xl">
                    <div class="bg-blue-900/20 p-4 border-b border-blue-900/50 flex justify-between items-center">
                        <span class="text-blue-400 font-black text-xs uppercase tracking-widest">Live Document Preview</span>
                        <span id="docTypeTag" class="bg-blue-500 text-[10px] px-3 py-1 rounded-full font-bold uppercase">Ready</span>
                    </div>
                    
                    <div class="p-8">
                        <pre id="output" class="text-slate-300 font-mono text-xs whitespace-pre-wrap leading-relaxed bg-slate-950/50 p-6 rounded-2xl border border-slate-800 mb-8 max-h-[400px] overflow-y-auto"></pre>
                        
                        <div class="bg-gradient-to-br from-yellow-500/10 to-transparent p-6 rounded-2xl border border-yellow-500/30 flex flex-col items-center">
                            <p class="text-yellow-500 font-bold text-sm mb-4 uppercase tracking-widest">Final Step: Secure Printing</p>
                            <div class="bg-black/50 p-4 rounded-2xl w-full text-center mb-6">
                                <p class="text-xs text-slate-400 mb-1 uppercase">Lipa Namba (M-Pesa)</p>
                                <p class="text-3xl font-black text-white italic">556677</p>
                                <p class="text-[10px] text-yellow-600 font-bold mt-1">Amount: 500 TZS</p>
                            </div>
                            <input id="txId" type="text" placeholder="PASTE TRANSACTION ID HERE" class="w-full max-w-sm bg-slate-950 p-4 rounded-xl border-2 border-yellow-500/50 text-center uppercase font-black tracking-widest mb-4 focus:border-yellow-500 outline-none">
                            <button onclick="sendOrder()" class="w-full max-w-sm bg-blue-600 hover:bg-blue-500 py-4 rounded-2xl font-black uppercase tracking-widest shadow-lg shadow-blue-500/20 transition-all active:scale-95">Confirm & Send to Printer</button>
                        </div>
                    </div>
                </div>

                <div id="emptyState" class="h-full flex flex-col items-center justify-center p-20 border-2 border-dashed border-slate-800 rounded-3xl text-slate-600">
                    <p class="uppercase font-bold tracking-widest text-sm">Waiting for content...</p>
                    <p class="text-xs mt-2 italic">Select a document type on the left to begin.</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentContent = "";
        let selectedType = "";

        async function getAI(t) {
            const topic = document.getElementById('topic').value;
            if(!topic) { alert("Please enter a topic first!"); return; }
            
            selectedType = t;
            const res = await fetch('http://127.0.0.1:5000/api/ai/copilot', {
                method:'POST', headers:{'Content-Type':'application/json'},
                body:JSON.stringify({type:t, topic})
            });
            const data = await res.json();
            currentContent = data.content;
            
            document.getElementById('emptyState').classList.add('hidden');
            document.getElementById('resultBox').classList.remove('hidden');
            document.getElementById('output').innerText = currentContent;
            document.getElementById('docTypeTag').innerText = t.toUpperCase();
        }

        async function sendOrder() {
            const reg = document.getElementById('leaderReg').value;
            const members = document.getElementById('groupMembers').value;
            const tx = document.getElementById('txId').value;
            
            if(!reg || !tx) { alert("Registration No and Transaction ID are required!"); return; }

            const finalContent = `LEADER: ${reg}\nGROUP: ${members}\n\n---\n${currentContent}`;

            const res = await fetch('http://127.0.0.1:5000/api/order/submit', {
                method:'POST', headers:{'Content-Type':'application/json'},
                body:JSON.stringify({reg, trans_id: tx, type: selectedType, content:

cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>HILSEY TIA PORTAL | PRO</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .glass { background: rgba(30, 41, 59, 0.7); backdrop-filter: blur(10px); }
        .btn-glow:hover { box-shadow: 0 0 15px rgba(59, 130, 246, 0.5); }
    </style>
</head>
<body class="bg-slate-900 text-slate-100 min-h-screen font-sans">
    <div class="max-w-5xl mx-auto p-4 md:p-10">
        
        <header class="flex justify-between items-center mb-10 border-b border-slate-800 pb-6">
            <div>
                <h1 class="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-emerald-400 uppercase tracking-tighter">Hilsey Stationary</h1>
                <p class="text-slate-500 text-xs font-bold tracking-widest uppercase mt-1">TIA Academic Logistics Hub</p>
            </div>
            <div class="hidden md:block text-right">
                <div class="text-[10px] text-slate-500 uppercase">System Status</div>
                <div class="flex items-center gap-2 text-emerald-400 font-mono text-sm">
                    <span class="w-2 h-2 bg-emerald-500 rounded-full animate-ping"></span> ONLINE
                </div>
            </div>
        </header>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <div class="lg:col-span-1 space-y-6">
                <section class="glass p-6 rounded-3xl border border-slate-800 shadow-xl">
                    <h2 class="text-blue-400 font-bold mb-4 uppercase text-xs flex items-center gap-2">
                        <span class="w-4 h-1 bg-blue-500"></span> 1. Document Context
                    </h2>
                    <input id="topic" type="text" placeholder="What is the topic?" class="w-full bg-slate-950 p-4 rounded-2xl mb-4 border border-slate-800 focus:border-blue-500 outline-none transition-all">
                    <div class="grid grid-cols-2 gap-3">
                        <button onclick="getAI('proposal')" class="bg-slate-800 hover:bg-blue-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Research Proposal</button>
                        <button onclick="getAI('field')" class="bg-slate-800 hover:bg-emerald-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Field Report</button>
                        <button onclick="getAI('cv')" class="bg-slate-800 hover:bg-purple-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Professional CV</button>
                        <button onclick="getAI('job')" class="bg-slate-800 hover:bg-orange-600 py-3 rounded-xl font-bold text-[10px] uppercase transition-all btn-glow border border-slate-700">Job Letter</button>
                    </div>
                </section>

                <section class="glass p-6 rounded-3xl border border-slate-800">
                    <h2 class="text-purple-400 font-bold mb-4 uppercase text-xs flex items-center gap-2">
                        <span class="w-4 h-1 bg-purple-500"></span> 2. Student Details
                    </h2>
                    <input id="leaderReg" type="text" placeholder="Leader Reg No (TIA/00...)" class="w-full bg-slate-950 p-3 rounded-xl mb-3 border border-slate-800 focus:border-purple-500 outline-none text-sm">
                    <textarea id="groupMembers" placeholder="Add extra members (optional)" class="w-full bg-slate-950 p-3 rounded-xl h-24 border border-slate-800 focus:border-purple-500 outline-none text-[11px]"></textarea>
                </section>
            </div>

            <div class="lg:col-span-2">
                <div id="resultBox" class="hidden glass rounded-3xl border border-blue-900/50 overflow-hidden shadow-2xl">
                    <div class="bg-blue-900/20 p-4 border-b border-blue-900/50 flex justify-between items-center">
                        <span class="text-blue-400 font-black text-xs uppercase tracking-widest">Live Document Preview</span>
                        <span id="docTypeTag" class="bg-blue-500 text-[10px] px-3 py-1 rounded-full font-bold uppercase">Ready</span>
                    </div>
                    
                    <div class="p-8">
                        <pre id="output" class="text-slate-300 font-mono text-xs whitespace-pre-wrap leading-relaxed bg-slate-950/50 p-6 rounded-2xl border border-slate-800 mb-8 max-h-[400px] overflow-y-auto"></pre>
                        
                        <div class="bg-gradient-to-br from-yellow-500/10 to-transparent p-6 rounded-2xl border border-yellow-500/30 flex flex-col items-center">
                            <p class="text-yellow-500 font-bold text-sm mb-4 uppercase tracking-widest">Final Step: Secure Printing</p>
                            <div class="bg-black/50 p-4 rounded-2xl w-full text-center mb-6">
                                <p class="text-xs text-slate-400 mb-1 uppercase">Lipa Namba (M-Pesa)</p>
                                <p class="text-3xl font-black text-white italic">556677</p>
                                <p class="text-[10px] text-yellow-600 font-bold mt-1">Amount: 500 TZS</p>
                            </div>
                            <input id="txId" type="text" placeholder="PASTE TRANSACTION ID HERE" class="w-full max-w-sm bg-slate-950 p-4 rounded-xl border-2 border-yellow-500/50 text-center uppercase font-black tracking-widest mb-4 focus:border-yellow-500 outline-none">
                            <button onclick="sendOrder()" class="w-full max-w-sm bg-blue-600 hover:bg-blue-500 py-4 rounded-2xl font-black uppercase tracking-widest shadow-lg shadow-blue-500/20 transition-all active:scale-95">Confirm & Send to Printer</button>
                        </div>
                    </div>
                </div>

                <div id="emptyState" class="h-full flex flex-col items-center justify-center p-20 border-2 border-dashed border-slate-800 rounded-3xl text-slate-600">
                    <p class="uppercase font-bold tracking-widest text-sm">Waiting for content...</p>
                    <p class="text-xs mt-2 italic">Select a document type on the left to begin.</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentContent = "";
        let selectedType = "";

        async function getAI(t) {
            const topic = document.getElementById('topic').value;
            if(!topic) { alert("Please enter a topic first!"); return; }
            
            selectedType = t;
            const res = await fetch('http://127.0.0.1:5000/api/ai/copilot', {
                method:'POST', headers:{'Content-Type':'application/json'},
                body:JSON.stringify({type:t, topic})
            });
            const data = await res.json();
            currentContent = data.content;
            
            document.getElementById('emptyState').classList.add('hidden');
            document.getElementById('resultBox').classList.remove('hidden');
            document.getElementById('output').innerText = currentContent;
            document.getElementById('docTypeTag').innerText = t.toUpperCase();
        }

        async function sendOrder() {
            const reg = document.getElementById('leaderReg').value;
            const members = document.getElementById('groupMembers').value;
            const tx = document.getElementById('txId').value;
            
            if(!reg || !tx) { alert("Registration No and Transaction ID are required!"); return; }

            const finalContent = `LEADER: ${reg}\nGROUP: ${members}\n\n---\n${currentContent}`;

            const res = await fetch('http://127.0.0.1:5000/api/order/submit', {
                method:'POST', headers:{'Content-Type':'application/json'},
                body:JSON.stringify({reg, trans_id: tx, type: selectedType, content: finalContent})
            });
            
            if(res.ok) {
                alert("SUCCESS! Order sent to Hilsey Stationary Terminal.");
                location.reload();
            }
        }
    </script>
</body>
</html>
EOF

cp index.html /mnt/c/Users/Public/index.html
python3 app.py
sudo apt update && sudo apt install nodejs npm -y
lt --port 5000 --subdomain hilsey-stationary
npx localtunnel --port 5000 --subdomain hilsey-stationary
$(npm bin -g)/lt --port 5000 --subdomain hilsey-stationary
/usr/local/bin/lt --port 5000 --subdomain hilsey-stationary
ssh -R 80:localhost:5000 hilsey-stationary@ssh.localhost.run
ssh -R 80:localhost:5000 hilsey@ssh.localhost.run
cat << 'EOF' > app.py
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)
CORS(app) # This allows your phone to talk to your laptop
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///hilsey_portal.db'
db = SQLAlchemy(app)

# Database to store student orders
class Order(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reg = db.Column(db.String(50))
    trans_id = db.Column(db.String(100))
    doc_type = db.Column(db.String(50))
    content = db.Column(db.Text)
    status = db.Column(db.String(20), default="Pending")
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

@app.route('/')
def home():
    return "Hilsey Server is LIVE! Connection Successful."

@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    data = request.json
    new_order = Order(
        reg=data.get('reg'), 
        trans_id=data.get('trans_id'), 
        doc_type=data.get('type'),
        content=data.get('content')
    )
    db.session.add(new_order)
    db.session.commit()
    return jsonify({"message": "Order Received by Hilsey!", "id": new_order.id})

@app.route('/api/ai/copilot', methods=['POST'])
def ai_logic():
    data = request.json
    topic = data.get('topic', 'General Assignment')
    doc_type = data.get('type', 'Report')
    # This simulates the AI writing for the student
    ai_text = f"HILSEY AI GENERATED {doc_type.upper()}\nTOPIC: {topic}\n\nIntroduction: This document outlines the key accounting principles regarding {topic} at TIA..."
    return jsonify({"content": ai_text})

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    print("🚀 HILSEY SERVER STARTING ON PORT 5000...")
    app.run(host='0.0.0.0', port=5000)
EOF

python3 app.py
ssh -R 80:localhost:5000 nokey@localhost.run
curl -s https://ngrok-free.app/setup.sh | sudo bash
ngrok config add-authtoken YOUR_TOKEN_HERE
ngrok http 5000
ssh -R 80:localhost:5000 nokey@localhost.run
ssh -R 80:localhost:5000 localhost.run
curl -sL https://bore.pub/install.sh | sudo bash
bore local 5000 --to bore.pub
sudo npm install -g localtunnel
lt --port 5000
python3 app.py --host=0.0.0.0
sudo ufw allow 5000
cat << 'EOF' > app.py
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
EOF

python3 app.py
lt --port 5000 --subdomain hilsey-stationary
curl ifconfig.me
python3 app.py
your url is: https://hilsey-stationary.localtunnel.me
python3 app.py
find ~ -name "app.py"
cat << 'EOF' > app.py
from flask import Flask, render_template_string, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Storage for student orders
orders = []

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HILSEY STATIONARY PRO</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #0a0a0a; color: #e0e0e0; margin: 0; padding: 20px; }
        .dashboard { max-width: 1000px; margin: auto; border: 1px solid #333; padding: 30px; border-radius: 15px; background: #111; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h1 { color: #00d4ff; border-bottom: 2px solid #00d4ff; padding-bottom: 15px; letter-spacing: 2px; }
        .grid { display: grid; grid-template-columns: 1.2fr 0.8fr; gap: 25px; margin-top: 20px; }
        .box { background: #1a1a1a; padding: 20px; border-radius: 10px; border: 1px solid #333; }
        h3 { color: #00d4ff; margin-top: 0; }
        input, textarea, select { width: 100%; padding: 12px; margin: 10px 0; background: #222; color: #fff; border: 1px solid #444; border-radius: 5px; box-sizing: border-box; }
        button { background: #00d4ff; color: #000; padding: 12px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; width: 100%; transition: 0.3s; }
        button:hover { background: #008fb3; }
        .order-row { background: #252525; padding: 15px; margin-top: 10px; border-left: 5px solid #00d4ff; border-radius: 4px; }
        .status-badge { background: #00d4ff; color: #000; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; float: right; }
    </style>
</head>
<body>
    <div class="dashboard">
        <h1>HILSEY PRO : COMMAND CENTER</h1>
        <div class="grid">
            <div class="box">
                <h3>📝 AI Generator & Editor</h3>
                <input type="text" id="topic" placeholder="Assignment Topic (e.g. TIA Financial Accounting)">
                <select id="docType">
                    <option value="Assignment">General Assignment</option>
                    <option value="Proposal">Research Proposal</option>
                    <option value="Case Study">Case Study Analysis</option>
                </select>
                <button onclick="generateAI()">GENERATE CONTENT</button>
                <textarea id="aiResult" rows="12" placeholder="AI-generated content will appear here for you to edit..."></textarea>
            </div>
            <div class="box">
                <h3>📥 Incoming TIA Orders</h3>
                <div id="orderList">
                    <p style="color: #666;">Waiting for student requests...</p>
                </div>
                <button onclick="loadOrders()" style="margin-top:15px; background:#333; color:#aaa;">REFRESH FEED</button>
            </div>
        </div>
    </div>
    <script>
        async function generateAI() {
            const topic = document.getElementById('topic').value;
            const type = document.getElementById('docType').value;
            document.getElementById('aiResult').value = "Hilsey AI is thinking...";
            const res = await fetch('/api/ai/copilot', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({topic, type})
            });
            const data = await res.json();
            document.getElementById('aiResult').value = data.content;
        }
        async function loadOrders() {
            const res = await fetch('/api/orders');
            const data = await res.json();
            const container = document.getElementById('orderList');
            container.innerHTML = data.map(o => `
                <div class="order-row">
                    <span class="status-badge">PENDING PRINT</span>
                    <strong>ID:</strong> ${o.reg}<br>
                    <strong>Service:</strong> ${o.doc_type}<br>
                    <small style="color:#888;">${o.time}</small>
                </div>
            `).join('') || "No active orders.";
        }
        setInterval(loadOrders, 5000);
    </script>
</body>
</html>
"""

@app.route('/')
def dashboard():
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/ai/copilot', methods=['POST'])
def ai_logic():
    data = request.json
    topic = data.get('topic', 'N/A')
    doc_type = data.get('type', 'Doc')
    ai_text = f"HILSEY AI GENERATED {doc_type.upper()}\n\nTOPIC: {topic}\n\n[DRAFT CONTENT]: Based on the TIA curriculum, this {doc_type} explores the core components of {topic}. It includes an introduction, literature review, and practical application for Tanzania's current economic climate..."
    return jsonify({"content": ai_text})

@app.route('/api/orders', methods=['GET'])
def get_orders():
    return jsonify(orders)

@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    data = request.json
    orders.append({
        "reg": data.get('reg', 'Unknown'),
        "doc_type": data.get('type', 'General'),
        "time": "Received"
    })
    return jsonify({"message": "Success"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

python3 app.py
pip install flask flask-cors
pip install flask flask-cors --break-system-packages
--break-system-packages
--nowarn-script-location.
python3 app.py
cat << 'EOF' > app.py
from flask import Flask, render_template_string, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Storage for student orders
orders = []

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HILSEY STATIONARY PRO</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #0a0a0a; color: #e0e0e0; margin: 0; padding: 20px; }
        .dashboard { max-width: 1000px; margin: auto; border: 1px solid #333; padding: 30px; border-radius: 15px; background: #111; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h1 { color: #00d4ff; border-bottom: 2px solid #00d4ff; padding-bottom: 15px; letter-spacing: 2px; }
        .grid { display: grid; grid-template-columns: 1.2fr 0.8fr; gap: 25px; margin-top: 20px; }
        .box { background: #1a1a1a; padding: 20px; border-radius: 10px; border: 1px solid #333; }
        h3 { color: #00d4ff; margin-top: 0; }
        input, textarea, select { width: 100%; padding: 12px; margin: 10px 0; background: #222; color: #fff; border: 1px solid #444; border-radius: 5px; box-sizing: border-box; }
        button { background: #00d4ff; color: #000; padding: 12px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; width: 100%; transition: 0.3s; }
        button:hover { background: #008fb3; }
        .order-row { background: #252525; padding: 15px; margin-top: 10px; border-left: 5px solid #00d4ff; border-radius: 4px; }
        .status-badge { background: #00d4ff; color: #000; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; float: right; }
    </style>
</head>
<body>
    <div class="dashboard">
        <h1>HILSEY PRO : COMMAND CENTER</h1>
        <div class="grid">
            <div class="box">
                <h3>📝 AI Generator & Editor</h3>
                <input type="text" id="topic" placeholder="Assignment Topic (e.g. TIA Financial Accounting)">
                <select id="docType">
                    <option value="Assignment">General Assignment</option>
                    <option value="Proposal">Research Proposal</option>
                    <option value="Case Study">Case Study Analysis</option>
                </select>
                <button onclick="generateAI()">GENERATE CONTENT</button>
                <textarea id="aiResult" rows="12" placeholder="AI-generated content will appear here for you to edit..."></textarea>
            </div>
            <div class="box">
                <h3>📥 Incoming TIA Orders</h3>
                <div id="orderList">
                    <p style="color: #666;">Waiting for student requests...</p>
                </div>
                <button onclick="loadOrders()" style="margin-top:15px; background:#333; color:#aaa;">REFRESH FEED</button>
            </div>
        </div>
    </div>
    <script>
        async function generateAI() {
            const topic = document.getElementById('topic').value;
            const type = document.getElementById('docType').value;
            document.getElementById('aiResult').value = "Hilsey AI is thinking...";
            const res = await fetch('/api/ai/copilot', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({topic, type})
            });
            const data = await res.json();
            document.getElementById('aiResult').value = data.content;
        }
        async function loadOrders() {
            const res = await fetch('/api/orders');
            const data = await res.json();
            const container = document.getElementById('orderList');
            container.innerHTML = data.map(o => `
                <div class="order-row">
                    <span class="status-badge">PENDING PRINT</span>
                    <strong>ID:</strong> ${o.reg}<br>
                    <strong>Service:</strong> ${o.doc_type}<br>
                    <small style="color:#888;">${o.time}</small>
                </div>
            `).join('') || "No active orders.";
        }
        setInterval(loadOrders, 5000);
    </script>
</body>
</html>
"""

@app.route('/')
def dashboard():
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/ai/copilot', methods=['POST'])
def ai_logic():
    data = request.json
    topic = data.get('topic', 'N/A')
    doc_type = data.get('type', 'Doc')
    ai_text = f"HILSEY AI GENERATED {doc_type.upper()}\n\nTOPIC: {topic}\n\n[DRAFT CONTENT]: Based on the TIA curriculum, this {doc_type} explores the core components of {topic}. It includes an introduction, literature review, and practical application for Tanzania's current economic climate..."
    return jsonify({"content": ai_text})

@app.route('/api/orders', methods=['GET'])
def get_orders():
    return jsonify(orders)

@app.route('/api/order/submit', methods=['POST'])
def submit_order():
    data = request.json
    orders.append({
        "reg": data.get('reg', 'Unknown'),
        "doc_type": data.get('type', 'General'),
        "time": "Received"
    })
    return jsonify({"message": "Success"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

python3 app.py
curl ifconfig.me
python3 app.py
curl ifconfig.me
fuser -k 5000/tcp
python3 app.py
curl ifconfig.me
ifconfig.me
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
0693
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok
ngrok config add-authtoken DOAQ5Q5SR6S62Q3ACWPZE7Z6NTH3ZMLF\
python3 app.py
ngrok http 5000
sudo tar -xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok
ngrok http 5000
sudo fuser -k 5000/tcp
python3 app.py
ngrok http 5000
python3 app.py
killall python3 && killall ngrok
python3 app.py
ngrok http 5000 --region us
ngrok config add-authtoken DOAQ5Q5SR6S62Q3ACWPZE7Z6NTH3ZMLF
python3 app.py
ngrok config edit
ngrok http 5000
pkill ngrok
python3 app.py
pkill -9 ngrok
python3 app.py & ngrok http 5000 --authtoken DOAQ5Q5SR6S62Q3ACWPZE7Z6NTH3ZMLF
killall -9 python3 ngrok
python3 app.py & ngrok http 5000 --authtoken DOAQ5Q5SR6S62Q3ACWPZE7Z6NTH3ZMLF
python3 app.py
ls
find ~ -name "app.py"
ls /mnt/c/Users/
python3 app.py
find ~ -maxdepth 3 -name "app.py"
sudo fuser -k 5000/tcp
app.run(host='0.0.0.0', port=8080)
nano app.py
python3 app.py
from flask import Flask, render_template_string, jsonify, request
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
HTML_TEMPLATE = """
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HILSEY STATIONARY PRO | ACADEMIC HUB</title>
    <style>
        :root { --neon-blue: #00d4ff; --bg-dark: #050a14; --card-bg: #0a1324; }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg-dark); color: #e0e0e0; margin: 0; padding: 20px; }
        
        /* Header Area */
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--neon-blue); padding-bottom: 20px; margin-bottom: 30px; }
        .logo-area h1 { margin: 0; color: var(--neon-blue); letter-spacing: 3px; font-size: 2.5rem; }
        
        /* Layout Grid */
        .main-container { display: grid; grid-template-columns: 350px 1fr 300px; gap: 20px; }
        
        .panel { background: var(--card-bg); border: 1px solid #1e2a44; border-radius: 15px; padding: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        
        /* Interactive Buttons */
        .btn { background: rgba(0, 212, 255, 0.1); border: 1px solid var(--neon-blue); color: var(--neon-blue); padding: 15px; margin: 10px 0; border-radius: 8px; cursor: pointer; transition: 0.3s; width: 100%; text-align: left; font-weight: bold; }
        .btn:hover { background: var(--neon-blue); color: #000; box-shadow: 0 0 20px var(--neon-blue); }
        
        /* Empty Space Fix: The "Workspace" */
        #workspace { background: rgba(255,255,255,0.02); border: 2px dashed #1e2a44; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 500px; text-align: center; }
        
        /* The "Super App" Features */
        .stat-card { background: #112240; padding: 15px; margin-bottom: 10px; border-radius: 10px; border-left: 4px solid var(--neon-blue); }
        .map-placeholder { height: 150px; background: #1b263b; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-style: italic; color: #555; }
        
        /* Transitions */
        .active-view { animation: fadeIn 0.5s forwards; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

    <div class="header">
        <div class="logo-area">
            <h1>HILSEY STATIONARY</h1>
            <small>TIA ACADEMIC LOGISTICS HUB • V2.0 PRO</small>
        </div>
        <div style="text-align:right">
            <span style="color: #4caf50;">● SYSTEM ONLINE</span><br>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
from flask import Flask, render_template_string, jsonify, request
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
HTML_TEMPLATE = """
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HILSEY STATIONARY PRO | ACADEMIC HUB</title>
    <style>
        :root { --neon-blue: #00d4ff; --bg-dark: #050a14; --card-bg: #0a1324; }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg-dark); color: #e0e0e0; margin: 0; padding: 20px; }
        
        /* Header Area */
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--neon-blue); padding-bottom: 20px; margin-bottom: 30px; }
        .logo-area h1 { margin: 0; color: var(--neon-blue); letter-spacing: 3px; font-size: 2.5rem; }
        
        /* Layout Grid */
        .main-container { display: grid; grid-template-columns: 350px 1fr 300px; gap: 20px; }
        
        .panel { background: var(--card-bg); border: 1px solid #1e2a44; border-radius: 15px; padding: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        
        /* Interactive Buttons */
        .btn { background: rgba(0, 212, 255, 0.1); border: 1px solid var(--neon-blue); color: var(--neon-blue); padding: 15px; margin: 10px 0; border-radius: 8px; cursor: pointer; transition: 0.3s; width: 100%; text-align: left; font-weight: bold; }
        .btn:hover { background: var(--neon-blue); color: #000; box-shadow: 0 0 20px var(--neon-blue); }
        
        /* Empty Space Fix: The "Workspace" */
        #workspace { background: rgba(255,255,255,0.02); border: 2px dashed #1e2a44; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 500px; text-align: center; }
        
        /* The "Super App" Features */
        .stat-card { background: #112240; padding: 15px; margin-bottom: 10px; border-radius: 10px; border-left: 4px solid var(--neon-blue); }
        .map-placeholder { height: 150px; background: #1b263b; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-style: italic; color: #555; }
        
        /* Transitions */
        .active-view { animation: fadeIn 0.5s forwards; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

    <div class="header">
        <div class="logo-area">
            <h1>HILSEY STATIONARY</h1>
            <small>TIA ACADEMIC LOGISTICS HUB • V2.0 PRO</small>
        </div>
        <div style="text-align:right">
            <span style="color: #4caf50;">● SYSTEM ONLINE</span><br>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

if __name__ == "__main__":
from flask import Flask, render_template_string, jsonify, request
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
HTML_TEMPLATE = """
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HILSEY STATIONARY PRO | ACADEMIC HUB</title>
    <style>
        :root { --neon-blue: #00d4ff; --bg-dark: #050a14; --card-bg: #0a1324; }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg-dark); color: #e0e0e0; margin: 0; padding: 20px; }
        
        /* Header Area */
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--neon-blue); padding-bottom: 20px; margin-bottom: 30px; }
        .logo-area h1 { margin: 0; color: var(--neon-blue); letter-spacing: 3px; font-size: 2.5rem; }
        
        /* Layout Grid */
        .main-container { display: grid; grid-template-columns: 350px 1fr 300px; gap: 20px; }
        
        .panel { background: var(--card-bg); border: 1px solid #1e2a44; border-radius: 15px; padding: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        
        /* Interactive Buttons */
        .btn { background: rgba(0, 212, 255, 0.1); border: 1px solid var(--neon-blue); color: var(--neon-blue); padding: 15px; margin: 10px 0; border-radius: 8px; cursor: pointer; transition: 0.3s; width: 100%; text-align: left; font-weight: bold; }
        .btn:hover { background: var(--neon-blue); color: #000; box-shadow: 0 0 20px var(--neon-blue); }
        
        /* Empty Space Fix: The "Workspace" */
        #workspace { background: rgba(255,255,255,0.02); border: 2px dashed #1e2a44; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 500px; text-align: center; }
        
        /* The "Super App" Features */
        .stat-card { background: #112240; padding: 15px; margin-bottom: 10px; border-radius: 10px; border-left: 4px solid var(--neon-blue); }
        .map-placeholder { height: 150px; background: #1b263b; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-style: italic; color: #555; }
        
        /* Transitions */
        .active-view { animation: fadeIn 0.5s forwards; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

    <div class="header">
        <div class="logo-area">
            <h1>HILSEY STATIONARY</h1>
            <small>TIA ACADEMIC LOGISTICS HUB • V2.0 PRO</small>
        </div>
        <div style="text-align:right">
            <span style="color: #4caf50;">● SYSTEM ONLINE</span><br>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
source venv/bin/activate
pip install flask flask-cors --break-system-packages
nano app.py
python3 app.py
hostname -I
explorer.exe .
rm app.py
nano app.py
python3 app.py
app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py\
from flask import Flask, render_template_string
app = Flask(__name__)
# This is the "Architecture" of the entire 12-point system
HTML_TEMPLATE = """
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>HILSEY SUPER-APP | TOTAL ECOSYSTEM</title>
    <style>
        :root { --neon: #00d4ff; --bg: #03070f; --panel: #0a1324; --text: #e0e6ed; --accent: #ff0055; }
        body { background: var(--bg); color: var(--text); font-family: 'Inter', sans-serif; margin: 0; display: flex; height: 100vh; }
        
        /* SIDEBAR NAVIGATION (12 DEPARTMENTS) */
        .sidebar { width: 300px; background: var(--panel); border-right: 1px solid #1e2a44; overflow-y: auto; padding-bottom: 50px; }
        .logo { padding: 30px; text-align: center; color: var(--neon); border-bottom: 1px solid #1e2a44; font-weight: 900; }
        .nav-label { padding: 15px 25px 5px; font-size: 0.7rem; color: #56657a; text-transform: uppercase; display: block; }
        .nav-item { padding: 12px 25px; cursor: pointer; display: flex; align-items: center; font-size: 0.85rem; border-left: 3px solid transparent; }
        .nav-item:hover { background: rgba(0, 212, 255, 0.05); color: var(--neon); }
        .nav-item.active { background: rgba(0, 212, 255, 0.1); color: var(--neon); border-left-color: var(--neon); }

        /* CONTENT VIEWPORT */
        .viewport { flex: 1; padding: 40px; overflow-y: auto; background: radial-gradient(circle at top right, #0a1324, #03070f); }
        .module { display: none; animation: fadeIn 0.3s forwards; }
        .module.active { display: block; }

        /* REUSABLE UI COMPONENTS */
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-top: 20px; }
        .card { background: rgba(255,255,255,0.03); border: 1px solid #1e2a44; padding: 25px; border-radius: 15px; transition: 0.3s; }
        .card:hover { border-color: var(--neon); box-shadow: 0 0 20px rgba(0,212,255,0.1); }
        .btn-pro { background: var(--neon); color: #000; border: none; padding: 12px 24px; border-radius: 8px; font-weight: bold; cursor: pointer; }
        
        /* SPECIFIC FEATURE STYLES */
        .video-call-area { width: 100%; height: 400px; background: #000; border-radius: 12px; display: flex; flex-direction: column; align-items: center; justify-content: center; position: relative; }
        .timer-display { font-size: 3rem; font-weight: bold; color: var(--accent); }
        
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="logo">HILSEY SUPER-APP</div>
        
        <span class="nav-label">1. ACADEMIC HUB</span>
        <div class="nav-item active" onclick="nav('m-dash', this)">📊 Course Overview</div>
</body>
</html>
"""

@app.route('/')
def home(): return render_template_string(HTML_TEMPLATE)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
from flask import Flask, render_template_string
app = Flask(__name__)
# This is the "Architecture" of the entire 12-point system
HTML_TEMPLATE = """
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>HILSEY SUPER-APP | TOTAL ECOSYSTEM</title>
    <style>
        :root { --neon: #00d4ff; --bg: #03070f; --panel: #0a1324; --text: #e0e6ed; --accent: #ff0055; }
        body { background: var(--bg); color: var(--text); font-family: 'Inter', sans-serif; margin: 0; display: flex; height: 100vh; }
        
        /* SIDEBAR NAVIGATION (12 DEPARTMENTS) */
        .sidebar { width: 300px; background: var(--panel); border-right: 1px solid #1e2a44; overflow-y: auto; padding-bottom: 50px; }
        .logo { padding: 30px; text-align: center; color: var(--neon); border-bottom: 1px solid #1e2a44; font-weight: 900; }
        .nav-label { padding: 15px 25px 5px; font-size: 0.7rem; color: #56657a; text-transform: uppercase; display: block; }
        .nav-item { padding: 12px 25px; cursor: pointer; display: flex; align-items: center; font-size: 0.85rem; border-left: 3px solid transparent; }
        .nav-item:hover { background: rgba(0, 212, 255, 0.05); color: var(--neon); }
        .nav-item.active { background: rgba(0, 212, 255, 0.1); color: var(--neon); border-left-color: var(--neon); }

        /* CONTENT VIEWPORT */
        .viewport { flex: 1; padding: 40px; overflow-y: auto; background: radial-gradient(circle at top right, #0a1324, #03070f); }
        .module { display: none; animation: fadeIn 0.3s forwards; }
        .module.active { display: block; }

        /* REUSABLE UI COMPONENTS */
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-top: 20px; }
        .card { background: rgba(255,255,255,0.03); border: 1px solid #1e2a44; padding: 25px; border-radius: 15px; transition: 0.3s; }
        .card:hover { border-color: var(--neon); box-shadow: 0 0 20px rgba(0,212,255,0.1); }
        .btn-pro { background: var(--neon); color: #000; border: none; padding: 12px 24px; border-radius: 8px; font-weight: bold; cursor: pointer; }
        
        /* SPECIFIC FEATURE STYLES */
        .video-call-area { width: 100%; height: 400px; background: #000; border-radius: 12px; display: flex; flex-direction: column; align-items: center; justify-content: center; position: relative; }
        .timer-display { font-size: 3rem; font-weight: bold; color: var(--accent); }
        
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="logo">HILSEY SUPER-APP</div>
        
        <span class="nav-label">1. ACADEMIC HUB</span>
        <div class="nav-item active" onclick="nav('m-dash', this)">📊 Course Overview</div>
</body>
</html>
"""

@app.route('/')
def home(): return render_template_string(HTML_TEMPLATE)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
from flask import Flask, render_template_string
app = Flask(__name__)
# This is the "Architecture" of the entire 12-point system
HTML_TEMPLATE = """
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>HILSEY SUPER-APP | TOTAL ECOSYSTEM</title>
    <style>
        :root { --neon: #00d4ff; --bg: #03070f; --panel: #0a1324; --text: #e0e6ed; --accent: #ff0055; }
        body { background: var(--bg); color: var(--text); font-family: 'Inter', sans-serif; margin: 0; display: flex; height: 100vh; }
        
        /* SIDEBAR NAVIGATION (12 DEPARTMENTS) */
        .sidebar { width: 300px; background: var(--panel); border-right: 1px solid #1e2a44; overflow-y: auto; padding-bottom: 50px; }
        .logo { padding: 30px; text-align: center; color: var(--neon); border-bottom: 1px solid #1e2a44; font-weight: 900; }
        .nav-label { padding: 15px 25px 5px; font-size: 0.7rem; color: #56657a; text-transform: uppercase; display: block; }
        .nav-item { padding: 12px 25px; cursor: pointer; display: flex; align-items: center; font-size: 0.85rem; border-left: 3px solid transparent; }
        .nav-item:hover { background: rgba(0, 212, 255, 0.05); color: var(--neon); }
        .nav-item.active { background: rgba(0, 212, 255, 0.1); color: var(--neon); border-left-color: var(--neon); }

        /* CONTENT VIEWPORT */
        .viewport { flex: 1; padding: 40px; overflow-y: auto; background: radial-gradient(circle at top right, #0a1324, #03070f); }
        .module { display: none; animation: fadeIn 0.3s forwards; }
        .module.active { display: block; }

        /* REUSABLE UI COMPONENTS */
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-top: 20px; }
        .card { background: rgba(255,255,255,0.03); border: 1px solid #1e2a44; padding: 25px; border-radius: 15px; transition: 0.3s; }
        .card:hover { border-color: var(--neon); box-shadow: 0 0 20px rgba(0,212,255,0.1); }
        .btn-pro { background: var(--neon); color: #000; border: none; padding: 12px 24px; border-radius: 8px; font-weight: bold; cursor: pointer; }
        
        /* SPECIFIC FEATURE STYLES */
        .video-call-area { width: 100%; height: 400px; background: #000; border-radius: 12px; display: flex; flex-direction: column; align-items: center; justify-content: center; position: relative; }
        .timer-display { font-size: 3rem; font-weight: bold; color: var(--accent); }
        
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="logo">HILSEY SUPER-APP</div>
        
        <span class="nav-label">1. ACADEMIC HUB</span>
        <div class="nav-item active" onclick="nav('m-dash', this)">📊 Course Overview</div>
</body>
</html>
"""

@app.route('/')
def home(): return render_template_string(HTML_TEMPLATE)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
sudo fuser -k 5000/tcp
nano app.py
python3 app.py
mkdir templates
nano templates/index.html
from flask import Flask, render_template
app = Flask(__name__)
@app.route('/')
def home():
if __name__ == "__main__":
from flask import Flask, render_template
app = Flask(__name__)
@app.route('/')
def home():
if __name__ == "__main__":;     app.run(host='0.0.0.0', port=5000)from flask import Flask, render_template
app = Flask(__name__)
@app.route('/')
def home():
if __name__ == "__main__":
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
cp app.py backup_camera.py
nano app.py
python3 app.py
cp app.py HILSEY_SUPERAPP_V1_FINAL.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
cp app.py app_backup_v2.py
nano app.py
python3 app.py
cp app.py app_working_march13.py
nano app.py
python3 app.py
nano app.py
python3 app.py
Open nano app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
pip install flask openai
nano app.py
python3 app.py
pip install openai flask
pip install openai flask --break-system-packages
source hilsey_env/bin/activate
sudo apt update
python3 app.py
python3 -m venv hilsey_env
ls -d hilsey_env
source hilsey_env/bin/activate
pip install openai flask
sudo apt update
python3 app.py
nano app.py
python3 app.py
ls
find ~ -name "app.py"
cd /path/to/your/folder
find ~ -name "hilsey_env" -type d 2>/dev/null
cd ~
ls
mkdir ~/hilsey_project && cd ~/hilsey_project
mkdir ~/hilsey_ai
cd ~/hilsey_ai
python3 -m venv hilsey_env
source hilsey_env/bin/activate
pip install flask openai --break-system-packages
nano app.py
python3 app.py
nano app.py
python app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
cd ~/hilsey_ai
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
ls
python3 app.py
ls
bash
nano app.py
python app.py
python3 app.py
cd ~/hilsey_ai
ls
python3 app.py
nano app.py
python app.py
python3 app.py
nano app.py
ls -d */
mkdir -p ~/hilsey_ai && cd ~/hilsey_ai && cat << 'EOF' > app.py
from flask import Flask, render_template_string, request, jsonify
from openai import OpenAI

app = Flask(__name__)
client = OpenAI(api_key="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")

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>HILSEY PRO SYSTEM</title>
    <style>
        :root { --neon:#00d4ff; --bg:#02060e; --panel:#0a1324; --text:#e0e6ed; }
        body { background:var(--bg); color:var(--text); font-family:sans-serif; margin:0; display:flex; height:100vh; overflow:hidden; }
        .sidebar { width:220px; background:var(--panel); border-right:1px solid #1e2a44; padding:20px; }
        .nav-item { padding:15px; margin:10px 0; border-radius:8px; cursor:pointer; color:#8899a6; transition:0.3s; }
        .active { background:rgba(0,212,255,0.1); color:var(--neon); border-left:4px solid var(--neon); }
        .main { flex:1; padding:25px; overflow-y:auto; }
        .engine-container { display:flex; gap:20px; height:70vh; }
        .chat-area { flex:1; background:#050a14; border:1px solid #1e2a44; border-radius:10px; display:flex; flex-direction:column; }
        #chatBox { flex:1; overflow-y:auto; padding:15px; display:flex; flex-direction:column; gap:10px; }
        .paper-view { flex:1; background:white; color:#1a1a1a; padding:35px; border-radius:10px; overflow-y:auto; font-family:serif; line-height:1.6; }
        .msg { padding:10px; border-radius:8px; max-width:85%; font-size:14px; }
        .ai { background:#0a2a40; color:var(--neon); align-self:flex-start; }
        .user { background:#1e2a44; align-self:flex-end; }
        .input-wrap { display:flex; padding:15px; border-top:1px solid #1e2a44; }
        input { flex:1; background:#02060e; border:1px solid #1e2a44; color:white; padding:12px; border-radius:5px; outline:none; }
        .btn { background:var(--neon); border:none; padding:10px 20px; font-weight:bold; cursor:pointer; border-radius:5px; margin-left:10px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2 style="color:var(--neon)">HILSEY PRO</h2>
        <div class="nav-item active" onclick="show('writing')">🧠 AI Engine</div>
        <div class="nav-item" onclick="show('db')">📁 Student DB</div>
    </div>
    <div class="main">
        <div id="writing" class="page">
            <h1>Writing Engine</h1>
            <div class="engine-container">
                <div class="chat-area">
                    <div id="chatBox"><div class="msg ai">Ready, William. Let's work.</div></div>
                    <div class="input-wrap">
                        <input id="userInput" placeholder="Type your instruction...">
                        <button class="btn" onclick="runAI()">GENERATE</button>
                    </div>
                </div>
                <div class="paper-view" id="paper"><em>Your document preview...</em></div>
            </div>
            <button class="btn" style="background:#25d366; margin-top:15px;" onclick="share()">📲 SHARE TO WHATSAPP</button>
        </div>
        <div id="db" class="page" style="display:none">
            <h1>TIA Student Records</h1>
            <table style="width:100%; color:white; border-collapse:collapse;">
                <tr style="border-bottom:1px solid #333;"><th>ID</th><th>Name</th><th>Course</th></tr>
                <tr><td>TIA-001</td><td>William Hilsey</td><td>Computer Science</td></tr>
            </table>
        </div>
    </div>
    <script>
        function show(id) {
            document.querySelectorAll('.page').forEach(p => p.style.display = 'none');
            document.getElementById(id).style.display = 'block';
        }
        async function runAI() {
            const input = document.getElementById('userInput');
            const chat = document.getElementById('chatBox');
            const paper = document.getElementById('paper');
            const val = input.value;
            chat.innerHTML += `<div class="msg user">${val}</div>`;
            input.value = '';
            chat.innerHTML += `<div id="load" class="msg ai">Thinking...</div>`;
            try {
                const res = await fetch('/ai', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({prompt: val})
                });
                const data = await res.json();
                document.getElementById('load').remove();
                chat.innerHTML += `<div class="msg ai">Finished.</div>`;
                paper.innerHTML = `<h2>TIA OFFICIAL REPORT</h2><hr><p>${data.reply}</p>`;
            } catch(e) { document.getElementById('load').innerText = "Error: Check credits."; }
        }
        function share() {
            const content = document.getElementById('paper').innerText;
            window.open(`https://wa.me/?text=${encodeURIComponent(content)}`, '_blank');
        }
    </script>
</body>
</html>
"""

@app.route("/")
def home(): return render_template_string(HTML)

@app.route("/ai", methods=["POST"])
def ai():
    try:
        data = request.json
        res = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": data['prompt']}]
        )
        return jsonify({"reply": res.choices[0].message.content})
    except Exception as e:
        return jsonify({"reply": f"Error: {str(e)}"}), 500

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
nano app.py
python3 app.py
echo "flask" > requirements.txt
echo "openai" >> requirements.txt
echo "flask" > requirements.txt
echo "openai" >> requirements.txt
git remote add origin https://github.com/hilsey-pro/hilsey-pro.git
cd ~/hilsey_ai
git init
git add .
git commit -m "First live build"
git config --global user.email "william@example.com"
git config --global user.name "William Hilsey"
git commit -m "First live build"
git push -u origin main
git add .
git commit -m "First live build"
git push -f origin main
git init
git add .
git commit -m "Emergency Fix"
git branch -M main
git remote remove origin
git remote add origin https://github.com/hilsey-pro/hilsey-pro.git
git push -f origin main
git remote add origin https://github.com/hilsey-pro/hilsey-pro.git
git branch -M main
git push -u origin main
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
git push -u origin main
git status
git push -u origin main:main
git commit --allow-empty -m "Forcing update"
git remote set-url origin https://github.com/hilsey-pro/hilsey-pro.git
git push -u origin main
python3 app.py
sudo mkdir -p /etc/apt/keyrings
sudo apt update
sudo apt install antigravity
sudo tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

sudo dnf makecache
sudo dnf install antigravity
sudo tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

sudo dnf makecache
ls
sudo apt update
mkdir hilsey-pro
cd hilsey-pro
npm init -y
npm create vite@latest . -- --template vanilla
mkdir hilsey-pro
cd hilsey-pro
npm init -y
npm create vite@latest . -- --template vanilla
y
npm create vite@latest . -- --template vanilla
led
npm error A complete log of this run can be found in: /home/poulbilliards/.npm/_logs/2026-03-22T14_43_42_403Z-debug/np
sudo rm -rf node_modules package-lock.json
sudo apt install build-essential
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
cd ~/hilsey-pro
npm install
cd ~/hilsey-pro
npm run dev
cat package.json
"scripts": {
}
cd ~/hilsey-pro
npm install
npm run dev
nano package.json
npm install
npm run dev
ls
nano index.html
cd ~/hilsey-pro
ls
npm run dev
cd ~/hilsey-pro
npm run dev
ls -l
npm run dev
nano index.html
npm run dev
cd Desktop/HilseyPro/server
# Example for Windows PowerShell:
cd "C:\Users\William\Desktop\HilseyPro\server"
# Example for Ubuntu/WSL:
cd /mnt/c/Users/William/Desktop/HilseyPro/server
cd /mnt/c/Users/YOUR_WINDOWS_USERNAME/Desktop/HilseyPro/server
ls
npm install express jsonwebtoken @google-cloud/storage dotenv cors
ls
npm install express jsonwebtoken @google-cloud/storage dotenv cors
node server.js
ls
npm install express jsonwebtoken @google-cloud/storage dotenv cors
node server.js
sudo apt update && sudo apt install nodejs npm -y
sudo apt clean && sudo apt autoremove
sudo apt update --fix-missing
sudo apt install -f
sudo apt install nodejs npm -y
sudo apt remove --purge nodejs npm
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
mkdir ~/HilseyPro
cd ~/HilseyPro
nano index.html
nano main.js
nano index.html
nano main.js
explorer.exe .
npm run dev
explorer.exe .
index.html
nano index.html
nano main.js
explorer.exe .
cd ~/HilseyPro
mkdir -p src/pages
nano src/pages/Marketplace.jsx
nano src/App.jsx
npm install lucide-react
npm run dev
src/pages/Marketplace.jsx
npm run dev
sudo apt remove --purge nodejs npm && sudo apt autoremove && sudo apt update
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
# Go to your home directory
cd ~
# Create a fresh, working project structure
npm create vite@latest HilseyPro -- --template react
cd ~/HilseyPro
npm install
npm install lucide-reactnpm install
npm install lucide-react# This gets the modern version (v20)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# This installs it
sudo apt install -y nodejs
cd ~
npm create vite@latest HilseyPro -- --template react
sudo apt remove --purge nodejs npm -y && sudo apt autoremove -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v
# Go to your home folder
cd ~
# Create the project (Wait for it to finish)
npm create vite@latest HilseyPro -- --template react
# Move into the folder
cd HilseyPro
# Install the "Engine Parts"
npm install
# Install the Icons for the Marketplace
npm install lucide-react
nano src/App.jsx
nano src/app.jsx
ls
sudo apt
npm run dev\
npm run dev
ls
C:\Users\User\.gemini\antigravity\scratch\hilsey-pro-portal
