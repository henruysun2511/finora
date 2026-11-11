import '../../domain/models/export_format.dart';
import '../../domain/models/report_overview_data.dart';
import '../../domain/models/report_period.dart';
import '../../domain/repositories/reports_repository.dart';
import '../dto/report_query_dto.dart';
import '../mappers/report_mapper.dart';
import '../services/reports_api_service.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsApiService _apiService;

  ReportsRepositoryImpl(this._apiService);

  @override
  Future<ReportOverviewData> getReportOverview({
    required ReportPeriod period,
    required DateTime targetDate,
    DateTime? customStart,
    DateTime? customEnd,
    String? walletId,
  }) async {
    final queryDto = ReportQueryDto.fromDomain(
      period: period,
      targetDate: targetDate,
      customStart: customStart,
      customEnd: customEnd,
      walletId: walletId,
    );

    // Đồng thời gọi API CategoryBreakdown, Overview, và Cashflow
    final catBreakdownFuture = _apiService.getCategoryBreakdown(queryDto);
    final overviewFuture = _apiService.getOverview(walletId: walletId);
    final cashFlowFuture = _apiService.getCashFlow(queryDto);

    final results = await Future.wait([
      catBreakdownFuture,
      overviewFuture,
      cashFlowFuture,
    ]);

    return ReportMapper.toDomain(
      period: period,
      targetDate: targetDate,
      customStart: customStart,
      customEnd: customEnd,
      categoryBreakdown: results[0] as dynamic,
      overview: results[1] as dynamic,
      cashFlow: results[2] as dynamic,
    );
  }

  @override
  Future<String> exportReport({
    required ReportOverviewData data,
    required ExportFormat format,
  }) async {
    // Giả lập tiến trình xuất báo cáo đẹp chuẩn Solarn
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final dateLabel = '${data.targetDate.year}_${data.targetDate.month.toString().padLeft(2, '0')}';
    final fileName = 'FINORA_Report_${data.period.apiKey}_$dateLabel.${format.extension}';

    return fileName;
  }
}
