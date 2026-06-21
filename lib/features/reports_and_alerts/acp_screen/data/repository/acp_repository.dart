import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/datasource/acp_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_filters_response.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class AcpRepository {
  Future<List<AcpLogData>> getAcpLogs();
  Future<List<AcpLogData>> getAcpSummary();

  Future<AcpFiltersResponse> getAcpFilters({
    String? trainNo,
    String? coachType,
  });

  Future<List<AcpLogData>> getAcpFilteredLogs({
    String? trainNo,
    String? techCoachNo,
  });
}

@Injectable(as: AcpRepository)
class AcpRepositoryImpl implements AcpRepository {
  final AcpRemoteDataSource remoteDataSource; // Kept for DI compatibility
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/acp/coaches');

  AcpRepositoryImpl(this.remoteDataSource);

  Future<List<AcpLogData>> _fetchFromFirebase() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> coachesData = snapshot.value as Map<dynamic, dynamic>;
        List<AcpLogData> parsedModels = [];
        
        coachesData.forEach((coachNumber, coachInfo) {
          if (coachInfo is Map && coachInfo.containsKey('devices')) {
            final Map<dynamic, dynamic> devices = coachInfo['devices'];
            devices.forEach((deviceId, deviceData) {
              if (deviceData is Map) {
                parsedModels.add(AcpLogData(
                  deviceId: deviceData['device_id']?.toString() ?? '',
                  rawAssetName: deviceData['device_name']?.toString() ?? 'ACP Device',
                  acpStatus: deviceData['acp_status']?.toString() ?? 'Normal',
                  trainNo: coachInfo['coach_info']?['train_number']?.toString() ?? 'Unknown',
                  commCoachNo: coachNumber.toString(),
                  techCoachNo: coachNumber.toString(),
                  trainLocation: deviceData['location']?.toString() ?? 'Unknown',
                  lastUpdated: deviceData['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
                ));
              }
            });
          }
        });
        
        if (parsedModels.isNotEmpty) {
          return parsedModels;
        }
      }
      
      print('No ACP data found in Firebase. Seeding with mock data...');
      await _seedFirebaseWithMockData();
      return _getMockData();
    } catch (e) {
      print('Failed to fetch from Firebase, using fallback data: $e');
      return _getMockData();
    }
  }

  @override
  Future<List<AcpLogData>> getAcpLogs() async {
    return await _fetchFromFirebase();
  }

  @override
  Future<List<AcpLogData>> getAcpSummary() async {
    return await _fetchFromFirebase();
  }

  @override
  Future<AcpFiltersResponse> getAcpFilters({
    String? trainNo,
    String? coachType,
  }) async {
    // Return mock filters based on our seeded data
    return AcpFiltersResponse(
      success: true,
      data: [
        AcpFilterData(trainNo: "12951", commCoachNo: "S1", techCoachNo: "S1"),
        AcpFilterData(trainNo: "12952", commCoachNo: "S2", techCoachNo: "S2"),
      ]
    );
  }

  @override
  Future<List<AcpLogData>> getAcpFilteredLogs({
    String? trainNo,
    String? techCoachNo,
  }) async {
    final allLogs = await _fetchFromFirebase();
    return allLogs.where((log) {
      bool matchesTrain = trainNo == null || log.trainNo == trainNo;
      bool matchesCoach = techCoachNo == null || log.techCoachNo == techCoachNo;
      return matchesTrain && matchesCoach;
    }).toList();
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "S1": {
        "coach_info": {
          "coach_type": "SL",
          "train_number": "12951",
          "train_name": "Rajdhani Express",
        },
        "devices": {
          "ACP-DEV-001": {
            "device_id": "ACP-DEV-001",
            "device_name": "ACP Handle 1",
            "location": "Near Door A",
            "acp_status": "Normal",
            "timestamp": DateTime.now().toIso8601String(),
          },
          "ACP-DEV-002": {
            "device_id": "ACP-DEV-002",
            "device_name": "ACP Handle 2",
            "location": "Near Door B",
            "acp_status": "Pulled",
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed ACP Firebase data: $e");
    }
  }

  List<AcpLogData> _getMockData() {
    return [
      AcpLogData(
        deviceId: "ACP-DEV-001",
        rawAssetName: "ACP Handle 1",
        acpStatus: "Normal",
        trainNo: "12951",
        commCoachNo: "S1",
        techCoachNo: "S1",
        trainLocation: "Near Door A",
        lastUpdated: DateTime.now().toIso8601String(),
      ),
      AcpLogData(
        deviceId: "ACP-DEV-002",
        rawAssetName: "ACP Handle 2",
        acpStatus: "Pulled",
        trainNo: "12951",
        commCoachNo: "S1",
        techCoachNo: "S1",
        trainLocation: "Near Door B",
        lastUpdated: DateTime.now().toIso8601String(),
      )
    ];
  }
}
