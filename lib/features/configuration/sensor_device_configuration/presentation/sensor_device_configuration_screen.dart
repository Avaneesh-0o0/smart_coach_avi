import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/widgets/configure_sensor_device.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/widgets/sensor_device_list.dart';

class SensorDeviceConfigurationScreen extends StatefulWidget {
  const SensorDeviceConfigurationScreen({super.key});

  @override
  State<SensorDeviceConfigurationScreen> createState() =>
      _SensorDeviceConfigurationScreenState();
}

class _SensorDeviceConfigurationScreenState extends State<SensorDeviceConfigurationScreen> {
  int selectedTab = 0;
  SensorDeviceEntity? selectedSensorDeviceItem;

  Future<void> _exportToExcel() async {
    final bloc = context.read<SensorDeviceConfigurationBloc>();
    final items = bloc.state.sensorDeviceList;
    if (items.isEmpty) return;

    final excel = Excel.createExcel();
    final sheet = excel['Sensors'];

    final headers = [
      'Tech Coach No', 'Comm Coach No', 'Sensor ID', 'Device Name',
      'Train No', 'Location', 'Status', 'Install Date', 'Device Unique ID',
      'Created', 'Created By', 'Updated', 'Updated By',
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (final item in items) {
      final deviceName = item.shortName?.isNotEmpty == true
          ? item.shortName!
          : item.fullName?.isNotEmpty == true
              ? item.fullName!
              : item.name ?? item.deviceId ?? '';
      sheet.appendRow([
        TextCellValue(item.techCoachNo ?? ''),
        TextCellValue(item.commCoachNo ?? ''),
        TextCellValue(item.sensorTypeName ?? ''),
        TextCellValue(deviceName),
        TextCellValue(item.trainNo ?? ''),
        TextCellValue(item.location ?? ''),
        TextCellValue(item.status ?? ''),
        TextCellValue(item.installDate ?? ''),
        TextCellValue(item.deviceUniqueId ?? ''),
        TextCellValue(item.createdDate ?? ''),
        TextCellValue(item.createdBy?.toString() ?? ''),
        TextCellValue(item.updatedDate ?? ''),
        TextCellValue(item.updatedBy?.toString() ?? ''),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sensors.xlsx');
    await file.writeAsBytes(excel.encode()!);
    await Share.shareXFiles([XFile(file.path)], text: 'Sensor Configuration Export');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Sensor Configuration",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.0.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomToggleButtons(
                        selectedIndex: selectedTab,
                        labels: const ['Configure', 'List'],
                        onTap: (index) {
                          selectedSensorDeviceItem = null;
                          selectedTab = index;
                          setState(() {});
                        },
                      ),
                    ),
                    if (selectedTab == 1)
                      SizedBox(
                        width: 4.w,
                      ),
                    if (selectedTab == 1)
                      CustomButton(
                        text: 'Export',
                        color: Colors.white,
                        textColor: Colors.black,
                        textSize: 12,
                        showBorder: true,
                        prefixIcon: Icons.download_outlined,
                        iconSize: 4,
                        padding: EdgeInsets.symmetric(
                          vertical: 1.3.h,
                          horizontal: 3.w,
                        ),
                        radius: 8,
                        onPressed: _exportToExcel,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: selectedTab == 0
                    ? ConfigureSensorDevice(
                        selectedSensorDeviceItem: selectedSensorDeviceItem,
                        onGoToListAndRefresh: () {
                          selectedTab = 1;
                          setState(
                            () {},
                          );
                        },
                      )
                    : SensorDeviceList(
                        onTapEdit: (SensorDeviceEntity sensorDeviceEntity) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<SensorDeviceConfigurationBloc>(),
                                child: Scaffold(
                                  appBar: AppBar(
                                    backgroundColor: Colors.white,
                                    elevation: 0.5,
                                    leading: IconButton(
                                      icon: Icon(Icons.arrow_back, color: Colors.black),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    title: Text(
                                      "Edit Sensor Configuration",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    centerTitle: true,
                                  ),
                                  body: SafeArea(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                      child: ConfigureSensorDevice(
                                        selectedSensorDeviceItem: sensorDeviceEntity,
                                        onGoToListAndRefresh: () {
                                          Navigator.pop(context);
                                          context.read<SensorDeviceConfigurationBloc>().add(LoadSensorDeviceConfigurationList());
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
