import 'daily_transaction_group.dart';

class MonthlyTransactionSummary {
  const MonthlyTransactionSummary({
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
  final List<DailyTransactionGroup> days;

  List<DailyTransactionGroup> get dailyGroups => days;

  factory MonthlyTransactionSummary.empty({int? month, int? year}) {
    final now = DateTime.now();
    return MonthlyTransactionSummary(
      month: month ?? now.month,
      year: year ?? now.year,
      totalIncome: 0,
      totalExpense: 0,
      netAmount: 0,
      totalTransactions: 0,
      days: const [],
    );
  }
}

