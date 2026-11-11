import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/friend_response.dart';

class FriendsApiService {
  FriendsApiService(this._dio);
  final Dio _dio;

  /// GET /friends - Lấy danh bạ bạn bè (hỗ trợ phân trang)
  Future<List<FriendResponseDto>> getFriends({int page = 1, int limit = 20}) async {
    final res = await _dio.get(
      ApiConstants.friends,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data['data'];
    final List items = data is List
        ? data
        : (data is Map ? (data['items'] ?? data['data'] ?? []) : []);
    return items
        .map((e) => FriendResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /friends/requests?type=received - Lấy danh sách lời mời kết bạn nhận được
  Future<List<FriendRequestResponseDto>> getFriendRequests() async {
    final res = await _dio.get(
      ApiConstants.friendRequests,
      queryParameters: {'type': 'received'},
    );
    final data = res.data['data'];
    final List items = data is List
        ? data
        : (data is Map ? (data['items'] ?? data['data'] ?? []) : []);
    return items
        .map((e) => FriendRequestResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /friends/requests?type=sent - Lấy danh sách lời mời kết bạn đã gửi
  Future<List<FriendRequestResponseDto>> getSentRequests() async {
    final res = await _dio.get(
      ApiConstants.friendRequests,
      queryParameters: {'type': 'sent'},
    );
    final data = res.data['data'];
    final List items = data is List
        ? data
        : (data is Map ? (data['items'] ?? data['data'] ?? []) : []);
    return items
        .map((e) => FriendRequestResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /friends/search?query=query - Tìm kiếm người dùng theo tên hoặc email
  Future<List<UserSearchResultDto>> searchUsers(String query) async {
    final trimmed = query.trim();
    final res = await _dio.get(
      ApiConstants.searchFriends,
      queryParameters: trimmed.isNotEmpty ? {'query': trimmed} : null,
    );
    final data = res.data['data'];
    final List items = data is List
        ? data
        : (data is Map ? (data['items'] ?? data['data'] ?? []) : []);
    return items
        .map((e) => UserSearchResultDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /friends/requests - Gửi yêu cầu kết bạn đến một người dùng khác
  Future<void> sendFriendRequest(String userId) async {
    await _dio.post(
      ApiConstants.friendRequests,
      data: {
        'addresseeId': userId,
        'friendId': userId,
      },
    );
  }

  /// PATCH /friends/requests/:id - Chấp nhận lời mời kết bạn (status = ACCEPTED)
  Future<void> acceptFriendRequest(String friendshipId) async {
    await _dio.patch(
      '${ApiConstants.friendRequests}/$friendshipId',
      data: {'status': 'ACCEPTED'},
    );
  }

  /// PATCH /friends/requests/:id - Từ chối lời mời kết bạn (status = REJECTED)
  Future<void> rejectFriendRequest(String friendshipId) async {
    await _dio.patch(
      '${ApiConstants.friendRequests}/$friendshipId',
      data: {'status': 'REJECTED'},
    );
  }

  /// DELETE /friends/:id - Hủy kết bạn (Unfriend theo friendUserId)
  Future<void> removeFriend(String targetUserId) async {
    await _dio.delete(ApiConstants.removeFriend(targetUserId));
  }

  /// PATCH /friends/:id/status - Chặn người dùng (status = BLOCKED)
  Future<void> blockUser(String targetUserId) async {
    await _dio.patch(
      '/friends/$targetUserId/status',
      data: {'status': 'BLOCKED'},
    );
  }
}
