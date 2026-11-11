import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../widgets/invite_member_dialog.dart';

/// Màn hình Ví chung & Quỹ nhóm chuẩn 1:1 theo `device-preview/screens/wallets/shared.html`
class SharedWalletsScreen extends ConsumerStatefulWidget {
  const SharedWalletsScreen({super.key});

  @override
  ConsumerState<SharedWalletsScreen> createState() => _SharedWalletsScreenState();
}

class _SharedWalletsScreenState extends ConsumerState<SharedWalletsScreen> {
  int _activeTabIndex = 0; // 0: Đóng góp, 1: Giao dịch, 2: Cài đặt
  String _selectedGroupName = '🌴 Quỹ Du lịch Đà Lạt';

  void _showGroupSelector() {
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
            _groupTile('🌴 Quỹ Du lịch Đà Lạt', '₫18,650,000 · 4 thành viên', true),
            _groupTile('🏠 Quỹ Chi tiêu Nhà trọ', '₫4,200,000 · 3 thành viên', false),
            _groupTile('⚽ Quỹ Đội bóng Finora FC', '₫1,850,000 · 11 thành viên', false),
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

  Widget _groupTile(String title, String subtitle, bool isSelected) {
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
      onTap: () {
        setState(() => _selectedGroupName = title);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ──────────────── 1. HERO SECTION ────────────────
            _buildHero(context),

            // ──────────────── 2. FLOATING QUICK ACTIONS ──────
            _buildFloatingActions(context),

            const SizedBox(height: 18),

            // ──────────────── 3. TABS BAR ─────────────────────
            _buildTabsBar(),

            const SizedBox(height: 14),

            // ──────────────── 4. TAB CONTENT ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCurrentTabContent(context, isDark),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// Banner Hero màu xanh thương hiệu Solarn & vàng kim (#0055A9 -> #0072D5 -> #F5B53F)
  Widget _buildHero(BuildContext context) {
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
          // Circular Watermark
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _showGroupSelector,
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
                              _selectedGroupName,
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
                    '₫ 18,650,000',
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Target Progress Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mục tiêu: ₫30,000,000',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            Text(
                              '62.2%',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.622,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF60A5FA), Color(0xFFFBBF24)],
                                ),
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2 Mini Summary Boxes
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'THU THÁNG NÀY',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '+₫12,000,000',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CHI THÁNG NÀY',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '-₫3,350,000',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4 Nút Thao tác nhanh Floating trên nền trắng
  Widget _buildFloatingActions(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _actionCard(
              icon: Icons.add_rounded,
              label: 'Nạp quỹ',
              colors: const [Color(0xFF0072D5), Color(0xFF0055A9)],
              onTap: () => context.push(RoutePaths.createTransaction),
            ),
            const SizedBox(width: 10),
            _actionCard(
              icon: Icons.arrow_outward_rounded,
              label: 'Rút tiền',
              colors: const [Color(0xFFEA580C), Color(0xFFC2410C)],
              onTap: () => context.push(RoutePaths.transfer),
            ),
            const SizedBox(width: 10),
            _actionCard(
              icon: Icons.call_split_rounded,
              label: 'Chia tiền',
              colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              onTap: () => context.push(RoutePaths.splitExpenses),
            ),
            const SizedBox(width: 10),
            _actionCard(
              icon: Icons.person_add_rounded,
              label: 'Mời bạn',
              colors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const InviteMemberDialog(walletId: 'shared-dalat'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 7),
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

  /// 3 Tabs Bar (Đóng góp / Giao dịch / Cài đặt)
  Widget _buildTabsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabPill(0, 'Đóng góp'),
          const SizedBox(width: 8),
          _tabPill(1, 'Giao dịch'),
          const SizedBox(width: 8),
          _tabPill(2, 'Cài đặt'),
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
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  /// Nội dung chuyển đổi theo từng tab
  Widget _buildCurrentTabContent(BuildContext context, bool isDark) {
    switch (_activeTabIndex) {
      case 0:
        return _buildContributionsTab(context, isDark);
      case 1:
        return _buildTransactionsTab(context, isDark);
      case 2:
        return _buildSettingsTab(context, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Tab 1: Đóng góp thành viên & Giao dịch gần đây
  Widget _buildContributionsTab(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Column(
      children: [
        // CARD 1: Đóng góp thành viên (4)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đóng góp thành viên (4)',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  Text(
                    'Chi tiết',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Thành viên 1: Hoàng Long (Trưởng quỹ - Crown)
              _memberRow(
                initial: 'HL',
                bgColor: const Color(0xFF0072D5),
                name: 'Hoàng Long',
                roleBadge: 'Trưởng quỹ',
                roleIcon: '👑',
                amount: '₫8,000,000',
                percent: '42.9%',
                isDark: isDark,
              ),
              // Thành viên 2: Thu Hà (Thủ quỹ - Shield)
              _memberRow(
                initial: 'TH',
                bgColor: const Color(0xFFEA580C),
                name: 'Thu Hà',
                roleBadge: 'Thủ quỹ',
                roleIcon: '🛡️',
                amount: '₫5,500,000',
                percent: '29.5%',
                isDark: isDark,
              ),
              // Thành viên 3: Minh Quân (Thành viên)
              _memberRow(
                initial: 'MQ',
                bgColor: const Color(0xFF7C3AED),
                name: 'Minh Quân',
                roleBadge: 'Thành viên',
                roleIcon: '👤',
                amount: '₫3,000,000',
                percent: '16.1%',
                isDark: isDark,
              ),
              // Thành viên 4: Bạn (Tôi)
              _memberRow(
                initial: 'Tôi',
                bgColor: const Color(0xFF0D9488),
                name: 'Bạn (Tôi)',
                roleBadge: 'Thành viên',
                roleIcon: '👤',
                amount: '₫2,150,000',
                percent: '11.5%',
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // CARD 2: Giao dịch gần đây
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch gần đây',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _activeTabIndex = 1),
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _recentTxRow(
                icon: Icons.flight_takeoff_rounded,
                iconColor: const Color(0xFFEC4899),
                title: 'Vé máy bay khứ hồi SGN-DLI',
                meta: 'Minh Quân chi · 18/08',
                amount: '-₫4,800,000',
                isExpense: true,
              ),
              const SizedBox(height: 10),
              _recentTxRow(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.success,
                title: 'Thu Hà nạp tiền quỹ tháng 8',
                meta: 'Thu Hà nạp · 15/08',
                amount: '+₫2,500,000',
                isExpense: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _memberRow({
    required String initial,
    required Color bgColor,
    required String name,
    required String roleBadge,
    required String roleIcon,
    required String amount,
    required String percent,
    required bool isDark,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: bgColor,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(roleIcon, style: const TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  roleBadge,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              Text(
                percent,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentTxRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String meta,
    required String amount,
    required bool isExpense,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
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
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                meta,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: isExpense ? AppColors.danger : AppColors.success,
          ),
        ),
      ],
    );
  }

  /// Tab 2: Lịch sử tất cả giao dịch nhóm
  Widget _buildTransactionsTab(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _recentTxRow(
            icon: Icons.flight_takeoff_rounded,
            iconColor: const Color(0xFFEC4899),
            title: 'Vé máy bay khứ hồi SGN-DLI',
            meta: 'Minh Quân chi · 18/08 · 14:20',
            amount: '-₫4,800,000',
            isExpense: true,
          ),
          const Divider(height: 20),
          _recentTxRow(
            icon: Icons.hotel_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Đặt cọc Villa Đà Lạt Garden',
            meta: 'Hoàng Long chi · 16/08 · 09:15',
            amount: '-₫3,000,000',
            isExpense: true,
          ),
          const Divider(height: 20),
          _recentTxRow(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.success,
            title: 'Thu Hà nạp tiền quỹ tháng 8',
            meta: 'Thu Hà nạp · 15/08 · 16:30',
            amount: '+₫2,500,000',
            isExpense: false,
          ),
        ],
      ),
    );
  }

  /// Tab 3: Cài đặt quỹ nhóm
  Widget _buildSettingsTab(BuildContext context, bool isDark) {
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            title: const Text('Đổi tên quỹ nhóm', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_selectedGroupName),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_rounded, color: Color(0xFFF59E0B)),
            title: const Text('Mục tiêu số dư', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('₫30,000,000 VND'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.qr_code_rounded, color: Color(0xFF0D9488)),
            title: const Text('Mã mời tham gia', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('DALAT2026 · Nhấn để sao chép'),
            trailing: const Icon(Icons.copy_rounded, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép mã mời DALAT2026')),
              );
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.exit_to_app_rounded, color: AppColors.danger),
            title: const Text('Rời khỏi quỹ nhóm', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Rời quỹ nhóm?'),
                  content: const Text('Bạn sẽ không còn theo dõi dòng tiền chung của nhóm này nữa.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.pop();
                      },
                      child: const Text('Rời nhóm', style: TextStyle(color: AppColors.danger)),
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
