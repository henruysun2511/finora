import 'package:finora_mb/features/transactions/domain/models/transaction_enums.dart';
import 'recurring_enums.dart';

/// Input model khi tạo / cập nhật quy tắc định kỳ
/// Khớp với CreateRecurringTransactionDto & UpdateRecurringTransactionDto của backend
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
    this.isPaused,
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
  final bool? isPaused;
}
