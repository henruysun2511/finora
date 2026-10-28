import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/loan_filter.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';

/// Provider quản lý bộ lọc danh sách khoản nợ (Tab và tìm kiếm).
/// Khi filter thay đổi, loanListProvider sẽ tự tải lại.
class LoanFilterNotifier extends Notifier<LoanFilter> {
  @override
  LoanFilter build() => const LoanFilter();

  void setType(LoanType? type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  void setStatus(LoanStatus? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
  }

  void setSearch(String? search) {
    state = state.copyWith(
      search: search?.isEmpty == true ? null : search,
      clearSearch: search == null || search.isEmpty,
    );
  }

  void setSortBy(LoanSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void toggleSortOrder() {
    state = state.copyWith(
      sortOrder: state.sortOrder == LoanSortOrder.asc
          ? LoanSortOrder.desc
          : LoanSortOrder.asc,
    );
  }

  void reset() {
    state = const LoanFilter();
  }
}

final loanFilterProvider =
    NotifierProvider<LoanFilterNotifier, LoanFilter>(LoanFilterNotifier.new);
