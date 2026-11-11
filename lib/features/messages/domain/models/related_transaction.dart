class RelatedTransaction {
  const RelatedTransaction({
    required this.id,
    required this.name,
    required this.amount,
    this.photoUrl,
    required this.transactionDate,
    this.isExpense = true,
    this.groupWalletName,
  });

  final String id;
  final String name;
  final double amount;
  final String? photoUrl;
  final DateTime transactionDate;
  final bool isExpense;
  final String? groupWalletName;
}
