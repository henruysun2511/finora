import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/export_format.dart';
import '../../domain/models/report_period.dart';
import 'report_overview_state.dart';
import 'reports_providers.dart';

class ReportOverviewNotifier extends AutoDisposeNotifier<ReportOverviewState> {
  @override
  ReportOverviewState build() {
    // Khởi tạo thời điểm mặc định
    final now = DateTime.now();
    final initialDate = DateTime(now.year, now.month, 1);

    final initialState = ReportOverviewState(
      period: ReportPeriod.month,
      targetDate: initialDate,
      isLoading: true,
    );

    // Kích hoạt nạp dữ liệu ban đầu
    Future.microtask(_fetchData);

    return initialState;
  }

  Future<void> _fetchData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(reportsRepositoryProvider);
      final data = await repo.getReportOverview(
        period: state.period,
        targetDate: state.targetDate,
        customStart: state.customStart,
        customEnd: state.customEnd,
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
    final cur = state.targetDate;
    DateTime nextDate;

    switch (state.period) {
      case ReportPeriod.week:
        nextDate = cur.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        nextDate = DateTime(cur.year, cur.month - 1, 1);
        break;
      case ReportPeriod.year:
        nextDate = DateTime(cur.year - 1, 1, 1);
        break;
      case ReportPeriod.custom:
        if (state.customStart != null && state.customEnd != null) {
          final diff = state.customEnd!.difference(state.customStart!);
          final newStart = state.customStart!.subtract(diff);
          final newEnd = state.customStart!;
          setCustomRange(newStart, newEnd);
          return;
        }
        nextDate = cur.subtract(const Duration(days: 30));
        break;
    }

    state = state.copyWith(
      targetDate: nextDate,
      clearSelectedCategory: true,
    );
    _fetchData();
  }

  void nextPeriod() {
    final cur = state.targetDate;
    DateTime nextDate;

    switch (state.period) {
      case ReportPeriod.week:
        nextDate = cur.add(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        nextDate = DateTime(cur.year, cur.month + 1, 1);
        break;
      case ReportPeriod.year:
        nextDate = DateTime(cur.year + 1, 1, 1);
        break;
      case ReportPeriod.custom:
        if (state.customStart != null && state.customEnd != null) {
          final diff = state.customEnd!.difference(state.customStart!);
          final newStart = state.customEnd!;
          final newEnd = state.customEnd!.add(diff);
          setCustomRange(newStart, newEnd);
          return;
        }
        nextDate = cur.add(const Duration(days: 30));
        break;
    }

    state = state.copyWith(
      targetDate: nextDate,
      clearSelectedCategory: true,
    );
    _fetchData();
  }

  void selectCategory(String? categoryId) {
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  Future<String?> exportReport(ExportFormat format) async {
    final currentData = state.data;
    if (currentData == null) return null;

    state = state.copyWith(isExporting: true);
    try {
      final repo = ref.read(reportsRepositoryProvider);
      final fileName = await repo.exportReport(
        data: currentData,
        format: format,
      );
      state = state.copyWith(isExporting: false);
      return fileName;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Lỗi xuất báo cáo: $e',
      );
      return null;
    }
  }

  Future<void> refresh() async {
    await _fetchData();
  }
}

final reportOverviewProvider =
    AutoDisposeNotifierProvider<ReportOverviewNotifier, ReportOverviewState>(
  ReportOverviewNotifier.new,
);
