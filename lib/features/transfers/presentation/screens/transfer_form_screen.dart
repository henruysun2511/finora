import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../accounts/domain/models/account_model.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../data/dto/create_transfer_request.dart';
import '../providers/convert_preview_provider.dart';
import '../providers/transfer_actions_provider.dart';
import '../widgets/account_picker_sheet.dart';
import '../widgets/convert_preview_card.dart';

class TransferFormScreen extends ConsumerStatefulWidget {
  final String? fromAccountId;
  final String? fromWalletId;

  const TransferFormScreen({
    super.key,
    this.fromAccountId,
    this.fromWalletId,
  });

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  AccountModel? _fromAccount;
  AccountModel? _toAccount;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _transferDate = DateTime.now();

  double _amount = 0.0;
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initAccountsFromProps());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initAccountsFromProps() {
    final overview = ref.read(walletsOverviewProvider).valueOrNull;
    if (overview == null) return;

    final allAccounts = <AccountModel>[];
    for (final item in overview.items) {
      allAccounts.addAll(item.allAccounts);
    }

    if (widget.fromAccountId != null) {
      final match = allAccounts.cast<AccountModel?>().firstWhere(
            (a) => a?.id == widget.fromAccountId,
            orElse: () => null,
          );
      if (match != null) {
        setState(() => _fromAccount = match);
      }
    } else if (widget.fromWalletId != null) {
      final walletItem = overview.items.cast<WalletItemState?>().firstWhere(
            (i) => i?.wallet.id == widget.fromWalletId,
            orElse: () => null,
          );
      if (walletItem != null && walletItem.allAccounts.isNotEmpty) {
        setState(() => _fromAccount = walletItem.allAccounts.first);
      }
    }
  }

  void _onAmountChanged(String val) {
    final parsed =
        double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _amount = parsed);
      }
    });
  }

  void _swapAccounts() {
    setState(() {
      final temp = _fromAccount;
      _fromAccount = _toAccount;
      _toAccount = temp;
    });
  }

  Future<void> _handleSubmit() async {
    if (_fromAccount == null) {
      AppToast.error(context, 'Vui lòng chọn tài khoản nguồn');
      return;
    }
    if (_toAccount == null) {
      AppToast.error(context, 'Vui lòng chọn tài khoản đích');
      return;
    }
    if (_fromAccount!.id == _toAccount!.id) {
      AppToast.error(context, 'Tài khoản nguồn và đích không được trùng nhau');
      return;
    }
    if (_amount <= 0) {
      AppToast.error(context, 'Số tiền chuyển phải lớn hơn 0');
      return;
    }
    if (_fromAccount!.balance < _amount) {
      AppToast.error(
        context,
        'Số dư tài khoản nguồn (${CurrencyFormatter.format(_fromAccount!.balance, currency: _fromAccount!.currency)}) không đủ để chuyển!',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final req = CreateTransferRequest(
        fromAccountId: _fromAccount!.id,
        toAccountId: _toAccount!.id,
        amount: _amount,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        transferDate: _transferDate.toIso8601String(),
      );

      await ref.read(transferActionsProvider).create(req);

      if (mounted) {
        AppToast.success(
          context,
          'Đã chuyển ${CurrencyFormatter.format(_amount, currency: _fromAccount!.currency)} thành công!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Convert preview state (if currencies differ)
    final isCrossCurrency = _fromAccount != null &&
        _toAccount != null &&
        _fromAccount!.currency.toUpperCase() !=
            _toAccount!.currency.toUpperCase();

    final previewAsync = isCrossCurrency && _amount > 0
        ? ref.watch(
            convertPreviewProvider(
              ConvertPreviewArgs(
                fromAccountId: _fromAccount!.id,
                toAccountId: _toAccount!.id,
                amount: _amount,
              ),
            ),
          )
        : null;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chuyển tiền nội bộ',
        subtitle: 'Giữa các ví và tài khoản',
        action: IconButton(
          icon: const Icon(Icons.history_rounded),
          tooltip: 'Lịch sử chuyển tiền',
          onPressed: () => context.push(RoutePaths.transferHistory),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ──────────────── 1. TÀI KHOẢN NGUỒN VÀ ĐÍCH ────────────────
            FormCard(
              title: 'TÀI KHOẢN GIAO DỊCH',
              child: Column(
                children: [
                  _accountCard(
                    label: 'TỪ TÀI KHOẢN (NGUỒN)',
                    account: _fromAccount,
                    isDark: isDark,
                    onTap: () async {
                      final acc = await AccountPickerSheet.show(
                        context,
                        title: 'Chọn tài khoản nguồn',
                        selectedAccountId: _fromAccount?.id,
                        excludedAccountId: _toAccount?.id,
                        initialWalletId:
                            widget.fromWalletId ?? _fromAccount?.walletId,
                      );
                      if (acc != null) setState(() => _fromAccount = acc);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: InkWell(
                        onTap: _swapAccounts,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackground
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _accountCard(
                    label: 'ĐẾN TÀI KHOẢN (ĐÍCH)',
                    account: _toAccount,
                    isDark: isDark,
                    onTap: () async {
                      final acc = await AccountPickerSheet.show(
                        context,
                        title: 'Chọn tài khoản đích',
                        selectedAccountId: _toAccount?.id,
                        excludedAccountId: _fromAccount?.id,
                        initialWalletId: _fromAccount?.walletId,
                      );
                      if (acc != null) setState(() => _toAccount = acc);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ──────────────── 2. SỐ TIỀN CHUYỂN ────────────────
            FormCard(
              title: 'SỐ TIỀN CHUYỂN',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                    onChanged: _onAmountChanged,
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: _fromAccount?.currency ?? 'VND',
                      suffixStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  if (_fromAccount != null) ...[
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số dư hiện tại:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            CurrencyFormatter.format(
                              _fromAccount!.balance,
                              currency: _fromAccount!.currency,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _fromAccount!.balance < _amount
                                  ? AppColors.danger
                                  : (isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ──────────────── 3. QUY ĐỔI TỶ GIÁ NẾU KHÁC TIỀN ──────
            if (isCrossCurrency) ...[
              previewAsync?.when(
                    data: (preview) => ConvertPreviewCard(preview: preview),
                    loading: () => const ConvertPreviewCard(
                      preview: null,
                      isLoading: true,
                    ),
                    error: (err, _) => FormCard(
                      title: 'TỶ GIÁ QUY ĐỔI',
                      child: Text(
                        'Không thể tải tỷ giá: $err',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ) ??
                  const SizedBox.shrink(),
              const SizedBox(height: 14),
            ],

            // ──────────────── 4. THÔNG TIN BỔ SUNG ────────────────
            FormCard(
              title: 'THÔNG TIN BỔ SUNG',
              child: Column(
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Thêm ghi chú chuyển tiền (tùy chọn)...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _transferDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _transferDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ngày giao dịch: ${_transferDate.day}/${_transferDate.month}/${_transferDate.year}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ──────────────── 5. NÚT CHUYỂN TIỀN ────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
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
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                              child: Text(
                            'XÁC NHẬN CHUYỂN TIỀN',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
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
    );
  }

  Widget _accountCard({
    required String label,
    required AccountModel? account,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account?.name ?? 'Chọn tài khoản...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          account != null ? FontWeight.w800 : FontWeight.w500,
                      color: account != null
                          ? (isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground)
                          : (isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
