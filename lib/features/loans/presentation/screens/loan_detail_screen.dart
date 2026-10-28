import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_input.dart';
import '../../domain/models/loan_payment.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import '../../domain/validators/loan_validators.dart';
import '../providers/loan_list_provider.dart';
import '../providers/loan_providers.dart';

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
      builder: (_) => _PaymentSheet(loan: loan),
    );
    if (!mounted || settled == null) return;
    AppToast.success(
      context,
      settled
          ? 'Khoản nợ đã được tất toán. Chúc mừng bạn!'
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
          content: const Text('Toàn bộ khoản nợ đã được thanh toán.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
        if (DateTime.now().difference(
              ref.read(reminderCooldownProvider(loan.id))!,
            ) >=
            const Duration(hours: 6)) {
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

  Future<void> _editLoan(Loan loan) async {
    final input = await showDialog<LoanUpdateInput>(
      context: context,
      builder: (_) => _EditLoanDialog(loan: loan),
    );
    if (input == null) return;
    try {
      await ref.read(loanRepositoryProvider).updateLoan(loan.id, input);
      ref.invalidate(loanDetailProvider(loan.id));
      ref.invalidate(loanListProvider);
      ref.invalidate(loanSummaryProvider);
      if (mounted) AppToast.success(context, 'Đã cập nhật khoản nợ.');
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
        Navigator.of(context).pop();
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Chi tiết khoản nợ', style: AppTextStyles.titleLarge()),
        centerTitle: true,
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        actions: [
          loanAsync.maybeWhen(
            data: (loan) {
              final paymentState = ref.watch(loanPaymentsProvider(loan.id));
              final canDelete = paymentState.maybeWhen(
                data: (items) => items.isEmpty,
                orElse: () => false,
              );
              return PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') _editLoan(loan);
                  if (action == 'delete') _deleteLoan(loan);
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
                  if (canDelete)
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                        ),
                        title: Text('Xóa khoản nợ'),
                      ),
                    ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
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
        data: (loan) => _buildDetails(loan, isDark),
      ),
    );
  }

  Widget _buildDetails(Loan loan, bool isDark) {
    final payments = ref.watch(loanPaymentsProvider(loan.id));
    final lastReminder = ref.watch(reminderCooldownProvider(loan.id));
    final remainingCooldown = lastReminder == null
        ? Duration.zero
        : const Duration(hours: 6) - DateTime.now().difference(lastReminder);
    final remindEnabled = remainingCooldown <= Duration.zero;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _LoanHero(loan: loan, isDark: isDark),
        if (loan.isLinkedToFriend) ...[
          const SizedBox(height: 12),
          Card(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khoản nợ này được liên kết với bạn bè FINORA.',
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _removeCounterparty(loan),
                      icon: const Icon(Icons.link_off_rounded),
                      label: const Text('Gỡ liên kết của tôi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text('Thao tác nhanh', style: AppTextStyles.titleMedium()),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: loan.effectiveStatus == LoanStatus.settled
                    ? null
                    : () => _recordPayment(loan),
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Ghi nhận trả nợ'),
              ),
            ),
            if (loan.type == LoanType.lent) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
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
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _InformationCard(loan: loan, isDark: isDark),
        const SizedBox(height: 20),
        Text('Lịch sử thanh toán', style: AppTextStyles.titleMedium()),
        const SizedBox(height: 8),
        payments.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => _InlineError(
            message: error is AppException ? error.message : error.toString(),
            onRetry: () => ref.invalidate(loanPaymentsProvider(loan.id)),
          ),
          data: (items) => items.isEmpty
              ? _EmptyPayments(isDark: isDark)
              : _PaymentTimeline(payments: items, isDark: isDark),
        ),
        payments.maybeWhen(
          data: (items) => items.isEmpty
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                      onPressed: () => _deleteLoan(loan),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Xóa khoản nợ'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      )),
                )
              : const SizedBox.shrink(),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
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

class _LoanHero extends StatelessWidget {
  const _LoanHero({required this.loan, required this.isDark});

  final Loan loan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final loanStatus = loan.effectiveStatus;
    final dueText = loan.dueDate == null
        ? 'Chưa đặt hạn thanh toán'
        : 'Hạn ${DateFormat('dd/MM/yyyy').format(loan.dueDate!)}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.balanceGradStart,
            AppColors.balanceGradMid,
            AppColors.balanceGradEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              loan.counterpartyName.isEmpty
                  ? '?'
                  : loan.counterpartyName.substring(0, 1).toUpperCase(),
              style: AppTextStyles.titleMedium(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loan.counterpartyName,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatVnd(loan.remainingAmount),
            style: AppTextStyles.amountCard(color: Colors.white),
          ),
          Text(
            'Còn lại · Đã trả ${(loan.repaidPercent * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.bodySmall(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Chip(
            avatar: Icon(
              loanStatus == LoanStatus.overdue
                  ? Icons.warning_amber_rounded
                  : Icons.event_available_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              loanStatus == LoanStatus.overdue
                  ? '${loan.overdueDays ?? 0} ngày quá hạn'
                  : dueText,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            side: BorderSide.none,
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
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin khoản nợ', style: AppTextStyles.titleMedium()),
            const SizedBox(height: 12),
            _InfoRow(label: 'Loại', value: loan.type.displayName),
            _InfoRow(
              label: 'Số tiền gốc',
              value: CurrencyFormatter.formatVnd(loan.principalAmount),
            ),
            _InfoRow(
              label: 'Đã thanh toán',
              value: CurrencyFormatter.formatVnd(loan.paidAmount),
            ),
            _InfoRow(
              label: 'Tài khoản nguồn',
              value: loan.sourceWalletName ??
                  loan.sourceWalletId ??
                  'Chưa liên kết ví',
            ),
            _InfoRow(
              label: 'Ngày tạo',
              value: DateFormat('dd/MM/yyyy').format(loan.createdAt),
            ),
            _InfoRow(
              label: 'Lãi suất',
              value: '${loan.interestRate ?? 0}% / '
                  '${loan.interestPeriod == 'year' ? 'năm' : 'tháng'}',
            ),
            if (loan.installmentMonths != null)
              _InfoRow(
                label: 'Trả góp',
                value: '${loan.currentInstallment ?? 0}/'
                    '${loan.installmentMonths} kỳ',
              ),
            if (loan.notes?.isNotEmpty == true)
              _InfoRow(label: 'Ghi chú', value: loan.notes!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: AppTextStyles.bodyMedium()),
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
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        children: [
          for (var index = 0; index < payments.length; index++)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.success.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                ),
              ),
              title: Text(
                CurrencyFormatter.formatVnd(payments[index].amount),
                style: AppTextStyles.titleSmall(),
              ),
              subtitle: Text(
                [
                  DateFormat('dd/MM/yyyy · HH:mm')
                      .format(payments[index].paymentDate),
                  if (payments[index].walletName != null)
                    'Ví: ${payments[index].walletName}',
                  if (payments[index].notes?.isNotEmpty == true)
                    payments[index].notes!,
                ].join('\n'),
                style: AppTextStyles.bodySmall(color: muted),
              ),
              isThreeLine: payments[index].notes?.isNotEmpty == true,
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
  Widget build(BuildContext context) => Card(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Chưa có đợt thanh toán nào được ghi nhận.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(),
          ),
        ),
      );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: AppColors.danger),
          title: Text(message),
          trailing: IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      );
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.loan});

  final Loan loan;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _walletIdController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  bool _affectsBalance = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.loan.remainingAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _walletIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _parseAmount(String value) =>
      double.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final walletId = _walletIdController.text.trim();
    final notes = _notesController.text.trim();
    try {
      await ref.read(loanRepositoryProvider).recordPayment(
            widget.loan.id,
            LoanPaymentInput(
              amount: _parseAmount(_amountController.text),
              paymentDate: _paymentDate,
              affectsBalance: _affectsBalance,
              walletId: walletId.isEmpty ? null : walletId,
              notes: notes.isEmpty ? null : notes,
            ),
          );
      final isSettled =
          _parseAmount(_amountController.text) >= widget.loan.remainingAmount;
      ref.invalidate(loanDetailProvider(widget.loan.id));
      ref.invalidate(loanPaymentsProvider(widget.loan.id));
      ref.invalidate(loanListProvider);
      ref.invalidate(loanSummaryProvider);
      if (mounted) Navigator.of(context).pop(isSettled);
    } catch (error) {
      final message = error is AppException ? error.message : error.toString();
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = message;
        });
      }
    }
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected != null) setState(() => _paymentDate = selected);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ghi nhận đợt thanh toán',
                style: AppTextStyles.titleLarge(),
              ),
              const SizedBox(height: 4),
              Text(
                'Số tiền còn nợ: '
                '${CurrencyFormatter.formatVnd(widget.loan.remainingAmount)}',
                style: AppTextStyles.bodyMedium(color: AppColors.primary),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: AppTextStyles.bodyMedium(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Số tiền trả (₫)'),
                validator: (value) => LoanValidators.validatePaymentAmount(
                  value,
                  widget.loan.remainingAmount,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Trả hết'),
                    onPressed: () => setState(() {
                      _amountController.text =
                          widget.loan.remainingAmount.toStringAsFixed(0);
                    }),
                  ),
                  ActionChip(
                    label: const Text('Trả một nửa'),
                    onPressed: () => setState(() {
                      _amountController.text =
                          (widget.loan.remainingAmount / 2).floor().toString();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _walletIdController,
                decoration: const InputDecoration(
                  labelText: 'Mã ví (nếu đã biết)',
                  helperText:
                      'Danh sách ví chưa được tích hợp; mã ví không được tra cứu tại đây.',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  widget.loan.type == LoanType.lent
                      ? 'Tự động cộng vào ví nhận tiền'
                      : 'Tự động trừ từ ví thanh toán',
                ),
                value: _affectsBalance,
                onChanged: (value) => setState(() => _affectsBalance = value),
              ),
              OutlinedButton.icon(
                onPressed: _chooseDate,
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(DateFormat('dd/MM/yyyy').format(_paymentDate)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú đợt thanh toán',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isSubmitting ? 'Đang ghi nhận...' : 'Xác nhận'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditLoanDialog extends StatefulWidget {
  const _EditLoanDialog({required this.loan});

  final Loan loan;

  @override
  State<_EditLoanDialog> createState() => _EditLoanDialogState();
}

class _EditLoanDialogState extends State<_EditLoanDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.loan.counterpartyName);
    _notesController = TextEditingController(text: widget.loan.notes ?? '');
    _dueDate = widget.loan.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: DateTime(today.year - 10),
      lastDate: DateTime(today.year + 30),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  void _save() {
    final name = _nameController.text.trim();
    final nameError = LoanValidators.validateCounterpartyName(name);
    if (nameError != null) {
      AppToast.error(context, nameError);
      return;
    }
    Navigator.of(context).pop(
      LoanUpdateInput(
        counterpartyName: name,
        dueDate: _dueDate,
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Chỉnh sửa khoản nợ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Đối tác'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue:
                    CurrencyFormatter.formatVnd(widget.loan.principalAmount),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Số tiền gốc (không thể chỉnh sửa)',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(
                  _dueDate == null
                      ? 'Chọn hạn thanh toán'
                      : DateFormat('dd/MM/yyyy').format(_dueDate!),
                ),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(onPressed: _save, child: const Text('Lưu')),
        ],
      );
}
