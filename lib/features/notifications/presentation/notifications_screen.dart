import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<NotificationItem> notifications = [
      NotificationItem(
        title: 'Critical Alert',
        message: 'Hot axle detected on Train T-12345, Coach C-3',
        time: '2 minutes ago',
        isRead: false,
        type: NotificationType.critical,
      ),
      NotificationItem(
        title: 'Maintenance Alert',
        message: 'Scheduled maintenance for Master Module M-001 tomorrow',
        time: '1 hour ago',
        isRead: false,
        type: NotificationType.maintenance,
      ),
      NotificationItem(
        title: 'System Update',
        message: 'New sensor configuration has been added successfully',
        time: '3 hours ago',
        isRead: true,
        type: NotificationType.info,
      ),
      NotificationItem(
        title: 'Warning',
        message: 'Diesel level below threshold on Train T-98765',
        time: '5 hours ago',
        isRead: true,
        type: NotificationType.warning,
      ),
      NotificationItem(
        title: 'User Approval',
        message: 'New user registration request pending approval',
        time: '1 day ago',
        isRead: true,
        type: NotificationType.info,
      ),
      NotificationItem(
        title: 'Critical Alert',
        message: 'BC Pressure anomaly detected on Train T-54321',
        time: '2 days ago',
        isRead: true,
        type: NotificationType.critical,
      ),
    ];

    return Scaffold(
      backgroundColor: ColorConstants.screenBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all as read',
              style: TextStyle(
                fontSize: 10.sp,
                color: ColorConstants.subTextLightBlueColor,
              ),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 60.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case NotificationType.critical:
        typeColor = Colors.red;
        typeIcon = Icons.error_outline;
        break;
      case NotificationType.warning:
        typeColor = Colors.orange;
        typeIcon = Icons.warning_amber_outlined;
        break;
      case NotificationType.maintenance:
        typeColor = Colors.blue;
        typeIcon = Icons.build_outlined;
        break;
      case NotificationType.info:
        typeColor = Colors.green;
        typeIcon = Icons.info_outline;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : Colors.blue[50]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(
              typeIcon,
              color: typeColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum NotificationType {
  critical,
  warning,
  maintenance,
  info,
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
