import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/report_overview_data.dart';

class ReportStatGrid extends StatelessWidget {
  final ReportStatMetrics metrics;
  final String currency;

  const ReportStatGrid({
    super.key,
    required this.metrics,
    this.currency = 'VND',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final incomeChangeText = metrics.momIncomeChange >= 0
        ? '🟢 Tăng ${metrics.momIncomeChange.abs().toStringAsFixed(1)}% ${metrics.comparePeriodLabel}'
        : '🔴 Giảm ${metrics.momIncomeChange.abs().toStringAsFixed(1)}% ${metrics.comparePeriodLabel}';

    final expenseChangeText = metrics.momExpenseChange <= 0
        ? '🟢 Giảm ${metrics.momExpenseChange.abs().toStringAsFixed(1)}% ${metrics.comparePeriodLabel}'
        : '🔴 Tăng ${metrics.momExpenseChange.abs().toStringAsFixed(1)}% ${metrics.comparePeriodLabel}';

    final surplusBadgeText = metrics.netSavings >= 0
        ? (metrics.isSavingsRateExceeded ? '⭐ Vượt chỉ tiêu tháng' : '🟢 Dòng tiền dương')
        : '⚠️ Thâm hụt ngân sách';

    final savingsRateTargetText = 'Mục tiêu: ${metrics.targetSavingsRate.toStringAsFixed(1)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'TỔNG THU NHẬP',
                  amountText: CurrencyFormatter.format(metrics.totalIncome),
                  badgeText: incomeChangeText,
                  badgeColor: metrics.momIncomeChange >= 0 ? AppColors.success : AppColors.danger,
                  isDark: isDark,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'TỔNG CHI TIÊU',
                  amountText: CurrencyFormatter.format(metrics.totalExpense),
                  badgeText: expenseChangeText,
                  badgeColor: metrics.momExpenseChange <= 0 ? AppColors.success : AppColors.danger,
                  isDark: isDark,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'THẶNG DƯ RÒNG',
                  amountText: '${metrics.netSavings >= 0 ? "+" : ""}${CurrencyFormatter.format(metrics.netSavings)}',
                  badgeText: surplusBadgeText,
                  badgeColor: metrics.netSavings >= 0 ? const Color(0xFFF59E0B) : AppColors.danger,
                  isDark: isDark,
                  icon: Icons.savings_outlined,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'TỶ LỆ TÍCH LŨY',
                  amountText: '${metrics.savingsRate.toStringAsFixed(1)}%',
                  badgeText: savingsRateTargetText,
                  badgeColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  isDark: isDark,
                  icon: Icons.pie_chart_outline_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String amountText;
  final String badgeText;
  final Color badgeColor;
  final bool isDark;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.amountText,
    required this.badgeText,
    required this.badgeColor,
    required this.isDark,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amountText,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            badgeText,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
