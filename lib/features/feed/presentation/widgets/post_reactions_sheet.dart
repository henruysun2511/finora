import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/post_reaction.dart';

class PostReactionsSheet extends StatelessWidget {
  const PostReactionsSheet({
    super.key,
    required this.reactions,
  });

  final List<PostReaction> reactions;

  static Future<void> show(
    BuildContext context, {
    required List<PostReaction> reactions,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostReactionsSheet(reactions: reactions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Cảm xúc bài đăng',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${reactions.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (reactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Chưa có ai thả cảm xúc vào bài này',
                  style: TextStyle(color: muted, fontSize: 14),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: reactions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: border.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final item = reactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            backgroundImage: item.avatar != null
                                ? NetworkImage(item.avatar!)
                                : null,
                            child: item.avatar == null
                                ? Text(
                                    item.initials,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: foreground,
                              ),
                            ),
                          ),
                          Text(
                            item.emoji.symbol,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

