// lib/features/reports_and_alerts/bc_pressure_screen/data/models/bc_pressure_model.dart

class BCPressureModel {
  final String coachNumber;
  final double pressure;
  final String status;
  final String brakeApplied;
  final String brakeReleased;
  final String? warningMessage;
  final DateTime lastUpdated;

  BCPressureModel({
    required this.coachNumber,
    required this.pressure,
    required this.status,
    required this.brakeApplied,
    required this.brakeReleased,
    this.warningMessage,
    required this.lastUpdated,
  });

  String getFormattedLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    if (difference.inMinutes < 1) return 'Updated just now';
    if (difference.inMinutes < 60) return 'Updated ${difference.inMinutes}m ago';
    if (difference.inHours < 24) return 'Updated ${difference.inHours}hr ago';
    return 'Updated ${difference.inDays}d ago';
  }
}

class BCHistoryEntry {
  final String coachNumber;
  final String sensorId;
  final double pressure;
  final String status;
  final String brakeApplied;
  final String brakeReleased;
  final String brakeResponseTime;
  final String location;
  final DateTime date;

  const BCHistoryEntry({
    required this.coachNumber,
    required this.sensorId,
    required this.pressure,
    required this.status,
    required this.brakeApplied,
    required this.brakeReleased,
    required this.brakeResponseTime,
    required this.location,
    required this.date,
  });
}