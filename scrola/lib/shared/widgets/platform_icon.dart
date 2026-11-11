import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum SocialPlatform {
  instagram,
  youtube,
  facebook,
  snapchat,
}

/// Platform tile matching design.md Section 6 & 12-home-dashboard.html:
/// Rounded square in platform's brand color with generic reel glyph.
class PlatformIcon extends StatelessWidget {
  final SocialPlatform platform;
  final double size;

  const PlatformIcon({
    super.key,
    required this.platform,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(platform);
    final iconColor = platform == SocialPlatform.snapchat
        ? AppColors.textOnAccent
        : Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.55, size * 0.55),
          painter: _ReelGlyphPainter(color: iconColor),
        ),
      ),
    );
  }

  Color _getBackgroundColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return AppColors.instagram;
      case SocialPlatform.youtube:
        return AppColors.youtube;
      case SocialPlatform.facebook:
        return AppColors.facebook;
      case SocialPlatform.snapchat:
        return AppColors.snapchat;
    }
  }
}

class _ReelGlyphPainter extends CustomPainter {
  final Color color;

  _ReelGlyphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.105
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Rounded vertical reel frame (<rect x="5" y="3" width="14" height="18" rx="4"/>)
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.06, w * 0.68, h * 0.88),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(rrect, strokePaint);

    // Inner play triangle (<path d="M10.5 9.5l3.5 2.5-3.5 2.5z"/>)
    final path = Path()
      ..moveTo(w * 0.41, h * 0.36)
      ..lineTo(w * 0.64, h * 0.50)
      ..lineTo(w * 0.41, h * 0.64)
      ..close();
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ReelGlyphPainter oldDelegate) => oldDelegate.color != color;
}
