import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/solarn_header.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/budget_enums.dart';
import '../../domain/models/budget_input.dart';
import '../../domain/validators/budget_validators.dart';
import '../providers/budget_detail_provider.dart';
import '../providers/budget_form_provider.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({
    super.key,
    this.initialBudget,
    this.budgetId,
  });

  final Budget? initialBudget;
  final String? budgetId;

  bool get isEditing =>
      initialBudget != null || (budgetId != null && budgetId!.isNotEmpty);

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;

  String? _selectedWalletId;
  String? _selectedCategoryId;
  BudgetPeriodType _selectedPeriod = BudgetPeriodType.monthly;
  DateTime _startDate = DateTime.now();
  bool _isRolloverEnabled = true;
  bool _isLoadedFromProvider = false;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController();
    final b = widget.initialBudget;
    if (b != null) {
      _populateFromBudget(b);
    } else {
      _selectedWalletId = '11111111-1111-4111-8111-111111111111';
      _selectedCategoryId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    }
  }

  void _populateFromBudget(Budget b) {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    _limitController.text = formatter.format(b.limitAmount).trim();
    _selectedWalletId = b.walletId;
    _selectedCategoryId = b.categoryId;
    _selectedPeriod = b.periodType;
    _startDate = b.startDate;
    _isRolloverEnabled = b.isRolloverEnabled;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> _buildWalletItems(Budget? currentBudget) {
    final map = <String, String>{
      '11111111-1111-4111-8111-111111111111': 'Ví Cá Nhân (VND)',
      '22222222-2222-4222-8222-222222222222': 'Ví Gia Đình (VND)',
    };
    if (_selectedWalletId != null && !map.containsKey(_selectedWalletId)) {
      map[_selectedWalletId!] =
          currentBudget?.walletName ?? 'Ví chi tiêu (${_selectedWalletId!.substring(0, 8)})';
    }
    return map.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList();
  }

  List<DropdownMenuItem<String>> _buildCategoryItems(Budget? currentBudget) {
    final map = <String, String>{
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa': '🍔 Ăn uống & Tiệc tùng',
      'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb': '🛍️ Mua sắm & Thời trang',
      'cccccccc-cccc-4ccc-8ccc-cccccccccccc': '☕ Cà phê & Gặp gỡ',
      'dddddddd-dddd-4ddd-8ddd-dddddddddddd': '🚗 Di chuyển & Xăng xe',
      'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee': '⚡ Hoá đơn & Tiện ích',
    };
    if (_selectedCategoryId != null && !map.containsKey(_selectedCategoryId)) {
      map[_selectedCategoryId!] =
          currentBudget?.categoryName ?? 'Danh mục (${_selectedCategoryId!.substring(0, 8)})';
    }
    return map.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList();
  }

  Future<void> _submit(String? activeId) async {
    if (!_formKey.currentState!.validate()) return;

    final limitRaw =
        _limitController.text.replaceAll(RegExp(r'[\.,\s₫VND]'), '');
    final limitAmount = double.tryParse(limitRaw) ?? 0.0;

    final input = BudgetInput(
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
      limitAmount: limitAmount,
      periodType: _selectedPeriod,
      startDate: _startDate,
      isRolloverEnabled: _isRolloverEnabled,
    );

    final formNotifier = ref.read(budgetFormProvider(activeId).notifier);
    final result = await formNotifier.submit(input);

    if (!mounted) return;

    if (result != null) {
      AppToast.show(
        context,
        message: widget.isEditing
            ? 'Cập nhật ngân sách thành công!'
            : 'Tạo mới ngân sách thành công!',
        type: ToastType.success,
      );
      Navigator.pop(context, result);
    } else {
      final err = ref.read(budgetFormProvider(activeId)).errorMessage;
      if (err != null) {
        AppToast.show(
          context,
          message: err,
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeId = widget.initialBudget?.id ?? widget.budgetId;

    // Nếu vào qua router với budgetId mà chưa có initialBudget
    if (widget.initialBudget == null && widget.budgetId != null) {
      final detailAsync = ref.watch(budgetDetailProvider(widget.budgetId!));
      return detailAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Lỗi')),
          body: Center(child: Text(err.toString())),
        ),
        data: (data) {
          if (!_isLoadedFromProvider) {
            _isLoadedFromProvider = true;
            _populateFromBudget(data.budget);
          }
          return _buildScaffold(context, isDark, activeId, data.budget);
        },
      );
    }

    return _buildScaffold(context, isDark, activeId, widget.initialBudget);
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isDark,
    String? activeId,
    Budget? currentBudget,
  ) {
    final formState = ref.watch(budgetFormProvider(activeId));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: SolarnHeader.subPage(
        title: widget.isEditing ? 'Chỉnh sửa ngân sách' : 'Thiết lập ngân sách mới',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Banner lỗi từ Backend nếu có
            if (formState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formState.errorMessage!,
                        style: GoogleFonts.inter(
                            color: AppColors.danger, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 1. Chọn ví chi tiêu
            Text(
              '1. Chọn Ví chi tiêu *',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedWalletId,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: BudgetValidators.validateWalletId,
              items: _buildWalletItems(currentBudget),
              onChanged: (val) => setState(() => _selectedWalletId = val),
            ),
            const SizedBox(height: 20),

            // 2. Chọn Danh mục chi tiêu
            Text(
              '2. Chọn Danh mục chi tiêu *',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '*(Lưu ý: Chỉ áp dụng cho danh mục Chi tiêu - EXPENSE)*',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.lightMuted,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: BudgetValidators.validateCategoryId,
              items: _buildCategoryItems(currentBudget),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            const SizedBox(height: 20),

            // 3. Hạn mức chi tiêu mong muốn
            Text(
              '3. Hạn mức chi tiêu mong muốn *',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Ví dụ: 5.000.000',
                suffixText: 'VND',
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: BudgetValidators.validateLimitAmount,
            ),
            const SizedBox(height: 20),

            // 4. Chu kỳ ngân sách
            Text(
              '4. Chu kỳ ngân sách',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: BudgetPeriodType.values.map((p) {
                final isSelected = _selectedPeriod == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(child: Text(p.label)),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedPeriod = p),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 5. Ngày bắt đầu kỳ
            Text(
              '5. Ngày bắt đầu áp dụng',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(_startDate),
                      style: GoogleFonts.inter(fontSize: 15),
                    ),
                    const Icon(Icons.calendar_today_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Tính năng Rollover
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.autorenew_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Cộng dồn ngân sách (Rollover)',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isRolloverEnabled,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) =>
                            setState(() => _isRolloverEnabled = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tự động cộng dồn số tiền chưa dùng hết của kỳ trước sang kỳ tiếp theo, hoặc trừ bớt nếu bạn chi tiêu vượt quá hạn mức.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: formState.isSubmitting
                    ? null
                    : () => _submit(activeId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: formState.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        widget.isEditing ? 'Cập nhật' : 'Hoàn tất & Kích hoạt',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
