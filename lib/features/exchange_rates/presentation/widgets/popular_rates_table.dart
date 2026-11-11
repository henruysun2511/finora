import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../domain/models/currency_item.dart';
import '../../domain/models/exchange_rate.dart';
import '../providers/currency_converter_provider.dart';
import '../providers/popular_rates_provider.dart';

class PopularRatesTable extends ConsumerWidget {
  const PopularRatesTable({super.key});

  String _formatRate(double rate) {
    if (rate >= 100) {
      return NumberFormat('#,##0.##', 'vi_VN').format(rate);
    } else {
      return NumberFormat('#,##0.####', 'vi_VN').format(rate);
    }
  }

  Widget _buildRateItem({
    required BuildContext context,
    required WidgetRef ref,
    required ExchangeRate rate,
    required Color foreground,
    required Color muted,
  }) {
    final currencyItem = CurrencyItem.findByCode(rate.from);
    final change = rate.changePercentage ?? 0.0;
    final isPositive = change >= 0;

    return InkWell(
      onTap: () {
        ref
            .read(currencyConverterProvider.notifier)
            .selectPair(rate.from, 'VND');
        AppToast.show(
          context,
          message: 'Đã chọn cặp ${rate.from}/VND vào bộ quy đổi',
          type: ToastType.info,
          duration: const Duration(seconds: 1),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Flag & Pair Code
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Text(
                    currencyItem.flagEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rate.from} / VND',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      Text(
                        currencyItem.name,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rate Value
            Expanded(
              flex: 4,
              child: Text(
                '₫ ${_formatRate(rate.rate)}',
                textAlign: TextAlign.right,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ),

            // Change % Badge
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(popularRatesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return FormCard(
      title: 'Bảng tỷ giá ngoại tệ hôm nay (so với VND)',
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'CẶP TIỀN TỆ',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'TỶ GIÁ',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'BIẾN ĐỘNG',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Rates Content
          ratesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    'Không thể tải bảng tỷ giá ngoại tệ.',
                    style: GoogleFonts.inter(fontSize: 13, color: muted),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(popularRatesProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
            data: (rates) {
              if (rates.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Chưa có dữ liệu tỷ giá',
                      style: GoogleFonts.inter(fontSize: 13, color: muted),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < rates.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        color: border.withValues(alpha: 0.4),
                      ),
                    _buildRateItem(
                      context: context,
                      ref: ref,
                      rate: rates[i],
                      foreground: foreground,
                      muted: muted,
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
