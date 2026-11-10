import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendTransaction,
    this.isGroup = false,
  });

  final void Function(String text) onSendText;
  final void Function({
    required String name,
    required double amount,
    bool isExpense,
    String? groupWalletName,
  }) onSendTransaction;
  final bool isGroup;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  void _showAttachBillSheet() {
    final nameCtrl = TextEditingController(text: 'Tiền ăn trưa bún bò');
    final amountCtrl = TextEditingController(text: '85000');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final dark = Theme.of(ctx).brightness == Brightness.dark;
        final surface = dark ? AppColors.darkSurface : Colors.white;
        final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
        final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
        final border = dark ? AppColors.darkBorder : AppColors.lightBorder;

        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Đính kèm hóa đơn chia tiền',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: foreground),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên khoản chi tiêu',
                  labelStyle: TextStyle(color: muted, fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền (VNĐ)',
                  labelStyle: TextStyle(color: muted, fontSize: 13),
                  suffixText: 'đ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                    if (name.isEmpty || amount <= 0) {
                      AppToast.error(ctx, 'Vui lòng nhập đầy đủ tên và số tiền hợp lệ');
                      return;
                    }
                    Navigator.pop(ctx);
                    widget.onSendTransaction(
                      name: name,
                      amount: amount,
                      isExpense: true,
                      groupWalletName: widget.isGroup ? 'Quỹ chung nhóm' : null,
                    );
                    AppToast.success(context, 'Đã đính kèm hóa đơn chia tiền vào cuộc trò chuyện');
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Gửi hóa đơn vào chat', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final bg = dark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
            tooltip: 'Đính kèm hóa đơn',
            onPressed: _showAttachBillSheet,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: widget.isGroup ? 'Thảo luận với nhóm ví chung...' : 'Nhắn tin...',
                  hintStyle: TextStyle(fontSize: 13.5, color: muted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: TextStyle(fontSize: 14, color: foreground),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
