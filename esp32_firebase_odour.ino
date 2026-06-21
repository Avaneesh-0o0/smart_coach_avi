#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include <Adafruit_SHT31.h>
#include <math.h>

// Firebase Addons
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// =====================================================
// --- USER CONFIGURATION ---
// =====================================================
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// Firebase Credentials (As previously configured)
#define API_KEY "AIzaSyClxti6TNTNANt-J_Cv-T35Ip9PFjHgxjY"
#define DATABASE_URL "https://smart-odour-cr-default-rtdb.firebaseio.com/"
#define USER_EMAIL "tester@example.com"
#define USER_PASSWORD "123456"

// Real-Time Database Path
#define RTDB_PATH "/modules/odour_management/coaches/T1/washrooms/Toilet-1-Front-Left"

// =====================================================
// --- Pin Definitions ---
// =====================================================
const int PIN_MQ2   = 32;
const int PIN_MQ135 = 34;
const int PIN_MQ136 = 35;
const int PIN_MQ137 = 33;
const int PIN_DOOR  = 26; // Limit switch pin (connect between pin 26 and GND)
const int PIN_I2C_SDA = 14;
const int PIN_I2C_SCL = 27;

// =====================================================
// --- Fresh Air Raw Baselines ---
// =====================================================
const int RAW_BASELINE_MQ2   = 83;
const int RAW_BASELINE_MQ135 = 976;
const int RAW_BASELINE_MQ136 = 223;
const int RAW_BASELINE_MQ137 = 166;

const float ISO_CLEAN_PPM_MQ2   = 1.0;
const float ISO_CLEAN_PPM_MQ135 = 415.0;
const float ISO_CLEAN_PPM_MQ136 = 0.01;
const float ISO_CLEAN_PPM_MQ137 = 0.05;

float R0_MQ2, R0_MQ135, R0_MQ136, R0_MQ137;
const float RL_BOARD = 1.0;

// =====================================================
// --- Globals ---
// =====================================================
Adafruit_SHT31 sht30 = Adafruit_SHT31();
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

bool lastDoorState = false;
int doorEventsToday = 0;

unsigned long lastTransmitTime = 0;
const unsigned long TRANSMIT_INTERVAL_MS = 15000; // Fast real-time: 15 seconds

// =====================================================
// --- Sensor Math & Status ---
// =====================================================
float calculateRs(int rawADC) {
  if (rawADC <= 5)    return 999999.0;
  if (rawADC >= 4095) rawADC = 4094;
  float v_out = ((float)rawADC / 4095.0) * 3.3;
  return RL_BOARD * (3.3 - v_out) / v_out;
}

float convertToPPM(float Rs_R0_ratio, float a, float b, float clean_ppm) {
  if (Rs_R0_ratio > 1000.0) return 0.00;
  float ppm = a * pow(Rs_R0_ratio, b);
  return (ppm < clean_ppm) ? clean_ppm : ppm;
}

float calculateHygieneScore(float p2, float p135, float p136, float p137) {
  const float W_MQ137 = 0.40; 
  const float W_MQ136 = 0.30; 
  const float W_MQ135 = 0.20; 
  const float W_MQ2   = 0.10; 

  float scoreMQ137 = (p137 < 0.20) ? (W_MQ137 * 1.0) : (p137 <= 1.00) ? (W_MQ137 * 0.5) : 0.0;
  float scoreMQ136 = (p136 < 0.05) ? (W_MQ136 * 1.0) : (p136 <= 0.10) ? (W_MQ136 * 0.5) : 0.0;
  float scoreMQ135 = (p135 < 800.0) ? (W_MQ135 * 1.0) : (p135 <= 1000.0) ? (W_MQ135 * 0.5) : 0.0;
  float scoreMQ2   = (p2 < 5.0) ? (W_MQ2 * 1.0) : (p2 <= 10.0) ? (W_MQ2 * 0.5) : 0.0;

  return (scoreMQ137 + scoreMQ136 + scoreMQ135 + scoreMQ2) * 100.0;
}

// =====================================================
// --- Setup ---
// =====================================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  // 1. Initialize Sensors & Pins
  pinMode(PIN_DOOR, INPUT_PULLUP);
  lastDoorState = (digitalRead(PIN_DOOR) == HIGH); // HIGH if switch is open

  Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL);
  if (!sht30.begin(0x44)) {
    Serial.println("SHT31 not found!");
  }

  R0_MQ2   = calculateRs(RAW_BASELINE_MQ2)   / pow((ISO_CLEAN_PPM_MQ2   / 574.25), (1.0 / -2.22));
  R0_MQ135 = calculateRs(RAW_BASELINE_MQ135) / pow((ISO_CLEAN_PPM_MQ135 / 110.47), (1.0 / -2.86));
  R0_MQ136 = calculateRs(RAW_BASELINE_MQ136) / pow((ISO_CLEAN_PPM_MQ136 / 42.12),  (1.0 / -2.54));
  R0_MQ137 = calculateRs(RAW_BASELINE_MQ137) / pow((ISO_CLEAN_PPM_MQ137 / 17.52),  (1.0 / -2.35));
  Serial.println("[SENSOR] Calibration complete.");

  // 2. Initialize Wi-Fi
  Serial.printf("[WIFI] Connecting to %s ", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n[WIFI] Connected! IP: " + WiFi.localIP().toString());

  // 3. Initialize Firebase (Native TLS/HTTPS)
  Serial.println("[FIREBASE] Initializing...");
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  
  config.token_status_callback = tokenStatusCallback; // See TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

// =====================================================
// --- Loop ---
// =====================================================
void loop() {
  // --- Check Door Activity (Immediate Trigger) ---
  bool currentDoorState = (digitalRead(PIN_DOOR) == HIGH); // HIGH = Open, LOW = Closed (if using pullup to GND)
  if (currentDoorState != lastDoorState) {
    delay(50); // Debounce
    currentDoorState = (digitalRead(PIN_DOOR) == HIGH);
    if (currentDoorState != lastDoorState) {
      if (currentDoorState) doorEventsToday++; // Increment on door open
      lastDoorState = currentDoorState;
      lastTransmitTime = 0; // Trigger an immediate Firebase update!
    }
  }

  // Always let Firebase handle internal tasks (token refresh, keeping socket alive)
  if (Firebase.ready() && (millis() - lastTransmitTime > TRANSMIT_INTERVAL_MS || lastTransmitTime == 0)) {
    lastTransmitTime = millis();

    // 1. Read Sensors
    float temperature = sht30.readTemperature();
    float humidity    = sht30.readHumidity();

    float ppmMQ2   = convertToPPM((calculateRs(analogRead(PIN_MQ2))   / R0_MQ2),   574.25, -2.22, ISO_CLEAN_PPM_MQ2);
    float ppmMQ135 = convertToPPM((calculateRs(analogRead(PIN_MQ135)) / R0_MQ135), 110.47, -2.86, ISO_CLEAN_PPM_MQ135);
    float ppmMQ136 = convertToPPM((calculateRs(analogRead(PIN_MQ136)) / R0_MQ136), 42.12,  -2.54, ISO_CLEAN_PPM_MQ136);
    float ppmMQ137 = convertToPPM((calculateRs(analogRead(PIN_MQ137)) / R0_MQ137), 17.52,  -2.35, ISO_CLEAN_PPM_MQ137);

    float tempFinal = isnan(temperature) ? 0.0 : temperature;
    float humFinal  = isnan(humidity)    ? 0.0 : humidity;
    float score = calculateHygieneScore(ppmMQ2, ppmMQ135, ppmMQ136, ppmMQ137);

    Serial.printf("\n[SENSORS] T:%.1f H:%.1f | VOC:%.0f NH3:%.2f H2S:%.3f Smoke:%.1f | Score:%.0f\n", 
                   tempFinal, humFinal, ppmMQ135, ppmMQ137, ppmMQ136, ppmMQ2, score);

    // 2. Build Firebase JSON Payload
    FirebaseJson json;
    json.set("device_id", "OMD-TEST-01");
    json.set("sensor_id", "SENS-TEST-01");
    json.set("status", (score >= 50.0) ? "Active" : "Alert");
    json.set("timestamp", "Live");
    json.set("sensors/voc", ppmMQ135);
    json.set("sensors/nh3", ppmMQ137);
    json.set("sensors/h2s", ppmMQ136);
    json.set("sensors/smoke", ppmMQ2);
    json.set("sensors/temperature", tempFinal);
    json.set("sensors/humidity", humFinal);
    json.set("gps/latitude", 22.7200);
    json.set("gps/longitude", 75.8600);
    json.set("door_status", currentDoorState ? "Open" : "Closed");
    json.set("door_events_today", doorEventsToday);

    // 3. Push to Firebase RTDB Directly!
    Serial.printf("[FIREBASE] Pushing to %s... ", RTDB_PATH);
    
    // Use setJSON to overwrite exactly this node. It's atomic and incredibly fast.
    if (Firebase.RTDB.setJSON(&fbdo, RTDB_PATH, &json)) {
      Serial.println("SUCCESS!");
    } else {
      Serial.println("FAILED.");
      Serial.println("REASON: " + fbdo.errorReason());
    }
  }
}
