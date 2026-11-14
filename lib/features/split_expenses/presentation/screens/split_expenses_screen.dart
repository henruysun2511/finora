import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/navigation/social_bottom_bar.dart';
import '../../../../core/widgets/navigation/social_tab.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/split_providers.dart';
import '../widgets/split_card.dart';
import '../widgets/split_summary_hero_card.dart';

class SplitExpensesScreen extends ConsumerWidget {
  const SplitExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = ref.watch(currentUserIdProvider);
    final summaryAsync = ref.watch(splitSummaryProvider);
    final splitsAsync = ref.watch(mySplitsProvider);
    final selectedTab = ref.watch(splitFilterTabProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chia tiền nhóm',
        subtitle: 'Quản lý các đợt chia bill & hóa đơn',
        onBack: () => context.go(RoutePaths.feed),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(splitSummaryProvider);
          await ref.read(mySplitsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── 1. Thẻ Hero Tổng quan dòng tiền ─────────────────────────────
            SliverToBoxAdapter(
              child: summaryAsync.when(
                data: (summary) => SplitSummaryHeroCard(summary: summary),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(child: LinearProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── 2. Nút Tạo đợt chia tiền mới (Ở trong màn hình) ──────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(RoutePaths.createSplitExpense),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(
                      'Tạo đợt chia tiền mới',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 3. Thanh Tabs Phân loại (Chuẩn GEMINI.md Mục 2) ──────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: SplitFilterTab.values.map((tab) {
                    final isSelected = tab == selectedTab;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          onTap: () {
                            ref.read(splitFilterTabProvider.notifier).state =
                                tab;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tab.label,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 6)),

            // ── 3. Danh sách các phiên chia tiền ──────────────────────────────
            splitsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: AppColors.danger,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Không thể tải danh sách đợt chia tiền',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            ref.read(mySplitsProvider.notifier).refresh();
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (splits) {
                if (splits.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có đợt chia tiền nào',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sau khi thanh toán hóa đơn, bạn có thể chia tiền cho bạn bè để cùng hoàn trả công bằng.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .push(RoutePaths.createSplitExpense),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Chọn hóa đơn để chia'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final item = splits[i];
                      return SplitCard(
                        split: item,
                        currentUserId: currentUserId,
                        onTap: () {
                          context.push('/split-expenses/${item.id}');
                        },
                      );
                    },
                    childCount: splits.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar:
          const SocialBottomBar(currentTab: SocialTab.splitBill),
    );
  }
}
