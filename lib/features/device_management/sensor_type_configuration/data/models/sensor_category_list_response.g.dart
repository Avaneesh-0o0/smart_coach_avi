// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_category_list_response.dart';

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

SensorCategoryListResponse _$SensorCategoryListResponseFromJson(
  Map<String, dynamic> json,
) => SensorCategoryListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => SensorCategoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SensorCategoryListResponseToJson(
  SensorCategoryListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

SensorCategoryItem _$SensorCategoryItemFromJson(Map<String, dynamic> json) =>
    SensorCategoryItem(
      id: _parseInt(json['id']),
      name: json['name'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SensorCategoryItemToJson(SensorCategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };
