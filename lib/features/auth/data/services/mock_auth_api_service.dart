import '../../domain/models/user.dart';
import '../dto/auth_response.dart';
import '../dto/auth_tokens_response.dart';
import '../dto/login_request.dart';
import '../dto/refresh_token_request.dart';
import '../dto/register_request.dart';
import 'auth_api_service.dart';

class MockAuthApiService implements AuthApiService {
  User _mockUser = const User(
    id: 'mock-user-1',
    email: 'user@finora.vn',
    name: 'Nguyễn Văn A',
  );

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _mockUser = User(
      id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      email: request.email,
      name: request.fullName,
    );
    return AuthResponse(
      user: _mockUser,
      tokens: const AuthTokensResponse(
        accessToken: 'mock_access_token_register',
        refreshToken: 'mock_refresh_token_register',
        expiresIn: '7d',
      ),
    );
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return AuthResponse(
      user: _mockUser,
      tokens: const AuthTokensResponse(
        accessToken: 'mock_access_token_login',
        refreshToken: 'mock_refresh_token_login',
        expiresIn: '7d',
      ),
    );
  }

  @override
  Future<AuthResponse> loginWithGoogle(String idToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _mockUser = const User(
      id: 'mock-google-user-1',
      email: 'google.user@finora.vn',
      name: 'Google User Demo',
    );
    return AuthResponse(
      user: _mockUser,
      tokens: const AuthTokensResponse(
        accessToken: 'mock_google_access_token',
        refreshToken: 'mock_google_refresh_token',
        expiresIn: '7d',
      ),
    );
  }

  @override
  Future<AuthTokensResponse> refreshToken(RefreshTokenRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const AuthTokensResponse(
      accessToken: 'mock_refreshed_access_token',
      refreshToken: 'mock_refreshed_refresh_token',
      expiresIn: '7d',
    );
  }

  @override
  Future<void> logout([String? refreshToken]) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<User> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockUser;
  }

  @override
  Future<User> updateProfile({
    String? fullName,
    String? phone,
    String? avatar,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _mockUser = _mockUser.copyWith(name: fullName ?? _mockUser.name);
    return _mockUser;
  }
}
