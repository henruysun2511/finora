class CashFlowTimelineItemModel {
  final String dateLabel;
  final double income;
  final double expense;
  final double net;

  const CashFlowTimelineItemModel({
    required this.dateLabel,
    required this.income,
    required this.expense,
    required this.net,
  });

  factory CashFlowTimelineItemModel.fromJson(Map<String, dynamic> json) {
    return CashFlowTimelineItemModel(
      dateLabel: json['dateLabel']?.toString() ?? '',
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
      net: (json['net'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DayOfWeekHeatmapItemModel {
  final String dayOfWeek;
  final double averageExpense;

  const DayOfWeekHeatmapItemModel({
    required this.dayOfWeek,
    required this.averageExpense,
  });

  factory DayOfWeekHeatmapItemModel.fromJson(Map<String, dynamic> json) {
    return DayOfWeekHeatmapItemModel(
      dayOfWeek: json['dayOfWeek']?.toString() ?? '',
      averageExpense: (json['averageExpense'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TimeOfDayDistributionItemModel {
  final String label;
  final double amount;
  final double percentage;

  const TimeOfDayDistributionItemModel({
    required this.label,
    required this.amount,
    required this.percentage,
  });

  factory TimeOfDayDistributionItemModel.fromJson(Map<String, dynamic> json) {
    return TimeOfDayDistributionItemModel(
      label: json['label']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CashFlowModel {
  final String period;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final List<CashFlowTimelineItemModel> timeline;
  final List<DayOfWeekHeatmapItemModel> dayOfWeekHeatmap;
  final Map<String, TimeOfDayDistributionItemModel> timeOfDayDistribution;

  const CashFlowModel({
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.timeline,
    required this.dayOfWeekHeatmap,
    required this.timeOfDayDistribution,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    final distMap = <String, TimeOfDayDistributionItemModel>{};
    if (json['timeOfDayDistribution'] is Map<String, dynamic>) {
      final map = json['timeOfDayDistribution'] as Map<String, dynamic>;
      map.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          distMap[k] = TimeOfDayDistributionItemModel.fromJson(v);
        }
      });
    }

    return CashFlowModel(
      period: json['period']?.toString() ?? 'MONTH',
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netSavings: (json['netSavings'] as num?)?.toDouble() ?? 0.0,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CashFlowTimelineItemModel.fromJson)
              .toList() ??
          const [],
      dayOfWeekHeatmap: (json['dayOfWeekHeatmap'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DayOfWeekHeatmapItemModel.fromJson)
              .toList() ??
          const [],
      timeOfDayDistribution: distMap,
    );
  }
}
