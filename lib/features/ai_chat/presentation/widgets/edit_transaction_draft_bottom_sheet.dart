import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/models/send_message_input.dart';
import '../../../categories/domain/models/category.dart';
import '../../../categories/domain/models/category_type.dart';
import '../../../categories/presentation/providers/category_list_provider.dart';
import '../../../wallets/domain/models/account_item_model.dart';
import '../../../wallets/presentation/providers/accounts_provider.dart';

class EditTransactionDraftBottomSheet extends ConsumerStatefulWidget {
  final String? initialType; // EXPENSE | INCOME
  final String initialName;
  final num initialAmount;
  final String? initialCategory;
  final String? initialCategoryId;
  final String? initialAccount;
  final String? initialAccountId;
  final String? initialDate;
  final String? initialNote;
  final String? initialLocation;
  final bool initialAmountHidden;
  final bool initialExcludeFromReport;
  final String? initialVisibility; // PRIVATE | FRIENDS
  final String? initialPhotoUrl;
  final ValueChanged<EditTransactionDraft> onSave;

  const EditTransactionDraftBottomSheet({
    super.key,
    this.initialType,
    required this.initialName,
    required this.initialAmount,
    this.initialCategory,
    this.initialCategoryId,
    this.initialAccount,
    this.initialAccountId,
    this.initialDate,
    this.initialNote,
    this.initialLocation,
    this.initialAmountHidden = false,
    this.initialExcludeFromReport = false,
    this.initialVisibility,
    this.initialPhotoUrl,
    required this.onSave,
  });

  static Future<EditTransactionDraft?> show(
    BuildContext context, {
    String? initialType,
    required String initialName,
    required num initialAmount,
    String? initialCategory,
    String? initialCategoryId,
    String? initialAccount,
    String? initialAccountId,
    String? initialDate,
    String? initialNote,
    String? initialLocation,
    bool initialAmountHidden = false,
    bool initialExcludeFromReport = false,
    String? initialVisibility,
    String? initialPhotoUrl,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<EditTransactionDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditTransactionDraftBottomSheet(
        initialType: initialType,
        initialName: initialName,
        initialAmount: initialAmount,
        initialCategory: initialCategory,
        initialCategoryId: initialCategoryId,
        initialAccount: initialAccount,
        initialAccountId: initialAccountId,
        initialDate: initialDate,
        initialNote: initialNote,
        initialLocation: initialLocation,
        initialAmountHidden: initialAmountHidden,
        initialExcludeFromReport: initialExcludeFromReport,
        initialVisibility: initialVisibility,
        initialPhotoUrl: initialPhotoUrl,
        onSave: (draft) => Navigator.pop(ctx, draft),
      ),
    );
  }

  @override
  ConsumerState<EditTransactionDraftBottomSheet> createState() =>
      _EditTransactionDraftBottomSheetState();
}

class _EditTransactionDraftBottomSheetState
    extends ConsumerState<EditTransactionDraftBottomSheet> {
  late String _type; // EXPENSE | INCOME
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _locationController;
  String? _selectedCategoryId;
  String _selectedCategory = '';
  String? _selectedAccountId;
  String _selectedAccount = '';
  late DateTime _selectedDate;
  late bool _amountHidden;
  late bool _excludeFromReport;
  late String _visibility; // PRIVATE | FRIENDS
  bool _showAdvancedOptions = false;
  String? _photoUrl;
  Uint8List? _localPhotoBytes;
  bool _isUploadingPhoto = false;

  // Danh mục chi tiêu phổ biến (fallback)
  static const List<String> _expenseCategories = [
    'Ăn uống & Cà phê',
    'Di chuyển & Xăng xe',
    'Mua sắm',
    'Hóa đơn sinh hoạt',
    'Nhà cửa / Tiền trọ',
    'Giải trí & Bạn bè',
    'Y tế & Sức khỏe',
    'Học tập & Phát triển',
    'Khác',
  ];

  // Danh mục thu nhập phổ biến (fallback)
  static const List<String> _incomeCategories = [
    'Lương & Thưởng',
    'Đầu tư & Sinh lời',
    'Thu nhập phụ / Freelance',
    'Quà tặng / Được cho',
    'Thu nhập khác',
  ];

  // Tài khoản thanh toán phổ biến (fallback)
  static const List<String> _accounts = [
    'Tiền mặt',
    'Vietcombank DigiBank',
    'Techcombank Mobile',
    'Ví MoMo',
    'MB Bank',
    'Thẻ tín dụng',
  ];

  @override
  void initState() {
    super.initState();
    _type =
        widget.initialType?.toUpperCase() == 'INCOME' ? 'INCOME' : 'EXPENSE';
    _nameController = TextEditingController(text: widget.initialName);
    _amountController =
        TextEditingController(text: widget.initialAmount.toStringAsFixed(0));
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _locationController =
        TextEditingController(text: widget.initialLocation ?? '');

    _selectedCategoryId = widget.initialCategoryId;
    _selectedCategory = widget.initialCategory ?? '';
    _selectedAccountId = widget.initialAccountId;
    _selectedAccount = widget.initialAccount ?? '';

    if (widget.initialDate != null) {
      _selectedDate = DateTime.tryParse(widget.initialDate!) ?? DateTime.now();
    } else {
      _selectedDate = DateTime.now();
    }

    _amountHidden = widget.initialAmountHidden;
    _excludeFromReport = widget.initialExcludeFromReport;
    _visibility = widget.initialVisibility?.toUpperCase() == 'FRIENDS'
        ? 'FRIENDS'
        : 'PRIVATE';
    _photoUrl = widget.initialPhotoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickAndUploadReceipt(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _localPhotoBytes = bytes;
        _isUploadingPhoto = true;
      });

      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final result = await cloudinaryService.uploadMedia(
        bytes: bytes,
        filename: picked.name.isNotEmpty
            ? picked.name
            : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
        folder: 'finora/receipts',
      );

      if (mounted) {
        setState(() {
          _photoUrl = result.secureUrl;
          _isUploadingPhoto = false;
        });
        AppToast.success(context, 'Tải ảnh hóa đơn lên thành công!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
        AppToast.error(context, 'Không thể tải ảnh: $e');
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _photoUrl = null;
      _localPhotoBytes = null;
    });
  }

  void _previewPhoto(BuildContext context) {
    if (_photoUrl == null && _localPhotoBytes == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _localPhotoBytes != null
                  ? Image.memory(_localPhotoBytes!, fit: BoxFit.contain)
                  : Image.network(_photoUrl!, fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                ),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText);

    if (name.isEmpty) {
      AppToast.warning(context, 'Vui lòng nhập tên khoản giao dịch');
      return;
    }

    if (amount == null || amount <= 0) {
      AppToast.warning(context, 'Vui lòng nhập số tiền hợp lệ (> 0)');
      return;
    }

    final accountsAsync = ref.read(accountsListProvider);
    final userAccounts = accountsAsync.asData?.value ?? [];
    final currentAcc = userAccounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    if (_type == 'EXPENSE' && currentAcc != null && currentAcc.balance < amount) {
      final balStr = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: '₫',
        decimalDigits: 0,
      ).format(currentAcc.balance).trim();
      AppToast.error(
        context,
        'Số dư tài khoản ${currentAcc.name} không đủ để chi tiêu (Hiện có: $balStr, Cần: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(amount).trim()})!',
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final draft = EditTransactionDraft(
      type: _type,
      name: name,
      amount: amount,
      accountId: _selectedAccountId,
      categoryId: _selectedCategoryId,
      categoryName: _selectedCategory,
      accountName: _selectedAccount,
      date: dateStr,
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
      locationName: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      visibility: _visibility,
      amountHidden: _amountHidden,
      excludeFromReport: _excludeFromReport,
      photoUrl: _photoUrl,
    );

    widget.onSave(draft);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isExpense = _type == 'EXPENSE';
    final fallbackCategories = isExpense ? _expenseCategories : _incomeCategories;

    // Lấy danh sách tài khoản thực tế của người dùng
    final accountsAsync = ref.watch(accountsListProvider);
    final userAccounts = accountsAsync.asData?.value ?? [];

    // Lấy danh sách danh mục thực tế của người dùng
    final categoriesAsync = ref.watch(categoryListProvider);
    final allCategories = categoriesAsync.asData?.value ?? [];
    final userCategories = allCategories
        .where((c) => isExpense ? c.type == CategoryType.expense : c.type == CategoryType.income)
        .toList();

    // Tự động gán nếu chưa có accountId hoặc tên
    if (userAccounts.isNotEmpty) {
      if (_selectedAccountId == null || !userAccounts.any((a) => a.id == _selectedAccountId)) {
        final matched = userAccounts.firstWhere(
          (a) => _selectedAccount.isNotEmpty && a.name.toLowerCase() == _selectedAccount.toLowerCase(),
          orElse: () => userAccounts.first,
        );
        _selectedAccountId = matched.id;
        _selectedAccount = matched.name;
      }
    }

    // Tự động gán nếu chưa có categoryId hoặc tên
    if (userCategories.isNotEmpty) {
      if (_selectedCategoryId == null || !userCategories.any((c) => c.id == _selectedCategoryId)) {
        final matched = userCategories.firstWhere(
          (c) => _selectedCategory.isNotEmpty && c.name.toLowerCase() == _selectedCategory.toLowerCase(),
          orElse: () => userCategories.first,
        );
        _selectedCategoryId = matched.id;
        _selectedCategory = matched.name;
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0072D5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: Color(0xFF0072D5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sửa giao dịch nháp',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                            Text(
                              'Chuẩn hóa đầy đủ các trường trước khi ghi sổ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Phân loại giao dịch (EXPENSE vs INCOME)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _type = 'EXPENSE';
                          if (!_expenseCategories.contains(_selectedCategory)) {
                            _selectedCategory = _expenseCategories.first;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isExpense
                              ? (isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isExpense
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              size: 16,
                              color: isExpense
                                  ? const Color(0xFFEF4444)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                                child: Text(
                              'Khoản chi tiêu',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isExpense
                                    ? const Color(0xFFEF4444)
                                    : (isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B)),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _type = 'INCOME';
                          if (!_incomeCategories.contains(_selectedCategory)) {
                            _selectedCategory = _incomeCategories.first;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: !isExpense
                              ? (isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !isExpense
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 16,
                              color: !isExpense
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                                child: Text(
                              'Khoản thu nhập',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: !isExpense
                                    ? const Color(0xFF10B981)
                                    : (isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B)),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Tên giao dịch (name)
            Text(
              'Tên giao dịch *',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintText: 'Ví dụ: Ăn buffet nướng, Cà phê, Lương tháng...',
              ),
            ),
            const SizedBox(height: 14),

            // 3. Số tiền giao dịch (amount)
            Text(
              'Số tiền (₫) *',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isExpense
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                prefixText: isExpense ? '- ₫ ' : '+ ₫ ',
                prefixStyle: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isExpense
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Danh mục & Tài khoản nguồn (2 cột)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh mục *',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId != null &&
                                userCategories.any((c) => c.id == _selectedCategoryId)
                            ? _selectedCategoryId
                            : (userCategories.isNotEmpty
                                ? userCategories.first.id
                                : (fallbackCategories.contains(_selectedCategory)
                                    ? _selectedCategory
                                    : fallbackCategories.first)),
                        isExpanded: true,
                        dropdownColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        items: userCategories.isNotEmpty
                            ? userCategories.map((c) {
                                return DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList()
                            : fallbackCategories.map((c) {
                                return DropdownMenuItem(value: c, child: Text(c));
                              }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            if (userCategories.any((c) => c.id == val)) {
                              final cat = userCategories.firstWhere((c) => c.id == val);
                              setState(() {
                                _selectedCategoryId = cat.id;
                                _selectedCategory = cat.name;
                              });
                            } else {
                              setState(() => _selectedCategory = val);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tài khoản nguồn *',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedAccountId != null &&
                                userAccounts.any((a) => a.id == _selectedAccountId)
                            ? _selectedAccountId
                            : (userAccounts.isNotEmpty
                                ? userAccounts.first.id
                                : (_accounts.contains(_selectedAccount)
                                    ? _selectedAccount
                                    : _accounts.first)),
                        isExpanded: true,
                        dropdownColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        items: userAccounts.isNotEmpty
                            ? userAccounts.map((a) {
                                final currentAmt = double.tryParse(_amountController.text) ?? 0.0;
                                final isLow = isExpense && a.balance < currentAmt;
                                final balanceStr = NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: '₫',
                                  decimalDigits: 0,
                                ).format(a.balance).trim();
                                return DropdownMenuItem(
                                  value: a.id,
                                  child: Text(
                                    '${a.name} ($balanceStr)',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isLow
                                          ? const Color(0xFFEF4444)
                                          : (isDark ? Colors.white : Colors.black87),
                                      fontWeight: isLow ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList()
                            : _accounts.map((a) {
                                return DropdownMenuItem(value: a, child: Text(a));
                              }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            if (userAccounts.any((a) => a.id == val)) {
                              final acc = userAccounts.firstWhere((a) => a.id == val);
                              setState(() {
                                _selectedAccountId = acc.id;
                                _selectedAccount = acc.name;
                              });
                            } else {
                              setState(() => _selectedAccount = val);
                            }
                          }
                        },
                      ),
                      // Cảnh báo số dư không đủ nếu tài khoản có balance < amount
                      if (userAccounts.isNotEmpty) ...[
                        Builder(
                          builder: (context) {
                            final curAcc = userAccounts.where((a) => a.id == _selectedAccountId).firstOrNull;
                            final curAmt = double.tryParse(_amountController.text) ?? 0.0;
                            if (isExpense && curAcc != null && curAcc.balance < curAmt) {
                              final balStr = NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                                decimalDigits: 0,
                              ).format(curAcc.balance).trim();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '⚠️ Số dư không đủ ($balStr)',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Ngày giao dịch & Địa điểm (2 cột)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày giao dịch',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: Color(0xFF0072D5)),
                              const SizedBox(width: 8),
                              Flexible(
                                  child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Địa điểm',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _locationController,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Vd: Quán Cô Ba',
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 6. Ghi chú thêm (note)
            Text(
              'Ghi chú thêm',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú chi tiết cho giao dịch...',
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 7. Ảnh hóa đơn / chứng từ (Cloudinary)
            Text(
              'Ảnh hóa đơn / chứng từ',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            if (_photoUrl != null || _localPhotoBytes != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _previewPhoto(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: _localPhotoBytes != null
                                  ? Image.memory(_localPhotoBytes!,
                                      fit: BoxFit.cover)
                                  : Image.network(
                                      _photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          Container(
                                        color:
                                            Colors.grey.withValues(alpha: 0.2),
                                        child: const Icon(
                                            Icons.broken_image_rounded,
                                            size: 28),
                                      ),
                                    ),
                            ),
                            if (_isUploadingPhoto)
                              Container(
                                width: 64,
                                height: 64,
                                color: Colors.black45,
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isUploadingPhoto
                                    ? Icons.cloud_upload_rounded
                                    : Icons.check_circle_rounded,
                                size: 15,
                                color: _isUploadingPhoto
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                  child: Text(
                                _isUploadingPhoto
                                    ? 'Đang tải lên Cloudinary...'
                                    : 'Đã đính kèm ảnh',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Chạm vào ảnh để phóng to xem chi tiết',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444)),
                      tooltip: 'Xóa ảnh này',
                      onPressed: _isUploadingPhoto ? null : _removePhoto,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Đính kèm hóa đơn / chứng từ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút Chụp ảnh
                    InkWell(
                      onTap: () => _pickAndUploadReceipt(ImageSource.camera),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0072D5).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded,
                                size: 15, color: Color(0xFF0072D5)),
                            const SizedBox(width: 4),
                            Flexible(
                                child: Text(
                              'Chụp',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0072D5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Nút Thư viện
                    InkWell(
                      onTap: () => _pickAndUploadReceipt(ImageSource.gallery),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library_rounded,
                              size: 15,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                                child: Text(
                              'Thư viện',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // 8. Cài đặt bổ sung / Nâng cao (Expandable Toggle)
            InkWell(
              onTap: () =>
                  setState(() => _showAdvancedOptions = !_showAdvancedOptions),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _showAdvancedOptions
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: const Color(0xFF0072D5),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                        child: Text(
                      'Tùy chọn nâng cao (Ví chia sẻ & Báo cáo)',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0072D5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ),

            if (_showAdvancedOptions) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    // Quyền hiển thị (visibility)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quyền hiển thị',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              Text(
                                'Riêng tư hoặc chia sẻ cùng thành viên ví',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _visibility,
                          underline: const SizedBox(),
                          dropdownColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0072D5),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'PRIVATE',
                              child: Text('Riêng tư'),
                            ),
                            DropdownMenuItem(
                              value: 'FRIENDS',
                              child: Text('Ví chia sẻ'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _visibility = val);
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 18),

                    // Ẩn số tiền (amountHidden)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ẩn số tiền',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              Text(
                                'Ẩn số tiền với thành viên khác trong ví chia sẻ',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _amountHidden,
                          activeTrackColor: const Color(0xFF0072D5),
                          onChanged: (val) =>
                              setState(() => _amountHidden = val),
                        ),
                      ],
                    ),
                    const Divider(height: 18),

                    // Loại trừ khỏi báo cáo (excludeFromReport)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loại trừ khỏi báo cáo',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              Text(
                                'Không tính vào thống kê chi tiêu tổng hợp',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _excludeFromReport,
                          activeTrackColor: const Color(0xFF0072D5),
                          onChanged: (val) =>
                              setState(() => _excludeFromReport = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _handleSubmit,
                icon: const Icon(Icons.check_rounded,
                    size: 20, color: Colors.white),
                label: Text(
                  'Lưu thay đổi',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0072D5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
