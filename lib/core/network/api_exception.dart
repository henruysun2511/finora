import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

AppException mapDioExceptionToAppException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return AppException.timeout();

    case DioExceptionType.connectionError:
      return AppException.network();

    case DioExceptionType.badCertificate:
      return AppException.unknown('Chứng chỉ bảo mật không hợp lệ.');

    case DioExceptionType.cancel:
      return AppException.unknown('Yêu cầu đã bị hủy.');

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      String? msg;
      if (data is Map<String, dynamic>) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          msg = errors.first?.toString();
        } else if (errors is Map && errors.isNotEmpty) {
          msg = errors.values.first?.toString();
        } else if (errors is String && errors.isNotEmpty) {
          msg = errors;
        } else if (data['message'] != null) {
          msg = data['message'].toString();
        }
      } else if (data is String && data.isNotEmpty) {
        msg = data;
      }
      if (statusCode == 401) {
        return AppException(
          msg ?? 'Phiên đăng nhập đã hết hạn.',
          statusCode: 401,
        );
      }
      return AppException(msg ?? 'Yêu cầu không hợp lệ.', statusCode: statusCode);

    case DioExceptionType.unknown:
      return AppException.unknown(error.message);
  }
}
