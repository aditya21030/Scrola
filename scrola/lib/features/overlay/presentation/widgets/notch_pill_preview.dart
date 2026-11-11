import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';

class NotchPillPreview extends StatelessWidget {
  final int watched;
  final int remaining;
  final bool expanded;
  final BrainyMood mood;
  final BrainySkin skin;
  final double scale;
  final VoidCallback? onTap;

  const NotchPillPreview({
    super.key,
    required this.watched,
    required this.remaining,
    required this.expanded,
    this.mood = BrainyMood.happy,
    this.skin = BrainySkin.classic,
    this.scale = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pillWidth = (expanded ? 252.0 : 150.0) * scale;
    final pillHeight = (expanded ? 48.0 : 42.0) * scale;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        width: pillWidth,
        height: pillHeight,
        padding: EdgeInsets.symmetric(horizontal: 10 * scale),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.14),
              spreadRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$watched',
                    style: AppTypography.numeric(
                      color: AppColors.primaryText,
                      fontSize: (expanded ? 17 : 15) * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  if (expanded)
                    Text(
                      'watched',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(
                        fontSize: 9.5 * scale,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: BrainyMascot(
                mood: mood,
                skin: skin,
                size: 28 * scale,
                animate: false,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$remaining',
                    style: AppTypography.numeric(
                      color: remaining <= 0
                          ? AppColors.error
                          : AppColors.primaryAccent,
                      fontSize: (expanded ? 17 : 15) * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  if (expanded)
                    Text(
                      'left',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(
                        fontSize: 9.5 * scale,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
