import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';
import 'package:smart_coach_new/features/user_management/domain/repositories/user_management_repository.dart';

@injectable
class UserManagementUseCase {
  final UserManagementRepository repository;

  UserManagementUseCase(this.repository);

  Future<List<UserItem>> getPendingUsers(int userId,
      {String? status,
      String? organisationType,
      String? fromDate,
      String? toDate}) {
    return repository.getPendingUsers(userId,
        status: status,
        organisationType: organisationType,
        fromDate: fromDate,
        toDate: toDate);
  }

  Future<String> approveUser(int userId, Map<String, dynamic> body) {
    return repository.approveUser(userId, body);
  }

  Future<String> approveBulkUser(int userId, Map<String, dynamic> body) {
    return repository.approveBulkUser(userId, body);
  }

  Future<String> changeRole(Map<String, dynamic> body) {
    return repository.changeRole(body);
  }
}
