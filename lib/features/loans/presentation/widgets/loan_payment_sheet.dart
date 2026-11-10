import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_input.dart';
import '../../domain/models/loan_type.dart';
import '../../domain/validators/loan_validators.dart';
import '../providers/loan_list_provider.dart';
import '../providers/loan_providers.dart';

class LoanPaymentSheet extends ConsumerStatefulWidget {
  const LoanPaymentSheet({super.key, required this.loan});

  final Loan loan;

  @override
  ConsumerState<LoanPaymentSheet> createState() => _LoanPaymentSheetState();
}

class _LoanPaymentSheetState extends ConsumerState<LoanPaymentSheet> {
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
      double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

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
              walletId: walletId.isEmpty ? widget.loan.sourceWalletId : walletId,
              accountId: widget.loan.accountId ?? (walletId.isEmpty ? null : walletId),
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
                decoration: const InputDecoration(
                  labelText: 'Số tiền trả (₫)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
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
                    label: const Text('Trả 50%'),
                    onPressed: () => setState(() {
                      _amountController.text =
                          (widget.loan.remainingAmount / 2).floor().toString();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormCard(
                title: 'Đồng bộ ví tiền',
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    widget.loan.type == LoanType.lent
                        ? 'Tự động cộng vào ví nhận tiền'
                        : 'Tự động trừ từ ví thanh toán',
                    style: AppTextStyles.bodyMedium(),
                  ),
                  value: _affectsBalance,
                  onChanged: (value) => setState(() => _affectsBalance = value),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _chooseDate,
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(
                  'Ngày thanh toán: ${DateFormat('dd/MM/yyyy').format(_paymentDate)}',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú đợt thanh toán',
                  hintText: 'vd: Trả đợt 1, chuyển khoản qua Vietcombank...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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

