import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import '../providers/loan_list_provider.dart';
import '../providers/loan_providers.dart';

class LoanCard extends ConsumerWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.onTap,
  });

  final Loan loan;
  final VoidCallback onTap;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      AppColors.orange,
      const Color(0xFFEC4899),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loanStatus = loan.effectiveStatus;
    final lastReminder = ref.watch(reminderCooldownProvider(loan.id));
    final reminderCoolingDown = lastReminder != null &&
        DateTime.now().difference(lastReminder) < const Duration(hours: 6);

    final statusColor = switch (loanStatus) {
      LoanStatus.overdue => AppColors.danger,
      LoanStatus.settled => AppColors.success,
      LoanStatus.active => switch (loan.type) {
          LoanType.lent => AppColors.primary,
          LoanType.borrowed => AppColors.orange,
          LoanType.installment => AppColors.violet,
        },
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: loanStatus == LoanStatus.overdue
              ? AppColors.danger.withValues(alpha: 0.7)
              : isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
          width: loanStatus == LoanStatus.overdue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar + Tên + Số tiền còn lại
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _getAvatarColor(loan.counterpartyName),
                      child: Text(
                        _getInitials(loan.counterpartyName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  loan.counterpartyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleMedium(
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                              ),
                              if (loan.isLinkedToFriend) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loan.notes?.isNotEmpty == true
                                ? loan.notes!
                                : loan.type.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall(
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatVnd(loan.remainingAmount),
                          style: AppTextStyles.amountItem(
                            color: loan.type == LoanType.lent
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _StatusBadge(
                          status: loanStatus,
                          color: statusColor,
                          overdueDays: loan.overdueDays,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar: Gradient Solarn
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: loan.repaidPercent,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      loan.repaidPercent >= 1.0
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Footer: Tiến độ trả + Nút hành động nhanh (Nhắc nợ / Trả nợ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        loan.dueDate != null
                            ? (loanStatus == LoanStatus.overdue
                                ? 'Quá hạn ${loan.overdueDays ?? 0} ngày'
                                : 'Hạn ${DateFormat('dd/MM/yyyy').format(loan.dueDate!)}')
                            : 'Đã trả ${(loan.repaidPercent * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.bodySmall(
                          color: loanStatus == LoanStatus.overdue
                              ? AppColors.danger
                              : isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                        ),
                      ),
                    ),
                    if (loanStatus != LoanStatus.settled) ...[
                      if (loan.type == LoanType.lent)
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: reminderCoolingDown
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(loanRepositoryProvider)
                                        .sendReminder(loan.id);
                                    ref
                                        .read(reminderCooldownProvider(loan.id)
                                            .notifier)
                                        .state = DateTime.now();
                                    if (context.mounted) {
                                      AppToast.success(
                                        context,
                                        'Đã gửi lời nhắc nợ thành công.',
                                      );
                                    }
                                  } catch (e) {
                                    final msg = e is AppException
                                        ? e.message
                                        : e.toString();
                                    if (context.mounted) {
                                      AppToast.error(context, msg);
                                    }
                                  }
                                },
                          icon: const Icon(Icons.notifications_active_outlined, size: 15),
                          label: Text(
                            reminderCoolingDown ? 'Đã nhắc gần đây' : 'Nhắc nợ',
                            style: const TextStyle(fontSize: 12),
                          ),
                        )
                      else
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: onTap,
                          icon: const Icon(Icons.add_rounded, size: 15),
                          label: const Text(
                            'Trả nợ',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.color,
    this.overdueDays,
  });

  final LoanStatus status;
  final Color color;
  final int? overdueDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status == LoanStatus.overdue && overdueDays != null
            ? 'Quá hạn $overdueDays ngày'
            : status.displayName,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

