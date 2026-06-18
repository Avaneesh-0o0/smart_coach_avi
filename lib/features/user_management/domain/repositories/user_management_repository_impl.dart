import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/user_management/data/datasources/user_management_remote_data_source.dart';
import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';
import 'package:smart_coach_new/features/user_management/domain/repositories/user_management_repository.dart';

@Injectable(as: UserManagementRepository)
class UserManagementRepositoryRepositoryImpl
    implements UserManagementRepository {
  final UserManagementRemoteDataSourceImpl remoteDataSource;

  UserManagementRepositoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserItem>> getPendingUsers(int userId,
      {String? status,
      String? organisationType,
      String? fromDate,
      String? toDate}) async {
    return remoteDataSource.getPendingUsers(userId,
        status: status,
        organisationType: organisationType,
        fromDate: fromDate,
        toDate: toDate);
  }

  @override
  Future<String> approveUser(int userId, Map<String, dynamic> body) async {
    return remoteDataSource.approveUser(userId, body);
  }

  @override
  Future<String> approveBulkUser(int userId, Map<String, dynamic> body) async {
    return remoteDataSource.approveBulkUser(userId, body);
  }

  @override
  Future<String> changeRole(Map<String, dynamic> body) async {
    return remoteDataSource.changeRole(body);
  }
}
