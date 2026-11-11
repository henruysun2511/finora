import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/budget_list_state.dart';

/// Khối nội dung Hero bên trong BannerHeader của màn hình Ngân sách
class BudgetBannerHero extends StatelessWidget {
  const BudgetBannerHero({
    super.key,
    required this.stateAsync,
  });

  final AsyncValue<BudgetListState> stateAsync;

  @override
  Widget build(BuildContext context) {
    return stateAsync.when(
      data: (data) {
        final summary = data.summary;
        if (summary == null) {
          return const SizedBox(
            height: 90,
            child: Center(
              child: Text(
                'Chưa có dữ liệu tổng quan ngân sách',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          );
        }

        final currencyFormatter = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: '₫',
          decimalDigits: 0,
        );
        final pct = (summary.percentage).clamp(0.0, 100.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label chu kỳ
            Text(
              'NGÂN SÁCH TỔNG · ${summary.periodLabel.toUpperCase()}',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),

            // Số tiền tổng ngân sách lớn màu trắng nổi bật
            Text(
              currencyFormatter.format(summary.totalLimit),
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Thanh tiến độ
            Container(
              height: 9,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(99),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: summary.totalLimit > 0 ? (pct / 100.0) : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF97316),
                        Color(0xFFFFC080),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Chân banner: Đã dùng ... / Còn ...
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đã dùng: ${currencyFormatter.format(summary.totalSpent)} (${summary.percentage.toStringAsFixed(0)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  'Còn: ${currencyFormatter.format(summary.totalRemaining)}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Lỗi tải ngân sách: $e',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}
