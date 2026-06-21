import 'package:smart_coach_new/features/reports_and_alerts/water_lvl_indicator/data/models/water_tank_model.dart';
import 'package:firebase_database/firebase_database.dart';

class WaterLvlRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/water_lvl/coaches');

  Future<List<WaterTankModel>> getWaterTankData() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> coachesData = snapshot.value as Map<dynamic, dynamic>;
        List<WaterTankModel> parsedModels = [];
        
        coachesData.forEach((coachNumber, coachInfo) {
          if (coachInfo is Map) {
            final assetsData = coachInfo['assets'] as List<dynamic>? ?? [];
            List<WliAsset> parsedAssets = assetsData.map((e) {
              final a = e as Map;
              return WliAsset(
                assetId: a['assetId']?.toString() ?? '',
                assetName: a['assetName']?.toString() ?? '',
                rawValue: int.tryParse(a['rawValue']?.toString() ?? '0') ?? 0,
                levelCm: double.tryParse(a['levelCm']?.toString() ?? '0') ?? 0.0,
                volumeLiters: double.tryParse(a['volumeLiters']?.toString() ?? '0') ?? 0.0,
                percentFull: double.tryParse(a['percentFull']?.toString() ?? '0') ?? 0.0,
              );
            }).toList();

            final sourceData = coachInfo['source'] as Map? ?? {};
            final locationData = coachInfo['location'] as Map? ?? {};
            final placementData = coachInfo['placement'] as Map? ?? {};

            parsedModels.add(WaterTankModel(
              source: WliSource(
                companyName: sourceData['companyName']?.toString() ?? 'Unknown',
                systemType: sourceData['systemType']?.toString() ?? 'WLI',
                deviceId: sourceData['deviceId']?.toString() ?? 'Unknown',
              ),
              location: WliLocation(
                coachId: locationData['coachId']?.toString() ?? coachNumber.toString(),
                coachName: locationData['coachName']?.toString() ?? coachNumber.toString(),
              ),
              messageType: coachInfo['messageType']?.toString() ?? 'Status',
              timestamp: coachInfo['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
              placement: WliPlacement(
                type: placementData['type']?.toString() ?? 'Roof',
                sensorCount: int.tryParse(placementData['sensorCount']?.toString() ?? '1') ?? 1,
                position: (placementData['position'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
              ),
              assets: parsedAssets,
            ));
          }
        });
        
        if (parsedModels.isNotEmpty) {
          return parsedModels;
        }
      }
      
      print('No Water Level data found in Firebase. Seeding with mock data...');
      await _seedFirebaseWithMockData();
      return _getMockData();
    } catch (e) {
      print('Failed to fetch Water Level from Firebase, using fallback data: $e');
      return _getMockData();
    }
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "WLI-001": {
        "source": {
          "companyName": "TechCorp",
          "systemType": "WLI",
          "deviceId": "DEV-1001"
        },
        "location": {
          "coachId": "C1",
          "coachName": "C1"
        },
        "messageType": "periodic",
        "timestamp": DateTime.now().toIso8601String(),
        "placement": {
          "type": "Roof",
          "sensorCount": 4,
          "position": ["LH1", "RH1", "LH2", "RH2"]
        },
        "assets": [
          {
            "assetId": "SENS-1",
            "assetName": "Tank 1",
            "rawValue": 500,
            "levelCm": 45.0,
            "volumeLiters": 250.0,
            "percentFull": 55.0
          },
          {
            "assetId": "SENS-2",
            "assetName": "Tank 2",
            "rawValue": 200,
            "levelCm": 15.0,
            "volumeLiters": 80.0,
            "percentFull": 15.0
          }
        ]
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed Water Level Firebase data: $e");
    }
  }

  List<WaterTankModel> _getMockData() {
    return [
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1001'),
        location: WliLocation(coachId: 'C1', coachName: 'C1'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 500, levelCm: 45.0, volumeLiters: 250.0, percentFull: 55.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 200, levelCm: 15.0, volumeLiters: 80.0, percentFull: 15.0),
        ],
      ),
    ];
  }
}
