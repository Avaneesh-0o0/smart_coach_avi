import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/odour_model.dart';

class OdourRepository {
  /// Tries Supabase first. If the database is empty, times out, or unreachable,
  /// silently falls back to built-in sample data.
  Future<List<OdourCoachModel>> getOdourData() async {
    try {
      final response = await Supabase.instance.client
          .from('odour_management_live')
          .select()
          .timeout(const Duration(seconds: 6));

      if (response.isNotEmpty) {
        final parsed = response.map((map) => _buildModelFromSupabase(map)).toList();
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
    } catch (e) {
      // Supabase unreachable / timed out / empty → fall through to mock
      print('[OdourRepository] Supabase unavailable ($e), using sample data.');
    }

    return getSampleData();
  }

  /// Streams live odour data. It yields local sample data first,
  /// then subscribes to the Supabase table `odour_management_live` for real-time updates.
  /// If the database is empty or an error occurs, it continues yielding sample data.
  Stream<List<OdourCoachModel>> watchOdourData() async* {
    // 1. Instantly yield sample data first so that it is shown by default
    yield getSampleData();

    // 2. Stream from Supabase database
    try {
      final stream = Supabase.instance.client
          .from('odour_management_live')
          .stream(primaryKey: ['id'])
          .map((maps) {
            if (maps.isEmpty) {
              return getSampleData();
            }
            return maps.map((map) => _buildModelFromSupabase(map)).toList();
          })
          .handleError((error) {
            print('[OdourRepository] Supabase stream error: $error');
            return getSampleData();
          });

      yield* stream;
    } catch (e) {
      print('[OdourRepository] Supabase stream subscription failed: $e. Falling back to sample data.');
    }
  }

  // ---------------------------------------------------------------------------
  // Supabase parser
  // ---------------------------------------------------------------------------

  OdourCoachModel _buildModelFromSupabase(Map<String, dynamic> data) {
    double _d(dynamic v, [double def = 0.0]) =>
        (v as num?)?.toDouble() ?? def;
    int _i(dynamic v, [int def = 0]) => (v as num?)?.toInt() ?? def;
    String _s(dynamic v, [String def = 'N/A']) =>
        v?.toString() ?? def;

    return OdourCoachModel(
      coachNumber: _s(data['coach_number']),
      coachType: _s(data['coach_type'], 'Unknown'),
      toiletPosition: _s(data['toilet_position']),
      status: _s(data['status'], 'Active'),
      reading: _d(data['reading'] ?? data['voc']),
      timestamp: _s(data['timestamp'], DateTime.now().toIso8601String()),
      sensorId: _s(data['sensor_id'], 'SENS-??'),
      deviceId: _s(data['device_id'], 'OMD-??'),
      trainNumber: _s(data['train_number'], '--'),
      trainName: _s(data['train_name'], '--'),
      route: _s(data['route'], '--'),
      isRecent: true,
      voc: _d(data['voc']),
      h2s: _d(data['h2s']),
      nh3: _d(data['nh3']),
      smoke: _d(data['smoke']),
      temperature: _d(data['temperature']),
      humidity: _d(data['humidity']),
      latitude: _d(data['latitude']),
      longitude: _d(data['longitude']),
      doorStatus: _s(data['door_status'], 'Closed'),
      doorOpenEventsToday: _i(data['door_open_events_today']),
      lastOpenedTime: _s(data['last_opened_time'], 'N/A'),
      lastClosedTime: _s(data['last_closed_time'], 'N/A'),
      totalDoorCyclesToday: _i(data['total_door_cycles_today']),
      averageOpenDuration: _s(data['average_open_duration'], 'N/A'),
      longestOpenDuration: _s(data['longest_open_duration'], 'N/A'),
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

  /// Write data from hardware directly to Supabase (called by push endpoint).
  Future<void> sendOdourData(Map<String, dynamic> payload) async {
    final coachNumber = payload['coach_data']?['coach_number'] ?? 'T1';
    final toiletPos = payload['coach_data']?['toilet_position'] ?? 'Toilet-1-Front-Left';

    final dbPayload = {
      "coach_number": coachNumber,
      "toilet_position": toiletPos,
      "device_id": payload['source']?['deviceId'] ?? 'Unknown',
      "sensor_id": payload['source']?['SensorId'] ?? 'Unknown',
      "status": payload['coach_data']?['status'] ?? 'Active',
      "timestamp": payload['coach_data']?['timestamp'] ?? DateTime.now().toIso8601String(),
      "voc": payload['coach_data']?['voc'] ?? 0.0,
      "nh3": payload['coach_data']?['nh3'] ?? 0.0,
      "h2s": payload['coach_data']?['h2s'] ?? 0.0,
      "smoke": payload['coach_data']?['smoke'] ?? 0.0,
      "temperature": payload['coach_data']?['temperature'] ?? 0.0,
      "humidity": payload['coach_data']?['humidity'] ?? 0.0,
      "latitude": payload['coach_data']?['latitude'] ?? 0.0,
      "longitude": payload['coach_data']?['longitude'] ?? 0.0,
      "door_status": payload['coach_data']?['door_status'] ?? 'Closed',
      "door_open_events_today": payload['coach_data']?['door_events_today'] ?? 0,
      // Default info columns for the dashboard
      "coach_type": payload['coach_data']?['coach_type'] ?? '3AC',
      "train_number": payload['coach_data']?['train_number'] ?? '12952',
      "train_name": payload['coach_data']?['train_name'] ?? 'Rajdhani Express',
      "route": payload['coach_data']?['route'] ?? 'NDLS-BCT',
    };

    try {
      await Supabase.instance.client
          .from('odour_management_live')
          .upsert(dbPayload);
    } catch (e) {
      print('[OdourRepository] Supabase sendOdourData failed: $e');
    }
  }
}
