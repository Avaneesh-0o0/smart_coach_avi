// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_list_response.dart';

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

RegionListResponse _$RegionListResponseFromJson(Map<String, dynamic> json) =>
    RegionListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : RegionListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegionListResponseToJson(RegionListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

RegionListData _$RegionListDataFromJson(Map<String, dynamic> json) =>
    RegionListData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegionListDataToJson(RegionListData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

RegionItem _$RegionItemFromJson(Map<String, dynamic> json) => RegionItem(
  regionId: _parseInt(json['region_id']),
  name: json['name'] as String?,
  divisionId: _parseInt(json['division_id']),
  isActive: _parseInt(json['is_active']),
  createdDate: json['created_date'] as String?,
  updatedDate: json['updated_date'] as String?,
);

Map<String, dynamic> _$RegionItemToJson(RegionItem instance) =>
    <String, dynamic>{
      'region_id': instance.regionId,
      'name': instance.name,
      'division_id': instance.divisionId,
      'is_active': instance.isActive,
      'created_date': instance.createdDate,
      'updated_date': instance.updatedDate,
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
