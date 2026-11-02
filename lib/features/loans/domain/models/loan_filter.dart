import 'loan_status.dart';
import 'loan_type.dart';

/// Tiêu chí lọc và sắp xếp danh sách khoản nợ
class LoanFilter {
  const LoanFilter({
    this.type,
    this.status,
    this.search,
    this.sortBy = LoanSortBy.dueDate,
    this.sortOrder = LoanSortOrder.asc,
  });

  final LoanType? type;
  final LoanStatus? status;
  final String? search;
  final LoanSortBy sortBy;
  final LoanSortOrder sortOrder;

  LoanFilter copyWith({
    LoanType? type,
    LoanStatus? status,
    String? search,
    LoanSortBy? sortBy,
    LoanSortOrder? sortOrder,
    bool clearType = false,
    bool clearStatus = false,
    bool clearSearch = false,
  }) {
    return LoanFilter(
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      search: clearSearch ? null : (search ?? this.search),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LoanFilter &&
      other.type == type &&
      other.status == status &&
      other.search == search &&
      other.sortBy == sortBy &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(type, status, search, sortBy, sortOrder);
}

enum LoanSortBy {
  dueDate('dueDate'),
  amount('principalAmount'),
  createdAt('createdAt');

  const LoanSortBy(this.value);
  final String value;
}

enum LoanSortOrder {
  asc('ASC'),
  desc('DESC');

  const LoanSortOrder(this.value);
  final String value;
}
