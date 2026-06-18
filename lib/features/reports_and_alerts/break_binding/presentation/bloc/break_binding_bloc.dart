import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/usecases/break_binding_usecases.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/presentation/bloc/break_binding_event.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/presentation/bloc/break_binding_state.dart';
@injectable
class BrakeBindingBloc extends Bloc<BrakeBindingEvent, BrakeBindingState> {
  final BreakBindingUsecases breakBindingUsecases;
  BrakeBindingBloc({required this.breakBindingUsecases}) : super(BrakeBindingInitial()) {
    on<LoadBrakeBinding>(_onLoad);
  }
  void _onLoad(LoadBrakeBinding event, Emitter<BrakeBindingState> emit) async {
    emit(BrakeBindingLoading());
    try {
      await breakBindingUsecases.getPneumaticStatus();
      emit(BrakeBindingLoaded());
    } catch (e) {
      emit(BrakeBindingError(e.toString()));
    }
  }
}
