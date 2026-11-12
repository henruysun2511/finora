import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/messages/data/dto/conversation_response.dart';
import 'package:finora_mb/features/messages/data/dto/message_response.dart';
import 'package:finora_mb/features/messages/data/mappers/messages_mapper.dart';
import 'package:finora_mb/features/messages/domain/models/direct_message.dart';

void main() {
  const mapper = MessagesMapper();

  group('MessagesMapper - toDomainConversation', () {
    test('chuyển đổi ConversationResponseDto sang Conversation domain model', () {
      const dto = ConversationResponseDto(
        friendId: 'conv-101',
        friendFullName: 'Trần Ngọc',
        lastMessageContent: 'Chia bill xong chưa?',
        lastMessageAt: '2026-10-19T10:00:00.000Z',
        unreadCount: 3,
        isGroup: false,
      );

      final conv = mapper.toDomainConversation(dto);

      expect(conv.id, 'conv-101');
      expect(conv.title, 'Trần Ngọc');
      expect(conv.lastMessageContent, 'Chia bill xong chưa?');
      expect(conv.unreadCount, 3);
      expect(conv.isGroup, false);
      expect(conv.initials, 'TN');
    });
  });

  group('MessagesMapper - toDomainMessage', () {
    test('chuyển đổi MessageResponseDto có đính kèm giao dịch chia tiền', () {
      final dto = MessageResponseDto(
        id: 'msg-01',
        senderId: 'user-01',
        senderName: 'Phạm Lan',
        content: 'Homestay Đà Lạt',
        relatedTransaction: const RelatedTransactionDto(
          id: 'tx-01',
          name: 'Homestay Đà Lạt',
          amount: 2400000,
          transactionDate: '2026-10-19T10:00:00.000Z',
          groupWalletName: 'Ví Chuyến đi Đà Lạt',
        ),
        createdAt: '2026-10-19T10:00:00.000Z',
      );

      final msg = mapper.toDomainMessage(dto, currentUserId: 'me');

      expect(msg.id, 'msg-01');
      expect(msg.isMe, false);
      expect(msg.type, MessageType.transactionShare);
      expect(msg.relatedTransaction?.amount, 2400000);
      expect(msg.relatedTransaction?.groupWalletName, 'Ví Chuyến đi Đà Lạt');
    });
  });
}
