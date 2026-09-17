import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'route_names.dart';

class QuickAddModal extends StatelessWidget {
  const QuickAddModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppColors.radiusXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header with Finora AI Nora chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tạo giao dịch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chọn phương thức nhập liệu thuận tiện nhất',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 13, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Nora AI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Options Grid
            Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.mic_rounded,
                    title: 'Giọng nói AI',
                    subtitle: 'PhoWhisper hiểu tiếng Việt tự nhiên',
                    gradient: const [Color(0xFF1E5BD8), Color(0xFF3B82F6)],
                    onTap: () {
                      Navigator.pop(context);
                      _showVoiceAiDemo(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.document_scanner_rounded,
                    title: 'Quét hóa đơn',
                    subtitle: 'VietOCR trích xuất số tiền tức thì',
                    gradient: const [Color(0xFFF97316), Color(0xFFFB923C)],
                    onTap: () {
                      Navigator.pop(context);
                      _showOcrDemo(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.edit_note_rounded,
                    title: 'Nhập thủ công',
                    subtitle: 'Ghi chép thu chi truyền thống',
                    gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.transactions);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Chuyển khoản',
                    subtitle: 'Giữa ví tiền và ngân hàng',
                    gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.wallets);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _showVoiceAiDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
        ),
        title: const Row(
          children: [
            Icon(Icons.mic_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Nora Voice AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Đang kết nối PhoWhisper Engine...\n\nHãy thử nói: "Ăn trưa phở thìn 65 ngàn bằng ví MoMo"',
          style: TextStyle(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void _showOcrDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
        ),
        title: const Row(
          children: [
            Icon(Icons.document_scanner_rounded, color: AppColors.orange),
            SizedBox(width: 8),
            Text('VietOCR Scanner', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Mở camera và chụp trực tiếp hóa đơn VAT, vé xem phim hoặc bill siêu thị.\n\nVietOCR sẽ tự động nhận diện tổng tiền và phân loại danh mục.',
          style: TextStyle(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppColors.darkMuted : const Color(0xFF94A3B8),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
