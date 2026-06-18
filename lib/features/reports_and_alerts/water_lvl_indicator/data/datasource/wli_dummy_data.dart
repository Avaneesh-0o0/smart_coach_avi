import 'package:intl/intl.dart';
import '../models/water_tank_model.dart';

class WliDummyData {
  static const String trainNumber = '12615 Grand Trunk';

  static List<WaterTankModel> generateCoaches() {
    final now = DateTime.now();
    final timestamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now);
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
          coachName: "Coach $id",
        ),
        messageType: "METRICS",
        timestamp: timestamp,
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
