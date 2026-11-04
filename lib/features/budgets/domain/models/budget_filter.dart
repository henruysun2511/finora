import 'budget_enums.dart';

/// Bộ lọc danh sách ngân sách: theo ví, chu kỳ hoặc từ khóa tìm kiếm
class BudgetFilter {
  const BudgetFilter({
    this.walletId,
    this.periodType,
    this.searchQuery,
  });

  /// null biểu thị "Tất cả các ví"
  final String? walletId;
  final BudgetPeriodType? periodType;
  final String? searchQuery;

  bool get isAllWallets => walletId == null || walletId!.isEmpty;

  BudgetFilter copyWith({
    String? walletId,
    BudgetPeriodType? periodType,
    String? searchQuery,
    bool clearWalletId = false,
  }) {
    return BudgetFilter(
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      periodType: periodType ?? this.periodType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

