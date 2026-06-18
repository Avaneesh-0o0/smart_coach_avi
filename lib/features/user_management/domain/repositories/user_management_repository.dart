import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';

abstract class UserManagementRepository {
  Future<List<UserItem>> getPendingUsers(int userId,
      {String? status,
      String? organisationType,
      String? fromDate,
      String? toDate});

  Future<String> approveUser(int userId, Map<String, dynamic> body);

  Future<String> approveBulkUser(int userId, Map<String, dynamic> body);

  Future<String> changeRole(Map<String, dynamic> body);
}
