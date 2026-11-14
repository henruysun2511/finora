import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/transfer.dart';
import '../providers/transfer_actions_provider.dart';

class TransferDetailScreen extends ConsumerWidget {
  final String transferId;
  final Transfer? initialTransfer;

  const TransferDetailScreen({
    super.key,
    required this.transferId,
    this.initialTransfer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(transferDetailProvider(transferId));

    final transfer = detailAsync.valueOrNull ?? initialTransfer;

    if (transfer == null && detailAsync.isLoading) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: const PageHeader.subPage(title: 'Chi tiết giao dịch'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (transfer == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: const PageHeader.subPage(title: 'Chi tiết giao dịch'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.danger, size: 48),
              const SizedBox(height: 12),
              const Text('Không tìm thấy thông tin giao dịch'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    final date = transfer.transferDate;
    final dateStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} · ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final isCross = transfer.fromCurrency.toUpperCase() !=
        transfer.toCurrency.toUpperCase();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const PageHeader.subPage(
        title: 'Chi tiết giao dịch',
        subtitle: 'Chuyển tiền nội bộ',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ──────────────── 1. HERO AMOUNT CARD ────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    CurrencyFormatter.format(
                      transfer.fromAmount,
                      currency: transfer.fromCurrency,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  if (isCross) ...[
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${CurrencyFormatter.format(transfer.toAmount, currency: transfer.toCurrency)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ──────────────── 2. TÀI KHOẢN LIÊN QUAN ────────────────
            FormCard(
              title: 'TÀI KHOẢN LIÊN QUAN',
              child: Column(
                children: [
                  _detailRow(
                    label: 'Tài khoản trích tiền (Nguồn)',
                    value: transfer.fromAccount?.name ?? 'TK nguồn',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _detailRow(
                    label: 'Tài khoản thụ hưởng (Đích)',
                    value: transfer.toAccount?.name ?? 'TK đích',
                    isDark: isDark,
                  ),
                  if (isCross) ...[
                    const Divider(height: 20),
                    _detailRow(
                      label: 'Tỷ giá áp dụng',
                      value:
                          '1 ${transfer.fromCurrency} = ${CurrencyFormatter.format(transfer.exchangeRate, currency: transfer.toCurrency)}',
                      isDark: isDark,
                    ),
                  ],
                  if (transfer.fee > 0) ...[
                    const Divider(height: 20),
                    _detailRow(
                      label: 'Phí giao dịch',
                      value: CurrencyFormatter.format(
                        transfer.fee,
                        currency: transfer.fromCurrency,
                      ),
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ──────────────── 3. GHI CHÚ & MÃ GD ────────────────
            FormCard(
              title: 'THÔNG TIN BỔ SUNG',
              child: Column(
                children: [
                  if (transfer.note != null && transfer.note!.isNotEmpty) ...[
                    _detailRow(
                      label: 'Ghi chú',
                      value: transfer.note!,
                      isDark: isDark,
                    ),
                    const Divider(height: 20),
                  ],
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: transfer.id));
                      AppToast.success(context, 'Đã sao chép mã giao dịch!');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mã giao dịch',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  transfer.id.length > 12
                                      ? '${transfer.id.substring(0, 8)}...'
                                      : transfer.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkForeground
                  : AppColors.lightForeground,
            ),
          ),
        ),
      ],
    );
  }
}
