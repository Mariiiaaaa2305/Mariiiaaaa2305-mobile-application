import paho.mqtt.client as mqtt
import time
import random

# Налаштування брокера (має бути ТАКИЙ ЖЕ як у Flutter)
BROKER = "broker.emqx.io"
PORT = 1883

client = mqtt.Client()

try:
    client.connect(BROKER, PORT, 60)
    print(f"✅ Емулятор підключився до {BROKER}")
except Exception as e:
    print(f"❌ Помилка підключення: {e}")
    exit()

# Ключі мають бути маленькими англійськими літерами, як ми прописали в MqttService
parkings = {
    "forum": {"name": "ТЦ Форум Львів", "total": 150, "free": 75},
    "victoria": {"name": "ТРЦ Victoria Gardens", "total": 300, "free": 120},
    "airport": {"name": "Аеропорт Львів", "total": 120, "free": 10},
    "valova": {"name": "Паркінг на Валовій", "total": 80, "free": 45}
}

while True:
    for key, data in parkings.items():
        # Рандомна зміна кількості місць
        change = random.randint(-2, 2)
        data["free"] = max(0, min(data["free"] + change, data["total"]))
        
        payload = f"{data['free']}/{data['total']}"
        topic = f"parking/{key}/status"
        
        client.publish(topic, payload)
        print(f"📡 Відправлено: {topic} -> {payload}")

    time.sleep(5) # Пауза 5 секунд