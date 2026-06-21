import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';
import 'package:firebase_database/firebase_database.dart';

class HotAxleRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/hot_axle/coaches');

  Future<List<HotAxleCoachModel>> getHotAxleData() async {
    // Instantly return sample data to prevent loading hangups on demo
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockData();
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "HA1": {
        "coach_info": {
          "coach_type": "1AC",
          "owning_rly": "NR",
          "train_number": "12951",
          "train_name": "Rajdhani Express",
        },
        "devices": {
          "HA-DEV-001": {
            "device_id": "HA-DEV-001",
            "a11_temp": 42.5,
            "a12_temp": 41.2,
            "a21_temp": 43.1,
            "a22_temp": 44.0,
            "a31_temp": 45.5,
            "a32_temp": 42.8,
            "a41_temp": 43.9,
            "a42_temp": 44.1,
            "battery_percentage": 90,
            "signal_strength": 3,
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      },
      "HA2": {
        "coach_info": {
          "coach_type": "2AC",
          "owning_rly": "NR",
          "train_number": "12951",
          "train_name": "Rajdhani Express",
        },
        "devices": {
          "HA-DEV-002": {
            "device_id": "HA-DEV-002",
            "a11_temp": 95.0,
            "a12_temp": 40.2,
            "a21_temp": 41.1,
            "a22_temp": 42.0,
            "a31_temp": 43.5,
            "a32_temp": 44.8,
            "a41_temp": 45.9,
            "a42_temp": 46.1,
            "battery_percentage": 15,
            "signal_strength": 1,
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed Hot Axle Firebase data: $e");
    }
  }

  List<HotAxleCoachModel> _getMockData() {
    return [
      HotAxleCoachModel(deviceId: 'HA-DEV-001', coachNumber: 'HA1', coachType: '1AC', owningRly: 'NR', trainNo: '12951', trainName: 'Rajdhani Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 42.5, a12Temp: 41.2, a21Temp: 43.1, a22Temp: 44.0, a31Temp: 45.5, a32Temp: 42.8, a41Temp: 43.9, a42Temp: 44.1, batteryPercentage: 90, signalStrength: 3),
      HotAxleCoachModel(deviceId: 'HA-DEV-002', coachNumber: 'HA2', coachType: '2AC', owningRly: 'NR', trainNo: '12951', trainName: 'Rajdhani Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 95.0, a12Temp: 40.2, a21Temp: 41.1, a22Temp: 42.0, a31Temp: 43.5, a32Temp: 44.8, a41Temp: 45.9, a42Temp: 46.1, batteryPercentage: 15, signalStrength: 1),
      HotAxleCoachModel(deviceId: 'HA-DEV-003', coachNumber: 'HA3', coachType: '3AC', owningRly: 'NR', trainNo: '12951', trainName: 'Rajdhani Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 38.0, a12Temp: 37.5, a21Temp: 39.2, a22Temp: 38.8, a31Temp: 40.1, a32Temp: 39.5, a41Temp: 37.9, a42Temp: 38.3, batteryPercentage: 85, signalStrength: 4),
      HotAxleCoachModel(deviceId: 'HA-DEV-004', coachNumber: 'HA4', coachType: 'SL', owningRly: 'WR', trainNo: '12615', trainName: 'Grand Trunk Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 55.0, a12Temp: 52.3, a21Temp: 48.7, a22Temp: 50.1, a31Temp: 53.9, a32Temp: 51.2, a41Temp: 49.8, a42Temp: 54.6, batteryPercentage: 72, signalStrength: 3),
      HotAxleCoachModel(deviceId: 'HA-DEV-005', coachNumber: 'HA5', coachType: '2AC', owningRly: 'WR', trainNo: '12615', trainName: 'Grand Trunk Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 41.0, a12Temp: 40.5, a21Temp: 42.3, a22Temp: 41.8, a31Temp: 43.2, a32Temp: 42.1, a41Temp: 40.7, a42Temp: 41.5, batteryPercentage: 95, signalStrength: 4),
      HotAxleCoachModel(deviceId: 'HA-DEV-006', coachNumber: 'HA6', coachType: '1AC', owningRly: 'SR', trainNo: '12621', trainName: 'Tamil Nadu Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 88.5, a12Temp: 85.2, a21Temp: 45.3, a22Temp: 44.9, a31Temp: 46.1, a32Temp: 45.7, a41Temp: 44.2, a42Temp: 43.8, batteryPercentage: 30, signalStrength: 2),
      HotAxleCoachModel(deviceId: 'HA-DEV-007', coachNumber: 'HA7', coachType: '3AC', owningRly: 'SR', trainNo: '12621', trainName: 'Tamil Nadu Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 36.5, a12Temp: 35.8, a21Temp: 37.2, a22Temp: 36.9, a31Temp: 38.0, a32Temp: 37.4, a41Temp: 36.1, a42Temp: 35.5, batteryPercentage: 100, signalStrength: 4),
      HotAxleCoachModel(deviceId: 'HA-DEV-008', coachNumber: 'HA8', coachType: 'SL', owningRly: 'ER', trainNo: '12301', trainName: 'Howrah Rajdhani',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 60.2, a12Temp: 58.7, a21Temp: 55.4, a22Temp: 57.1, a31Temp: 59.8, a32Temp: 56.3, a41Temp: 54.9, a42Temp: 61.0, batteryPercentage: 45, signalStrength: 2),
      HotAxleCoachModel(deviceId: 'HA-DEV-009', coachNumber: 'HA9', coachType: '2AC', owningRly: 'ER', trainNo: '12301', trainName: 'Howrah Rajdhani',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 39.8, a12Temp: 40.1, a21Temp: 38.5, a22Temp: 39.3, a31Temp: 41.0, a32Temp: 40.6, a41Temp: 38.9, a42Temp: 39.7, batteryPercentage: 78, signalStrength: 3),
      HotAxleCoachModel(deviceId: 'HA-DEV-010', coachNumber: 'HA10', coachType: '1AC', owningRly: 'CR', trainNo: '12125', trainName: 'Pragati Express',
        timestamp: DateTime.now().toIso8601String(), a11Temp: 44.2, a12Temp: 43.8, a21Temp: 45.6, a22Temp: 44.1, a31Temp: 46.3, a32Temp: 45.0, a41Temp: 43.5, a42Temp: 44.7, batteryPercentage: 62, signalStrength: 3),
    ];
  }
}
