import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/domain/models/budget_health_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'section_header.dart';

/// Section: Ngân sách tháng này – hiển thị dữ liệu từ GET /dashboard/budget-health.
class DashboardBudgetSection extends ConsumerWidget {
  const DashboardBudgetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetHealthAsync = ref.watch(dashboardBudgetHealthProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Ngân sách tháng này',
          actionText: 'Xem tất cả',
          onTap: () => context.go(RoutePaths.budgets),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: budgetHealthAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chưa có dữ liệu ngân sách',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ),
            data: (health) {
              final budgets = health.categoryBudgets;
              final br = health.burnRateMetrics;

              return Column(
                children: [
                  // Burn rate mini banner
                  if (br.willOverspend)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tốc độ tiêu ${CurrencyFormatter.formatCompact(br.actualDailyBurnRate)}/ngày - dự báo vượt chi',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Danh sách từng ngân sách
                  ...List.generate(budgets.length, (index) {
                    final item = budgets[index];
                    final isLast = index == budgets.length - 1;

                    Color stColor = AppColors.success;
                    if (item.colorStatus == 'ORANGE') stColor = const Color(0xFFF97316);
                    if (item.colorStatus == 'RED') stColor = AppColors.danger;

                    final pct = (item.spentPercentage / 100.0).clamp(0.0, 1.0);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: stColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(item.icon,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.categoryName,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.darkForeground
                                                : AppColors.lightForeground,
                                          ),
                                        ),
                                        Text(
                                          '${item.spentPercentage.toStringAsFixed(0)}%',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w900,
                                            color: stColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkBorder
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: pct,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(99),
                                            color: stColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${CurrencyFormatter.formatCompact(item.spentAmount)} / ${CurrencyFormatter.formatCompact(item.limitAmount)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
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
                        if (!isLast)
                          Divider(
                            height: 1,
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                      ],
                    );
                  }),

                  // Xem tất cả nút
                  InkWell(
                    onTap: () => context.go(RoutePaths.budgets),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(22),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        'Xem tất cả ngân sách chi tiết →',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
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
