import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/export_format.dart';
import '../providers/report_overview_provider.dart';
import '../widgets/report_category_breakdown_list.dart';
import '../widgets/report_donut_chart.dart';
import '../widgets/report_export_sheet.dart';
import '../widgets/report_period_selector.dart';
import '../widgets/report_stat_grid.dart';

class ReportsOverviewScreen extends ConsumerWidget {
  const ReportsOverviewScreen({super.key});

  void _handleExport(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    final fileName =
        await ref.read(reportOverviewProvider.notifier).exportReport(format);
    if (!context.mounted) return;

    if (fileName != null) {
      AppToast.success(
        context,
        'Đã xuất file $fileName thành công!',
      );
    } else {
      AppToast.error(
        context,
        'Xuất báo cáo không thành công, vui lòng thử lại.',
      );
    }
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    final state = ref.read(reportOverviewProvider);
    final data = state.data;
    if (data == null) {
      AppToast.info(context, 'Chưa có dữ liệu báo cáo để xuất file.');
      return;
    }

    ReportExportSheet.show(
      context,
      data: data,
      onSelectFormat: (format) => _handleExport(context, ref, format),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(reportOverviewProvider);
    final notifier = ref.read(reportOverviewProvider.notifier);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Báo cáo Tài chính',
        subtitle: 'Bức tranh tài chính tổng thể chu kỳ',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút [📥 Xuất PDF] chuẩn ASCII wireframe
            TextButton.icon(
              onPressed: () => _handleExport(context, ref, ExportFormat.pdf),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: Text(
                'Xuất PDF',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Nút Menu 3 chấm [ ⠇ ]
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'Tùy chọn xuất file',
              onPressed: () => _showExportOptions(context, ref),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: AppColors.primary,
        child: state.isLoading && state.data == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : state.errorMessage != null && state.data == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.danger,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: notifier.refresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildContent(context, ref, state, isDark),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    reportState,
    bool isDark,
  ) {
    final notifier = ref.read(reportOverviewProvider.notifier);
    final data = reportState.data;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Thanh Chọn Kỳ & Điều Hướng [<] Tháng 10, 2026 [>] ──────────
          ReportPeriodSelector(
            selectedPeriod: reportState.period,
            targetDate: reportState.targetDate,
            customStart: reportState.customStart,
            customEnd: reportState.customEnd,
            onPeriodChanged: notifier.setPeriod,
            onPrevious: notifier.previousPeriod,
            onNext: notifier.nextPeriod,
            onCustomRangeSelected: notifier.setCustomRange,
          ),
          const SizedBox(height: 8),

          // ── Lưới 4 Chỉ Số Sức Khỏe Dòng Tiền (Stat 4-Box Grid) ──────────
          if (data != null)
            ReportStatGrid(
              metrics: data.statMetrics,
              currency: data.currency,
            ),
          const SizedBox(height: 24),

          // ── Biểu Đồ Tròn Donut Chart Cơ Cấu Chi Tiêu ───────────────────
          if (data != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CƠ CẤU CHI TIÊU THEO DANH MỤC',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  if (reportState.selectedCategoryId != null)
                    GestureDetector(
                      onTap: () => notifier.selectCategory(null),
                      child: Text(
                        'Xem tất cả',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ReportDonutChart(
              slices: data.slices,
              totalExpense: data.totalExpense,
              selectedCategoryId: reportState.selectedCategoryId,
              onSliceSelected: notifier.selectCategory,
            ),
            const SizedBox(height: 24),

            // ── Danh Sách Tỷ Trọng Danh Mục Chi Tiết ───────────────────────
            ReportCategoryBreakdownList(
              categories: data.categories,
              selectedCategoryId: reportState.selectedCategoryId,
              onCategoryTap: notifier.selectCategory,
            ),
          ],
        ],
      ),
    );
  }
}
