import '../../domain/models/report_overview_data.dart';
import '../../domain/models/report_period.dart';

class ReportOverviewState {
  final ReportPeriod period;
  final DateTime targetDate;
  final DateTime? customStart;
  final DateTime? customEnd;
  final String? selectedCategoryId;
  final ReportOverviewData? data;
  final bool isLoading;
  final bool isExporting;
  final String? errorMessage;

  const ReportOverviewState({
    required this.period,
    required this.targetDate,
    this.customStart,
    this.customEnd,
    this.selectedCategoryId,
    this.data,
    this.isLoading = false,
    this.isExporting = false,
    this.errorMessage,
  });

  ReportOverviewState copyWith({
    ReportPeriod? period,
    DateTime? targetDate,
    DateTime? customStart,
    DateTime? customEnd,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    ReportOverviewData? data,
    bool? isLoading,
    bool? isExporting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportOverviewState(
      period: period ?? this.period,
      targetDate: targetDate ?? this.targetDate,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

