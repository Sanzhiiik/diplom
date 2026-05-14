from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import json
from datetime import datetime

app = FastAPI(title="Anti-Collision Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Хаб: хранит подключения Flutter-приложений ─────────────────
class ConnectionHub:
    def __init__(self):
        self.app_clients: list[WebSocket] = []
        self.last_data: dict = {}
        self.esp32_connected: bool = False

    async def add_app(self, ws: WebSocket):
        await ws.accept()
        self.app_clients.append(ws)
        print(f"[{_now()}] [APP] Приложение подключилось. Всего: {len(self.app_clients)}")
        # Сразу отправляем последние данные чтобы экран не был пустым
        if self.last_data:
            try:
                await ws.send_text(json.dumps(self.last_data))
            except Exception:
                pass

    def remove_app(self, ws: WebSocket):
        if ws in self.app_clients:
            self.app_clients.remove(ws)
        print(f"[{_now()}] [APP] Приложение отключилось. Осталось: {len(self.app_clients)}")

    async def broadcast_to_apps(self, data: dict):
        """Рассылаем данные от ESP32 всем подключённым приложениям"""
        self.last_data = data
        dead = []
        for ws in self.app_clients:
            try:
                await ws.send_text(json.dumps(data))
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.remove_app(ws)

hub = ConnectionHub()

def _now() -> str:
    return datetime.now().strftime("%H:%M:%S")

# ─── WebSocket для ESP32 ─────────────────────────────────────────
@app.websocket("/ws/sensor")
async def sensor_endpoint(ws: WebSocket):
    await ws.accept()
    hub.esp32_connected = True
    print(f"[{_now()}] [ESP32] Подключился! Жду данные...")

    try:
        while True:
            raw = await ws.receive_text()
            data = json.loads(raw)

            # Лог в терминал
            dist = data.get("min_distance", -1)
            level = data.get("level", "?")
            if dist > 0:
                print(f"[{_now()}] [ESP32] {dist:.1f} см — {level.upper()}")
            else:
                print(f"[{_now()}] [ESP32] Нет объектов")

            # Пересылаем в Flutter
            await hub.broadcast_to_apps(data)

    except WebSocketDisconnect:
        hub.esp32_connected = False
        print(f"[{_now()}] [ESP32] Отключился")
    except Exception as e:
        hub.esp32_connected = False
        print(f"[{_now()}] [ESP32] Ошибка: {e}")

# ─── WebSocket для Flutter приложения ───────────────────────────
@app.websocket("/ws/app")
async def app_endpoint(ws: WebSocket):
    await hub.add_app(ws)   
    try:
        while True:
            # Просто держим соединение живым
            await ws.receive_text()
    except WebSocketDisconnect:
        hub.remove_app(ws)
    except Exception:
        hub.remove_app(ws)

# ─── HTTP эндпоинт — проверить что бэкенд работает ──────────────
@app.get("/")
def status():
    return {
        "status": "running",
        "esp32_connected": hub.esp32_connected,
        "app_clients": len(hub.app_clients),
        "last_distance_cm": hub.last_data.get("min_distance", None),
        "last_level": hub.last_data.get("level", None),
    }
