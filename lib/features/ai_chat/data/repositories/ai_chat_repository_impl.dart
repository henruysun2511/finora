import '../../domain/models/chat_message_model.dart';
import '../../domain/models/pending_action_detail_model.dart';
import '../../domain/models/send_message_input.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../services/ai_chat_api_service.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatApiService _apiService;

  AiChatRepositoryImpl({required AiChatApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<ChatMessageModel>> getHistory({
    required String walletId,
    String? beforeId,
    int limit = 30,
  }) {
    return _apiService.getHistory(
      walletId: walletId,
      beforeId: beforeId,
      limit: limit,
    );
  }

  @override
  Future<ChatMessageModel> sendMessage(SendMessageInput input) {
    return _apiService.sendMessage(input);
  }

  @override
  Future<ChatMessageModel> sendMediaMessage({
    required String walletId,
    required List<int> bytes,
    required String filename,
  }) {
    return _apiService.sendMediaMessage(
      walletId: walletId,
      bytes: bytes,
      filename: filename,
    );
  }

  @override
  Future<PendingActionDetailModel> executePendingAction({
    required String actionId,
    required PendingActionDecision action,
    EditTransactionDraft? editedData,
  }) {
    return _apiService.executePendingAction(
      actionId: actionId,
      action: action,
      editedData: editedData,
    );
  }

  @override
  Future<PendingActionDetailModel> getPendingAction(String actionId) {
    return _apiService.getPendingAction(actionId);
  }

  @override
  Future<void> clearHistory(String walletId) {
    return _apiService.clearHistory(walletId);
  }
}
