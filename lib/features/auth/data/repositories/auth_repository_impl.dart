import 'dart:convert';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/models/auth_tokens.dart';
import '../../domain/models/login_input.dart';
import '../../domain/models/register_input.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/refresh_token_request.dart';
import '../mappers/auth_mapper.dart';
import '../services/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _api;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  const AuthRepositoryImpl({
    required AuthApiService api,
    required SecureStorage secureStorage,
    required LocalStorage localStorage,
  })  : _api = api,
        _secureStorage = secureStorage,
        _localStorage = localStorage;

  Future<void> _persistTokens(String accessToken, String refreshToken) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  @override
  Future<User> login(LoginInput input) async {
    final res = await _api.login(input.toLoginRequest());
    await _persistTokens(res.tokens.accessToken, res.tokens.refreshToken);
    await _localStorage.saveCachedUser(jsonEncode(res.user.toJson()));
    return res.user;
  }

  @override
  Future<User> register(RegisterInput input) async {
    final res = await _api.register(input.toRegisterRequest());
    await _persistTokens(res.tokens.accessToken, res.tokens.refreshToken);
    await _localStorage.saveCachedUser(jsonEncode(res.user.toJson()));
    return res.user;
  }

  @override
  Future<void> clearLocalSession() async {
    await _secureStorage.clearTokens();
    await _localStorage.clearCachedUser();
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final refresh = await _secureStorage.getRefreshToken();
        await _api.logout(refresh);
      }
    } catch (_) {
      // Bỏ qua lỗi mạng khi logout để luôn xóa sạch phiên trên thiết bị
    } finally {
      await clearLocalSession();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await _api.getCurrentUser();
      await _localStorage.saveCachedUser(jsonEncode(user.toJson()));
      return user;
    } on AppException catch (e) {
      if (e.statusCode == 401) {
        await _secureStorage.clearTokens();
        await _localStorage.clearCachedUser();
        return null;
      }
      final cachedJson = _localStorage.getCachedUser();
      if (cachedJson != null) {
        try {
          return User.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
        } catch (_) {}
      }
      rethrow;
    } catch (_) {
      final cachedJson = _localStorage.getCachedUser();
      if (cachedJson != null) {
        try {
          return User.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
        } catch (_) {}
      }
      return null;
    }
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final res = await _api.refreshToken(
      RefreshTokenRequest(refreshToken: refreshToken),
    );
    await _persistTokens(res.accessToken, res.refreshToken);
    return AuthTokens(
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
      expiresIn: res.expiresIn,
    );
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final updated = await _api.updateProfile(
      fullName: name,
      phone: phone,
      avatar: avatarUrl,
    );
    await _localStorage.saveCachedUser(jsonEncode(updated.toJson()));
    return updated;
  }
}
