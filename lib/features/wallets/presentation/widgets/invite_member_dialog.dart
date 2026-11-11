import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/enums/wallet_member_role.dart';
import '../providers/wallet_detail_provider.dart';

class InviteMemberDialog extends ConsumerStatefulWidget {
  final String walletId;

  const InviteMemberDialog({super.key, required this.walletId});

  @override
  ConsumerState<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
  final _emailController = TextEditingController();
  WalletMemberRole _selectedRole = WalletMemberRole.editor;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppToast.error(context, 'Vui lòng nhập email hợp lệ');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(walletDetailActionsProvider(widget.walletId))
          .inviteMember(email, _selectedRole);

      if (mounted) {
        Navigator.pop(context);
        AppToast.success(context, 'Đã gửi lời mời tham gia ví tới $email');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFF6366F1),
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
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      Text(
                        'Cùng quản lý chi tiêu trong ví chung',
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

            // Email input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email thành viên (*)',
                hintText: 'nguyenvanb@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Role selection
            Text(
              'Gán vai trò (*):',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 8),

            // Radio Editor
            RadioListTile<WalletMemberRole>(
              value: WalletMemberRole.editor,
              groupValue: _selectedRole,
              title: Text(
                'Biên tập viên (Editor)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Được thêm thu chi, liên kết tài khoản ngân hàng',
                style: GoogleFonts.inter(fontSize: 11),
              ),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),

            // Radio Viewer
            RadioListTile<WalletMemberRole>(
              value: WalletMemberRole.viewer,
              groupValue: _selectedRole,
              title: Text(
                'Người xem (Viewer)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Chỉ xem số dư và báo cáo, không thể chỉnh sửa',
                style: GoogleFonts.inter(fontSize: 11),
              ),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('HỦY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'GỬI LỜI MỜI',
                    isLoading: _isLoading,
                    onPressed: _handleInvite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

