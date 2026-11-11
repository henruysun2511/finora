import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/user_search_result.dart';
import 'friends_providers.dart';

// ─── Search query state ───────────────────────────────────────────────────────

final friendSearchQueryProvider = StateProvider<String>((ref) => '');

// ─── Combined state ───────────────────────────────────────────────────────────

class FriendsListState {
  const FriendsListState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.sentRequests = const [],
    this.searchResults = const [],
    this.isSearching = false,
    this.searchQuery = '',
  });

  final List<Friend> friends;
  final List<FriendRequest> pendingRequests;
  final List<FriendRequest> sentRequests;
  final List<UserSearchResult> searchResults;
  final bool isSearching;
  final String searchQuery;

  FriendsListState copyWith({
    List<Friend>? friends,
    List<FriendRequest>? pendingRequests,
    List<FriendRequest>? sentRequests,
    List<UserSearchResult>? searchResults,
    bool? isSearching,
    String? searchQuery,
  }) {
    return FriendsListState(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class FriendsListNotifier extends AsyncNotifier<FriendsListState> {
  Timer? _debounceTimer;

  @override
  Future<FriendsListState> build() async {
    ref.onDispose(() => _debounceTimer?.cancel());
    final repo = ref.read(friendsRepositoryProvider);
    final results = await Future.wait([
      repo.getFriends(),
      repo.getFriendRequests(),
      repo.getSentRequests(),
    ]);
    return FriendsListState(
      friends: results[0] as List<Friend>,
      pendingRequests: results[1] as List<FriendRequest>,
      sentRequests: results[2] as List<FriendRequest>,
    );
  }

  /// Làm mới danh sách bạn bè
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Tìm kiếm người dùng với debounce 400ms
  void search(String query) {
    _debounceTimer?.cancel();

    final trimmed = query.trim();

    // Cập nhật query ngay lập tức
    state = state.whenData(
      (s) => s.copyWith(searchQuery: trimmed, isSearching: trimmed.isNotEmpty),
    );

    if (trimmed.isEmpty) {
      state = state.whenData((s) => s.copyWith(searchResults: [], isSearching: false));
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final repo = ref.read(friendsRepositoryProvider);
      try {
        final results = await repo.searchUsers(trimmed);
        state = state.whenData(
          (s) => s.copyWith(searchResults: results, isSearching: false),
        );
      } catch (_) {
        state = state.whenData((s) => s.copyWith(searchResults: [], isSearching: false));
      }
    });
  }

  /// Gửi lời mời kết bạn với Optimistic UI
  Future<void> sendRequest(String userId) async {
    final repo = ref.read(friendsRepositoryProvider);
    // Optimistic: đánh dấu ngay trên search results
    state = state.whenData((s) {
      final updated = s.searchResults.map((r) {
        if (r.userId == userId) {
          return UserSearchResult(
            userId: r.userId,
            fullName: r.fullName,
            username: r.username,
            avatar: r.avatar,
            email: r.email,
            friendshipStatus: FriendshipStatus.sentRequest,
            friendshipId: r.friendshipId,
          );
        }
        return r;
      }).toList();
      return s.copyWith(searchResults: updated);
    });

    try {
      await repo.sendFriendRequest(userId);
    } catch (_) {
      // Revert nếu API thất bại
      state = state.whenData((s) {
        final reverted = s.searchResults.map((r) {
          if (r.userId == userId) {
            return UserSearchResult(
              userId: r.userId,
              fullName: r.fullName,
              username: r.username,
              avatar: r.avatar,
              email: r.email,
              friendshipStatus: FriendshipStatus.none,
              friendshipId: r.friendshipId,
            );
          }
          return r;
        }).toList();
        return s.copyWith(searchResults: reverted);
      });
      rethrow;
    }
  }

  /// Chấp nhận lời mời kết bạn
  Future<void> acceptRequest(String friendshipId) async {
    final repo = ref.read(friendsRepositoryProvider);
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic: chuyển request → friend
    final acceptedReq = currentState.pendingRequests
        .where((r) => r.friendshipId == friendshipId)
        .firstOrNull;

    state = state.whenData((s) {
      final remaining = s.pendingRequests
          .where((r) => r.friendshipId != friendshipId)
          .toList();
      final newFriends = acceptedReq != null
          ? [
              ...s.friends,
              Friend(
                friendshipId: friendshipId,
                userId: acceptedReq.requesterId,
                fullName: acceptedReq.requesterName,
                username: acceptedReq.requesterUsername,
                avatar: acceptedReq.requesterAvatar,
                status: FriendshipStatus.accepted,
                connectedAt: DateTime.now(),
              ),
            ]
          : s.friends;
      return s.copyWith(pendingRequests: remaining, friends: newFriends);
    });

    try {
      await repo.acceptFriendRequest(friendshipId);
    } catch (_) {
      // Revert
      state = AsyncData(currentState);
      rethrow;
    }
  }

  /// Từ chối lời mời kết bạn
  Future<void> rejectRequest(String friendshipId) async {
    final repo = ref.read(friendsRepositoryProvider);
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic: xóa khỏi danh sách pending
    state = state.whenData((s) {
      return s.copyWith(
        pendingRequests: s.pendingRequests
            .where((r) => r.friendshipId != friendshipId)
            .toList(),
      );
    });

    try {
      await repo.rejectFriendRequest(friendshipId);
    } catch (_) {
      // Revert
      state = AsyncData(currentState);
      rethrow;
    }
  }

  /// Hủy kết bạn / xóa bạn
  Future<void> removeFriend(String friendshipId, {String? targetUserId}) async {
    final repo = ref.read(friendsRepositoryProvider);
    final currentState = state.value;
    if (currentState == null) return;

    final targetId = targetUserId ?? friendshipId;

    // Optimistic: xóa khỏi danh sách bạn bè
    state = state.whenData((s) {
      return s.copyWith(
        friends: s.friends
            .where((f) => f.friendshipId != friendshipId && f.userId != targetId)
            .toList(),
      );
    });

    try {
      await repo.removeFriend(targetId);
    } catch (_) {
      // Revert
      state = AsyncData(currentState);
      rethrow;
    }
  }

  /// Chặn người dùng
  Future<void> blockUser(String targetUserId) async {
    final repo = ref.read(friendsRepositoryProvider);
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic: xóa khỏi danh sách bạn bè và lời mời
    state = state.whenData((s) {
      return s.copyWith(
        friends: s.friends.where((f) => f.userId != targetUserId).toList(),
        pendingRequests: s.pendingRequests.where((r) => r.requesterId != targetUserId).toList(),
      );
    });

    try {
      await repo.blockUser(targetUserId);
    } catch (_) {
      // Revert
      state = AsyncData(currentState);
      rethrow;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final friendsListProvider =
    AsyncNotifierProvider<FriendsListNotifier, FriendsListState>(() {
  return FriendsListNotifier();
});
