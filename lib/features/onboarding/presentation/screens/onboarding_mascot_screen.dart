import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../../../mascot/domain/models/mascot_enums.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/onboarding_top_bar.dart';

/// Bước 4 Onboarding: Gặp gỡ Trợ lý AI chỉ định & Cấu hình phong cách
/// Tuân thủ nghiệp vụ Finora: Linh vật chỉ định theo Tài sản ròng (Net Worth),
/// người dùng tùy chỉnh Giọng điệu (Tone) và Độ nhạy (Sensitivity).
class OnboardingMascotScreen extends ConsumerStatefulWidget {
  const OnboardingMascotScreen({super.key});

  @override
  ConsumerState<OnboardingMascotScreen> createState() =>
      _OnboardingMascotScreenState();
}

class _OnboardingMascotScreenState
    extends ConsumerState<OnboardingMascotScreen> {
  late MascotData _previewMascot;
  late MascotData _assignedMascot;
  late MascotTone _selectedTone;
  late MascotSensitivity _selectedSensitivity;

  final _currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingControllerProvider);
    _assignedMascot = data.assignedMascot;
    _previewMascot = _assignedMascot;
    _selectedTone = data.mascotTone;
    _selectedSensitivity = data.mascotSensitivity;
  }

  void _onNext() {
    ref.read(onboardingControllerProvider.notifier).updateMascotSettings(
          tone: _selectedTone,
          sensitivity: _selectedSensitivity,
        );

    context.push(RoutePaths.onboardingAllSet);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = ref.watch(onboardingControllerProvider);

    final mascotColor = Color(
      int.parse(_previewMascot.colorHex.replaceFirst('#', '0xFF')),
    );
    final isAssigned = (_previewMascot.id == _assignedMascot.id);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const OnboardingTopBar(
        title: 'Trợ lý AI đồng hành',
        step: 4,
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
                    // Header Subtitle
                    Text(
                      'Người đồng hành của bạn',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkForeground
                            : const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dựa trên số dư ${_currencyFormat.format(data.balance.toInt())} ₫, Finora chỉ định trợ lý phù hợp nhất:',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkMuted
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // ── 1. Spotlight Card Trợ lý AI ─────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: mascotColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: mascotColor.withValues(
                              alpha: isDark ? 0.2 : 0.08,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Badge chỉ định theo tài sản
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isAssigned
                                      ? mascotColor.withValues(alpha: 0.14)
                                      : Colors.grey.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LucideIcon(
                                      name: isAssigned
                                          ? LucideIcons.sparkles
                                          : LucideIcons.eye,
                                      size: 13,
                                      color: isAssigned
                                          ? mascotColor
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                        child: Text(
                                      isAssigned
                                          ? 'Trợ lý chỉ định theo số dư'
                                          : 'Xem trước cấp bậc',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isAssigned
                                            ? mascotColor
                                            : Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: mascotColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _previewMascot.tier,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: mascotColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Mascot Avatar & Title
                          Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: mascotColor.withValues(alpha: 0.1),
                                ),
                                child: ClipOval(
                                  child: MascotWidget(
                                    mascot: _previewMascot,
                                    mode: MascotMode.avatar,
                                    size: 68,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_previewMascot.name} (${_previewMascot.role})',
                                      style: GoogleFonts.inter(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppColors.darkForeground
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _previewMascot.range,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: mascotColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Vai trò & Tính cách
                          _buildDetailRow(
                            title: 'VAI TRÒ & TÍNH CÁCH',
                            content: _previewMascot.personality,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),

                          // Quan điểm tài chính
                          _buildDetailRow(
                            title: 'QUAN ĐIỂM TÀI CHÍNH',
                            content: _previewMascot.finance,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),

                          // Trích dẫn thoại
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              '"${_previewMascot.q1}"',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── 2. Cấu hình Phong cách giao tiếp (User Settings) ─────
                    Text(
                      'CẤU HÌNH PHONG CÁCH GIAO TIẾP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkMuted
                            : const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Giọng điệu (Mascot Tone)
                    Text(
                      'Giọng điệu phản hồi',
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
                      children: MascotTone.values.map((tone) {
                        final isSelected = _selectedTone == tone;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTone = tone),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkSurface
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tone.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tone.label,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? AppColors.darkForeground
                                                : AppColors.lightForeground),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),

                    // ── 3. Bản đồ tiến hóa 7 cấp bậc (Evolution Preview) ────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'BẢN ĐỒ TIẾN HÓA 7 CẤP BẬC',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isAssigned)
                          GestureDetector(
                            onTap: () {
                              setState(() => _previewMascot = _assignedMascot);
                            },
                            child: Text(
                              'Về linh vật của bạn',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: MascotRegistry.tiers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final m = MascotRegistry.tiers[index];
                          final isItemActive = (_previewMascot.id == m.id);
                          final isItemAssigned = (_assignedMascot.id == m.id);
                          final itemColor = Color(
                            int.parse(m.colorHex.replaceFirst('#', '0xFF')),
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() => _previewMascot = m);
                            },
                            child: Container(
                              width: 82,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isItemActive
                                    ? itemColor.withValues(
                                        alpha: isDark ? 0.25 : 0.1,
                                      )
                                    : (isDark
                                        ? AppColors.darkSurface
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isItemActive
                                      ? itemColor
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                  width: isItemActive ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: MascotWidget(
                                      mascot: m,
                                      mode: MascotMode.avatar,
                                      size: 36,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    m.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: isItemActive
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isItemActive
                                          ? itemColor
                                          : (isDark
                                              ? AppColors.darkForeground
                                              : AppColors.lightForeground),
                                    ),
                                  ),
                                  if (isItemAssigned)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'CỦA BẠN',
                                        style: TextStyle(
                                          fontSize: 7.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
                  const OnboardingProgressIndicator(currentStep: 4),
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
                            'Kích hoạt ${_assignedMascot.name} & Tiếp tục',
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

  Widget _buildDetailRow({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkMuted : const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: isDark ? AppColors.darkForeground : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
