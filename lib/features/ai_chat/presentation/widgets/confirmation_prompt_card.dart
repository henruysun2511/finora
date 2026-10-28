import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/models/send_message_input.dart';
import 'edit_transaction_draft_bottom_sheet.dart';

class ConfirmationPromptCard extends StatelessWidget {
  final ChatMessageModel message;
  final ValueChanged<String>? onConfirm;
  final ValueChanged<String>? onReject;
  final void Function(String actionId, EditTransactionDraft draft)? onSaveDraft;

  const ConfirmationPromptCard({
    super.key,
    required this.message,
    this.onConfirm,
    this.onReject,
    this.onSaveDraft,
  });

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 ₫';
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  @override
  Widget build(BuildContext context) {
    final payload = message.payloadJson ?? {};
    if (payload['result'] != null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingAction = message.pendingAction;
    final actionId = (pendingAction != null && pendingAction.id.isNotEmpty)
        ? pendingAction.id
        : (payload['pendingActionId']?.toString() ?? '');
    final status = pendingAction?.status ?? PendingActionStatusEnum.pending;

    // Trích xuất thông tin giao dịch từ preview hoặc toolInput hoặc payload gốc
    final preview = payload['preview'] is Map
        ? Map<String, dynamic>.from(payload['preview'] as Map)
        : (payload['toolInput'] is Map
            ? Map<String, dynamic>.from(payload['toolInput'] as Map)
            : payload);

    if (preview['amount'] == null && payload['amount'] == null && preview['amountFormatted'] == null) {
      return const SizedBox.shrink();
    }

    final txName = preview['name'] ??
        preview['transaction_name'] ??
        preview['title'] ??
        payload['name'] ??
        payload['transaction_name'] ??
        payload['title'] ??
        'Giao dịch chi tiêu';

    final amountVal = (preview['amount'] as num?) ??
        (payload['amount'] as num?) ??
        0;

    final formattedAmount = preview['amountFormatted']?.toString();

    final categoryName = preview['categoryName'] ??
        preview['category'] ??
        preview['category_name'] ??
        payload['categoryName'] ??
        payload['category'] ??
        'Chưa phân loại';

    final accountName = preview['accountName'] ??
        preview['account'] ??
        preview['account_name'] ??
        payload['accountName'] ??
        payload['account'] ??
        'Tiền Mặt Sẵn Có';

    final isIncome = preview['type']?.toString().toUpperCase() == 'INCOME' ||
        payload['type']?.toString().toUpperCase() == 'INCOME';

    final dateStr = preview['date']?.toString() ?? payload['date']?.toString();
    final noteStr = preview['note']?.toString() ?? payload['note']?.toString();
    final photoUrl = message.imageUrl ??
        preview['photoUrl']?.toString() ??
        payload['photoUrl']?.toString() ??
        preview['imageUrl']?.toString() ??
        payload['imageUrl']?.toString() ??
        preview['receiptUrl']?.toString() ??
        payload['receiptUrl']?.toString();
    final budgetRemaining = preview['budgetRemaining'] ??
        preview['budget_remaining'] ??
        payload['budgetRemaining'] ??
        payload['budget_remaining'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8, bottom: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: status == PendingActionStatusEnum.confirmed
                  ? const Color(0xFF10B981).withValues(alpha: 0.5)
                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XÁC NHẬN GIAO DỊCH TỰ ĐỘNG',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (status == PendingActionStatusEnum.confirmed)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 13, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            'Đã ghi sổ',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (status == PendingActionStatusEnum.rejected)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Đã hủy bỏ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                  else if (status == PendingActionStatusEnum.expired)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Đã hết hạn',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 1: Khoản chi & Số tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      txName.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${formattedAmount ?? _formatCurrency(amountVal)}',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isIncome
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: Danh mục
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh mục',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      categoryName.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 3: Nguồn tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tài khoản',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    accountName.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),

              // Row 4: Ngày ghi sổ nếu có
              if (dateStr != null && dateStr.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                  ],
                ),
              ],

              // Row 5: Ảnh hóa đơn nếu có
              if (photoUrl != null && photoUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hóa đơn đính kèm',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
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
                                  child: Image.network(photoUrl, fit: BoxFit.contain),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                    ),
                                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0072D5).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt_long_rounded, size: 14, color: Color(0xFF0072D5)),
                            const SizedBox(width: 4),
                            Text(
                              'Xem hóa đơn',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0072D5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Action buttons if PENDING
              if (status == PendingActionStatusEnum.pending) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Sửa button (Edit draft)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: actionId.isNotEmpty
                            ? () async {
                                final draft =
                                    await EditTransactionDraftBottomSheet.show(
                                  context,
                                  initialType: isIncome ? 'INCOME' : 'EXPENSE',
                                  initialName: txName.toString(),
                                  initialAmount: amountVal,
                                  initialCategory: categoryName.toString(),
                                  initialCategoryId: preview['categoryId']?.toString() ??
                                      payload['categoryId']?.toString(),
                                  initialAccount: accountName.toString(),
                                  initialAccountId: preview['accountId']?.toString() ??
                                      payload['accountId']?.toString(),
                                  initialDate: dateStr,
                                  initialNote: noteStr,
                                  initialLocation: preview['locationName']?.toString() ??
                                      payload['locationName']?.toString(),
                                  initialAmountHidden: preview['amountHidden'] == true ||
                                      payload['amountHidden'] == true,
                                  initialExcludeFromReport:
                                      preview['excludeFromReport'] == true ||
                                          payload['excludeFromReport'] == true,
                                  initialVisibility: preview['visibility']?.toString() ??
                                      payload['visibility']?.toString() ??
                                      'PRIVATE',
                                  initialPhotoUrl: photoUrl,
                                );
                                if (draft != null) {
                                  onSaveDraft?.call(actionId, draft);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã cập nhật bản nháp. Bấm "Xác nhận ghi sổ" để hoàn tất.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(
                          'Sửa',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          foregroundColor: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Confirm button (Xác nhận ghi sổ)
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        onPressed: actionId.isNotEmpty
                            ? () => onConfirm?.call(actionId)
                            : null,
                        icon: const Icon(Icons.check_rounded,
                            size: 17, color: Colors.white),
                        label: Text(
                          'Xác nhận ghi sổ',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          backgroundColor: const Color(0xFF0072D5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reject button (Hủy bỏ)
                    IconButton(
                      onPressed: actionId.isNotEmpty
                          ? () => onReject?.call(actionId)
                          : null,
                      tooltip: 'Hủy bỏ',
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: Colors.redAccent),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Budget hint below card (match .budget-hint in device-preview)
        if (budgetRemaining != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.track_changes_rounded,
                  size: 14,
                  color: Color(0xFF0072D5),
                ),
                const SizedBox(width: 5),
                Text(
                  '$categoryName tháng này: còn ${_formatCurrency(budgetRemaining as num?)}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0072D5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
