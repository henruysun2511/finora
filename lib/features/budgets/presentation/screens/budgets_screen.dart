import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/banner_header.dart';
import '../providers/budget_filter_provider.dart';
import '../providers/budget_list_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/budget_banner_hero.dart';
import '../widgets/budget_empty_card.dart';
import '../widgets/budget_period_filter_tabs.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/budget_search_bar.dart';

/// Màn hình Quản lý Ngân sách chuẩn FinTech Style (`static-ui/ui-sample-3`).
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateAsync = ref.watch(budgetListProvider);
    final filter = ref.watch(budgetFilterProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ── 1. Banner Header Hero lớn chuẩn GEMINI.md & static-ui ────────
          BannerHeader(
            title: 'Ngân sách chi tiêu',
            centerTitle: true,
            showBackButton: true,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.home);
              }
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E5BD8),
                Color(0xFF1742A0),
                Color(0xFFF97316),
              ],
              stops: [0.0, 0.55, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            action: BannerHeader.primaryButton(
              icon: const Icon(
                Icons.add_rounded,
                size: 22,
                color: Colors.white,
              ),
              onTap: () => context.push(RoutePaths.createBudget),
              tooltip: 'Tạo ngân sách',
            ),
            child: BudgetBannerHero(stateAsync: stateAsync),
          ),

          // ── 2. Thanh Tìm kiếm & Bộ lọc Chu kỳ (ChoiceChips chuẩn GEMINI.md) ──
          const BudgetSearchBar(),
          const SizedBox(height: 6),
          BudgetPeriodFilterTabs(
            filter: filter,
            onPeriodChanged: (period) {
              ref.read(budgetFilterProvider.notifier).setPeriodType(period);
            },
          ),
          const SizedBox(height: 6),

          // ── 3. Danh sách các thẻ ngân sách ──
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(budgetListProvider.notifier).refresh(),
              child: stateAsync.when(
                data: (data) {
                  if (data.items.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        BudgetEmptyCard(isDark: isDark),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: data.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index < data.items.length) {
                        final item = data.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: BudgetProgressCard(
                            budget: item,
                            onTap: () {
                              context.push(
                                RoutePaths.budgetDetail
                                    .replaceAll(':id', item.id),
                              );
                            },
                          ),
                        );
                      }

                      // Nút thêm ngân sách mới viền nét đứt ở cuối danh sách
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () => context.push(RoutePaths.createBudget),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Thêm ngân sách mới',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 40, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Không thể tải ngân sách: $e'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(budgetListProvider.notifier).refresh(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
