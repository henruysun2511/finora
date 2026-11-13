import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../accounts/domain/models/account_model.dart';
import '../../data/dto/update_wallet_request.dart';
import '../../domain/enums/wallet_member_role.dart';
import '../../domain/models/wallet_member_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/domain/models/shared_wallet_dashboard_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../notifications/domain/models/notification_item.dart';
import '../../../notifications/domain/models/notification_type.dart';
import '../../../notifications/presentation/providers/notification_list_provider.dart';
import '../providers/wallet_detail_provider.dart';
import '../providers/wallets_overview_provider.dart';
import '../widgets/invite_member_dialog.dart';

/// Màn hình Ví chung & Quỹ nhóm chuẩn FinTech Design System
/// 100% kết nối API thật, loại bỏ hoàn toàn mock data
class SharedWalletsScreen extends ConsumerStatefulWidget {
  const SharedWalletsScreen({super.key});

  @override
  ConsumerState<SharedWalletsScreen> createState() =>
      _SharedWalletsScreenState();
}

class _SharedWalletsScreenState extends ConsumerState<SharedWalletsScreen> {
  int _activeTabIndex = 0; // 0: Nguồn tiền, 1: Thành viên, 2: Giao dịch, 3: Cài đặt
  String? _selectedWalletId;
  String? _selectedMemberFilterUserId;

  void _changeRole(
    String walletId,
    WalletMemberModel member,
    WalletMemberRole newRole,
  ) async {
    try {
      await ref
          .read(walletDetailActionsProvider(walletId))
          .updateMemberRole(member.userId, newRole);
      if (mounted) {
        AppToast.success(
          context,
          'Đã đổi vai trò của ${member.fullName} thành ${newRole.displayName}',
        );
      }
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    }
  }

  void _confirmKick(
    String walletId,
    WalletMemberModel member,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa thành viên'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${member.fullName}" khỏi quỹ nhóm này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(walletDetailActionsProvider(walletId))
                    .kickMember(member.userId);
                if (mounted) {
                  AppToast.success(context, 'Đã xóa thành viên khỏi quỹ');
                }
              } catch (e) {
                if (mounted) AppToast.error(context, e.toString());
              }
            },
            child: const Text(
              'XÓA KHỎI QUỸ',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGroupSelector(
    BuildContext context,
    bool isDark,
    List<WalletItemState> sharedItems,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn Quỹ nhóm / Ví chung',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 14),
            if (sharedItems.isNotEmpty)
              ...sharedItems.map((item) {
                final isSelected = item.wallet.id == _selectedWalletId;
                return _groupTile(
                  isDark,
                  item.wallet.name,
                  '${CurrencyFormatter.format(item.balance.totalBalance, currency: item.wallet.defaultCurrency)} · ${item.accountsPreview.length} tài khoản',
                  isSelected,
                  onTap: () {
                    setState(() {
                      _selectedWalletId = item.wallet.id;
                    });
                    Navigator.pop(context);
                  },
                );
              })
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Bạn chưa có ví chung hoặc quỹ nhóm nào.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                context.push(RoutePaths.createSharedWallet);
              },
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              label: Text(
                'Tạo thêm quỹ nhóm mới',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupTile(
    bool isDark,
    String title,
    String subtitle,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark
                  ? AppColors.darkBackground
                  : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.groups_rounded,
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.darkForeground
                  : AppColors.lightForeground),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overviewAsync = ref.watch(walletsOverviewProvider);
    final overview = overviewAsync.valueOrNull;

    final sharedItems =
        overview?.items.where((i) => i.wallet.isShared).toList() ?? [];

    if (sharedItems.isNotEmpty &&
        (_selectedWalletId == null ||
            !sharedItems.any((i) => i.wallet.id == _selectedWalletId))) {
      _selectedWalletId = sharedItems.first.wallet.id;
    }

    final selectedItem = sharedItems.cast<WalletItemState?>().firstWhere(
          (i) => i?.wallet.id == _selectedWalletId,
          orElse: () => sharedItems.isNotEmpty ? sharedItems.first : null,
        );

    final notificationsAsync = ref.watch(notificationListProvider);
    final pendingInvites = notificationsAsync.valueOrNull
            ?.where((n) => n.type == NotificationType.walletInvite && !n.isRead)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(walletsOverviewProvider.future);
          if (_selectedWalletId != null) {
            await ref.refresh(walletDetailProvider(_selectedWalletId!).future);
            ref.invalidate(walletTransactionsProvider(_selectedWalletId!));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ──────────────── 1. BANNER HEADER CHUẨN HERO ────
              _buildHero(context, isDark, selectedItem, sharedItems),

              // ──────────────── LỜI MỜI THAM GIA QUỸ (Item 2) ───
              if (pendingInvites.isNotEmpty)
                _buildPendingInvitations(context, isDark, pendingInvites),

              if (selectedItem == null) ...[
                _buildEmptySharedState(context, isDark),
              ] else ...[
                // ──────────────── 2. FLOATING QUICK ACTIONS ──────
                // (Giữ nguyên chuẩn theo hình ảnh người dùng yêu cầu)
                _buildFloatingActions(context, isDark, selectedItem),

                const SizedBox(height: 18),

                // ──────────────── 3. TABS BAR (Quy chuẩn 2) ──────
                _buildTabsBar(isDark),

                const SizedBox(height: 14),

                // ──────────────── 4. TAB CONTENT ──────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCurrentTabContent(context, isDark, selectedItem),
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySharedState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có Ví chung hoặc Quỹ nhóm nào',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo quỹ nhóm để cùng bạn bè, đồng nghiệp hoặc người thân quản lý chi tiêu chung minh bạch.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(RoutePaths.createSharedWallet),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Tạo Quỹ nhóm mới',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner lời mời tham gia quỹ nhóm (Item 2)
  Widget _buildPendingInvitations(
    BuildContext context,
    bool isDark,
    List<NotificationItem> invites,
  ) {
    if (invites.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: invites.map((invite) {
          final walletId = invite.relatedEntityId ??
              invite.metadata?['walletId']?.toString();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEFF6FF), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.mail_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lời mời tham gia Quỹ nhóm',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            invite.body,
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: walletId == null
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(walletDetailActionsProvider(walletId))
                                      .rejectInvite();
                                  await ref
                                      .read(notificationListProvider.notifier)
                                      .markAsRead(invite.id);
                                  if (context.mounted) {
                                    AppToast.info(context, 'Đã từ chối lời mời');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppToast.error(context, e.toString());
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Từ chối',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: walletId == null
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(walletDetailActionsProvider(walletId))
                                      .acceptInvite();
                                  await ref
                                      .read(notificationListProvider.notifier)
                                      .markAsRead(invite.id);
                                  ref.invalidate(walletsOverviewProvider);
                                  if (context.mounted) {
                                    AppToast.success(
                                      context,
                                      'Đã tham gia quỹ nhóm thành công!',
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppToast.error(context, e.toString());
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Tham gia ngay',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Banner Header chuẩn Quy chuẩn 1 GEMINI.md (.acc-hero Solarn Gradient)
  Widget _buildHero(
    BuildContext context,
    bool isDark,
    WalletItemState? selectedItem,
    List<WalletItemState> sharedItems,
  ) {
    final title = selectedItem?.wallet.name ?? 'Chưa chọn quỹ';
    final balance = selectedItem?.balance.totalBalance ?? 0.0;
    final currency = selectedItem?.wallet.defaultCurrency ?? 'VND';

    return BannerHeader(
      title: 'Ví chung & Quỹ nhóm',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.wallets);
        }
      },
      action: BannerHeader.primaryButton(
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        onTap: () => context.push(RoutePaths.createSharedWallet),
      ),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0055A9),
          Color(0xFF0072D5),
          Color(0xFFF5B53F),
        ],
        stops: [0.0, 0.55, 1.0],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group Selector Chip
          if (sharedItems.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _showGroupSelector(context, isDark, sharedItems),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),

          // Số dư quỹ hiện tại
          Text(
            'SỐ DƯ QUỸ HIỆN TẠI',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.format(balance, currency: currency),
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 4 Nút Floating Quick Actions (Giữ nguyên chuẩn theo hình ảnh người dùng yêu cầu)
  Widget _buildFloatingActions(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    return Container(
      transform: Matrix4.translationValues(0, -18, 0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _qAction(
            isDark: isDark,
            icon: Icons.add_rounded,
            iconColor: const Color(0xFF0072D5),
            label: 'Đóng góp',
            onTap: () => context.push(
              '${RoutePaths.createTransaction}?walletId=${selectedItem.wallet.id}&type=income',
            ),
          ),
          _qAction(
            isDark: isDark,
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFFEA580C),
            label: 'Chi quỹ',
            onTap: () => context.push(
              '${RoutePaths.createTransaction}?walletId=${selectedItem.wallet.id}&type=expense',
            ),
          ),
          _qAction(
            isDark: isDark,
            icon: Icons.person_add_rounded,
            iconColor: const Color(0xFF0D9488),
            label: 'Mời bạn',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) =>
                    InviteMemberDialog(walletId: selectedItem.wallet.id),
              );
            },
          ),
          _qAction(
            isDark: isDark,
            icon: Icons.tune_rounded,
            iconColor: const Color(0xFF7C3AED),
            label: 'Cài đặt',
            onTap: () => setState(() => _activeTabIndex = 3),
          ),
        ],
      ),
    );
  }

  Widget _qAction({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkForeground
                    : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4 Tabs Bar: Nguồn tiền, Thành viên, Giao dịch, Cài đặt (Quy chuẩn 2 GEMINI.md)
  Widget _buildTabsBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabPill(0, 'Nguồn tiền', isDark),
          const SizedBox(width: 6),
          _tabPill(1, 'Thành viên', isDark),
          const SizedBox(width: 6),
          _tabPill(2, 'Giao dịch', isDark),
          const SizedBox(width: 6),
          _tabPill(3, 'Cài đặt', isDark),
        ],
      ),
    );
  }

  Widget _tabPill(int index, String title, bool isDark) {
    final isSelected = _activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground),
            ),
          ),
        ),
      ),
    );
  }

  /// Nội dung chuyển đổi theo từng tab từ dữ liệu thật API
  Widget _buildCurrentTabContent(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    switch (_activeTabIndex) {
      case 0:
        return _buildAccountsTab(context, isDark, selectedItem);
      case 1:
        return _buildMembersTab(context, isDark, selectedItem);
      case 2:
        return _buildTransactionsTab(context, isDark, selectedItem);
      case 3:
        return _buildSettingsTab(context, isDark, selectedItem);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Tab 0: Tài khoản nguồn tiền thật từ API
  Widget _buildAccountsTab(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final detailAsync = ref.watch(walletDetailProvider(selectedItem.wallet.id));
    final accounts = detailAsync.valueOrNull?.activeAccounts ?? [];
    final canManage = selectedItem.wallet.canEdit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tài khoản nguồn tiền (${accounts.length})',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              if (canManage)
                GestureDetector(
                  onTap: () => context.push(
                    '${RoutePaths.createAccount}?walletId=${selectedItem.wallet.id}',
                  ),
                  child: Text(
                    '+ Thêm tài khoản',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có tài khoản nào trong quỹ này',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canManage
                        ? 'Thêm tài khoản ngân hàng hoặc tiền mặt để bắt đầu quản lý chi tiêu chung.'
                        : 'Quỹ hiện chưa có tài khoản nguồn tiền nào.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      fontSize: 12,
                    ),
                  ),
                  if (canManage) ...[
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => context.push(
                        '${RoutePaths.createAccount}?walletId=${selectedItem.wallet.id}',
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Thêm tài khoản ngay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: accounts.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              itemBuilder: (ctx, index) {
                final acc = accounts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  onTap: () =>
                      context.push(RoutePaths.accountDetailWithId(acc.id)),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: acc.displayColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      acc.displayIcon,
                      color: acc.displayColor,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    acc.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  subtitle: Text(
                    acc.maskedNumber.isNotEmpty
                        ? '${acc.maskedNumber} · ${acc.type.displayName}'
                        : acc.type.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkMuted
                          : AppColors.lightMuted,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.format(
                          acc.balance,
                          currency: acc.currency,
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Tab 1: Thành viên thật từ API & Thống kê đóng góp, Ma trận nợ (Item 1)
  Widget _buildMembersTab(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final detailAsync = ref.watch(walletDetailProvider(selectedItem.wallet.id));
    final members = detailAsync.valueOrNull?.members ?? [];
    final isCurrentOwner =
        selectedItem.wallet.currentUserRole == WalletMemberRole.owner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thành viên quỹ (${members.length})',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) =>
                            InviteMemberDialog(walletId: selectedItem.wallet.id),
                      );
                    },
                    child: Text(
                      '+ Mời bạn bè',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (members.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Chưa có thành viên nào khác trong quỹ này.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                ...members.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final member = entry.value;
                  final isLast = idx == members.length - 1;
                  final isOwner = member.isOwner;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              isOwner ? AppColors.primary : Colors.grey.shade400,
                          child: Text(
                            member.fullName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.fullName,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member.role.displayName,
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
                        if (isOwner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              '👑 Chủ ví',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else if (isCurrentOwner)
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            onSelected: (val) {
                              if (val == 'MAKE_EDITOR') {
                                _changeRole(
                                  selectedItem.wallet.id,
                                  member,
                                  WalletMemberRole.editor,
                                );
                              } else if (val == 'MAKE_VIEWER') {
                                _changeRole(
                                  selectedItem.wallet.id,
                                  member,
                                  WalletMemberRole.viewer,
                                );
                              } else if (val == 'KICK') {
                                _confirmKick(
                                  selectedItem.wallet.id,
                                  member,
                                );
                              }
                            },
                            itemBuilder: (ctx) => [
                              if (member.role != WalletMemberRole.editor)
                                PopupMenuItem(
                                  value: 'MAKE_EDITOR',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_note_rounded,
                                          size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Đổi thành Biên tập viên',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (member.role != WalletMemberRole.viewer)
                                PopupMenuItem(
                                  value: 'MAKE_VIEWER',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.visibility_rounded,
                                          size: 18, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Đổi thành Người xem',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 'KICK',
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_remove_rounded,
                                        size: 18, color: AppColors.danger),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Xóa khỏi quỹ',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Thống kê tỷ trọng đóng góp chi tiêu (Item 1) ───────────
        _buildContributionSection(context, isDark, selectedItem),
        const SizedBox(height: 16),
        // ── Ma trận cấn trừ nợ & Quyết toán (Item 1) ──────────────
        _buildSettlementMatrixSection(context, isDark, selectedItem),
      ],
    );
  }

  /// Khối Tỷ trọng đóng góp chi tiêu thật từ Dashboard API (Item 1)
  Widget _buildContributionSection(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final dashboardAsync =
        ref.watch(dashboardSharedWalletProvider(selectedItem.wallet.id));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: dashboardAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Chưa có dữ liệu thống kê đóng góp.',
            style: GoogleFonts.inter(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              fontSize: 12.5,
            ),
          ),
        ),
        data: (dashboard) {
          final contributions = dashboard.memberContributions;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tỷ trọng đóng góp chi tiêu',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(
                      dashboard.totalSpent,
                      currency: dashboard.currency,
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tổng các khoản chi tiêu đã phát sinh của quỹ nhóm',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              const SizedBox(height: 16),
              if (contributions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Chưa có thành viên nào phát sinh chi tiêu trong quỹ này.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      fontSize: 12.5,
                    ),
                  ),
                )
              else
                ...contributions.map((c) {
                  final pct = c.percentage;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.15),
                              child: Text(
                                c.fullName.isNotEmpty
                                    ? c.fullName[0].toUpperCase()
                                    : 'U',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c.fullName,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                            ),
                            Text(
                              '${CurrencyFormatter.format(c.totalPaid, currency: dashboard.currency)} (${pct.toStringAsFixed(1)}%)',
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
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: (pct / 100).clamp(0.0, 1.0),
                            backgroundColor: isDark
                                ? AppColors.darkBorder
                                : const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  /// Khối Ma trận cấn trừ nợ & Gợi ý quyết toán (Item 1)
  Widget _buildSettlementMatrixSection(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final dashboardAsync =
        ref.watch(dashboardSharedWalletProvider(selectedItem.wallet.id));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: dashboardAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (dashboard) {
          final matrix = dashboard.settlementMatrix;
          final isBalanced =
              matrix.isBalanced || matrix.suggestedSettlements.isEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.swap_horizontal_circle_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ma trận nợ & Quyết toán',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isBalanced
                              ? AppColors.success
                              : const Color(0xFFEA580C))
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      isBalanced ? 'Đã cân bằng' : 'Cần bù trừ',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isBalanced
                            ? AppColors.success
                            : const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Thuật toán tự động tính toán số tiền tối thiểu cần thanh toán để cân bằng chi phí giữa các thành viên.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              if (isBalanced)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quỹ đã cân bằng hoàn hảo! ✨',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Không có khoản tiền nào cần bù trừ giữa các thành viên.',
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
                    ],
                  ),
                )
              else
                ...matrix.suggestedSettlements.map((s) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    s.fromUserName,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.darkForeground
                                          : AppColors.lightForeground,
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    s.toUserName,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.darkForeground
                                          : AppColors.lightForeground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.reason,
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
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(
                                s.amount,
                                currency: dashboard.currency,
                              ),
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                context.push(
                                  '${RoutePaths.createTransaction}?walletId=${selectedItem.wallet.id}&type=expense',
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Quyết toán',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  /// Tab 2: Lịch sử giao dịch thật từ API kèm Bộ lọc người chi tiêu (Item 5)
  Widget _buildTransactionsTab(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final txsAsync =
        ref.watch(walletTransactionsProvider(selectedItem.wallet.id));
    final detailAsync =
        ref.watch(walletDetailProvider(selectedItem.wallet.id));
    final members = detailAsync.valueOrNull?.members ?? [];
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: txsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Chưa thể tải giao dịch quỹ.',
              style: GoogleFonts.inter(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ),
        ),
        data: (txs) {
          if (txs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Chưa có giao dịch nào trong quỹ nhóm này.',
                  style: GoogleFonts.inter(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ),
            );
          }

          // Lọc theo người chi tiêu
          final filteredTxs = _selectedMemberFilterUserId == null
              ? txs
              : txs
                  .where((t) => t.createdBy == _selectedMemberFilterUserId)
                  .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tiêu đề & Tổng số giao dịch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch sử thu chi',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  Text(
                    '${filteredTxs.length}/${txs.length} giao dịch',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bộ lọc người chi tiêu (Quy chuẩn 2 GEMINI.md)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _memberFilterChip(
                      label: 'Tất cả (${txs.length})',
                      isSelected: _selectedMemberFilterUserId == null,
                      isDark: isDark,
                      onSelected: () =>
                          setState(() => _selectedMemberFilterUserId = null),
                    ),
                    if (currentUser != null) ...[
                      const SizedBox(width: 8),
                      _memberFilterChip(
                        label: 'Của tôi',
                        isSelected:
                            _selectedMemberFilterUserId == currentUser.id,
                        isDark: isDark,
                        onSelected: () => setState(
                            () => _selectedMemberFilterUserId = currentUser.id),
                      ),
                    ],
                    ...members
                        .where((m) => m.userId != currentUser?.id)
                        .map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _memberFilterChip(
                          label: m.fullName,
                          isSelected:
                              _selectedMemberFilterUserId == m.userId,
                          isDark: isDark,
                          onSelected: () => setState(
                              () => _selectedMemberFilterUserId = m.userId),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              const SizedBox(height: 8),

              if (filteredTxs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Không có giao dịch nào từ thành viên này.',
                      style: GoogleFonts.inter(
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                )
              else
                ...filteredTxs.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final tx = entry.value;
                  final isLast = idx == filteredTxs.length - 1;
                  final isIncome = tx.type == 'INCOME';

                  // Tìm thông tin thành viên tạo giao dịch
                  WalletMemberModel? creator;
                  if (tx.createdBy != null) {
                    for (final m in members) {
                      if (m.userId == tx.createdBy) {
                        creator = m;
                        break;
                      }
                    }
                  }

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (isIncome
                                    ? AppColors.success
                                    : AppColors.danger)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: isIncome
                                ? AppColors.success
                                : AppColors.danger,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          tx.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                        subtitle: Text(
                          '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}${creator != null ? ' · Bởi ${creator.fullName}' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: isIncome
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                    ],
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  /// Chip lọc thành viên chuẩn Quy chuẩn 2 GEMINI.md
  Widget _memberFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark
                ? AppColors.darkForeground
                : AppColors.lightForeground),
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  /// Tab 3: Cài đặt quỹ nhóm chuẩn FormCard (Quy chuẩn 3 GEMINI.md)
  Widget _buildSettingsTab(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final isCurrentOwner =
        selectedItem.wallet.currentUserRole == WalletMemberRole.owner;
    final detailAsync =
        ref.watch(walletDetailProvider(selectedItem.wallet.id));
    final otherMembers = detailAsync.valueOrNull?.members
            .where((m) => !m.isOwner)
            .toList() ??
        [];

    return FormCard(
      title: 'Cài đặt quỹ nhóm',
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (isCurrentOwner) ...[
            // 1. Đổi tên quỹ nhóm (Owner)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
              title: Text(
                'Đổi tên quỹ nhóm',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              onTap: () => _showRenameDialog(context, selectedItem),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),

            // 2. Chuyển quyền Chủ sở hữu (Owner)
            if (otherMembers.isNotEmpty) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.swap_horiz_rounded,
                    color: Color(0xFF6366F1)),
                title: Text(
                  'Chuyển quyền Chủ sở hữu',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                subtitle: Text(
                  'Bàn giao vai trò Chủ quỹ cho thành viên khác',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
                onTap: () => _showTransferOwnershipDialog(
                  context,
                  isDark,
                  selectedItem,
                  otherMembers,
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ],

            // 3. Chuyển về Ví cá nhân (Owner - Item 3)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline_rounded,
                  color: AppColors.primary),
              title: Text(
                'Chuyển về Ví cá nhân',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              subtitle: Text(
                'Tắt chế độ quỹ nhóm và thu hồi quyền truy cập của các thành viên khác',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              onTap: () => _showConvertToPersonalDialog(context, selectedItem),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),

            // 4. Giải tán / Xóa quỹ nhóm (Owner)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              title: Text(
                'Giải tán / Xóa quỹ nhóm',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                  fontSize: 13.5,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              onTap: () => _showDisbandDialog(context, selectedItem),
            ),
          ] else ...[
            // 4. Tự rời khỏi quỹ nhóm (Editor / Viewer)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: Text(
                'Rời khỏi quỹ nhóm này',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(
                'Bạn sẽ không còn quyền truy cập vào quỹ nhóm này nữa',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              onTap: () => _showLeaveDialog(context, selectedItem),
            ),
          ],
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WalletItemState selectedItem) {
    final nameCtrl = TextEditingController(text: selectedItem.wallet.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Đổi tên quỹ nhóm'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Tên quỹ mới',
            hintText: 'Nhập tên mới cho quỹ...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(walletDetailActionsProvider(selectedItem.wallet.id))
                    .updateWallet(
                      UpdateWalletRequest(name: nameCtrl.text.trim()),
                    );
                ref.invalidate(walletsOverviewProvider);
                if (mounted) {
                  AppToast.success(context, 'Đã đổi tên quỹ thành công!');
                }
              } catch (e) {
                if (mounted) AppToast.error(context, e.toString());
              }
            },
            child: const Text('LƯU'),
          ),
        ],
      ),
    );
  }

  void _showDisbandDialog(BuildContext context, WalletItemState selectedItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Giải tán quỹ nhóm?'),
        content: Text(
          'Bạn có chắc chắn muốn giải tán quỹ "${selectedItem.wallet.name}" không? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(walletDetailActionsProvider(selectedItem.wallet.id))
                    .deleteWallet();
                ref.invalidate(walletsOverviewProvider);
                if (mounted) {
                  AppToast.success(context, 'Đã giải tán quỹ nhóm!');
                  setState(() => _selectedWalletId = null);
                }
              } catch (e) {
                if (mounted) AppToast.error(context, e.toString());
              }
            },
            child: const Text(
              'XÓA QUỸ',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConvertToPersonalDialog(
    BuildContext context,
    WalletItemState selectedItem,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Chuyển thành Ví cá nhân?'),
        content: Text(
          'Khi chuyển thành Ví cá nhân, các thành viên khác sẽ không còn quyền truy cập hay theo dõi các giao dịch thuộc ví "${selectedItem.wallet.name}".\n\nBạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(walletDetailActionsProvider(selectedItem.wallet.id))
                    .updateWallet(const UpdateWalletRequest(isShared: false));
                ref.invalidate(walletsOverviewProvider);
                if (mounted) {
                  AppToast.success(
                    context,
                    'Đã chuyển thành Ví cá nhân thành công!',
                  );
                  context.go(RoutePaths.wallets);
                }
              } catch (e) {
                if (mounted) AppToast.error(context, e.toString());
              }
            },
            child: const Text(
              'XÁC NHẬN CHUYỂN',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferOwnershipDialog(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
    List<WalletMemberModel> otherMembers,
  ) {
    String? selectedNewOwnerId;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Chuyển quyền Chủ sở hữu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Chọn thành viên bạn muốn trao quyền Chủ quỹ. Sau khi chuyển giao, bạn sẽ trở thành Biên tập viên.',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedNewOwnerId,
                hint: const Text('Chọn thành viên nhận quyền...'),
                isExpanded: true,
                items: otherMembers.map((m) {
                  return DropdownMenuItem(
                    value: m.userId,
                    child: Text('${m.fullName} (${m.role.displayName})'),
                  );
                }).toList(),
                onChanged: (val) => setDlgState(() => selectedNewOwnerId = val),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('HỦY')),
            TextButton(
              onPressed: () async {
                if (selectedNewOwnerId == null) {
                  AppToast.error(
                      context, 'Vui lòng chọn thành viên nhận quyền');
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await ref
                      .read(walletDetailActionsProvider(
                          selectedItem.wallet.id))
                      .transferOwnership(selectedNewOwnerId!);
                  ref.invalidate(walletsOverviewProvider);
                  if (mounted) {
                    AppToast.success(context,
                        'Chuyển giao quyền chủ sở hữu thành công!');
                  }
                } catch (e) {
                  if (mounted) AppToast.error(context, e.toString());
                }
              },
              child: const Text(
                'XÁC NHẬN',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveDialog(
    BuildContext context,
    WalletItemState selectedItem,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rời khỏi quỹ nhóm?'),
        content: Text(
          'Bạn có chắc chắn muốn rời khỏi quỹ "${selectedItem.wallet.name}" không? Bạn sẽ cần được mời lại nếu muốn tham gia tiếp.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('HỦY')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(walletDetailActionsProvider(selectedItem.wallet.id))
                    .leaveWallet();
                ref.invalidate(walletsOverviewProvider);
                if (mounted) {
                  AppToast.success(context, 'Đã rời khỏi quỹ nhóm thành công!');
                  setState(() => _selectedWalletId = null);
                }
              } catch (e) {
                if (mounted) AppToast.error(context, e.toString());
              }
            },
            child: const Text(
              'RỜI QUỸ',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
