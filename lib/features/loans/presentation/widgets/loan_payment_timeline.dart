import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/loan_payment.dart';

class LoanPaymentTimeline extends StatelessWidget {
  const LoanPaymentTimeline({
    super.key,
    required this.payments,
    required this.isDark,
  });

  final List<LoanPayment> payments;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final p in payments)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: isDark ? AppColors.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.check_rounded, color: Color(0xFF16A34A)),
              ),
              title: Text(
                '+ ${CurrencyFormatter.formatVnd(p.amount)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy HH:mm').format(p.paymentDate) +
                    (p.notes != null ? ' · ${p.notes}' : ''),
                style: AppTextStyles.bodySmall(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
