import 'transaction_item.dart';

class DailyTransactionGroup {
  const DailyTransactionGroup({
    required this.dateString,
    required this.date,
    required this.dayOfWeek,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.transactions,
  });

  final String dateString; // '2026-10-18'
  final DateTime date;
  final String dayOfWeek; // 'Hôm nay', 'Hôm qua', 'Thứ 2'...
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final List<TransactionItem> transactions;
}

