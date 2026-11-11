import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/debts_dashboard_model.dart';

/// Biểu đồ Tương quan Vị thế Nợ (Receivables vs Payables Balance Bar)
/// Thiết kế trực quan tỷ lệ giữa Khoản phải thu và Khoản phải trả.
class DebtBalanceBarChartWidget extends StatelessWidget {
  final DebtsDashboardModel debts;
  final bool isDark;

  const DebtBalanceBarChartWidget({
    super.key,
    required this.debts,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final rec = debts.totalReceivables;
    final pay = debts.totalPayables;
    final total = rec + pay;

    final recPct = total > 0 ? (rec / total) * 100 : 50.0;
    final payPct = total > 0 ? (pay / total) * 100 : 50.0;

    final isNetPositive = debts.netDebtPosition >= 0;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const LucideIcon(name: 'hand-coins', size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CÂN ĐỐI NGHĨA VỤ NỢ',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isNetPositive ? AppColors.success : AppColors.danger)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isNetPositive ? '🟢 Vị thế nợ ròng dương' : '🔴 Vị thế nợ ròng âm',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isNetPositive ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Thanh Tỷ trọng Đối đầu (Receivables vs Payables Split Bar) ─────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 22,
              child: Row(
                children: [
                  // Nợ phải thu (Xanh lá)
                  Expanded(
                    flex: (recPct * 10).toInt().clamp(5, 995),
                    child: Container(
                      color: AppColors.success,
                      alignment: Alignment.center,
                      child: Text(
                        '${recPct.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Nợ phải trả (Đỏ)
                  Expanded(
                    flex: (payPct * 10).toInt().clamp(5, 995),
                    child: Container(
                      color: AppColors.danger,
                      alignment: Alignment.center,
                      child: Text(
                        '${payPct.toStringAsFixed(0)}%',
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

          // Chú thích 2 bên
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Phải thu: ${CurrencyFormatter.formatCompact(rec)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Phải trả: ${CurrencyFormatter.formatCompact(pay)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Thông số Tỷ lệ Nợ trên Tài sản & Vị thế Ròng ─────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                        'Vị thế nợ ròng',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${isNetPositive ? "+" : ""}${CurrencyFormatter.format(debts.netDebtPosition)}',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isNetPositive ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                        'Nợ / Tổng tài sản',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${debts.debtToAssetRatio.toStringAsFixed(1)}%',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: debts.debtToAssetRatio < 40 ? AppColors.primary : AppColors.orange,
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

