import 'package:json_annotation/json_annotation.dart';
part 'sensor_list_response.g.dart';
@JsonSerializable()
class SensorListResponse {
  final bool success;
  final String message;
  final List<SensorItem>? data;
  SensorListResponse({required this.success, required this.message, this.data});
  factory SensorListResponse.fromJson(Map<String, dynamic> json) => _$SensorListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SensorListResponseToJson(this);
}
@JsonSerializable()
class SensorItem {
  @JsonKey(name: 'sensor_type_id') final int? sensorTypeId;
  final String? name;
  final String? description;
  SensorItem({this.sensorTypeId, this.name, this.description});
  factory SensorItem.fromJson(Map<String, dynamic> json) => _$SensorItemFromJson(json);
  Map<String, dynamic> toJson() => _$SensorItemToJson(this);
}
