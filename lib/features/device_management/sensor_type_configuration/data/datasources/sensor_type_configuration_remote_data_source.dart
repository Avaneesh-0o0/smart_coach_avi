import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_category_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/si_unit_list_response.dart';
@injectable
class SensorTypeConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  SensorTypeConfigurationRemoteDataSourceImpl(this.restClient);
  Future<List<SensorItem>> fetchSensor() async {
    return safeRequest(() async {
      final response = await restClient.getSensorList();
      if (!response.success || response.data == null) throw Exception(response.message);
      return response.data!;
    });
  }
  Future<List<SensorCategoryItem>> getCategories() async {
    return safeRequest(() async {
      final response = await restClient.getCategories();
      if (!response.success || response.data == null) throw Exception(response.message);
      return response.data!;
    });
  }
  Future<List<SiUnitItem>> getSiUnits(int? categoryId) async {
    return safeRequest(() async {
      final response = await restClient.getSiUnits(categoryId);
      if (!response.success || response.data == null) throw Exception(response.message);
      return response.data!;
    });
  }
}
