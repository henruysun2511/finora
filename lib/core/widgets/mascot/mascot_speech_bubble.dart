import 'package:flutter/material.dart';

/// Cartoon speech bubble widget matching the Finora device-preview mascot design.
/// Features a comic-book style border (2.5px solid #1A1A1A), rounded corners,
/// drop shadow, and a downward-pointing tail pointing to the mascot.
class MascotSpeechBubble extends StatelessWidget {
  final String text;
  final double maxWidth;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final VoidCallback? onTap;

  const MascotSpeechBubble({
    super.key,
    required this.text,
    this.maxWidth = 240,
    this.textStyle,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFF1A1A1A),
    this.shadowColor = const Color(0x24000000),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bubble Body
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(3, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle ??
                const TextStyle(
                  color: Color(0xFF1A202C),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  letterSpacing: -0.1,
                ),
          ),
        ),

        // Downward Tail
        CustomPaint(
          size: const Size(18, 9),
          painter: _SpeechBubbleTailPainter(
            fillColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: 2.5,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class _SpeechBubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  _SpeechBubbleTailPainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border lines (only left and right legs of the triangle)
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final outlinePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(outlinePath, borderPaint);

    // Overwrite the top seam with fill color so it merges seamlessly with the bubble
    final seamPaint = Paint()
      ..color = fillColor
      ..strokeWidth = borderWidth + 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(borderWidth, 0),
      Offset(size.width - borderWidth, 0),
      seamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeechBubbleTailPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
