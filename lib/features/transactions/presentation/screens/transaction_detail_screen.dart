import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';
import '../providers/transaction_list_provider.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_detail_balance_card.dart';
import '../widgets/transaction_detail_hero_card.dart';
import '../widgets/transaction_detail_info_card.dart';
import '../widgets/transaction_detail_receipt_card.dart';
import '../widgets/transaction_detail_split_card.dart';

final transactionDetailFutureProvider = FutureProvider.autoDispose
    .family<TransactionItem, String>((ref, id) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionById(id);
});

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  String _formatDateTimeVi(DateTime dt) {
    const weekdays = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật',
    ];
    final wd = weekdays[(dt.weekday - 1) % 7];
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$wd, $d/$m/$y - $h:$min';
  }

  void _showImageDialog(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: !kIsWeb && File(path).existsSync()
                    ? Image.file(File(path), fit: BoxFit.contain)
                    : Image.network(path, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa giao dịch này?',
      message:
          'Số dư trong tài khoản và hạn mức ngân sách liên quan sẽ được tự động hoàn tác chính xác.',
      confirmText: 'Xác nhận xóa',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        final repo = ref.read(transactionRepositoryProvider);
        await repo.deleteTransaction(transactionId);
        ref.read(dailyGridProvider.notifier).refresh();

        if (context.mounted) {
          AppToast.show(
            context,
            message: 'Đã xóa giao dịch và hoàn tất cập nhật số dư!',
            type: ToastType.success,
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.show(
            context,
            message: 'Lỗi khi xóa giao dịch: $e',
            type: ToastType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(transactionDetailFutureProvider(transactionId));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chi tiết giao dịch',
        subtitle: transactionId.length >= 8
            ? 'Mã: #${transactionId.substring(0, 8)}'
            : null,
        action: TextButton(
          onPressed: () => context.push(RoutePaths.createTransaction),
          child: Text(
            'Sửa',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text(
            'Lỗi tải thông tin giao dịch: $err',
            style: GoogleFonts.inter(color: muted),
          ),
        ),
        data: (item) {
          final dateStr = _formatDateTimeVi(item.transactionDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. KHỐI HERO: ICON + TÊN + SỐ TIỀN ──
                TransactionDetailHeroCard(item: item),
                const SizedBox(height: 16),

                // ── 2. KHỐI THÔNG TIN CHI TIẾT ĐẦY ĐỦ ──
                TransactionDetailInfoCard(item: item, dateStr: dateStr),

                // ── 3. KHỐI CHIA TIỀN BẠN BÈ (SPLIT BILL) ──
                if (item.type == TransactionType.expense && item.amount > 0) ...[
                  const SizedBox(height: 16),
                  TransactionDetailSplitCard(amount: item.amount),
                ],

                // ── 4. KHỐI HÓA ĐƠN ĐÍNH KÈM (NẾU CÓ) ──
                if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  TransactionDetailReceiptCard(
                    photoUrl: item.photoUrl!,
                    onTapImage: () => _showImageDialog(context, item.photoUrl!),
                  ),
                ],

                const SizedBox(height: 24),

                // ── 5. HÀNG NÚT THAO TÁC: XOÁ & CHỈNH SỬA ──
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleDelete(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon:
                            const Icon(Icons.delete_outline_rounded, size: 18),
                        label: Text(
                          'Xóa giao dịch',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.push(RoutePaths.createTransaction),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text(
                          'Chỉnh sửa',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
