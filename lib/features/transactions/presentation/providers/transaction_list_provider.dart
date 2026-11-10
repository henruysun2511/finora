import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/monthly_transaction_summary.dart';
import 'transaction_providers.dart';

/// Provider lưu giữ Tháng / Năm đang được chọn để xem Sổ giao dịch
final transactionPeriodProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider nạp danh sách giao dịch gom nhóm theo ngày (Daily Grid)
final dailyGridProvider =
    AsyncNotifierProvider<DailyGridNotifier, MonthlyTransactionSummary>(() {
  return DailyGridNotifier();
});

class DailyGridNotifier extends AsyncNotifier<MonthlyTransactionSummary> {
  @override
  Future<MonthlyTransactionSummary> build() async {
    final period = ref.watch(transactionPeriodProvider);
    return _fetchGrid(period.month, period.year);
  }

  Future<MonthlyTransactionSummary> _fetchGrid(int month, int year) async {
    final repo = ref.read(transactionRepositoryProvider);
    return repo.getDailyGrid(month: month, year: year);
  }

  void previousMonth() {
    final current = ref.read(transactionPeriodProvider);
    final prev = DateTime(current.year, current.month - 1);
    ref.read(transactionPeriodProvider.notifier).state = prev;
  }

  void nextMonth() {
    final current = ref.read(transactionPeriodProvider);
    final next = DateTime(current.year, current.month + 1);
    ref.read(transactionPeriodProvider.notifier).state = next;
  }

  void setPeriod(int year, int month) {
    ref.read(transactionPeriodProvider.notifier).state = DateTime(year, month);
  }

  Future<void> refresh() async {
    final period = ref.read(transactionPeriodProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGrid(period.month, period.year));
  }
}

