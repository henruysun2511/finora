import '../../domain/models/conversation.dart';
import '../../domain/models/direct_message.dart';
import '../../domain/models/related_transaction.dart';
import '../../domain/repositories/messages_repository.dart';
import '../mappers/messages_mapper.dart';
import '../services/messages_api_service.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(
    this._api, {
    this.mapper = const MessagesMapper(),
    this.currentUserId = 'me',
  });

  final MessagesApiService _api;
  final MessagesMapper mapper;
  final String currentUserId;

  // ─── Mock Fallback Data ───────────────────────────────────────────────────

  final List<Conversation> _mockConversations = [
    Conversation(
      id: 'conv-1',
      title: 'Trần Ngọc',
      lastMessageContent: 'Chia bill xong chưa bạn ơi?',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    Conversation(
      id: 'conv-2',
      title: 'Hùng Minh',
      lastMessageContent: 'Mình đã chuyển khoản phần tiền trưa rồi nha 💰',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: true,
    ),
    Conversation(
      id: 'conv-group-dalat',
      title: 'Nhóm Chia bill Đà Lạt ✈️',
      lastMessageContent: 'Phạm Lan: Đã cập nhật hóa đơn khách sạn 2.4tr vào ví chung',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 4,
      isGroup: true,
      groupWalletName: 'Ví Chuyến đi Đà Lạt',
      membersCount: 5,
    ),
    Conversation(
      id: 'conv-3',
      title: 'Anh Thư',
      lastMessageContent: 'Starbucks chiều nay chill chill nha! ☕✨',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 6)),
      unreadCount: 0,
      isOnline: false,
    ),
    Conversation(
      id: 'conv-group-teamlunch',
      title: 'Quỹ Ăn trưa Văn phòng 🍜',
      lastMessageContent: 'Minh Tuấn: Hôm nay ai order bún chả thì xác nhận nhé!',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isGroup: true,
      groupWalletName: 'Quỹ Trưa Team Tech',
      membersCount: 8,
    ),
  ];

  final Map<String, List<DirectMessage>> _mockMessages = {
    'conv-1': [
      DirectMessage(
        id: 'm1-1',
        senderId: 'conv-1',
        senderName: 'Trần Ngọc',
        content: 'Chào bạn! Bữa trưa nay ăn ngon quá 😋',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      DirectMessage(
        id: 'm1-2',
        senderId: 'conv-1',
        senderName: 'Trần Ngọc',
        content: 'Mình vừa tạo bill chia tiền cho cả nhóm nè, bạn check giúp mình nhé:',
        type: MessageType.transactionShare,
        relatedTransaction: RelatedTransaction(
          id: 'tx-bun-bo',
          name: 'Bún bò Huế trưa nay 🍜',
          amount: 85000,
          transactionDate: DateTime.now().subtract(const Duration(minutes: 25)),
          isExpense: true,
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      DirectMessage(
        id: 'm1-3',
        senderId: 'me',
        senderName: 'Tôi',
        content: 'Okie bạn ơi, mình thấy rồi nha! Đang chuyển khoản ngay đây 👍',
        isMe: true,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      DirectMessage(
        id: 'm1-4',
        senderId: 'conv-1',
        senderName: 'Trần Ngọc',
        content: 'Chia bill xong chưa bạn ơi?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
    'conv-group-dalat': [
      DirectMessage(
        id: 'mg-1',
        senderId: 'u-pham-lan',
        senderName: 'Phạm Lan',
        groupId: 'conv-group-dalat',
        content: 'Mọi người ơi, mình vừa thanh toán tiền phòng homestay Đà Lạt xong!',
        type: MessageType.transactionShare,
        relatedTransaction: RelatedTransaction(
          id: 'tx-homestay',
          name: 'Homestay Thung lũng Đà Lạt (2 đêm)',
          amount: 2400000,
          transactionDate: DateTime.now().subtract(const Duration(hours: 4)),
          isExpense: true,
          groupWalletName: 'Ví Chuyến đi Đà Lạt',
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      DirectMessage(
        id: 'mg-2',
        senderId: 'u-hung-minh',
        senderName: 'Hùng Minh',
        groupId: 'conv-group-dalat',
        content: 'Đã check! Mỗi người 600k đúng không Lan ơi? Mình chuyển vào quỹ chung luôn nhé 💸',
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
      ),
      DirectMessage(
        id: 'mg-3',
        senderId: 'me',
        senderName: 'Tôi',
        groupId: 'conv-group-dalat',
        content: 'Mình vừa chuyển 600k vào Ví chung rồi nhé cả nhà ơi!',
        isMe: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
  };

  @override
  Future<List<Conversation>> getConversations({String? search}) async {
    try {
      final dtos = await _api.getConversations(search: search);
      final items = dtos.map(mapper.toDomainConversation).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback
    }

    if (search == null || search.trim().isEmpty) {
      return _mockConversations;
    }
    final q = search.toLowerCase();
    return _mockConversations.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.lastMessageContent.toLowerCase().contains(q) ||
          (c.groupWalletName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Future<List<DirectMessage>> getMessages(String conversationId, {int page = 1, int limit = 30}) async {
    try {
      final dtos = await _api.getHistory(conversationId, page: page, limit: limit);
      final items = dtos.map((d) => mapper.toDomainMessage(d, currentUserId: currentUserId)).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback
    }

    return _mockMessages[conversationId] ?? [
      DirectMessage(
        id: 'm-default',
        senderId: conversationId,
        senderName: 'Bạn bè',
        content: 'Bắt đầu cuộc trò chuyện tài chính cùng bạn bè! 👋',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required String content,
    String? relatedTransactionId,
  }) async {
    try {
      final dto = await _api.sendMessage(
        friendId: conversationId,
        content: content,
        relatedTransactionId: relatedTransactionId,
      );
      return mapper.toDomainMessage(dto, currentUserId: currentUserId);
    } catch (_) {
      // Local fallback
    }

    final newMsg = DirectMessage(
      id: 'm-local-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Tôi',
      receiverId: conversationId,
      content: content,
      isMe: true,
      createdAt: DateTime.now(),
    );

    if (!_mockMessages.containsKey(conversationId)) {
      _mockMessages[conversationId] = [];
    }
    _mockMessages[conversationId]!.add(newMsg);
    return newMsg;
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      await _api.markAsRead(conversationId);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  @override
  Future<void> addReaction({required String messageId, required String emoji}) async {
    final apiEmoji = MessagesMapper.toApiEmoji(emoji);
    try {
      await _api.addReaction(messageId, apiEmoji);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  @override
  Future<void> removeReaction(String messageId) async {
    try {
      await _api.removeReaction(messageId);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  @override
  Future<void> recallMessage(String messageId) async {
    try {
      await _api.recallMessage(messageId);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }

    // Cập nhật mock nếu đang dùng dữ liệu nội bộ
    for (final list in _mockMessages.values) {
      final idx = list.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          content: 'Tin nhắn đã được thu hồi',
          isRecalled: true,
        );
      }
    }
  }
}
