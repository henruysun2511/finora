import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/recurring-enum.dart';
import '../../domain/models/recurring-transaction-input.dart';
import '../providers/recurring-transaction-list-provider.dart';

// ─── Lightweight providers để load accounts & categories ─────────────────────

/// Trả về danh sách Map {id, name} của tất cả accounts thuộc user
final _accountsForFormProvider =
    FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.accounts);
  final data = res.data['data'];
  final List items = data is Map
      ? (data['items'] ?? data['data'] ?? [])
      : (data ?? []);
  return items
      .map<Map<String, String>>((e) => {
            'id': e['id']?.toString() ?? '',
            'name': e['name']?.toString() ?? '',
            'walletId': e['walletId']?.toString() ?? '',
          })
      .where((e) => e['id']!.isNotEmpty)
      .toList();
});

/// Trả về danh sách Map {id, name} của tất cả categories
final _categoriesForFormProvider =
    FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiConstants.categories);
  final data = res.data['data'];
  final List items = data is Map
      ? (data['items'] ?? data['data'] ?? [])
      : (data ?? []);
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
  const RecurringTransactionFormScreen({super.key});

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
  DateTime _startDate = DateTime.now();

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
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
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
      executeImmediately: _executeImmediately,
    );

    final saved = await ref
        .read(recurringTransactionFormProvider.notifier)
        .submit(input);

    if (!mounted) return;

    if (saved != null) {
      AppToast.success(context, 'Đã tạo quy tắc định kỳ thành công!');
      Navigator.of(context).pop();
    } else {
      final msg =
          ref.read(recurringTransactionFormProvider).errorMessage ?? 'Lỗi không xác định';
      AppToast.error(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(recurringTransactionFormProvider);
    final accountsAsync = ref.watch(_accountsForFormProvider);
    final categoriesAsync = ref.watch(_categoriesForFormProvider);

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final fg = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Tạo quy tắc định kỳ',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: fg),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Không thể tải tài khoản: $e',
                  textAlign: TextAlign.center),
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
                Text('Không thể tải danh mục: $e',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(_categoriesForFormProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (categories) => Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── 1. Tên khoản ──────────────────────────────────────────
                _SectionLabel(label: 'Tên khoản thanh toán', muted: muted),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: fg),
                  decoration: _inputDecoration(
                    'Ví dụ: Netflix, Điện, Internet…',
                    isDark: isDark,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Vui lòng nhập tên'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── 2. Loại giao dịch ──────────────────────────────────────
                _SectionLabel(label: 'Loại giao dịch', muted: muted),
                const SizedBox(height: 8),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Chi tiêu'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Thu nhập'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) =>
                      setState(() => _type = s.first),
                ),
                const SizedBox(height: 16),

                // ── 3. Số tiền ─────────────────────────────────────────────
                _SectionLabel(label: 'Số tiền', muted: muted),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  style: TextStyle(color: fg),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: _inputDecoration(
                    '0',
                    prefixText: '₫ ',
                    isDark: isDark,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Số tiền phải lớn hơn 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── 4. Tài khoản nguồn ────────────────────────────────────
                _SectionLabel(label: 'Tài khoản thanh toán *', muted: muted),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  style: TextStyle(color: fg),
                  dropdownColor: surface,
                  decoration: _inputDecoration(null, isDark: isDark)
                      .copyWith(hintText: 'Chọn tài khoản nguồn'),
                  items: accounts.map((acc) {
                    return DropdownMenuItem<String>(
                      value: acc['id'],
                      child: Text(acc['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final acc = accounts.firstWhere((a) => a['id'] == val,
                        orElse: () => {});
                    setState(() {
                      _selectedAccountId = val;
                      _selectedWalletId = acc['walletId'];
                    });
                  },
                  validator: (v) =>
                      v == null ? 'Vui lòng chọn tài khoản' : null,
                ),
                const SizedBox(height: 16),

                // ── 5. Danh mục ───────────────────────────────────────────
                _SectionLabel(label: 'Danh mục *', muted: muted),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  style: TextStyle(color: fg),
                  dropdownColor: surface,
                  decoration: _inputDecoration(null, isDark: isDark)
                      .copyWith(hintText: 'Chọn danh mục giao dịch'),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id'],
                      child: Text(cat['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCategoryId = val),
                  validator: (v) =>
                      v == null ? 'Vui lòng chọn danh mục' : null,
                ),
                const SizedBox(height: 16),

                // ── 6. Chu kỳ lặp ─────────────────────────────────────────
                _SectionLabel(label: 'Chu kỳ lặp lại', muted: muted),
                const SizedBox(height: 6),
                DropdownButtonFormField<RecurringFrequency>(
                  value: _frequency,
                  style: TextStyle(color: fg),
                  dropdownColor: surface,
                  decoration: _inputDecoration(null, isDark: isDark),
                  items: RecurringFrequency.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f.displayName),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _frequency = val ?? _frequency),
                ),
                const SizedBox(height: 16),

                // ── 7. Ngày bắt đầu ───────────────────────────────────────
                _SectionLabel(label: 'Ngày bắt đầu', muted: muted),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickStartDate,
                  borderRadius: BorderRadius.circular(AppColors.radiusSm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusSm),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: muted),
                        const SizedBox(width: 10),
                        Text(
                          '${_startDate.day.toString().padLeft(2, '0')}/'
                          '${_startDate.month.toString().padLeft(2, '0')}/'
                          '${_startDate.year}',
                          style: TextStyle(color: fg),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── 8. Thực thi ngay ──────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius:
                        BorderRadius.circular(AppColors.radiusSm),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      'Thực thi giao dịch ngay khi tạo',
                      style: TextStyle(color: fg, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Ghi nhận giao dịch đầu tiên ngay lập tức',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    value: _executeImmediately,
                    onChanged: (v) =>
                        setState(() => _executeImmediately = v ?? false),
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusSm),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Submit button ─────────────────────────────────────────
                FilledButton.icon(
                  onPressed: formState.isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusSm),
                    ),
                  ),
                  icon: formState.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bolt_rounded),
                  label: Text(
                    formState.isSubmitting
                        ? 'Đang lưu…'
                        : 'Kích hoạt quy tắc định kỳ',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String? hint, {
    String? prefixText,
    required bool isDark,
  }) {
    final surface =
        isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: TextStyle(color: muted),
      filled: true,
      fillColor: surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
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
        color: muted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}