import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/direct_message.dart';
import '../../domain/models/related_transaction.dart';
import 'messages_providers.dart';

final chatDetailProvider =
    AsyncNotifierProvider.family.autoDispose<ChatDetailNotifier, List<DirectMessage>, String>(() {
  return ChatDetailNotifier();
});

class ChatDetailNotifier extends AutoDisposeFamilyAsyncNotifier<List<DirectMessage>, String> {
  @override
  Future<List<DirectMessage>> build(String arg) async {
    final repo = ref.read(messagesRepositoryProvider);
    // Tự động đánh dấu đã đọc
    repo.markAsRead(arg);
    return repo.getMessages(arg);
  }

  Future<void> sendTextMessage(String text) async {
    final currentList = state.value ?? [];
    final repo = ref.read(messagesRepositoryProvider);

    // Optimistic UI
    final tempMsg = DirectMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Tôi',
      content: text,
      isMe: true,
      createdAt: DateTime.now(),
    );

    state = AsyncData([...currentList, tempMsg]);

    try {
      final saved = await repo.sendMessage(conversationId: arg, content: text);
      final updated = (state.value ?? []).map((m) => m.id == tempMsg.id ? saved : m).toList();
      state = AsyncData(updated);
    } catch (_) {
      // Revert if error
      state = AsyncData(currentList);
    }
  }

  Future<void> sendTransactionShare({
    required String name,
    required double amount,
    bool isExpense = true,
    String? groupWalletName,
  }) async {
    final currentList = state.value ?? [];
    final repo = ref.read(messagesRepositoryProvider);

    final tx = RelatedTransaction(
      id: 'tx-temp-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      amount: amount,
      transactionDate: DateTime.now(),
      isExpense: isExpense,
      groupWalletName: groupWalletName,
    );

    final tempMsg = DirectMessage(
      id: 'temp-tx-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Tôi',
      content: 'Chia sẻ hóa đơn: $name (${amount.toStringAsFixed(0)}đ)',
      type: MessageType.transactionShare,
      relatedTransaction: tx,
      isMe: true,
      createdAt: DateTime.now(),
    );

    state = AsyncData([...currentList, tempMsg]);

    try {
      await repo.sendMessage(
        conversationId: arg,
        content: tempMsg.content,
        relatedTransactionId: tx.id,
      );
    } catch (_) {
      // Bỏ qua lỗi
    }
  }
}
