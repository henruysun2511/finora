import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final void Function(List<int> bytes, String filename, {String? promptHint})? onSendMedia;
  final bool isSending;
  final String mascotName;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onSendMedia,
    required this.isSending,
    this.mascotName = 'Nora',
  });

  @override
  State<ChatInputBar> createState() => ChatInputBarState();
}

class ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void setText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    _controller.clear();
    widget.onSend(text);
  }

  void _showVoiceModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nhập liệu bằng giọng nói',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nói câu lệnh chi tiêu, ví dụ:\n"Ghi cho anh ăn sáng phở Thìn 65k tiền mặt"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    setText('Ăn sáng phở Thìn 65k tiền mặt');
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0072D5), Color(0xFF0058A8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0072D5).withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chạm để dùng câu lệnh mẫu hoặc nói',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadReceipt(
    BuildContext context,
    ImageSource source,
  ) async {
    Navigator.pop(context);
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final filename = image.name.isNotEmpty
            ? image.name
            : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';

        if (widget.onSendMedia != null) {
          widget.onSendMedia!(
            bytes,
            filename,
            promptHint:
                '📷 Đã tải lên ảnh hóa đơn: $filename. Hãy đọc bóc tách OCR giúp tôi.',
          );
        } else {
          widget.onSend(
              'Tôi vừa tải lên ảnh hóa đơn $filename, hãy đọc giúp tôi.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh từ thiết bị: $e')),
        );
      }
    }
  }

  void _showScanModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quét hóa đơn thông minh (OCR)',
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'AI sẽ tự động đọc tổng tiền, ngày và tên cửa hàng từ ảnh hóa đơn.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                const SizedBox(height: 16),

                // Option 1: Tải ảnh từ thiết bị (Gallery / File upload)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Tải ảnh hóa đơn từ thiết bị',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Chọn ảnh hóa đơn JPG, PNG từ thư viện máy',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pickAndUploadReceipt(ctx, ImageSource.gallery),
                ),
                const SizedBox(height: 4),

                // Option 2: Chụp ảnh mới từ Camera
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0072D5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF0072D5),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Chụp ảnh hóa đơn mới',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Mở máy ảnh chụp trực tiếp hóa đơn giấy',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pickAndUploadReceipt(ctx, ImageSource.camera),
                ),
                const Divider(height: 20),

                // Quick Simulation OCR samples
                Text(
                  'HOẶC THỬ NHANH VỚI HÓA ĐƠN MẪU',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickSampleChip(
                      ctx,
                      '☕ Highlands Coffee 65k',
                      'Highlands Coffee 65k tiền mặt',
                    ),
                    _buildQuickSampleChip(
                      ctx,
                      '🛒 Siêu thị WinMart 345k',
                      'WinMart 345k thẻ Vietcombank',
                    ),
                    _buildQuickSampleChip(
                      ctx,
                      '🍜 Haidilao Hotpot 850k',
                      'Ăn tối Haidilao 850k thẻ tín dụng',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSampleChip(
    BuildContext context,
    String label,
    String simulateText,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      avatar: const Icon(Icons.receipt_rounded, size: 15, color: Color(0xFF0072D5)),
      label: Text(label),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        Navigator.pop(context);
        setText(simulateText);
        _handleSend();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice action button (Mic)
            InkWell(
              onTap: () => _showVoiceModal(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mic_none_rounded,
                  color: isDark
                      ? AppColors.darkForeground
                      : const Color(0xFF475569),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Camera / Scan receipt action button (Scan OCR)
            InkWell(
              onTap: () => _showScanModal(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: isDark
                      ? AppColors.darkForeground
                      : const Color(0xFF475569),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Text input field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhắn cho ${widget.mascotName}: vd ăn trưa 45k...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            InkWell(
              onTap: _hasText && !widget.isSending ? _handleSend : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _hasText && !widget.isSending
                      ? const LinearGradient(
                          colors: [Color(0xFF0072D5), Color(0xFF0058A8)],
                        )
                      : null,
                  color: _hasText && !widget.isSending
                      ? null
                      : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0)),
                ),
                child: widget.isSending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0072D5),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: _hasText
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8)),
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
