import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/user_search_result.dart';
import '../dto/friend_response.dart';

class FriendsMapper {
  const FriendsMapper();

  Friend toDomainFriend(FriendResponseDto dto) {
    return Friend(
      friendshipId: dto.friendshipId,
      userId: dto.userId,
      fullName: dto.fullName,
      username: dto.username,
      avatar: dto.avatar,
      email: dto.email,
      phone: dto.phone,
      status: _parseStatus(dto.status),
      connectedAt: dto.connectedAt != null
          ? DateTime.tryParse(dto.connectedAt!)
          : null,
    );
  }

  FriendRequest toDomainRequest(FriendRequestResponseDto dto) {
    return FriendRequest(
      friendshipId: dto.friendshipId,
      requesterId: dto.requesterId,
      requesterName: dto.requesterName,
      requesterUsername: dto.requesterUsername,
      requesterAvatar: dto.requesterAvatar,
      requestedAt: DateTime.tryParse(dto.requestedAt) ?? DateTime.now(),
    );
  }

  UserSearchResult toDomainSearchResult(UserSearchResultDto dto) {
    return UserSearchResult(
      userId: dto.userId,
      fullName: dto.fullName,
      username: dto.username,
      avatar: dto.avatar,
      email: dto.email,
      friendshipStatus: _parseStatus(dto.relationStatus),
      friendshipId: dto.friendshipId,
    );
  }

  FriendshipStatus _parseStatus(String s) {
    return switch (s.toUpperCase()) {
      'ACCEPTED' => FriendshipStatus.accepted,
      'PENDING' || 'PENDING_RECEIVED' => FriendshipStatus.pending,
      'SENT_REQUEST' || 'SENT' || 'PENDING_SENT' => FriendshipStatus.sentRequest,
      'BLOCKED' => FriendshipStatus.blocked,
      _ => FriendshipStatus.accepted,
    };
  }
}
