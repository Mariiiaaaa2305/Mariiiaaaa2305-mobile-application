import sqlite3

def create_database():
    conn = sqlite3.connect('parking.db')
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            spots TEXT NOT NULL,
            status_color TEXT NOT NULL
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            email TEXT UNIQUE,
            carBrand TEXT,
            carModel TEXT,
            carPlate TEXT,
            password TEXT
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            location TEXT NOT NULL,
            slot TEXT NOT NULL,
            time TEXT,
            email TEXT
        )
    ''')

    cursor.execute("DELETE FROM locations")
    locations = [
        ('ТЦ Форум Львів', '12 / 150', 'green'),
        ('ТРЦ Victoria Gardens', '3 / 300', 'orange'),
        ('Аеропорт "Львів"', '0 / 50', 'red'),
        ('Паркінг на Валовій', '45 / 80', 'green')
    ]
    cursor.executemany("INSERT INTO locations (name, spots, status_color) VALUES (?, ?, ?)", locations)

    cursor.execute('''
        INSERT OR IGNORE INTO users (fullName, email, carBrand, carModel, carPlate, password)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', ('Maria', 'tsiupka2305@gmail.com', 'Tesla', 'Model 3', 'BC 7777 AB', '123'))

    conn.commit()
    conn.close()
    print("✅ База даних оновлена: додано таблиці users та bookings!")

if __name__ == "__main__":
    create_database()