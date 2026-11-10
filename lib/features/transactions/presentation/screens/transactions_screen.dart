import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/banner_header.dart';
import '../providers/transaction_list_provider.dart';
import '../widgets/daily_transaction_group_card.dart';
import '../widgets/transactions_banner_hero.dart';
import '../widgets/transactions_empty_state.dart';
import '../widgets/transactions_month_navigator.dart';

/// Màn hình Sổ giao dịch với Hero Banner chuẩn FinTech (`BannerHeader`)
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(transactionPeriodProvider);
    final gridAsync = ref.watch(dailyGridProvider);
    final notifier = ref.read(dailyGridProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final monthTitle = 'Tháng ${period.month}, ${period.year}';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ── 1. BANNER HEADER MÀU MIDNIGHT SAPPHIRE ──
          BannerHeader(
            title: 'Sổ giao dịch',
            centerTitle: true,
            showBackButton: true,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.home);
              }
            },
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F172A), // Slate Navy đậm
                Color(0xFF1E293B), // Midnight Blue
                Color(0xFF1E3A8A), // Deep Royal Navy
              ],
              stops: [0.0, 0.45, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            action: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(RoutePaths.createTransaction),
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            child: gridAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Không tải được thống kê tháng này',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Thử lại',
                      onPressed: notifier.refresh,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              data: (summary) => TransactionsBannerHero(summary: summary),
            ),
          ),

          // ── 2. BỘ ĐIỀU HƯỚNG THÁNG (ĐẶT DƯỚI BANNER) ──
          TransactionsMonthNavigator(
            monthTitle: monthTitle,
            onPrevious: notifier.previousMonth,
            onNext: notifier.nextMonth,
          ),

          // ── 3. DANH SÁCH GIAO DỊCH THEO NGÀY ──
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: notifier.refresh,
              child: gridAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Không thể tải sổ giao dịch: $err',
                        style: GoogleFonts.inter(fontSize: 13, color: muted),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: notifier.refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
                data: (summary) {
                  if (summary.days.isEmpty) {
                    return TransactionsEmptyState(
                      monthTitle: monthTitle,
                      onCreate: () => context.push(RoutePaths.createTransaction),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: summary.days.length,
                    itemBuilder: (context, index) {
                      final group = summary.days[index];
                      return DailyTransactionGroupCard(
                        group: group,
                        onTransactionTap: (tx) {
                          context.push(
                            RoutePaths.transactionDetail
                                .replaceFirst(':id', tx.id),
                            extra: tx,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
