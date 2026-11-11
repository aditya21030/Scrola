import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';

class PlatformBreakdownSection extends StatelessWidget {
  final List<SocialPlatform>? platforms;
  final Map<SocialPlatform, int> counts;
  final Map<SocialPlatform, int> limits;
  final VoidCallback? onDetailsTap;
  final ValueChanged<SocialPlatform>? onPlatformTap;

  const PlatformBreakdownSection({
    super.key,
    this.platforms,
    required this.counts,
    required this.limits,
    this.onDetailsTap,
    this.onPlatformTap,
  });

  @override
  Widget build(BuildContext context) {
    final activePlatforms = platforms ??
        (counts.isNotEmpty ? counts.keys.toList() : SocialPlatform.values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Platforms',
              style: AppTypography.heading(color: AppColors.primaryText),
            ),
            GestureDetector(
              onTap: () {
                HapticService.subtle();
                onDetailsTap?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Details',
                  style: AppTypography.caption(color: AppColors.primaryAccent)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < activePlatforms.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCard(activePlatforms[i]),
              ),
              const SizedBox(width: 12),
              if (i + 1 < activePlatforms.length)
                Expanded(
                  child: _buildCard(activePlatforms[i + 1]),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCard(SocialPlatform platform) {
    return _PlatformTileCard(
      platform: platform,
      label: platform.reelsName,
      count: counts[platform] ?? 0,
      limit: limits[platform] ?? 0,
      brandColor: platform.brandColor,
      onTap: () => onPlatformTap?.call(platform),
    );
  }
}

class _PlatformTileCard extends StatelessWidget {
  final SocialPlatform platform;
  final String label;
  final int count;
  final int limit;
  final Color brandColor;
  final VoidCallback onTap;

  const _PlatformTileCard({
    required this.platform,
    required this.label,
    required this.count,
    required this.limit,
    required this.brandColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeLimit = math.max(1, limit);
    final fraction = (count / safeLimit).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Container(
        height: 152,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
          gradient: RadialGradient(
            center: const Alignment(0.85, -0.75),
            radius: 1.15,
            colors: [
              brandColor.withValues(alpha: 0.14),
              AppColors.surfaceSolid,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlatformIcon(platform: platform, size: 40),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CustomPaint(
                    painter: _MiniRingPainter(
                      progress: fraction,
                      color: brandColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$count',
                        style: AppTypography.numeric(
                          color: AppColors.primaryText,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ $safeLimit',
                        style: AppTypography.numeric(
                          color: AppColors.secondaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(color: AppColors.secondaryText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MiniRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 4;
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    final sweep = (progress <= 0 ? 0.01 : progress) * 2 * math.pi;
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.progress != progress || old.color != color;
}
