import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';

@injectable
class UserManagementRemoteDataSourceImpl {
  final RestClient restClient;

  UserManagementRemoteDataSourceImpl(this.restClient);

  Future<List<UserItem>> getPendingUsers(int userId,
      {String? status,
      String? organisationType,
      String? fromDate,
      String? toDate}) async {
    return safeRequest(() async {
      final response = await restClient.getPendingUsers(userId,
          status: status,
          organisationType: organisationType,
          fromDate: fromDate,
          toDate: toDate);
      if (!response.success) throw Exception(response.message);
      return response.data ?? [];
    });
  }

  Future<String> approveUser(int userId, Map<String, dynamic> body) async {
    return safeRequest(() async {
      final response = await restClient.approveUser(userId, body);
      if (!response.success) throw Exception(response.message);
      return response.message;
    });
  }

  Future<String> approveBulkUser(
      int userId, Map<String, dynamic> body) async {
    return safeRequest(() async {
      final response = await restClient.approveBulkUser(userId, body);
      if (!response.success) throw Exception(response.message);
      return response.message;
    });
  }

  Future<String> changeRole(Map<String, dynamic> body) async {
    return safeRequest(() async {
      final response = await restClient.changeRole(body);
      if (!response.success) throw Exception(response.message);
      return response.message;
    });
  }
}
