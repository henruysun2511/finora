import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_mascot_dialogue.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/onboarding_top_bar.dart';

/// Bước 3 Onboarding: Nguồn tiền & Số dư khởi điểm
/// Tự động tính Net Worth và xác định Linh vật AI theo nấc thang tài sản
class OnboardingWalletScreen extends ConsumerStatefulWidget {
  const OnboardingWalletScreen({super.key});

  @override
  ConsumerState<OnboardingWalletScreen> createState() =>
      _OnboardingWalletScreenState();
}

class _OnboardingWalletScreenState
    extends ConsumerState<OnboardingWalletScreen> {
  late final TextEditingController _walletNameController;
  late final TextEditingController _balanceController;

  late String _selectedType;
  late String _selectedTypeLabel;
  late double _balance;

  final _currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingControllerProvider);
    _walletNameController = TextEditingController(text: data.walletName);
    _selectedType = data.walletType;
    _selectedTypeLabel = data.walletTypeLabel;
    _balance = data.balance;
    _balanceController = TextEditingController(
      text: _currencyFormat.format(_balance.toInt()),
    );
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _updateBalance(double val) {
    setState(() {
      _balance = val;
      _balanceController.text = _currencyFormat.format(_balance.toInt());
    });
  }

  void _onNext() {
    final name = _walletNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên ví quản lý')),
      );
      return;
    }

    ref.read(onboardingControllerProvider.notifier).updateWallet(
          walletName: name,
          walletType: _selectedType,
          walletTypeLabel: _selectedTypeLabel,
          balance: _balance,
        );

    context.push(RoutePaths.onboardingMascot);
  }

  void _onSkip() {
    _updateBalance(0);
    _onNext();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tự động phân cấp linh vật theo số dư hiện tại
    final matchedMascot = MascotRegistry.resolveByBalance(_balance);
    final mascotColor = Color(
      int.parse(matchedMascot.colorHex.replaceFirst('#', '0xFF')),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const OnboardingTopBar(
        title: 'Ví & Nguồn tiền',
        step: 3,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic Dialogue
                    OnboardingMascotDialogue(
                      message:
                          'Số dư ${_currencyFormat.format(_balance.toInt())} ₫? ${matchedMascot.name} (${matchedMascot.role}) sẽ là trợ lý AI chỉ định theo cấp độ tài sản của bạn!',
                      mascot: matchedMascot,
                    ),

                    // ── 1. Tên ví quản lý ───────────────────────────────────
                    Text(
                      'Tên ví quản lý',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: TextField(
                        controller: _walletNameController,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: Ví cá nhân',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: LucideIcon(
                              name: LucideIcons.wallet,
                              size: 19,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 46,
                            minHeight: 46,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── 2. Nguồn tiền chính (2x2 Grid) ──────────────────────
                    Text(
                      'Nguồn tiền chính',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildAccountTypeCard(
                          icon: '💵',
                          type: 'cash',
                          label: 'Tiền mặt',
                          sub: 'Chi tiêu thường nhật',
                          isDark: isDark,
                        ),
                        _buildAccountTypeCard(
                          icon: '🏦',
                          type: 'bank',
                          label: 'Ngân hàng',
                          sub: 'MB, VCB, Techcom...',
                          isDark: isDark,
                        ),
                        _buildAccountTypeCard(
                          icon: '📱',
                          type: 'ewallet',
                          label: 'Ví điện tử',
                          sub: 'Momo, ZaloPay...',
                          isDark: isDark,
                        ),
                        _buildAccountTypeCard(
                          icon: '💳',
                          type: 'credit',
                          label: 'Thẻ tín dụng',
                          sub: 'Visa, Mastercard',
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── 3. Số dư hiện tại ───────────────────────────────────
                    Text(
                      'Số dư hiện tại',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '₫',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _balanceController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                              ),
                              onChanged: (text) {
                                final clean =
                                    text.replaceAll(RegExp(r'[^0-9]'), '');
                                final num = double.tryParse(clean) ?? 0;
                                setState(() {
                                  _balance = num;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickAmountChip('0 ₫', 0, isDark),
                        _buildQuickAmountChip('+1M', 1000000, isDark),
                        _buildQuickAmountChip('+5M', 5000000, isDark),
                        _buildQuickAmountChip('+20M', 20000000, isDark),
                        _buildQuickAmountChip('+100M', 100000000, isDark),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── 4. Thẻ Tier Alert (Gợi ý tự động chuẩn Finora) ───────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            mascotColor.withValues(alpha: isDark ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: mascotColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          LucideIcon(
                            name: LucideIcons.sparkles,
                            size: 18,
                            color: mascotColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: mascotColor,
                                  height: 1.35,
                                ),
                                children: [
                                  const TextSpan(text: 'Trợ lý AI chỉ định: '),
                                  TextSpan(
                                    text:
                                        '${matchedMascot.name} · ${matchedMascot.role} (${matchedMascot.range})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer Flow ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.8,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OnboardingProgressIndicator(currentStep: 3),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Text(
                            'Tiếp tục',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          const SizedBox(width: 8),
                          const LucideIcon(
                            name: LucideIcons.arrowUpRight,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Bỏ qua, nhập số dư sau',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkMuted
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String icon,
    required String type,
    required String label,
    required String sub,
    required bool isDark,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedTypeLabel = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String label, double val, bool isDark) {
    final isSelected = (_balance == val);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (selected) {
        if (selected) {
          _updateBalance(val);
        }
      },
    );
  }
}
