/// Request DTO cho tạo quy tắc định kỳ mới
/// Khớp với CreateRecurringTransactionDto của backend
class CreateRecurringTransactionRequest {
  CreateRecurringTransactionRequest({
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
  final String type; // 'EXPENSE' | 'INCOME'
  final double amount;
  final String frequency; // 'DAILY' | 'WEEKLY' | 'BIWEEKLY' | 'MONTHLY' | 'QUARTERLY' | 'YEARLY'
  final String startDate; // ISO date string
  final String currency;
  final String? endDate; // ISO date string, optional
  final bool executeImmediately;

  Map<String, dynamic> toJson() => {
        'walletId': walletId,
        'accountId': accountId,
        'categoryId': categoryId,
        'name': name,
        'type': type,
        'amount': amount,
        'frequency': frequency,
        'startDate': startDate,
        'currency': currency,
        if (endDate != null) 'endDate': endDate,
        'executeImmediately': executeImmediately,
      };
}