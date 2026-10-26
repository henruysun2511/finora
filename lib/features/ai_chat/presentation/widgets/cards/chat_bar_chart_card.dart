import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';

class ChatBarChartCard extends StatelessWidget {
  final Map<String, dynamic> payload;

  const ChatBarChartCard({super.key, required this.payload});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 ₫';
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final functionName = payload['functionName'] as String? ?? '';
    final isComparison = functionName == 'COMPARE_PERIODS' || payload.containsKey('delta');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isComparison
          ? _buildComparisonView(context, isDark)
          : _buildTopCategoriesView(context, isDark),
    );
  }

  Widget _buildComparisonView(BuildContext context, bool isDark) {
    final periodLabel = payload['periodLabel'] as String? ?? 'Kỳ này';
    final previousLabel = payload['previousLabel'] as String? ?? 'Kỳ trước';
    final currentTotal = (payload['currentTotal'] as num?)?.toDouble() ?? 0.0;
    final previousTotal = (payload['previousTotal'] as num?)?.toDouble() ?? 0.0;
    final delta = (payload['delta'] as num?)?.toDouble() ?? 0.0;
    final deltaPercent = payload['deltaPercent'] as num?;
    final direction = payload['direction'] as String? ?? 'same';
    final isUp = direction == 'up';
    final isDown = direction == 'down';

    final categoryChanges = payload['categoryChanges'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0072D5).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.compare_arrows_rounded,
                    size: 16,
                    color: Color(0xFF0072D5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SO SÁNH CHI TIÊU',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isUp
                    ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                    : isDown
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp
                        ? Icons.trending_up_rounded
                        : isDown
                            ? Icons.trending_down_rounded
                            : Icons.remove_rounded,
                    size: 13,
                    color: isUp
                        ? const Color(0xFFEF4444)
                        : isDown
                            ? const Color(0xFF10B981)
                            : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deltaPercent != null
                        ? '${isUp ? '+' : ''}$deltaPercent%'
                        : 'Không đổi',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isUp
                          ? const Color(0xFFEF4444)
                          : isDown
                              ? const Color(0xFF10B981)
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Comparison Two Column Bars
        Row(
          children: [
            // Previous Period
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      previousLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(previousTotal),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Current Period
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0072D5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0072D5).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0072D5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(currentTotal),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0072D5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Chênh lệch tuyệt đối
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (isUp ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isUp ? 'Chi nhiều hơn kỳ trước' : 'Tiết kiệm hơn kỳ trước',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUp ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                ),
              ),
              Text(
                '${isUp ? '+' : '-'}${_formatCurrency(delta.abs())}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isUp ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),

        // Biến động từng danh mục (nếu có)
        if (categoryChanges.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            'Biến động danh mục lớn nhất',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          ...categoryChanges.take(3).map((item) {
            final catLabel = item['label']?.toString() ?? '';
            final catDelta = (item['delta'] as num?)?.toDouble() ?? 0.0;
            final isCatUp = catDelta > 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    catLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  Text(
                    '${isCatUp ? '+' : ''}${_formatCurrency(catDelta)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCatUp ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTopCategoriesView(BuildContext context, bool isDark) {
    final periodLabel = payload['periodLabel'] as String? ?? 'Kỳ này';
    final functionName = payload['functionName'] as String? ?? '';
    final rawData = payload['data'] as List<dynamic>? ?? [];

    String cardTitle = 'TOP DANH MỤC CHI TIÊU';
    IconData cardIcon = Icons.bar_chart_rounded;
    Color iconColor = const Color(0xFF0072D5);

    if (functionName == 'GET_RULE_50_30_20') {
      cardTitle = 'QUY TẮC TÀI CHÍNH 50/30/20';
      cardIcon = Icons.pie_chart_outline_rounded;
      iconColor = const Color(0xFF8B5CF6);
    } else if (functionName == 'GET_SPENDING_HABITS') {
      cardTitle = 'THÓI QUEN THEO THỨ / NGÀY';
      cardIcon = Icons.calendar_view_week_rounded;
      iconColor = const Color(0xFFF59E0B);
    } else if (functionName == 'GET_CASHFLOW_SAVINGS') {
      cardTitle = 'DÒNG TIỀN THUẦN & TÍCH LŨY';
      cardIcon = Icons.savings_rounded;
      iconColor = const Color(0xFF10B981);
    }

    final items = rawData.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'label': item['label']?.toString() ?? 'Khác',
          'value': (item['value'] as num?)?.toDouble() ?? 0.0,
          'percentage': (item['percentage'] as num?)?.toDouble() ?? 0.0,
        };
      }
      return {'label': 'Khác', 'value': 0.0, 'percentage': 0.0};
    }).where((item) => (item['value'] as double) > 0).toList();

    final maxVal = items.fold(0.0, (m, i) => (i['value'] as double) > m ? (i['value'] as double) : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    cardIcon,
                    size: 16,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cardTitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                periodLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal Bars
        ...items.map((item) {
          final label = item['label'] as String;
          final value = item['value'] as double;
          final pct = (item['percentage'] as double).toStringAsFixed(0);
          final ratio = maxVal > 0 ? (value / maxVal).clamp(0.05, 1.0) : 0.05;

          // Màu thanh progress tùy ngữ cảnh
          Color barColor = const Color(0xFF0072D5);
          Color valColor = const Color(0xFFEF4444);

          if (functionName == 'GET_RULE_50_30_20') {
            if (label.contains('50')) {
              barColor = const Color(0xFF0072D5);
              valColor = const Color(0xFF0072D5);
            } else if (label.contains('30')) {
              barColor = const Color(0xFFF59E0B);
              valColor = const Color(0xFFF59E0B);
            } else {
              barColor = const Color(0xFF10B981);
              valColor = const Color(0xFF10B981);
            }
          } else if (functionName == 'GET_CASHFLOW_SAVINGS') {
            if (label.contains('Thu')) {
              barColor = const Color(0xFF10B981);
              valColor = const Color(0xFF10B981);
            } else if (label.contains('Chi')) {
              barColor = const Color(0xFFEF4444);
              valColor = const Color(0xFFEF4444);
            } else {
              barColor = const Color(0xFF0072D5);
              valColor = const Color(0xFF0072D5);
            }
          } else if (functionName == 'GET_SPENDING_HABITS') {
            barColor = const Color(0xFFF59E0B);
            valColor = isDark ? Colors.white : AppColors.lightForeground;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$pct% · ',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _formatCurrency(value),
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: valColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
