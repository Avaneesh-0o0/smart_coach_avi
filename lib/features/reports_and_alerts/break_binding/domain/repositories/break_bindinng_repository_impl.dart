import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/datasources/break_binding_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/repositories/break_bindinng_repository.dart';
@Injectable(as: BreakBindinngRepository)
class BreakBindinngRepositoryImpl implements BreakBindinngRepository {
  final BreakBindingRemoteDataSourceImpl remoteDataSource;
  BreakBindinngRepositoryImpl({required this.remoteDataSource});
  @override
  Future<PneumaticStatusResponse> getPneumaticStatus() async {
    return remoteDataSource.getPneumaticStatus();
  }
}
