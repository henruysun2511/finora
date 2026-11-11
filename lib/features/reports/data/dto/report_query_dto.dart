import '../../domain/models/report_period.dart';

class ReportQueryDto {
  final String period;
  final String? month;
  final String? startDate;
  final String? endDate;
  final String? walletId;

  const ReportQueryDto({
    required this.period,
    this.month,
    this.startDate,
    this.endDate,
    this.walletId,
  });

  Map<String, dynamic> toCategoryQueryParams() {
    return {
      if (month != null) 'month': month,
      if (walletId != null) 'walletId': walletId,
      'type': 'EXPENSE',
    };
  }

  Map<String, dynamic> toCashFlowQueryParams() {
    return {
      'period': period,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (walletId != null) 'walletId': walletId,
    };
  }

  factory ReportQueryDto.fromDomain({
    required ReportPeriod period,
    required DateTime targetDate,
    DateTime? customStart,
    DateTime? customEnd,
    String? walletId,
  }) {
    final year = targetDate.year.toString().padLeft(4, '0');
    final month = targetDate.month.toString().padLeft(2, '0');
    final monthStr = '$year-$month';

    String? sDate;
    String? eDate;

    if (period == ReportPeriod.custom && customStart != null && customEnd != null) {
      sDate = '${customStart.year.toString().padLeft(4, '0')}-${customStart.month.toString().padLeft(2, '0')}-${customStart.day.toString().padLeft(2, '0')}';
      eDate = '${customEnd.year.toString().padLeft(4, '0')}-${customEnd.month.toString().padLeft(2, '0')}-${customEnd.day.toString().padLeft(2, '0')}';
    }

    return ReportQueryDto(
      period: period.apiKey,
      month: monthStr,
      startDate: sDate,
      endDate: eDate,
      walletId: walletId,
    );
  }
}
