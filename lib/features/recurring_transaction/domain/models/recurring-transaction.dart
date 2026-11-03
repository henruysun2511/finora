import 'recurring-enum.dart';

/// Domain Entity cho một quy tắc giao dịch định kỳ
/// Khớp với RecurringTransactionResponseDto của backend
class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.currency,
    required this.isPaused,
    required this.nextRunDate,
    required this.createdAt,
    this.accountName,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.endDate,
    // Detail fields (chỉ có khi gọi GET /:id)
    this.totalExecutedTimes,
    this.totalAmountSpent,
    this.executionHistory,
  });

  final String id;
  final String name;
  final double amount;
  final TransactionType type;
  final RecurringFrequency frequency;
  final String currency;
  final bool isPaused;
  final DateTime nextRunDate;
  final DateTime createdAt;
  final String? accountName;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final DateTime? endDate;

  // Fields từ RecurringTransactionDetailResponseDto
  final int? totalExecutedTimes;
  final double? totalAmountSpent;
  final List<RecurringExecutionHistory>? executionHistory;

  RecurringTransaction copyWith({
    String? id,
    String? name,
    double? amount,
    TransactionType? type,
    RecurringFrequency? frequency,
    String? currency,
    bool? isPaused,
    DateTime? nextRunDate,
    DateTime? createdAt,
    String? accountName,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    DateTime? endDate,
    int? totalExecutedTimes,
    double? totalAmountSpent,
    List<RecurringExecutionHistory>? executionHistory,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      currency: currency ?? this.currency,
      isPaused: isPaused ?? this.isPaused,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      createdAt: createdAt ?? this.createdAt,
      accountName: accountName ?? this.accountName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      endDate: endDate ?? this.endDate,
      totalExecutedTimes: totalExecutedTimes ?? this.totalExecutedTimes,
      totalAmountSpent: totalAmountSpent ?? this.totalAmountSpent,
      executionHistory: executionHistory ?? this.executionHistory,
    );
  }
}

/// Lịch sử thực thi - khớp với ExecutionHistoryItemDto
class RecurringExecutionHistory {
  const RecurringExecutionHistory({
    required this.transactionId,
    required this.amount,
    required this.date,
  });

  final String transactionId;
  final double amount;
  final DateTime date;
}