import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/currency_item.dart';
import '../providers/currency_converter_provider.dart';
import 'currency_picker_bottom_sheet.dart';
import 'swap_currency_button.dart';

class CurrencyConverterCard extends ConsumerStatefulWidget {
  const CurrencyConverterCard({super.key});

  @override
  ConsumerState<CurrencyConverterCard> createState() =>
      _CurrencyConverterCardState();
}

class _CurrencyConverterCardState extends ConsumerState<CurrencyConverterCard> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final initialAmount = ref.read(currencyConverterProvider).amount;
    _amountController = TextEditingController(
      text: initialAmount == initialAmount.roundToDouble()
          ? initialAmount.toInt().toString()
          : initialAmount.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    // Cho phép nhập số thập phân dấu phẩy hoặc chấm
    final clean = val.replaceAll(',', '.').trim();
    final numVal = double.tryParse(clean) ?? 0.0;
    ref.read(currencyConverterProvider.notifier).setAmount(numVal);
  }

  Future<void> _pickCurrency({
    required bool isFrom,
    required String currentCode,
  }) async {
    final picked = await CurrencyPickerBottomSheet.show(
      context: context,
      selectedCode: currentCode,
      title: isFrom ? 'Chọn đồng tiền nguồn' : 'Chọn đồng tiền đích',
    );

    if (picked != null) {
      if (isFrom) {
        ref.read(currencyConverterProvider.notifier).setFromCurrency(picked);
      } else {
        ref.read(currencyConverterProvider.notifier).setToCurrency(picked);
      }
    }
  }

  String _formatRate(double rate) {
    if (rate >= 100) {
      return NumberFormat('#,##0.##', 'vi_VN').format(rate);
    } else if (rate >= 1) {
      return NumberFormat('#,##0.####', 'vi_VN').format(rate);
    } else {
      return NumberFormat('0.000000', 'vi_VN').format(rate);
    }
  }

  String _formatConverted(double amount, String currencyCode) {
    if (currencyCode == 'VND' || currencyCode == 'KRW' || currencyCode == 'JPY') {
      return NumberFormat('#,###', 'vi_VN').format(amount.round());
    }
    return NumberFormat('#,##0.00', 'vi_VN').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      currencyConverterProvider.select((s) => s.amount),
      (_, nextAmount) {
        final textVal =
            double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
        if ((textVal - nextAmount).abs() > 0.0001) {
          _amountController.text = nextAmount == nextAmount.roundToDouble()
              ? nextAmount.toInt().toString()
              : nextAmount.toString();
        }
      },
    );

    final state = ref.watch(currencyConverterProvider);
    final notifier = ref.read(currencyConverterProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── KHỐI TIỀN NGUỒN ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'BẠN CHUYỂN ĐỔI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (state.isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Currency Selector Button
              InkWell(
                onTap: () => _pickCurrency(
                  isFrom: true,
                  currentCode: state.fromCurrency.code,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.fromCurrency.flagEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${state.fromCurrency.code} - ${state.fromCurrency.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: muted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Input Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.fromCurrency.symbol,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: muted.withValues(alpha: 0.4),
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: _onAmountChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── NÚT ĐẢO CHIỀU SWAP ──
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SwapCurrencyButton(
            onTap: notifier.swapCurrencies,
          ),
        ),

        // ── KHỐI TIỀN ĐÍCH ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUY ĐỔI THÀNH',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Currency Selector Button
              InkWell(
                onTap: () => _pickCurrency(
                  isFrom: false,
                  currentCode: state.toCurrency.code,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.toCurrency.flagEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${state.toCurrency.code} - ${state.toCurrency.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: muted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Converted Amount Display
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.toCurrency.symbol,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatConverted(
                        state.convertedAmount,
                        state.toCurrency.code,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.toCurrency.code,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── DÒNG TỶ GIÁ THAM CHIẾU ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tỷ giá tham chiếu: 1 ${state.fromCurrency.code} = ${_formatRate(state.currentRate)} ${state.toCurrency.code}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (state.isEstimated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Ước tính',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

