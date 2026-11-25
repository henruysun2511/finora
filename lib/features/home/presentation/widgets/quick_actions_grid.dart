import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/quick_action_item_model.dart';
import '../providers/quick_actions_provider.dart';

/// Lưới các phím tắt Thao tác nhanh trên màn hình chính
/// Chuẩn thiết kế FinTech SOLARN Style gốc (GEMINI.md)
class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  void _handleNavigation(BuildContext context, String routePath) {
    if (routePath == RoutePaths.budgets ||
        routePath == RoutePaths.wallets ||
        routePath == RoutePaths.aiChat ||
        routePath == RoutePaths.dashboard) {
      context.go(routePath);
    } else {
      context.push(routePath);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncState = ref.watch(quickActionsProvider);

    // Lấy danh sách item: nếu đang load hoặc lỗi thì fallback về danh mục mặc định
    final List<QuickActionItemModel> items = asyncState.valueOrNull?.enabledItems ??
        allQuickActionsCatalog.where((e) => e.isDefaultEnabled).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Card bọc lưới tiện ích thiết yếu (giữ nguyên phong cách gốc) ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.88,
              mainAxisSpacing: 16,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _QuickActionItem(
                isDark: isDark,
                icon: item.icon,
                label: item.label,
                bgColor: item.bgColor,
                onTap: () => _handleNavigation(context, item.routePath),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: bgColor.withValues(alpha: 0.12),
        highlightColor: bgColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : const Color(0xFF1E293B),
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
