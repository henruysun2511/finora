import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/current_mascot_provider.dart';
import '../widgets/mascot_profile_detail_panel.dart';

/// Màn hình giới thiệu chi tiết 7 Linh vật AI Finora
/// Tham khảo giao diện trực tiếp từ `static-ui/ai-mascot/index.html`
/// Hỗ trợ tương tác Master-Detail: Click card linh vật phía trên để xem chi tiết Profile bên dưới.
class MascotShowcaseScreen extends ConsumerStatefulWidget {
  const MascotShowcaseScreen({super.key, this.initialMascotId});

  final String? initialMascotId;

  @override
  ConsumerState<MascotShowcaseScreen> createState() =>
      _MascotShowcaseScreenState();
}

class _MascotShowcaseScreenState extends ConsumerState<MascotShowcaseScreen> {
  late String _selectedMascotId;
  final List<MascotData> _mascots = MascotRegistry.tiers;

  @override
  void initState() {
    super.initState();
    _selectedMascotId = widget.initialMascotId ?? 'nora';
  }

  void _selectMascot(String id) {
    setState(() => _selectedMascotId = id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMascotAsync = ref.watch(currentMascotProvider);
    final currentTierName =
        currentMascotAsync.valueOrNull?.mascot.tierName.toLowerCase();

    final selectedMascot = MascotRegistry.get(_selectedMascotId);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const PageHeader.subPage(
        title: 'Linh vật AI Finora',
        subtitle: 'Khám phá 7 phong cách tài chính cá nhân hóa',
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Hero Intro Banner ──
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E293B),
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFFEFF6FF),
                            const Color(0xFFDBEAFE),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const LucideIcon(
                        name: 'sparkles',
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HỆ THỐNG TIẾN HÓA LINH VẬT',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mỗi mốc Tài sản ròng (Net Worth) sở hữu một linh vật với nhân sinh quan và phương pháp tư vấn riêng.',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 2. Header Danh sách Cards ──
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'CHỌN LINH VẬT ĐỂ XEM CHI TIẾT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_mascots.length} linh vật',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3. Multi-line Cards Wrap (Xuống dòng được, tự co giãn theo màn hình) ──
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = (constraints.maxWidth > 520)
                      ? 4
                      : (constraints.maxWidth > 330 ? 3 : 2);
                  const spacing = 10.0;
                  final totalSpacing = (crossAxisCount - 1) * spacing;
                  final cardWidth =
                      ((constraints.maxWidth - totalSpacing) / crossAxisCount)
                          .floorToDouble();

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: _mascots.map((mascot) {
                      final isSelected = mascot.id == _selectedMascotId;
                      final isCurrentCompanion =
                          mascot.id.toLowerCase() == currentTierName;

                      return GestureDetector(
                        onTap: () => _selectMascot(mascot.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: cardWidth,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? mascot.color
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? mascot.color.withValues(alpha: 0.25)
                                    : Colors.black.withValues(
                                        alpha: isDark ? 0.2 : 0.04),
                                blurRadius: isSelected ? 12 : 6,
                                offset: Offset(0, isSelected ? 4 : 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Current Tag
                              if (isCurrentCompanion)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ĐỒNG HÀNH',
                                    style: GoogleFonts.inter(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 18),

                              // Mascot Avatar SVG
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: MascotWidget(
                                  mascotId: mascot.id,
                                  mode: MascotMode.avatar,
                                  size: 54,
                                  float: isSelected,
                                  interactive: false,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Tên & Tier (Hỗ trợ xuống dòng mềm mại)
                              Text(
                                mascot.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mascot.range,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: mascot.color,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Indicator bar dưới đáy khi active
                              Container(
                                width: isSelected ? 28 : 0,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: mascot.color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── 4. Profile Detail Panel (Theo mẫu .profile trong index.html) ──
              MascotProfileDetailPanel(
                mascot: selectedMascot,
                isCurrentCompanion:
                    selectedMascot.id.toLowerCase() == currentTierName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

