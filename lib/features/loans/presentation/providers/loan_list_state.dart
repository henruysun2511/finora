import '../../domain/models/loan.dart';

/// State cho danh sách khoản nợ
class LoanListState {
  const LoanListState({
    required this.items,
    this.isRefreshing = false,
  });

  final List<Loan> items;
  final bool isRefreshing;

  LoanListState copyWith({
    List<Loan>? items,
    bool? isRefreshing,
  }) {
    return LoanListState(
      items: items ?? this.items,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
