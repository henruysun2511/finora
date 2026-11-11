import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/domain/models/cash_flow_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'section_header.dart';

/// Card Snapshot: Xu hướng Thu & Chi trên Trang chủ
/// Thiết kế chuẩn Solarn FinTech 100% từ `static-ui/device-preview/screens/home/dashboard.html` (#incomeExpenseChartCard)
class HomeWeeklyTrendSection extends ConsumerStatefulWidget {
  const HomeWeeklyTrendSection({super.key});

  @override
  ConsumerState<HomeWeeklyTrendSection> createState() =>
      _HomeWeeklyTrendSectionState();
}

class _HomeWeeklyTrendSectionState
    extends ConsumerState<HomeWeeklyTrendSection> {
  // Kỳ lọc: '7d' (7 ngày), '4w' (4 tuần), 'month' (Tháng)
  String _selectedPeriod = '7d';
  // Chỉ số mốc đang được chọn trong biểu đồ
  int _selectedDayIndex = 4; // Mặc định Thứ 6 (T6)

  // ── Bộ dữ liệu chuẩn Solarn Style ──────────────────────────────────────────
  static final _data7d = _PeriodDataset(
    sub: '7 ngày gần nhất · Đơn vị: nghìn ₫',
    income: '₫15,350K',
    expense: '₫8,320K',
    surplus: '+₫7,030K',
    bench: 'Trung bình chi: ₫280K/d',
    benchFraction: 0.52,
    days: const [
      _ChartDayItem(
        day: 'T2',
        incomeHeight: 0.18,
        expenseHeight: 0.38,
        inVal: '₫0',
        expVal: '₫120K',
        inAmt: 0,
        expAmt: 120000,
        title: 'Thứ Hai · Ngày 25/08',
        note: 'Ăn tối ngoài & Cà phê',
      ),
      _ChartDayItem(
        day: 'T3',
        incomeHeight: 0.18,
        expenseHeight: 0.25,
        inVal: '₫0',
        expVal: '₫80K',
        inAmt: 0,
        expAmt: 80000,
        title: 'Thứ Ba · Ngày 26/08',
        note: 'Ăn trưa & BeBike',
      ),
      _ChartDayItem(
        day: 'T4',
        incomeHeight: 0.25,
        expenseHeight: 0.28,
        inVal: '₫350K',
        expVal: '₫95K',
        inAmt: 350000,
        expAmt: 95000,
        title: 'Thứ Tư · Ngày 27/08',
        note: 'Thu nợ bạn + Cơm trưa',
      ),
      _ChartDayItem(
        day: 'T5',
        incomeHeight: 0.18,
        expenseHeight: 0.48,
        inVal: '₫0',
        expVal: '₫210K',
        inAmt: 0,
        expAmt: 210000,
        title: 'Thứ Năm · Ngày 28/08',
        note: 'Buffet trưa đồng nghiệp',
      ),
      _ChartDayItem(
        day: 'T6',
        incomeHeight: 0.95,
        expenseHeight: 0.65,
        inVal: '₫15,000K',
        expVal: '₫420K',
        inAmt: 15000000,
        expAmt: 420000,
        title: 'Thứ Sáu · Ngày 29/08',
        note: 'Lương Finora + Siêu thị WinMart',
      ),
      _ChartDayItem(
        day: 'T7',
        incomeHeight: 0.18,
        expenseHeight: 0.52,
        inVal: '₫0',
        expVal: '₫260K',
        inAmt: 0,
        expAmt: 260000,
        title: 'Thứ Bảy · Ngày 30/08',
        note: 'Cà phê cuối tuần & Mua sắm',
      ),
      _ChartDayItem(
        day: 'CN',
        incomeHeight: 0.18,
        expenseHeight: 0.35,
        inVal: '₫0',
        expVal: '₫110K',
        inAmt: 0,
        expAmt: 110000,
        title: 'Chủ Nhật · Ngày 31/08',
        note: 'Xem phim & Ăn tối',
      ),
    ],
    defaultIndex: 4,
  );

  static final _data4w = _PeriodDataset(
    sub: '4 tuần qua trong tháng · Đơn vị: triệu ₫',
    income: '₫15.35M',
    expense: '₫8.32M',
    surplus: '+₫7.03M',
    bench: 'Trung bình: ₫2.08M/tuần',
    benchFraction: 0.50,
    days: const [
      _ChartDayItem(
        day: 'W1',
        incomeHeight: 0.20,
        expenseHeight: 0.45,
        inVal: '₫0',
        expVal: '₫1.85M',
        inAmt: 0,
        expAmt: 1850000,
        title: 'Tuần 1 (01 - 07/08)',
        note: 'Ăn uống & Tiện ích đầu tháng',
      ),
      _ChartDayItem(
        day: 'W2',
        incomeHeight: 0.25,
        expenseHeight: 0.60,
        inVal: '₫350K',
        expVal: '₫2.45M',
        inAmt: 350000,
        expAmt: 2450000,
        title: 'Tuần 2 (08 - 14/08)',
        note: 'Chi tiêu ăn ngoài tăng (+22%)',
      ),
      _ChartDayItem(
        day: 'W3',
        incomeHeight: 0.20,
        expenseHeight: 0.40,
        inVal: '₫0',
        expVal: '₫1.62M',
        inAmt: 0,
        expAmt: 1620000,
        title: 'Tuần 3 (15 - 21/08)',
        note: 'Kiểm soát ngân sách tốt',
      ),
      _ChartDayItem(
        day: 'W4',
        incomeHeight: 0.95,
        expenseHeight: 0.55,
        inVal: '₫15.0M',
        expVal: '₫2.40M',
        inAmt: 15000000,
        expAmt: 2400000,
        title: 'Tuần 4 (22 - 31/08)',
        note: 'Nhận lương tháng + Mua sắm tuần',
      ),
    ],
    defaultIndex: 3,
  );

  static final _dataMonth = _PeriodDataset(
    sub: 'So sánh 6 tháng gần nhất · Đơn vị: triệu ₫',
    income: '₫92.0M',
    expense: '₫51.8M',
    surplus: '+₫40.2M',
    bench: 'Trung bình chi: ₫8.6M/tháng',
    benchFraction: 0.50,
    days: const [
      _ChartDayItem(
        day: 'T3',
        incomeHeight: 0.70,
        expenseHeight: 0.50,
        inVal: '₫14.5M',
        expVal: '₫8.1M',
        inAmt: 14500000,
        expAmt: 8100000,
        title: 'Tháng 3 · 2026',
        note: 'Tiết kiệm đạt 44%',
      ),
      _ChartDayItem(
        day: 'T4',
        incomeHeight: 0.72,
        expenseHeight: 0.55,
        inVal: '₫15.0M',
        expVal: '₫8.9M',
        inAmt: 15000000,
        expAmt: 8900000,
        title: 'Tháng 4 · 2026',
        note: 'Chi lễ 30/4 & Du lịch',
      ),
      _ChartDayItem(
        day: 'T5',
        incomeHeight: 0.70,
        expenseHeight: 0.48,
        inVal: '₫14.8M',
        expVal: '₫7.8M',
        inAmt: 14800000,
        expAmt: 7800000,
        title: 'Tháng 5 · 2026',
        note: 'Dòng tiền thặng dư cao (+₫7.0M)',
      ),
      _ChartDayItem(
        day: 'T6',
        incomeHeight: 0.85,
        expenseHeight: 0.65,
        inVal: '₫17.5M',
        expVal: '₫10.2M',
        inAmt: 17500000,
        expAmt: 10200000,
        title: 'Tháng 6 · 2026',
        note: 'Thưởng quý 2 + Mua sắm hè',
      ),
      _ChartDayItem(
        day: 'T7',
        incomeHeight: 0.72,
        expenseHeight: 0.52,
        inVal: '₫15.2M',
        expVal: '₫8.5M',
        inAmt: 15200000,
        expAmt: 8500000,
        title: 'Tháng 7 · 2026',
        note: 'Chi tiêu theo đúng ngân sách',
      ),
      _ChartDayItem(
        day: 'T8',
        incomeHeight: 0.80,
        expenseHeight: 0.52,
        inVal: '₫15.35M',
        expVal: '₫8.32M',
        inAmt: 15350000,
        expAmt: 8320000,
        title: 'Tháng 8 · Hiện tại',
        note: 'Tỷ lệ tiết kiệm đạt 44.5%',
      ),
    ],
    defaultIndex: 5,
  );

  _PeriodDataset _getCurrentData(CashFlowModel? realCashFlow) {
    switch (_selectedPeriod) {
      case '4w':
        return _data4w;
      case 'month':
        return _dataMonth;
      case '7d':
      default:
        // Nếu API trả về timeline thật có dữ liệu thì cập nhật số tổng
        if (realCashFlow != null && realCashFlow.timeline.isNotEmpty) {
          final realTotalIn = realCashFlow.totalIncome;
          final realTotalExp = realCashFlow.totalExpense;
          final realSurplus = realTotalIn - realTotalExp;
          return _PeriodDataset(
            sub: _data7d.sub,
            income: realTotalIn > 0
                ? CurrencyFormatter.formatCompact(realTotalIn)
                : _data7d.income,
            expense: realTotalExp > 0
                ? CurrencyFormatter.formatCompact(realTotalExp)
                : _data7d.expense,
            surplus: realSurplus >= 0
                ? '+${CurrencyFormatter.formatCompact(realSurplus)}'
                : '-${CurrencyFormatter.formatCompact(realSurplus.abs())}',
            bench: _data7d.bench,
            benchFraction: _data7d.benchFraction,
            days: _data7d.days,
            defaultIndex: _data7d.defaultIndex,
          );
        }
        return _data7d;
    }
  }

  void _switchPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      if (period == '7d') {
        _selectedDayIndex = _data7d.defaultIndex;
      } else if (period == '4w') {
        _selectedDayIndex = _data4w.defaultIndex;
      } else {
        _selectedDayIndex = _dataMonth.defaultIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cashFlowAsync = ref.watch(dashboardCashFlowProvider);
    final realCashFlow = cashFlowAsync.value;
    final currentData = _getCurrentData(realCashFlow);

    final safeIndex = _selectedDayIndex.clamp(0, currentData.days.length - 1);
    final selectedDay = currentData.days[safeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Phân tích Thu Chi',
          actionText: 'Chi tiết',
          onTap: () => context.push(RoutePaths.dashboard),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Header Card: Tiêu đề + Bộ nút chọn kỳ (ana-pills) ────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xu hướng Thu & Chi',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark
                                ? AppColors.darkForeground
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          currentData.sub,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkMuted
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Nhóm tab chọn kỳ
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PeriodPillButton(
                          topText: '7',
                          bottomText: 'ngày',
                          isSelected: _selectedPeriod == '7d',
                          isDark: isDark,
                          onTap: () => _switchPeriod('7d'),
                        ),
                        _PeriodPillButton(
                          topText: '4',
                          bottomText: 'tuần',
                          isSelected: _selectedPeriod == '4w',
                          isDark: isDark,
                          onTap: () => _switchPeriod('4w'),
                        ),
                        _PeriodPillButton(
                          topText: 'Tháng',
                          bottomText: null,
                          isSelected: _selectedPeriod == 'month',
                          isDark: isDark,
                          onTap: () => _switchPeriod('month'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── 2. Hàng 3 thẻ chỉ số nhanh (ana-stat-row) ──────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      dotColor: const Color(0xFF10B981),
                      label: 'Tổng thu',
                      value: currentData.income,
                      valueColor: const Color(0xFF059669),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      dotColor: const Color(0xFFF43F5E),
                      label: 'Tổng chi',
                      value: currentData.expense,
                      valueColor: const Color(0xFFE11D48),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      dotColor: AppColors.primary,
                      label: 'Thặng dư',
                      value: currentData.surplus,
                      valueColor: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 3. Biểu đồ Cột đôi Tương tác (ana-chart-canvas) ─────────────
              SizedBox(
                height: 145,
                child: Stack(
                  children: [
                    // Đường chuẩn nét đứt (Benchmark Line)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 100 * (1 - currentData.benchFraction),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: _DashedLinePainter(
                                color: AppColors.primary.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white)
                                  .withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              currentData.bench,
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lưới các cột đôi
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(currentData.days.length, (i) {
                          final item = currentData.days[i];
                          final isSelected = i == safeIndex;

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _selectedDayIndex = i;
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Cặp cột Thu - Chi
                                  SizedBox(
                                    height: 98,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        // Cột Thu (Xanh lá)
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 260),
                                          curve: Curves.easeOutCubic,
                                          width: 8,
                                          height: math.max(
                                              4.0,
                                              95 *
                                                  item.incomeHeight *
                                                  (isSelected ? 1.05 : 1.0)),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF10B981),
                                                Color(0xFF059669)
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(5),
                                              bottom: Radius.circular(2),
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color:
                                                          const Color(0xFF10B981)
                                                              .withValues(
                                                                  alpha: 0.35),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        // Cột Chi (Đỏ hồng)
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 260),
                                          curve: Curves.easeOutCubic,
                                          width: 8,
                                          height: math.max(
                                              4.0,
                                              95 *
                                                  item.expenseHeight *
                                                  (isSelected ? 1.05 : 1.0)),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFF43F5E),
                                                Color(0xFFE11D48)
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(5),
                                              bottom: Radius.circular(2),
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color:
                                                          const Color(0xFFF43F5E)
                                                              .withValues(
                                                                  alpha: 0.35),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Đường gạch đáy mờ
                                  Container(
                                    height: 1.2,
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : const Color(0xFFE2E8F0),
                                  ),
                                  const SizedBox(height: 6),
                                  // Nhãn ngày (T2, T3...)
                                  Text(
                                    item.day,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.darkMuted
                                              : const Color(0xFF64748B)),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  // Dấu chấm active dưới nhãn ngày
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── 4. Thẻ chi tiết khi tương tác mốc (ana-day-detail-box) ───────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bên trái: Ngày + Số tiền Thu & Chi
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${selectedDay.title}: ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            if (selectedDay.inAmt > 0 ||
                                selectedDay.inVal != '₫0') ...[
                              TextSpan(
                                text: '+${selectedDay.inVal} ',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                            TextSpan(
                              text: '-${selectedDay.expVal}',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bên phải: Ghi chú nổi bật (note) màu xanh thương hiệu
                    Flexible(
                      child: Text(
                        selectedDay.note,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Thẻ thống kê chip nhanh
class _StatChip extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;
  final Color valueColor;
  final bool isDark;

  const _StatChip({
    required this.dotColor,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút lựa chọn kỳ phân tích (7 ngày / 4 tuần / Tháng)
class _PeriodPillButton extends StatelessWidget {
  final String topText;
  final String? bottomText;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PeriodPillButton({
    required this.topText,
    this.bottomText,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topText,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkMuted : const Color(0xFF64748B)),
                height: 1.1,
              ),
            ),
            if (bottomText != null)
              Text(
                bottomText!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkMuted : const Color(0xFF64748B)),
                  height: 1.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Painter vẽ đường nét đứt chuẩn FinTech
class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(math.min(startX + dashWidth, size.width), y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ChartDayItem {
  final String day;
  final double incomeHeight;
  final double expenseHeight;
  final String inVal;
  final String expVal;
  final double inAmt;
  final double expAmt;
  final String title;
  final String note;

  const _ChartDayItem({
    required this.day,
    required this.incomeHeight,
    required this.expenseHeight,
    required this.inVal,
    required this.expVal,
    required this.inAmt,
    required this.expAmt,
    required this.title,
    required this.note,
  });
}

class _PeriodDataset {
  final String sub;
  final String income;
  final String expense;
  final String surplus;
  final String bench;
  final double benchFraction;
  final List<_ChartDayItem> days;
  final int defaultIndex;

  const _PeriodDataset({
    required this.sub,
    required this.income,
    required this.expense,
    required this.surplus,
    required this.bench,
    required this.benchFraction,
    required this.days,
    required this.defaultIndex,
  });
}
