class RegisterRequest {
  final String fullName;
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'username': username,
        'email': email,
        'password': password,
      };
}
