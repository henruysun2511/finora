class AuthTokensResponse {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  const AuthTokensResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponse(
      accessToken: (json['accessToken'] ?? json['access_token']) as String? ?? '',
      refreshToken: (json['refreshToken'] ?? json['refresh_token']) as String? ?? '',
      expiresIn: json['expiresIn']?.toString() ?? '1d',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      };
}
