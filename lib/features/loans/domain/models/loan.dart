import 'loan_status.dart';
import 'loan_type.dart';

/// Entity thuần Domain cho khoản Vay/Nợ theo chuẩn Clean Architecture.
/// Tầng domain hoàn toàn độc lập, không phụ thuộc vào Flutter hay Dio.
class Loan {
  const Loan({
    required this.id,
    required this.type,
    required this.status,
    required this.counterpartyName,
    required this.principalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.affectsBalance,
    required this.createdAt,
    this.counterpartyUserId,
    this.counterpartyPhone,
    this.counterpartyAvatarUrl,
    this.sourceWalletId,
    this.sourceWalletName,
    this.dueDate,
    this.interestRate,
    this.interestPeriod,
    this.notes,
    this.installmentMonths,
    this.currentInstallment,
    this.updatedAt,
  });

  final String id;
  final LoanType type;
  final LoanStatus status;
  final String counterpartyName;
  final double principalAmount;
  final double paidAmount;
  final double remainingAmount;
  final bool affectsBalance;
  final DateTime createdAt;

  // Thông tin đối tác
  final String? counterpartyUserId;
  final String? counterpartyPhone;
  final String? counterpartyAvatarUrl;

  // Thông tin ví nguồn
  final String? sourceWalletId;
  final String? sourceWalletName;

  // Thời hạn & lãi suất
  final DateTime? dueDate;
  final double? interestRate;
  final String? interestPeriod; // 'month' | 'year'

  // Ghi chú
  final String? notes;

  // Trả góp (INSTALLMENT)
  final int? installmentMonths;
  final int? currentInstallment;

  final DateTime? updatedAt;

  /// Phần trăm đã hoàn trả (0.0 - 1.0)
  double get repaidPercent => principalAmount > 0
      ? (paidAmount / principalAmount).clamp(0.0, 1.0)
      : 0.0;

  /// Kiểm tra đã liên kết bạn bè trong FINORA
  bool get isLinkedToFriend => counterpartyUserId != null;

  LoanStatus get effectiveStatus {
    if (status == LoanStatus.settled) return LoanStatus.settled;
    final due = dueDate;
    if (status == LoanStatus.overdue ||
        (due != null && _dateOnly(due).isBefore(_dateOnly(DateTime.now())))) {
      return LoanStatus.overdue;
    }
    return LoanStatus.active;
  }

  /// Số ngày quá hạn (dương = quá hạn, âm = còn thời gian)
  int? get overdueDays {
    if (dueDate == null) return null;
    final diff =
        _dateOnly(DateTime.now()).difference(_dateOnly(dueDate!)).inDays;
    return diff > 0 ? diff : null;
  }

  /// Số ngày còn lại đến hạn (chỉ khi chưa quá)
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final diff =
        _dateOnly(dueDate!).difference(_dateOnly(DateTime.now())).inDays;
    return diff >= 0 ? diff : null;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Loan copyWith({
    String? id,
    LoanType? type,
    LoanStatus? status,
    String? counterpartyName,
    double? principalAmount,
    double? paidAmount,
    double? remainingAmount,
    bool? affectsBalance,
    DateTime? createdAt,
    String? counterpartyUserId,
    String? counterpartyPhone,
    String? counterpartyAvatarUrl,
    String? sourceWalletId,
    String? sourceWalletName,
    DateTime? dueDate,
    double? interestRate,
    String? interestPeriod,
    String? notes,
    int? installmentMonths,
    int? currentInstallment,
    DateTime? updatedAt,
    bool clearCounterpartyUserId = false,
  }) {
    return Loan(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      principalAmount: principalAmount ?? this.principalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      affectsBalance: affectsBalance ?? this.affectsBalance,
      createdAt: createdAt ?? this.createdAt,
      counterpartyUserId: clearCounterpartyUserId
          ? null
          : (counterpartyUserId ?? this.counterpartyUserId),
      counterpartyPhone: counterpartyPhone ?? this.counterpartyPhone,
      counterpartyAvatarUrl:
          counterpartyAvatarUrl ?? this.counterpartyAvatarUrl,
      sourceWalletId: sourceWalletId ?? this.sourceWalletId,
      sourceWalletName: sourceWalletName ?? this.sourceWalletName,
      dueDate: dueDate ?? this.dueDate,
      interestRate: interestRate ?? this.interestRate,
      interestPeriod: interestPeriod ?? this.interestPeriod,
      notes: notes ?? this.notes,
      installmentMonths: installmentMonths ?? this.installmentMonths,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
