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
    final path = options.path;
    final isPublicEndpoint = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');

    if (!isPublicEndpoint) {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final isAuthEndpoint = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout') ||
        path.contains('/auth/google');

    if (!isUnauthorized || isAuthEndpoint) {
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
      data: {'refreshToken': refreshToken},
    );

    final rawData = response.data;
    final Map<String, dynamic> responseData;
    if (rawData is Map<String, dynamic>) {
      responseData = rawData['data'] is Map<String, dynamic>
          ? rawData['data'] as Map<String, dynamic>
          : rawData;
    } else {
      responseData = <String, dynamic>{};
    }

    final newAccessToken = (responseData['accessToken'] ?? responseData['access_token']) as String?;
    final newRefreshToken = (responseData['refreshToken'] ?? responseData['refresh_token']) as String?;

    if (newAccessToken == null) return null;

    await _secureStorage.saveAccessToken(newAccessToken);
    if (newRefreshToken != null) {
      await _secureStorage.saveRefreshToken(newRefreshToken);
    }
    return newAccessToken;
  }
}
