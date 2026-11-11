import '../models/conversation.dart';
import '../models/message.dart';
import '../models/message_filter.dart';
import '../models/message_input.dart';

/// Hợp đồng dữ liệu nghiệp vụ (Repository Interface) cho module Tin nhắn P2P.
abstract class MessageRepository {
  /// Lấy danh sách các cuộc hội thoại
  Future<List<Conversation>> getConversations({MessageFilter? filter});

  /// Lấy chi tiết một cuộc hội thoại theo id
  Future<Conversation> getConversationById(String conversationId);

  /// Lấy danh sách tin nhắn trong một cuộc hội thoại hoặc với bạn bè
  Future<List<Message>> getMessages({
    String? conversationId,
    String? friendId,
    int page = 1,
    int limit = 30,
    String? before,
  });

  /// Gửi tin nhắn mới
  Future<Message> sendMessage(SendMessageInput input);

  /// Đánh dấu cuộc hội thoại đã đọc
  Future<void> markConversationAsRead(String friendId);

  /// Thu hồi tin nhắn
  Future<void> recallMessage(String messageId);

  /// Thả cảm xúc emoji vào tin nhắn
  Future<void> addReaction(String messageId, String emoji);

  /// Gỡ bỏ cảm xúc trên tin nhắn
  Future<void> removeReaction(String messageId);

  /// Xóa cuộc hội thoại (local/compatibility)
  Future<void> deleteConversation(String conversationId);
}
