import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/expense_split_model.dart';

class RebalanceSplitSheet extends StatefulWidget {
  const RebalanceSplitSheet({
    super.key,
    required this.split,
    required this.onSubmit,
  });

  final ExpenseSplitModel split;
  final Future<void> Function(List<Map<String, dynamic>> participants) onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    required ExpenseSplitModel split,
    required Future<void> Function(List<Map<String, dynamic>> participants)
        onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RebalanceSplitSheet(split: split, onSubmit: onSubmit),
    );
  }

  @override
  State<RebalanceSplitSheet> createState() => _RebalanceSplitSheetState();
}

class _RebalanceSplitSheetState extends State<RebalanceSplitSheet> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (final p in widget.split.friendParticipants) {
      final initAmount = p.proposedAmount ?? p.assignedAmount;
      _controllers[p.userId] = TextEditingController(
        text: initAmount.round().toString(),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _calculateOwnerShare() {
    double totalAssigned = 0;
    for (final c in _controllers.values) {
      final val =
          double.tryParse(c.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
      totalAssigned += val;
    }
    return (widget.split.totalAmount - totalAssigned).roundToDouble();
  }

  Future<void> _handleSave() async {
    final List<Map<String, dynamic>> payload = [];
    double totalAssigned = 0;

    for (final p in widget.split.friendParticipants) {
      final ctrl = _controllers[p.userId];
      final val = double.tryParse(
            ctrl?.text.replaceAll('.', '').replaceAll(',', '') ?? '0',
          ) ??
          0;
      if (val <= 0) {
        AppToast.show(
          context,
          message: 'Số tiền phân bổ cho ${p.displayName} phải lớn hơn 0',
          type: ToastType.warning,
        );
        return;
      }
      totalAssigned += val;
      payload.add({
        'userId': p.userId,
        'assignedAmount': val,
      });
    }

    if (totalAssigned >= widget.split.totalAmount) {
      AppToast.show(
        context,
        message: 'Tổng số tiền bạn bè trả phải nhỏ hơn tổng hóa đơn',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(payload);
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ownerShare = _calculateOwnerShare();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Điều chỉnh phân bổ lại',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      Text(
                        'Tổng hóa đơn: ${CurrencyFormatter.format(widget.split.totalAmount)}',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // Phần của chủ chi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Phần bạn tự chi trả:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.format(ownerShare > 0 ? ownerShare : 0),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ownerShare >= 0
                          ? AppColors.primary
                          : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Danh sách bạn bè để chỉnh
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.split.friendParticipants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final p = widget.split.friendParticipants[i];
                final ctrl = _controllers[p.userId]!;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          p.initials,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (p.proposedAmount != null)
                              Text(
                                'Đề xuất: ${CurrencyFormatter.format(p.proposedAmount!)}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF8B5CF6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          decoration: const InputDecoration(
                            suffixText: '₫',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Nút Lưu & Gửi lại
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.send_rounded, size: 18),
                label: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Cập nhật & Gửi lại xác nhận',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
