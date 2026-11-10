import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../domain/models/budget_enums.dart';
import '../../domain/models/budget_filter.dart';
import '../providers/budget_filter_provider.dart';
import '../providers/budget_list_provider.dart';
import '../providers/budget_list_state.dart';
import '../widgets/budget_progress_card.dart';

/// Màn hình Quản lý Ngân sách chuẩn FinTech Style (`static-ui/ui-sample-3`).
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        ref.read(budgetFilterProvider.notifier).setSearchQuery(value.trim());
      }
    });
  }

  Widget _buildBlueAddButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(RoutePaths.createBudget),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          alignment: Alignment.center,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildBannerContent(AsyncValue<BudgetListState> stateAsync) {
    return stateAsync.when(
      data: (data) {
        final summary = data.summary;
        if (summary == null) {
          return const SizedBox(
            height: 90,
            child: Center(
              child: Text(
                'Chưa có dữ liệu tổng quan ngân sách',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          );
        }

        final currencyFormatter = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: '₫',
          decimalDigits: 0,
        );
        final pct = (summary.percentage).clamp(0.0, 100.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label chu kỳ
            Text(
              'NGÂN SÁCH TỔNG · ${summary.periodLabel.toUpperCase()}',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),

            // Số tiền tổng ngân sách lớn màu trắng nổi bật
            Text(
              currencyFormatter.format(summary.totalLimit),
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Thanh tiến độ
            Container(
              height: 9,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(99),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: summary.totalLimit > 0 ? (pct / 100.0) : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF97316),
                        Color(0xFFFFC080),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Chân banner: Đã dùng ... / Còn ...
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đã dùng: ${currencyFormatter.format(summary.totalSpent)} (${summary.percentage.toStringAsFixed(0)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  'Còn: ${currencyFormatter.format(summary.totalRemaining)}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Lỗi tải ngân sách: $e',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm theo danh mục hoặc ví...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : Colors.white,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BudgetFilter filter, bool isDark) {
    final tabs = [
      (null, 'Tất cả', Icons.apps_rounded),
      (BudgetPeriodType.monthly, 'Theo Tháng', Icons.calendar_month_rounded),
      (BudgetPeriodType.weekly, 'Theo Tuần', Icons.view_week_rounded),
      (BudgetPeriodType.yearly, 'Theo Năm', Icons.event_note_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = filter.periodType == tab.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                tab.$3,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
              ),
              label: Text(tab.$2),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
              showCheckmark: false,
              onSelected: (_) {
                ref.read(budgetFilterProvider.notifier).setPeriodType(tab.$1);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(budgetListProvider);
    final filter = ref.watch(budgetFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ── 1. Banner Header Ngân sách chuẩn FinTech ──
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
                Color(0xFF1E5BD8), // Solarn primary blue ban đầu của trang ngân sách
                Color(0xFF1742A0),
                Color(0xFFF97316), // Solarn orange ban đầu của trang ngân sách
              ],
              stops: [0.0, 0.55, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            action: _buildBlueAddButton(context),
            child: _buildBannerContent(stateAsync),
          ),

          // ── 2. Thanh Tìm kiếm & Bộ lọc Chu kỳ (ChoiceChips chuẩn GEMINI.md) ──
          _buildSearchField(isDark),
          _buildFilterTabs(filter, isDark),

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
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.savings_outlined,
                                  size: 48, color: AppColors.lightMuted),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có ngân sách nào được thiết lập.',
                                style: GoogleFonts.inter(
                                  color: AppColors.lightMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: data.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index < data.items.length) {
                        final budget = data.items[index];
                        return BudgetProgressCard(
                          budget: budget,
                          onTap: () {
                            context.push(
                              RoutePaths.budgetDetail
                                  .replaceAll(':id', budget.id),
                            );
                          },
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
                                const Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Thêm ngân sách mới',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : const Color(0xFF334155),
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
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Đã có lỗi xảy ra: $err',
                      style: const TextStyle(color: AppColors.danger),
                    ),
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
