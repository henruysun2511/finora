import 'budget_enums.dart';

/// Dữ liệu đầu vào khi Tạo mới / Cập nhật một Ngân sách.
/// Không chứa `id`, `spentAmount` hoặc các trường do Backend tự tính toán.
class BudgetInput {
  const BudgetInput({
    required this.walletId,
    required this.categoryId,
    required this.limitAmount,
    this.periodType = BudgetPeriodType.monthly,
    required this.startDate,
    this.isRolloverEnabled = true,
  });

  final String walletId;
  final String categoryId;
  final double limitAmount;
  final BudgetPeriodType periodType;
  final DateTime startDate;
  final bool isRolloverEnabled;
}

