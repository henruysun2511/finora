import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../friends/friends.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_input.dart';
import '../../domain/models/loan_type.dart';
import '../../domain/validators/loan_validators.dart';
import '../providers/loan_form_provider.dart';
import '../providers/loan_list_provider.dart';

class LoanFormScreen extends ConsumerStatefulWidget {
  const LoanFormScreen({super.key, this.loanId});

  final String? loanId;

  bool get isEditing => loanId != null;

  @override
  ConsumerState<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends ConsumerState<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _friendIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _walletIdController = TextEditingController();
  final _interestController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedFriendId;
  LoanType _type = LoanType.lent;
  DateTime? _dueDate;
  int? _installmentMonths;
  bool _affectsBalance = true;
  bool _hasInterest = false;
  String _interestPeriod = 'month';
  bool _initialDataLoaded = false;

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

  void _populateData(Loan loan) {
    if (_initialDataLoaded) return;
    _initialDataLoaded = true;

    _type = loan.type;
    _nameController.text = loan.counterpartyName;
    _phoneController.text = loan.counterpartyPhone ?? '';
    _selectedFriendId = loan.counterpartyUserId;
    _friendIdController.text = loan.counterpartyUserId ?? '';
    _amountController.text = loan.principalAmount.toInt().toString();
    _walletIdController.text = loan.sourceWalletId ?? '';
    _dueDate = loan.dueDate;
    _notesController.text = loan.notes ?? '';
    _affectsBalance = loan.affectsBalance;
    _installmentMonths = loan.installmentMonths;

    if (loan.interestRate != null && loan.interestRate! > 0) {
      _hasInterest = true;
      _interestController.text = loan.interestRate.toString();
      _interestPeriod = loan.interestPeriod ?? 'month';
    }
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
      double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final friendId = (_selectedFriendId ?? _friendIdController.text).trim();
    final phone = _phoneController.text.trim();
    final walletId = _walletIdController.text.trim();
    final notes = _notesController.text.trim();

    if (widget.isEditing) {
      final input = LoanUpdateInput(
        counterpartyName: _nameController.text.trim(),
        counterpartyPhone: phone.isEmpty ? null : phone,
        counterpartyUserId: friendId.isEmpty ? null : friendId,
        dueDate: _dueDate,
        notes: notes.isEmpty ? null : notes,
        principalAmount: _parseAmount(_amountController.text),
      );

      final updated = await ref
          .read(loanFormProvider.notifier)
          .submitUpdate(widget.loanId!, input);

      if (updated != null && mounted) {
        AppToast.success(context, 'Đã cập nhật khoản nợ thành công.');
        Navigator.of(context).pop(updated);
      }
    } else {
      final input = LoanInput(
        type: _type,
        counterpartyName: _nameController.text.trim(),
        counterpartyPhone: phone.isEmpty ? null : phone,
        counterpartyUserId: friendId.isEmpty ? null : friendId,
        principalAmount: _parseAmount(_amountController.text),
        sourceWalletId: walletId.isEmpty ? null : walletId,
        accountId: walletId.isEmpty ? null : walletId,
        affectsBalance: _affectsBalance,
        dueDate: _dueDate,
        interestRate: _hasInterest
            ? double.tryParse(_interestController.text.trim().replaceAll(',', '.')) ?? 0
            : 0,
        interestPeriod: _interestPeriod,
        notes: notes.isEmpty ? null : notes,
        installmentMonths:
            _type == LoanType.installment ? _installmentMonths : null,
      );

      final saved =
          await ref.read(loanFormProvider.notifier).submitCreate(input);

      if (saved != null && mounted) {
        AppToast.success(context, 'Đã thêm khoản nợ vào sổ thành công.');
        Navigator.of(context).pop(saved);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(loanFormProvider);
    final friendsAsync =
        ref.watch(friendsListProvider).whenData((state) => state.friends);

    if (widget.isEditing) {
      final loanAsync = ref.watch(loanDetailProvider(widget.loanId!));
      return loanAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: const PageHeader.subPage(title: 'Lỗi tải khoản nợ'),
          body: Center(child: Text(err.toString())),
        ),
        data: (loan) {
          _populateData(loan);
          return _buildScaffold(context, isDark, formState, friendsAsync);
        },
      );
    }

    return _buildScaffold(context, isDark, formState, friendsAsync);
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isDark,
    LoanFormState formState,
    AsyncValue<List<Friend>> friendsAsync,
  ) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: widget.isEditing
            ? 'Chỉnh sửa khoản nợ'
            : 'Thêm khoản Vay / Nợ mới',
        subtitle: widget.isEditing
            ? 'Cập nhật số tiền và thông tin liên hệ'
            : 'Ghi nhận khoản cho vay hoặc đi vay',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (formState.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formState.errorMessage!,
                        style: AppTextStyles.bodySmall(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),

            // Phân loại khoản nợ (Chuẩn ChoiceChip đồng bộ form thiết lập ngân sách)
            if (!widget.isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: LoanType.values.map((type) {
                    final isSelected = _type == type;
                    final icon = switch (type) {
                      LoanType.lent => Icons.arrow_outward_rounded,
                      LoanType.borrowed => Icons.south_west_rounded,
                      LoanType.installment => Icons.credit_card_rounded,
                    };
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          avatar: Icon(
                            icon,
                            size: 15,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted),
                          ),
                          label: Center(
                            child: Text(
                              type.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                          showCheckmark: false,
                          onSelected: (_) => setState(() {
                            _type = type;
                            if (type != LoanType.installment) {
                              _installmentMonths = null;
                            }
                          }),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Card 1: Người vay / Đối tác
            _FormCard(
              title: _type == LoanType.installment
                  ? 'Đơn vị / Cửa hàng bán trả góp'
                  : (_type == LoanType.lent
                      ? 'Người mượn tiền của bạn'
                      : 'Người cho bạn mượn tiền'),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên đối tác *',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: LoanValidators.validateCounterpartyName,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại / Thông tin liên hệ',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: LoanValidators.validatePhone,
                  ),
                  const SizedBox(height: 12),
                  _buildFriendSelectField(friendsAsync),
                ],
              ),
            ),

            // Card 2: Số tiền gốc & Kỳ trả góp
            _FormCard(
              title: 'Số tiền & Phương thức',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Số tiền nợ (₫) *',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: LoanValidators.validatePrincipalAmount,
                    onChanged: (_) => setState(() {}),
                  ),

                  // Phần trả góp
                  if (_type == LoanType.installment) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Số kỳ trả góp:',
                      style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [3, 6, 12, 24].map((m) {
                        final isSel = _installmentMonths == m;
                        return ChoiceChip(
                          label: Text('$m tháng'),
                          selected: isSel,
                          onSelected: (_) =>
                              setState(() => _installmentMonths = m),
                          selectedColor: AppColors.primary,
                          backgroundColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          side: BorderSide(
                            color: isSel
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelStyle: TextStyle(
                            color: isSel
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground),
                            fontWeight:
                                isSel ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    if (_installmentMonths != null && _amountController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Dự kiến thanh toán: ~${CurrencyFormatter.formatVnd(_parseAmount(_amountController.text) / _installmentMonths!)} / tháng (0% lãi)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _walletIdController,
                    decoration: const InputDecoration(
                      labelText: 'Mã tài khoản / Nguồn tiền',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      hintText: 'Để trống để dùng ví mặc định',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_rounded),
                    title: Text(
                      _dueDate == null
                          ? 'Chọn hạn thanh toán / hoàn trả'
                          : 'Hạn trả: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    trailing: OutlinedButton(
                      onPressed: _selectDueDate,
                      child: Text(_dueDate == null ? 'Chọn ngày' : 'Đổi ngày'),
                    ),
                  ),
                ],
              ),
            ),

            // Card 3: Đồng bộ số dư & Lãi suất
            _FormCard(
              title: 'Cài đặt bổ sung',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _type == LoanType.lent
                          ? 'Tự động trừ tiền khỏi ví khi tạo khoản cho vay'
                          : 'Tự động cộng tiền vào ví khi nhận khoản vay',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    value: _affectsBalance,
                    onChanged: (v) => setState(() => _affectsBalance = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Có tính lãi suất',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    value: _hasInterest,
                    onChanged: (v) => setState(() => _hasInterest = v),
                  ),
                  if (_hasInterest) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _interestController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Lãi suất (%)',
                              suffixText: '%',
                            ),
                            validator: LoanValidators.validateInterestRate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _interestPeriod,
                            decoration: const InputDecoration(labelText: 'Kỳ hạn'),
                            items: const [
                              DropdownMenuItem(value: 'month', child: Text('Mỗi tháng')),
                              DropdownMenuItem(value: 'year', child: Text('Mỗi năm')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _interestPeriod = v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú / Mục đích',
                      hintText: 'vd: Cho vay cọc phòng trọ, mua xe máy cũ...',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: formState.isSubmitting ? null : _submit,
              icon: formState.isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(
                formState.isSubmitting
                    ? 'Đang lưu...'
                    : (widget.isEditing
                        ? 'Cập nhật khoản nợ'
                        : 'Tạo và lưu vào sổ nợ'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendSelectField(AsyncValue<List<Friend>> friendsAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const LucideIcon(name: 'users', size: 18, color: AppColors.lightMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chưa có bạn bè FINORA để liên kết',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final effectiveValue = friends.any((f) => f.id == _selectedFriendId)
            ? _selectedFriendId
            : null;

        return DropdownButtonFormField<String?>(
          value: effectiveValue,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Liên kết bạn bè FINORA (tùy chọn)',
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: LucideIcon(name: 'user-plus', size: 18, color: AppColors.primary),
            ),
            suffixIcon: _selectedFriendId != null
                ? IconButton(
                    icon: const LucideIcon(name: 'x', size: 16, color: AppColors.lightMuted),
                    tooltip: 'Bỏ chọn bạn bè',
                    onPressed: () {
                      setState(() {
                        _selectedFriendId = null;
                        _friendIdController.clear();
                      });
                    },
                  )
                : null,
          ),
          hint: Text(
            'Chọn bạn bè từ danh bạ...',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightMuted),
          ),
          selectedItemBuilder: (context) {
            return [
              Text(
                'Không liên kết bạn bè',
                style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.lightMuted),
              ),
              ...friends.map((f) {
                return Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0072D6), Color(0xFF0284C7)],
                        ),
                        image: f.avatar != null && f.avatar!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(f.avatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: f.avatar == null || f.avatar!.isEmpty
                          ? Text(
                              f.initials,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${f.displayName} (${f.email})',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }),
            ];
          },
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'Không liên kết bạn bè',
                style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.lightMuted),
              ),
            ),
            ...friends.map((f) {
              return DropdownMenuItem<String?>(
                value: f.id,
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0072D6), Color(0xFF0284C7)],
                        ),
                        image: f.avatar != null && f.avatar!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(f.avatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: f.avatar == null || f.avatar!.isEmpty
                          ? Text(
                              f.initials,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            f.displayName,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (f.email != null &&
                              f.email!.isNotEmpty &&
                              f.email != f.displayName)
                            Text(
                              f.email!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.lightMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (val) {
            setState(() {
              _selectedFriendId = val;
              _friendIdController.text = val ?? '';
              if (val != null) {
                final friend = friends.firstWhere((x) => x.id == val);
                if (_nameController.text.trim().isEmpty) {
                  _nameController.text = friend.displayName;
                }
              }
            });
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

typedef _FormCard = FormCard;
