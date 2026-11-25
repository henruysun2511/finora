import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Huy hiệu đếm số lượng định kỳ trong banner hero
class RecurringCountBadge extends StatelessWidget {
  const RecurringCountBadge({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.bgColor,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Flexible(
              child: Text(
            '$count $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    );
  }
}

/// Khối thống kê Hero nằm trong BannerHeader của màn hình giao dịch định kỳ
class RecurringBannerHero extends StatelessWidget {
  const RecurringBannerHero({
    super.key,
    required this.monthlyExpense,
    required this.monthlyIncome,
    required this.activeCount,
    required this.pausedCount,
  });

  final double monthlyExpense;
  final double monthlyIncome;
  final int activeCount;
  final int pausedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHI PHÍ ĐỊNH KỲ ƯỚC TÍNH / THÁNG',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          CurrencyFormatter.formatVnd(monthlyExpense),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        if (monthlyIncome > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Thu nhập định kỳ: +${CurrencyFormatter.format(monthlyIncome)}/tháng',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            RecurringCountBadge(
              label: 'Đang chạy',
              count: activeCount,
              icon: Icons.play_circle_fill_rounded,
              bgColor: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(width: 10),
            RecurringCountBadge(
              label: 'Tạm dừng',
              count: pausedCount,
              icon: Icons.pause_circle_rounded,
              bgColor: Colors.white.withValues(alpha: 0.12),
            ),
          ],
        ),
      ],
    );
  }
}
