import 'package:json_annotation/json_annotation.dart';
part 'pneumatic_status_model.g.dart';
@JsonSerializable()
class PneumaticStatusResponse {
  final bool success;
  final String? message;
  final PneumaticHistory? history;
  PneumaticStatusResponse({required this.success, this.message, this.history});
  factory PneumaticStatusResponse.fromJson(Map<String, dynamic> json) => _$PneumaticStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PneumaticStatusResponseToJson(this);
}
@JsonSerializable()
class PneumaticHistory {
  final List<PneumaticHistoryData>? data;
  PneumaticHistory({this.data});
  factory PneumaticHistory.fromJson(Map<String, dynamic> json) => _$PneumaticHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PneumaticHistoryToJson(this);
}
@JsonSerializable()
class PneumaticHistoryData {
  @JsonKey(name: 'train_no') final String? trainNo;
  @JsonKey(name: 'coach_no') final String? coachNo;
  @JsonKey(name: 'device_id') final String? deviceId;
  @JsonKey(name: 'brake_fault') final String? brakeFault;
  @JsonKey(name: 'brake_status') final String? brakeStatus;
  @JsonKey(name: 'created_at') final String? createdAt;
  PneumaticHistoryData({this.trainNo, this.coachNo, this.deviceId, this.brakeFault, this.brakeStatus, this.createdAt});
  factory PneumaticHistoryData.fromJson(Map<String, dynamic> json) => _$PneumaticHistoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$PneumaticHistoryDataToJson(this);
}
