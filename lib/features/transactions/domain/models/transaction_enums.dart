enum TransactionType {
  expense,
  income,
  transfer;

  String get code {
    switch (this) {
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }

  String get label {
    switch (this) {
      case TransactionType.expense:
        return 'Chi tiêu';
      case TransactionType.income:
        return 'Thu nhập';
      case TransactionType.transfer:
        return 'Chuyển khoản';
    }
  }

  static TransactionType fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'INCOME':
        return TransactionType.income;
      case 'TRANSFER':
        return TransactionType.transfer;
      case 'EXPENSE':
      default:
        return TransactionType.expense;
    }
  }
}

enum TransactionStatus {
  confirmed,
  pending,
  cancelled;

  static TransactionStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'PENDING':
        return TransactionStatus.pending;
      case 'CANCELLED':
        return TransactionStatus.cancelled;
      case 'CONFIRMED':
      default:
        return TransactionStatus.confirmed;
    }
  }
}

