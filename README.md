# 🚆 Smart Coach IoT System

![Smart Coach Banner](https://img.shields.io/badge/Project-Smart_Coach-0052cc?style=for-the-badge&logo=train)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![ESP32](https://img.shields.io/badge/ESP32-000000?style=for-the-badge&logo=espressif&logoColor=white)
![Arduino](https://img.shields.io/badge/Arduino-00979D?style=for-the-badge&logo=Arduino&logoColor=white)

The **Smart Coach IoT System** is a comprehensive hardware-to-software solution designed to monitor, track, and analyze critical operational and environmental telemetry for railway coaches in real-time. It pairs a robust multi-sensor hardware suite with a sleek, industrial-styled Flutter mobile dashboard.

---

## 🌟 Key Features & Modules

The platform is designed modularly to handle various critical aspects of a modern rail coach:

*   **💨 Odour Management System (OMS)**
    *   **Sensors:** MQ-2 (Smoke), MQ-135 (TVOCs/CO2), MQ-136 (H2S), MQ-137 (Ammonia), SHT-31 (Temp/Humidity).
    *   **Door Tracking:** Limit switch integration to track door status (Open/Closed), events, and duration.
    *   **Analytics:** Live Hygiene Score (0-100), Threshold visualisations, and actionable alert management.
*   **💧 Water Level Indicator**
    *   Monitors overhead tank water levels across the coach to prevent water shortage during transits.
*   **🔥 Hot Axle & Brake Binding**
    *   Monitors thermal characteristics of wheels and brakes to prevent mechanical failures and derailments.
*   **🚨 ACP (Alarm Chain Pulling) & FSDS (Fire & Smoke Detection)**
    *   Real-time event tracking for passenger emergencies and fire hazards.
*   **⚙️ Core Configuration & Administration**
    *   Full CRUD interface to manage Users, Device Assignments, Trains, Rules, and Threshold Configurations directly from the app.

---

## 🏗️ Architecture Overview

The system bridges physical hardware with cloud infrastructure seamlessly:

### 1. Hardware Edge (Arduino / ESP32 / SIM900A)
The edge devices collect raw analog and digital signals from the sensor arrays.
*   **Wi-Fi / Native TLS (ESP32):** `esp32_firebase_odour.ino` streams data natively via Wi-Fi securely using the Firebase ESP Client.
*   **GPRS / Cellular (SIM900A):** `sketch_jun19a.ino` uses the SIM900A module to post data over mobile networks via an HTTP proxy or directly to endpoints.
*   **Edge Processing:** Converts analog inputs to precise PPM (Parts Per Million) values and computes a weighted Hygiene Score locally to minimize bandwidth.

### 2. Cloud Infrastructure (Firebase)
*   **Firebase Realtime Database (RTDB):** Provides instantaneous synchronization across all devices. Subscribing clients (the mobile app) receive updates the millisecond a threshold is breached or a door is opened.
*   **Firebase Authentication:** Secures the admin dashboards and restricts configuration access to authorized personnel.

### 3. Mobile Dashboard (Flutter)
A premium, dark-themed industrial UI built with Flutter.
*   **State Management:** Powered by `flutter_bloc` for scalable and predictable state handling.
*   **Data Visualization:** Incorporates `fl_chart` for dynamic, multi-line historical data representation with threshold indicators.
*   **PDF Reporting:** Built-in PDF report generation and sharing via `pdf` and `share_plus` packages.

---

## 🚀 Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or later)
*   [Arduino IDE](https://www.arduino.cc/en/software) (for compiling firmware)
*   Firebase Project (Realtime Database & Authentication enabled)

### Mobile App Setup

1. Navigate to the app directory:
   ```bash
   cd smart_coach
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up Firebase Configuration:
   * Generate or place your `google-services.json` in `android/app/`.
   * Place `GoogleService-Info.plist` in `ios/Runner/`.
4. Run the app:
   ```bash
   flutter run
   ```

### Hardware Setup

1. Open either `esp32_firebase_odour.ino` or `sketch_jun19a.ino` in the Arduino IDE.
2. Install the necessary libraries via the Library Manager:
   * `Firebase ESP32 Client` (by Mobizt)
   * `Adafruit SHT31 Library`
3. Update the credentials block in the `.ino` file:
   ```cpp
   #define WIFI_SSID "YOUR_WIFI_SSID"
   #define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
   #define API_KEY "YOUR_FIREBASE_WEB_API_KEY"
   ```
4. Flash to your ESP32 or Arduino board.

---

## 🎨 UI / UX Philosophy

The **Smart Coach** dashboard was built with a specific aesthetic in mind:
*   **Industrial IoT Look:** Sleek, dark mode interfaces that reduce eye strain for operators.
*   **Action-Oriented:** Critical alerts (Red/Warning) immediately draw the eye, with large typography for key metrics like the "Hygiene Score".
*   **Responsive:** Layouts utilize `FittedBox` and dynamic constraints to work perfectly on both mobile phones and operator tablets.

---

## 🛡️ License & Confidentiality
*(Proprietary - Smart Coach Project)*  
All rights reserved. This repository contains proprietary hardware schematics logic and application source code.
