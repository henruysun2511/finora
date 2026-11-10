import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/feed_post_response.dart';
import '../dto/post_reaction_response.dart';

class FeedApiService {
  FeedApiService(this._dio);
  final Dio _dio;

  /// 1. GET /feed
  Future<List<FeedPostResponseDto>> getFeed(
      Map<String, dynamic> queryParams) async {
    final res = await _dio.get(
      ApiConstants.feed,
      queryParameters: queryParams,
    );
    final responseData = res.data['data'];
    final List items = responseData is Map
        ? (responseData['items'] ?? responseData['data'] ?? [])
        : (responseData is List ? responseData : []);
    return items
        .map((e) => FeedPostResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 2. POST /feed/:transactionId/reactions
  Future<AddReactionResponseDto> addReaction(
      String transactionId, String emoji) async {
    final res = await _dio.post(
      ApiConstants.feedReactions(transactionId),
      data: {'emoji': emoji},
    );
    final data = res.data['data'] as Map<String, dynamic>? ?? {};
    return AddReactionResponseDto.fromJson(data);
  }

  /// 3. DELETE /feed/:transactionId/reactions
  Future<void> removeReaction(String transactionId) async {
    await _dio.delete(ApiConstants.feedReactions(transactionId));
  }

  /// 4. GET /feed/:transactionId/reactions
  Future<List<PostReactionResponseDto>> getReactions(
      String transactionId) async {
    final res = await _dio.get(ApiConstants.feedReactions(transactionId));
    final data = res.data['data'];
    final List items = data is List ? data : [];
    return items
        .map((e) => PostReactionResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 5. PATCH /feed/:transactionId
  Future<Map<String, dynamic>> updatePost(
      String transactionId, Map<String, dynamic> body) async {
    final res = await _dio.patch(
      ApiConstants.feedPost(transactionId),
      data: body,
    );
    return res.data['data'] as Map<String, dynamic>? ?? {};
  }
}

