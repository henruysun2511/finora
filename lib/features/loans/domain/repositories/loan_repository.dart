import '../models/loan.dart';
import '../models/loan_input.dart';
import '../models/loan_payment.dart';
import '../models/loan_summary.dart';

/// Repository Interface – Hợp đồng nghiệp vụ cho module Loans.
/// Tầng Presentation chỉ phụ thuộc vào interface này, không biết nguồn dữ liệu.
abstract class LoanRepository {
  // ── READ ──────────────────────────────────────────────────────────────────

  /// Lấy danh sách khoản nợ có phân trang và bộ lọc
  Future<List<Loan>> getLoans({
    String? type,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  /// Lấy số liệu tổng hợp cho Hero Card
  Future<LoanSummary> getLoanSummary();

  /// Lấy chi tiết khoản nợ
  Future<Loan> getLoanById(String id);

  /// Lấy lịch sử các đợt thanh toán
  Future<List<LoanPayment>> getLoanPayments(String loanId);

  // ── WRITE ─────────────────────────────────────────────────────────────────

  /// Tạo khoản vay/nợ mới
  Future<Loan> createLoan(LoanInput input);

  /// Cập nhật khoản nợ (chặn đổi số tiền gốc nếu đã có thanh toán)
  Future<Loan> updateLoan(String id, LoanUpdateInput input);

  /// Xóa khoản nợ (chặn nếu đã có thanh toán)
  Future<void> deleteLoan(String id);

  /// Ghi nhận đợt trả nợ
  Future<LoanPayment> recordPayment(String loanId, LoanPaymentInput input);

  // ── SOCIAL ────────────────────────────────────────────────────────────────

  /// Nhắc nợ 1-click qua Push/Socket (rate limit 6 tiếng)
  Future<void> sendReminder(String loanId);

  /// Gỡ liên kết bạn bè khỏi khoản nợ
  Future<void> removeCounterparty(String loanId);
}
