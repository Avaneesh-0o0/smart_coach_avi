import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_list_response.dart';
class SensorTypeEntity {
  int? sensorTypeId;
  String? name;
  SensorTypeEntity({this.sensorTypeId, this.name});
  factory SensorTypeEntity.fromModel(SensorItem model) {
    return SensorTypeEntity(sensorTypeId: model.sensorTypeId, name: model.name);
  }
}
