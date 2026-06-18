import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';
import 'package:smart_coach_new/features/user_management/domain/usecases/user_management_usecase.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_event.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_state.dart';

@injectable
class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final UserManagementUseCase userManagementUseCase;
  final Prefs prefs;

  int get _userId => prefs.userId ?? 0;

  UserManagementBloc({
    required this.userManagementUseCase,
    required this.prefs,
  }) : super(UserManagementInitial()) {
    on<LoadPendingUsers>(_onLoadPendingUsers);
    on<ApproveUser>(_onApproveUser);
    on<RejectUser>(_onRejectUser);
    on<BulkApproveUsers>(_onBulkApproveUsers);
    on<BulkRejectUsers>(_onBulkRejectUsers);
    on<UpdateSearch>(_onUpdateSearch);
    on<ToggleSelection>(_onToggleSelection);
    on<ToggleSelectAll>(_onToggleSelectAll);
    on<ApplyFilters>(_onApplyFilters);
    on<ResetFilters>(_onResetFilters);
  }

  void _onLoadPendingUsers(
    LoadPendingUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is UserManagementLoaded) {
      emit((state as UserManagementLoaded)
          .copyWith(errorMessage: null, clearAction: true));
    } else {
      emit(UserManagementLoading());
    }
    try {
      final loaded = state is UserManagementLoaded
          ? state as UserManagementLoaded
          : null;
      List<UserItem> users = await userManagementUseCase.getPendingUsers(
        _userId,
        status: loaded?.filterStatuses.isNotEmpty == true
            ? loaded!.filterStatuses.join(',')
            : null,
        organisationType: loaded?.filterOrgTypes.isNotEmpty == true
            ? loaded!.filterOrgTypes.join(',')
            : null,
        fromDate: loaded?.filterFromDate != null && loaded!.filterFromDate!.isNotEmpty
            ? Utils.convertToIsoDate(loaded.filterFromDate!)
            : null,
        toDate: loaded?.filterToDate != null && loaded!.filterToDate!.isNotEmpty
            ? Utils.convertToIsoDate(loaded.filterToDate!)
            : null,
      );
      final searchQuery = loaded?.searchQuery ?? '';
      final filtered = _applySearch(users, searchQuery);
      emit(UserManagementLoaded(
        allUsers: users,
        filteredUsers: filtered,
        searchQuery: searchQuery,
        filterStatuses: loaded?.filterStatuses ?? {},
        filterOrgTypes: loaded?.filterOrgTypes ?? {},
        filterFromDate: loaded?.filterFromDate,
        filterToDate: loaded?.filterToDate,
        sortColumn: loaded?.sortColumn,
        sortAscending: loaded?.sortAscending ?? true,
      ));
    } catch (e) {
      if (state is UserManagementLoaded) {
        emit((state as UserManagementLoaded)
            .copyWith(errorMessage: e.toString()));
      } else {
        emit(UserManagementError(e.toString()));
      }
    }
  }

  void _onApproveUser(
    ApproveUser event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    emit(current.copyWith(errorMessage: null, clearAction: true));
    try {
      if (event.user.userId == null) {
        emit(current.copyWith(errorMessage: 'Invalid user ID'));
        return;
      }
      final msg = await userManagementUseCase.approveUser(
        _userId,
        {'user_id': event.user.userId, 'status': 'approved'},
      );
      final updated = current.allUsers.map((u) {
        if (u.userId == event.user.userId) {
          return UserItem(
            userId: u.userId,
            name: u.name,
            email: u.email,
            mobile: u.mobile,
            roleName: u.roleName,
            status: 'approved',
            createdAt: u.createdAt,
            firstName: u.firstName,
            lastName: u.lastName,
            organization: u.organization,
            jobRole: u.jobRole,
            employeeId: u.employeeId,
            pan: u.pan,
            aadhaar: u.aadhaar,
            photo: u.photo,
          );
        }
        return u;
      }).toList();
      final filtered = _applySearch(updated, current.searchQuery);
      emit(current.copyWith(
        allUsers: updated,
        filteredUsers: filtered,
        actionMessage: msg,
        selectedUsers: {},
      ));
    } catch (e) {
      emit(current.copyWith(errorMessage: e.toString()));
    }
  }

  void _onRejectUser(
    RejectUser event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    emit(current.copyWith(errorMessage: null, clearAction: true));
    try {
      if (event.user.userId == null) {
        emit(current.copyWith(errorMessage: 'Invalid user ID'));
        return;
      }
      final msg = await userManagementUseCase.approveUser(
        _userId,
        {'user_id': event.user.userId, 'status': 'rejected'},
      );
      final updated = current.allUsers.map((u) {
        if (u.userId == event.user.userId) {
          return UserItem(
            userId: u.userId,
            name: u.name,
            email: u.email,
            mobile: u.mobile,
            roleName: u.roleName,
            status: 'rejected',
            createdAt: u.createdAt,
            firstName: u.firstName,
            lastName: u.lastName,
            organization: u.organization,
            jobRole: u.jobRole,
            employeeId: u.employeeId,
            pan: u.pan,
            aadhaar: u.aadhaar,
            photo: u.photo,
          );
        }
        return u;
      }).toList();
      final filtered = _applySearch(updated, current.searchQuery);
      emit(current.copyWith(
        allUsers: updated,
        filteredUsers: filtered,
        actionMessage: msg,
        selectedUsers: {},
      ));
    } catch (e) {
      emit(current.copyWith(errorMessage: e.toString()));
    }
  }

  void _onBulkApproveUsers(
    BulkApproveUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    emit(current.copyWith(errorMessage: null, clearAction: true));
    try {
      final userIds = event.users.map((u) => u.userId).where((id) => id != null).toList();
      if (userIds.isEmpty) {
        emit(current.copyWith(errorMessage: 'No valid users selected'));
        return;
      }
      final msg = await userManagementUseCase.approveBulkUser(
        _userId,
        {'user_ids': userIds, 'status': 'approved'},
      );
      add(LoadPendingUsers());
      emit(current.copyWith(actionMessage: msg, selectedUsers: {}));
    } catch (e) {
      emit(current.copyWith(errorMessage: e.toString()));
    }
  }

  void _onBulkRejectUsers(
    BulkRejectUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    emit(current.copyWith(errorMessage: null, clearAction: true));
    try {
      final userIds = event.users.map((u) => u.userId).where((id) => id != null).toList();
      if (userIds.isEmpty) {
        emit(current.copyWith(errorMessage: 'No valid users selected'));
        return;
      }
      final msg = await userManagementUseCase.approveBulkUser(
        _userId,
        {'user_ids': userIds, 'status': 'rejected'},
      );
      add(LoadPendingUsers());
      emit(current.copyWith(actionMessage: msg, selectedUsers: {}));
    } catch (e) {
      emit(current.copyWith(errorMessage: e.toString()));
    }
  }

  void _onUpdateSearch(
    UpdateSearch event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    final filtered = _applySearch(current.allUsers, event.query);
    emit(current.copyWith(
      searchQuery: event.query,
      filteredUsers: filtered,
      selectedUsers: {},
    ));
  }

  void _onToggleSelection(
    ToggleSelection event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    final selected = Set<UserItem>.from(current.selectedUsers);
    if (selected.contains(event.user)) {
      selected.remove(event.user);
    } else {
      selected.add(event.user);
    }
    emit(current.copyWith(selectedUsers: selected));
  }

  void _onToggleSelectAll(
    ToggleSelectAll event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    if (current.selectedUsers.length == current.filteredUsers.length) {
      emit(current.copyWith(selectedUsers: {}));
    } else {
      emit(current.copyWith(
        selectedUsers: current.filteredUsers.toSet(),
      ));
    }
  }

  void _onApplyFilters(
    ApplyFilters event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    emit(current.copyWith(
      filterStatuses: event.statuses,
      filterOrgTypes: event.orgTypes,
      filterFromDate: event.fromDate,
      filterToDate: event.toDate,
      errorMessage: null,
      clearAction: true,
    ));
    add(LoadPendingUsers());
  }

  void _onResetFilters(
    ResetFilters event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! UserManagementLoaded) return;
    final current = state as UserManagementLoaded;
    emit(current.copyWith(
      filterStatuses: {},
      filterOrgTypes: {},
      filterFromDate: null,
      filterToDate: null,
      errorMessage: null,
      clearAction: true,
    ));
    add(LoadPendingUsers());
  }

  List<UserItem> _applySearch(List<UserItem> users, String query) {
    if (query.isEmpty) return users;
    final q = query.toLowerCase();
    return users.where((u) {
      return (u.firstName?.toLowerCase().contains(q) == true) ||
          (u.lastName?.toLowerCase().contains(q) == true) ||
          (u.mobile?.toLowerCase().contains(q) == true) ||
          (u.email?.toLowerCase().contains(q) == true) ||
          (u.organization?.toLowerCase().contains(q) == true) ||
          (u.jobRole?.toLowerCase().contains(q) == true) ||
          (u.employeeId?.toLowerCase().contains(q) == true) ||
          (u.pan?.toLowerCase().contains(q) == true) ||
          (u.aadhaar?.toLowerCase().contains(q) == true) ||
          (u.status?.toLowerCase().contains(q) == true);
    }).toList();
  }
}
