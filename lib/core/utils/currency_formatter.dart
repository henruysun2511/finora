import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  /// Format số tiền chuẩn:
  /// `format(24850000)` -> `24.850.000 ₫`
  static String format(num amount, {String symbol = '₫'}) {
    final formatted = _formatter.format(amount);
    return '$formatted $symbol';
  }

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

  /// Format rút gọn cho badge và thẻ:
  /// `formatCompact(35000000)` -> `35M ₫`
  /// `formatCompact(500000)` -> `500k ₫`
  static String formatCompact(num amount, {String symbol = '₫'}) {
    final abs = amount.abs();
    if (abs >= 1000000000) {
      final b = amount / 1000000000;
      return '${b.toStringAsFixed(b.truncateToDouble() == b ? 0 : 1)}B $symbol';
    }
    if (abs >= 1000000) {
      final m = amount / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M $symbol';
    }
    if (abs >= 1000) {
      final k = amount / 1000;
      return '${k.toStringAsFixed(0)}k $symbol';
    }
    return '$amount $symbol';
  }
}
