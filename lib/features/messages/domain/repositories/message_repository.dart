import '../models/conversation.dart';
import '../models/message.dart';
import '../models/message_filter.dart';
import '../models/message_input.dart';

/// Hợp đồng dữ liệu nghiệp vụ (Repository Interface) cho module Tin nhắn P2P.
/// Tầng Presentation chỉ tương tác với interface này.
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
  });

  /// Gửi tin nhắn mới
  Future<Message> sendMessage(SendMessageInput input);

  /// Đánh dấu cuộc hội thoại đã đọc
  Future<void> markConversationAsRead(String conversationId);

  /// Xóa cuộc hội thoại
  Future<void> deleteConversation(String conversationId);
}

