/// Entity tóm tắt số liệu Hero Card: Vị thế nợ ròng
class LoanSummary {
  const LoanSummary({
    required this.totalLent,
    required this.totalBorrowed,
    required this.totalInstallment,
    required this.overdueCount,
    required this.activeCount,
  });

  /// Tổng tiền đang cho vay (cần thu về)
  final double totalLent;

  /// Tổng tiền đang đi vay (phải trả)
  final double totalBorrowed;

  /// Tổng nợ còn lại của trả góp (phải trả)
  final double totalInstallment;

  /// Vị thế ròng = totalLent - (totalBorrowed + totalInstallment)
  /// Dương = thặng dư (cho vay > đi vay); Âm = áp lực nợ
  double get netPosition => totalLent - (totalBorrowed + totalInstallment);

  /// Số khoản đang quá hạn
  final int overdueCount;

  /// Tổng số khoản đang hoạt động
  final int activeCount;

  const LoanSummary.empty()
      : totalLent = 0,
        totalBorrowed = 0,
        totalInstallment = 0,
        overdueCount = 0,
        activeCount = 0;
}
