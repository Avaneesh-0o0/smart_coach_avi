import 'package:json_annotation/json_annotation.dart';

part 'user_management_response.g.dart';

@JsonSerializable()
class UserManagementResponse {
  final bool success;
  final String message;
  final List<UserItem>? data;

  UserManagementResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserManagementResponse.fromJson(Map<String, dynamic> json) =>
      _$UserManagementResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserManagementResponseToJson(this);
}

@JsonSerializable()
class UserItem {
  final int? userId;
  final String? name;
  final String? email;
  final String? mobile;
  final String? roleName;
  final String? status;
  final String? createdAt;
  final String? firstName;
  final String? lastName;
  final String? organization;
  final String? jobRole;
  final String? employeeId;
  final String? pan;
  final String? aadhaar;
  final String? photo;

  UserItem({
    this.userId,
    this.name,
    this.email,
    this.mobile,
    this.roleName,
    this.status,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.organization,
    this.jobRole,
    this.employeeId,
    this.pan,
    this.aadhaar,
    this.photo,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }
    String? _first(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return null;
    }
    return UserItem(
      userId: parseId(json['user_id']),
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      roleName: _first(['role_name', 'roleName', 'role']),
      status: json['status'] as String?,
      createdAt: _first(['created_at', 'createdAt', 'created_date', 'createdDate']),
      firstName: _first(['first_name', 'firstName', 'firstname', 'fname']),
      lastName: _first(['last_name', 'lastName', 'lastname', 'lname']),
      organization: _first(['organization', 'organisation', 'org', 'org_name', 'orgName']),
      jobRole: _first(['job_role', 'jobRole', 'job_title', 'jobTitle', 'role']),
      employeeId: _first(['employee_id', 'employeeId', 'emp_id', 'empId', 'employeeid']),
      pan: json['pan'] as String?,
      aadhaar: json['aadhaar'] as String?,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'email': email,
    'mobile': mobile,
    'role_name': roleName,
    'status': status,
    'created_at': createdAt,
    'first_name': firstName,
    'last_name': lastName,
    'organization': organization,
    'job_role': jobRole,
    'employee_id': employeeId,
    'pan': pan,
    'aadhaar': aadhaar,
    'photo': photo,
  };
}
