import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/core/utils/currency_formatter.dart';
import 'package:finora_mb/core/validation/inputs/email_input.dart';
import 'package:finora_mb/core/validation/inputs/password_input.dart';

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

  group('Validation Inputs', () {
    test('EmailInput validation', () {
      const empty = EmailInput.dirty('');
      expect(empty.isValid, isFalse);

      const valid = EmailInput.dirty('user@finora.vn');
      expect(valid.isValid, isTrue);
    });

    test('PasswordInput validation', () {
      const short = PasswordInput.dirty('123');
      expect(short.isValid, isFalse);

      const valid = PasswordInput.dirty('123456');
      expect(valid.isValid, isTrue);
    });
  });
}
