import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/budget_filter_provider.dart';
import '../providers/budget_list_provider.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/wallet_filter_tabs.dart';
import 'budget_detail_screen.dart';
import 'budget_form_screen.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(budgetListProvider);
    final filter = ref.watch(budgetFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Ngân sách & Hạn mức',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(budgetListProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Tabs bộ lọc ví
            Text(
              'Ví áp dụng:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 8),
            WalletFilterTabs(
              selectedWalletId: filter.walletId,
              onSelected: (walletId) {
                ref.read(budgetFilterProvider.notifier).setWalletId(walletId);
              },
            ),
            const SizedBox(height: 16),

            // Card Tổng quan
            stateAsync.when(
              data: (data) => data.summary != null
                  ? BudgetOverviewCard(summary: data.summary!)
                  : const SizedBox.shrink(),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Lỗi tải tổng quan: $e', style: const TextStyle(color: AppColors.danger)),
              ),
            ),
            const SizedBox(height: 24),

            // Mục tiêu chi tiêu header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MỤC TIÊU CHI TIÊU',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BudgetFormScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tạo ngân sách'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Danh sách các ngân sách
            stateAsync.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.savings_outlined, size: 48, color: AppColors.lightMuted),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có ngân sách nào được thiết lập.',
                            style: GoogleFonts.inter(color: AppColors.lightMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final budget = data.items[index];
                    return BudgetProgressCard(
                      budget: budget,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BudgetDetailScreen(budgetId: budget.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, _) => Center(
                child: Text('Đã có lỗi xảy ra: $err', style: const TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
