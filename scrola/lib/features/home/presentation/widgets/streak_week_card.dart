import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';

class StreakWeekCard extends StatelessWidget {
  final int streakDays;
  final VoidCallback? onCalendarTap;

  const StreakWeekCard({
    super.key,
    this.streakDays = 7,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: "This week" & "Calendar"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This week',
                style: AppTypography.heading(
                  color: AppColors.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticService.subtle();
                  onCalendarTap?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Calendar',
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

          // Main Streak Card
          GestureDetector(
            onTap: () => HapticService.light(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak count headline with Flame
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.primaryAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$streakDays day streak',
                        style: AppTypography.subheading(
                          color: AppColors.primaryText,
                        ).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Days of the week row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(days.length, (index) {
                      final isCompleted = index < 6; // Monday to Saturday completed
                      final isCurrent = index == 6; // Sunday active

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            days[index],
                            style: AppTypography.caption(
                              color: AppColors.mutedText,
                            ).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildDayDot(
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDot({
    required bool isCompleted,
    required bool isCurrent,
  }) {
    if (isCompleted) {
      // Completed Day: Orange filled circle with subtle drop/flame mark
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.primaryAccent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.textOnAccent.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else if (isCurrent) {
      // Current / Today: Dark circle with orange outline
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryAccent,
            width: 2,
          ),
          color: Colors.transparent,
        ),
      );
    } else {
      // Future Day
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
          color: Colors.transparent,
        ),
      );
    }
  }
}
