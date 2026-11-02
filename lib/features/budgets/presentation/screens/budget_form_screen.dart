import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/budget_enums.dart';
import '../../domain/models/budget_input.dart';
import '../../domain/validators/budget_validators.dart';
import '../providers/budget_form_provider.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({
    super.key,
    this.initialBudget,
  });

  final Budget? initialBudget;

  bool get isEditing => initialBudget != null;

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

  @override
  void initState() {
    super.initState();
    final b = widget.initialBudget;
    if (b != null) {
      final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
      _limitController = TextEditingController(text: formatter.format(b.limitAmount).trim());
      _selectedWalletId = b.walletId;
      _selectedCategoryId = b.categoryId;
      _selectedPeriod = b.periodType;
      _startDate = b.startDate;
      _isRolloverEnabled = b.isRolloverEnabled;
    } else {
      _limitController = TextEditingController();
      _selectedWalletId = 'personal';
      _selectedCategoryId = 'food';
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final limitRaw = _limitController.text.replaceAll(RegExp(r'[\.,\s₫VND]'), '');
    final limitAmount = double.tryParse(limitRaw) ?? 0.0;

    final input = BudgetInput(
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
      limitAmount: limitAmount,
      periodType: _selectedPeriod,
      startDate: _startDate,
      isRolloverEnabled: _isRolloverEnabled,
    );

    final formNotifier = ref.read(budgetFormProvider(widget.initialBudget?.id).notifier);
    final result = await formNotifier.submit(input);

    if (!mounted) return;

    if (result != null) {
      AppToast.show(
        context,
        message: widget.isEditing ? 'Cập nhật ngân sách thành công!' : 'Tạo mới ngân sách thành công!',
        type: ToastType.success,
      );
      Navigator.pop(context, result);
    } else {
      final err = ref.read(budgetFormProvider(widget.initialBudget?.id)).errorMessage;
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
    final formState = ref.watch(budgetFormProvider(widget.initialBudget?.id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Chỉnh sửa ngân sách' : 'Thiết lập ngân sách mới',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Banner lỗi từ Backend nếu có (Lớp 2 validation)
            if (formState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formState.errorMessage!,
                        style: GoogleFonts.inter(color: AppColors.danger, fontSize: 13),
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
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedWalletId,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: BudgetValidators.validateWalletId,
              items: const [
                DropdownMenuItem(value: 'personal', child: Text('Ví Cá Nhân (VND)')),
                DropdownMenuItem(value: 'family', child: Text('Ví Gia Đình (VND)')),
              ],
              onChanged: (val) => setState(() => _selectedWalletId = val),
            ),
            const SizedBox(height: 20),

            // 2. Chọn Danh mục chi tiêu
            Text(
              '2. Chọn Danh mục chi tiêu *',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '*(Lưu ý: Chỉ áp dụng cho danh mục Chi tiêu - EXPENSE)*',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightMuted, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: BudgetValidators.validateCategoryId,
              items: const [
                DropdownMenuItem(value: 'food', child: Text('🍔 Ăn uống & Tiệc tùng')),
                DropdownMenuItem(value: 'shopping', child: Text('🛍️ Mua sắm & Thời trang')),
                DropdownMenuItem(value: 'cafe', child: Text('☕ Cà phê & Gặp gỡ')),
                DropdownMenuItem(value: 'transport', child: Text('🚗 Di chuyển & Xăng xe')),
                DropdownMenuItem(value: 'bills', child: Text('⚡ Hoá đơn & Tiện ích')),
              ],
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            const SizedBox(height: 20),

            // 3. Hạn mức chi tiêu mong muốn
            Text(
              '3. Hạn mức chi tiêu mong muốn *',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: BudgetValidators.validateLimitAmount,
            ),
            const SizedBox(height: 20),

            // 4. Chu kỳ ngân sách
            Text(
              '4. Chu kỳ ngân sách',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
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
                        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedPeriod = p),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 5. Ngày bắt đầu áp dụng
            Text(
              '5. Ngày bắt đầu áp dụng',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('yyyy-MM-dd').format(_startDate),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 6. Cơ chế Rollover
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.autorenew_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Bật tính năng Rollover',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isRolloverEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isRolloverEnabled = val),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    '• Tiết kiệm được: Tiền thừa tháng này cộng vào tháng sau.\n• Bị bội chi: Tháng sau sẽ bị trừ bớt hạn mức bù lại.',
                    style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: AppColors.lightMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút Lưu ngân sách
            ElevatedButton(
              onPressed: formState.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: formState.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.isEditing ? 'Cập nhật ngân sách' : 'Lưu ngân sách',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

