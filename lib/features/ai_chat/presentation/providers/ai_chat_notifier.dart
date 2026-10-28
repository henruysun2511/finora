import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/chat_message_model.dart';
import '../../domain/models/send_message_input.dart';
import '../../domain/models/wallet_item_model.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import 'ai_chat_providers.dart';
import 'ai_chat_state.dart';

final aiChatNotifierProvider =
    StateNotifierProvider.autoDispose<AiChatNotifier, AiChatState>((ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return AiChatNotifier(repository: repository, ref: ref)..initialize();
});

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiChatRepository _repository;
  final Ref _ref;

  AiChatNotifier({
    required AiChatRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(const AiChatState());

  Future<void> initialize() async {
    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      // 1. Lấy thông tin linh vật thực tế của người dùng theo tài sản ròng
      String? currentMascotCode;
      try {
        currentMascotCode = await _ref.read(currentUserMascotProvider.future);
      } catch (_) {}

      // 2. Lấy danh sách ví
      final wallets = await _ref.read(userWalletsProvider.future);
      String? activeId = state.activeWalletId;
      String activeName = state.activeWalletName;

      if (wallets.isNotEmpty) {
        activeId ??= wallets.first.id;
        activeName = wallets.first.name;
      } else {
        activeId ??= 'a1111111-1111-4111-a111-111111111111';
      }

      state = state.copyWith(
        wallets: wallets,
        activeWalletId: activeId,
        activeWalletName: activeName,
        mascotId: currentMascotCode ?? state.mascotId,
      );

      // 3. Tải lịch sử tin nhắn của ví
      await loadHistory(activeId);
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: 'Không thể kết nối đến lịch sử hội thoại: $e',
      );
    }
  }

  Future<void> loadHistory(String walletId) async {
    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      final messages = await _repository.getHistory(walletId: walletId);
      // Backend trả về mới nhất trước, hiển thị trên giao diện từ trên xuống (cũ đến mới)
      final sortedMessages = List<ChatMessageModel>.from(messages.reversed);

      String currentMascot = state.mascotId;
      if (currentMascot == 'nora') {
        for (final m in messages) {
          if (m.mascot != null && m.mascot!.isNotEmpty) {
            currentMascot = m.mascot!;
            break;
          }
        }
      }

      state = state.copyWith(
        messages: sortedMessages,
        isLoadingHistory: false,
        hasMore: messages.length >= 30,
        mascotId: currentMascot,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: 'Lỗi tải lịch sử chat: $e',
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMore || state.messages.isEmpty) return;
    final walletId = state.activeWalletId;
    if (walletId == null) return;

    final beforeId = state.messages.first.id;
    // Bỏ qua temp messages
    if (beforeId.startsWith('temp_')) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final olderMessages = await _repository.getHistory(
        walletId: walletId,
        beforeId: beforeId,
        limit: 30,
      );

      final olderSorted = List<ChatMessageModel>.from(olderMessages.reversed);

      state = state.copyWith(
        messages: [...olderSorted, ...state.messages],
        isLoadingMore: false,
        hasMore: olderMessages.length >= 30,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Không thể tải thêm tin nhắn cũ: $e',
      );
    }
  }

  Future<void> sendMessage(String text, {String? intentOverride}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || state.isSending) return;
    final walletId = state.activeWalletId ?? 'a1111111-1111-4111-a111-111111111111';

    // 1. Thêm tin nhắn người dùng ngay lập tức (Optimistic UI)
    final tempUserMessage = ChatMessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRoleEnum.user,
      messageType: ChatMessageTypeEnum.text,
      textContent: cleanText,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, tempUserMessage],
      isSending: true,
      clearError: true,
    );

    try {
      // 2. Gửi request tới Backend
      final assistantMsg = await _repository.sendMessage(
        SendMessageInput(
          walletId: walletId,
          message: cleanText,
          intentOverride: intentOverride,
        ),
      );

      // Cập nhật Mascot nếu câu trả lời từ linh vật cụ thể
      final newMascot = assistantMsg.mascot ?? state.mascotId;

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isSending: false,
        mascotId: newMascot,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Không thể gửi tin nhắn. Vui lòng thử lại.',
      );
    }
  }

  Future<void> sendMediaMessage(
    List<int> bytes,
    String filename, {
    String? userPromptHint,
  }) async {
    final walletId = state.activeWalletId ?? 'a1111111-1111-4111-a111-111111111111';

    final lowerName = filename.toLowerCase();
    final isAudio = lowerName.endsWith('.mp3') ||
        lowerName.endsWith('.wav') ||
        lowerName.endsWith('.m4a') ||
        lowerName.endsWith('.aac') ||
        lowerName.endsWith('.ogg') ||
        lowerName.endsWith('.webm') ||
        lowerName.contains('audio') ||
        lowerName.contains('voice');
    final mediaType = isAudio ? 'audio' : 'image';

    final tempId = 'temp_media_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessageModel(
      id: tempId,
      role: ChatRoleEnum.user,
      messageType: ChatMessageTypeEnum.text,
      textContent: userPromptHint ?? (isAudio ? '🎤 Tin nhắn thoại' : '📷 Ảnh hóa đơn'),
      mediaBytes: Uint8List.fromList(bytes),
      mediaType: mediaType,
      retryBytes: bytes,
      retryFilename: filename,
      payloadJson: {
        'input': isAudio ? 'voice' : 'receipt',
        'filename': filename,
      },
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, tempMsg],
      isSending: true,
      clearError: true,
    );

    try {
      final assistantMsg = await _repository.sendMediaMessage(
        walletId: walletId,
        bytes: bytes,
        filename: filename,
      );

      final newMascot = assistantMsg.mascot ?? state.mascotId;

      final serverImageUrl = assistantMsg.imageUrl;
      final serverAudioUrl = assistantMsg.audioUrl;

      final updatedMessages = state.messages.map((m) {
        if (m.id == tempId) {
          final updatedPayload = Map<String, dynamic>.from(m.payloadJson ?? {});
          if (serverImageUrl != null && serverImageUrl.isNotEmpty) {
            updatedPayload['imageUrl'] = serverImageUrl;
            updatedPayload['photoUrl'] = serverImageUrl;
          }
          if (serverAudioUrl != null && serverAudioUrl.isNotEmpty) {
            updatedPayload['audioUrl'] = serverAudioUrl;
          }
          return m.copyWith(payloadJson: updatedPayload);
        }
        return m;
      }).toList();

      state = state.copyWith(
        messages: [...updatedMessages, assistantMsg],
        isSending: false,
        mascotId: newMascot,
      );
    } catch (e) {
      String userFriendlyError =
          'Dịch vụ đọc hóa đơn đang bận. Vui lòng thử lại hoặc nhập tay.';
      if (e is DioException) {
        final respData = e.response?.data;
        if (respData is Map && respData['message'] != null) {
          userFriendlyError = respData['message'].toString();
        } else if (e.message != null && e.message!.isNotEmpty) {
          userFriendlyError = e.message!;
        }
      }

      final failedMsg = tempMsg.copyWith(
        hasError: true,
        errorMessage: userFriendlyError,
      );

      final updatedMessages = state.messages.map((m) {
        return m.id == tempId ? failedMsg : m;
      }).toList();

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
        errorMessage: userFriendlyError,
      );
    }
  }

  Future<void> retryMediaMessage(ChatMessageModel msg) async {
    if (msg.retryBytes == null) return;
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != msg.id).toList(),
      clearError: true,
    );
    await sendMediaMessage(
      msg.retryBytes!,
      msg.retryFilename ??
          (msg.mediaType == 'audio' ? 'voice.mp3' : 'receipt.jpg'),
      userPromptHint: msg.textContent,
    );
  }

  Future<void> confirmPendingAction(
    String actionId, {
    EditTransactionDraft? editedData,
  }) async {
    try {
      // Nếu chưa có editedData truyền vào, kiểm tra xem bản draft đã sửa lưu trong tin nhắn chưa
      EditTransactionDraft? finalEditedData = editedData;
      if (finalEditedData == null) {
        for (final m in state.messages) {
          final mActionId = m.pendingAction?.id ??
              m.payloadJson?['pendingActionId']?.toString();
          if (mActionId == actionId && m.payloadJson?['editedData'] is Map) {
            finalEditedData = EditTransactionDraft.fromJson(
              Map<String, dynamic>.from(m.payloadJson!['editedData'] as Map),
            );
            break;
          }
        }
      }

      final result = await _repository.executePendingAction(
        actionId: actionId,
        action: PendingActionDecision.confirm,
        editedData: finalEditedData,
      );

      // Cập nhật trạng thái card trong danh sách tin nhắn hiện tại
      _updateMessagePendingActionStatus(
        actionId,
        PendingActionStatusEnum.confirmed,
        editedData: finalEditedData,
      );

      // Nếu có assistantMessage phản hồi sau khi lưu, thêm vào cuộc trò chuyện
      if (result.assistantMessage != null) {
        state = state.copyWith(
          messages: [...state.messages, result.assistantMessage!],
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Không thể xác nhận giao dịch: $e',
      );
    }
  }

  void updatePendingActionDraft(
    String actionId,
    EditTransactionDraft editedData,
  ) {
    final updatedList = state.messages.map((msg) {
      final msgActionId = msg.pendingAction?.id ??
          (msg.payloadJson != null
              ? msg.payloadJson!['pendingActionId']?.toString()
              : null);

      if (msgActionId == actionId) {
        var updatedPayload = msg.payloadJson != null
            ? Map<String, dynamic>.from(msg.payloadJson!)
            : <String, dynamic>{};

        if (updatedPayload['preview'] is Map) {
          final preview = Map<String, dynamic>.from(updatedPayload['preview'] as Map);
          if (editedData.type != null) preview['type'] = editedData.type;
          if (editedData.name != null) preview['name'] = editedData.name;
          if (editedData.amount != null) {
            preview['amount'] = editedData.amount;
            preview['amountFormatted'] = null;
          }
          if (editedData.categoryName != null) preview['categoryName'] = editedData.categoryName;
          if (editedData.accountName != null) preview['accountName'] = editedData.accountName;
          if (editedData.date != null) preview['date'] = editedData.date;
          if (editedData.note != null) preview['note'] = editedData.note;
          if (editedData.locationName != null) preview['locationName'] = editedData.locationName;
          if (editedData.visibility != null) preview['visibility'] = editedData.visibility;
          if (editedData.amountHidden != null) preview['amountHidden'] = editedData.amountHidden;
          if (editedData.excludeFromReport != null) preview['excludeFromReport'] = editedData.excludeFromReport;
          updatedPayload['preview'] = preview;
        }

        if (updatedPayload['toolInput'] is Map) {
          final toolInput = Map<String, dynamic>.from(updatedPayload['toolInput'] as Map);
          if (editedData.type != null) toolInput['type'] = editedData.type;
          if (editedData.name != null) toolInput['name'] = editedData.name;
          if (editedData.amount != null) toolInput['amount'] = editedData.amount;
          if (editedData.date != null) toolInput['date'] = editedData.date;
          if (editedData.note != null) toolInput['note'] = editedData.note;
          if (editedData.accountId != null) toolInput['accountId'] = editedData.accountId;
          if (editedData.categoryId != null) toolInput['categoryId'] = editedData.categoryId;
          if (editedData.locationName != null) toolInput['locationName'] = editedData.locationName;
          if (editedData.visibility != null) toolInput['visibility'] = editedData.visibility;
          if (editedData.amountHidden != null) toolInput['amountHidden'] = editedData.amountHidden;
          if (editedData.excludeFromReport != null) toolInput['excludeFromReport'] = editedData.excludeFromReport;
          updatedPayload['toolInput'] = toolInput;
        }

        if (editedData.type != null) updatedPayload['type'] = editedData.type;
        if (editedData.name != null) updatedPayload['name'] = editedData.name;
        if (editedData.amount != null) updatedPayload['amount'] = editedData.amount;
        if (editedData.categoryName != null) updatedPayload['categoryName'] = editedData.categoryName;
        if (editedData.accountName != null) updatedPayload['accountName'] = editedData.accountName;
        if (editedData.date != null) updatedPayload['date'] = editedData.date;
        if (editedData.note != null) updatedPayload['note'] = editedData.note;
        if (editedData.locationName != null) updatedPayload['locationName'] = editedData.locationName;
        if (editedData.visibility != null) updatedPayload['visibility'] = editedData.visibility;
        if (editedData.amountHidden != null) updatedPayload['amountHidden'] = editedData.amountHidden;
        if (editedData.excludeFromReport != null) updatedPayload['excludeFromReport'] = editedData.excludeFromReport;

        // Lưu bản nháp đã sửa vào payloadJson
        updatedPayload['editedData'] = editedData.toJson();

        return msg.copyWith(
          payloadJson: updatedPayload,
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedList);
  }

  Future<void> rejectPendingAction(String actionId) async {
    try {
      final result = await _repository.executePendingAction(
        actionId: actionId,
        action: PendingActionDecision.reject,
      );

      _updateMessagePendingActionStatus(actionId, PendingActionStatusEnum.rejected);

      if (result.assistantMessage != null) {
        state = state.copyWith(
          messages: [...state.messages, result.assistantMessage!],
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Không thể hủy giao dịch: $e',
      );
    }
  }

  void _updateMessagePendingActionStatus(
    String actionId,
    PendingActionStatusEnum newStatus, {
    EditTransactionDraft? editedData,
  }) {
    final updatedList = state.messages.map((msg) {
      final msgActionId = msg.pendingAction?.id ??
          (msg.payloadJson != null
              ? msg.payloadJson!['pendingActionId']?.toString()
              : null);

      if (msgActionId == actionId) {
        var updatedPayload = msg.payloadJson;
        if (editedData != null && updatedPayload != null) {
          updatedPayload = Map<String, dynamic>.from(updatedPayload);
          if (updatedPayload['preview'] is Map) {
            final preview = Map<String, dynamic>.from(updatedPayload['preview'] as Map);
            if (editedData.name != null) preview['name'] = editedData.name;
            if (editedData.amount != null) preview['amount'] = editedData.amount;
            if (editedData.note != null) preview['note'] = editedData.note;
            updatedPayload['preview'] = preview;
          }
          if (editedData.name != null) updatedPayload['name'] = editedData.name;
          if (editedData.amount != null) updatedPayload['amount'] = editedData.amount;
          if (editedData.note != null) updatedPayload['note'] = editedData.note;
        }

        final currentPending = msg.pendingAction ??
            PendingActionSummary(id: actionId, status: newStatus);

        return msg.copyWith(
          pendingAction: currentPending.copyWith(status: newStatus),
          payloadJson: updatedPayload,
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedList);
  }

  Future<void> switchWallet(WalletItemModel wallet) async {
    if (wallet.id == state.activeWalletId) return;

    state = state.copyWith(
      activeWalletId: wallet.id,
      activeWalletName: wallet.name,
      messages: [],
    );

    await loadHistory(wallet.id);
  }

  Future<void> clearHistory() async {
    final walletId = state.activeWalletId;
    if (walletId == null) return;

    try {
      await _repository.clearHistory(walletId);
      state = state.copyWith(messages: []);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Lỗi khi xóa lịch sử trò chuyện: $e',
      );
    }
  }
}
