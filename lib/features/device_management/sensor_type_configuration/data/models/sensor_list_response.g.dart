// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_list_response.dart';

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

SensorListResponse _$SensorListResponseFromJson(Map<String, dynamic> json) =>
    SensorListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SensorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SensorListResponseToJson(SensorListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

SensorItem _$SensorItemFromJson(Map<String, dynamic> json) => SensorItem(
  sensorTypeId: _parseInt(json['sensor_type_id']),
  name: json['name'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$SensorItemToJson(SensorItem instance) =>
    <String, dynamic>{
      'sensor_type_id': instance.sensorTypeId,
      'name': instance.name,
      'description': instance.description,
    };
