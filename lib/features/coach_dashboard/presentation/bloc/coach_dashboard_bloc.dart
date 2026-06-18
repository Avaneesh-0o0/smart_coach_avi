import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/usecases/coach_configuration_usecase.dart';
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
    try {
      final coaches = await coachConfigurationUseCase.fetchCoachList();
      final devices = await coachConfigurationUseCase.fetchDevice();

      final selectedCoach = state.selectedCoach;
      final List<DeviceEntity> filtered = selectedCoach != null
          ? _filterDevices(devices, selectedCoach)
          : [];

      emit(state.copyWith(
        isLoading: false,
        coachList: coaches,
        allDevices: devices,
        filteredDevices: filtered,
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
