import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_model.dart';
import 'package:firebase_database/firebase_database.dart';

class BcPressureRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/bc_pressure/coaches');

  Future<List<BCPressureModel>> getBcPressureData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockData();
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
      BCPressureModel(coachNumber: 'C1', pressure: 3.8, status: 'Good', brakeApplied: 'Yes', brakeReleased: 'No', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C2', pressure: 1.2, status: 'Critical', brakeApplied: 'Yes', brakeReleased: 'Yes', warningMessage: 'Pressure drop detected', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C3', pressure: 3.5, status: 'Good', brakeApplied: 'Yes', brakeReleased: 'No', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C4', pressure: 2.1, status: 'Warning', brakeApplied: 'Yes', brakeReleased: 'No', warningMessage: 'Low pressure warning', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C5', pressure: 4.0, status: 'Good', brakeApplied: 'No', brakeReleased: 'Yes', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C6', pressure: 0.8, status: 'Critical', brakeApplied: 'Yes', brakeReleased: 'Yes', warningMessage: 'Severe pressure loss', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C7', pressure: 3.2, status: 'Good', brakeApplied: 'Yes', brakeReleased: 'No', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C8', pressure: 2.5, status: 'Warning', brakeApplied: 'Yes', brakeReleased: 'No', warningMessage: 'Intermittent leak', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C9', pressure: 3.9, status: 'Good', brakeApplied: 'No', brakeReleased: 'Yes', lastUpdated: DateTime.now()),
      BCPressureModel(coachNumber: 'C10', pressure: 1.5, status: 'Critical', brakeApplied: 'Yes', brakeReleased: 'Yes', warningMessage: 'Brake pipe blockage', lastUpdated: DateTime.now()),
    ];
  }
}
