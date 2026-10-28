import '../../domain/models/loan.dart';
import '../../domain/models/loan_payment.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_summary.dart';
import '../../domain/models/loan_type.dart';
import '../dto/loan_request.dart';
import '../dto/loan_response.dart';
import '../dto/loan_summary_response.dart';
import '../../domain/models/loan_input.dart';

/// Chuyển đổi hai chiều: DTO ↔ Domain Model
extension LoanResponseMapper on LoanResponse {
  Loan toModel() => Loan(
        id: id,
        type: LoanType.fromValue(type),
        status: LoanStatus.fromValue(status),
        counterpartyName: counterpartyName,
        principalAmount: principalAmount.toDouble(),
        paidAmount: paidAmount.toDouble(),
        remainingAmount: remainingAmount.toDouble(),
        affectsBalance: affectsBalance,
        createdAt: createdAt,
        counterpartyUserId: counterpartyUserId,
        counterpartyPhone: counterpartyPhone,
        counterpartyAvatarUrl: counterpartyAvatarUrl,
        sourceWalletId: sourceWalletId,
        sourceWalletName: sourceWalletName,
        dueDate: dueDate,
        interestRate: interestRate?.toDouble(),
        interestPeriod: interestPeriod,
        notes: notes,
        installmentMonths: installmentMonths,
        currentInstallment: currentInstallment,
        updatedAt: updatedAt,
      );
}

extension LoanSummaryResponseMapper on LoanSummaryResponse {
  LoanSummary toModel() => LoanSummary(
        totalLent: totalLent.toDouble(),
        totalBorrowed: totalBorrowed.toDouble(),
        totalInstallment: totalInstallment.toDouble(),
        overdueCount: overdueCount,
        activeCount: activeCount,
      );
}

extension LoanPaymentResponseMapper on LoanPaymentResponse {
  LoanPayment toModel() => LoanPayment(
        id: id,
        loanId: loanId,
        amount: amount.toDouble(),
        paymentDate: paymentDate,
        walletId: walletId,
        walletName: walletName,
        notes: notes,
        createdAt: createdAt,
      );
}

extension LoanInputMapper on LoanInput {
  CreateLoanRequest toRequest() => CreateLoanRequest(
        type: type.value,
        counterpartyName: counterpartyName,
        principalAmount: principalAmount,
        affectsBalance: affectsBalance,
        counterpartyUserId: counterpartyUserId,
        counterpartyPhone: counterpartyPhone,
        sourceWalletId: sourceWalletId,
        dueDate: dueDate,
        interestRate: interestRate,
        interestPeriod: interestPeriod,
        notes: notes,
        installmentMonths: installmentMonths,
      );
}

extension LoanUpdateInputMapper on LoanUpdateInput {
  UpdateLoanRequest toRequest() => UpdateLoanRequest(
        counterpartyName: counterpartyName,
        counterpartyUserId: counterpartyUserId,
        counterpartyPhone: counterpartyPhone,
        dueDate: dueDate,
        notes: notes,
      );
}

extension LoanPaymentInputMapper on LoanPaymentInput {
  CreateLoanPaymentRequest toRequest() => CreateLoanPaymentRequest(
        amount: amount,
        paymentDate: paymentDate,
        affectsBalance: affectsBalance,
        walletId: walletId,
        notes: notes,
      );
}
