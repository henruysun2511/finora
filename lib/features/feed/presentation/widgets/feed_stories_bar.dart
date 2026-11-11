import 'package:flutter/material.dart';

import '../../../../core/widgets/lucide_icon.dart';

class FeedStoryItem {
  const FeedStoryItem({
    this.id,
    required this.name,
    required this.initials,
    this.avatar,
    required this.gradient,
    this.isSeen = false,
  });

  final String? id;
  final String name;
  final String initials;
  final String? avatar;
  final List<Color> gradient;
  final bool isSeen;
}

/// Khối Stories cuộn ngang hiển thị bên trong Hero Banner (.lf-stories)
class FeedStoriesBar extends StatelessWidget {
  const FeedStoriesBar({
    super.key,
    required this.stories,
    this.isLoading = false,
    this.selectedFriendName,
    required this.onFriendSelected,
    required this.onAddBill,
    this.onAddFriend,
  });

  final List<FeedStoryItem> stories;
  final bool isLoading;
  final String? selectedFriendName;
  final ValueChanged<String?> onFriendSelected;
  final VoidCallback onAddBill;
  final VoidCallback? onAddFriend;

  @override
  Widget build(BuildContext context) {
    if (isLoading && stories.isEmpty) {
      return SizedBox(
        height: 94,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            if (index == 0) return _buildAddBillStoryHero();
            return _buildShimmerHero();
          },
        ),
      );
    }

    // Nếu chưa có bạn bè, hiện nút Thêm bạn bên cạnh Chia bill
    final displayCount = stories.isEmpty ? 2 : stories.length + 1;

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayCount,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddBillStoryHero();
          }

          if (stories.isEmpty) {
            return _buildAddFriendStoryHero();
          }

          final story = stories[index - 1];
          final isFilterActive = selectedFriendName == story.name;
          return _buildFriendStoryHero(
            story: story,
            isActive: isFilterActive,
            onTap: () {
              if (selectedFriendName == story.name) {
                onFriendSelected(null);
              } else {
                onFriendSelected(story.name);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAddBillStoryHero() {
    return InkWell(
      onTap: onAddBill,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Center(
                child: LucideIcon(
                  name: 'plus',
                  color: Colors.white,
                  size: 24,
                  strokeWidth: 2.4,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Chia bill',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFriendStoryHero() {
    return InkWell(
      onTap: onAddFriend,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.8,
                ),
              ),
              child: const Center(
                child: LucideIcon(
                  name: 'user-plus',
                  color: Colors.white,
                  size: 22,
                  strokeWidth: 2.2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thêm bạn',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerHero() {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendStoryHero({
    required FeedStoryItem story,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final hasAvatar = story.avatar != null && story.avatar!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Colors.white, Color(0xFF67E8F9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : (story.isSeen
                        ? LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.45),
                              Colors.white.withValues(alpha: 0.25),
                            ],
                          )
                        : LinearGradient(
                            colors: story.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasAvatar
                      ? null
                      : LinearGradient(
                          colors: story.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  image: hasAvatar
                      ? DecorationImage(
                          image: NetworkImage(story.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: hasAvatar
                    ? null
                    : Text(
                        story.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              story.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
