import 'package:json_annotation/json_annotation.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_list_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart';

part 'master_module_list_response.g.dart';

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable(explicitToJson: true)
class MasterModuleListResponse {
  final bool success;
  final String message;
  final List<MasterModuleItem>? data;

  MasterModuleListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MasterModuleListResponse.fromJson(Map<String, dynamic> json) =>
      _$MasterModuleListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MasterModuleListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MasterModuleItem {
  @JsonKey(name: 'module_id', fromJson: _parseInt)
  final int? moduleId;

  @JsonKey(name: 'module_unique_id')
  final String? moduleUniqueId;

  @JsonKey(name: 'make_model')
  final String? makeModel;

  @JsonKey(name: 'firmware_version')
  final String? firmwareVersion;

  @JsonKey(name: 'seriel_number')
  final String? serialNumber;

  @JsonKey(name: 'installation_date')
  final String? installationDate;

  final String? location;

  @JsonKey(name: 'placement_type')
  final String? placementType;

  @JsonKey(name: 'specify_placement_location')
  final String? specifyPlacementLocation;

  @JsonKey(name: 'sim_no')
  final String? simNo;

  @JsonKey(name: 'service_provider_primary')
  final String? serviceProviderPrimary;

  @JsonKey(name: 'service_provider_secondary')
  final String? serviceProviderSecondary;

  @JsonKey(name: 'activation_date')
  final String? activationDate;

  @JsonKey(name: 'recharge_date')
  final String? rechargeDate;

  @JsonKey(name: 'battery_recharge_date')
  final String? batteryRechargeDate;

  @JsonKey(name: 'sim_status')
  final String? simStatus;

  @JsonKey(name: 'battery_replacement_date')
  final String? batteryReplacementDate;

  @JsonKey(name: 'dual_profile_supported', fromJson: _parseBool)
  final bool? dualProfileSupported;

  @JsonKey(name: 'lora_enabled', fromJson: _parseBool)
  final bool? loraEnabled;

  @JsonKey(name: 'power_supply_available')
  final String? powerSupplyAvailable;

  @JsonKey(name: 'esim_enabled', fromJson: _parseBool)
  final bool? esimEnabled;

  @JsonKey(name: 'battery_capacity', fromJson: _parseInt)
  final int? batteryCapacity;

  @JsonKey(name: 'battery_type')
  final String? batteryType;

  @JsonKey(name: 'created_by', fromJson: _parseInt)
  final int? createdBy;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  @JsonKey(name: 'updated_by', fromJson: _parseInt)
  final int? updatedBy;

  @JsonKey(name: 'updated_date')
  final String? updatedDate;

  final CoachItem? coach;
  final TrainItem? train;

  @JsonKey(name: 'module_created_by_name')
  final String? createdByName;

  @JsonKey(name: 'module_updated_by_name')
  final String? updatedByName;

  final List<DeviceItem>? devices;

  MasterModuleItem({
    this.moduleId,
    this.moduleUniqueId,
    this.makeModel,
    this.firmwareVersion,
    this.serialNumber,
    this.installationDate,
    this.location,
    this.placementType,
    this.specifyPlacementLocation,
    this.simNo,
    this.serviceProviderPrimary,
    this.serviceProviderSecondary,
    this.activationDate,
    this.rechargeDate,
    this.batteryRechargeDate,
    this.simStatus,
    this.batteryReplacementDate,
    this.dualProfileSupported,
    this.loraEnabled,
    this.powerSupplyAvailable,
    this.esimEnabled,
    this.batteryCapacity,
    this.batteryType,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.coach,
    this.train,
    this.createdByName,
    this.updatedByName,
    this.devices,
  });

  factory MasterModuleItem.fromJson(Map<String, dynamic> json) =>
      _$MasterModuleItemFromJson(json);

  Map<String, dynamic> toJson() => _$MasterModuleItemToJson(this);
}