import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../shared/widgets/platform_icon.dart';

class PlatformItemData {
  final SocialPlatform platform;
  final String name;
  final int count;
  final int limit;
  final Color themeColor;
  final Color glowColor;

  const PlatformItemData({
    required this.platform,
    required this.name,
    required this.count,
    required this.limit,
    required this.themeColor,
    required this.glowColor,
  });
}

class PlatformBreakdownSection extends StatelessWidget {
  final int instagramCount;
  final int instagramLimit;
  final int youtubeCount;
  final int youtubeLimit;
  final int facebookCount;
  final int facebookLimit;
  final int snapchatCount;
  final int snapchatLimit;
  final VoidCallback? onDetailsTap;
  final void Function(SocialPlatform platform)? onPlatformTap;

  const PlatformBreakdownSection({
    super.key,
    this.instagramCount = 12,
    this.instagramLimit = 20,
    this.youtubeCount = 9,
    this.youtubeLimit = 15,
    this.facebookCount = 3,
    this.facebookLimit = 10,
    this.snapchatCount = 0,
    this.snapchatLimit = 5,
    this.onDetailsTap,
    this.onPlatformTap,
  });

  List<PlatformItemData> get platforms => [
        PlatformItemData(
          platform: SocialPlatform.instagram,
          name: 'Instagram Reels',
          count: instagramCount,
          limit: instagramLimit,
          themeColor: AppColors.instagram,
          glowColor: AppColors.instagramGlow,
        ),
        PlatformItemData(
          platform: SocialPlatform.youtube,
          name: 'YouTube Shorts',
          count: youtubeCount,
          limit: youtubeLimit,
          themeColor: AppColors.youtube,
          glowColor: AppColors.youtubeGlow,
        ),
        PlatformItemData(
          platform: SocialPlatform.facebook,
          name: 'Facebook Reels',
          count: facebookCount,
          limit: facebookLimit,
          themeColor: AppColors.facebook,
          glowColor: AppColors.facebookGlow,
        ),
        PlatformItemData(
          platform: SocialPlatform.snapchat,
          name: 'Snapchat Spotlight',
          count: snapchatCount,
          limit: snapchatLimit,
          themeColor: AppColors.snapchat,
          glowColor: AppColors.snapchatGlow,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: "Platforms" & "Details"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platforms',
                style: AppTypography.heading(
                  color: AppColors.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticService.subtle();
                  onDetailsTap?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Details',
                    style: AppTypography.body(
                      color: AppColors.primaryAccent,
                    ).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2x2 Grid of Platform Cards
          Row(
            children: [
              Expanded(
                child: _buildPlatformCard(platforms[0]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPlatformCard(platforms[1]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildPlatformCard(platforms[2]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPlatformCard(platforms[3]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(PlatformItemData item) {
    final double fraction = item.limit > 0 ? (item.count / item.limit).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {
        HapticService.light();
        onPlatformTap?.call(item.platform);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: item.glowColor.withValues(alpha: 0.12),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Platform Icon & Progress Ring
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlatformIcon(
                  platform: item.platform,
                  size: 32,
                  useReelsVariant: true,
                ),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CustomPaint(
                    painter: _MiniCircularProgressPainter(
                      progress: fraction,
                      activeColor: item.themeColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Middle Row: 12 / 20
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${item.count}',
                  style: AppTypography.heading(
                    color: AppColors.primaryText,
                  ).copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${item.limit}',
                  style: AppTypography.caption(
                    color: AppColors.secondaryText,
                  ).copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Bottom: Platform Name
            Text(
              item.name,
              style: AppTypography.caption(
                color: AppColors.secondaryText,
              ).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;

  _MiniCircularProgressPainter({
    required this.progress,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.elevatedSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      const startAngle = -1.5708; // -pi/2 (top)
      final sweepAngle = 2 * 3.1415926535 * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
  }
}
