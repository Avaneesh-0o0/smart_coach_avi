import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_category_list_response.dart';
class SensorCategoryEntity {
  int? id;
  String? name;
  SensorCategoryEntity({this.id, this.name});
  factory SensorCategoryEntity.fromModel(SensorCategoryItem model) {
    return SensorCategoryEntity(id: model.id, name: model.name);
  }
}
