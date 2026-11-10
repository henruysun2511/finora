import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../wallets/domain/models/account_item_model.dart';
import '../../../wallets/presentation/providers/accounts_provider.dart';
import '../../domain/models/transaction_enums.dart';
import '../providers/transaction_form_provider.dart';
import 'receipt_capture_screen.dart';

class CreateTransactionScreen extends ConsumerStatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  ConsumerState<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState
    extends ConsumerState<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _feeController;
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late final TextEditingController _locationController;

  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _feeController = TextEditingController();
    _nameController = TextEditingController();
    _noteController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatNumber(double amount) {
    final str = amount.round().abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Hôm nay';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final numVal = double.tryParse(clean) ?? 0.0;
    ref.read(transactionFormProvider.notifier).setAmountDirectly(numVal, clean);
  }

  void _onFeeChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final numVal = double.tryParse(clean) ?? 0.0;
    ref.read(transactionFormProvider.notifier).setFee(numVal);
  }

  void _addAmount(double add) {
    final curClean = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cur = double.tryParse(curClean) ?? 0.0;
    final total = cur + add;
    _amountController.text = _formatNumber(total);
    _onAmountChanged(_amountController.text);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = ref.read(transactionFormProvider).transactionDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      ref.read(transactionFormProvider.notifier).setTransactionDate(picked);
    }
  }

  Future<void> _handleSave() async {
    final clean = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final numVal = double.tryParse(clean) ?? 0.0;
    ref.read(transactionFormProvider.notifier).setAmountDirectly(numVal, clean);

    final success =
        await ref.read(transactionFormProvider.notifier).submit();

    if (success && mounted) {
      AppToast.show(
        context,
        message: 'Đã lưu giao dịch thành công!',
        type: ToastType.success,
      );
      context.pop();
    } else {
      final err = ref.read(transactionFormProvider).errorMessage;
      if (err != null && mounted) {
        AppToast.show(
          context,
          message: err,
          type: ToastType.error,
        );
      }
    }
  }

  bool _isUploadingGallery = false;

  Future<void> _handleCaptureReceipt() async {
    final uploadedUrl = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const ReceiptCaptureScreen(),
      ),
    );
    if (uploadedUrl != null && uploadedUrl.isNotEmpty && mounted) {
      ref.read(transactionFormProvider.notifier).setPhoto(uploadedUrl);
    }
  }

  Future<void> _handlePickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 88,
      );
      if (picked == null) return;

      setState(() => _isUploadingGallery = true);
      final dio = ref.read(dioProvider);
      final bytes = await picked.readAsBytes();
      final filename = picked.name.isNotEmpty
          ? picked.name
          : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'folder': 'finora/receipts',
      });

      final res = await dio.post<dynamic>(
        ApiConstants.cloudinaryUpload,
        data: formData,
      );

      final data = res.data;
      String? remoteUrl;
      if (data is Map<String, dynamic>) {
        if (data['data'] != null && data['data'] is Map) {
          remoteUrl = data['data']['secureUrl']?.toString() ??
              data['data']['url']?.toString();
        } else {
          remoteUrl =
              data['secureUrl']?.toString() ?? data['url']?.toString();
        }
      }

      final finalUrl = remoteUrl ?? 'data:image/jpeg;base64,${base64Encode(bytes)}';
      ref.read(transactionFormProvider.notifier).setPhoto(finalUrl);

      if (mounted) {
        AppToast.show(
          context,
          message: remoteUrl != null
              ? 'Đã đính kèm ảnh hóa đơn thành công!'
              : 'Đã đính kèm ảnh xem trước.',
          type: ToastType.success,
        );
      }
    } catch (err) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Lỗi tải ảnh lên Cloudinary: $err',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingGallery = false);
    }
  }

  Widget _buildReceiptImageWidget(
    String path, {
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.topCenter,
  }) {
    if (path.startsWith('data:image')) {
      final commaIndex = path.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(path.substring(commaIndex + 1));
          return Image.memory(
            bytes,
            fit: fit,
            alignment: alignment,
          );
        } catch (_) {}
      }
    }
    return Image.network(
      path,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.primary.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(
            Icons.receipt_long_rounded,
            color: AppColors.primary,
            size: 40,
          ),
        ),
      ),
    );
  }

  void _showImagePreviewDialog(String imageUrl) {
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
              child: InteractiveViewer(
                child: _buildReceiptImageWidget(imageUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(ctx).pop(),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = formState.type == TransactionType.income
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Thêm giao dịch',
        subtitle: 'Ghi chép thu chi & dòng tiền đa năng',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // ── 1. PHÂN LOẠI 3 TABS (ChoiceChips chuẩn GEMINI.md) ──
            Row(
              children: [
                _buildTabChip(
                  label: 'CHI TIÊU',
                  isSelected: formState.type == TransactionType.expense,
                  onSelected: () => notifier.setType(TransactionType.expense),
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  foreground: foreground,
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  label: 'THU NHẬP',
                  isSelected: formState.type == TransactionType.income,
                  onSelected: () => notifier.setType(TransactionType.income),
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  foreground: foreground,
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  label: 'CHUYỂN TIỀN',
                  isSelected: formState.type == TransactionType.transfer,
                  onSelected: () => notifier.setType(TransactionType.transfer),
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  foreground: foreground,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── 2. ĐÍNH KÈM / CHỤP ẢNH HÓA ĐƠN TRÊN ĐẦU (TOP BANNER) ──
            _buildTopReceiptBanner(
              formState: formState,
              notifier: notifier,
              isDark: isDark,
              surface: surface,
              border: border,
              foreground: foreground,
              muted: muted,
            ),

            const SizedBox(height: 16),

            // ── 3. KHỐI NHẬP SỐ TIỀN CỰC LỚN (FINTECH HERO INPUT) ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SỐ TIỀN GIAO DỊCH (*)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'VND (₫)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: formState.type == TransactionType.expense
                          ? AppColors.danger
                          : (formState.type == TransactionType.income
                              ? AppColors.success
                              : AppColors.primary),
                      letterSpacing: -0.5,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: _onAmountChanged,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: muted.withValues(alpha: 0.4),
                      ),
                      prefixText: formState.type == TransactionType.expense
                          ? '- ₫ '
                          : (formState.type == TransactionType.income
                              ? '+ ₫ '
                              : '⇄ ₫ '),
                      prefixStyle: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: formState.type == TransactionType.expense
                            ? AppColors.danger
                            : (formState.type == TransactionType.income
                                ? AppColors.success
                                : AppColors.primary),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Phím tắt cộng nhanh số tiền
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickAmountChip('+50.000', 50000, border),
                      _buildQuickAmountChip('+100.000', 100000, border),
                      _buildQuickAmountChip('+200.000', 200000, border),
                      _buildQuickAmountChip('+500.000', 500000, border),
                    ],
                  ),

                  // Phí chuyển tiền (Nếu là Tab Chuyển tiền)
                  if (formState.type == TransactionType.transfer) ...[
                    const SizedBox(height: 14),
                    Divider(color: border.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_atm_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Phí chuyển tiền (nếu có):',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _feeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: _onFeeChanged,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                            decoration: InputDecoration(
                              hintText: '0 ₫ (Miễn phí)',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: muted.withValues(alpha: 0.6),
                              ),
                              suffixText: '₫',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 3. CHỌN DANH MỤC (NẾU THU HOẶC CHI) ──
            if (formState.type != TransactionType.transfer) ...[
              FormCard(
                title: formState.type == TransactionType.expense
                    ? 'DANH MỤC CHI TIÊU (*)'
                    : 'DANH MỤC THU NHẬP (*)',
                child: categoriesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  error: (_, __) => _buildCategoryChipsFallback(
                    formState,
                    notifier,
                    isDark,
                    border,
                    foreground,
                  ),
                  data: (categories) {
                    if (categories.isEmpty) {
                      return _buildCategoryChipsFallback(
                        formState,
                        notifier,
                        isDark,
                        border,
                        foreground,
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = formState.categoryId == cat.id;
                        return ChoiceChip(
                          showCheckmark: false,
                          avatar: CategoryIcon(
                            icon: cat.icon,
                            colorHex: cat.color,
                            size: 24,
                          ),
                          label: Text(
                            cat.name,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? Colors.white : foreground,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (_) {
                            notifier.setCategory(
                              id: cat.id,
                              name: cat.name,
                              icon: cat.icon,
                              color: cat.color,
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── 4. CHỌN NGUỒN TIỀN & TÀI KHOẢN TRÍCH TIỀN ──
            FormCard(
              title: formState.type == TransactionType.transfer
                  ? 'TÀI KHOẢN CHUYỂN & NHẬN TIỀN (*)'
                  : (formState.type == TransactionType.expense
                      ? 'TÀI KHOẢN TRÍCH TIỀN (NGUỒN CHI) (*)'
                      : 'TÀI KHOẢN THỤ HƯỞNG (NGUỒN THU) (*)'),
              child: accountsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => _buildAccountFallbackList(
                  formState: formState,
                  notifier: notifier,
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  foreground: foreground,
                  muted: muted,
                ),
                data: (accounts) {
                  final list = accounts.isNotEmpty
                      ? accounts
                      : _getDefaultFallbackAccounts();

                  // Tự động gán tài khoản đầu tiên nếu chưa chọn
                  if (formState.accountId == null || formState.accountId!.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && (formState.accountId == null || formState.accountId!.isEmpty)) {
                        notifier.setAccount(id: list.first.id, name: list.first.name);
                      }
                    });
                  }

                  if (formState.type == TransactionType.transfer) {
                    // Nếu là Chuyển tiền -> Chọn Tài khoản nguồn và Tài khoản đích
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Tài khoản chuyển đi (Trích tiền):',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAccountSelector(
                          accounts: list,
                          selectedId: formState.accountId ?? list.first.id,
                          onSelect: (acc) =>
                              notifier.setAccount(id: acc.id, name: acc.name),
                          isDark: isDark,
                          surface: surface,
                          border: border,
                          foreground: foreground,
                          muted: muted,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '2. Tài khoản nhận tiền (Cộng tiền):',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAccountSelector(
                          accounts: list,
                          selectedId: formState.toAccountId ??
                              (list.length > 1 ? list[1].id : list.first.id),
                          onSelect: (acc) =>
                              notifier.setToAccount(id: acc.id, name: acc.name),
                          isDark: isDark,
                          surface: surface,
                          border: border,
                          foreground: foreground,
                          muted: muted,
                        ),
                      ],
                    );
                  }

                  // Nếu là Chi tiêu hoặc Thu nhập thông thường
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formState.type == TransactionType.expense
                            ? 'Chọn tài khoản bị trừ tiền:'
                            : 'Chọn tài khoản nhận tiền cộng vào:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildAccountSelector(
                        accounts: list,
                        selectedId: formState.accountId ?? list.first.id,
                        onSelect: (acc) =>
                            notifier.setAccount(id: acc.id, name: acc.name),
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        foreground: foreground,
                        muted: muted,
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── 5. THỜI GIAN & CHI TIẾT GIAO DỊCH ──
            FormCard(
              title: 'CHI TIẾT GIAO DỊCH',
              child: Column(
                children: [
                  // Tên giao dịch
                  TextFormField(
                    controller: _nameController,
                    onChanged: notifier.setName,
                    style: GoogleFonts.inter(fontSize: 13.5, color: foreground),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.label_outline_rounded,
                        size: 20,
                        color: muted,
                      ),
                      labelText: 'Tên giao dịch',
                      labelStyle: GoogleFonts.inter(fontSize: 13, color: muted),
                      hintText: 'VD: Ăn trưa bún bò, Đổ xăng...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: muted.withValues(alpha: 0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Chọn ngày giờ
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ngày phát sinh',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: muted,
                                  ),
                                ),
                                Text(
                                  _formatDateTime(formState.transactionDate),
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_calendar_rounded,
                            size: 18,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tên địa điểm
                  TextFormField(
                    controller: _locationController,
                    onChanged: notifier.setLocationName,
                    style: GoogleFonts.inter(fontSize: 13.5, color: foreground),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.place_outlined,
                        size: 20,
                        color: muted,
                      ),
                      labelText: 'Địa điểm',
                      labelStyle: GoogleFonts.inter(fontSize: 13, color: muted),
                      hintText: 'VD: Quán Cơm Tấm Ba Ghiền, Co.opmart...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: muted.withValues(alpha: 0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Ghi chú chi tiết
                  TextFormField(
                    controller: _noteController,
                    onChanged: notifier.setNote,
                    maxLines: 2,
                    style: GoogleFonts.inter(fontSize: 13.5, color: foreground),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.notes_rounded,
                        size: 20,
                        color: muted,
                      ),
                      labelText: 'Ghi chú chi tiết',
                      labelStyle: GoogleFonts.inter(fontSize: 13, color: muted),
                      hintText: 'Thêm ghi chú để dễ dàng tra cứu lại sau này...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: muted.withValues(alpha: 0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 6. NÚT MỞ RỘNG CÀI ĐẶT NÂNG CAO ──
            InkWell(
              onTap: () {
                setState(() {
                  _showAdvancedOptions = !_showAdvancedOptions;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showAdvancedOptions
                          ? Icons.expand_less_rounded
                          : Icons.tune_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showAdvancedOptions
                          ? 'Thu gọn cài đặt nâng cao'
                          : 'Cài đặt nâng cao & Riêng tư (Báo cáo, Ví chia sẻ)',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_showAdvancedOptions) ...[
              const SizedBox(height: 8),
              // Khối Cài đặt nâng cao chuẩn GEMINI.md Phần 3
              FormCard(
                title: 'CÀI ĐẶT NÂNG CAO & BÁO CÁO',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: formState.excludeFromReport,
                      activeColor: AppColors.primary,
                      title: Text(
                        'Không tính vào báo cáo',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Loại trừ khoản này khỏi tổng chi tiêu tháng và theo dõi ngân sách',
                        style: GoogleFonts.inter(fontSize: 11.5, color: muted),
                      ),
                      onChanged: notifier.setExcludeFromReport,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: formState.amountHidden,
                      activeColor: AppColors.primary,
                      title: Text(
                        'Ẩn số tiền trong ví chia sẻ',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Chỉ hiển thị danh mục và ghi chú, ẩn số tiền đối với thành viên khác',
                        style: GoogleFonts.inter(fontSize: 11.5, color: muted),
                      ),
                      onChanged: notifier.setAmountHidden,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: formState.visibility == 'FRIENDS',
                      activeColor: AppColors.primary,
                      title: Text(
                        'Chia sẻ lên Bảng tin & Ví chung',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        formState.visibility == 'FRIENDS'
                            ? 'Bật: Bạn bè và thành viên ví chung có thể thấy giao dịch'
                            : 'Tắt: Chỉ mình tôi thấy (Hoàn toàn riêng tư)',
                        style: GoogleFonts.inter(fontSize: 11.5, color: muted),
                      ),
                      onChanged: (val) {
                        notifier.setVisibility(val ? 'FRIENDS' : 'PRIVATE');
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── 7. NÚT LƯU GIAO DỊCH (SUBMIT BUTTON) ──
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: formState.isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: formState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Lưu giao dịch ✓',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color foreground,
  }) {
    return Expanded(
      child: Material(
        color: isSelected ? AppColors.primary : surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : border,
          ),
        ),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(
    String label,
    double addAmount,
    Color border,
  ) {
    return InkWell(
      onTap: () => _addAmount(addAmount),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChipsFallback(
    dynamic formState,
    dynamic notifier,
    bool isDark,
    Color border,
    Color foreground,
  ) {
    final fallbacks = [
      ('cat-1', 'Ăn uống', 'utensils', '#EF4444'),
      ('cat-2', 'Mua sắm', 'shopping-cart', '#3B82F6'),
      ('cat-3', 'Cà phê', 'coffee', '#F59E0B'),
      ('cat-4', 'Di chuyển', 'car', '#10B981'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fallbacks.map((f) {
        final isSelected = formState.categoryId == f.$1;
        return ChoiceChip(
          showCheckmark: false,
          avatar: CategoryIcon(icon: f.$3, colorHex: f.$4, size: 24),
          label: Text(
            f.$2,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : foreground,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.primary,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (_) {
            notifier.setCategory(
              id: f.$1,
              name: f.$2,
              icon: f.$3,
              color: f.$4,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildAccountSelector({
    required List<AccountItemModel> accounts,
    required String? selectedId,
    required ValueChanged<AccountItemModel> onSelect,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color foreground,
    required Color muted,
  }) {
    return Column(
      children: accounts.map((acc) {
        final isSelected = selectedId == acc.id;
        final formattedBalance = _formatNumber(acc.balance);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onSelect(acc),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? Colors.white10
                              : AppColors.primary.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      acc.defaultIcon,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                acc.name,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : foreground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (acc.accountNumberLast4 != null &&
                                acc.accountNumberLast4!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: border.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '•••• ${acc.accountNumberLast4}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: muted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              acc.typeLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('•',
                                style: TextStyle(fontSize: 10, color: muted)),
                            const SizedBox(width: 6),
                            Text(
                              'Số dư: $formattedBalance ₫',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected ? AppColors.primary : foreground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? AppColors.primary
                        : muted.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<AccountItemModel> _getDefaultFallbackAccounts() {
    return const [
      AccountItemModel(
        id: 'acc-cash',
        name: 'Tiền mặt (Ví da)',
        type: 'cash',
        balance: 2500000,
        currency: 'VND',
      ),
      AccountItemModel(
        id: 'acc-vcb',
        name: 'Vietcombank Digibank',
        type: 'bank',
        balance: 18250000,
        currency: 'VND',
        accountNumberLast4: '6789',
      ),
      AccountItemModel(
        id: 'acc-momo',
        name: 'Ví điện tử MoMo',
        type: 'ewallet',
        balance: 850000,
        currency: 'VND',
      ),
      AccountItemModel(
        id: 'acc-tcb',
        name: 'Techcombank Visa Debit',
        type: 'bank',
        balance: 5400000,
        currency: 'VND',
        accountNumberLast4: '3456',
      ),
    ];
  }

  Widget _buildAccountFallbackList({
    required dynamic formState,
    required dynamic notifier,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color foreground,
    required Color muted,
  }) {
    final list = _getDefaultFallbackAccounts();
    return _buildAccountSelector(
      accounts: list,
      selectedId: formState.accountId ?? list.first.id,
      onSelect: (acc) => notifier.setAccount(id: acc.id, name: acc.name),
      isDark: isDark,
      surface: surface,
      border: border,
      foreground: foreground,
      muted: muted,
    );
  }

  Widget _buildTopReceiptBanner({
    required dynamic formState,
    required dynamic notifier,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color foreground,
    required Color muted,
  }) {
    if (_isUploadingGallery) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Đang tải ảnh hóa đơn lên Cloudinary...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final photoUrl = formState.photoUrl as String?;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Preview image banner
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImagePreviewDialog(photoUrl),
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      child: _buildReceiptImageWidget(
                        photoUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),

                  // Tag top-left: Hóa đơn
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Ảnh chứng từ',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tag top-right: Cloudinary status
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đã lưu Cloudinary',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hint xem phóng to góc dưới phải
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fullscreen_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Chạm để phóng to',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action bar under image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _handleCaptureReceipt,
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: Text(
                      'Chụp lại',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _handlePickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: Text(
                      'Đổi ảnh khác',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => notifier.setPhoto(null),
                    tooltip: 'Gỡ ảnh',
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Khi chưa đính kèm ảnh: Giao diện scan banner chuẩn add-manual.html
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đính kèm hoặc chụp ảnh hóa đơn',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chụp ảnh lưu chứng từ & nhận diện giao dịch',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleCaptureReceipt,
                  icon: const Icon(Icons.camera_alt_rounded,
                      size: 16, color: Colors.white),
                  label: Text(
                    'Chụp ảnh hóa đơn',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handlePickFromGallery,
                  icon: const Icon(Icons.photo_library_rounded,
                      size: 16, color: AppColors.primary),
                  label: Text(
                    'Chọn từ thư viện',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
