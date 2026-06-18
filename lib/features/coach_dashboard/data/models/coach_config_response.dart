import 'package:json_annotation/json_annotation.dart';
part 'coach_config_response.g.dart';
@JsonSerializable()
class CoachConfigResponse {
  final bool success;
  final String message;
  final CoachConfigData? data;
  CoachConfigResponse({required this.success, required this.message, this.data});
  factory CoachConfigResponse.fromJson(Map<String, dynamic> json) => _$CoachConfigResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CoachConfigResponseToJson(this);
}
@JsonSerializable()
class CoachConfigData {
  @JsonKey(name: 'config') final String? config;
  CoachConfigData({this.config});
  factory CoachConfigData.fromJson(Map<String, dynamic> json) => _$CoachConfigDataFromJson(json);
  Map<String, dynamic> toJson() => _$CoachConfigDataToJson(this);
}
