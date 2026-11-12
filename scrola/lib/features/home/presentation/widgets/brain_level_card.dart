import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_card.dart';

class BrainLevelCard extends StatelessWidget {
  final int level;
  final String stageTitle;
  final int currentXp;
  final int targetXp;
  final int nextEvolveLevel;
  final VoidCallback? onRewardsTap;
  final VoidCallback? onCardTap;

  const BrainLevelCard({
    super.key,
    required this.level,
    required this.stageTitle,
    required this.currentXp,
    required this.targetXp,
    required this.nextEvolveLevel,
    this.onRewardsTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeTarget = math.max(1, targetXp);
    final fraction = (currentXp / safeTarget).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Brain level',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading(color: AppColors.primaryText),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticService.subtle();
                onRewardsTap?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Rewards',
                  style: AppTypography.caption(color: AppColors.primaryAccent)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ScrolaCard(
          padding: const EdgeInsets.all(16),
          onTap: () {
            HapticService.subtle();
            onCardTap?.call();
          },
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: _LevelRingPainter(progress: fraction),
                  child: Center(
                    child: Text(
                      '$level',
                      style: AppTypography.numeric(
                        color: AppColors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stageTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subheading(
                        color: AppColors.primaryText,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currentXp / $safeTarget XP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.numeric(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    const BrainyMascot(
                      mood: BrainyMood.happy,
                      size: 38,
                      animate: false,
                      silhouette: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Evolves\nLv $nextEvolveLevel',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(fontSize: 10, height: 1.15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelRingPainter extends CustomPainter {
  final double progress;

  _LevelRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 5;

    final fillPaint = Paint()
      ..color = AppColors.primaryAccent.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    final sweep = (progress <= 0 ? 0.02 : progress) * 2 * math.pi;
    final arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.accentHighlight, AppColors.primaryAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_LevelRingPainter old) => old.progress != progress;
}
