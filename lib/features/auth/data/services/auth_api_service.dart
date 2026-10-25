import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/models/user.dart';
import '../dto/auth_response.dart';
import '../dto/auth_tokens_response.dart';
import '../dto/login_request.dart';
import '../dto/refresh_token_request.dart';
import '../dto/register_request.dart';

abstract class AuthApiService {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthTokensResponse> refreshToken(RefreshTokenRequest request);
  Future<void> logout([String? refreshToken]);
  Future<User> getCurrentUser();
  Future<AuthResponse> register(RegisterRequest request);
  Future<User> updateProfile({String? fullName, String? phone, String? avatar});
}

class DioAuthApiService implements AuthApiService {
  DioAuthApiService(this._dio);

  final Dio _dio;

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return <String, dynamic>{};
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) => _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          ApiConstants.login,
          data: request.toJson(),
        );
        return AuthResponse.fromJson(_extractData(res.data));
      });

  @override
  Future<AuthTokensResponse> refreshToken(RefreshTokenRequest request) =>
      _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          ApiConstants.refreshToken,
          data: request.toJson(),
        );
        return AuthTokensResponse.fromJson(_extractData(res.data));
      });

  @override
  Future<void> logout([String? refreshToken]) => _guard(() async {
        await _dio.post<dynamic>(
          '/auth/logout',
          data: refreshToken != null ? {'refreshToken': refreshToken} : null,
        );
      });

  @override
  Future<User> getCurrentUser() => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(ApiConstants.profile);
        return User.fromJson(_extractData(res.data));
      });

  @override
  Future<AuthResponse> register(RegisterRequest request) => _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          ApiConstants.register,
          data: request.toJson(),
        );
        return AuthResponse.fromJson(_extractData(res.data));
      });

  @override
  Future<User> updateProfile({String? fullName, String? phone, String? avatar}) =>
      _guard(() async {
        final body = <String, dynamic>{};
        if (fullName != null) body['fullName'] = fullName.trim();
        if (phone != null) body['phone'] = phone.trim();
        if (avatar != null) body['avatar'] = avatar.trim();

        final res = await _dio.patch<Map<String, dynamic>>(
          ApiConstants.updateProfile,
          data: body,
        );
        return User.fromJson(_extractData(res.data));
      });
}
