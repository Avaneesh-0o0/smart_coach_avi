import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/usecases/sensor_type_configuration_usecase.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_state.dart';
@injectable
class SensorTypeConfigurationBloc extends Bloc<SensorTypeConfigurationEvent, SensorTypeConfigurationState> {
  final SensorTypeConfigurationUseCase sensorTypeConfigurationUseCase;
  SensorTypeConfigurationBloc({required this.sensorTypeConfigurationUseCase}) : super(SensorTypeConfigurationInitial()) {
    on<LoadSensorTypeConfiguration>(_onLoad);
  }
  void _onLoad(LoadSensorTypeConfiguration event, Emitter<SensorTypeConfigurationState> emit) async {
    emit(SensorTypeConfigurationLoading());
    try {
      await sensorTypeConfigurationUseCase.fetchSensor();
      emit(SensorTypeConfigurationLoaded());
    } catch (e) {
      emit(SensorTypeConfigurationError(e.toString()));
    }
  }
}
