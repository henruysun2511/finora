/// DTO gửi lên Backend để tạo ngân sách mới: POST /api/v1/budgets
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
        'periodType': periodType,
        'startDate': startDate.toIso8601String().split('T').first,
        'isRolloverEnabled': isRolloverEnabled,
      };
}
