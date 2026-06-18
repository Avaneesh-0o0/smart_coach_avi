// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_block_request.dart';

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

_ConditionBlockRequest _$ConditionBlockRequestFromJson(
  Map<String, dynamic> json,
) => _ConditionBlockRequest(
  valueTypeId: _parseInt(json['value_type_id']),
  valueFormat: json['value_format'] as String?,
  siUnitId: _parseInt(json['si_unit_id']),
  alertTypeId: _parseInt(json['alert_type_id']),
  alertMessageTemplate: json['alert_message_template'] == null
      ? null
      : AlertMessageTemplateRequest.fromJson(
          json['alert_message_template'] as Map<String, dynamic>,
        ),
  connector: json['connector'] as String?,
  subConditions: (json['sub_conditions'] as List<dynamic>?)
      ?.map((e) => SubConditionRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ConditionBlockRequestToJson(
  _ConditionBlockRequest instance,
) => <String, dynamic>{
  'value_type_id': instance.valueTypeId,
  'value_format': instance.valueFormat,
  'si_unit_id': instance.siUnitId,
  'alert_type_id': instance.alertTypeId,
  'alert_message_template': instance.alertMessageTemplate,
  'connector': instance.connector,
  'sub_conditions': instance.subConditions,
};
