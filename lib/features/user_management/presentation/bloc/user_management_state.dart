import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';

abstract class UserManagementState {}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UserManagementLoaded extends UserManagementState {
  final List<UserItem> allUsers;
  final List<UserItem> filteredUsers;
  final Set<UserItem> selectedUsers;
  final String searchQuery;
  final Set<String> filterStatuses;
  final Set<String> filterOrgTypes;
  final String? filterFromDate;
  final String? filterToDate;
  final String? sortColumn;
  final bool sortAscending;
  final String? actionMessage;
  final String? errorMessage;

  UserManagementLoaded({
    required this.allUsers,
    required this.filteredUsers,
    this.selectedUsers = const {},
    this.searchQuery = '',
    this.filterStatuses = const {},
    this.filterOrgTypes = const {},
    this.filterFromDate,
    this.filterToDate,
    this.sortColumn,
    this.sortAscending = true,
    this.actionMessage,
    this.errorMessage,
  });

  UserManagementLoaded copyWith({
    List<UserItem>? allUsers,
    List<UserItem>? filteredUsers,
    Set<UserItem>? selectedUsers,
    String? searchQuery,
    Set<String>? filterStatuses,
    Set<String>? filterOrgTypes,
    String? filterFromDate,
    String? filterToDate,
    String? sortColumn,
    bool? sortAscending,
    String? actionMessage,
    String? errorMessage,
    bool clearAction = false,
    bool clearError = false,
  }) {
    return UserManagementLoaded(
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatuses: filterStatuses ?? this.filterStatuses,
      filterOrgTypes: filterOrgTypes ?? this.filterOrgTypes,
      filterFromDate: filterFromDate ?? this.filterFromDate,
      filterToDate: filterToDate ?? this.filterToDate,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      actionMessage: clearAction ? null : (actionMessage ?? this.actionMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class UserManagementError extends UserManagementState {
  final String error;
  UserManagementError(this.error);
}
