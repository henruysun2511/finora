import 'package:finora_mb/features/transactions/domain/models/transaction_enums.dart';

export 'package:finora_mb/features/transactions/domain/models/transaction_enums.dart'
    show TransactionType;

/// Chu kỳ lặp lại - khớp với RecurrencePeriod enum của backend
enum RecurringFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly;

  String get backendValue => name.toUpperCase();

  String get displayName {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Hàng ngày';
      case RecurringFrequency.weekly:
        return 'Hàng tuần';
      case RecurringFrequency.biweekly:
        return 'Hai tuần một lần';
      case RecurringFrequency.monthly:
        return 'Hàng tháng';
      case RecurringFrequency.quarterly:
        return 'Hàng quý';
      case RecurringFrequency.yearly:
        return 'Hàng năm';
    }
  }

  static RecurringFrequency fromBackend(String value) {
    switch (value.toUpperCase()) {
      case 'DAILY':
        return RecurringFrequency.daily;
      case 'WEEKLY':
        return RecurringFrequency.weekly;
      case 'BIWEEKLY':
        return RecurringFrequency.biweekly;
      case 'QUARTERLY':
        return RecurringFrequency.quarterly;
      case 'YEARLY':
        return RecurringFrequency.yearly;
      case 'MONTHLY':
      default:
        return RecurringFrequency.monthly;
    }
  }
}

extension RecurringTransactionTypeX on TransactionType {
  String get backendValue => code;
  String get displayName => label;
}
