import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';

class SensorApiService {
  final String baseUrl;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/level_indicator/sensors');

  SensorApiService({required this.baseUrl});

  Future<SensorData> fetchSensorData(String sensorId) async {
    try {
      final snapshot = await _dbRef.child(sensorId).get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        return SensorData(
          id: int.tryParse(data['id']?.toString() ?? '0') ?? 0,
          sensorId: data['sensor_id']?.toString() ?? sensorId,
          waterLevel: double.tryParse(data['water_level']?.toString() ?? '0') ?? 0.0,
          timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
        );
      }
      
      print('No Level Indicator data found in Firebase for $sensorId. Seeding with mock data...');
      await _seedFirebaseWithMockData(sensorId);
      return _getMockData(sensorId);
    } catch (e) {
      print('Failed to fetch Level Indicator from Firebase, using fallback data: $e');
      return _getMockData(sensorId);
    }
  }

  Future<void> _seedFirebaseWithMockData(String sensorId) async {
    final mockData = {
      "id": 1,
      "sensor_id": sensorId,
      "water_level": 78.5,
      "timestamp": DateTime.now().toIso8601String(),
    };
    try {
      await _dbRef.child(sensorId).set(mockData);
    } catch (e) {
      print("Could not seed Level Indicator Firebase data: $e");
    }
  }

  SensorData _getMockData(String sensorId) {
    return SensorData(
      id: 1,
      sensorId: sensorId,
      waterLevel: 78.5,
      timestamp: DateTime.now(),
    );
  }
}
