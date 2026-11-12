import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/friends/data/dto/friend_response.dart';
import 'package:finora_mb/features/friends/data/mappers/friends_mapper.dart';
import 'package:finora_mb/features/friends/domain/models/friend.dart';

void main() {
  const mapper = FriendsMapper();

  group('FriendsMapper - toDomainFriend', () {
    test('chuyển đổi FriendResponseDto sang Friend domain model', () {
      const dto = FriendResponseDto(
        friendshipId: 'fs-123',
        userId: 'u-456',
        fullName: 'Nguyễn Văn A',
        username: 'nguyenvana',
        status: 'ACCEPTED',
        connectedAt: '2026-10-19T00:00:00.000Z',
      );

      final friend = mapper.toDomainFriend(dto);

      expect(friend.friendshipId, 'fs-123');
      expect(friend.userId, 'u-456');
      expect(friend.fullName, 'Nguyễn Văn A');
      expect(friend.username, 'nguyenvana');
      expect(friend.status, FriendshipStatus.accepted);
      expect(friend.displayName, 'Nguyễn Văn A');
      expect(friend.initials, 'NA');
    });
  });

  group('FriendsMapper - toDomainRequest', () {
    test('chuyển đổi FriendRequestResponseDto sang FriendRequest model', () {
      final dto = FriendRequestResponseDto(
        friendshipId: 'fr-123',
        requesterId: 'u-789',
        requesterName: 'Trần Thị B',
        requesterUsername: 'tranthib',
        requestedAt: DateTime.now().toIso8601String(),
      );

      final request = mapper.toDomainRequest(dto);

      expect(request.friendshipId, 'fr-123');
      expect(request.requesterId, 'u-789');
      expect(request.requesterName, 'Trần Thị B');
      expect(request.displayName, 'Trần Thị B');
      expect(request.initials, 'TB');
    });
  });

  group('FriendsMapper - toDomainSearchResult', () {
    test('chuyển đổi UserSearchResultDto sang UserSearchResult model', () {
      const dto = UserSearchResultDto(
        userId: 'u-999',
        fullName: 'Hoàng Văn C',
        username: 'hoangvanc',
        relationStatus: 'PENDING_SENT',
      );

      final result = mapper.toDomainSearchResult(dto);

      expect(result.userId, 'u-999');
      expect(result.fullName, 'Hoàng Văn C');
      expect(result.friendshipStatus, FriendshipStatus.sentRequest);
      expect(result.initials, 'HC');
    });
  });
}
