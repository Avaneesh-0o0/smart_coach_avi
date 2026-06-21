import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/usecases/coach_configuration_usecase.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'coach_dashboard_event.dart';
import 'coach_dashboard_state.dart';

@injectable
class CoachDashboardBloc extends Bloc<CoachDashboardEvent, CoachDashboardState> {
  final CoachConfigurationUseCase coachConfigurationUseCase;

  CoachDashboardBloc({required this.coachConfigurationUseCase}) : super(const CoachDashboardState()) {
    on<LoadCoachDashboardData>(_onLoadData);
    on<SelectCoach>(_onSelectCoach);
    on<SearchCoachById>(_onSearchCoach);
  }

  Future<void> _onLoadData(LoadCoachDashboardData event, Emitter<CoachDashboardState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await Future.delayed(const Duration(milliseconds: 300)); // Smooth UX transition

    try {
      final List<CoachEntity> coaches = [
        const CoachEntity(
          coachId: 1,
          coachUniqueId: "COACH_B1_001",
          coachDisplayId: "B1 (AC 3-Tier)",
          makeOfCoach: "ICF",
          typeOfCoach: "LHB",
          coachStatus: "Active",
        ),
        const CoachEntity(
          coachId: 2,
          coachUniqueId: "COACH_B2_002",
          coachDisplayId: "B2 (AC 3-Tier)",
          makeOfCoach: "ICF",
          typeOfCoach: "LHB",
          coachStatus: "Active",
        ),
        const CoachEntity(
          coachId: 3,
          coachUniqueId: "COACH_S1_003",
          coachDisplayId: "S1 (Sleeper)",
          makeOfCoach: "RCF",
          typeOfCoach: "ICF",
          coachStatus: "Maintenance",
        ),
      ];

      final List<DeviceEntity> devices = [
        DeviceEntity(
          deviceId: "DEV_001",
          fullName: "Odour Sensor Node 1",
          coachUniqueId: "COACH_B1_001",
          isActive: 1,
        ),
        DeviceEntity(
          deviceId: "DEV_002",
          fullName: "Limit Switch Node 1",
          coachUniqueId: "COACH_B1_001",
          isActive: 1,
        ),
        DeviceEntity(
          deviceId: "DEV_003",
          fullName: "Odour Sensor Node 2",
          coachUniqueId: "COACH_B2_002",
          isActive: 1,
        ),
      ];

      final selectedCoach = state.selectedCoach ?? coaches.first;
      final List<DeviceEntity> filtered = _filterDevices(devices, selectedCoach);

      emit(state.copyWith(
        isLoading: false,
        coachList: coaches,
        allDevices: devices,
        filteredDevices: filtered,
        selectedCoach: selectedCoach,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  List<DeviceEntity> _filterDevices(List<DeviceEntity> devices, CoachEntity coach) {
    return devices.where((d) =>
        d.coachUniqueId == coach.coachUniqueId
    ).toList();
  }

  void _onSelectCoach(SelectCoach event, Emitter<CoachDashboardState> emit) {
    final filtered = _filterDevices(state.allDevices, event.coach);
    emit(state.copyWith(
      selectedCoach: event.coach,
      filteredDevices: filtered,
    ));
  }

  void _onSearchCoach(SearchCoachById event, Emitter<CoachDashboardState> emit) {
    if (event.query.isEmpty) return;

    final q = event.query.toLowerCase();
    final matches = state.coachList.where(
      (c) => (c.coachUniqueId ?? "").toLowerCase().contains(q) ||
             (c.coachDisplayId ?? "").toLowerCase().contains(q),
    ).toList();

    if (matches.isEmpty) {
      emit(state.copyWith(errorMessage: "No coach found matching '${event.query}'"));
      return;
    }
    add(SelectCoach(matches.first));
  }
}
