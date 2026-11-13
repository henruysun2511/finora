import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../accounts/domain/models/account_model.dart';
import '../../../../core/widgets/page_header.dart';
import '../../data/dto/update_wallet_request.dart';
import '../providers/wallet_detail_provider.dart';
import '../providers/wallets_overview_provider.dart';

/// Màn hình Chi tiết ví & Tài khoản chuẩn 1:1 theo `device-preview/screens/wallets/detail.html`
/// 100% kết nối API thật, loại bỏ hoàn toàn mock data
class WalletDetailScreen extends ConsumerStatefulWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  Future<void> _syncWallet(BuildContext context) async {
    try {
      await ref.refresh(walletDetailProvider(widget.walletId).future);
      ref.invalidate(walletsOverviewProvider);
      ref.invalidate(walletTransactionsProvider(widget.walletId));
      if (mounted) {
        AppToast.success(context, 'Đã đồng bộ số dư ví thành công!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    }
  }

  void _confirmToggleShared(
    BuildContext context,
    bool enableShared,
    String walletName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          enableShared ? 'Chuyển thành Ví chung?' : 'Chuyển về Ví cá nhân?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          enableShared
              ? 'Bạn có muốn chuyển ví "$walletName" thành Ví chung để mời bạn bè, người thân cùng quản lý thu chi không? Sau khi chuyển, ví sẽ xuất hiện trong mục Ví chung & Quỹ nhóm.'
              : 'Bạn có chắc chắn muốn chuyển ví "$walletName" về ví cá nhân không? Các thành viên khác sẽ không thể tiếp tục truy cập ví này.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.4),
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
                    .read(walletDetailActionsProvider(widget.walletId))
                    .updateWallet(UpdateWalletRequest(isShared: enableShared));
                ref.invalidate(walletsOverviewProvider);
                if (mounted) {
                  AppToast.success(
                    context,
                    enableShared
                        ? 'Đã chuyển ví thành Ví chung thành công!'
                        : 'Đã chuyển ví về Ví cá nhân!',
                  );
                  if (enableShared) {
                    context.push(RoutePaths.sharedWallets);
                  }
                }
              } catch (e) {
                if (mounted) {
                  AppToast.error(context, e.toString());
                }
              }
            },
            child: Text(
              'XÁC NHẬN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: enableShared ? AppColors.primary : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveWallet(
    BuildContext context,
    String walletName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Rời khỏi ví chung?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc chắn muốn rời khỏi ví "$walletName" không? Bạn sẽ không còn quyền truy cập hay theo dõi các giao dịch thuộc ví này nữa.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.4),
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
                    .read(walletDetailActionsProvider(widget.walletId))
                    .leaveWallet();
                ref.invalidate(walletsOverviewProvider);
                if (mounted) {
                  AppToast.success(
                    context,
                    'Đã rời khỏi ví chung thành công!',
                  );
                  context.go(RoutePaths.wallets);
                }
              } catch (e) {
                if (mounted) {
                  AppToast.error(context, e.toString());
                }
              }
            },
            child: const Text(
              'RỜI VÍ',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(walletDetailProvider(widget.walletId));
    final walletDetail = detailAsync.valueOrNull;

    final walletName = walletDetail?.wallet.name ??
        (detailAsync.isLoading ? 'Đang tải ví...' : 'Chi tiết ví');
    final balance = walletDetail?.balance.availableBalance ?? 0.0;
    final currency = walletDetail?.wallet.defaultCurrency ?? 'VND';
    final isMain = walletDetail?.wallet.isShared != true;

    final last4 = (walletDetail != null &&
            walletDetail.activeAccounts.isNotEmpty &&
            walletDetail.activeAccounts.first.accountNumberLast4 != null)
        ? '•••• ${walletDetail.activeAccounts.first.accountNumberLast4}'
        : 'FINORA DIGITAL';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: PageHeader.subPage(
        title: walletName,
        subtitle: isMain ? 'Ví cá nhân' : 'Ví dùng chung',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.wallets);
          }
        },
        action: walletDetail == null
            ? null
            : PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? AppColors.darkSurface : Colors.white,
                onSelected: (val) {
                  if (val == 'TOGGLE_SHARED') {
                    _confirmToggleShared(
                      context,
                      !walletDetail.isShared,
                      walletDetail.wallet.name,
                    );
                  } else if (val == 'OPEN_SHARED') {
                    context.push(RoutePaths.sharedWallets);
                  } else if (val == 'SYNC') {
                    _syncWallet(context);
                  } else if (val == 'LEAVE') {
                    _confirmLeaveWallet(context, walletDetail.wallet.name);
                  }
                },
                itemBuilder: (ctx) => [
                  if (walletDetail.isOwner && !walletDetail.isShared)
                    PopupMenuItem(
                      value: 'TOGGLE_SHARED',
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Chuyển thành Ví chung',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (walletDetail.isShared)
                    PopupMenuItem(
                      value: 'OPEN_SHARED',
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded,
                              size: 18, color: Color(0xFF0D9488)),
                          const SizedBox(width: 8),
                          Text(
                            'Mở mục Ví chung & Quỹ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'SYNC',
                    child: Row(
                      children: [
                        const Icon(Icons.sync_rounded,
                            size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          'Đồng bộ số dư ví',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!walletDetail.isOwner && walletDetail.isShared)
                    PopupMenuItem(
                      value: 'LEAVE',
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded,
                              size: 18, color: AppColors.danger),
                          const SizedBox(width: 8),
                          Text(
                            'Rời khỏi ví này',
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
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(walletDetailProvider(widget.walletId).future);
            ref.invalidate(walletTransactionsProvider(widget.walletId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ──────────────── 1. BANK CARD HERO ─────────────────────
                _buildBankCardHero(
                  walletName: walletName,
                  balance: balance,
                  currency: currency,
                  isMain: isMain,
                  last4: last4,
                ),

                const SizedBox(height: 16),

                // ──────────────── 3. QUICK ACTIONS GRID ─────────────────
                _buildQuickActions(context),

                const SizedBox(height: 20),

                // ──────────────── 4. ACCOUNTS IN WALLET ─────────────────
                _buildAccountsList(
                  context,
                  isDark,
                  walletDetail?.activeAccounts ?? [],
                ),

                const SizedBox(height: 20),

                // ──────────────── 5. CÀI ĐẶT VÍ (FormCard Quy chuẩn 3 GEMINI.md) ────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FormCard(
                    title: 'CÀI ĐẶT VÍ & CHIA SẺ',
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Chuyển thành Ví chung (Quỹ nhóm)',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          subtitle: Text(
                            (walletDetail?.isShared ?? false)
                                ? 'Ví đang là Ví chung. Bạn có thể mời bạn bè và thành viên cùng quản lý.'
                                : 'Bật để mời bạn bè cùng quản lý thu chi, phân quyền và theo dõi đóng góp quỹ.',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          value: walletDetail?.isShared ?? false,
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          trackOutlineColor:
                              WidgetStateProperty.all(Colors.transparent),
                          onChanged: walletDetail == null || !walletDetail.isOwner
                              ? null
                              : (val) => _confirmToggleShared(
                                    context,
                                    val,
                                    walletDetail.wallet.name,
                                  ),
                        ),
                        if (walletDetail != null &&
                            !walletDetail.isOwner &&
                            walletDetail.isShared) ...[
                          Divider(
                            height: 1,
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.logout_rounded,
                                color: AppColors.danger),
                            title: Text(
                              'Rời khỏi ví chung này',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                            ),
                            subtitle: Text(
                              'Bạn sẽ không còn quyền truy cập vào ví này nữa',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                            onTap: () => _confirmLeaveWallet(
                              context,
                              walletDetail.wallet.name,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ──────────────── 6. TRANSACTION HISTORY ────────────────
                _buildTransactionHistory(context, isDark),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// Thẻ Bank Card Hero chuẩn Solarn Blue
  Widget _buildBankCardHero({
    required String walletName,
    required double balance,
    required String currency,
    required bool isMain,
    required String last4,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0072D5),
            Color(0xFF0055A9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072D5).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        walletName,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (isMain)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Ví chính',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'SỐ DƯ KHẢ DỤNG',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(balance, currency: currency),
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHỦ VÍ',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          walletName.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      last4,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: Colors.white,
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
  }

  /// 3 Nút Quick Actions: Ghi sổ GD, Chuyển tiền, Đồng bộ
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _actionTile(
            icon: Icons.add_rounded,
            label: 'Ghi sổ GD',
            bgColor: const Color(0xFF0072D5).withValues(alpha: 0.12),
            iconColor: const Color(0xFF0072D5),
            onTap: () => context.push(RoutePaths.createTransaction),
          ),
          const SizedBox(width: 12),
          _actionTile(
            icon: Icons.swap_horiz_rounded,
            label: 'Chuyển tiền',
            bgColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
            iconColor: const Color(0xFF0D9488),
            onTap: () => context.push(
              '${RoutePaths.transfer}?fromWalletId=${widget.walletId}',
            ),
          ),
          const SizedBox(width: 12),
          _actionTile(
            icon: Icons.sync_rounded,
            label: 'Đồng bộ',
            bgColor: AppColors.success.withValues(alpha: 0.12),
            iconColor: AppColors.success,
            onTap: () => _syncWallet(context),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsList(
    BuildContext context,
    bool isDark,
    List<AccountModel> accounts,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tài khoản nguồn tiền (${accounts.length})',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('${RoutePaths.createAccount}?walletId=${widget.walletId}'),
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
          const SizedBox(height: 10),
          if (accounts.isEmpty)
            InkWell(
              onTap: () => context.push('${RoutePaths.createAccount}?walletId=${widget.walletId}'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.primary, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có tài khoản nào trong ví này',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bấm để thêm tài khoản ngân hàng hoặc tiền mặt',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            Material(
              color: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: accounts.map((acc) {
                  return ListTile(
                    onTap: () => context.push(RoutePaths.accountDetailWithId(acc.id)),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        acc.type.isEWallet
                            ? Icons.smartphone_rounded
                            : (acc.type.isCash
                                ? Icons.account_balance_wallet_rounded
                                : Icons.account_balance_rounded),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      acc.name,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      acc.accountNumberLast4 != null
                          ? '•••• ${acc.accountNumberLast4} · ${acc.type.displayName}'
                          : acc.type.displayName,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.format(acc.balance, currency: acc.currency),
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  /// Lịch sử giao dịch thật từ API
  Widget _buildTransactionHistory(BuildContext context, bool isDark) {
    final txsAsync = ref.watch(walletTransactionsProvider(widget.walletId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử giao dịch ví',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RoutePaths.transactions),
                child: Text(
                  'Xem tất cả',
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
          txsAsync.when(
            loading: () => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
              ),
            ),
            error: (err, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chưa thể tải lịch sử giao dịch',
                      style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            data: (txs) {
              if (txs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có giao dịch nào trong ví này',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: txs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final tx = entry.value;
                    final isIncome = tx.type == 'INCOME';
                    final isLast = idx == txs.length - 1;
                    final dateStr =
                        '${tx.transactionDate.day.toString().padLeft(2, '0')}/${tx.transactionDate.month.toString().padLeft(2, '0')} · ${tx.transactionDate.hour.toString().padLeft(2, '0')}:${tx.transactionDate.minute.toString().padLeft(2, '0')}';

                    return _txItem(
                      icon: isIncome ? Icons.arrow_downward_rounded : Icons.shopping_bag_rounded,
                      iconBg: (isIncome ? AppColors.success : const Color(0xFFF43F5E))
                          .withValues(alpha: 0.12),
                      iconColor: isIncome ? AppColors.success : const Color(0xFFF43F5E),
                      title: tx.title,
                      meta: dateStr,
                      amount: '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                      amountColor: isIncome ? AppColors.success : AppColors.danger,
                      isDark: isDark,
                      hasBorder: !isLast,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _txItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String meta,
    required String amount,
    required Color amountColor,
    required bool isDark,
    required bool hasBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: hasBorder
            ? const Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
