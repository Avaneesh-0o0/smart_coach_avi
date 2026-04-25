import 'package:dio/dio.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';

Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    final data = e.response?.data;

    if (data is Map && data['errors'] != null) {
      final errors =
          (data['errors'] as List).map((e) => e['msg'].toString()).toList();
      throw MultiFieldsValidationException(errors);
    }

    if (data is Map && data['message'] != null) {
      throw ApiException(data['message']);
    }

    throw ApiException('Something went wrong');
  } catch (e, stack) {
    print('❌ SAFE_REQUEST REAL ERROR: $e');  // ADD THIS
    print('❌ SAFE_REQUEST REAL STACK: $stack');  // ADD THIS
    throw ApiException('Unexpected error');
  }
}
