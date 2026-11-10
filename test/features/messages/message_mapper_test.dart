import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/messages/data/dto/conversation_response.dart';
import 'package:finora_mb/features/messages/data/dto/message_response.dart';
import 'package:finora_mb/features/messages/data/mappers/message_mapper.dart';
import 'package:finora_mb/features/messages/domain/models/message_attachment.dart';
import 'package:finora_mb/features/messages/domain/models/message_enums.dart';
import 'package:finora_mb/features/messages/domain/models/message_input.dart';

void main() {
  group('MessageMapper - toDomain', () {
    test('chuyển đổi MessageResponse sang Message Entity chính xác với đầy đủ dữ liệu', () {
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

    test('chuyển đổi an toàn khi enum type hoặc status từ backend là giá trị lạ/không tồn tại', () {
      final now = DateTime.now();
      final dto = MessageResponse(
        id: 'msg_unknown',
        conversationId: 'conv_1',
        senderId: 'user_a',
        receiverId: 'user_b',
        content: 'Tin nhắn thử',
        type: 'RANDOM_UNKNOWN_TYPE',
        status: 'CUSTOM_STATUS',
        createdAt: now,
      );

      final domain = MessageMapper.toDomain(dto);

      // Fallback về text và sent mặc định, không bao giờ làm crash ứng dụng
      expect(domain.type, MessageType.text);
      expect(domain.status, MessageDeliveryStatus.sent);
      expect(domain.transactionAttachment, isNull);
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
      expect(domain.lastMessage, isNull);
    });

    test('chuyển đổi đúng khi có lastMessage kèm theo', () {
      final now = DateTime(2026, 11, 10, 10, 0);
      final lastMsgDto = MessageResponse(
        id: 'msg_last',
        conversationId: 'conv_2',
        senderId: 'user_y',
        receiverId: 'me',
        content: 'Hẹn gặp bạn sau!',
        createdAt: now,
      );

      final dto = ConversationResponse(
        id: 'conv_2',
        participant: const ConversationParticipantDto(
          id: 'user_y',
          displayName: 'Mai Lan',
        ),
        lastMessage: lastMsgDto,
        unreadCount: 1,
        updatedAt: now,
      );

      final domain = MessageMapper.toConversationDomain(dto);

      expect(domain.lastMessage, isNotNull);
      expect(domain.lastMessage!.content, 'Hẹn gặp bạn sau!');
      expect(domain.unreadCount, 1);
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
      expect(req.transactionAttachment, isNull);
    });

    test('chuyển đổi SendMessageInput có đính kèm giao dịch sang Request DTO', () {
      const attachment = MessageTransactionAttachment(
        transactionId: 'tx_bill',
        title: 'Hoá đơn điện tử',
        amount: 250000,
        categoryName: 'Hoá đơn',
        isExpense: true,
      );

      const input = SendMessageInput(
        receiverId: 'user_target',
        content: 'Hoá đơn này nhé',
        type: MessageType.transactionShare,
        transactionAttachment: attachment,
      );

      final req = MessageMapper.toRequest(input);

      expect(req.type, 'TRANSACTION_SHARE');
      expect(req.transactionAttachment?.amount, 250000);
      expect(req.transactionAttachment?.title, 'Hoá đơn điện tử');
    });
  });
}
