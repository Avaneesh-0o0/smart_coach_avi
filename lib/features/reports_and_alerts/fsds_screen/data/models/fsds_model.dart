class FsdsCoachModel {
  final String coachNumber;
  final String status; // 'ON' or 'OFF'
  final String updateTime;
  final bool isFireDetected;
  final String sensorId;
  final String lastPull;
  final String reset;
  final String trainSpeed;
  final String location;

  const FsdsCoachModel({
    required this.coachNumber,
    required this.status,
    required this.updateTime,
    this.isFireDetected = false,
    this.sensorId = 'FSDS-B5-04',
    this.lastPull = '10:42 AM',
    this.reset = 'Not done',
    this.trainSpeed = '62 km/h',
    this.location = 'Ratlam',
  });

  bool get isOn => status == 'ON';
}
