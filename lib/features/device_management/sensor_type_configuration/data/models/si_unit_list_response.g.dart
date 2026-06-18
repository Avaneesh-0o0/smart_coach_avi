// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'si_unit_list_response.dart';

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

SiUnitListResponse _$SiUnitListResponseFromJson(Map<String, dynamic> json) =>
    SiUnitListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SiUnitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SiUnitListResponseToJson(SiUnitListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

SiUnitItem _$SiUnitItemFromJson(Map<String, dynamic> json) => SiUnitItem(
  id: _parseInt(json['id']),
  unit: json['unit'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$SiUnitItemToJson(SiUnitItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unit': instance.unit,
      'description': instance.description,
    };
