#include <Arduino.h>
#include <WiFi.h>
#include <WebSocketsClient.h>
#include <ArduinoJson.h>

const char* WIFI_SSID = "Sanzhik";
const char* WIFI_PASS = "12345678san";
const char* WS_HOST   = "172.20.10.8";
const uint16_t WS_PORT = 8000;
const char* WS_PATH   = "/ws/sensor";

struct Sensor {
  const char* zone;
  uint8_t trig;
  uint8_t echo;
};

Sensor sensors[] = {
  {"left",  17, 16},
  {"right", 21, 19},
  {"rear",  22, 5}     // TRIG D22, ECHO D5
};
const int COUNT = 3;

const float DANGER_CM  = 100.0;
const float WARNING_CM = 250.0;

WebSocketsClient webSocket;
unsigned long lastSendMs = 0;

float measure(uint8_t trig, uint8_t echo) {
  digitalWrite(trig, LOW);  delayMicroseconds(2);
  digitalWrite(trig, HIGH); delayMicroseconds(10);
  digitalWrite(trig, LOW);
  long d = pulseIn(echo, HIGH, 30000UL);
  return d == 0 ? -1.0f : d * 0.0343f / 2.0f;
}

void wsEvent(WStype_t type, uint8_t* p, size_t l) {
  if (type == WStype_CONNECTED)
    Serial.println("[WS] подключился к бэкенду");
  if (type == WStype_DISCONNECTED)
    Serial.println("[WS] переподключаюсь...");
}

void setup() {
  Serial.begin(115200);
  for (int i = 0; i < COUNT; i++) {
    pinMode(sensors[i].trig, OUTPUT);
    pinMode(sensors[i].echo, INPUT);
    digitalWrite(sensors[i].trig, LOW);
  }
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(400); Serial.print(".");
  }
  Serial.printf("\nIP: %s\n", WiFi.localIP().toString().c_str());
  webSocket.begin(WS_HOST, WS_PORT, WS_PATH);
  webSocket.onEvent(wsEvent);
  webSocket.setReconnectInterval(3000);
}

void loop() {
  webSocket.loop();

  float dist[COUNT];
  float minDist = 9999.0f;

  for (int i = 0; i < COUNT; i++) {
    dist[i] = measure(sensors[i].trig, sensors[i].echo);
    delay(30);
    if (dist[i] > 0 && dist[i] < minDist)
      minDist = dist[i];
    Serial.printf("[%s] %.1f см\n", sensors[i].zone, dist[i]);
  }

  if (millis() - lastSendMs >= 200) {
    lastSendMs = millis();

    String level = "safe";
    if (minDist < DANGER_CM) level = "danger";
    else if (minDist < WARNING_CM) level = "warning";

    JsonDocument doc;
    doc["ts"]           = millis();
    doc["min_distance"] = minDist > 9000 ? -1 : minDist;
    doc["level"]        = level;

    JsonObject readings = doc["readings"].to<JsonObject>();
    readings["left"]  = dist[0];
    readings["right"] = dist[1];
    readings["rear"]  = dist[2];   // теперь реальные данные
    readings["front"] = -1;

    String json;
    serializeJson(doc, json);
    webSocket.sendTXT(json);
  }
  delay(20);
}