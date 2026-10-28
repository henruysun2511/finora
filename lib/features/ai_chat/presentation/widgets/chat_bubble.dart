import 'dart:typed_data';
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
  final ValueChanged<ChatMessageModel>? onRetry;
  final VoidCallback? onManualInput;

  const ChatBubble({
    super.key,
    required this.message,
    required this.mascot,
    this.onConfirmPendingAction,
    this.onSaveDraft,
    this.onRejectPendingAction,
    this.onSelectClarifyAction,
    this.onRetry,
    this.onManualInput,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.isUser) {
      // User message bubble (Aligned to the Right)
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 48), // Indent from left
                Flexible(
                  child: message.hasImage
                      ? _buildUserImageBubble(context)
                      : message.hasAudio
                          ? _buildUserAudioBubble(context)
                          : _buildUserTextBubble(context),
                ),
              ],
            ),
            if (message.hasError) ...[
              const SizedBox(height: 6),
              _buildErrorActions(context),
            ],
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

  Widget _buildUserTextBubble(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildUserImageBubble(BuildContext context) {
    final bytes = message.mediaBytes;
    final url = message.imageUrl;
    final hasCaption = message.textContent.isNotEmpty &&
        !message.textContent.contains('Ảnh hóa đơn') &&
        message.textContent != '📷 Ảnh hóa đơn';

    return GestureDetector(
      onTap: () => _showFullImageDialog(context, bytes: bytes, url: url),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
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
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Thumbnail with badge overlay
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFF0F172A),
                    child: bytes != null
                        ? Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                          )
                        : (url != null && url.isNotEmpty)
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (ctx, err, stack) => Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.broken_image_rounded,
                                        color: Colors.white54,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Không thể tải ảnh',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.receipt_long_rounded,
                                      color: Colors.white70,
                                      size: 38,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Hóa đơn đã phân tích',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),

                  // Top badge: Hóa đơn
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hóa đơn',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom zoom hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              // Caption / Description if present
              if (hasCaption)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    message.textContent,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAudioBubble(BuildContext context) {
    // Generate simulated waveform heights for realistic visual feedback
    const waveform = [
      8.0, 14.0, 22.0, 12.0, 26.0, 18.0, 10.0, 24.0, 16.0, 12.0, 20.0, 14.0, 8.0
    ];

    final hasTranscript = message.textContent.isNotEmpty &&
        !message.textContent.contains('Tin nhắn thoại') &&
        message.textContent != '🎤 Tin nhắn thoại';

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Audio Player Control & Waveform
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Mic icon circle
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),

              // Waveform Bars
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: waveform.map((height) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 3,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 10),

              // Duration / Type Label
              Text(
                'Thoại',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          // Speech-to-Text transcript subtitle if available
          if (hasTranscript) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 13,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      message.textContent,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullImageDialog(
    BuildContext context, {
    Uint8List? bytes,
    String? url,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: bytes != null
                    ? Image.memory(bytes, fit: BoxFit.contain)
                    : (url != null && url.isNotEmpty)
                        ? Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (c, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : const Icon(
                            Icons.receipt_long_rounded,
                            size: 80,
                            color: Colors.white70,
                          ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errText = message.errorMessage?.isNotEmpty == true
        ? message.errorMessage!
        : 'Gửi thất bại. Vui lòng thử lại hoặc nhập tay.';

    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D1618) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF43F5E).withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error description with warning icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 6),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: Color(0xFFE11D48),
                ),
              ),
              Expanded(
                child: Text(
                  errText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFFDA4AF)
                        : const Color(0xFFBE123C),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Action Buttons: Thử lại & Nhập tay
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Manual Input Button
              if (onManualInput != null) ...[
                InkWell(
                  onTap: onManualInput,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 15,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nhập tay',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // 2. Retry Button
              InkWell(
                onTap: () => onRetry?.call(message),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 15,
                        color: Color(0xFFE11D48),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Thử lại',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
