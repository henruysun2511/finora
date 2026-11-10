class OverdueStatsModel {
  final int overdueReceivableCount;
  final double overdueReceivableAmount;
  final int overduePayableCount;
  final double overduePayableAmount;

  const OverdueStatsModel({
    required this.overdueReceivableCount,
    required this.overdueReceivableAmount,
    required this.overduePayableCount,
    required this.overduePayableAmount,
  });

  factory OverdueStatsModel.fromJson(Map<String, dynamic> json) {
    return OverdueStatsModel(
      overdueReceivableCount: (json['overdueReceivableCount'] as num?)?.toInt() ?? 0,
      overdueReceivableAmount: (json['overdueReceivableAmount'] as num?)?.toDouble() ?? 0.0,
      overduePayableCount: (json['overduePayableCount'] as num?)?.toInt() ?? 0,
      overduePayableAmount: (json['overduePayableAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TopDebtorItemModel {
  final String counterpartyName;
  final String? counterpartyUserId;
  final String type; // LENT | BORROWED | INSTALLMENT
  final double remainingAmount;
  final String? dueDate;
  final bool isOverdue;
  final int daysOverdue;

  const TopDebtorItemModel({
    required this.counterpartyName,
    this.counterpartyUserId,
    required this.type,
    required this.remainingAmount,
    this.dueDate,
    required this.isOverdue,
    required this.daysOverdue,
  });

  factory TopDebtorItemModel.fromJson(Map<String, dynamic> json) {
    return TopDebtorItemModel(
      counterpartyName: json['counterpartyName']?.toString() ?? 'Khách hàng',
      counterpartyUserId: json['counterpartyUserId']?.toString(),
      type: json['type']?.toString() ?? 'LENT',
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate']?.toString(),
      isOverdue: json['isOverdue'] == true,
      daysOverdue: (json['daysOverdue'] as num?)?.toInt() ?? 0,
    );
  }
}

class InstallmentItemModel {
  final String loanId;
  final String counterpartyName;
  final double totalPrincipal;
  final double paidAmount;
  final double remainingAmount;
  final double progressPercentage;
  final String? nextDueDate;

  const InstallmentItemModel({
    required this.loanId,
    required this.counterpartyName,
    required this.totalPrincipal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.progressPercentage,
    this.nextDueDate,
  });

  factory InstallmentItemModel.fromJson(Map<String, dynamic> json) {
    return InstallmentItemModel(
      loanId: json['loanId']?.toString() ?? '',
      counterpartyName: json['counterpartyName']?.toString() ?? 'Trả góp',
      totalPrincipal: (json['totalPrincipal'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      nextDueDate: json['nextDueDate']?.toString(),
    );
  }
}

class DebtsDashboardModel {
  final double totalReceivables;
  final double totalPayables;
  final double netDebtPosition;
  final double debtToAssetRatio;
  final OverdueStatsModel overdueStats;
  final List<TopDebtorItemModel> topDebtors;
  final List<InstallmentItemModel> installments;

  const DebtsDashboardModel({
    required this.totalReceivables,
    required this.totalPayables,
    required this.netDebtPosition,
    required this.debtToAssetRatio,
    required this.overdueStats,
    required this.topDebtors,
    required this.installments,
  });

  factory DebtsDashboardModel.fromJson(Map<String, dynamic> json) {
    return DebtsDashboardModel(
      totalReceivables: (json['totalReceivables'] as num?)?.toDouble() ?? 0.0,
      totalPayables: (json['totalPayables'] as num?)?.toDouble() ?? 0.0,
      netDebtPosition: (json['netDebtPosition'] as num?)?.toDouble() ?? 0.0,
      debtToAssetRatio: (json['debtToAssetRatio'] as num?)?.toDouble() ?? 0.0,
      overdueStats: json['overdueStats'] is Map<String, dynamic>
          ? OverdueStatsModel.fromJson(json['overdueStats'] as Map<String, dynamic>)
          : const OverdueStatsModel(
              overdueReceivableCount: 0,
              overdueReceivableAmount: 0,
              overduePayableCount: 0,
              overduePayableAmount: 0,
            ),
      topDebtors: (json['topDebtors'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TopDebtorItemModel.fromJson)
              .toList() ??
          const [],
      installments: (json['installments'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(InstallmentItemModel.fromJson)
              .toList() ??
          const [],
    );
  }
}
