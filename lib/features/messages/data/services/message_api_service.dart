import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dto/conversation_response.dart';
import '../dto/message_response.dart';
import '../dto/send_message_request.dart';

abstract class MessageApiService {
  Future<List<ConversationResponse>> getConversations({String? search});
  Future<ConversationResponse> getConversationById(String conversationId);
  Future<List<MessageResponse>> getMessages({
    String? conversationId,
    String? friendId,
    int page = 1,
    int limit = 30,
    String? before,
  });
  Future<MessageResponse> sendMessage(SendMessageRequest request);
  Future<void> markMessagesAsRead(String friendId);
  Future<void> markConversationAsRead(String conversationId);
  Future<void> recallMessage(String messageId);
  Future<void> addReaction(String messageId, String emoji);
  Future<void> removeReaction(String messageId);
  Future<void> deleteConversation(String conversationId);
}

class DioMessageApiService implements MessageApiService {
  DioMessageApiService(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? data['error'] as String?;
      }
      throw AppException(
        message ?? e.message ?? 'Đã xảy ra lỗi khi kết nối máy chủ',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    }
    return responseData;
  }

  @override
  Future<List<ConversationResponse>> getConversations({String? search}) =>
      _guard(() async {
        final query = <String, dynamic>{};
        if (search != null && search.trim().isNotEmpty) {
          query['search'] = search.trim();
        }

        final res = await _dio.get<dynamic>(
          ApiConstants.conversations,
          queryParameters: query.isNotEmpty ? query : null,
        );
        final raw = _extractData(res.data);
        List<dynamic> items = [];
        if (raw is List) {
          items = raw;
        } else if (raw is Map<String, dynamic> && raw['items'] is List) {
          items = raw['items'] as List;
        }
        return items
            .map((e) =>
                ConversationResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<ConversationResponse> getConversationById(String conversationId) =>
      _guard(() async {
        // Lấy danh sách hội thoại và tìm conversationId (chính là friendId)
        final convs = await getConversations();
        return convs.firstWhere(
          (c) => c.id == conversationId || c.participant.id == conversationId,
          orElse: () => ConversationResponse(
            id: conversationId,
            participant: ConversationParticipantDto(
              id: conversationId,
              displayName: 'Bạn bè',
            ),
            updatedAt: DateTime.now(),
          ),
        );
      });

  @override
  Future<List<MessageResponse>> getMessages({
    String? conversationId,
    String? friendId,
    int page = 1,
    int limit = 30,
    String? before,
  }) =>
      _guard(() async {
        final targetId =
            (friendId != null && friendId.isNotEmpty) ? friendId : conversationId;

        final query = <String, dynamic>{
          'page': page,
          'limit': limit,
        };
        if (before != null && before.isNotEmpty) {
          query['before'] = before;
        }

        final path = ApiConstants.friendMessages(targetId ?? '');
        final res = await _dio.get<dynamic>(
          path,
          queryParameters: query,
        );
        final raw = _extractData(res.data);
        List<dynamic> items = [];
        if (raw is List) {
          items = raw;
        } else if (raw is Map<String, dynamic> && raw['items'] is List) {
          items = raw['items'] as List;
        }
        return items
            .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<MessageResponse> sendMessage(SendMessageRequest request) =>
      _guard(() async {
        final res = await _dio.post<dynamic>(
          ApiConstants.sendP2PMessage,
          data: request.toJson(),
        );
        final raw = _extractData(res.data);
        return MessageResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<void> markMessagesAsRead(String friendId) => _guard(() async {
        await _dio.patch<dynamic>(ApiConstants.markMessagesAsRead(friendId));
      });

  @override
  Future<void> markConversationAsRead(String conversationId) =>
      markMessagesAsRead(conversationId);

  @override
  Future<void> recallMessage(String messageId) => _guard(() async {
        await _dio.delete<dynamic>(ApiConstants.recallMessage(messageId));
      });

  @override
  Future<void> addReaction(String messageId, String emoji) => _guard(() async {
        await _dio.post<dynamic>(
          ApiConstants.messageReactions(messageId),
          data: {'emoji': emoji},
        );
      });

  @override
  Future<void> removeReaction(String messageId) => _guard(() async {
        await _dio.delete<dynamic>(ApiConstants.messageReactions(messageId));
      });

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Backend NestJS không có endpoint xoá cả cuộc trò chuyện,
    // các cuộc trò chuyện tự tính toán từ lịch sử tin nhắn.
  }
}
