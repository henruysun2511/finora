import 'transfer_account.dart';

class Transfer {
  final String id;
  final String fromAccountId;
  final TransferAccount? fromAccount;
  final String toAccountId;
  final TransferAccount? toAccount;
  final double fromAmount;
  final String fromCurrency;
  final double toAmount;
  final String toCurrency;
  final double exchangeRate;
  final double fee;
  final String? feeAccountId;
  final String? note;
  final DateTime transferDate;
  final DateTime createdAt;

  const Transfer({
    required this.id,
    required this.fromAccountId,
    this.fromAccount,
    required this.toAccountId,
    this.toAccount,
    required this.fromAmount,
    required this.fromCurrency,
    required this.toAmount,
    required this.toCurrency,
    required this.exchangeRate,
    required this.fee,
    this.feeAccountId,
    this.note,
    required this.transferDate,
    required this.createdAt,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] as String? ?? '',
      fromAccountId: json['fromAccountId'] as String? ?? '',
      fromAccount: json['fromAccount'] is Map<String, dynamic>
          ? TransferAccount.fromJson(json['fromAccount'] as Map<String, dynamic>)
          : null,
      toAccountId: json['toAccountId'] as String? ?? '',
      toAccount: json['toAccount'] is Map<String, dynamic>
          ? TransferAccount.fromJson(json['toAccount'] as Map<String, dynamic>)
          : null,
      fromAmount: (json['fromAmount'] as num?)?.toDouble() ?? 0.0,
      fromCurrency: json['fromCurrency'] as String? ?? 'VND',
      toAmount: (json['toAmount'] as num?)?.toDouble() ?? 0.0,
      toCurrency: json['toCurrency'] as String? ?? 'VND',
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 1.0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      feeAccountId: json['feeAccountId'] as String?,
      note: json['note'] as String?,
      transferDate: json['transferDate'] != null
          ? DateTime.tryParse(json['transferDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
