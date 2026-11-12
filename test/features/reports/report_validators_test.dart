import 'package:finora_mb/features/reports/domain/validators/report_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportValidators - validateCustomDateRange', () {
    test('trả về lỗi khi ngày bắt đầu hoặc ngày kết thúc null', () {
      expect(
        ReportValidators.validateCustomDateRange(null, DateTime.now()),
        'Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc',
      );
      expect(
        ReportValidators.validateCustomDateRange(DateTime.now(), null),
        'Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc',
      );
    });

    test('trả về lỗi khi ngày kết thúc trước ngày bắt đầu', () {
      final start = DateTime(2026, 10, 15);
      final end = DateTime(2026, 10, 10);
      expect(
        ReportValidators.validateCustomDateRange(start, end),
        'Ngày kết thúc không được trước ngày bắt đầu',
      );
    });

    test('trả về lỗi khi khoảng thời gian vượt quá 366 ngày', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2026, 2, 1);
      expect(
        ReportValidators.validateCustomDateRange(start, end),
        'Khoảng thời gian báo cáo tối đa không quá 366 ngày',
      );
    });

    test('hợp lệ khi khoảng thời gian đúng quy định', () {
      final start = DateTime(2026, 10, 1);
      final end = DateTime(2026, 10, 31);
      expect(ReportValidators.validateCustomDateRange(start, end), isNull);
    });
  });

  group('ReportValidators - validateTargetDate', () {
    test('trả về lỗi khi date null', () {
      expect(
        ReportValidators.validateTargetDate(null),
        'Vui lòng chọn thời điểm báo cáo',
      );
    });

    test('hợp lệ khi date nằm trong phạm vi hợp lý', () {
      final now = DateTime.now();
      expect(ReportValidators.validateTargetDate(now), isNull);
    });
  });
}
