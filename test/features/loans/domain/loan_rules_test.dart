import 'package:finora_mb/features/loans/domain/models/loan.dart';
import 'package:finora_mb/features/loans/domain/models/loan_status.dart';
import 'package:finora_mb/features/loans/domain/models/loan_summary.dart';
import 'package:finora_mb/features/loans/domain/models/loan_type.dart';
import 'package:finora_mb/features/loans/domain/validators/loan_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('net position is derived from lent, borrowed and installment totals',
      () {
    const summary = LoanSummary(
      totalLent: 18.2,
      totalBorrowed: 2.5,
      totalInstallment: 1.2,
      overdueCount: 0,
      activeCount: 2,
    );

    expect(summary.netPosition, closeTo(14.5, 0.000001));
  });

  group('Loan effective status', () {
    test('marks a past calendar date overdue even within 24 hours', () {
      final today = DateTime.now();
      final yesterday = DateTime(today.year, today.month, today.day - 1, 23);
      final loan = _loan(status: LoanStatus.active, dueDate: yesterday);

      expect(loan.effectiveStatus, LoanStatus.overdue);
      expect(loan.overdueDays, 1);
    });

    test('keeps settled loan settled after its due date', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 2));
      final loan = _loan(status: LoanStatus.settled, dueDate: yesterday);

      expect(loan.effectiveStatus, LoanStatus.settled);
    });
  });

  group('LoanValidators.validatePaymentAmount', () {
    test('rejects a payment greater than the remaining balance', () {
      expect(
        LoanValidators.validatePaymentAmount('1001', 1000),
        'Số tiền thanh toán không được vượt quá số nợ còn lại',
      );
    });

    test('accepts a payment equal to the remaining balance', () {
      expect(LoanValidators.validatePaymentAmount('1000', 1000), isNull);
    });
  });
}

Loan _loan({
  required LoanStatus status,
  required DateTime dueDate,
}) =>
    Loan(
      id: 'loan-test',
      type: LoanType.lent,
      status: status,
      counterpartyName: 'Người vay',
      principalAmount: 1000,
      paidAmount: 0,
      remainingAmount: 1000,
      affectsBalance: false,
      createdAt: DateTime(2026),
      dueDate: dueDate,
    );
