import 'package:json_annotation/json_annotation.dart';
part 'approve_or_reject_response.g.dart';
@JsonSerializable()
class ApproveOrRejectResponse {
  final bool success;
  final String message;
  ApproveOrRejectResponse({required this.success, required this.message});
  factory ApproveOrRejectResponse.fromJson(Map<String, dynamic> json) => _$ApproveOrRejectResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApproveOrRejectResponseToJson(this);
}
