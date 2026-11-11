class MemberContributionModel {
  final String userId;
  final String fullName;
  final String? avatar;
  final double totalPaid;
  final double percentage;

  const MemberContributionModel({
    required this.userId,
    required this.fullName,
    this.avatar,
    required this.totalPaid,
    required this.percentage,
  });

  factory MemberContributionModel.fromJson(Map<String, dynamic> json) {
    return MemberContributionModel(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Thành viên',
      avatar: json['avatar']?.toString(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SuggestedSettlementModel {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;
  final String reason;

  const SuggestedSettlementModel({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    required this.reason,
  });

  factory SuggestedSettlementModel.fromJson(Map<String, dynamic> json) {
    return SuggestedSettlementModel(
      fromUserId: json['fromUserId']?.toString() ?? '',
      fromUserName: json['fromUserName']?.toString() ?? 'Thành viên',
      toUserId: json['toUserId']?.toString() ?? '',
      toUserName: json['toUserName']?.toString() ?? 'Thành viên',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString() ?? '',
    );
  }
}

class SettlementMatrixModel {
  final bool isBalanced;
  final List<SuggestedSettlementModel> suggestedSettlements;

  const SettlementMatrixModel({
    required this.isBalanced,
    required this.suggestedSettlements,
  });

  factory SettlementMatrixModel.fromJson(Map<String, dynamic> json) {
    final list = json['suggestedSettlements'] as List<dynamic>? ?? [];
    return SettlementMatrixModel(
      isBalanced: json['isBalanced'] == true,
      suggestedSettlements: list
          .whereType<Map<String, dynamic>>()
          .map(SuggestedSettlementModel.fromJson)
          .toList(),
    );
  }
}

class SharedWalletDashboardModel {
  final String walletId;
  final String walletName;
  final double totalSpent;
  final String currency;
  final List<MemberContributionModel> memberContributions;
  final SettlementMatrixModel settlementMatrix;

  const SharedWalletDashboardModel({
    required this.walletId,
    required this.walletName,
    required this.totalSpent,
    required this.currency,
    required this.memberContributions,
    required this.settlementMatrix,
  });

  factory SharedWalletDashboardModel.fromJson(Map<String, dynamic> json) {
    final contributions = json['memberContributions'] as List<dynamic>? ?? [];
    return SharedWalletDashboardModel(
      walletId: json['walletId']?.toString() ?? '',
      walletName: json['walletName']?.toString() ?? 'Ví chung',
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'VND',
      memberContributions: contributions
          .whereType<Map<String, dynamic>>()
          .map(MemberContributionModel.fromJson)
          .toList(),
      settlementMatrix: json['settlementMatrix'] is Map<String, dynamic>
          ? SettlementMatrixModel.fromJson(
              json['settlementMatrix'] as Map<String, dynamic>)
          : const SettlementMatrixModel(
              isBalanced: true, suggestedSettlements: []),
    );
  }
}
