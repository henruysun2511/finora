import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../providers/ai_chat_notifier.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/quick_prompt_chips.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ChatInputBarState> _inputKey = GlobalKey<ChatInputBarState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <= 40) {
      ref.read(aiChatNotifierProvider.notifier).loadMoreMessages();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(aiChatNotifierProvider);
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    final mascot = state.mascotData;

    // Lắng nghe thay đổi tin nhắn để tự cuộn xuống cuối
    ref.listen(aiChatNotifierProvider.select((s) => s.messages.length), (_, __) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: ChatHeader(
        mascot: mascot,
        activeWalletName: state.activeWalletName,
        wallets: state.wallets,
        onSelectWallet: (w) => notifier.switchWallet(w),
        onClearHistory: () => notifier.clearHistory(),
      ),
      body: Column(
        children: [
          // Error alert banner if any
          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.redAccent.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.push(RoutePaths.createTransaction),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Nhập tay',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Message Stream / Body
          Expanded(
            child: state.isLoadingHistory && state.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF0072D5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đang tải hội thoại tài chính...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (state.isLoadingMore)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0072D5),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          itemCount: state.messages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4, bottom: 14),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    'HÔM NAY · 12:30',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final msg = state.messages[index - 1];
                            return ChatBubble(
                              message: msg,
                              mascot: mascot,
                              onConfirmPendingAction: (actionId) =>
                                  notifier.confirmPendingAction(actionId),
                              onSaveDraft: (actionId, draft) =>
                                  notifier.updatePendingActionDraft(
                                actionId,
                                draft,
                              ),
                              onRejectPendingAction: (actionId) =>
                                  notifier.rejectPendingAction(actionId),
                              onSelectClarifyAction: (intent) =>
                                  notifier.sendMessage(
                                'Tôi chọn: $intent',
                                intentOverride: intent,
                              ),
                              onRetry: (msgToRetry) =>
                                  notifier.retryMediaMessage(msgToRetry),
                              onManualInput: () =>
                                  context.push(RoutePaths.createTransaction),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),

          // Quick Prompt Chips
          QuickPromptChips(
            onSelectPrompt: (prompt) {
              notifier.sendMessage(prompt);
            },
          ),
          const SizedBox(height: 6),

          // Interactive Input Bar
          ChatInputBar(
            key: _inputKey,
            isSending: state.isSending,
            mascotName: mascot.name,
            onSend: (text) => notifier.sendMessage(text),
            onSendMedia: (bytes, filename, {promptHint}) =>
                notifier.sendMediaMessage(
              bytes,
              filename,
              userPromptHint: promptHint,
            ),
          ),
        ],
      ),
    );
  }
}
