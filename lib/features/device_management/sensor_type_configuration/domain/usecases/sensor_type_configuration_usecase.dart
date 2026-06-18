import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/repositories/sensor_type_configuration_repository.dart';
@injectable
class SensorTypeConfigurationUseCase {
  final SensorTypeConfigurationRepository repository;
  SensorTypeConfigurationUseCase(this.repository);
  Future<List<SensorTypeEntity>> fetchSensor() => repository.fetchSensor();
}
