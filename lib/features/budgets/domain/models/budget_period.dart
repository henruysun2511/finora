/// Bản ghi lịch sử một chu kỳ của ngân sách (phục vụ mục Lịch sử các chu kỳ trước & Rollover)
class BudgetPeriod {
  const BudgetPeriod({
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

  /// Hạn mức thực tế áp dụng cho kỳ này: Gốc + Thừa/Thiếu từ kỳ trước
  double get effectiveLimit => limitAmount + rolloverAmount;

  /// Số tiền chênh lệch (dương = tiết kiệm được, âm = bị bội chi)
  double get varianceAmount => effectiveLimit - spentAmount;

  /// Tỷ lệ phần trăm đã tiêu (%)
  double get percentage => effectiveLimit > 0 ? (spentAmount / effectiveLimit) * 100 : 0.0;

  BudgetPeriod copyWith({
    String? id,
    String? budgetId,
    DateTime? startDate,
    DateTime? endDate,
    double? limitAmount,
    double? spentAmount,
    double? rolloverAmount,
    bool? isClosed,
  }) {
    return BudgetPeriod(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

