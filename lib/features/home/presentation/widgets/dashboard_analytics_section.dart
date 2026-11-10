import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/domain/models/cash_flow_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'section_header.dart';

/// Section: Báo cáo nhanh – kết nối GET /dashboard/cash-flow.
class DashboardAnalyticsSection extends ConsumerWidget {
  const DashboardAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cashFlowAsync = ref.watch(dashboardCashFlowProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Báo cáo & Xu hướng',
          actionText: 'Xem chi tiết',
          onTap: () => context.push(RoutePaths.analytics),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: cashFlowAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chưa có dữ liệu xu hướng',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ),
            data: (cf) {
              final timeline = cf.timeline;
              final maxVal = timeline.fold<double>(
                1.0,
                (prev, e) => e.income > prev ? e.income : (e.expense > prev ? e.expense : prev),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề nhỏ + Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DIỄN BIẾN THU CHI GẦN ĐÂY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      Row(
                        children: [
                          _Legend(
                            color: AppColors.success,
                            label: 'Thu',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _Legend(
                            color: AppColors.danger,
                            label: 'Chi',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mini bar chart
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(timeline.length, (i) {
                        final item = timeline[i];
                        final inc = item.income;
                        final exp = item.expense;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (inc > 0)
                                  Container(
                                    height: (inc / maxVal * 64).clamp(4.0, 64.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Container(
                                  height: (exp / maxVal * 64).clamp(4.0, 64.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.dateLabel,
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
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stat 3 ô
                  Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          isDark: isDark,
                          label: 'Tổng thu',
                          value: CurrencyFormatter.formatCompact(cf.totalIncome),
                          icon: Icons.trending_up_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          isDark: isDark,
                          label: 'Tổng chi',
                          value: CurrencyFormatter.formatCompact(cf.totalExpense),
                          icon: Icons.trending_down_rounded,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          isDark: isDark,
                          label: 'Thặng dư',
                          value: CurrencyFormatter.formatCompact(cf.netSavings),
                          icon: Icons.savings_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Nút bấm chi tiết 3 loại báo cáo
                  Row(
                    children: [
                      Expanded(
                        child: _ReportButton(
                          isDark: isDark,
                          icon: Icons.bar_chart_rounded,
                          label: 'Dòng tiền',
                          color: const Color(0xFF3B82F6),
                          onTap: () => context.push(RoutePaths.cashflowReport),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ReportButton(
                          isDark: isDark,
                          icon: Icons.pie_chart_rounded,
                          label: 'Cơ cấu 50/30/20',
                          color: const Color(0xFFEC4899),
                          onTap: () => context.push(RoutePaths.categoryReport),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ReportButton(
                          isDark: isDark,
                          icon: Icons.analytics_rounded,
                          label: 'Phân tích',
                          color: const Color(0xFF10B981),
                          onTap: () => context.push(RoutePaths.analytics),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;
  const _Legend({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip({
    required this.isDark,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ReportButton({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
