import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/message.dart';
import '../../domain/models/message_enums.dart';

class P2pChatBubble extends StatelessWidget {
  const P2pChatBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('HH:mm').format(message.createdAt);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine
              ? null
              : Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Thẻ đính kèm giao dịch chia tiền nếu có
            if (message.transactionAttachment != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMine
                      ? Colors.white.withValues(alpha: 0.15)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.25)
                        : AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.transactionAttachment?.categoryIcon ?? '💳',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.transactionAttachment?.title ?? 'Giao dịch',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isMine ? Colors.white : AppColors.primary,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(message.transactionAttachment?.amount ?? 0),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isMine ? Colors.white : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Nội dung văn bản
            Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isMine
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),

            // Thời gian và trạng thái
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.75)
                        : AppColors.lightMuted,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == MessageDeliveryStatus.read
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

