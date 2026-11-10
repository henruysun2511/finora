class FriendRequest {
  const FriendRequest({
    required this.friendshipId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterUsername,
    this.requesterAvatar,
    required this.requestedAt,
  });

  final String friendshipId;
  final String requesterId;
  final String requesterName;
  final String requesterUsername;
  final String? requesterAvatar;
  final DateTime requestedAt;

  String get displayName => requesterName.isNotEmpty ? requesterName : requesterUsername;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
