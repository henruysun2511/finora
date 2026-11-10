import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/messages/data/dto/conversation_response.dart';
import 'package:finora_mb/features/messages/data/dto/message_response.dart';
import 'package:finora_mb/features/messages/data/mappers/message_mapper.dart';
import 'package:finora_mb/features/messages/domain/models/message_attachment.dart';
import 'package:finora_mb/features/messages/domain/models/message_enums.dart';
import 'package:finora_mb/features/messages/domain/models/message_input.dart';

void main() {
  group('MessageMapper - toDomain', () {
    test('chuyển đổi MessageResponse sang Message Entity chính xác', () {
      final now = DateTime(2026, 11, 10, 10, 0);
      const attachment = MessageTransactionAttachment(
        transactionId: 'tx_123',
        title: 'Bữa trưa',
        amount: 85000,
        categoryName: 'Ăn uống',
        isExpense: true,
      );

      final dto = MessageResponse(
        id: 'msg_1',
        conversationId: 'conv_1',
        senderId: 'user_a',
        receiverId: 'user_b',
        content: 'Chia tiền cơm trưa nhé',
        type: 'TRANSACTION_SHARE',
        status: 'SENT',
        transactionAttachment: attachment,
        createdAt: now,
      );

      final domain = MessageMapper.toDomain(dto);

      expect(domain.id, 'msg_1');
      expect(domain.conversationId, 'conv_1');
      expect(domain.senderId, 'user_a');
      expect(domain.receiverId, 'user_b');
      expect(domain.content, 'Chia tiền cơm trưa nhé');
      expect(domain.type, MessageType.transactionShare);
      expect(domain.status, MessageDeliveryStatus.sent);
      expect(domain.transactionAttachment?.amount, 85000);
      expect(domain.isMine('user_a'), isTrue);
      expect(domain.isMine('user_b'), isFalse);
    });
  });

  group('MessageMapper - toConversationDomain', () {
    test('chuyển đổi ConversationResponse sang Conversation Entity chính xác', () {
      final now = DateTime(2026, 11, 10, 10, 0);
      final dto = ConversationResponse(
        id: 'conv_1',
        participant: const ConversationParticipantDto(
          id: 'user_x',
          displayName: 'Hoàng Nam',
          avatarUrl: 'https://avatar.png',
          isOnline: true,
        ),
        unreadCount: 3,
        updatedAt: now,
      );

      final domain = MessageMapper.toConversationDomain(dto);

      expect(domain.id, 'conv_1');
      expect(domain.participant.displayName, 'Hoàng Nam');
      expect(domain.participant.isOnline, isTrue);
      expect(domain.unreadCount, 3);
    });
  });

  group('MessageMapper - toRequest', () {
    test('chuyển đổi SendMessageInput sang SendMessageRequest chính xác', () {
      const input = SendMessageInput(
        receiverId: 'user_target',
        conversationId: 'conv_abc',
        content: 'Xin chào!',
        type: MessageType.text,
      );

      final req = MessageMapper.toRequest(input);

      expect(req.receiverId, 'user_target');
      expect(req.conversationId, 'conv_abc');
      expect(req.content, 'Xin chào!');
      expect(req.type, 'TEXT');
    });
  });
}

