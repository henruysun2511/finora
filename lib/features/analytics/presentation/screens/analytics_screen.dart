import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Báo cáo & Phân tích',
        subtitle: 'Bức tranh chi tiết toàn cảnh tài chính',
        action: IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Làm mới',
          onPressed: () {
            ref.invalidate(dashboardOverviewProvider);
            ref.invalidate(dashboardCashFlowProvider);
            ref.invalidate(dashboardCategoryBreakdownProvider);
            ref.invalidate(dashboardBudgetHealthProvider);
            ref.invalidate(dashboardCalendarProvider);
          },
        ),
      ),
      body: Column(
        children: [
          // ── Tabs Bar chuẩn FinTech RULE[GEMINI.md] ──────────────────────
          Container(
            color: isDark ? AppColors.darkSurface : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
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
                Tab(text: 'Dòng tiền'),
                Tab(text: 'Cơ cấu 50/30/20'),
                Tab(text: 'Sức khỏe ngân sách'),
                Tab(text: 'Lịch & Hóa đơn'),
              ],
            ),
          ),

          // ── Tab Views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CashFlowTab(isDark: isDark),
                _CategoryBreakdownTab(isDark: isDark),
                _BudgetHealthTab(isDark: isDark),
                _CalendarTab(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: DÒNG TIỀN (CASH FLOW TIMELINE + HEATMAP + KHUNG GIỜ)
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
          padding: const EdgeInsets.all(16),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Thu: +${CurrencyFormatter.formatCompact(item.income)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      'Chi: -${CurrencyFormatter.formatCompact(item.expense)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${isPositive ? '+' : ''}${CurrencyFormatter.formatCompact(item.net)}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isPositive
                                  ? AppColors.success
                                  : AppColors.danger,
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
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
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
                              color: AppColors.primary.withValues(alpha: 0.12),
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
// TAB 2: CƠ CẤU 50/30/20 & DANH MỤC CHI TIÊU
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
          padding: const EdgeInsets.all(16),
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
                        child: Text(c.icon, style: const TextStyle(fontSize: 18)),
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
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.formatCompact(sub.amount)} (${sub.percentage.toStringAsFixed(1)}%)',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
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

              // Top khoản chi tiêu lớn nhất
              _SectionContainer(
                isDark: isDark,
                title: 'KHOẢN CHI TIÊU LỚN TRONG THÁNG',
                child: Column(
                  children: cat.topSpendingItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.receipt_rounded,
                            size: 20,
                            color: Color(0xFFF97316),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                                Text(
                                  '${item.categoryName} · ${item.date}',
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
// TAB 3: SỨC KHỎE NGÂN SÁCH (BURN-RATE + RUNWAY PREDICTION)
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
          padding: const EdgeInsets.all(16),
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
                            br.willOverspend ? 'Cảnh báo vượt ngân sách' : 'An toàn',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${CurrencyFormatter.formatCompact(br.actualDailyBurnRate)} / ngày',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tốc độ khuyến nghị an toàn: ${CurrencyFormatter.formatCompact(br.recommendedDailyBurnRate)} / ngày',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    if (br.projectedRunwayDate != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dự báo cạn ngân sách vào ngày: ${br.projectedRunwayDate}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tổng ngân sách vs Đã chi
              _SectionContainer(
                isDark: isDark,
                title: 'TỔNG QUAN HẠN MỨC THÁNG',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã chi ${CurrencyFormatter.format(health.totalSpent)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                        Text(
                          'Hạn mức: ${CurrencyFormatter.format(health.totalBudgetLimit)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (health.spentPercentage / 100.0).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: health.spentPercentage > 85
                                ? AppColors.danger
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Còn lại: ${CurrencyFormatter.format(health.remainingBudget)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Còn ${health.daysRemaining} ngày',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Danh sách từng ngân sách
              _SectionContainer(
                isDark: isDark,
                title: 'TIẾN ĐỘ NGÂN SÁCH DANH MỤC',
                child: Column(
                  children: health.categoryBudgets.map((item) {
                    Color stColor = AppColors.success;
                    if (item.colorStatus == 'ORANGE') stColor = const Color(0xFFF97316);
                    if (item.colorStatus == 'RED') stColor = AppColors.danger;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(item.icon, style: const TextStyle(fontSize: 18)),
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
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: stColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor:
                                  (item.spentPercentage / 100.0).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: stColor,
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
                                '${CurrencyFormatter.formatCompact(item.spentAmount)} / ${CurrencyFormatter.formatCompact(item.limitAmount)}',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                              Text(
                                item.remainingAmount > 0
                                    ? 'Còn lại: ${CurrencyFormatter.formatCompact(item.remainingAmount)}'
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
// TAB 4: LỊCH TÀI CHÍNH & HÓA ĐƠN ĐỊNH KỲ
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
          padding: const EdgeInsets.all(16),
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
                    Text(
                      'HÓA ĐƠN SẮP TỚI (30 NGÀY TỚI)',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(
                        cal.upcomingBillsSummary.totalUpcoming30Days,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tiền mặt khả dụng dự kiến còn: ${CurrencyFormatter.format(cal.upcomingBillsSummary.projectedDisposableCash)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Danh sách hóa đơn
              _SectionContainer(
                isDark: isDark,
                title: 'DANH SÁCH HÓA ĐƠN CẦN THANH TOÁN',
                child: Column(
                  children: bills.map((b) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              size: 18,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                                Text(
                                  'Ngày chạy: ${b.nextRunDate} (còn ${b.daysRemaining} ngày)',
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
                            CurrencyFormatter.format(b.amount),
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
              const SizedBox(height: 18),

              // Lịch theo ngày
              _SectionContainer(
                isDark: isDark,
                title: 'LỊCH CHI TIÊU CÁC NGÀY TRONG THÁNG',
                child: Column(
                  children: cal.days.map((d) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: d.hasSpikeExpense
                                  ? AppColors.danger.withValues(alpha: 0.12)
                                  : (isDark
                                      ? AppColors.darkBackground
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              d.date,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: d.hasSpikeExpense
                                    ? AppColors.danger
                                    : (isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (d.hasSpikeExpense)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '⚡ Đột biến',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            '-${CurrencyFormatter.formatCompact(d.totalExpense)}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
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
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
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
