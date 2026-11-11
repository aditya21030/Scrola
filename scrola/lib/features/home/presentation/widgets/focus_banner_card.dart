import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';

class FocusBannerCard extends StatelessWidget {
  final bool isFocusActive;
  final String formattedRemainingTime;
  final VoidCallback onStartFocus;

  const FocusBannerCard({
    super.key,
    required this.isFocusActive,
    this.formattedRemainingTime = '25:00',
    required this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.medium();
        onStartFocus();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentHighlight, AppColors.primaryAccent],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: -40,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              right: -12,
              bottom: -14,
              child: const BrainyMascot(
                mood: BrainyMood.focused,
                size: 108,
                animate: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 102, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFocusActive ? 'ACTIVE SESSION' : 'FOCUS',
                    style: AppTypography.label(
                      color: AppColors.textOnAccent.withValues(alpha: 0.72),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isFocusActive
                        ? '$formattedRemainingTime left'
                        : 'Reset for 25\nminutes',
                    style: AppTypography.title(
                      color: AppColors.textOnAccent,
                    ).copyWith(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reels stay blocked until the timer ends.',
                    style: AppTypography.caption(
                      color: AppColors.textOnAccent.withValues(alpha: 0.82),
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.textOnAccent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.primaryText,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isFocusActive ? 'View session' : 'Start focus',
                            style: AppTypography.caption(
                              color: AppColors.primaryText,
                            ).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
