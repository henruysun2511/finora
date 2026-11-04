/// Chu kỳ ngân sách: Theo Tuần, Theo Tháng, Theo Năm
enum BudgetPeriodType {
  weekly('WEEKLY', 'Theo Tuần'),
  monthly('MONTHLY', 'Theo Tháng'),
  yearly('YEARLY', 'Theo Năm');

  const BudgetPeriodType(this.value, this.label);

  final String value;
  final String label;

  static BudgetPeriodType fromValue(String? value) {
    return BudgetPeriodType.values.firstWhere(
      (e) => e.value.toUpperCase() == (value ?? '').toUpperCase(),
      orElse: () => BudgetPeriodType.monthly,
    );
  }
}

/// Trạng thái tiến độ ngân sách dựa trên tỷ lệ % đã chi:
/// - SAFE (0% - 79.9%): Xanh lá
/// - WARNING (80% - 99.9%): Vàng cam
/// - EXCEEDED (>= 100%): Đỏ báo động
enum BudgetProgressStatus {
  safe('SAFE', 'An toàn', 0.0, 79.99),
  warning('WARNING', 'Sắp chạm trần', 80.0, 99.99),
  exceeded('EXCEEDED', 'Đã vượt hạn mức', 100.0, double.infinity);

  const BudgetProgressStatus(this.code, this.label, this.minPercentage, this.maxPercentage);

  final String code;
  final String label;
  final double minPercentage;
  final double maxPercentage;

  static BudgetProgressStatus fromPercentage(double percentage) {
    if (percentage >= 100.0) return BudgetProgressStatus.exceeded;
    if (percentage >= 80.0) return BudgetProgressStatus.warning;
    return BudgetProgressStatus.safe;
  }

  static BudgetProgressStatus fromCode(String? code) {
    return BudgetProgressStatus.values.firstWhere(
      (e) => e.code.toUpperCase() == (code ?? '').toUpperCase(),
      orElse: () => BudgetProgressStatus.safe,
    );
  }
}

