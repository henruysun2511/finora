import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mappers/report_mapper.dart';
import '../../domain/models/export_format.dart';
import '../../domain/models/report_overview_data.dart';
import '../../domain/models/report_period.dart';
import 'dashboard_providers.dart';
import 'report_overview_state.dart';

class ReportOverviewNotifier extends AutoDisposeNotifier<ReportOverviewState> {
  @override
  ReportOverviewState build() {
    final now = DateTime.now();
    final initialDate = DateTime(now.year, now.month, 1);

    final initialState = ReportOverviewState(
      period: ReportPeriod.month,
      targetDate: initialDate,
      isLoading: true,
    );

    Future.microtask(_fetchData);

    return initialState;
  }

  Future<void> _fetchData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final String periodParam;
      switch (state.period) {
        case ReportPeriod.week:
          periodParam = 'WEEK';
          break;
        case ReportPeriod.quarter:
          periodParam = 'QUARTER';
          break;
        case ReportPeriod.year:
          periodParam = 'YEAR';
          break;
        case ReportPeriod.month:
        default:
          periodParam = 'MONTH';
          break;
      }

      final monthParam =
          '${state.targetDate.year}-${state.targetDate.month.toString().padLeft(2, '0')}';

      final results = await Future.wait([
        repo.getCategoryBreakdown(month: monthParam),
        repo.getOverview(),
        repo.getCashFlow(period: periodParam),
      ]);

      final data = ReportMapper.toDomain(
        period: state.period,
        targetDate: state.targetDate,
        customStart: state.customStart,
        customEnd: state.customEnd,
        categoryBreakdown: results[0] as dynamic,
        overview: results[1] as dynamic,
        cashFlow: results[2] as dynamic,
      );

      state = state.copyWith(
        data: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể nạp dữ liệu báo cáo: $e',
      );
    }
  }

  void setPeriod(ReportPeriod newPeriod) {
    if (state.period == newPeriod) return;
    state = state.copyWith(
      period: newPeriod,
      clearSelectedCategory: true,
    );
    _fetchData();
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      period: ReportPeriod.custom,
      customStart: start,
      customEnd: end,
      clearSelectedCategory: true,
    );
    _fetchData();
  }

  void previousPeriod() {
    final current = state.targetDate;
    DateTime nextDate;

    switch (state.period) {
      case ReportPeriod.week:
        nextDate = current.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        nextDate = DateTime(current.year, current.month - 1, 1);
        break;
      case ReportPeriod.quarter:
        nextDate = DateTime(current.year, current.month - 3, 1);
        break;
      case ReportPeriod.year:
        nextDate = DateTime(current.year - 1, 1, 1);
        break;
      case ReportPeriod.custom:
        return;
    }

    state = state.copyWith(targetDate: nextDate);
    _fetchData();
  }

  void nextPeriod() {
    final current = state.targetDate;
    final now = DateTime.now();
    DateTime nextDate;

    switch (state.period) {
      case ReportPeriod.week:
        nextDate = current.add(const Duration(days: 7));
        if (nextDate.isAfter(now)) return;
        break;
      case ReportPeriod.month:
        nextDate = DateTime(current.year, current.month + 1, 1);
        if (nextDate.isAfter(DateTime(now.year, now.month, 1))) return;
        break;
      case ReportPeriod.quarter:
        nextDate = DateTime(current.year, current.month + 3, 1);
        if (nextDate.isAfter(now)) return;
        break;
      case ReportPeriod.year:
        nextDate = DateTime(current.year + 1, 1, 1);
        if (nextDate.year > now.year) return;
        break;
      case ReportPeriod.custom:
        return;
    }

    state = state.copyWith(targetDate: nextDate);
    _fetchData();
  }

  void selectCategory(String? categoryId) {
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  Future<void> refresh() async {
    await _fetchData();
  }

  Future<String?> exportReport(ExportFormat format) async {
    final data = state.data;
    if (data == null) return null;

    state = state.copyWith(isExporting: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final dateLabel =
          '${data.targetDate.year}_${data.targetDate.month.toString().padLeft(2, '0')}';
      return 'Finora_BaoCao_${dateLabel}.${format.extension}';
    } finally {
      state = state.copyWith(isExporting: false);
    }
  }
}

final reportOverviewProvider =
    AutoDisposeNotifierProvider<ReportOverviewNotifier, ReportOverviewState>(
  ReportOverviewNotifier.new,
);

