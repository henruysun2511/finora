import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dto/conversation_response.dart';
import '../dto/message_response.dart';
import '../dto/send_message_request.dart';

abstract class MessageApiService {
  Future<List<ConversationResponse>> getConversations();
  Future<ConversationResponse> getConversationById(String conversationId);
  Future<List<MessageResponse>> getMessages({
    String? conversationId,
    String? friendId,
    int page = 1,
    int limit = 30,
  });
  Future<MessageResponse> sendMessage(SendMessageRequest request);
  Future<void> markConversationAsRead(String conversationId);
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
  Future<List<ConversationResponse>> getConversations() => _guard(() async {
        final res = await _dio.get<dynamic>(ApiConstants.conversations);
        final raw = _extractData(res.data);
        List<dynamic> items = [];
        if (raw is List) {
          items = raw;
        } else if (raw is Map<String, dynamic> && raw['items'] is List) {
          items = raw['items'] as List;
        }
        return items
            .map((e) => ConversationResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<ConversationResponse> getConversationById(String conversationId) =>
      _guard(() async {
        final res = await _dio.get<dynamic>(ApiConstants.conversationDetail(conversationId));
        final raw = _extractData(res.data);
        return ConversationResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<List<MessageResponse>> getMessages({
    String? conversationId,
    String? friendId,
    int page = 1,
    int limit = 30,
  }) =>
      _guard(() async {
        final path = friendId != null && friendId.isNotEmpty
            ? ApiConstants.friendMessages(friendId)
            : '${ApiConstants.conversations}/$conversationId/messages';

        final res = await _dio.get<dynamic>(
          path,
          queryParameters: {'page': page, 'limit': limit},
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
  Future<MessageResponse> sendMessage(SendMessageRequest request) => _guard(() async {
        final res = await _dio.post<dynamic>(
          ApiConstants.sendP2PMessage,
          data: request.toJson(),
        );
        final raw = _extractData(res.data);
        return MessageResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<void> markConversationAsRead(String conversationId) => _guard(() async {
        await _dio.post<dynamic>('${ApiConstants.conversationDetail(conversationId)}/read');
      });

  @override
  Future<void> deleteConversation(String conversationId) => _guard(() async {
        await _dio.delete<dynamic>(ApiConstants.conversationDetail(conversationId));
      });
}

