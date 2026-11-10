import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';

class BrainLevelCard extends StatelessWidget {
  final int level;
  final String levelTitle;
  final int currentXP;
  final int targetXP;
  final int nextEvolutionLevel;
  final VoidCallback? onRewardsTap;

  const BrainLevelCard({
    super.key,
    this.level = 4,
    this.levelTitle = 'Curious Cortex',
    this.currentXP = 320,
    this.targetXP = 500,
    this.nextEvolutionLevel = 5,
    this.onRewardsTap,
  });

  @override
  Widget build(BuildContext context) {
    final double xpProgress = (currentXP / targetXP).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Brain level" & "Rewards"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brain level',
                style: AppTypography.heading(
                  color: AppColors.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticService.subtle();
                  onRewardsTap?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Rewards',
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

          // Main Level Progress Card
          GestureDetector(
            onTap: () => HapticService.light(),
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
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Level Badge with Orange Ring
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.4),
                        width: 2.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(3.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentHighlight,
                            AppColors.primaryAccent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$level',
                          style: AppTypography.title(
                            color: AppColors.textOnAccent,
                          ).copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Center Details: Name, XP ratio, progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          levelTitle,
                          style: AppTypography.subheading(
                            color: AppColors.primaryText,
                          ).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$currentXP / $targetXP XP',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                          ).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Linear XP Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            height: 6,
                            color: AppColors.elevatedSurface,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: xpProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryAccent.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Right Side: Silhouette & Evolution note
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/brainy_silhouette.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Evolves\nat Lv $nextEvolutionLevel',
                        style: AppTypography.caption(
                          color: AppColors.mutedText,
                        ).copyWith(
                          fontSize: 10,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
