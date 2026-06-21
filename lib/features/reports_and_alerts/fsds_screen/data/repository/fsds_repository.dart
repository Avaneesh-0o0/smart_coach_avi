import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/datasource/fsds_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';
import 'package:firebase_database/firebase_database.dart';

class FsdsRepository {
  final FsdsRemoteDataSource remoteDataSource; // Kept for DI compatibility
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/fsds/coaches');

  FsdsRepository(this.remoteDataSource);

  Future<List<FsdsAssetModel>> getFsdsStatus() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> coachesData = snapshot.value as Map<dynamic, dynamic>;
        List<FsdsAssetModel> parsedModels = [];

        coachesData.forEach((coachNumber, coachInfo) {
          if (coachInfo is Map && coachInfo.containsKey('devices')) {
            final Map<dynamic, dynamic> devices = coachInfo['devices'];
            devices.forEach((deviceId, deviceData) {
              if (deviceData is Map) {
                parsedModels.add(FsdsAssetModel(
                  deviceId: deviceData['device_id']?.toString() ?? '',
                  deviceName: deviceData['device_name']?.toString() ?? '',
                  coachUniqueId: deviceData['coach_unique_id']?.toString() ?? '',
                  coachDisplayId: coachNumber.toString(),
                  coachNumber: coachNumber.toString(),
                  trainId: int.tryParse(coachInfo['coach_info']?['train_id']?.toString() ?? '0') ?? 0,
                  trainNo: coachInfo['coach_info']?['train_number']?.toString() ?? '',
                  trainName: coachInfo['coach_info']?['train_name']?.toString() ?? '',
                  location: deviceData['location']?.toString() ?? '',
                  bypassStatus: deviceData['bypass_status'] == true || deviceData['bypass_status'] == 'true',
                  alertStatus: deviceData['alert_status'] == true || deviceData['alert_status'] == 'true',
                  timestamp: deviceData['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
                  remarks: deviceData['remarks']?.toString() ?? '',
                  sensorId: deviceData['sensor_id']?.toString() ?? '',
                ));
              }
            });
          }
        });
        if (parsedModels.isNotEmpty) {
          return parsedModels;
        }
      }

      print('No FSDS data found in Firebase. Seeding with mock data...');
      await _seedFirebaseWithMockData();
      return _getMockData();
    } catch (e) {
      print('Failed to fetch from Firebase, using fallback data: $e');
      return _getMockData();
    }
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "A1": {
        "coach_info": {
          "coach_type": "1AC",
          "train_id": "1",
          "train_number": "12951",
          "train_name": "Rajdhani Express",
        },
        "devices": {
          "FSDS-DEV-001": {
            "device_id": "FSDS-DEV-001",
            "device_name": "FSDS Master",
            "coach_unique_id": "UID-A1",
            "location": "Cabin-1",
            "bypass_status": false,
            "alert_status": false,
            "timestamp": DateTime.now().toIso8601String(),
            "remarks": "Normal operation",
            "sensor_id": "SENS-F01"
          },
          "FSDS-DEV-002": {
            "device_id": "FSDS-DEV-002",
            "device_name": "FSDS Slave",
            "coach_unique_id": "UID-A1",
            "location": "Cabin-2",
            "bypass_status": false,
            "alert_status": true,
            "timestamp": DateTime.now().toIso8601String(),
            "remarks": "Smoke Detected",
            "sensor_id": "SENS-F02"
          }
        }
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed FSDS Firebase data: $e");
    }
  }

  List<FsdsAssetModel> _getMockData() {
    return [
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-001',
        deviceName: 'FSDS Master',
        coachUniqueId: 'UID-A1',
        coachDisplayId: 'A1',
        coachNumber: 'A1',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-1',
        bypassStatus: false,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Normal operation',
        sensorId: 'SENS-F01',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-002',
        deviceName: 'FSDS Slave',
        coachUniqueId: 'UID-A1',
        coachDisplayId: 'A1',
        coachNumber: 'A1',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-2',
        bypassStatus: false,
        alertStatus: true,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Smoke Detected',
        sensorId: 'SENS-F02',
      ),
    ];
  }
}
