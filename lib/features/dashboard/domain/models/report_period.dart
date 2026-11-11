enum ReportPeriod {
  week,
  month,
  year,
  custom;

  String get label {
    switch (this) {
      case ReportPeriod.week:
        return 'Tuần';
      case ReportPeriod.month:
        return 'Tháng';
      case ReportPeriod.year:
        return 'Năm';
      case ReportPeriod.custom:
        return 'Tùy chọn';
    }
  }

  String get apiKey {
    switch (this) {
      case ReportPeriod.week:
        return 'WEEK';
      case ReportPeriod.month:
        return 'MONTH';
      case ReportPeriod.year:
        return 'YEAR';
      case ReportPeriod.custom:
        return 'CUSTOM';
    }
  }
}
