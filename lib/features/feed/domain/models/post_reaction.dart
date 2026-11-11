import 'reaction_emoji.dart';

class PostReaction {
  const PostReaction({
    required this.userId,
    required this.fullName,
    this.avatar,
    required this.emoji,
    required this.createdAt,
  });

  final String userId;
  final String fullName;
  final String? avatar;
  final ReactionEmoji emoji;
  final DateTime createdAt;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

