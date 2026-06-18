import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/si_unit_list_response.dart';
class SiUnitEntity {
  int? id;
  String? unit;
  SiUnitEntity({this.id, this.unit});
  factory SiUnitEntity.fromModel(SiUnitItem model) {
    return SiUnitEntity(id: model.id, unit: model.unit);
  }
}
