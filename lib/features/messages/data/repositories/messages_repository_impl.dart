import '../../domain/models/conversation.dart';
import '../../domain/models/direct_message.dart';
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

  @override
  Future<List<Conversation>> getConversations({String? search}) async {
    final dtos = await _api.getConversations(search: search);
    return dtos.map(mapper.toDomainConversation).toList();
  }

  @override
  Future<List<DirectMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 30,
  }) async {
    final dtos = await _api.getHistory(conversationId, page: page, limit: limit);
    return dtos.map((d) => mapper.toDomainMessage(d, currentUserId: currentUserId)).toList();
  }

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required String content,
    String? relatedTransactionId,
  }) async {
    final dto = await _api.sendMessage(
      friendId: conversationId,
      content: content,
      relatedTransactionId: relatedTransactionId,
    );
    return mapper.toDomainMessage(dto, currentUserId: currentUserId);
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _api.markAsRead(conversationId);
  }

  @override
  Future<void> addReaction({required String messageId, required String emoji}) async {
    final apiEmoji = MessagesMapper.toApiEmoji(emoji);
    await _api.addReaction(messageId, apiEmoji);
  }

  @override
  Future<void> removeReaction(String messageId) async {
    await _api.removeReaction(messageId);
  }

  @override
  Future<void> recallMessage(String messageId) async {
    await _api.recallMessage(messageId);
  }
}
