import 'package:firebase_database/firebase_database.dart';
import '../models/odour_model.dart';

class OdourRepository {
  // Path matches what ESP32 writes to:
  // /modules/odour_management/coaches/{coachId}/washrooms/{toiletId}
  static const String _basePath = 'modules/odour_management/coaches';

  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child(_basePath);

  /// Tries Firebase first. If the database is empty or unreachable,
  /// silently falls back to built-in sample data.
  Future<List<OdourCoachModel>> getOdourData() async {
    try {
      final snapshot = await _dbRef
          .get()
          .timeout(const Duration(seconds: 6));

      if (snapshot.exists && snapshot.value != null) {
        final parsed = _parseFirebaseSnapshot(snapshot);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
    } catch (e) {
      // Firebase unreachable / timed out → fall through to mock
      print('[OdourRepository] Firebase unavailable ($e), using sample data.');
    }

    return getSampleData();
  }

  Stream<List<OdourCoachModel>> watchOdourData() {
    return _dbRef.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final parsed = _parseFirebaseSnapshot(event.snapshot);
        if (parsed.isNotEmpty) return parsed;
      }
      return getSampleData();
    });
  }

  // ---------------------------------------------------------------------------
  // Firebase parser
  // ---------------------------------------------------------------------------

  List<OdourCoachModel> _parseFirebaseSnapshot(DataSnapshot snapshot) {
    final result = <OdourCoachModel>[];
    try {
      final coachesMap = snapshot.value as Map<dynamic, dynamic>;

      for (final coachEntry in coachesMap.entries) {
        final coachId = coachEntry.key.toString();
        final coachData = coachEntry.value;
        if (coachData == null) continue;

        final coachMap = Map<String, dynamic>.from(coachData as Map);

        // Support both structured (with coach_info + washrooms) and flat nodes
        final hasWashrooms =
            coachMap.containsKey('washrooms') && coachMap['washrooms'] != null;

        if (hasWashrooms) {
          final coachInfo =
              coachMap['coach_info'] as Map<dynamic, dynamic>? ?? {};
          final washroomsMap =
              coachMap['washrooms'] as Map<dynamic, dynamic>;

          for (final wEntry in washroomsMap.entries) {
            final toiletId = wEntry.key.toString();
            final toilet = wEntry.value;
            if (toilet == null) continue;

            final t = Map<String, dynamic>.from(toilet as Map);
            result.add(_buildModel(
              coachId: coachId,
              toiletId: toiletId,
              toiletData: t,
              coachInfo: Map<String, dynamic>.from(coachInfo),
            ));
          }
        } else {
          // Flat node (e.g. from ESP32 writing directly without washrooms key)
          result.add(_buildModel(
            coachId: coachId,
            toiletId: 'Toilet-1',
            toiletData: coachMap,
            coachInfo: const {},
          ));
        }
      }
    } catch (e) {
      print('[OdourRepository] Parse error: $e');
    }
    return result;
  }

  OdourCoachModel _buildModel({
    required String coachId,
    required String toiletId,
    required Map<String, dynamic> toiletData,
    required Map<String, dynamic> coachInfo,
  }) {
    final sensors =
        toiletData['sensors'] as Map<dynamic, dynamic>? ?? {};
    final door =
        toiletData['door_activity'] as Map<dynamic, dynamic>? ?? {};
    final gps =
        toiletData['gps'] as Map<dynamic, dynamic>? ?? {};

    double _d(dynamic v, [double def = 0.0]) =>
        (v as num?)?.toDouble() ?? def;
    int _i(dynamic v, [int def = 0]) => (v as num?)?.toInt() ?? def;
    String _s(dynamic v, [String def = 'N/A']) =>
        v?.toString() ?? def;

    return OdourCoachModel(
      coachNumber: coachId,
      coachType: _s(coachInfo['coach_type'], 'Unknown'),
      toiletPosition: toiletId,
      status: _s(toiletData['status'], 'Active'),
      reading: _d(sensors['voc']),
      timestamp: _s(toiletData['timestamp'],
          DateTime.now().toIso8601String()),
      sensorId: _s(toiletData['sensor_id'], 'SENS-??'),
      deviceId: _s(toiletData['device_id'], 'OMD-??'),
      trainNumber: _s(coachInfo['train_number'], '--'),
      trainName: _s(coachInfo['train_name'], '--'),
      route: _s(coachInfo['route'], '--'),
      isRecent: true,
      voc: _d(sensors['voc']),
      h2s: _d(sensors['h2s']),
      nh3: _d(sensors['nh3']),
      smoke: _d(sensors['smoke']),
      temperature: _d(sensors['temperature']),
      humidity: _d(sensors['humidity']),
      latitude: _d(gps['latitude']),
      longitude: _d(gps['longitude']),
      doorStatus: _s(door['status'] ?? toiletData['door_status'], 'Closed'),
      doorOpenEventsToday:
          _i(door['events_today'] ?? toiletData['door_events_today']),
      lastOpenedTime: _s(door['last_opened'], 'N/A'),
      lastClosedTime: _s(door['last_closed'], 'N/A'),
      totalDoorCyclesToday:
          _i(door['events_today'] ?? toiletData['door_events_today']),
      averageOpenDuration: _s(door['avg_duration'], 'N/A'),
      longestOpenDuration: _s(door['longest_duration'], 'N/A'),
    );
  }

  // ---------------------------------------------------------------------------
  // Sample / Fallback data
  // ---------------------------------------------------------------------------

  List<OdourCoachModel> getSampleData() {
    return [
      OdourCoachModel(
        coachNumber: "B1",
        coachType: "3AC",
        toiletPosition: "Toilet-1-Front-Left",
        status: "Active",
        reading: 950.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-001",
        deviceId: "OMD-MASTER-01",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 950.0,
        h2s: 0.08,
        nh3: 0.8,
        smoke: 6.5,
        temperature: 32.5,
        humidity: 65.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 142,
        lastOpenedTime: "14:45",
        lastClosedTime: "14:47",
        totalDoorCyclesToday: 142,
        averageOpenDuration: "2 mins",
        longestOpenDuration: "8 mins",
        recentDoorEventsTimeline: [
          {"event": "Door Closed", "time": "14:47"},
          {"event": "Door Opened", "time": "14:45"},
          {"event": "Door Closed", "time": "14:15"},
          {"event": "Door Opened", "time": "14:12"},
        ],
      ),
      OdourCoachModel(
        coachNumber: "B1",
        coachType: "3AC",
        toiletPosition: "Toilet-2-Front-Right",
        status: "Active",
        reading: 450.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-002",
        deviceId: "OMD-MASTER-01",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 450.0,
        h2s: 0.02,
        nh3: 0.1,
        smoke: 2.5,
        temperature: 30.5,
        humidity: 60.0,
        doorStatus: "Open",
        doorOpenEventsToday: 89,
        lastOpenedTime: "14:55",
        lastClosedTime: "14:20",
        totalDoorCyclesToday: 89,
        averageOpenDuration: "3 mins",
        longestOpenDuration: "12 mins",
        recentDoorEventsTimeline: [
          {"event": "Door Opened", "time": "14:55"},
          {"event": "Door Closed", "time": "14:20"},
          {"event": "Door Opened", "time": "14:15"},
        ],
      ),
      OdourCoachModel(
        coachNumber: "B2",
        coachType: "3AC",
        toiletPosition: "Toilet-3-Rear-Left",
        status: "Inactive",
        reading: 120.0,
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        sensorId: "SENS-003",
        deviceId: "OMD-MASTER-02",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        voc: 120.0,
        h2s: 0.01,
        nh3: 0.05,
        smoke: 1.2,
        temperature: 28.0,
        humidity: 50.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 22,
        lastOpenedTime: "12:45",
        lastClosedTime: "12:47",
        totalDoorCyclesToday: 22,
        averageOpenDuration: "5 mins",
        longestOpenDuration: "15 mins",
        recentDoorEventsTimeline: [
          {"event": "Door Closed", "time": "12:47"},
          {"event": "Door Opened", "time": "12:45"},
        ],
      ),
      OdourCoachModel(
        coachNumber: "A1",
        coachType: "2AC",
        toiletPosition: "Toilet-1-Front-Left",
        status: "Active",
        reading: 710.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-004",
        deviceId: "OMD-MASTER-03",
        trainNumber: "12952",
        trainName: "Rajdhani Express",
        route: "NDLS-BCT",
        isRecent: true,
        voc: 710.0,
        h2s: 0.06,
        nh3: 0.5,
        smoke: 4.0,
        temperature: 31.0,
        humidity: 58.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 67,
        lastOpenedTime: "14:30",
        lastClosedTime: "14:33",
        totalDoorCyclesToday: 67,
        averageOpenDuration: "2 mins",
        longestOpenDuration: "7 mins",
      ),
      OdourCoachModel(
        coachNumber: "C1",
        coachType: "CC",
        toiletPosition: "Toilet-1-Front",
        status: "Active",
        reading: 380.0,
        timestamp: DateTime.now().toIso8601String(),
        sensorId: "SENS-005",
        deviceId: "OMD-MASTER-04",
        trainNumber: "12002",
        trainName: "Shatabdi Express",
        route: "NDLS-HBJ",
        isRecent: true,
        voc: 380.0,
        h2s: 0.03,
        nh3: 0.15,
        smoke: 2.0,
        temperature: 29.5,
        humidity: 55.0,
        doorStatus: "Closed",
        doorOpenEventsToday: 54,
        lastOpenedTime: "14:10",
        lastClosedTime: "14:12",
        totalDoorCyclesToday: 54,
        averageOpenDuration: "1 min",
        longestOpenDuration: "5 mins",
      ),
    ];
  }

  /// Write data from hardware directly to Firebase (called by push endpoint).
  Future<void> sendOdourData(Map<String, dynamic> payload) async {
    final coachNumber =
        payload['coach_data']?['coach_number'] ?? 'T1';
    final toiletPos =
        payload['coach_data']?['toilet_position'] ??
            'Toilet-1-Front-Left';

    final dbPayload = {
      "device_id": payload['source']?['deviceId'] ?? 'Unknown',
      "sensor_id": payload['source']?['SensorId'] ?? 'Unknown',
      "status": payload['coach_data']?['status'] ?? 'Active',
      "timestamp": payload['coach_data']?['timestamp'] ??
          DateTime.now().toIso8601String(),
      "sensors": {
        "voc": payload['coach_data']?['voc'] ?? 0,
        "h2s": payload['coach_data']?['h2s'] ?? 0,
        "nh3": payload['coach_data']?['nh3'] ?? 0,
        "smoke": payload['coach_data']?['smoke'] ?? 0,
        "temperature": payload['coach_data']?['temperature'] ?? 0,
        "humidity": payload['coach_data']?['humidity'] ?? 0,
      },
      "gps": {
        "latitude": payload['coach_data']?['latitude'] ?? 0,
        "longitude": payload['coach_data']?['longitude'] ?? 0,
      },
    };

    try {
      await _dbRef
          .child(coachNumber)
          .child('washrooms')
          .child(toiletPos)
          .update(dbPayload);
    } catch (e) {
      print('[OdourRepository] sendOdourData failed: $e');
    }
  }
}
