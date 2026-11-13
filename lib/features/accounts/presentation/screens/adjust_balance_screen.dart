import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../wallets/presentation/providers/wallet_detail_provider.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../domain/enums/balance_direction.dart';
import '../../domain/models/account_model.dart';
import '../providers/account_detail_provider.dart';

/// Màn hình chuyên biệt: Điều chỉnh số dư tài khoản nguồn tiền (Đối soát thực tế)
class AdjustBalanceScreen extends ConsumerStatefulWidget {
  final String accountId;
  final AccountModel? initialAccount;

  const AdjustBalanceScreen({
    super.key,
    required this.accountId,
    this.initialAccount,
  });

  @override
  ConsumerState<AdjustBalanceScreen> createState() =>
      _AdjustBalanceScreenState();
}

class _AdjustBalanceScreenState extends ConsumerState<AdjustBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _pinController = TextEditingController();

  BalanceDirection _direction = BalanceDirection.increase;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  double get _enteredAmount {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(text) ?? 0.0;
  }

  double _calculatedNewBalance(AccountModel account) {
    final cur = account.balance;
    if (_direction == BalanceDirection.increase) {
      return cur + _enteredAmount;
    } else {
      return cur - _enteredAmount;
    }
  }

  String _generateIdempotencyKey() {
    final random = Random();
    return 'adj-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(999999)}';
  }

  Future<void> _handleConfirm(AccountModel account) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _enteredAmount;
    if (amount <= 0) {
      AppToast.error(context, 'Số tiền điều chỉnh phải lớn hơn 0');
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      AppToast.error(context, 'Vui lòng nhập lý do điều chỉnh đối soát');
      return;
    }

    final pin = _pinController.text.trim();

    setState(() => _isLoading = true);

    try {
      final key = _generateIdempotencyKey();
      await ref
          .read(accountDetailActionsProvider(account.id))
          .adjustBalance(
            walletId: account.walletId,
            direction: _direction,
            amount: amount,
            reason: reason,
            pin: pin.isNotEmpty ? pin : null,
            idempotencyKey: key,
          );

      ref.invalidate(accountDetailProvider(account.id));
      ref.invalidate(walletDetailProvider(account.walletId));
      ref.invalidate(walletsOverviewProvider);

      if (mounted) {
        AppToast.success(context, 'Cân chỉnh số dư thực tế thành công!');
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.accountDetailWithId(account.id));
        }
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

    // Ưu tiên account được truyền từ extra, nếu không thì fetch từ provider
    if (widget.initialAccount != null) {
      return _buildScaffold(context, isDark, widget.initialAccount!);
    }

    final detailAsync = ref.watch(accountDetailProvider(widget.accountId));

    return detailAsync.when(
      loading: () => Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: PageHeader.subPage(
          title: 'Điều chỉnh số dư',
          subtitle: 'Đang tải thông tin tài khoản...',
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: PageHeader.subPage(
          title: 'Điều chỉnh số dư',
          subtitle: 'Lỗi tải dữ liệu',
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ),
      ),
      data: (data) => _buildScaffold(context, isDark, data.account),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isDark,
    AccountModel account,
  ) {
    final newBalance = _calculatedNewBalance(account);
    final isNegative = newBalance < 0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Điều chỉnh số dư',
        subtitle: '${account.name} · ${account.type.displayName}',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.accountDetailWithId(account.id));
          }
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // THẺ 1: THÔNG TIN TÀI KHOẢN & SỐ DƯ HIỆN TẠI
              FormCard(
                title: 'Nguồn tiền cần đối soát',
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: account.displayColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: account.displayColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        account.displayIcon,
                        color: account.displayColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Số dư sổ sách hiện tại:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(
                        account.balance,
                        currency: account.currency,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // THẺ 2: HƯỚNG & SỐ TIỀN ĐIỀU CHỈNH
              FormCard(
                title: 'Hướng & Số tiền điều chỉnh',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bộ chọn Tăng / Giảm theo chuẩn FinTech
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(
                                  () => _direction = BalanceDirection.increase);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _direction == BalanceDirection.increase
                                    ? AppColors.success
                                    : (isDark
                                        ? AppColors.darkSurface
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _direction == BalanceDirection.increase
                                      ? AppColors.success
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 18,
                                    color:
                                        _direction == BalanceDirection.increase
                                            ? Colors.white
                                            : AppColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TĂNG (+)',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: _direction ==
                                              BalanceDirection.increase
                                          ? Colors.white
                                          : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(
                                  () => _direction = BalanceDirection.decrease);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _direction == BalanceDirection.decrease
                                    ? AppColors.danger
                                    : (isDark
                                        ? AppColors.darkSurface
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _direction == BalanceDirection.decrease
                                      ? AppColors.danger
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 18,
                                    color:
                                        _direction == BalanceDirection.decrease
                                            ? Colors.white
                                            : AppColors.danger,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'GIẢM (-)',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: _direction ==
                                              BalanceDirection.decrease
                                          ? Colors.white
                                          : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nhập số tiền chênh lệch
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Số tiền chênh lệch (*)',
                        hintText: 'VD: 250000',
                        suffixText: account.currency,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập số tiền cần điều chỉnh';
                        }
                        if (_enteredAmount <= 0) {
                          return 'Số tiền phải lớn hơn 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // Khối Preview Ước tính số dư mới
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
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
                              Text(
                                CurrencyFormatter.format(
                                  account.balance,
                                  currency: account.currency,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Chênh lệch đối soát:',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                              Text(
                                '${_direction == BalanceDirection.increase ? "+" : "-"}${CurrencyFormatter.format(_enteredAmount, currency: account.currency)}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _direction == BalanceDirection.increase
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 16,
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Số dư sau điều chỉnh:',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(
                                  newBalance,
                                  currency: account.currency,
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isNegative
                                      ? AppColors.danger
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // THẺ 3: THÔNG TIN ĐỐI SOÁT & BẢO MẬT
              FormCard(
                title: 'Thông tin đối soát & Bảo mật',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lý do điều chỉnh
                    TextFormField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: 'Lý do điều chỉnh (* Bắt buộc)',
                        hintText: 'VD: Đối chiếu số dư SMS, đếm lại tiền mặt...',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập lý do điều chỉnh đối soát';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Mã PIN bảo mật
                    TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Mã PIN bảo mật (nếu có thiết lập)',
                        hintText: '••••••',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // NÚT XÁC NHẬN
              ElevatedButton(
                onPressed: _isLoading ? null : () => _handleConfirm(account),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Xác nhận điều chỉnh số dư',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
