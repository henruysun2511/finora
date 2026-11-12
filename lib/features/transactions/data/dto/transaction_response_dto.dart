import '../../domain/models/receipt_model.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';

class TransactionResponseDto {
  const TransactionResponseDto({
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
    this.status = 'CONFIRMED',
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
  final String type;
  final double amount;
  final String currency;
  final String name;
  final String? note;
  final String? photoUrl;
  final double? balanceAfter;
  final String? toAccountId;
  final String? toAccountName;
  final String status;
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

  factory TransactionResponseDto.fromJson(Map<String, dynamic> json) {
    return TransactionResponseDto(
      id: json['id'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      accountName: json['accountName'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      categoryColor: json['categoryColor'] as String?,
      type: json['type'] as String? ?? 'EXPENSE',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'VND',
      name: json['name'] as String? ?? '',
      note: json['note'] as String?,
      photoUrl: json['photoUrl'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      toAccountId: json['toAccountId'] as String?,
      toAccountName: json['toAccountName'] as String?,
      status: json['status'] as String? ?? 'CONFIRMED',
      locationName: json['locationName'] as String?,
      source: json['source'] as String? ?? 'MANUAL',
      visibility: json['visibility'] as String? ?? 'PRIVATE',
      excludeFromReport: json['excludeFromReport'] as bool? ?? false,
      receiptId: json['receiptId'] as String?,
      receipt: json['receipt'] != null && json['receipt'] is Map<String, dynamic>
          ? ReceiptModel.fromJson(json['receipt'] as Map<String, dynamic>)
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isRecurring: json['isRecurring'] as bool? ?? (json['recurringRule'] != null),
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  TransactionItem toDomain() {
    return TransactionItem(
      id: id,
      accountId: accountId,
      accountName: accountName,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      type: TransactionType.fromString(type),
      amount: amount,
      currency: currency,
      name: name.isNotEmpty ? name : (categoryName ?? 'Giao dịch'),
      note: note,
      photoUrl: photoUrl,
      balanceAfter: balanceAfter,
      toAccountId: toAccountId,
      toAccountName: toAccountName,
      status: TransactionStatus.fromString(status),
      locationName: locationName,
      source: source,
      visibility: visibility,
      excludeFromReport: excludeFromReport,
      receiptId: receiptId,
      receipt: receipt,
      latitude: latitude,
      longitude: longitude,
      isRecurring: isRecurring,
      transactionDate: transactionDate,
      createdAt: createdAt,
    );
  }
}

