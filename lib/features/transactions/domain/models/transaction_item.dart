import 'transaction_enums.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.name,
    required this.transactionDate,
    required this.createdAt,
    this.accountName,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.note,
    this.photoUrl,
    this.balanceAfter,
    this.toAccountId,
    this.toAccountName,
    this.status = TransactionStatus.confirmed,
  });

  final String id;
  final String accountId;
  final String? accountName;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final TransactionType type;
  final double amount;
  final String currency;
  final String name;
  final String? note;
  final String? photoUrl;
  final double? balanceAfter;
  final String? toAccountId;
  final String? toAccountName;
  final TransactionStatus status;
  final DateTime transactionDate;
  final DateTime createdAt;

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;
}

