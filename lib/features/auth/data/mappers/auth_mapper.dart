import '../../domain/models/login_input.dart';
import '../../domain/models/register_input.dart';
import '../dto/login_request.dart';
import '../dto/register_request.dart';

extension RegisterInputMapper on RegisterInput {
  RegisterRequest toRegisterRequest() => RegisterRequest(
        fullName: fullName.trim(),
        username: username.trim(),
        email: email.trim(),
        password: password,
      );
}

extension LoginInputMapper on LoginInput {
  LoginRequest toLoginRequest() => LoginRequest(
        username: username.trim(),
        password: password,
      );
}
