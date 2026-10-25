import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot_banner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/home_accounts_section.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Top Header (Greeting, Full Name, Balance Hero Card) ──
                HomeHeader(user: user),

                // ── 2. Body Content ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mascot AI Insight Banner
                      MascotBanner(
                        name: 'Nora AI',
                        message:
                            'Bạn đã tiết kiệm được 44.5% thu nhập tháng này, vượt mục tiêu 10%!',
                        actionText: 'Xem chi tiết',
                        onAction: () => context.go(RoutePaths.analytics),
                      ),
                      const SizedBox(height: 20),

                      // Section: Thao tác nhanh (16 tiện ích)
                      const QuickActionsGrid(),
                      const SizedBox(height: 22),

                      // Section: Tài khoản
                      const HomeAccountsSection(),
                      const SizedBox(height: 22),

                      // Section: Giao dịch gần đây
                      const RecentTransactionsSection(),
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
