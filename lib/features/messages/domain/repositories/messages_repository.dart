import '../models/conversation.dart';
import '../models/direct_message.dart';

abstract class MessagesRepository {
  /// Lấy danh sách các cuộc trò chuyện (1-1 và nhóm ví chung)
  Future<List<Conversation>> getConversations({String? search});

  /// Lấy lịch sử tin nhắn của một cuộc trò chuyện
  Future<List<DirectMessage>> getMessages(String conversationId, {int page = 1, int limit = 30});

  /// Gửi tin nhắn mới (hỗ trợ đính kèm bài đăng / hóa đơn chia tiền)
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required String content,
    String? relatedTransactionId,
  });

  /// Đánh dấu cuộc trò chuyện đã đọc
  Future<void> markAsRead(String conversationId);

  /// Thả cảm xúc vào tin nhắn
  Future<void> addReaction({required String messageId, required String emoji});
}
