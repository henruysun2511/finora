import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

/// Thẻ Tài sản Ròng (Net Worth Hero Card) chuẩn 1:1 phong cách SOLARN (`ui-sample-3` & `device-preview`).
class BalanceCard extends StatefulWidget {
  final double netWorth;
  final double monthlyIncome;
  final double monthlyExpense;
  final double? savingsRate;
  final String tierTitle;
  final String? mascotMood;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.netWorth,
    this.monthlyIncome = 0.0,
    this.monthlyExpense = 0.0,
    this.savingsRate,
    this.tierTitle = 'Gold Tier',
    this.mascotMood = 'HAPPY',
    this.onTap,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isHidden = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.balanceGradStart,
              AppColors.balanceGradMid,
              AppColors.balanceGradEnd,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.38),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Circular watermark in top right
            Positioned(
              top: -70,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.09),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Title + Eye + Tier Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 15,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'TỔNG TÀI SẢN',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelSmall(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ).copyWith(letterSpacing: 1.1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => setState(() => _isHidden = !_isHidden),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  _isHidden
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              widget.tierTitle,
                              style: AppTextStyles.labelSmall(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Amount
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isHidden
                          ? '•••••••• ₫'
                          : CurrencyFormatter.format(widget.netWorth),
                      style: AppTextStyles.amountHero(color: Colors.white).copyWith(
                        fontSize: 33,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Two Columns (Thu tháng này & Chi tháng này)
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Col 1: Thu tháng này
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                                child: const Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Thu tháng này',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall(
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ).copyWith(fontSize: 10.5, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 1),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _isHidden
                                            ? '••••••'
                                            : '+${CurrencyFormatter.format(widget.monthlyIncome)}',
                                        maxLines: 1,
                                        style: AppTextStyles.titleSmall(color: Colors.white)
                                            .copyWith(fontSize: 13.5, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Col 2: Chi tháng này
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                                child: const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Chi tháng này',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall(
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ).copyWith(fontSize: 10.5, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 1),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _isHidden
                                            ? '••••••'
                                            : '-${CurrencyFormatter.format(widget.monthlyExpense)}',
                                        maxLines: 1,
                                        style: AppTextStyles.titleSmall(color: Colors.white)
                                            .copyWith(fontSize: 13.5, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
