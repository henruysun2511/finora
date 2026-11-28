import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/core/utils/currency_formatter.dart';
import 'package:finora_mb/features/auth/domain/validators/auth_validators.dart';

void main() {
  group('CurrencyFormatter', () {
    test('định dạng số tiền VND chuẩn phong cách ui-sample-3', () {
      expect(CurrencyFormatter.formatVnd(24850000), '₫ 24.850.000');
    });

    test('định dạng số tiền biến động dương', () {
      expect(CurrencyFormatter.formatDelta(15000000), '+₫ 15.000.000');
    });

    test('định dạng số tiền biến động âm', () {
      expect(CurrencyFormatter.formatDelta(-8320000), '-₫ 8.320.000');
    });
  });

  group('AuthValidators', () {
    test('validateEmail', () {
      expect(AuthValidators.validateEmail(''), isNotNull);
      expect(AuthValidators.validateEmail('invalid-email'), isNotNull);
      expect(AuthValidators.validateEmail('user@finora.vn'), isNull);
    });

    test('validatePassword', () {
      expect(AuthValidators.validatePassword(''), isNotNull);
      expect(AuthValidators.validatePassword('123'), isNotNull);
      expect(AuthValidators.validatePassword('123456'), isNull);
    });

    test('validateUsername', () {
      expect(AuthValidators.validateUsername(''), isNotNull);
      expect(AuthValidators.validateUsername('ab'), isNotNull);
      expect(AuthValidators.validateUsername('admin'), isNull);
    });
  });
}
