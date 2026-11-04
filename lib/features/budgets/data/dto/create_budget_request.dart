/// DTO gửi lên Backend để tạo ngân sách mới: POST /api/v1/budgets
/// Tương thích 100% với CreateBudgetDto của NestJS backend.
class CreateBudgetRequest {
  const CreateBudgetRequest({
    required this.walletId,
    required this.categoryId,
    required this.limitAmount,
    required this.periodType,
    required this.startDate,
    this.isRolloverEnabled = true,
  });

  final String walletId;
  final String categoryId;
  final double limitAmount;
  final String periodType;
  final DateTime startDate;
  final bool isRolloverEnabled;

  Map<String, dynamic> toJson() => {
        'walletId': walletId,
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        // Backend NestJS nhận field 'period' (enum: 'weekly', 'monthly', 'yearly')
        'period': periodType.toLowerCase(),
        'periodType': periodType.toLowerCase(),
        'startDate': startDate.toIso8601String().split('T').first,
        // Backend NestJS nhận field 'isRollover'
        'isRollover': isRolloverEnabled,
        'isRolloverEnabled': isRolloverEnabled,
      };
}
