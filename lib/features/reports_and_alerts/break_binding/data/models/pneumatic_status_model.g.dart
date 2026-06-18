// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pneumatic_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PneumaticStatusResponse _$PneumaticStatusResponseFromJson(
  Map<String, dynamic> json,
) => PneumaticStatusResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  history: json['history'] == null
      ? null
      : PneumaticHistory.fromJson(json['history'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PneumaticStatusResponseToJson(
  PneumaticStatusResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'history': instance.history,
};

PneumaticHistory _$PneumaticHistoryFromJson(Map<String, dynamic> json) =>
    PneumaticHistory(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PneumaticHistoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PneumaticHistoryToJson(PneumaticHistory instance) =>
    <String, dynamic>{'data': instance.data};

PneumaticHistoryData _$PneumaticHistoryDataFromJson(
  Map<String, dynamic> json,
) => PneumaticHistoryData(
  trainNo: json['train_no'] as String?,
  coachNo: json['coach_no'] as String?,
  deviceId: json['device_id'] as String?,
  brakeFault: json['brake_fault'] as String?,
  brakeStatus: json['brake_status'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PneumaticHistoryDataToJson(
  PneumaticHistoryData instance,
) => <String, dynamic>{
  'train_no': instance.trainNo,
  'coach_no': instance.coachNo,
  'device_id': instance.deviceId,
  'brake_fault': instance.brakeFault,
  'brake_status': instance.brakeStatus,
  'created_at': instance.createdAt,
};
