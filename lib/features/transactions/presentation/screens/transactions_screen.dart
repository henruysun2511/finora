import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../dashboard/domain/models/dashboard_data.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Sổ giao dịch',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Tất cả', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'Chi tiêu', isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: 'Thu nhập', isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: 'Chuyển khoản', isSelected: false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions Group
          Text(
            'Hôm nay, 17 tháng 9',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: TransactionItem.sampleTransactions.map((tx) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(tx.icon, size: 18, color: isDark ? Colors.white : const Color(0xFF334155)),
                  ),
                  title: Text(
                    tx.title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    '${tx.category} · ${tx.dateText}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkMuted : const Color(0xFF94A3B8),
                    ),
                  ),
                  trailing: Text(
                    '${tx.isIncome ? '+' : '-'}${CurrencyFormatter.formatVnd(tx.amount.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: tx.isIncome ? AppColors.success : AppColors.danger,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }
}
