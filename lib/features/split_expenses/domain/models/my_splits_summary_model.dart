class MySplitsSummaryModel {
  const MySplitsSummaryModel({
    required this.pendingRequestsCount,
    required this.totalOwedToMe,
    required this.totalIOwe,
  });

  final int pendingRequestsCount;
  final double totalOwedToMe;
  final double totalIOwe;

  factory MySplitsSummaryModel.fromJson(Map<String, dynamic> json) {
    return MySplitsSummaryModel(
      pendingRequestsCount: (json['pendingRequestsCount'] as num?)?.toInt() ?? 0,
      totalOwedToMe: (json['totalOwedToMe'] as num?)?.toDouble() ?? 0.0,
      totalIOwe: (json['totalIOwe'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const empty = MySplitsSummaryModel(
    pendingRequestsCount: 0,
    totalOwedToMe: 0.0,
    totalIOwe: 0.0,
  );
}
