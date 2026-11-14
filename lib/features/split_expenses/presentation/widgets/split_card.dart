import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/expense_split_model.dart';
import '../../domain/models/split_enums.dart';

class SplitCard extends StatelessWidget {
  const SplitCard({
    super.key,
    required this.split,
    required this.currentUserId,
    required this.onTap,
  });

  final ExpenseSplitModel split;
  final String? currentUserId;
  final VoidCallback onTap;

  Color _getStatusColor(SplitStatus status) {
    switch (status) {
      case SplitStatus.pending:
        return const Color(0xFFF59E0B);
      case SplitStatus.allAccepted:
        return AppColors.primary;
      case SplitStatus.confirmed:
        return AppColors.success;
      case SplitStatus.cancelled:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = split.isOwner(currentUserId);
    final statusColor = _getStatusColor(split.status);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(split.createdAt);

    final totalFriends = split.friendParticipants.length;
    final acceptedFriends = split.acceptedFriendsCount;
    final consensusRate = split.consensusRate;

    // Xác định số tiền liên quan đến người dùng hiện tại
    double userAmount = 0;
    if (isOwner) {
      // Số tiền bạn bè cần trả lại cho mình (tổng - phần của mình)
      final myAssigned = split.ownerParticipant?.assignedAmount ?? 0;
      userAmount = split.totalAmount - myAssigned;
    } else {
      // Số tiền mình phải trả
      final myPart = split.participants
          .where((p) => p.userId == currentUserId)
          .firstOrNull;
      userAmount = myPart?.assignedAmount ?? 0;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hàng 1: Icon + Người tạo / Ngày giờ + Badge Trạng thái
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isOwner
                            ? Icons.arrow_outward_rounded
                            : Icons.arrow_downward_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOwner
                                ? 'Bạn đã chi (${split.splitType.label})'
                                : '${split.creatorName ?? "Bạn bè"} đã chi',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          Text(
                            dateStr,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        split.status.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Hàng 2: Số tiền & Chi tiết
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOwner ? 'Cần thu lại từ nhóm' : 'Phần bạn phải trả',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(userAmount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isOwner
                                  ? AppColors.primary
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tổng hóa đơn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(split.totalAmount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Hàng 3: Thanh tiến độ đồng thuận
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: consensusRate,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? Colors.white12
                              : Colors.black.withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            split.status == SplitStatus.confirmed
                                ? AppColors.success
                                : (split.hasIssues
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$acceptedFriends/$totalFriends đồng ý',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
