import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/lucide_icon.dart';

import '../../../../core/widgets/page_header.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/budget_enums.dart';
import '../../domain/models/budget_input.dart';
import '../../domain/validators/budget_validators.dart';
import '../providers/budget_detail_provider.dart';
import '../providers/budget_form_provider.dart';
import '../../../ai_chat/domain/models/wallet_item_model.dart';
import '../../../categories/domain/models/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

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

  List<DropdownMenuItem<String>> _buildWalletItems(
    Budget? currentBudget,
    List<WalletItemModel> wallets,
  ) {
    final list = <DropdownMenuItem<String>>[];
    final seen = <String>{};

    for (final w in wallets) {
      seen.add(w.id);
      list.add(
        DropdownMenuItem(
          value: w.id,
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: LucideIcon(
                  name: LucideIcon.normalizeIconName(w.icon ?? 'wallet'),
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${w.name} (${w.defaultCurrency})',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedWalletId != null && !seen.contains(_selectedWalletId)) {
      seen.add(_selectedWalletId!);
      final name = currentBudget?.walletName ??
          'Ví chi tiêu (${_selectedWalletId!.substring(0, 8)})';
      list.add(
        DropdownMenuItem(
          value: _selectedWalletId!,
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const LucideIcon(
                  name: 'wallet',
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      list.add(
        DropdownMenuItem(
          value: '11111111-1111-4111-8111-111111111111',
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const LucideIcon(
                  name: 'wallet',
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ví Cá Nhân (VND)',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return list;
  }

  List<DropdownMenuItem<String>> _buildCategoryItems(
    Budget? currentBudget,
    List<Category> categories,
  ) {
    final list = <DropdownMenuItem<String>>[];
    final seen = <String>{};

    for (final c in categories) {
      seen.add(c.id);
      list.add(
        DropdownMenuItem(
          value: c.id,
          child: Row(
            children: [
              CategoryIcon(
                icon: c.icon,
                colorHex: c.color,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedCategoryId != null && !seen.contains(_selectedCategoryId)) {
      seen.add(_selectedCategoryId!);
      final name = currentBudget?.categoryName ??
          'Danh mục (${_selectedCategoryId!.substring(0, 8)})';
      list.add(
        DropdownMenuItem(
          value: _selectedCategoryId!,
          child: Row(
            children: [
              const CategoryIcon(
                icon: 'tag',
                colorHex: '#1E5BD8',
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      list.add(
        DropdownMenuItem(
          value: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          child: Row(
            children: [
              const CategoryIcon(
                icon: 'utensils',
                colorHex: '#F97316',
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ăn uống & Tiệc tùng',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return list;
  }

  Widget _buildWalletDropdown(
    BuildContext context,
    bool isDark,
    Budget? currentBudget,
    List<WalletItemModel> wallets,
  ) {
    final items = _buildWalletItems(currentBudget, wallets);
    final value = items.any((i) => i.value == _selectedWalletId)
        ? _selectedWalletId
        : items.first.value;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: BudgetValidators.validateWalletId,
      items: items,
      onChanged: (val) => setState(() => _selectedWalletId = val),
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    bool isDark,
    Budget? currentBudget,
    List<Category> categories,
  ) {
    final items = _buildCategoryItems(currentBudget, categories);
    final value = items.any((i) => i.value == _selectedCategoryId)
        ? _selectedCategoryId
        : items.first.value;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: BudgetValidators.validateCategoryId,
      items: items,
      onChanged: (val) => setState(() => _selectedCategoryId = val),
    );
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
    final walletsAsync = ref.watch(walletsListProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
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

            // 1. Chọn ví chi tiêu (API GET /wallets)
            Text(
              '1. Chọn Ví chi tiêu *',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            walletsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) =>
                  _buildWalletDropdown(context, isDark, currentBudget, []),
              data: (wallets) {
                if (_selectedWalletId == null &&
                    wallets.isNotEmpty &&
                    currentBudget == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedWalletId == null) {
                      setState(() => _selectedWalletId = wallets.first.id);
                    }
                  });
                }
                return _buildWalletDropdown(
                    context, isDark, currentBudget, wallets);
              },
            ),
            const SizedBox(height: 20),

            // 2. Chọn Danh mục chi tiêu (API GET /categories?type=EXPENSE)
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
            categoriesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) =>
                  _buildCategoryDropdown(context, isDark, currentBudget, []),
              data: (categories) {
                if (_selectedCategoryId == null &&
                    categories.isNotEmpty &&
                    currentBudget == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedCategoryId == null) {
                      setState(() => _selectedCategoryId = categories.first.id);
                    }
                  });
                }
                return _buildCategoryDropdown(
                    context, isDark, currentBudget, categories);
              },
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

            // 6. Tính năng Rollover (Cài đặt bổ sung)
            FormCard(
              title: 'Cài đặt bổ sung',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.autorenew_rounded,
                    color: AppColors.primary, size: 22),
                title: Text(
                  'Cộng dồn ngân sách (Rollover)',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Tự động cộng dồn số tiền chưa dùng hết của kỳ trước sang kỳ tiếp theo, hoặc trừ bớt nếu bạn chi tiêu vượt quá hạn mức.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                value: _isRolloverEnabled,
                onChanged: (val) => setState(() => _isRolloverEnabled = val),
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
