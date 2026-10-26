import '../models/chat_message_model.dart';
import '../models/pending_action_detail_model.dart';
import '../models/send_message_input.dart';

abstract class AiChatRepository {
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
