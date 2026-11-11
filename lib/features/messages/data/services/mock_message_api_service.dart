import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/message_attachment.dart';
import '../dto/conversation_response.dart';
import '../dto/message_response.dart';
import '../dto/send_message_request.dart';
import 'message_api_service.dart';

/// Dịch vụ giả lập để kiểm thử và demo giao diện Chat P2P & chia sẻ tài chính
class MockMessageApiService implements MessageApiService {
  MockMessageApiService() {
    _seed();
  }

  final List<ConversationResponse> _conversations = [];
  final Map<String, List<MessageResponse>> _messages = {};
  int _nextMsgId = 100;
  static const _delay = Duration(milliseconds: 300);

  void _seed() {
    final now = DateTime.now();

    // 1. Cuộc hội thoại với Minh Anh (Bạn thân - Chia tiền tiệc)
    final msg1 = MessageResponse(
      id: 'm1',
      conversationId: 'c1',
      senderId: 'user_minhanh',
      receiverId: 'me',
      content: 'Mình vừa thanh toán hóa đơn trà chiều, chia đôi nhé!',
      type: 'TRANSACTION_SHARE',
      status: 'READ',
      transactionAttachment: const MessageTransactionAttachment(
        transactionId: 'tx_99',
        title: 'Trà chiều Phê La',
        amount: 145000,
        categoryName: 'Cà phê & Gặp gỡ',
        categoryIcon: '☕',
        isExpense: true,
      ),
      createdAt: now.subtract(const Duration(minutes: 15)),
    );

    // 2. Cuộc hội thoại với Quốc Bảo (Đồng nghiệp)
    final msg2 = MessageResponse(
      id: 'm2',
      conversationId: 'c2',
      senderId: 'user_bao',
      receiverId: 'me',
      content: 'OK đã nhận tiền chuyển khoản rồi nhé. Cảm ơn ông!',
      type: 'TEXT',
      status: 'DELIVERED',
      createdAt: now.subtract(const Duration(hours: 2)),
    );

    // 3. Cuộc hội thoại với Thuỳ Linh
    final msg3 = MessageResponse(
      id: 'm3',
      conversationId: 'c3',
      senderId: 'me',
      receiverId: 'user_linh',
      content: 'Đã gửi ảnh hóa đơn ăn trưa cho cậu xem rồi nha',
      type: 'TEXT',
      status: 'SENT',
      createdAt: now.subtract(const Duration(days: 1)),
    );

    _conversations.addAll([
      ConversationResponse(
        id: 'c1',
        participant: const ConversationParticipantDto(
          id: 'user_minhanh',
          displayName: 'Minh Anh',
          avatarUrl: 'https://i.pravatar.cc/150?u=minhanh',
          isOnline: true,
        ),
        lastMessage: msg1,
        unreadCount: 1,
        updatedAt: now.subtract(const Duration(minutes: 15)),
      ),
      ConversationResponse(
        id: 'c2',
        participant: const ConversationParticipantDto(
          id: 'user_bao',
          displayName: 'Quốc Bảo',
          avatarUrl: 'https://i.pravatar.cc/150?u=quocbao',
          isOnline: false,
        ),
        lastMessage: msg2,
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      ConversationResponse(
        id: 'c3',
        participant: const ConversationParticipantDto(
          id: 'user_linh',
          displayName: 'Thuỳ Linh',
          avatarUrl: 'https://i.pravatar.cc/150?u=thuylinh',
          isOnline: true,
        ),
        lastMessage: msg3,
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // Dữ liệu tin nhắn trong c1
    _messages['c1'] = [
      MessageResponse(
        id: 'm0',
        conversationId: 'c1',
        senderId: 'me',
        receiverId: 'user_minhanh',
        content: 'Hôm nay vui quá, lát gửi mình bill nhé!',
        type: 'TEXT',
        status: 'READ',
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
      msg1,
    ];

    _messages['c2'] = [msg2];
    _messages['c3'] = [msg3];
  }

  @override
  Future<List<ConversationResponse>> getConversations({String? search}) async {
    await Future.delayed(_delay);
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      return _conversations
          .where((c) =>
              c.participant.displayName.toLowerCase().contains(q) ||
              (c.lastMessage?.content.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return List<ConversationResponse>.from(_conversations);
  }

  @override
  Future<ConversationResponse> getConversationById(String conversationId) async {
    await Future.delayed(_delay);
    final found = _conversations.where((c) => c.id == conversationId).firstOrNull;
    if (found == null) {
      throw const AppException('Không tìm thấy cuộc trò chuyện', statusCode: 404);
    }
    return found;
  }

  @override
  Future<List<MessageResponse>> getMessages({
    String? conversationId,
    String? friendId,
    int page = 1,
    int limit = 30,
    String? before,
  }) async {
    await Future.delayed(_delay);
    final key = conversationId ?? (friendId != null ? 'c1' : 'c1');
    return List<MessageResponse>.from(_messages[key] ?? []);
  }

  @override
  Future<MessageResponse> sendMessage(SendMessageRequest request) async {
    await Future.delayed(_delay);
    final cId = request.receiverId.isNotEmpty ? request.receiverId : 'c1';
    final newMsg = MessageResponse(
      id: 'm_${_nextMsgId++}',
      conversationId: cId,
      senderId: 'me',
      receiverId: request.receiverId,
      content: request.content,
      type: request.relatedTransactionId != null ? 'TRANSACTION_SHARE' : 'TEXT',
      status: 'SENT',
      relatedTransactionId: request.relatedTransactionId,
      createdAt: DateTime.now(),
    );

    _messages.putIfAbsent(cId, () => []).add(newMsg);

    final idx = _conversations.indexWhere((c) => c.id == cId);
    if (idx != -1) {
      final old = _conversations[idx];
      _conversations[idx] = ConversationResponse(
        id: old.id,
        participant: old.participant,
        lastMessage: newMsg,
        unreadCount: 0,
        updatedAt: DateTime.now(),
      );
    }

    return newMsg;
  }

  @override
  Future<void> markMessagesAsRead(String friendId) async {
    await Future.delayed(_delay);
    final idx = _conversations.indexWhere((c) => c.id == friendId || c.participant.id == friendId);
    if (idx != -1) {
      final old = _conversations[idx];
      _conversations[idx] = ConversationResponse(
        id: old.id,
        participant: old.participant,
        lastMessage: old.lastMessage,
        unreadCount: 0,
        updatedAt: old.updatedAt,
      );
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId) =>
      markMessagesAsRead(conversationId);

  @override
  Future<void> recallMessage(String messageId) async {
    await Future.delayed(_delay);
    for (final list in _messages.values) {
      list.removeWhere((m) => m.id == messageId);
    }
  }

  @override
  Future<void> addReaction(String messageId, String emoji) async {
    await Future.delayed(_delay);
  }

  @override
  Future<void> removeReaction(String messageId) async {
    await Future.delayed(_delay);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await Future.delayed(_delay);
    _conversations.removeWhere((c) => c.id == conversationId);
    _messages.remove(conversationId);
  }
}
