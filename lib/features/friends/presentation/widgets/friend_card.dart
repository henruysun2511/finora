import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/friend.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    required this.onChat,
    required this.onUnfriend,
    this.onBlock,
  });

  final Friend friend;
  final VoidCallback onChat;
  final VoidCallback onUnfriend;
  final VoidCallback? onBlock;

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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

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
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _avatarGradient(friend.userId),
            ),
            alignment: Alignment.center,
            child: Text(
              friend.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            friend.displayName,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: foreground,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (friend.email != null)
                Text(
                  friend.email!,
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              if (friend.connectedAt != null)
                Text(
                  'Kết nối ${_timeAgo(friend.connectedAt!)}',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                color: AppColors.primary,
                tooltip: 'Nhắn tin',
                onPressed: onChat,
              ),
              Flexible(
                  child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: muted),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                color: surface,
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'unfriend',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_rounded,
                            size: 18, color: AppColors.danger),
                        SizedBox(width: 10),
                        Flexible(
                            child: Text(
                          'Hủy kết bạn',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ],
                    ),
                  ),
                  if (onBlock != null)
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block_rounded,
                              size: 18, color: AppColors.danger),
                          SizedBox(width: 10),
                          Flexible(
                              child: Text(
                            'Chặn người này',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ),
                ],
                onSelected: (val) {
                  if (val == 'unfriend') onUnfriend();
                  if (val == 'block') onBlock?.call();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
