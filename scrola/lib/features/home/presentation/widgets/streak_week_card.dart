import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_card.dart';

class StreakWeekCard extends StatefulWidget {
  final int streakDays;
  final List<bool> daysCompleted;
  final VoidCallback? onCalendarTap;

  const StreakWeekCard({
    super.key,
    required this.streakDays,
    this.daysCompleted = const [true, true, true, true, true, true, false],
    this.onCalendarTap,
  });

  @override
  State<StreakWeekCard> createState() => _StreakWeekCardState();
}

class _StreakWeekCardState extends State<StreakWeekCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
    final reduceMotion = AppMotion.isReducedMotion(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This week',
              style: AppTypography.heading(color: AppColors.primaryText),
            ),
            GestureDetector(
              onTap: () {
                HapticService.subtle();
                widget.onCalendarTap?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Calendar',
                  style: AppTypography.caption(color: AppColors.primaryAccent)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ScrolaCard(
          padding: const EdgeInsets.all(18),
          onTap: () {
            HapticService.subtle();
            widget.onCalendarTap?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.primaryAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.streakDays} day streak',
                    style: AppTypography.subheading(
                      color: AppColors.primaryText,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(7, (index) {
                  final done = index < widget.daysCompleted.length
                      ? widget.daysCompleted[index]
                      : false;
                  final isToday = index == todayIndex;

                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          dayLetters[index],
                          style: AppTypography.caption(
                            color: isToday
                                ? AppColors.primaryAccent
                                : AppColors.secondaryText,
                          ).copyWith(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final glowAlpha = isToday && !done && !reduceMotion
                                ? 0.15 + 0.25 * _pulseController.value
                                : 0.0;
                            return Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done
                                    ? AppColors.primaryAccent
                                    : Colors.transparent,
                                border: Border.all(
                                  color: done
                                      ? AppColors.primaryAccent
                                      : isToday
                                          ? AppColors.primaryAccent
                                          : AppColors.border,
                                  width: isToday ? 2 : 1.5,
                                ),
                                boxShadow: glowAlpha > 0
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryAccent
                                              .withValues(alpha: glowAlpha),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: done
                                  ? const Center(
                                      child: Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 17,
                                        color: AppColors.textOnAccent,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
