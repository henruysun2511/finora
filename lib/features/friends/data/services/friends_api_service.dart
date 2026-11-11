import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../dto/friend_response_dto.dart';

class FriendsApiService {
  FriendsApiService(this._dio);

  final Dio _dio;

  /// GET /friends
  Future<List<FriendResponseDto>> getFriends({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final res = await _dio.get(
      ApiConstants.friends,
      queryParameters: queryParams,
    );

    final responseData = res.data is Map ? res.data['data'] : res.data;
    final List items = responseData is Map
        ? (responseData['items'] ?? responseData['data'] ?? [])
        : (responseData is List ? responseData : []);

    return items
        .map((e) => FriendResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

