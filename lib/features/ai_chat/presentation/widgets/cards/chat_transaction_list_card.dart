import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/theme/app_colors.dart';

class ChatTransactionListCard extends StatelessWidget {
  final Map<String, dynamic> payload;

  const ChatTransactionListCard({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final functionName = payload['functionName'] as String? ?? '';
    final items = payload['items'] as List<dynamic>? ?? [];
    final isDebt = functionName == 'GET_DEBT_SUMMARY';
    final isTopExpenses = functionName == 'GET_TOP_EXPENSES';

    String headerTitle = 'GIAO DỊCH GẦN ĐÂY';
    IconData headerIcon = Icons.receipt_long_rounded;
    Color headerColor = const Color(0xFF0072D5);
    String badgeText = '${items.length} giao dịch';

    if (isDebt) {
      headerTitle = 'SỔ NỢ & CHO VAY';
      headerIcon = Icons.handshake_outlined;
      headerColor = const Color(0xFFF59E0B);
      badgeText = '${items.length} khoản';
    } else if (isTopExpenses) {
      headerTitle = 'CHI TIÊU LỚN NHẤT';
      headerIcon = Icons.trending_up_rounded;
      headerColor = const Color(0xFFEF4444);
    }

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
      child: Column(
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
                      color: headerColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      headerIcon,
                      size: 16,
                      color: headerColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    headerTitle,
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
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items list
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final name = item['name']?.toString() ?? 'Giao dịch';
            final amountFormatted = item['amountFormatted']?.toString() ?? '0 ₫';
            final categoryName = item['categoryName']?.toString() ?? 'Chung';
            final type = item['type']?.toString().toUpperCase() ?? 'EXPENSE';
            final isExpense = type == 'EXPENSE';
            final date = item['date']?.toString() ?? '';

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: idx < items.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: (isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isExpense ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
                      size: 16,
                      color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              categoryName,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            if (date.isNotEmpty) ...[
                              Text(
                                ' · $date',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isExpense ? '-' : '+'}$amountFormatted',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
