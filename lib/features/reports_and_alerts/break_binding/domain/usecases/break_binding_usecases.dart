import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/repositories/break_bindinng_repository.dart';
@injectable
class BreakBindingUsecases {
  final BreakBindinngRepository repository;
  BreakBindingUsecases({required this.repository});
  Future<PneumaticStatusResponse> getPneumaticStatus() => repository.getPneumaticStatus();
}
