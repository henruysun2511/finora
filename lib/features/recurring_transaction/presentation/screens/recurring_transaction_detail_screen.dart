import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finora_mb/features/transactions/domain/models/transaction_enums.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/recurring_enums.dart';
import '../../domain/models/recurring_transaction.dart';
import '../providers/recurring_transaction_list_provider.dart';
import 'recurring_transaction_form_screen.dart';

class RecurringTransactionDetailScreen extends ConsumerWidget {
  const RecurringTransactionDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final detailAsync = ref.watch(recurringTransactionDetailProvider(id));

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: 'Chi tiết định kỳ',
        subtitle: 'Thông tin quy tắc & lịch sử thực thi',
        action: detailAsync.valueOrNull == null
            ? null
            : PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: fg),
                onSelected: (val) async {
                  final item = detailAsync.value!;
                  if (val == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RecurringTransactionFormScreen(initialRule: item),
                      ),
                    );
                  } else if (val == 'toggle_pause') {
                    await ref
                        .read(recurringTransactionDetailProvider(id).notifier)
                        .togglePause();
                    if (context.mounted) {
                      AppToast.success(context,
                          item.isPaused ? 'Đã tiếp tục quy tắc' : 'Đã tạm dừng quy tắc');
                    }
                  } else if (val == 'execute') {
                    _executeNow(context, ref);
                  } else if (val == 'delete') {
                    _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (ctx) {
                  final item = detailAsync.value!;
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_pause',
                      child: Row(
                        children: [
                          Icon(
                            item.isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(item.isPaused ? 'Tiếp tục' : 'Tạm dừng'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'execute',
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded, size: 20, color: AppColors.primary),
                          SizedBox(width: 10),
                          Text('Chạy ngay'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 20, color: AppColors.danger),
                          SizedBox(width: 10),
                          Text('Xóa quy tắc',
                              style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.danger),
                const SizedBox(height: 12),
                Text('Lỗi tải dữ liệu: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(recurringTransactionDetailProvider(id)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (item) {
          final isExpense = item.type == TransactionType.expense;
          final amountColor =
              isExpense ? AppColors.danger : AppColors.success;
          final amountPrefix = isExpense ? '- ' : '+ ';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── 1. Hero Card ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isPaused
                                ? (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder)
                                : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.isPaused
                                    ? Icons.pause_circle_rounded
                                    : Icons.play_circle_fill_rounded,
                                size: 14,
                                color: item.isPaused
                                    ? muted
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.isPaused ? 'Đang tạm dừng' : 'Đang hoạt động',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: item.isPaused
                                      ? muted
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBorder.withValues(alpha: 0.5)
                                : AppColors.lightBorder.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.frequency.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$amountPrefix${CurrencyFormatter.format(item.amount)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: amountColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Thống kê thực thi ──────────────────────────────────
              FormCard(
                title: 'THỐNG KÊ THỰC THI',
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'Số lần đã chạy',
                        value: '${item.totalExecutedTimes ?? 0} lần',
                        icon: Icons.repeat_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: 'Tổng tiền đã ghi',
                        value: CurrencyFormatter.formatCompact(
                            item.totalAmountSpent ?? 0),
                        icon: Icons.payments_rounded,
                        color: isExpense ? AppColors.danger : AppColors.success,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3. Thông tin quy tắc ──────────────────────────────────
              FormCard(
                title: 'CẤU HÌNH QUY TẮC',
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Tài khoản nguồn',
                      value: item.accountName ?? 'Chưa xác định',
                      icon: Icons.account_balance_wallet_outlined,
                      isDark: isDark,
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Hạng mục',
                      value: item.categoryName ?? 'Chưa phân loại',
                      icon: Icons.category_outlined,
                      isDark: isDark,
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Ngày bắt đầu',
                      value: _formatDate(item.createdAt),
                      icon: Icons.calendar_today_rounded,
                      isDark: isDark,
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Lần chạy tiếp theo',
                      value: _formatDate(item.nextRunDate),
                      icon: Icons.update_rounded,
                      isDark: isDark,
                    ),
                    if (item.endDate != null) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        label: 'Ngày kết thúc',
                        value: _formatDate(item.endDate!),
                        icon: Icons.event_busy_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),

              // ── 4. Lịch sử thực thi ──────────────────────────────────
              FormCard(
                title: 'LỊCH SỬ THỰC THI',
                child: (item.executionHistory == null ||
                        item.executionHistory!.isEmpty)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history_rounded,
                                  size: 36, color: muted),
                              const SizedBox(height: 8),
                              Text(
                                'Chưa có lượt thực thi nào',
                                style: TextStyle(color: muted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: item.executionHistory!.map((history) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDateTime(history.date),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: fg,
                                        ),
                                      ),
                                      Text(
                                        'Mã: ${history.transactionId.substring(0, 8)}...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(history.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: amountColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 24),

              // ── 5. Action Buttons ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(
                                recurringTransactionDetailProvider(id).notifier)
                            .togglePause();
                        if (context.mounted) {
                          AppToast.success(
                              context,
                              item.isPaused
                                  ? 'Đã tiếp tục quy tắc'
                                  : 'Đã tạm dừng quy tắc');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        item.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                      ),
                      label: Text(item.isPaused ? 'Tiếp tục' : 'Tạm dừng'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: item.isPaused
                          ? null
                          : () => _executeNow(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('Chạy ngay'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _executeNow(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(recurringTransactionDetailProvider(id).notifier)
          .executeNow();
      if (context.mounted) {
        AppToast.success(context, 'Thực thi giao dịch định kỳ thành công');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, 'Lỗi thực thi: $e');
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa quy tắc định kỳ',
      message:
          'Bạn có chắc chắn muốn xóa quy tắc này? Các giao dịch đã thực thi trước đó sẽ không bị ảnh hưởng.',
      confirmText: 'Xóa',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(recurringTransactionDetailProvider(id).notifier)
            .delete();
        if (context.mounted) {
          AppToast.success(context, 'Đã xóa quy tắc định kỳ');
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(context, 'Lỗi khi xóa: $e');
        }
      }
    }
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String _formatDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Row(
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: muted),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ],
    );
  }
}

