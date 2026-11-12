import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_exception.dart';

abstract class SettingsApiService {
  Future<Map<String, dynamic>> getSettings();
  Future<void> updateGeneralSettings({
    String? defaultCurrency,
    String? language,
    String? defaultTransactionVisibility,
    bool? defaultAmountHidden,
  });
  Future<Map<String, dynamic>> updateNotificationPreferences(Map<String, dynamic> preferences);
  Future<Map<String, dynamic>> updateAiSettings({
    String? provider,
    String? model,
    String? apiKey,
  });
  Future<Map<String, dynamic>> deleteCustomApiKey();
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
  Future<void> updateGeneralSettings({
    String? defaultCurrency,
    String? language,
    String? defaultTransactionVisibility,
    bool? defaultAmountHidden,
  }) =>
      _guard(() async {
        await _dio.patch<dynamic>(
          ApiConstants.updateGeneralSettings,
          data: {
            if (defaultCurrency != null) 'defaultCurrency': defaultCurrency.toUpperCase(),
            if (language != null) 'language': language.toLowerCase(),
            if (defaultTransactionVisibility != null)
              'defaultTransactionVisibility': defaultTransactionVisibility.toUpperCase(),
            if (defaultAmountHidden != null)
              'defaultAmountHidden': defaultAmountHidden,
          },
        );
      });

  @override
  Future<Map<String, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> preferences,
  ) =>
      _guard(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          ApiConstants.updateNotificationSettings,
          data: preferences,
        );
        return _extractData(res.data);
      });

  @override
  Future<Map<String, dynamic>> updateAiSettings({
    String? provider,
    String? model,
    String? apiKey,
  }) =>
      _guard(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          ApiConstants.updateAiSettings,
          data: {
            if (provider != null) 'provider': provider,
            if (model != null) 'model': model,
            if (apiKey != null) 'apiKey': apiKey,
          },
        );
        return _extractData(res.data);
      });

  @override
  Future<Map<String, dynamic>> deleteCustomApiKey() => _guard(() async {
        final res = await _dio.delete<Map<String, dynamic>>(
          ApiConstants.deleteAiApiKey,
        );
        return _extractData(res.data);
      });
}

