import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/enums/account_type.dart';
import '../../domain/enums/balance_direction.dart';
import '../../domain/models/account_model.dart';
import '../providers/account_detail_provider.dart';

class AdjustBalanceDialog extends ConsumerStatefulWidget {
  final AccountModel account;

  const AdjustBalanceDialog({super.key, required this.account});

  // Giữ field để tương thích hot reload trong phiên debug
  static final AccountModel? _defaultAccount = null;

  @override
  ConsumerState<AdjustBalanceDialog> createState() =>
      _AdjustBalanceDialogState();
}

class _AdjustBalanceDialogState extends ConsumerState<AdjustBalanceDialog> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _pinController = TextEditingController();

  BalanceDirection _direction = BalanceDirection.increase;
  bool _isLoading = false;

  AccountModel get _account => widget.account;

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

  double get _calculatedNewBalance {
    final cur = _account.balance;
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

  Future<void> _handleConfirm() async {
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
      await ref.read(accountDetailActionsProvider(_account.id)).adjustBalance(
            walletId: _account.walletId,
            direction: _direction,
            amount: amount,
            reason: reason,
            pin: pin.isNotEmpty ? pin : null,
            idempotencyKey: key,
          );

      if (mounted) {
        Navigator.pop(context);
        AppToast.success(context, 'Cân chỉnh số dư thực tế thành công!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final account = _account;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.balance_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Điều chỉnh số dư tài khoản',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      Text(
                        'Khớp số dư thực tế với sổ sách',
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
              ],
            ),
            const SizedBox(height: 18),

            // Số dư hiện tại Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Số dư ghi nhận hiện tại:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      CurrencyFormatter.format(
                        account.balance,
                        currency: account.currency,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chọn Hướng điều chỉnh
            Text(
              'Hướng điều chỉnh (*):',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _direction = BalanceDirection.increase);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _direction == BalanceDirection.increase
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _direction == BalanceDirection.increase
                              ? const Color(0xFF10B981)
                              : (isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0)),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                              child: Text(
                            'TĂNG (+)',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _direction = BalanceDirection.decrease);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _direction == BalanceDirection.decrease
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _direction == BalanceDirection.decrease
                              ? const Color(0xFFEF4444)
                              : (isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0)),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                              child: Text(
                            'GIẢM (-)',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEF4444),
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
            const SizedBox(height: 14),

            // Nhập số tiền chênh lệch
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Số tiền chênh lệch cần điều chỉnh (*)',
                hintText: 'VD: 150000',
                suffixText: account.currency,
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),

            // Ước tính số dư mới
            if (_enteredAmount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ước tính số dư mới:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        CurrencyFormatter.format(
                          _calculatedNewBalance,
                          currency: account.currency,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Lý do điều chỉnh
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Lý do điều chỉnh (* Bắt buộc)',
                hintText: 'VD: Đối chiếu số dư với SMS Banking...',
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Mã PIN
            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Mã PIN bảo mật',
                hintText: '••••••',
                counterText: '',
                prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('HỦY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'XÁC NHẬN',
                    isLoading: _isLoading,
                    onPressed: _handleConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
