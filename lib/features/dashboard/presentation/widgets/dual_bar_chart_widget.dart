import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/cash_flow_model.dart';

/// Biểu đồ Cột đôi Tương tác Thu & Chi (Interactive Dual Bar Chart)
/// Thiết kế theo chuẩn Solarn FinTech (`static-ui/device-preview/screens/home/dashboard.html`).
class DualBarChartWidget extends StatefulWidget {
  final List<CashFlowTimelineItemModel> timeline;
  final bool isDark;

  const DualBarChartWidget({
    super.key,
    required this.timeline,
    required this.isDark,
  });

  @override
  State<DualBarChartWidget> createState() => _DualBarChartWidgetState();
}

class _DualBarChartWidgetState extends State<DualBarChartWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.timeline.isEmpty) {
      return const SizedBox.shrink();
    }

    // Lấy tối đa 7 mốc gần nhất để hiển thị trực quan không bị chen chúc
    final displayItems = widget.timeline.length > 7
        ? widget.timeline.sublist(widget.timeline.length - 7)
        : widget.timeline;

    // Tìm giá trị max để scale chiều cao cột
    double maxVal = 100000;
    double totalExp = 0;
    for (final item in displayItems) {
      maxVal = math.max(maxVal, math.max(item.income, item.expense));
      totalExp += item.expense;
    }
    final avgExpense = displayItems.isNotEmpty ? totalExp / displayItems.length : 0.0;
    final avgHeightPct = (avgExpense / maxVal).clamp(0.05, 0.95);

    // Mặc định chọn mốc cuối cùng nếu chưa chọn
    final selectedIdx = _selectedIndex ?? (displayItems.length - 1);
    final selectedItem = selectedIdx >= 0 && selectedIdx < displayItems.length
        ? displayItems[selectedIdx]
        : displayItems.last;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Biểu đồ: Tiêu đề + Chú thích màu ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'XU HƯỚNG THU & CHI',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'So sánh dòng tiền các mốc gần nhất',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: widget.isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ],
              ),
              // Chú thích Thu / Chi
              Row(
                children: [
                  _LegendChip(
                    color: AppColors.success,
                    label: 'Thu',
                    isDark: widget.isDark,
                  ),
                  const SizedBox(width: 8),
                  _LegendChip(
                    color: AppColors.danger,
                    label: 'Chi',
                    isDark: widget.isDark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Tooltip chi tiết của mốc đang được chọn ───────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkBackground
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const LucideIcon(name: 'calendar', size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Ngày ${selectedItem.dateLabel}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '+${CurrencyFormatter.formatCompact(selectedItem.income)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      '  /  -${CurrencyFormatter.formatCompact(selectedItem.expense)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (selectedItem.net >= 0 ? AppColors.success : AppColors.danger)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${selectedItem.net >= 0 ? "+" : ""}${CurrencyFormatter.formatCompact(selectedItem.net)}',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: selectedItem.net >= 0 ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Canvas Cột Đôi 150px với Đường Benchmark ──────────────────────
          SizedBox(
            height: 150,
            child: Stack(
              children: [
                // Vạch đứt trung bình chi (Benchmark line)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30 + (100 * avgHeightPct),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: widget.isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: widget.isDark ? AppColors.darkMuted : AppColors.lightMuted,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'TB: ~${CurrencyFormatter.formatCompact(avgExpense)}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: widget.isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: (widget.isDark ? AppColors.darkMuted : AppColors.lightMuted)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách các cột đôi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(displayItems.length, (idx) {
                    final item = displayItems[idx];
                    final isCurrentSelected = idx == selectedIdx;

                    final incomeHeight = ((item.income / maxVal) * 100).clamp(6.0, 100.0);
                    final expenseHeight = ((item.expense / maxVal) * 100).clamp(6.0, 100.0);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = idx;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 2 Cột song song
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isCurrentSelected
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Cột Thu
                                  Flexible(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 10,
                                      height: incomeHeight,
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                          alpha: isCurrentSelected ? 1.0 : 0.65,
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                        boxShadow: isCurrentSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.success.withValues(alpha: 0.4),
                                                  blurRadius: 6,
                                                )
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  // Cột Chi
                                  Flexible(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 10,
                                      height: expenseHeight,
                                      decoration: BoxDecoration(
                                        color: AppColors.danger.withValues(
                                          alpha: isCurrentSelected ? 1.0 : 0.65,
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                        boxShadow: isCurrentSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.danger.withValues(alpha: 0.4),
                                                  blurRadius: 6,
                                                )
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Nhãn ngày mốc
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isCurrentSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.dateLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: isCurrentSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isCurrentSelected
                                      ? Colors.white
                                      : (widget.isDark
                                          ? AppColors.darkMuted
                                          : AppColors.lightMuted),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendChip({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
      ],
    );
  }
}

