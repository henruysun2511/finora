import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';

class ShareMilestoneSheet extends StatefulWidget {
  const ShareMilestoneSheet({super.key, this.onSuccess});
  final VoidCallback? onSuccess;

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareMilestoneSheet(onSuccess: onSuccess),
    );
  }

  @override
  State<ShareMilestoneSheet> createState() => _ShareMilestoneSheetState();
}

class _ShareMilestoneSheetState extends State<ShareMilestoneSheet> {
  int _selectedPresetIndex = 0;
  final TextEditingController _noteCtrl = TextEditingController();

  final List<({String title, String amount, String icon, String desc})> _presets = const [
    (
      title: 'Chạm mốc tiết kiệm 10 triệu',
      amount: '10.000.000đ',
      icon: '🏆',
      desc: 'Đã tích lũy thành công hũ dự phòng Finora!',
    ),
    (
      title: 'Hoàn thành 50% Mục tiêu Quỹ Du lịch',
      amount: '5.000.000đ',
      icon: '✈️',
      desc: 'Sắp tới lúc vi vu Đà Lạt cùng hội bạn thân rồi!',
    ),
    (
      title: '30 ngày kỷ luật tài chính',
      amount: '1.200.000đ',
      icon: '☕',
      desc: 'Tự pha cà phê tại nhà, tiết kiệm được một khoản bất ngờ.',
    ),
    (
      title: 'Hoàn thành thanh toán khoản nợ',
      amount: '3.500.000đ',
      icon: '🎉',
      desc: 'Tự do tài chính hơn mỗi ngày cùng Finora.',
    ),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context);
    widget.onSuccess?.call();
    AppToast.success(context, 'Đã chia sẻ cột mốc lên Bảng tin cộng đồng! 🏆✨');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final bg = dark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chia sẻ Cột mốc Tiết kiệm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Truyền cảm hứng tài chính lành mạnh cho bạn bè 🦊',
                        style: TextStyle(fontSize: 12.5, color: muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: muted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CHỌN CỘT MỐC CỦA BẠN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Preset cards
                  ...List.generate(_presets.length, (i) {
                    final p = _presets[i];
                    final isSelected = _selectedPresetIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPresetIndex = i),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : border,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : surface,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(p.icon, style: const TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? AppColors.primary : foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${p.amount} · ${p.desc}',
                                      style: TextStyle(fontSize: 12, color: muted),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  const Text(
                    'CẢM NGHĨ HOẶC BÍ QUYẾT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Chia sẻ một vài dòng cảm nghĩ hoặc bí kíp để đạt được cột mốc này nhé...',
                        hintStyle: TextStyle(fontSize: 13, color: muted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      style: TextStyle(fontSize: 13.5, color: foreground),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nora Mascot Motivation Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Text('🦊', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nora chúc mừng bạn! Mỗi bước tiến nhỏ là nền tảng cho sự tự do tài chính vững chắc!',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).viewPadding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: surface,
              border: Border(top: BorderSide(color: border)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submit,
                icon: const Icon(Icons.celebration_rounded, size: 20),
                label: const Text(
                  'Đăng bài chia sẻ ngay',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
