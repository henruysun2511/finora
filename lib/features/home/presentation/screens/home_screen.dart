import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../../core/widgets/mascot_banner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/domain/models/dashboard_overview_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../mascot/domain/models/current_mascot.dart';
import '../../../mascot/presentation/providers/current_mascot_provider.dart';
import '../../../mascot/presentation/widgets/mascot_level_up_dialog.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../widgets/home_accounts_section.dart';
import '../widgets/home_budget_health_card.dart';
import '../widgets/home_category_breakdown_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_mascot_section.dart';
import '../widgets/home_photo_calendar_section.dart';
import '../widgets/home_weekly_trend_section.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final overviewAsync = ref.watch(dashboardOverviewProvider);

    // Lắng nghe sự kiện thăng hạng Linh vật AI tự động
    ref.listen<AsyncValue<CurrentMascot>>(currentMascotProvider, (prev, next) {
      final cur = next.valueOrNull;
      if (cur == null) return;

      final storage = ref.read(localStorageProvider);
      final lastSeen = storage.getLastSeenMascotTier();

      if (lastSeen == null) {
        // Lần đầu ghi nhận mốc linh vật hiện tại
        storage.setLastSeenMascotTier(cur.mascot.tierName);
      } else if (lastSeen.toLowerCase() != cur.mascot.tierName.toLowerCase()) {
        final lastTierData = MascotRegistry.get(lastSeen);
        final curTierData = MascotRegistry.get(cur.mascot.tierName);

        // Chỉ chúc mừng khi thăng hạng (min net worth cao hơn)
        if (curTierData.min > lastTierData.min) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              MascotLevelUpDialog.show(
                context,
                tierName: cur.mascot.tierName,
                previousTierName: lastSeen,
                netWorth: cur.netWorth,
              );
            }
          });
        }
        storage.setLastSeenMascotTier(cur.mascot.tierName);
      }
    });

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
            ref.invalidate(walletsOverviewProvider);

            // Kiểm tra và đồng bộ tiến hóa linh vật từ backend
            final evolution =
                await ref.read(currentMascotProvider.notifier).syncEvolution();
            if (evolution != null &&
                evolution.evolved &&
                (evolution.isLevelUp ?? true)) {
              if (context.mounted) {
                MascotLevelUpDialog.show(
                  context,
                  tierName: evolution.currentMascot.tierName,
                  previousTierName: evolution.previousMascot?.tierName,
                  customMessage: evolution.message,
                  netWorth: evolution.netWorth,
                );
              }
            }

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

                      // ── Lịch ảnh chi tiêu (Photo Expense Calendar) ───────
                      const HomePhotoCalendarSection(),
                      const SizedBox(height: 22),

                      // ── Snapshot Xu hướng Thu & Chi 7 ngày qua ──────────
                      const HomeWeeklyTrendSection(),
                      const SizedBox(height: 22),

                      // ── Cơ cấu Chi tiêu (Donut + Category Breakdown) ───
                      const HomeCategoryBreakdownCard(),
                      const SizedBox(height: 22),

                      // ── Tiến độ Ngân sách & Sức khỏe Dòng tiền ──────────
                      const HomeBudgetHealthCard(),
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
