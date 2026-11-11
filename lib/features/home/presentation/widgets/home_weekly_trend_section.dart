import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/dual_bar_chart_widget.dart';
import 'section_header.dart';

/// Card Snapshot: Xu hướng Thu & Chi 7 ngày qua trên Trang chủ
/// Thiết kế theo chuẩn Solarn FinTech từ `static-ui/device-preview/screens/home/dashboard.html`
class HomeWeeklyTrendSection extends ConsumerWidget {
  const HomeWeeklyTrendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cashFlowAsync = ref.watch(dashboardCashFlowProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Xu hướng Thu & Chi',
          actionText: 'Xem phân tích',
          onTap: () => context.push(RoutePaths.dashboard),
        ),
        const SizedBox(height: 12),
        cashFlowAsync.when(
          loading: () => Container(
            height: 180,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (cashFlow) {
            final timeline = cashFlow.timeline;
            if (timeline.isEmpty) return const SizedBox.shrink();

            double totalIncomeWeek = 0;
            double totalExpenseWeek = 0;
            final displayItems = timeline.length > 7
                ? timeline.sublist(timeline.length - 7)
                : timeline;

            for (final item in displayItems) {
              totalIncomeWeek += item.income;
              totalExpenseWeek += item.expense;
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(22),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card với 2 indicator pill Thu / Chi
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '7 NGÀY GẦN NHẤT',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dòng tiền tuần này',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                          ],
                        ),
                        // Indicator Pills
                        Row(
                          children: [
                            _IndicatorPill(
                              label: 'Thu',
                              value: CurrencyFormatter.formatCompact(
                                  totalIncomeWeek),
                              color: AppColors.primary,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 6),
                            _IndicatorPill(
                              label: 'Chi',
                              value: CurrencyFormatter.formatCompact(
                                  totalExpenseWeek),
                              color: const Color(0xFFF97316),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Biểu đồ cột đôi tương tác
                  DualBarChartWidget(
                    timeline: displayItems,
                    isDark: isDark,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _IndicatorPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _IndicatorPill({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$label $value',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

