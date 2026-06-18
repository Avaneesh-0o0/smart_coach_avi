class FsdsAssetModel {
  final String deviceId;
  final String deviceName;
  final String coachUniqueId;
  final String coachDisplayId;
  final String coachNumber;
  final int trainId;
  final String trainNo;
  final String trainName;
  final String location;
  final bool bypassStatus;
  final bool alertStatus;
  final String timestamp;
  final String remarks;
  final String sensorId;

  FsdsAssetModel({
    required this.deviceId,
    required this.deviceName,
    required this.coachUniqueId,
    required this.coachDisplayId,
    required this.coachNumber,
    required this.trainId,
    required this.trainNo,
    required this.trainName,
    required this.location,
    required this.bypassStatus,
    required this.alertStatus,
    required this.timestamp,
    this.remarks = '',
    this.sensorId = '',
  });

  bool get isBypassOn => bypassStatus;
  bool get isAlertActive => alertStatus;

  bool get isRecent {
    try {
      return DateTime.now().difference(DateTime.parse(timestamp)).inMinutes < 60;
    } catch (_) {
      return false;
    }
  }

  String get bypassStatusText => bypassStatus ? 'ON' : 'OFF';
  String get alertStatusText => alertStatus ? 'YES' : 'NO';
}
