import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_exception.dart';

abstract class SettingsApiService {
  Future<Map<String, dynamic>> getSettings();
  Future<void> updateGeneralSettings({String? defaultCurrency});
}

class DioSettingsApiService implements SettingsApiService {
  DioSettingsApiService(this._dio);

  final Dio _dio;

  Map<String, dynamic> _extractData(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    return {};
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getSettings() => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/settings');
        return _extractData(res.data);
      });

  @override
  Future<void> updateGeneralSettings({String? defaultCurrency}) =>
      _guard(() async {
        await _dio.patch<dynamic>(
          ApiConstants.updateGeneralSettings,
          data: {
            if (defaultCurrency != null) 'defaultCurrency': defaultCurrency,
          },
        );
      });
}

