import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_bloc.dart';
import 'package:smart_coach_new/features/user_management/presentation/widgets/user_detail_dialog.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_event.dart';
import 'package:smart_coach_new/features/user_management/presentation/bloc/user_management_state.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserRegistrationManagementScreen extends StatefulWidget {
  const UserRegistrationManagementScreen({super.key});

  @override
  State<UserRegistrationManagementScreen> createState() =>
      _UserRegistrationManagementScreenState();
}

class _UserRegistrationManagementScreenState
    extends State<UserRegistrationManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  late UserManagementBloc _bloc;
  String _searchText = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<UserManagementBloc>()..add(LoadPendingUsers());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchText = value;
      _bloc.add(UpdateSearch(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: BlocConsumer<UserManagementBloc, UserManagementState>(
        listener: (context, state) {
          if (state is UserManagementLoading) {
            Loader.show();
          } else {
            Loader.dismiss();
          }
          if (state is UserManagementLoaded) {
            if (state.errorMessage != null) {
              Utils.showApiErrorMessageOrList(
                context,
                message: state.errorMessage!,
              );
            }
            if (state.actionMessage != null) {
              ToastMessageUtils.showMessage(context, state.actionMessage!);
            }
          }
          if (state is UserManagementError) {
            Utils.showApiErrorMessageOrList(
              context,
              message: state.error,
            );
          }
        },
        builder: (context, state) {
          if (state is UserManagementLoading && state is! UserManagementLoaded) {
            return _buildLoadingState();
          }
          if (state is UserManagementError) {
            return _buildErrorState();
          }
          if (state is UserManagementLoaded) {
            return _buildContent(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32.0),
              Container(height: 26.0, width: 70.w, color: Colors.grey[300]),
              const SizedBox(height: 8.0),
              Container(height: 16.0, width: 50.w, color: Colors.grey[300]),
              const SizedBox(height: 32.0),
              Container(
                height: 64.0,
                width: 140.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              const SizedBox(height: 24.0),
              Container(
                height: 72.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.0, color: Colors.grey),
          const SizedBox(height: 20.0),
          Text(
            'Failed to load users',
            style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () => _bloc.add(LoadPendingUsers()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(UserManagementLoaded state) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32.0),
              const Text(
                'User Registration Management',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Manage and approve user registration requests',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 32.0),
              _buildFilterButton(),
              const SizedBox(height: 24.0),
              _buildBulkActions(state),
              const SizedBox(height: 12.0),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${state.selectedUsers.length} of ${state.filteredUsers.length} selected',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Search',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 12.0),
              _buildSearchField(),
              const SizedBox(height: 20.0),
              if (state.filteredUsers.isEmpty)
                SizedBox(
                  height: 300.0,
                  child: Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF424242),
                      ),
                    ),
                  ),
                )
              else
                _buildTable(state),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => _showFilterDialog(),
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, size: 18.0, color: Colors.black),
            SizedBox(width: 6.0),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActions(UserManagementLoaded state) {
    final bool hasSelection = state.selectedUsers.isNotEmpty;
    return Wrap(
      spacing: 12.0,
      runSpacing: 8.0,
      children: [
        GestureDetector(
          onTap: hasSelection
              ? () => _bloc.add(BulkApproveUsers(state.selectedUsers.toList()))
              : null,
          child: AnimatedOpacity(
            opacity: hasSelection ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: hasSelection
                    ? const Color(0xFF43A047)
                    : const Color(0xFFA5D6A7),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      size: 18.0, color: Colors.white),
                  SizedBox(width: 6.0),
                  Text(
                    'Approve Selected',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: hasSelection
              ? () => _bloc.add(BulkRejectUsers(state.selectedUsers.toList()))
              : null,
          child: AnimatedOpacity(
            opacity: hasSelection ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: hasSelection
                    ? const Color(0xFFE53935)
                    : const Color(0xFFEF9A9A),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, size: 18.0, color: Colors.white),
                  SizedBox(width: 6.0),
                  Text(
                    'Reject Selected',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDADADA), width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20.0, color: Color(0xFF9E9E9E)),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by any field...',
                hintStyle: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF9E9E9E),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
          ),
          if (_searchText.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchText = '';
                _bloc.add(UpdateSearch(''));
              },
              child: const Icon(Icons.clear, color: Colors.black, size: 20.0),
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final state = _bloc.state;
    if (state is! UserManagementLoaded) return;

    Set<String> statuses = Set.from(state.filterStatuses);
    Set<String> orgTypes = Set.from(state.filterOrgTypes);
    TextEditingController fromDateCtrl = TextEditingController(
        text: state.filterFromDate ?? '');
    TextEditingController toDateCtrl = TextEditingController(
        text: state.filterToDate ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Options',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, size: 20.0),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Status',
                    style: TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6.0),
                ...['Pending', 'Approved', 'Rejected'].map((s) {
                  return CheckboxListTile(
                    title: Text(s, style: const TextStyle(fontSize: 14.0)),
                    value: statuses.contains(s.toLowerCase()),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      setDState(() {
                        if (v == true) {
                          statuses.add(s.toLowerCase());
                        } else {
                          statuses.remove(s.toLowerCase());
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 16.0),
                const Text('Organization Type',
                    style: TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6.0),
                ...['Indian Railways', 'Contractor'].map((s) {
                  return CheckboxListTile(
                    title: Text(s, style: const TextStyle(fontSize: 14.0)),
                    value: orgTypes.contains(s.toLowerCase()),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      setDState(() {
                        if (v == true) {
                          orgTypes.add(s.toLowerCase());
                        } else {
                          orgTypes.remove(s.toLowerCase());
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 16.0),
                const Text('Date Range',
                    style: TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDState(() {
                              fromDateCtrl.text =
                                  '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: Container(
                            height: 42.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFDADADA)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: fromDateCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 13.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDState(() {
                              toDateCtrl.text =
                                  '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: Container(
                            height: 42.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFDADADA)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: toDateCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 13.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _bloc.add(ResetFilters());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Text('Reset',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _bloc.add(ApplyFilters(
                          statuses: statuses,
                          orgTypes: orgTypes,
                          fromDate: fromDateCtrl.text.isEmpty
                              ? null
                              : fromDateCtrl.text,
                          toDate: toDateCtrl.text.isEmpty
                              ? null
                              : toDateCtrl.text,
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Text('Apply',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(UserManagementLoaded state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9D9D9), width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          child: SfDataGridTheme(
            data: SfDataGridThemeData(
              headerColor: const Color(0xFFF3F3F3),
              headerHoverColor: const Color(0xFFE8E8E8),
            ),
            child: SfDataGrid(
              source: _UserDataSource(
                items: state.filteredUsers,
                selectedUsers: state.selectedUsers,
                bloc: _bloc,
                onEdit: (user) {
                  showDialog(
                    context: context,
                    builder: (_) => UserDetailDialog(user: user),
                  );
                },
              ),
              allowSorting: true,
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              isScrollbarAlwaysShown: true,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              selectionMode: SelectionMode.none,
              defaultColumnWidth: 130.0,
              columns: [
                _gridColumn(label: '', width: 50.0, allowSorting: false),
                _gridColumn(label: 'First Name', width: 130.0),
                _gridColumn(label: 'Last Name', width: 130.0),
                _gridColumn(label: 'Mobile', width: 140.0),
                _gridColumn(label: 'Email', width: 200.0),
                _gridColumn(label: 'Organization', width: 160.0),
                _gridColumn(label: 'Job Role', width: 130.0),
                _gridColumn(label: 'Employee ID', width: 130.0),
                _gridColumn(label: 'PAN', width: 130.0),
                _gridColumn(label: 'Aadhaar', width: 140.0),
                _gridColumn(label: 'Photo', width: 80.0, allowSorting: false),
                _gridColumn(label: 'Status', width: 120.0, allowSorting: false),
                _gridColumn(label: 'Actions', width: 170.0, allowSorting: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GridColumn _gridColumn(
      {required String label, double width = 130.0, bool allowSorting = true}) {
    return GridColumn(
      columnName: label,
      label: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF666666),
          ),
        ),
      ),
      width: width,
      allowSorting: allowSorting,
    );
  }
}

class _UserDataSource extends DataGridSource {
  final List<UserItem> items;
  final Set<UserItem> selectedUsers;
  final UserManagementBloc bloc;
  final Function(UserItem)? onEdit;

  _UserDataSource({
    required this.items,
    required this.selectedUsers,
    required this.bloc,
    this.onEdit,
  }) {
    _buildRows();
  }

  late List<DataGridRow> _rows;

  void _buildRows() {
    _rows = items.map((item) {
      String firstName = item.firstName ?? '';
      String lastName = item.lastName ?? '';
      if (firstName.isEmpty && lastName.isEmpty && (item.name?.isNotEmpty == true)) {
        final parts = item.name!.trim().split(' ');
        firstName = parts.isNotEmpty ? parts.first : '';
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
      return DataGridRow(cells: [
        DataGridCell<bool>(columnName: '', value: selectedUsers.contains(item)),
        DataGridCell<String>(columnName: 'First Name', value: firstName),
        DataGridCell<String>(columnName: 'Last Name', value: lastName),
        DataGridCell<String>(columnName: 'Mobile', value: item.mobile ?? ''),
        DataGridCell<String>(columnName: 'Email', value: item.email ?? ''),
        DataGridCell<String>(
            columnName: 'Organization', value: item.organization ?? ''),
        DataGridCell<String>(
            columnName: 'Job Role', value: item.jobRole ?? ''),
        DataGridCell<String>(
            columnName: 'Employee ID', value: item.employeeId ?? ''),
        DataGridCell<String>(columnName: 'PAN', value: item.pan ?? ''),
        DataGridCell<String>(
            columnName: 'Aadhaar', value: item.aadhaar ?? ''),
        DataGridCell<String>(columnName: 'Photo', value: item.photo ?? ''),
        DataGridCell<String>(
            columnName: 'Status', value: item.status ?? ''),
        DataGridCell<String>(columnName: 'Actions', value: null),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = _rows.indexOf(row);
    final item = items[rowIndex];
    final isSelected = selectedUsers.contains(item);

    return DataGridRowAdapter(
      color: isSelected ? const Color(0xFFECECEC) : Colors.white,
      cells: row.getCells().map((cell) {
        if (cell.columnName.isEmpty) {
          return Center(
            child: SizedBox(
              width: 28.0,
              height: 28.0,
              child: Checkbox(
                value: isSelected,
                activeColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF9E9E9E), width: 2.0),
                onChanged: (_) => bloc.add(ToggleSelection(item)),
              ),
            ),
          );
        }
        if (cell.columnName == 'Status') {
          return Center(child: _statusBadge(cell.value.toString()));
        }
        if (cell.columnName == 'Photo') {
          return Center(child: _photoWidget(cell.value.toString()));
        }
        if (cell.columnName == 'Actions') {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _actionIcon(Icons.check, const Color(0xFF4CAF50), () {
                  bloc.add(ApproveUser(item));
                }),
                const SizedBox(width: 8.0),
                _actionIcon(Icons.close, const Color(0xFFF44336), () {
                  bloc.add(RejectUser(item));
                }),
                const SizedBox(width: 8.0),
                _actionIcon(Icons.edit, const Color(0xFF9E9E9E), () {
                  onEdit?.call(item);
                }),
              ],
            ),
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cell.value.toString(),
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statusBadge(String status) {
    final lower = status.toLowerCase();
    Color bg;
    Color textColor;
    if (lower == 'approved' || lower == 'active') {
      bg = const Color(0xFFD9F6DF);
      textColor = const Color(0xFF2E7D32);
    } else if (lower == 'rejected' || lower == 'inactive') {
      bg = const Color(0xFFF9E0DC);
      textColor = const Color(0xFFC62828);
    } else {
      bg = const Color(0xFFEEEEEE);
      textColor = const Color(0xFF616161);
    }
    return Container(
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Text(
          status,
          style: TextStyle(
            fontSize: 14.0,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _photoWidget(String url) {
    return CircleAvatar(
      radius: 18.0,
      backgroundColor: const Color(0xFFE0E0E0),
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? const Icon(Icons.person_outline, size: 22.0, color: Color(0xFF757575))
          : null,
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.0, color: color),
      ),
    );
  }
}
