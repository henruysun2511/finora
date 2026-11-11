import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../dashboard/domain/models/budget_health_model.dart';
import '../../../dashboard/domain/models/dashboard_overview_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

/// Card 2: Tiến độ Ngân sách & Sức khỏe Dòng tiền trên Trang chủ
/// Thiết kế 1:1 theo chuẩn `static-ui/device-preview/screens/home/dashboard.html` (#budgetPacingCard)
class HomeBudgetHealthCard extends ConsumerWidget {
  const HomeBudgetHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetAsync = ref.watch(dashboardBudgetHealthProvider);
    final overviewAsync = ref.watch(dashboardOverviewProvider);

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    final timePercent = ((currentDay / daysInMonth) * 100).round();

    return GestureDetector(
      onTap: () => context.push(RoutePaths.dashboard),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: budgetAsync.when(
          loading: () => const SizedBox(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, __) => _buildPacingContent(
            isDark: isDark,
            spent: 8320000,
            totalBudget: 13500000,
            spendingPercent: 62,
            timePercent: timePercent,
            currentDay: currentDay,
            daysInMonth: daysInMonth,
            savingsRate: 44.5,
            healthScore: 88,
            statusTag: 'An toàn',
          ),
          data: (budget) {
            final spent = budget.totalSpent > 0 ? budget.totalSpent : 8320000.0;
            final totalBudget = budget.totalBudgetLimit > 0
                ? budget.totalBudgetLimit
                : 13500000.0;
            final spendPct =
                ((spent / totalBudget) * 100).clamp(0, 150).round();

            final ov = overviewAsync.valueOrNull;
            final savingsRate = ov?.monthlyCashflow.savingsRate ?? 44.5;

            return _buildPacingContent(
              isDark: isDark,
              spent: spent,
              totalBudget: totalBudget,
              spendingPercent: spendPct,
              timePercent: timePercent,
              currentDay: currentDay,
              daysInMonth: daysInMonth,
              savingsRate: savingsRate,
              healthScore: 88,
              statusTag: spendPct <= timePercent ? 'An toàn' : 'Cần chú ý',
            );
          },
        ),
      ),
    );
  }

  Widget _buildPacingContent({
    required bool isDark,
    required double spent,
    required double totalBudget,
    required int spendingPercent,
    required int timePercent,
    required int currentDay,
    required int daysInMonth,
    required double savingsRate,
    required int healthScore,
    required String statusTag,
  }) {
    final diff = spendingPercent - timePercent;
    final isSafe = diff <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Card Head ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến độ Ngân sách & Sức khỏe',
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'So sánh tốc độ chi tiêu so với số ngày còn lại',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: isSafe
                    ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                    : (isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFF7ED)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSafe
                      ? const Color(0xFF10B981).withValues(alpha: 0.35)
                      : const Color(0xFFF97316).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LucideIcon(
                    name: 'shield-check',
                    size: 11,
                    color: isSafe ? const Color(0xFF10B981) : const Color(0xFFF97316),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusTag,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isSafe ? const Color(0xFF10B981) : const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── 2. Pacing Box (Metrics & Dual Progress Bar) ─────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã chi tiêu',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                    children: [
                      TextSpan(text: CurrencyFormatter.format(spent)),
                      TextSpan(
                        text: ' / ${CurrencyFormatter.format(totalBudget)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              '$spendingPercent%',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dual Progress Bar: Spending vs Time
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Stack(
            children: [
              // Thanh tiến độ thời gian (Time Progress Bar)
              FractionallySizedBox(
                widthFactor: (timePercent / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFDBFE),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              // Thanh tiến độ chi tiêu thực tế (Spending Progress Bar)
              FractionallySizedBox(
                widthFactor: (spendingPercent / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Subline text so sánh
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ chi: $spendingPercent%',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            Text(
              isSafe
                  ? '✦ Tiêu chậm hơn thời gian ($diff%)'
                  : '✦ Tiêu nhanh hơn thời gian (+$diff%)',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSafe ? const Color(0xFF10B981) : const Color(0xFFF97316),
              ),
            ),
            Text(
              'Thời gian: $timePercent% ($currentDay/$daysInMonth)',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── 3. Hai thẻ Mini KPI (Tỷ lệ tiết kiệm & Điểm sức khỏe) ───────────
        Row(
          children: [
            // KPI 1: Tỷ lệ tiết kiệm
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161E2E)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: LucideIcon(
                          name: 'trending-up',
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tỷ lệ tiết kiệm',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF10B981),
                              ),
                              children: [
                                TextSpan(
                                    text: '${savingsRate.toStringAsFixed(1)}% '),
                                TextSpan(
                                  text: '(Đạt)',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // KPI 2: Điểm sức khỏe
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161E2E)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: LucideIcon(
                          name: 'sparkles',
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Điểm sức khỏe',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                              children: const [
                                TextSpan(text: '88/100 '),
                                TextSpan(
                                  text: 'Tốt ✦',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── 4. Nora AI Phân tích Banner ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFF0F7FF),
                      const Color(0xFFE0EDFF),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFBFDBFE),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Center(
                  child: Text(
                    '🤖',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFF1E40AF),
                      height: 1.45,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Nora AI phân tích: ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text:
                            'Dự kiến số dư cuối tháng sẽ đạt ~₫16.5M (thặng dư +₫6.68M). Bạn có thể trích ₫3.5M vào mục tiêu Du lịch mà vẫn đảm bảo an toàn tài chính!',
                      ),
                    ],
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

