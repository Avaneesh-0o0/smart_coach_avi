import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_model.dart';
import 'package:firebase_database/firebase_database.dart';

class BcPressureRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/bc_pressure/coaches');

  Future<List<BCPressureModel>> getBcPressureData() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> coachesData = snapshot.value as Map<dynamic, dynamic>;
        List<BCPressureModel> parsedModels = [];
        
        coachesData.forEach((coachNumber, coachInfo) {
          if (coachInfo is Map && coachInfo.containsKey('devices')) {
            final Map<dynamic, dynamic> devices = coachInfo['devices'];
            devices.forEach((deviceId, deviceData) {
              if (deviceData is Map) {
                parsedModels.add(BCPressureModel(
                  coachNumber: coachNumber.toString(),
                  pressure: double.tryParse(deviceData['pressure']?.toString() ?? '0') ?? 0.0,
                  status: deviceData['status']?.toString() ?? 'Good',
                  brakeApplied: deviceData['brake_applied']?.toString() ?? 'Yes',
                  brakeReleased: deviceData['brake_released']?.toString() ?? 'No',
                  warningMessage: deviceData['warning_message']?.toString(),
                  lastUpdated: DateTime.tryParse(deviceData['timestamp']?.toString() ?? '') ?? DateTime.now(),
                ));
              }
            });
          }
        });
        
        if (parsedModels.isNotEmpty) {
          return parsedModels;
        }
      }
      
      print('No BC Pressure data found in Firebase. Seeding with mock data...');
      await _seedFirebaseWithMockData();
      return _getMockData();
    } catch (e) {
      print('Failed to fetch BC Pressure from Firebase, using fallback data: $e');
      return _getMockData();
    }
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "C1": {
        "coach_info": {
          "coach_type": "LHB",
          "train_number": "12615",
          "train_name": "Grand Trunk Exp",
        },
        "devices": {
          "BC-DEV-001": {
            "device_id": "BC-DEV-001",
            "sensor_id": "SENS-B01",
            "pressure": 3.8,
            "status": "Good",
            "brake_applied": "Yes",
            "brake_released": "No",
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      },
      "C2": {
        "coach_info": {
          "coach_type": "LHB",
          "train_number": "12615",
          "train_name": "Grand Trunk Exp",
        },
        "devices": {
          "BC-DEV-002": {
            "device_id": "BC-DEV-002",
            "sensor_id": "SENS-B02",
            "pressure": 1.2,
            "status": "Critical",
            "brake_applied": "Yes",
            "brake_released": "Yes",
            "warningMessage": "Pressure drop detected",
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed BC Pressure Firebase data: $e");
    }
  }

  List<BCPressureModel> _getMockData() {
    return [
      BCPressureModel(
        coachNumber: 'C1',
        pressure: 3.8,
        status: 'Good',
        brakeApplied: 'Yes',
        brakeReleased: 'No',
        lastUpdated: DateTime.now(),
      ),
      BCPressureModel(
        coachNumber: 'C2',
        pressure: 1.2,
        status: 'Critical',
        brakeApplied: 'Yes',
        brakeReleased: 'Yes',
        warningMessage: 'Pressure drop detected',
        lastUpdated: DateTime.now(),
      ),
    ];
  }
}
