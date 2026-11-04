import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/budgets/domain/validators/budget_validators.dart';

void main() {
  group('BudgetValidators - validateLimitAmount', () {
    test('trả về lỗi khi để trống hoặc null', () {
      expect(BudgetValidators.validateLimitAmount(null), 'Vui lòng nhập hạn mức chi tiêu');
      expect(BudgetValidators.validateLimitAmount(''), 'Vui lòng nhập hạn mức chi tiêu');
      expect(BudgetValidators.validateLimitAmount('   '), 'Vui lòng nhập hạn mức chi tiêu');
    });

    test('trả về lỗi khi số tiền <= 0', () {
      expect(BudgetValidators.validateLimitAmount('0'), 'Hạn mức phải lớn hơn 0 ₫');
      expect(BudgetValidators.validateLimitAmount('-50000'), 'Hạn mức phải lớn hơn 0 ₫');
    });

    test('trả về lỗi khi định dạng không hợp lệ', () {
      expect(BudgetValidators.validateLimitAmount('abc'), 'Hạn mức không hợp lệ');
    });

    test('trả về lỗi khi số tiền vượt trần 10 tỷ', () {
      expect(BudgetValidators.validateLimitAmount('10000000001'), 'Hạn mức tối đa 10 tỷ ₫');
    });

    test('hợp lệ khi nhập số tiền dương có định dạng ngăn cách', () {
      expect(BudgetValidators.validateLimitAmount('5.000.000'), isNull);
      expect(BudgetValidators.validateLimitAmount('5000000'), isNull);
      expect(BudgetValidators.validateLimitAmount('5,000,000 VND'), isNull);
    });
  });

  group('BudgetValidators - validateWalletId', () {
    test('trả về lỗi khi chưa chọn ví', () {
      expect(BudgetValidators.validateWalletId(null), 'Vui lòng chọn ví chi tiêu áp dụng');
      expect(BudgetValidators.validateWalletId(''), 'Vui lòng chọn ví chi tiêu áp dụng');
    });

    test('hợp lệ khi đã có walletId', () {
      expect(BudgetValidators.validateWalletId('wallet-123'), isNull);
    });
  });

  group('BudgetValidators - validateCategoryId', () {
    test('trả về lỗi khi chưa chọn danh mục', () {
      expect(BudgetValidators.validateCategoryId(null), 'Vui lòng chọn danh mục chi tiêu');
      expect(BudgetValidators.validateCategoryId(''), 'Vui lòng chọn danh mục chi tiêu');
    });

    test('hợp lệ khi đã có categoryId', () {
      expect(BudgetValidators.validateCategoryId('cat-456'), isNull);
    });
  });

  group('BudgetValidators - validateStartDate', () {
    test('trả về lỗi khi chưa chọn ngày bắt đầu', () {
      expect(BudgetValidators.validateStartDate(null), 'Vui lòng chọn ngày bắt đầu áp dụng');
    });

    test('hợp lệ khi đã có ngày', () {
      expect(BudgetValidators.validateStartDate(DateTime(2026, 10, 1)), isNull);
    });
  });
}

