import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/balance_card.dart';
import '../../../auth/domain/models/user.dart';

class HomeHeader extends StatelessWidget {
  final User? user;

  const HomeHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      child: Column(
        children: [
          // Greeting & Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào buổi sáng',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Builder(
                      builder: (context) {
                        final fullName = (user?.name ?? 'Người dùng').trim();
                        final lastSpace = fullName.lastIndexOf(' ');
                        if (lastSpace == -1) {
                          return Text(
                            fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          );
                        }
                        return RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                            children: [
                              TextSpan(
                                text: fullName.substring(0, lastSpace + 1),
                              ),
                              TextSpan(
                                text: fullName.substring(lastSpace + 1),
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  // Notification Bell Chip
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.notifications),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkSurface
                                      : Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Avatar Chip
                  GestureDetector(
                    onTap: () => context.go(RoutePaths.profile),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (user?.name.isNotEmpty == true) ? user!.name[0] : 'N',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Balance Hero Card
          const BalanceCard(
            netWorth: 24850000,
            monthlyIncome: 15000000,
            monthlyExpense: 8320000,
            savingsRate: 44.5,
            tierTitle: 'Gold Tier',
            mascotMood: 'HAPPY',
          ),
        ],
      ),
    );
  }
}
