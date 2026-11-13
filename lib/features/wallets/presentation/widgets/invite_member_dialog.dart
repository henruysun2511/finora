import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../friends/domain/models/friend.dart';
import '../../../friends/presentation/providers/friends_list_provider.dart';
import '../../domain/enums/wallet_member_role.dart';
import '../providers/wallet_detail_provider.dart';

/// Hộp thoại mời thành viên vào ví chung bằng thẻ Select chọn bạn bè
class InviteMemberDialog extends ConsumerStatefulWidget {
  final String walletId;

  const InviteMemberDialog({super.key, required this.walletId});

  @override
  ConsumerState<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
  String? _selectedUserId;
  WalletMemberRole _selectedRole = WalletMemberRole.editor;
  bool _isLoading = false;

  Future<void> _handleInvite(List<Friend> friends) async {
    if (_selectedUserId == null || _selectedUserId!.isEmpty) {
      AppToast.error(context, 'Vui lòng chọn một người bạn từ danh bạ');
      return;
    }

    final selectedFriend = friends.cast<Friend?>().firstWhere(
          (f) => f?.userId == _selectedUserId,
          orElse: () => null,
        );

    if (selectedFriend == null) {
      AppToast.error(context, 'Không tìm thấy thông tin bạn bè đã chọn');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(walletDetailActionsProvider(widget.walletId))
          .inviteMember(
            userId: selectedFriend.userId,
            email: selectedFriend.email,
            role: _selectedRole,
          );

      if (mounted) {
        Navigator.pop(context);
        AppToast.success(
          context,
          'Đã gửi lời mời tham gia quỹ tới ${selectedFriend.displayName}!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final friendsAsync = ref.watch(friendsListProvider);
    final friends = friendsAsync.valueOrNull?.friends ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Tiêu đề Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mời Thành viên vào Ví',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chọn bạn bè cùng quản lý quỹ nhóm',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // THẺ SELECT CHỌN BẠN BÈ
            Text(
              'Chọn bạn bè (*):',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 8),

            if (friendsAsync.isLoading)
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Đang tải danh sách bạn bè...',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ],
                ),
              )
            else if (friends.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_outline_rounded,
                      color: AppColors.warning,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Chưa có bạn bè trong danh bạ. Vui lòng kết bạn trước tại mục Bạn bè.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedUserId,
                isExpanded: true,
                hint: Text(
                  'Chọn một người bạn từ danh bạ...',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkBackground
                      : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                items: friends.map((friend) {
                  return DropdownMenuItem<String>(
                    value: friend.userId,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            friend.initials,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                friend.displayName,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              if (friend.email != null &&
                                  friend.email!.isNotEmpty)
                                Text(
                                  friend.email!,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedUserId = val);
                },
              ),

            const SizedBox(height: 18),

            // PHÂN QUYỀN VAI TRÒ
            Text(
              'Gán vai trò (*):',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 8),

            // Card Editor
            _buildRoleOption(
              isDark: isDark,
              role: WalletMemberRole.editor,
              title: 'Biên tập viên (Editor)',
              subtitle: 'Được ghi thu chi, liên kết nguồn tiền vào quỹ',
              icon: Icons.edit_note_rounded,
              isSelected: _selectedRole == WalletMemberRole.editor,
              onTap: () =>
                  setState(() => _selectedRole = WalletMemberRole.editor),
            ),
            const SizedBox(height: 8),

            // Card Viewer
            _buildRoleOption(
              isDark: isDark,
              role: WalletMemberRole.viewer,
              title: 'Người xem (Viewer)',
              subtitle: 'Chỉ theo dõi số dư và báo cáo, không thể chỉnh sửa',
              icon: Icons.visibility_rounded,
              isSelected: _selectedRole == WalletMemberRole.viewer,
              onTap: () =>
                  setState(() => _selectedRole = WalletMemberRole.viewer),
            ),

            const SizedBox(height: 22),

            // ACTIONS BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'HỦY',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (_isLoading || friends.isEmpty)
                        ? null
                        : () => _handleInvite(friends),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'GỬI LỜI MỜI',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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

  Widget _buildRoleOption({
    required bool isDark,
    required WalletMemberRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : (isDark
                  ? AppColors.darkBackground
                  : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
            ),
          ],
        ),
      ),
    ),
  );
}
}
