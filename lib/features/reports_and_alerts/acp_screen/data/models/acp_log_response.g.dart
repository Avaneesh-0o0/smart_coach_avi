// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acp_log_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

AcpLogResponse _$AcpLogResponseFromJson(Map<String, dynamic> json) =>
    AcpLogResponse(
      success: json['success'] as bool?,
      count: _parseInt(json['count']),
      totalRegisteredDevices: (json['total_registered_devices'] as num?)
          ?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AcpLogData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcpLogResponseToJson(AcpLogResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'total_registered_devices': instance.totalRegisteredDevices,
      'data': instance.data,
    };

AcpLogData _$AcpLogDataFromJson(Map<String, dynamic> json) => AcpLogData(
  logId: _parseInt(json['log_id']),
  lastUpdated: json['last_updated'] as String?,
  rawAssetName: json['raw_asset_name'] as String?,
  acpStatus: json['acp_status'] as String?,
  trainNo: json['train_no'] as String?,
  commCoachNo: json['comm_coach_no'] as String?,
  techCoachNo: json['tech_coach_no'] as String?,
  trainLocation: json['train_location'] as String?,
  powerCarNo: json['power_car_no'] as String?,
  totalCount: json['total_count'] as String?,
  deviceId: json['device_id'] as String?,
);

Map<String, dynamic> _$AcpLogDataToJson(AcpLogData instance) =>
    <String, dynamic>{
      'log_id': instance.logId,
      'last_updated': instance.lastUpdated,
      'raw_asset_name': instance.rawAssetName,
      'acp_status': instance.acpStatus,
      'train_no': instance.trainNo,
      'comm_coach_no': instance.commCoachNo,
      'tech_coach_no': instance.techCoachNo,
      'train_location': instance.trainLocation,
      'power_car_no': instance.powerCarNo,
      'total_count': instance.totalCount,
      'device_id': instance.deviceId,
    };
