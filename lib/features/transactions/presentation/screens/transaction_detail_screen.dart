import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';
import '../providers/transaction_list_provider.dart';
import '../providers/transaction_providers.dart';

final transactionDetailFutureProvider = FutureProvider.autoDispose
    .family<TransactionItem, String>((ref, id) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionById(id);
});

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  String _formatCurrency(double amount) {
    return NumberFormat('#,###', 'vi_VN').format(amount.round());
  }

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Xóa giao dịch này?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Số dư trong tài khoản và hạn mức ngân sách liên quan sẽ được tự động hoàn tác chính xác.',
          style: GoogleFonts.inter(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
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
    final detailAsync = ref.watch(transactionDetailFutureProvider(transactionId));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chi tiết giao dịch',
        subtitle: transactionId.length >= 8
            ? 'Mã: #${transactionId.substring(0, 8)}'
            : null,
        action: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.danger),
          tooltip: 'Xóa giao dịch',
          onPressed: () => _handleDelete(context, ref),
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
          Color amountColor;
          String prefix;
          switch (item.type) {
            case TransactionType.expense:
              amountColor = AppColors.danger;
              prefix = '- ₫ ';
              break;
            case TransactionType.income:
              amountColor = AppColors.success;
              prefix = '+ ₫ ';
              break;
            case TransactionType.transfer:
              amountColor = AppColors.primary;
              prefix = '⇄ ₫ ';
              break;
          }

          final dateStr = _formatDateTimeVi(item.transactionDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── KHỐI HERO: ICON + TÊN + SỐ TIỀN ──
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      CategoryIcon(
                        icon: item.categoryIcon,
                        colorHex: item.categoryColor,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: foreground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$prefix${_formatCurrency(item.amount)}',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: amountColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Đã hoàn tất • ${item.type.label}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── KHỐI THÔNG TIN CHI TIẾT ──
                FormCard(
                  title: 'Thông tin chi tiết',
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Nguồn tiền',
                        item.accountName ?? 'Tài khoản chính',
                        Icons.account_balance_wallet_rounded,
                        foreground,
                        muted,
                      ),
                      Divider(height: 20, color: border.withValues(alpha: 0.4)),
                      if (item.type == TransactionType.transfer &&
                          item.toAccountName != null) ...[
                        _buildDetailRow(
                          'Tài khoản đích',
                          item.toAccountName!,
                          Icons.download_rounded,
                          foreground,
                          muted,
                        ),
                        Divider(height: 20, color: border.withValues(alpha: 0.4)),
                      ],
                      _buildDetailRow(
                        'Ngày giờ',
                        dateStr,
                        Icons.access_time_rounded,
                        foreground,
                        muted,
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        Divider(height: 20, color: border.withValues(alpha: 0.4)),
                        _buildDetailRow(
                          'Ghi chú',
                          item.note!,
                          Icons.notes_rounded,
                          foreground,
                          muted,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── KHỐI HÓA ĐƠN ĐÍNH KÈM (NẾU CÓ) ──
                if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  FormCard(
                    title: 'Hóa đơn & Chứng từ đính kèm',
                    child: InkWell(
                      onTap: () => _showImageDialog(context, item.photoUrl!),
                      borderRadius: BorderRadius.circular(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              !kIsWeb && File(item.photoUrl!).existsSync()
                                  ? Image.file(
                                      File(item.photoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      item.photoUrl!,
                                      fit: BoxFit.cover,
                                    ),
                              Container(
                                color: Colors.black26,
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.zoom_in_rounded,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Chạm để phóng to ảnh',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── KHỐI TÁC ĐỘNG TÀI CHÍNH ──
                if (item.balanceAfter != null) ...[
                  const SizedBox(height: 16),
                  FormCard(
                    title: 'Tác động tài chính',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số dư tài khoản sau giao dịch:',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: muted,
                          ),
                        ),
                        Text(
                          '₫ ${_formatCurrency(item.balanceAfter!)}',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── NÚT XÓA GIAO DỊCH ──
                OutlinedButton.icon(
                  onPressed: () => _handleDelete(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text(
                    'XÓA GIAO DỊCH & HOÀN TÁC SỐ DƯ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color foreground,
    Color muted,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
