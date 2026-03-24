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

    cursor.execute("DELETE FROM locations")
    locations = [
        ('ТЦ Форум Львів', '12 / 150', 'green'),
        ('ТРЦ Victoria Gardens', '3 / 300', 'orange'),
        ('Аеропорт "Львів"', '0 / 50', 'red'),
        ('Паркінг на Валовій', '45 / 80', 'green')
    ]
    
    cursor.executemany("INSERT INTO locations (name, spots, status_color) VALUES (?, ?, ?)", locations)
    
    conn.commit()
    conn.close()
    print("✅ База даних створена, 4 локації додано!")

if __name__ == "__main__":
    create_database()