import 'package:finora_mb/features/transactions/domain/models/transaction_enums.dart';
import 'recurring_enums.dart';

/// Filter cho danh sách giao dịch định kỳ
/// Khớp với RecurringTransactionQueryDto của backend
class RecurringTransactionFilter {
  const RecurringTransactionFilter({
    this.walletId,
    this.type,
    this.isPaused,
    this.page = 1,
    this.limit = 20,
  });

  final String? walletId;
  final TransactionType? type;
  final bool? isPaused;
  final int page;
  final int limit;

  RecurringTransactionFilter copyWith({
    String? walletId,
    TransactionType? type,
    bool? isPaused,
    bool clearPaused = false,
    bool clearWalletId = false,
    bool clearType = false,
    int? page,
    int? limit,
  }) {
    return RecurringTransactionFilter(
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      type: clearType ? null : (type ?? this.type),
      isPaused: clearPaused ? null : (isPaused ?? this.isPaused),
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryMap() {
    return {
      if (walletId != null) 'walletId': walletId,
      if (type != null) 'type': type!.backendValue,
      if (isPaused != null) 'isPaused': isPaused,
      'page': page,
      'limit': limit,
    };
  }
}
