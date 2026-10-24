import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'route_names.dart';

/// Modal Thao tác nhanh phong cách Solarn FinTech (`ui-sample-3`).
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh kéo drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Tiêu đề & Mascot badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thao tác nhanh',
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chọn phương thức nhập liệu thuận tiện nhất',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Nora AI',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lưới 4 tùy chọn thao tác
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
                      subtitle: 'VietOCR bóc tách số tiền tức thì',
                      gradient: const [Color(0xFFF97316), Color(0xFFFB923C)],
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RoutePaths.scanReceipt);
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
                        context.push(RoutePaths.createTransaction);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Chuyển khoản',
                      subtitle: 'Giữa các ví và tài khoản NH',
                      gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RoutePaths.transfer);
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
                      icon: Icons.event_repeat_rounded,
                      title: 'GD định kỳ',
                      subtitle: 'Thiết lập hóa đơn lặp lại',
                      gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RoutePaths.createRecurringTransaction);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Tạo ngân sách',
                      subtitle: 'Hạn mức chi tiêu theo tháng',
                      gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RoutePaths.createBudget);
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
                      icon: Icons.handshake_rounded,
                      title: 'Ghi nhận sổ nợ',
                      subtitle: 'Khoản cho vay hoặc đi vay',
                      gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RoutePaths.createLoan);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.call_split_rounded,
                      title: 'Chia tiền nhóm',
                      subtitle: 'Tạo đợt chia bill công bằng',
                      gradient: const [Color(0xFFDB2777), Color(0xFFF472B6)],
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RoutePaths.createSplitExpense);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  fontSize: 13,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
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
