#include <Arduino.h>
#include <WiFi.h>
#include "esp_camera.h"
#include "esp_http_server.h"

const char* WIFI_SSID = "Sanzhik";
const char* WIFI_PASS = "12345678san";

#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

httpd_handle_t stream_httpd = NULL;

static esp_err_t stream_handler(httpd_req_t *req) {
  camera_fb_t *fb = NULL;
  esp_err_t res = ESP_OK;
  char buf[64];
  httpd_resp_set_type(req, "multipart/x-mixed-replace;boundary=frame");
  while (true) {
    fb = esp_camera_fb_get();
    if (!fb) { res = ESP_FAIL; break; }
    size_t hlen = snprintf(buf, sizeof(buf),
      "--frame\r\nContent-Type: image/jpeg\r\n"
      "Content-Length: %u\r\n\r\n", fb->len);
    res = httpd_resp_send_chunk(req, buf, hlen);
    if (res == ESP_OK)
      res = httpd_resp_send_chunk(req, (const char*)fb->buf, fb->len);
    if (res == ESP_OK)
      res = httpd_resp_send_chunk(req, "\r\n", 2);
    esp_camera_fb_return(fb);
    if (res != ESP_OK) break;
  }
  return res;
}

void startStreamServer() {
  httpd_config_t config = HTTPD_DEFAULT_CONFIG();
  config.server_port = 81;
  httpd_uri_t uri = {
    .uri     = "/stream",
    .method  = HTTP_GET,
    .handler = stream_handler,
    .user_ctx = NULL
  };
  if (httpd_start(&stream_httpd, &config) == ESP_OK)
    httpd_register_uri_handler(stream_httpd, &uri);
}

bool initCamera() {
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer   = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM; config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM; config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM; config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM; config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk     = XCLK_GPIO_NUM;
  config.pin_pclk     = PCLK_GPIO_NUM;
  config.pin_vsync    = VSYNC_GPIO_NUM;
  config.pin_href     = HREF_GPIO_NUM;
  config.pin_sccb_sda = SIOD_GPIO_NUM;
  config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn     = PWDN_GPIO_NUM;
  config.pin_reset    = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  config.grab_mode    = CAMERA_GRAB_WHEN_EMPTY;
  config.fb_location  = CAMERA_FB_IN_PSRAM;
 if (psramFound()) {
  config.frame_size   = FRAMESIZE_VGA;   // 640x480
  config.jpeg_quality = 15;              // средне
  config.fb_count     = 2;
} else {
  config.frame_size   = FRAMESIZE_QVGA;  // 320x240
  config.jpeg_quality = 20;
  config.fb_count     = 1;
}
  return esp_camera_init(&config) == ESP_OK;
}

void setup() {
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  delay(2000);
  Serial.println("\n\n=== ESP32-CAM СТАРТ ===");

  Serial.println("Инициализация камеры...");
  if (!initCamera()) {
    Serial.println("ОШИБКА: камера не найдена!");
    delay(3000);
    ESP.restart();
  }
  Serial.println("Камера OK");

  Serial.printf("Подключаюсь к WiFi: %s\n", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\nОШИБКА: WiFi не подключился!");
    delay(3000);
    ESP.restart();
  }

  Serial.printf("\nWiFi OK! IP: %s\n", WiFi.localIP().toString().c_str());

  startStreamServer();
  Serial.printf("Стрим: http://%s:81/stream\n",
    WiFi.localIP().toString().c_str());
}

void loop() {
  delay(5000);
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi потерян — перезагрузка");
    ESP.restart();
  }
}