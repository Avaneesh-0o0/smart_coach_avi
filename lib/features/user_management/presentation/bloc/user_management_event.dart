import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';

abstract class UserManagementEvent {}

class LoadPendingUsers extends UserManagementEvent {}

class ApproveUser extends UserManagementEvent {
  final UserItem user;
  ApproveUser(this.user);
}

class RejectUser extends UserManagementEvent {
  final UserItem user;
  RejectUser(this.user);
}

class BulkApproveUsers extends UserManagementEvent {
  final List<UserItem> users;
  BulkApproveUsers(this.users);
}

class BulkRejectUsers extends UserManagementEvent {
  final List<UserItem> users;
  BulkRejectUsers(this.users);
}

class UpdateSearch extends UserManagementEvent {
  final String query;
  UpdateSearch(this.query);
}

class ToggleSelection extends UserManagementEvent {
  final UserItem user;
  ToggleSelection(this.user);
}

class ToggleSelectAll extends UserManagementEvent {}

class ApplyFilters extends UserManagementEvent {
  final Set<String> statuses;
  final Set<String> orgTypes;
  final String? fromDate;
  final String? toDate;
  ApplyFilters({
    required this.statuses,
    required this.orgTypes,
    this.fromDate,
    this.toDate,
  });
}

class ResetFilters extends UserManagementEvent {}
