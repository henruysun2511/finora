import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../domain/models/loan_filter.dart';
import '../providers/loan_list_provider.dart';

class LoanSummaryCard extends ConsumerWidget {
  const LoanSummaryCard({
    super.key,
    this.onBack,
    this.onAdd,
    this.onToggleSort,
    this.sortOrder,
  });

  final VoidCallback? onBack;
  final VoidCallback? onAdd;
  final VoidCallback? onToggleSort;
  final LoanSortOrder? sortOrder;

  Widget _buildBlueButton({
    required Widget icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    Widget btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
    if (tooltip != null) {
      btn = Tooltip(message: tooltip, child: btn);
    }
    return btn;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(loanSummaryProvider);

    return BannerHeader(
      title: 'Sổ ghi nợ',
      centerTitle: true,
      onBack: onBack,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      gradient: const LinearGradient(
        colors: [
          Color(0xFF0F4B92),
          AppColors.primary,
          Color(0xFFF5B53F),
        ],
        stops: [0.0, 0.55, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onToggleSort != null) ...[
            _buildBlueButton(
              icon: Icon(
                sortOrder == LoanSortOrder.asc
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 18,
              ),
              onTap: onToggleSort!,
              tooltip: 'Đổi thứ tự hiển thị',
            ),
            const SizedBox(width: 8),
          ],
          _buildBlueButton(
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 22,
            ),
            onTap: onAdd ?? () => context.push(RoutePaths.createLoan),
            tooltip: 'Thêm khoản nợ',
          ),
        ],
      ),
      child: summary.when(
        loading: () => const SizedBox(
          height: 110,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (error, _) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Không tải được tổng quan: '
                  '${error is AppException ? error.message : error}',
                  style: AppTextStyles.bodySmall(color: Colors.white),
                ),
              ),
              IconButton(
                tooltip: 'Tải lại tổng quan',
                onPressed: () => ref.invalidate(loanSummaryProvider),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'VỊ THẾ NỢ RÒNG',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${data.activeCount} khoản đang nợ',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${data.netPosition >= 0 ? '+ ' : '- '}${CurrencyFormatter.formatVnd(data.netPosition.abs())}',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // ── 3 Ô tóm tắt (Frosted Boxes theo chuẩn ui-sample-3) ──
            Row(
              children: [
                Expanded(
                  child: _FrostedBox(
                    label: 'Cần thu về',
                    value: CurrencyFormatter.formatCompact(data.totalLent),
                    valueColor: const Color(0xFF86EFAC),
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FrostedBox(
                    label: 'Phải trả',
                    value: CurrencyFormatter.formatCompact(
                      data.totalBorrowed + data.totalInstallment,
                    ),
                    valueColor: const Color(0xFFFCA5A5),
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FrostedBox(
                    label: 'Quá hạn',
                    value: '${data.overdueCount} khoản',
                    valueColor: data.overdueCount > 0
                        ? const Color(0xFFFCA5A5)
                        : Colors.white,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FrostedBox extends StatelessWidget {
  const _FrostedBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
