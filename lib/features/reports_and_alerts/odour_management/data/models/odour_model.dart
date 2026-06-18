class OdourCoachModel {
  final String coachNumber;
  final String coachType;
  final String toiletPosition;
  final String status;
  final num reading;
  final String timestamp;
  final String sensorId;
  final String deviceId;
  final String trainNumber;
  final String trainName;
  final String route;
  final bool isRecent;

  OdourCoachModel({
    required this.coachNumber,
    required this.coachType,
    required this.toiletPosition,
    required this.status,
    required this.reading,
    required this.timestamp,
    required this.sensorId,
    required this.deviceId,
    required this.trainNumber,
    required this.trainName,
    required this.route,
    this.isRecent = false,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get hasAlert => reading > 70;
}

class CoachToiletGroup {
  final String coachNumber;
  final String coachType;
  final String trainNumber;
  final String trainName;
  final String route;
  final List<OdourCoachModel> toilets;

  CoachToiletGroup({
    required this.coachNumber,
    required this.coachType,
    required this.trainNumber,
    required this.trainName,
    required this.route,
    required this.toilets,
  });

  int get totalToilets => toilets.length;
  int get activeToilets => toilets.where((t) => t.isActive).length;
  int get alertToilets => toilets.where((t) => t.hasAlert).length;
  String get worstStatus {
    if (toilets.any((t) => t.hasAlert)) return 'Alert';
    if (toilets.any((t) => !t.isActive)) return 'Inactive';
    return 'Good';
  }

  static List<CoachToiletGroup> groupByCoach(List<OdourCoachModel> models) {
    final map = <String, List<OdourCoachModel>>{};
    for (final m in models) {
      map.putIfAbsent(m.coachNumber, () => []).add(m);
    }
    return map.entries.map((e) {
      final first = e.value.first;
      return CoachToiletGroup(
        coachNumber: e.key,
        coachType: first.coachType,
        trainNumber: first.trainNumber,
        trainName: first.trainName,
        route: first.route,
        toilets: e.value,
      );
    }).toList();
  }
}
