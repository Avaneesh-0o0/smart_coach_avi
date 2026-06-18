import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_status_response.dart';

abstract class FsdsRemoteDataSource {
  Future<FsdsStatusResponse> getFsdsStatus();
}

@Injectable(as: FsdsRemoteDataSource)
class FsdsRemoteDataSourceImpl implements FsdsRemoteDataSource {
  final RestClient restClient;

  FsdsRemoteDataSourceImpl(this.restClient);

  @override
  Future<FsdsStatusResponse> getFsdsStatus() async {
    return safeRequest(() async {
      return await restClient.getFsdsStatus();
    });
  }
}
