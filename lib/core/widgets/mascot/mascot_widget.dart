import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'mascot_model.dart';
import 'mascot_registry.dart';
import 'mascot_speech_bubble.dart';

/// Available presentation modes for Finora Mascot components,
/// identical to the Finora Web Component architecture.
enum MascotMode {
  /// Pure mascot avatar with optional speech bubble and float animation
  avatar,

  /// Elevated financial tier card with ambient blurred glow, tier badge, name & role
  card,

  /// Horizontal dialogue row (avatar + speech box) for AI assistant chat
  dialogue,

  /// Comprehensive profile spotlight banner with quotes and financial views
  profile,
}

/// The universal Finora Mascot Flutter Widget.
///
/// Ports 1:1 all 10+ AI Mascots from `device-preview/components/mascot/`:
/// - Ash, Penny, Sage, Nora, Jade, Ruby, Bellingham/Sterling (Financial Tiers)
/// - Ronaldo, Messi (Legends)
/// - Huy Sun (Special)
///
/// Supports automatic net-worth tier resolution via [balance],
/// high-fidelity vector rendering via `flutter_svg`, floating animations,
/// interactive scale on press, and comic speech bubbles.
class MascotWidget extends StatefulWidget {
  /// Direct mascot model
  final MascotData? mascot;

  /// Mascot identifier (e.g. 'nora', 'ash', 'penny', 'ronaldo', 'messi', 'huysun')
  final String? mascotId;

  /// Optional account balance/net worth. If provided without [mascot] or [mascotId],
  /// automatically resolves the corresponding tier mascot.
  final num? balance;

  /// Presentation mode
  final MascotMode mode;

  /// Desired size for avatar/card SVG
  final double? size;

  /// Whether to play a smooth continuous floating animation
  final bool float;

  /// Whether the mascot reacts with interactive scale when tapped or hovered
  final bool interactive;

  /// Explicit text for the cartoon speech bubble. Pass empty string to hide.
  final String? bubbleText;

  /// If true, automatically displays the mascot's signature bubble text
  final bool showBubble;

  /// Active state highlight when in [MascotMode.card]
  final bool cardActive;

  /// Callback when user taps the mascot
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    this.mascot,
    this.mascotId,
    this.balance,
    this.mode = MascotMode.avatar,
    this.size,
    this.float = false,
    this.interactive = false,
    this.bubbleText,
    this.showBubble = false,
    this.cardActive = false,
    this.onTap,
  });

  /// Convenient factory constructor for resolving mascot by balance
  factory MascotWidget.byBalance({
    Key? key,
    required num balance,
    MascotMode mode = MascotMode.avatar,
    double? size,
    bool float = false,
    bool interactive = false,
    String? bubbleText,
    bool showBubble = false,
    bool cardActive = false,
    VoidCallback? onTap,
  }) {
    return MascotWidget(
      key: key,
      balance: balance,
      mode: mode,
      size: size,
      float: float,
      interactive: interactive,
      bubbleText: bubbleText,
      showBubble: showBubble,
      cardActive: cardActive,
      onTap: onTap,
    );
  }

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.float) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.float != oldWidget.float) {
      if (widget.float) {
        _floatController.repeat(reverse: true);
      } else {
        _floatController.stop();
        _floatController.reset();
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  MascotData _resolveMascot() {
    if (widget.mascot != null) return widget.mascot!;
    if (widget.mascotId != null && widget.mascotId!.isNotEmpty) {
      return MascotRegistry.get(widget.mascotId!);
    }
    if (widget.balance != null) {
      return MascotRegistry.resolveByBalance(widget.balance!);
    }
    return MascotRegistry.nora;
  }

  String? _resolveBubbleText(MascotData mascot) {
    if (widget.bubbleText != null) {
      return widget.bubbleText!.isEmpty ? null : widget.bubbleText;
    }
    if (widget.showBubble) {
      return mascot.bubble.isNotEmpty ? mascot.bubble : mascot.q1;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mascot = _resolveMascot();

    switch (widget.mode) {
      case MascotMode.avatar:
        return _buildAvatarMode(context, mascot);
      case MascotMode.card:
        return _buildCardMode(context, mascot);
      case MascotMode.dialogue:
        return _buildDialogueMode(context, mascot);
      case MascotMode.profile:
        return _buildProfileMode(context, mascot);
    }
  }

  // -------------------------------------------------------------
  // 1. AVATAR MODE
  // -------------------------------------------------------------
  Widget _buildAvatarMode(BuildContext context, MascotData mascot) {
    final bubble = _resolveBubbleText(mascot);
    final size = widget.size ?? 120.0;

    Widget svgBody = SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        mascot.svg,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );

    if (widget.float) {
      svgBody = AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        ),
        child: svgBody,
      );
    }

    Widget content = bubble != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MascotSpeechBubble(
                text: bubble,
                onTap: widget.onTap,
              ),
              const SizedBox(height: 8),
              svgBody,
            ],
          )
        : svgBody;

    if (widget.interactive || widget.onTap != null) {
      content = GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: content,
        ),
      );
    }

    return content;
  }

  // -------------------------------------------------------------
  // 2. CARD MODE
  // -------------------------------------------------------------
  Widget _buildCardMode(BuildContext context, MascotData mascot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final svgSize = widget.size ?? 96.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: widget.cardActive
                ? mascot.accent
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: widget.cardActive ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.cardActive
                  ? mascot.accent.withValues(alpha: 0.22)
                  : (isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : const Color(0x0E000000)),
              blurRadius: widget.cardActive ? 20 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient glowing radial blob
            Positioned(
              top: 15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mascot.blobColor.withValues(alpha: 0.35),
                ),
              ),
            ),

            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: svgSize,
                  height: svgSize * (240 / 200),
                  child: SvgPicture.string(
                    mascot.svg,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mascot.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mascot.tier,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: mascot.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mascot.role,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. DIALOGUE ROW MODE
  // -------------------------------------------------------------
  Widget _buildDialogueMode(BuildContext context, MascotData mascot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = widget.bubbleText ?? mascot.q1;
    final avatarSize = widget.size ?? 52.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mascot Avatar Thumbnail
          SizedBox(
            width: avatarSize,
            height: avatarSize * (240 / 200),
            child: SvgPicture.string(
              mascot.svg,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),

          // Message Bubble Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      mascot.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: mascot.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: mascot.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        mascot.role,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: mascot.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 4. PROFILE SPOTLIGHT MODE
  // -------------------------------------------------------------
  Widget _buildProfileMode(BuildContext context, MascotData mascot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Spotlight Avatar Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [
                  mascot.accent.withValues(alpha: 0.22),
                  isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                ],
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                ),
                child: SizedBox(
                  width: 140,
                  height: 140 * (240 / 200),
                  child: SvgPicture.string(
                    mascot.svg,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: mascot.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mascot.tier,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Name & Range
                Text(
                  mascot.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  mascot.range,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: mascot.accent,
                  ),
                ),
                const SizedBox(height: 14),

                // Personality
                if (mascot.personality.isNotEmpty)
                  _buildProfileSection(
                    title: 'VAI TRÒ & TÍNH CÁCH',
                    content: mascot.personality,
                    isDark: isDark,
                  ),

                // Finance view
                if (mascot.finance.isNotEmpty)
                  _buildProfileSection(
                    title: 'QUAN ĐIỂM TÀI CHÍNH',
                    content: mascot.finance,
                    isDark: isDark,
                  ),

                // Characteristic advice
                if (mascot.advice.isNotEmpty)
                  _buildProfileSection(
                    title: 'LỜI KHUYÊN ĐẶC TRƯNG',
                    content: mascot.advice,
                    isDark: isDark,
                  ),

                // Quotes
                if (mascot.q1.isNotEmpty)
                  _buildQuoteBox(mascot.q1, isDark, mascot.accent),
                if (mascot.q2.isNotEmpty)
                  _buildQuoteBox(mascot.q2, isDark, mascot.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteBox(String quote, bool isDark, Color accent) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: accent, width: 3.5),
        ),
      ),
      child: Text(
        '“$quote”',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

/// Type alias for backward compatibility and intuitive usage
typedef FinoraMascot = MascotWidget;
