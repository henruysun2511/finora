import 'package:formz/formz.dart';

class PasswordInput extends FormzInput<String, String> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  static const int _minLength = 6;

  @override
  String? validator(String value) {
    if (value.trim().isEmpty) return 'Mật khẩu không được để trống';
    if (value.length < _minLength) {
      return 'Mật khẩu phải có ít nhất $_minLength ký tự';
    }
    return null;
  }
}
