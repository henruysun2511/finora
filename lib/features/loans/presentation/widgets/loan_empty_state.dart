import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/loan_filter.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';

class LoanEmptyState extends StatelessWidget {
  const LoanEmptyState({
    super.key,
    required this.filter,
    required this.isDark,
    required this.onAdd,
  });

  final LoanFilter filter;
  final bool isDark;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final hasSearch = filter.search?.isNotEmpty == true;
    final title = hasSearch
        ? 'Không tìm thấy khoản nợ phù hợp'
        : switch (filter.status) {
            LoanStatus.settled => 'Chưa có khoản nợ nào đã tất toán.',
            _ => switch (filter.type) {
                LoanType.lent =>
                  'Bạn không có khoản nợ nào cần thu hồi. Tiền bạc phân minh, an tâm tích lũy!',
                LoanType.borrowed =>
                  'Tuyệt vời! Bạn không có khoản nợ nào cần trả.',
                LoanType.installment =>
                  'Không có khoản mua sắm trả góp nào đang kích hoạt.',
                null => 'Chưa có khoản vay hoặc nợ nào.',
              },
          };

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 36, 12, 32),
      child: Column(
        children: [
          Icon(
            filter.type == LoanType.installment
                ? Icons.credit_card_rounded
                : filter.type == LoanType.borrowed
                    ? Icons.south_west_rounded
                    : Icons.arrow_outward_rounded,
            size: 56,
            color: filter.type == LoanType.borrowed
                ? AppColors.orange
                : AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium(
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          if (!hasSearch && filter.status != LoanStatus.settled) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                filter.type == LoanType.lent
                    ? 'Cho ai đó vay'
                    : 'Thêm khoản mới',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

