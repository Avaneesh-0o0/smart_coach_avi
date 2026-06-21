#include <Wire.h>
#include <Adafruit_SHT31.h>
#include <math.h>

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

// SIM900A UART Pins
#define RXD2 16
#define TXD2 17

// =====================================================
// --- USER CONFIGURATION ---
// =====================================================
const char* SMS_NUMBER = "+917724855056";

// API Configuration
// NOTE: SIM900A DOES NOT support modern HTTPS (TLS 1.2/SNI) which Firebase requires.
// To send data to Firebase using SIM900, point this API_URL to a plain HTTP Proxy (e.g., Pipedream, Make.com, or a PHP script)
// that forwards the request to your Firebase database: https://smart-odour-cr-default-rtdb.firebaseio.com/modules/odour_management/...
const char* API_URL = "http://YOUR_HTTP_PROXY_URL_HERE/forward_to_firebase"; 
const char* APN = "airtelgprs.com"; // Change to your SIM provider's APN

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
HardwareSerial sim900(2);

bool lastDoorState = false;
int doorEventsToday = 0;

unsigned long lastTransmitTime = 0;
const unsigned long TRANSMIT_INTERVAL_MS = 60000; // 60 seconds

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
  if (ppm < 5.0)   return "Good"; // Per your criteria: < 5.0 is Good
  if (ppm <= 10.0) return "Moderate";
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
  const float W_MQ137 = 0.40; // Ammonia
  const float W_MQ136 = 0.30; // Hydrogen Sulfide
  const float W_MQ135 = 0.20; // CO2 / TVOCs
  const float W_MQ2   = 0.10; // Smoke

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
  else                    scoreMQ135 = W_MQ135 * 0.0;

  if (p2 < 5.0)       scoreMQ2 = W_MQ2 * 1.0;
  else if (p2 <= 10.0) scoreMQ2 = W_MQ2 * 0.5;
  else                 scoreMQ2 = W_MQ2 * 0.0;

  float currentHygieneScore = (scoreMQ137 + scoreMQ136 + scoreMQ135 + scoreMQ2) * 100.0;
  return currentHygieneScore;
}

const char* getHygieneVerdict(float score) {
  if (score >= 80.0) return "EXCELLENT / CLEAN";
  if (score >= 50.0) return "MODERATE / VENTILATION";
  return "POOR / ACTION NEEDED";
}

// =====================================================
// --- GSM Helper ---
// =====================================================
void gsmCmd(const char* cmd, unsigned int waitMs = 2000) {
  sim900.println(cmd);
  unsigned long t = millis();
  String resp = "";
  while (millis() - t < waitMs) {
    if (sim900.available()) {
      char c = sim900.read();
      Serial.write(c);
      resp += c;
      if (resp.endsWith("OK\r\n") || resp.endsWith("ERROR\r\n")) break; // Fast exit
    }
  }
}

String gsmReadResponse(unsigned int waitMs = 5000) {
  String resp = "";
  unsigned long t = millis();
  while (millis() - t < waitMs) {
    if (sim900.available()) {
      char c = sim900.read();
      Serial.write(c);
      resp += c;
    }
  }
  return resp;
}

// =====================================================
// --- SMS ---
// =====================================================
void sendSMS(const char* message) {
  Serial.println("\n[SMS] Sending...");
  gsmCmd("AT", 1000);
  gsmCmd("AT+CMGF=1", 1000);

  sim900.print("AT+CMGS=\"");
  sim900.print(SMS_NUMBER);
  sim900.println("\"");
  delay(2000);
  while (sim900.available()) Serial.write(sim900.read());

  sim900.print(message);
  delay(200);
  sim900.write(26); // Ctrl+Z
  gsmReadResponse(6000);
  Serial.println("[SMS] Done.");
}

// =====================================================
// --- HTTP POST Helper (via SIM900 GPRS) ---
// =====================================================
void sendHTTPPost(const char* jsonPayload) {
  Serial.println("\n[HTTP] Initializing GPRS...");
  gsmCmd("AT+SAPBR=3,1,\"Contype\",\"GPRS\"", 2000);
  
  String apnCmd = String("AT+SAPBR=3,1,\"APN\",\"") + APN + "\"";
  gsmCmd(apnCmd.c_str(), 2000);
  
  gsmCmd("AT+SAPBR=1,1", 3000); // Enable bearer
  gsmCmd("AT+SAPBR=2,1", 2000); // Check IP

  Serial.println("[HTTP] Sending POST request...");
  gsmCmd("AT+HTTPINIT", 2000);
  gsmCmd("AT+HTTPPARA=\"CID\",1", 2000);
  
  String urlCmd = String("AT+HTTPPARA=\"URL\",\"") + API_URL + "\"";
  gsmCmd(urlCmd.c_str(), 2000);
  
  gsmCmd("AT+HTTPPARA=\"CONTENT\",\"application/json\"", 2000);
  
  // Try to enable SSL if URL is HTTPS (Note: Will likely fail on SIM900)
  if (String(API_URL).startsWith("https")) {
    gsmCmd("AT+HTTPSSL=1", 2000); 
  } else {
    gsmCmd("AT+HTTPSSL=0", 2000);
  }

  // Inject Firebase METHOD OVERRIDE header if updating a specific node.
  // This allows Firebase to treat the POST request as a PUT to update data cleanly.
  gsmCmd("AT+HTTPPARA=\"USERDATA\",\"X-HTTP-Method-Override: PUT\\r\\n\"", 2000);

  sim900.print("AT+HTTPDATA=");
  sim900.print(strlen(jsonPayload)); // Exact payload length
  sim900.println(",10000");
  delay(2000);
  
  sim900.print(jsonPayload); // FIXED: Using .print instead of .println to prevent extra \r\n
  delay(2000);
  
  gsmCmd("AT+HTTPACTION=1", 10000); // 1 = POST (which is overridden to PUT if sent to Firebase via proxy)
  String response = gsmReadResponse(5000); // Wait for the async HTTPACTION result
  Serial.println("[HTTP] HTTPACTION Response:");
  Serial.println(response);

  Serial.println("[HTTP] Reading server response...");
  gsmCmd("AT+HTTPREAD", 5000);
  
  gsmCmd("AT+HTTPTERM", 2000);
  gsmCmd("AT+SAPBR=0,1", 2000); // Close bearer
}

// =====================================================
// --- Setup ---
// =====================================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(PIN_DOOR, INPUT_PULLUP);
  lastDoorState = (digitalRead(PIN_DOOR) == HIGH); // HIGH if switch is open

  Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL);
  sht30.begin(0x44);

  sim900.begin(9600, SERIAL_8N1, RXD2, TXD2);
  delay(3000);
  Serial.println("[GSM] SIM900A ready.");

  // Sensor calibration
  R0_MQ2   = calculateRs(RAW_BASELINE_MQ2)   / pow((ISO_CLEAN_PPM_MQ2   / 574.25), (1.0 / -2.22));
  R0_MQ135 = calculateRs(RAW_BASELINE_MQ135) / pow((ISO_CLEAN_PPM_MQ135 / 110.47), (1.0 / -2.86));
  R0_MQ136 = calculateRs(RAW_BASELINE_MQ136) / pow((ISO_CLEAN_PPM_MQ136 / 42.12),  (1.0 / -2.54));
  R0_MQ137 = calculateRs(RAW_BASELINE_MQ137) / pow((ISO_CLEAN_PPM_MQ137 / 17.52),  (1.0 / -2.35));

  Serial.println("[SENSOR] Calibration complete.");

  // Trigger first transmission immediately
  lastTransmitTime = millis() - TRANSMIT_INTERVAL_MS;
}

// =====================================================
// --- Loop ---
// =====================================================
void loop() {
  // --- Check Door Activity (Immediate Trigger) ---
  bool currentDoorState = (digitalRead(PIN_DOOR) == HIGH); // HIGH = Open, LOW = Closed
  if (currentDoorState != lastDoorState) {
    delay(50); // Debounce
    currentDoorState = (digitalRead(PIN_DOOR) == HIGH);
    if (currentDoorState != lastDoorState) {
      if (currentDoorState) doorEventsToday++; // Increment on door open
      lastDoorState = currentDoorState;
      // Trigger immediate SMS and HTTP POST because the state changed!
      lastTransmitTime = millis() - TRANSMIT_INTERVAL_MS; 
    }
  }

  // 1. Raw ADC
  int mq2Raw   = analogRead(PIN_MQ2);
  int mq135Raw = analogRead(PIN_MQ135);
  int mq136Raw = analogRead(PIN_MQ136);
  int mq137Raw = analogRead(PIN_MQ137);

  // 2. Climate
  float temperature = sht30.readTemperature();
  float humidity    = sht30.readHumidity();

  // 3. Resistance
  float rsMQ2   = calculateRs(mq2Raw);
  float rsMQ135 = calculateRs(mq135Raw);
  float rsMQ136 = calculateRs(mq136Raw);
  float rsMQ137 = calculateRs(mq137Raw);

  // 4. PPM
  float ppmMQ2   = convertToPPM((rsMQ2   / R0_MQ2),   574.25, -2.22, ISO_CLEAN_PPM_MQ2);
  float ppmMQ135 = convertToPPM((rsMQ135 / R0_MQ135), 110.47, -2.86, ISO_CLEAN_PPM_MQ135);
  float ppmMQ136 = convertToPPM((rsMQ136 / R0_MQ136), 42.12,  -2.54, ISO_CLEAN_PPM_MQ136);
  float ppmMQ137 = convertToPPM((rsMQ137 / R0_MQ137), 17.52,  -2.35, ISO_CLEAN_PPM_MQ137);

  // 5. Score
  float hygieneScore = calculateHygieneScore(ppmMQ2, ppmMQ135, ppmMQ136, ppmMQ137);

  float tempFinal = isnan(temperature) ? 0.0 : (temperature - 1);
  float humFinal  = isnan(humidity)    ? 0.0 : humidity;

  // --- Serial Log ---
  Serial.println("\n============== ENVIRONMENTAL LOG ==============");
  Serial.printf("MQ-2   (Smoke)         : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ2,   mq2Raw,   getStatusMQ2(ppmMQ2));
  Serial.printf("MQ-135 (CO2/TVOCs)     : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ135, mq135Raw, getStatusMQ135(ppmMQ135));
  Serial.printf("MQ-136 (H2S)           : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ136, mq136Raw, getStatusMQ136(ppmMQ136));
  Serial.printf("MQ-137 (NH3)           : %.2f ppm   [Raw: %d]   Status: %s\n", ppmMQ137, mq137Raw, getStatusMQ137(ppmMQ137));
  Serial.println("-----------------------------------------------");
  Serial.printf("Temperature            : %.2f C\n", tempFinal);
  Serial.printf("Relative Humidity      : %.2f %%\n", humFinal);
  Serial.println("-----------------------------------------------");
  Serial.printf("FINAL HYGIENE SCORE    : %.1f / 100.0\n", hygieneScore);
  Serial.printf("WASHROOM CONDITION     : %s\n", getHygieneVerdict(hygieneScore));
  Serial.println("===============================================");

  // --- Transmit SMS every 60 seconds ---
  unsigned long now = millis();
  if (now - lastTransmitTime >= TRANSMIT_INTERVAL_MS) {
    lastTransmitTime = now;

    char smsMsg[160];
    snprintf(smsMsg, sizeof(smsMsg),
      "ENV LOG\nSmoke:%.1f(%s)\nCO2:%.0f(%s)\nH2S:%.3f(%s)\nNH3:%.2f(%s)\nT:%.1fC H:%.1f%%\nScore:%.0f %s",
      ppmMQ2,   getStatusMQ2(ppmMQ2),
      ppmMQ135, getStatusMQ135(ppmMQ135),
      ppmMQ136, getStatusMQ136(ppmMQ136),
      ppmMQ137, getStatusMQ137(ppmMQ137),
      tempFinal, humFinal,
      hygieneScore, getHygieneVerdict(hygieneScore)
    );
    sendSMS(smsMsg);

    // --- Prepare and Send JSON Data ---
    // Updated Schema to perfectly match the newly created Firebase structure
    char jsonPayload[512];
    snprintf(jsonPayload, sizeof(jsonPayload),
      "{"
        "\"device_id\":\"OMD-TEST-01\","
        "\"sensor_id\":\"SENS-TEST-01\","
        "\"status\":\"%s\","
        "\"timestamp\":\"Live\","
        "\"sensors\":{"
          "\"voc\":%.2f,"
          "\"nh3\":%.2f,"
          "\"h2s\":%.3f,"
          "\"smoke\":%.2f,"
          "\"temperature\":%.1f,"
          "\"humidity\":%.1f"
        "},"
        "\"gps\":{"
          "\"latitude\":22.7200,"
          "\"longitude\":75.8600"
        "},"
        "\"door_status\":\"%s\","
        "\"door_events_today\":%d"
      "}",
      (hygieneScore >= 50.0) ? "Active" : "Alert", // Status
      ppmMQ135, ppmMQ137, ppmMQ136, ppmMQ2, tempFinal, humFinal,
      currentDoorState ? "Open" : "Closed", doorEventsToday
    );
    sendHTTPPost(jsonPayload);
  }

  // Read Incoming data from module asynchronously 
  while (sim900.available()) {
    Serial.write(sim900.read());
  }

  delay(2000);
}