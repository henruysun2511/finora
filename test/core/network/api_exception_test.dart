import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/core/network/api_exception.dart';

void main() {
  group('mapDioExceptionToAppException', () {
    test('ưu tiên lấy lỗi đầu tiên trong mảng errors nếu có', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 400,
          data: {
            'path': '/api/v1/auth/login',
            'success': false,
            'statusCode': 400,
            'code': 'VALIDATION_ERROR',
            'message': 'Dữ liệu không hợp lệ',
            'errors': [
              'Tên đăng nhập không được để trống',
              'Tên đăng nhập phải là chuỗi',
            ],
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final appException = mapDioExceptionToAppException(dioException);
      expect(appException.message, 'Tên đăng nhập không được để trống');
      expect(appException.statusCode, 400);
    });

    test('fallback sang message nếu mảng errors rỗng hoặc null', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {
            'path': '/api/v1/auth/login',
            'success': false,
            'statusCode': 401,
            'message': 'Tên đăng nhập hoặc mật khẩu không chính xác',
            'errors': null,
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final appException = mapDioExceptionToAppException(dioException);
      expect(appException.message, 'Tên đăng nhập hoặc mật khẩu không chính xác');
      expect(appException.statusCode, 401);
    });
  });
}
