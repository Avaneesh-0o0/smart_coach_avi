import 'package:json_annotation/json_annotation.dart';
part 'break_binding_response.g.dart';
@JsonSerializable()
class BreakBindingResponse {
  final bool success;
  final String message;
  BreakBindingResponse({required this.success, required this.message});
  factory BreakBindingResponse.fromJson(Map<String, dynamic> json) => _$BreakBindingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BreakBindingResponseToJson(this);
}
