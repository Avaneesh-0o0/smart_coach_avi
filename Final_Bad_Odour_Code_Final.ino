#include <Adafruit_SHT31.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include <math.h>

// =====================================================
// --- Hardware Pin Definitions ---
// =====================================================
const int PIN_MQ2 = 32;
const int PIN_MQ135 = 34;
const int PIN_MQ136 = 35;
const int PIN_MQ137 = 33;

const int PIN_LIMIT_SWITCH = 13;

const int PIN_I2C_SDA = 14;
const int PIN_I2C_SCL = 27;

// Shared SIM800L/SIM900 HardwareSerial Pins
#define RXD2 16
#define TXD2 17

// =====================================================
// --- USER CONFIGURATION ---
// =====================================================
const String API_TOKEN = "pk.1ba263e613f4f74a0c58e3b4ee4c8ebb";
const String APN = "airtelgprs.com";
const char *SMS_NUMBER = "+917724855056";
const char *COACH_NO = "S";
const char *WASHROOM_NO = "WS";

const char *HTTP_PROXY_URL = "http://eo9lw8i08foix45.m.pipedream.net";

// =====================================================
// --- Fresh Air Raw Baselines ---
// =====================================================
const int RAW_BASELINE_MQ2 = 83;
const int RAW_BASELINE_MQ135 = 976;
const int RAW_BASELINE_MQ136 = 223;
const int RAW_BASELINE_MQ137 = 166;

const float ISO_CLEAN_PPM_MQ2 = 1.0;
const float ISO_CLEAN_PPM_MQ135 = 415.0;
const float ISO_CLEAN_PPM_MQ136 = 0.01;
const float ISO_CLEAN_PPM_MQ137 = 0.05;

float R0_MQ2, R0_MQ135, R0_MQ136, R0_MQ137;
const float RL_BOARD = 1.0;

// Hardware Drivers
Adafruit_SHT31 sht30 = Adafruit_SHT31();
HardwareSerial sim800l(2);

// Running Coordinates (Maintained globally by GSM Triangulation)
double currentLat = 0.0;
double currentLon = 0.0;
bool locationAvailable = false;

// Non-blocking Timing Structures
unsigned long lastSensorExecutionTime = 0;
const unsigned long SENSOR_LOOP_INTERVAL_MS =
    10000; // Exactly 10 Seconds for Environmental Data Readings

unsigned long lastLocationFetchTime = 0;
const unsigned long LOCATION_FETCH_INTERVAL_MS =
    900000; // Exactly 15 Minutes for GSM Triangulation Updates

// Limit Switch & Door Variables
bool lastSwitchState = HIGH;
int openEventCount = 0;
unsigned long doorStartTime = 0;

int u_count = 0;
int f_count = 0;

// Critical Alarm Variables
bool alertTimerActive = false;
unsigned long alertStartTime = 0;
const unsigned long CRITICAL_TIMEOUT_MS = 1800000; // Exactly 30 Minutes

// SMS Queue
#define QUEUE_MAX_SIZE 20
char smsQueue[QUEUE_MAX_SIZE][160];
int queueCount = 0;

unsigned long lastRetryTime = 0;
const unsigned long RETRY_INTERVAL_MS = 180000; // 3 minutes

// =====================================================
// --- Core Helper Functions ---
// =====================================================
String sendATCommand(String command, const int timeout) {
  String response = "";
  sim800l.println(command);
  long int time = millis();
  while ((time + timeout) > millis()) {
    while (sim800l.available()) {
      response += (char)sim800l.read();
    }
  }
  return response;
}

bool gsmCmdWithCheck(const char *cmd, const char *expectedResponse,
                     unsigned int waitMs = 2000) {
  sim800l.println(cmd);
  String resp = "";
  unsigned long t = millis();
  while (millis() - t < waitMs) {
    while (sim800l.available()) {
      resp += (char)sim800l.read();
    }
  }
  return (resp.indexOf(expectedResponse) != -1);
}

// =====================================================
// --- Status Classifications Helpers ---
// =====================================================
const char *getStatusMQ2(float ppm) {
  if (ppm < 5.0)
    return "Good";
  if (ppm <= 10.0)
    return "Moderate";
  return "Bad";
}
const char *getStatusMQ135(float ppm) {
  if (ppm < 800.0)
    return "Good";
  if (ppm <= 1000.0)
    return "Moderate";
  return "Bad";
}
const char *getStatusMQ136(float ppm) {
  if (ppm < 0.05)
    return "Good";
  if (ppm <= 0.10)
    return "Moderate";
  return "Bad";
}
const char *getStatusMQ137(float ppm) {
  if (ppm < 0.20)
    return "Good";
  if (ppm <= 1.00)
    return "Moderate";
  return "Bad";
}
const char *getHygieneVerdict(float score) {
  if (score >= 80.0)
    return "EXCELLENT / CLEAN";
  if (score >= 50.0)
    return "MODERATE / VENTILATION";
  return "POOR / ACTION NEEDED";
}

// =====================================================
// --- GSM Location Engine (API Integration) ---
// =====================================================
void updateGSMFallbackLocation() {
  Serial.println("\n[GSM LOCATION] 15-Min Timer Triggered: Fetching cell tower "
                 "tracking logs...");

  sendATCommand("AT+CREG=2", 2000);
  String response = sendATCommand("AT+CREG?", 2000);
  int q1 = response.indexOf('"');
  int q2 = response.indexOf('"', q1 + 1);
  int q3 = response.indexOf('"', q2 + 1);
  int q4 = response.indexOf('"', q3 + 1);

  if (q1 != -1 && q2 != -1 && q3 != -1 && q4 != -1) {
    String hexLAC = response.substring(q1 + 1, q2);
    String hexCI = response.substring(q3 + 1, q4);

    long decLAC = strtol(hexLAC.c_str(), NULL, 16);
    long decCI = strtol(hexCI.c_str(), NULL, 16);

    long mcc = 404;
    long mnc = 93;

    sendATCommand("AT+SAPBR=3,1,\"Contype\",\"GPRS\"", 2000);
    sendATCommand("AT+SAPBR=3,1,\"APN\",\"" + APN + "\"", 2000);
    sendATCommand("AT+SAPBR=1,1", 4000);

    StaticJsonDocument<256> doc;
    doc["token"] = API_TOKEN;
    doc["radio"] = "gsm";
    doc["mcc"] = mcc;
    doc["mnc"] = mnc;

    JsonArray cells = doc.createNestedArray("cells");
    JsonObject cell0 = cells.createNestedObject();
    cell0["lac"] = decLAC;
    cell0["cid"] = decCI;
    doc["address"] = 1;

    String jsonPayload;
    serializeJson(doc, jsonPayload);

    sendATCommand("AT+HTTPINIT", 2000);
    sendATCommand("AT+HTTPPARA=\"CID\",1", 2000);
    sendATCommand(
        "AT+HTTPPARA=\"URL\",\"http://us1.unwiredlabs.com/v2/process.php\"",
        2000);
    sendATCommand("AT+HTTPPARA=\"CONTENT\",\"application/json\"", 2000);

    sendATCommand("AT+HTTPDATA=" + String(jsonPayload.length()) + ",10000",
                  2000);
    sim800l.print(jsonPayload);
    delay(500);

    String httpAction = sendATCommand("AT+HTTPACTION=1", 15000);

    if (httpAction.indexOf(",200,") != -1) {
      String httpRead = sendATCommand("AT+HTTPREAD", 5000);
      int jsonStart = httpRead.indexOf('{');
      int jsonEnd = httpRead.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        String cleanJson = httpRead.substring(jsonStart, jsonEnd + 1);
        StaticJsonDocument<512> replyDoc;
        DeserializationError error = deserializeJson(replyDoc, cleanJson);

        if (!error && replyDoc["status"] == "ok") {
          currentLat = replyDoc["lat"];
          currentLon = replyDoc["lon"];
          locationAvailable = true;
          Serial.printf(
              "[GSM LOCATION] Update Success -> Lat: %.6f, Lon: %.6f\n",
              currentLat, currentLon);
        }
      }
    }
    sendATCommand("AT+HTTPTERM", 1500);
    sendATCommand("AT+SAPBR=0,1", 1500);
  } else {
    Serial.println("[GSM LOCATION] Internal Tower extraction rejected.");
  }
}

// =====================================================
// --- Queue & SMS Communications Engine ---
// =====================================================
void pushToQueue(const char *message) {
  if (queueCount < QUEUE_MAX_SIZE) {
    strncpy(smsQueue[queueCount], message, 159);
    smsQueue[queueCount][159] = '\0';
    queueCount++;
  } else {
    for (int i = 0; i < QUEUE_MAX_SIZE - 1; i++) {
      strcpy(smsQueue[i], smsQueue[i + 1]);
    }
    strncpy(smsQueue[QUEUE_MAX_SIZE - 1], message, 159);
    smsQueue[QUEUE_MAX_SIZE - 1][159] = '\0';
  }
}

void shiftQueue() {
  if (queueCount <= 0)
    return;
  for (int i = 0; i < queueCount - 1; i++) {
    strcpy(smsQueue[i], smsQueue[i + 1]);
  }
  queueCount--;
}

bool executeSMSTransmit(const char *message) {
  sim800l.println("AT");
  delay(200);
  while (sim800l.available())
    sim800l.read();

  if (!gsmCmdWithCheck("AT+CMGF=1", "OK", 1500))
    return false;

  sim800l.print("AT+CMGS=\"");
  sim800l.print(SMS_NUMBER);
  sim800l.println("\"");
  delay(1500);

  sim800l.print(message);
  delay(200);
  sim800l.write(26);

  String resp = "";
  unsigned long t = millis();
  while (millis() - t < 8000) {
    while (sim800l.available()) {
      resp += (char)sim800l.read();
    }
  }
  return (resp.indexOf("+CMGS:") != -1);
}

void processSMSQueue() {
  if (queueCount == 0)
    return;
  if (executeSMSTransmit(smsQueue[0])) {
    shiftQueue();
  }
}

// =====================================================
// --- Supabase Database Sync ---
// =====================================================
void pushToSupabase(const char *jsonPayload) {
  sendATCommand("AT+SAPBR=3,1,\"Contype\",\"GPRS\"", 1000);
  sendATCommand("AT+SAPBR=3,1,\"APN\",\"" + APN + "\"", 1000);
  Serial.println("[SUPABASE] Attaching to GPRS Network...");
  String sapbrStatus = sendATCommand("AT+SAPBR=1,1", 5000);
  Serial.println("[SUPABASE] GPRS Status: " + sapbrStatus);

  sendATCommand("AT+HTTPINIT", 1000);
  sendATCommand("AT+HTTPPARA=\"CID\",1", 1000);
  sendATCommand(String("AT+HTTPPARA=\"URL\",\"") + HTTP_PROXY_URL + "\"", 1000);
  sendATCommand("AT+HTTPPARA=\"CONTENT\",\"application/json\"", 1000);

  // Wait specifically for DOWNLOAD
  String dataCmd = "AT+HTTPDATA=" + String(strlen(jsonPayload)) + ",10000";
  sendATCommand(dataCmd, 2000);

  // Send actual payload
  sim800l.print(jsonPayload);
  delay(2000);

  Serial.println(
      "[SUPABASE] Executing HTTP POST via Proxy (Waiting up to 20s)...");
  String httpAction =
      sendATCommand("AT+HTTPACTION=1", 20000); // 20 Seconds Timeout
  Serial.println("[SUPABASE] HTTP Action Response: " + httpAction);

  if (httpAction.indexOf(",200,") != -1) {
    Serial.println(
        "[SUPABASE] ✅ SUCCESS: Data securely uploaded to Supabase!");
    String response = sendATCommand("AT+HTTPREAD", 5000);

    // Check if the app requested a resolve SMS
    if (response.indexOf("\"pending_action\":\"RESOLVE\"") != -1) {
      Serial.println("[SUPABASE] Resolve command received from App!");
      pushToQueue("ALERT RESOLVED: The washroom issue has been addressed. - "
                  "Smart Coach");

      // Clear the action so we don't spam SMS
      delay(1000);
      sendATCommand("AT+HTTPDATA=24,10000", 1000);
      sim800l.print("{\"pending_action\":null}");
      delay(1000);
      sendATCommand("AT+HTTPACTION=1", 5000);
      sendATCommand("AT+HTTPREAD", 2000);
    }
  } else {
    Serial.println("[SUPABASE] ❌ ERROR: Failed to upload data. Check Proxy "
                   "URL or GPRS connection.");
  }

  sendATCommand("AT+HTTPTERM", 1000);
}

// =====================================================
// --- Sensor Computations ---
// =====================================================
float calculateRs(int rawADC) {
  if (rawADC <= 5)
    return 999999.0;
  if (rawADC >= 4095)
    rawADC = 4094;
  float v_out = ((float)rawADC / 4095.0) * 3.3;
  return RL_BOARD * (3.3 - v_out) / v_out;
}

float convertToPPM(float Rs_R0_ratio, float a, float b, float clean_ppm) {
  if (Rs_R0_ratio > 1000.0)
    return 0.00;
  float ppm = a * pow(Rs_R0_ratio, b);
  return (ppm < clean_ppm) ? clean_ppm : ppm;
}

float calculateHygieneScore(float p2, float p135, float p136, float p137) {
  const float W_MQ137 = 0.40;
  const float W_MQ136 = 0.30;
  const float W_MQ135 = 0.20;
  const float W_MQ2 = 0.10;
  float s137 = (p137 < 0.20) ? 1.0 : (p137 <= 1.00) ? 0.5 : 0.0;
  float s136 = (p136 < 0.05) ? 1.0 : (p136 <= 0.10) ? 0.5 : 0.0;
  float s135 = (p135 < 800.0) ? 1.0 : (p135 <= 1000.0) ? 0.5 : 0.0;
  float s2 = (p2 < 5.0) ? 1.0 : (p2 <= 10.0) ? 0.5 : 0.0;
  return (s137 * W_MQ137 + s136 * W_MQ136 + s135 * W_MQ135 + s2 * W_MQ2) *
         100.0;
}

// =====================================================
// --- Setup Control Execution ---
// =====================================================
void setup() {
  Serial.begin(115200);
  pinMode(PIN_LIMIT_SWITCH, INPUT_PULLUP);
  lastSwitchState = digitalRead(PIN_LIMIT_SWITCH);

  Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL);
  sht30.begin(0x44);

  sim800l.begin(9600, SERIAL_8N1, RXD2, TXD2);

  delay(3000);

  R0_MQ2 = calculateRs(RAW_BASELINE_MQ2) /
           pow((ISO_CLEAN_PPM_MQ2 / 574.25), (1.0 / -2.22));
  R0_MQ135 = calculateRs(RAW_BASELINE_MQ135) /
             pow((ISO_CLEAN_PPM_MQ135 / 110.47), (1.0 / -2.86));
  R0_MQ136 = calculateRs(RAW_BASELINE_MQ136) /
             pow((ISO_CLEAN_PPM_MQ136 / 42.12), (1.0 / -2.54));
  R0_MQ137 = calculateRs(RAW_BASELINE_MQ137) /
             pow((ISO_CLEAN_PPM_MQ137 / 17.52), (1.0 / -2.35));

  Serial.println("[SYSTEM] Initialization Complete. Logs: 10s | GSM "
                 "Triangulation Fetch: 15m");
}

// =====================================================
// --- Loop Routine Execution ---
// =====================================================
void loop() {
  unsigned long now = millis();

  // A. CONSTANT HIGH-SPEED BACKGROUND ASYNCHRONOUS TASKS
  // 1. High-speed evaluation of Limit Switch door tracking conversions
  bool currentSwitchState = digitalRead(PIN_LIMIT_SWITCH);
  if (currentSwitchState == LOW && lastSwitchState == HIGH) {
    delay(40);
    if (digitalRead(PIN_LIMIT_SWITCH) == LOW) {
      openEventCount++;
      if (openEventCount == 1) {
        doorStartTime = now;
      } else if (openEventCount == 2) {
        float durationMin = (float)(now - doorStartTime) / 60000.0;
        if (durationMin >= 1.0 && durationMin <= 5.0)
          u_count++;
        else if (durationMin > 5.0 && durationMin <= 30.0)
          f_count++;

        openEventCount = 0;
        doorStartTime = 0;
      }
    }
  }
  if (openEventCount == 1 && (now - doorStartTime > 1800000)) {
    openEventCount = 0;
    doorStartTime = 0;
  }
  lastSwitchState = currentSwitchState;

  // B. DECOUPLED LOCATION UPDATE TICK (Runs exactly every 15 Minutes via GSM)
  if (now - lastLocationFetchTime >= LOCATION_FETCH_INTERVAL_MS) {
    lastLocationFetchTime = now;
    updateGSMFallbackLocation();
  }

  // C. READINGS LOGGING & CRITICAL MONITORING TICK (Runs exactly every 10
  // Seconds)
  if (now - lastSensorExecutionTime >= SENSOR_LOOP_INTERVAL_MS) {
    lastSensorExecutionTime = now;

    // 1. Fetch Raw Analog Values
    int mq2Raw = analogRead(PIN_MQ2);
    int mq135Raw = analogRead(PIN_MQ135);
    int mq136Raw = analogRead(PIN_MQ136);
    int mq137Raw = analogRead(PIN_MQ137);

    // 2. Read environmental SHT30 properties
    float temperature = sht30.readTemperature();
    float humidity = sht30.readHumidity();
    float tempFinal = isnan(temperature) ? 0.0 : (temperature - 1.0);
    float humFinal = isnan(humidity) ? 0.0 : humidity;

    // 3. Compute gas metrics calculations
    float rsMQ2 = calculateRs(mq2Raw);
    float rsMQ135 = calculateRs(mq135Raw);
    float rsMQ136 = calculateRs(mq136Raw);
    float rsMQ137 = calculateRs(mq137Raw);

    float ppmMQ2 =
        convertToPPM((rsMQ2 / R0_MQ2), 574.25, -2.22, ISO_CLEAN_PPM_MQ2);
    float ppmMQ135 =
        convertToPPM((rsMQ135 / R0_MQ135), 110.47, -2.86, ISO_CLEAN_PPM_MQ135);
    float ppmMQ136 =
        convertToPPM((rsMQ136 / R0_MQ136), 42.12, -2.54, ISO_CLEAN_PPM_MQ136);
    float ppmMQ137 =
        convertToPPM((rsMQ137 / R0_MQ137), 17.52, -2.35, ISO_CLEAN_PPM_MQ137);

    float hygieneScore =
        calculateHygieneScore(ppmMQ2, ppmMQ135, ppmMQ136, ppmMQ137);

    // 4. 30-Minute Continuous Low-Score Assessment logic
    if (hygieneScore < 40.0) {
      if (!alertTimerActive) {
        alertTimerActive = true;
        alertStartTime = now;
        Serial.println("[ALERT] Status Drop below threshold. 30-minute timer "
                       "sequence started.");
      }
    } else if (hygieneScore >= 50.0) {
      if (alertTimerActive) {
        alertTimerActive = false;
        alertStartTime = 0;
        Serial.println("[ALERT] Status recovered. Monitoring timer reset.");
      }
    }

    // Breach condition matching requirements (30-min continuous bad status)
    if (alertTimerActive && (now - alertStartTime >= CRITICAL_TIMEOUT_MS)) {
      char latStr[16] = "No Fix";
      char lngStr[16] = "No Fix";
      if (locationAvailable) {
        dtostrf(currentLat, 2, 6, latStr);
        dtostrf(currentLon, 2, 6, lngStr);
      }

      char criticalMsg[160];
      snprintf(criticalMsg, sizeof(criticalMsg),
               "CRITICAL: HYGIENE ALERT\nCoach:%s WR:%s\nScore:%.0f\nU:%d "
               "F:%d\nMAPS:https://maps.google.com/?q=%s,%s",
               COACH_NO, WASHROOM_NO, hygieneScore, u_count, f_count, latStr,
               lngStr);

      pushToQueue(criticalMsg);
      alertTimerActive = false;
      alertStartTime = 0;
    }

    // 5. EXTENSIVE FORMATTED ENVIRONMENTAL LOG (Prints directly to serial
    // window)
    Serial.println("\n============== ENVIRONMENTAL LOG ==============");
    Serial.printf(
        "MQ-2   (Smoke)         : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ2,
        mq2Raw, getStatusMQ2(ppmMQ2));
    Serial.printf(
        "MQ-135 (CO2/TVOCs)     : %.2f ppm   [Raw: %d]   Status: %s\n",
        ppmMQ135, mq135Raw, getStatusMQ135(ppmMQ135));
    Serial.printf(
        "MQ-136 (H2S)           : %.2f ppm   [Raw: %d]   Status: %s\n",
        ppmMQ136, mq136Raw, getStatusMQ136(ppmMQ136));
    Serial.printf(
        "MQ-137 (NH3)           : %.2f ppm   [Raw: %d]   Status: %s\n",
        ppmMQ137, mq137Raw, getStatusMQ137(ppmMQ137));
    Serial.println("-----------------------------------------------");
    Serial.printf("Temperature            : %.2f C\n", tempFinal);
    Serial.printf("Relative Humidity      : %.2f %%\n", humFinal);
    Serial.println("-----------------------------------------------");
    Serial.printf(
        "GSM TRIANGULATION LOC  : Lat: %.6f | Lng: %.6f | Status: %s\n",
        currentLat, currentLon, locationAvailable ? "VALID" : "NO FIX");
    Serial.printf("DOOR METRICS           : U-Count: %d  |  F-Count: %d\n",
                  u_count, f_count);
    Serial.printf("OFFLINE SMS BUFFER     : Queued Alerts: %d / %d\n",
                  queueCount, QUEUE_MAX_SIZE);

    if (openEventCount == 1) {
      float runningSec = (float)(now - doorStartTime) / 1000.0;
      Serial.printf("DOOR TIMER STATUS      : RUNNING (Elapsed: %.1fs, Waiting "
                    "for 2nd Open)\n",
                    runningSec);
    } else {
      Serial.println("DOOR TIMER STATUS      : IDLE / WAITING FOR 1ST OPEN");
    }

    if (alertTimerActive) {
      float elapsedMin = (float)(now - alertStartTime) / 60000.0;
      Serial.printf("ALERT TIMER ACTIVE     : Elapsed Time: %.2f / 30.0 min\n",
                    elapsedMin);
    } else {
      Serial.println("ALERT TIMER ACTIVE     : NO");
    }
    Serial.println("-----------------------------------------------");
    Serial.printf("FINAL HYGIENE SCORE    : %.1f / 100.0\n", hygieneScore);
    Serial.printf("WASHROOM CONDITION     : %s\n",
                  getHygieneVerdict(hygieneScore));
    Serial.println("===============================================");

    // 6. Push to Database via JSON
    char jsonPayload[700];
    snprintf(jsonPayload, sizeof(jsonPayload),
             "{"
             "\"device_id\":\"OMD-%s-%s\","
             "\"sensor_id\":\"SENS-%s-%s\","
             "\"coach_number\":\"%s\","
             "\"toilet_position\":\"%s\","
             "\"status\":\"%s\","
             "\"voc\":%.2f,"
             "\"nh3\":%.2f,"
             "\"h2s\":%.3f,"
             "\"smoke\":%.2f,"
             "\"temperature\":%.1f,"
             "\"humidity\":%.1f,"
             "\"latitude\":%.6f,"
             "\"longitude\":%.6f,"
             "\"door_status\":\"%s\","
             "\"door_open_events_today\":%d"
             "}",
             COACH_NO, WASHROOM_NO, COACH_NO, WASHROOM_NO, COACH_NO,
             WASHROOM_NO, (hygieneScore >= 50.0) ? "Active" : "Alert", ppmMQ135,
             ppmMQ137, ppmMQ136, ppmMQ2, tempFinal, humFinal, currentLat,
             currentLon, lastSwitchState ? "Open" : "Closed", openEventCount);

    Serial.println("\n[SUPABASE] Formatting JSON & Syncing telemetry...");
    pushToSupabase(jsonPayload);

    // 7. SMS Transmission Queue Handler Engine
    if (now - lastRetryTime >= RETRY_INTERVAL_MS) {
      lastRetryTime = now;
      processSMSQueue();
    }
  }
}