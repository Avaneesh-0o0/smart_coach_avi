import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
abstract class SensorTypeConfigurationRepository {
  Future<List<SensorTypeEntity>> fetchSensor();
}
