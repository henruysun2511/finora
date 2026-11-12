import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/form_card.dart';
import '../../domain/models/receipt_model.dart';

class TransactionDetailReceiptCard extends StatelessWidget {
  const TransactionDetailReceiptCard({
    super.key,
    this.receipt,
    this.photoUrl,
    this.currency = 'VND',
    required this.onTapImage,
  });

  final ReceiptModel? receipt;
  final String? photoUrl;
  final String currency;
  final void Function(String url) onTapImage;

  String _formatAmount(double amount) {
    final formatted = NumberFormat('#,###', 'vi_VN').format(amount.round());
    if (currency.toUpperCase() == 'VND') {
      return '$formatted ₫';
    }
    return '$formatted $currency';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardBg = isDark
        ? AppColors.darkBackground.withValues(alpha: 0.6)
        : const Color(0xFFF8FAFC);

    final effectivePhotoUrl = (photoUrl != null && photoUrl!.isNotEmpty)
        ? photoUrl
        : receipt?.imageUrl;

    final hasMerchant = (receipt?.merchantName != null &&
            receipt!.merchantName!.trim().isNotEmpty) ||
        (receipt?.merchantAddress != null &&
            receipt!.merchantAddress!.trim().isNotEmpty);

    final hasItems = receipt != null && receipt!.items.isNotEmpty;

    return FormCard(
      title: 'HÓA ĐƠN & BẢNG KÊ CHỨNG TỪ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. MERCHANT & STORE BANNER (NẾU CÓ DỮ LIỆU) ──
          if (hasMerchant) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (receipt?.merchantName != null &&
                            receipt!.merchantName!.trim().isNotEmpty)
                          Text(
                            receipt!.merchantName!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        if (receipt?.merchantAddress != null &&
                            receipt!.merchantAddress!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            receipt!.merchantAddress!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.document_scanner_rounded,
                          color: AppColors.primary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OCR Đã quét',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── 2. ẢNH HÓA ĐƠN ĐÍNH KÈM (THUMBNAIL + TAP TO ZOOM) ──
          if (effectivePhotoUrl != null && effectivePhotoUrl.isNotEmpty) ...[
            InkWell(
              onTap: () => onTapImage(effectivePhotoUrl),
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      !kIsWeb && File(effectivePhotoUrl).existsSync()
                          ? Image.file(
                              File(effectivePhotoUrl),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              effectivePhotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: muted,
                                  size: 40,
                                ),
                              ),
                            ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.25),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
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
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Chạm để phóng to ảnh chứng từ',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── 3. BẢNG DANH SÁCH MÓN & CHI TIẾT DÒNG HÀNG (LINE ITEMS) ──
          if (hasItems) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  // Header hàng cột
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'MẶT HÀNG / DỊCH VỤ',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: muted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'SL',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: muted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'ĐƠN GIÁ',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: muted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'THÀNH TIỀN',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: muted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Danh sách các món
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: receipt!.items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 0.8,
                      color: border.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, idx) {
                      final it = receipt!.items[idx];
                      final qtyStr = it.quantity % 1 == 0
                          ? it.quantity.toInt().toString()
                          : it.quantity.toString();
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                it.name,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: fg,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                qtyStr,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: muted,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatAmount(it.unitPrice),
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: muted,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatAmount(it.totalPrice),
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: fg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── 4. TỔNG HỢP TIỀN: TẠM TÍNH, THUẾ, TIP & TỔNG CỘNG ──
          if (receipt != null &&
              (receipt!.totalAmount > 0 ||
                  (receipt!.taxAmount != null && receipt!.taxAmount! > 0) ||
                  (receipt!.tipAmount != null && receipt!.tipAmount! > 0))) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  if (hasItems) ...[
                    _buildSummaryRow(
                      context,
                      label: 'Tạm tính (Subtotal)',
                      value: _formatAmount(
                        receipt!.items.fold<double>(
                          0,
                          (sum, item) => sum + item.totalPrice,
                        ),
                      ),
                      isMuted: true,
                    ),
                  ],
                  if (receipt!.taxAmount != null &&
                      receipt!.taxAmount! > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      context,
                      label: 'Thuế VAT',
                      value: '+${_formatAmount(receipt!.taxAmount!)}',
                      isMuted: true,
                    ),
                  ],
                  if (receipt!.tipAmount != null &&
                      receipt!.tipAmount! > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      context,
                      label: 'Tiền Tip / Phí dịch vụ',
                      value: '+${_formatAmount(receipt!.tipAmount!)}',
                      isMuted: true,
                    ),
                  ],
                  Divider(
                    height: 16,
                    thickness: 1,
                    color: border,
                  ),
                  _buildSummaryRow(
                    context,
                    label: 'TỔNG CỘNG HÓA ĐƠN',
                    value: _formatAmount(receipt!.totalAmount),
                    isBold: true,
                    highlightColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ] else if (!hasItems &&
              effectivePhotoUrl != null &&
              effectivePhotoUrl.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ảnh hóa đơn đã được đính kèm. Bạn có thể nhấn vào ảnh để xem toàn văn chứng từ gốc.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: muted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    bool isMuted = false,
    Color? highlightColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isBold ? 12 : 11,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isMuted ? muted : fg,
            letterSpacing: isBold ? 0.3 : 0,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: highlightColor ?? (isMuted ? muted : fg),
          ),
        ),
      ],
    );
  }
}
