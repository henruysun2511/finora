import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/dashboard_data.dart';
import '../widgets/accounts_scroll.dart';
import '../widgets/balance_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Home Header & Balance Card Container
                Container(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: const Column(
                    children: [
                      DashboardHeader(),
                      SizedBox(height: 18),
                      BalanceCard(),
                    ],
                  ),
                ),

                // 2. Body sections
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section: Tài khoản
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                        child: _SectionHeader(
                          title: 'Tài khoản',
                          actionText: 'Xem tất cả',
                          onActionTap: () => context.push(RoutePaths.wallets),
                        ),
                      ),
                      AccountsScroll(
                        onAccountSelected: (account) {
                          // Có thể cập nhật filter hoặc xem chi tiết
                        },
                      ),

                      // Section: Thao tác nhanh
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: const _SectionHeader(
                          title: 'Thao tác nhanh',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: QuickActionsGrid(
                          onActionTap: (action) {
                            switch (action.type) {
                              case QuickActionType.incomeExpense:
                                context.go(RoutePaths.transactions);
                                break;
                              case QuickActionType.transfer:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Chức năng chuyển tiền')),
                                );
                                break;
                              case QuickActionType.report:
                                context.go(RoutePaths.analytics);
                                break;
                              case QuickActionType.budget:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Quản lý ngân sách')),
                                );
                                break;
                            }
                          },
                        ),
                      ),

                      // Section: Giao dịch gần đây
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                        child: _SectionHeader(
                          title: 'Giao dịch gần đây',
                          actionText: 'Tất cả',
                          onActionTap: () => context.go(RoutePaths.transactions),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RecentTransactionsList(
                          onTransactionTap: (tx) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Chi tiết: ${tx.title}')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
