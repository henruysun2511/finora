import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

class QuickPromptChips extends StatelessWidget {
  final ValueChanged<String> onSelectPrompt;

  const QuickPromptChips({
    super.key,
    required this.onSelectPrompt,
  });

  static const List<Map<String, String>> _prompts = [
    {
      'label': '🍜 Ăn tối 250k',
      'query': 'Ăn tối buffet 250k',
    },
    {
      'label': '📊 Tiêu nhiều nhất ở đâu?',
      'query': 'Tháng này tôi tiêu nhiều nhất vào đâu?',
    },
    {
      'label': '💡 Mẹo tiết kiệm tuần này',
      'query': 'Gợi ý cho tôi mẹo tiết kiệm tuần này',
    },
    {
      'label': '☕ Cà phê 45k',
      'query': 'Cà phê Highland 45k thanh toán bằng tiền mặt',
    },
    {
      'label': '🎯 Tiến độ ngân sách',
      'query': 'Tình hình tiến độ ngân sách tháng này của tôi thế nào?',
    },
    {
      'label': '💵 Số dư tài khoản',
      'query': 'Tra cứu số dư các tài khoản ví của tôi',
    },
    {
      'label': '📊 Quy tắc 50/30/20',
      'query': 'Đánh giá chi tiêu của tôi theo quy tắc 50 30 20 tháng này',
    },
    {
      'label': '📈 Dòng tiền & tích lũy',
      'query': 'Dòng tiền thu chi và tỷ lệ tiết kiệm tháng này của tôi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = _prompts[index];
          return InkWell(
            onTap: () => onSelectPrompt(p['query']!),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                p['label']!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
