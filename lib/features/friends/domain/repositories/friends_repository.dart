import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/user_search_result.dart';

abstract class FriendsRepository {
  /// Lấy danh sách bạn bè đã kết nối
  Future<List<Friend>> getFriends();

  /// Lấy danh sách lời mời kết bạn nhận được
  Future<List<FriendRequest>> getFriendRequests();

  /// Lấy danh sách lời mời kết bạn đã gửi
  Future<List<FriendRequest>> getSentRequests();

  /// Tìm kiếm người dùng theo email hoặc SĐT/username
  Future<List<UserSearchResult>> searchUsers(String query);

  /// Gửi lời mời kết bạn tới userId
  Future<void> sendFriendRequest(String userId);

  /// Chấp nhận lời mời kết bạn theo friendshipId
  Future<void> acceptFriendRequest(String friendshipId);

  /// Từ chối lời mời kết bạn
  Future<void> rejectFriendRequest(String friendshipId);

  /// Hủy kết bạn / xóa bạn
  Future<void> removeFriend(String friendshipId);
}
