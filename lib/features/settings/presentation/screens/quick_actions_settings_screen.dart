import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../home/domain/models/quick_action_item_model.dart';
import '../../../home/presentation/providers/quick_actions_provider.dart';

/// Màn hình tùy chỉnh thanh Thao tác nhanh trên Trang chủ
/// Chuẩn FinTech Design System (GEMINI.md)
class QuickActionsSettingsScreen extends ConsumerWidget {
  const QuickActionsSettingsScreen({super.key});

  String _getGroupName(QuickActionGroup group) {
    switch (group) {
      case QuickActionGroup.transaction:
        return 'Giao dịch thu chi';
      case QuickActionGroup.planning:
        return 'Kế hoạch & Sổ sách';
      case QuickActionGroup.management:
        return 'Báo cáo & Danh mục';
      case QuickActionGroup.social:
        return 'Cộng đồng & Tin nhắn';
      case QuickActionGroup.extended:
        return 'Tiện ích mở rộng';
    }
  }

  Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Khôi phục mặc định?',
      message:
          'Toàn bộ danh sách thao tác nhanh sẽ được thiết lập lại về 12 tiện ích tiêu chuẩn ban đầu.',
      confirmText: 'Khôi phục',
      cancelText: 'Hủy',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(quickActionsProvider.notifier).resetToDefault();
      if (context.mounted) {
        AppToast.success(context, 'Đã khôi phục danh sách tiện ích mặc định!');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncState = ref.watch(quickActionsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Tùy chỉnh thao tác nhanh',
        subtitle: 'Chọn và sắp xếp các tiện ích hiển thị trên trang chủ',
        action: IconButton(
          icon: const Icon(Icons.restart_alt_rounded),
          tooltip: 'Khôi phục mặc định',
          onPressed: () => _handleReset(context, ref),
        ),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Không thể tải cài đặt: $err',
            style: TextStyle(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
        ),
        data: (state) {
          final enabled = state.enabledItems;
          final disabled = state.disabledItems;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // ── 1. KHỐI XEM TRƯỚC TRÊN TRANG CHỦ ─────────────────────────
              FormCard(
                title: 'Xem trước trên trang chủ (${enabled.length} tiện ích)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thứ tự dưới đây sẽ tương ứng với giao diện trên màn hình chính của bạn.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Lưới preview thu nhỏ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: enabled.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.92,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 4,
                        ),
                        itemBuilder: (context, index) {
                          final item = enabled[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: item.bgColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.bgColor.withValues(alpha: 0.28),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    item.icon,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── 2. DANH SÁCH TIỆN ÍCH ĐANG HIỂN THỊ (KÉO THẢ) ─────────────
              FormCard(
                title: 'Tiện ích đang hiển thị (${enabled.length})',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.drag_indicator_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Giữ và kéo để đổi vị trí hiển thị (Tối thiểu 4 mục)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: enabled.length,
                      onReorder: (oldIdx, newIdx) {
                        ref
                            .read(quickActionsProvider.notifier)
                            .reorder(oldIdx, newIdx);
                      },
                      itemBuilder: (context, index) {
                        final item = enabled[index];
                        return Container(
                          key: ValueKey(item.id),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackground
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: item.bgColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.bgColor.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  item.icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            title: Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                            subtitle: Text(
                              _getGroupName(item.group),
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 22,
                                  ),
                                  tooltip: 'Ẩn khỏi trang chủ',
                                  onPressed: () async {
                                    final success = await ref
                                        .read(quickActionsProvider.notifier)
                                        .toggleAction(item.id);
                                    if (!success && context.mounted) {
                                      AppToast.warning(
                                        context,
                                        'Cần giữ tối thiểu 4 tiện ích hiển thị trên trang chủ!',
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 2),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.lightMuted,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── 3. DANH SÁCH TIỆN ÍCH CÒN LẠI (CÓ THỂ THÊM VÀO) ────────────
              if (disabled.isNotEmpty) ...[
                FormCard(
                  title: 'Tiện ích chưa kích hoạt (${disabled.length})',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhấn vào nút cộng để thêm tiện ích này ra màn hình chính.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: disabled.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = disabled[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: item.bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.bgColor.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    item.icon,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              subtitle: Text(
                                _getGroupName(item.group),
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                              ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                tooltip: 'Thêm vào trang chủ',
                                onPressed: () {
                                  ref
                                      .read(quickActionsProvider.notifier)
                                      .toggleAction(item.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
