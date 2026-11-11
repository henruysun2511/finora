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

  @override
  Future<List<Friend>> getFriends() async {
    final dtos = await _api.getFriends();
    return dtos.map(mapper.toDomainFriend).toList();
  }

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    final dtos = await _api.getFriendRequests();
    return dtos.map(mapper.toDomainRequest).toList();
  }

  @override
  Future<List<FriendRequest>> getSentRequests() async {
    final dtos = await _api.getSentRequests();
    return dtos.map(mapper.toDomainRequest).toList();
  }

  @override
  Future<List<UserSearchResult>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final dtos = await _api.searchUsers(query);
    return dtos.map(mapper.toDomainSearchResult).toList();
  }

  @override
  Future<void> sendFriendRequest(String userId) async {
    await _api.sendFriendRequest(userId);
  }

  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    await _api.acceptFriendRequest(friendshipId);
  }

  @override
  Future<void> rejectFriendRequest(String friendshipId) async {
    await _api.rejectFriendRequest(friendshipId);
  }

  @override
  Future<void> removeFriend(String targetUserId) async {
    await _api.removeFriend(targetUserId);
  }

  @override
  Future<void> blockUser(String targetUserId) async {
    await _api.blockUser(targetUserId);
  }
}
