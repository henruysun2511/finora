import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_type.dart';

class LoanInformationCard extends StatelessWidget {
  const LoanInformationCard({
    super.key,
    required this.loan,
    required this.isDark,
  });

  final Loan loan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Loại khoản nợ', loan.type.displayName),
          _buildRow('Số tiền gốc ban đầu',
              CurrencyFormatter.formatVnd(loan.principalAmount)),
          _buildRow('Đã hoàn trả',
              CurrencyFormatter.formatVnd(loan.paidAmount)),
          if (loan.counterpartyPhone != null)
            _buildRow('Số điện thoại liên hệ', loan.counterpartyPhone!),
          if (loan.sourceWalletName != null || loan.accountName != null)
            _buildRow('Nguồn tài khoản / Ví',
                loan.accountName ?? loan.sourceWalletName!),
          if (loan.interestRate != null && loan.interestRate! > 0)
            _buildRow('Lãi suất',
                '${loan.interestRate}% / ${loan.interestPeriod == 'year' ? 'năm' : 'tháng'}'),
          if (loan.installmentMonths != null)
            _buildRow('Kỳ hạn trả góp', '${loan.installmentMonths} tháng'),
          if (loan.notes?.isNotEmpty == true)
            _buildRow('Ghi chú', loan.notes!, isLast: true)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium(
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
