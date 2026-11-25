import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';

class ProposeAmountDialog extends StatefulWidget {
  const ProposeAmountDialog({
    super.key,
    required this.currentAmount,
    required this.totalAmount,
    required this.onSubmit,
  });

  final double currentAmount;
  final double totalAmount;
  final Future<void> Function(double amount, String note) onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    required double currentAmount,
    required double totalAmount,
    required Future<void> Function(double amount, String note) onSubmit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ProposeAmountDialog(
        currentAmount: currentAmount,
        totalAmount: totalAmount,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ProposeAmountDialog> createState() => _ProposeAmountDialogState();
}

class _ProposeAmountDialogState extends State<ProposeAmountDialog> {
  late final TextEditingController _amountController;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.currentAmount.round().toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final parsed = double.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll(',', ''),
    );
    if (parsed == null || parsed <= 0) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập số tiền đề xuất lớn hơn 0',
        type: ToastType.warning,
      );
      return;
    }

    if (parsed >= widget.totalAmount) {
      AppToast.show(
        context,
        message: 'Số tiền đề xuất phải nhỏ hơn tổng hóa đơn (${CurrencyFormatter.format(widget.totalAmount)})',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(parsed, _noteController.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đề xuất lại số tiền',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Số tiền hiện tại được chia: ${CurrencyFormatter.format(widget.currentAmount)}. Bạn có thể đề xuất lại số tiền khác kèm lý do cho chủ chi xem xét.',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 16),

            // Ô nhập số tiền đề xuất
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8B5CF6),
              ),
              decoration: InputDecoration(
                labelText: 'Số tiền mong muốn trả',
                suffixText: '₫',
                filled: true,
                fillColor:
                    isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Ô nhập lý do
            TextField(
              controller: _noteController,
              maxLines: 2,
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Lý do / Lời nhắn',
                hintText: 'VD: Tôi về sớm chỉ ăn nửa bữa...',
                hintStyle: GoogleFonts.inter(fontSize: 12.5),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Gửi đề xuất'),
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

