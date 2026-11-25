import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/user_search_result.dart';

class UserSearchCard extends StatelessWidget {
  const UserSearchCard({
    super.key,
    required this.user,
    required this.onSendRequest,
    required this.onAcceptRequest,
  });

  final UserSearchResult user;
  final VoidCallback onSendRequest;
  final VoidCallback onAcceptRequest;

  LinearGradient _avatarGradient(String seed) {
    final gradients = [
      const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFF0072D6), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
    ];
    return gradients[seed.hashCode.abs() % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final isFriend = user.friendshipStatus == FriendshipStatus.accepted;
    final isSent = user.friendshipStatus == FriendshipStatus.sentRequest;
    final isPending = user.friendshipStatus == FriendshipStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _avatarGradient(user.userId),
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            user.displayName,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: foreground,
            ),
          ),
          subtitle: user.email != null
              ? Text(user.email!, style: TextStyle(fontSize: 12, color: muted))
              : null,
          trailing: isFriend
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: AppColors.success),
                      SizedBox(width: 4),
                      Flexible(
                          child: Text('Bạn bè',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                )
              : isSent
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Đã gửi',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    )
                  : isPending
                      ? FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: onAcceptRequest,
                          child: const Text('Chấp nhận',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        )
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: onSendRequest,
                          icon: const Icon(Icons.person_add_rounded, size: 15),
                          label: const Text('Kết bạn',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
        ),
      ),
    );
  }
}
