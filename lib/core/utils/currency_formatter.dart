import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  /// Mã tiền tệ mặc định toàn cục của ứng dụng (được đồng bộ từ GeneralSettings)
  static String defaultCurrency = 'VND';

  /// Lấy ký hiệu tiền tệ từ mã chuẩn ISO 4217 (VND -> ₫, USD -> $, EUR -> €, ...)
  static String symbolFor(String? currencyCode) {
    final code = (currencyCode == null || currencyCode.isEmpty) ? defaultCurrency : currencyCode;
    switch (code.toUpperCase()) {
      case 'VND':
        return '₫';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'SGD':
        return r'S$';
      case 'GBP':
        return '£';
      case 'THB':
        return '฿';
      default:
        return code;
    }
  }

  /// Format số tiền chuẩn:
  /// `format(24850000)` -> `24.850.000 ₫`
  /// `format(100, currency: 'USD')` -> `100 $`
  static String format(num amount, {String? symbol, String? currency}) {
    final sym = symbol ?? symbolFor(currency);
    final formatted = _formatter.format(amount);
    return '$formatted $sym';
  }

  /// Format số tiền:
  /// `formatCurrency(24850000, currency: 'USD')` -> `24.850.000 $`
  /// `formatCurrency(-50000, currency: 'VND')` -> `-50.000 ₫`
  static String formatCurrency(num amount, {String? currency, bool includeSymbol = true}) {
    final formatted = _formatter.format(amount.abs());
    final sym = symbolFor(currency);
    final sign = amount < 0 ? '-' : '';
    if (!includeSymbol) return '$sign$formatted';
    return '$sign$formatted $sym';
  }

  /// Format số tiền chuẩn phong cách `ui-sample-3`:
  /// `formatVnd(24850000)` -> `₫ 24,850,000`
  static String formatVnd(num amount, {bool includeSymbol = true}) {
    final formatted = _formatter.format(amount.abs());
    final prefix = amount < 0 ? '-₫ ' : (includeSymbol ? '₫ ' : '');
    return '$prefix$formatted';
  }

  /// Format biến động số dư (+15,000,000 ₫ hoặc -8,320,000 ₫)
  static String formatDelta(num amount, {String? currency}) {
    final formatted = _formatter.format(amount.abs());
    final sym = symbolFor(currency);
    final sign = amount >= 0 ? '+' : '-';
    return '$sign$formatted $sym';
  }

  /// Format rút gọn cho badge và thẻ:
  /// `formatCompact(35000000)` -> `35M ₫`
  /// `formatCompact(500000, currency: 'USD')` -> `500k $`
  static String formatCompact(num amount, {String? symbol, String? currency}) {
    final sym = symbol ?? symbolFor(currency);
    final abs = amount.abs();
    if (abs >= 1000000000) {
      final b = amount / 1000000000;
      return '${b.toStringAsFixed(b.truncateToDouble() == b ? 0 : 1)}B $sym';
    }
    if (abs >= 1000000) {
      final m = amount / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M $sym';
    }
    if (abs >= 1000) {
      final k = amount / 1000;
      return '${k.toStringAsFixed(0)}k $sym';
    }
    return '$amount $sym';
  }
}
