class FriendResponseDto {
  final String friendshipId;
  final String userId;
  final String fullName;
  final String username;
  final String? avatar;
  final String? email;
  final String? phone;
  final String status;
  final String? connectedAt;

  const FriendResponseDto({
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

  factory FriendResponseDto.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ cả NestJS FriendResponseDto { id, fullName, email, avatar, connectedAt }
    // và nested format { id, friend: { id, fullName, ... } }
    final friend = json['friend'] as Map<String, dynamic>? ?? json;
    final id = json['id'] as String? ?? '';
    final friendId = friend['id'] as String? ?? id;

    return FriendResponseDto(
      friendshipId: id,
      userId: friendId,
      fullName: friend['fullName'] as String? ?? '',
      username: friend['username'] as String? ?? (friend['email'] as String? ?? '').split('@').first,
      avatar: friend['avatar'] as String?,
      email: friend['email'] as String?,
      phone: friend['phone'] as String?,
      status: json['status'] as String? ?? 'ACCEPTED',
      connectedAt: (json['connectedAt'] ?? json['createdAt'])?.toString(),
    );
  }
}

class FriendRequestResponseDto {
  final String friendshipId;
  final String requesterId;
  final String requesterName;
  final String requesterUsername;
  final String? requesterAvatar;
  final String requestedAt;
  final String type; // 'received' | 'sent'

  const FriendRequestResponseDto({
    required this.friendshipId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterUsername,
    this.requesterAvatar,
    required this.requestedAt,
    this.type = 'received',
  });

  factory FriendRequestResponseDto.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ NestJS PendingFriendRequestResponseDto { id, user: { id, fullName, email, avatar }, type, createdAt }
    final user = json['user'] as Map<String, dynamic>? ??
        json['requester'] as Map<String, dynamic>? ??
        json;

    return FriendRequestResponseDto(
      friendshipId: json['id'] as String? ?? '',
      requesterId: user['id'] as String? ?? '',
      requesterName: user['fullName'] as String? ?? '',
      requesterUsername: user['username'] as String? ?? (user['email'] as String? ?? '').split('@').first,
      requesterAvatar: user['avatar'] as String?,
      requestedAt: (json['createdAt'] ?? json['requestedAt'] ?? DateTime.now().toIso8601String()).toString(),
      type: json['type'] as String? ?? 'received',
    );
  }
}

class UserSearchResultDto {
  final String userId;
  final String fullName;
  final String username;
  final String? avatar;
  final String? email;
  final String relationStatus; // NONE, ACCEPTED, PENDING_SENT, PENDING_RECEIVED, BLOCKED
  final String? friendshipId;

  const UserSearchResultDto({
    required this.userId,
    required this.fullName,
    required this.username,
    this.avatar,
    this.email,
    required this.relationStatus,
    this.friendshipId,
  });

  factory UserSearchResultDto.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ NestJS SearchUserResultDto { id, fullName, email, avatar, relationStatus }
    final relation = json['relationStatus'] as String? ??
        json['friendshipStatus'] as String? ??
        'NONE';

    return UserSearchResultDto(
      userId: json['id'] as String? ?? json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String? ?? (json['email'] as String? ?? '').split('@').first,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      relationStatus: relation,
      friendshipId: json['friendshipId'] as String?,
    );
  }
}
