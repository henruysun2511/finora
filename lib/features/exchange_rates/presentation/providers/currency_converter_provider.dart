import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/currency_item.dart';
import 'currency_converter_state.dart';
import 'exchange_rate_providers.dart';

final currencyConverterProvider =
    StateNotifierProvider<CurrencyConverterNotifier, CurrencyConverterState>(
        (ref) {
  return CurrencyConverterNotifier(ref);
});

class CurrencyConverterNotifier extends StateNotifier<CurrencyConverterState> {
  CurrencyConverterNotifier(this._ref) : super(CurrencyConverterState.initial()) {
    // Tải tỷ giá khởi tạo
    _calculateConversion();
  }

  final Ref _ref;
  Timer? _debounceTimer;

  void setAmount(double amount) {
    if (amount < 0) amount = 0;
    state = state.copyWith(amount: amount);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _calculateConversion();
    });
  }

  void setFromCurrency(CurrencyItem currency) {
    if (currency == state.fromCurrency) return;
    state = state.copyWith(fromCurrency: currency);
    _calculateConversion();
  }

  void setToCurrency(CurrencyItem currency) {
    if (currency == state.toCurrency) return;
    state = state.copyWith(toCurrency: currency);
    _calculateConversion();
  }

  /// Đảo chiều 2 đồng tiền
  void swapCurrencies() {
    final oldFrom = state.fromCurrency;
    final oldTo = state.toCurrency;
    final oldRate = state.currentRate;
    final oldInverse = state.inverseRate;

    // Cập nhật tức thì bằng inverseRate để không bị lag giao diện
    final immediateConverted = oldRate != 0 ? state.amount * oldInverse : 0.0;

    state = state.copyWith(
      fromCurrency: oldTo,
      toCurrency: oldFrom,
      currentRate: oldInverse,
      inverseRate: oldRate,
      convertedAmount: double.parse(immediateConverted.toStringAsFixed(2)),
    );

    _calculateConversion();
  }

  /// Chọn nhanh cặp tiền từ bảng tỷ giá hôm nay
  void selectPair(String fromCode, String toCode) {
    final from = CurrencyItem.findByCode(fromCode);
    final to = CurrencyItem.findByCode(toCode);
    state = state.copyWith(fromCurrency: from, toCurrency: to);
    _calculateConversion();
  }

  Future<void> recalculate() => _calculateConversion();

  Future<void> _calculateConversion() async {
    final repo = _ref.read(exchangeRateRepositoryProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await repo.convertCurrency(
        from: state.fromCurrency.code,
        to: state.toCurrency.code,
        amount: state.amount,
      );

      if (!mounted) return;
      state = state.copyWith(
        amount: result.amount,
        convertedAmount: result.convertedAmount,
        currentRate: result.rate,
        inverseRate: result.inverseRate,
        updatedAt: result.updatedAt,
        source: result.source,
        isEstimated: result.isEstimated,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể cập nhật tỷ giá trực tuyến. Đang dùng tỷ giá tham chiếu.',
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

