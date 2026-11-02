import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/budget_enums.dart';
import '../../domain/models/budget_summary.dart';
import 'budget_progress_bar.dart';

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({
    super.key,
    required this.summary,
  });

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = summary.status;
    Color statusColor;
    String statusText;
    switch (status) {
      case BudgetProgressStatus.safe:
        statusColor = AppColors.success;
        statusText = '🟢 An toàn';
        break;
      case BudgetProgressStatus.warning:
        statusColor = AppColors.warning;
        statusText = '🟡 Sắp chạm trần';
        break;
      case BudgetProgressStatus.exceeded:
        statusColor = AppColors.danger;
        statusText = '🔴 Đã vượt hạn mức';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
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
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'TỔNG NGÂN SÁCH ${summary.periodLabel.toUpperCase()}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hạn mức',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(summary.totalLimit),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Đã tiêu',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(summary.totalSpent),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          BudgetProgressBar(percentage: summary.percentage, height: 10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Còn lại: ${currencyFormatter.format(summary.totalRemaining)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: summary.totalRemaining >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
              Text(
                'Tiến độ: ${summary.percentage.toStringAsFixed(1)}% (Còn ${summary.daysRemaining} ngày)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.lightMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

