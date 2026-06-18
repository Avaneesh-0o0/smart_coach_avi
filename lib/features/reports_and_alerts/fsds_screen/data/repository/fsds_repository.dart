import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/datasource/fsds_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';

class FsdsRepository {
  final FsdsRemoteDataSource remoteDataSource;

  FsdsRepository(this.remoteDataSource);

  Future<List<FsdsAssetModel>> getFsdsStatus() async {
    final response = await remoteDataSource.getFsdsStatus();
    final data = response.data ?? [];
    return data.map((d) => FsdsAssetModel(
      deviceId: d.deviceId ?? '',
      deviceName: d.deviceName ?? '',
      coachUniqueId: d.coachUniqueId ?? '',
      coachDisplayId: d.coachDisplayId ?? '',
      coachNumber: d.coachNumber ?? '',
      trainId: d.trainId ?? 0,
      trainNo: d.trainNo ?? '',
      trainName: d.trainName ?? '',
      location: d.location ?? '',
      bypassStatus: d.bypassStatus ?? false,
      alertStatus: d.alertStatus ?? false,
      timestamp: d.timestamp ?? '',
      remarks: d.remarks ?? '',
      sensorId: d.sensorId ?? '',
    )).toList();
  }
}
