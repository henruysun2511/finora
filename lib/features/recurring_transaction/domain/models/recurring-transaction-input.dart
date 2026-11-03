import 'recurring-enum.dart';

/// Input model khi tạo quy tắc định kỳ mới
/// Khớp với CreateRecurringTransactionDto của backend
class RecurringTransactionInput {
  const RecurringTransactionInput({
    required this.walletId,
    required this.accountId,
    required this.categoryId,
    required this.name,
    required this.type,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.currency = 'VND',
    this.endDate,
    this.executeImmediately = false,
  });

  final String walletId;
  final String accountId;
  final String categoryId;
  final String name;
  final TransactionType type;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final String currency;
  final DateTime? endDate;
  final bool executeImmediately;
}