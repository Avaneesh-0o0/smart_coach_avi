import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/user_management/data/models/user_management_response.dart';

class UserDetailDialog extends StatelessWidget {
  final UserItem user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.w),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('User Details',
                      style: TextStyle(fontSize: 14.sp, color: Colors.black)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildItem(label: 'Name', value: user.name),
              _buildItem(label: 'First Name', value: user.firstName),
              _buildItem(label: 'Last Name', value: user.lastName),
              _buildItem(label: 'Email', value: user.email),
              _buildItem(label: 'Mobile', value: user.mobile),
              _buildItem(label: 'Organization', value: user.organization),
              _buildItem(label: 'Job Role', value: user.jobRole),
              _buildItem(label: 'Employee ID', value: user.employeeId),
              _buildItem(label: 'PAN', value: user.pan),
              _buildItem(label: 'Aadhaar', value: user.aadhaar),
              _buildItem(label: 'Status', value: user.status),
              _buildItem(label: 'Registered', value: user.createdAt),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Close',
                    padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
                    textSize: 12,
                    radius: 6,
                    color: const Color(0xFFF2F3F5),
                    textColor: Colors.black,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({required String label, required String? value}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
          SizedBox(height: 0.3.h),
          Text(value ?? 'N/A',
              style: TextStyle(fontSize: 12.5.sp, color: Colors.black)),
        ],
      ),
    );
  }
}
