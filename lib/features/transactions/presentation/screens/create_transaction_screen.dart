import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../wallets/presentation/providers/accounts_provider.dart';
import '../../domain/models/transaction_enums.dart';
import '../providers/transaction_form_provider.dart';
import '../widgets/category_quick_chips.dart';
import '../widgets/quick_amount_chips.dart';
import '../widgets/receipt_top_banner.dart';
import '../widgets/transaction_account_selector.dart';
import '../widgets/transaction_type_toggle.dart';
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
  bool _isUploadingGallery = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _feeController = TextEditingController();
    _nameController = TextEditingController();
    _noteController = TextEditingController();
    _locationController = TextEditingController();

    final formState = ref.read(transactionFormProvider);
    if (formState.amount > 0) {
      _amountController.text = _formatNumber(formState.amount);
    }
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
    if (amount == 0) return '';
    return NumberFormat('#,###', 'vi_VN').format(amount.round());
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Hôm nay';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Hôm nay, ${DateFormat('HH:mm').format(dt)}';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(clean) ?? 0;
    ref.read(transactionFormProvider.notifier).setAmount(parsed);
  }

  void _onFeeChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(clean) ?? 0;
    ref.read(transactionFormProvider.notifier).setFee(parsed);
  }

  void _addAmount(double add) {
    final current = ref.read(transactionFormProvider).amount;
    final next = current + add;
    _amountController.text = _formatNumber(next);
    ref.read(transactionFormProvider.notifier).setAmount(next);
  }

  Future<void> _pickDate() async {
    final current =
        ref.read(transactionFormProvider).transactionDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    final finalDt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime?.hour ?? current.hour,
      pickedTime?.minute ?? current.minute,
    );
    ref.read(transactionFormProvider.notifier).setDate(finalDt);
  }

  Future<void> _handleSave() async {
    final formState = ref.read(transactionFormProvider);
    if (formState.amount <= 0) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập số tiền giao dịch lớn hơn 0',
        type: ToastType.warning,
      );
      return;
    }

    final success =
        await ref.read(transactionFormProvider.notifier).submit();
    if (!mounted) return;

    if (success) {
      AppToast.show(
        context,
        message: 'Đã lưu giao dịch thành công!',
        type: ToastType.success,
      );
      context.pop(true);
    } else {
      final err = ref.read(transactionFormProvider).errorMessage;
      AppToast.show(
        context,
        message: err ?? 'Có lỗi xảy ra khi lưu giao dịch',
        type: ToastType.error,
      );
    }
  }

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

      final finalUrl =
          remoteUrl ?? 'data:image/jpeg;base64,${base64Encode(bytes)}';
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
            TransactionTypeToggle(
              selectedType: formState.type,
              onTypeChanged: notifier.setType,
            ),

            const SizedBox(height: 14),

            // ── 2. ĐÍNH KÈM / CHỤP ẢNH HÓA ĐƠN TRÊN ĐẦU (TOP BANNER) ──
            ReceiptTopBanner(
              isUploading: _isUploadingGallery,
              photoUrl: formState.photoUrl,
              onCapture: _handleCaptureReceipt,
              onPickGallery: _handlePickFromGallery,
              onRemovePhoto: () => notifier.setPhoto(null),
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
                  QuickAmountChips(onAddAmount: _addAmount),

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
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                            decoration: InputDecoration(
                              hintText: '0 ₫',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: muted.withValues(alpha: 0.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: border),
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

            // ── 4. CHỌN DANH MỤC THU / CHI ──
            if (formState.type != TransactionType.transfer) ...[
              FormCard(
                title: formState.type == TransactionType.expense
                    ? 'DANH MỤC CHI TIÊU (*)'
                    : 'DANH MỤC THU NHẬP (*)',
                child: CategoryQuickChips(
                  selectedCategoryId: formState.categoryId,
                  isExpense: formState.type == TransactionType.expense,
                  onSelectCategory: (cat) {
                    notifier.setCategory(
                      id: cat.id,
                      name: cat.name,
                      icon: cat.icon,
                      color: cat.color,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── 5. CHỌN NGUỒN TIỀN & TÀI KHOẢN TRÍCH TIỀN ──
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
                error: (_, __) => TransactionAccountSelector(
                  accounts: const [],
                  selectedId: formState.accountId,
                  onSelect: (acc) =>
                      notifier.setAccount(id: acc.id, name: acc.name),
                ),
                data: (accounts) {
                  final list = accounts.isNotEmpty
                      ? accounts
                      : TransactionAccountSelector.defaultFallbackAccounts;

                  if (formState.accountId == null ||
                      formState.accountId!.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted &&
                          (formState.accountId == null ||
                              formState.accountId!.isEmpty)) {
                        notifier.setAccount(
                          id: list.first.id,
                          name: list.first.name,
                        );
                      }
                    });
                  }

                  if (formState.type == TransactionType.transfer) {
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
                        TransactionAccountSelector(
                          accounts: list,
                          selectedId: formState.accountId ?? list.first.id,
                          onSelect: (acc) =>
                              notifier.setAccount(id: acc.id, name: acc.name),
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
                        TransactionAccountSelector(
                          accounts: list,
                          selectedId: formState.toAccountId ??
                              (list.length > 1 ? list[1].id : list.first.id),
                          onSelect: (acc) =>
                              notifier.setToAccount(id: acc.id, name: acc.name),
                        ),
                      ],
                    );
                  }

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
                      TransactionAccountSelector(
                        accounts: list,
                        selectedId: formState.accountId ?? list.first.id,
                        onSelect: (acc) =>
                            notifier.setAccount(id: acc.id, name: acc.name),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── 6. THỜI GIAN & CHI TIẾT GIAO DỊCH ──
            FormCard(
              title: 'CHI TIẾT GIAO DỊCH',
              child: Column(
                children: [
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
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: muted.withValues(alpha: 0.6),
                      ),
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
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: muted.withValues(alpha: 0.6),
                      ),
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
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: muted.withValues(alpha: 0.6),
                      ),
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

            // ── 7. NÚT MỞ RỘNG CÀI ĐẶT NÂNG CAO ──
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

            // ── 8. NÚT LƯU GIAO DỊCH (SUBMIT BUTTON) ──
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
}
