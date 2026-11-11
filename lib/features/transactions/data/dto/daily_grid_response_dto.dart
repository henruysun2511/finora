import '../../domain/models/daily_transaction_group.dart';
import '../../domain/models/monthly_transaction_summary.dart';
import 'transaction_response_dto.dart';

class DailyGridResponseDto {
  const DailyGridResponseDto({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.totalTransactions,
    required this.days,
  });

  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final int totalTransactions;
  final List<DailyGridDayDto> days;

  factory DailyGridResponseDto.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>? ?? {};
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final daysList = json['days'] as List<dynamic>? ?? [];

    return DailyGridResponseDto(
      month: (period['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (period['year'] as num?)?.toInt() ?? DateTime.now().year,
      totalIncome: (summary['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (summary['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netAmount: (summary['netAmount'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (summary['totalTransactions'] as num?)?.toInt() ?? 0,
      days: daysList
          .whereType<Map<String, dynamic>>()
          .map(DailyGridDayDto.fromJson)
          .toList(),
    );
  }

  MonthlyTransactionSummary toDomain() {
    return MonthlyTransactionSummary(
      month: month,
      year: year,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: netAmount,
      totalTransactions: totalTransactions,
      days: days.map((d) => d.toDomain()).toList(),
    );
  }
}

class DailyGridDayDto {
  const DailyGridDayDto({
    required this.date,
    required this.dayOfWeek,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.transactions,
  });

  final String date;
  final String dayOfWeek;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final List<TransactionResponseDto> transactions;

  factory DailyGridDayDto.fromJson(Map<String, dynamic> json) {
    final txList = json['transactions'] as List<dynamic>? ?? [];

    return DailyGridDayDto(
      date: json['date'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      transactions: txList
          .whereType<Map<String, dynamic>>()
          .map(TransactionResponseDto.fromJson)
          .toList(),
    );
  }

  DailyTransactionGroup toDomain() {
    final parsedDate = DateTime.tryParse(date) ?? DateTime.now();
    return DailyTransactionGroup(
      dateString: date,
      date: parsedDate,
      dayOfWeek: _localizeDayOfWeek(parsedDate, dayOfWeek),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: netAmount,
      transactions: transactions.map((t) => t.toDomain()).toList(),
    );
  }

  static String _localizeDayOfWeek(DateTime date, String backendDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Hôm nay';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    }

    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
      default:
        return 'Chủ Nhật';
    }
  }
}

