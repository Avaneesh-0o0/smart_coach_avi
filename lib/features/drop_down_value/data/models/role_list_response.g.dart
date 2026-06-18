// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

RoleListResponse _$RoleListResponseFromJson(Map<String, dynamic> json) =>
    RoleListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : RoleListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoleListResponseToJson(RoleListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

RoleListData _$RoleListDataFromJson(Map<String, dynamic> json) => RoleListData(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => RoleItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RoleListDataToJson(RoleListData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

RoleItem _$RoleItemFromJson(Map<String, dynamic> json) => RoleItem(
  roleId: _parseInt(json['role_id']),
  name: json['name'] as String?,
  isActive: _parseInt(json['is_active']),
  scope: json['scope'] as String?,
);

Map<String, dynamic> _$RoleItemToJson(RoleItem instance) => <String, dynamic>{
  'role_id': instance.roleId,
  'name': instance.name,
  'is_active': instance.isActive,
  'scope': instance.scope,
};

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };
