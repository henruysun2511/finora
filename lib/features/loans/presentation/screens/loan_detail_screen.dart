import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import '../providers/loan_list_provider.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_detail_hero_banner.dart';
import '../widgets/loan_information_card.dart';
import '../widgets/loan_payment_sheet.dart';
import '../widgets/loan_payment_timeline.dart';

class LoanDetailScreen extends ConsumerStatefulWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends ConsumerState<LoanDetailScreen> {
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _recordPayment(Loan loan) async {
    final settled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => LoanPaymentSheet(loan: loan),
    );
    if (!mounted || settled == null) return;
    AppToast.success(
      context,
      settled
          ? 'Khoản nợ đã được tất toán thành công. Chúc mừng bạn!'
          : 'Đã ghi nhận đợt thanh toán.',
    );
    if (settled) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.celebration_rounded,
            color: AppColors.success,
            size: 44,
          ),
          title: const Text('Khoản nợ đã tất toán'),
          content: const Text('Toàn bộ khoản nợ đã được thanh toán hoàn tất.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sendReminder(Loan loan) async {
    try {
      await ref.read(loanRepositoryProvider).sendReminder(loan.id);
      ref.read(reminderCooldownProvider(loan.id).notifier).state =
          DateTime.now();
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final last = ref.read(reminderCooldownProvider(loan.id));
        if (last == null ||
            DateTime.now().difference(last) >= const Duration(hours: 6)) {
          _countdownTimer?.cancel();
        }
        setState(() {});
      });
      if (mounted) AppToast.success(context, 'Đã gửi lời nhắc nợ lịch sự.');
    } catch (error) {
      final message = error is AppException ? error.message : error.toString();
      if (mounted) AppToast.error(context, message);
    }
  }

  Future<void> _deleteLoan(Loan loan) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa khoản nợ?',
      message:
          'Khoản nợ này sẽ bị xóa khỏi sổ. Thao tác này không thể hoàn tác.',
    );
    if (!confirmed) return;
    try {
      await ref.read(loanListProvider.notifier).deleteLoan(loan.id);
      if (mounted) {
        AppToast.success(context, 'Đã xóa khoản nợ.');
        context.pop();
      }
    } catch (error) {
      final message = error is AppException ? error.message : error.toString();
      if (mounted) AppToast.error(context, message);
    }
  }

  Future<void> _removeCounterparty(Loan loan) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Gỡ liên kết bạn bè?',
      message:
          'Tên khoản nợ vẫn được giữ lại, nhưng liên kết với tài khoản FINORA sẽ bị gỡ.',
      confirmText: 'Gỡ liên kết',
      isDestructive: false,
      icon: Icons.link_off_rounded,
    );
    if (!confirmed) return;
    try {
      await ref.read(loanRepositoryProvider).removeCounterparty(loan.id);
      ref.invalidate(loanDetailProvider(loan.id));
      ref.invalidate(loanListProvider);
      if (mounted) AppToast.success(context, 'Đã gỡ liên kết bạn bè.');
    } catch (error) {
      final message = error is AppException ? error.message : error.toString();
      if (mounted) AppToast.error(context, message);
    }
  }

  String _formatCooldown(Duration duration) {
    if (duration <= Duration.zero) return 'Nhắc nợ';
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loanAsync = ref.watch(loanDetailProvider(widget.loanId));
    final loan = loanAsync.valueOrNull;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chi tiết khoản nợ',
        subtitle: loan != null
            ? '${loan.type == LoanType.lent ? "Cho vay" : "Đi vay"} · ${loan.counterpartyName}'
            : null,
        action: loan == null
            ? null
            : PopupMenuButton<String>(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                    size: 20,
                  ),
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    context.pushNamed(
                      RouteNames.editLoan,
                      pathParameters: {'id': loan.id},
                    );
                  }
                  if (val == 'delete') _deleteLoan(loan);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Chỉnh sửa'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                      ),
                      title: Text('Xóa khoản nợ'),
                    ),
                  ),
                ],
              ),
      ),
      body: loanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          final message =
              error is AppException ? error.message : error.toString();
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(loanDetailProvider(widget.loanId)),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (loan) => _buildBody(loan, isDark),
      ),
    );
  }

  Widget _buildBody(Loan loan, bool isDark) {
    final payments = ref.watch(loanPaymentsProvider(loan.id));
    final lastReminder = ref.watch(reminderCooldownProvider(loan.id));
    final remainingCooldown = lastReminder == null
        ? Duration.zero
        : const Duration(hours: 6) - DateTime.now().difference(lastReminder);
    final remindEnabled = remainingCooldown <= Duration.zero;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Banner Chi Tiết Khoản Nợ ──
          LoanDetailHeroBanner(loan: loan),

          // ── Phần nội dung thân màn hình ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thao tác nhanh
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: loan.effectiveStatus == LoanStatus.settled
                            ? null
                            : () => _recordPayment(loan),
                        icon: const Icon(Icons.add_card_rounded),
                        label: const Text(
                          'Ghi nhận trả nợ',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    if (loan.type == LoanType.lent) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: loan.isLinkedToFriend && remindEnabled
                              ? () => _sendReminder(loan)
                              : null,
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: Text(
                            !loan.isLinkedToFriend
                                ? 'Chưa liên kết'
                                : remindEnabled
                                    ? 'Nhắc nợ'
                                    : _formatCooldown(remainingCooldown),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (loan.isLinkedToFriend) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Đã liên kết với tài khoản bạn bè FINORA.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _removeCounterparty(loan),
                          child: const Text('Gỡ', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Text('Thông tin chi tiết', style: AppTextStyles.titleMedium()),
                const SizedBox(height: 10),
                LoanInformationCard(loan: loan, isDark: isDark),

                const SizedBox(height: 22),
                Text('Lịch sử các đợt thanh toán', style: AppTextStyles.titleMedium()),
                const SizedBox(height: 10),
                payments.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => _InlineError(
                    message:
                        error is AppException ? error.message : error.toString(),
                    onRetry: () => ref.invalidate(loanPaymentsProvider(loan.id)),
                  ),
                  data: (items) => items.isEmpty
                      ? _EmptyPayments(isDark: isDark)
                      : LoanPaymentTimeline(payments: items, isDark: isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPayments extends StatelessWidget {
  const _EmptyPayments({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 44,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có đợt thanh toán nào được ghi nhận.',
              style: AppTextStyles.bodySmall(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(message),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
