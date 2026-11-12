import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/enums/wallet_member_role.dart';
import '../../domain/models/wallet_member_model.dart';
import '../providers/wallet_detail_provider.dart';
import 'invite_member_dialog.dart';

class WalletMembersTab extends ConsumerWidget {
  final String walletId;
  final List<WalletMemberModel> members;
  final bool isOwner;

  const WalletMembersTab({
    super.key,
    required this.walletId,
    required this.members,
    required this.isOwner,
  });

  void _openInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => InviteMemberDialog(walletId: walletId),
    );
  }

  void _confirmKick(
    BuildContext context,
    WidgetRef ref,
    WalletMemberModel member,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa thành viên'),
        content: Text(
          'Bạn có chắc chắn muốn mời "${member.fullName}" rời khỏi ví này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(walletDetailActionsProvider(walletId))
                    .kickMember(member.userId);
                AppToast.success(context, 'Đã xóa thành viên khỏi ví');
              } catch (e) {
                AppToast.error(context, e);
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _changeRole(
    BuildContext context,
    WidgetRef ref,
    WalletMemberModel member,
    WalletMemberRole newRole,
  ) async {
    try {
      await ref
          .read(walletDetailActionsProvider(walletId))
          .updateMemberRole(member.userId, newRole);
      AppToast.success(
        context,
        'Đã đổi vai trò của ${member.fullName} thành ${newRole.displayName}',
      );
    } catch (e) {
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Count + "+ Mời bạn"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THÀNH VIÊN VÍ DÙNG CHUNG (${members.length})',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              if (isOwner)
                ElevatedButton.icon(
                  onPressed: () => _openInviteDialog(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: Text(
                    'Mời bạn',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Member Cards List
          ...members.map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: m.role.badgeColor.withValues(alpha: 0.15),
                    backgroundImage: m.avatar != null && m.avatar!.isNotEmpty
                        ? NetworkImage(m.avatar!)
                        : null,
                    child: m.avatar == null || m.avatar!.isEmpty
                        ? Text(
                            m.fullName.isNotEmpty
                                ? m.fullName[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: m.role.badgeColor,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.fullName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.email,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Badge Role
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: m.role.badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(m.role.icon, size: 12, color: m.role.badgeColor),
                        const SizedBox(width: 4),
                        Text(
                          m.role.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: m.role.badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions menu for Owner (excluding Owner themselves)
                  if (isOwner && !m.isOwner) ...[
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      onSelected: (val) {
                        if (val == 'MAKE_EDITOR') {
                          _changeRole(
                            context,
                            ref,
                            m,
                            WalletMemberRole.editor,
                          );
                        } else if (val == 'MAKE_VIEWER') {
                          _changeRole(
                            context,
                            ref,
                            m,
                            WalletMemberRole.viewer,
                          );
                        } else if (val == 'KICK') {
                          _confirmKick(context, ref, m);
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (m.role != WalletMemberRole.editor)
                          const PopupMenuItem(
                            value: 'MAKE_EDITOR',
                            child: Text('Đổi thành Biên tập viên (Editor)'),
                          ),
                        if (m.role != WalletMemberRole.viewer)
                          const PopupMenuItem(
                            value: 'MAKE_VIEWER',
                            child: Text('Đổi thành Người xem (Viewer)'),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'KICK',
                          child: Text(
                            'Xóa khỏi ví',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // Chú thích phân quyền
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Chú thích quyền hạn thành viên:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Owner: Toàn quyền thêm/xóa thành viên, xóa ví, tạo tài khoản.\n'
                  '• Editor: Được ghi chép giao dịch, thêm tài khoản ngân hàng.\n'
                  '• Viewer: Chỉ được xem báo cáo & số dư, không thể chỉnh sửa.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

