import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  /// Format số tiền chuẩn phong cách `ui-sample-3`:
  /// `formatVnd(24850000)` -> `₫ 24,850,000`
  static String formatVnd(num amount, {bool includeSymbol = true}) {
    final formatted = _formatter.format(amount.abs());
    final prefix = amount < 0 ? '-₫ ' : (includeSymbol ? '₫ ' : '');
    return '$prefix$formatted';
  }

  /// Format biến động số dư (+₫ 15,000,000 hoặc -₫ 8,320,000)
  static String formatDelta(num amount) {
    final formatted = _formatter.format(amount.abs());
    final sign = amount >= 0 ? '+₫ ' : '-₫ ';
    return '$sign$formatted';
  }
}
