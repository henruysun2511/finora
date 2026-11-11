import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot_banner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/domain/models/dashboard_overview_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../widgets/dashboard_analytics_section.dart';
import '../widgets/dashboard_budget_section.dart';
import '../widgets/dashboard_loans_section.dart';
import '../widgets/dashboard_recurring_section.dart';
import '../widgets/home_accounts_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_mascot_section.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final overviewAsync = ref.watch(dashboardOverviewProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(dashboardOverviewProvider);
            ref.invalidate(dashboardBudgetHealthProvider);
            ref.invalidate(dashboardCashFlowProvider);
            ref.invalidate(dashboardCategoryBreakdownProvider);
            ref.invalidate(dashboardDebtsProvider);
            ref.invalidate(dashboardCalendarProvider);
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Top Header (Greeting, Full Name, Net Worth Hero Card) ──
                HomeHeader(user: user),

                // ── 2. Body Content ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Mascot AI Insight Banner ────────────────────────
                      overviewAsync.maybeWhen(
                        data: (ov) => MascotBanner(
                          name: 'Nora AI',
                          message:
                              'Tỷ lệ tiết kiệm tháng này đạt ${ov.monthlyCashflow.savingsRate.toStringAsFixed(1)}%, thặng dư ròng +${(ov.monthlyCashflow.netCashflow / 1000000).toStringAsFixed(1)}M ₫!',
                          actionText: 'Xem chi tiết',
                          onAction: () => context.push(RoutePaths.dashboard),
                        ),
                        orElse: () => MascotBanner(
                          name: 'Nora AI',
                          message:
                              'Bạn đã tiết kiệm được 47.6% thu nhập tháng này, vượt mục tiêu 10%!',
                          actionText: 'Xem chi tiết',
                          onAction: () => context.push(RoutePaths.dashboard),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Active Alerts Banner (Cảnh báo khẩn cấp từ API) ──
                      overviewAsync.maybeWhen(
                        data: (ov) {
                          if (ov.activeAlerts.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: ov.activeAlerts.map((alert) {
                              final isCritical = alert.severity == 'HIGH' ||
                                  alert.severity == 'CRITICAL';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: isCritical
                                      ? AppColors.danger.withValues(alpha: 0.1)
                                      : const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCritical
                                        ? AppColors.danger
                                            .withValues(alpha: 0.3)
                                        : const Color(0xFFF59E0B)
                                            .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCritical
                                          ? Icons.error_outline_rounded
                                          : Icons.warning_amber_rounded,
                                      size: 18,
                                      color: isCritical
                                          ? AppColors.danger
                                          : const Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        alert.message,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.darkForeground
                                              : AppColors.lightForeground,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),

                      // ── Thao tác nhanh (16 tiện ích) ───────────────────
                      const QuickActionsGrid(),
                      const SizedBox(height: 22),

                      // ── Tài khoản & Nguồn tiền (GET /dashboard/overview) ─
                      const HomeAccountsSection(),
                      const SizedBox(height: 22),

                      // ── Giao dịch gần đây (GET /dashboard/overview) ────
                      const RecentTransactionsSection(),
                      const SizedBox(height: 22),

                      // ── Ngân sách & Burn-rate (GET /dashboard/budget-health)
                      const DashboardBudgetSection(),
                      const SizedBox(height: 22),

                      // ── Sổ nợ & Nghĩa vụ (GET /dashboard/debts) ────────
                      const DashboardLoansSection(),
                      const SizedBox(height: 22),

                      // ── Báo cáo & Dòng tiền (GET /dashboard/cash-flow) ──
                      const DashboardAnalyticsSection(),
                      const SizedBox(height: 22),

                      // ── Hóa đơn & Định kỳ sắp tới (GET /dashboard/calendar)
                      const DashboardRecurringSection(),
                      const SizedBox(height: 22),

                      // ── Linh vật AI đồng hành ──────────────────────────
                      const HomeMascotSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Alias để tương thích ngược
typedef DashboardScreen = HomeScreen;
