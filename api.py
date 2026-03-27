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

@app.route('/api/user/update', methods=['PUT'])
def update_profile():
    data = request.json
    email = data.get('email')
    conn = get_db_connection()
    conn.execute('''
        UPDATE users SET fullName=?, carBrand=?, carModel=?, carPlate=?
        WHERE email=?''', 
        (data['fullName'], data['carBrand'], data['carModel'], data['carPlate'], email))
    conn.commit()
    conn.close()
    print(f"--- [PUT] ПРОФІЛЬ ОНОВЛЕНО: {email} ---")
    return jsonify({"status": "success"}), 200

@app.route('/api/bookings/<int:id>', methods=['DELETE'])
def delete_booking(id):
    conn = get_db_connection()
    conn.execute('DELETE FROM bookings WHERE id = ?', (id,))
    conn.commit()
    conn.close()
    print(f"--- [DELETE] ВИДАЛЕНО БРОНЮВАННЯ ID: {id} ---")
    return jsonify({"status": "success"}), 200

@app.route('/api/action', methods=['POST', 'OPTIONS'])
def log_action():
    if request.method == 'OPTIONS': return '', 200
    data = request.json
    print(f"--- [POST] ДІЯ КОРИСТУВАЧА: {data.get('action')} ---")
    return jsonify({"status": "success"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)