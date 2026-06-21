import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/odour_model.dart';

class OdourRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/odour_management/coaches');

  Future<List<OdourCoachModel>> getOdourData() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> coachesData = snapshot.value as Map<dynamic, dynamic>;
        List<OdourCoachModel> parsedModels = [];
        
        coachesData.forEach((coachNumber, coachInfo) {
          if (coachInfo is Map && coachInfo.containsKey('washrooms')) {
            final Map<dynamic, dynamic> washrooms = coachInfo['washrooms'];
            washrooms.forEach((toiletPos, toiletData) {
              if (toiletData is Map) {
                final sensors = toiletData['sensors'] ?? {};
                final gps = toiletData['gps'] ?? {};
                
                parsedModels.add(OdourCoachModel(
                  coachNumber: coachNumber.toString(),
                  coachType: coachInfo['coach_info']?['coach_type'] ?? "Unknown",
                  toiletPosition: toiletPos.toString(),
                  status: toiletData['status']?.toString() ?? "Active",
                  reading: ((sensors['voc'] ?? 0) as num).toDouble(),
                  timestamp: toiletData['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
                  sensorId: toiletData['sensor_id']?.toString() ?? "Unknown",
                  deviceId: toiletData['device_id']?.toString() ?? "Unknown",
                  trainNumber: coachInfo['coach_info']?['train_number'] ?? "Unknown",
                  trainName: coachInfo['coach_info']?['train_name'] ?? "Unknown",
                  route: coachInfo['coach_info']?['route'] ?? "Unknown",
                  isRecent: true,
                  voc: ((sensors['voc'] ?? 0) as num).toDouble(),
                  h2s: ((sensors['h2s'] ?? 0) as num).toDouble(),
                  nh3: ((sensors['nh3'] ?? 0) as num).toDouble(),
                  smoke: ((sensors['smoke'] ?? 0) as num).toDouble(),
                  temperature: ((sensors['temperature'] ?? 0) as num).toDouble(),
                  humidity: ((sensors['humidity'] ?? 0) as num).toDouble(),
                  latitude: ((gps['latitude'] ?? toiletData['latitude'] ?? 0) as num).toDouble(),
                  longitude: ((gps['longitude'] ?? toiletData['longitude'] ?? 0) as num).toDouble(),
                  doorStatus: toiletData['door_status']?.toString() ?? 'Closed',
                  doorOpenEventsToday: ((toiletData['door_events_today'] ?? 0) as num).toInt(),
                  lastOpenedTime: toiletData['last_opened_time']?.toString() ?? 'N/A',
                  lastClosedTime: toiletData['last_closed_time']?.toString() ?? 'N/A',
                ));
              }
            });
          }
        });
        if (parsedModels.isNotEmpty) {
          return parsedModels;
        }
      }
      
      // If no data exists in Firebase yet, let's bootstrap it with our sample data
      print('No odour data found in Firebase. Seeding with mock data...');
      await _seedFirebaseWithMockData();
      return _getMockData();
    } catch (e) {
      print('Failed to fetch from Firebase, using fallback data: $e');
      return _getMockData();
    }
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "B1": {
        "coach_info": {
          "coach_type": "3AC",
          "train_number": "12952",
          "train_name": "Rajdhani Express",
          "route": "NDLS-BCT"
        },
        "washrooms": {
          "Toilet-1-Front-Left": {
            "device_id": "OMD-MASTER-01",
            "sensor_id": "SENS-001",
            "status": "Active",
            "timestamp": DateTime.now().toIso8601String(),
            "sensors": {"voc": 950.0, "h2s": 0.08, "nh3": 0.8, "smoke": 6.5, "temperature": 32.5, "humidity": 65.0},
            "door_activity": {"status": "Closed", "events_today": 142, "last_opened": "14:45", "last_closed": "14:47"},
            "gps": {"latitude": 22.7200, "longitude": 75.8600}
          },
          "Toilet-2-Front-Right": {
            "device_id": "OMD-MASTER-01",
            "sensor_id": "SENS-002",
            "status": "Active",
            "timestamp": DateTime.now().toIso8601String(),
            "sensors": {"voc": 450.0, "h2s": 0.02, "nh3": 0.1, "smoke": 2.5, "temperature": 30.5, "humidity": 60.0},
            "door_activity": {"status": "Open", "events_today": 89, "last_opened": "14:55", "last_closed": "14:20"},
            "gps": {"latitude": 22.7200, "longitude": 75.8600}
          }
        }
      },
      "B2": {
        "coach_info": {
          "coach_type": "3AC",
          "train_number": "12952",
          "train_name": "Rajdhani Express",
          "route": "NDLS-BCT"
        },
        "washrooms": {
          "Toilet-3-Rear-Left": {
            "device_id": "OMD-MASTER-02",
            "sensor_id": "SENS-003",
            "status": "Inactive",
            "timestamp": DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            "sensors": {"voc": 120.0, "h2s": 0.01, "nh3": 0.05, "smoke": 1.2, "temperature": 28.0, "humidity": 50.0},
            "door_activity": {"status": "Closed", "events_today": 12, "last_opened": "12:45", "last_closed": "12:47"},
            "gps": {"latitude": 22.7200, "longitude": 75.8600}
          }
        }
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed Firebase: $e");
    }
  }

  List<OdourCoachModel> _getMockData() {
    return [
      OdourCoachModel(
        coachNumber: "B1",
        coachType: "3AC",
        toiletPosition: "Toilet-1-Front-Left",
        status: "Active",
        reading: 950.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-001",
        deviceId: "OMD-MASTER-01",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 950.0,
        h2s: 0.08,
        nh3: 0.8,
        smoke: 6.5,
        temperature: 32.5,
        humidity: 65.0,
      ),
      OdourCoachModel(
        coachNumber: "B2",
        coachType: "3AC",
        toiletPosition: "Toilet-3-Rear-Left",
        status: "Inactive",
        reading: 120.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        sensorId: "SENS-003",
        deviceId: "OMD-MASTER-02",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        voc: 120.0,
        h2s: 0.01,
        nh3: 0.05,
        smoke: 1.2,
        temperature: 28.0,
        humidity: 50.0,
      ),
    ];
  }

  Future<void> sendOdourData(Map<String, dynamic> payload) async {
    // If the hardware uses the REST API instead, we can keep the HTTP call here.
    // However, if the hardware sends to Firebase directly, we can also write directly.
    final coachNumber = payload['coach_data']?['coach_number'] ?? 'B1';
    final toiletPos = payload['coach_data']?['toilet_position'] ?? 'Toilet-1-Front-Left';
    
    final dbPayload = {
      "device_id": payload['source']?['deviceId'] ?? 'Unknown',
      "sensor_id": payload['source']?['SensorId'] ?? 'Unknown',
      "status": payload['coach_data']?['status'] ?? 'Active',
      "timestamp": payload['coach_data']?['timestamp'] ?? DateTime.now().toIso8601String(),
      "sensors": {
        "voc": payload['coach_data']?['voc'] ?? 0,
        "h2s": payload['coach_data']?['h2s'] ?? 0,
        "nh3": payload['coach_data']?['nh3'] ?? 0,
        "smoke": payload['coach_data']?['smoke'] ?? 0,
        "temperature": payload['coach_data']?['temperature'] ?? 0,
        "humidity": payload['coach_data']?['humidity'] ?? 0,
      },
      "gps": {
        "latitude": payload['coach_data']?['latitude'] ?? 0,
        "longitude": payload['coach_data']?['longitude'] ?? 0,
      }
    };
    
    try {
      await _dbRef.child(coachNumber).child('washrooms').child(toiletPos).update(dbPayload);
    } catch (e) {
      print('Failed to send odour data to Firebase: $e');
    }
  }
}
