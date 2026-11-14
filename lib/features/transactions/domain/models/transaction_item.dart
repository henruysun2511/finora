import 'receipt_model.dart';
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
    this.locationName,
    this.source = 'MANUAL',
    this.visibility = 'PRIVATE',
    this.excludeFromReport = false,
    this.receiptId,
    this.receipt,
    this.latitude,
    this.longitude,
    this.isRecurring = false,
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
  final String? locationName;
  final String source;
  final String visibility;
  final bool excludeFromReport;
  final String? receiptId;
  final ReceiptModel? receipt;
  final double? latitude;
  final double? longitude;
  final bool isRecurring;
  final DateTime transactionDate;
  final DateTime createdAt;

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;

  TransactionItem copyWith({
    String? id,
    String? accountId,
    String? accountName,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    TransactionType? type,
    double? amount,
    String? currency,
    String? name,
    String? note,
    String? photoUrl,
    double? balanceAfter,
    String? toAccountId,
    String? toAccountName,
    TransactionStatus? status,
    String? locationName,
    String? source,
    String? visibility,
    bool? excludeFromReport,
    String? receiptId,
    ReceiptModel? receipt,
    double? latitude,
    double? longitude,
    bool? isRecurring,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      name: name ?? this.name,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      toAccountId: toAccountId ?? this.toAccountId,
      toAccountName: toAccountName ?? this.toAccountName,
      status: status ?? this.status,
      locationName: locationName ?? this.locationName,
      source: source ?? this.source,
      visibility: visibility ?? this.visibility,
      excludeFromReport: excludeFromReport ?? this.excludeFromReport,
      receiptId: receiptId ?? this.receiptId,
      receipt: receipt ?? this.receipt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isRecurring: isRecurring ?? this.isRecurring,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

