import 'package:equatable/equatable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

class CoachDashboardState extends Equatable {
  final List<CoachEntity> coachList;
  final CoachEntity? selectedCoach;
  final List<DeviceEntity> allDevices;
  final List<DeviceEntity> filteredDevices;
  final bool isLoading;
  final String? errorMessage;

  const CoachDashboardState({
    this.coachList = const [],
    this.selectedCoach,
    this.allDevices = const [],
    this.filteredDevices = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CoachDashboardState copyWith({
    List<CoachEntity>? coachList,
    CoachEntity? selectedCoach,
    List<DeviceEntity>? allDevices,
    List<DeviceEntity>? filteredDevices,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CoachDashboardState(
      coachList: coachList ?? this.coachList,
      selectedCoach: selectedCoach ?? this.selectedCoach,
      allDevices: allDevices ?? this.allDevices,
      filteredDevices: filteredDevices ?? this.filteredDevices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        coachList,
        selectedCoach,
        allDevices,
        filteredDevices,
        isLoading,
        errorMessage,
      ];
}
