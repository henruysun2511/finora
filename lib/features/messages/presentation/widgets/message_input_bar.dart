import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/message_attachment.dart';

class MessageInputBar extends StatefulWidget {
  const MessageInputBar({
    super.key,
    required this.onSend,
    this.isSending = false,
  });

  final void Function(String text, MessageTransactionAttachment? attachment) onSend;
  final bool isSending;

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final _controller = TextEditingController();
  MessageTransactionAttachment? _selectedAttachment;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedAttachment == null) return;
    if (widget.isSending) return;

    widget.onSend(text, _selectedAttachment);
    _controller.clear();
    setState(() {
      _selectedAttachment = null;
    });
  }

  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ĐÍNH KÈM CHIA SẺ TÀI CHÍNH',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: LucideIcon(name: 'receipt', size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Chia sẻ giao dịch gần đây'),
                  subtitle: const Text('Gửi chi tiết hoá đơn ăn uống, mua sắm để chia tiền'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedAttachment = const MessageTransactionAttachment(
                        transactionId: 'tx_sample',
                        title: 'Ăn tối nhóm bạn',
                        amount: 320000,
                        categoryName: 'Ăn uống',
                        categoryIcon: '🍕',
                      );
                    });
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.success.withValues(alpha: 0.15),
                    child: const LucideIcon(name: 'coins', size: 18, color: AppColors.success),
                  ),
                  title: const Text('Tạo yêu cầu chuyển tiền'),
                  subtitle: const Text('Nhắc nhẹ bạn bè thanh toán phần chia tiền'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedAttachment = const MessageTransactionAttachment(
                        transactionId: 'tx_req',
                        title: 'Yêu cầu chuyển tiền cà phê',
                        amount: 45000,
                        categoryName: 'Cà phê',
                        categoryIcon: '☕',
                        isExpense: false,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner đính kèm nếu đang chọn
          if (_selectedAttachment != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(_selectedAttachment!.categoryIcon ?? '💳', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đính kèm: ${_selectedAttachment!.title} (${_selectedAttachment!.amount.toStringAsFixed(0)} ₫)',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const LucideIcon(name: 'x', size: 16, color: AppColors.primary),
                    onPressed: () => setState(() => _selectedAttachment = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              IconButton(
                icon: const LucideIcon(name: 'plus', color: AppColors.primary),
                onPressed: _showAttachOptions,
                tooltip: 'Đính kèm tài chính',
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn tế nhị...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: widget.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const LucideIcon(name: 'send', size: 20, color: AppColors.primary),
                onPressed: widget.isSending ? null : _handleSend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

