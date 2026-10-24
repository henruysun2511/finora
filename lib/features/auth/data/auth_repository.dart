import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import 'models/auth_requests.dart';
import 'models/user.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  const AuthRepository({
    required Dio dio,
    required SecureStorage secureStorage,
    required LocalStorage localStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _localStorage = localStorage;

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return <String, dynamic>{};
  }

  Future<void> _persistTokens(String accessToken, String refreshToken) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      final payload = _extractData(response.data);
      final user = User.fromJson(payload['user'] as Map<String, dynamic>);
      final accessToken = (payload['accessToken'] ?? payload['access_token']) as String;
      final refreshToken = (payload['refreshToken'] ?? payload['refresh_token']) as String;

      await _persistTokens(accessToken, refreshToken);
      await _localStorage.saveCachedUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: RegisterRequest(name: name, email: email, password: password).toJson(),
      );
      final payload = _extractData(response.data);
      final user = User.fromJson(payload['user'] as Map<String, dynamic>);
      final accessToken = (payload['accessToken'] ?? payload['access_token']) as String;
      final refreshToken = (payload['refreshToken'] ?? payload['refresh_token']) as String;

      await _persistTokens(accessToken, refreshToken);
      await _localStorage.saveCachedUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearTokens();
    await _localStorage.clearCachedUser();
  }

  Future<User?> getCurrentUser() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _dio.get(ApiConstants.profile);
      final payload = _extractData(response.data);
      final user = User.fromJson(payload);
      await _localStorage.saveCachedUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      final appEx = mapDioExceptionToAppException(e);
      if (appEx.statusCode == 401) {
        await _secureStorage.clearTokens();
        await _localStorage.clearCachedUser();
        return null;
      }
      final cachedJson = _localStorage.getCachedUser();
      if (cachedJson != null) {
        try {
          return User.fromJson(
            jsonDecode(cachedJson) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
      throw appEx;
    } catch (_) {
      final cachedJson = _localStorage.getCachedUser();
      if (cachedJson != null) {
        try {
          return User.fromJson(
            jsonDecode(cachedJson) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
      rethrow;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    secureStorage: ref.watch(secureStorageProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});
