import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/report_period.dart';

class ReportPeriodSelector extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final DateTime targetDate;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ValueChanged<ReportPeriod> onPeriodChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(DateTime start, DateTime end)? onCustomRangeSelected;

  const ReportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.targetDate,
    this.customStart,
    this.customEnd,
    required this.onPeriodChanged,
    required this.onPrevious,
    required this.onNext,
    this.onCustomRangeSelected,
  });

  String _formatPeriodTitle() {
    switch (selectedPeriod) {
      case ReportPeriod.week:
        final startOfWeek = targetDate.subtract(Duration(days: targetDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return 'Tuần ${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}';
      case ReportPeriod.month:
        return 'Tháng ${targetDate.month}, ${targetDate.year}';
      case ReportPeriod.quarter:
        final quarterNum = ((targetDate.month - 1) ~/ 3) + 1;
        return 'Quý $quarterNum, ${targetDate.year}';
      case ReportPeriod.year:
        return 'Năm ${targetDate.year}';
      case ReportPeriod.custom:
        if (customStart != null && customEnd != null) {
          return '${DateFormat('dd/MM/yy').format(customStart!)} - ${DateFormat('dd/MM/yy').format(customEnd!)}';
        }
        return 'Khoảng ngày tùy chọn';
    }
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      initialDateRange: customStart != null && customEnd != null
          ? DateTimeRange(start: customStart!, end: customEnd!)
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ),
    );

    if (picked != null && onCustomRangeSelected != null) {
      onCustomRangeSelected!(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Navigation [<] Tháng 10, 2026 [>] ──────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: LucideIcon(
                    name: 'chevron-left',
                    size: 20,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                  onPressed: onPrevious,
                  tooltip: 'Kỳ trước',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                GestureDetector(
                  onTap: selectedPeriod == ReportPeriod.custom
                      ? () => _pickCustomRange(context)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatPeriodTitle(),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      if (selectedPeriod == ReportPeriod.custom) ...[
                        const SizedBox(width: 6),
                        const LucideIcon(
                          name: 'calendar',
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: LucideIcon(
                    name: 'chevron-right',
                    size: 20,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                  onPressed: onNext,
                  tooltip: 'Kỳ sau',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ),

        // ── Thanh Chọn Kỳ: Tuần | Tháng | Năm | Tùy chọn (Quy chuẩn RULE GEMINI.md) ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: ReportPeriod.values.map((period) {
              final isSelected = selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(period.label),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onSelected: (val) {
                    if (val) {
                      if (period == ReportPeriod.custom) {
                        _pickCustomRange(context);
                      } else {
                        onPeriodChanged(period);
                      }
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
