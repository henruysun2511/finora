import '../models/export_format.dart';
import '../models/report_overview_data.dart';
import '../models/report_period.dart';

abstract class ReportsRepository {
  Future<ReportOverviewData> getReportOverview({
    required ReportPeriod period,
    required DateTime targetDate,
    DateTime? customStart,
    DateTime? customEnd,
    String? walletId,
  });

  Future<String> exportReport({
    required ReportOverviewData data,
    required ExportFormat format,
  });
}
