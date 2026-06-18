// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_condition_request.dart';

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

_SubConditionRequest _$SubConditionRequestFromJson(Map<String, dynamic> json) =>
    _SubConditionRequest(
      operator: json['operator'] as String?,
      thresholdValue: json['threshold_value'] as num?,
      connector: json['connector'] as String?,
      sortOrder: _parseInt(json['sort_order']),
    );

Map<String, dynamic> _$SubConditionRequestToJson(
  _SubConditionRequest instance,
) => <String, dynamic>{
  'operator': instance.operator,
  'threshold_value': instance.thresholdValue,
  'connector': instance.connector,
  'sort_order': instance.sortOrder,
};
