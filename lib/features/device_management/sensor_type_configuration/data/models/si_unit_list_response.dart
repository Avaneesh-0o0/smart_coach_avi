import 'package:json_annotation/json_annotation.dart';
part 'si_unit_list_response.g.dart';
@JsonSerializable()
class SiUnitListResponse {
  final bool success;
  final String message;
  final List<SiUnitItem>? data;
  SiUnitListResponse({required this.success, required this.message, this.data});
  factory SiUnitListResponse.fromJson(Map<String, dynamic> json) => _$SiUnitListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SiUnitListResponseToJson(this);
}
@JsonSerializable()
class SiUnitItem {
  final int? id;
  final String? unit;
  final String? description;
  SiUnitItem({this.id, this.unit, this.description});
  factory SiUnitItem.fromJson(Map<String, dynamic> json) => _$SiUnitItemFromJson(json);
  Map<String, dynamic> toJson() => _$SiUnitItemToJson(this);
}
