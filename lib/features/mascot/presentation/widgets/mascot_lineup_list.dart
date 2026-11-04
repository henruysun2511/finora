import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../../domain/models/mascot_tier.dart';

class MascotLineupList extends StatelessWidget {
  const MascotLineupList({
    super.key,
    required this.tiers,
    required this.currentTierName,
  });

  final List<MascotTier> tiers;
  final String currentTierName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tiers.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
        ),
        itemBuilder: (context, index) {
          final tier = tiers[index];
          final isCurrent = tier.tierName.toLowerCase() == currentTierName.toLowerCase();

          return InkWell(
            onTap: () => context.push(
              '\?id=',
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
              children: [
                MascotWidget(
                  mascotId: tier.tierName,
                  mode: MascotMode.avatar,
                  size: 42,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.fullTitle,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'HIỆN TẠI',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mốc Net Worth: ${tier.rangeLabel}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  const Icon(
                    Icons.stars_rounded,
                    color: AppColors.primary,
                    size: 22,
                  )
                else
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.lightMuted,
                    size: 18,
                  ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

