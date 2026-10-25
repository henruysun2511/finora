import '../../domain/models/user.dart';
import 'auth_tokens_response.dart';

class AuthResponse {
  final AuthTokensResponse tokens;
  final User user;

  const AuthResponse({
    required this.tokens,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final tokens = AuthTokensResponse.fromJson(json);
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;
    return AuthResponse(
      tokens: tokens,
      user: User.fromJson(userMap),
    );
  }
}
