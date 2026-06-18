import 'package:json_annotation/json_annotation.dart';
part 'sensor_category_list_response.g.dart';
@JsonSerializable()
class SensorCategoryListResponse {
  final bool success;
  final String message;
  final List<SensorCategoryItem>? data;
  SensorCategoryListResponse({required this.success, required this.message, this.data});
  factory SensorCategoryListResponse.fromJson(Map<String, dynamic> json) => _$SensorCategoryListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SensorCategoryListResponseToJson(this);
}
@JsonSerializable()
class SensorCategoryItem {
  final int? id;
  final String? name;
  final String? description;
  SensorCategoryItem({this.id, this.name, this.description});
  factory SensorCategoryItem.fromJson(Map<String, dynamic> json) => _$SensorCategoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$SensorCategoryItemToJson(this);
}
