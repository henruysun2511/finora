/// Filter cho danh sách giao dịch định kỳ
/// Khớp với RecurringTransactionQueryDto của backend
class RecurringTransactionFilter {
  const RecurringTransactionFilter({
    this.walletId,
    this.isPaused,
    this.page = 1,
    this.limit = 20,
  });

  final String? walletId;
  final bool? isPaused;
  final int page;
  final int limit;

  RecurringTransactionFilter copyWith({
    String? walletId,
    bool? isPaused,
    bool clearPaused = false,
    bool clearWalletId = false,
    int? page,
    int? limit,
  }) {
    return RecurringTransactionFilter(
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      isPaused: clearPaused ? null : (isPaused ?? this.isPaused),
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryMap() {
    return {
      if (walletId != null) 'walletId': walletId,
      if (isPaused != null) 'isPaused': isPaused,
      'page': page,
      'limit': limit,
    };
  }
}