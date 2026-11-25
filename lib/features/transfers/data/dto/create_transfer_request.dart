class CreateTransferRequest {
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final double fee;
  final String? feeAccountId;
  final String? note;
  final String? transferDate;
  final String? pin;

  const CreateTransferRequest({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    this.fee = 0.0,
    this.feeAccountId,
    this.note,
    this.transferDate,
    this.pin,
  });

  Map<String, dynamic> toJson() => {
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        if (fee > 0) 'fee': fee,
        if (feeAccountId != null && feeAccountId!.isNotEmpty)
          'feeAccountId': feeAccountId,
        if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
        if (transferDate != null && transferDate!.isNotEmpty)
          'transferDate': transferDate,
        if (pin != null && pin!.isNotEmpty) 'pin': pin,
      };
}
