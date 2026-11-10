import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/current_mascot_provider.dart';
import '../providers/mascot_lineup_provider.dart';
import '../widgets/current_mascot_card.dart';
import '../widgets/mascot_lineup_list.dart';
import '../widgets/mascot_sensitivity_selector.dart';
import '../widgets/mascot_tone_selector.dart';

/// Màn hình Cài đặt Linh vật & Nhân cách AI chuẩn Solarn FinTech Style
class MascotSettingsScreen extends ConsumerStatefulWidget {
  const MascotSettingsScreen({super.key});

  @override
  ConsumerState<MascotSettingsScreen> createState() =>
      _MascotSettingsScreenState();
}

class _MascotSettingsScreenState extends ConsumerState<MascotSettingsScreen> {
  bool _isSyncing = false;

  Future<void> _handleSyncEvolution() async {
    setState(() => _isSyncing = true);
    final result =
        await ref.read(currentMascotProvider.notifier).syncEvolution();
    setState(() => _isSyncing = false);

    if (result != null && mounted) {
      if (result.evolved) {
        AppToast.show(
          context,
          message: result.message,
          type: ToastType.success,
        );
      } else {
        AppToast.show(
          context,
          message: result.message,
          type: ToastType.info,
        );
      }
    }
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mascotAsync = ref.watch(currentMascotProvider);
    final lineupAsync = ref.watch(mascotLineupProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const PageHeader.subPage(
        title: 'Linh vật & Nhân cách AI',
        subtitle: 'Tùy chỉnh trợ lý tài chính đồng hành',
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(currentMascotProvider.notifier).refresh(),
          child: mascotAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không thể tải dữ liệu linh vật: $e',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            ),
            data: (curMascot) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
                children: [
                  // ── 1. Spotlight Linh vật hiện tại ──
                  CurrentMascotCard(
                    currentMascot: curMascot,
                    isSyncing: _isSyncing,
                    onSyncEvolution: _handleSyncEvolution,
                  ),

                  const SizedBox(height: 24),

                  // ── 2. Cài đặt hiển thị linh vật (FormCard) ──
                  FormCard(
                    title: 'Cài đặt hiển thị',
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Hiển thị linh vật Finora',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      subtitle: Text(
                        curMascot.showMascot
                            ? 'Linh vật đang đồng hành và đưa ra lời khuyên'
                            : 'Đã ẩn linh vật trên giao diện ứng dụng',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                      value: curMascot.showMascot,
                      onChanged: (val) {
                        ref
                            .read(currentMascotProvider.notifier)
                            .updateShowMascot(val);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 3. Phong cách phản hồi (Mascot Tone) ──
                  _buildSectionHeader(
                    context: context,
                    title: 'Phong cách phản hồi (Tone)',
                    subtitle: 'Cách trợ lý nhận xét và đưa ra lời khuyên cho bạn',
                  ),
                  MascotToneSelector(
                    selectedTone: curMascot.mascotTone,
                    onToneChanged: (newTone) {
                      ref
                          .read(currentMascotProvider.notifier)
                          .updateTone(newTone);
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── 4. Tần suất cảnh báo (Mascot Sensitivity) ──
                  _buildSectionHeader(
                    context: context,
                    title: 'Tần suất cảnh báo',
                    subtitle: 'Mức độ nhạy khi phát hiện chi tiêu bất thường',
                  ),
                  MascotSensitivitySelector(
                    selectedSensitivity: curMascot.mascotSensitivity,
                    onSensitivityChanged: (newSensitivity) {
                      ref
                          .read(currentMascotProvider.notifier)
                          .updateSensitivity(newSensitivity);
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── 5. Tuyến linh vật 7 nấc thang tài chính ──
                  _buildSectionHeader(
                    context: context,
                    title: '7 Nấc thang tiến hóa linh vật',
                    subtitle:
                        'Linh vật tự động thăng hạng khi Tài sản ròng (Net Worth) tăng trưởng',
                  ),
                  lineupAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (tiers) => MascotLineupList(
                      tiers: tiers,
                      currentTierName: curMascot.mascot.tierName,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

