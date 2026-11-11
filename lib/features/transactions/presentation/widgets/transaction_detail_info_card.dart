import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/form_card.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';

class TransactionDetailInfoCard extends StatelessWidget {
  const TransactionDetailInfoCard({
    super.key,
    required this.item,
    required this.dateStr,
  });

  final TransactionItem item;
  final String dateStr;

  String _formatSource(String source) {
    switch (source.toUpperCase()) {
      case 'OPEN_BANKING':
      case 'BANKING':
        return 'Đồng bộ Open Banking';
      case 'OCR_RECEIPT':
      case 'RECEIPT':
        return 'Quét hóa đơn AI OCR';
      case 'AI_VOICE':
      case 'AI_CHAT':
        return 'Trợ lý AI Nora';
      case 'MANUAL':
      default:
        return 'Nhập tay thủ công';
    }
  }

  String _formatStatus(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirmed:
        return 'Đã ghi sổ thành công';
      case TransactionStatus.pending:
        return 'Chờ xác nhận';
      case TransactionStatus.rejected:
        return 'Đã từ chối';
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppToast.show(
      context,
      message: 'Đã sao chép $label vào bộ nhớ tạm!',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final createdAtStr =
        DateFormat('dd/MM/yyyy · HH:mm:ss').format(item.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. KHỐI PHÂN LOẠI & DÒNG TIỀN ──
        FormCard(
          title: 'Phân loại & Nguồn tiền',
          child: Column(
            children: [
              // Danh mục chi tiêu
              _buildCustomRow(
                label: 'Danh mục',
                icon: Icons.category_rounded,
                foreground: foreground,
                muted: muted,
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CategoryIcon(
                      icon: item.categoryIcon,
                      colorHex: item.categoryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.categoryName ?? 'Chi tiêu chung',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Loại giao dịch
              _buildRow(
                'Loại giao dịch',
                item.type.label,
                item.type == TransactionType.income
                    ? Icons.arrow_downward_rounded
                    : (item.type == TransactionType.transfer
                        ? Icons.swap_horiz_rounded
                        : Icons.arrow_upward_rounded),
                foreground,
                muted,
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Nguồn tiền (Tài khoản gốc)
              _buildRow(
                item.type == TransactionType.transfer
                    ? 'Từ tài khoản'
                    : 'Ví thanh toán',
                item.accountName ?? 'Tài khoản chính',
                Icons.account_balance_wallet_rounded,
                foreground,
                muted,
              ),

              // Tài khoản nhận (nếu có)
              if (item.type == TransactionType.transfer &&
                  item.toAccountName != null) ...[
                Divider(height: 20, color: border.withValues(alpha: 0.4)),
                _buildRow(
                  'Đến tài khoản',
                  item.toAccountName!,
                  Icons.account_balance_rounded,
                  foreground,
                  muted,
                ),
              ],

              // Số dư sau giao dịch (nếu có)
              if (item.balanceAfter != null) ...[
                Divider(height: 20, color: border.withValues(alpha: 0.4)),
                _buildRow(
                  'Số dư sau GD',
                  CurrencyFormatter.format(item.balanceAfter!,
                      currency: item.currency),
                  Icons.savings_rounded,
                  AppColors.primary,
                  muted,
                  valueBold: true,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── 2. KHỐI THỜI GIAN & ĐỊA ĐIỂM ──
        FormCard(
          title: 'Thời gian & Địa điểm',
          child: Column(
            children: [
              _buildRow(
                'Thời gian',
                dateStr,
                Icons.access_time_rounded,
                foreground,
                muted,
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Lặp lại định kỳ
              _buildRow(
                'Lặp lại định kỳ',
                item.isRecurring ? 'Định kỳ hàng tháng' : 'Không lặp lại',
                Icons.repeat_rounded,
                foreground,
                muted,
              ),

              // Địa điểm giao dịch
              if (item.locationName != null &&
                  item.locationName!.isNotEmpty) ...[
                Divider(height: 20, color: border.withValues(alpha: 0.4)),
                _buildRow(
                  'Địa điểm',
                  item.locationName!,
                  Icons.place_rounded,
                  foreground,
                  muted,
                ),
              ],

              // Ghi chú
              if (item.note != null && item.note!.isNotEmpty) ...[
                Divider(height: 20, color: border.withValues(alpha: 0.4)),
                _buildRow(
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

        const SizedBox(height: 14),

        // ── 3. KHỐI QUẢN TRỊ & HỆ THỐNG ──
        FormCard(
          title: 'Trạng thái & Quản trị',
          child: Column(
            children: [
              // Trạng thái ghi sổ
              _buildCustomRow(
                label: 'Trạng thái',
                icon: Icons.check_circle_outline_rounded,
                foreground: foreground,
                muted: muted,
                valueWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatStatus(item.status),
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Nguồn tạo giao dịch
              _buildRow(
                'Nguồn dữ liệu',
                _formatSource(item.source),
                Icons.input_rounded,
                foreground,
                muted,
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Chế độ hiển thị
              _buildRow(
                'Phạm vi hiển thị',
                item.visibility == 'SHARED'
                    ? 'Ví chung & Quỹ nhóm'
                    : 'Riêng tư cá nhân',
                item.visibility == 'SHARED'
                    ? Icons.group_rounded
                    : Icons.lock_outline_rounded,
                foreground,
                muted,
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Báo cáo thống kê
              _buildRow(
                'Báo cáo chi tiêu',
                item.excludeFromReport
                    ? 'Loại trừ khỏi báo cáo'
                    : 'Tính vào báo cáo',
                Icons.pie_chart_outline_rounded,
                foreground,
                muted,
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Thời điểm tạo bản ghi
              _buildRow(
                'Ghi sổ lúc',
                createdAtStr,
                Icons.history_rounded,
                foreground,
                muted,
              ),
              Divider(height: 20, color: border.withValues(alpha: 0.4)),

              // Mã định danh UUID
              _buildCustomRow(
                label: 'Mã giao dịch',
                icon: Icons.tag_rounded,
                foreground: foreground,
                muted: muted,
                valueWidget: InkWell(
                  onTap: () => _copyToClipboard(context, item.id, 'mã giao dịch'),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.id.length > 12
                              ? '${item.id.substring(0, 8)}...${item.id.substring(item.id.length - 4)}'
                              : item.id,
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value,
    IconData icon,
    Color foreground,
    Color muted, {
    bool valueBold = false,
  }) {
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
              fontWeight: valueBold ? FontWeight.w800 : FontWeight.w700,
              color: foreground,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRow({
    required String label,
    required IconData icon,
    required Color foreground,
    required Color muted,
    required Widget valueWidget,
  }) {
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
        valueWidget,
      ],
    );
  }
}
