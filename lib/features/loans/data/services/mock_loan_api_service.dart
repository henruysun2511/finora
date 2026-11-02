import '../../../../core/errors/app_exception.dart';
import '../dto/loan_request.dart';
import '../dto/loan_response.dart';
import '../dto/loan_summary_response.dart';
import 'loan_api_service.dart';

/// Mock backend giả lập lưu trong bộ nhớ – chạy demo không cần server.
class MockLoanApiService implements LoanApiService {
  MockLoanApiService() {
    _seed();
  }

  final List<LoanResponse> _loans = [];
  final List<LoanPaymentResponse> _payments = [];
  int _nextId = 100;
  static const _latency = Duration(milliseconds: 350);

  // Rate-limit: lưu thời gian nhắc nợ gần nhất theo loanId
  final Map<String, DateTime> _lastRemindTime = {};

  bool _isOverdue(LoanResponse loan, DateTime today) {
    if (loan.status == 'SETTLED') return false;
    if (loan.status == 'OVERDUE') return true;
    final dueDate = loan.dueDate;
    return dueDate != null &&
        DateTime(dueDate.year, dueDate.month, dueDate.day)
            .isBefore(DateTime(today.year, today.month, today.day));
  }

  void _seed() {
    final now = DateTime.now();

    // Khoản cho vay 1 – Quá hạn
    _loans.add(LoanResponse(
      id: 'loan-1',
      type: 'LENT',
      status: 'OVERDUE',
      counterpartyName: 'Hoàng Long',
      principalAmount: 2000000,
      paidAmount: 0,
      remainingAmount: 2000000,
      affectsBalance: true,
      createdAt: now.subtract(const Duration(days: 35)),
      counterpartyUserId: 'user-002',
      counterpartyPhone: '0987654321',
      dueDate: now.subtract(const Duration(days: 3)),
      notes: 'Cho vay tiền cọc nhà trọ',
    ));

    // Khoản cho vay 2 – Còn hạn, đang trả
    _loans.add(LoanResponse(
      id: 'loan-2',
      type: 'LENT',
      status: 'ACTIVE',
      counterpartyName: 'Trần Ngọc',
      principalAmount: 4500000,
      paidAmount: 3000000,
      remainingAmount: 1500000,
      affectsBalance: true,
      createdAt: now.subtract(const Duration(days: 28)),
      counterpartyPhone: '0912345678',
      dueDate: now.add(const Duration(days: 18)),
      notes: 'Cho mượn mua laptop cũ',
    ));

    // Khoản cho vay 3 – Còn nhiều thời gian
    _loans.add(LoanResponse(
      id: 'loan-3',
      type: 'LENT',
      status: 'ACTIVE',
      counterpartyName: 'Minh Tuấn',
      principalAmount: 11700000,
      paidAmount: 2700000,
      remainingAmount: 9000000,
      affectsBalance: true,
      createdAt: now.subtract(const Duration(days: 10)),
      dueDate: now.add(const Duration(days: 50)),
      notes: 'Hỗ trợ học phí học kỳ 2',
    ));

    // Khoản đi vay 1
    _loans.add(LoanResponse(
      id: 'loan-4',
      type: 'BORROWED',
      status: 'ACTIVE',
      counterpartyName: 'Anh Hùng (Họ hàng)',
      principalAmount: 5000000,
      paidAmount: 1000000,
      remainingAmount: 4000000,
      affectsBalance: true,
      createdAt: now.subtract(const Duration(days: 15)),
      dueDate: now.add(const Duration(days: 30)),
      notes: 'Vay khẩn cấp sửa xe máy',
    ));

    // Khoản trả góp
    _loans.add(LoanResponse(
      id: 'loan-5',
      type: 'INSTALLMENT',
      status: 'ACTIVE',
      counterpartyName: 'FE Credit - Trả góp iPhone 16 Pro',
      principalAmount: 15000000,
      paidAmount: 2500000,
      remainingAmount: 12500000,
      affectsBalance: true,
      createdAt: now.subtract(const Duration(days: 60)),
      dueDate: now.add(const Duration(days: 8)),
      installmentMonths: 12,
      currentInstallment: 2,
      interestRate: 0,
      notes: 'Lãi suất 0%, thanh toán tháng 3/12',
    ));

    // Khoản đã tất toán
    _loans.add(LoanResponse(
      id: 'loan-6',
      type: 'LENT',
      status: 'SETTLED',
      counterpartyName: 'Thanh Hà',
      principalAmount: 3000000,
      paidAmount: 3000000,
      remainingAmount: 0,
      affectsBalance: true,
      createdAt: now.subtract(const Duration(days: 60)),
      dueDate: now.subtract(const Duration(days: 5)),
      notes: 'Đã tất toán đầy đủ',
    ));

    // Seed payments for loan-2
    _payments.addAll([
      LoanPaymentResponse(
        id: 'pay-1',
        loanId: 'loan-2',
        amount: 1500000,
        paymentDate: now.subtract(const Duration(days: 10)),
        walletName: 'Ví Tiền mặt',
        notes: 'Đợt 1: Trả tiền mặt',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      LoanPaymentResponse(
        id: 'pay-2',
        loanId: 'loan-2',
        amount: 1500000,
        paymentDate: now.subtract(const Duration(days: 3)),
        walletName: 'Vietcombank Digi',
        notes: 'Đợt 2: Trả chuyển khoản',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  @override
  Future<List<LoanResponse>> getLoans({
    String? type,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    await Future<void>.delayed(_latency);

    var result = List<LoanResponse>.from(_loans);
    final today = DateTime.now();

    if (type != null) result = result.where((l) => l.type == type).toList();
    if (status != null) {
      result = result.where((loan) {
        if (loan.status == 'SETTLED') return status == 'SETTLED';
        final isOverdue = _isOverdue(loan, today);
        return status == 'OVERDUE'
            ? isOverdue
            : status == 'ACTIVE'
                ? !isOverdue
                : false;
      }).toList();
    }
    if (search != null && search.isNotEmpty) {
      final kw = search.toLowerCase();
      result = result
          .where((l) =>
              l.counterpartyName.toLowerCase().contains(kw) ||
              (l.notes?.toLowerCase().contains(kw) ?? false))
          .toList();
    }

    // Sort
    result.sort((a, b) {
      final isDesc = (sortOrder ?? 'ASC').toUpperCase() == 'DESC';
      int cmp;
      switch (sortBy ?? 'dueDate') {
        case 'principalAmount':
          cmp = a.principalAmount.compareTo(b.principalAmount);
          break;
        case 'createdAt':
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        default: // dueDate
          final ad = a.dueDate;
          final bd = b.dueDate;
          if (ad == null && bd == null) {
            cmp = 0;
          } else if (ad == null) {
            cmp = 1;
          } else if (bd == null) {
            cmp = -1;
          } else {
            cmp = ad.compareTo(bd);
          }
      }
      return isDesc ? -cmp : cmp;
    });

    return result;
  }

  @override
  Future<LoanSummaryResponse> getLoanSummary() async {
    await Future<void>.delayed(_latency);

    final now = DateTime.now();
    final active = _loans.where((l) => l.status != 'SETTLED');
    final totalLent = active
        .where((l) => l.type == 'LENT')
        .fold<double>(0, (s, l) => s + l.remainingAmount.toDouble());
    final totalBorrowed = active
        .where((l) => l.type == 'BORROWED')
        .fold<double>(0, (s, l) => s + l.remainingAmount.toDouble());
    final totalInstallment = active
        .where((l) => l.type == 'INSTALLMENT')
        .fold<double>(0, (s, l) => s + l.remainingAmount.toDouble());

    return LoanSummaryResponse(
      totalLent: totalLent,
      totalBorrowed: totalBorrowed,
      totalInstallment: totalInstallment,
      netPosition: totalLent - totalBorrowed - totalInstallment,
      overdueCount: _loans.where((loan) => _isOverdue(loan, now)).length,
      activeCount: _loans.where((l) => l.status != 'SETTLED').length,
    );
  }

  @override
  Future<LoanResponse> getLoanById(String id) async {
    await Future<void>.delayed(_latency);
    return _loans.firstWhere(
      (l) => l.id == id,
      orElse: () =>
          throw const AppException('Không tìm thấy khoản nợ.', statusCode: 404),
    );
  }

  @override
  Future<LoanResponse> createLoan(CreateLoanRequest r) async {
    await Future<void>.delayed(_latency);
    final now = DateTime.now();
    final id = 'loan-${_nextId++}';

    // Tính trạng thái ban đầu
    final dueDate = r.dueDate;
    final status = dueDate != null &&
            DateTime(dueDate.year, dueDate.month, dueDate.day)
                .isBefore(DateTime(now.year, now.month, now.day))
        ? 'OVERDUE'
        : 'ACTIVE';

    final loan = LoanResponse(
      id: id,
      type: r.type,
      status: status,
      counterpartyName: r.counterpartyName,
      principalAmount: r.principalAmount,
      paidAmount: 0,
      remainingAmount: r.principalAmount,
      affectsBalance: r.affectsBalance,
      createdAt: now,
      counterpartyUserId: r.counterpartyUserId,
      counterpartyPhone: r.counterpartyPhone,
      sourceWalletId: r.sourceWalletId,
      dueDate: r.dueDate,
      interestRate: r.interestRate,
      interestPeriod: r.interestPeriod,
      notes: r.notes,
      installmentMonths: r.installmentMonths,
      currentInstallment: r.installmentMonths != null ? 0 : null,
      updatedAt: now,
    );
    _loans.insert(0, loan);
    return loan;
  }

  @override
  Future<LoanResponse> updateLoan(String id, UpdateLoanRequest r) async {
    await Future<void>.delayed(_latency);
    final index = _loans.indexWhere((l) => l.id == id);
    if (index == -1) {
      throw const AppException('Không tìm thấy khoản nợ.', statusCode: 404);
    }
    final old = _loans[index];
    final updated = LoanResponse(
      id: old.id,
      type: old.type,
      status: old.status,
      counterpartyName: r.counterpartyName ?? old.counterpartyName,
      principalAmount: old.principalAmount,
      paidAmount: old.paidAmount,
      remainingAmount: old.remainingAmount,
      affectsBalance: old.affectsBalance,
      createdAt: old.createdAt,
      counterpartyUserId: r.counterpartyUserId ?? old.counterpartyUserId,
      counterpartyPhone: r.counterpartyPhone ?? old.counterpartyPhone,
      counterpartyAvatarUrl: old.counterpartyAvatarUrl,
      sourceWalletId: old.sourceWalletId,
      sourceWalletName: old.sourceWalletName,
      dueDate: r.dueDate ?? old.dueDate,
      interestRate: old.interestRate,
      interestPeriod: old.interestPeriod,
      notes: r.notes ?? old.notes,
      installmentMonths: old.installmentMonths,
      currentInstallment: old.currentInstallment,
      updatedAt: DateTime.now(),
    );
    _loans[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteLoan(String id) async {
    await Future<void>.delayed(_latency);
    final hasPayment = _payments.any((p) => p.loanId == id);
    if (hasPayment) {
      throw const AppException(
        'Không thể xóa khoản nợ đã có lịch sử thanh toán.',
        statusCode: 422,
      );
    }
    final before = _loans.length;
    _loans.removeWhere((l) => l.id == id);
    if (_loans.length == before) {
      throw const AppException('Không tìm thấy khoản nợ.', statusCode: 404);
    }
  }

  @override
  Future<LoanPaymentResponse> recordPayment(
    String loanId,
    CreateLoanPaymentRequest r,
  ) async {
    await Future<void>.delayed(_latency);

    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index == -1) {
      throw const AppException('Không tìm thấy khoản nợ.', statusCode: 404);
    }
    final loan = _loans[index];

    if (r.amount > loan.remainingAmount.toDouble()) {
      throw const AppException(
        'Số tiền thanh toán vượt quá số nợ còn lại.',
        statusCode: 422,
      );
    }

    final newPaid = loan.paidAmount.toDouble() + r.amount;
    final newRemaining = loan.remainingAmount.toDouble() - r.amount;
    final newStatus = newRemaining <= 0 ? 'SETTLED' : loan.status;

    // Tăng installment nếu có
    final newInstallment =
        loan.currentInstallment != null ? loan.currentInstallment! + 1 : null;

    _loans[index] = LoanResponse(
      id: loan.id,
      type: loan.type,
      status: newStatus,
      counterpartyName: loan.counterpartyName,
      principalAmount: loan.principalAmount,
      paidAmount: newPaid,
      remainingAmount: newRemaining,
      affectsBalance: loan.affectsBalance,
      createdAt: loan.createdAt,
      counterpartyUserId: loan.counterpartyUserId,
      counterpartyPhone: loan.counterpartyPhone,
      counterpartyAvatarUrl: loan.counterpartyAvatarUrl,
      sourceWalletId: loan.sourceWalletId,
      sourceWalletName: loan.sourceWalletName,
      dueDate: loan.dueDate,
      interestRate: loan.interestRate,
      interestPeriod: loan.interestPeriod,
      notes: loan.notes,
      installmentMonths: loan.installmentMonths,
      currentInstallment: newInstallment,
      updatedAt: DateTime.now(),
    );

    final payment = LoanPaymentResponse(
      id: 'pay-${_nextId++}',
      loanId: loanId,
      amount: r.amount,
      paymentDate: r.paymentDate,
      walletId: r.walletId,
      notes: r.notes,
      createdAt: DateTime.now(),
    );
    _payments.insert(0, payment);
    return payment;
  }

  @override
  Future<List<LoanPaymentResponse>> getLoanPayments(String loanId) async {
    await Future<void>.delayed(_latency);
    return _payments.where((p) => p.loanId == loanId).toList();
  }

  @override
  Future<void> sendReminder(String loanId) async {
    await Future<void>.delayed(_latency);
    const rateLimitHours = 6;
    final last = _lastRemindTime[loanId];
    if (last != null) {
      final diff = DateTime.now().difference(last).inHours;
      if (diff < rateLimitHours) {
        throw AppException(
          'Đã gửi nhắc nợ gần đây. Vui lòng chờ ${rateLimitHours - diff} tiếng nữa.',
          statusCode: 429,
        );
      }
    }
    _lastRemindTime[loanId] = DateTime.now();
    // Simulate sending notification
  }

  @override
  Future<void> removeCounterparty(String loanId) async {
    await Future<void>.delayed(_latency);
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index == -1) {
      throw const AppException('Không tìm thấy khoản nợ.', statusCode: 404);
    }
    final old = _loans[index];
    _loans[index] = LoanResponse(
      id: old.id,
      type: old.type,
      status: old.status,
      counterpartyName: old.counterpartyName,
      principalAmount: old.principalAmount,
      paidAmount: old.paidAmount,
      remainingAmount: old.remainingAmount,
      affectsBalance: old.affectsBalance,
      createdAt: old.createdAt,
      counterpartyUserId: null, // Cleared
      counterpartyPhone: old.counterpartyPhone,
      counterpartyAvatarUrl: null,
      sourceWalletId: old.sourceWalletId,
      sourceWalletName: old.sourceWalletName,
      dueDate: old.dueDate,
      interestRate: old.interestRate,
      interestPeriod: old.interestPeriod,
      notes: old.notes,
      installmentMonths: old.installmentMonths,
      currentInstallment: old.currentInstallment,
      updatedAt: DateTime.now(),
    );
  }
}
