import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/data/models/diesel_tank_model.dart';
import 'package:firebase_database/firebase_database.dart';

class DieselTankRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/diesel_tank/coaches');

  Future<List<DieselTankModel>> getDieselTanks() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> coachesData = snapshot.value as Map<dynamic, dynamic>;
        List<DieselTankModel> parsedModels = [];
        
        coachesData.forEach((coachNumber, coachInfo) {
          if (coachInfo is Map && coachInfo.containsKey('devices')) {
            final Map<dynamic, dynamic> devices = coachInfo['devices'];
            devices.forEach((deviceId, deviceData) {
              if (deviceData is Map) {
                parsedModels.add(DieselTankModel(
                  engineId: deviceData['engine_id']?.toString() ?? '',
                  sensorId: deviceId.toString(),
                  locoNumber: coachNumber.toString(),
                  trainName: coachInfo['train_name']?.toString() ?? '',
                  percentage: int.tryParse(deviceData['percentage']?.toString() ?? '0') ?? 0,
                  status: deviceData['status']?.toString() ?? 'Normal',
                  height: double.tryParse(deviceData['height']?.toString() ?? '0') ?? 0.0,
                  width: double.tryParse(deviceData['width']?.toString() ?? '0') ?? 0.0,
                  length: double.tryParse(deviceData['length']?.toString() ?? '0') ?? 0.0,
                  capacity: int.tryParse(deviceData['capacity']?.toString() ?? '0') ?? 0,
                  consumptionRate: int.tryParse(deviceData['consumption_rate']?.toString() ?? '0') ?? 0,
                  estimatedRunTime: double.tryParse(deviceData['estimated_run_time']?.toString() ?? '0') ?? 0.0,
                  rangeLeft: int.tryParse(deviceData['range_left']?.toString() ?? '0') ?? 0,
                  refilledBy: deviceData['refilled_by']?.toString() ?? '',
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
      
      print('No Diesel Tank data found in Firebase. Seeding with mock data...');
      await _seedFirebaseWithMockData();
      return _getMockData();
    } catch (e) {
      print('Failed to fetch Diesel Tank from Firebase, using fallback data: $e');
      return _getMockData();
    }
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "WDP4D #40345": {
        "train_name": "12615/6 Grand Trunk Express",
        "devices": {
          "WLI 125678": {
            "engine_id": "WDP4D #40345",
            "percentage": 75,
            "status": "Good",
            "height": 180.0,
            "width": 120.0,
            "length": 220.0,
            "capacity": 5000,
            "consumption_rate": 400,
            "estimated_run_time": 8.5,
            "range_left": 950,
            "refilled_by": "Ramesh Kumar",
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed Diesel Tank Firebase data: $e");
    }
  }

  List<DieselTankModel> _getMockData() {
    return [
      DieselTankModel(
        engineId: 'WDP4D #40345',
        sensorId: 'WLI 125678',
        locoNumber: 'WDP4D #40345',
        trainName: '12615/6 Grand Trunk Express',
        percentage: 75,
        status: 'Good',
        height: 180,
        width: 120,
        length: 220,
        capacity: 5000,
        consumptionRate: 400,
        estimatedRunTime: 8.5,
        rangeLeft: 950,
        refilledBy: 'Ramesh Kumar',
        lastUpdated: DateTime.now(),
      )
    ];
  }
}
