class CalendarDayItemModel {
  final String date;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;
  final bool hasSpikeExpense;
  final String? highlightPhotoUrl;

  const CalendarDayItemModel({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
    required this.hasSpikeExpense,
    this.highlightPhotoUrl,
  });

  factory CalendarDayItemModel.fromJson(Map<String, dynamic> json) {
    return CalendarDayItemModel(
      date: json['date']?.toString() ?? '',
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      hasSpikeExpense: json['hasSpikeExpense'] == true,
      highlightPhotoUrl: json['highlightPhotoUrl']?.toString(),
    );
  }
}

class UpcomingBillItemModel {
  final String id;
  final String name;
  final double amount;
  final String nextRunDate;
  final String frequency;
  final int daysRemaining;

  const UpcomingBillItemModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.nextRunDate,
    required this.frequency,
    required this.daysRemaining,
  });

  factory UpcomingBillItemModel.fromJson(Map<String, dynamic> json) {
    return UpcomingBillItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Hóa đơn định kỳ',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      nextRunDate: json['nextRunDate']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? 'MONTHLY',
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
    );
  }
}

class UpcomingBillsSummaryModel {
  final double totalUpcoming30Days;
  final double projectedDisposableCash;
  final List<UpcomingBillItemModel> bills;

  const UpcomingBillsSummaryModel({
    required this.totalUpcoming30Days,
    required this.projectedDisposableCash,
    required this.bills,
  });

  factory UpcomingBillsSummaryModel.fromJson(Map<String, dynamic> json) {
    return UpcomingBillsSummaryModel(
      totalUpcoming30Days: (json['totalUpcoming30Days'] as num?)?.toDouble() ?? 0.0,
      projectedDisposableCash: (json['projectedDisposableCash'] as num?)?.toDouble() ?? 0.0,
      bills: (json['bills'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(UpcomingBillItemModel.fromJson)
              .toList() ??
          const [],
    );
  }
}

class CalendarDashboardModel {
  final String month;
  final List<CalendarDayItemModel> days;
  final UpcomingBillsSummaryModel upcomingBillsSummary;

  const CalendarDashboardModel({
    required this.month,
    required this.days,
    required this.upcomingBillsSummary,
  });

  factory CalendarDashboardModel.fromJson(Map<String, dynamic> json) {
    return CalendarDashboardModel(
      month: json['month']?.toString() ?? '',
      days: (json['days'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CalendarDayItemModel.fromJson)
              .toList() ??
          const [],
      upcomingBillsSummary: json['upcomingBillsSummary'] is Map<String, dynamic>
          ? UpcomingBillsSummaryModel.fromJson(json['upcomingBillsSummary'] as Map<String, dynamic>)
          : const UpcomingBillsSummaryModel(
              totalUpcoming30Days: 0,
              projectedDisposableCash: 0,
              bills: [],
            ),
    );
  }
}
