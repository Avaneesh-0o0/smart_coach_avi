import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/datasources/sensor_type_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/repositories/sensor_type_configuration_repository.dart';
@Injectable(as: SensorTypeConfigurationRepository)
class SensorTypeConfigurationRepositoryImpl implements SensorTypeConfigurationRepository {
  final SensorTypeConfigurationRemoteDataSourceImpl remoteDataSource;
  SensorTypeConfigurationRepositoryImpl({required this.remoteDataSource});
  @override
  Future<List<SensorTypeEntity>> fetchSensor() async {
    final models = await remoteDataSource.fetchSensor();
    return models.map((item) => SensorTypeEntity.fromModel(item as SensorItem)).toList();
  }
}
