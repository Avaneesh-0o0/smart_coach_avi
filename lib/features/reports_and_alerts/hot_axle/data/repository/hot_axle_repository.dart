import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';
import 'package:firebase_database/firebase_database.dart';

class HotAxleRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/hot_axle/coaches');

  Future<List<HotAxleCoachModel>> getHotAxleData() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> coachesData = snapshot.value as Map<dynamic, dynamic>;
        List<HotAxleCoachModel> parsedModels = [];
        
        coachesData.forEach((coachNumber, coachInfo) {
          if (coachInfo is Map && coachInfo.containsKey('devices')) {
            final Map<dynamic, dynamic> devices = coachInfo['devices'];
            devices.forEach((deviceId, deviceData) {
              if (deviceData is Map) {
                parsedModels.add(HotAxleCoachModel(
                  deviceId: deviceData['device_id']?.toString() ?? '',
                  coachNumber: coachNumber.toString(),
                  coachType: coachInfo['coach_info']?['coach_type']?.toString() ?? 'Unknown',
                  owningRly: coachInfo['coach_info']?['owning_rly']?.toString() ?? 'NR',
                  trainNo: coachInfo['coach_info']?['train_number']?.toString() ?? '',
                  trainName: coachInfo['coach_info']?['train_name']?.toString() ?? '',
                  timestamp: deviceData['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
                  a11Temp: double.tryParse(deviceData['a11_temp']?.toString() ?? '0') ?? 0.0,
                  a12Temp: double.tryParse(deviceData['a12_temp']?.toString() ?? '0') ?? 0.0,
                  a21Temp: double.tryParse(deviceData['a21_temp']?.toString() ?? '0') ?? 0.0,
                  a22Temp: double.tryParse(deviceData['a22_temp']?.toString() ?? '0') ?? 0.0,
                  a31Temp: double.tryParse(deviceData['a31_temp']?.toString() ?? '0') ?? 0.0,
                  a32Temp: double.tryParse(deviceData['a32_temp']?.toString() ?? '0') ?? 0.0,
                  a41Temp: double.tryParse(deviceData['a41_temp']?.toString() ?? '0') ?? 0.0,
                  a42Temp: double.tryParse(deviceData['a42_temp']?.toString() ?? '0') ?? 0.0,
                  batteryPercentage: int.tryParse(deviceData['battery_percentage']?.toString() ?? '100') ?? 100,
                  signalStrength: int.tryParse(deviceData['signal_strength']?.toString() ?? '4') ?? 4,
                ));
              }
            });
          }
        });
        
        if (parsedModels.isNotEmpty) {
          return parsedModels;
        }
      }
      
      print('No Hot Axle data found in Firebase. Seeding with mock data...');
      await _seedFirebaseWithMockData();
      return _getMockData();
    } catch (e) {
      print('Failed to fetch Hot Axle from Firebase, using fallback data: $e');
      return _getMockData();
    }
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
      HotAxleCoachModel(
        deviceId: 'HA-DEV-001',
        coachNumber: 'HA1',
        coachType: '1AC',
        owningRly: 'NR',
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        timestamp: DateTime.now().toIso8601String(),
        a11Temp: 42.5, a12Temp: 41.2, a21Temp: 43.1, a22Temp: 44.0,
        a31Temp: 45.5, a32Temp: 42.8, a41Temp: 43.9, a42Temp: 44.1,
        batteryPercentage: 90,
        signalStrength: 3,
      ),
      HotAxleCoachModel(
        deviceId: 'HA-DEV-002',
        coachNumber: 'HA2',
        coachType: '2AC',
        owningRly: 'NR',
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        timestamp: DateTime.now().toIso8601String(),
        a11Temp: 95.0, a12Temp: 40.2, a21Temp: 41.1, a22Temp: 42.0,
        a31Temp: 43.5, a32Temp: 44.8, a41Temp: 45.9, a42Temp: 46.1,
        batteryPercentage: 15,
        signalStrength: 1,
      ),
    ];
  }
}
