class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
}
