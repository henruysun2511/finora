import 'package:flutter/material.dart';

import '../../../../core/widgets/lucide_icon.dart';

class FeedStoryItem {
  const FeedStoryItem({
    required this.name,
    required this.initials,
    required this.gradient,
    this.isSeen = false,
  });

  final String name;
  final String initials;
  final List<Color> gradient;
  final bool isSeen;
}

/// Khối Stories cuộn ngang hiển thị bên trong Hero Banner (.lf-stories)
class FeedStoriesBar extends StatelessWidget {
  const FeedStoriesBar({
    super.key,
    required this.stories,
    this.selectedFriendName,
    required this.onFriendSelected,
    required this.onAddBill,
  });

  final List<FeedStoryItem> stories;
  final String? selectedFriendName;
  final ValueChanged<String?> onFriendSelected;
  final VoidCallback onAddBill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddBillStoryHero();
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.2),
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
                gradient: LinearGradient(
                  colors: story.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
