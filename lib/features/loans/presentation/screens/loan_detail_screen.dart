import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_payment.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import '../providers/loan_list_provider.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_payment_sheet.dart';

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
          _DetailHeroBanner(loan: loan),

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
                _InformationCard(loan: loan, isDark: isDark),

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
                      : _PaymentTimeline(payments: items, isDark: isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}

class _DetailHeroBanner extends StatelessWidget {
  const _DetailHeroBanner({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final loanStatus = loan.effectiveStatus;
    final formatter = DateFormat('dd/MM/yyyy');
    final dueText = loan.dueDate == null
        ? 'Chưa đặt hạn thanh toán'
        : 'Hạn: ' + formatter.format(loan.dueDate!);

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
          // Hero Content: Avatar + Tên + Số tiền lớn + Badge hạn trả
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
              Text(
                loan.counterpartyName,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
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
            'Số nợ còn lại · Đã thanh toán ' + (loan.repaidPercent * 100).toStringAsFixed(1) + '%',
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
                Text(
                  loanStatus == LoanStatus.overdue
                      ? 'Quá hạn ' + (loan.overdueDays ?? 0).toString() + ' ngày'
                      : dueText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.loan, required this.isDark});

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
          _buildRow('Số tiền gốc ban đầu', CurrencyFormatter.formatVnd(loan.principalAmount)),
          _buildRow('Đã hoàn trả', CurrencyFormatter.formatVnd(loan.paidAmount)),
          if (loan.counterpartyPhone != null)
            _buildRow('Số điện thoại liên hệ', loan.counterpartyPhone!),
          if (loan.sourceWalletName != null || loan.accountName != null)
            _buildRow('Nguồn tài khoản / Ví', loan.accountName ?? loan.sourceWalletName!),
          if (loan.interestRate != null && loan.interestRate! > 0)
            _buildRow('Lãi suất', '${loan.interestRate}% / ${loan.interestPeriod == 'year' ? 'năm' : 'tháng'}'),
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
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTimeline extends StatelessWidget {
  const _PaymentTimeline({required this.payments, required this.isDark});

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
              ),
            ),
          ),
      ],
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
