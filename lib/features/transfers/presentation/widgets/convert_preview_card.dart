import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/form_card.dart';
import '../../domain/models/convert_preview.dart';

class ConvertPreviewCard extends StatelessWidget {
  final ConvertPreview? preview;
  final bool isLoading;

  const ConvertPreviewCard({
    super.key,
    required this.preview,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return FormCard(
        title: 'TỶ GIÁ QUY ĐỔI',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Flexible(
                  child: Text(
                'Đang cập nhật tỷ giá thực...',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ),
      );
    }

    if (preview == null) return const SizedBox.shrink();

    final prev = preview!;
    Color badgeColor;
    String badgeText;
    switch (prev.rateSource.toLowerCase()) {
      case 'live':
        badgeColor = AppColors.success;
        badgeText = 'Tỷ giá Live';
        break;
      case 'cache':
        badgeColor = const Color(0xFFF59E0B);
        badgeText = 'Bộ nhớ đệm';
        break;
      default:
        badgeColor = AppColors.primary;
        badgeText = 'Ước tính';
        break;
    }

    return FormCard(
      title: 'TỶ GIÁ QUY ĐỔI TIỀN TỆ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                        child: Text(
                      badgeText,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
              Text(
                '1 ${prev.fromCurrency} ≈ ${CurrencyFormatter.format(prev.exchangeRate, currency: prev.toCurrency)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Dự kiến tài khoản đích nhận:',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.format(
                    prev.toAmount,
                    currency: prev.toCurrency,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
