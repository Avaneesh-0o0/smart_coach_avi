import '../models/water_tank_model.dart';

class WliDummyData {
  static List<WaterTankModel> generateCoaches() {
    return List.generate(20, (index) {
      final id = index + 1;
      final percent = id == 7 || id == 20 ? 15.0 : (id == 4 || id == 11 ? 35.0 : 85.0);
      
      return WaterTankModel(
        source: WliSource(
          companyName: "VASP Rails Tech",
          systemType: "WLI",
          deviceId: "WLI_DEV_${4540 + id}",
        ),
        location: WliLocation(
          coachId: "COACH_B$id",
          coachName: "B$id - AC 3 Tier",
        ),
        messageType: "METRICS",
        timestamp: "2026-04-23T15:00:00Z",
        placement: WliPlacement(
          type: "UNDERSLUNG",
          sensorCount: 1,
          position: ["CENTER"],
        ),
        assets: [
          WliAsset(
            assetId: "WLI-SENS-00$id",
            assetName: "Main Water Tank",
            rawValue: 414,
            levelCm: 30.5,
            volumeLiters: 160.0,
            percentFull: percent,
          ),
        ],
      );
    });
  }
}
