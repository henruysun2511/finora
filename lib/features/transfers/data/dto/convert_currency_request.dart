class ConvertCurrencyRequest {
  final String fromAccountId;
  final String toAccountId;
  final double amount;

  const ConvertCurrencyRequest({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
      };
}
