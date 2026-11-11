import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../domain/models/dashboard_overview_model.dart';
import '../../domain/models/export_format.dart';
import '../providers/dashboard_providers.dart';
import '../providers/report_overview_provider.dart';
import '../widgets/report_category_breakdown_list.dart';
import '../widgets/report_donut_chart.dart';
import '../widgets/report_export_sheet.dart';
import '../widgets/report_period_selector.dart';
import '../widgets/report_stat_grid.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overviewAsync = ref.watch(dashboardOverviewProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // ── 1. Hero Banner Header (.acc-hero chuẩn FinTech) ─────────
            SliverToBoxAdapter(
              child: BannerHeader(
                title: 'Dashboard Tài chính',
                subtitle: 'Trung tâm Báo cáo & Phân tích chuyên sâu',
                showBackButton: false,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F4B92),
                    AppColors.primary,
                    Color(0xFFF5B53F),
                  ],
                  stops: [0.0, 0.55, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                action: BannerHeader.glassButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  onTap: () {
                    ref.invalidate(dashboardOverviewProvider);
                    ref.invalidate(dashboardCashFlowProvider);
                    ref.invalidate(dashboardCategoryBreakdownProvider);
                    ref.invalidate(dashboardBudgetHealthProvider);
                    ref.invalidate(dashboardDebtsProvider);
                    ref.invalidate(dashboardCalendarProvider);
                    ref.invalidate(reportOverviewProvider);
                  },
                  tooltip: 'Làm mới toàn bộ dữ liệu',
                ),
                child: _DashboardHeroBanner(overviewAsync: overviewAsync),
              ),
            ),

            // ── 2. Pinned TabBar (Chuẩn Tab Selection FinTech GEMINI.md) ─
            SliverPersistentHeader(
              pinned: true,
              delegate: _DashboardTabBarDelegate(
                isDark: isDark,
                tabBar: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Tổng quan'),
                    Tab(text: 'Dòng tiền'),
                    Tab(text: 'Cơ cấu 50/30/20'),
                    Tab(text: 'Sức khỏe ngân sách'),
                    Tab(text: 'Sổ nợ & Nghĩa vụ'),
                    Tab(text: 'Lịch & Hóa đơn'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(isDark: isDark),
            _CashFlowTab(isDark: isDark),
            _CategoryBreakdownTab(isDark: isDark),
            _BudgetHealthTab(isDark: isDark),
            _DebtsTab(isDark: isDark),
            _CalendarTab(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELEGATE PINNED TABBAR
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  const _DashboardTabBarDelegate({
    required this.tabBar,
    required this.isDark,
  });

  @override
  double get minExtent => 52.0;

  @override
  double get maxExtent => 52.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _DashboardTabBarDelegate oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.tabBar != tabBar;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER TRONG BANNERHEADER
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardHeroBanner extends StatelessWidget {
  final AsyncValue<DashboardOverviewModel> overviewAsync;

  const _DashboardHeroBanner({required this.overviewAsync});

  @override
  Widget build(BuildContext context) {
    return overviewAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Lỗi tải tổng quan: $e',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
      data: (ov) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TỔNG TÀI SẢN RÒNG (NET WORTH)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ov.assetTier.title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.format(ov.netWorth),
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thu nhập tháng',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '+${CurrencyFormatter.formatCompact(ov.monthlyCashflow.income)}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF86EFAC),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chi tiêu tháng',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '-${CurrencyFormatter.formatCompact(ov.monthlyCashflow.expense)}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFCA5A5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tỷ lệ tiết kiệm',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${ov.monthlyCashflow.savingsRate.toStringAsFixed(1)}%',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF93C5FD),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: BÁO CÁO TỔNG QUAN (DONUT CHART + PERIODS + EXPORT PDF)
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  final bool isDark;
  const _OverviewTab({required this.isDark});

  void _handleExport(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    final fileName =
        await ref.read(reportOverviewProvider.notifier).exportReport(format);
    if (!context.mounted) return;

    if (fileName != null) {
      AppToast.success(context, 'Đã xuất file $fileName thành công!');
    } else {
      AppToast.error(
          context, 'Xuất báo cáo không thành công, vui lòng thử lại.');
    }
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    final state = ref.read(reportOverviewProvider);
    final data = state.data;
    if (data == null) {
      AppToast.info(context, 'Chưa có dữ liệu báo cáo để xuất file.');
      return;
    }

    ReportExportSheet.show(
      context,
      data: data,
      onSelectFormat: (format) => _handleExport(context, ref, format),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportOverviewProvider);
    final notifier = ref.read(reportOverviewProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Bộ chọn Chu kỳ (Tuần / Tháng / Quý / Năm / Tùy chọn)
          ReportPeriodSelector(
            selectedPeriod: state.period,
            targetDate: state.targetDate,
            customStart: state.customStart,
            customEnd: state.customEnd,
            onPeriodChanged: notifier.setPeriod,
            onPrevious: notifier.previousPeriod,
            onNext: notifier.nextPeriod,
            onCustomRangeSelected: notifier.setCustomRange,
          ),
          const SizedBox(height: 14),

          // Nút xuất báo cáo PDF/Excel
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showExportOptions(context, ref),
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: Text(
                  'Xuất báo cáo (PDF/Excel)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.data != null) ...[
            // 2. Lưới 4 Thống kê Chỉ số Vàng
            ReportStatGrid(
              summary: state.data!.summary,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // 3. Biểu đồ tròn Donut Tỷ trọng chi tiêu
            if (state.data!.slices.isNotEmpty)
              ReportDonutChart(
                slices: state.data!.slices,
                totalExpense: state.data!.summary.totalExpense,
                selectedCategoryId: state.selectedCategoryId,
                onSliceSelected: notifier.selectCategory,
              ),
            const SizedBox(height: 20),

            // 4. Danh sách Danh mục chi tiết
            ReportCategoryBreakdownList(
              categories: state.data!.categories,
              selectedCategoryId: state.selectedCategoryId,
              onCategorySelected: notifier.selectCategory,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: DÒNG TIỀN (CASH FLOW TIMELINE + HEATMAP + KHUNG GIỜ)
// ─────────────────────────────────────────────────────────────────────────────
class _CashFlowTab extends ConsumerWidget {
  final bool isDark;
  const _CashFlowTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashFlowAsync = ref.watch(dashboardCashFlowProvider);

    return cashFlowAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
      data: (cf) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary 3 Ô Stat
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      isDark: isDark,
                      label: 'Tổng thu',
                      value: CurrencyFormatter.formatCompact(cf.totalIncome),
                      color: AppColors.success,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      isDark: isDark,
                      label: 'Tổng chi',
                      value: CurrencyFormatter.formatCompact(cf.totalExpense),
                      color: AppColors.danger,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      isDark: isDark,
                      label: 'Thặng dư ròng',
                      value: CurrencyFormatter.formatCompact(cf.netSavings),
                      color: AppColors.primary,
                      icon: Icons.savings_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Diễn biến dòng tiền theo timeline
              _SectionContainer(
                isDark: isDark,
                title: 'DIỄN BIẾN DÒNG TIỀN (THÁNG)',
                child: Column(
                  children: cf.timeline.map((item) {
                    final isPositive = item.net >= 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.dateLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '+${CurrencyFormatter.formatCompact(item.income)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '-${CurrencyFormatter.formatCompact(item.expense)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${isPositive ? '+' : ''}${CurrencyFormatter.formatCompact(item.net)}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isPositive
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Heatmap các thứ trong tuần
              _SectionContainer(
                isDark: isDark,
                title: 'CHI TIÊU THEO THỨ TRONG TUẦN',
                child: Column(
                  children: cf.dayOfWeekHeatmap.map((item) {
                    const maxAvg = 1500000.0;
                    final pct = (item.averageExpense / maxAvg).clamp(0.05, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              item.dayOfWeek,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: pct,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: item.averageExpense > 1000000
                                        ? const Color(0xFFF97316)
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '~${CurrencyFormatter.formatCompact(item.averageExpense)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Phân bổ chi tiêu theo khung giờ
              _SectionContainer(
                isDark: isDark,
                title: 'PHÂN BỔ CHI TIÊU THEO KHUNG GIỜ',
                child: Column(
                  children: cf.timeOfDayDistribution.values.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatCompact(item.amount),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.percentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: CƠ CẤU 50/30/20 & DANH MỤC CHI TIÊU
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryBreakdownTab extends ConsumerWidget {
  final bool isDark;
  const _CategoryBreakdownTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(dashboardCategoryBreakdownProvider);

    return catAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
      data: (cat) {
        final rule = cat.rule503020Evaluation;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quy tắc 50/30/20 Card
              if (rule != null)
                _SectionContainer(
                  isDark: isDark,
                  title: 'ĐÁNH GIÁ QUY TẮC TÀI CHÍNH 50/30/20',
                  child: Column(
                    children: [
                      _RuleRow(
                        isDark: isDark,
                        label: 'Nhu cầu thiết yếu (Needs)',
                        target: 'Mục tiêu: 50%',
                        actualPct: rule.needs.percentage,
                        amount: rule.needs.amount,
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 12),
                      _RuleRow(
                        isDark: isDark,
                        label: 'Mong muốn linh hoạt (Wants)',
                        target: 'Mục tiêu: 30%',
                        actualPct: rule.wants.percentage,
                        amount: rule.wants.amount,
                        color: const Color(0xFFF97316),
                      ),
                      const SizedBox(height: 12),
                      _RuleRow(
                        isDark: isDark,
                        label: 'Tích lũy & Đầu tư (Savings)',
                        target: 'Mục tiêu: 20%',
                        actualPct: rule.savings.percentage,
                        amount: rule.savings.amount,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),

              // Danh sách danh mục cha & con
              _SectionContainer(
                isDark: isDark,
                title: 'TỶ TRỌNG TỪNG DANH MỤC',
                child: Column(
                  children: cat.categories.map((c) {
                    return ExpansionTile(
                      shape: const Border(),
                      tilePadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(c.icon,
                            style: const TextStyle(fontSize: 18)),
                      ),
                      title: Text(
                        c.name,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${CurrencyFormatter.formatCompact(c.amount)} (${c.percentage.toStringAsFixed(1)}%)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const Icon(Icons.expand_more_rounded, size: 20),
                        ],
                      ),
                      children: c.subCategories.map((sub) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(46, 4, 8, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sub.name,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(sub.amount),
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Top 3 khoản chi tiêu lớn nhất
              _SectionContainer(
                isDark: isDark,
                title: 'TOP KHOẢN CHI TIÊU LỚN NHẤT',
                child: Column(
                  children: cat.topExpenses.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                                Text(
                                  '${item.categoryName} • ${item.date}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-${CurrencyFormatter.format(item.amount)}',
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RuleRow extends StatelessWidget {
  final bool isDark;
  final String label;
  final String target;
  final double actualPct;
  final double amount;
  final Color color;

  const _RuleRow({
    required this.isDark,
    required this.label,
    required this.target,
    required this.actualPct,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            Text(
              '${actualPct.toStringAsFixed(1)}% ($target)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (actualPct / 100.0).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount),
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4: SỨC KHỎE NGÂN SÁCH (BURN-RATE + RUNWAY PREDICTION)
// ─────────────────────────────────────────────────────────────────────────────
class _BudgetHealthTab extends ConsumerWidget {
  final bool isDark;
  const _BudgetHealthTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(dashboardBudgetHealthProvider);

    return healthAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
      data: (health) {
        final br = health.burnRateMetrics;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Burn-rate AI Prediction Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: br.willOverspend
                        ? const [Color(0xFFE11D48), Color(0xFFBE123C)]
                        : const [Color(0xFF0D9488), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (br.willOverspend
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF0D9488))
                          .withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DỰ BÁO TỐC ĐỘ TIÊU TIỀN (BURN-RATE)',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.white70,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            br.willOverspend
                                ? 'Cảnh báo vượt chi'
                                : 'An toàn',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      br.aiPredictionText,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Burn-rate thực tế/ngày',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(
                                    br.actualDailyBurnRate),
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Số ngày cạn dự kiến',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '${br.predictedRunwayDays} ngày',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: br.willOverspend
                                      ? const Color(0xFFFCA5A5)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Danh sách tình trạng từng ngân sách
              _SectionContainer(
                isDark: isDark,
                title: 'TÌNH TRẠNG NGÂN SÁCH THEO DANH MỤC',
                child: Column(
                  children: health.budgets.map((item) {
                    final pct = (item.spentPercentage / 100.0).clamp(0.0, 1.0);
                    Color color = AppColors.success;
                    if (item.colorStatus == 'ORANGE') color = AppColors.orange;
                    if (item.colorStatus == 'RED') color = AppColors.danger;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(item.icon,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.categoryName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.spentPercentage.toStringAsFixed(0)}%',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 7,
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
                                  color: color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đã chi: ${CurrencyFormatter.formatCompact(item.spentAmount)} / ${CurrencyFormatter.formatCompact(item.limitAmount)}',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                              Text(
                                item.remainingAmount > 0
                                    ? 'Còn: ${CurrencyFormatter.formatCompact(item.remainingAmount)}'
                                    : 'Vượt: ${CurrencyFormatter.formatCompact(item.spentAmount - item.limitAmount)}',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: item.remainingAmount > 0
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 5: SỔ NỢ & NGHĨA VỤ TÀI CHÍNH (DEBTS DASHBOARD)
// ─────────────────────────────────────────────────────────────────────────────
class _DebtsTab extends ConsumerWidget {
  final bool isDark;
  const _DebtsTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(dashboardDebtsProvider);

    return debtsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
      data: (debts) {
        final overdue = debts.overdueStats;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Metric Cards
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      isDark: isDark,
                      label: 'Phải thu',
                      value: CurrencyFormatter.formatCompact(
                          debts.totalReceivables),
                      color: AppColors.success,
                      icon: Icons.call_received_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      isDark: isDark,
                      label: 'Phải trả',
                      value: CurrencyFormatter.formatCompact(
                          debts.totalPayables),
                      color: AppColors.danger,
                      icon: Icons.call_made_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      isDark: isDark,
                      label: 'Vị thế ròng',
                      value: CurrencyFormatter.formatCompact(
                          debts.netDebtPosition),
                      color: debts.netDebtPosition >= 0
                          ? AppColors.primary
                          : AppColors.danger,
                      icon: Icons.account_balance_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Cảnh báo quá hạn
              if (overdue.overduePayableCount > 0 ||
                  overdue.overdueReceivableCount > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded,
                            color: AppColors.danger, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CẢNH BÁO QUÁ HẠN NỢ',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bạn có ${overdue.overduePayableCount} khoản nợ phải trả (${CurrencyFormatter.formatCompact(overdue.overduePayableAmount)}) và ${overdue.overdueReceivableCount} khoản phải thu (${CurrencyFormatter.formatCompact(overdue.overdueReceivableAmount)}) đã quá hạn.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Top đối tác nợ
              _SectionContainer(
                isDark: isDark,
                title: 'TOP ĐỐI TÁC NỢ & CHO VAY',
                child: debts.topDebtors.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Không có dữ liệu nợ đối tác',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: debts.topDebtors.map((debtor) {
                          final isReceivable = debtor.type == 'LENT';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: (isReceivable
                                          ? AppColors.success
                                          : AppColors.danger)
                                      .withValues(alpha: 0.12),
                                  child: Text(
                                    debtor.counterpartyName.isNotEmpty
                                        ? debtor.counterpartyName[0]
                                        : '?',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: isReceivable
                                          ? AppColors.success
                                          : AppColors.danger,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debtor.counterpartyName,
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.darkForeground
                                              : AppColors.lightForeground,
                                        ),
                                      ),
                                      if (debtor.dueDate != null)
                                        Text(
                                          'Hạn: ${debtor.dueDate} ${debtor.isOverdue ? "(${debtor.daysOverdue} ngày quá hạn)" : ""}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: debtor.isOverdue
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: debtor.isOverdue
                                                ? AppColors.danger
                                                : (isDark
                                                    ? AppColors.darkMuted
                                                    : AppColors.lightMuted),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isReceivable ? "+" : "-"}${CurrencyFormatter.format(debtor.remainingAmount)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isReceivable
                                            ? AppColors.success
                                            : AppColors.danger,
                                      ),
                                    ),
                                    Text(
                                      isReceivable ? 'Cần thu' : 'Cần trả',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isReceivable
                                            ? AppColors.success
                                            : AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 18),

              // 4. Tiến độ trả góp
              if (debts.installments.isNotEmpty)
                _SectionContainer(
                  isDark: isDark,
                  title: 'TIẾN ĐỘ CÁC KHOẢN TRẢ GÓP',
                  child: Column(
                    children: debts.installments.map((inst) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  inst.counterpartyName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                                Text(
                                  '${inst.progressPercentage.toStringAsFixed(0)}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (inst.progressPercentage / 100.0)
                                        .clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đã trả: ${CurrencyFormatter.formatCompact(inst.paidAmount)} / ${CurrencyFormatter.formatCompact(inst.totalPrincipal)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                  ),
                                ),
                                if (inst.nextDueDate != null)
                                  Text(
                                    'Kỳ tới: ${inst.nextDueDate}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.orange,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 6: LỊCH TÀI CHÍNH & HÓA ĐƠN ĐỊNH KỲ
// ─────────────────────────────────────────────────────────────────────────────
class _CalendarTab extends ConsumerWidget {
  final bool isDark;
  const _CalendarTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calAsync = ref.watch(dashboardCalendarProvider);

    return calAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
      data: (cal) {
        final bills = cal.upcomingBillsSummary.bills;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hóa đơn 30 ngày tới Summary
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DỰ PHÓNG HÓA ĐƠN 30 NGÀY TỚI',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.white70,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${cal.upcomingBillsSummary.totalBillsCount} hóa đơn',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(
                          cal.upcomingBillsSummary.totalProjectedAmount),
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Danh sách hóa đơn sắp tới
              _SectionContainer(
                isDark: isDark,
                title: 'HÓA ĐƠN ĐỊNH KỲ SẮP ĐẾN HẠN',
                child: bills.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Không có hóa đơn nào sắp tới',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: bills.map((bill) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 18,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bill.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.darkForeground
                                              : AppColors.lightForeground,
                                        ),
                                      ),
                                      Text(
                                        'Hạn: ${bill.nextRunDate} • Còn ${bill.daysRemaining} ngày',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: bill.daysRemaining <= 3
                                              ? AppColors.danger
                                              : (isDark
                                                  ? AppColors.darkMuted
                                                  : AppColors.lightMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-${CurrencyFormatter.format(bill.amount)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 18),

              // Cảnh báo đột biến chi tiêu
              if (cal.spendingSpikes.isNotEmpty)
                _SectionContainer(
                  isDark: isDark,
                  title: 'CẢNH BÁO ĐỘT BIẾN CHI TIÊU',
                  child: Column(
                    children: cal.spendingSpikes.map((spike) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: AppColors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ngày ${spike.date}: Chi tiêu đột biến ${CurrencyFormatter.format(spike.amount)} (+${spike.deviationPercentage.toStringAsFixed(0)}% so với trung bình)',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
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
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.isDark,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final bool isDark;
  final String title;
  final Widget child;

  const _SectionContainer({
    required this.isDark,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
