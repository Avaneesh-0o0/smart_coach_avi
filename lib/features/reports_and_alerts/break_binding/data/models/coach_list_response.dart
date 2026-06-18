import 'package:json_annotation/json_annotation.dart';
part 'coach_list_response.g.dart';
@JsonSerializable()
class CoachListResponseForBreakBinding {
  final bool success;
  final String message;
  final List<CoachItemForBreakBinding>? data;
  CoachListResponseForBreakBinding({required this.success, required this.message, this.data});
  factory CoachListResponseForBreakBinding.fromJson(Map<String, dynamic> json) => _$CoachListResponseForBreakBindingFromJson(json);
  Map<String, dynamic> toJson() => _$CoachListResponseForBreakBindingToJson(this);
}
@JsonSerializable()
class CoachItemForBreakBinding {
  @JsonKey(name: 'coach_id') final int? coachId;
  @JsonKey(name: 'coach_number') final String? coachNumber;
  CoachItemForBreakBinding({this.coachId, this.coachNumber});
  factory CoachItemForBreakBinding.fromJson(Map<String, dynamic> json) => _$CoachItemForBreakBindingFromJson(json);
  Map<String, dynamic> toJson() => _$CoachItemForBreakBindingToJson(this);
}
