import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_status.dart';

class LoanDetailHeroBanner extends StatelessWidget {
  const LoanDetailHeroBanner({super.key, required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final loanStatus = loan.effectiveStatus;
    final formatter = DateFormat('dd/MM/yyyy');
    final dueText = loan.dueDate == null
        ? 'Chưa đặt hạn thanh toán'
        : 'Hạn: ${formatter.format(loan.dueDate!)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.balanceGradStart,
            AppColors.balanceGradMid,
            AppColors.balanceGradEnd,
          ],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: Text(
              loan.counterpartyName.isEmpty
                  ? '?'
                  : loan.counterpartyName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(
                loan.counterpartyName,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              if (loan.isLinkedToFriend) ...[
                const SizedBox(width: 6),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatVnd(loan.remainingAmount),
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: Colors.white,
            ),
          ),
          Text(
            'Số nợ còn lại · Đã thanh toán ${(loan.repaidPercent * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  loanStatus == LoanStatus.overdue
                      ? Icons.warning_amber_rounded
                      : Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Flexible(
                    child: Text(
                  loanStatus == LoanStatus.overdue
                      ? 'Quá hạn ${loan.overdueDays ?? 0} ngày'
                      : dueText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
