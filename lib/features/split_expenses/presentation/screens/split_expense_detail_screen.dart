import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/expense_split_model.dart';
import '../../domain/models/split_enums.dart';
import '../providers/split_providers.dart';
import '../widgets/consensus_tracker_card.dart';
import '../widgets/propose_amount_dialog.dart';
import '../widgets/rebalance_split_sheet.dart';
import '../widgets/split_participant_tile.dart';

class SplitExpenseDetailScreen extends ConsumerWidget {
  const SplitExpenseDetailScreen({
    super.key,
    required this.splitId,
  });

  final String splitId;

  Future<void> _handleConfirmSplit(
    BuildContext context,
    WidgetRef ref,
    ExpenseSplitModel split,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Chốt phiên chia tiền?',
      message:
          'Khi chốt phiên, hệ thống sẽ tự động tạo các khoản nợ phải thu (Lent) trong Sổ Nợ đối với từng bạn bè đã đồng ý. Hành động này không thể hoàn tác.',
      confirmText: 'Chốt ngay',
      cancelText: 'Hủy',
      isDestructive: false,
      icon: Icons.verified_rounded,
      iconColor: AppColors.primary,
    );

    if (!confirmed) return;

    final res =
        await ref.read(splitActionsProvider.notifier).confirmSplit(split.id);

    if (context.mounted) {
      if (res != null) {
        AppToast.show(
          context,
          message: 'Đã chốt phiên chia tiền và tạo Sổ Nợ thành công!',
          type: ToastType.success,
        );
      } else {
        AppToast.show(
          context,
          message: 'Không thể chốt phiên. Vui lòng thử lại!',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _handleCancelSplit(
    BuildContext context,
    WidgetRef ref,
    ExpenseSplitModel split,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hủy phiên chia tiền?',
      message:
          'Bạn có chắc chắn muốn hủy phiên chia tiền này? Thông báo hủy sẽ được gửi tới tất cả người tham gia.',
      confirmText: 'Xác nhận hủy',
      cancelText: 'Quay lại',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.danger,
    );

    if (!confirmed) return;

    final res =
        await ref.read(splitActionsProvider.notifier).cancelSplit(split.id);

    if (context.mounted) {
      if (res != null) {
        AppToast.show(
          context,
          message: 'Đã hủy phiên chia tiền.',
          type: ToastType.info,
        );
        context.pop();
      } else {
        AppToast.show(
          context,
          message: 'Không thể hủy phiên. Vui lòng thử lại!',
          type: ToastType.error,
        );
      }
    }
  }

  void _openRebalanceSheet(
    BuildContext context,
    WidgetRef ref,
    ExpenseSplitModel split,
  ) {
    RebalanceSplitSheet.show(
      context,
      split: split,
      onSubmit: (parts) async {
        await ref.read(splitActionsProvider.notifier).rebalanceSplit(
              splitId: split.id,
              participants: parts,
            );
        if (context.mounted) {
          AppToast.show(
            context,
            message: 'Đã cập nhật lại số tiền phân bổ!',
            type: ToastType.success,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final splitAsync = ref.watch(splitDetailProvider(splitId));
    final currentUserId = ref.watch(currentUserIdProvider);
    final actionsState = ref.watch(splitActionsProvider);
    final isLoadingAction = actionsState.isLoading;

    final splitItem = splitAsync.valueOrNull;
    final isOwner = splitItem?.isOwner(currentUserId) ?? false;
    final canControl = isOwner &&
        !(splitItem?.isConfirmed ?? false) &&
        !(splitItem?.isCancelled ?? false);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chi tiết đợt chia bill',
        subtitle: 'Mã phiên: #${splitId.substring(0, 8)}',
        action: canControl
            ? PopupMenuButton<String>(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (val) {
                  if (val == 'rebalance' && splitItem != null) {
                    _openRebalanceSheet(context, ref, splitItem);
                  } else if (val == 'cancel' && splitItem != null) {
                    _handleCancelSplit(context, ref, splitItem);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'rebalance',
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          'Điều chỉnh phân bổ',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.danger),
                        const SizedBox(width: 10),
                        Text(
                          'Hủy phiên chia tiền',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
      body: splitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 44, color: AppColors.danger),
                const SizedBox(height: 12),
                Text(
                  'Không thể tải thông tin đợt chia tiền',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => ref.invalidate(splitDetailProvider(splitId)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (split) {
          final isOwner = split.isOwner(currentUserId);
          final dateStr =
              DateFormat('dd/MM/yyyy HH:mm').format(split.createdAt);

          // Tìm xem người dùng hiện tại có phải là người tham gia không
          final currentParticipant = split.participants
              .where((p) => p.userId == currentUserId)
              .firstOrNull;

          final canRespond = !isOwner &&
              currentParticipant != null &&
              !split.isConfirmed &&
              !split.isCancelled;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(splitDetailProvider(splitId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. BANNER THÔNG TIN HÓA ĐƠN GỐC ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TỔNG HÓA ĐƠN CHI TIÊU',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                split.splitType.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(split.totalAmount),
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Người thanh toán: ${isOwner ? "Bạn" : (split.creatorName ?? "Bạn bè")}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 2. THANH TIẾN ĐỘ ĐỒNG THUẬN (CONSENSUS TRACKER) ──────────────
                  ConsensusTrackerCard(split: split),

                  // ── 3. KHỐI PHẢN HỒI NỔI BẬT DÀNH CHO BẠN BÈ ĐƯỢC CHIA ─────────
                  if (canRespond) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF8B5CF6)
                                      .withValues(alpha: 0.18),
                                  AppColors.darkSurface,
                                ]
                              : [
                                  const Color(0xFFF5F3FF),
                                  Colors.white,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.pending_actions_rounded,
                                color: Color(0xFF8B5CF6),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Yêu cầu phản hồi từ bạn',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Số tiền phân bổ cho bạn: ${CurrencyFormatter.format(currentParticipant.assignedAmount)}. Bạn có đồng ý với khoản chi này không?',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Nút Đồng ý
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: isLoadingAction
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                  splitActionsProvider.notifier)
                                              .respondSplit(
                                                splitId: split.id,
                                                action: 'accept',
                                              );
                                          if (context.mounted) {
                                            AppToast.show(
                                              context,
                                              message:
                                                  'Đã xác nhận đồng ý khoản chia tiền',
                                              type: ToastType.success,
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon:
                                      const Icon(Icons.check_rounded, size: 18),
                                  label: Text(
                                    'Đồng ý',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Nút Đề xuất lại
                              Expanded(
                                flex: 3,
                                child: OutlinedButton(
                                  onPressed: isLoadingAction
                                      ? null
                                      : () {
                                          ProposeAmountDialog.show(
                                            context,
                                            currentAmount: currentParticipant
                                                .assignedAmount,
                                            totalAmount: split.totalAmount,
                                            onSubmit: (amt, note) async {
                                              await ref
                                                  .read(splitActionsProvider
                                                      .notifier)
                                                  .respondSplit(
                                                    splitId: split.id,
                                                    action: 'propose',
                                                    proposedAmount: amt,
                                                    note: note,
                                                  );
                                              if (context.mounted) {
                                                AppToast.show(
                                                  context,
                                                  message:
                                                      'Đã gửi đề xuất số tiền mới',
                                                  type: ToastType.success,
                                                );
                                              }
                                            },
                                          );
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF8B5CF6),
                                    side: const BorderSide(
                                      color: Color(0xFF8B5CF6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Đề xuất lại',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Nút Từ chối
                              IconButton(
                                onPressed: isLoadingAction
                                    ? null
                                    : () async {
                                        await ref
                                            .read(splitActionsProvider.notifier)
                                            .respondSplit(
                                              splitId: split.id,
                                              action: 'reject',
                                            );
                                        if (context.mounted) {
                                          AppToast.show(
                                            context,
                                            message:
                                                'Đã từ chối khoản chia tiền này',
                                            type: ToastType.warning,
                                          );
                                        }
                                      },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.danger,
                                ),
                                tooltip: 'Từ chối',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── 4. DANH SÁCH THÀNH VIÊN VÀ TIỀN PHÂN BỔ ──────────────────────
                  FormCard(
                    title:
                        'Danh sách thành viên (${split.participants.length})',
                    child: Column(
                      children: [
                        // Chủ phiên trước
                        if (split.ownerParticipant != null)
                          SplitParticipantTile(
                            participant: split.ownerParticipant!,
                            isOwner: true,
                          ),

                        // Bạn bè tham gia
                        ...split.friendParticipants.map(
                          (p) => SplitParticipantTile(
                            participant: p,
                            isOwner: false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 5. BẢNG ĐIỀU KHIỂN DÀNH CHO CHỦ PHIÊN (CHUẨN HỆ THỐNG FINORA) ─
                  if (canControl) ...[
                    // Nút Chốt phiên (Chỉ enable khi 100% đồng ý)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: (!split.isAllAccepted || isLoadingAction)
                            ? null
                            : () => _handleConfirmSplit(context, ref, split),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              isDark ? Colors.white12 : Colors.black12,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.verified_rounded, size: 20),
                        label: Text(
                          split.isAllAccepted
                              ? 'Chốt phiên chia tiền (Tạo Sổ Nợ)'
                              : 'Chờ tất cả bạn bè đồng ý để chốt',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Hàng nút Thao tác phụ: "Điều chỉnh lại" & "Hủy phiên" chuẩn FinTech
                    Row(
                      children: [
                        // Nút Điều chỉnh lại
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoadingAction
                                ? null
                                : () => _openRebalanceSheet(
                                      context,
                                      ref,
                                      split,
                                    ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: Text(
                              'Điều chỉnh lại',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nút Hủy phiên
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoadingAction
                                ? null
                                : () => _handleCancelSplit(context, ref, split),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(
                                color: AppColors.danger,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18),
                            label: Text(
                              'Hủy phiên',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── 6. THÔNG BÁO KHI ĐÃ CHỐT SỔ NỢ ──────────────────────────────
                  if (split.isConfirmed) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Phiên chia tiền đã được chốt sổ nợ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tất cả các khoản nợ của bạn bè đã được ghi nhận vào Sổ Nợ. Bạn có thể kiểm tra danh sách người vay và trạng thái hoàn trả.',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(RoutePaths.loans),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.success,
                                side:
                                    const BorderSide(color: AppColors.success),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.book_outlined, size: 16),
                              label: Text(
                                'Xem danh sách Sổ Nợ',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
