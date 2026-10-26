import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';

class MascotPersonaSheet extends StatelessWidget {
  final MascotData activeMascot;

  const MascotPersonaSheet({super.key, required this.activeMascot});

  static Future<void> show(BuildContext context, MascotData activeMascot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => MascotPersonaSheet(activeMascot: activeMascot),
    );
  }

  static const Map<String, String> _quotes = {
    'ash': 'Mọi tòa lâu đài đều khởi đầu từ một viên gạch nhỏ. Hãy ghi sổ thật kỷ luật!',
    'penny': 'Tiết kiệm từng đồng nhỏ hôm nay là tích lũy tự do cho ngày mai.',
    'sage': 'Chi tiêu có kế hoạch, đầu tư vào tri thức là khoản đầu tư sinh lời nhất.',
    'nora': 'Cân bằng giữa tận hưởng cuộc sống và an toàn tài chính là chìa khóa hạnh phúc!',
    'jade': 'Tài sản bắt đầu sinh sôi khi bạn biết điều khiển dòng tiền thông minh.',
    'ruby': 'Đỉnh cao tài chính không chỉ là con số, mà là quyền tự do lựa chọn cuộc sống.',
    'bellingham': 'Di sản bền vững được kiến tạo từ tầm nhìn chiến lược và sự kiên định.',
  };

  static const Map<String, String> _tierNames = {
    'ash': 'Cấp 1 · Khởi nguồn Tiết kiệm',
    'penny': 'Cấp 2 · Kỷ luật Tài chính',
    'sage': 'Cấp 3 · Khôn ngoan Tích lũy',
    'nora': 'Cấp 4 · Cân bằng Thịnh vượng',
    'jade': 'Cấp 5 · Tăng trưởng Đột phá',
    'ruby': 'Cấp 6 · Đỉnh cao Tự do',
    'bellingham': 'Cấp 7 · Huyền thoại Di sản',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mascotId = activeMascot.id.toLowerCase();
    final quote = _quotes[mascotId] ?? activeMascot.personality;
    final tier = _tierNames[mascotId] ?? 'Trợ lý Tài chính AI';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI MASCOT ĐỒNG HÀNH',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Active Mascot Showcase Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeMascot.blobColor.withValues(alpha: isDark ? 0.25 : 0.15),
                      activeMascot.color.withValues(alpha: isDark ? 0.15 : 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeMascot.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: activeMascot.color.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: activeMascot.color.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: MascotWidget(
                          mascotId: activeMascot.id,
                          size: 56,
                          float: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${activeMascot.name} · ${activeMascot.role}',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: activeMascot.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tier,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: activeMascot.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '“$quote”',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mascots Lineup Preview
              Text(
                '7 Cấp độ AI Mascot Finora',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMascotMiniAvatar(MascotRegistry.ash, mascotId),
                    _buildMascotMiniAvatar(MascotRegistry.penny, mascotId),
                    _buildMascotMiniAvatar(MascotRegistry.sage, mascotId),
                    _buildMascotMiniAvatar(MascotRegistry.nora, mascotId),
                    _buildMascotMiniAvatar(MascotRegistry.jade, mascotId),
                    _buildMascotMiniAvatar(MascotRegistry.ruby, mascotId),
                    _buildMascotMiniAvatar(MascotRegistry.bellingham, mascotId),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action button to Mascot selection
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.onboardingMascot);
                  },
                  icon: const Icon(Icons.diversity_3_rounded, size: 20),
                  label: Text(
                    'Xem chi tiết 7 AI Mascots',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0072D5),
                    side: const BorderSide(color: Color(0xFF0072D5), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotMiniAvatar(MascotData m, String currentId) {
    final isSelected = m.id.toLowerCase() == currentId;

    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: m.blobColor.withValues(alpha: 0.2),
              border: Border.all(
                color: isSelected ? m.color : Colors.transparent,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: m.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: MascotWidget(mascotId: m.id, size: 38, float: false),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            m.name,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? m.color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
