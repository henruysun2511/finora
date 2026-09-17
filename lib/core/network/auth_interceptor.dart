import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  static final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();

  static Stream<void> get onUnauthorized => _unauthorizedController.stream;

  final SecureStorage _secureStorage;
  final Dio _dio;
  final Dio _refreshDio;
  Future<String?>? _refreshFuture;

  AuthInterceptor({
    required SecureStorage secureStorage,
    required Dio dio,
  })  : _secureStorage = secureStorage,
        _dio = dio,
        _refreshDio = Dio(dio.options);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path == ApiConstants.refreshToken;

    if (!isUnauthorized || isRefreshCall) {
      handler.next(err);
      return;
    }

    try {
      final newToken = await (_refreshFuture ??= _refreshAccessToken());

      if (newToken == null) {
        await _secureStorage.clearTokens();
        _unauthorizedController.add(null);
        handler.next(err);
        return;
      }

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _secureStorage.clearTokens();
      _unauthorizedController.add(null);
      handler.next(err);
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await _refreshDio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final newAccessToken = response.data['access_token'] as String?;
    final newRefreshToken = response.data['refresh_token'] as String?;

    if (newAccessToken == null) return null;

    await _secureStorage.saveAccessToken(newAccessToken);
    if (newRefreshToken != null) {
      await _secureStorage.saveRefreshToken(newRefreshToken);
    }
    return newAccessToken;
  }
}
