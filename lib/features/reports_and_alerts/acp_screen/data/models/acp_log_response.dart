import 'package:json_annotation/json_annotation.dart';

part 'acp_log_response.g.dart';

@JsonSerializable()
class AcpLogResponse {
  final bool? success;
  final int? count;
  @JsonKey(name: 'total_registered_devices')
  final int? totalRegisteredDevices;
  final List<AcpLogData>? data;

  AcpLogResponse({this.success, this.count, this.totalRegisteredDevices, this.data});

  factory AcpLogResponse.fromJson(Map<String, dynamic> json) =>
      _$AcpLogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcpLogResponseToJson(this);
}

@JsonSerializable()
class AcpLogData {
  @JsonKey(name: 'log_id')
  final int? logId;
  @JsonKey(name: 'last_updated')
  final String? lastUpdated;
  @JsonKey(name: 'raw_asset_name')
  final String? rawAssetName;
  @JsonKey(name: 'acp_status')
  final String? acpStatus;
  @JsonKey(name: 'train_no')
  final String? trainNo;
  @JsonKey(name: 'comm_coach_no')
  final String? commCoachNo;
  @JsonKey(name: 'tech_coach_no')
  final String? techCoachNo;
  @JsonKey(name: 'train_location')
  final String? trainLocation;
  @JsonKey(name: 'power_car_no')
  final String? powerCarNo;
  @JsonKey(name: 'total_count')
  final String? totalCount;
  @JsonKey(name: 'device_id')
  final String? deviceId;

  AcpLogData({
    this.logId,
    this.lastUpdated,
    this.rawAssetName,
    this.acpStatus,
    this.trainNo,
    this.commCoachNo,
    this.techCoachNo,
    this.trainLocation,
    this.powerCarNo,
    this.totalCount,
    this.deviceId,
  });

  factory AcpLogData.fromJson(Map<String, dynamic> json) {
    String? _safeString(dynamic val) {
      if (val == null || val == 'null') return null;
      return val.toString();
    }
    return AcpLogData(
      logId: json['log_id'] as int?,
      lastUpdated: json['last_updated'] as String?,
      rawAssetName: json['raw_asset_name'] as String?,
      acpStatus: _safeString(json['acp_status']),
      trainNo: _safeString(json['train_no']),
      commCoachNo: _safeString(json['comm_coach_no']),
      techCoachNo: _safeString(json['tech_coach_no']),
      trainLocation: json['train_location'] as String?,
      powerCarNo: _safeString(json['power_car_no']),
      totalCount: _safeString(json['total_count']),
      deviceId: _safeString(json['device_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'last_updated': lastUpdated,
      'raw_asset_name': rawAssetName,
      'acp_status': acpStatus,
      'train_no': trainNo,
      'comm_coach_no': commCoachNo,
      'tech_coach_no': techCoachNo,
      'train_location': trainLocation,
      'power_car_no': powerCarNo,
      'total_count': totalCount,
      'device_id': deviceId,
    };
  }
}
