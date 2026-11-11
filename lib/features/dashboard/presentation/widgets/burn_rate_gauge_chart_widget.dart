import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/budget_health_model.dart';

/// Biểu đồ Vòng cung Tốc độ Đốt tiền Ngân sách (Burn-rate Speedometer Gauge)
/// Chuẩn thiết kế Solarn FinTech đo lường tốc độ chi tiêu so với định mức an toàn.
class BurnRateGaugeChartWidget extends StatelessWidget {
  final BudgetHealthModel health;
  final bool isDark;

  const BurnRateGaugeChartWidget({
    super.key,
    required this.health,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = health.spentPercentage;
    final br = health.burnRateMetrics;

    // Xác định màu trạng thái chính
    Color statusColor = const Color(0xFF10B981);
    String statusTitle = 'TỐC ĐỘ AN TOÀN';
    String statusBadge = '🟢 Ổn định';
    if (pct > 100 || br.willOverspend) {
      statusColor = const Color(0xFFEF4444);
      statusTitle = 'NGUY CƠ THÂM HỤT';
      statusBadge = '🔴 Cảnh báo đỏ';
    } else if (pct > 75) {
      statusColor = const Color(0xFFF59E0B);
      statusTitle = 'CHI TIÊU NHANH';
      statusBadge = '🟡 Cần thắt chặt';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: LucideIcon(name: 'gauge', size: 16, color: statusColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusTitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusBadge,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Gauge Arc Painter ──────────────────────────────────────────
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 130),
                  painter: _GaugePainter(
                    percent: (pct / 100.0).clamp(0.0, 1.5),
                    isDark: isDark,
                    activeColor: statusColor,
                  ),
                ),
                // Số liệu tâm vòng cung
                Positioned(
                  bottom: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Đã dùng ngân sách',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Lưới so sánh Tốc độ thực tế vs Định mức ──────────────────────
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tốc độ chi/ngày',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(br.actualDailyBurnRate),
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
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
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Định mức khuyên dùng',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(br.recommendedDailyBurnRate),
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
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
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số ngày còn lại',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${health.daysRemaining} ngày',
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent; // 0.0 -> 1.5
  final bool isDark;
  final Color activeColor;

  const _GaugePainter({
    required this.percent,
    required this.isDark,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 12;

    const strokeWidth = 14.0;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // 1. Vẽ rãnh nền xám mờ
    final trackPaint = Paint()
      ..color = (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. Vẽ 3 dải màu phân vùng mảnh phía trong
    final zoneRadius = radius - strokeWidth - 4;
    final zonePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Vùng Xanh (0 -> 70%)
    zonePaint.color = const Color(0xFF10B981).withValues(alpha: 0.5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: zoneRadius),
      startAngle,
      sweepAngle * 0.7,
      false,
      zonePaint,
    );

    // Vùng Cam (70% -> 100%)
    zonePaint.color = const Color(0xFFF59E0B).withValues(alpha: 0.5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: zoneRadius),
      startAngle + sweepAngle * 0.7,
      sweepAngle * 0.3,
      false,
      zonePaint,
    );

    // 3. Vẽ tiến độ thực tế (Active Sweep)
    final progressSweep = (sweepAngle * (percent / 1.0)).clamp(0.05, sweepAngle);
    final activePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF10B981),
          percent > 0.75 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
          if (percent > 1.0) const Color(0xFFEF4444),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      activePaint,
    );

    // 4. Vẽ chấm chỉ báo kim ở điểm cuối tiến độ
    final currentAngle = startAngle + progressSweep;
    final needleX = center.dx + radius * math.cos(currentAngle);
    final needleY = center.dy + radius * math.sin(currentAngle);

    final needlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(needleX, needleY), strokeWidth / 2 - 1, needlePaint);

    final innerDotPaint = Paint()..color = activeColor;
    canvas.drawCircle(Offset(needleX, needleY), strokeWidth / 2 - 3.5, innerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.isDark != isDark ||
        oldDelegate.activeColor != activeColor;
  }
}
