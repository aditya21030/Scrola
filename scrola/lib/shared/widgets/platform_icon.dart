import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum SocialPlatform {
  instagram,
  youtube,
  facebook,
  snapchat,
}

/// Official brand colors & icons for the tracked platforms.
class PlatformIcon extends StatelessWidget {
  final SocialPlatform platform;
  final double size;
  final bool useReelsVariant;

  const PlatformIcon({
    super.key,
    required this.platform,
    this.size = 32,
    this.useReelsVariant = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(platform),
        gradient: _getGradient(platform),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: _getGlowColor(platform),
            blurRadius: size * 0.45,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.58, size * 0.58),
          painter: _PlatformPainter(
            platform: platform,
            isReelsVariant: useReelsVariant,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return const Color(0xFFE1306C);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.snapchat:
        return const Color(0xFFFFFC00);
    }
  }

  Gradient? _getGradient(SocialPlatform platform) {
    if (platform == SocialPlatform.instagram) {
      return const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFFFD1D1D),
          Color(0xFFE1306C),
          Color(0xFF833AB4),
        ],
      );
    }
    return null;
  }

  Color _getGlowColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return AppColors.instagramGlow;
      case SocialPlatform.youtube:
        return AppColors.youtubeGlow;
      case SocialPlatform.facebook:
        return AppColors.facebookGlow;
      case SocialPlatform.snapchat:
        return AppColors.snapchatGlow;
    }
  }
}

class _PlatformPainter extends CustomPainter {
  final SocialPlatform platform;
  final bool isReelsVariant;

  _PlatformPainter({
    required this.platform,
    required this.isReelsVariant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final paintWhite = Paint()
      ..color = (platform == SocialPlatform.snapchat ? const Color(0xFF101010) : Colors.white)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokeWhite = Paint()
      ..color = (platform == SocialPlatform.snapchat ? const Color(0xFF101010) : Colors.white)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    if (isReelsVariant) {
      // Reels / Video play badge variant as shown in Scrola UI & design system
      _drawReelsGlyph(canvas, size, paintWhite, strokeWhite);
    } else {
      // Native official brand logo variant
      switch (platform) {
        case SocialPlatform.instagram:
          _drawInstagramLogo(canvas, size, strokeWhite, paintWhite);
          break;
        case SocialPlatform.youtube:
          _drawYouTubeLogo(canvas, size, paintWhite);
          break;
        case SocialPlatform.facebook:
          _drawFacebookLogo(canvas, size, paintWhite);
          break;
        case SocialPlatform.snapchat:
          _drawSnapchatGhost(canvas, size, paintWhite);
          break;
      }
    }
  }

  void _drawReelsGlyph(Canvas canvas, Size size, Paint fillPaint, Paint strokePaint) {
    final w = size.width;
    final h = size.height;

    // Outer clapperboard / reel squircle outline
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(rrect, strokePaint);

    // Center play triangle
    final playPath = Path();
    playPath.moveTo(w * 0.40, h * 0.32);
    playPath.lineTo(w * 0.68, h * 0.50);
    playPath.lineTo(w * 0.40, h * 0.68);
    playPath.close();
    canvas.drawPath(playPath, fillPaint);
  }

  void _drawInstagramLogo(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Outer rounded square
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.28),
    );
    canvas.drawRRect(outer, stroke);

    // Center circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.22, stroke);

    // Top-right flash dot
    canvas.drawCircle(Offset(w * 0.76, h * 0.24), w * 0.07, fill);
  }

  void _drawYouTubeLogo(Canvas canvas, Size size, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Centered play triangle
    final path = Path();
    path.moveTo(w * 0.30, h * 0.20);
    path.lineTo(w * 0.78, h * 0.50);
    path.lineTo(w * 0.30, h * 0.80);
    path.close();
    canvas.drawPath(path, fill);
  }

  void _drawFacebookLogo(Canvas canvas, Size size, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Facebook lowercase 'f'
    final path = Path();
    path.moveTo(w * 0.65, h * 0.95);
    path.lineTo(w * 0.45, h * 0.95);
    path.lineTo(w * 0.45, h * 0.55);
    path.lineTo(w * 0.32, h * 0.55);
    path.lineTo(w * 0.32, h * 0.40);
    path.lineTo(w * 0.45, h * 0.40);
    path.lineTo(w * 0.45, h * 0.28);
    path.cubicTo(w * 0.45, h * 0.12, w * 0.54, h * 0.05, w * 0.70, h * 0.05);
    path.lineTo(w * 0.80, h * 0.05);
    path.lineTo(w * 0.80, h * 0.22);
    path.lineTo(w * 0.72, h * 0.22);
    path.cubicTo(w * 0.65, h * 0.22, w * 0.65, h * 0.26, w * 0.65, h * 0.32);
    path.lineTo(w * 0.65, h * 0.40);
    path.lineTo(w * 0.80, h * 0.40);
    path.lineTo(w * 0.77, h * 0.55);
    path.lineTo(w * 0.65, h * 0.55);
    path.close();

    canvas.drawPath(path, fill);
  }

  void _drawSnapchatGhost(Canvas canvas, Size size, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Playful ghost silhouette
    final path = Path();
    path.moveTo(w * 0.5, h * 0.1);
    path.cubicTo(w * 0.72, h * 0.1, w * 0.82, h * 0.3, w * 0.82, h * 0.5);
    path.cubicTo(w * 0.88, h * 0.55, w * 0.95, h * 0.62, w * 0.85, h * 0.72);
    path.cubicTo(w * 0.78, h * 0.75, w * 0.82, h * 0.85, w * 0.70, h * 0.88);
    path.cubicTo(w * 0.62, h * 0.83, w * 0.58, h * 0.88, w * 0.5, h * 0.88);
    path.cubicTo(w * 0.42, h * 0.88, w * 0.38, h * 0.83, w * 0.30, h * 0.88);
    path.cubicTo(w * 0.18, h * 0.85, w * 0.22, h * 0.75, w * 0.15, h * 0.72);
    path.cubicTo(w * 0.05, h * 0.62, w * 0.12, h * 0.55, w * 0.18, h * 0.5);
    path.cubicTo(w * 0.18, h * 0.3, w * 0.28, h * 0.1, w * 0.5, h * 0.1);
    path.close();

    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant _PlatformPainter oldDelegate) {
    return oldDelegate.platform != platform || oldDelegate.isReelsVariant != isReelsVariant;
  }
}
