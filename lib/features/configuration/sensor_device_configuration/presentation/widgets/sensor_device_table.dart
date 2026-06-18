import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SearchParams {
  final List<SensorDeviceEntity> sensorDeviceList;
  final String query;

  SearchParams(this.sensorDeviceList, this.query);
}

List<SensorDeviceEntity> _filterSensorDevice(SearchParams params) {
  final query = params.query.toLowerCase();
  return params.sensorDeviceList.where((item) {
    return [
      item.techCoachNo,
      item.commCoachNo,
      item.sensorTypeName,
      item.deviceId,
      item.trainNo,
      item.location,
      item.status,
      item.createdDate,
      item.createdBy,
      item.updatedDate,
      item.updatedBy,
    ].any((field) => field.toString().toLowerCase().contains(query));
  }).toList();
}

class SensorDeviceTable extends StatefulWidget {
  final List<SensorDeviceEntity> items;
  final Function(SensorDeviceEntity sensorDeviceEntity) onTapEdit;
  final Function(SensorDeviceEntity sensorDeviceEntity) onTapView;
  final Function(SensorDeviceEntity sensorDeviceEntity) onTapDelete;

  const SensorDeviceTable(
      {super.key,
      required this.items,
      required this.onTapEdit,
      required this.onTapView,
      required this.onTapDelete});

  @override
  State<SensorDeviceTable> createState() => _SensorDeviceTableState();
}

class _SensorDeviceTableState extends State<SensorDeviceTable> {
  late TableDataSource _dataSource;
  final DataGridController _controller = DataGridController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Timer? _debounce;

  @override
  void initState() {
    _buildDataSource();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SensorDeviceTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _buildDataSource();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _buildDataSource() async {
    final sensorDeviceListToFilter = widget.items;

    List<SensorDeviceEntity> filteredItems;
    if (_searchText.isEmpty) {
      filteredItems = sensorDeviceListToFilter;
    } else {
      filteredItems = await compute(_filterSensorDevice,
          SearchParams(sensorDeviceListToFilter, _searchText));
    }

    setState(() {
      _dataSource = TableDataSource(
        items: filteredItems,
        onTapEdit: widget.onTapEdit,
        onTapView: widget.onTapView,
        onTapDelete: widget.onTapDelete,
      );
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      setState(() {
        _searchText = value.toLowerCase();
      });
      _buildDataSource();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showSearch = true;
    final bool hasSearch = _searchText.isNotEmpty;
    return Column(
      children: [
        if (showSearch)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search by any field...',
              labelText: 'Search',
              prefixIcon: Icons.search,
              onChanged: _onSearchChanged,
              showShadowOnTextField: true,
              suffixIcon: hasSearch
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: Icon(Icons.clear, color: Colors.black, size: 18),
                    )
                  : null,
            ),
          ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SfDataGridTheme(
                  data: SfDataGridThemeData(
                    headerColor: Colors.grey.shade100,
                    headerHoverColor: Colors.grey.shade200,
                  ),
                  child: SfDataGrid(
                    controller: _controller,
                    source: _dataSource,
                    allowSorting: true,
                    selectionMode: SelectionMode.multiple,
                    showCheckboxColumn: true,
                    columnWidthMode: ColumnWidthMode.fitByCellValue,
                    isScrollbarAlwaysShown: true,
                    onSelectionChanged:
                        (List<DataGridRow> added, List<DataGridRow> removed) {
                      _dataSource.handleSelectionChanged(added, removed);
                    },
                    gridLinesVisibility: GridLinesVisibility.both,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    columns: [
                      Utils.gridColumn(label: 'Tech Coach No'),
                      Utils.gridColumn(label: 'Comm Coach No'),
                      Utils.gridColumn(label: 'Sensor ID'),
                      Utils.gridColumn(label: 'Device Name'),
                      Utils.gridColumn(label: 'Train No'),
                      Utils.gridColumn(label: 'Location'),
                      Utils.gridColumn(label: 'Status'),
                      Utils.gridColumn(label: 'Install Date'),
                      Utils.gridColumn(label: 'Created'),
                      Utils.gridColumn(label: 'Created By'),
                      Utils.gridColumn(label: 'Updated'),
                      Utils.gridColumn(label: 'Updated By'),
                      Utils.gridColumn(
                          label: 'Actions', width: 50.w, allowSorting: false),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TableDataSource extends DataGridSource {
  final List<SensorDeviceEntity> items;
  final Function(SensorDeviceEntity coachItem) onTapEdit;
  final Function(SensorDeviceEntity coachItem) onTapView;
  final Function(SensorDeviceEntity coachItem) onTapDelete;

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;
  final List<DataGridRow> _selectedRows = [];

  TableDataSource({
    required this.items,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapView,
  }) {
    String emptyText = '----';
    _rows = items.map((item) {
      final deviceName = item.shortName?.isNotEmpty == true
          ? item.shortName!
          : item.fullName?.isNotEmpty == true
              ? item.fullName!
              : item.name?.isNotEmpty == true
                  ? item.name!
                  : item.deviceId ?? emptyText;
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'Tech Coach No',
            value: item.techCoachNo?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Comm Coach No',
            value: item.commCoachNo?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Sensor ID',
            value: item.sensorTypeName?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Device Name',
            value: deviceName),
        DataGridCell<String>(
            columnName: 'Train No',
            value: item.trainNo?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Location',
            value: item.location?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Status',
            value: item.status?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Install Date',
            value: item.installDate?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Created',
            value: item.createdDate?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Created By',
            value: item.createdBy?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Updated',
            value: item.updatedDate?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Updated By',
            value: item.updatedBy?.toString() ?? emptyText),
        DataGridCell<String>(columnName: 'Actions', value: null),
      ]);
    }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = _rows.indexOf(row);
    final item = items[rowIndex];
    return DataGridRowAdapter(
      color: _selectedRows.contains(row) ? Colors.grey.shade200 : null,
      cells: row.getCells().map((cell) {
        if (cell.columnName == 'Status') {
          final cellStatus = cell.value.toString().toLowerCase().replaceAll(' ', '');
          final isOnline = cellStatus == 'online' || cellStatus == 'active';
          final Color bgColor = isOnline
              ? Colors.green.withValues(alpha: 0.13)
              : Colors.red.shade900.withValues(alpha: 0.13);
          final Color textColor = isOnline ? Colors.green : Colors.red.shade900;
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  child: Text(
                    cell.value.toString(),
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (cell.columnName == 'Actions') {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 1.w),
                GestureDetector(
                  onTap: () {
                    onTapView.call(item);
                  },
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(width: 1.5.w),
                GestureDetector(
                  onTap: () {
                    onTapEdit.call(item);
                  },
                  child: Icon(
                    Icons.mode_edit_outlined,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(width: 1.5.w),
                GestureDetector(
                  onTap: () {
                    onTapDelete.call(item);
                  },
                  child: Icon(
                    Icons.delete_forever_outlined,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void handleSelectionChanged(
      List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
    _selectedRows
      ..removeWhere((row) => removedRows.contains(row))
      ..addAll(addedRows);

    notifyListeners();
  }
}
