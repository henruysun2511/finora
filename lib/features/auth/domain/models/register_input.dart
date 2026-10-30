class RegisterInput {
  const RegisterInput({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String username;
  final String email;
  final String password;

  RegisterInput copyWith({
    String? fullName,
    String? username,
    String? email,
    String? password,
  }) {
    return RegisterInput(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
