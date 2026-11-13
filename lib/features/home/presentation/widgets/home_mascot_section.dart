import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../../../mascot/presentation/providers/current_mascot_provider.dart';
import '../../../mascot/presentation/widgets/mascot_level_up_dialog.dart';
import 'section_header.dart';

/// Section hiển thị danh sách các Linh vật AI đồng hành trên Trang chủ
/// Cho phép lướt xem nhanh các mascot và nhấn vào để xem chi tiết đầy đủ tại MascotShowcaseScreen
class HomeMascotSection extends ConsumerWidget {
  const HomeMascotSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMascotAsync = ref.watch(currentMascotProvider);
    final currentTierName =
        currentMascotAsync.valueOrNull?.mascot.tierName.toLowerCase();

    final mascots = MascotRegistry.tiers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Linh vật AI đồng hành',
          actionText: 'Khám phá tất cả (7)',
          onTap: () => context.push(RoutePaths.mascotShowcase),
        ),
        const SizedBox(height: 12),

        // ── Banner Nút Xem Demo Thăng Hạng Mascot ──
        InkWell(
          onTap: () => _openLevelUpDemo(context, currentTierName),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E293B),
                        AppColors.primary.withValues(alpha: 0.25),
                      ]
                    : [
                        const Color(0xFFF0FDF4),
                        AppColors.primary.withValues(alpha: 0.12),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xem demo Thăng hạng Mascot 🎉',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Nhấn để xem hiệu ứng popup chúc mừng khi đạt cột mốc mới',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: mascots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final mascot = mascots[index];
              final isCurrent = currentTierName == mascot.id ||
                  (currentTierName == null && mascot.id == 'nora');

              return _MascotPreviewCard(
                mascot: mascot,
                isCurrent: isCurrent,
                isDark: isDark,
                onTap: () => context.push(
                  '${RoutePaths.mascotShowcase}?id=${mascot.id}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openLevelUpDemo(BuildContext context, String? currentTier) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final allMascots = MascotRegistry.all;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.72,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkBorder : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chọn Mascot để xem Demo Thăng hạng',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: allMascots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final m = allMascots[index];
                      return ListTile(
                        onTap: () {
                          Navigator.pop(ctx);
                          MascotLevelUpDialog.show(
                            context,
                            tierName: m.id,
                            previousTierName: currentTier ?? 'penny',
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        tileColor: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF8FAFC),
                        leading: CircleAvatar(
                          backgroundColor: m.color.withValues(alpha: 0.15),
                          child: Text(
                            m.name.substring(0, 1),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: m.color,
                            ),
                          ),
                        ),
                        title: Text(
                          '${m.name} · ${m.role}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                        subtitle: Text(
                          'Cột mốc: ${m.range}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MascotPreviewCard extends StatelessWidget {
  const _MascotPreviewCard({
    required this.mascot,
    required this.isCurrent,
    required this.isDark,
    required this.onTap,
  });

  final MascotData mascot;
  final bool isCurrent;
  final bool isDark;
  final VoidCallback onTap;

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _parseColor(mascot.colorHex);

    final cardBg = isDark
        ? (isCurrent ? const Color(0xFF1E293B) : AppColors.darkSurface)
        : (isCurrent ? const Color(0xFFF0FDF4) : AppColors.lightSurface);

    final borderColor = isCurrent
        ? tierColor.withValues(alpha: isDark ? 0.8 : 0.6)
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                  color: tierColor.withValues(alpha: isDark ? 0.3 : 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top badge: "ĐANG DÙNG" or Tier label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: tierColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ĐANG DÙNG',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: tierColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      mascot.name,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                    ),
                ],
              ),

              // Mascot Floating Avatar
              SizedBox(
                width: 58,
                height: 58,
                child: MascotWidget(
                  mascotId: mascot.id,
                  size: 56,
                  float: true,
                  interactive: false,
                ),
              ),

              // Name & Role
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mascot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    mascot.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkMuted
                          : AppColors.lightMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Range Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      mascot.range,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: tierColor,
                      ),
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
}

