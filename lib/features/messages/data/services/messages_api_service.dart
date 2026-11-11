import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/conversation_response.dart';
import '../dto/message_response.dart';

class MessagesApiService {
  MessagesApiService(this._dio);
  final Dio _dio;

  /// GET /messages/conversations
  Future<List<ConversationResponseDto>> getConversations({String? search}) async {
    final res = await _dio.get(
      ApiConstants.conversations,
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final data = res.data['data'];
    final List items = data is List
        ? data
        : (data is Map ? (data['items'] ?? data['data'] ?? []) : []);
    return items
        .map((e) => ConversationResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /messages/:friendId
  Future<List<MessageResponseDto>> getHistory(
    String friendId, {
    int page = 1,
    int limit = 30,
  }) async {
    final res = await _dio.get(
      ApiConstants.friendMessages(friendId),
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data['data'];
    final List items = data is List
        ? data
        : (data is Map ? (data['items'] ?? data['data'] ?? []) : []);
    return items
        .map((e) => MessageResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /messages
  Future<MessageResponseDto> sendMessage({
    required String friendId,
    required String content,
    String? relatedTransactionId,
  }) async {
    final res = await _dio.post(
      ApiConstants.sendP2PMessage,
      data: {
        'receiverId': friendId,
        'friendId': friendId,
        'content': content,
        if (relatedTransactionId != null) 'relatedTransactionId': relatedTransactionId,
      },
    );
    final data = res.data['data'] as Map<String, dynamic>? ?? {};
    return MessageResponseDto.fromJson(data);
  }

  /// PATCH /messages/:friendId/read
  Future<void> markAsRead(String friendId) async {
    await _dio.patch('${ApiConstants.friendMessages(friendId)}/read');
  }

  /// DELETE /messages/:id
  Future<void> recallMessage(String messageId) async {
    await _dio.delete(ApiConstants.recallMessage(messageId));
  }

  /// POST /messages/:id/reactions
  Future<void> addReaction(String messageId, String emoji) async {
    await _dio.post(
      ApiConstants.messageReactions(messageId),
      data: {'emoji': emoji},
    );
  }

  /// DELETE /messages/:id/reactions
  Future<void> removeReaction(String messageId) async {
    await _dio.delete(ApiConstants.messageReactions(messageId));
  }
}
