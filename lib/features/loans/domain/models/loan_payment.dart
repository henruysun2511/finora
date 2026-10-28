/// Entity cho từng đợt trả nợ (Payment)
class LoanPayment {
  const LoanPayment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    this.walletId,
    this.walletName,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String loanId;
  final double amount;
  final DateTime paymentDate;
  final String? walletId;
  final String? walletName;
  final String? notes;
  final DateTime? createdAt;
}
