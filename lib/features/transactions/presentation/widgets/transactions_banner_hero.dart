import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/models/monthly_transaction_summary.dart';

class TransactionsBannerHero extends StatelessWidget {
  const TransactionsBannerHero({
    super.key,
    required this.summary,
  });

  final MonthlyTransactionSummary summary;

  @override
  Widget build(BuildContext context) {
    final totalTxCount = summary.days.fold<int>(
      0,
      (acc, day) => acc + day.transactions.length,
    );
    final formattedNet = NumberFormat('#,###', 'vi_VN')
        .format(summary.netAmount.abs().round());
    final formattedIncome =
        NumberFormat('#,###', 'vi_VN').format(summary.totalIncome.round());
    final formattedExpense =
        NumberFormat('#,###', 'vi_VN').format(summary.totalExpense.round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'THẶNG DƯ RÒNG THÁNG',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$totalTxCount giao dịch',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${summary.netAmount >= 0 ? '+' : '-'}₫ $formattedNet',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // 2 Ô Thu & Chi kính mờ chuẩn FinTech
        Row(
          children: [
            Expanded(
              child: FrostedStatBox(
                label: 'TỔNG THU',
                value: '+₫ $formattedIncome',
                valueColor: const Color(0xFF86EFAC),
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FrostedStatBox(
                label: 'TỔNG CHI',
                value: '-₫ $formattedExpense',
                valueColor: const Color(0xFFFCA5A5),
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FrostedStatBox extends StatelessWidget {
  const FrostedStatBox({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: valueColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
