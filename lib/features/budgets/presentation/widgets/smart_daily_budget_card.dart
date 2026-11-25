import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/budget.dart';

class SmartDailyBudgetCard extends StatelessWidget {
  const SmartDailyBudgetCard({
    super.key,
    required this.budget,
    this.customDailyAmount,
  });

  final Budget budget;
  final double? customDailyAmount;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final days = budget.daysRemaining;
    final dailyAmount = customDailyAmount ?? budget.dailyBudgetRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TRỢ LÝ THÔNG MINH (SMART DAILY BUDGET)',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (days > 0 && dailyAmount > 0)
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
                children: [
                  const TextSpan(text: 'Trong '),
                  TextSpan(
                    text: '$days ngày còn lại',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' của kỳ này, mỗi ngày bạn chỉ nên tiêu tối đa:\n'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '👉 ${currencyFormatter.format(dailyAmount)} / ngày',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '\nđể kết thúc chu kỳ mà vẫn đạt mục tiêu tiết kiệm!'),
                ],
              ),
            )
          else if (budget.remainingAmount <= 0)
            Text(
              '🚨 Bạn đã hết ngân sách hoặc bị bội chi trong chu kỳ này! Hãy kiểm soát các khoản phát sinh để tránh thâm hụt vào kỳ sau.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.danger,
                height: 1.4,
              ),
            )
          else
            Text(
              'Chu kỳ ngân sách này đã kết thúc hôm nay. Hãy sẵn sàng cho chu kỳ mới!',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.lightMuted,
              ),
            ),
        ],
      ),
    );
  }
}

