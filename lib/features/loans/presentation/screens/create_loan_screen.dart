import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/loan_input.dart';
import '../../domain/models/loan_type.dart';
import '../../domain/validators/loan_validators.dart';
import '../providers/loan_form_provider.dart';

class CreateLoanScreen extends ConsumerStatefulWidget {
  const CreateLoanScreen({super.key});

  @override
  ConsumerState<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends ConsumerState<CreateLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _friendIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _walletIdController = TextEditingController();
  final _interestController = TextEditingController();
  final _notesController = TextEditingController();

  LoanType _type = LoanType.lent;
  DateTime? _dueDate;
  int? _installmentMonths;
  bool _affectsBalance = true;
  bool _hasInterest = false;
  String _interestPeriod = 'month';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _friendIdController.dispose();
    _amountController.dispose();
    _walletIdController.dispose();
    _interestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: DateTime(today.year - 10),
      lastDate: DateTime(today.year + 30),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  double _parseAmount(String value) =>
      double.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final friendId = _friendIdController.text.trim();
    final phone = _phoneController.text.trim();
    final walletId = _walletIdController.text.trim();
    final notes = _notesController.text.trim();
    final input = LoanInput(
      type: _type,
      counterpartyName: _nameController.text.trim(),
      counterpartyPhone: phone.isEmpty ? null : phone,
      counterpartyUserId: friendId.isEmpty ? null : friendId,
      principalAmount: _parseAmount(_amountController.text),
      sourceWalletId: walletId.isEmpty ? null : walletId,
      affectsBalance: _affectsBalance,
      dueDate: _dueDate,
      interestRate: _hasInterest
          ? double.parse(_interestController.text.trim().replaceAll(',', '.'))
          : 0,
      interestPeriod: _interestPeriod,
      notes: notes.isEmpty ? null : notes,
      installmentMonths:
          _type == LoanType.installment ? _installmentMonths : null,
    );

    final saved = await ref.read(loanFormProvider.notifier).submit(input);
    if (saved != null && mounted) {
      AppToast.success(context, 'Đã thêm khoản nợ vào sổ thành công.');
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(loanFormProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Thêm khoản vay / nợ', style: AppTextStyles.titleLarge()),
        centerTitle: true,
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (formState.errorMessage != null)
              _FormError(message: formState.errorMessage!),
            _SectionCard(
              title: 'Loại khoản nợ',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in LoanType.values)
                    ChoiceChip(
                      label: Text(type.displayName),
                      selected: type == _type,
                      onSelected: (_) => setState(() {
                        _type = type;
                        if (type != LoanType.installment) {
                          _installmentMonths = null;
                        }
                      }),
                      selectedColor: AppColors.primary.withValues(alpha: 0.16),
                    ),
                ],
              ),
            ),
            _SectionCard(
              title: _type == LoanType.installment
                  ? 'Thông tin đơn vị / cửa hàng'
                  : 'Người vay / đối tác',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Tên người hoặc đơn vị *',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: LoanValidators.validateCounterpartyName,
                  ),
                  if (_type != LoanType.installment) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9 +()-]')),
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại (không bắt buộc)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: LoanValidators.validatePhone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _friendIdController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Mã tài khoản FINORA (nếu đã biết)',
                        helperText:
                            'Danh bạ bạn bè chưa được tích hợp; không có chức năng tìm/chọn bạn tại đây.',
                        prefixIcon: Icon(Icons.people_outline_rounded),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _SectionCard(
              title: 'Số tiền gốc',
              child: TextFormField(
                controller: _amountController,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Số tiền (₫) *',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: LoanValidators.validatePrincipalAmount,
              ),
            ),
            if (_type == LoanType.installment)
              _SectionCard(
                title: 'Kế hoạch trả góp',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _installmentMonths,
                      decoration: const InputDecoration(
                        labelText: 'Số kỳ thanh toán',
                      ),
                      items: const [3, 6, 12, 24]
                          .map((months) => DropdownMenuItem(
                                value: months,
                                child: Text('$months tháng'),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _installmentMonths = value),
                      validator: (value) =>
                          value == null ? 'Vui lòng chọn số kỳ trả góp' : null,
                    ),
                    if (_installmentMonths != null &&
                        _amountController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Dự kiến ${CurrencyFormatter.formatVnd(_parseAmount(_amountController.text) / _installmentMonths!)} / tháng',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            _SectionCard(
              title: 'Ví và ảnh hưởng số dư',
              child: Column(
                children: [
                  TextFormField(
                    controller: _walletIdController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mã ví (nếu đã biết)',
                      helperText:
                          'Danh sách ví và số dư chưa được tích hợp; mã ví không được tra cứu/xác nhận tại đây.',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tự động cập nhật số dư ví'),
                    subtitle: Text(
                      _type == LoanType.lent
                          ? 'Trừ tiền khi ghi nhận khoản cho vay.'
                          : 'Đồng bộ số dư theo loại khoản nợ.',
                    ),
                    value: _affectsBalance,
                    onChanged: (value) =>
                        setState(() => _affectsBalance = value),
                  ),
                ],
              ),
            ),
            _SectionCard(
              title: 'Hạn hoàn trả',
              child: OutlinedButton.icon(
                onPressed: _selectDueDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(
                  _dueDate == null
                      ? 'Chọn ngày đến hạn (không bắt buộc)'
                      : DateFormat('dd/MM/yyyy').format(_dueDate!),
                ),
              ),
            ),
            _SectionCard(
              title: 'Lãi suất',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Khoản vay có tính lãi'),
                    value: _hasInterest,
                    onChanged: (value) => setState(() => _hasInterest = value),
                  ),
                  if (_hasInterest)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _interestController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Lãi suất (%)',
                            ),
                            validator: (value) => _hasInterest
                                ? (value?.trim().isEmpty == true
                                    ? 'Vui lòng nhập lãi suất'
                                    : LoanValidators.validateInterestRate(
                                        value))
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _interestPeriod,
                          items: const [
                            DropdownMenuItem(
                              value: 'month',
                              child: Text('Mỗi tháng'),
                            ),
                            DropdownMenuItem(
                              value: 'year',
                              child: Text('Mỗi năm'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _interestPeriod = value);
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            _SectionCard(
              title: 'Ghi chú / mục đích',
              child: TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Ghi lại mục đích hoặc thỏa thuận thanh toán',
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: formState.isSubmitting ? null : _submit,
              icon: formState.isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.handshake_rounded),
              label: Text(
                formState.isSubmitting ? 'Đang lưu...' : 'Tạo và lưu vào sổ nợ',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleSmall()),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium(color: AppColors.danger),
              ),
            ),
          ],
        ),
      );
}
