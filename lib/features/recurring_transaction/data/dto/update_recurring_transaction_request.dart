/// Request DTO cho cập nhật quy tắc định kỳ
/// Khớp với UpdateRecurringTransactionDto của backend
class UpdateRecurringTransactionRequest {
  const UpdateRecurringTransactionRequest({
    this.walletId,
    this.accountId,
    this.categoryId,
    this.name,
    this.type,
    this.amount,
    this.frequency,
    this.startDate,
    this.currency,
    this.endDate,
    this.isPaused,
  });

  final String? walletId;
  final String? accountId;
  final String? categoryId;
  final String? name;
  final String? type;
  final double? amount;
  final String? frequency;
  final String? startDate;
  final String? currency;
  final String? endDate;
  final bool? isPaused;

  Map<String, dynamic> toJson() => {
        if (walletId != null) 'walletId': walletId,
        if (accountId != null) 'accountId': accountId,
        if (categoryId != null) 'categoryId': categoryId,
        if (name != null) 'name': name,
        if (type != null) 'type': type,
        if (amount != null) 'amount': amount,
        if (frequency != null) 'frequency': frequency,
        if (startDate != null) 'startDate': startDate,
        if (currency != null) 'currency': currency,
        if (endDate != null) 'endDate': endDate,
        if (isPaused != null) 'isPaused': isPaused,
      };
}

