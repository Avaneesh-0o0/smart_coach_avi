// lib/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart

class AxleModel {
  final int axleNumber;
  final String status;
  final String maxTemp;
  final String currentTemp;
  final String sensorId;
  final String speed;
  final String detectedAt;
  final String location;
  final String lastMaintenance;
  final String updateTime;

  const AxleModel({
    required this.axleNumber,
    required this.status,
    required this.maxTemp,
    required this.currentTemp,
    required this.sensorId,
    required this.speed,
    required this.detectedAt,
    required this.location,
    required this.lastMaintenance,
    required this.updateTime,
  });
}

class HotAxleCoachModel {
  final String coachNumber;
  final String status;
  final String maxTemp;
  final int axlesMonitored;
  final int axlesIssue;
  final String updateTime;
  final List<AxleModel> axles;

  const HotAxleCoachModel({
    required this.coachNumber,
    required this.status,
    required this.maxTemp,
    required this.axlesMonitored,
    required this.axlesIssue,
    required this.updateTime,
    required this.axles,
  });
}

class AxleHistoryEntry {
  final String coachNumber;
  final int axleNumber;
  final String sensorId;
  final String maxTemp;
  final String status;
  final String speed;
  final String detectedAt;
  final String location;
  final DateTime date;

  const AxleHistoryEntry({
    required this.coachNumber,
    required this.axleNumber,
    required this.sensorId,
    required this.maxTemp,
    required this.status,
    required this.speed,
    required this.detectedAt,
    required this.location,
    required this.date,
  });
}