import 'package:json_annotation/json_annotation.dart';

part 'fsds_status_response.g.dart';

@JsonSerializable()
class FsdsStatusResponse {
  final bool success;
  final String message;
  final List<FsdsBypassData>? data;

  FsdsStatusResponse({required this.success, required this.message, this.data});

  factory FsdsStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$FsdsStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FsdsStatusResponseToJson(this);
}

@JsonSerializable()
class FsdsBypassData {
  @JsonKey(name: 'device_id')
  final String? deviceId;

  @JsonKey(name: 'device_name')
  final String? deviceName;

  @JsonKey(name: 'coach_unique_id')
  final String? coachUniqueId;

  @JsonKey(name: 'coach_display_id')
  final String? coachDisplayId;

  @JsonKey(name: 'coach_number')
  final String? coachNumber;

  @JsonKey(name: 'train_id')
  final int? trainId;

  @JsonKey(name: 'train_no')
  final String? trainNo;

  @JsonKey(name: 'train_name')
  final String? trainName;

  final String? location;

  @JsonKey(name: 'bypass_status')
  final bool? bypassStatus;

  @JsonKey(name: 'alert_status')
  final bool? alertStatus;

  final String? timestamp;
  final String? remarks;

  @JsonKey(name: 'sensor_id')
  final String? sensorId;

  FsdsBypassData({
    this.deviceId,
    this.deviceName,
    this.coachUniqueId,
    this.coachDisplayId,
    this.coachNumber,
    this.trainId,
    this.trainNo,
    this.trainName,
    this.location,
    this.bypassStatus,
    this.alertStatus,
    this.timestamp,
    this.remarks,
    this.sensorId,
  });

  factory FsdsBypassData.fromJson(Map<String, dynamic> json) =>
      _$FsdsBypassDataFromJson(json);

  Map<String, dynamic> toJson() => _$FsdsBypassDataToJson(this);
}
