import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/models/send_message_input.dart';
import 'cards/chat_bar_chart_card.dart';
import 'cards/chat_pie_chart_card.dart';
import 'cards/chat_stat_card.dart';
import 'cards/chat_transaction_list_card.dart';
import 'confirmation_prompt_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final MascotData mascot;
  final ValueChanged<String>? onConfirmPendingAction;
  final void Function(String actionId, EditTransactionDraft draft)? onSaveDraft;
  final ValueChanged<String>? onRejectPendingAction;
  final ValueChanged<String>? onSelectClarifyAction;

  const ChatBubble({
    super.key,
    required this.message,
    required this.mascot,
    this.onConfirmPendingAction,
    this.onSaveDraft,
    this.onRejectPendingAction,
    this.onSelectClarifyAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.isUser) {
      // User message bubble (Aligned to the Right)
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 48), // Indent from left
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0072D5), Color(0xFF0058A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0072D5).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  message.textContent,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // AI Mascot message bubble (Aligned to the Left with Mascot Avatar)
    final hasPendingAction = message.isConfirmationPrompt;
    final payload = message.payloadJson;
    final clarifyActions = payload?['clarifyActions'] as List<dynamic>?;

    final isPieChart = !hasPendingAction &&
        (message.messageType == ChatMessageTypeEnum.chartPie ||
            (payload != null && payload['chartType'] == 'pie'));
    final isBarChart = !hasPendingAction &&
        (message.messageType == ChatMessageTypeEnum.chartBar ||
            (payload != null && payload['chartType'] == 'bar'));
    final isStatCard = !hasPendingAction &&
        (message.messageType == ChatMessageTypeEnum.statCard ||
            (payload != null &&
                (payload.containsKey('totalBalanceFormatted') ||
                    (payload.containsKey('categoryName') &&
                        !payload.containsKey('preview')))));
    final isTxList = !hasPendingAction &&
        (message.messageType == ChatMessageTypeEnum.transactionList ||
            (payload != null && payload.containsKey('items')));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mascot Avatar (match .msg-av in device-preview)
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mascot.blobColor.withValues(alpha: 0.18),
              border: Border.all(
                color: mascot.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: mascot.color.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: MascotWidget(
                mascotId: message.mascot ?? mascot.id,
                size: 32,
                float: false,
              ),
            ),
          ),

          // Message content and optional cards
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text bubble
                if (message.textContent.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.textContent,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                        height: 1.45,
                      ),
                    ),
                  ),

                // 1. Confirmation Card for HITL Pending Action
                if (hasPendingAction)
                  ConfirmationPromptCard(
                    message: message,
                    onConfirm: onConfirmPendingAction,
                    onSaveDraft: onSaveDraft,
                    onReject: onRejectPendingAction,
                  ),

                // 2. Rich Card: Pie Chart
                if (isPieChart && payload != null)
                  ChatPieChartCard(payload: payload),

                // 3. Rich Card: Bar Chart / Period Comparison
                if (isBarChart && payload != null)
                  ChatBarChartCard(payload: payload),

                // 4. Rich Card: Stat Card (Balance / Category detail)
                if (isStatCard && payload != null)
                  ChatStatCard(payload: payload),

                // 5. Rich Card: Transaction List
                if (isTxList && payload != null)
                  ChatTransactionListCard(payload: payload),

                // Clarify Action Chips if AI requests clarification
                if (clarifyActions != null && clarifyActions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: clarifyActions.map((action) {
                        final label = action is Map<String, dynamic>
                            ? action['label'] ?? action['title'] ?? 'Chọn'
                            : action.toString();
                        final intent = action is Map<String, dynamic>
                            ? action['intent'] as String?
                            : null;

                        return InkWell(
                          onTap: () => onSelectClarifyAction?.call(intent ?? label),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF0072D5).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0072D5),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
