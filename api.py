from flask import Flask, jsonify, request
import sqlite3
from flask_cors import CORS

app = Flask(__name__)
CORS(app) 
def get_db_connection():
    conn = sqlite3.connect('parking.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/api/locations', methods=['GET'])
def get_locations():
    conn = get_db_connection()
    rows = conn.execute('SELECT * FROM locations').fetchall()
    conn.close()
    return jsonify([dict(row) for row in rows])

@app.route('/api/action', methods=['POST', 'OPTIONS'])
def log_action():
    if request.method == 'OPTIONS':
        return '', 200
        
    data = request.json
    action = data.get('action', 'Unknown')
    location = data.get('location', 'General')
    
    print(f"--- !!! ДІЯ КОРИСТУВАЧА: {action} --- Локація: {location} ---")
    
    return jsonify({"status": "success"}), 200





if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)