import 'package:smart_coach_new/features/reports_and_alerts/water_lvl_indicator/data/models/water_tank_model.dart';
import 'package:firebase_database/firebase_database.dart';

class WaterLvlRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/water_lvl/coaches');

  Future<List<WaterTankModel>> getWaterTankData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockData();
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
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1002'),
        location: WliLocation(coachId: 'C2', coachName: 'C2'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 900, levelCm: 85.0, volumeLiters: 450.0, percentFull: 90.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 850, levelCm: 80.0, volumeLiters: 420.0, percentFull: 84.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1003'),
        location: WliLocation(coachId: 'C3', coachName: 'C3'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 350, levelCm: 30.0, volumeLiters: 175.0, percentFull: 35.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 380, levelCm: 32.0, volumeLiters: 190.0, percentFull: 38.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1004'),
        location: WliLocation(coachId: 'C4', coachName: 'C4'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 100, levelCm: 8.0, volumeLiters: 40.0, percentFull: 8.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 80, levelCm: 6.0, volumeLiters: 30.0, percentFull: 6.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1005'),
        location: WliLocation(coachId: 'C5', coachName: 'C5'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 700, levelCm: 65.0, volumeLiters: 350.0, percentFull: 70.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 680, levelCm: 63.0, volumeLiters: 340.0, percentFull: 68.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1006'),
        location: WliLocation(coachId: 'C6', coachName: 'C6'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 500, levelCm: 45.0, volumeLiters: 250.0, percentFull: 50.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 490, levelCm: 44.0, volumeLiters: 245.0, percentFull: 49.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1007'),
        location: WliLocation(coachId: 'C7', coachName: 'C7'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 620, levelCm: 56.0, volumeLiters: 310.0, percentFull: 62.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 600, levelCm: 54.0, volumeLiters: 300.0, percentFull: 60.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1008'),
        location: WliLocation(coachId: 'C8', coachName: 'C8'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 750, levelCm: 68.0, volumeLiters: 375.0, percentFull: 75.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 720, levelCm: 65.0, volumeLiters: 360.0, percentFull: 72.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1009'),
        location: WliLocation(coachId: 'C9', coachName: 'C9'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 800, levelCm: 72.0, volumeLiters: 400.0, percentFull: 80.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 780, levelCm: 70.0, volumeLiters: 390.0, percentFull: 78.0),
        ],
      ),
      WaterTankModel(
        source: WliSource(companyName: 'TechCorp', systemType: 'WLI', deviceId: 'DEV-1010'),
        location: WliLocation(coachId: 'C10', coachName: 'C10'),
        messageType: 'periodic',
        timestamp: DateTime.now().toIso8601String(),
        placement: WliPlacement(type: 'Roof', sensorCount: 4, position: ['LH1', 'RH1', 'LH2', 'RH2']),
        assets: [
          WliAsset(assetId: 'SENS-1', assetName: 'Tank 1', rawValue: 950, levelCm: 90.0, volumeLiters: 475.0, percentFull: 95.0),
          WliAsset(assetId: 'SENS-2', assetName: 'Tank 2', rawValue: 920, levelCm: 87.0, volumeLiters: 460.0, percentFull: 92.0),
        ],
      ),
    ];
  }
}
