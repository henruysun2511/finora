class Friend {
  const Friend({
    required this.friendshipId,
    required this.userId,
    required this.fullName,
    required this.username,
    this.avatar,
    this.email,
    this.phone,
    required this.status,
    this.connectedAt,
  });

  final String friendshipId;
  final String userId;
  final String fullName;
  final String username;
  final String? avatar;
  final String? email;
  final String? phone;
  final FriendshipStatus status;
  final DateTime? connectedAt;

  String get displayName => fullName.isNotEmpty ? fullName : username;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

enum FriendshipStatus { accepted, pending, sentRequest, blocked }
