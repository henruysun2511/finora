class ReportValidators {
  ReportValidators._();

  static String? validateCustomDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc';
    }
    if (end.isBefore(start)) {
      return 'Ngày kết thúc không được trước ngày bắt đầu';
    }
    final differenceDays = end.difference(start).inDays;
    if (differenceDays > 366) {
      return 'Khoảng thời gian báo cáo tối đa không quá 366 ngày';
    }
    return null;
  }

  static String? validateTargetDate(DateTime? date) {
    if (date == null) {
      return 'Vui lòng chọn thời điểm báo cáo';
    }
    final now = DateTime.now();
    if (date.year > now.year + 5) {
      return 'Năm báo cáo không hợp lệ';
    }
    return null;
  }
}
