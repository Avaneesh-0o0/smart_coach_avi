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
      
      emit(state.copyWith(
        isLoading: false,
        coachList: coaches,
        allDevices: devices,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSelectCoach(SelectCoach event, Emitter<CoachDashboardState> emit) {
    final filtered = state.allDevices.where((d) => d.coachUniqueId == event.coach.coachUniqueId).toList();
    emit(state.copyWith(
      selectedCoach: event.coach,
      filteredDevices: filtered,
    ));
  }

  void _onSearchCoach(SearchCoachById event, Emitter<CoachDashboardState> emit) {
    if (event.query.isEmpty) return;
    
    try {
      final coach = state.coachList.firstWhere(
        (c) => (c.coachUniqueId ?? "").toLowerCase().contains(event.query.toLowerCase()) || 
               (c.coachDisplayId ?? "").toLowerCase().contains(event.query.toLowerCase()),
      );
      add(SelectCoach(coach));
    } catch (e) {
      emit(state.copyWith(errorMessage: "No coach found matching '${event.query}'"));
    }
  }
}
