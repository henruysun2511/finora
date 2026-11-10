import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/models/message_filter.dart';
import '../../domain/models/message_input.dart';
import '../../domain/repositories/message_repository.dart';
import '../mappers/message_mapper.dart';
import '../services/message_api_service.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._service);

  final MessageApiService _service;

  @override
  Future<List<Conversation>> getConversations({MessageFilter? filter}) async {
    final list = await _service.getConversations();
    var domainList = list.map(MessageMapper.toConversationDomain).toList();

    if (filter != null) {
      if (filter.unreadOnly) {
        domainList = domainList.where((c) => c.unreadCount > 0).toList();
      }
      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        final q = filter.searchQuery!.trim().toLowerCase();
        domainList = domainList.where((c) {
          final name = c.participant.displayName.toLowerCase();
          final lastContent = (c.lastMessage?.content ?? '').toLowerCase();
          return name.contains(q) || lastContent.contains(q);
        }).toList();
      }
    }

    return domainList;
  }

  @override
  Future<Conversation> getConversationById(String conversationId) async {
    final dto = await _service.getConversationById(conversationId);
    return MessageMapper.toConversationDomain(dto);
  }

  @override
  Future<List<Message>> getMessages({
    String? conversationId,
    String? friendId,
    int page = 1,
    int limit = 30,
  }) async {
    final list = await _service.getMessages(
      conversationId: conversationId,
      friendId: friendId,
      page: page,
      limit: limit,
    );
    return list.map(MessageMapper.toDomain).toList();
  }

  @override
  Future<Message> sendMessage(SendMessageInput input) async {
    final req = MessageMapper.toRequest(input);
    final res = await _service.sendMessage(req);
    return MessageMapper.toDomain(res);
  }

  @override
  Future<void> markConversationAsRead(String conversationId) {
    return _service.markConversationAsRead(conversationId);
  }

  @override
  Future<void> deleteConversation(String conversationId) {
    return _service.deleteConversation(conversationId);
  }
}

