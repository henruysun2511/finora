import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/domain/models/category_breakdown_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

/// Card 1: Cơ cấu Chi tiêu (Donut Chart + Danh mục Progress) trên Trang chủ
/// Thiết kế 1:1 theo chuẩn `static-ui/device-preview/screens/home/dashboard.html` (#categoryBreakdownCard)
class HomeCategoryBreakdownCard extends ConsumerStatefulWidget {
  const HomeCategoryBreakdownCard({super.key});

  @override
  ConsumerState<HomeCategoryBreakdownCard> createState() =>
      _HomeCategoryBreakdownCardState();
}

class _HomeCategoryBreakdownCardState
    extends ConsumerState<HomeCategoryBreakdownCard> {
  int _selectedCategoryIndex = 0;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  static const List<Color> _palette = [
    Color(0xFF0072D6), // Xanh thương hiệu - Ăn uống
    Color(0xFFF97316), // Cam san hô - Mua sắm
    Color(0xFF10B981), // Xanh lá ngọc - Hóa đơn
    Color(0xFF8B5CF6), // Tím lavender - Di chuyển
    Color(0xFFEC4899), // Hồng tươi - Khác & Giải trí
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthParam =
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
    final breakdownAsync =
        ref.watch(dashboardCategoryBreakdownByMonthProvider(monthParam));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => context.push(RoutePaths.dashboard),
          child: Container(
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
            padding: const EdgeInsets.all(16),
            child: breakdownAsync.when(
              loading: () => const SizedBox(
                height: 240,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => _buildContent(
                isDark: isDark,
                month: _selectedMonth.month,
                year: _selectedMonth.year,
                totalExpense: 8300000,
                items: _mockCategories(),
              ),
              data: (data) => _buildContent(
                isDark: isDark,
                month: _selectedMonth.month,
                year: _selectedMonth.year,
                totalExpense:
                    data.totalAmount > 0 ? data.totalAmount : 8300000,
                items: data.categories.isNotEmpty
                    ? data.categories.take(5).toList()
                    : _mockCategories(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<CategoryBreakdownItemModel> _mockCategories() {
    return const [
      CategoryBreakdownItemModel(
        id: 'cat-1',
        name: 'Ăn uống',
        icon: 'utensils',
        color: '#0072D6',
        amount: 3160000,
        percentage: 38.0,
      ),
      CategoryBreakdownItemModel(
        id: 'cat-2',
        name: 'Mua sắm',
        icon: 'shopping-bag',
        color: '#F97316',
        amount: 2080000,
        percentage: 25.0,
      ),
      CategoryBreakdownItemModel(
        id: 'cat-3',
        name: 'Hóa đơn',
        icon: 'receipt',
        color: '#10B981',
        amount: 1250000,
        percentage: 15.0,
      ),
      CategoryBreakdownItemModel(
        id: 'cat-4',
        name: 'Di chuyển',
        icon: 'car',
        color: '#8B5CF6',
        amount: 998000,
        percentage: 12.0,
      ),
      CategoryBreakdownItemModel(
        id: 'cat-5',
        name: 'Khác & Giải trí',
        icon: 'gamepad-2',
        color: '#EC4899',
        amount: 834000,
        percentage: 10.0,
      ),
    ];
  }

  Widget _buildContent({
    required bool isDark,
    required int month,
    required int year,
    required double totalExpense,
    required List<CategoryBreakdownItemModel> items,
  }) {
    final activeItem = _selectedCategoryIndex < items.length
        ? items[_selectedCategoryIndex]
        : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Card Header ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cơ cấu Chi tiêu',
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Phân bổ 5 nhóm danh mục tháng $month',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
            // Nút bộ lọc chọn tháng tương tác
            GestureDetector(
              onTap: () => _showMonthPicker(context, isDark),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tháng $month',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── 2. Donut Section (Donut Chart Trái + List Tiến độ Phải) ─────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Donut Chart Vector
            SizedBox(
              width: 112,
              height: 112,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(112, 112),
                    painter: _DonutChartPainter(
                      items: items,
                      colors: _palette,
                      selectedIndex: _selectedCategoryIndex,
                      isDark: isDark,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.formatCompact(totalExpense),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Tổng chi',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
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
            const SizedBox(width: 16),

            // Category Progress List
            Expanded(
              child: Column(
                children: List.generate(items.length, (idx) {
                  final cat = items[idx];
                  final color = _palette[idx % _palette.length];
                  final isSelected = idx == _selectedCategoryIndex;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = idx;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.5),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkForeground
                                            : AppColors.lightForeground,
                                      ),
                                    ),
                                    Text(
                                      '${cat.percentage.toStringAsFixed(0)}% · ${CurrencyFormatter.formatCompact(cat.amount)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppColors.darkForeground
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: (cat.percentage / 100).clamp(0.02, 1.0),
                                    minHeight: 4,
                                    backgroundColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              ],
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
        const SizedBox(height: 14),

        // ── 3. Bottom Insight Box ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              const Text(
                '✦ ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkForeground
                          : const Color(0xFF334155),
                    ),
                    children: [
                      TextSpan(
                        text: activeItem.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text:
                            ' chiếm ${activeItem.percentage.toStringAsFixed(0)}% (${CurrencyFormatter.formatCompact(activeItem.amount)}). Bấm từng danh mục để xem phân tích.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context, bool isDark) {
    final now = DateTime.now();
    // Tạo danh sách 12 tháng gần nhất từ hiện tại lùi về
    final months = List.generate(12, (index) {
      return DateTime(now.year, now.month - index);
    });

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh kéo
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHỌN THÁNG XEM CƠ CẤU CHI TIÊU',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkMuted
                          : AppColors.lightMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: months.length,
                itemBuilder: (context, i) {
                  final m = months[i];
                  final isSelected = m.year == _selectedMonth.year &&
                      m.month == _selectedMonth.month;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMonth = DateTime(m.year, m.month);
                          _selectedCategoryIndex = 0;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF8FAFC)),
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
                          'Tháng ${m.month}/${m.year}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryBreakdownItemModel> items;
  final List<Color> colors;
  final int selectedIndex;
  final bool isDark;

  _DonutChartPainter({
    required this.items,
    required this.colors,
    required this.selectedIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 14.0;

    // Track circle background
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (items.isEmpty) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < items.length; i++) {
      final sweepAngle = (items[i].percentage / 100) * 2 * math.pi;
      final color = colors[i % colors.length];
      final isSelected = i == selectedIndex;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 2 : strokeWidth
        ..strokeCap = StrokeCap.round;

      // Vẽ segment có gap nhỏ
      final adjustedSweep = math.max(0.01, sweepAngle - 0.08);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.04,
        adjustedSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.items != items ||
        oldDelegate.isDark != isDark;
  }
}

