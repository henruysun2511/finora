import 'package:formz/formz.dart';

class EmailInput extends FormzInput<String, String> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  static final RegExp _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  String? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email không được để trống';
    if (!_emailRegex.hasMatch(trimmed)) return 'Email không hợp lệ';
    return null;
  }
}
