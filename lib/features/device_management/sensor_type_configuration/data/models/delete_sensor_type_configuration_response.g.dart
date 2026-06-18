// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_sensor_type_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteSensorTypeConfigurationResponse
_$DeleteSensorTypeConfigurationResponseFromJson(Map<String, dynamic> json) =>
    DeleteSensorTypeConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$DeleteSensorTypeConfigurationResponseToJson(
  DeleteSensorTypeConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};
