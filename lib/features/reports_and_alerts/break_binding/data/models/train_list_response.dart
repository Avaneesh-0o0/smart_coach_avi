import 'package:json_annotation/json_annotation.dart';
part 'train_list_response.g.dart';
@JsonSerializable()
class TrainListResponseForBreakBinding {
  final bool success;
  final String message;
  final List<TrainItemForBreakBinding>? data;
  TrainListResponseForBreakBinding({required this.success, required this.message, this.data});
  factory TrainListResponseForBreakBinding.fromJson(Map<String, dynamic> json) => _$TrainListResponseForBreakBindingFromJson(json);
  Map<String, dynamic> toJson() => _$TrainListResponseForBreakBindingToJson(this);
}
@JsonSerializable()
class TrainItemForBreakBinding {
  @JsonKey(name: 'train_id') final int? trainId;
  @JsonKey(name: 'train_number') final int? trainNumber;
  @JsonKey(name: 'train_name') final String? trainName;
  TrainItemForBreakBinding({this.trainId, this.trainNumber, this.trainName});
  factory TrainItemForBreakBinding.fromJson(Map<String, dynamic> json) => _$TrainItemForBreakBindingFromJson(json);
  Map<String, dynamic> toJson() => _$TrainItemForBreakBindingToJson(this);
}
