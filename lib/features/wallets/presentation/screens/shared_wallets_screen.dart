import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/dto/update_wallet_request.dart';
import '../providers/wallet_detail_provider.dart';
import '../providers/wallets_overview_provider.dart';
import '../widgets/invite_member_dialog.dart';

/// Màn hình Ví chung & Quỹ nhóm chuẩn 1:1 theo `device-preview/screens/wallets/shared.html`
/// 100% kết nối API thật, loại bỏ hoàn toàn mock data
class SharedWalletsScreen extends ConsumerStatefulWidget {
  const SharedWalletsScreen({super.key});

  @override
  ConsumerState<SharedWalletsScreen> createState() => _SharedWalletsScreenState();
}

class _SharedWalletsScreenState extends ConsumerState<SharedWalletsScreen> {
  int _activeTabIndex = 0; // 0: Đóng góp, 1: Giao dịch, 2: Cài đặt
  String? _selectedWalletId;

  void _showGroupSelector(List<WalletItemState> sharedItems) {
    showModalBottomSheet(
      context: context,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn Quỹ nhóm / Ví chung',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            if (sharedItems.isNotEmpty)
              ...sharedItems.map((item) {
                final isSelected = item.wallet.id == _selectedWalletId;
                return _groupTile(
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Bạn chưa có ví chung hoặc quỹ nhóm nào.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                context.push(RoutePaths.createWallet);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tạo thêm quỹ nhóm mới'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupTile(String title, String subtitle, bool isSelected, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.groups_rounded,
          color: isSelected ? AppColors.primary : Colors.grey.shade600,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
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
              // ──────────────── 1. HERO SECTION ────────────────
              _buildHero(context, selectedItem, sharedItems),

              if (selectedItem == null) ...[
                _buildEmptySharedState(context, isDark),
              ] else ...[
                // ──────────────── 2. FLOATING QUICK ACTIONS ──────
                _buildFloatingActions(context, selectedItem),

                const SizedBox(height: 18),

                // ──────────────── 3. TABS BAR ─────────────────────
                _buildTabsBar(),

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
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo quỹ nhóm để cùng bạn bè, đồng nghiệp hoặc người thân quản lý chi tiêu chung minh bạch.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(RoutePaths.createWallet),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Tạo Quỹ nhóm mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner Hero màu xanh thương hiệu Solarn & vàng kim (#0055A9 -> #0072D5 -> #F5B53F)
  Widget _buildHero(
    BuildContext context,
    WalletItemState? selectedItem,
    List<WalletItemState> sharedItems,
  ) {
    final title = selectedItem?.wallet.name ?? 'Chưa chọn quỹ';
    final balance = selectedItem?.balance.totalBalance ?? 0.0;
    final currency = selectedItem?.wallet.defaultCurrency ?? 'VND';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0055A9),
            Color(0xFF0072D5),
            Color(0xFFF5B53F),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Nav Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RoutePaths.wallets);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'Ví chung & Quỹ nhóm',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RoutePaths.createWallet),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Group Selector Chip
                  if (sharedItems.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => _showGroupSelector(sharedItems),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            ),
          ),
        ],
      ),
    );
  }

  /// 4 Nút Floating Quick Actions
  Widget _buildFloatingActions(BuildContext context, WalletItemState selectedItem) {
    return Container(
      transform: Matrix4.translationValues(0, -18, 0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _qAction(
            icon: Icons.add_rounded,
            iconColor: const Color(0xFF0072D5),
            label: 'Đóng góp',
            onTap: () => context.push(RoutePaths.createTransaction),
          ),
          _qAction(
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFFEA580C),
            label: 'Chi quỹ',
            onTap: () => context.push(RoutePaths.createTransaction),
          ),
          _qAction(
            icon: Icons.person_add_rounded,
            iconColor: const Color(0xFF0D9488),
            label: 'Mời bạn',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => InviteMemberDialog(walletId: selectedItem.wallet.id),
              );
            },
          ),
          _qAction(
            icon: Icons.tune_rounded,
            iconColor: const Color(0xFF7C3AED),
            label: 'Cài đặt',
            onTap: () => setState(() => _activeTabIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _qAction({
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
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3 Tabs Bar: Đóng góp, Giao dịch, Cài đặt
  Widget _buildTabsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabPill(0, 'Thành viên & Đóng góp'),
          const SizedBox(width: 8),
          _tabPill(1, 'Giao dịch quỹ'),
          const SizedBox(width: 8),
          _tabPill(2, 'Cài đặt quỹ'),
        ],
      ),
    );
  }

  Widget _tabPill(int index, String title) {
    final isSelected = _activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
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
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
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
        return _buildMembersTab(context, isDark, selectedItem);
      case 1:
        return _buildTransactionsTab(context, isDark, selectedItem);
      case 2:
        return _buildSettingsTab(context, isDark, selectedItem);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Tab 1: Thành viên thật từ API
  Widget _buildMembersTab(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final detailAsync = ref.watch(walletDetailProvider(selectedItem.wallet.id));
    final members = detailAsync.valueOrNull?.members ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => InviteMemberDialog(walletId: selectedItem.wallet.id),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Chưa có thành viên nào khác trong quỹ này.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
                  border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isOwner ? AppColors.primary : Colors.grey.shade400,
                      child: Text(
                        member.fullName.isNotEmpty
                            ? member.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.role.displayName,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text('👑 Chủ ví', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Tab 2: Lịch sử giao dịch thật từ API
  Widget _buildTransactionsTab(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    final txsAsync = ref.watch(walletTransactionsProvider(selectedItem.wallet.id));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: txsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ),
        ),
        error: (_, __) => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Chưa thể tải giao dịch quỹ.', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ),
        data: (txs) {
          if (txs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Chưa có giao dịch nào trong quỹ nhóm này.', style: TextStyle(color: Color(0xFF64748B))),
              ),
            );
          }
          return Column(
            children: txs.asMap().entries.map((entry) {
              final tx = entry.value;
              final isIncome = tx.type == 'INCOME';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isIncome ? AppColors.success : AppColors.danger).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isIncome ? AppColors.success : AppColors.danger,
                    size: 18,
                  ),
                ),
                title: Text(tx.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
                subtitle: Text(
                  '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
                trailing: Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isIncome ? AppColors.success : AppColors.danger,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// Tab 3: Cài đặt quỹ nhóm thật
  Widget _buildSettingsTab(
    BuildContext context,
    bool isDark,
    WalletItemState selectedItem,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
            title: const Text('Đổi tên quỹ nhóm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 18),
            onTap: () {
              final nameCtrl = TextEditingController(text: selectedItem.wallet.name);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Đổi tên quỹ nhóm'),
                  content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên quỹ mới')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref.read(walletDetailActionsProvider(selectedItem.wallet.id)).updateWallet(
                              UpdateWalletRequest(name: nameCtrl.text.trim()),
                            );
                        ref.invalidate(walletsOverviewProvider);
                        if (mounted) AppToast.success(context, 'Đã đổi tên quỹ thành công!');
                      },
                      child: const Text('LƯU'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            title: const Text('Giải tán / Xóa quỹ nhóm', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13.5)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 18),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Giải tán quỹ nhóm?'),
                  content: Text('Bạn có chắc chắn muốn giải tán quỹ "${selectedItem.wallet.name}" không?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref.read(walletDetailActionsProvider(selectedItem.wallet.id)).deleteWallet();
                        ref.invalidate(walletsOverviewProvider);
                        if (mounted) {
                          AppToast.success(context, 'Đã giải tán quỹ nhóm!');
                          setState(() => _selectedWalletId = null);
                        }
                      },
                      child: const Text('XÓA QUỸ', style: TextStyle(color: AppColors.danger)),
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
}
