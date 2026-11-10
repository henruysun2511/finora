import 'transaction_enums.dart';

class CreateTransactionInput {
  const CreateTransactionInput({
    required this.accountId,
    required this.type,
    required this.amount,
    this.categoryId,
    this.toAccountId,
    this.name,
    this.note,
    this.transactionDate,
    this.photoUrl,
    this.fee,
    this.locationName,
    this.excludeFromReport = false,
    this.amountHidden = false,
    this.visibility = 'PRIVATE',
  });

  final String accountId;
  final String? toAccountId; // Cho chuyển khoản
  final String? categoryId; // Bắt buộc khi chi tiêu/thu nhập
  final TransactionType type;
  final double amount;
  final double? fee; // Phí chuyển khoản
  final String? name;
  final String? note;
  final DateTime? transactionDate;
  final String? photoUrl; // Ảnh chụp/thư viện đính kèm
  final String? locationName; // Tên địa điểm
  final bool excludeFromReport; // Loại trừ khỏi báo cáo
  final bool amountHidden; // Ẩn số tiền trong ví chia sẻ
  final String visibility; // PRIVATE hoặc FRIENDS

  Map<String, dynamic> toTransactionJson() {
    return {
      'accountId': accountId,
      'categoryId': categoryId,
      'type': type.code,
      'amount': amount,
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      if (locationName != null && locationName!.trim().isNotEmpty)
        'locationName': locationName!.trim(),
      if (photoUrl != null && photoUrl!.trim().isNotEmpty)
        'photoUrl': photoUrl!.trim(),
      'excludeFromReport': excludeFromReport,
      'amountHidden': amountHidden,
      'visibility': visibility,
      'transactionDate': (transactionDate ?? DateTime.now()).toIso8601String(),
    };
  }

  Map<String, dynamic> toTransferJson() {
    return {
      'fromAccountId': accountId,
      'toAccountId': toAccountId,
      'amount': amount,
      if (fee != null && fee! > 0) 'fee': fee,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      'transferDate': (transactionDate ?? DateTime.now()).toIso8601String(),
    };
  }
}
