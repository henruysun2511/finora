import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/auth/domain/validators/auth_validators.dart';

void main() {
  group('AuthValidators - validateUsername', () {
    test('trả về lỗi khi để trống', () {
      expect(
        AuthValidators.validateUsername(''),
        'Vui lòng nhập tên đăng nhập hoặc email',
      );
      expect(
        AuthValidators.validateUsername('   '),
        'Vui lòng nhập tên đăng nhập hoặc email',
      );
      expect(
        AuthValidators.validateUsername(null),
        'Vui lòng nhập tên đăng nhập hoặc email',
      );
    });

    test('trả về lỗi khi dưới 3 ký tự', () {
      expect(
        AuthValidators.validateUsername('ab'),
        'Tên đăng nhập tối thiểu 3 ký tự',
      );
    });

    test('trả về lỗi khi quá 100 ký tự', () {
      final longStr = 'a' * 101;
      expect(
        AuthValidators.validateUsername(longStr),
        'Tối đa 100 ký tự',
      );
    });

    test('hợp lệ với username hoặc email chuẩn', () {
      expect(AuthValidators.validateUsername('nguyenvana'), isNull);
      expect(AuthValidators.validateUsername('user@finora.vn'), isNull);
      expect(AuthValidators.validateUsername('finora_pro_01'), isNull);
    });
  });

  group('AuthValidators - validatePassword', () {
    test('trả về lỗi khi để trống', () {
      expect(
        AuthValidators.validatePassword(''),
        'Vui lòng nhập mật khẩu',
      );
      expect(
        AuthValidators.validatePassword(null),
        'Vui lòng nhập mật khẩu',
      );
    });

    test('trả về lỗi khi dưới 6 ký tự', () {
      expect(
        AuthValidators.validatePassword('12345'),
        'Mật khẩu tối thiểu 6 ký tự',
      );
    });

    test('trả về lỗi khi vượt quá 50 ký tự', () {
      final longPass = 'p' * 51;
      expect(
        AuthValidators.validatePassword(longPass),
        'Mật khẩu tối đa 50 ký tự',
      );
    });

    test('hợp lệ khi đủ điều kiện', () {
      expect(AuthValidators.validatePassword('123456'), isNull);
      expect(AuthValidators.validatePassword('MatKhau@123'), isNull);
    });
  });
}
