// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_list_response.dart';

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

TrainListResponseForBreakBinding _$TrainListResponseForBreakBindingFromJson(
  Map<String, dynamic> json,
) => TrainListResponseForBreakBinding(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => TrainItemForBreakBinding.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TrainListResponseForBreakBindingToJson(
  TrainListResponseForBreakBinding instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

TrainItemForBreakBinding _$TrainItemForBreakBindingFromJson(
  Map<String, dynamic> json,
) => TrainItemForBreakBinding(
  trainId: _parseInt(json['train_id']),
  trainNumber: _parseInt(json['train_number']),
  trainName: json['train_name'] as String?,
);

Map<String, dynamic> _$TrainItemForBreakBindingToJson(
  TrainItemForBreakBinding instance,
) => <String, dynamic>{
  'train_id': instance.trainId,
  'train_number': instance.trainNumber,
  'train_name': instance.trainName,
};
