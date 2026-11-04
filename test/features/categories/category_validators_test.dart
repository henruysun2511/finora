import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/categories/domain/validators/category_validators.dart';

void main() {
  group('CategoryValidators', () {
    test('validateName trả về lỗi khi để trống hoặc null', () {
      expect(CategoryValidators.validateName(null), isNotNull);
      expect(CategoryValidators.validateName(''), isNotNull);
      expect(CategoryValidators.validateName('   '), isNotNull);
    });

    test('validateName trả về lỗi khi dưới 2 ký tự hoặc quá 50 ký tự', () {
      expect(CategoryValidators.validateName('A'), isNotNull);
      expect(CategoryValidators.validateName('A' * 51), isNotNull);
    });

    test('validateName hợp lệ khi từ 2 đến 50 ký tự', () {
      expect(CategoryValidators.validateName('Ăn uống'), isNull);
      expect(CategoryValidators.validateName('Mua sắm online'), isNull);
    });

    test('validateColor kiểm tra định dạng hex hợp lệ', () {
      expect(CategoryValidators.validateColor(null), isNull);
      expect(CategoryValidators.validateColor('#1E5BD8'), isNull);
      expect(CategoryValidators.validateColor('1E5BD8'), isNull);
      expect(CategoryValidators.validateColor('#FFF'), isNotNull);
      expect(CategoryValidators.validateColor('invalid-color'), isNotNull);
    });
  });
}

