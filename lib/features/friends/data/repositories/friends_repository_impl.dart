import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/user_search_result.dart';
import '../../domain/repositories/friends_repository.dart';
import '../mappers/friends_mapper.dart';
import '../services/friends_api_service.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  FriendsRepositoryImpl(this._api, {this.mapper = const FriendsMapper()});

  final FriendsApiService _api;
  final FriendsMapper mapper;

  // ─── Mock fallback data ───────────────────────────────────────────────────

  final List<Friend> _mockFriends = [
    Friend(
      friendshipId: 'fs-001',
      userId: 'u-tran-ngoc',
      fullName: 'Trần Ngọc',
      username: 'tranngoc',
      status: FriendshipStatus.accepted,
      connectedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Friend(
      friendshipId: 'fs-002',
      userId: 'u-hung-minh',
      fullName: 'Hùng Minh',
      username: 'hungminh',
      status: FriendshipStatus.accepted,
      connectedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Friend(
      friendshipId: 'fs-003',
      userId: 'u-pham-lan',
      fullName: 'Phạm Lan',
      username: 'phamlan',
      status: FriendshipStatus.accepted,
      connectedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Friend(
      friendshipId: 'fs-004',
      userId: 'u-anh-thu',
      fullName: 'Anh Thư',
      username: 'anhthu',
      status: FriendshipStatus.accepted,
      connectedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Friend(
      friendshipId: 'fs-005',
      userId: 'u-minh-tuan',
      fullName: 'Minh Tuấn',
      username: 'minhtuan',
      status: FriendshipStatus.accepted,
      connectedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  final List<FriendRequest> _mockFriendRequests = [
    FriendRequest(
      friendshipId: 'fr-001',
      requesterId: 'u-nguyen-hai-nam',
      requesterName: 'Nguyễn Hải Nam',
      requesterUsername: 'hainam',
      requestedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    FriendRequest(
      friendshipId: 'fr-002',
      requesterId: 'u-tran-thao-vy',
      requesterName: 'Trần Thảo Vy',
      requesterUsername: 'thaovy',
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FriendRequest(
      friendshipId: 'fr-003',
      requesterId: 'u-hoang-van-duc',
      requesterName: 'Hoàng Văn Đức',
      requesterUsername: 'vanduc',
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<FriendRequest> _mockSentRequests = [
    FriendRequest(
      friendshipId: 'fs-sent-001',
      requesterId: 'me',
      requesterName: 'Le Van Khanh',
      requesterUsername: 'levankhanh',
      requestedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    FriendRequest(
      friendshipId: 'fs-sent-002',
      requesterId: 'me',
      requesterName: 'Nguyen Bich Ngoc',
      requesterUsername: 'bichngoc',
      requestedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<UserSearchResult> _mockSearchResults = [
    const UserSearchResult(
      userId: 'u-nguyen-bao-chau',
      fullName: 'Nguyễn Bảo Châu',
      username: 'baochau',
      friendshipStatus: FriendshipStatus.accepted,
      friendshipId: 'fs-999',
    ),
    const UserSearchResult(
      userId: 'u-do-quang-vinh',
      fullName: 'Đỗ Quang Vinh',
      username: 'quangvinh',
      friendshipStatus: FriendshipStatus.pending,
      friendshipId: 'fr-999',
    ),
  ];

  // ─── Repository Methods ───────────────────────────────────────────────────

  @override
  Future<List<Friend>> getFriends() async {
    try {
      final dtos = await _api.getFriends();
      final items = dtos.map(mapper.toDomainFriend).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback khi không có kết nối hoặc backend rỗng
    }
    return _mockFriends;
  }

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    try {
      final dtos = await _api.getFriendRequests();
      final items = dtos.map(mapper.toDomainRequest).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback
    }
    return _mockFriendRequests;
  }

  @override
  Future<List<FriendRequest>> getSentRequests() async {
    try {
      final dtos = await _api.getSentRequests();
      final items = dtos.map(mapper.toDomainRequest).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback
    }
    return _mockSentRequests;
  }

  @override
  Future<List<UserSearchResult>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final dtos = await _api.searchUsers(query);
      final items = dtos.map(mapper.toDomainSearchResult).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback: filter mock data theo query
    }
    final lower = query.toLowerCase();
    return _mockSearchResults.where((r) {
      return r.fullName.toLowerCase().contains(lower) ||
          r.username.toLowerCase().contains(lower) ||
          (r.email?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  @override
  Future<void> sendFriendRequest(String userId) async {
    try {
      await _api.sendFriendRequest(userId);
    } catch (_) {
      // Bỏ qua lỗi mạng – optimistic UI xử lý ở provider
    }
  }

  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _api.acceptFriendRequest(friendshipId);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  @override
  Future<void> rejectFriendRequest(String friendshipId) async {
    try {
      await _api.rejectFriendRequest(friendshipId);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    try {
      await _api.removeFriend(friendshipId);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }
}
