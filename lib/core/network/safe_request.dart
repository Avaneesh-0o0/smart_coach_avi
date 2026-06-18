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

    String? errorMsg;
    if (e.error is ApiException) {
      errorMsg = (e.error as ApiException).message;
    }
    if (e.response?.statusCode != null) {
      errorMsg ??= 'Request failed (${e.response!.statusCode})';
    }

    throw ApiException(errorMsg ?? 'Something went wrong');
  } catch (e, stack) {
    throw ApiException(e.toString());
  }
}
