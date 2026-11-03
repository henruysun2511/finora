/// DTO gửi lên Backend để cập nhật ngân sách: PUT /api/v1/budgets/:id
class UpdateBudgetRequest {
  const UpdateBudgetRequest({
    this.limitAmount,
    this.periodType,
    this.isRolloverEnabled,
  });

  final double? limitAmount;
  final String? periodType;
  final bool? isRolloverEnabled;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (limitAmount != null) map['limitAmount'] = limitAmount;
    if (periodType != null) map['periodType'] = periodType;
    if (isRolloverEnabled != null) map['isRolloverEnabled'] = isRolloverEnabled;
    return map;
  }
}

