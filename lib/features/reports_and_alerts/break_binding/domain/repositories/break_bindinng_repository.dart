import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';
abstract class BreakBindinngRepository {
  Future<PneumaticStatusResponse> getPneumaticStatus();
}
