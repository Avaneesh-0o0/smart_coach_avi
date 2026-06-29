#include <Wire.h>
#include <Adafruit_SHT31.h>
#include <math.h>
#include <ArduinoJson.h>

// =====================================================
// --- GSM MODULE (SIM800L) ---
// =====================================================
HardwareSerial sim800l(2);

// --- GSM / GPRS CONFIGURATION ---
const String API_TOKEN   = "pk.1ba263e613f4f74a0c58e3b4ee4c8ebb"; // Replace with your free token
const String APN         = "airtelgprs.com";                      // Replace with your SIM card's APN
const String PHONE_NUMBER = "+917724855056";

// Default carrier values for India (MCC: 404, MNC: 93) - Change if using another carrier
const long MCC = 404;
const long MNC = 93;

// =====================================================
// --- CLOUD CONFIGURATION ---
// =====================================================
// Connects to Supabase via custom HTTP Webhook to bypass SIM800L SSL limits
const String HTTP_PROXY_URL = "http://avaneeshm04.pythonanywhere.com/proxy";

// =====================================================
// --- Pin Definitions ---
// =====================================================
const int PIN_MQ2   = 32;
const int PIN_MQ135 = 34;
const int PIN_MQ136 = 35;
const int PIN_MQ137 = 33;

const int PIN_LIMIT_SWITCH = 13;

const int PIN_I2C_SDA = 14;
const int PIN_I2C_SCL = 27;

// =====================================================
// --- USER CONFIGURATION ---
// =====================================================
// For testing: Coach S, Washroom WS (matches existing DB row SENS-S-WS)
const char* COACH_NO    = "S";
const char* WASHROOM_NO = "WS";

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

Adafruit_SHT31 sht30 = Adafruit_SHT31();

// Non-blocking Serial Monitor Timer
unsigned long lastSerialPrintTime = 0;
const unsigned long SERIAL_PRINT_INTERVAL_MS = 2000;

// =====================================================
// --- Limit Switch & Door Timer Variables ---
// =====================================================
bool lastSwitchState = HIGH;
int openEventCount = 0;
unsigned long doorStartTime = 0;

// Metrics Counters
int u_count = 0;
int f_count = 0;

// =====================================================
// --- ALARM MONITORING STATE ---
// =====================================================
bool alertTimerActive = false;
unsigned long alertStartTime = 0;

// Raw cell tower info
long globalLAC = 0;
long globalCID = 0;
bool cellInfoValid = false;

// =====================================================
// --- Supabase Upload Timer (every 40 seconds) ---
// =====================================================
unsigned long lastSupabaseUploadTime = 0;
const unsigned long SUPABASE_UPLOAD_INTERVAL_MS = 40000; // 40 seconds
unsigned long lastSupabaseUploadDurationMs = 0; // how long the most recent upload sequence took

// =====================================================
// --- Sustained Low-Hygiene SMS Trigger (30 continuous minutes below 40) ---
// =====================================================
const unsigned long SMS_ALERT_SUSTAIN_MS = 1800000; // 30 minutes
bool smsAlertAlreadySent = false; // prevents repeat SMS while still below threshold

// =====================================================
// --- Sensor Math ---
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

// =====================================================
// --- Status Classifications ---
// =====================================================
const char* getStatusMQ2(float ppm) {
  if (ppm <= 30.0) return "Good";
  if (ppm <= 40.0) return "Moderate";
  return "Bad";
}
const char* getStatusMQ135(float ppm) {
  if (ppm < 800.0)   return "Good";
  if (ppm <= 1000.0) return "Moderate";
  return "Bad";
}
const char* getStatusMQ136(float ppm) {
  if (ppm < 0.05)  return "Good";
  if (ppm <= 0.10) return "Moderate";
  return "Bad";
}
const char* getStatusMQ137(float ppm) {
  if (ppm < 0.20)  return "Good";
  if (ppm <= 1.00) return "Moderate";
  return "Bad";
}

// =====================================================
// --- PRIORITY-WEIGHTED SCORE CALCULATOR ---
// =====================================================
float calculateHygieneScore(float p2, float p135, float p136, float p137) {
  const float W_MQ137 = 0.40;
  const float W_MQ136 = 0.30;
  const float W_MQ135 = 0.20;
  const float W_MQ2   = 0.10;

  float scoreMQ137 = 0.0;
  float scoreMQ136 = 0.0;
  float scoreMQ135 = 0.0;
  float scoreMQ2   = 0.0;

  if (p137 < 0.20)       scoreMQ137 = W_MQ137 * 1.0;
  else if (p137 <= 1.00) scoreMQ137 = W_MQ137 * 0.5;
  else                   scoreMQ137 = W_MQ137 * 0.0;

  if (p136 < 0.05)       scoreMQ136 = W_MQ136 * 1.0;
  else if (p136 <= 0.10) scoreMQ136 = W_MQ136 * 0.5;
  else                   scoreMQ136 = W_MQ136 * 0.0;

  if (p135 < 800.0)       scoreMQ135 = W_MQ135 * 1.0;
  else if (p135 <= 1000.0) scoreMQ135 = W_MQ135 * 0.5;
  else                     scoreMQ135 = W_MQ135 * 0.0;

  if (p2 <= 30.0)      scoreMQ2 = W_MQ2 * 1.0;
  else if (p2 <= 40.0) scoreMQ2 = W_MQ2 * 0.5;
  else                 scoreMQ2 = W_MQ2 * 0.0;

  float currentHygieneScore = (scoreMQ137 + scoreMQ136 + scoreMQ135 + scoreMQ2) * 100.0;
  return currentHygieneScore;
}

const char* getHygieneVerdict(float score) {
  if (score >= 80.0) return "EXCELLENT / CLEAN";
  if (score >= 50.0) return "MODERATE / VENTILATION";
  return "POOR / ACTION NEEDED";
}

// Builds a string showing raw cell tower info
String getReportedAddress() {
  if (cellInfoValid) {
    return "MCC=" + String(MCC) + ", MNC=" + String(MNC) +
           ", LAC=" + String(globalLAC) + ", CID=" + String(globalCID);
  }
  return "Unknown (no cell info available)";
}

// Takes a genuine, fresh sensor reading right now and prints the full
// ENVIRONMENTAL LOG style block - same format as the periodic log - so every
// single GSM command shows real-time sensor data at that exact instant.
void printLiveTelemetryBlock() {
  int mq2Raw   = analogRead(PIN_MQ2);
  int mq135Raw = analogRead(PIN_MQ135);
  int mq136Raw = analogRead(PIN_MQ136);
  int mq137Raw = analogRead(PIN_MQ137);

  float temperature = sht30.readTemperature();
  float humidity    = sht30.readHumidity();

  float rsMQ2   = calculateRs(mq2Raw);
  float rsMQ135 = calculateRs(mq135Raw);
  float rsMQ136 = calculateRs(mq136Raw);
  float rsMQ137 = calculateRs(mq137Raw);

  float freshMQ2   = convertToPPM((rsMQ2   / R0_MQ2),   574.25, -2.22, ISO_CLEAN_PPM_MQ2);
  float freshMQ135 = convertToPPM((rsMQ135 / R0_MQ135), 110.47, -2.86, ISO_CLEAN_PPM_MQ135);
  float freshMQ136 = convertToPPM((rsMQ136 / R0_MQ136), 42.12,  -2.54, ISO_CLEAN_PPM_MQ136);
  float freshMQ137 = convertToPPM((rsMQ137 / R0_MQ137), 17.52,  -2.35, ISO_CLEAN_PPM_MQ137);

  float freshHygiene = calculateHygieneScore(freshMQ2, freshMQ135, freshMQ136, freshMQ137);
  float freshTemp = isnan(temperature) ? 0.0 : (temperature - 1);
  float freshHum  = isnan(humidity)    ? 0.0 : humidity;

  unsigned long now = millis();
  float freshRunningSec = (openEventCount == 1) ? ((float)(now - doorStartTime) / 1000.0) : 0.0;
  float freshElapsedMin = (alertTimerActive) ? ((float)(now - alertStartTime) / 60000.0) : 0.0;

  Serial.println("\n========== LIVE TELEMETRY (at GSM command) ==========");
  Serial.printf("MQ-2   (Smoke)         : %.2f ppm   [Raw: %d]   Status: %s\n", freshMQ2,   mq2Raw,   getStatusMQ2(freshMQ2));
  Serial.printf("MQ-135 (CO2/TVOCs)     : %.2f ppm   [Raw: %d]   Status: %s\n", freshMQ135, mq135Raw, getStatusMQ135(freshMQ135));
  Serial.printf("MQ-136 (H2S)           : %.2f ppm   [Raw: %d]   Status: %s\n", freshMQ136, mq136Raw, getStatusMQ136(freshMQ136));
  Serial.printf("MQ-137 (NH3)           : %.2f ppm   [Raw: %d]   Status: %s\n", freshMQ137, mq137Raw, getStatusMQ137(freshMQ137));
  Serial.println("-----------------------------------------------");
  Serial.printf("Temperature            : %.2f C\n", freshTemp);
  Serial.printf("Relative Humidity      : %.2f %%\n", freshHum);
  Serial.println("-----------------------------------------------");
  Serial.printf("Cell Info              : MCC=%ld MNC=%ld LAC=%ld CID=%ld\n", MCC, MNC, globalLAC, globalCID);
  Serial.println("-----------------------------------------------");
  Serial.printf("DOOR METRICS           : U-Count: %d  |  F-Count: %d\n", u_count, f_count);

  if (openEventCount == 1) {
    Serial.printf("DOOR TIMER STATUS      : RUNNING (Elapsed: %.1fs, Waiting for 2nd Open)\n", freshRunningSec);
  } else {
    Serial.println("DOOR TIMER STATUS      : IDLE / WAITING FOR 1ST OPEN");
  }

  if (alertTimerActive) {
    Serial.printf("ALERT TIMER ACTIVE     : Elapsed Time: %.2f / 30.0 min (SMS fires at 30 min if uninterrupted)\n", freshElapsedMin);
  } else {
    Serial.println("ALERT TIMER ACTIVE     : NO");
  }

  Serial.println("-----------------------------------------------");
  Serial.printf("FINAL HYGIENE SCORE    : %.1f / 100.0\n", freshHygiene);
  Serial.printf("WASHROOM CONDITION     : %s\n", getHygieneVerdict(freshHygiene));
  Serial.println("-----------------------------------------------");
  if (lastSupabaseUploadDurationMs > 0) {
    Serial.printf("LAST SUPABASE UPLOAD   : Took %lu ms (%.2f s)\n", lastSupabaseUploadDurationMs, lastSupabaseUploadDurationMs / 1000.0);
  } else {
    Serial.println("LAST SUPABASE UPLOAD   : Not sent yet");
  }
  Serial.println("=======================================================");
}

// =====================================================
// --- GSM / AT COMMAND HELPERS ---
// =====================================================

// Forward declaration: checkDoorSwitch() is defined further down (near loop()),
// but sendATCommand() needs to call it during its busy-wait so door-open/close
// events are never missed while the SIM800L is mid-command.
void checkDoorSwitch();

// Same idea as delay(ms), but keeps polling the door limit switch while waiting,
// instead of blocking blindly. Used everywhere a GSM/HTTP step needs a short
// pause so door events during that pause are never missed.
void delayWithDoorCheck(unsigned long ms) {
  unsigned long start = millis();
  while (millis() - start < ms) {
    checkDoorSwitch();
  }
}

String sendATCommand(String command, const int timeout) {
  String response = "";
  Serial.println("[GSM CMD] " + command); // Print the command being sent
  printLiveTelemetryBlock(); // Fresh full telemetry block, sampled right now
  unsigned long cmdStart = millis();
  sim800l.println(command);
  long int time = millis();
  while ((time + timeout) > millis()) {
    checkDoorSwitch(); // Keep polling the limit switch even while waiting on the modem
    while (sim800l.available()) {
      response += (char)sim800l.read();
    }
  }
  unsigned long cmdDuration = millis() - cmdStart;
  Serial.println(">> " + response); // Debug output of the response
  Serial.printf("[GSM TIMING] '%s' took %lu ms\n", command.c_str(), cmdDuration);
  return response;
}

void initGSM() {
  Serial.println("Initializing GSM module...");
  sendATCommand("AT", 2000);
  sendATCommand("ATE0", 1000);
  sendATCommand("AT+CREG=2", 2000); // Enable location parameters

  Serial.println("Registering to cellular network...");
  while (true) {
    String creg = sendATCommand("AT+CREG?", 2000);
    if (creg.indexOf(",1") != -1 || creg.indexOf(",5") != -1) {
      break;
    }
    delayWithDoorCheck(2000);
  }
  Serial.println("Network Registered.");
}

// =====================================================
// LIGHTWEIGHT: Fetches ONLY raw cell tower info (MCC/MNC/LAC/CID) via AT+CREG?.
// No HTTP / GPRS / Unwired Labs call at all. This is what runs in NORMAL
// (non-alert) conditions - cheap, fast, no data session opened.
// =====================================================
void fetchCellTowerInfo() {
  String response = sendATCommand("AT+CREG?", 2000);
  int q1 = response.indexOf('"');
  int q2 = response.indexOf('"', q1 + 1);
  int q3 = response.indexOf('"', q2 + 1);
  int q4 = response.indexOf('"', q3 + 1);

  if (q1 == -1 || q2 == -1 || q3 == -1 || q4 == -1) {
    Serial.println("Failed to fetch accurate Tower Data properties.");
    cellInfoValid = false;
    return;
  }

  String hexLAC = response.substring(q1 + 1, q2);
  String hexCI  = response.substring(q3 + 1, q4);

  long decLAC = strtol(hexLAC.c_str(), NULL, 16);
  long decCI  = strtol(hexCI.c_str(), NULL, 16);

  globalLAC = decLAC;
  globalCID = decCI;
  cellInfoValid = true;

  Serial.println("Tower Extracted -> LAC: " + String(decLAC) + " | CellID: " + String(decCI));
}


void sendSMS(String number, String messageText) {
  sendATCommand("AT+CMGF=1", 2000);
  Serial.println("[GSM CMD] AT+CMGS=\"" + number + "\"");
  sim800l.print("AT+CMGS=\"");
  sim800l.print(number);
  sim800l.println("\"");
  delayWithDoorCheck(1000);
  sim800l.print(messageText);
  delayWithDoorCheck(500);
  sim800l.write(26); // Ctrl+Z to send
  delayWithDoorCheck(5000);
  Serial.println("[GSM] SMS send sequence complete.");
}

// =====================================================
// --- Supabase Upload via SIM800L HTTP POST ---
// =====================================================
// Pushes sensor data to Pipedream webhook, which relays to odour_management_live.
void sendTelemetryToSupabase(float ppmMQ2, float ppmMQ135, float ppmMQ136, float ppmMQ137,
                              float tempFinal, float humFinal,
                              int u_count_val, int f_count_val,
                              float hygieneScore, bool isAlertRow) {

  Serial.println("\n[SUPABASE] Preparing telemetry upload via Webhook...");
  unsigned long uploadStart = millis();

  // Open the GPRS bearer (safe to call even if already open)
  sendATCommand("AT+SAPBR=3,1,\"Contype\",\"GPRS\"", 2000);
  sendATCommand("AT+SAPBR=3,1,\"APN\",\"" + APN + "\"", 2000);
  sendATCommand("AT+SAPBR=1,1", 4000);
  sendATCommand("AT+SAPBR=2,1", 2000);

  // Build JSON payload
  StaticJsonDocument<512> doc;
  doc["sensor_id"]              = String("SENS-") + COACH_NO + "-" + WASHROOM_NO;
  doc["device_id"]              = String("OMD-") + COACH_NO + "-" + WASHROOM_NO;
  doc["coach_number"]           = COACH_NO;
  doc["toilet_position"]        = WASHROOM_NO;
  doc["status"]                 = isAlertRow ? "Alert" : ((hygieneScore >= 50.0) ? "Active" : "Alert");
  doc["voc"]                    = ppmMQ135;
  doc["nh3"]                    = ppmMQ137;
  doc["h2s"]                    = ppmMQ136;
  doc["smoke"]                  = ppmMQ2;
  doc["temperature"]            = tempFinal;
  doc["humidity"]               = humFinal;
  doc["mcc"]                    = String(MCC);
  doc["mnc"]                    = String(MNC);
  doc["lac"]                    = String(globalLAC);
  doc["cell_id"]                = String(globalCID);
  doc["door_status"]            = (lastSwitchState == LOW) ? "Open" : "Closed";
  doc["door_open_events_today"] = u_count_val + f_count_val;

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  Serial.println("[SUPABASE] Payload: " + jsonPayload);

  // HTTP init
  sendATCommand("AT+HTTPINIT", 2000);
  sendATCommand("AT+HTTPPARA=\"CID\",1", 2000);
  // SSL is NOT needed because we are sending to an HTTP webhook
  sendATCommand("AT+HTTPPARA=\"URL\",\"" + HTTP_PROXY_URL + "\"", 2000);
  sendATCommand("AT+HTTPPARA=\"CONTENT\",\"application/json\"", 2000);

  String httpDataCmd = "AT+HTTPDATA=" + String(jsonPayload.length()) + ",10000";
  sendATCommand(httpDataCmd, 2000);

  sim800l.print(jsonPayload);
  delayWithDoorCheck(2000);

  // 10s timeout is plenty for plain HTTP
  String httpAction = sendATCommand("AT+HTTPACTION=1", 10000);

  if (httpAction.indexOf(",200,") != -1 || httpAction.indexOf(",201,") != -1) {
    Serial.println("[SUPABASE] ✅ Upload succeeded! Data synced via Webhook.");
    String httpRead = sendATCommand("AT+HTTPREAD", 5000);

    // Check for pending_action from app (RESOLVE flow)
    if (httpRead.indexOf("\"pending_action\":\"RESOLVE\"") != -1) {
      Serial.println("[SUPABASE] Resolve command received from App!");
      sendSMS(PHONE_NUMBER, "ALERT RESOLVED: The washroom issue has been addressed. - Smart Coach");
    }
  } else {
    Serial.println("[SUPABASE] ❌ Upload failed. Response: " + httpAction);
    Serial.println("[SUPABASE] Check: APN config, signal strength.");
  }

  sendATCommand("AT+HTTPTERM", 2000);
  sendATCommand("AT+SAPBR=0,1", 2000);

  lastSupabaseUploadDurationMs = millis() - uploadStart;
  Serial.printf("[SUPABASE TIMING] Total upload took %lu ms (%.2f s)\n",
                lastSupabaseUploadDurationMs, lastSupabaseUploadDurationMs / 1000.0);
}


void setup() {
  Serial.begin(115200);
  sim800l.begin(9600, SERIAL_8N1, 16, 17);
  delay(1000);

  pinMode(PIN_LIMIT_SWITCH, INPUT_PULLUP);
  lastSwitchState = digitalRead(PIN_LIMIT_SWITCH);

  Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL);
  sht30.begin(0x44);

  delay(1000);
  Serial.println("[SYSTEM] Initialized. Environment Monitoring Active.");
  Serial.printf("[SYSTEM] Target: Coach %s, Washroom %s -> sensor_id: SENS-%s-%s\n",
                COACH_NO, WASHROOM_NO, COACH_NO, WASHROOM_NO);

  // Sensor Calibration
  R0_MQ2   = calculateRs(RAW_BASELINE_MQ2)   / pow((ISO_CLEAN_PPM_MQ2   / 574.25), (1.0 / -2.22));
  R0_MQ135 = calculateRs(RAW_BASELINE_MQ135) / pow((ISO_CLEAN_PPM_MQ135 / 110.47), (1.0 / -2.86));
  R0_MQ136 = calculateRs(RAW_BASELINE_MQ136) / pow((ISO_CLEAN_PPM_MQ136 / 42.12),  (1.0 / -2.54));
  R0_MQ137 = calculateRs(RAW_BASELINE_MQ137) / pow((ISO_CLEAN_PPM_MQ137 / 17.52),  (1.0 / -2.35));

  Serial.println("[SENSOR] Calibration complete.");
  lastSerialPrintTime = millis();

  // Let the SIM800L module fully power up and find a signal before talking to it
  Serial.println("[GSM] Waiting 30 seconds for module to stabilize before sending AT commands...");
  delay(30000);

  // Initialize GSM and register on the cellular network
  initGSM();

  // NORMAL CONDITION: only fetch raw cell tower info (MCC/MNC/LAC/CID).
  // Do NOT run the full HTTP geolocation lookup here.
  fetchCellTowerInfo();

  lastSupabaseUploadTime = millis();
}

// =====================================================
// --- Loop ---
// =====================================================

// Checks the door limit switch for a fresh open transition and runs the
// open-to-open timer logic. Safe to call frequently/repeatedly - it only
// acts on a genuine LOW transition via lastSwitchState, so calling it many
// times per second (including from inside sendATCommand()'s busy-wait) does
// not cause duplicate detections.
void checkDoorSwitch() {
  unsigned long now = millis();
  bool currentSwitchState = digitalRead(PIN_LIMIT_SWITCH);

  if (currentSwitchState == LOW && lastSwitchState == HIGH) {
    delay(40); // Debounce
    if (digitalRead(PIN_LIMIT_SWITCH) == LOW) {
      openEventCount++;
      Serial.print("\n[DOOR] Open Event detected! Count: ");
      Serial.println(openEventCount);

      if (openEventCount == 1) {
        doorStartTime = now;
        Serial.println("[TIMER] First door opening. Timer Started.");
      }
      else if (openEventCount == 2) {
        unsigned long durationMs = now - doorStartTime;
        float durationMin = (float)durationMs / 60000.0;
        Serial.print("[TIMER] Second door opening. Timer Stopped. Duration: ");
        Serial.print(durationMin);
        Serial.println(" minutes");

        if (durationMin >= 1.0 && durationMin <= 5.0) {
          u_count++;
          Serial.println("[TIMER] Score: u_count incremented!");
        }
        else if (durationMin > 5.0 && durationMin <= 30.0) {
          f_count++;
          Serial.println("[TIMER] Score: f_count incremented!");
        } else {
          Serial.println("[TIMER] Score: Clean drop (outside 1-30 min window).");
        }

        openEventCount = 0;
        doorStartTime = 0;
        Serial.println("[TIMER] Sequence complete. Variables reset to zero.");
      }
    }
  }

  // Safety Timeout Check
  if (openEventCount == 1 && (now - doorStartTime > 1800000)) {
    Serial.println("\n[TIMER] !!! TIMEOUT RESET !!! Passed 30 mins limit without 2nd open event. Clearing.");
    openEventCount = 0;
    doorStartTime = 0;
  }

  lastSwitchState = currentSwitchState;
}

void loop() {
  unsigned long now = millis();

  // 1. Open-to-Open Toggle Matching Logic
  checkDoorSwitch();

  // 2. Process Gas Sensor Calculations
  int mq2Raw   = analogRead(PIN_MQ2);
  int mq135Raw = analogRead(PIN_MQ135);
  int mq136Raw = analogRead(PIN_MQ136);
  int mq137Raw = analogRead(PIN_MQ137);

  float temperature = sht30.readTemperature();
  float humidity    = sht30.readHumidity();

  float rsMQ2   = calculateRs(mq2Raw);
  float rsMQ135 = calculateRs(mq135Raw);
  float rsMQ136 = calculateRs(mq136Raw);
  float rsMQ137 = calculateRs(mq137Raw);

  float ppmMQ2   = convertToPPM((rsMQ2   / R0_MQ2),   574.25, -2.22, ISO_CLEAN_PPM_MQ2);
  float ppmMQ135 = convertToPPM((rsMQ135 / R0_MQ135), 110.47, -2.86, ISO_CLEAN_PPM_MQ135);
  float ppmMQ136 = convertToPPM((rsMQ136 / R0_MQ136), 42.12,  -2.54, ISO_CLEAN_PPM_MQ136);
  float ppmMQ137 = convertToPPM((rsMQ137 / R0_MQ137), 17.52,  -2.35, ISO_CLEAN_PPM_MQ137);

  float hygieneScore = calculateHygieneScore(ppmMQ2, ppmMQ135, ppmMQ136, ppmMQ137);
  float tempFinal = isnan(temperature) ? 0.0 : (temperature - 1);
  float humFinal  = isnan(humidity)    ? 0.0 : humidity;

  // 3. Sustained Low-Hygiene SMS Trigger Logic
  // SMS fires only if hygiene score stays continuously below 40 for 30 full minutes.
  if (hygieneScore < 40.0) {
    if (!alertTimerActive) {
      alertTimerActive = true;
      alertStartTime = now;
      smsAlertAlreadySent = false;
      Serial.println("\n[ALERT MONITOR] Warning! Score below 40. 30-Min Sustain Counter started.");
    }
  } else {
    // Any reading at or above 40 breaks the "continuous" condition -> reset
    if (alertTimerActive) {
      alertTimerActive = false;
      alertStartTime = 0;
      smsAlertAlreadySent = false;
      Serial.println("\n[ALERT MONITOR] Recovered! Score back to >= 40. Sustain Timer Cleared.");
    }
  }

  if (alertTimerActive && !smsAlertAlreadySent && (now - alertStartTime >= SMS_ALERT_SUSTAIN_MS)) {
    Serial.println("\n===============================================");
    Serial.println("!!! CRITICAL ALERT: HYGIENE SCORE BELOW 40 FOR 30 CONTINUOUS MINUTES !!!");
    Serial.printf("BAD ODOUR DETECTED -> Coach: %s | WR: %s\n", COACH_NO, WASHROOM_NO);
    Serial.println("===============================================");


    String report = "!!! LOW HYGIENE ALERT (30min) !!!\n";
    report += "Coach:" + String(COACH_NO) + " WR:" + String(WASHROOM_NO) + "\n";
    report += "MQ2:" + String(ppmMQ2, 2) + "ppm[" + getStatusMQ2(ppmMQ2) + "]\n";
    report += "MQ135:" + String(ppmMQ135, 2) + "ppm[" + getStatusMQ135(ppmMQ135) + "]\n";
    report += "MQ136:" + String(ppmMQ136, 3) + "ppm[" + getStatusMQ136(ppmMQ136) + "]\n";
    report += "MQ137:" + String(ppmMQ137, 3) + "ppm[" + getStatusMQ137(ppmMQ137) + "]\n";
    report += "Temp:" + String(tempFinal, 2) + "C Hum:" + String(humFinal, 2) + "%\n";
    report += "Loc: CID " + String(globalCID) + " (" + getReportedAddress() + ")\n";
    report += "Addr:" + getReportedAddress() + "\n";
    report += "U:" + String(u_count) + " F:" + String(f_count) + "\n";
    report += "Hygiene:" + String(hygieneScore, 1) + "[" + getHygieneVerdict(hygieneScore) + "]";

    Serial.println("[SMS ALERT] Sending sustained low-hygiene SMS now...");
    sendSMS(PHONE_NUMBER, report);

    // Also push this alert row to Supabase, now that we have the resolved location
    Serial.println("[SUPABASE] Sending alert telemetry row...");
    sendTelemetryToSupabase(ppmMQ2, ppmMQ135, ppmMQ136, ppmMQ137,
                             tempFinal, humFinal,
                             u_count, f_count,
                             hygieneScore, true);
    lastSupabaseUploadTime = now; // avoid an immediate duplicate periodic upload right after

    smsAlertAlreadySent = true; // don't resend again until score recovers and drops again
  }

  // Live derived values used both for serial log and SMS report
  float runningSec = (openEventCount == 1) ? ((float)(now - doorStartTime) / 1000.0) : 0.0;
  float elapsedMin = (alertTimerActive) ? ((float)(now - alertStartTime) / 60000.0) : 0.0;

  // 4. Non-Blocking Serial Output Log (Every 2 seconds)
  if (now - lastSerialPrintTime >= SERIAL_PRINT_INTERVAL_MS) {
    lastSerialPrintTime = now;

    Serial.println("\n============== ENVIRONMENTAL LOG ==============");
    Serial.printf("MQ-2   (Smoke)         : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ2,   mq2Raw,   getStatusMQ2(ppmMQ2));
    Serial.printf("MQ-135 (CO2/TVOCs)     : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ135, mq135Raw, getStatusMQ135(ppmMQ135));
    Serial.printf("MQ-136 (H2S)           : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ136, mq136Raw, getStatusMQ136(ppmMQ136));
    Serial.printf("MQ-137 (NH3)           : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ137, mq137Raw, getStatusMQ137(ppmMQ137));
    Serial.println("-----------------------------------------------");
    Serial.printf("Temperature            : %.2f C\n", tempFinal);
    Serial.printf("Relative Humidity      : %.2f %%\n", humFinal);
    Serial.println("-----------------------------------------------");
    Serial.printf("Cell Info              : MCC=%ld MNC=%ld LAC=%ld CID=%ld\n", MCC, MNC, globalLAC, globalCID);
      Serial.printf("Cell Info Only         : %s\n", getReportedAddress().c_str());
    Serial.printf("Location Address       : %s\n", getReportedAddress().c_str());
    Serial.println("-----------------------------------------------");
    Serial.printf("DOOR METRICS           : U-Count: %d  |  F-Count: %d\n", u_count, f_count);

    if (openEventCount == 1) {
      Serial.printf("DOOR TIMER STATUS      : RUNNING (Elapsed: %.1fs, Waiting for 2nd Open)\n", runningSec);
    } else {
      Serial.println("DOOR TIMER STATUS      : IDLE / WAITING FOR 1ST OPEN");
    }

    if (alertTimerActive) {
      Serial.printf("ALERT TIMER ACTIVE     : Elapsed Time: %.2f / 30.0 min (SMS fires at 30 min if uninterrupted)\n", elapsedMin);
    } else {
      Serial.println("ALERT TIMER ACTIVE     : NO");
    }

    Serial.println("-----------------------------------------------");
    Serial.printf("FINAL HYGIENE SCORE    : %.1f / 100.0\n", hygieneScore);
    Serial.printf("WASHROOM CONDITION     : %s\n", getHygieneVerdict(hygieneScore));
    Serial.println("-----------------------------------------------");
    if (lastSupabaseUploadDurationMs > 0) {
      Serial.printf("LAST SUPABASE UPLOAD   : Took %lu ms (%.2f s)\n", lastSupabaseUploadDurationMs, lastSupabaseUploadDurationMs / 1000.0);
    } else {
      Serial.println("LAST SUPABASE UPLOAD   : Not sent yet");
    }
    Serial.println("===============================================");
  }

  // 5. Periodic Telemetry Upload to Supabase (Every 40 seconds)
  // NORMAL CONDITION: only refresh raw cell tower info (MCC/MNC/LAC/CID).
  // Full HTTP geolocation lookup is intentionally skipped here.
  if (now - lastSupabaseUploadTime >= SUPABASE_UPLOAD_INTERVAL_MS) {
    lastSupabaseUploadTime = now;

    fetchCellTowerInfo();

    sendTelemetryToSupabase(ppmMQ2, ppmMQ135, ppmMQ136, ppmMQ137,
                             tempFinal, humFinal,
                             u_count, f_count,
                             hygieneScore, false);
  }

  delay(50);
}