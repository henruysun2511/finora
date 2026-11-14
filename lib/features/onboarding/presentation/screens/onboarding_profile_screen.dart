import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_mascot_dialogue.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/onboarding_top_bar.dart';

/// Bước 2 Onboarding: Thiết lập hồ sơ cá nhân
/// Đồng bộ 100% với static-ui/device-preview/screens/onboarding/setup-profile.html
class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState
    extends ConsumerState<OnboardingProfileScreen> {
  late final TextEditingController _nameController;
  late String _selectedLanguage;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingControllerProvider);
    _nameController = TextEditingController(text: data.name);
    _selectedLanguage = data.language;
    _selectedCurrency = data.currency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNext() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên của bạn')),
      );
      return;
    }

    ref.read(onboardingControllerProvider.notifier).updateProfile(
          name: name,
          language: _selectedLanguage,
          currency: _selectedCurrency,
        );

    context.push(RoutePaths.onboardingWallet);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const OnboardingTopBar(
        title: 'Thiết lập hồ sơ',
        step: 2,
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
                    // Nora Dialogue
                    const OnboardingMascotDialogue(
                      message:
                          'Cho mình biết tên để chúng mình dễ xưng hô và cá nhân hóa tư vấn nhé! 💙',
                    ),

                    // ── 1. Tên của bạn ──────────────────────────────────────
                    Text(
                      'Tên của bạn',
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
                        controller: _nameController,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: Nguyễn Minh',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: LucideIcon(
                              name: LucideIcons.user,
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

                    // ── 2. Ngôn ngữ hiển thị ────────────────────────────────
                    Text(
                      'Ngôn ngữ hiển thị',
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : const Color(0xFFF1F5F9),
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
                            child: _buildSegButton(
                              label: '🇻🇳 Tiếng Việt',
                              isActive: _selectedLanguage == 'vi',
                              onTap: () =>
                                  setState(() => _selectedLanguage = 'vi'),
                              isDark: isDark,
                            ),
                          ),
                          Expanded(
                            child: _buildSegButton(
                              label: '🇬🇧 English',
                              isActive: _selectedLanguage == 'en',
                              onTap: () =>
                                  setState(() => _selectedLanguage = 'en'),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── 3. Đơn vị tiền tệ chính ─────────────────────────────
                    Text(
                      'Đơn vị tiền tệ chính',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCurrencyCard(
                            flag: '🇻🇳',
                            code: 'VND (₫)',
                            label: 'Đồng Việt Nam',
                            isSelected: _selectedCurrency == 'VND',
                            onTap: () =>
                                setState(() => _selectedCurrency = 'VND'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCurrencyCard(
                            flag: '🇺🇸',
                            code: 'USD (\$)',
                            label: 'Đô la Mỹ',
                            isSelected: _selectedCurrency == 'USD',
                            onTap: () =>
                                setState(() => _selectedCurrency = 'USD'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Ngoại tệ khác
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCurrencyChip('EUR', '🇪🇺 EUR (€)', isDark),
                        _buildCurrencyChip('JPY', '🇯🇵 JPY (¥)', isDark),
                        _buildCurrencyChip('SGD', '🇸🇬 SGD (\$)', isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer Flow ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                  const OnboardingProgressIndicator(currentStep: 2),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkForeground
                      : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyCard({
    required String flag,
    required String code,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              code,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyChip(String code, String label, bool isDark) {
    final isSelected = _selectedCurrency == code;
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
          setState(() => _selectedCurrency = code);
        }
      },
    );
  }
}
