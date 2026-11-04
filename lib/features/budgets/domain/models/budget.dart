import 'budget_enums.dart';
import 'budget_period.dart';

/// Entity thuần Domain cho Ngân sách (Budget).
/// Tuân thủ Clean Architecture, không phụ thuộc vào Flutter UI hay Network library.
class Budget {
  const Budget({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.limitAmount,
    this.spentAmount = 0.0,
    this.rolloverAmount = 0.0,
    this.periodType = BudgetPeriodType.monthly,
    required this.startDate,
    this.endDate,
    this.isRolloverEnabled = true,
    this.historyPeriods = const [],
    this.walletName,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String walletId;
  final String categoryId;
  final double limitAmount;
  final double spentAmount;
  final double rolloverAmount;
  final BudgetPeriodType periodType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRolloverEnabled;
  final List<BudgetPeriod> historyPeriods;

  // Thuộc tính tiện ích phục vụ hiển thị
  final String? walletName;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Hạn mức khả dụng thực tế: Gốc + Cộng dồn từ kỳ trước
  double get effectiveLimit => limitAmount + rolloverAmount;

  /// Số tiền còn được phép chi: effectiveLimit - spentAmount
  double get remainingAmount => effectiveLimit - spentAmount;

  /// Tỷ lệ phần trăm đã tiêu (%)
  double get percentage => effectiveLimit > 0 ? (spentAmount / effectiveLimit) * 100 : 0.0;

  /// Trạng thái tiến độ: SAFE, WARNING, EXCEEDED
  BudgetProgressStatus get status => BudgetProgressStatus.fromPercentage(percentage);

  /// Số ngày còn lại của kỳ hiện tại
  int get daysRemaining {
    final targetEnd = endDate ?? DateTime(startDate.year, startDate.month + 1, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDay = DateTime(targetEnd.year, targetEnd.month, targetEnd.day);
    final diff = endDay.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Trợ lý thông minh: Gợi ý số tiền tối đa nên tiêu mỗi ngày trong những ngày còn lại
  double get dailyBudgetRemaining {
    if (remainingAmount <= 0) return 0.0;
    final days = daysRemaining;
    if (days <= 0) return remainingAmount;
    return remainingAmount / days;
  }

  Budget copyWith({
    String? id,
    String? walletId,
    String? categoryId,
    double? limitAmount,
    double? spentAmount,
    double? rolloverAmount,
    BudgetPeriodType? periodType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRolloverEnabled,
    List<BudgetPeriod>? historyPeriods,
    String? walletName,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRolloverEnabled: isRolloverEnabled ?? this.isRolloverEnabled,
      historyPeriods: historyPeriods ?? this.historyPeriods,
      walletName: walletName ?? this.walletName,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
