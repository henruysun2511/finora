import 'friend.dart';

class UserSearchResult {
  const UserSearchResult({
    required this.userId,
    required this.fullName,
    required this.username,
    this.avatar,
    this.email,
    required this.friendshipStatus,
    this.friendshipId,
  });

  final String userId;
  final String fullName;
  final String username;
  final String? avatar;
  final String? email;
  final FriendshipStatus friendshipStatus;
  final String? friendshipId;

  String get displayName => fullName.isNotEmpty ? fullName : username;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
