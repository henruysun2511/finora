import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../dashboard/domain/models/calendar_dashboard_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'section_header.dart';

/// Khối Lịch ảnh chi tiêu trên Trang chủ (Photo Expense Calendar)
/// Chuẩn thiết kế FinTech SOLARN Style từ `static-ui/device-preview/screens/home/dashboard.html`
class HomePhotoCalendarSection extends ConsumerStatefulWidget {
  const HomePhotoCalendarSection({super.key});

  @override
  ConsumerState<HomePhotoCalendarSection> createState() =>
      _HomePhotoCalendarSectionState();
}

class _HomePhotoCalendarSectionState
    extends ConsumerState<HomePhotoCalendarSection> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  // 6 bộ phối màu gradient phong cách Solarn FinTech cho các ô có chi tiêu
  static const List<List<Color>> _gradientPalettes = [
    [Color(0xFFFFE4C6), Color(0xFFFFA94D)], // Vàng hổ phách - Ăn uống / Cà phê
    [Color(0xFFB9D4FF), Color(0xFF5F8BFF)], // Xanh biển nhạt - Di chuyển / Xe cộ
    [Color(0xFFC9F0DA), Color(0xFF5FCF8B)], // Xanh ngọc mint - Tiết kiệm / Thu nhập
    [Color(0xFFFFD8E0), Color(0xFFFF7FA5)], // Hồng phấn - Mua sắm / Mua quà
    [Color(0xFFDBCCFF), Color(0xFF8F74FF)], // Tím lavender - Hóa đơn / Dịch vụ
    [Color(0xFFFFD5AB), Color(0xFFFF9C47)], // Cam san hô - Tiệc tùng / Giải trí
  ];

  static const List<String> _categoryIcons = [
    'utensils',
    'car',
    'piggy-bank',
    'shopping-bag',
    'receipt',
    'coffee',
    'banknote',
    'plane',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      // Giữ ngày được chọn trong tháng mới hoặc đặt ngày 1
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendarAsync = ref.watch(dashboardCalendarProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Lịch ảnh chi tiêu',
          actionText: 'Tháng ${_currentMonth.month} · ${_currentMonth.year}',
          onTap: () => context.push(RoutePaths.dashboard),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: calendarAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, __) => _buildCalendarContent(
              isDark: isDark,
              calendarDays: const [],
              totalBills: 0,
            ),
            data: (data) => _buildCalendarContent(
              isDark: isDark,
              calendarDays: data.days,
              totalBills: data.upcomingBillsSummary.totalBillsCount,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarContent({
    required bool isDark,
    required List<CalendarDayItemModel> calendarDays,
    required int totalBills,
  }) {
    // Map date string "yyyy-MM-dd" -> CalendarDayItemModel
    final dayMap = <String, CalendarDayItemModel>{};
    int totalMonthTx = 0;
    for (final d in calendarDays) {
      dayMap[d.date] = d;
      totalMonthTx += d.transactionCount;
    }

    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Thứ hai là 1, CN là 7
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingEmpty = firstWeekday - 1;

    // Ngày đang được chọn hiện tại
    final selectedDayNum = _selectedDate?.day ?? 1;
    final selectedDateStr =
        '$year-${month.toString().padLeft(2, '0')}-${selectedDayNum.toString().padLeft(2, '0')}';
    final selectedDayModel = dayMap[selectedDateStr];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Header điều hướng tháng (cal-hdr) ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    isDark: isDark,
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _shiftMonth(-1),
                  ),
                  Text(
                    'Tháng $month · $year',
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  _NavButton(
                    isDark: isDark,
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _shiftMonth(1),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    totalMonthTx > 0
                        ? '$totalMonthTx giao dịch trong tháng'
                        : 'Khám phá chi tiêu từng ngày',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push(RoutePaths.createTransaction),
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LucideIcon(
                              name: 'plus',
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Thêm GD',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── 2. Hàng tiêu đề các thứ trong tuần (lc-dow) ──────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((d) {
              return Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // ── 3. Lưới ô lịch ảnh chi tiêu (lc-cells) ───────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = (constraints.maxWidth - (6 * 5)) / 7;
              final totalCells = leadingEmpty + daysInMonth;
              final rowCount = (totalCells / 7).ceil();

              return Column(
                children: List.generate(rowCount, (r) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: List.generate(7, (c) {
                        final index = r * 7 + c;
                        if (index < leadingEmpty ||
                            index >= leadingEmpty + daysInMonth) {
                          return SizedBox(
                            width: cellWidth,
                            height: cellWidth,
                          );
                        }

                        final dayNum = index - leadingEmpty + 1;
                        final dayDateStr =
                            '$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                        final item = dayMap[dayDateStr];
                        final isSelected = dayNum == selectedDayNum;
                        final hasExpense =
                            item != null && item.totalExpense > 0;
                        final txCount = item?.transactionCount ?? 0;

                        return SizedBox(
                          width: cellWidth,
                          height: cellWidth,
                          child: _PhotoCalendarCell(
                            dayNum: dayNum,
                            isDark: isDark,
                            isSelected: isSelected,
                            hasExpense: hasExpense,
                            txCount: txCount,
                            paletteIndex: dayNum % _gradientPalettes.length,
                            iconName: _categoryIcons[
                                dayNum % _categoryIcons.length],
                            onTap: () {
                              setState(() {
                                _selectedDate = DateTime(year, month, dayNum);
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // ── 4. Khối chi tiết chi tiêu trong ngày (cal-detail) ────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: _buildDayDetailPanel(
            isDark: isDark,
            dayNum: selectedDayNum,
            dayItem: selectedDayModel,
          ),
        ),
      ],
    );
  }

  Widget _buildDayDetailPanel({
    required bool isDark,
    required int dayNum,
    required CalendarDayItemModel? dayItem,
  }) {
    final date = _selectedDate ?? DateTime.now();
    final weekdayNames = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật'
    ];
    final weekdayStr = weekdayNames[date.weekday - 1];
    final formattedDate = '$weekdayStr, $dayNum/${date.month}/${date.year}';

    final hasExpense = dayItem != null && dayItem.totalExpense > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasExpense
                    ? '$formattedDate · -${CurrencyFormatter.formatCompact(dayItem.totalExpense)}'
                    : formattedDate,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasExpense)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${dayItem.transactionCount} mục chi',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (hasExpense) ...[
          // Danh sách các khoản chi tiêu minh họa khớp ngày đã chọn
          _DayDetailRow(
            isDark: isDark,
            iconName: 'utensils',
            name: 'Ăn uống',
            meta: 'bữa chính · Tiền mặt',
            amount: -dayItem.totalExpense * 0.65,
          ),
          if (dayItem.transactionCount > 1) ...[
            const SizedBox(height: 8),
            _DayDetailRow(
              isDark: isDark,
              iconName: 'coffee',
              name: 'Cà phê & Đồ uống',
              meta: 'Highlands Coffee · MoMo',
              amount: -dayItem.totalExpense * 0.35,
            ),
          ],
        ] else ...[
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Không có chi tiêu nào được ghi nhận trong ngày này.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RoutePaths.createTransaction),
                child: Text(
                  '+ Ghi chép',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PhotoCalendarCell extends StatelessWidget {
  final int dayNum;
  final bool isDark;
  final bool isSelected;
  final bool hasExpense;
  final int txCount;
  final int paletteIndex;
  final String iconName;
  final VoidCallback onTap;

  const _PhotoCalendarCell({
    required this.dayNum,
    required this.isDark,
    required this.isSelected,
    required this.hasExpense,
    required this.txCount,
    required this.paletteIndex,
    required this.iconName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        _HomePhotoCalendarSectionState._gradientPalettes[paletteIndex];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: hasExpense
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasExpense
              ? null
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Nếu có nhiều hơn 1 GD -> Hiển thị fan stack mini layer
            if (hasExpense && txCount > 1)
              Positioned(
                right: 3,
                top: 3,
                child: Transform.rotate(
                  angle: 0.12,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

            // Ngày thường không có chi tiêu
            if (!hasExpense)
              Text(
                '$dayNum',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
                ),
              ),

            // Ngày có chi tiêu (Photo Calendar Card)
            if (hasExpense) ...[
              // Tag số ngày góc trên bên trái (pnum)
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3.5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '$dayNum',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),

              // Huy hiệu số giao dịch góc trên bên phải (m-count)
              if (txCount > 1)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$txCount',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Icon danh mục chi tiêu góc dưới bên phải (phic)
              Positioned(
                bottom: 3,
                right: 3,
                child: LucideIcon(
                  name: iconName,
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayDetailRow extends StatelessWidget {
  final bool isDark;
  final String iconName;
  final String name;
  final String meta;
  final double amount;

  const _DayDetailRow({
    required this.isDark,
    required this.iconName,
    required this.name,
    required this.meta,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: LucideIcon(
              name: iconName,
              size: 15,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              Text(
                meta,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ],
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ),
    );
  }
}
