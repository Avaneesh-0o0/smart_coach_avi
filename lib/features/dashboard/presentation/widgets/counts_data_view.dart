import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/features/dashboard/domain/entities/dashboard_item.dart';

class CountsDataView extends StatelessWidget {
  final int totalTrains;
  final int smartCoaches;
  final int activeDevices;
  final int activeSensors;
  final int criticalAlerts;
  final int warnings;
  final int moderate;
  final int normalState;

  const CountsDataView({
    super.key,
    required this.totalTrains,
    required this.smartCoaches,
    required this.activeDevices,
    required this.activeSensors,
    required this.criticalAlerts,
    required this.warnings,
    required this.moderate,
    required this.normalState,
  });

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(
        title: 'Trains',
        value: totalTrains.toString(),
        icon: Icons.train,
        color: Colors.blue,
      ),
      DashboardItem(
        title: 'Coaches',
        value: smartCoaches.toString(),
        icon: Icons.directions_bus,
        color: Colors.purple,
      ),
      DashboardItem(
        title: 'Devices',
        value: activeDevices.toString(),
        icon: Icons.devices,
        color: Colors.green,
      ),
      DashboardItem(
        title: 'Sensors',
        value: activeSensors.toString(),
        icon: Icons.sensors,
        color: Colors.teal,
      ),
      DashboardItem(
        title: 'Critical',
        value: criticalAlerts.toString(),
        icon: Icons.error,
        color: Colors.red,
        showTextInColor: true,
      ),
      DashboardItem(
        title: 'Warnings',
        value: warnings.toString(),
        icon: Icons.warning_amber,
        color: Colors.orange,
        showTextInColor: true,
      ),
      DashboardItem(
        title: 'Moderate',
        value: moderate.toString(),
        icon: Icons.error_outline,
        color: const Color(0xFFC0AF6A),
        showTextInColor: true,
      ),
      DashboardItem(
        title: 'Normal',
        value: normalState.toString(),
        icon: Icons.check_circle_outline,
        color: Colors.green,
        showTextInColor: true,
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.5.w,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2.5.w),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon circle
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color.withValues(alpha: 0.13),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 10.sp,
                ),
              ),
              // Value
              Text(
                item.value,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: item.showTextInColor ? item.color : Colors.black87,
                ),
              ),
              // Title
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}