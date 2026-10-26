import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/models/pending_action_detail_model.dart';
import '../../domain/models/send_message_input.dart';

abstract class AiChatApiService {
  Future<List<ChatMessageModel>> getHistory({
    required String walletId,
    String? beforeId,
    int limit = 30,
  });

  Future<ChatMessageModel> sendMessage(SendMessageInput input);

  Future<ChatMessageModel> sendMediaMessage({
    required String walletId,
    required List<int> bytes,
    required String filename,
  });

  Future<PendingActionDetailModel> executePendingAction({
    required String actionId,
    required PendingActionDecision action,
    EditTransactionDraft? editedData,
  });

  Future<PendingActionDetailModel> getPendingAction(String actionId);

  Future<void> clearHistory(String walletId);
}

class DioAiChatApiService implements AiChatApiService {
  final Dio _dio;

  DioAiChatApiService(this._dio);

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ChatMessageModel>> getHistory({
    required String walletId,
    String? beforeId,
    int limit = 30,
  }) =>
      _guard(() async {
        final queryParams = <String, dynamic>{
          'walletId': walletId,
          'limit': limit,
        };
        if (beforeId != null && beforeId.isNotEmpty) {
          queryParams['beforeId'] = beforeId;
        }

        final res = await _dio.get(
          ApiConstants.chatMessages,
          queryParameters: queryParams,
        );

        final rawData = _extractData(res.data);
        if (rawData is List) {
          return rawData
              .whereType<Map>()
              .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <ChatMessageModel>[];
      });

  @override
  Future<ChatMessageModel> sendMessage(SendMessageInput input) =>
      _guard(() async {
        final res = await _dio.post(
          ApiConstants.chatMessages,
          data: input.toJson(),
        );

        final rawData = _extractData(res.data);
        if (rawData is Map) {
          return ChatMessageModel.fromJson(Map<String, dynamic>.from(rawData));
        }
        throw Exception('Phản hồi không hợp lệ từ máy chủ');
      });

  @override
  Future<ChatMessageModel> sendMediaMessage({
    required String walletId,
    required List<int> bytes,
    required String filename,
  }) =>
      _guard(() async {
        final formData = FormData.fromMap({
          'walletId': walletId,
          'file': MultipartFile.fromBytes(bytes, filename: filename),
        });

        final res = await _dio.post(
          '${ApiConstants.chatMessages}/media',
          data: formData,
        );

        final rawData = _extractData(res.data);
        if (rawData is Map) {
          return ChatMessageModel.fromJson(Map<String, dynamic>.from(rawData));
        }
        throw Exception('Phản hồi không hợp lệ từ máy chủ khi gửi tệp media');
      });

  @override
  Future<PendingActionDetailModel> executePendingAction({
    required String actionId,
    required PendingActionDecision action,
    EditTransactionDraft? editedData,
  }) =>
      _guard(() async {
        final body = <String, dynamic>{
          'action': action.toApiString(),
        };
        if (editedData != null) {
          body['editedData'] = editedData.toJson();
        }

        final res = await _dio.post(
          '${ApiConstants.chatPendingActions}/$actionId/execute',
          data: body,
        );

        final rawData = _extractData(res.data);
        if (rawData is Map) {
          return PendingActionDetailModel.fromJson(Map<String, dynamic>.from(rawData));
        }
        throw Exception('Phản hồi không hợp lệ từ máy chủ khi xử lý hành động chờ');
      });

  @override
  Future<PendingActionDetailModel> getPendingAction(String actionId) =>
      _guard(() async {
        final res = await _dio.get(
          '${ApiConstants.chatPendingActions}/$actionId',
        );

        final rawData = _extractData(res.data);
        if (rawData is Map) {
          return PendingActionDetailModel.fromJson(Map<String, dynamic>.from(rawData));
        }
        throw Exception('Không tìm thấy hành động chờ');
      });

  @override
  Future<void> clearHistory(String walletId) => _guard(() async {
        await _dio.delete(
          ApiConstants.chatMessages,
          queryParameters: {'walletId': walletId},
        );
      });
}
