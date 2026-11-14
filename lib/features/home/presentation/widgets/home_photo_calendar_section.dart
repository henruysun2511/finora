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
import '../../../dashboard/domain/models/dashboard_overview_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/presentation/providers/transaction_list_provider.dart';
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
    [
      Color(0xFFFFD5AB),
      Color(0xFFFF9C47)
    ], // 0: Cam san hô / Vàng hổ phách (Ăn uống, cà phê)
    [
      Color(0xFFC7D2FE),
      Color(0xFF818CF8)
    ], // 1: Xanh tím / Lavender (Di chuyển / Xe cộ)
    [
      Color(0xFFC9F0DA),
      Color(0xFF4ADE80)
    ], // 2: Xanh mint tươi (Tiết kiệm, heo đất)
    [Color(0xFFFFD2E0), Color(0xFFFF7FA5)], // 3: Hồng phấn (Mua sắm)
    [Color(0xFFB9D4FF), Color(0xFF5F8BFF)], // 4: Xanh biển (Hóa đơn / Đăng ký)
    [
      Color(0xFFFEF08A),
      Color(0xFFFACC15)
    ], // 5: Vàng chanh tươi sáng (Thu nhập / Thưởng)
  ];

  static _CellVisuals _getCellVisuals(int dayNum) {
    if (dayNum == 1) {
      return _CellVisuals(_gradientPalettes[0], _gradientPalettes[1], 'coffee');
    }
    if (dayNum == 4) {
      return _CellVisuals(_gradientPalettes[0], _gradientPalettes[1], 'coffee');
    }
    if (dayNum == 5) {
      return _CellVisuals(_gradientPalettes[1], _gradientPalettes[0], 'car');
    }
    if (dayNum == 8) {
      return _CellVisuals(
          _gradientPalettes[4], _gradientPalettes[1], 'utensils');
    }
    if (dayNum == 10) {
      return _CellVisuals(
          _gradientPalettes[3], _gradientPalettes[5], 'shopping-bag');
    }
    if (dayNum == 13) {
      return _CellVisuals(
          _gradientPalettes[2], _gradientPalettes[0], 'piggy-bank');
    }

    switch (dayNum % 6) {
      case 0:
        return _CellVisuals(
            _gradientPalettes[4], _gradientPalettes[2], 'receipt');
      case 1:
        return _CellVisuals(
            _gradientPalettes[0], _gradientPalettes[1], 'coffee');
      case 2:
        return _CellVisuals(
            _gradientPalettes[3], _gradientPalettes[5], 'shopping-bag');
      case 3:
        return _CellVisuals(
            _gradientPalettes[2], _gradientPalettes[4], 'piggy-bank');
      case 4:
        return _CellVisuals(
            _gradientPalettes[0], _gradientPalettes[1], 'utensils');
      case 5:
      default:
        return _CellVisuals(_gradientPalettes[1], _gradientPalettes[0], 'car');
    }
  }

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
    final monthKey =
        '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
    final calendarAsync = ref.watch(dashboardCalendarByMonthProvider(monthKey));
    final overviewAsync = ref.watch(dashboardOverviewProvider);

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
              recentTransactions: overviewAsync.value?.recentTransactions,
            ),
            data: (data) => _buildCalendarContent(
              isDark: isDark,
              calendarDays: data.days,
              totalBills: data.upcomingBillsSummary.totalBillsCount,
              recentTransactions: overviewAsync.value?.recentTransactions,
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
    List<DashboardRecentTransactionModel>? recentTransactions,
  }) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Thứ hai là 1, CN là 7
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingEmpty = firstWeekday - 1;

    // Map theo số ngày trong tháng (1..31) để đối chiếu chính xác tuyệt đối không bị lệch múi giờ hay định dạng
    final dayMap = <int, CalendarDayItemModel>{};
    int totalMonthTx = 0;

    for (final d in calendarDays) {
      totalMonthTx += d.transactionCount;
      int? matchedDay;

      // 1. Phân tích qua DateTime
      final dt = DateTime.tryParse(d.date);
      if (dt != null) {
        if (dt.year == year && dt.month == month) {
          matchedDay = dt.day;
        } else {
          final local = dt.toLocal();
          if (local.year == year && local.month == month) {
            matchedDay = local.day;
          }
        }
      }

      // 2. Phân tích qua chuỗi YYYY-MM-DD
      if (matchedDay == null && d.date.length >= 10) {
        final parts = d.date.substring(0, 10).split('-');
        if (parts.length == 3) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final day = int.tryParse(parts[2]);
          if (y == year && m == month && day != null) {
            matchedDay = day;
          }
        }
      }

      if (matchedDay != null) {
        dayMap[matchedDay] = d;
      }
    }

    // Nếu có giao dịch gần đây từ overview mà chưa có trong calendarDays thì bổ sung
    if (recentTransactions != null) {
      for (final tx in recentTransactions) {
        final dt = tx.transactionDate;
        int? txDay;
        if (dt.year == year && dt.month == month) {
          txDay = dt.day;
        } else {
          final local = dt.toLocal();
          if (local.year == year && local.month == month) {
            txDay = local.day;
          }
        }
        if (txDay != null && !dayMap.containsKey(txDay)) {
          dayMap[txDay] = CalendarDayItemModel(
            date:
                '$year-${month.toString().padLeft(2, '0')}-${txDay.toString().padLeft(2, '0')}',
            totalIncome: tx.type == 'INCOME' ? tx.amount : 0,
            totalExpense: tx.type == 'EXPENSE' ? tx.amount : 0,
            transactionCount: 1,
            hasSpikeExpense: false,
            highlightPhotoUrl: null,
          );
          totalMonthTx += 1;
        }
      }
    }

    // Ngày đang được chọn hiện tại
    final selectedDayNum = _selectedDate?.day ?? 1;
    final selectedDayModel = dayMap[selectedDayNum];

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
                  Flexible(
                    child: Text(
                      'Tháng $month · $year',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
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
                  Expanded(
                    child: Text(
                      totalMonthTx > 0
                          ? '$totalMonthTx giao dịch trong tháng'
                          : 'Khám phá chi tiêu từng ngày',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                            Flexible(
                                child: Text(
                              'Thêm GD',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Builder(
            builder: (context) {
              final totalCells = leadingEmpty + daysInMonth;
              final rowCount = (totalCells / 7).ceil();

              return Column(
                children: List.generate(rowCount, (r) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: List.generate(7, (c) {
                        final index = r * 7 + c;
                        if (index < leadingEmpty ||
                            index >= leadingEmpty + daysInMonth) {
                          return const Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: SizedBox.shrink(),
                            ),
                          );
                        }

                        final dayNum = index - leadingEmpty + 1;
                        final item = dayMap[dayNum];
                        final isSelected = dayNum == selectedDayNum;
                        final hasExpense = item != null &&
                            (item.totalExpense > 0 ||
                                item.transactionCount > 0);
                        final txCount =
                            item?.transactionCount ?? (hasExpense ? 1 : 0);
                        final visuals = _getCellVisuals(dayNum);
                        final isFan =
                            hasExpense && txCount >= 2 && (dayNum % 2 == 0);

                        return Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: _PhotoCalendarCell(
                                dayNum: dayNum,
                                isDark: isDark,
                                isSelected: isSelected,
                                hasExpense: hasExpense,
                                txCount: txCount,
                                isFan: isFan,
                                frontPalette: visuals.front,
                                backPalette: visuals.back,
                                iconName: visuals.icon,
                                highlightPhotoUrl: item?.highlightPhotoUrl,
                                onTap: () {
                                  setState(() {
                                    _selectedDate =
                                        DateTime(year, month, dayNum);
                                  });
                                },
                              ),
                            ),
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
            if (hasExpense) ...[
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
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openTransactionDetailModal(
                    context: context,
                    dateStr: formattedDate,
                    dayItem: dayItem,
                    dayNum: dayNum,
                    isDark: isDark,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text(
                          'Xem chi tiết',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
            onTap: () => _openTransactionDetailModal(
              context: context,
              dateStr: formattedDate,
              dayItem: dayItem,
              dayNum: dayNum,
              isDark: isDark,
              initialIndex: 0,
            ),
          ),
          if (dayItem.transactionCount > 1) ...[
            const SizedBox(height: 8),
            _DayDetailRow(
              isDark: isDark,
              iconName: 'coffee',
              name: 'Cà phê & Đồ uống',
              meta: 'Highlands Coffee · MoMo',
              amount: -dayItem.totalExpense * 0.35,
              onTap: () => _openTransactionDetailModal(
                context: context,
                dateStr: formattedDate,
                dayItem: dayItem,
                dayNum: dayNum,
                isDark: isDark,
                initialIndex: 1,
              ),
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

  void _openTransactionDetailModal({
    required BuildContext context,
    required String dateStr,
    required CalendarDayItemModel? dayItem,
    required int dayNum,
    required bool isDark,
    int initialIndex = 0,
  }) {
    if (dayItem == null) return;

    final dailySummary = ref.read(dailyGridProvider).value;
    final List<_DetailTxEntry> entries = [];

    if (dailySummary != null) {
      for (final g in dailySummary.days) {
        if (g.date.day == dayNum && g.date.month == _currentMonth.month) {
          for (final tx in g.transactions) {
            entries.add(
              _DetailTxEntry(
                title: tx.name.isNotEmpty
                    ? tx.name
                    : (tx.categoryName ?? 'Chi tiêu'),
                category: tx.categoryName ?? 'Chi tiêu',
                categoryIcon: tx.categoryIcon ?? 'receipt',
                account: tx.accountName ?? 'Ví chính',
                time:
                    '${tx.transactionDate.hour.toString().padLeft(2, '0')}:${tx.transactionDate.minute.toString().padLeft(2, '0')}',
                amount: tx.isExpense ? -tx.amount : tx.amount,
                note: tx.note,
                photoUrl: tx.photoUrl,
              ),
            );
          }
          break;
        }
      }
    }

    if (entries.isEmpty) {
      final total = dayItem.totalExpense > 0 ? dayItem.totalExpense : 155000.0;
      final p1 = dayItem.highlightPhotoUrl ??
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=700&auto=format&fit=crop';
      const p2 =
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=700&auto=format&fit=crop';

      entries.add(
        _DetailTxEntry(
          title: 'Ăn uống',
          category: 'Ăn uống & Nhà hàng',
          categoryIcon: 'utensils',
          account: 'Tiền mặt',
          time: '12:30',
          amount: -total * 0.65,
          note: 'Bữa trưa chính cùng đồng nghiệp dự án FINORA',
          photoUrl: p1,
        ),
      );

      if (dayItem.transactionCount > 1) {
        entries.add(
          _DetailTxEntry(
            title: 'Cà phê & Đồ uống',
            category: 'Cà phê & Giải khát',
            categoryIcon: 'coffee',
            account: 'Ví MoMo',
            time: '14:45',
            amount: -total * 0.35,
            note: 'Highlands Coffee - 2 Ly Phin Sữa Đá Cỡ Vừa',
            photoUrl: p2,
          ),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DayTransactionDetailSheet(
        dateStr: dateStr,
        entries: entries,
        initialIndex: initialIndex.clamp(0, entries.length - 1),
        isDark: isDark,
      ),
    );
  }
}

class _PhotoCalendarCell extends StatelessWidget {
  final int dayNum;
  final bool isDark;
  final bool isSelected;
  final bool hasExpense;
  final int txCount;
  final bool isFan;
  final List<Color> frontPalette;
  final List<Color> backPalette;
  final String iconName;
  final String? highlightPhotoUrl;
  final VoidCallback onTap;

  const _PhotoCalendarCell({
    required this.dayNum,
    required this.isDark,
    required this.isSelected,
    required this.hasExpense,
    required this.txCount,
    required this.isFan,
    required this.frontPalette,
    required this.backPalette,
    required this.iconName,
    this.highlightPhotoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emptyBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final hasRealPhoto =
        highlightPhotoUrl != null && highlightPhotoUrl!.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: (!hasExpense || isFan) ? emptyBg : null,
          gradient: (hasExpense && !isFan && !hasRealPhoto)
              ? LinearGradient(
                  colors: frontPalette,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.38),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 10.5 : 13),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // 1. Ngày trống (không có chi tiêu)
              if (!hasExpense)
                Center(
                  child: Text(
                    '$dayNum',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkMuted
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),

              // 2. Có chi tiêu & Fan Stack (nhiều giao dịch xếp xòe quạt theo Solarn UI chuẩn preview)
              if (hasExpense && isFan)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Thẻ sau: lệch trái & nghiêng -12 độ
                      Transform.translate(
                        offset: const Offset(-4, 2),
                        child: Transform.rotate(
                          angle: -0.21,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: backPalette,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(9),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.22),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Thẻ trước: lệch phải & nghiêng +10 độ
                      Transform.translate(
                        offset: const Offset(3.5, -0.5),
                        child: Transform.rotate(
                          angle: 0.17,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: frontPalette,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(9),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.28),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Ảnh thật nếu người dùng có chụp hóa đơn
              if (hasExpense && !isFan && hasRealPhoto)
                Image.network(
                  highlightPhotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),

              // 4. Các huy hiệu (Badges)
              if (hasExpense) ...[
                // Số ngày (pnum) - góc trên bên trái
                Positioned(
                  top: 3.5,
                  left: 3.5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 3.5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
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
                        height: 1.1,
                      ),
                    ),
                  ),
                ),

                // Huy hiệu đếm số giao dịch (m-count) - góc trên bên phải
                if (txCount > 1)
                  Positioned(
                    top: 3.5,
                    right: 3.5,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 15, minHeight: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3.5, vertical: 0.5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$txCount',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color:
                                isSelected ? AppColors.primary : Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Icon danh mục (phic) - góc dưới bên phải (chỉ hiện khi ô đơn không phải fan-stack)
                if (!isFan)
                  Positioned(
                    right: 3.5,
                    bottom: 3.5,
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
  final VoidCallback? onTap;

  const _DayDetailRow({
    required this.isDark,
    required this.iconName,
    required this.name,
    required this.meta,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
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
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(amount),
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                          child: Text(
                        'Chi tiết',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ),
    );
  }
}

class _CellVisuals {
  final List<Color> front;
  final List<Color> back;
  final String icon;

  const _CellVisuals(this.front, this.back, this.icon);
}

class _DetailTxEntry {
  final String title;
  final String category;
  final String categoryIcon;
  final String account;
  final String time;
  final double amount;
  final String? note;
  final String? photoUrl;

  const _DetailTxEntry({
    required this.title,
    required this.category,
    required this.categoryIcon,
    required this.account,
    required this.time,
    required this.amount,
    this.note,
    this.photoUrl,
  });
}

class _DayTransactionDetailSheet extends StatefulWidget {
  final String dateStr;
  final List<_DetailTxEntry> entries;
  final int initialIndex;
  final bool isDark;

  const _DayTransactionDetailSheet({
    required this.dateStr,
    required this.entries,
    required this.initialIndex,
    required this.isDark,
  });

  @override
  State<_DayTransactionDetailSheet> createState() =>
      _DayTransactionDetailSheetState();
}

class _DayTransactionDetailSheetState
    extends State<_DayTransactionDetailSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _showZoomDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entries[_selectedIndex];
    final isDark = widget.isDark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi tiết giao dịch',
                        style: GoogleFonts.inter(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkForeground
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.dateStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkForeground
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nếu ngày có nhiều hơn 1 GD -> Hiện thanh chuyển tab giao dịch
                  if (widget.entries.length > 1) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(widget.entries.length, (i) {
                          final item = widget.entries[i];
                          final isSel = i == _selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              showCheckmark: false,
                              label: Text(
                                  '${item.title} (${CurrencyFormatter.formatCompact(item.amount.abs())})'),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight:
                                    isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground),
                              ),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSel
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                ),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedIndex = i;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Khối 1: Ảnh hóa đơn / Biên lai ────────────────────────
                  Container(
                    height: 195,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (entry.photoUrl != null &&
                              entry.photoUrl!.isNotEmpty)
                            Image.network(
                              entry.photoUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderReceipt(isDark),
                            )
                          else
                            _buildPlaceholderReceipt(isDark),

                          // Huy hiệu overlay
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const LucideIcon(
                                    name: 'camera',
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                      child: Text(
                                    'Ảnh hóa đơn / Biên lai',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ],
                              ),
                            ),
                          ),

                          // Nút phóng to ảnh
                          if (entry.photoUrl != null &&
                              entry.photoUrl!.isNotEmpty)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () =>
                                    _showZoomDialog(context, entry.photoUrl!),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.zoom_in_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                          child: Text(
                                        'Phóng to',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Khối 2: Số tiền lớn & Trạng thái ──────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Số tiền chi tiêu',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(entry.amount),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                  child: Text(
                                'Đã xác thực',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF10B981),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Khối 3: Bảng thông tin chi tiết các trường ──────────────
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailItemRow(
                          isDark: isDark,
                          iconName: entry.categoryIcon,
                          label: 'Danh mục',
                          value: entry.category,
                        ),
                        const Divider(height: 1),
                        _buildDetailItemRow(
                          isDark: isDark,
                          iconName: 'wallet',
                          label: 'Nguồn tiền',
                          value: entry.account,
                        ),
                        const Divider(height: 1),
                        _buildDetailItemRow(
                          isDark: isDark,
                          iconName: 'clock',
                          label: 'Thời gian',
                          value: '${entry.time} · ${widget.dateStr}',
                        ),
                        if (entry.note != null && entry.note!.isNotEmpty) ...[
                          const Divider(height: 1),
                          _buildDetailItemRow(
                            isDark: isDark,
                            iconName: 'file-text',
                            label: 'Ghi chú',
                            value: entry.note!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Nút xem trong sổ giao dịch ─────────────────────────────
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(RoutePaths.transactions);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Xem trong Sổ giao dịch',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderReceipt(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 44,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có ảnh chụp biên lai',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItemRow({
    required bool isDark,
    required String iconName,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          LucideIcon(
            name: iconName,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppColors.darkForeground : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
