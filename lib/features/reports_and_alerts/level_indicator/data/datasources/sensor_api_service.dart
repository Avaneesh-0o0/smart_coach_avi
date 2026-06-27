import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_data.dart';

class SensorApiService {
  final String baseUrl;

  SensorApiService({required this.baseUrl});

  Future<SensorData> fetchSensorData(String sensorId) async {
    try {
      final response = await Supabase.instance.client
          .from('level_indicator_sensors')
          .select()
          .eq('sensor_id', sensorId)
          .maybeSingle();

      if (response != null) {
        return SensorData(
          id: int.tryParse(response['id']?.toString() ?? '0') ?? 0,
          sensorId: response['sensor_id']?.toString() ?? sensorId,
          waterLevel: double.tryParse(response['water_level']?.toString() ?? '0') ?? 0.0,
          timestamp: DateTime.tryParse(response['timestamp']?.toString() ?? '') ?? DateTime.now(),
        );
      }
      
      print('No Level Indicator data found in Supabase for $sensorId. Seeding with mock data...');
      await _seedSupabaseWithMockData(sensorId);
      return _getMockData(sensorId);
    } catch (e) {
      print('Failed to fetch Level Indicator from Supabase, using fallback data: $e');
      return _getMockData(sensorId);
    }
  }

  Future<void> _seedSupabaseWithMockData(String sensorId) async {
    final mockData = {
      "id": 1,
      "sensor_id": sensorId,
      "water_level": 78.5,
      "timestamp": DateTime.now().toIso8601String(),
    };
    try {
      await Supabase.instance.client
          .from('level_indicator_sensors')
          .upsert(mockData);
    } catch (e) {
      print("Could not seed Level Indicator Supabase data: $e");
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
