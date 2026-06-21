import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/datasource/fsds_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';
import 'package:firebase_database/firebase_database.dart';

class FsdsRepository {
  final FsdsRemoteDataSource remoteDataSource; // Kept for DI compatibility
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/fsds/coaches');

  FsdsRepository(this.remoteDataSource);

  Future<List<FsdsAssetModel>> getFsdsStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockData();
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
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-003',
        deviceName: 'FSDS Master',
        coachUniqueId: 'UID-A2',
        coachDisplayId: 'A2',
        coachNumber: 'A2',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-1',
        bypassStatus: false,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Normal operation',
        sensorId: 'SENS-F03',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-004',
        deviceName: 'FSDS Slave',
        coachUniqueId: 'UID-A2',
        coachDisplayId: 'A2',
        coachNumber: 'A2',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-2',
        bypassStatus: true,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Bypassed by Staff',
        sensorId: 'SENS-F04',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-005',
        deviceName: 'FSDS Master',
        coachUniqueId: 'UID-A3',
        coachDisplayId: 'A3',
        coachNumber: 'A3',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-1',
        bypassStatus: false,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Normal operation',
        sensorId: 'SENS-F05',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-006',
        deviceName: 'FSDS Slave',
        coachUniqueId: 'UID-A3',
        coachDisplayId: 'A3',
        coachNumber: 'A3',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-2',
        bypassStatus: false,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Normal operation',
        sensorId: 'SENS-F06',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-007',
        deviceName: 'FSDS Master',
        coachUniqueId: 'UID-A4',
        coachDisplayId: 'A4',
        coachNumber: 'A4',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-1',
        bypassStatus: false,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Normal operation',
        sensorId: 'SENS-F07',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-008',
        deviceName: 'FSDS Slave',
        coachUniqueId: 'UID-A4',
        coachDisplayId: 'A4',
        coachNumber: 'A4',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-2',
        bypassStatus: false,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Normal operation',
        sensorId: 'SENS-F08',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-009',
        deviceName: 'FSDS Master',
        coachUniqueId: 'UID-A5',
        coachDisplayId: 'A5',
        coachNumber: 'A5',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-1',
        bypassStatus: false,
        alertStatus: true,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'High Temp Alert',
        sensorId: 'SENS-F09',
      ),
      FsdsAssetModel(
        deviceId: 'FSDS-DEV-010',
        deviceName: 'FSDS Slave',
        coachUniqueId: 'UID-A5',
        coachDisplayId: 'A5',
        coachNumber: 'A5',
        trainId: 1,
        trainNo: '12951',
        trainName: 'Rajdhani Express',
        location: 'Cabin-2',
        bypassStatus: false,
        alertStatus: false,
        timestamp: DateTime.now().toIso8601String(),
        remarks: 'Normal operation',
        sensorId: 'SENS-F10',
      ),
    ];
  }
}
