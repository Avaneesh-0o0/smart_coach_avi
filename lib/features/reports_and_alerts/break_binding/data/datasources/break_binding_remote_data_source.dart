import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';
@injectable
class BreakBindingRemoteDataSourceImpl {
  final RestClient restClient;
  BreakBindingRemoteDataSourceImpl(this.restClient);
  Future<PneumaticStatusResponse> getPneumaticStatus() async {
    return safeRequest(() async {
      final response = await restClient.getPneumaticStatus(null, null, null, null, null, null);
      return response;
    });
  }
}
