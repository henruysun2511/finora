import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/split_enums.dart';
import '../../domain/models/split_participant_model.dart';

class SplitParticipantTile extends StatelessWidget {
  const SplitParticipantTile({
    super.key,
    required this.participant,
    required this.isOwner,
  });

  final SplitParticipantModel participant;
  final bool isOwner;

  Color _getStatusColor(ParticipantStatus status) {
    switch (status) {
      case ParticipantStatus.pending:
        return const Color(0xFFF59E0B);
      case ParticipantStatus.accepted:
        return AppColors.success;
      case ParticipantStatus.rejected:
        return AppColors.danger;
      case ParticipantStatus.proposed:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getStatusIcon(ParticipantStatus status) {
    switch (status) {
      case ParticipantStatus.pending:
        return Icons.hourglass_top_rounded;
      case ParticipantStatus.accepted:
        return Icons.check_circle_rounded;
      case ParticipantStatus.rejected:
        return Icons.cancel_rounded;
      case ParticipantStatus.proposed:
        return Icons.edit_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(participant.status);
    final statusIcon = _getStatusIcon(participant.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: participant.userAvatar != null
                    ? NetworkImage(participant.userAvatar!)
                    : null,
                child: participant.userAvatar == null
                    ? Text(
                        participant.initials,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),

              // Tên & Nhãn Chủ chi (nếu có)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            participant.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Chủ chi',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Badge trạng thái
                    Row(
                      children: [
                        Icon(statusIcon, size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text(
                          isOwner ? 'Đã chi trả' : participant.status.label,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isOwner ? AppColors.success : statusColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              // Số tiền phân bổ
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(participant.assignedAmount),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  if (participant.status == ParticipantStatus.proposed &&
                      participant.proposedAmount != null)
                    Text(
                      'Đề xuất: ${CurrencyFormatter.format(participant.proposedAmount!)}',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Lời nhắn / Ghi chú (nếu có)
          if (participant.note != null &&
              participant.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      participant.note!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
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
}
