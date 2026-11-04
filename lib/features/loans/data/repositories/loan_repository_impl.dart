import '../../domain/models/loan.dart';
import '../../domain/models/loan_input.dart';
import '../../domain/models/loan_payment.dart';
import '../../domain/models/loan_summary.dart';
import '../../domain/repositories/loan_repository.dart';
import '../mappers/loan_mapper.dart';
import '../services/loan_api_service.dart';

/// Triển khai LoanRepository sử dụng LoanApiService + LoanMapper
class LoanRepositoryImpl implements LoanRepository {
  LoanRepositoryImpl(this._service);

  final LoanApiService _service;

  @override
  Future<List<Loan>> getLoans({
    String? type,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final responses = await _service.getLoans(
      type: type,
      status: status,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    return responses.map((r) => r.toModel()).toList();
  }

  @override
  Future<LoanSummary> getLoanSummary() async =>
      (await _service.getLoanSummary()).toModel();

  @override
  Future<Loan> getLoanById(String id) async =>
      (await _service.getLoanById(id)).toModel();

  @override
  Future<List<LoanPayment>> getLoanPayments(String loanId) async {
    final responses = await _service.getLoanPayments(loanId);
    return responses.map((r) => r.toModel()).toList();
  }

  @override
  Future<Loan> createLoan(LoanInput input) async =>
      (await _service.createLoan(input.toRequest())).toModel();

  @override
  Future<Loan> updateLoan(String id, LoanUpdateInput input) async =>
      (await _service.updateLoan(id, input.toRequest())).toModel();

  @override
  Future<void> deleteLoan(String id) => _service.deleteLoan(id);

  @override
  Future<LoanPayment> recordPayment(
    String loanId,
    LoanPaymentInput input,
  ) async =>
      (await _service.recordPayment(loanId, input.toRequest())).toModel();

  @override
  Future<void> sendReminder(String loanId) => _service.sendReminder(loanId);

  @override
  Future<void> removeCounterparty(String loanId) =>
      _service.removeCounterparty(loanId);
}
