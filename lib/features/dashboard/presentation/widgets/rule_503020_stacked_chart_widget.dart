import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/category_breakdown_model.dart';

/// Biểu đồ Thanh Phân Tầng Quy Tắc 50/30/20 (Stacked 50/30/20 Segmented Chart)
/// Phân bổ tổng thể giữa Thiết yếu (Needs), Mong muốn (Wants) và Tích lũy (Savings).
class Rule503020StackedChartWidget extends StatelessWidget {
  final Rule503020EvaluationModel? rule;
  final double totalAmount;
  final bool isDark;

  const Rule503020StackedChartWidget({
    super.key,
    required this.rule,
    required this.totalAmount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (rule == null) {
      return const SizedBox.shrink();
    }

    final needs = rule!.needs;
    final wants = rule!.wants;
    final savings = rule!.savings;

    final totalPct = (needs.percentage + wants.percentage + savings.percentage);
    final safeTotalPct = totalPct > 0 ? totalPct : 100.0;

    final needsFlex =
        ((needs.percentage / safeTotalPct) * 1000).toInt().clamp(50, 1000);
    final wantsFlex =
        ((wants.percentage / safeTotalPct) * 1000).toInt().clamp(50, 1000);
    final savingsFlex =
        ((savings.percentage / safeTotalPct) * 1000).toInt().clamp(50, 1000);

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
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const LucideIcon(
                          name: 'layers', size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'QUY TẮC CÂN ĐỐI 50 / 30 / 20',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tổng: ${CurrencyFormatter.formatCompact(totalAmount)}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Thanh Phân Tầng Segmented Stacked Bar ──────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  // Thiết yếu (Needs)
                  Expanded(
                    flex: needsFlex,
                    child: Container(
                      color: AppColors.primary,
                      alignment: Alignment.center,
                      child: Text(
                        '${needs.percentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Mong muốn (Wants)
                  Expanded(
                    flex: wantsFlex,
                    child: Container(
                      color: const Color(0xFFF59E0B),
                      alignment: Alignment.center,
                      child: Text(
                        '${wants.percentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Tích lũy (Savings)
                  Expanded(
                    flex: savingsFlex,
                    child: Container(
                      color: const Color(0xFF10B981),
                      alignment: Alignment.center,
                      child: Text(
                        '${savings.percentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Vạch mốc chỉ báo mục tiêu 50% / 30% / 20%
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 2,
                children: [
                  Text(
                    'Thiết yếu (chuẩn 50%)',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Mong muốn (chuẩn 30%)',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  Text(
                    'Tích lũy (chuẩn 20%)',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 3 Khối Đánh Giá Chi Tiết ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _CategoryPillarCard(
                  title: 'Thiết yếu',
                  target: '<= 50%',
                  percentage: needs.percentage,
                  amount: needs.amount,
                  color: AppColors.primary,
                  isCompliant: needs.percentage <= 50,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CategoryPillarCard(
                  title: 'Mong muốn',
                  target: '<= 30%',
                  percentage: wants.percentage,
                  amount: wants.amount,
                  color: const Color(0xFFF59E0B),
                  isCompliant: wants.percentage <= 30,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CategoryPillarCard(
                  title: 'Tích lũy',
                  target: '>= 20%',
                  percentage: savings.percentage,
                  amount: savings.amount,
                  color: const Color(0xFF10B981),
                  isCompliant: savings.percentage >= 20,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryPillarCard extends StatelessWidget {
  final String title;
  final String target;
  final double percentage;
  final double amount;
  final Color color;
  final bool isCompliant;
  final bool isDark;

  const _CategoryPillarCard({
    required this.title,
    required this.target,
    required this.percentage,
    required this.amount,
    required this.color,
    required this.isCompliant,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              Icon(
                isCompliant
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                size: 13,
                color: isCompliant
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Mục tiêu: $target',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
        ],
      ),
    );
  }
}
