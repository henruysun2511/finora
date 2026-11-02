/// DTO lịch sử các chu kỳ trước từ bản ghi budget_periods
class BudgetPeriodResponse {
  const BudgetPeriodResponse({
    required this.id,
    required this.budgetId,
    required this.startDate,
    required this.endDate,
    required this.limitAmount,
    required this.spentAmount,
    this.rolloverAmount = 0.0,
    this.isClosed = false,
  });

  final String id;
  final String budgetId;
  final DateTime startDate;
  final DateTime endDate;
  final double limitAmount;
  final double spentAmount;
  final double rolloverAmount;
  final bool isClosed;

  factory BudgetPeriodResponse.fromJson(Map<String, dynamic> json) {
    return BudgetPeriodResponse(
      id: json['id']?.toString() ?? '',
      budgetId: json['budgetId']?.toString() ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      limitAmount: (json['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      rolloverAmount: (json['rolloverAmount'] as num?)?.toDouble() ?? 0.0,
      isClosed: (json['isClosed'] as bool?) ?? false,
    );
  }
}
