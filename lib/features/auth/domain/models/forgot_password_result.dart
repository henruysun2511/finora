class ForgotPasswordResult {
  final String email;
  final int expiresIn;

  const ForgotPasswordResult({
    required this.email,
    required this.expiresIn,
  });

  factory ForgotPasswordResult.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResult(
      email: json['email']?.toString() ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 30,
    );
  }
}
