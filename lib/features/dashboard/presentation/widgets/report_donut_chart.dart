import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/report_overview_data.dart';

class ReportDonutChart extends StatefulWidget {
  final List<ReportDonutSlice> slices;
  final double totalExpense;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSliceSelected;

  const ReportDonutChart({
    super.key,
    required this.slices,
    required this.totalExpense,
    this.selectedCategoryId,
    required this.onSliceSelected,
  });

  @override
  State<ReportDonutChart> createState() => _ReportDonutChartState();
}

class _ReportDonutChartState extends State<ReportDonutChart> {
  static Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000000) {
      return '₫ ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '₫ ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₫ ${(amount / 1000).toStringAsFixed(0)}k';
    }
    return CurrencyFormatter.format(amount);
  }

  void _handleTouch(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    const outerRadius = 110.0;
    const innerRadius = 72.0;

    // Chạm vào bên trong tâm rỗng -> bỏ chọn
    if (distance < innerRadius - 10) {
      widget.onSliceSelected(null);
      return;
    }

    // Nằm ngoài đường tròn
    if (distance > outerRadius + 18) {
      return;
    }

    // Tính góc từ đỉnh (-pi / 2)
    var angle = math.atan2(dy, dx);
    angle += math.pi / 2; // Xoay bắt đầu từ 12h
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    final totalPercent = widget.slices.fold<double>(0, (sum, s) => sum + s.percentage);
    if (totalPercent <= 0) return;

    var currentAngle = 0.0;
    for (final slice in widget.slices) {
      final sweepAngle = (slice.percentage / totalPercent) * 2 * math.pi;
      if (angle >= currentAngle && angle <= currentAngle + sweepAngle) {
        widget.onSliceSelected(slice.id);
        return;
      }
      currentAngle += sweepAngle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const chartSize = 220.0;

    final selectedSlice = widget.slices.cast<ReportDonutSlice?>().firstWhere(
          (s) => s?.id == widget.selectedCategoryId,
          orElse: () => null,
        );

    return Column(
      children: [
        // ── Single-Touch Inspect Tooltip nổi trên biểu đồ ──────────────────
        AnimatedOpacity(
          opacity: selectedSlice != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedSlice != null
                    ? _parseColor(selectedSlice.colorHex)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: selectedSlice != null
                      ? _parseColor(selectedSlice.colorHex).withValues(alpha: 0.18)
                      : Colors.transparent,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: selectedSlice == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selectedSlice.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        selectedSlice.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _parseColor(selectedSlice.colorHex),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${selectedSlice.percentage.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        CurrencyFormatter.format(selectedSlice.amount),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // ── Donut Chart 220px kèm Gesture Detect ──────────────────────────
        GestureDetector(
          onTapDown: (details) => _handleTouch(details.localPosition, chartSize),
          onPanUpdate: (details) => _handleTouch(details.localPosition, chartSize),
          child: SizedBox(
            width: chartSize,
            height: chartSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(chartSize, chartSize),
                  painter: _DonutChartPainter(
                    slices: widget.slices,
                    selectedCategoryId: widget.selectedCategoryId,
                    isDark: isDark,
                  ),
                ),

                // ── Tâm rỗng hiển thị Tổng chi tiêu định dạng ngắn gọn (₫ 18.2M) ──
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TỔNG CHI TIÊU',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCompactCurrency(
                        selectedSlice != null ? selectedSlice.amount : widget.totalExpense,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: selectedSlice != null
                            ? _parseColor(selectedSlice.colorHex)
                            : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
                      ),
                    ),
                    if (selectedSlice != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${selectedSlice.percentage.toStringAsFixed(1)}% cơ cấu',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _parseColor(selectedSlice.colorHex),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<ReportDonutSlice> slices;
  final String? selectedCategoryId;
  final bool isDark;

  _DonutChartPainter({
    required this.slices,
    required this.selectedCategoryId,
    required this.isDark,
  });

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final totalPercent = slices.fold<double>(0, (sum, s) => sum + s.percentage);

    if (totalPercent <= 0 || slices.isEmpty) {
      // Vẽ vòng tròn rỗng dự phòng
      final emptyPaint = Paint()
        ..color = isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32;
      canvas.drawCircle(center, 90, emptyPaint);
      return;
    }

    var startAngle = -math.pi / 2; // Bắt đầu từ 12h
    const baseStrokeWidth = 30.0;
    const baseRadius = 88.0;

    for (final slice in slices) {
      final isSelected = selectedCategoryId == slice.id;
      final sweepAngle = (slice.percentage / totalPercent) * 2 * math.pi;

      // Single-Touch Inspect: Lát cắt được chọn nở ra nhẹ 4px
      final strokeWidth = isSelected ? baseStrokeWidth + 6.0 : baseStrokeWidth;
      final radius = isSelected ? baseRadius + 4.0 : baseRadius;

      final paint = Paint()
        ..color = _parseColor(slice.colorHex)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final rect = Rect.fromCircle(center: center, radius: radius);

      // Thêm khoảng hở 1.5 độ giữa các lát cắt nếu có nhiều hơn 1 lát
      final gapAngle = slices.length > 1 ? 0.03 : 0.0;
      final actualSweep = sweepAngle > gapAngle ? sweepAngle - gapAngle : sweepAngle;
      final actualStart = startAngle + gapAngle / 2;

      canvas.drawArc(rect, actualStart, actualSweep, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.selectedCategoryId != selectedCategoryId ||
        oldDelegate.isDark != isDark;
  }
}
