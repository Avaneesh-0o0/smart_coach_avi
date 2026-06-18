import 'package:json_annotation/json_annotation.dart';
part 'delete_sensor_type_configuration_response.g.dart';
@JsonSerializable()
class DeleteSensorTypeConfigurationResponse {
  final bool success;
  final String message;
  DeleteSensorTypeConfigurationResponse({required this.success, required this.message});
  factory DeleteSensorTypeConfigurationResponse.fromJson(Map<String, dynamic> json) => _$DeleteSensorTypeConfigurationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DeleteSensorTypeConfigurationResponseToJson(this);
}
