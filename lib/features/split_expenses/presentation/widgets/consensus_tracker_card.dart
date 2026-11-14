import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/expense_split_model.dart';
import '../../domain/models/split_enums.dart';

class ConsensusTrackerCard extends StatelessWidget {
  const ConsensusTrackerCard({
    super.key,
    required this.split,
  });

  final ExpenseSplitModel split;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalFriends = split.friendParticipants.length;
    final acceptedCount = split.acceptedFriendsCount;
    final rate = split.consensusRate;
    final percent = (rate * 100).round();

    final isConfirmed = split.isConfirmed;
    final isCancelled = split.isCancelled;
    final isAllAccepted = split.isAllAccepted;

    Color barColor = AppColors.primary;
    String statusTitle = '$percent% Bạn bè đã đồng ý';
    String statusSubtitle = 'Cần tất cả bạn bè đồng ý để chốt phiên';

    if (isConfirmed) {
      barColor = AppColors.success;
      statusTitle = 'Đã chốt phiên chia tiền';
      statusSubtitle = 'Khoản nợ đã được ghi nhận vào Sổ Nợ (Loans)';
    } else if (isCancelled) {
      barColor = AppColors.danger;
      statusTitle = 'Phiên chia tiền đã hủy';
      statusSubtitle = 'Chủ phiên đã hủy yêu cầu chia tiền này';
    } else if (isAllAccepted) {
      barColor = AppColors.success;
      statusTitle = '100% Đồng thuận! Sẵn sàng chốt';
      statusSubtitle = 'Tất cả bạn bè đã đồng ý, chủ phiên có thể bấm Chốt';
    } else if (split.hasIssues) {
      barColor = const Color(0xFFF59E0B);
      statusTitle = 'Có bạn bè từ chối hoặc đề xuất lại';
      statusSubtitle = 'Chủ phiên có thể điều chỉnh lại tiền (Rebalance)';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: barColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isConfirmed
                      ? Icons.verified_rounded
                      : (isAllAccepted
                          ? Icons.thumb_up_rounded
                          : Icons.handshake_outlined),
                  color: barColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusSubtitle,
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
              Text(
                '$acceptedCount/$totalFriends',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: isConfirmed ? 1.0 : rate,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

