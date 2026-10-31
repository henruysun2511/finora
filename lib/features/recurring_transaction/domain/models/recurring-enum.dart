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

/// Loại giao dịch - khớp với TransactionType enum của backend
enum TransactionType {
  expense,
  income;

  String get backendValue => name.toUpperCase();

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Chi tiêu (EXPENSE)';
      case TransactionType.income:
        return 'Thu nhập (INCOME)';
    }
  }

  static TransactionType fromBackend(String value) {
    if (value.toUpperCase() == 'INCOME') return TransactionType.income;
    return TransactionType.expense;
  }
}