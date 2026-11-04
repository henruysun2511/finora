/// DTO biểu diễn dữ liệu chu kỳ ngân sách từ backend
class BudgetPeriodResponse {
  const BudgetPeriodResponse({
    required this.id,
    this.budgetId = '',
    required this.startDate,
    required this.endDate,
    required this.limitAmount,
    required this.spentAmount,
    this.rolloverAmount = 0.0,
    this.effectiveLimit,
    this.remainingAmount,
    this.percentage,
    this.isClosed = false,
  });

  final String id;
  final String budgetId;
  final DateTime startDate;
  final DateTime endDate;
  final double limitAmount;
  final double spentAmount;
  final double rolloverAmount;
  final double? effectiveLimit;
  final double? remainingAmount;
  final double? percentage;
  final bool isClosed;

  factory BudgetPeriodResponse.fromJson(Map<String, dynamic> json) {
    final limit = (json['limitAmount'] as num?)?.toDouble() ?? 0.0;
    final spent = (json['spentAmount'] as num?)?.toDouble() ?? 0.0;
    final rollover = (json['rolloverAmount'] as num?)?.toDouble() ?? 0.0;
    final effLimit = (json['effectiveLimit'] as num?)?.toDouble() ?? (limit + rollover);
    final remaining = (json['remainingAmount'] as num?)?.toDouble() ?? (effLimit - spent);
    final pct = (json['percentage'] as num?)?.toDouble() ??
        (effLimit > 0 ? (spent / effLimit) * 100 : 0.0);

    return BudgetPeriodResponse(
      id: json['id']?.toString() ?? '',
      budgetId: json['budgetId']?.toString() ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      limitAmount: limit,
      spentAmount: spent,
      rolloverAmount: rollover,
      effectiveLimit: effLimit,
      remainingAmount: remaining,
      percentage: pct,
      isClosed: (json['isClosed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'budgetId': budgetId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'limitAmount': limitAmount,
        'spentAmount': spentAmount,
        'rolloverAmount': rolloverAmount,
        'effectiveLimit': effectiveLimit,
        'remainingAmount': remainingAmount,
        'percentage': percentage,
        'isClosed': isClosed,
      };
}
