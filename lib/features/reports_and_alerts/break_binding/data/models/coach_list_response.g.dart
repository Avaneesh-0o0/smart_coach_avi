// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_list_response.dart';

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

CoachListResponseForBreakBinding _$CoachListResponseForBreakBindingFromJson(
  Map<String, dynamic> json,
) => CoachListResponseForBreakBinding(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CoachItemForBreakBinding.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoachListResponseForBreakBindingToJson(
  CoachListResponseForBreakBinding instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

CoachItemForBreakBinding _$CoachItemForBreakBindingFromJson(
  Map<String, dynamic> json,
) => CoachItemForBreakBinding(
  coachId: _parseInt(json['coach_id']),
  coachNumber: json['coach_number'] as String?,
);

Map<String, dynamic> _$CoachItemForBreakBindingToJson(
  CoachItemForBreakBinding instance,
) => <String, dynamic>{
  'coach_id': instance.coachId,
  'coach_number': instance.coachNumber,
};
