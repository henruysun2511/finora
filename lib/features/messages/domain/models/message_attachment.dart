/// Dữ liệu đính kèm giao dịch tài chính trong tin nhắn (FinTech Chat)
class MessageTransactionAttachment {
  const MessageTransactionAttachment({
    required this.transactionId,
    required this.title,
    required this.amount,
    this.categoryName = 'Khác',
    this.categoryIcon,
    this.isExpense = true,
  });

  final String transactionId;
  final String title;
  final double amount;
  final String categoryName;
  final String? categoryIcon;
  final bool isExpense;

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'title': title,
        'amount': amount,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon,
        'isExpense': isExpense,
      };

  factory MessageTransactionAttachment.fromJson(Map<String, dynamic> json) {
    return MessageTransactionAttachment(
      transactionId: json['transactionId']?.toString() ?? '',
      title: json['title'] as String? ?? 'Giao dịch',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      categoryName: json['categoryName'] as String? ?? 'Khác',
      categoryIcon: json['categoryIcon'] as String?,
      isExpense: (json['isExpense'] as bool?) ?? true,
    );
  }
}

