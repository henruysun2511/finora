import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:finora_mb/features/transactions/domain/models/transaction_enums.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/recurring_enums.dart';
import '../../domain/models/recurring_transaction.dart';
import '../../domain/models/recurring_transaction_input.dart';
import '../../domain/validators/recurring_transaction_validators.dart';
import '../providers/recurring_transaction_list_provider.dart';

// ─── Lightweight providers để load accounts & categories ─────────────────────

final _accountsForFormProvider =
    FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.accounts);
  final data = res.data['data'];
  final List items =
      data is Map ? (data['items'] ?? data['data'] ?? []) : (data ?? []);
  return items
      .map<Map<String, String>>((e) => {
            'id': e['id']?.toString() ?? '',
            'name': e['name']?.toString() ?? '',
            'walletId': e['walletId']?.toString() ?? '',
          })
      .where((e) => e['id']!.isNotEmpty)
      .toList();
});

final _categoriesForFormProvider =
    FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.categories);
  final data = res.data['data'];
  final List items =
      data is Map ? (data['items'] ?? data['data'] ?? []) : (data ?? []);
  return items
      .map<Map<String, String>>((e) => {
            'id': e['id']?.toString() ?? '',
            'name': e['name']?.toString() ?? '',
          })
      .where((e) => e['id']!.isNotEmpty)
      .toList();
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class RecurringTransactionFormScreen extends ConsumerStatefulWidget {
  const RecurringTransactionFormScreen({
    super.key,
    this.initialRule,
  });

  final RecurringTransaction? initialRule;

  @override
  ConsumerState<RecurringTransactionFormScreen> createState() =>
      _RecurringTransactionFormScreenState();
}

class _RecurringTransactionFormScreenState
    extends ConsumerState<RecurringTransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  String? _selectedAccountId;
  String? _selectedWalletId;
  String? _selectedCategoryId;
  bool _executeImmediately = false;
  bool _isPaused = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool get _isEdit => widget.initialRule != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final rule = widget.initialRule!;
      _nameController.text = rule.name;
      _amountController.text = rule.amount.toStringAsFixed(0);
      _type = rule.type;
      _frequency = rule.frequency;
      _selectedCategoryId = rule.categoryId;
      _startDate = rule.nextRunDate;
      _endDate = rule.endDate;
      _isPaused = rule.isPaused;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null) {
      AppToast.error(context, 'Số tiền không hợp lệ');
      return;
    }

    if (_selectedAccountId == null || _selectedWalletId == null) {
      AppToast.error(context, 'Vui lòng chọn tài khoản thanh toán');
      return;
    }
    if (_selectedCategoryId == null) {
      AppToast.error(context, 'Vui lòng chọn danh mục');
      return;
    }

    final input = RecurringTransactionInput(
      walletId: _selectedWalletId!,
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      name: _nameController.text.trim(),
      type: _type,
      amount: amount,
      frequency: _frequency,
      startDate: _startDate,
      endDate: _endDate,
      executeImmediately: _executeImmediately,
      isPaused: _isPaused,
    );

    if (_isEdit) {
      final updated = await ref
          .read(recurringTransactionFormProvider.notifier)
          .update(widget.initialRule!.id, input);

      if (!mounted) return;

      if (updated != null) {
        AppToast.success(context, 'Đã cập nhật quy tắc định kỳ thành công!');
        Navigator.of(context).pop();
      } else {
        final msg = ref.read(recurringTransactionFormProvider).errorMessage ??
            'Lỗi khi cập nhật';
        AppToast.error(context, msg);
      }
    } else {
      final saved = await ref
          .read(recurringTransactionFormProvider.notifier)
          .submit(input);

      if (!mounted) return;

      if (saved != null) {
        AppToast.success(context, 'Đã tạo quy tắc định kỳ thành công!');
        Navigator.of(context).pop();
      } else {
        final msg = ref.read(recurringTransactionFormProvider).errorMessage ??
            'Lỗi không xác định';
        AppToast.error(context, msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsAsync = ref.watch(_accountsForFormProvider);
    final categoriesAsync = ref.watch(_categoriesForFormProvider);
    final formState = ref.watch(recurringTransactionFormProvider);

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final fg = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: _isEdit ? 'Sửa giao dịch định kỳ' : 'Thêm giao dịch định kỳ',
        subtitle: _isEdit
            ? 'Cập nhật cấu hình quy tắc tự động'
            : 'Thiết lập tự động hoá thu chi',
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Không thể tải tài khoản: $e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(_accountsForFormProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (accounts) => categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Không thể tải danh mục: $e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(_categoriesForFormProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (categories) {
            // Tự động gán default nếu chưa chọn
            if (_selectedAccountId == null && accounts.isNotEmpty) {
              _selectedAccountId = accounts.first['id'];
              _selectedWalletId = accounts.first['walletId'];
            }
            if (_selectedCategoryId == null && categories.isNotEmpty) {
              _selectedCategoryId = categories.first['id'];
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── 1. Loại giao dịch (Chi tiêu / Thu nhập) ───────────────
                  _SectionLabel(label: 'Loại giao dịch', muted: muted),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          context: context,
                          label: 'Chi tiêu',
                          icon: Icons.arrow_downward_rounded,
                          selected: _type == TransactionType.expense,
                          onSelected: () =>
                              setState(() => _type = TransactionType.expense),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceChip(
                          context: context,
                          label: 'Thu nhập',
                          icon: Icons.arrow_upward_rounded,
                          selected: _type == TransactionType.income,
                          onSelected: () =>
                              setState(() => _type = TransactionType.income),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── 2. Tên quy tắc ───────────────────────────────────────
                  _SectionLabel(label: 'Tên khoản định kỳ', muted: muted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: fg),
                    decoration: _inputDecoration(
                      'VD: Netflix hàng tháng, Tiền thuê nhà, Tiền lương',
                      isDark: isDark,
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                    ),
                    validator: RecurringTransactionValidators.validateName,
                  ),
                  const SizedBox(height: 16),

                  // ── 3. Số tiền ───────────────────────────────────────────
                  _SectionLabel(label: 'Số tiền (VND)', muted: muted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    decoration: _inputDecoration(
                      '0',
                      isDark: isDark,
                      prefixIcon: const Icon(Icons.payments_outlined),
                      suffixText: '₫',
                    ),
                    validator: RecurringTransactionValidators.validateAmount,
                  ),
                  const SizedBox(height: 16),

                  // ── 4. Tài khoản thanh toán ─────────────────────────────
                  _SectionLabel(label: 'Tài khoản nguồn', muted: muted),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    style: TextStyle(color: fg, fontSize: 14),
                    dropdownColor: surface,
                    decoration: _inputDecoration(
                      null,
                      isDark: isDark,
                      prefixIcon:
                          const Icon(Icons.account_balance_wallet_outlined),
                    ),
                    items: accounts.map((acc) {
                      return DropdownMenuItem(
                        value: acc['id'],
                        child: Text(acc['name'] ?? 'Không tên'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final found = accounts.firstWhere((e) => e['id'] == val);
                      setState(() {
                        _selectedAccountId = val;
                        _selectedWalletId = found['walletId'];
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── 5. Danh mục ──────────────────────────────────────────
                  _SectionLabel(label: 'Danh mục', muted: muted),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    style: TextStyle(color: fg, fontSize: 14),
                    dropdownColor: surface,
                    decoration: _inputDecoration(
                      null,
                      isDark: isDark,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat['id'],
                        child: Text(cat['name'] ?? 'Không tên'),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                  ),
                  const SizedBox(height: 20),

                  // ── 6. Chu kỳ lặp ─────────────────────────────────────────
                  _SectionLabel(label: 'Chu kỳ lặp lại', muted: muted),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: RecurringFrequency.values.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildChoiceChip(
                            context: context,
                            label: f.displayName,
                            selected: _frequency == f,
                            onSelected: () => setState(() => _frequency = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── 7. Thời gian hiệu lực ─────────────────────────────────
                  _SectionLabel(label: 'Thời gian hiệu lực', muted: muted),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickStartDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ngày bắt đầu',
                                    style:
                                        TextStyle(fontSize: 11, color: muted)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 14, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Flexible(
                                        child: Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(_startDate),
                                      style: TextStyle(
                                        color: fg,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickEndDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('Ngày kết thúc',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 11, color: muted)),
                                    ),
                                    const SizedBox(width: 8),
                                    if (_endDate != null)
                                      GestureDetector(
                                        onTap: () =>
                                            setState(() => _endDate = null),
                                        child: Icon(Icons.close_rounded,
                                            size: 14, color: muted),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.event_busy_rounded,
                                        size: 14, color: muted),
                                    const SizedBox(width: 6),
                                    Flexible(
                                        child: Text(
                                      _endDate == null
                                          ? 'Vô thời hạn'
                                          : DateFormat('dd/MM/yyyy')
                                              .format(_endDate!),
                                      style: TextStyle(
                                        color: _endDate == null ? muted : fg,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── 8. Cài đặt bổ sung (Chuẩn Rule #3 GEMINI.md) ───────────
                  FormCard(
                    title: 'CÀI ĐẶT BỔ SUNG',
                    child: Column(
                      children: [
                        if (!_isEdit)
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Thực thi ngay lần đầu',
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Ghi nhận giao dịch đầu tiên vào sổ ngay khi lưu',
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                            value: _executeImmediately,
                            onChanged: (val) =>
                                setState(() => _executeImmediately = val),
                          )
                        else
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Tạm dừng quy tắc',
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Quy tắc sẽ tạm ngưng tự động kích hoạt',
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                            value: _isPaused,
                            onChanged: (val) => setState(() => _isPaused = val),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Submit button ─────────────────────────────────────────
                  FilledButton.icon(
                    onPressed: formState.isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: formState.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(_isEdit
                            ? Icons.save_rounded
                            : Icons.check_circle_rounded),
                    label: Text(
                      formState.isSubmitting
                          ? 'Đang xử lý...'
                          : (_isEdit
                              ? 'Lưu thay đổi'
                              : 'Kích hoạt quy tắc định kỳ'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
              child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      side: BorderSide(
        color: selected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

  InputDecoration _inputDecoration(
    String? hint, {
    required bool isDark,
    Widget? prefixIcon,
    String? suffixText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
    final surface = isDark ? AppColors.darkSurface : Colors.white;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: surface,
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.muted});
  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.2,
      ),
    );
  }
}
