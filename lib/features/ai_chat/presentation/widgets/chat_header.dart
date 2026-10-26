import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../../domain/models/wallet_item_model.dart';
import 'mascot_persona_sheet.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final MascotData mascot;
  final String activeWalletName;
  final List<WalletItemModel> wallets;
  final ValueChanged<WalletItemModel>? onSelectWallet;
  final VoidCallback? onClearHistory;

  const ChatHeader({
    super.key,
    required this.mascot,
    required this.activeWalletName,
    required this.wallets,
    this.onSelectWallet,
    this.onClearHistory,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  void _showWalletSelector(BuildContext context) {
    if (wallets.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chọn ví quản lý',
                      style: GoogleFonts.inter(
                        fontSize: 16,
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
                const SizedBox(height: 12),
                ...wallets.map((w) {
                  final isSelected = w.name == activeWalletName;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isSelected ? AppColors.primary : Colors.grey)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        w.isShared
                            ? Icons.group_rounded
                            : Icons.account_balance_wallet_rounded,
                        color: isSelected ? AppColors.primary : Colors.grey,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      w.name,
                      style: GoogleFonts.inter(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground),
                      ),
                    ),
                    subtitle: Text(
                      w.isShared ? 'Ví chia sẻ' : 'Ví cá nhân',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      onSelectWallet?.call(w);
                    },
                  );
                }),
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Back Button (match .tx-back)
              InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Nora Avatar with Online Status Dot (match .nora-av & .nora-dot)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mascot.blobColor.withValues(alpha: 0.18),
                      border: Border.all(
                        color: mascot.color.withValues(alpha: 0.35),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mascot.color.withValues(alpha: 0.16),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: MascotWidget(
                        mascotId: mascot.id,
                        size: 38,
                        float: false,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          width: 2.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Title & Online Status
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${mascot.name} · AI Mascot',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => _showWalletSelector(context),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              activeWalletName,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 15,
                            color: Color(0xFF10B981),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mascot Persona Spotlight Button (match .tx-back #icon-sparkles)
              InkWell(
                onTap: () => MascotPersonaSheet.show(context, mascot),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFF59E0B),
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Menu Options (Clear chat history / Change persona)
              PopupMenuButton<String>(
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                    size: 20,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: isDark ? AppColors.darkSurface : Colors.white,
                onSelected: (val) {
                  if (val == 'clear') {
                    onClearHistory?.call();
                  } else if (val == 'wallet') {
                    _showWalletSelector(context);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'wallet',
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Đổi ví tài chính',
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Xóa lịch sử chat',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
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
