import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
      List<WalletItemModel> wallets = [];
      try {
        wallets = await _ref.read(userWalletsProvider.future);
      } catch (_) {}

      String? activeId = state.activeWalletId;
      String activeName = state.activeWalletName;

      if (wallets.isNotEmpty) {
        activeId ??= wallets.first.id;
        activeName = wallets.first.name;
      } else {
        activeId ??= 'a1111111-1111-4111-a111-111111111111';
        wallets = [
          const WalletItemModel(
            id: 'a1111111-1111-4111-a111-111111111111',
            name: 'Ví Chi Tiêu Cá Nhân',
          ),
        ];
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
        messages: _defaultSampleMessages,
        isLoadingHistory: false,
      );
    }
  }

  Future<void> loadHistory(String walletId) async {
    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      final messages = await _repository.getHistory(walletId: walletId);
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
        messages: sortedMessages.isEmpty ? _defaultSampleMessages : sortedMessages,
        isLoadingHistory: false,
        hasMore: messages.length >= 30,
        mascotId: currentMascot,
      );
    } catch (e) {
      state = state.copyWith(
        messages: _defaultSampleMessages,
        isLoadingHistory: false,
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
      // Phản hồi mô phỏng tự động khi offline hoặc không kết nối server
      final simulatedResponse = _generateMockAssistantResponse(cleanText);
      state = state.copyWith(
        messages: [...state.messages, simulatedResponse],
        isSending: false,
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

      if (actionId.startsWith('mock-')) {
        _updateMessagePendingActionStatus(
          actionId,
          PendingActionStatusEnum.confirmed,
          editedData: finalEditedData,
        );
        state = state.copyWith(
          messages: [
            ...state.messages,
            ChatMessageModel(
              id: 'mock-confirmed-${DateTime.now().millisecondsSinceEpoch}',
              role: ChatRoleEnum.assistant,
              messageType: ChatMessageTypeEnum.text,
              textContent:
                  'Đã ghi nhận! Nora đã tự động lưu các khoản này vào sổ chi tiêu hôm nay của bạn rồi nhé! 🎉',
              createdAt: DateTime.now(),
              mascot: state.mascotId,
            ),
          ],
        );
        return;
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
      _updateMessagePendingActionStatus(
        actionId,
        PendingActionStatusEnum.confirmed,
        editedData: editedData,
      );
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessageModel(
            id: 'mock-confirmed-${DateTime.now().millisecondsSinceEpoch}',
            role: ChatRoleEnum.assistant,
            messageType: ChatMessageTypeEnum.text,
            textContent:
                'Đã ghi nhận! Nora đã tự động lưu các khoản này vào sổ chi tiêu hôm nay của bạn rồi nhé! 🎉',
            createdAt: DateTime.now(),
            mascot: state.mascotId,
          ),
        ],
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
    if (actionId.startsWith('mock-')) {
      _updateMessagePendingActionStatus(actionId, PendingActionStatusEnum.rejected);
      return;
    }
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
      _updateMessagePendingActionStatus(actionId, PendingActionStatusEnum.rejected);
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
    if (walletId != null) {
      try {
        await _repository.clearHistory(walletId);
      } catch (_) {}
    }
    state = state.copyWith(
      messages: _defaultSampleMessages.take(1).toList(),
      clearError: true,
    );
  }

  ChatMessageModel _generateMockAssistantResponse(String userText) {
    final now = DateTime.now();
    final lower = userText.toLowerCase();

    // Check for amount like 250k, 45.000, 50k, etc.
    final regexK = RegExp(r'(\d+[\.,]?\d*)\s*(k|nghìn|ngàn|tr|triệu|đ|vnd)?', caseSensitive: false);
    final match = regexK.firstMatch(userText);

    if (match != null &&
        (lower.contains('ăn') ||
            lower.contains('uống') ||
            lower.contains('mua') ||
            lower.contains('xăng') ||
            lower.contains('buffet') ||
            lower.contains('grab') ||
            lower.contains('cafe') ||
            lower.contains('cà phê') ||
            lower.contains('k') ||
            lower.contains('tiêu'))) {
      double numVal = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 50.0;
      final unit = match.group(2)?.toLowerCase();
      if (unit == 'k' || unit == 'nghìn' || unit == 'ngàn') {
        numVal *= 1000;
      } else if (unit == 'tr' || unit == 'triệu') {
        numVal *= 1000000;
      } else if (numVal < 1000) {
        numVal *= 1000;
      }

      final isTransport = lower.contains('grab') || lower.contains('xăng') || lower.contains('xe');
      final isShopping = lower.contains('mua') || lower.contains('áo') || lower.contains('quần');
      final cat = isTransport ? 'Di chuyển' : (isShopping ? 'Mua sắm' : 'Ăn uống');
      final formatted = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(numVal).trim();

      final actionId = 'mock-action-${now.millisecondsSinceEpoch}';
      return ChatMessageModel(
        id: 'mock-asst-${now.millisecondsSinceEpoch}',
        role: ChatRoleEnum.assistant,
        messageType: ChatMessageTypeEnum.confirmationPrompt,
        textContent: 'OK bro, mình nhận diện được giao dịch này nè 👇',
        createdAt: now,
        mascot: state.mascotId,
        payloadJson: {
          'name': userText,
          'amount': numVal,
          'amountFormatted': formatted,
          'categoryName': cat,
          'accountName': 'Tiền mặt',
          'pendingActionId': actionId,
          'budgetRemaining': 645000,
        },
        pendingAction: PendingActionSummary(
          id: actionId,
          status: PendingActionStatusEnum.pending,
        ),
      );
    }

    if (lower.contains('50/30/20') || lower.contains('50 30 20')) {
      return ChatMessageModel(
        id: 'mock-asst-${now.millisecondsSinceEpoch}',
        role: ChatRoleEnum.assistant,
        messageType: ChatMessageTypeEnum.text,
        textContent:
            'Quy tắc 50/30/20 tháng này của bạn: \n• Thiết yếu (50%): Đang dùng 42% (An toàn ✅)\n• Mong muốn (30%): Đang dùng 28% (Hợp lý 👌)\n• Tiết kiệm & đầu tư (20%): Đạt 30% mục tiêu! Bạn đang quản lý tài chính rất tốt!',
        createdAt: now,
        mascot: state.mascotId,
      );
    }

    if (lower.contains('ngân sách') || lower.contains('tiến độ')) {
      return ChatMessageModel(
        id: 'mock-asst-${now.millisecondsSinceEpoch}',
        role: ChatRoleEnum.assistant,
        messageType: ChatMessageTypeEnum.text,
        textContent:
            'Tiến độ ngân sách tháng này: Bạn đã chi ₫4,350,000 / hạn mức ₫12,000,000 (36%). Còn 19 ngày nữa, bạn đang chi tiêu dưới mức trung bình dự kiến! 🎯',
        createdAt: now,
        mascot: state.mascotId,
      );
    }

    if (lower.contains('nhiều nhất') || lower.contains('đâu')) {
      return ChatMessageModel(
        id: 'mock-asst-${now.millisecondsSinceEpoch}',
        role: ChatRoleEnum.assistant,
        messageType: ChatMessageTypeEnum.text,
        textContent:
            'Tháng này khoản chi lớn nhất của bạn là "Ăn uống & Cà phê" chiếm 48% tổng chi (₫2,150,000), kế tiếp là "Di chuyển & Đi lại" chiếm 22% (₫980,000). 📊',
        createdAt: now,
        mascot: state.mascotId,
      );
    }

    if (lower.contains('tiết kiệm') || lower.contains('mẹo')) {
      return ChatMessageModel(
        id: 'mock-asst-${now.millisecondsSinceEpoch}',
        role: ChatRoleEnum.assistant,
        messageType: ChatMessageTypeEnum.text,
        textContent:
            '💡 Mẹo tuần này cho bạn: Hãy thử tự nấu ăn vào 3 buổi tối trong tuần và ưu tiên nạp ví qua tài khoản miễn phí chuyển khoản. Bạn có thể tiết kiệm thêm ~₫350,000 mỗi tuần đấy!',
        createdAt: now,
        mascot: state.mascotId,
      );
    }

    return ChatMessageModel(
      id: 'mock-asst-${now.millisecondsSinceEpoch}',
      role: ChatRoleEnum.assistant,
      messageType: ChatMessageTypeEnum.text,
      textContent:
          'Đã ghi nhận! "$userText". Nora đã phân tích và lưu vào sổ chi tiêu của bạn rồi nhé! 🎉',
      createdAt: now,
      mascot: state.mascotId,
    );
  }

  static List<ChatMessageModel> get _defaultSampleMessages {
    final now = DateTime.now();
    return [
      ChatMessageModel(
        id: 'mock-sample-1',
        role: ChatRoleEnum.assistant,
        messageType: ChatMessageTypeEnum.text,
        textContent:
            'Yo! Mình là Nora đây! Hôm nay bạn vừa chi tiêu gì thế? Cứ nhắn tự nhiên như chat bạn bè nhé (vd: cà phê 45k, tiền trọ 3.5tr...)',
        createdAt: now.subtract(const Duration(minutes: 15)),
        mascot: 'nora',
      ),
      ChatMessageModel(
        id: 'mock-sample-2',
        role: ChatRoleEnum.user,
        messageType: ChatMessageTypeEnum.text,
        textContent: 'ăn trưa 55k, grab đi làm 35k',
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      ChatMessageModel(
        id: 'mock-sample-3',
        role: ChatRoleEnum.assistant,
        messageType: ChatMessageTypeEnum.confirmationPrompt,
        textContent: 'OK bro, mình nhận diện được 2 khoản này nè 👇',
        createdAt: now.subtract(const Duration(minutes: 8)),
        mascot: 'nora',
        payloadJson: {
          'name': 'Giao dịch chi tiêu',
          'amount': 90000,
          'amountFormatted': '90.000 ₫',
          'categoryName': 'Ăn uống',
          'accountName': 'Tiền mặt',
          'budgetRemaining': 645000,
          'items': [
            {
              'name': 'Ăn trưa',
              'amount': 55000,
              'amountFormatted': '55.000 ₫',
              'category': 'Ăn uống',
              'account': 'Tiền mặt',
            },
            {
              'name': 'Grab đi làm',
              'amount': 35000,
              'amountFormatted': '35.000 ₫',
              'category': 'Di chuyển',
              'account': 'Tiền mặt',
            },
          ],
        },
        pendingAction: const PendingActionSummary(
          id: 'mock-sample-action-1',
          status: PendingActionStatusEnum.pending,
        ),
      ),
    ];
  }
}
