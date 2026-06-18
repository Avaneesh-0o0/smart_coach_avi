abstract class SensorTypeConfigurationState {}
class SensorTypeConfigurationInitial extends SensorTypeConfigurationState {}
class SensorTypeConfigurationLoading extends SensorTypeConfigurationState {}
class SensorTypeConfigurationLoaded extends SensorTypeConfigurationState {}
class SensorTypeConfigurationError extends SensorTypeConfigurationState {
  final String error;
  SensorTypeConfigurationError(this.error);
}
