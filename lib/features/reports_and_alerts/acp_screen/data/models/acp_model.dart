class AcpCoachModel {
  final String coachNumber;
  final String status;
  final String updateTime;
  final bool isChainPulled;
  final String sensorId;
  final String lastPull;
  final String reset;
  final String trainSpeed;
  final String location;
  final String rawAssetName;
  final String totalCount;
  final bool isOn;
  final bool isRecent;
  final String trainNo;
  final String deviceId;

  const AcpCoachModel({
    required this.coachNumber,
    required this.status,
    required this.updateTime,
    this.isChainPulled = false,
    this.sensorId = 'N/A',
    this.lastPull = 'N/A',
    this.reset = 'N/A',
    this.trainSpeed = 'N/A',
    this.location = 'N/A',
    this.rawAssetName = '',
    this.totalCount = '0',
    this.isOn = true,
    this.isRecent = false,
    this.trainNo = 'N/A',
    this.deviceId = 'N/A',
  });

  /// Number of ACP activations (parsed from totalCount)
  int get deployedCount => int.tryParse(totalCount) ?? 0;
}

class AcpHistoryEntry {
  final String sensorId;
  final String lastPull;
  final String reset;
  final String trainSpeed;
  final String location;
  final DateTime date;
  final String status;
  final String totalCount;
  final String powerCarNo;
  final String rawAssetName;
  final String deviceId;

  const AcpHistoryEntry({
    required this.sensorId,
    required this.lastPull,
    required this.reset,
    required this.trainSpeed,
    required this.location,
    required this.date,
    this.status = '0',
    this.totalCount = '0',
    this.powerCarNo = 'N/A',
    this.rawAssetName = '',
    this.deviceId = 'N/A',
  });
}