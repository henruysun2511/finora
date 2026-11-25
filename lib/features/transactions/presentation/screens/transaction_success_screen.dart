import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';
import '../widgets/split_bill_bottom_sheet.dart';

class TransactionSuccessScreen extends StatefulWidget {
  const TransactionSuccessScreen({
    super.key,
    this.transaction,
  });

  final TransactionItem? transaction;

  @override
  State<TransactionSuccessScreen> createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> {
  bool _hasCreatedSplit = false;

  void _copyTransactionId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    AppToast.show(
      context,
      message: 'Đã sao chép mã giao dịch vào bộ nhớ tạm',
      type: ToastType.info,
    );
  }

  void _openSplitBillSheet(TransactionItem tx) {
    SplitBillBottomSheet.show(
      context,
      transaction: tx,
      onSplitCreated: () {
        setState(() => _hasCreatedSplit = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tx = widget.transaction;

    // Fallback nếu không có transaction data
    if (tx == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: PageHeader.subPage(
          title: 'Giao dịch thành công',
          subtitle: 'Xác nhận tạo giao dịch',
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Đã lưu giao dịch thành công!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Về Trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    final isExpense = tx.isExpense;
    final isIncome = tx.isIncome;
    final isTransfer = tx.isTransfer;

    final amountColor = isIncome
        ? AppColors.success
        : (isExpense ? AppColors.danger : AppColors.primary);

    final sign = isIncome ? '+' : (isExpense ? '-' : '');
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(tx.transactionDate);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chi tiết kết quả',
        subtitle: 'Giao dịch đã được ghi nhận',
        action: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Về Trang chủ',
          onPressed: () => context.go(RoutePaths.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── 1. HERO SUCCESS BANNER ──────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Hào quang tỏa sáng nền
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(alpha: 0.12),
                          ),
                        ),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.success.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Lưu giao dịch thành công!',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── 2. SỐ TIỀN & PHÂN LOẠI ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isExpense
                        ? 'Số tiền chi tiêu'
                        : (isIncome ? 'Số tiền nhận được' : 'Số tiền chuyển'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$sign ${CurrencyFormatter.format(tx.amount)}',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Badge trạng thái
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isExpense
                          ? 'Chi tiêu'
                          : (isIncome ? 'Thu nhập' : 'Chuyển khoản'),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ─── 3. THẺ TÙY CHỌN CHIA TIỀN CHO BẠN BÈ (SPLIT BILL) ──────────────
            if (isExpense) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.primary.withValues(alpha: 0.18),
                            AppColors.darkSurface,
                          ]
                        : [
                            const Color(0xFFEFF6FF),
                            Colors.white,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.group_work_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chia tiền cho bạn bè (Split Bill)',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _hasCreatedSplit
                                    ? 'Đã mở phiên chia tiền cho giao dịch này'
                                    : 'Chia đều hoặc tự nhập tiền để bạn bè cùng hoàn trả',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _hasCreatedSplit
                                      ? AppColors.success
                                      : (isDark
                                          ? AppColors.darkMuted
                                          : AppColors.lightMuted),
                                  fontWeight: _hasCreatedSplit
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _openSplitBillSheet(tx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasCreatedSplit
                              ? AppColors.success
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          _hasCreatedSplit
                              ? Icons.check_circle_outline_rounded
                              : Icons.share_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _hasCreatedSplit
                              ? 'Cập nhật lại phiên chia tiền'
                              : 'Mở chia tiền ngay',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (_hasCreatedSplit) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push(RoutePaths.splitExpenses),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon:
                              const Icon(Icons.receipt_long_rounded, size: 16),
                          label: const Text(
                            'Xem tiến độ chia tiền nhóm',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ─── 4. THẺ THÔNG TIN CHI TIẾT ───────────────────────────────────────
            FormCard(
              title: 'Thông tin giao dịch',
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Tên giao dịch',
                    value: tx.name.isNotEmpty ? tx.name : 'Không có tiêu đề',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  if (tx.categoryName != null) ...[
                    _buildDetailRow(
                      label: 'Danh mục',
                      value: tx.categoryName!,
                      icon: Icons.category_outlined,
                      isDark: isDark,
                    ),
                    const Divider(height: 20),
                  ],
                  _buildDetailRow(
                    label: isTransfer ? 'Từ tài khoản' : 'Tài khoản',
                    value: tx.accountName ?? 'Tài khoản mặc định',
                    icon: Icons.account_balance_wallet_outlined,
                    isDark: isDark,
                  ),
                  if (isTransfer && tx.toAccountName != null) ...[
                    const Divider(height: 20),
                    _buildDetailRow(
                      label: 'Đến tài khoản',
                      value: tx.toAccountName!,
                      icon: Icons.arrow_forward_rounded,
                      isDark: isDark,
                    ),
                  ],
                  if (tx.note != null && tx.note!.trim().isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildDetailRow(
                      label: 'Ghi chú',
                      value: tx.note!,
                      icon: Icons.notes_rounded,
                      isDark: isDark,
                    ),
                  ],
                  if (tx.locationName != null &&
                      tx.locationName!.trim().isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildDetailRow(
                      label: 'Địa điểm',
                      value: tx.locationName!,
                      icon: Icons.location_on_outlined,
                      isDark: isDark,
                    ),
                  ],
                  const Divider(height: 20),
                  // Mã giao dịch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Mã giao dịch',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _copyTransactionId(tx.id),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  child: Text(
                                tx.id.length > 12
                                    ? '${tx.id.substring(0, 8)}...${tx.id.substring(tx.id.length - 4)}'
                                    : tx.id,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: AppColors.primary,
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

            const SizedBox(height: 12),

            // ─── 5. NÚT ĐIỀU HƯỚNG DƯỚI CÙNG ─────────────────────────────────────
            // Nút Thêm giao dịch khác
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pushReplacement(RoutePaths.createTransaction);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: Text(
                  'Thêm giao dịch khác',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Nút Xem chi tiết giao dịch
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.pushReplacement(
                    RoutePaths.transactionDetailWithId(tx.id),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                  side: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: Text(
                  'Xem chi tiết giao dịch',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Nút Về Trang chủ
            TextButton(
              onPressed: () => context.go(RoutePaths.home),
              child: Text(
                'Về Trang chủ',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    IconData? icon,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
                child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ),
      ],
    );
  }
}
