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
        msg = data['message']?.toString();
      }
      if (statusCode == 401) return AppException.unauthorized();
      return AppException(msg ?? 'Yêu cầu không hợp lệ.', statusCode: statusCode);

    case DioExceptionType.unknown:
      return AppException.unknown(error.message);
  }
}
